///|
/// Canonical C types (top-level qualifiers are not modelled yet;
/// `_Atomic` is accepted and behaves like its underlying type).
pub(all) enum CType {
  CVoid
  CBool
  CChar(Bool)
  CShort(Bool)
  CInt(Bool)
  CLong(Bool)
  CLongLong(Bool)
  CLongDouble
  CFloat
  CDouble
  CComplex(CType)
  CPtr(CType)
  CArray(CType, Int)
  CVLA(CType, TExpr)
  CFunc(CType, Array[CType], Bool)
  CStruct(Int)
  CUnion(Int)
  CEnum(Int)
  CBitInt(Int)
}

///|
/// Structural type equality (CVLA compares element types only).
pub fn ty_eq(a : CType, b : CType) -> Bool {
  match (a, b) {
    (CVoid, CVoid)
    | (CBool, CBool)
    | (CLongDouble, CLongDouble)
    | (CFloat, CFloat)
    | (CDouble, CDouble) => true
    (CChar(x), CChar(y))
    | (CShort(x), CShort(y))
    | (CInt(x), CInt(y))
    | (CLong(x), CLong(y))
    | (CLongLong(x), CLongLong(y)) => x == y
    (CComplex(x), CComplex(y)) => ty_eq(x, y)
    (CPtr(x), CPtr(y)) => ty_eq(x, y)
    (CArray(x, n), CArray(y, m)) => n == m && ty_eq(x, y)
    (CVLA(x, _), CVLA(y, _)) => ty_eq(x, y)
    (CFunc(r1, p1, v1), CFunc(r2, p2, v2)) =>
      v1 == v2 &&
      ty_eq(r1, r2) &&
      p1.length() == p2.length() &&
      ({
        let mut ok = true
        let mut i = 0
        while i < p1.length() {
          if !ty_eq(p1[i], p2[i]) {
            ok = false
          }
          i = i + 1
        }
        ok
      })
    (CStruct(x), CStruct(y))
    | (CUnion(x), CUnion(y))
    | (CEnum(x), CEnum(y))
    | (CBitInt(x), CBitInt(y)) => x == y
    _ => false
  }
}

///|
pub fn is_integer(t : CType) -> Bool {
  match t {
    CBool
    | CChar(_)
    | CShort(_)
    | CInt(_)
    | CLong(_)
    | CLongLong(_)
    | CEnum(_)
    | CBitInt(_) => true
    _ => false
  }
}

///|
pub fn is_signed(t : CType) -> Bool {
  match t {
    CChar(s) | CShort(s) | CInt(s) | CLong(s) | CLongLong(s) => s
    CFloat | CDouble | CLongDouble => true
    _ => false
  }
}

///|
pub fn is_float(t : CType) -> Bool {
  match t {
    CFloat | CDouble | CLongDouble => true
    _ => false
  }
}

///|
pub fn is_complex(t : CType) -> Bool {
  match t {
    CComplex(_) => true
    _ => false
  }
}

///|
pub fn is_arith(t : CType) -> Bool {
  is_integer(t) || is_float(t) || is_complex(t)
}

///|
pub fn is_ptr(t : CType) -> Bool {
  match t {
    CPtr(_) => true
    _ => false
  }
}

///|
pub fn is_scalar(t : CType) -> Bool {
  is_arith(t) || is_ptr(t)
}

///|
/// Array-to-pointer and function-to-pointer decay.
pub fn decay(t : CType) -> CType {
  match t {
    CArray(e, _) => CPtr(e)
    CVLA(e, _) => CPtr(e)
    CFunc(_, _, _) => CPtr(t)
    _ => t
  }
}

///|
pub fn size_of_ty(t : CType, layouts : Array[Layout]) -> Int {
  match t {
    CVoid => 1
    CBool | CChar(_) => 1
    CShort(_) => 2
    CInt(_) | CFloat | CEnum(_) => 4
    CLong(_) | CLongLong(_) | CDouble | CLongDouble | CPtr(_) => 8
    CComplex(e) => size_of_ty(e, layouts) * 2
    CArray(e, n) => size_of_ty(e, layouts) * (if n == 0 { 0 } else { n })
    CVLA(e, _) => size_of_ty(e, layouts)
    CFunc(_, _, _) => 1
    CStruct(i) | CUnion(i) => layouts[i].size
    CBitInt(n) =>
      if n <= 8 {
        1
      } else if n <= 16 {
        2
      } else if n <= 32 {
        4
      } else {
        8
      }
  }
}

///|
pub fn align_of_ty(t : CType, layouts : Array[Layout]) -> Int {
  match t {
    CVoid => 1
    CBool | CChar(_) => 1
    CShort(_) => 2
    CInt(_) | CFloat | CEnum(_) => 4
    CLong(_) | CLongLong(_) | CDouble | CLongDouble | CPtr(_) => 8
    CComplex(e) => align_of_ty(e, layouts)
    CArray(e, _) => align_of_ty(e, layouts)
    CVLA(e, _) => align_of_ty(e, layouts)
    CFunc(_, _, _) => 1
    CStruct(i) | CUnion(i) => layouts[i].align
    CBitInt(n) =>
      if n <= 8 {
        1
      } else if n <= 16 {
        2
      } else if n <= 32 {
        4
      } else {
        8
      }
  }
}
