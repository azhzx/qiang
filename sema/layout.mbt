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
}

///|
pub fn align_up(x : Int, a : Int) -> Int {
  if a <= 1 {
    x
  } else {
    (x + a - 1) / a * a
  }
}
