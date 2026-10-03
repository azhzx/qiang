///|
pub(all) enum SymKind {
  SymVar
  // A C23 constexpr object: still an object, but usable in constant
  // expressions (its initializer is folded into Symbol.value).
  SymConstVar
  SymFunc
  SymTypedef
  SymEnumConst
  SymLabel
}

///|
pub(all) enum Storage {
  StNone
  StStatic
  StExtern
  StTypedef
  StAuto
  StRegister
  StThread
}

///|
pub struct Symbol {
  name : String
  gname : String // non-empty for a static local, naming its global
  kind : SymKind
  ty : CType
  storage : Storage
  value : Int64
}

///|
pub struct ScopeStack {
  scopes : Array[Map[String, Symbol]]
  tags : Array[Map[String, Int]]
}

///|
pub fn ScopeStack::new() -> ScopeStack {
  { scopes: [Map::new()], tags: [Map::new()], }
}

///|
pub fn ScopeStack::push(self : ScopeStack) -> Unit {
  self.scopes.push(Map::new())
  self.tags.push(Map::new())
}

///|
pub fn ScopeStack::pop(self : ScopeStack) -> Unit {
  let _ = self.scopes.pop()
  let _ = self.tags.pop()
}

///|
pub fn ScopeStack::define(self : ScopeStack, s : Symbol) -> Unit {
  self.scopes[self.scopes.length() - 1].set(s.name, s)
}

///|
pub fn ScopeStack::lookup(self : ScopeStack, name : String) -> Symbol? {
  let mut i = self.scopes.length()
  while i > 0 {
    i = i - 1
    match self.scopes[i].get(name) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  None
}

///|
pub fn ScopeStack::define_tag(
  self : ScopeStack,
  name : String,
  idx : Int,
) -> Unit {
  self.tags[self.tags.length() - 1].set(name, idx)
}

///|
pub fn ScopeStack::lookup_tag(self : ScopeStack, name : String) -> Int? {
  let mut i = self.tags.length()
  while i > 0 {
    i = i - 1
    match self.tags[i].get(name) {
      Some(x) => return Some(x)
      None => ()
    }
  }
  None
}
