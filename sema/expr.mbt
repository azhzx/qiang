///|
fn mk_expr(kind : TExprKind, ty : CType, lvalue : Bool) -> TExpr {
  { kind, ty, lvalue, }
}

///|
fn err_expr(ctx : Ctx) -> TExpr {
  mk_expr(TInt(0L), CInt(false), false)
}

///|
fn is_long_long_ty(t : CType) -> Bool {
  match t {
    CLongLong(_) => true
    _ => false
  }
}

///|
fn is_long_ty(t : CType) -> Bool {
  match t {
    CLong(_) => true
    _ => false
  }
}

///|
fn promote_arith(a : CType, b : CType) -> CType {
  if ty_eq(a, CDouble) || ty_eq(b, CDouble) {
    CDouble
  } else if ty_eq(a, CFloat) || ty_eq(b, CFloat) {
    CFloat
  } else if is_long_long_ty(a) || is_long_long_ty(b) {
    CLongLong(is_signed(a) && is_signed(b))
  } else if is_long_ty(a) || is_long_ty(b) {
    CLong(is_signed(a) && is_signed(b))
  } else {
    CInt(is_signed(a) && is_signed(b))
  }
}

///|
fn is_func_ty(t : CType) -> Bool {
  match t {
    CFunc(_, _, _) => true
    _ => false
  }
}

///|
/// Common type of a conditional expression.
pub fn common_type(a : CType, b : CType) -> CType {
  if ty_eq(a, b) {
    a
  } else if is_func_ty(a) {
    decay(a)
  } else if is_func_ty(b) {
    decay(b)
  } else if is_arith(a) && is_arith(b) {
    promote_arith(a, b)
  } else if is_ptr(a) {
    a
  } else {
    b
  }
}

///|
pub fn int_literal_type(s : String) -> CType {
  let a = s.to_array()
  let mut i = a.length()
  let mut has_l = false
  let mut has_ll = false
  let mut has_u = false
  while i > 0 {
    let ch = a[i - 1]
    if ch == 'l' || ch == 'L' {
      if has_l {
        has_ll = true
      } else {
        has_l = true
      }
      i = i - 1
    } else if ch == 'u' || ch == 'U' {
      has_u = true
      i = i - 1
    } else {
      break
    }
  }
  if has_ll {
    CLongLong(!has_u)
  } else if has_l {
    CLong(!has_u)
  } else if has_u {
    CInt(false)
  } else {
    let v = parse_int_lit(s)
    if v > 2147483647L || v < -2147483648L {
      CLong(true)
    } else {
      CInt(true)
    }
  }
}

///|
fn int_expr(v : Int64) -> TExpr {
  mk_expr(TInt(v), CInt(false), false)
}

///|
fn field_of(layout : Layout, name : String) -> Field? {
  for f in layout.fields {
    if f.name == name {
      return Some(f)
    }
  }
  None
}

