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
  struct_tys : Map[String, Int]
  consts : Map[String, Int64]
  typedefs : Map[String, Ty]
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
fn ty_kw(t : Tok) -> Bool {
  match t {
    TKw("int")
    | TKw("char")
    | TKw("short")
    | TKw("long")
    | TKw("signed")
    | TKw("unsigned")
    | TKw("float")
    | TKw("double")
    | TKw("void")
    | TKw("_Bool")
    | TKw("bool")
    | TKw("struct")
    | TKw("union")
    | TKw("enum")
    | TKw("const")
    | TKw("volatile")
    | TKw("restrict")
    | TKw("_Atomic")
    | TKw("typedef")
    | TKw("static")
    | TKw("extern")
    | TKw("auto")
    | TKw("register")
    | TKw("inline") => true
    _ => false
  }
}

///|
fn P::at_type(self : P) -> Bool {
  match self.peek() {
    TIdent(n) => self.typedefs.contains(n)
    t => ty_kw(t)
  }
}

///|
fn P::at_label(self : P) -> Bool {
  match (self.peek(), self.peek2()) {
    (TIdent(_), TPunct(":")) => true
    _ => false
  }
}

///|
fn P::ty_ahead(self : P) -> Bool {
  match self.peek2() {
    TIdent(n) => self.typedefs.contains(n)
    t => ty_kw(t)
  }
}

