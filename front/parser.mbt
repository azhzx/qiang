///|
/// Recursive-descent parser for the full C11 grammar plus GNU extensions.
/// Produces a surface AST; no semantic analysis is performed here.

///|
priv struct Parser {
  toks : Array[Token]
  mut pos : Int
  typedefs : Map[String, Bool]
  mode : StdMode
}

///|
fn Parser::peek(self : Parser) -> Token {
  self.toks[self.pos]
}

///|
fn Parser::peek_n(self : Parser, n : Int) -> Token {
  let i = self.pos + n
  if i < self.toks.length() {
    self.toks[i]
  } else {
    self.toks[self.toks.length() - 1]
  }
}

///|
fn[T] Parser::fail(self : Parser, msg : String) -> T {
  let t = self.peek()
  abort("qpcc/front: " + msg + " at line " + t.line.to_string())
}

///|
fn Parser::at_punct(self : Parser, p : String) -> Bool {
  match self.peek().kind {
    Punct(q) => q == p
    _ => false
  }
}

///|
fn Parser::at_kw(self : Parser, k : String) -> Bool {
  match self.peek().kind {
    Keyword(q) => q == k
    _ => false
  }
}

///|
fn Parser::eat_punct(self : Parser, p : String) -> Bool {
  if self.at_punct(p) {
    self.pos = self.pos + 1
    true
  } else {
    false
  }
}

///|
fn Parser::expect_punct(self : Parser, p : String) -> Unit {
  if !self.eat_punct(p) {
    self.fail("expected '" + p + "'")
  }
}

///|
fn Parser::eat_kw(self : Parser, k : String) -> Bool {
  if self.at_kw(k) {
    self.pos = self.pos + 1
    true
  } else {
    false
  }
}

///|
fn Parser::eat_ident(self : Parser) -> String? {
  match self.peek().kind {
    Ident(n) => {
      self.pos = self.pos + 1
      Some(n)
    }
    _ => None
  }
}

///|
fn Parser::expect_ident(self : Parser) -> String {
  match self.eat_ident() {
    Some(n) => n
    None => self.fail("expected identifier")
  }
}

///|
fn is_qualifier_kw(k : String) -> Bool {
  match k {
    "const"
    | "volatile"
    | "restrict"
    | "__const"
    | "__const__"
    | "__volatile"
    | "__volatile__"
    | "__restrict"
    | "__restrict__"
    | "_Nullable"
    | "_Nonnull"
    | "_Null_unspecified"
    | "__nullable"
    | "__nonnull"
    | "constexpr" => true
    _ => false
  }
}

///|
fn is_basic_type_kw(k : String) -> Bool {
  match k {
    "void"
    | "char"
    | "short"
    | "int"
    | "long"
    | "float"
    | "double"
    | "signed"
    | "unsigned"
    | "_Bool"
    | "_Complex"
    | "_Imaginary"
    | "__int128"
    | "__signed"
    | "__signed__"
    | "__auto_type"
    | "bool"
    | "__builtin_va_list"
    | "__builtin_ms_va_list" => true
    _ => false
  }
}

///|
fn Parser::at_typedef(self : Parser) -> Bool {
  match self.peek().kind {
    Ident(n) => self.typedefs.contains(n)
    _ => false
  }
}

///|
fn Parser::is_type_start(self : Parser) -> Bool {
  self.is_type_start_at(0)
}

///|
fn Parser::is_type_start_at(self : Parser, off : Int) -> Bool {
  match self.peek_n(off).kind {
    Keyword(k) =>
      is_basic_type_kw(k) ||
      is_qualifier_kw(k) ||
      k == "struct" ||
      k == "union" ||
      k == "enum" ||
      k == "typeof" ||
      k == "__typeof" ||
      k == "__typeof__" ||
      k == "typeof_unqual" ||
      k == "_BitInt" ||
      k == "alignas" ||
      k == "thread_local" ||
      k == "_Atomic" ||
      k == "_Alignas" ||
      k == "__attribute" ||
      k == "__attribute__" ||
      k == "__extension__" ||
      k == "_Noreturn" ||
      k == "inline" ||
      k == "__inline" ||
      k == "__inline__" ||
      k == "__thread" ||
      k == "_Thread_local" ||
      k == "typedef" ||
      k == "extern" ||
      k == "static" ||
      k == "auto" ||
      k == "register"
    Ident(n) => self.typedefs.contains(n)
    _ => false
  }
}

///|
/// Heuristic: an identifier starts a declaration if followed by another
/// identifier, '*', or '(' (function/pointer declarator).
fn Parser::at_decl_start(self : Parser) -> Bool {
  self.is_type_start()
}

///|
fn Parser::parse_qualifiers(self : Parser) -> Array[String] {
  let out : Array[String] = []
  let mut go = true
  while go {
    match self.peek().kind {
      Keyword(k) if is_qualifier_kw(k) => {
        out.push(k)
        self.pos = self.pos + 1
      }
      Keyword("_Atomic") if !self.at_punct("(") => {
        out.push("_Atomic")
        self.pos = self.pos + 1
      }
      _ => go = false
    }
  }
  out
}

