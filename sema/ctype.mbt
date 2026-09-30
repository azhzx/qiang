///|
/// Canonical C types (qualifiers are accepted but not modelled yet).
pub(all) enum CType {
  CVoid
  CBool
  CChar(Bool)
  CShort(Bool)
  CInt(Bool)
  CLong(Bool)
  CLongLong(Bool)
  CFloat
  CDouble
  CPtr(CType)
  CArray(CType, Int)
  CFunc(CType, Array[CType], Bool)
  CStruct(Int)
  CUnion(Int)
  CEnum(Int)
  CBitInt(Int)
} derive(Eq)

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
    CFloat | CDouble => true
    _ => false
  }
}

///|
pub fn is_float(t : CType) -> Bool {
  match t {
    CFloat | CDouble => true
    _ => false
  }
}

///|
pub fn is_arith(t : CType) -> Bool {
  is_integer(t) || is_float(t)
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
    CLong(_) | CLongLong(_) | CDouble | CPtr(_) => 8
    CArray(e, n) => size_of_ty(e, layouts) * (if n == 0 { 0 } else { n })
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
    CLong(_) | CLongLong(_) | CDouble | CPtr(_) => 8
    CArray(e, _) => align_of_ty(e, layouts)
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
