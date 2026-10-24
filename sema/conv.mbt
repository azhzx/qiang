///|
// Weak conversions for --strict.
//
// C converts between nearly everything without a diagnostic: pointers of
// unrelated types, integers and pointers, signed and unsigned, narrowing, and
// integers and floating point. --strict rejects the lossy ones, so that a
// translation unit has to say what it means with an explicit cast.
fn int_rank(t : CType) -> Int? {
  match t {
    CBool => Some(0)
    CChar(_) => Some(1)
    CShort(_) => Some(2)
    CEnum(_) | CInt(_) => Some(3)
    CLong(_) => Some(4)
    CLongLong(_) => Some(5)
    _ => None
  }
}

///|
fn int_signed(t : CType) -> Bool {
  match t {
    CChar(s) | CShort(s) | CInt(s) | CLong(s) | CLongLong(s) => s
    CEnum(_) => true
    _ => false
  }
}

///|
fn is_flt_ty(t : CType) -> Bool {
  match t {
    CFloat | CDouble | CLongDouble => true
    _ => false
  }
}

///|
fn flt_rank(t : CType) -> Int {
  match t {
    CFloat => 1
    CDouble => 2
    _ => 3
  }
}

///|
pub fn weak_conv(from : CType, to : CType) -> String? {
  let f = decay(from)
  let t = decay(to)
  if ty_eq(f, t) {
    return None
  }
  match (f, t) {
    (CStruct(_), _) | (_, CStruct(_)) | (CUnion(_), _) | (_, CUnion(_)) =>
      Some("conversion to or from an aggregate")
    (CPtr(a), CPtr(b)) =>
      match (a, b) {
        (CVoid, _) | (_, CVoid) => None
        _ =>
          if ty_eq(a, b) {
            None
          } else {
            Some("pointer to a different object type")
          }
      }
    (
      CPtr(_),
      CInt(_)
      | CLong(_)
      | CLongLong(_)
      | CChar(_)
      | CShort(_)
      | CEnum(_),
    ) => Some("pointer to integer")
    // Integer to pointer is kept: the overwhelmingly common case is the null
    // pointer constant 0, and the semantic check on a literal would have to be
    // done on the expression rather than on the type.
    (
      CInt(_)
      | CLong(_)
      | CLongLong(_)
      | CChar(_)
      | CShort(_)
      | CEnum(_),
      CPtr(_),
    ) => None
    (CPtr(_), CFloat | CDouble | CLongDouble) =>
      Some("pointer to floating point")
    (CFloat | CDouble | CLongDouble, CPtr(_)) =>
      Some("floating point to pointer")
    (CFloat | CDouble | CLongDouble, CFloat | CDouble | CLongDouble) =>
      if flt_rank(f) > flt_rank(t) {
        Some("narrowing floating point conversion")
      } else {
        None
      }
    (CFloat | CDouble | CLongDouble, _) => Some("floating point to integer")
    (_, CFloat | CDouble | CLongDouble) => None // int to float is exact enough
    _ =>
      match (int_rank(f), int_rank(t)) {
        (Some(rf), Some(rt)) =>
          if int_signed(f) != int_signed(t) {
            Some("changes signedness")
          } else if rf > rt {
            Some("narrowing integer conversion")
          } else {
            None
          }
        _ => Some("incompatible types")
      }
  }
}
