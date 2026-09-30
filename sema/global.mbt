///|
fn ensure_len(bytes : Array[Byte], n : Int) -> Unit {
  while bytes.length() < n {
    bytes.push((0).to_byte())
  }
}

///|
fn put_int(bytes : Array[Byte], off : Int, size : Int, v : Int64) -> Unit {
  let mut i = 0
  while i < size {
    let b = ((v >> (i * 8)) & 0xFFL).to_int().to_byte()
    if off + i < bytes.length() {
      bytes[off + i] = b
    } else {
      ensure_len(bytes, off + i)
      bytes[off + i] = b
    }
    i = i + 1
  }
}

///|
fn put_str(bytes : Array[Byte], off : Int, s : String) -> Int {
  let a = s.to_array()
  let mut i = 0
  for c in a {
    let n = c.to_int()
    if n < 128 {
      ensure_len(bytes, off + i + 1)
      bytes[off + i] = n.to_byte()
      i = i + 1
      // minimal UTF-8 encoding
    } else if n < 2048 {
      ensure_len(bytes, off + i + 2)
      bytes[off + i] = (0xC0 | (n >> 6)).to_byte()
      bytes[off + i + 1] = (0x80 | (n & 0x3F)).to_byte()
      i = i + 2
    } else {
      ensure_len(bytes, off + i + 3)
      bytes[off + i] = (0xE0 | (n >> 12)).to_byte()
      bytes[off + i + 1] = (0x80 | ((n >> 6) & 0x3F)).to_byte()
      bytes[off + i + 2] = (0x80 | (n & 0x3F)).to_byte()
      i = i + 3
    }
  }
  i
}

///|
fn ptr_reloc(e : @front.Expr, ctx : Ctx) -> GlobalReloc? {
  match e {
    @front.EString(parts) => {
      let mut joined = ""
      for p in parts {
        joined = joined + p
      }
      let idx = ctx.strings.length()
      ctx.strings.push(joined)
      Some(RString(idx, 0))
    }
    @front.EIdent(n) => Some(RGlobal(n, 0))
    @front.EUnary("&", x) =>
      match x {
        @front.EIdent(n) => Some(RGlobal(n, 0))
        _ => None
      }
    @front.EBinary("+", l, r) =>
      match (ptr_reloc(l, ctx), r) {
        (Some(RGlobal(n, k)), @front.EInt(s)) =>
          if is_const_expr(r, ctx) {
            Some(RGlobal(n, k + const_eval_int(r, ctx).to_int()))
          } else {
            Some(RGlobal(n, k))
          }
        _ => None
      }
    _ => None
  }
}

///|
fn encode_ptr(
  e : @front.Expr,
  off : Int,
  bytes : Array[Byte],
  relocs : Array[(Int, GlobalReloc)],
  ctx : Ctx,
) -> Unit {
  ensure_len(bytes, off + 8)
  match ptr_reloc(e, ctx) {
    Some(r) => relocs.push((off, r))
    None => ()
  }
}

///|
pub fn encode_global_init(
  init : @front.Initializer,
  ty : CType,
  off : Int,
  bytes : Array[Byte],
  relocs : Array[(Int, GlobalReloc)],
  ctx : Ctx,
) -> Unit {
  ensure_len(bytes, off + size_of_ty(ty, ctx.layouts))
  match init {
    @front.IExpr(e) =>
      match ty {
        CPtr(_) => encode_ptr(e, off, bytes, relocs, ctx)
        CArray(el, n) =>
          match e {
            @front.EString(parts) => {
              let mut joined = ""
              for p in parts {
                joined = joined + p
              }
              let s = decode_string(joined)
              let written = put_str(bytes, off, s)
              if n == 0 || written < size_of_ty(el, ctx.layouts) * n {
                ensure_len(bytes, off + written + 1)
              }
            }
            _ => ()
          }
        CFloat => put_int(bytes, off, 4, float_bits32(e, ctx))
        CDouble | CLongDouble => put_int(bytes, off, 8, double_bits64(e, ctx))
        _ =>
          if is_integer(ty) {
            put_int(
              bytes,
              off,
              size_of_ty(ty, ctx.layouts),
              const_eval_int(e, ctx),
            )
          }
      }
    @front.IList(items) =>
      match ty {
        CArray(el, n) => {
          let stride = size_of_ty(el, ctx.layouts)
          let mut idx = 0
          for it in items {
            let o = if it.designators.length() > 0 {
              match it.designators[0] {
                @front.DIndex(de) => const_eval_int(de, ctx).to_int() * stride
                _ => idx * stride
              }
            } else {
              idx * stride
            }
            encode_global_init(it.init, el, off + o, bytes, relocs, ctx)
            idx = idx + 1
          }
        }
        CStruct(i) => {
          let lay = ctx.layouts[i]
          let mut midx = 0
          for it in items {
            let (moff, mty) = if it.designators.length() > 0 {
              match it.designators[0] {
                @front.DField(n) =>
                  match field_of(lay, n) {
                    Some(f) => (f.offset, f.ty)
                    None => (0, CInt(false))
                  }
                _ => (0, CInt(false))
              }
            } else if midx < lay.fields.length() {
              (lay.fields[midx].offset, lay.fields[midx].ty)
            } else {
              (0, CInt(false))
            }
            encode_global_init(it.init, mty, off + moff, bytes, relocs, ctx)
            midx = midx + 1
          }
        }
        CUnion(i) => {
          let lay = ctx.layouts[i]
          if items.length() > 0 && lay.fields.length() > 0 {
            encode_global_init(
              items[0].init,
              lay.fields[0].ty,
              off + lay.fields[0].offset,
              bytes,
              relocs,
              ctx,
            )
          }
        }
        _ =>
          if items.length() > 0 {
            encode_global_init(items[0].init, ty, off, bytes, relocs, ctx)
          }
      }
  }
}

///|
fn float_bits32(e : @front.Expr, ctx : Ctx) -> Int64 {
  match e {
    @front.EFloat(s) =>
      parse_float_lit(s).to_float().reinterpret_as_uint().to_int64()
    _ => const_eval_int(e, ctx)
  }
}

///|
fn double_bits64(e : @front.Expr, ctx : Ctx) -> Int64 {
  match e {
    @front.EFloat(s) => parse_float_lit(s).reinterpret_as_int64()
    _ => const_eval_int(e, ctx)
  }
}
