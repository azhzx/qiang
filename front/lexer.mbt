///|
/// Full C11 + GNU extension lexer.

///|
fn is_id_start(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c == '_' || c == '$' || c.to_int() >= 128
}

///|
fn is_id_char(c : Char) -> Bool {
  is_id_start(c) || c.is_ascii_digit()
}

///|
fn is_digit(c : Char) -> Bool {
  c.is_ascii_digit()
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' ||
  c == '\t' ||
  c == '\n' ||
  c == '\r' ||
  c == '\u{b}' ||
  c == '\u{c}'
}

///|
pub fn is_keyword(s : String) -> Bool {
  match s {
    "auto"
    | "break"
    | "case"
    | "char"
    | "const"
    | "continue"
    | "default"
    | "do"
    | "double"
    | "else"
    | "enum"
    | "extern"
    | "float"
    | "for"
    | "goto"
    | "if"
    | "inline"
    | "int"
    | "long"
    | "register"
    | "restrict"
    | "return"
    | "short"
    | "signed"
    | "sizeof"
    | "static"
    | "struct"
    | "switch"
    | "typedef"
    | "union"
    | "unsigned"
    | "void"
    | "volatile"
    | "while"
    | "_Alignas"
    | "_Alignof"
    | "_Atomic"
    | "_Bool"
    | "_Complex"
    | "_Generic"
    | "_Imaginary"
    | "_Noreturn"
    | "_Static_assert"
    | "_Thread_local"
    | "asm"
    | "typeof"
    | "__asm"
    | "__asm__"
    | "__attribute"
    | "__attribute__"
    | "__alignof"
    | "__alignof__"
    | "__const"
    | "__const__"
    | "__extension__"
    | "__inline"
    | "__inline__"
    | "__int128"
    | "__label__"
    | "__restrict"
    | "__restrict__"
    | "__signed"
    | "__signed__"
    | "__thread"
    | "__typeof"
    | "__typeof__"
    | "__volatile"
    | "__volatile__"
    | "__auto_type"
    | "__real__"
    | "__imag__"
    | "__builtin_va_arg"
    | "__builtin_offsetof"
    | "__builtin_va_list"
    | "__builtin_ms_va_list"
    | "__builtin_types_compatible_p"
    | "__builtin_constant_p"
    | "__builtin_expect"
    | "_Nullable"
    | "_Nonnull"
    | "_Null_unspecified"
    | "__nullable"
    | "__nonnull" => true
    _ => false
  }
}

///|
priv struct Scanner {
  mut src : StringView
  mut line : Int
  mut col : Int
}

///|
fn Scanner::bump(self : Scanner, n : Int) -> Unit {
  for _i in 0..<n {
    match self.src {
      ['\n', .. r] => {
        self.src = r
        self.line = self.line + 1
        self.col = 1
      }
      [_, .. r] => {
        self.src = r
        self.col = self.col + 1
      }
      [] => ()
    }
  }
}

///|
fn Scanner::skip_trivia(self : Scanner) -> Unit {
  let mut go = true
  while go {
    match self.src {
      [c, ..] if is_space(c) => self.bump(1)
      ['\\', '\n', ..] => self.bump(2)
      ['\\', '\r', '\n', ..] => self.bump(3)
      ['/', '/', ..] => {
        self.bump(2)
        let mut stop = false
        while !stop {
          match self.src {
            ['\n', ..] => stop = true
            [_, ..] => self.bump(1)
            [] => stop = true
          }
        }
      }
      ['/', '*', ..] => {
        self.bump(2)
        let mut stop = false
        while !stop {
          match self.src {
            ['*', '/', ..] => {
              self.bump(2)
              stop = true
            }
            [_, ..] => self.bump(1)
            [] => stop = true
          }
        }
      }
      _ => go = false
    }
  }
}

///|
fn Scanner::read_while(self : Scanner, pred : (Char) -> Bool) -> String {
  let sb = StringBuilder::new()
  let mut go = true
  while go {
    match self.src {
      [c, ..] if pred(c) => {
        sb.write_char(c)
        self.bump(1)
      }
      _ => go = false
    }
  }
  sb.to_string()
}

///|
fn Scanner::read_quoted(self : Scanner, delim : Char) -> String {
  let sb = StringBuilder::new()
  let mut stop = false
  while !stop {
    match self.src {
      [c, ..] =>
        if c == delim {
          self.bump(1)
          stop = true
        } else if c == '\\' {
          sb.write_char(c)
          self.bump(1)
          match self.src {
            [c2, ..] => {
              sb.write_char(c2)
              self.bump(1)
            }
            [] => stop = true
          }
        } else if c == '\n' {
          stop = true
        } else {
          sb.write_char(c)
          self.bump(1)
        }
      [] => stop = true
    }
  }
  sb.to_string()
}

