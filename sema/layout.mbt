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
  // QPCC -f_tagged_union: `_Tagged_union Tag { ... }` is laid out as
  // `struct { int __tag; union { members } __payload; }`. `tagged` marks
  // it, `payload_off` is where the members start, and `tag_vals` maps a
  // member name to its discriminator (declaration order, 0-based).
  tagged : Bool
  payload_off : Int
  tag_vals : Array[(String, Int64)]
}

///|
pub fn align_up(x : Int, a : Int) -> Int {
  if a <= 1 {
    x
  } else {
    (x + a - 1) / a * a
  }
}