///|
pub fn check_expr(e : @front.Expr, ctx : Ctx) -> TExpr {
  match e {
    @front.EInt(s) =>
      mk_expr(TInt(parse_int_lit(s)), int_literal_type(s), false)
    @front.EChar(s) => mk_expr(TInt(parse_char_lit(s)), CInt(true), false)
    @front.EBool(b) =>
      mk_expr(TInt(if b { 1L } else { 0L }), CInt(false), false)
    @front.ENullptr => mk_expr(TInt(0L), CPtr(CVoid), false)
    @front.EFloat(s) => {
      let last = s.to_array()[s.length() - 1]
      let is_f = last == 'f' || last == 'F'
      mk_expr(
        TFlt(parse_float_lit(s), is_f),
        if is_f {
          CFloat
        } else {
          CDouble
        },
        false,
      )
    }
    @front.EImag(s) => {
      // An imaginary literal is a _Complex value with a zero real part; the
      // f/F suffix selects the single-precision element type.
      let last = s.to_array()[s.length() - 1]
      let is_f = last == 'f' || last == 'F'
      let elem = if is_f { CFloat } else { CDouble }
      let esz = if is_f { 4 } else { 8 }
      let v = parse_float_lit(s)
      let real = mk_expr(TFlt(0.0, is_f), elem, false)
      let imag = mk_expr(TFlt(v, is_f), elem, false)
      mk_expr(
        TCompoundLit([(0, real, 0, 0), (esz, imag, 0, 0)]),
        CComplex(elem),
        false,
      )
    }
    @front.EString(parts) => {
      let mut joined = ""
      for p in parts {
        joined = joined + p
      }
      let idx = ctx.strings.length()
      ctx.strings.push(joined)
      mk_expr(TStr(idx), CPtr(CChar(true)), false)
    }
    @front.EIdent(n) =>
      match ctx.scopes.lookup(n) {
        Some(sym) =>
          match sym.kind {
            SymEnumConst => mk_expr(TInt(sym.value), sym.ty, false)
            SymFunc => mk_expr(TVar(n), sym.ty, false)
            SymVar =>
              mk_expr(
                TVar(if sym.gname != "" { sym.gname } else { n }),
                sym.ty,
                true,
              )
            _ => mk_expr(TVar(n), sym.ty, false)
          }
        None => {
          ctx.diags.error("use of undeclared identifier: " + n)
          err_expr(ctx)
        }
      }
    @front.EComma(l, r) => {
      let tl = check_expr(l, ctx)
      let tr = check_expr(r, ctx)
      mk_expr(TComma(tl, tr), tr.ty, tr.lvalue)
    }
    @front.EAssign(op, l, r) => {
      let tl = check_expr(l, ctx)
      let tr = check_expr(r, ctx)
      if !tl.lvalue {
        ctx.diags.error("assignment to non-lvalue")
      }
      let combined = if op == "=" {
        tr
      } else {
        let bop = op.substring(start=0, end=op.length() - 1)
        mk_expr(TBin(bop, tl, tr), tl.ty, false)
      }
      mk_expr(TAssign(tl, combined), tl.ty, false)
    }
    @front.EBinary(op, l, r) => check_binary(op, l, r, ctx)
    @front.EUnary(op, x) => check_unary(op, x, ctx)
    @front.EPostfix(op, x) => check_unary(op, x, ctx)
    @front.ECond(c, t, f) => {
      let tc = check_expr(c, ctx)
      let tt = check_expr(t, ctx)
      let tf = check_expr(f, ctx)
      mk_expr(TCond(tc, tt, tf), common_type(tt.ty, tf.ty), false)
    }
    @front.ECall(callee, args) => check_call(callee, args, ctx)
    @front.ECast(spec, d, x) => {
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(d, base, ctx)
      let tx = check_expr(x, ctx)
      mk_expr(TCast(tx), ty, false)
    }
    @front.EMember(base, name, arrow) => {
      let tb = check_expr(base, ctx)
      // `p->f` is `(*p).f`: the member base must be the dereferenced pointer,
      // not the pointer expression itself.
      let (sty, mb) = if arrow {
        match decay(tb.ty) {
          CPtr(t) => (t, mk_expr(TDeref(tb), t, true))
          _ => (tb.ty, tb)
        }
      } else {
        (tb.ty, tb)
      }
      match sty {
        CStruct(i) | CUnion(i) =>
          match field_of(ctx.layouts[i], name) {
            Some(f) =>
              if f.bit_width > 0 {
                mk_expr(
                  TBitField(mb, f.offset, f.bit_offset, f.bit_width),
                  f.ty,
                  true,
                )
              } else {
                mk_expr(TMember(mb, f.offset), f.ty, arrow || tb.lvalue)
              }
            None => {
              ctx.diags.error("no member named " + name)
              err_expr(ctx)
            }
          }
        _ => {
          ctx.diags.error("member access on a non-aggregate type")
          err_expr(ctx)
        }
      }
    }
    @front.EIndex(base, idx) => {
      let tb = check_expr(base, ctx)
      let ti = check_expr(idx, ctx)
      let (ptr_e, idx_e, elem) = match decay(tb.ty) {
        CPtr(t) => (tb, ti, t)
        _ =>
          match decay(ti.ty) {
            CPtr(t) => (ti, tb, t)
            _ => {
              ctx.diags.error("subscript on a non-pointer type")
              (tb, ti, CInt(false))
            }
          }
      }
      mk_expr(
        TDeref(mk_expr(TBin("+", ptr_e, idx_e), CPtr(elem), false)),
        elem,
        true,
      )
    }
    @front.ESizeofExpr(x) => {
      let tx = check_expr(x, ctx)
      mk_expr(TSizeof(size_of_ty(tx.ty, ctx.layouts)), CLong(false), false)
    }
    @front.ESizeofType(spec, d) => {
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(d, base, ctx)
      mk_expr(TSizeof(size_of_ty(ty, ctx.layouts)), CLong(false), false)
    }
    @front.EAlignofType(spec, d) => {
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(d, base, ctx)
      mk_expr(TAlignof(align_of_ty(ty, ctx.layouts)), CLong(false), false)
    }
    @front.EAlignofExpr(x) => {
      let tx = check_expr(x, ctx)
      mk_expr(TAlignof(align_of_ty(tx.ty, ctx.layouts)), CLong(false), false)
    }
    @front.EGeneric(ctrl, assocs) => {
      let tc = check_expr(ctrl, ctx)
      let tct = decay(tc.ty)
      let mut chosen : TExpr? = None
      let mut dflt : TExpr? = None
      for a in assocs {
        match a.spec {
          Some(spec) => {
            let base = declspec_to_type(spec, ctx)
            let d = match a.decl {
              Some(d) => d
              None => @front.DAbstract
            }
            let ty = build_type(d, base, ctx)
            if ty_eq(ty, tct) {
              chosen = Some(check_expr(a.expr, ctx))
            }
          }
          None => dflt = Some(check_expr(a.expr, ctx))
        }
      }
      match chosen {
        Some(t) => t
        None =>
          match dflt {
            Some(t) => t
            None => {
              ctx.diags.error("no matching _Generic association")
              err_expr(ctx)
            }
          }
      }
    }
    @front.EStmtExpr(items) => {
      let body = check_block_items(items, ctx)
      let n = body.length()
      let ty = if n > 0 {
        match body[n - 1].kind {
          KSExpr(Some(e)) => e.ty
          _ => CInt(false)
        }
      } else {
        CInt(false)
      }
      mk_expr(TStmtExpr(body), ty, false)
    }
    @front.ECompound(spec, d, init) => {
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(d, base, ctx)
      let stores : Array[(Int, TExpr, Int, Int)] = []
      check_init_into(init, ty, 0, stores, ctx)
      mk_expr(TCompoundLit(stores), ty, true)
    }
    @front.ETypesCompatible(s1, d1, s2, d2) => {
      let b1 = declspec_to_type(s1, ctx)
      let t1 = build_type(d1, b1, ctx)
      let b2 = declspec_to_type(s2, ctx)
      let t2 = build_type(d2, b2, ctx)
      mk_expr(TInt(if ty_eq(t1, t2) { 1L } else { 0L }), CInt(false), false)
    }
    @front.EOffsetof(spec, d, designators) => {
      let base = declspec_to_type(spec, ctx)
      let mut ty = build_type(d, base, ctx)
      let mut off = 0
      for dz in designators {
        match dz {
          @front.DField(n) =>
            match ty {
              CStruct(i) | CUnion(i) =>
                match field_of(ctx.layouts[i], n) {
                  Some(f) => {
                    off = off + f.offset
                    ty = f.ty
                  }
                  None => ctx.diags.error("__builtin_offsetof: no member " + n)
                }
              _ => ctx.diags.error("__builtin_offsetof: not an aggregate")
            }
          @front.DIndex(e) =>
            match ty {
              CArray(el, _) => {
                off = off +
                  const_eval_int(e, ctx).to_int() * size_of_ty(el, ctx.layouts)
                ty = el
              }
              _ => ctx.diags.error("__builtin_offsetof: not an array")
            }
          _ => ()
        }
      }
      mk_expr(TInt(off.to_int64()), CLong(false), false)
    }
    @front.EVaArg(x, spec, d) => {
      let tx = check_expr(x, ctx)
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(d, base, ctx)
      mk_expr(TVaArg(tx), ty, false)
    }
    @front.ETemp => {
      ctx.diags.error("internal temporary expression in source")
      err_expr(ctx)
    }
    _ => {
      ctx.diags.error("unsupported expression")
      err_expr(ctx)
    }
  }
}

