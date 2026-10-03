///|
// Is this declaration specifier an inferred type? Both C23 `auto` (which the
// parser rewrites) and the GNU `__auto_type` arrive as `__auto_type`.
pub fn has_auto_type(spec : @front.DeclSpec) -> Bool {
  for ts in spec.type_specs {
    match ts {
      @front.TKw("__auto_type") => return true
      _ => ()
    }
  }
  false
}

///|
// Infer the declared type from the initializer. C23 requires a single
// declarator, no pointer/array/function declarator, and an initializer.
pub fn infer_auto_type(
  decls : Array[@front.InitDeclarator],
  idecl : @front.InitDeclarator,
  ctx : Ctx,
) -> CType {
  if decls.length() != 1 {
    ctx.diags.error("auto requires exactly one declarator")
    return CInt(false)
  }
  match idecl.decl {
    @front.DName(_) => ()
    _ => {
      ctx.diags.error(
        "auto cannot be used with a pointer, array or function declarator",
      )
      return CInt(false)
    }
  }
  match idecl.init {
    Some(@front.IExpr(e)) => check_expr(e, ctx).ty
    Some(@front.IList(_)) => {
      ctx.diags.error("auto cannot be initialized with a braced initializer")
      CInt(false)
    }
    None => {
      ctx.diags.error("auto requires an initializer")
      CInt(false)
    }
  }
}

///|
/// Resolve a declarator tree against a base type.
pub fn build_type(d : @front.Declarator, base : CType, ctx : Ctx) -> CType {
  match d {
    @front.DName(_) | @front.DAbstract => base
    @front.DPointer(_, inner) => build_type(inner, CPtr(base), ctx)
    @front.DArray(inner, size, _) =>
      match size {
        Some(e) =>
          if is_const_expr(e, ctx) {
            build_type(
              inner,
              CArray(base, const_eval_int(e, ctx).to_int()),
              ctx,
            )
          } else {
            build_type(inner, CVLA(base, check_expr(e, ctx)), ctx)
          }
        None => build_type(inner, CArray(base, 0), ctx)
      }
    @front.DFunction(inner, params, va) => {
      let ps : Array[CType] = []
      for p in params {
        let pb = declspec_to_type(p.spec, ctx)
        let p1 = build_type(p.decl, pb, ctx)
        let p1 = match p1 {
          CFunc(_, _, _) => CPtr(p1)
          CArray(e, _) => CPtr(e)
          _ => p1
        }
        ps.push(p1)
      }
      build_type(inner, CFunc(base, ps, va), ctx)
    }
  }
}

///|
pub fn is_const_expr(e : @front.Expr, ctx : Ctx) -> Bool {
  match e {
    @front.EInt(_) | @front.EChar(_) | @front.EBool(_) | @front.ENullptr => true
    @front.EIdent(n) =>
      match ctx.scopes.lookup(n) {
        Some(s) =>
          match s.kind {
            SymEnumConst | SymConstVar => true
            _ => false
          }
        None => false
      }
    @front.EBinary(_, l, r) => is_const_expr(l, ctx) && is_const_expr(r, ctx)
    @front.EUnary(_, x) => is_const_expr(x, ctx)
    @front.ECond(c, t, f) =>
      is_const_expr(c, ctx) && is_const_expr(t, ctx) && is_const_expr(f, ctx)
    @front.ECast(_, _, x) => is_const_expr(x, ctx)
    @front.ESizeofType(_, _) | @front.EAlignofType(_, _) => true
    @front.EMaxofType(_, _) | @front.EMinofType(_, _) => true
    @front.ECountofExpr(_) | @front.ECountofType(_, _) => true
    @front.EGetTag(_, _, _) => true
    _ => false
  }
}

///|
pub fn decl_name(d : @front.Declarator) -> String? {
  match d {
    @front.DName(n) => Some(n)
    @front.DPointer(_, inner) => decl_name(inner)
    @front.DArray(inner, _, _) => decl_name(inner)
    @front.DFunction(inner, _, _) => decl_name(inner)
    @front.DAbstract => None
  }
}

