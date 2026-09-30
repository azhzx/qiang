///|
/// Minimal C compiler (M0): int <name>() { return <n>; }

///|
pub(all) enum Token {
  TInt
  TReturn
  TIdent(String)
  TNumber(Int64)
  TLParen
  TRParen
  TLBrace
  TRBrace
  TSemicolon
  TEof
} derive(Eq, Debug)

///|
fn is_ident_start(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c == '_'
}

///|
fn is_ident_char(c : Char) -> Bool {
  is_ident_start(c) || c.is_ascii_digit()
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\n' || c == '\r'
}

///|
fn read_ident(s : StringView) -> (String, StringView) {
  let sb = StringBuilder::new()
  let mut rest = s
  for cur = s {
    match cur {
      [c, .. r] if is_ident_char(c) => {
        sb.write_char(c)
        rest = r
        continue r
      }
      _ => break
    }
  }
  (sb.to_string(), rest)
}

///|
fn read_number(s : StringView) -> (Int64, StringView) {
  let mut v : Int64 = 0L
  let mut rest = s
  for cur = s {
    match cur {
      [c, .. r] if c.is_ascii_digit() => {
        v = v * 10L + (c.to_int() - 48).to_int64()
        rest = r
        continue r
      }
      _ => break
    }
  }
  (v, rest)
}

///|
fn skip_space(s : StringView) -> StringView {
  let mut rest = s
  for cur = s {
    match cur {
      [c, .. r] if is_space(c) => {
        rest = r
        continue r
      }
      _ => break
    }
  }
  rest
}

///|
fn next_token(s : StringView) -> (Token, StringView) {
  let s = skip_space(s)
  match s {
    [c, .. _r] if c.is_ascii_digit() => {
      let (n, r2) = read_number(s)
      (TNumber(n), r2)
    }
    [c, .. _r] if is_ident_start(c) => {
      let (id, r2) = read_ident(s)
      let t = if id == "int" {
        TInt
      } else if id == "return" {
        TReturn
      } else {
        TIdent(id)
      }
      (t, r2)
    }
    ['(', .. r] => (TLParen, r)
    [')', .. r] => (TRParen, r)
    ['{', .. r] => (TLBrace, r)
    ['}', .. r] => (TRBrace, r)
    [';', .. r] => (TSemicolon, r)
    [_c, ..] => abort("qpcc: unexpected character")
    [] => (TEof, s)
  }
}

///|
pub fn tokenize(src : String) -> Array[Token] {
  let toks : Array[Token] = []
  let mut sv : StringView = src
  let mut running = true
  while running {
    let (t, r) = next_token(sv)
    toks.push(t)
    sv = r
    if t == TEof {
      running = false
    }
  }
  toks
}

///|
pub struct FuncDef {
  name : String
  value : Int64
}

///|
pub struct Program {
  funcs : Array[FuncDef]
}

///|
priv struct Parser {
  toks : Array[Token]
  mut pos : Int
}

///|
fn Parser::peek(self : Parser) -> Token {
  self.toks[self.pos]
}

///|
fn Parser::advance(self : Parser) -> Token {
  let t = self.toks[self.pos]
  self.pos = self.pos + 1
  t
}

///|
fn Parser::expect(self : Parser, t : Token) -> Unit {
  let got = self.advance()
  if got != t {
    abort("qpcc: parse error")
  }
}

///|
pub fn parse(src : String) -> Program {
  let toks = tokenize(src)
  let p = Parser::{ toks, pos: 0, }
  let funcs : Array[FuncDef] = []
  while p.peek() != TEof {
    p.expect(TInt)
    let name = match p.advance() {
      TIdent(n) => n
      _ => abort("qpcc: expected function name")
    }
    p.expect(TLParen)
    p.expect(TRParen)
    p.expect(TLBrace)
    p.expect(TReturn)
    let value = match p.advance() {
      TNumber(n) => n
      _ => abort("qpcc: expected return value")
    }
    p.expect(TSemicolon)
    p.expect(TRBrace)
    funcs.push(FuncDef::{ name, value, })
  }
  Program::{ funcs, }
}

///|
fn build(src : String) -> @ir_builder.Builder {
  let p = parse(src)
  let b = @ir_builder.Builder::new()
  for fd in p.funcs {
    let f = b.add_func(fd.name, @ir_builder.Word, [], true)
    let c = b.iconst(f, fd.value)
    b.ret(f, c)
  }
  b
}

///|
pub fn compile_il(src : String) -> String raise {
  let b = build(src)
  b.emit_il()
}

///|
pub fn compile_object(src : String) -> Bytes raise {
  let b = build(src)
  b.emit_object()
}
