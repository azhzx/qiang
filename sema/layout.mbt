///|
pub struct Field {
  name : String
  ty : CType
  offset : Int32
  bit_width : Int32
  bit_offset : Int32
}

///|
pub struct Layout {
  name : String
  is_union : Bool
  fields : Array[Field]
  size : Int32
  align : Int32
  enum_vals : Array[(String, Int64)]
  // For an enum, the C23 underlying integer type (default int); the enum is
  // represented by it. None for structs and unions.
  enum_ty : CType?
  // Qiang -f_tagged_union: `_Tagged_union Tag { ... }` is laid out as
  // `struct { int __tag; union { members } __payload; }`. `tagged` marks
  // it, `payload_off` is where the members start, and `tag_vals` maps a
  // member name to its discriminator (declaration order, 0-based).
  tagged : Bool
  payload_off : Int32
  tag_vals : Array[(String, Int64)]
}

///|
pub fn align_up(x : Int32, a : Int32) -> Int32 {
  if a <= 1 {
    x
  } else {
    (x + a - 1) / a * a
  }
}
