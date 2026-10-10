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
  // QPCC/N3914: the `_Any_func` function type. It never appears on its own;
  // `_Function_pointer` is the pointer to it, which is the storage type.
  CAnyFunc
  // QPCC closures: a two-word { function pointer, environment pointer } value.
  // The Int is the layout of the captured environment, or -1 for the written
  // type `_Lambda T (params)` where no environment is known yet.
  CClosure(CType, Array[CType], Int)
}

///|
/// Element-wise type equality, used for parameter lists.
fn same_types(a : Array[CType], b : Array[CType]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i in 0..<a.length() {
    if !ty_eq(a[i], b[i]) {
      return false
    }
  }
  true
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
    // N3914 4.6: adding the any-function type changes no compatible type, so
    // `_Any_func` is compatible with itself and with nothing else - in
    // particular not with any other function type.
    (CAnyFunc, CAnyFunc) => true
    // Two closures are the same type when their signatures match; the captured
    // environment is not part of the written type `_Lambda T (params)`.
    (CClosure(r1, p1, _), CClosure(r2, p2, _)) =>
      ty_eq(r1, r2) && same_types(p1, p2)
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
// The minimum and maximum representable values of an integer type, as Int64
// bit patterns (an unsigned 64-bit maximum is -1L). None for types the C2y
// _Maxof/_Minof operators reject (_Bool, non-integers, wide _BitInt).
pub fn int_type_limits(t : CType) -> (Int64, Int64)? {
  match t {
    CBool => None
    CChar(s) => if s { Some((-128L, 127L)) } else { Some((0L, 255L)) }
    CShort(s) => if s { Some((-32768L, 32767L)) } else { Some((0L, 65535L)) }
    CInt(s) =>
      if s {
        Some((-2147483648L, 2147483647L))
      } else {
        Some((0L, 4294967295L))
      }
    CLong(_) | CLongLong(_) =>
      Some((-9223372036854775808L, 9223372036854775807L))
    CEnum(_) => Some((-2147483648L, 2147483647L))
    CBitInt(n) =>
      if n <= 0 || n > 64 {
        None
      } else if n == 64 {
        Some((-9223372036854775808L, 9223372036854775807L))
      } else {
        Some((-(1L << (n - 1)), (1L << (n - 1)) - 1L))
      }
    _ => None
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
    CAnyFunc => 1
    CClosure(_, _, _) => 16
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
    CAnyFunc => 1
    CClosure(_, _, _) => 8
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
