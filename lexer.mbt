///|
/// Tokens for the QPCC C subset.
pub(all) enum Tok {
  TIdent(String)
  TNum(Int64)
  TStr(String)
  TKw(String)
  TPunct(String)
  TEof
} derive(Eq, Debug)

///|
fn is_id_start(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c == '_'
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
  c == ' ' || c == '\t' || c == '\n' || c == '\r'
}

///|
fn kw_of(s : String) -> Bool {
  match s {
    "return"
    | "if"
    | "else"
    | "while"
    | "for"
    | "do"
    | "break"
    | "continue"
    | "int"
    | "char"
    | "long"
    | "void"
    | "sizeof"
    | "struct" => true
    _ => false
  }
}

///|
fn read_ident(s : StringView) -> (String, StringView) {
  let sb = StringBuilder::new()
  let mut rest = s
  for cur = s {
    match cur {
      [c, .. r] if is_id_char(c) => {
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
      [c, .. r] if is_digit(c) => {
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
fn read_string(s : StringView) -> (String, StringView) {
  let sb = StringBuilder::new()
  let mut rest = s
  let mut esc = false
  for cur = s {
    match cur {
      ['"', .. r] if !esc => {
        rest = r
        break
      }
      ['\\', .. r] if !esc => {
        esc = true
        rest = r
        continue r
      }
      [c, .. r] => {
        if esc {
          match c {
            'n' => sb.write_char('\n')
            't' => sb.write_char('\t')
            'r' => sb.write_char('\r')
            '0' => sb.write_char('\u{0}')
            '\\' => sb.write_char('\\')
            '"' => sb.write_char('"')
            _ => sb.write_char(c)
          }
        } else {
          sb.write_char(c)
        }
        esc = false
        rest = r
        continue r
      }
      [] => break
    }
  }
  (sb.to_string(), rest)
}

///|
fn skip_ws(s : StringView) -> StringView {
  let mut rest = s
  for cur = s {
    let stop = match cur {
      [c, .. r] if is_space(c) => {
        rest = r
        continue r
      }
      ['/', .. r] =>
        match r {
          ['/', .. r2] => {
            let mut rr = r2
            for c2 = r2 {
              match c2 {
                ['\n', .. r3] => {
                  rr = r3
                  break
                }
                [_, .. r3] => {
                  rr = r3
                  continue r3
                }
                [] => break
              }
            }
            rest = rr
            continue rr
          }
          _ => {
            rest = r
            continue r
          }
        }
      _ => break
    }
    ignore(stop)
    break
  }
  rest
}

///|
fn read_punct(s : StringView) -> (String, StringView) {
  match s {
    ['<', '<', '=', .. r] => ("<<=", r)
    ['>', '>', '=', .. r] => (">>=", r)
    ['.', '.', '.', .. r] => ("...", r)
    ['=', '=', .. r] => ("==", r)
    ['!', '=', .. r] => ("!=", r)
    ['<', '=', .. r] => ("<=", r)
    ['>', '=', .. r] => (">=", r)
    ['&', '&', .. r] => ("&&", r)
    ['|', '|', .. r] => ("||", r)
    ['+', '+', .. r] => ("++", r)
    ['-', '-', .. r] => ("--", r)
    ['+', '=', .. r] => ("+=", r)
    ['-', '=', .. r] => ("-=", r)
    ['*', '=', .. r] => ("*=", r)
    ['/', '=', .. r] => ("/=", r)
    ['%', '=', .. r] => ("%=", r)
    ['&', '=', .. r] => ("&=", r)
    ['|', '=', .. r] => ("|=", r)
    ['^', '=', .. r] => ("^=", r)
    ['<', '<', .. r] => ("<<", r)
    ['>', '>', .. r] => (">>", r)
    ['-', '>', .. r] => ("->", r)
    ['+', .. r] => ("+", r)
    ['-', .. r] => ("-", r)
    ['*', .. r] => ("*", r)
    ['/', .. r] => ("/", r)
    ['%', .. r] => ("%", r)
    ['=', .. r] => ("=", r)
    ['<', .. r] => ("<", r)
    ['>', .. r] => (">", r)
    ['!', .. r] => ("!", r)
    ['&', .. r] => ("&", r)
    ['|', .. r] => ("|", r)
    ['^', .. r] => ("^", r)
    ['~', .. r] => ("~", r)
    ['?', .. r] => ("?", r)
    [':', .. r] => (":", r)
    [';', .. r] => (";", r)
    [',', .. r] => (",", r)
    ['.', .. r] => (".", r)
    ['(', .. r] => ("(", r)
    [')', .. r] => (")", r)
    ['{', .. r] => ("{", r)
    ['}', .. r] => ("}", r)
    ['[', .. r] => ("[", r)
    [']', .. r] => ("]", r)
    [c, ..] => abort("qpcc: unexpected character")
    [] => abort("qpcc: unexpected end of input")
  }
}

///|
fn esc_code(c : Char) -> Int64 {
  match c {
    'n' => 10L
    't' => 9L
    'r' => 13L
    '0' => 0L
    '\\' => 92L
    '\'' => 39L
    '"' => 34L
    _ => c.to_int().to_int64()
  }
}

///|
fn read_char(s : StringView) -> (Int64, StringView) {
  match s {
    ['\\', c, '\'', .. r] => (esc_code(c), r)
    [c, '\'', .. r] => (c.to_int().to_int64(), r)
    _ => abort("qpcc: bad character literal")
  }
}

///|
fn next_token(s : StringView) -> (Tok, StringView) {
  let s = skip_ws(s)
  match s {
    [c, .. _r] if is_digit(c) => {
      let (n, r2) = read_number(s)
      (TNum(n), r2)
    }
    [c, .. _r] if is_id_start(c) => {
      let (id, r2) = read_ident(s)
      (if kw_of(id) { TKw(id) } else { TIdent(id) }, r2)
    }
    ['"', .. r] => {
      let (st, r2) = read_string(r)
      (TStr(st), r2)
    }
    ['\'', .. r] => {
      let (code, r2) = read_char(r)
      (TNum(code), r2)
    }
    [_c, ..] => {
      let (p, r2) = read_punct(s)
      (TPunct(p), r2)
    }
    [] => (TEof, s)
  }
}

///|
pub fn tokenize(src : String) -> Array[Tok] {
  let toks : Array[Tok] = []
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
