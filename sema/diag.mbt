///|
/// A diagnostic produced by sema.
pub(all) enum Severity {
  SevError
  SevWarning
}

///|
pub struct Diag {
  sev : Severity
  line : Int
  col : Int
  msg : String
}

///|
pub struct Diags {
  items : Array[Diag]
  mut cur_line : Int
  mut cur_col : Int
}

///|
pub fn Diags::new() -> Diags {
  { items: [], cur_line: 0, cur_col: 0, }
}

///|
pub fn Diags::error(self : Diags, msg : String) -> Unit {
  self.items.push({
    sev: SevError,
    line: self.cur_line,
    col: self.cur_col,
    msg,
  })
}

///|
pub fn Diags::warning(self : Diags, msg : String) -> Unit {
  self.items.push({
    sev: SevWarning,
    line: self.cur_line,
    col: self.cur_col,
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
