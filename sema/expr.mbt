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
  if a == CDouble || b == CDouble {
    CDouble
  } else if a == CFloat || b == CFloat {
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
    @front.EInt(s) => mk_expr(TInt(parse_int_lit(s)), CInt(false), false)
    @front.EChar(s) => mk_expr(TInt(parse_char_lit(s)), CInt(false), false)
    @front.EBool(b) =>
      mk_expr(TInt(if b { 1L } else { 0L }), CInt(false), false)
    @front.ENullptr => mk_expr(TInt(0L), CPtr(CVoid), false)
    @front.EFloat(s) => mk_expr(TFlt(parse_float_lit(s), false), CDouble, false)
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
            SymVar => mk_expr(TVar(n), sym.ty, true)
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
      mk_expr(TComma(tl, tr), tr.ty, false)
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
      mk_expr(TCond(tc, tt, tf), promote_arith(tt.ty, tf.ty), false)
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
      let sty = if arrow {
        match decay(tb.ty) {
          CPtr(t) => t
          _ => tb.ty
        }
      } else {
        tb.ty
      }
      match sty {
        CStruct(i) | CUnion(i) =>
          match field_of(ctx.layouts[i], name) {
            Some(f) => mk_expr(TMember(tb, f.offset), f.ty, arrow || tb.lvalue)
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
      let elem = match decay(tb.ty) {
        CPtr(t) => t
        CArray(t, _) => t
        _ => {
          ctx.diags.error("subscript on a non-pointer type")
          CInt(false)
        }
      }
      let deref = mk_expr(
        TDeref(mk_expr(TBin("+", tb, ti), CPtr(elem), false)),
        elem,
        true,
      )
      deref
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
            if ty == tc.ty {
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
      mk_expr(TStmtExpr(body), CInt(false), false)
    }
    _ => err_expr(ctx)
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
      (CPtr(e), _) => if op == "+" || op == "-" { CPtr(e) } else { lt }
      (_, CPtr(e)) => CPtr(e)
      _ => promote_arith(lt, rt)
    }
    mk_expr(TBin(op, tl, tr), ty, false)
  }
}

///|
fn check_unary(op : String, x : @front.Expr, ctx : Ctx) -> TExpr {
  let tx = check_expr(x, ctx)
  match op {
    "&" =>
      if tx.lvalue {
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
  let tc = check_expr(callee, ctx)
  let targs : Array[TExpr] = []
  for a in args {
    targs.push(check_expr(a, ctx))
  }
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
  if !va && targs.length() > params.length() {
    ctx.diags.error("too many arguments to function")
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
