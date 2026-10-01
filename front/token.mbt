///|
/// The C standard version the parser is targeting.
pub(all) enum StdMode {
  C11
  C23
} derive(Eq)

///|
/// Token kinds for the full C11 + GNU extension lexer.
pub(all) enum TokenKind {
  Ident(String)
  Keyword(String)
  IntLit(String)
  FloatLit(String)
  ImagLit(String)
  StringLit(String)
  CharLit(String)
  Punct(String)
  Eof
} derive(Eq, Debug)

///|
pub struct Token {
  kind : TokenKind
  line : Int
  col : Int
}

///|
pub fn Token::text(self : Token) -> String {
  match self.kind {
    Ident(s) | Keyword(s) | IntLit(s) | FloatLit(s) | ImagLit(s) | Punct(s) => s
    StringLit(s) => s
    CharLit(s) => s
    Eof => "<eof>"
  }
}
