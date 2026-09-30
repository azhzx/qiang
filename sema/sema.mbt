///|
/// Sema context: scopes, layouts and diagnostics.
pub struct Ctx {
  scopes : ScopeStack
  layouts : Array[Layout]
  diags : Diags
  mut ret_ty : CType?
  strings : Array[String]
  funcs : Array[CheckedFunc]
}

///|
pub struct CheckedProgram {
  layouts : Array[Layout]
  funcs : Array[CheckedFunc]
  strings : Array[String]
  diags : Array[Diag]
}

///|
fn has_storage(spec : @front.DeclSpec, s : String) -> Bool {
  for x in spec.storage {
    if x == s {
      return true
    }
  }
  false
}

///|
fn storage_of(spec : @front.DeclSpec) -> Storage {
  if has_storage(spec, "typedef") {
    StTypedef
  } else if has_storage(spec, "static") {
    StStatic
  } else if has_storage(spec, "extern") {
    StExtern
  } else if has_storage(spec, "register") {
    StRegister
  } else if has_storage(spec, "auto") {
    StAuto
  } else if has_storage(spec, "_Thread_local") ||
    has_storage(spec, "thread_local") ||
    has_storage(spec, "__thread") {
    StThread
  } else {
    StNone
  }
}

///|
fn digit_val(c : Char) -> Int {
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
pub fn parse_int_lit(s : String) -> Int64 {
  let chars = s.to_array()
  let n = chars.length()
  let mut i = 0
  let mut base = 10
  if n >= 2 && chars[0] == '0' && (chars[1] == 'x' || chars[1] == 'X') {
    base = 16
    i = 2
  } else if n >= 2 && chars[0] == '0' && (chars[1] == 'b' || chars[1] == 'B') {
    base = 2
    i = 2
  } else if n >= 1 && chars[0] == '0' {
    base = 8
    i = 1
  }
  let mut v : Int64 = 0L
  while i < n {
    let d = digit_val(chars[i])
    if d < 0 || d >= base {
      break
    }
    v = v * base.to_int64() + d.to_int64()
    i = i + 1
  }
  v
}

///|
pub fn parse_char_lit(s : String) -> Int64 {
  let chars = s.to_array()
  if chars.length() == 0 {
    return 0L
  }
  if chars[0] == '\\' {
    if chars.length() >= 2 {
      match chars[1] {
        'n' => 10L
        't' => 9L
        'r' => 13L
        '0' => 0L
        '\\' => 92L
        '\'' => 39L
        '"' => 34L
        _ => chars[1].to_int().to_int64()
      }
    } else {
      0L
    }
  } else {
    chars[0].to_int().to_int64()
  }
}

///|
pub fn const_eval_int(e : @front.Expr, ctx : Ctx) -> Int64 {
  match e {
    @front.EInt(s) => parse_int_lit(s)
    @front.EChar(s) => parse_char_lit(s)
    @front.EBool(b) => if b { 1L } else { 0L }
    @front.ENullptr => 0L
    @front.EIdent(n) =>
      match ctx.scopes.lookup(n) {
        Some(s) => s.value
        None => 0L
      }
    @front.EBinary(op, l, r) => {
      let a = const_eval_int(l, ctx)
      let b = const_eval_int(r, ctx)
      match op {
        "+" => a + b
        "-" => a - b
        "*" => a * b
        "/" =>
          if b == 0L {
            ctx.diags.error("division by zero in constant expression")
            0L
          } else {
            a / b
          }
        "%" => if b == 0L { 0L } else { a % b }
        "&" => a & b
        "|" => a | b
        "^" => a ^ b
        "<<" => a << b.to_int()
        ">>" => a >> b.to_int()
        "==" => if a == b { 1L } else { 0L }
        "!=" => if a != b { 1L } else { 0L }
        "<" => if a < b { 1L } else { 0L }
        "<=" => if a <= b { 1L } else { 0L }
        ">" => if a > b { 1L } else { 0L }
        ">=" => if a >= b { 1L } else { 0L }
        "&&" => if a != 0L && b != 0L { 1L } else { 0L }
        "||" => if a != 0L || b != 0L { 1L } else { 0L }
        _ => 0L
      }
    }
    @front.EUnary(op, x) => {
      let a = const_eval_int(x, ctx)
      match op {
        "-" => -a
        "~" => -1L - a
        "!" => if a == 0L { 1L } else { 0L }
        _ => 0L
      }
    }
    @front.ECond(c, t, f) =>
      if const_eval_int(c, ctx) != 0L {
        const_eval_int(t, ctx)
      } else {
        const_eval_int(f, ctx)
      }
    @front.ECast(_, _, x) => const_eval_int(x, ctx)
    @front.ESizeofType(spec, d) => {
      let b = declspec_to_type(spec, ctx)
      size_of_ty(build_type(d, b, ctx), ctx.layouts).to_int64()
    }
    @front.EAlignofType(spec, d) => {
      let b = declspec_to_type(spec, ctx)
      align_of_ty(build_type(d, b, ctx), ctx.layouts).to_int64()
    }
    _ => 0L
  }
}

///|
fn check_external(d : @front.ExternalDecl, ctx : Ctx) -> Unit {
  match d {
    @front.EDecl(spec, decls) => {
      let base = declspec_to_type(spec, ctx)
      let is_td = has_storage(spec, "typedef")
      for idecl in decls {
        let ty = build_type(idecl.decl, base, ctx)
        match decl_name(idecl.decl) {
          Some(n) =>
            if is_td {
              ctx.scopes.define({
                name: n,
                kind: SymTypedef,
                ty,
                storage: StTypedef,
                value: 0L,
              })
            } else {
              ctx.scopes.define({
                name: n,
                kind: SymVar,
                ty,
                storage: storage_of(spec),
                value: 0L,
              })
            }
          None => ()
        }
      }
    }
    @front.EFunc(spec, decl, body) => {
      let base = declspec_to_type(spec, ctx)
      let ty = build_type(decl, base, ctx)
      let name = match decl_name(decl) {
        Some(n) => n
        None => ""
      }
      if name != "" {
        ctx.scopes.define({
          name,
          kind: SymFunc,
          ty,
          storage: storage_of(spec),
          value: 0L,
        })
      }
      ctx.scopes.push()
      ctx.scopes.define({
        name: "__func__",
        kind: SymVar,
        ty: CArray(CChar(true), 0),
        storage: StStatic,
        value: 0L,
      })
      ctx.scopes.define({
        name: "__FUNCTION__",
        kind: SymVar,
        ty: CArray(CChar(true), 0),
        storage: StStatic,
        value: 0L,
      })
      ctx.scopes.define({
        name: "__va_area__",
        kind: SymVar,
        ty: CPtr(CChar(true)),
        storage: StNone,
        value: 0L,
      })
      match ty {
        CFunc(r, _, _) => ctx.ret_ty = Some(r)
        _ => ctx.ret_ty = None
      }
      for pd in func_params(decl) {
        let pb = declspec_to_type(pd.spec, ctx)
        let pty = build_type(pd.decl, pb, ctx)
        match decl_name(pd.decl) {
          Some(pn) =>
            ctx.scopes.define({
              name: pn,
              kind: SymVar,
              ty: pty,
              storage: StNone,
              value: 0L,
            })
          None => ()
        }
      }
      let tb = check_stmt(body, ctx)
      ctx.scopes.pop()
      ctx.funcs.push({ name, ty, body: tb, })
    }
    @front.EStaticAssert(e, _msg) =>
      if const_eval_int(e, ctx) == 0L {
        ctx.diags.error("static assertion failed")
      }
    _ => ()
  }
}

///|
/// Check a translation unit: build types, layouts and symbols.
pub fn check(tu : @front.TranslationUnit) -> CheckedProgram {
  let ctx = Ctx::{
    scopes: ScopeStack::new(),
    layouts: [],
    diags: Diags::new(),
    ret_ty: None,
    strings: [],
    funcs: [],
  }
  let va_list_ty = CPtr(CChar(true))
  for b in ["va_start", "va_end", "va_copy", "va_arg"] {
    ctx.scopes.define({
      name: b,
      kind: SymFunc,
      ty: CFunc(CVoid, [va_list_ty, va_list_ty], true),
      storage: StNone,
      value: 0L,
    })
  }
  for d in tu.decls {
    check_external(d, ctx)
  }
  {
    layouts: ctx.layouts,
    funcs: ctx.funcs,
    strings: ctx.strings,
    diags: ctx.diags.items,
  }
}