///|
fn P::parse_type(self : P) -> Ty {
  match self.peek() {
    TIdent(n) =>
      match self.typedefs.get(n) {
        Some(t) => {
          self.pos = self.pos + 1
          let mut tt = t
          while self.eat("*") {
            tt = TPtr(tt)
          }
          return tt
        }
        None => ()
      }
    _ => ()
  }
  let mut uns = false
  let mut n_long = 0
  let mut n_short = 0
  let mut base = TInt
  let mut go = true
  while go {
    match self.peek() {
      TKw("signed") => self.pos = self.pos + 1
      TKw("unsigned") => {
        self.pos = self.pos + 1
        uns = true
      }
      TKw("short") => {
        self.pos = self.pos + 1
        n_short = n_short + 1
      }
      TKw("long") => {
        self.pos = self.pos + 1
        n_long = n_long + 1
      }
      TKw("int") => self.pos = self.pos + 1
      TKw("char") => {
        self.pos = self.pos + 1
        base = TChar
      }
      TKw("float") => {
        self.pos = self.pos + 1
        base = TFloat
      }
      TKw("double") => {
        self.pos = self.pos + 1
        base = TDouble
      }
      TKw("void") => {
        self.pos = self.pos + 1
        base = TVoid
      }
      TKw("_Bool") | TKw("bool") => {
        self.pos = self.pos + 1
        base = TBool
      }
      TKw("struct") | TKw("union") => base = self.parse_struct_type()
      TKw("enum") => base = self.parse_enum_type()
      TKw("const")
      | TKw("volatile")
      | TKw("restrict")
      | TKw("_Atomic")
      | TKw("typedef")
      | TKw("static")
      | TKw("extern")
      | TKw("auto")
      | TKw("register")
      | TKw("inline") => self.pos = self.pos + 1
      _ => go = false
    }
  }
  let t = match base {
    TChar => if uns { TUChar } else { TChar }
    TInt =>
      if n_short > 0 {
        if uns {
          TUShort
        } else {
          TShort
        }
      } else if n_long == 1 {
        if uns {
          TULong
        } else {
          TLong
        }
      } else if n_long >= 2 {
        if uns {
          TULongLong
        } else {
          TLongLong
        }
      } else if uns {
        TUInt
      } else {
        TInt
      }
    other => other
  }
  let mut tt = t
  while self.eat("*") {
    tt = TPtr(tt)
    let mut go2 = true
    while go2 {
      match self.peek() {
        TKw("const") | TKw("volatile") | TKw("restrict") | TKw("_Atomic") =>
          self.pos = self.pos + 1
        _ => go2 = false
      }
    }
  }
  tt
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
fn align_up(x : Int, a : Int) -> Int {
  if a <= 1 {
    x
  } else {
    (x + a - 1) / a * a
  }
}

///|
fn P::parse_struct_type(self : P) -> Ty {
  let is_union = if self.eat_kw("union") {
    true
  } else {
    self.expect_kw("struct")
    false
  }
  let tag = match self.eat_ident() {
    Some(n) => n
    None => abort("qpcc: expected struct tag")
  }
  if self.eat("{") {
    let members : Array[(String, Ty, Int)] = []
    let mut off = 0
    let mut maxa = 1
    let mut maxsz = 0
    while !self.eat("}") {
      let bty = self.parse_type()
      let mut more = true
      while more {
        let (mname, mty) = self.parse_declarator(bty)
        let a = align_of(mty, self.structs)
        if a > maxa {
          maxa = a
        }
        let sz = size_of(mty, self.structs)
        if sz > maxsz {
          maxsz = sz
        }
        let moff = if is_union {
          0
        } else {
          let o = align_up(off, a)
          off = o + sz
          o
        }
        members.push((mname, mty, moff))
        if self.eat(",") {
          continue
        }
        more = false
      }
      self.expect(";")
    }
    let size = if is_union {
      align_up(maxsz, maxa)
    } else {
      align_up(off, maxa)
    }
    let idx = self.structs.length()
    self.structs.push(StructDef::{
      name: tag,
      members,
      size,
      align: maxa,
      is_union,
    })
    self.struct_tys.set(tag, idx)
    TStruct(idx)
  } else {
    match self.struct_tys.get(tag) {
      Some(i) => TStruct(i)
      None => {
        let idx = self.structs.length()
        self.structs.push(StructDef::{
          name: tag,
          members: [],
          size: 0,
          align: 1,
          is_union,
        })
        self.struct_tys.set(tag, idx)
        TStruct(idx)
      }
    }
  }
}

///|
fn P::lookup_member(self : P, ty : Ty, name : String) -> (Int, Ty) {
  let i = match decay(ty) {
    TStruct(j) => j
    _ => abort("qpcc: member access on non-struct")
  }
  for m in self.structs[i].members {
    if m.0 == name {
      return (m.2, m.1)
    }
  }
  abort("qpcc: no such member " + name)
}

///|
fn P::parse_enum_type(self : P) -> Ty {
  self.expect_kw("enum")
  let _tag = self.eat_ident()
  if self.eat("{") {
    let mut val : Int64 = 0L
    while !self.eat("}") {
      let name = match self.eat_ident() {
        Some(x) => x
        None => abort("qpcc: expected enumerator name")
      }
      if self.eat("=") {
        val = match self.adv() {
          TNum(n) => n
          _ => abort("qpcc: enum value must be an integer constant")
        }
      }
      self.consts.set(name, val)
      val = val + 1L
      if self.eat(",") {
        continue
      }
    }
  }
  TInt
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
  } else if is_float(lt) || is_float(rt) {
    if lt == TDouble || rt == TDouble {
      TDouble
    } else {
      TFloat
    }
  } else {
    match (lt, rt) {
      (TPtr(e), _) => if op == "+" || op == "-" { TPtr(e) } else { TLong }
      (_, TPtr(_)) => TLong
      (TLong | TULong, _) | (_, TLong | TULong) => TLong
      (TLongLong | TULongLong, _) | (_, TLongLong | TULongLong) => TLongLong
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
    TPunct("(") =>
      if self.ty_ahead() {
        self.pos = self.pos + 1
        let ty = self.parse_type()
        self.expect(")")
        let e = self.parse_unary()
        mk(ECast(e), ty)
      } else {
        self.parse_postfix()
      }
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
    TKw("_Alignof") => {
      self.pos = self.pos + 1
      self.expect("(")
      let t = self.parse_type()
      self.expect(")")
      mk(EAlignofT(t), TLong)
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
    } else if self.eat(".") {
      let mname = match self.eat_ident() {
        Some(n) => n
        None => abort("qpcc: expected member name")
      }
      let (off, mty) = self.lookup_member(e.ty, mname)
      e = mk(EMember(e, off), mty)
    } else if self.eat("->") {
      let mname = match self.eat_ident() {
        Some(n) => n
        None => abort("qpcc: expected member name")
      }
      let sty = match decay(e.ty) {
        TPtr(TStruct(j)) => TStruct(j)
        _ => abort("qpcc: member access on non-struct pointer")
      }
      let d = mk(EDeref(e), sty)
      let (off, mty) = self.lookup_member(sty, mname)
      e = mk(EMember(d, off), mty)
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
    TFlt(v, is_f) => mk(EFlt(v, is_f), if is_f { TFloat } else { TDouble })
    TKw("true") => mk(ENum(1), TBool)
    TKw("false") => mk(ENum(0), TBool)
    TKw("nullptr") => mk(ENum(0), TPtr(TVoid))
    TStr(s) => {
      let id = self.strings.length()
      self.strings.push(s)
      mk(EStr(id), TPtr(TChar))
    }
    TIdent(n) =>
      match self.consts.get(n) {
        Some(v) => mk(ENum(v), TInt)
        None => mk(EVar(n), self.lookup(n))
      }
    TPunct("(") => {
      let e = self.parse_expr()
      self.expect(")")
      e
    }
    _ => abort("qpcc: expected expression")
  }
}

///|
fn P::parse_init_list(self : P) -> Array[Expr] {
  let out : Array[Expr] = []
  self.expect("{")
  while !self.eat("}") {
    out.push(self.parse_assign())
    if !self.eat(",") {
      self.expect("}")
      break
    }
  }
  out
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
    let is_td = self.eat_kw("typedef")
    let base = self.parse_type()
    if self.eat(";") {
      { kind: SBlock([]), }
    } else {
      let (name, ty) = self.parse_declarator(base)
      if is_td {
        self.typedefs.set(name, ty)
        while self.eat(",") {
          let (n2, t2) = self.parse_declarator(base)
          self.typedefs.set(n2, t2)
        }
        self.expect(";")
        return { kind: SBlock([]), }
      }
      let init = if self.eat("=") {
        if self.peek() == TPunct("{") {
          let items = self.parse_init_list()
          self.expect(";")
          self.locals.set(name, ty)
          return { kind: SAggInit(name, ty, items), }
        }
        Some(self.parse_assign())
      } else {
        None
      }
      while self.eat(",") {
        let _ = self.parse_declarator(base)
      }
      self.expect(";")
      self.locals.set(name, ty)
      { kind: SLocal(name, ty, init), }
    }
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
  } else if self.eat_kw("switch") {
    self.expect("(")
    let e = self.parse_expr()
    self.expect(")")
    let b = self.parse_stmt()
    { kind: SSwitch(e, b), }
  } else if self.eat_kw("case") {
    let v = match self.adv() {
      TNum(n) => n
      _ => abort("qpcc: case value must be an integer constant")
    }
    self.expect(":")
    { kind: SCase(v), }
  } else if self.eat_kw("default") {
    self.expect(":")
    { kind: SDefault, }
  } else if self.eat_kw("goto") {
    let n = match self.eat_ident() {
      Some(x) => x
      None => abort("qpcc: expected label name")
    }
    self.expect(";")
    { kind: SGoto(n), }
  } else if self.at_label() {
    let n = match self.eat_ident() {
      Some(x) => x
      None => abort("qpcc: expected label name")
    }
    self.expect(":")
    let s = self.parse_stmt()
    { kind: SLabel(n, s), }
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
  let is_td = self.eat_kw("typedef")
  let base = self.parse_type()
  if self.eat(";") {
    return
  }
  let (name, ty) = self.parse_declarator(base)
  if is_td {
    self.typedefs.set(name, ty)
    while self.eat(",") {
      let (n2, t2) = self.parse_declarator(base)
      self.typedefs.set(n2, t2)
    }
    self.expect(";")
    return
  }
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
    struct_tys: Map::new(),
    consts: Map::new(),
    typedefs: Map::new(),
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