///|
fn check_binary(
  op : String,
  l : @front.Expr,
  r : @front.Expr,
  ctx : Ctx,
) -> TExpr {
  let tl = check_expr(l, ctx)
  let tr = check_expr(r, ctx)
  let cmp = op == "==" ||
    op == "!=" ||
    op == "<" ||
    op == "<=" ||
    op == ">" ||
    op == ">=" ||
    op == "&&" ||
    op == "||"
  if cmp {
    mk_expr(TBin(op, tl, tr), CInt(false), false)
  } else {
    let lt = decay(tl.ty)
    let rt = decay(tr.ty)
    let ty = match (lt, rt) {
      (CComplex(a), CComplex(b)) => CComplex(promote_arith(a, b))
      (CComplex(a), _) => CComplex(promote_arith(a, rt))
      (_, CComplex(b)) => CComplex(promote_arith(lt, b))
      // Subtracting two pointers yields ptrdiff_t, an integer, not a
      // pointer. The code generator decides whether to scale a `p + i` by
      // looking at the type of `i`, so typing this as a pointer silently
      // turned `p[a - b]` into a byte offset.
      (CPtr(pa), CPtr(_)) => if op == "-" { CLong(false) } else { CPtr(pa) }
      (CPtr(e), _) => if op == "+" || op == "-" { CPtr(e) } else { lt }
      (_, CPtr(e)) => CPtr(e)
      _ => promote_arith(lt, rt)
    }
    mk_expr(TBin(op, tl, tr), ty, false)
  }
}