///|
fn Parser::skip_balanced(
  self : Parser,
  open : String,
  close : String,
) -> String {
  self.expect_punct(open)
  let sb = StringBuilder::new()
  let mut depth = 1
  let mut go = true
  while go {
    if self.at_punct(open) {
      depth = depth + 1
      sb.write_string(open)
      self.pos = self.pos + 1
    } else if self.at_punct(close) {
      depth = depth - 1
      self.pos = self.pos + 1
      if depth == 0 {
        go = false
      } else {
        sb.write_string(close)
      }
    } else {
      let t = self.peek()
      match t.kind {
        Eof => go = false
        _ => {
          sb.write_string(t.text())
          sb.write_string(" ")
          self.pos = self.pos + 1
        }
      }
    }
  }
  sb.to_string()
}

///|
fn Parser::at_c23_attr(self : Parser) -> Bool {
  self.mode == C23 && self.at_punct("[") && self.peek_n(1).kind is Punct("[")
}

///|
fn Parser::parse_c23_attrs(self : Parser) -> Array[String] {
  let out : Array[String] = []
  while self.at_c23_attr() {
    self.pos = self.pos + 2
    let sb = StringBuilder::new()
    let mut depth = 1
    while depth > 0 {
      if self.at_punct("[") && self.peek_n(1).kind is Punct("[") {
        depth = depth + 1
        sb.write_string("[[ ")
        self.pos = self.pos + 2
      } else if self.at_punct("]") && self.peek_n(1).kind is Punct("]") {
        depth = depth - 1
        if depth > 0 {
          sb.write_string("]] ")
        }
        self.pos = self.pos + 2
      } else if self.peek().kind is Eof {
        depth = 0
      } else {
        sb.write_string(self.peek().text())
        sb.write_string(" ")
        self.pos = self.pos + 1
      }
    }
    out.push(sb.to_string())
  }
  out
}

///|
fn Parser::parse_attribute(self : Parser) -> String {
  self.pos = self.pos + 1
  if self.at_punct("(") {
    self.skip_balanced("(", ")")
  } else {
    ""
  }
}

///|
fn Parser::skip_attrs(self : Parser) -> Unit {
  let mut go = true
  while go {
    if self.at_kw("__attribute__") || self.at_kw("__attribute") {
      let _ = self.parse_attribute()
    } else if self.at_kw("__extension__") {
      self.pos = self.pos + 1
    } else if (
        self.at_kw("asm") || self.at_kw("__asm") || self.at_kw("__asm__")
      ) &&
      self.peek_n(1).kind is Punct("(") {
      // GNU asm label attached to a declaration
      let _ = self.parse_asm()
    } else {
      go = false
    }
  }
}

///|
fn Parser::parse_asm(self : Parser) -> String {
  self.pos = self.pos + 1
  let mut go = true
  while go {
    if self.at_kw("volatile") ||
      self.at_kw("__volatile__") ||
      self.at_kw("inline") ||
      self.at_kw("goto") {
      self.pos = self.pos + 1
    } else {
      go = false
    }
  }
  if self.at_punct("(") {
    self.skip_balanced("(", ")")
  } else {
    ""
  }
}

///|
fn Parser::parse_typeof(self : Parser) -> TypeSpec {
  self.pos = self.pos + 1
  self.expect_punct("(")
  if self.is_type_start() || self.at_decl_start() {
    let spec = self.parse_declspec()
    let d = self.parse_declarator()
    self.expect_punct(")")
    TTypeofType(spec, d)
  } else {
    let e = self.parse_expr()
    self.expect_punct(")")
    TTypeofExpr(e)
  }
}

///|
fn Parser::parse_struct_body(self : Parser) -> Array[StructDecl] {
  let out : Array[StructDecl] = []
  self.expect_punct("{")
  while !self.eat_punct("}") {
    self.skip_attrs()
    if self.eat_punct(";") {
      continue
    }
    if self.at_kw("_Static_assert") || self.at_kw("static_assert") {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let e = self.parse_assign_expr()
      let msg = if self.eat_punct(",") {
        match self.peek().kind {
          StringLit(s) => {
            self.pos = self.pos + 1
            Some(s)
          }
          _ => None
        }
      } else {
        None
      }
      self.expect_punct(")")
      self.expect_punct(";")
      out.push(SStaticAssert(e, msg))
      continue
    }
    if self.at_kw("__pragma") || self.at_kw("_Pragma") {
      self.pos = self.pos + 1
      if self.at_punct("(") {
        let _ = self.skip_balanced("(", ")")
      }
      out.push(SPragma(""))
      continue
    }
    let spec = self.parse_declspec()
    if self.eat_punct(";") {
      out.push(SAnon(spec))
      continue
    }
    let decls : Array[InitDeclarator] = []
    let mut go = true
    while go {
      let d = self.parse_declarator()
      let bits = if self.eat_punct(":") {
        Some(self.parse_const_expr())
      } else {
        None
      }
      self.skip_attrs()
      decls.push({ decl: d, init: None, bits, })
      if self.eat_punct(",") {
        continue
      }
      go = false
    }
    self.expect_punct(";")
    out.push(SDecl(spec, decls))
  }
  out
}

