///|
/// Recursive-descent parser for the QPCC C subset.
priv struct P {
  toks : Array[Tok]
  mut pos : Int
  mut locals : Map[String, Ty]
  globals : Map[String, Ty]
  funcs : Map[String, (Ty, Array[Ty])]
  strings : Array[String]
  structs : Array[StructDef]
  funcs_list : Array[FuncDef]
  globals_list : Array[GlobalDef]
}

///|
fn P::peek(self : P) -> Tok {
  self.toks[self.pos]
}

///|
fn P::peek2(self : P) -> Tok {
  if self.pos + 1 < self.toks.length() {
    self.toks[self.pos + 1]
  } else {
    TEof
  }
}

///|
fn P::adv(self : P) -> Tok {
  let t = self.toks[self.pos]
  self.pos = self.pos + 1
  t
}

///|
fn P::eat(self : P, p : String) -> Bool {
  match self.peek() {
    TPunct(q) if q == p => {
      self.pos = self.pos + 1
      true
    }
    _ => false
  }
}

///|
fn P::expect(self : P, p : String) -> Unit {
  if !self.eat(p) {
    abort("qpcc: expected " + p)
  }
}

///|
fn P::eat_kw(self : P, k : String) -> Bool {
  match self.peek() {
    TKw(q) if q == k => {
      self.pos = self.pos + 1
      true
    }
    _ => false
  }
}

///|
fn P::expect_kw(self : P, k : String) -> Unit {
  if !self.eat_kw(k) {
    abort("qpcc: expected keyword " + k)
  }
}

///|
fn P::eat_ident(self : P) -> String? {
  match self.peek() {
    TIdent(n) => {
      self.pos = self.pos + 1
      Some(n)
    }
    _ => None
  }
}

///|
fn P::at_type(self : P) -> Bool {
  match self.peek() {
    TKw("int") | TKw("char") | TKw("long") | TKw("void") => true
    _ => false
  }
}

///|
fn P::parse_type(self : P) -> Ty {
  let base = match self.peek() {
    TKw("int") => {
      self.pos = self.pos + 1
      TInt
    }
    TKw("char") => {
      self.pos = self.pos + 1
      TChar
    }
    TKw("long") => {
      self.pos = self.pos + 1
      TLong
    }
    TKw("void") => {
      self.pos = self.pos + 1
      TVoid
    }
    _ => abort("qpcc: expected type")
  }
  let mut t = base
  while self.eat("*") {
    t = TPtr(t)
  }
  t
}

///|
/// Parse a declarator: an optional name and array suffix.
fn P::parse_declarator(self : P, base : Ty) -> (String, Ty) {
  // pointer suffixes may follow the base type before the name
  let mut b = base
  while self.eat("*") {
    b = TPtr(b)
  }
  let name = match self.eat_ident() {
    Some(n) => n
    None => abort("qpcc: expected identifier")
  }
  let mut t = b
  while self.eat("[") {
    let n = match self.adv() {
      TNum(k) => k.to_int()
      _ => abort("qpcc: expected array size")
    }
    self.expect("]")
    t = TArr(t, n)
  }
  (name, t)
}

///|
fn P::lookup(self : P, name : String) -> Ty {
  match self.locals.get(name) {
    Some(t) => t
    None =>
      match self.globals.get(name) {
        Some(t) => t
        None =>
          match self.funcs.get(name) {
            Some((r, _)) => TPtr(r)
            None => TInt // implicit declaration: assume int
          }
      }
  }
}

///|
fn mk(kind : EK, ty : Ty) -> Expr {
  { kind, ty, }
}

///|
fn P::parse_expr(self : P) -> Expr {
  let mut e = self.parse_assign()
  while self.eat(",") {
    let r = self.parse_assign()
    e = mk(EComma(e, r), r.ty)
  }
  e
}

///|
fn P::parse_assign(self : P) -> Expr {
  let lhs = self.parse_cond()
  let op = match self.peek() {
    TPunct("=") => "="
    TPunct("+=") => "+"
    TPunct("-=") => "-"
    TPunct("*=") => "*"
    TPunct("/=") => "/"
    TPunct("%=") => "%"
    TPunct("&=") => "&"
    TPunct("|=") => "|"
    TPunct("^=") => "^"
    TPunct("<<=") => "<<"
    TPunct(">>=") => ">>"
    _ => ""
  }
  if op != "" {
    self.pos = self.pos + 1
    let rhs = self.parse_assign()
    if op == "=" {
      mk(EAssign(lhs, rhs), lhs.ty)
    } else {
      let combined = self.mk_bin(op, lhs, rhs)
      mk(EAssign(lhs, combined), lhs.ty)
    }
  } else {
    lhs
  }
}

///|
fn P::parse_cond(self : P) -> Expr {
  let c = self.parse_binary(1)
  if self.eat("?") {
    let t = self.parse_expr()
    self.expect(":")
    let f = self.parse_cond()
    mk(ECond(c, t, f), t.ty)
  } else {
    c
  }
}

