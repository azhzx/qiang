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
pub fn collect_locals(s : TStmt, out : Array[(String, CType)]) -> Unit {
  match s.kind {
    KSDecl(n, ty, _) => out.push((n, ty))
    KSAggInit(n, ty, _) => out.push((n, ty))
    KSBlock(items) =>
      for x in items {
        collect_locals(x, out)
      }
    KSIf(_, t, el) => {
      collect_locals(t, out)
      match el {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    KSWhile(_, b) => collect_locals(b, out)
    KSDoWhile(b, _) => collect_locals(b, out)
    KSFor(i, _, _, b) => {
      match i {
        Some(x) => collect_locals(x, out)
        None => ()
      }
      collect_locals(b, out)
    }
    KSSwitch(_, cases, d) => {
      for c in cases {
        collect_locals(c.1, out)
      }
      match d {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    KSExpr(Some(e)) => collect_in_expr(e, out)
    KSReturn(Some(e)) => collect_in_expr(e, out)
    _ => ()
  }
}

///|
fn collect_in_expr(e : TExpr, out : Array[(String, CType)]) -> Unit {
  match e.kind {
    TStmtExpr(items) =>
      for s in items {
        collect_locals(s, out)
      }
    _ => ()
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
      match st {
        Some(x) => {
          let _ = check_stmt(x, ctx)
        }
        None => ()
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