///|
fn Parser::parse_enum_body(self : Parser) -> Array[EnumItem] {
  let out : Array[EnumItem] = []
  self.expect_punct("{")
  while !self.eat_punct("}") {
    let name = self.expect_ident()
    self.skip_attrs()
    let value = if self.eat_punct("=") {
      Some(self.parse_const_expr())
    } else {
      None
    }
    out.push({ name, value, })
    if self.eat_punct(",") {
      continue
    }
    self.expect_punct("}")
    break
  }
  out
}

///|
fn Parser::eat_storage(self : Parser, out : Array[String]) -> Bool {
  match self.peek().kind {
    Keyword(k) =>
      match k {
        "typedef"
        | "extern"
        | "static"
        | "auto"
        | "register"
        | "_Thread_local"
        | "__thread"
        | "thread_local" => {
          out.push(k)
          self.pos = self.pos + 1
          true
        }
        _ => false
      }
    _ => false
  }
}

///|
fn Parser::parse_declspec(self : Parser) -> DeclSpec {
  let storage : Array[String] = []
  let qualifiers : Array[String] = []
  let type_specs : Array[TypeSpec] = []
  let func_specs : Array[String] = []
  let align : Array[AlignmentSpec] = []
  let attrs : Array[String] = []
  let mut go = true
  while go {
    match self.peek().kind {
      Keyword(k) =>
        if is_qualifier_kw(k) ||
          (k == "_Atomic" && !(self.peek_n(1).kind is Punct("("))) ||
          k == "constexpr" {
          qualifiers.push(k)
          self.pos = self.pos + 1
        } else if self.eat_storage(storage) {
          ()
        } else if k == "inline" ||
          k == "__inline" ||
          k == "__inline__" ||
          k == "_Noreturn" {
          func_specs.push(k)
          self.pos = self.pos + 1
        } else if is_basic_type_kw(k) {
          type_specs.push(TKw(k))
          self.pos = self.pos + 1
        } else if k == "struct" {
          self.pos = self.pos + 1
          let mut tag = self.eat_ident()
          self.skip_attrs()
          if tag is None {
            tag = self.eat_ident()
            self.skip_attrs()
          }
          let body = if self.at_punct("{") {
            self.parse_struct_body()
          } else {
            []
          }
          type_specs.push(TStruct(tag, body))
        } else if k == "union" {
          self.pos = self.pos + 1
          let mut tag = self.eat_ident()
          self.skip_attrs()
          if tag is None {
            tag = self.eat_ident()
            self.skip_attrs()
          }
          let body = if self.at_punct("{") {
            self.parse_struct_body()
          } else {
            []
          }
          type_specs.push(TUnion(tag, body))
        } else if k == "enum" {
          self.pos = self.pos + 1
          let tag = self.eat_ident()
          let body = if self.at_punct("{") {
            self.parse_enum_body()
          } else {
            []
          }
          type_specs.push(TEnum(tag, body))
        } else if k == "typeof" ||
          k == "__typeof" ||
          k == "__typeof__" ||
          k == "typeof_unqual" {
          type_specs.push(self.parse_typeof())
        } else if k == "_Atomic" && self.peek_n(1).kind is Punct("(") {
          self.pos = self.pos + 1
          self.expect_punct("(")
          let spec = self.parse_declspec()
          let d = self.parse_declarator()
          self.expect_punct(")")
          type_specs.push(TAtomicSpec(spec, d))
        } else if k == "_BitInt" {
          self.pos = self.pos + 1
          self.expect_punct("(")
          let e = self.parse_const_expr()
          self.expect_punct(")")
          type_specs.push(TBitInt(e))
        } else if k == "_Alignas" || k == "alignas" {
          self.pos = self.pos + 1
          self.expect_punct("(")
          if self.is_type_start() {
            let spec = self.parse_declspec()
            let d = self.parse_declarator()
            align.push(AlignType(spec, d))
          } else {
            align.push(AlignExpr(self.parse_assign_expr()))
          }
          self.expect_punct(")")
        } else if k == "__attribute__" || k == "__attribute" {
          attrs.push(self.parse_attribute())
        } else if k == "__extension__" {
          self.pos = self.pos + 1
        } else {
          go = false
        }
      Punct("[") =>
        if self.mode == C23 && self.peek_n(1).kind is Punct("[") {
          let a = self.parse_c23_attrs()
          for x in a {
            attrs.push(x)
          }
        } else {
          go = false
        }
      Ident(n) =>
        if self.typedefs.contains(n) && type_specs.length() == 0 {
          type_specs.push(TTypedefName(n))
          self.pos = self.pos + 1
        } else {
          go = false
        }
      _ => go = false
    }
  }
  { storage, qualifiers, type_specs, func_specs, align, attrs, }
}

///|
fn Parser::parse_param_list(self : Parser) -> (Array[ParamDecl], Bool) {
  let params : Array[ParamDecl] = []
  let mut va = false
  if self.eat_punct(")") {
    return (params, va)
  }
  if self.at_kw("void") && self.peek_n(1).kind is Punct(")") {
    self.pos = self.pos + 1
    self.expect_punct(")")
    return (params, va)
  }
  let mut go = true
  while go {
    if self.eat_punct("...") {
      va = true
      self.expect_punct(")")
      go = false
    } else {
      let spec = self.parse_declspec()
      let d = self.parse_declarator()
      params.push({ spec, decl: d, })
      if self.eat_punct(",") {
        continue
      }
      self.expect_punct(")")
      go = false
    }
  }
  (params, va)
}

