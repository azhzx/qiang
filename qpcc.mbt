///|
/// Minimal preprocessor: drop lines that start with '#'. This supports
/// #include/#define directives well enough for the current C subset (libc
/// calls are treated as implicit declarations).
fn strip_directives(src : String) -> String {
  let sb = StringBuilder::new()
  for line in src.split("\n") {
    if line.has_prefix("#") {
      sb.write_string("\n")
    } else {
      sb.write_string(line.to_string())
      sb.write_string("\n")
    }
  }
  sb.to_string()
}

///|
/// QPCC driver: parse a translation unit and emit via the qbe.mbt builder.
pub fn compile_il(src : String) -> String raise {
  let p = parse(strip_directives(src))
  let b = compile_program(p)
  b.emit_il()
}

///|
pub fn compile_object(src : String) -> Bytes raise {
  let p = parse(strip_directives(src))
  let b = compile_program(p)
  b.emit_object()
}
