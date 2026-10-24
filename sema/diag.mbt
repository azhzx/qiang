///|
/// A diagnostic produced by sema.
pub(all) enum Severity {
  SevError
  SevWarning
}

///|
pub struct Diag {
  sev : Severity
  line : Int32
  col : Int32
  len : Int32
  msg : String
}

///|
pub struct Diags {
  items : Array[Diag]
  mut cur_line : Int32
  mut cur_col : Int32
  mut cur_len : Int32
}

///|
pub fn Diags::new() -> Diags {
  { items: [], cur_line: 0, cur_col: 0, cur_len: 0, }
}

///|
pub fn Diags::error(self : Diags, msg : String) -> Unit {
  self.items.push({
    sev: SevError,
    line: self.cur_line,
    col: self.cur_col,
    len: self.cur_len,
    msg,
  })
}

///|
pub fn Diags::warning(self : Diags, msg : String) -> Unit {
  self.items.push({
    sev: SevWarning,
    line: self.cur_line,
    col: self.cur_col,
    len: self.cur_len,
    msg,
  })
}

///|
pub fn Diags::has_error(self : Diags) -> Bool {
  for d in self.items {
    match d.sev {
      SevError => return true
      _ => ()
    }
  }
  false
}
