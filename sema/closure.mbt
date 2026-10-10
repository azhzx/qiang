///|
// QPCC closures.
//
// A _Lambda expression builds a two-word value { fn, env }:
//
//   struct { ret (*fn)(env *, params...); env *env; }
//
// env is a synthesized struct with one field per capture, in capture order: a
// by-value capture stores the variable's value at creation time, a
// by-reference capture stores its address. The body becomes a hidden function
// that takes the environment as an extra leading parameter; inside it a
// capture name is bound to its environment field, so a by-value capture reads
// and writes the copy and a by-reference capture is the stored pointer.
//
// The environment lives in the enclosing function's frame, so a closure that
// outlives the scope it was created in is undefined behaviour.

///|
/// Synthesize the environment layout for a capture list and return its index
/// plus each field's offset.
fn env_layout(
  ctx : Ctx,
  caps : Array[@front.Capture],
  types : Array[CType],
) -> (Int, Array[Int]) {
  let fields : Array[Field] = []
  let offs : Array[Int] = []
  let mut off = 0
  let mut maxa = 1
  for i in 0..<caps.length() {
    let c = caps[i]
    let ty = if c.by_ref { CPtr(types[i]) } else { types[i] }
    let a = align_of_ty(ty, ctx.layouts)
    let sz = size_of_ty(ty, ctx.layouts)
    if a > maxa {
      maxa = a
    }
    let o = align_up(off, a)
    off = o + sz
    offs.push(o)
    fields.push({ name: c.name, ty, offset: o, bit_width: 0, bit_offset: 0, })
  }
  let id = ctx.layouts.length()
  ctx.layouts.push({
    name: "__closure_env_" + id.to_string(),
    is_union: false,
    fields,
    size: align_up(off, maxa),
    align: maxa,
    enum_vals: [],
    enum_ty: None,
    tagged: false,
    payload_off: 0,
    tag_vals: [],
  })
  (id, offs)
}

