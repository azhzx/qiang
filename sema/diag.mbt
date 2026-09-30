///|
/// A diagnostic produced by sema.
pub(all) enum Severity {
  SevError
  SevWarning
}

///|
pub struct Diag {
  sev : Severity
  msg : String
}

///|
pub struct Diags {
  items : Array[Diag]
}

///|
pub fn Diags::new() -> Diags {
  { items: [], }
}

///|
pub fn Diags::error(self : Diags, msg : String) -> Unit {
  self.items.push({ sev: SevError, msg, })
}

///|
pub fn Diags::warning(self : Diags, msg : String) -> Unit {
  self.items.push({ sev: SevWarning, msg, })
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