///|
fn Parser::parse_declarator(self : Parser) -> Declarator {
  self.skip_attrs()
  if self.eat_punct("*") {
    let quals = self.parse_qualifiers()
    self.skip_attrs()
    let inner = self.parse_declarator()
    DPointer(quals, inner)
  } else {
    self.parse_direct_declarator()
  }
}

///|
fn Parser::parse_direct_declarator(self : Parser) -> Declarator {
  let mut d = if self.at_punct("(") &&
    (self.peek_n(1).kind is Punct(")") || self.is_type_start_at(1)) {
    self.pos = self.pos + 1
    let (params, va) = self.parse_param_list()
    DFunction(DAbstract, params, va)
  } else if self.eat_punct("(") {
    let inner = self.parse_declarator()
    self.expect_punct(")")
    inner
  } else {
    match self.eat_ident() {
      Some(n) => DName(n)
      None => DAbstract
    }
  }
  let mut go = true
  while go {
    if self.eat_punct("[") {
      let mut is_static = false
      let mut scanning = true
      while scanning {
        if self.eat_kw("static") {
          is_static = true
        } else {
          let q = self.parse_qualifiers()
          if q.length() == 0 {
            scanning = false
          }
        }
      }
      let size = if self.eat_punct("]") {
        None
      } else if self.at_punct("*") && self.peek_n(1).kind is Punct("]") {
        self.pos = self.pos + 1
        self.expect_punct("]")
        None
      } else {
        let e = self.parse_assign_expr()
        self.expect_punct("]")
        Some(e)
      }
      d = DArray(d, size, is_static)
    } else if self.eat_punct("(") {
      let (params, va) = self.parse_param_list()
      d = DFunction(d, params, va)
    } else {
      go = false
    }
  }
  d
}

///|
fn Parser::parse_designators(self : Parser) -> Array[Designator] {
  let out : Array[Designator] = []
  let mut go = true
  while go {
    if self.eat_punct(".") {
      out.push(DField(self.expect_ident()))
    } else if self.eat_punct("[") {
      let e = self.parse_const_expr()
      if self.eat_punct("...") {
        let e2 = self.parse_const_expr()
        self.expect_punct("]")
        out.push(DRange(e, e2))
      } else {
        self.expect_punct("]")
        out.push(DIndex(e))
      }
    } else {
      go = false
    }
  }
  out
}

///|
fn Parser::parse_initializer(self : Parser) -> Initializer {
  if self.eat_punct("{") {
    let items : Array[DesignatedInit] = []
    while !self.eat_punct("}") {
      let desigs = self.parse_designators()
      if desigs.length() > 0 {
        let _ = self.eat_punct("=")
      }
      let init = self.parse_initializer()
      items.push({ designators: desigs, init, })
      if self.eat_punct(",") {
        continue
      }
      self.expect_punct("}")
      break
    }
    IList(items)
  } else {
    IExpr(self.parse_assign_expr())
  }
}

///|
fn Parser::parse_init_declarator(self : Parser) -> InitDeclarator {
  let d = self.parse_declarator()
  let bits = if self.eat_punct(":") {
    Some(self.parse_const_expr())
  } else {
    None
  }
  self.skip_attrs()
  let init = if self.eat_punct("=") {
    Some(self.parse_initializer())
  } else {
    None
  }
  { decl: d, init, bits, }
}

///|
fn Parser::declare_typedefs(
  self : Parser,
  spec : DeclSpec,
  decls : Array[InitDeclarator],
) -> Unit {
  let mut is_td = false
  for s in spec.storage {
    if s == "typedef" {
      is_td = true
    }
  }
  if is_td {
    for d in decls {
      // the declarator may not be a plain name; record the direct name
      match decl_name(d.decl) {
        Some(n) => self.typedefs.set(n, true)
        None => ()
      }
    }
  }
}

///|
fn decl_name(d : Declarator) -> String? {
  match d {
    DName(n) => Some(n)
    DPointer(_, inner) => decl_name(inner)
    DArray(inner, _, _) => decl_name(inner)
    DFunction(inner, _, _) => decl_name(inner)
    DAbstract => None
  }
}

///|
fn Parser::parse_external_decl(self : Parser) -> ExternalDecl {
  let tok = self.peek()
  let pos = Span::{ line: tok.line, col: tok.col, }
  { kind: self.parse_external_decl_kind(), pos, }
}

