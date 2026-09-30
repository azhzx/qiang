///|
fn is_name_path(d : @front.Declarator) -> Bool {
  match d {
    @front.DName(_) | @front.DAbstract => true
    _ => false
  }
}

///|
/// Find the parameter list of a function declarator on the path to the name.
pub fn func_params(d : @front.Declarator) -> Array[@front.ParamDecl] {
  match d {
    @front.DFunction(inner, params, _) =>
      if is_name_path(inner) {
        params
      } else {
        func_params(inner)
      }
    @front.DPointer(_, inner) => func_params(inner)
    @front.DArray(inner, _, _) => func_params(inner)
    _ => []
  }
}

///|
fn check_local_decl(
  spec : @front.DeclSpec,
  decls : Array[@front.InitDeclarator],
  ctx : Ctx,
  out : Array[TStmt],
) -> Unit {
  let base = declspec_to_type(spec, ctx)
  let is_td = has_storage(spec, "typedef")
  for idecl in decls {
    let ty = build_type(idecl.decl, base, ctx)
    match decl_name(idecl.decl) {
      Some(n) =>
        if is_td {
          ctx.scopes.define({
            name: n,
            kind: SymTypedef,
            ty,
            storage: StTypedef,
            value: 0L,
          })
        } else {
          let init = match idecl.init {
            Some(@front.IExpr(e)) => Some(check_expr(e, ctx))
            Some(_) => {
              ctx.diags.error("aggregate initializers are not supported yet")
              None
            }
            None => None
          }
          out.push({ kind: KSDecl(n, ty, init), })
          ctx.scopes.define({
            name: n,
            kind: SymVar,
            ty,
            storage: storage_of(spec),
            value: 0L,
          })
        }
      None => ()
    }
  }
}

///|
pub fn check_block_items(
  items : Array[@front.BlockItem],
  ctx : Ctx,
) -> Array[TStmt] {
  let out : Array[TStmt] = []
  for it in items {
    match it {
      @front.BStmt(s) => out.push(check_stmt(s, ctx))
      @front.BDecl(spec, decls) => check_local_decl(spec, decls, ctx, out)
    }
  }
  out
}

///|
pub fn check_stmt(s : @front.Stmt, ctx : Ctx) -> TStmt {
  match s {
    @front.SCompound(items) => {
      ctx.scopes.push()
      let body = check_block_items(items, ctx)
      ctx.scopes.pop()
      { kind: KSBlock(body), }
    }
    @front.SExpr(Some(e)) => { kind: KSExpr(Some(check_expr(e, ctx))), }
    @front.SExpr(None) => { kind: KSEmpty, }
    @front.SReturn(e) => {
      let te = match e {
        Some(x) => Some(check_expr(x, ctx))
        None => None
      }
      { kind: KSReturn(te), }
    }
    @front.SIf(c, t, el) => {
      let tc = check_expr(c, ctx)
      let tt = check_stmt(t, ctx)
      let tf = match el {
        Some(x) => Some(check_stmt(x, ctx))
        None => None
      }
      { kind: KSIf(tc, tt, tf), }
    }
    @front.SWhile(c, b) =>
      { kind: KSWhile(check_expr(c, ctx), check_stmt(b, ctx)), }
    @front.SDoWhile(b, c) =>
      { kind: KSDoWhile(check_stmt(b, ctx), check_expr(c, ctx)), }
    @front.SFor(init, cond, step, b) => {
      ctx.scopes.push()
      let ti = match init {
        Some(@front.FDecl(spec, decls)) => {
          let arr : Array[TStmt] = []
          check_local_decl(spec, decls, ctx, arr)
          Some({ kind: KSBlock(arr), })
        }
        Some(@front.FExpr(e)) =>
          Some({ kind: KSExpr(Some(check_expr(e, ctx))), })
        None => None
      }
      let tc = match cond {
        Some(e) => Some(check_expr(e, ctx))
        None => None
      }
      let ts = match step {
        Some(e) => Some(check_expr(e, ctx))
        None => None
      }
      let tb = check_stmt(b, ctx)
      ctx.scopes.pop()
      { kind: KSFor(ti, tc, ts, tb), }
    }
    @front.SBreak => { kind: KSBreak, }
    @front.SContinue => { kind: KSContinue, }
    @front.SGoto(n) => { kind: KSGoto(n), }
    @front.SLabel(n, st) => {
      let _ = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      { kind: KSLabel(n), }
    }
    @front.SEmpty => { kind: KSEmpty, }
    @front.SDecl(spec, decls) => {
      let arr : Array[TStmt] = []
      check_local_decl(spec, decls, ctx, arr)
      { kind: KSBlock(arr), }
    }
    @front.SStaticAssert(e, _msg) => {
      if const_eval_int(e, ctx) == 0L {
        ctx.diags.error("static assertion failed")
      }
      { kind: KSEmpty, }
    }
    @front.SSwitch(ctrl, body) => {
      let _ = check_expr(ctrl, ctx)
      let tb = check_stmt(body, ctx)
      { kind: KSBlock([tb]), }
    }
    @front.SCase(_, st) =>
      match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
    @front.SCaseRange(_, _, st) =>
      match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
    @front.SDefault(st) =>
      match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
    _ => { kind: KSEmpty, }
  }
}