///|
fn prec_of(op : String) -> Int {
  match op {
    "||" => 1
    "&&" => 2
    "|" => 3
    "^" => 4
    "&" => 5
    "==" | "!=" => 6
    "<" | "<=" | ">" | ">=" => 7
    "<<" | ">>" => 8
    "+" | "-" => 9
    "*" | "/" | "%" => 10
    _ => 0
  }
}

///|
fn bin_op(t : Tok) -> String {
  match t {
    TPunct(p) => if prec_of(p) > 0 { p } else { "" }
    _ => ""
  }
}

///|
fn P::mk_bin(self : P, op : String, l : Expr, r : Expr) -> Expr {
  let cmp = op == "==" ||
    op == "!=" ||
    op == "<" ||
    op == "<=" ||
    op == ">" ||
    op == ">=" ||
    op == "&&" ||
    op == "||"
  let lt = decay(l.ty)
  let rt = decay(r.ty)
  let ty = if cmp {
    TInt
  } else {
    match (lt, rt) {
      (TPtr(e), _) => if op == "+" || op == "-" { TPtr(e) } else { TLong }
      (_, TPtr(_)) => TLong
      (TLong, _) | (_, TLong) => TLong
      _ => TInt
    }
  }
  mk(EBin(op, l, r), ty)
}

///|
fn P::parse_binary(self : P, min_prec : Int) -> Expr {
  let mut lhs = self.parse_unary()
  let mut go = true
  while go {
    let op = bin_op(self.peek())
    if op == "" || prec_of(op) < min_prec {
      go = false
    } else {
      self.pos = self.pos + 1
      let rhs = self.parse_binary(prec_of(op) + 1)
      lhs = self.mk_bin(op, lhs, rhs)
    }
  }
  lhs
}

///|
fn P::parse_unary(self : P) -> Expr {
  match self.peek() {
    TPunct("-") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EUn("-", e), e.ty)
    }
    TPunct("!") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EUn("!", e), TInt)
    }
    TPunct("~") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EUn("~", e), e.ty)
    }
    TPunct("&") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EAddr(e), TPtr(e.ty))
    }
    TPunct("*") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      let t = match decay(e.ty) {
        TPtr(inner) => inner
        _ => TInt
      }
      mk(EDeref(e), t)
    }
    TPunct("++") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EUn("pre++", e), e.ty)
    }
    TPunct("--") => {
      self.pos = self.pos + 1
      let e = self.parse_unary()
      mk(EUn("pre--", e), e.ty)
    }
    TKw("sizeof") => {
      self.pos = self.pos + 1
      if self.eat("(") {
        if self.at_type() {
          let t = self.parse_type()
          self.expect(")")
          mk(ESizeofT(t), TLong)
        } else {
          let e = self.parse_expr()
          self.expect(")")
          mk(ESizeofE(e), TLong)
        }
      } else {
        let e = self.parse_unary()
        mk(ESizeofE(e), TLong)
      }
    }
    _ => self.parse_postfix()
  }
}

///|
fn P::parse_postfix(self : P) -> Expr {
  let mut e = self.parse_primary()
  let mut go = true
  while go {
    if self.eat("(") {
      let args : Array[Expr] = []
      if !self.eat(")") {
        let mut more = true
        while more {
          args.push(self.parse_assign())
          if self.eat(",") {
            continue
          }
          more = false
        }
        self.expect(")")
      }
      let name = match e.kind {
        EVar(n) => n
        _ => abort("qpcc: indirect calls are not supported")
      }
      let ty = match self.funcs.get(name) {
        Some((r, _)) => r
        None => TInt
      }
      e = mk(ECall(name, args), ty)
    } else if self.eat("[") {
      let idx = self.parse_expr()
      self.expect("]")
      let elem = match decay(e.ty) {
        TPtr(t) => t
        _ => TInt
      }
      let ptr = self.mk_bin("+", e, idx)
      e = mk(EDeref(ptr), elem)
    } else if self.eat("++") {
      e = mk(EUn("post++", e), e.ty)
    } else if self.eat("--") {
      e = mk(EUn("post--", e), e.ty)
    } else {
      go = false
    }
  }
  e
}

///|
fn P::parse_primary(self : P) -> Expr {
  match self.adv() {
    TNum(n) => mk(ENum(n), TInt)
    TStr(s) => {
      let id = self.strings.length()
      self.strings.push(s)
      mk(EStr(id), TPtr(TChar))
    }
    TIdent(n) => mk(EVar(n), self.lookup(n))
    TPunct("(") => {
      let e = self.parse_expr()
      self.expect(")")
      e
    }
    _ => abort("qpcc: expected expression")
  }
}

