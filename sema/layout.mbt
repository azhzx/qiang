///|
pub struct Field {
  name : String
  ty : CType
  offset : Int
  bit_width : Int
  bit_offset : Int
}

///|
pub struct Layout {
  name : String
  is_union : Bool
  fields : Array[Field]
  size : Int
  align : Int
  enum_vals : Array[(String, Int64)]
  // For an enum, the C23 underlying integer type (default int); the enum is
  // represented by it. None for structs and unions.
  enum_ty : CType?
}

///|
pub fn align_up(x : Int, a : Int) -> Int {
  if a <= 1 {
    x
  } else {
    (x + a - 1) / a * a
  }
}