///|
fn punct_at(s : StringView) -> String? {
  match s {
    ['<', '<', '=', ..] => Some("<<=")
    ['>', '>', '=', ..] => Some(">>=")
    ['.', '.', '.', ..] => Some("...")
    ['-', '>', '*', ..] => Some("->*")
    ['.', '*', ..] => Some(".*")
    ['=', '=', ..] => Some("==")
    ['!', '=', ..] => Some("!=")
    ['<', '=', ..] => Some("<=")
    ['>', '=', ..] => Some(">=")
    ['&', '&', ..] => Some("&&")
    ['|', '|', ..] => Some("||")
    ['+', '+', ..] => Some("++")
    ['-', '-', ..] => Some("--")
    ['+', '=', ..] => Some("+=")
    ['-', '=', ..] => Some("-=")
    ['*', '=', ..] => Some("*=")
    ['/', '=', ..] => Some("/=")
    ['%', '=', ..] => Some("%=")
    ['&', '=', ..] => Some("&=")
    ['|', '=', ..] => Some("|=")
    ['^', '=', ..] => Some("^=")
    ['<', '<', ..] => Some("<<")
    ['>', '>', ..] => Some(">>")
    ['-', '>', ..] => Some("->")
    ['#', '#', ..] => Some("##")
    ['<', ':', ..] => Some("<:")
    [':', '>', ..] => Some(":>")
    ['%', ':', ..] => Some("%:")
    ['%', '%', ..] => Some("%%")
    ['#', ..] => Some("#")
    ['+', ..] => Some("+")
    ['-', ..] => Some("-")
    ['*', ..] => Some("*")
    ['/', ..] => Some("/")
    ['%', ..] => Some("%")
    ['=', ..] => Some("=")
    ['<', ..] => Some("<")
    ['>', ..] => Some(">")
    ['!', ..] => Some("!")
    ['&', ..] => Some("&")
    ['|', ..] => Some("|")
    ['^', ..] => Some("^")
    ['~', ..] => Some("~")
    ['?', ..] => Some("?")
    [':', ..] => Some(":")
    [';', ..] => Some(";")
    [',', ..] => Some(",")
    ['.', ..] => Some(".")
    ['(', ..] => Some("(")
    [')', ..] => Some(")")
    ['{', ..] => Some("{")
    ['}', ..] => Some("}")
    ['[', ..] => Some("[")
    [']', ..] => Some("]")
    ['@', ..] => Some("@")
    _ => None
  }
}

///|
fn is_num_char(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c.is_ascii_digit() || c == '.' || c == '_'
}

///|
fn classify_float(text : String) -> Bool {
  let chars = text.to_array()
  let hex = chars.length() >= 2 &&
    chars[0] == '0' &&
    (chars[1] == 'x' || chars[1] == 'X')
  let mut is_f = false
  for c in chars {
    if c == '.' {
      is_f = true
    }
    if hex {
      if c == 'p' || c == 'P' {
        is_f = true
      }
    } else if c == 'e' || c == 'E' {
      is_f = true
    }
  }
  is_f
}

///|
fn mk(kind : TokenKind, line : Int, col : Int) -> Token {
  { kind, line, col, }
}

///|
fn Scanner::next(self : Scanner) -> Token {
  self.skip_trivia()
  let line = self.line
  let col = self.col
  match self.src {
    [] => mk(Eof, line, col)
    ['u', '8', '"', ..] => {
      self.bump(3)
      mk(StringLit(self.read_quoted('"')), line, col)
    }
    ['u', '8', '\'', ..] => {
      self.bump(3)
      mk(CharLit(self.read_quoted('\'')), line, col)
    }
    [p, '"', ..] if p == 'L' || p == 'u' || p == 'U' => {
      self.bump(2)
      mk(StringLit(self.read_quoted('"')), line, col)
    }
    [p, '\'', ..] if p == 'L' || p == 'u' || p == 'U' => {
      self.bump(2)
      mk(CharLit(self.read_quoted('\'')), line, col)
    }
    ['"', ..] => {
      self.bump(1)
      mk(StringLit(self.read_quoted('"')), line, col)
    }
    ['\'', ..] => {
      self.bump(1)
      mk(CharLit(self.read_quoted('\'')), line, col)
    }
    [c, ..] if is_id_start(c) => {
      let s = self.read_while(is_id_char)
      mk(if is_keyword(s) { Keyword(s) } else { Ident(s) }, line, col)
    }
    [c, ..] if is_digit(c) => {
      let text = self.read_while(is_num_char)
      mk(
        if classify_float(text) {
          FloatLit(text)
        } else {
          IntLit(text)
        },
        line,
        col,
      )
    }
    ['.', c, ..] if is_digit(c) => {
      let text = self.read_while(is_num_char)
      mk(FloatLit(text), line, col)
    }
    _ =>
      match punct_at(self.src) {
        Some(p) => {
          self.bump(p.length())
          mk(Punct(p), line, col)
        }
        None => {
          self.bump(1)
          self.next()
        }
      }
  }
}

///|
pub fn tokenize(src : String) -> Array[Token] {
  let sc = Scanner::{ src, line: 1, col: 1, }
  let out : Array[Token] = []
  let mut go = true
  while go {
    let t = sc.next()
    out.push(t)
    match t.kind {
      Eof => go = false
      _ => ()
    }
  }
  out
}
