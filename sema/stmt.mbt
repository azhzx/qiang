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
          match idecl.init {
            Some(@front.IExpr(e)) => {
              let te = check_expr(e, ctx)
              out.push({ kind: KSDecl(n, ty, Some(te)), })
            }
            Some(@front.IList(_)) => {
              let stores : Array[(Int, TExpr)] = []
              match idecl.init {
                Some(init) => check_init_into(init, ty, 0, stores, ctx)
                None => ()
              }
              out.push({ kind: KSAggInit(n, ty, stores), })
            }
            None => out.push({ kind: KSDecl(n, ty, None), })
          }
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