///|
/// `_Lambda(a, &b) T (params) { body }`: one hidden function plus the value
/// that pairs it with its captured environment.
fn check_lambda(
  caps : Array[@front.Capture],
  ret : @front.DeclSpec,
  params : Array[@front.ParamDecl],
  va : Bool,
  body : @front.Stmt,
  ctx : Ctx,
) -> TExpr {
  // Resolve the captures in the enclosing scope. The source expression is the
  // captured variable seen from the enclosing function, so code generation can
  // load it (by value) or take its address (by reference) at the creation site.
  let cap_tys : Array[CType] = []
  let cap_srcs : Array[TExpr] = []
  for c in caps {
    match ctx.scopes.lookup(c.name) {
      Some(s) =>
        match s.kind {
          SymVar => {
            cap_tys.push(s.ty)
            cap_srcs.push(mk_expr(TVar(c.name), s.ty, true))
          }
          _ => {
            ctx.diags.error("cannot capture '" + c.name + "': not a variable")
            cap_tys.push(CInt(false))
            cap_srcs.push(err_expr(ctx))
          }
        }
      None => {
        ctx.diags.error("cannot capture '" + c.name + "': not declared")
        cap_tys.push(CInt(false))
        cap_srcs.push(err_expr(ctx))
      }
    }
  }
  let (env_id, offs) = env_layout(ctx, caps, cap_tys)
  let rt = declspec_to_type(ret, ctx)
  let ptypes : Array[CType] = []
  let hidden_params : Array[(String, CType)] = []
  let self_name = "$closure_self"
  let env_ptr_ty = CPtr(CStruct(env_id))
  hidden_params.push((self_name, env_ptr_ty))
  // Check the body as a function of its own: the enclosing locals are not in
  // scope, only the captures and the lambda's own parameters.
  let saved_params = ctx.cur_params
  let saved_locals = ctx.cur_locals
  let saved_ret = ctx.ret_ty
  let saved_loop = ctx.loop_depth
  let saved_switch = ctx.switch_depth
  let saved_gotos = ctx.gotos
  let saved_labels = ctx.labels
  ctx.scopes.push()
  ctx.cur_params = []
  ctx.cur_locals = []
  ctx.ret_ty = Some(rt)
  ctx.loop_depth = 0
  ctx.switch_depth = 0
  ctx.gotos = []
  ctx.labels = Map::new()
  for i in 0..<caps.length() {
    ctx.scopes.define({
      name: caps[i].name,
      gname: "",
      kind: SymVar,
      // A by-reference capture keeps the pointer the environment stores.
      ty: if caps[i].by_ref {
        CPtr(cap_tys[i])
      } else {
        cap_tys[i]
      },
      storage: StNone,
      value: 0L,
    })
  }
  for pd in params {
    let pb = declspec_to_type(pd.spec, ctx)
    let pty0 = build_type(pd.decl, pb, ctx)
    // Parameters of function or array type are adjusted to pointers.
    let pty = match pty0 {
      CFunc(_, _, _) => CPtr(pty0)
      CArray(e, _) => CPtr(e)
      _ => pty0
    }
    ptypes.push(pty)
    match decl_name(pd.decl) {
      Some(pn) => {
        ctx.cur_params.push((pn, pty))
        hidden_params.push((pn, pty))
        ctx.scopes.define({
          name: pn,
          gname: "",
          kind: SymVar,
          ty: pty,
          storage: StNone,
          value: 0L,
        })
      }
      None => ()
    }
  }
  let tb = check_stmt(body, ctx)
  for g in ctx.gotos {
    if !ctx.labels.contains(g) {
      ctx.diags.error("goto to undefined label: " + g)
    }
  }
  collect_locals(tb, ctx.cur_locals)
  let lam_params = ctx.cur_params
  let lam_locals = ctx.cur_locals
  ctx.scopes.pop()
  ctx.cur_params = saved_params
  ctx.cur_locals = saved_locals
  ctx.ret_ty = saved_ret
  ctx.loop_depth = saved_loop
  ctx.switch_depth = saved_switch
  ctx.gotos = saved_gotos
  ctx.labels = saved_labels
  // The hidden function, appended before the value that refers to it.
  let hidden_name = "__lambda_" + ctx.funcs.length().to_string()
  let hidden_ptypes : Array[CType] = [env_ptr_ty]
  for t in ptypes {
    hidden_ptypes.push(t)
  }
  let cap_infos : Array[ClosureCapture] = []
  for i in 0..<caps.length() {
    cap_infos.push({
      name: caps[i].name,
      off: offs[i],
      ty: if caps[i].by_ref {
        CPtr(cap_tys[i])
      } else {
        cap_tys[i]
      },
    })
  }
  ctx.funcs.push({
    name: hidden_name,
    ty: CFunc(rt, hidden_ptypes, va),
    params: hidden_params,
    locals: lam_locals,
    is_vararg: va,
    is_export: false,
    body: tb,
    closure: Some({ self_name, captures: cap_infos, }),
  })
  let fields : Array[(Int, TExpr, Bool)] = []
  for i in 0..<caps.length() {
    fields.push((offs[i], cap_srcs[i], caps[i].by_ref))
  }
  mk_expr(
    TLambda(hidden_name, env_id, fields),
    CClosure(rt, ptypes, env_id),
    false,
  )
}

///|
/// `_Closure_environment(e)`: the environment pointer half of a closure value.
fn check_closure_env(e : @front.Expr, ctx : Ctx) -> TExpr {
  let te = check_expr(e, ctx)
  match te.ty {
    CClosure(_, _, env) =>
      if env < 0 {
        ctx.diags.error(
          "_Closure_environment needs a closure whose captured environment is known; give the variable the type of a _Lambda expression",
        )
        err_expr(ctx)
      } else {
        mk_expr(TClosureEnv(te), CPtr(CStruct(env)), false)
      }
    _ => {
      ctx.diags.error("_Closure_environment needs a closure")
      err_expr(ctx)
    }
  }
}
