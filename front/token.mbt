///|
/// Token kinds for the full C11 + GNU extension lexer.
pub(all) enum TokenKind {
  Ident(String)
  Keyword(String)
  IntLit(String)
  FloatLit(String)
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
    Ident(s) | Keyword(s) | IntLit(s) | FloatLit(s) | Punct(s) => s
    StringLit(s) => s
    CharLit(s) => s
    Eof => "<eof>"
  }
}
