///|
/// Tokens for the QPCC C subset.
pub(all) enum Tok {
  TIdent(String)
  TNum(Int64)
  TFlt(Double, Bool)
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
fn hexval(c : Char) -> Int {
  let n = c.to_int()
  if n >= 48 && n <= 57 {
    n - 48
  } else if n >= 97 && n <= 102 {
    n - 87
  } else if n >= 65 && n <= 70 {
    n - 55
  } else {
    -1
  }
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
    | "goto"
    | "switch"
    | "case"
    | "default"
    | "sizeof"
    | "int"
    | "char"
    | "short"
    | "long"
    | "signed"
    | "unsigned"
    | "float"
    | "double"
    | "void"
    | "_Bool"
    | "bool"
    | "struct"
    | "union"
    | "enum"
    | "typedef"
    | "static"
    | "extern"
    | "const"
    | "volatile"
    | "register"
    | "auto"
    | "inline"
    | "restrict"
    | "_Noreturn"
    | "_Alignas"
    | "_Alignof"
    | "_Static_assert"
    | "_Generic"
    | "_Atomic"
    | "_Thread_local"
    | "true"
    | "false"
    | "nullptr"
    | "typeof"
    | "constexpr"
    | "static_assert" => true
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
fn pow10(n : Int) -> Double {
  let mut r = 1.0
  for _i in 0..<n {
    r = r * 10.0
  }
  r
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
    ['-', '>', .. r] => ("->", r)
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
/// Skip whitespace, line comments and block comments.
fn skip_ws(s : StringView) -> StringView {
  let mut rest = s
  let mut go = true
  while go {
    match rest {
      [c, .. r] if is_space(c) => rest = r
      ['/', '/', .. r] => {
        let mut rr = r
        let mut done = false
        for c2 = r {
          match c2 {
            ['\n', .. r3] => {
              rr = r3
              done = true
              break
            }
            [_, .. r3] => {
              rr = r3
              continue r3
            }
            [] => {
              done = true
              break
            }
          }
        }
        let _ = done
        rest = rr
      }
      ['/', '*', .. r] => {
        let mut rr = r
        let mut done = false
        for c2 = r {
          match c2 {
            ['*', '/', .. r3] => {
              rr = r3
              done = true
              break
            }
            [_, .. r3] => {
              rr = r3
              continue r3
            }
            [] => {
              done = true
              break
            }
          }
        }
        let _ = done
        rest = rr
      }
      _ => go = false
    }
  }
  rest
}

///|
fn scan_digits(s : StringView, base : Int) -> (Int64, Int, StringView) {
  let mut v : Int64 = 0L
  let mut n = 0
  let mut rest = s
  for cur = s {
    match cur {
      [c, .. r] => {
        let d = hexval(c)
        if d >= 0 && d < base {
          v = v * base.to_int64() + d.to_int64()
          n = n + 1
          rest = r
          continue r
        }
        break
      }
      [] => break
    }
  }
  (v, n, rest)
}

///|
fn skip_int_suffix(s : StringView) -> StringView {
  let mut rest = s
  let mut go = true
  while go {
    match rest {
      ['u', .. r] | ['U', .. r] | ['l', .. r] | ['L', .. r] => rest = r
      _ => go = false
    }
  }
  rest
}

///|
fn read_num(s : StringView) -> (Tok, StringView) {
  match s {
    ['0', 'x', .. r0] | ['0', 'X', .. r0] => {
      let (v, _n, r) = scan_digits(r0, 16)
      (TNum(v), skip_int_suffix(r))
    }
    ['0', 'b', .. r0] | ['0', 'B', .. r0] => {
      let (v, _n, r) = scan_digits(r0, 2)
      (TNum(v), skip_int_suffix(r))
    }
    _ => {
      let (ipart, _n, r1) = scan_digits(s, 10)
      match r1 {
        ['.', .. r2] => {
          let (frac, fd, r3) = scan_digits(r2, 10)
          let (exp, r4) = read_exp(r3)
          let val = (ipart.to_double() + frac.to_double() / pow10(fd)) *
            pow10(exp)
          let (is_f, r5) = float_suffix(r4)
          (TFlt(val, is_f), r5)
        }
        ['e', .. _r2] | ['E', .. _r2] => {
          let (exp, r3) = read_exp(r1)
          let (is_f, r4) = float_suffix(r3)
          (TFlt(ipart.to_double() * pow10(exp), is_f), r4)
        }
        _ => (TNum(ipart), skip_int_suffix(r1))
      }
    }
  }
}

///|
fn read_exp(s : StringView) -> (Int, StringView) {
  match s {
    ['e', .. r] | ['E', .. r] => {
      let (neg, r1) = match r {
        ['-', .. r2] => (true, r2)
        ['+', .. r2] => (false, r2)
        _ => (false, r)
      }
      let (v, _n, r2) = scan_digits(r1, 10)
      (if neg { -v.to_int() } else { v.to_int() }, r2)
    }
    _ => (0, s)
  }
}

///|
fn float_suffix(s : StringView) -> (Bool, StringView) {
  match s {
    ['f', .. r] | ['F', .. r] => (true, r)
    ['l', .. r] | ['L', .. r] => (false, r)
    _ => (false, s)
  }
}

///|
fn next_token(s : StringView) -> (Tok, StringView) {
  let s = skip_ws(s)
  match s {
    [c, .. _r] if is_digit(c) => read_num(s)
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
