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
            SymEnumConst => true
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
  let mut complex = false
  let mut n_long = 0
  let mut n_short = 0
  let mut base : CType? = None
  for ts in spec.type_specs {
    match ts {
      @front.TKw(k) =>
        match k {
          "unsigned" => uns = true
          "signed" => ()
          "short" => n_short = n_short + 1
          "long" => n_long = n_long + 1
          "int" => if base is None { base = Some(CInt(false)) }
          "char" => base = Some(CChar(true))
          "void" => base = Some(CVoid)
          "float" => base = Some(CFloat)
          "double" => base = Some(CDouble)
          "_Bool" | "bool" => base = Some(CBool)
          "_Complex" | "_Imaginary" => complex = true
          "__int128" => base = Some(CBitInt(128))
          "__builtin_va_list" | "__builtin_ms_va_list" =>
            base = Some(CPtr(CVoid))
          "__auto_type" => ctx.diags.error("__auto_type is not supported")
          _ => ()
        }
      @front.TStruct(tag, body) =>
        base = Some(CStruct(resolve_aggregate(ctx, tag, body, false)))
      @front.TUnion(tag, body) =>
        base = Some(CUnion(resolve_aggregate(ctx, tag, body, true)))
      @front.TEnum(tag, items) =>
        base = Some(CEnum(define_enum(ctx, tag, items)))
      @front.TTypedefName(n) =>
        match ctx.scopes.lookup(n) {
          Some(s) => base = Some(s.ty)
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
  let r = match b {
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
              }
              return i
            }
          None => ()
        }
      None => ()
    }
  }
  let idx = ctx.layouts.length()
  ctx.layouts.push({ name, is_union, fields, size, align: maxa, enum_vals: [], })
  match tag {
    Some(t) => ctx.scopes.define_tag(t, idx)
    None => ()
  }
  idx
}

///|
fn define_enum(ctx : Ctx, tag : String?, items : Array[@front.EnumItem]) -> Int {
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
      kind: SymEnumConst,
      ty: CInt(false),
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
    size: 4,
    align: 4,
    enum_vals: vals,
  })
  match tag {
    Some(t) => ctx.scopes.define_tag(t, idx)
    None => ()
  }
  idx
}