///|
pub fn declspec_to_type(spec : @front.DeclSpec, ctx : Ctx) -> CType {
  let mut uns = false
  // `signed` written explicitly, and whether the base type came from a typedef
  // (whose own signedness must survive when no specifier overrides it).
  let mut sgn = false
  let mut from_typedef = false
  let mut complex = false
  let mut n_long = 0
  let mut n_short = 0
  let mut base : CType? = None
  for ts in spec.type_specs {
    match ts {
      @front.TKw(k) =>
        match k {
          "unsigned" => uns = true
          "signed" => sgn = true
          "short" => n_short = n_short + 1
          "long" => n_long = n_long + 1
          "int" => if base is None { base = Some(CInt(false)) }
          "char" => base = Some(CChar(true))
          "void" => base = Some(CVoid)
          "float" => base = Some(CFloat)
          "double" => base = Some(CDouble)
          "_Bool" | "bool" => base = Some(CBool)
          "char8_t" => base = Some(CChar(false))
          "_Complex" | "_Imaginary" => complex = true
          "__int128" => base = Some(CBitInt(128))
          "__builtin_va_list" | "__builtin_ms_va_list" =>
            base = Some(CPtr(CVoid))
          // Handled by the declaration sites via has_auto_type/infer_auto_type.
          "__auto_type" => ()
          _ => ()
        }
      @front.TStruct(tag, body) =>
        base = Some(CStruct(resolve_aggregate(ctx, tag, body, false)))
      @front.TUnion(tag, body) =>
        base = Some(CUnion(resolve_aggregate(ctx, tag, body, true)))
      @front.TTaggedUnion(tag, body) =>
        base = Some(resolve_tagged_union(ctx, tag, body))
      @front.TEnum(tag, items, underlying) => {
        base = Some(define_enum(ctx, tag, items, underlying))
        // An enum is represented by its underlying integer type; keep the
        // suffix logic below from re-applying "signed"/"unsigned" to it.
        from_typedef = true
      }
      @front.TTypedefName(n) =>
        match ctx.scopes.lookup(n) {
          Some(s) => {
            base = Some(s.ty)
            from_typedef = true
          }
          None => ctx.diags.error("unknown type name: " + n)
        }
      @front.TTypeofType(s2, d2) => {
        let b = declspec_to_type(s2, ctx)
        base = Some(build_type(d2, b, ctx))
      }
      @front.TTypeofExpr(e) => base = Some(check_expr(e, ctx).ty)
      @front.TAtomicSpec(s2, d2) => {
        let b = declspec_to_type(s2, ctx)
        base = Some(build_type(d2, b, ctx))
      }
      @front.TBitInt(e) => base = Some(CBitInt(const_eval_int(e, ctx).to_int()))
    }
  }
  let b = match base {
    Some(t) => t
    None => CInt(false)
  }
  let r = if from_typedef && !uns && !sgn && n_short == 0 && n_long == 0 {
    // `uint x` keeps uint's own signedness rather than defaulting to signed.
    b
  } else {
    match b {
      CChar(_) => CChar(!uns)
      CShort(_) => CShort(!uns)
      CInt(_) =>
        if n_short > 0 {
          CShort(!uns)
        } else if n_long == 1 {
          CLong(!uns)
        } else if n_long >= 2 {
          CLongLong(!uns)
        } else {
          CInt(!uns)
        }
      CDouble => if n_long > 0 { CLongDouble } else { CDouble }
      other => other
    }
  }
  if complex {
    CComplex(r)
  } else {
    r
  }
}

///|
/// Resolve a struct/union type: reuse an existing tag when there is no body,
/// otherwise define a new layout.
fn resolve_aggregate(
  ctx : Ctx,
  tag : String?,
  body : Array[@front.StructDecl],
  is_union : Bool,
) -> Int {
  if body.length() == 0 {
    match tag {
      Some(t) =>
        match ctx.scopes.lookup_tag(t) {
          Some(i) => return i
          None => ()
        }
      None => ()
    }
  }
  define_aggregate(ctx, tag, body, is_union)
}

///|
///|
/// Resolve a `_Tagged_union Tag { ... }`: an existing tag with no body, or
/// a freshly defined one.
fn resolve_tagged_union(
  ctx : Ctx,
  tag : String,
  body : Array[@front.StructDecl],
) -> CType {
  if body.length() == 0 {
    match ctx.scopes.lookup_tag(tag) {
      Some(i) =>
        if ctx.layouts[i].tagged {
          return CStruct(i)
        } else {
          ctx.diags.error("not a _Tagged_union: " + tag)
        }
      None => ctx.diags.error("unknown _Tagged_union: " + tag)
    }
  }
  define_tagged_union(ctx, tag, body)
}

