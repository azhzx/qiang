///|
/// Sema context: scopes, layouts and diagnostics.
pub struct Ctx {
  scopes : ScopeStack
  // The language mode. Only the QPCC-only relaxations consult it: the lexer
  // has already decided which words are keywords.
  mode : @front.StdMode
  layouts : Array[Layout]
  diags : Diags
  mut ret_ty : CType?
  strings : Array[String]
  funcs : Array[CheckedFunc]
  globals : Array[CheckedGlobal]
  mut cur_params : Array[(String, CType)]
  mut cur_locals : Array[(String, CType, Int)]
  mut loop_depth : Int
  mut switch_depth : Int
  // C2y named loops: the label waiting to name the next loop/switch, and the
  // stack of labels on the enclosing breakable/continuable constructs.
  label_pending : Array[String]
  // Nesting depth inside _Defer statements: jumps out of one are diagnosed.
  mut defer_depth : Int
  break_labels : Array[Array[String]]
  cont_labels : Array[Array[String]]
  mut labels : Map[String, Bool]
  mut gotos : Array[String]
  mut static_counter : Int
}

///|
pub struct CheckedProgram {
  layouts : Array[Layout]
  funcs : Array[CheckedFunc]
  globals : Array[CheckedGlobal]
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
fn has_qualifier(spec : @front.DeclSpec, q : String) -> Bool {
  for x in spec.qualifiers {
    if x == q {
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
fn sign_extend_char(v : Int) -> Int64 {
  let b = v & 0xFF
  if b >= 128 {
    (b - 256).to_int64()
  } else {
    b.to_int64()
  }
}

///|
pub fn parse_char_lit(s : String) -> Int64 {
  let a = s.to_array()
  let n = a.length()
  if n == 0 {
    return 0L
  }
  if a[0] == '\\' && n >= 2 {
    let e = a[1]
    let v = match e {
      'n' => 10
      't' => 9
      'r' => 13
      '0' => 0
      '\\' => 92
      '\'' => 39
      '"' => 34
      'a' => 7
      'b' => 8
      'f' => 12
      'v' => 11
      'x' => {
        let mut vv = 0
        let mut k = 2
        while k < n {
          let d = digit_val(a[k])
          if d < 0 {
            break
          }
          vv = vv * 16 + d
          k = k + 1
        }
        vv
      }
      _ =>
        if e >= '0' && e <= '7' {
          let mut vv = 0
          let mut k = 1
          while k < n && a[k] >= '0' && a[k] <= '7' {
            vv = vv * 8 + (a[k].to_int() - 48)
            k = k + 1
          }
          vv
        } else {
          e.to_int()
        }
    }
    sign_extend_char(v)
  } else {
    sign_extend_char(a[0].to_int())
  }
}

///|
/// Decode C string escapes into the actual bytes (kept as a String).
pub fn decode_string(raw : String) -> String {
  let out = StringBuilder::new()
  let a = raw.to_array()
  let n = a.length()
  let mut i = 0
  while i < n {
    let ch = a[i]
    if ch == '\\' && i + 1 < n {
      i = i + 1
      let e = a[i]
      match e {
        'n' => out.write_char('\n')
        't' => out.write_char('\t')
        'r' => out.write_char('\r')
        '0' => out.write_char('\u{0}')
        '\\' => out.write_char('\\')
        '\'' => out.write_char('\'')
        '"' => out.write_char('"')
        'x' => {
          let mut v = 0
          while i + 1 < n {
            let d = digit_val(a[i + 1])
            if d < 0 {
              break
            }
            v = v * 16 + d
            i = i + 1
          }
          out.write_char(Char::from_int(v))
        }
        _ =>
          if e >= '0' && e <= '7' {
            let mut v = 0
            let mut k = 0
            while i < n && k < 3 && a[i] >= '0' && a[i] <= '7' {
              v = v * 8 + (a[i].to_int() - 48)
              i = i + 1
              k = k + 1
            }
            i = i - 1
            out.write_char(Char::from_int(v))
          } else {
            out.write_char(e)
          }
      }
    } else {
      out.write_char(ch)
    }
    i = i + 1
  }
  out.to_string()
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
    @front.EStaticTag(spec, d, m) =>
      match build_type(d, declspec_to_type(spec, ctx), ctx) {
        CStruct(i) | CUnion(i) =>
          match tag_of(ctx.layouts[i], m) {
            Some(v) => v
            None => 0L
          }
        _ => 0L
      }
    @front.ECountofExpr(x) =>
      match check_expr(x, ctx).ty {
        CArray(_, n) => n.to_int64()
        _ => 0L
      }
    @front.ECountofType(spec, d) =>
      match build_type(d, declspec_to_type(spec, ctx), ctx) {
        CArray(_, n) => n.to_int64()
        _ => 0L
      }
    @front.EMaxofType(spec, d) => {
      let ty = build_type(d, declspec_to_type(spec, ctx), ctx)
      match int_type_limits(ty) {
        Some((_, hi)) => hi
        None => 0L
      }
    }
    @front.EMinofType(spec, d) => {
      let ty = build_type(d, declspec_to_type(spec, ctx), ctx)
      match int_type_limits(ty) {
        Some((lo, _)) => lo
        None => 0L
      }
    }
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
  ctx.diags.cur_line = d.pos.line
  ctx.diags.cur_col = d.pos.col
  match d.kind {
    @front.EDecl(spec, decls) => {
      let base = declspec_to_type(spec, ctx)
      let auto_ty = has_auto_type(spec)
      let is_td = has_storage(spec, "typedef")
      for idecl in decls {
        let b = if auto_ty { infer_auto_type(decls, idecl, ctx) } else { base }
        let ty = build_type(idecl.decl, b, ctx)
        match decl_name(idecl.decl) {
          Some(n) =>
            if is_td {
              ctx.scopes.define({
                name: n,
                gname: "",
                kind: SymTypedef,
                ty,
                storage: StTypedef,
                value: 0L,
              })
            } else if is_func_ty(ty) {
              ctx.scopes.define({
                name: n,
                gname: "",
                kind: SymFunc,
                ty,
                storage: storage_of(spec),
                value: 0L,
              })
            } else {
              let is_cexpr = has_qualifier(spec, "constexpr")
              let cval : Int64 = if is_cexpr {
                match idecl.init {
                  Some(@front.IExpr(e)) =>
                    if is_const_expr(e, ctx) {
                      const_eval_int(e, ctx)
                    } else {
                      ctx.diags.error(
                        "constexpr initializer is not a constant expression",
                      )
                      0L
                    }
                  _ => {
                    ctx.diags.error("constexpr requires a constant initializer")
                    0L
                  }
                }
              } else {
                0L
              }
              ctx.scopes.define({
                name: n,
                gname: "",
                kind: if is_cexpr {
                  SymConstVar
                } else {
                  SymVar
                },
                ty,
                storage: storage_of(spec),
                value: cval,
              })
              let init = match idecl.init {
                Some(@front.IExpr(e)) =>
                  if is_const_expr(e, ctx) {
                    Some(const_eval_int(e, ctx))
                  } else {
                    None
                  }
                _ => None
              }
              let bytes : Array[Byte] = []
              let relocs : Array[(Int, GlobalReloc)] = []
              match idecl.init {
                Some(i) => encode_global_init(i, ty, 0, bytes, relocs, ctx)
                None => ()
              }
              let has_init = idecl.init is Some(_)
              let is_extern = storage_of(spec) is StExtern
              if !(is_extern && !has_init) {
                let is_export = !(storage_of(spec) is StStatic)
                let align = spec_align(spec, ty, ctx)
                ctx.globals.push({
                  name: n,
                  ty,
                  init,
                  bytes,
                  relocs,
                  is_export,
                  align,
                })
              }
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
          gname: "",
          kind: SymFunc,
          ty,
          storage: storage_of(spec),
          value: 0L,
        })
      }
      ctx.scopes.push()
      ctx.cur_params = []
      ctx.cur_locals = []
      ctx.loop_depth = 0
      ctx.switch_depth = 0
      ctx.gotos = []
      ctx.labels = Map::new()
      ctx.scopes.define({
        name: "__func__",
        gname: "",
        kind: SymVar,
        ty: CArray(CChar(true), 0),
        storage: StStatic,
        value: 0L,
      })
      ctx.scopes.define({
        name: "__FUNCTION__",
        gname: "",
        kind: SymVar,
        ty: CArray(CChar(true), 0),
        storage: StStatic,
        value: 0L,
      })
      ctx.scopes.define({
        name: "__va_area__",
        gname: "",
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
        let pty0 = build_type(pd.decl, pb, ctx)
        // Parameters of function or array type are adjusted to pointers.
        let pty = match pty0 {
          CFunc(_, _, _) => CPtr(pty0)
          CArray(e, _) => CPtr(e)
          _ => pty0
        }
        match decl_name(pd.decl) {
          Some(pn) => {
            ctx.cur_params.push((pn, pty))
            ctx.scopes.define({
              name: pn,
              gname: "",
              kind: SymVar,
              ty: pty,
              storage: StNone,
              value: 0L,
            })
          }
          None => ()
        }
      }
      let tb = check_stmt(body, ctx)
      for g in ctx.gotos {
        if !ctx.labels.contains(g) {
          ctx.diags.error("goto to undefined label: " + g)
        }
      }
      collect_locals(tb, ctx.cur_locals)
      ctx.scopes.pop()
      let is_vararg = match ty {
        CFunc(_, _, v) => v
        _ => false
      }
      ctx.funcs.push({
        name,
        ty,
        params: ctx.cur_params,
        locals: ctx.cur_locals,
        is_vararg,
        is_export: !(storage_of(spec) is StStatic),
        body: tb,
        closure: None,
      })
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
pub fn check(
  tu : @front.TranslationUnit,
  mode? : @front.StdMode = @front.Cqe,
) -> CheckedProgram {
  let ctx = Ctx::{
    scopes: ScopeStack::new(),
    mode,
    layouts: [],
    diags: Diags::new(),
    ret_ty: None,
    strings: [],
    funcs: [],
    globals: [],
    cur_params: [],
    cur_locals: [],
    loop_depth: 0,
    switch_depth: 0,
    label_pending: [],
    defer_depth: 0,
    break_labels: [],
    cont_labels: [],
    labels: Map::new(),
    gotos: [],
    static_counter: 0,
  }
  for n in ["__uint128_t", "__int128_t"] {
    ctx.scopes.define({
      name: n,
      gname: "",
      kind: SymTypedef,
      ty: CBitInt(128),
      storage: StTypedef,
      value: 0L,
    })
  }
  let va_list_ty = CPtr(CChar(true))
  ctx.scopes.define({
    name: "alloca",
    gname: "",
    kind: SymFunc,
    ty: CFunc(CPtr(CVoid), [CInt(false)], false),
    storage: StNone,
    value: 0L,
  })
  for b in ["__builtin_alloca", "alloca"] {
    ctx.scopes.define({
      name: b,
      gname: "",
      kind: SymFunc,
      ty: CFunc(CPtr(CVoid), [CInt(false)], false),
      storage: StNone,
      value: 0L,
    })
  }
  for
    b in [
      "va_start", "va_end", "va_copy", "va_arg", "__builtin_va_start", "__builtin_va_end",
      "__builtin_va_copy", "__builtin_va_arg",
    ] {
    ctx.scopes.define({
      name: b,
      gname: "",
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
    globals: ctx.globals,
    strings: ctx.strings,
    diags: ctx.diags.items,
  }
}