///|
fn Parser::parse_external_decl_kind(self : Parser) -> ExternalDeclKind {
  self.skip_attrs()
  if self.at_kw("_Static_assert") || self.at_kw("static_assert") {
    self.pos = self.pos + 1
    self.expect_punct("(")
    let e = self.parse_assign_expr()
    let msg = if self.eat_punct(",") {
      match self.peek().kind {
        StringLit(s) => {
          self.pos = self.pos + 1
          Some(s)
        }
        _ => None
      }
    } else {
      None
    }
    self.expect_punct(")")
    self.expect_punct(";")
    return EStaticAssert(e, msg)
  }
  if self.at_kw("asm") || self.at_kw("__asm") || self.at_kw("__asm__") {
    let text = self.parse_asm()
    self.expect_punct(";")
    return EAsm(text)
  }
  if self.eat_punct(";") {
    return EEmpty
  }
  let spec = self.parse_declspec()
  if self.eat_punct(";") {
    return EDecl(spec, [])
  }
  let first = self.parse_init_declarator()
  if self.at_punct("{") && is_function_declarator(first.decl) {
    let body = self.parse_compound_stmt()
    return EFunc(spec, first.decl, body)
  }
  let decls : Array[InitDeclarator] = [first]
  while self.eat_punct(",") {
    decls.push(self.parse_init_declarator())
  }
  self.expect_punct(";")
  self.declare_typedefs(spec, decls)
  EDecl(spec, decls)
}

///|
fn is_name_decl(d : Declarator) -> Bool {
  match d {
    DName(_) | DAbstract => true
    _ => false
  }
}

///|
/// The outer type constructor of a declarator is the AST node closest to the
/// declared name.
fn outer_kind(d : Declarator) -> Int {
  match d {
    DName(_) | DAbstract => 0
    DPointer(_, inner) =>
      if is_name_decl(inner) {
        1
      } else {
        outer_kind(inner)
      }
    DArray(inner, _, _) =>
      if is_name_decl(inner) {
        2
      } else {
        outer_kind(inner)
      }
    DFunction(inner, _, _) =>
      if is_name_decl(inner) {
        3
      } else {
        outer_kind(inner)
      }
  }
}

///|
fn is_function_declarator(d : Declarator) -> Bool {
  outer_kind(d) == 3
}

///|
fn Parser::parse_compound_stmt(self : Parser) -> Stmt {
  let tok = self.peek()
  let pos = Span::{ line: tok.line, col: tok.col, }
  { kind: self.parse_compound(), pos, }
}

///|
fn Parser::parse_compound(self : Parser) -> StmtKind {
  self.expect_punct("{")
  let items : Array[BlockItem] = []
  while !self.eat_punct("}") {
    if self.peek().kind is Eof {
      self.fail("unexpected end of file in block")
    }
    if self.at_c23_attr() {
      let _ = self.parse_c23_attrs()
    }
    if self.at_decl_start() &&
      !(self.peek().kind is Ident(_) && self.peek_n(1).kind is Punct(":")) {
      let spec = self.parse_declspec()
      if self.eat_punct(";") {
        items.push(BDecl(spec, []))
        continue
      }
      let decls : Array[InitDeclarator] = [self.parse_init_declarator()]
      while self.eat_punct(",") {
        decls.push(self.parse_init_declarator())
      }
      self.expect_punct(";")
      self.declare_typedefs(spec, decls)
      items.push(BDecl(spec, decls))
    } else {
      items.push(BStmt(self.parse_stmt()))
    }
  }
  SCompound(items)
}

///|
fn Parser::parse_stmt(self : Parser) -> Stmt {
  let tok = self.peek()
  let pos = Span::{ line: tok.line, col: tok.col, }
  { kind: self.parse_stmt_kind(), pos, }
}

