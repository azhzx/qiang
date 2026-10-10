///|
/// Source line `line` (1-based) with its trailing newline removed.
pub fn source_line(src : String, line : Int) -> String {
  if line <= 0 {
    return ""
  }
  let mut n = 1
  for l in src.split("\n") {
    if n == line {
      return l.to_string()
    }
    n = n + 1
  }
  ""
}

///|
/// A rustc-shaped diagnostic: the message, a `-->` location, the offending
/// source line and a caret run under the span. Shared by the parser (fatal
/// syntax errors) and the driver (sema diagnostics).
pub fn render_diag(
  display : String,
  src : String,
  severity : String,
  msg : String,
  line : Int,
  col : Int,
  len : Int,
) -> String {
  let loc = if display == "" {
    "line " + line.to_string() + ", column " + col.to_string()
  } else {
    display + ":" + line.to_string() + ":" + col.to_string()
  }
  let mut out = severity + ": " + msg + "\n"
  out = out + "  --> " + loc + "\n"
  let text = source_line(src, line)
  if text != "" && col >= 1 {
    let n = line.to_string()
    let mut pad = ""
    for _i in 0..<n.length() {
      pad = pad + " "
    }
    out = out + pad + " |\n"
    out = out + n + " | " + text + "\n"
    out = out + pad + " | "
    for _i in 1..<col {
      out = out + " "
    }
    let w = if len > 0 { len } else { 1 }
    for _i in 0..<w {
      out = out + "^"
    }
    out = out + "\n"
  }
  out
}