///|
/// Define `_Tagged_union Tag { body }`: the synthetic int tag sits at
/// offset 0 and the members overlap after it, like
/// `struct { int __tag; union { members } __payload; }`.
fn define_tagged_union(
  ctx : Ctx,
  tag : String,
  body : Array[@front.StructDecl],
) -> CType {
  let fields : Array[Field] = []
  let tag_vals : Array[(String, Int64)] = []
  let mut maxa = 1
  let mut maxsz = 0
  let mut next : Int64 = 0L
  for sd in body {
    match sd {
      @front.SDecl(spec, decls) =>
        for idecl in decls {
          let b = declspec_to_type(spec, ctx)
          let ty = build_type(idecl.decl, b, ctx)
          match idecl.bits {
            Some(_) =>
              ctx.diags.error("_Tagged_union members cannot be bit-fields")
            None => ()
          }
          let name = match decl_name(idecl.decl) {
            Some(n) => n
            None => ""
          }
          if name == "" {
            ctx.diags.error("_Tagged_union members need names")
          } else {
            let a = align_of_ty(ty, ctx.layouts)
            let sz = size_of_ty(ty, ctx.layouts)
            if a > maxa {
              maxa = a
            }
            if sz > maxsz {
              maxsz = sz
            }
            fields.push({ name, ty, offset: 0, bit_width: 0, bit_offset: 0, })
            tag_vals.push((name, next))
            next = next + 1L
          }
        }
      @front.SStaticAssert(e, _) =>
        if const_eval_int(e, ctx) == 0L {
          ctx.diags.error("static assertion failed")
        }
      @front.SAnon(_) =>
        ctx.diags.error("_Tagged_union members need names")
      @front.SPragma(_) => ()
    }
  }
  if fields.length() == 0 {
    ctx.diags.error("_Tagged_union needs at least one member")
  }
  let payload_off = align_up(4, maxa)
  let align = if maxa > 4 { maxa } else { 4 }
  let size = align_up(payload_off + maxsz, align)
  let idx = ctx.layouts.length()
  ctx.layouts.push({
    name: tag,
    is_union: false,
    fields,
    size,
    align,
    enum_vals: [],
    enum_ty: None,
    tagged: true,
    payload_off,
    tag_vals,
  })
  ctx.scopes.define_tag(tag, idx)
  CStruct(idx)
}

