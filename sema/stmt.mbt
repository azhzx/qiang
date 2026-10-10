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
    KSSwitch(e, cases, d, _) => {
      collect_expr_locals(e, out)
      for c in cases {
        collect_locals(c.1, out)
      }
      match d {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    KSCaseMark(_, _, b) => collect_locals(b, out)
    KSLabel(_, b) => collect_locals(b, out)
    KSGotoPtr(e) => collect_expr_locals(e, out)
    // A _Defer body can declare locals of its own.
    KSDefer(b) => collect_locals(b, out)
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
    if req > 16 {
      ctx.diags.error(
        "alignment greater than 16 is unsupported by the QBE stack ABI",
      )
    } else if req > a {
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
  let auto_ty = has_auto_type(spec)
  let is_td = has_storage(spec, "typedef")
  for idecl in decls {
    let b = if auto_ty { infer_auto_type(decls, idecl, ctx) } else { base }
    let mut ty = build_type(idecl.decl, b, ctx)
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
        } else if ty is CVoid {
          // QPCC: `void x = f();` declares no object. The initializer is
          // evaluated for its side effects and its value discarded, exactly as
          // if the expression had been written as a statement of its own.
          // `void x;` has nothing to evaluate and stays an error.
          match idecl.init {
            Some(@front.IExpr(e)) => {
              let te = check_expr(e, ctx)
              out.push({ kind: KSExpr(Some(te)), })
            }
            _ =>
              ctx.diags.error("variable '" + n + "' has incomplete type 'void'")
          }
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
            let is_cexpr = has_qualifier(spec, "constexpr")
            ctx.scopes.define({
              name: n,
              gname,
              kind: if is_cexpr {
                SymConstVar
              } else {
                SymVar
              },
              ty,
              storage,
              value: match init0 {
                Some(v) => v
                None => 0L
              },
            })
          } else {
            match idecl.init {
              Some(@front.IExpr(e)) => {
                let te = check_expr(e, ctx)
                out.push({ kind: KSDecl(n, ty, Some(te), al), })
              }
              Some(@front.IList(_)) => {
                let stores : Array[(Int, TExpr, Int, Int)] = []
                match idecl.init {
                  Some(init) => check_init_into(init, ty, 0, stores, ctx)
                  None => ()
                }
                out.push({ kind: KSAggInit(n, ty, stores, al), })
              }
              None => out.push({ kind: KSDecl(n, ty, None, al), })
            }
            let is_cexpr = has_qualifier(spec, "constexpr")
            let cval : Int64 = if is_cexpr {
              match idecl.init {
                Some(@front.IExpr(e)) =>
                  if is_const_expr(e, ctx) {
                    const_eval_int(e, ctx)
                  } else {
                    ctx.diags.error(
                      "constexpr initializer is not a constant expression",
                    )
                    0L
                  }
                _ => {
                  ctx.diags.error("constexpr requires a constant initializer")
                  0L
                }
              }
            } else {
              0L
            }
            ctx.scopes.define({
              name: n,
              gname: "",
              kind: if is_cexpr {
                SymConstVar
              } else {
                SymVar
              },
              ty,
              storage,
              value: cval,
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
  stores : Array[(Int, TExpr, Int, Int)],
  ctx : Ctx,
) -> Unit {
  match init {
    @front.IExpr(e) => {
      let te = check_expr(e, ctx)
      // The element may need narrowing (e.g. the bytes of a char array
      // compound literal); store it already converted so the element size is
      // used when writing.
      let v = if is_scalar(ty) && !ty_eq(te.ty, ty) {
        mk_expr(TCast(te), ty, false)
      } else {
        te
      }
      stores.push((base_off, v, 0, 0))
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
        CStruct(i) if ctx.layouts[i].tagged => {
          let lay = ctx.layouts[i]
          if items.length() == 0 {
            ctx.diags.error(
              "_Tagged_union initialization needs a member designator",
            )
          } else {
            let mut last_tag : Int64? = None
            for it in items {
              if it.designators.length() > 0 {
                match it.designators[0] {
                  @front.DField(n) =>
                    match tag_of(lay, n) {
                      Some(tv) =>
                        match field_of(lay, n) {
                          Some(f) => {
                            last_tag = Some(tv)
                            check_init_into(
                              it.init,
                              f.ty,
                              base_off + lay.payload_off + f.offset,
                              stores,
                              ctx,
                            )
                          }
                          None => ()
                        }
                      None =>
                        ctx.diags.error("no _Tagged_union member named " + n)
                    }
                  _ =>
                    ctx.diags.error(
                      "_Tagged_union initialization needs a member designator",
                    )
                }
              } else {
                ctx.diags.error(
                  "_Tagged_union initialization needs a member designator",
                )
              }
            }
            match last_tag {
              Some(tv) =>
                stores.push(
                  (base_off, mk_expr(TInt(tv), CInt(true), false), 0, 0),
                )
              None => ()
            }
          }
        }
        CStruct(i) => {
          let lay = ctx.layouts[i]
          let mut midx = 0
          for it in items {
            let (moff, mty, mbo, mbw) = if it.designators.length() > 0 {
              match it.designators[0] {
                @front.DField(n) =>
                  match field_of(lay, n) {
                    Some(f) => (f.offset, f.ty, f.bit_offset, f.bit_width)
                    None => (0, CInt(false), 0, 0)
                  }
                _ => (0, CInt(false), 0, 0)
              }
            } else if midx < lay.fields.length() {
              let f = lay.fields[midx]
              (f.offset, f.ty, f.bit_offset, f.bit_width)
            } else {
              (0, CInt(false), 0, 0)
            }
            if mbw > 0 {
              match it.init {
                @front.IExpr(e) => {
                  let te = check_expr(e, ctx)
                  let v = if is_scalar(mty) && !ty_eq(te.ty, mty) {
                    mk_expr(TCast(te), mty, false)
                  } else {
                    te
                  }
                  stores.push((base_off + moff, v, mbo, mbw))
                }
                _ => check_init_into(it.init, mty, base_off + moff, stores, ctx)
              }
            } else {
              check_init_into(it.init, mty, base_off + moff, stores, ctx)
            }
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
fn sw_is_mark(st : TStmt) -> Bool {
  match st.kind {
    KSCaseMark(_, _, _) => true
    _ => false
  }
}

///|
/// Registers every case label reachable from `st`, at any nesting depth. A
/// label whose statement is nested must be found just the same as a top-level
/// one, because jumping to it skips the enclosing condition; the Duff device
/// in a switch-heavy parser is the pattern that needs this.
fn sw_collect_one(
  st : TStmt,
  cases : Array[(Int64, TStmt)],
  dflt : Array[TStmt?],
  dfpos : Array[Int],
) -> Unit {
  match st.kind {
    KSBlock(ss) => sw_collect(ss, cases, dflt, dfpos)
    KSIf(_, a, b) => {
      sw_collect_one(a, cases, dflt, dfpos)
      match b {
        Some(x) => sw_collect_one(x, cases, dflt, dfpos)
        None => ()
      }
    }
    KSWhile(_, b) => sw_collect_one(b, cases, dflt, dfpos)
    KSDoWhile(b, _) => sw_collect_one(b, cases, dflt, dfpos)
    KSFor(_, _, _, b) => sw_collect_one(b, cases, dflt, dfpos)
    KSLabel(_, b) => sw_collect_one(b, cases, dflt, dfpos)
    KSSwitch(_, _, _, _) => ()
    _ => ()
  }
}

///|
/// Walks one statement list in source order. A label becomes an entry whose
/// block runs from the label up to the next label in the same list, so the
/// fall-through between the generated case blocks reproduces the fall-through
/// in the source.
fn sw_collect(
  ss : Array[TStmt],
  cases : Array[(Int64, TStmt)],
  dflt : Array[TStmt?],
  dfpos : Array[Int],
) -> Unit {
  let n = ss.length()
  let mut i = 0
  while i < n {
    match ss[i].kind {
      KSCaseMark(vals, is_def, inner) => {
        let blk : Array[TStmt] = [inner]
        let mut j = i + 1
        while j < n && !sw_is_mark(ss[j]) {
          blk.push(ss[j])
          j = j + 1
        }
        let block : TStmt = { kind: KSBlock(blk), }
        if is_def {
          dflt[0] = Some(block)
          dfpos[0] = cases.length()
        } else {
          for v in vals {
            cases.push((v, block))
          }
        }
        sw_collect_one(inner, cases, dflt, dfpos)
      }
      _ => sw_collect_one(ss[i], cases, dflt, dfpos)
    }
    i = i + 1
  }
}

///|
// C2y named loops: the innermost enclosing breakable/continuable construct
// whose label is `l`, as a frame-skip count (0 == innermost).
fn check_jump_out_of_defer(ctx : Ctx) -> Unit {
  if ctx.defer_depth > 0 {
    ctx.diags.error("cannot jump out of a _Defer statement")
  }
}

///|
fn find_label(stack : Array[Array[String]], l : String) -> Int? {
  let mut i = stack.length()
  while i > 0 {
    i = i - 1
    for x in stack[i] {
      if x == l {
        return Some(stack.length() - 1 - i)
      }
    }
  }
  None
}

///|
// Consume the label a preceding `label:` left for the next loop/switch.
fn take_labels(ctx : Ctx) -> Array[String] {
  let ls = ctx.label_pending.copy()
  ctx.label_pending.clear()
  ls
}

///|
// Does this statement (possibly through a chain of labels) name a loop or
// switch? N3355 names only the immediate syntactic operand.
fn names_loop_or_switch(s : @front.Stmt) -> Bool {
  match s.kind {
    @front.SFor(_, _, _, _)
    | @front.SWhile(_, _)
    | @front.SDoWhile(_, _)
    | @front.SSwitch(_, _) => true
    @front.SLabel(_, Some(x)) => names_loop_or_switch(x)
    _ => false
  }
}

///|
fn check_switch(ctrl : @front.Expr, body : @front.Stmt, ctx : Ctx) -> TStmt {
  let tc = check_expr(ctrl, ctx)
  let lbls = take_labels(ctx)
  ctx.switch_depth = ctx.switch_depth + 1
  ctx.break_labels.push(lbls)
  let stmts : Array[TStmt] = match body.kind {
    @front.SCompound(items) => check_block_items(items, ctx)
    _ => [check_stmt(body, ctx)]
  }
  let cases : Array[(Int64, TStmt)] = []
  let dflt : Array[TStmt?] = [None]
  let dfpos : Array[Int] = [cases.length()]
  sw_collect(stmts, cases, dflt, dfpos)
  let _ = ctx.break_labels.pop()
  ctx.switch_depth = ctx.switch_depth - 1
  { kind: KSSwitch(tc, cases, dflt[0], dfpos[0]), }
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
    @front.SReturn(e) => {
      check_jump_out_of_defer(ctx)
      check_return(e, ctx)
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
    @front.SWhile(c, b) => {
      let tc = check_expr(c, ctx)
      let lbls = take_labels(ctx)
      ctx.loop_depth = ctx.loop_depth + 1
      ctx.break_labels.push(lbls)
      ctx.cont_labels.push(lbls)
      let tb = check_stmt(b, ctx)
      let _ = ctx.cont_labels.pop()
      let _ = ctx.break_labels.pop()
      ctx.loop_depth = ctx.loop_depth - 1
      { kind: KSWhile(tc, tb), }
    }
    @front.SDoWhile(b, c) => {
      let lbls = take_labels(ctx)
      ctx.loop_depth = ctx.loop_depth + 1
      ctx.break_labels.push(lbls)
      ctx.cont_labels.push(lbls)
      let tb = check_stmt(b, ctx)
      let _ = ctx.cont_labels.pop()
      let _ = ctx.break_labels.pop()
      ctx.loop_depth = ctx.loop_depth - 1
      { kind: KSDoWhile(tb, check_expr(c, ctx)), }
    }
    @front.SFor(init, cond, step, b) => {
      let lbls = take_labels(ctx)
      ctx.scopes.push()
      ctx.loop_depth = ctx.loop_depth + 1
      ctx.break_labels.push(lbls)
      ctx.cont_labels.push(lbls)
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
      let _ = ctx.cont_labels.pop()
      let _ = ctx.break_labels.pop()
      ctx.loop_depth = ctx.loop_depth - 1
      ctx.scopes.pop()
      { kind: KSFor(ti, tc, ts, tb), }
    }
    @front.SBreak(n) => {
      check_jump_out_of_defer(ctx)
      let d = match n {
        None => {
          if ctx.loop_depth + ctx.switch_depth == 0 {
            ctx.diags.error("break outside of a loop or switch")
          }
          0
        }
        Some(l) =>
          match find_label(ctx.break_labels, l) {
            Some(d) => d
            None => {
              ctx.diags.error(
                "break label '" + l + "' is not a loop or switch label",
              )
              0
            }
          }
      }
      { kind: KSBreak(d), }
    }
    @front.SContinue(n) => {
      check_jump_out_of_defer(ctx)
      let d = match n {
        None => {
          if ctx.loop_depth == 0 {
            ctx.diags.error("continue outside of a loop")
          }
          0
        }
        Some(l) =>
          match find_label(ctx.cont_labels, l) {
            Some(d) => d
            None => {
              ctx.diags.error("continue label '" + l + "' is not a loop label")
              0
            }
          }
      }
      { kind: KSContinue(d), }
    }
    @front.SGoto(n) => {
      check_jump_out_of_defer(ctx)
      ctx.gotos.push(n)
      { kind: KSGoto(n), }
    }
    @front.SGotoPtr(e) => {
      check_jump_out_of_defer(ctx)
      { kind: KSGotoPtr(check_expr(e, ctx)), }
    }
    @front.SLabel(n, st) => {
      ctx.labels.set(n, true)
      // N3355: a label directly on a loop or switch names it for break/continue.
      let is_loopish = match st {
        Some(x) => names_loop_or_switch(x)
        None => false
      }
      let old_len = ctx.label_pending.length()
      if is_loopish {
        ctx.label_pending.push(n)
      }
      let tb = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      while ctx.label_pending.length() > old_len {
        let _ = ctx.label_pending.pop()
      }
      { kind: KSLabel(n, tb), }
    }
    @front.SDefer(st) => {
      ctx.defer_depth = ctx.defer_depth + 1
      let tb = check_stmt(st, ctx)
      ctx.defer_depth = ctx.defer_depth - 1
      { kind: KSDefer(tb), }
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
    @front.SCase(e, st) => {
      let inner = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      { kind: KSCaseMark([const_eval_int(e, ctx)], false, inner), }
    }
    @front.SCaseRange(lo, hi, st) => {
      let vals : Array[Int64] = []
      let a = const_eval_int(lo, ctx)
      let b = const_eval_int(hi, ctx)
      let mut v = a
      while v <= b {
        vals.push(v)
        v = v + 1L
      }
      let inner = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      { kind: KSCaseMark(vals, false, inner), }
    }
    @front.SDefault(st) => {
      let inner = match st {
        Some(x) => check_stmt(x, ctx)
        None => { kind: KSEmpty, }
      }
      { kind: KSCaseMark([], true, inner), }
    }
    _ => { kind: KSEmpty, }
  }
}