///|
fn P::parse_block(self : P) -> Stmt {
  self.expect("{")
  let stmts : Array[Stmt] = []
  while !self.eat("}") {
    if self.peek() == TEof {
      abort("qpcc: unexpected end of file in block")
    }
    stmts.push(self.parse_stmt())
  }
  { kind: SBlock(stmts), }
}

///|
fn P::parse_stmt(self : P) -> Stmt {
  if self.at_type() {
    let base = self.parse_type()
    let (name, ty) = self.parse_declarator(base)
    let init = if self.eat("=") { Some(self.parse_assign()) } else { None }
    while self.eat(",") {
      let _ = self.parse_declarator(base)
    }
    self.expect(";")
    self.locals.set(name, ty)
    { kind: SLocal(name, ty, init), }
  } else if self.eat("{") {
    self.pos = self.pos - 1
    self.parse_block()
  } else if self.eat_kw("return") {
    if self.eat(";") {
      { kind: SReturn(None), }
    } else {
      let e = self.parse_expr()
      self.expect(";")
      { kind: SReturn(Some(e)), }
    }
  } else if self.eat_kw("if") {
    self.expect("(")
    let c = self.parse_expr()
    self.expect(")")
    let then = self.parse_stmt()
    let els = if self.eat_kw("else") { Some(self.parse_stmt()) } else { None }
    { kind: SIf(c, then, els), }
  } else if self.eat_kw("while") {
    self.expect("(")
    let c = self.parse_expr()
    self.expect(")")
    let b = self.parse_stmt()
    { kind: SWhile(c, b), }
  } else if self.eat_kw("for") {
    self.expect("(")
    let init = if self.eat(";") {
      None
    } else {
      let s = self.parse_stmt()
      Some(s)
    }
    let cond = if self.eat(";") {
      None
    } else {
      let e = self.parse_expr()
      self.expect(";")
      Some(e)
    }
    let step = if self.eat(")") {
      None
    } else {
      let e = self.parse_expr()
      self.expect(")")
      Some(e)
    }
    let b = self.parse_stmt()
    { kind: SFor(init, cond, step, b), }
  } else if self.eat_kw("do") {
    let b = self.parse_stmt()
    self.expect_kw("while")
    self.expect("(")
    let c = self.parse_expr()
    self.expect(")")
    self.expect(";")
    { kind: SDoWhile(b, c), }
  } else if self.eat_kw("break") {
    self.expect(";")
    { kind: SBreak, }
  } else if self.eat_kw("continue") {
    self.expect(";")
    { kind: SContinue, }
  } else if self.eat(";") {
    { kind: SBlock([]), }
  } else {
    let e = self.parse_expr()
    self.expect(";")
    { kind: SExpr(e), }
  }
}

///|
fn P::parse_params(self : P) -> Array[Param] {
  let ps : Array[Param] = []
  self.expect("(")
  if !self.eat(")") {
    let mut more = true
    while more {
      let base = self.parse_type()
      let mut ty = base
      while self.eat("*") {
        ty = TPtr(ty)
      }
      let name = match self.eat_ident() {
        Some(n) => n
        None => ""
      }
      ps.push({ name, ty, })
      if self.eat(",") {
        continue
      }
      more = false
    }
    self.expect(")")
  }
  ps
}

///|
fn P::parse_top(self : P) -> Unit {
  let base = self.parse_type()
  let (name, ty) = self.parse_declarator(base)
  if self.eat("(") {
    // function: params follow, we already consumed "("
    self.pos = self.pos - 1
    let params = self.parse_params()
    let ptypes : Array[Ty] = []
    for p in params {
      ptypes.push(p.ty)
    }
    self.funcs.set(name, (ty, ptypes))
    if self.eat(";") {
      return
    }
    // register parameter names as locals
    for p in params {
      if p.name != "" {
        self.locals.set(p.name, p.ty)
      }
    }
    let body = self.parse_block()
    // clear locals for the next function
    self.locals = Map::new()
    self.funcs_list.push({ name, ret: ty, params, body, })
  } else {
    let init = if self.eat("=") {
      match self.adv() {
        TNum(n) => Some(n)
        TPunct("-") =>
          match self.adv() {
            TNum(n) => Some(-n)
            _ => abort("qpcc: bad global initializer")
          }
        _ => Some(0L)
      }
    } else {
      None
    }
    self.expect(";")
    self.globals.set(name, ty)
    self.globals_list.push({ name, ty, init, })
  }
}

///|
pub fn parse(src : String) -> Program {
  let p = P::{
    toks: tokenize(src),
    pos: 0,
    locals: Map::new(),
    globals: Map::new(),
    funcs: Map::new(),
    strings: [],
    structs: [],
    funcs_list: [],
    globals_list: [],
  }
  while p.peek() != TEof {
    p.parse_top()
  }
  Program::{
    funcs: p.funcs_list,
    globals: p.globals_list,
    strings: p.strings,
    structs: p.structs,
  }
}
