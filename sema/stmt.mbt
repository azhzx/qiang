///|
fn is_name_path(d : @front.Declarator) -> Bool {
  match d {
    @front.DName(_) | @front.DAbstract => true
    _ => false
  }
}

///|
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
pub fn collect_locals(s : TStmt, out : Array[(String, CType, Int)]) -> Unit {
  match s.kind {
    KSBlock(items) =>
      for x in items {
        collect_locals(x, out)
      }
    KSDecl(n, ty, init, al) => {
      out.push((n, ty, al))
      match init {
        Some(e) => collect_expr_locals(e, out)
        None => ()
      }
    }
    KSAggInit(n, ty, stores, al) => {
      out.push((n, ty, al))
      for entry in stores {
        collect_expr_locals(entry.1, out)
      }
    }
    KSExpr(e) =>
      match e {
        Some(x) => collect_expr_locals(x, out)
        None => ()
      }
    KSReturn(e) =>
      match e {
        Some(x) => collect_expr_locals(x, out)
        None => ()
      }
    KSIf(c, t, el) => {
      collect_expr_locals(c, out)
      collect_locals(t, out)
      match el {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    KSWhile(c, b) => {
      collect_expr_locals(c, out)
      collect_locals(b, out)
    }
    KSDoWhile(b, c) => {
      collect_locals(b, out)
      collect_expr_locals(c, out)
    }
    KSFor(i, c, st, b) => {
      match i {
        Some(x) => collect_locals(x, out)
        None => ()
      }
      match c {
        Some(x) => collect_expr_locals(x, out)
        None => ()
      }
      match st {
        Some(x) => collect_expr_locals(x, out)
        None => ()
      }
      collect_locals(b, out)
    }
    KSSwitch(e, cases, d) => {
      collect_expr_locals(e, out)
      for c in cases {
        collect_locals(c.1, out)
      }
      match d {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    KSLabel(_, b) => collect_locals(b, out)
    KSGotoPtr(e) => collect_expr_locals(e, out)
    _ => ()
  }
}

///|
fn collect_expr_locals(e : TExpr, out : Array[(String, CType, Int)]) -> Unit {
  match e.kind {
    TStmtExpr(items) =>
      for s in items {
        collect_locals(s, out)
      }
    TBin(_, l, r) => {
      collect_expr_locals(l, out)
      collect_expr_locals(r, out)
    }
    TUn(_, x) => collect_expr_locals(x, out)
    TAssign(l, r) => {
      collect_expr_locals(l, out)
      collect_expr_locals(r, out)
    }
    TCall(_, c, args) => {
      collect_expr_locals(c, out)
      for a in args {
        collect_expr_locals(a, out)
      }
    }
    TCond(a, b, c) => {
      collect_expr_locals(a, out)
      collect_expr_locals(b, out)
      collect_expr_locals(c, out)
    }
    TCast(x) => collect_expr_locals(x, out)
    TMember(b, _) => collect_expr_locals(b, out)
    TIndex(a, b) => {
      collect_expr_locals(a, out)
      collect_expr_locals(b, out)
    }
    TComma(a, b) => {
      collect_expr_locals(a, out)
      collect_expr_locals(b, out)
    }
    TAddr(x) => collect_expr_locals(x, out)
    TDeref(x) => collect_expr_locals(x, out)
    TSizeofVLA(x) => collect_expr_locals(x, out)
    TCompoundLit(stores) =>
      for entry in stores {
        collect_expr_locals(entry.1, out)
      }
    TVaArg(x) => collect_expr_locals(x, out)
    _ => ()
  }
}

///|

///|
// Complete an array type with an unspecified bound from its initializer.
fn complete_array(ty : CType, init : @front.Initializer, ctx : Ctx) -> CType {
  match (ty, init) {
    (CArray(elem, 0), @front.IList(items)) => {
      let mut n = 0
      let mut idx = 0
      for it in items {
        let k = if it.designators.length() > 0 {
          match it.designators[0] {
            @front.DIndex(e) => const_eval_int(e, ctx).to_int()
            _ => idx
          }
        } else {
          idx
        }
        if k + 1 > n {
          n = k + 1
        }
        idx = idx + 1
      }
      CArray(elem, n)
    }
    _ => ty
  }
}

///|

///|
// A label address (&&l) is a code-generation-time constant, so an initializer
// that contains one cannot be encoded into a global data section.
fn init_has_label_addr(init : @front.Initializer) -> Bool {
  match init {
    @front.IExpr(e) => expr_has_label_addr(e)
    @front.IList(items) => {
      let mut r = false
      for it in items {
        if init_has_label_addr(it.init) {
          r = true
        }
      }
      r
    }
  }
}

///|
fn expr_has_label_addr(e : @front.Expr) -> Bool {
  match e {
    @front.EUnary("&&", _) => true
    @front.EBinary(_, l, r) => expr_has_label_addr(l) || expr_has_label_addr(r)
    @front.EAssign(_, l, r) => expr_has_label_addr(r) || expr_has_label_addr(l)
    @front.EUnary(_, x) => expr_has_label_addr(x)
    @front.EPostfix(_, x) => expr_has_label_addr(x)
    _ => false
  }
}

///|

///|
// Effective alignment of a declaration, taking _Alignas into account.
fn spec_align(spec : @front.DeclSpec, ty : CType, ctx : Ctx) -> Int {
  let mut a = align_of_ty(ty, ctx.layouts)
  for al in spec.align {
    let req = match al {
      @front.AlignExpr(e) => const_eval_int(e, ctx).to_int()
      @front.AlignType(s, d) =>
        align_of_ty(build_type(d, declspec_to_type(s, ctx), ctx), ctx.layouts)
    }
    if req > a {
      a = req
    }
  }
  a
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
    let mut ty = build_type(idecl.decl, base, ctx)
    match idecl.init {
      Some(init) => ty = complete_array(ty, init, ctx)
      None => ()
    }
    let al = spec_align(spec, ty, ctx)
    match decl_name(idecl.decl) {
      Some(n) =>
        if is_td {
          ctx.scopes.define({
            name: n,
            gname: "",
            kind: SymTypedef,
            ty,
            storage: StTypedef,
            value: 0L,
          })
        } else {
          let storage = storage_of(spec)
          let lbl_init = match idecl.init {
            Some(i) => init_has_label_addr(i)
            None => false
          }
          if storage is StStatic && !lbl_init {
            // A static local lives in the data section, keeps its value across
            // calls and is zero-initialised.
            ctx.static_counter = ctx.static_counter + 1
            let gname = "__static_" + n + "_" + ctx.static_counter.to_string()
            let bytes : Array[Byte] = []
            let relocs : Array[(Int, GlobalReloc)] = []
            match idecl.init {
              Some(init) => encode_global_init(init, ty, 0, bytes, relocs, ctx)
              None => ()
            }
            let init0 = match idecl.init {
              Some(@front.IExpr(e)) =>
                if is_const_expr(e, ctx) {
                  Some(const_eval_int(e, ctx))
                } else {
                  None
                }
              _ => None
            }
            ctx.globals.push({
              name: gname,
              ty,
              init: init0,
              bytes,
              relocs,
              is_export: false,
              align: al,
            })
            ctx.scopes.define({
              name: n,
              gname,
              kind: SymVar,
              ty,
              storage,
              value: 0L,
            })
          } else {
            match idecl.init {
              Some(@front.IExpr(e)) => {
                let te = check_expr(e, ctx)
                out.push({ kind: KSDecl(n, ty, Some(te), al), })
              }
              Some(@front.IList(_)) => {
                let stores : Array[(Int, TExpr)] = []
                match idecl.init {
                  Some(init) => check_init_into(init, ty, 0, stores, ctx)
                  None => ()
                }
                out.push({ kind: KSAggInit(n, ty, stores, al), })
              }
              None => out.push({ kind: KSDecl(n, ty, None, al), })
            }
            ctx.scopes.define({
              name: n,
              gname: "",
              kind: SymVar,
              ty,
              storage,
              value: 0L,
            })
          }
        }
      None => ()
    }
  }
}

///|
fn check_init_into(
  init : @front.Initializer,
  ty : CType,
  base_off : Int,
  stores : Array[(Int, TExpr)],
  ctx : Ctx,
) -> Unit {
  match init {
    @front.IExpr(e) => {
      let te = check_expr(e, ctx)
      stores.push((base_off, te))
    }
    @front.IList(items) =>
      match ty {
        CArray(elem, _) => {
          let stride = size_of_ty(elem, ctx.layouts)
          let mut idx = 0
          for it in items {
            let off = if it.designators.length() > 0 {
              match it.designators[0] {
                @front.DIndex(e) => const_eval_int(e, ctx).to_int() * stride
                _ => idx * stride
              }
            } else {
              idx * stride
            }
            check_init_into(it.init, elem, base_off + off, stores, ctx)
            idx = idx + 1
          }
        }
        CStruct(i) => {
          let lay = ctx.layouts[i]
          let mut midx = 0
          for it in items {
            let (moff, mty) = if it.designators.length() > 0 {
              match it.designators[0] {
                @front.DField(n) =>
                  match field_of(lay, n) {
                    Some(f) => (f.offset, f.ty)
                    None => (0, CInt(false))
                  }
                _ => (0, CInt(false))
              }
            } else if midx < lay.fields.length() {
              (lay.fields[midx].offset, lay.fields[midx].ty)
            } else {
              (0, CInt(false))
            }
            check_init_into(it.init, mty, base_off + moff, stores, ctx)
            midx = midx + 1
          }
        }
        CUnion(i) => {
          let lay = ctx.layouts[i]
          if items.length() > 0 && lay.fields.length() > 0 {
            check_init_into(
              items[0].init,
              lay.fields[0].ty,
              base_off + lay.fields[0].offset,
              stores,
              ctx,
            )
          }
        }
        _ =>
          if items.length() > 0 {
            check_init_into(items[0].init, ty, base_off, stores, ctx)
          }
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
fn check_block_item(it : @front.BlockItem, ctx : Ctx) -> TStmt {
  match it {
    @front.BStmt(s) => check_stmt(s, ctx)
    @front.BDecl(spec, decls) => {
      let arr : Array[TStmt] = []
      check_local_decl(spec, decls, ctx, arr)
      { kind: KSBlock(arr), }
    }
  }
}

///|
fn is_case_item(it : @front.BlockItem) -> Bool {
  match it {
    @front.BStmt(s) =>
      match s.kind {
        @front.SCase(_, _) | @front.SCaseRange(_, _, _) | @front.SDefault(_) =>
          true
        _ => false
      }
    _ => false
  }
}

///|
fn check_switch(ctrl : @front.Expr, body : @front.Stmt, ctx : Ctx) -> TStmt {
  let tc = check_expr(ctrl, ctx)
  ctx.switch_depth = ctx.switch_depth + 1
  let cases : Array[(Int64, TStmt)] = []
  let mut dflt : TStmt? = None
  match body.kind {
    @front.SCompound(items) => {
      let mut i = 0
      let n = items.length()
      while i < n {
        if is_case_item(items[i]) {
          let arr : Array[TStmt] = []
          let vals : Array[Int64] = []
          let mut is_default = false
          match items[i] {
            @front.BStmt(sc) =>
              match sc.kind {
                @front.SCase(e, st) => {
                  vals.push(const_eval_int(e, ctx))
                  match st {
                    Some(x) => arr.push(check_stmt(x, ctx))
                    None => ()
                  }
                }
                @front.SCaseRange(lo, hi, st) => {
                  let a = const_eval_int(lo, ctx)
                  let b = const_eval_int(hi, ctx)
                  let mut v = a
                  while v <= b {
                    vals.push(v)
                    v = v + 1L
                  }
                  match st {
                    Some(x) => arr.push(check_stmt(x, ctx))
                    None => ()
                  }
                }
                @front.SDefault(st) => {
                  is_default = true
                  match st {
                    Some(x) => arr.push(check_stmt(x, ctx))
                    None => ()
                  }
                }
                _ => ()
              }
            _ => ()
          }
          let mut j = i + 1
          while j < n && !is_case_item(items[j]) {
            arr.push(check_block_item(items[j], ctx))
            j = j + 1
          }
          let block : TStmt = { kind: KSBlock(arr), }
          if is_default {
            dflt = Some(block)
          } else {
            for v in vals {
              cases.push((v, block))
            }
          }
          i = j
        } else {
          let _ = check_block_item(items[i], ctx)
          i = i + 1
        }
      }
    }
    _ => {
      let _ = check_stmt(body, ctx)
    }
  }
  ctx.switch_depth = ctx.switch_depth - 1
  { kind: KSSwitch(tc, cases, dflt), }
}

///|
fn check_return(e : @front.Expr?, ctx : Ctx) -> TStmt {
  let te = match e {
    Some(x) => Some(check_expr(x, ctx))
    None => None
  }
  let is_void = match ctx.ret_ty {
    Some(CVoid) => true
    None => true
    _ => false
  }
  match (ctx.ret_ty, te) {
    (Some(CVoid), Some(_)) =>
      ctx.diags.error("return with a value in a void function")
    _ => ()
  }
  { kind: KSReturn(te), }
}

///|
pub fn check_stmt(s : @front.Stmt, ctx : Ctx) -> TStmt {
  ctx.diags.cur_line = s.pos.line
  ctx.diags.cur_col = s.pos.col
  match s.kind {
    @front.SCompound(items) => {
      ctx.scopes.push()
      let body = check_block_items(items, ctx)
      ctx.scopes.pop()
      { kind: KSBlock(body), }
    }
    @front.SExpr(Some(e)) => { kind: KSExpr(Some(check_expr(e, ctx))), }
    @front.SExpr(None) => { kind: KSEmpty, }
    @front.SReturn(e) => check_return(e, ctx)
    @front.SIf(c, t, el) => {
      let tc = check_expr(c, ctx)
      let tt = check_stmt(t, ctx)
      let tf = match el {
        Some(x) => Some(check_stmt(x, ctx))
        None => None
      }
      { kind: KSIf(tc, tt, tf), }
    }
    @front.SWhile(c, b) => {
      let tc = check_expr(c, ctx)
      ctx.loop_depth = ctx.loop_depth + 1
      let tb = check_stmt(b, ctx)
      ctx.loop_depth = ctx.loop_depth - 1
      { kind: KSWhile(tc, tb), }
    }
    @front.SDoWhile(b, c) => {
      ctx.loop_depth = ctx.loop_depth + 1
      let tb = check_stmt(b, ctx)
      ctx.loop_depth = ctx.loop_depth - 1
      { kind: KSDoWhile(tb, check_expr(c, ctx)), }
    }
    @front.SFor(init, cond, step, b) => {
      ctx.scopes.push()
      ctx.loop_depth = ctx.loop_depth + 1
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
      ctx.loop_depth = ctx.loop_depth - 1
      ctx.scopes.pop()
      { kind: KSFor(ti, tc, ts, tb), }
    }
    @front.SBreak => {
      if ctx.loop_depth + ctx.switch_depth == 0 {
        ctx.diags.error("break outside of a loop or switch")
      }
      { kind: KSBreak, }
    }
    @front.SContinue => {
      if ctx.loop_depth == 0 {
        ctx.diags.error("continue outside of a loop")
      }
      { kind: KSContinue, }
    }
    @front.SGoto(n) => {
      ctx.gotos.push(n)
      { kind: KSGoto(n), }
    }
    @front.SGotoPtr(e) => { kind: KSGotoPtr(check_expr(e, ctx)), }
    @front.SLabel(n, st) => {
      ctx.labels.set(n, true)
      let tb = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      { kind: KSLabel(n, tb), }
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
    @front.SSwitch(ctrl, body) => check_switch(ctrl, body, ctx)
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