///|
fn Parser::parse_stmt_kind(self : Parser) -> StmtKind {
  self.skip_attrs()
  if self.at_punct("{") {
    self.parse_compound()
  } else if self.eat_kw("if") {
    self.expect_punct("(")
    let c = self.parse_expr()
    self.expect_punct(")")
    let t = self.parse_stmt()
    let e = if self.eat_kw("else") { Some(self.parse_stmt()) } else { None }
    SIf(c, t, e)
  } else if self.eat_kw("switch") {
    self.expect_punct("(")
    let c = self.parse_expr()
    self.expect_punct(")")
    let b = self.parse_stmt()
    SSwitch(c, b)
  } else if self.eat_kw("while") {
    self.expect_punct("(")
    let c = self.parse_expr()
    self.expect_punct(")")
    let b = self.parse_stmt()
    SWhile(c, b)
  } else if self.eat_kw("do") {
    let b = self.parse_stmt()
    if !self.eat_kw("while") {
      self.fail("expected while")
    }
    self.expect_punct("(")
    let c = self.parse_expr()
    self.expect_punct(")")
    self.expect_punct(";")
    SDoWhile(b, c)
  } else if self.eat_kw("for") {
    self.expect_punct("(")
    let init = if self.eat_punct(";") {
      None
    } else if self.at_decl_start() {
      let spec = self.parse_declspec()
      let decls : Array[InitDeclarator] = [self.parse_init_declarator()]
      while self.eat_punct(",") {
        decls.push(self.parse_init_declarator())
      }
      self.expect_punct(";")
      self.declare_typedefs(spec, decls)
      Some(FDecl(spec, decls))
    } else {
      let e = self.parse_expr()
      self.expect_punct(";")
      Some(FExpr(e))
    }
    let cond = if self.eat_punct(";") {
      None
    } else {
      let e = self.parse_expr()
      self.expect_punct(";")
      Some(e)
    }
    let step = if self.eat_punct(")") {
      None
    } else {
      let e = self.parse_expr()
      self.expect_punct(")")
      Some(e)
    }
    let b = self.parse_stmt()
    SFor(init, cond, step, b)
  } else if self.eat_kw("goto") {
    if self.eat_punct("*") {
      let e = self.parse_expr()
      self.expect_punct(";")
      SGotoPtr(e)
    } else {
      let n = self.expect_ident()
      self.expect_punct(";")
      SGoto(n)
    }
  } else if self.eat_kw("continue") {
    self.expect_punct(";")
    SContinue
  } else if self.eat_kw("break") {
    self.expect_punct(";")
    SBreak
  } else if self.eat_kw("return") {
    if self.eat_punct(";") {
      SReturn(None)
    } else {
      let e = self.parse_expr()
      self.expect_punct(";")
      SReturn(Some(e))
    }
  } else if self.at_kw("case") {
    self.pos = self.pos + 1
    let e = self.parse_const_expr()
    let st = if self.eat_punct("...") {
      let e2 = self.parse_const_expr()
      self.expect_punct(":")
      Some(e2)
    } else {
      self.expect_punct(":")
      None
    }
    let body = self.parse_stmt_opt()
    match st {
      Some(e2) => SCaseRange(e, e2, body)
      None => SCase(e, body)
    }
  } else if self.eat_kw("default") {
    self.expect_punct(":")
    SDefault(self.parse_stmt_opt())
  } else if self.at_kw("_Static_assert") || self.at_kw("static_assert") {
    self.pos = self.pos + 1
    self.expect_punct("(")
    let e = self.parse_assign_expr()
    let msg = if self.eat_punct(",") {
      match self.peek().kind {
        StringLit(s) => {
          self.pos = self.pos + 1
          Some(s)
        }
        _ => None
      }
    } else {
      None
    }
    self.expect_punct(")")
    self.expect_punct(";")
    SStaticAssert(e, msg)
  } else if self.at_kw("asm") || self.at_kw("__asm") || self.at_kw("__asm__") {
    let text = self.parse_asm()
    self.expect_punct(";")
    SAsm(text)
  } else if self.eat_punct(";") {
    SEmpty
  } else {
    // label or expression statement
    match (self.peek().kind, self.peek_n(1).kind) {
      (Ident(n), Punct(":")) => {
        self.pos = self.pos + 2
        SLabel(n, self.parse_stmt_opt())
      }
      _ => {
        let e = self.parse_expr()
        self.expect_punct(";")
        SExpr(Some(e))
      }
    }
  }
}

///|
fn Parser::parse_stmt_opt(self : Parser) -> Stmt? {
  if self.at_punct("}") || self.at_kw("case") || self.at_kw("default") {
    None
  } else {
    Some(self.parse_stmt())
  }
}

///|
fn Parser::parse_const_expr(self : Parser) -> Expr {
  self.parse_cond_expr()
}

///|
fn Parser::parse_expr(self : Parser) -> Expr {
  let mut e = self.parse_assign_expr()
  while self.eat_punct(",") {
    let r = self.parse_assign_expr()
    e = EComma(e, r)
  }
  e
}

///|
fn is_assign_op(p : String) -> Bool {
  match p {
    "="
    | "+="
    | "-="
    | "*="
    | "/="
    | "%="
    | "&="
    | "|="
    | "^="
    | "<<="
    | ">>=" => true
    _ => false
  }
}

///|
fn Parser::parse_assign_expr(self : Parser) -> Expr {
  let lhs = self.parse_cond_expr()
  match self.peek().kind {
    Punct(p) if is_assign_op(p) => {
      self.pos = self.pos + 1
      let rhs = self.parse_assign_expr()
      EAssign(p, lhs, rhs)
    }
    _ => lhs
  }
}

///|
fn Parser::parse_cond_expr(self : Parser) -> Expr {
  let c = self.parse_binary_expr(1)
  if self.eat_punct("?") {
    if self.eat_punct(":") {
      let f = self.parse_cond_expr()
      ECond(c, c, f)
    } else {
      let t = self.parse_expr()
      self.expect_punct(":")
      let e = self.parse_cond_expr()
      ECond(c, t, e)
    }
  } else {
    c
  }
}

///|
fn binary_prec(p : String) -> Int {
  match p {
    "||" => 1
    "&&" => 2
    "|" => 3
    "^" => 4
    "&" => 5
    "==" | "!=" => 6
    "<" | ">" | "<=" | ">=" => 7
    "<<" | ">>" => 8
    "+" | "-" => 9
    "*" | "/" | "%" => 10
    _ => 0
  }
}

///|
fn Parser::parse_binary_expr(self : Parser, min_prec : Int) -> Expr {
  let mut lhs = self.parse_cast_expr()
  let mut go = true
  while go {
    let p = match self.peek().kind {
      Punct(q) => q
      _ => ""
    }
    let prec = binary_prec(p)
    if prec == 0 || prec < min_prec {
      go = false
    } else {
      self.pos = self.pos + 1
      let rhs = self.parse_binary_expr(prec + 1)
      lhs = EBinary(p, lhs, rhs)
    }
  }
  lhs
}