///|
fn check_unary(op : String, x : @front.Expr, ctx : Ctx) -> TExpr {
  if op == "&&" {
    let n = match x {
      @front.EIdent(n) => n
      _ => ""
    }
    return mk_expr(TLabelAddr(n), CPtr(CVoid), false)
  }
  let tx = check_expr(x, ctx)
  match op {
    "&" =>
      if tx.lvalue ||
        (match tx.ty {
          CFunc(_, _, _) => true
          _ => false
        }) {
        mk_expr(TAddr(tx), CPtr(tx.ty), false)
      } else {
        ctx.diags.error("cannot take the address of an rvalue")
        err_expr(ctx)
      }
    "*" =>
      match decay(tx.ty) {
        CPtr(t) => mk_expr(TDeref(tx), t, true)
        _ => {
          ctx.diags.error("cannot dereference a non-pointer")
          err_expr(ctx)
        }
      }
    "!" => mk_expr(TUn(op, tx), CInt(false), false)
    "__real__" | "__imag__" =>
      match decay(tx.ty) {
        CComplex(el) => mk_expr(TUn(op, tx), el, false)
        _ => tx
      }
    "-" | "~" => mk_expr(TUn(op, tx), tx.ty, false)
    "++" | "--" | "pre++" | "pre--" | "post++" | "post--" =>
      mk_expr(TUn(op, tx), tx.ty, false)
    _ => tx
  }
}

///|
fn check_call(
  callee : @front.Expr,
  args : Array[@front.Expr],
  ctx : Ctx,
) -> TExpr {
  match callee {
    @front.EIdent(n) =>
      if ctx.scopes.lookup(n) is None {
        ctx.scopes.define({
          name: n,
          gname: "",
          kind: SymFunc,
          ty: CFunc(CInt(true), [], true),
          storage: StNone,
          value: 0L,
        })
      }
    _ => ()
  }
  match callee {
    @front.EIdent(n) =>
      if n.has_prefix("__c11_atomic_") ||
        n.has_prefix("__atomic_") ||
        n.has_prefix("atomic_") {
        let targs0 : Array[TExpr] = []
        for a in args {
          targs0.push(check_expr(a, ctx))
        }
        let t = if targs0.length() > 0 { targs0[0].ty } else { CInt(false) }
        return mk_expr(
          TCall(n, mk_expr(TInt(0L), CPtr(CVoid), false), targs0),
          t,
          false,
        )
      }
    _ => ()
  }
  let tc = check_expr(callee, ctx)
  let targs : Array[TExpr] = []
  let fty = decay(tc.ty)
  let (name, ret, params, va) = match fty {
    CPtr(CFunc(r, ps, v)) => {
      let nm = match callee {
        @front.EIdent(n) => n
        _ => ""
      }
      (nm, r, ps, v)
    }
    CFunc(r, ps, v) => {
      let nm = match callee {
        @front.EIdent(n) => n
        _ => ""
      }
      (nm, r, ps, v)
    }
    _ => {
      ctx.diags.error("called object is not a function")
      ("", CInt(false), [], true)
    }
  }
  let mut argi = 0
  for a in args {
    let te = check_expr(a, ctx)
    // Arguments that have no declared parameter get the default argument
    // promotions: arrays and functions decay, and float widens to double.
    let v = if va && argi >= params.length() {
      let dt = decay(te.ty)
      if !ty_eq(dt, te.ty) {
        mk_expr(TCast(te), dt, false)
      } else {
        match te.ty {
          CFloat => mk_expr(TCast(te), CDouble, false)
          _ => te
        }
      }
    } else {
      te
    }
    targs.push(v)
    argi = argi + 1
  }
  if !va && params.length() > 0 && targs.length() > params.length() {
    ctx.diags.error("too many arguments to function: " + name)
  }
  mk_expr(TCall(name, tc, targs), ret, false)
}

///|
pub fn parse_float_lit(s : String) -> Double {
  let chars = s.to_array()
  let mut i = 0
  let n = chars.length()
  let mut int_part : Double = 0.0
  while i < n && chars[i] >= '0' && chars[i] <= '9' {
    int_part = int_part * 10.0 + (chars[i].to_int() - 48).to_double()
    i = i + 1
  }
  let mut val = int_part
  if i < n && chars[i] == '.' {
    i = i + 1
    let mut scale = 0.1
    while i < n && chars[i] >= '0' && chars[i] <= '9' {
      val = val + (chars[i].to_int() - 48).to_double() * scale
      scale = scale * 0.1
      i = i + 1
    }
  }
  if i < n && (chars[i] == 'e' || chars[i] == 'E') {
    i = i + 1
    let mut neg = false
    if i < n && (chars[i] == '+' || chars[i] == '-') {
      neg = chars[i] == '-'
      i = i + 1
    }
    let mut e = 0
    while i < n && chars[i] >= '0' && chars[i] <= '9' {
      e = e * 10 + (chars[i].to_int() - 48)
      i = i + 1
    }
    let mut k = 0
    while k < e {
      val = if neg { val / 10.0 } else { val * 10.0 }
      k = k + 1
    }
  }
  val
}
