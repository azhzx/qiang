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
/// C23-only keywords. In C11 mode these are ordinary identifiers.
pub fn is_c23_keyword(s : String) -> Bool {
  match s {
    "bool"
    | "char8_t"
    | "true"
    | "false"
    | "nullptr"
    | "constexpr"
    | "typeof_unqual"
    | "_BitInt"
    | "static_assert"
    | "alignas"
    | "alignof"
    | "thread_local" => true
    _ => false
  }
}

///|
/// C2y-only keywords. In C11/C23 mode these are ordinary identifiers.
pub fn is_c2y_keyword(s : String) -> Bool {
  match s {
    "_Countof" | "_Maxof" | "_Minof" | "_Defer" => true
    _ => false
  }
}

///|

///|
/// QPCC \`-f_tagged_union\` keywords. Without the flag they are ordinary
/// identifiers.
pub fn is_tagged_keyword(s : String) -> Bool {
  match s {
    "_Tagged_union" | "_Tag_of" | "_Get_tag" => true
    _ => false
  }
}

///|
pub fn is_keyword_mode(s : String, mode : StdMode) -> Bool {
  is_keyword(s) ||
  (match mode {
    C2y => is_c23_keyword(s) || is_c2y_keyword(s)
    C23 => is_c23_keyword(s)
    C11 => false
  })
}

///|
priv struct Scanner {
  mut src : StringView
  mut line : Int
  mut col : Int
  mode : StdMode
  tagged_union : Bool
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
// Scan a numeric literal, allowing a C23 digit separator (') only when it
// sits between two digits, so `1'a'` is still `1` followed by a character
// literal. The separators are dropped from the returned text.
fn Scanner::read_number(self : Scanner) -> String {
  let sb = StringBuilder::new()
  let mut is_hex = false
  let mut is_bin = false
  let mut prev_dig = false
  let mut go = true
  while go {
    match self.src {
      [c, ..] if is_num_char(c) => {
        sb.write_char(c)
        if c == 'x' || c == 'X' {
          is_hex = true
        } else if c == 'b' || c == 'B' {
          is_bin = true
        }
        prev_dig = num_digit_in(c, is_hex, is_bin)
        self.bump(1)
      }
      ['\'', c, ..] if prev_dig && num_digit_in(c, is_hex, is_bin) =>
        self.bump(1)
      _ => go = false
    }
  }
  sb.to_string()
}

///|
// Is `c` a digit in the base the numeric literal has selected so far?
fn num_digit_in(c : Char, is_hex : Bool, is_bin : Bool) -> Bool {
  if is_bin {
    c == '0' || c == '1'
  } else if is_hex {
    is_digit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
  } else {
    is_digit(c)
  }
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

///|
// Split a trailing imaginary suffix (i or j) from a numeric literal.
fn split_imag(text : String) -> (String, Bool) {
  let chars = text.to_array()
  let n = chars.length()
  if n >= 2 {
    let c = chars[n - 1]
    if c == 'i' || c == 'j' {
      return (text.substring(start=0, end=n - 1), true)
    }
  }
  (text, false)
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
      mk(
        if is_keyword_mode(s, self.mode) ||
          (self.tagged_union && is_tagged_keyword(s)) {
          Keyword(s)
        } else {
          Ident(s)
        },
        line,
        col,
      )
    }
    [c, ..] if is_digit(c) => {
      let raw = self.read_number()
      let (text, imag) = split_imag(raw)
      mk(
        if imag {
          ImagLit(text)
        } else if classify_float(text) {
          FloatLit(text)
        } else {
          IntLit(text)
        },
        line,
        col,
      )
    }
    ['.', c, ..] if is_digit(c) => {
      let raw = self.read_number()
      let (text, imag) = split_imag(raw)
      mk(if imag { ImagLit(text) } else { FloatLit(text) }, line, col)
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
pub fn tokenize(
  src : String,
  mode : StdMode,
  tagged_union? : Bool = false,
) -> Array[Token] {
  let sc = Scanner::{ src, line: 1, col: 1, mode, tagged_union, }
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