///|
/// Try to parse a type-name after '(' ; returns None if it is not a type.
fn Parser::try_type_name(self : Parser) -> (DeclSpec, Declarator)? {
  if !(self.is_type_start() || self.at_typedef()) {
    return None
  }
  let spec = self.parse_declspec()
  let d = self.parse_declarator()
  Some((spec, d))
}

///|
fn Parser::parse_cast_expr(self : Parser) -> Expr {
  if self.at_punct("(") {
    // lookahead for a cast
    match self.peek_n(1).kind {
      Keyword(k) if is_basic_type_kw(k) ||
        is_qualifier_kw(k) ||
        k == "struct" ||
        k == "union" ||
        k == "enum" ||
        k == "_Atomic" ||
        k == "typeof" ||
        k == "__typeof" ||
        k == "__typeof__" => {
        self.pos = self.pos + 1
        let spec = self.parse_declspec()
        let d = self.parse_declarator()
        self.expect_punct(")")
        // compound literal: (type){...}
        if self.at_punct("{") {
          return self.parse_postfix_tail(
            ECompound(spec, d, self.parse_initializer()),
          )
        }
        let e = self.parse_cast_expr()
        return ECast(spec, d, e)
      }
      Ident(n) if self.typedefs.contains(n) => {
        self.pos = self.pos + 1
        let spec = self.parse_declspec()
        let d = self.parse_declarator()
        self.expect_punct(")")
        if self.at_punct("{") {
          return self.parse_postfix_tail(
            ECompound(spec, d, self.parse_initializer()),
          )
        }
        let e = self.parse_cast_expr()
        return ECast(spec, d, e)
      }
      _ => ()
    }
  }
  self.parse_unary_expr()
}

///|
fn Parser::parse_unary_expr(self : Parser) -> Expr {
  self.skip_attrs()
  match self.peek().kind {
    Punct(p) if p == "++" ||
      p == "--" ||
      p == "&" ||
      p == "*" ||
      p == "+" ||
      p == "-" ||
      p == "~" ||
      p == "!" => {
      self.pos = self.pos + 1
      let e = self.parse_cast_expr()
      if p == "&" && self.at_punct("&") {
        // handled below; unreachable
        EUnary(p, e)
      } else if p == "++" {
        EUnary("pre++", e)
      } else if p == "--" {
        EUnary("pre--", e)
      } else {
        EUnary(p, e)
      }
    }
    Punct("&&") => {
      // GNU label address
      self.pos = self.pos + 1
      let n = self.expect_ident()
      EUnary("&&", EIdent(n))
    }
    Keyword("__real__") | Keyword("__imag__") => {
      let k = match self.peek().kind {
        Keyword(k) => k
        _ => ""
      }
      self.pos = self.pos + 1
      EUnary(k, self.parse_cast_expr())
    }
    Keyword("sizeof") => {
      self.pos = self.pos + 1
      if self.at_punct("(") {
        match self.peek_n(1).kind {
          Keyword(k) if is_basic_type_kw(k) ||
            is_qualifier_kw(k) ||
            k == "struct" ||
            k == "union" ||
            k == "enum" ||
            k == "_Atomic" ||
            k == "typeof" ||
            k == "__typeof" ||
            k == "__typeof__" => {
            self.pos = self.pos + 1
            let spec = self.parse_declspec()
            let d = self.parse_declarator()
            self.expect_punct(")")
            ESizeofType(spec, d)
          }
          Ident(n) if self.typedefs.contains(n) => {
            self.pos = self.pos + 1
            let spec = self.parse_declspec()
            let d = self.parse_declarator()
            self.expect_punct(")")
            ESizeofType(spec, d)
          }
          _ => {
            let e = self.parse_unary_expr()
            ESizeofExpr(e)
          }
        }
      } else {
        ESizeofExpr(self.parse_unary_expr())
      }
    }
    Keyword("_Alignof")
    | Keyword("__alignof")
    | Keyword("__alignof__")
    | Keyword("alignof") => {
      self.pos = self.pos + 1
      if self.eat_punct("(") {
        if self.is_type_start() || self.at_typedef() {
          let spec = self.parse_declspec()
          let d = self.parse_declarator()
          self.expect_punct(")")
          EAlignofType(spec, d)
        } else {
          let e = self.parse_expr()
          self.expect_punct(")")
          ESizeofExpr(e)
        }
      } else {
        EAlignofExpr(self.parse_unary_expr())
      }
    }
    Keyword("_Generic") => {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let ctrl = self.parse_assign_expr()
      let assocs : Array[GenericAssoc] = []
      while self.eat_punct(",") {
        if self.eat_kw("default") {
          self.expect_punct(":")
          assocs.push({
            spec: None,
            decl: None,
            expr: self.parse_assign_expr(),
          })
        } else {
          let spec = self.parse_declspec()
          let d = self.parse_declarator()
          self.expect_punct(":")
          assocs.push({
            spec: Some(spec),
            decl: Some(d),
            expr: self.parse_assign_expr(),
          })
        }
      }
      self.expect_punct(")")
      EGeneric(ctrl, assocs)
    }
    Keyword("__builtin_types_compatible_p") => {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let s1 = self.parse_declspec()
      let d1 = self.parse_declarator()
      self.expect_punct(",")
      let s2 = self.parse_declspec()
      let d2 = self.parse_declarator()
      self.expect_punct(")")
      ETypesCompatible(s1, d1, s2, d2)
    }
    Keyword("__builtin_constant_p") | Keyword("__builtin_expect") => {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let e = self.parse_assign_expr()
      while self.eat_punct(",") {
        let _ = self.parse_assign_expr()
      }
      self.expect_punct(")")
      e
    }
    Keyword("__builtin_offsetof") => {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let spec = self.parse_declspec()
      let d = self.parse_declarator()
      self.expect_punct(",")
      let desigs = if self.at_punct(".") || self.at_punct("[") {
        self.parse_designators()
      } else {
        let n = self.expect_ident()
        [DField(n)]
      }
      self.expect_punct(")")
      EOffsetof(spec, d, desigs)
    }
    Keyword("__builtin_va_arg") => {
      self.pos = self.pos + 1
      self.expect_punct("(")
      let e = self.parse_assign_expr()
      self.expect_punct(",")
      let spec = self.parse_declspec()
      let d = self.parse_declarator()
      self.expect_punct(")")
      EVaArg(e, spec, d)
    }
    Punct("(") =>
      match self.peek_n(1).kind {
        Punct("{") => {
          // GNU statement expression
          self.pos = self.pos + 1
          let body = self.parse_compound()
          self.expect_punct(")")
          match body {
            SCompound(items) => EStmtExpr(items)
            _ => EStmtExpr([])
          }
        }
        _ => self.parse_postfix_expr()
      }
    _ => self.parse_postfix_expr()
  }
}