///|
fn define_aggregate(
  ctx : Ctx,
  tag : String?,
  body : Array[@front.StructDecl],
  is_union : Bool,
) -> Int {
  let fields : Array[Field] = []
  let mut off = 0
  let mut maxa = 1
  let mut maxsz = 0
  let mut bit_pos = 0
  let mut unit_off = 0
  for sd in body {
    match sd {
      @front.SDecl(spec, decls) =>
        for idecl in decls {
          let b = declspec_to_type(spec, ctx)
          let ty = build_type(idecl.decl, b, ctx)
          let name = match decl_name(idecl.decl) {
            Some(n) => n
            None => ""
          }
          let a = align_of_ty(ty, ctx.layouts)
          let sz = size_of_ty(ty, ctx.layouts)
          if a > maxa {
            maxa = a
          }
          if sz > maxsz {
            maxsz = sz
          }
          let w = match idecl.bits {
            Some(e) => const_eval_int(e, ctx).to_int()
            None => 0
          }
          if w > 0 && !is_union {
            let unit_bits = sz * 8
            if bit_pos == 0 {
              unit_off = align_up(off, a)
            }
            if bit_pos + w > unit_bits {
              unit_off = align_up(unit_off + (bit_pos + 7) / 8, a)
              bit_pos = 0
            }
            fields.push({
              name,
              ty,
              offset: unit_off,
              bit_width: w,
              bit_offset: bit_pos,
            })
            bit_pos = bit_pos + w
            off = unit_off + (bit_pos + 7) / 8
          } else {
            bit_pos = 0
            let fo = if is_union {
              0
            } else {
              let o = align_up(off, a)
              off = o + sz
              o
            }
            fields.push({ name, ty, offset: fo, bit_width: 0, bit_offset: 0, })
          }
        }
      @front.SAnon(spec) => {
        let ty = declspec_to_type(spec, ctx)
        match ty {
          CStruct(i) | CUnion(i) => {
            let lay = ctx.layouts[i]
            if lay.align > maxa {
              maxa = lay.align
            }
            if lay.size > maxsz {
              maxsz = lay.size
            }
            let base_off = if is_union { 0 } else { align_up(off, lay.align) }
            for f in lay.fields {
              fields.push({
                name: f.name,
                ty: f.ty,
                offset: base_off + f.offset,
                bit_width: f.bit_width,
                bit_offset: f.bit_offset,
              })
            }
            if !is_union {
              off = base_off + lay.size
            }
          }
          _ => {
            let a = align_of_ty(ty, ctx.layouts)
            let sz = size_of_ty(ty, ctx.layouts)
            if a > maxa {
              maxa = a
            }
            if sz > maxsz {
              maxsz = sz
            }
            let fo = if is_union {
              0
            } else {
              let o = align_up(off, a)
              off = o + sz
              o
            }
            fields.push({
              name: "",
              ty,
              offset: fo,
              bit_width: 0,
              bit_offset: 0,
            })
          }
        }
      }
      _ => ()
    }
  }
  let size = if is_union { align_up(maxsz, maxa) } else { align_up(off, maxa) }
  let name = match tag {
    Some(t) => t
    None => ""
  }
  if fields.length() > 0 {
    match tag {
      Some(t) =>
        match ctx.scopes.lookup_tag(t) {
          Some(i) =>
            if ctx.layouts[i].fields.length() == 0 {
              ctx.layouts[i] = {
                name,
                is_union,
                fields,
                size,
                align: maxa,
                enum_vals: [],
                enum_ty: None,
                tagged: false,
                payload_off: 0,
                tag_vals: [],
              }
              return i
            }
          None => ()
        }
      None => ()
    }
  }
  let idx = ctx.layouts.length()
  ctx.layouts.push({
    name,
    is_union,
    fields,
    size,
    align: maxa,
    enum_vals: [],
    enum_ty: None,
    tagged: false,
    payload_off: 0,
    tag_vals: [],
  })
  match tag {
    Some(t) => ctx.scopes.define_tag(t, idx)
    None => ()
  }
  idx
}

///|
fn define_enum(
  ctx : Ctx,
  tag : String?,
  items : Array[@front.EnumItem],
  underlying : @front.DeclSpec?,
) -> CType {
  // A reference to an already-defined tag (`enum E x;`) has no body and no
  // underlying specifier: return the type recorded when E was defined.
  if items.length() == 0 {
    match tag {
      Some(t) =>
        match ctx.scopes.lookup_tag(t) {
          Some(i) =>
            match ctx.layouts[i].enum_ty {
              Some(u) => return u
              None => ()
            }
          None => ()
        }
      None => ()
    }
  }
  // C23 `enum E : T` fixes the underlying type; otherwise it is int. The enum
  // is represented by that integer type so layout and code generation reuse
  // the existing integer support.
  let u0 = match underlying {
    Some(spec) => declspec_to_type(spec, ctx)
    None => CInt(false)
  }
  let u = if is_integer(u0) {
    u0
  } else {
    ctx.diags.error("enum underlying type must be an integer type")
    CInt(false)
  }

  let vals : Array[(String, Int64)] = []
  let mut next : Int64 = 0L
  for it in items {
    let v = match it.value {
      Some(e) => const_eval_int(e, ctx)
      None => next
    }
    vals.push((it.name, v))
    ctx.scopes.define({
      name: it.name,
      gname: "",
      kind: SymEnumConst,
      ty: u,
      storage: StNone,
      value: v,
    })
    next = v + 1L
  }
  let idx = ctx.layouts.length()
  ctx.layouts.push({
    name: match tag {
      Some(t) => t
      None => ""
    },
    is_union: false,
    fields: [],
    size: size_of_ty(u, ctx.layouts),
    align: align_of_ty(u, ctx.layouts),
    enum_vals: vals,
    enum_ty: Some(u),
    tagged: false,
    payload_off: 0,
    tag_vals: [],
  })
  match tag {
    Some(t) => ctx.scopes.define_tag(t, idx)
    None => ()
  }
  u
}