///|
fn Parser::parse_postfix_expr(self : Parser) -> Expr {
  self.parse_postfix_tail(self.parse_primary_expr())
}

///|
fn Parser::parse_postfix_tail(self : Parser, start : Expr) -> Expr {
  let mut e = start
  let mut go = true
  while go {
    if self.eat_punct("[") {
      let i = self.parse_expr()
      self.expect_punct("]")
      e = EIndex(e, i)
    } else if self.eat_punct("(") {
      let args : Array[Expr] = []
      if !self.eat_punct(")") {
        let mut more = true
        while more {
          args.push(self.parse_assign_expr())
          if self.eat_punct(",") {
            continue
          }
          self.expect_punct(")")
          more = false
        }
      }
      e = ECall(e, args)
    } else if self.eat_punct(".") {
      let n = self.expect_ident()
      e = EMember(e, n, false)
    } else if self.eat_punct("->") {
      let n = self.expect_ident()
      e = EMember(e, n, true)
    } else if self.eat_punct("++") {
      e = EPostfix("post++", e)
    } else if self.eat_punct("--") {
      e = EPostfix("post--", e)
    } else {
      go = false
    }
  }
  e
}

///|
fn Parser::parse_primary_expr(self : Parser) -> Expr {
  let t = self.peek()
  match t.kind {
    IntLit(s) => {
      self.pos = self.pos + 1
      EInt(s)
    }
    FloatLit(s) => {
      self.pos = self.pos + 1
      EFloat(s)
    }
    ImagLit(s) => {
      self.pos = self.pos + 1
      EImag(s)
    }
    CharLit(s) => {
      self.pos = self.pos + 1
      EChar(s)
    }
    StringLit(s) => {
      let parts : Array[String] = []
      while true {
        match self.peek().kind {
          StringLit(x) => {
            parts.push(x)
            self.pos = self.pos + 1
          }
          _ => break
        }
      }
      EString(parts)
    }
    Ident(n) => {
      self.pos = self.pos + 1
      EIdent(n)
    }
    Keyword("true") => {
      self.pos = self.pos + 1
      EBool(true)
    }
    Keyword("false") => {
      self.pos = self.pos + 1
      EBool(false)
    }
    Keyword("nullptr") => {
      self.pos = self.pos + 1
      ENullptr
    }
    Punct("(") => {
      self.pos = self.pos + 1
      let e = self.parse_expr()
      self.expect_punct(")")
      e
    }
    Punct("{") => {
      // GNU statement expression without the enclosing '(' (rare)
      let body = self.parse_compound()
      match body {
        SCompound(items) => EStmtExpr(items)
        _ => EStmtExpr([])
      }
    }
    _ => self.fail("expected expression")
  }
}

///|
fn empty_declspec() -> DeclSpec {
  {
    storage: [],
    qualifiers: [],
    type_specs: [],
    func_specs: [],
    align: [],
    attrs: [],
  }
}

///|
pub fn parse(src : String, mode? : StdMode = C11) -> TranslationUnit {
  let toks = tokenize(src, mode)
  let typedefs : Map[String, Bool] = Map::new()
  for
    n in [
      "__uint128_t", "__int128_t", "__builtin_va_list", "__builtin_ms_va_list",
    ] {
    typedefs.set(n, true)
  }
  let p = Parser::{ toks, pos: 0, typedefs, mode, }
  let decls : Array[ExternalDecl] = []
  while !(p.peek().kind is Eof) {
    decls.push(p.parse_external_decl())
  }
  { decls, }
}
