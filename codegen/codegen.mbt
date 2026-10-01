///|
priv struct Cg {
  b : @ir_builder.Builder
  layouts : Array[@sema.Layout]
  strings : Array[String]
  mut locals : Map[String, Int]
  mut local_ty : Map[String, @sema.CType]
  mut labels : Map[String, Int]
  mut fid : Int
  break_blks : Array[Int]
  cont_blks : Array[Int]
  mut ret_ty : @sema.CType
  mut open : Bool
  mut ret_sret : Bool
  mut sret_ptr : Int
  mut scratch : Int
  mut bump : Int
  mut block_seq : Int
  label_ids : Map[String, Int]
  mut label_seq : Int
  mut cur_labels : Array[String]
}

///|
fn cls_of(ty : @sema.CType) -> @types.Class {
  match ty {
    @sema.CVoid => @types.Kw
    @sema.CFloat => @types.Ks
    @sema.CDouble | @sema.CLongDouble => @types.Kd
    @sema.CLong(_)
    | @sema.CLongLong(_)
    | @sema.CPtr(_)
    | @sema.CFunc(_, _, _)
    | @sema.CArray(_, _)
    | @sema.CVLA(_, _)
    | @sema.CStruct(_)
    | @sema.CUnion(_)
    | @sema.CComplex(_) => @types.Kl
    _ => @types.Kw
  }
}

///|
fn ret_of(ty : @sema.CType) -> @ir_builder.Ret {
  match ty {
    @sema.CVoid => @ir_builder.Void
    @sema.CFloat => @ir_builder.Single
    @sema.CDouble | @sema.CLongDouble => @ir_builder.Double
    @sema.CLong(_)
    | @sema.CLongLong(_)
    | @sema.CPtr(_)
    | @sema.CFunc(_, _, _)
    | @sema.CArray(_, _)
    | @sema.CVLA(_, _)
    | @sema.CStruct(_)
    | @sema.CUnion(_) => @ir_builder.Long
    _ => @ir_builder.Word
  }
}

///|
fn is_aggregate(ty : @sema.CType) -> Bool {
  match ty {
    @sema.CArray(_, _)
    | @sema.CVLA(_, _)
    | @sema.CStruct(_)
    | @sema.CUnion(_)
    | @sema.CComplex(_) => true
    _ => false
  }
}

///|
fn size_of(ty : @sema.CType, layouts : Array[@sema.Layout]) -> Int {
  @sema.size_of_ty(ty, layouts)
}

///|
fn align_of(ty : @sema.CType, layouts : Array[@sema.Layout]) -> Int {
  @sema.align_of_ty(ty, layouts)
}

///|
fn is_flt(ty : @sema.CType) -> Bool {
  @sema.is_float(ty)
}

///|
fn is_uns(ty : @sema.CType) -> Bool {
  @sema.is_integer(ty) && !@sema.is_signed(ty)
}

///|
fn wider(l : @sema.CType, r : @sema.CType) -> @types.Class {
  let a = cls_of(l)
  let b = cls_of(r)
  if a == @types.Kd || b == @types.Kd {
    @types.Kd
  } else if a == @types.Ks || b == @types.Ks {
    @types.Ks
  } else if a == @types.Kl || b == @types.Kl {
    @types.Kl
  } else {
    @types.Kw
  }
}

///|
fn Cg::zero_of(c : Cg, cls : @types.Class) -> Int {
  if cls == @types.Ks {
    c.b.sconst(c.fid, 0.0)
  } else if cls == @types.Kd {
    c.b.fconst(c.fid, 0.0)
  } else {
    c.b.iconst(c.fid, 0L)
  }
}

///|
fn Cg::one_of(c : Cg, cls : @types.Class) -> Int {
  if cls == @types.Ks {
    c.b.sconst(c.fid, 1.0)
  } else if cls == @types.Kd {
    c.b.fconst(c.fid, 1.0)
  } else {
    c.b.iconst(c.fid, 1L)
  }
}

///|
fn Cg::norm_bool(c : Cg, v : Int) -> Int {
  c.b.cmp(c.fid, @types.Cnew, @types.Kw, v, c.b.iconst(c.fid, 0L))
}

///|
fn Cg::coerce(
  c : Cg,
  v : Int,
  from : @types.Class,
  to : @types.Class,
  uns? : Bool = false,
) -> Int {
  if from == to {
    v
  } else if from == @types.Kw && to == @types.Kl {
    // A 32-bit word widened to 64 bits keeps its value only if the
    // extension matches the source signedness.  Using Extsw for an
    // unsigned source turns 0x80000000 into -2147483648.
    if uns {
      c.b.unop(c.fid, @types.Extuw, @types.Kl, @types.Kl, v)
    } else {
      c.b.unop(c.fid, @types.Extsw, @types.Kl, @types.Kl, v)
    }
  } else if from == @types.Kl && to == @types.Kw {
    c.b.unop(c.fid, @types.Copy, @types.Kw, @types.Kw, v)
  } else if from == @types.Kw && to == @types.Ks {
    c.b.unop(c.fid, @types.Swtof, @types.Ks, @types.Ks, v)
  } else if from == @types.Kl && to == @types.Ks {
    c.b.unop(c.fid, @types.Sltof, @types.Ks, @types.Ks, v)
  } else if from == @types.Kw && to == @types.Kd {
    c.b.unop(c.fid, @types.Swtof, @types.Kd, @types.Kd, v)
  } else if from == @types.Kl && to == @types.Kd {
    c.b.unop(c.fid, @types.Sltof, @types.Kd, @types.Kd, v)
  } else if from == @types.Ks && to == @types.Kd {
    c.b.unop(c.fid, @types.Exts, @types.Kd, @types.Kd, v)
  } else if from == @types.Kd && to == @types.Ks {
    c.b.unop(c.fid, @types.Truncd, @types.Ks, @types.Ks, v)
  } else if from == @types.Ks && to == @types.Kw {
    c.b.unop(c.fid, @types.Stosi, @types.Kw, @types.Kw, v)
  } else if from == @types.Kd && to == @types.Kw {
    c.b.unop(c.fid, @types.Dtosi, @types.Kw, @types.Kw, v)
  } else if from == @types.Ks && to == @types.Kl {
    c.b.unop(c.fid, @types.Stosi, @types.Kl, @types.Kl, v)
  } else if from == @types.Kd && to == @types.Kl {
    c.b.unop(c.fid, @types.Dtosi, @types.Kl, @types.Kl, v)
  } else {
    v
  }
}

///|
fn Cg::load_scalar(c : Cg, ty : @sema.CType, addr : Int) -> Int {
  match ty {
    @sema.CBool => c.b.load(c.fid, @types.Loadub, @types.Kw, addr)
    @sema.CChar(s) =>
      c.b.load(
        c.fid,
        if s {
          @types.Loadsb
        } else {
          @types.Loadub
        },
        @types.Kw,
        addr,
      )
    @sema.CShort(s) =>
      c.b.load(
        c.fid,
        if s {
          @types.Loadsh
        } else {
          @types.Loaduh
        },
        @types.Kw,
        addr,
      )
    @sema.CInt(s) =>
      c.b.load(
        c.fid,
        if s {
          @types.Loadsw
        } else {
          @types.Loaduw
        },
        @types.Kw,
        addr,
      )
    @sema.CEnum(_) => c.b.load(c.fid, @types.Loadsw, @types.Kw, addr)
    @sema.CBitInt(n) =>
      if n <= 32 {
        c.b.load(c.fid, @types.Loadsw, @types.Kw, addr)
      } else {
        c.b.load(c.fid, @types.Load, @types.Kl, addr)
      }
    @sema.CLong(_) | @sema.CLongLong(_) | @sema.CPtr(_) =>
      c.b.load(c.fid, @types.Load, @types.Kl, addr)
    @sema.CFloat => c.b.load(c.fid, @types.Load, @types.Ks, addr)
    @sema.CDouble | @sema.CLongDouble =>
      c.b.load(c.fid, @types.Load, @types.Kd, addr)
    _ => addr
  }
}

///|
fn Cg::store_scalar(c : Cg, ty : @sema.CType, val : Int, addr : Int) -> Unit {
  match ty {
    @sema.CBool | @sema.CChar(_) =>
      c.b.store(c.fid, @types.Storeb, @types.Kw, val, addr)
    @sema.CShort(_) => c.b.store(c.fid, @types.Storeh, @types.Kw, val, addr)
    @sema.CInt(_) | @sema.CEnum(_) =>
      c.b.store(c.fid, @types.Storew, @types.Kw, val, addr)
    @sema.CBitInt(n) =>
      if n <= 32 {
        c.b.store(c.fid, @types.Storew, @types.Kw, val, addr)
      } else {
        c.b.store(c.fid, @types.Storel, @types.Kl, val, addr)
      }
    @sema.CLong(_) | @sema.CLongLong(_) | @sema.CPtr(_) =>
      c.b.store(c.fid, @types.Storel, @types.Kl, val, addr)
    @sema.CFloat => c.b.store(c.fid, @types.Stores, @types.Ks, val, addr)
    @sema.CDouble | @sema.CLongDouble =>
      c.b.store(c.fid, @types.Stored, @types.Kd, val, addr)
    _ => ()
  }
}

///|
fn Cg::new_block(c : Cg, name : String) -> Int {
  c.block_seq = c.block_seq + 1
  c.b.add_block(c.fid, name + "." + c.block_seq.to_string())
}

///|
fn Cg::switch(c : Cg, blk : Int) -> Unit {
  c.b.switch_to(c.fid, blk)
  c.open = true
}

///|
fn is_composite(ty : @sema.CType) -> Bool {
  match ty {
    @sema.CStruct(_)
    | @sema.CUnion(_)
    | @sema.CArray(_, _)
    | @sema.CVLA(_, _)
    | @sema.CComplex(_) => true
    _ => false
  }
}

///|
fn Cg::alloc_slot(c : Cg, size : Int) -> Int {
  c.alloc_slot_al(size, 0)
}

///|
// Write a bitfield: read the containing unit, clear the field's bits and
// place the new value.
fn Cg::store_bitfield(
  c : Cg,
  ty : @sema.CType,
  value : Int,
  addr : Int,
  bo : Int,
  bw : Int,
) -> Unit {
  let cls = cls_of(ty)
  let old = c.load_scalar(ty, addr)
  let fmask = (1L << bw) - 1L
  let nmask = -1L ^ (fmask << bo)
  let cleared = c.b.arith(c.fid, @types.And, cls, old, c.b.iconst(c.fid, nmask))
  let masked = c.b.arith(
    c.fid,
    @types.And,
    cls,
    value,
    c.b.iconst(c.fid, fmask),
  )
  let placed = c.b.arith(
    c.fid,
    @types.Shl,
    cls,
    masked,
    c.b.iconst(c.fid, bo.to_int64()),
  )
  let nv = c.b.arith(c.fid, @types.Or, cls, cleared, placed)
  c.store_scalar(ty, nv, addr)
}

///|
// Clear `size` bytes at `addr` with 8-byte stores.
fn Cg::zero_mem(c : Cg, addr : Int, size : Int) -> Unit {
  let mut off = 0
  while off < size {
    let a = if off == 0 {
      addr
    } else {
      c.b.arith(
        c.fid,
        @types.Add,
        @types.Kl,
        addr,
        c.b.iconst(c.fid, off.to_int64()),
      )
    }
    c.store_scalar(@sema.CLong(false), c.b.iconst(c.fid, 0L), a)
    off = off + 8
  }
}

///|
// Allocate a stack slot with an explicit alignment (C _Alignas).
fn Cg::alloc_slot_al(c : Cg, size : Int, align : Int) -> Int {
  let a = if align < 8 { 8 } else if align <= 16 { align } else { 16 }
  let sz = if size < a { a } else { (size + a - 1) / a * a }
  let op = if a >= 16 {
    @types.Alloc16
  } else if a >= 8 {
    @types.Alloc8
  } else {
    @types.Alloc4
  }
  c.b.emit_ins(
    c.fid,
    op,
    @types.Kl,
    @types.Kl,
    c.b.iconst(c.fid, sz.to_int64()),
    -1,
  )
}

///|
fn Cg::emit_memcpy(c : Cg, dst : Int, src : Int, n : Int) -> Unit {
  let _ = c.b.call(
    c.fid,
    "memcpy",
    [
      (@types.Kl, dst),
      (@types.Kl, src),
      (@types.Kl, c.b.iconst(c.fid, n.to_int64())),
    ],
    @ir_builder.Void,
  )
}

///|
/// Number of 8-byte register words a composite parameter occupies (<16B).
fn param_words(sz : Int) -> Int {
  (sz + 7) / 8
}

///|
fn is_cmp(op : String) -> Bool {
  op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">="
}

///|
fn Cg::bitfield_addr(c : Cg, base : @sema.TExpr, off : Int) -> Int {
  let a = c.gen_addr(base)
  if off == 0 {
    a
  } else {
    c.b.arith(
      c.fid,
      @types.Add,
      @types.Kl,
      a,
      c.b.iconst(c.fid, off.to_int64()),
    )
  }
}

///|
fn Cg::bitfield_read(
  c : Cg,
  ty : @sema.CType,
  addr : Int,
  bo : Int,
  bw : Int,
) -> Int {
  let raw = c.load_scalar(ty, addr)
  let cls = cls_of(ty)
  let bits = size_of(ty, c.layouts) * 8
  let shl = c.b.arith(
    c.fid,
    @types.Shl,
    cls,
    raw,
    c.b.iconst(c.fid, (bits - bo - bw).to_int64()),
  )
  let sr = if is_uns(ty) { @types.Shr } else { @types.Sar }
  c.b.arith(c.fid, sr, cls, shl, c.b.iconst(c.fid, (bits - bw).to_int64()))
}

///|
fn elem_of(ty : @sema.CType) -> @sema.CType {
  match ty {
    @sema.CPtr(t) => t
    @sema.CArray(t, _) => t
    @sema.CComplex(t) => t
    _ => ty
  }
}

///|
fn Cg::gen_addr(c : Cg, e : @sema.TExpr) -> Int {
  match e.kind {
    @sema.TVar(n) =>
      match c.locals.get(n) {
        Some(a) => a
        None => c.b.global(c.fid, n)
      }
    @sema.TDeref(p) => c.gen_expr(p)
    @sema.TMember(b, off) => {
      let a = c.gen_addr(b)
      if off == 0 {
        a
      } else {
        c.b.arith(
          c.fid,
          @types.Add,
          @types.Kl,
          a,
          c.b.iconst(c.fid, off.to_int64()),
        )
      }
    }
    @sema.TCompoundLit(stores) => {
      let raw = size_of(e.ty, c.layouts)
      let slot = c.alloc_slot(raw)
      // C zero-fills members an initializer list leaves out, so clear the
      // whole object before applying the explicit stores.
      c.zero_mem(slot, raw)
      for entry in stores {
        let (off, x, bo, bw) = entry
        let addr = if off == 0 {
          slot
        } else {
          c.b.arith(
            c.fid,
            @types.Add,
            @types.Kl,
            slot,
            c.b.iconst(c.fid, off.to_int64()),
          )
        }
        let v = c.gen_expr(x)
        // A composite member is a pointer to the value, so it is copied rather
        // than stored as a scalar (store_scalar ignores aggregate types).
        if is_composite(x.ty) {
          c.emit_memcpy(addr, v, size_of(x.ty, c.layouts))
        } else {
          let vv = c.coerce(v, cls_of(x.ty), cls_of(x.ty))
          if bw > 0 {
            c.store_bitfield(x.ty, vv, addr, bo, bw)
          } else {
            c.store_scalar(x.ty, vv, addr)
          }
        }
      }
      slot
    }
    _ =>
      if is_composite(e.ty) {
        c.gen_expr(e)
      } else {
        let v = c.gen_expr(e)
        let slot = c.alloc_slot(size_of(e.ty, c.layouts))
        c.store_scalar(e.ty, v, slot)
        slot
      }
  }
}

///|
fn Cg::gen_expr(c : Cg, e : @sema.TExpr) -> Int {
  match e.kind {
    @sema.TInt(n) => c.b.iconst(c.fid, n)
    @sema.TFlt(v, is_f) =>
      if is_f {
        c.b.sconst(c.fid, Float::from_double(v))
      } else {
        c.b.fconst(c.fid, v)
      }
    @sema.TStr(i) => c.b.global(c.fid, c.strings[i])
    @sema.TLabelAddr(n) =>
      c.b.iconst(
        c.fid,
        match c.label_ids.get(n) {
          Some(x) => x.to_int64()
          None => 0L
        },
      )
    @sema.TVar(n) =>
      match c.locals.get(n) {
        Some(a) => {
          let ty = match c.local_ty.get(n) {
            Some(t) => t
            None => e.ty
          }
          if is_aggregate(ty) {
            a
          } else {
            c.load_scalar(ty, a)
          }
        }
        None =>
          match e.ty {
            @sema.CFunc(_, _, _) => c.b.global(c.fid, n)
            _ => {
              let a = c.b.global(c.fid, n)
              if is_aggregate(e.ty) {
                a
              } else {
                c.load_scalar(e.ty, a)
              }
            }
          }
      }
    @sema.TAddr(x) => c.gen_addr(x)
    @sema.TDeref(p) => {
      let a = c.gen_expr(p)
      if is_aggregate(e.ty) {
        a
      } else {
        c.load_scalar(e.ty, a)
      }
    }
    @sema.TBitField(base, off, bo, bw) => {
      let addr = c.bitfield_addr(base, off)
      c.bitfield_read(e.ty, addr, bo, bw)
    }
    @sema.TMember(_, _) => {
      let a = c.gen_addr(e)
      if is_aggregate(e.ty) {
        a
      } else {
        c.load_scalar(e.ty, a)
      }
    }
    @sema.TAssign(l, r) =>
      match l.kind {
        @sema.TBitField(base, off, bo, bw) => {
          let addr = c.bitfield_addr(base, off)
          let old = c.load_scalar(l.ty, addr)
          let fmask = (1L << bw) - 1L
          let nmask = -1L ^ (fmask << bo)
          let cleared = c.b.arith(
            c.fid,
            @types.And,
            cls_of(l.ty),
            old,
            c.b.iconst(c.fid, nmask),
          )
          let rv = c.gen_expr(r)
          let rc = c.convert(rv, r.ty, l.ty)
          let masked = c.b.arith(
            c.fid,
            @types.And,
            cls_of(l.ty),
            rc,
            c.b.iconst(c.fid, fmask),
          )
          let placed = c.b.arith(
            c.fid,
            @types.Shl,
            cls_of(l.ty),
            masked,
            c.b.iconst(c.fid, bo.to_int64()),
          )
          let nv = c.b.arith(c.fid, @types.Or, cls_of(l.ty), cleared, placed)
          c.store_scalar(l.ty, nv, addr)
          c.bitfield_read(l.ty, addr, bo, bw)
        }
        _ => {
          let a = c.gen_addr(l)
          if is_complex_ty(l.ty) && !is_composite(r.ty) {
            let elem = elem_of(l.ty)
            let esz = size_of(elem, c.layouts)
            let v = c.convert(c.gen_expr(r), r.ty, elem)
            c.store_scalar(elem, v, a)
            let off = c.b.arith(
              c.fid,
              @types.Add,
              @types.Kl,
              a,
              c.b.iconst(c.fid, esz.to_int64()),
            )
            c.store_scalar(elem, c.zero_elem(elem), off)
            a
          } else if is_composite(l.ty) {
            let src = c.gen_expr(r)
            let sz = size_of(l.ty, c.layouts)
            if sz > 0 {
              c.emit_memcpy(a, src, sz)
            }
            a
          } else {
            let v = c.gen_expr(r)
            let vv = c.convert(v, r.ty, l.ty)
            c.store_scalar(l.ty, vv, a)
            vv
          }
        }
      }
    @sema.TComma(a, b) => {
      let _ = c.gen_expr(a)
      c.gen_expr(b)
    }
    @sema.TBin(op, l, r) => c.gen_bin(op, l, r)
    @sema.TUn(op, x) => c.gen_un(op, x)
    @sema.TCall(name, callee, args) => {
      if name == "__c11_atomic_load" ||
        name == "atomic_load" ||
        name == "__atomic_load_n" ||
        name == "__atomic_load" {
        if args.length() > 0 {
          let ptr = args[0]
          return c.b.atomic_load(
            c.fid,
            cls_of(elem_of(ptr.ty)),
            c.gen_expr(ptr),
          )
        }
        return c.b.iconst(c.fid, 0L)
      }
      if name == "__c11_atomic_store" ||
        name == "atomic_store" ||
        name == "__atomic_store_n" ||
        name == "__atomic_store" {
        if args.length() >= 2 {
          let ptr = args[0]
          let val = args[1]
          let elem = elem_of(ptr.ty)
          let v = c.gen_expr(val)
          let vv = c.convert(v, val.ty, elem)
          let addr = c.gen_expr(ptr)
          c.b.atomic_store(c.fid, cls_of(elem), vv, addr)
        }
        return c.b.iconst(c.fid, 0L)
      }
      if name == "atomic_thread_fence" ||
        name == "atomic_signal_fence" ||
        name == "__c11_atomic_thread_fence" ||
        name == "__atomic_thread_fence" {
        c.b.fence(c.fid)
        return c.b.iconst(c.fid, 0L)
      }
      if name == "__builtin_va_start" {
        if args.length() > 0 {
          let ap = c.gen_addr(args[0])
          c.b.vastart(c.fid, ap)
        }
        return c.b.iconst(c.fid, 0L)
      }
      if name == "__builtin_va_end" {
        return c.b.iconst(c.fid, 0L)
      }
      if name == "__builtin_va_copy" {
        if args.length() >= 2 {
          let d = c.gen_addr(args[0])
          let src = c.gen_addr(args[1])
          c.emit_memcpy(d, src, 8)
        }
        return c.b.iconst(c.fid, 0L)
      }
      let rty = match callee.ty {
        @sema.CFunc(r, _, _) => r
        @sema.CPtr(@sema.CFunc(r, _, _)) => r
        _ => @sema.CInt(false)
      }
      let ptypes : Array[@sema.CType] = match callee.ty {
        @sema.CFunc(_, ps, _) => ps
        @sema.CPtr(@sema.CFunc(_, ps, _)) => ps
        _ => []
      }
      let va = match callee.ty {
        @sema.CFunc(_, _, v) => v
        @sema.CPtr(@sema.CFunc(_, _, v)) => v
        _ => false
      }
      let nfixed = ptypes.length()
      let ret_aggr = is_composite(rty)
      let sret_tmp = if ret_aggr {
        c.alloc_slot(size_of(rty, c.layouts))
      } else {
        -1
      }
      let arglist : Array[(@types.Class, Int)] = []
      if ret_aggr {
        arglist.push((@types.Kl, sret_tmp))
      }
      let mut ai = 0
      for a in args {
        let pty = if va {
          if ai < nfixed {
            ptypes[ai]
          } else {
            promote_vararg(a.ty)
          }
        } else if ai < ptypes.length() {
          ptypes[ai]
        } else {
          a.ty
        }
        if is_composite(pty) {
          let sz = size_of(pty, c.layouts)
          let addr = c.gen_expr(a)
          if sz > 16 {
            arglist.push((@types.Kl, addr))
          } else {
            let nw = param_words(sz)
            for k in 0..<nw {
              let off = k * 8
              let chunk = if off == 0 {
                c.b.load(c.fid, @types.Load, @types.Kl, addr)
              } else {
                let a2 = c.b.arith(
                  c.fid,
                  @types.Add,
                  @types.Kl,
                  addr,
                  c.b.iconst(c.fid, off.to_int64()),
                )
                c.b.load(c.fid, @types.Load, @types.Kl, a2)
              }
              arglist.push((@types.Kl, chunk))
            }
          }
        } else {
          let v = c.gen_expr(a)
          arglist.push((cls_of(pty), c.convert(v, a.ty, pty)))
        }
        ai = ai + 1
      }
      let call_ret = if ret_aggr { @ir_builder.Void } else { ret_of(rty) }
      let direct = match callee.ty {
        @sema.CFunc(_, _, _) => true
        _ => false
      }
      let cv = if direct && name != "" {
        if va {
          let fixed : Array[(@types.Class, Int)] = []
          let rest : Array[(@types.Class, Int)] = []
          let limit = nfixed + (if ret_aggr { 1 } else { 0 })
          let mut i = 0
          for a in arglist {
            if i < limit {
              fixed.push(a)
            } else {
              rest.push(a)
            }
            i = i + 1
          }
          c.b.call_vararg(c.fid, name, fixed, rest, call_ret)
        } else {
          c.b.call(c.fid, name, arglist, call_ret)
        }
      } else {
        let fp = c.gen_expr(callee)
        c.b.call_value(c.fid, fp, arglist, call_ret)
      }
      if ret_aggr {
        sret_tmp
      } else {
        cv
      }
    }
    @sema.TCond(cond, t, f) => {
      let then_b = c.new_block("cond.then")
      let else_b = c.new_block("cond.else")
      let join = c.new_block("cond.join")
      let p = c.b.block_param(c.fid, join, cls_of(e.ty))
      let cv = c.gen_expr(cond)
      c.b.jnz(c.fid, cv, then_b, [], else_b, [])
      c.open = false
      c.switch(then_b)
      let tv = c.gen_expr(t)
      c.b.jmp(c.fid, join, [tv])
      c.open = false
      c.switch(else_b)
      let fv = c.gen_expr(f)
      c.b.jmp(c.fid, join, [fv])
      c.open = false
      c.switch(join)
      p
    }
    @sema.TSizeof(n) => c.b.iconst(c.fid, n.to_int64())
    @sema.TAlignof(n) => c.b.iconst(c.fid, n.to_int64())
    @sema.TSizeofVLA(x) => c.gen_expr(x)
    @sema.TStmtExpr(items) => {
      let n = items.length()
      if n == 0 {
        c.b.iconst(c.fid, 0L)
      } else {
        let mut i = 0
        while i < n - 1 {
          c.gen_stmt(items[i])
          i = i + 1
        }
        let last = items[n - 1]
        match last.kind {
          @sema.KSExpr(Some(x)) => c.gen_expr(x)
          _ => {
            c.gen_stmt(last)
            c.b.iconst(c.fid, 0L)
          }
        }
      }
    }
    @sema.TCompoundLit(_) => {
      let a = c.gen_addr(e)
      if is_aggregate(e.ty) {
        a
      } else {
        c.load_scalar(e.ty, a)
      }
    }
    @sema.TVaArg(x) => {
      let ap = c.gen_addr(x)
      c.b.vaarg(c.fid, cls_of(e.ty), ap)
    }
    @sema.TCast(x) => {
      let v = c.gen_expr(x)
      c.convert(v, x.ty, e.ty)
    }
    @sema.TIndex(a, i) => {
      let base = c.gen_expr(a)
      let idx = c.gen_expr(i)
      let sz = size_of(e.ty, c.layouts)
      let off = c.b.arith(
        c.fid,
        @types.Mul,
        @types.Kl,
        idx,
        c.b.iconst(c.fid, sz.to_int64()),
      )
      let addr = c.b.arith(c.fid, @types.Add, @types.Kl, base, off)
      if is_aggregate(e.ty) {
        addr
      } else {
        c.load_scalar(e.ty, addr)
      }
    }
    @sema.TUnsupported(_) => abort("qpcc: unsupported expression")
  }
}

///|
fn is_complex_ty(ty : @sema.CType) -> Bool {
  match ty {
    @sema.CComplex(_) => true
    _ => false
  }
}

///|
fn Cg::zero_elem(c : Cg, elem : @sema.CType) -> Int {
  if is_flt(elem) {
    c.b.fconst(c.fid, 0.0)
  } else {
    c.b.iconst(c.fid, 0L)
  }
}

///|
fn Cg::complex_operand(
  c : Cg,
  x : @sema.TExpr,
  elem : @sema.CType,
) -> (Int, Int) {
  if is_complex_ty(x.ty) {
    let addr = c.gen_expr(x)
    let esz = size_of(elem, c.layouts)
    let re = c.load_scalar(elem, addr)
    let off = c.b.arith(
      c.fid,
      @types.Add,
      @types.Kl,
      addr,
      c.b.iconst(c.fid, esz.to_int64()),
    )
    let im = c.load_scalar(elem, off)
    (re, im)
  } else {
    (c.convert(c.gen_expr(x), x.ty, elem), c.zero_elem(elem))
  }
}

///|
fn Cg::gen_complex_bin(
  c : Cg,
  op : String,
  l : @sema.TExpr,
  r : @sema.TExpr,
) -> Int {
  let cty = if is_complex_ty(l.ty) { l.ty } else { r.ty }
  let elem = elem_of(cty)
  let cls = cls_of(elem)
  let esz = size_of(elem, c.layouts)
  let (ar, ai) = c.complex_operand(l, elem)
  let (br, bi) = c.complex_operand(r, elem)
  if is_cmp(op) {
    let cc = cmp_op(op, cls, false, is_flt(elem))
    let r1 = c.b.cmp(c.fid, cc, cls, ar, br)
    let r2 = c.b.cmp(c.fid, cc, cls, ai, bi)
    let o = if op == "!=" { @types.Or } else { @types.And }
    return c.b.arith(c.fid, o, @types.Kw, r1, r2)
  }
  let add = @types.Add
  let sub = @types.Sub
  let mul = @types.Mul
  let div = @types.Div
  let real = if op == "+" {
    c.b.arith(c.fid, add, cls, ar, br)
  } else if op == "-" {
    c.b.arith(c.fid, sub, cls, ar, br)
  } else if op == "*" {
    c.b.arith(
      c.fid,
      sub,
      cls,
      c.b.arith(c.fid, mul, cls, ar, br),
      c.b.arith(c.fid, mul, cls, ai, bi),
    )
  } else {
    let d = c.b.arith(
      c.fid,
      add,
      cls,
      c.b.arith(c.fid, mul, cls, br, br),
      c.b.arith(c.fid, mul, cls, bi, bi),
    )
    c.b.arith(
      c.fid,
      div,
      cls,
      c.b.arith(
        c.fid,
        add,
        cls,
        c.b.arith(c.fid, mul, cls, ar, br),
        c.b.arith(c.fid, mul, cls, ai, bi),
      ),
      d,
    )
  }
  let imag = if op == "+" {
    c.b.arith(c.fid, add, cls, ai, bi)
  } else if op == "-" {
    c.b.arith(c.fid, sub, cls, ai, bi)
  } else if op == "*" {
    c.b.arith(
      c.fid,
      add,
      cls,
      c.b.arith(c.fid, mul, cls, ar, bi),
      c.b.arith(c.fid, mul, cls, ai, br),
    )
  } else {
    let d = c.b.arith(
      c.fid,
      add,
      cls,
      c.b.arith(c.fid, mul, cls, br, br),
      c.b.arith(c.fid, mul, cls, bi, bi),
    )
    c.b.arith(
      c.fid,
      div,
      cls,
      c.b.arith(
        c.fid,
        sub,
        cls,
        c.b.arith(c.fid, mul, cls, ai, br),
        c.b.arith(c.fid, mul, cls, ar, bi),
      ),
      d,
    )
  }
  let slot = c.alloc_slot(esz * 2)
  c.store_scalar(elem, real, slot)
  let off = c.b.arith(
    c.fid,
    @types.Add,
    @types.Kl,
    slot,
    c.b.iconst(c.fid, esz.to_int64()),
  )
  c.store_scalar(elem, imag, off)
  slot
}

///|
fn Cg::gen_bin(c : Cg, op : String, l : @sema.TExpr, r : @sema.TExpr) -> Int {
  if is_complex_ty(l.ty) || is_complex_ty(r.ty) {
    return c.gen_complex_bin(op, l, r)
  }
  let lt = @sema.decay(l.ty)
  let rt = @sema.decay(r.ty)
  let cls = wider(lt, rt)
  let fl = is_flt(lt) || is_flt(rt)
  // For a shift only the left operand decides the result: `x >> n` is an
  // arithmetic shift when x is signed and a logical one when it is not,
  // whatever n is.  An unsigned count must not make a signed shift logical.
  let uns = if op == "<<" || op == ">>" {
    is_uns(lt) || is_ptr_ty(lt)
  } else {
    is_uns(lt) || is_uns(rt) || is_ptr_ty(lt) || is_ptr_ty(rt)
  }
  if op == "&&" || op == "||" {
    let a = c.gen_expr(l)
    let av = c.coerce(a, cls_of(lt), cls)
    let b = c.gen_expr(r)
    let bv = c.coerce(b, cls_of(rt), cls)
    let z = c.zero_of(cls)
    let nz = if cls == @types.Ks || cls == @types.Kd {
      @types.Cnes
    } else if cls == @types.Kl {
      @types.Cnel
    } else {
      @types.Cnew
    }
    let ca = c.b.cmp(c.fid, nz, cls, av, z)
    let cb = c.b.cmp(c.fid, nz, cls, bv, z)
    let o = if op == "&&" { @types.And } else { @types.Or }
    c.b.arith(c.fid, o, @types.Kw, ca, cb)
  } else if is_cmp(op) {
    let a = c.gen_expr(l)
    let av = c.coerce(a, cls_of(lt), cls)
    let b = c.gen_expr(r)
    let bv = c.coerce(b, cls_of(rt), cls)
    c.b.cmp(c.fid, cmp_op(op, cls, uns, fl), cls, av, bv)
  } else if (op == "+" || op == "-") && !fl {
    match (lt, rt) {
      (@sema.CPtr(el), _) =>
        if !is_ptr_ty(r.ty) {
          let base = c.gen_expr(l)
          let idx = c.coerce(c.gen_expr(r), cls_of(rt), @types.Kl)
          let sz = size_of(el, c.layouts)
          let off = c.b.arith(
            c.fid,
            @types.Mul,
            @types.Kl,
            idx,
            c.b.iconst(c.fid, sz.to_int64()),
          )
          if op == "-" {
            c.b.arith(c.fid, @types.Sub, @types.Kl, base, off)
          } else {
            c.b.arith(c.fid, @types.Add, @types.Kl, base, off)
          }
        } else if op == "-" {
          let a = c.gen_expr(l)
          let b = c.gen_expr(r)
          let d = c.b.arith(c.fid, @types.Sub, @types.Kl, a, b)
          let sz = size_of(el, c.layouts)
          c.b.arith(
            c.fid,
            @types.Div,
            @types.Kl,
            d,
            c.b.iconst(c.fid, sz.to_int64()),
          )
        } else {
          let a = c.coerce(c.gen_expr(l), cls_of(lt), cls)
          let b = c.coerce(c.gen_expr(r), cls_of(rt), cls)
          c.b.arith(c.fid, arith_op(op, cls, uns), cls, a, b)
        }
      (_, @sema.CPtr(el)) => {
        let base = c.gen_expr(r)
        let idx = c.coerce(c.gen_expr(l), cls_of(lt), @types.Kl)
        let sz = size_of(el, c.layouts)
        let off = c.b.arith(
          c.fid,
          @types.Mul,
          @types.Kl,
          idx,
          c.b.iconst(c.fid, sz.to_int64()),
        )
        c.b.arith(c.fid, @types.Add, @types.Kl, base, off)
      }
      _ => {
        let a = c.coerce(c.gen_expr(l), cls_of(lt), cls)
        let b = c.coerce(c.gen_expr(r), cls_of(rt), cls)
        c.b.arith(c.fid, arith_op(op, cls, uns), cls, a, b)
      }
    }
  } else {
    let a = c.coerce(c.gen_expr(l), cls_of(lt), cls)
    let b = c.coerce(c.gen_expr(r), cls_of(rt), cls)
    c.b.arith(c.fid, arith_op(op, cls, uns), cls, a, b)
  }
}

///|
fn Cg::truncate(c : Cg, ty : @sema.CType, v : Int) -> Int {
  match ty {
    @sema.CBool => c.norm_bool(v)
    @sema.CChar(sgn) =>
      if sgn {
        let t = c.b.arith(
          c.fid,
          @types.Shl,
          @types.Kw,
          v,
          c.b.iconst(c.fid, 24L),
        )
        c.b.arith(c.fid, @types.Sar, @types.Kw, t, c.b.iconst(c.fid, 24L))
      } else {
        c.b.arith(c.fid, @types.And, @types.Kw, v, c.b.iconst(c.fid, 255L))
      }
    @sema.CShort(sgn) =>
      if sgn {
        let t = c.b.arith(
          c.fid,
          @types.Shl,
          @types.Kw,
          v,
          c.b.iconst(c.fid, 16L),
        )
        c.b.arith(c.fid, @types.Sar, @types.Kw, t, c.b.iconst(c.fid, 16L))
      } else {
        c.b.arith(c.fid, @types.And, @types.Kw, v, c.b.iconst(c.fid, 65535L))
      }
    _ => v
  }
}

///|
fn Cg::convert(c : Cg, v : Int, from : @sema.CType, to : @sema.CType) -> Int {
  if is_complex_ty(from) && !is_complex_ty(to) {
    let elem = elem_of(from)
    return c.convert(c.load_scalar(elem, v), elem, to)
  }
  if is_complex_ty(to) && !is_complex_ty(from) {
    let elem = elem_of(to)
    let esz = size_of(elem, c.layouts)
    let slot = c.alloc_slot(esz * 2)
    c.store_scalar(elem, c.convert(v, from, elem), slot)
    let off = c.b.arith(
      c.fid,
      @types.Add,
      @types.Kl,
      slot,
      c.b.iconst(c.fid, esz.to_int64()),
    )
    c.store_scalar(elem, c.zero_elem(elem), off)
    return slot
  }
  c.truncate(to, c.coerce(v, cls_of(from), cls_of(to), uns=is_uns(from)))
}

///|
fn promote_vararg(ty : @sema.CType) -> @sema.CType {
  match ty {
    @sema.CFloat => @sema.CDouble
    @sema.CBool | @sema.CChar(_) | @sema.CShort(_) | @sema.CEnum(_) =>
      @sema.CInt(true)
    _ => ty
  }
}

///|
fn is_ptr_ty(ty : @sema.CType) -> Bool {
  match @sema.decay(ty) {
    @sema.CPtr(_) => true
    _ => false
  }
}

///|
fn arith_op(op : String, cls : @types.Class, uns : Bool) -> @types.Op {
  let fl = cls == @types.Ks || cls == @types.Kd
  match op {
    "+" => @types.Add
    "-" => @types.Sub
    "*" => @types.Mul
    "/" => if fl { @types.Div } else if uns { @types.Udiv } else { @types.Div }
    "%" => if uns { @types.Urem } else { @types.Rem }
    "&" => @types.And
    "|" => @types.Or
    "^" => @types.Xor
    "<<" => @types.Shl
    ">>" => if uns { @types.Shr } else { @types.Sar }
    _ => abort("qpcc: unknown binary operator " + op)
  }
}

///|
fn cmp_op(op : String, cls : @types.Class, uns : Bool, fl : Bool) -> @types.Op {
  if fl {
    match op {
      "==" => if cls == @types.Kd { @types.Ceqd } else { @types.Ceqs }
      "!=" => if cls == @types.Kd { @types.Cned } else { @types.Cnes }
      "<" => if cls == @types.Kd { @types.Cltd } else { @types.Clts }
      "<=" => if cls == @types.Kd { @types.Cled } else { @types.Cles }
      ">" => if cls == @types.Kd { @types.Cgtd } else { @types.Cgts }
      ">=" => if cls == @types.Kd { @types.Cged } else { @types.Cges }
      _ => abort("qpcc: unknown comparison " + op)
    }
  } else {
    let l = cls == @types.Kl
    match op {
      "==" => if l { @types.Ceql } else { @types.Ceqw }
      "!=" => if l { @types.Cnel } else { @types.Cnew }
      "<" =>
        if l {
          if uns {
            @types.Cultl
          } else {
            @types.Csltl
          }
        } else if uns {
          @types.Cultw
        } else {
          @types.Csltw
        }
      "<=" =>
        if l {
          if uns {
            @types.Culel
          } else {
            @types.Cslel
          }
        } else if uns {
          @types.Culew
        } else {
          @types.Cslew
        }
      ">" =>
        if l {
          if uns {
            @types.Cugtl
          } else {
            @types.Csgtl
          }
        } else if uns {
          @types.Cugtw
        } else {
          @types.Csgtw
        }
      ">=" =>
        if l {
          if uns {
            @types.Cugel
          } else {
            @types.Csgel
          }
        } else if uns {
          @types.Cugew
        } else {
          @types.Csgew
        }
      _ => abort("qpcc: unknown comparison " + op)
    }
  }
}

///|

///|
// Unary operators on a _Complex value.
fn Cg::gen_complex_un(c : Cg, op : String, x : @sema.TExpr) -> Int {
  let elem = elem_of(x.ty)
  let cls = cls_of(elem)
  let esz = size_of(elem, c.layouts)
  let (ar, ai) = c.complex_operand(x, elem)
  if op == "+" {
    return c.gen_expr(x)
  }
  let nr = c.b.arith(c.fid, @types.Sub, cls, c.zero_elem(elem), ar)
  let ni = c.b.arith(c.fid, @types.Sub, cls, c.zero_elem(elem), ai)
  let slot = c.alloc_slot(esz * 2)
  c.store_scalar(elem, nr, slot)
  let off = c.b.arith(
    c.fid,
    @types.Add,
    @types.Kl,
    slot,
    c.b.iconst(c.fid, esz.to_int64()),
  )
  c.store_scalar(elem, ni, off)
  slot
}

///|
fn Cg::gen_un(c : Cg, op : String, x : @sema.TExpr) -> Int {
  if op == "__real__" || op == "__imag__" {
    if is_complex_ty(x.ty) {
      let elem = elem_of(x.ty)
      let addr = c.gen_expr(x)
      if op == "__real__" {
        return c.load_scalar(elem, addr)
      }
      let off = c.b.arith(
        c.fid,
        @types.Add,
        @types.Kl,
        addr,
        c.b.iconst(c.fid, size_of(elem, c.layouts).to_int64()),
      )
      return c.load_scalar(elem, off)
    }
    return c.gen_expr(x)
  }
  if is_complex_ty(x.ty) {
    return c.gen_complex_un(op, x)
  }
  match op {
    "-" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      let z = c.zero_of(cls)
      c.b.arith(c.fid, @types.Sub, cls, z, v)
    }
    "~" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      c.b.arith(c.fid, @types.Xor, cls, v, c.b.iconst(c.fid, -1L))
    }
    "!" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      let z = c.zero_of(cls)
      c.b.cmp(c.fid, cmp_op("==", cls, is_uns(x.ty), is_flt(x.ty)), cls, v, z)
    }
    _ => {
      let inc = op == "++" || op == "pre++" || op == "post++"
      let pre = op == "pre++" || op == "pre--"
      let a = c.gen_addr(x)
      let ty = x.ty
      let old = c.load_scalar(ty, a)
      let cls = cls_of(ty)
      let one = match @sema.decay(ty) {
        @sema.CPtr(el) => c.b.iconst(c.fid, size_of(el, c.layouts).to_int64())
        _ => c.one_of(cls)
      }
      let nv = c.b.arith(
        c.fid,
        if inc {
          @types.Add
        } else {
          @types.Sub
        },
        cls,
        old,
        one,
      )
      c.store_scalar(ty, nv, a)
      if pre {
        nv
      } else {
        old
      }
    }
  }
}

///|
fn collect_labels(s : @sema.TStmt, out : Array[String]) -> Unit {
  match s.kind {
    @sema.KSBlock(ss) =>
      for x in ss {
        collect_labels(x, out)
      }
    @sema.KSCaseMark(_, _, b) => collect_labels(b, out)
    @sema.KSLabel(n, b) => {
      out.push(n)
      collect_labels(b, out)
    }
    @sema.KSIf(_, a, b) => {
      collect_labels(a, out)
      match b {
        Some(x) => collect_labels(x, out)
        None => ()
      }
    }
    @sema.KSWhile(_, b) => collect_labels(b, out)
    @sema.KSDoWhile(b, _) => collect_labels(b, out)
    @sema.KSFor(i, _, _, b) => {
      match i {
        Some(x) => collect_labels(x, out)
        None => ()
      }
      collect_labels(b, out)
    }
    @sema.KSSwitch(_, cases, d, _) => {
      for c in cases {
        collect_labels(c.1, out)
      }
      match d {
        Some(x) => collect_labels(x, out)
        None => ()
      }
    }
    _ => ()
  }
}

///|
fn Cg::gen_switch(
  c : Cg,
  e : @sema.TExpr,
  cases : Array[(Int64, @sema.TStmt)],
  dflt : @sema.TStmt?,
  dfpos : Int,
) -> Unit {
  let end = c.new_block("switch.end")
  let v = c.gen_expr(e)
  let cls = cls_of(e.ty)
  let n = cases.length()
  let blocks : Array[Int] = []
  for _i in 0..<n {
    blocks.push(c.new_block("switch.case"))
  }
  let dblk = match dflt {
    Some(_) => c.new_block("switch.default")
    None => end
  }
  let tests : Array[Int] = []
  for _i in 0..<n {
    tests.push(c.new_block("switch.test"))
  }
  if n == 0 {
    c.b.jmp(c.fid, dblk, [])
  } else {
    c.b.jmp(c.fid, tests[0], [])
  }
  c.open = false
  for i in 0..<n {
    c.switch(tests[i])
    let cv = c.b.iconst(c.fid, cases[i].0)
    let cc = c.b.cmp(
      c.fid,
      if cls == @types.Kl {
        @types.Ceql
      } else {
        @types.Ceqw
      },
      cls,
      v,
      cv,
    )
    let next = if i + 1 < n { tests[i + 1] } else { dblk }
    c.b.jnz(c.fid, cc, blocks[i], [], next, [])
    c.open = false
  }
  c.break_blks.push(end)
  for i in 0..<n {
    c.switch(blocks[i])
    c.gen_stmt(cases[i].1)
    if c.open {
      // A case falls into the next label in source order, and the default
      // is one of those labels: `case 'h': default: ...` shares one body,
      // so the fall-through has to be able to reach it.
      let next = if dfpos == i + 1 {
        dblk
      } else if i + 1 < n {
        blocks[i + 1]
      } else {
        end
      }
      c.b.jmp(c.fid, next, [])
      c.open = false
    }
  }
  match dflt {
    Some(b) => {
      c.switch(dblk)
      c.gen_stmt(b)
      if c.open {
        let next = if dfpos < n { blocks[dfpos] } else { end }
        c.b.jmp(c.fid, next, [])
        c.open = false
      }
    }
    None => ()
  }
  let _ = c.break_blks.pop()
  c.switch(end)
}

///|

///|
// Branch to t when e is true, to f otherwise. && and || are expanded into
// control flow so their right-hand sides are only evaluated when needed.
fn Cg::gen_cond_branch(c : Cg, e : @sema.TExpr, t : Int, f : Int) -> Unit {
  match e.kind {
    @sema.TBin(op, l, r) if op == "&&" || op == "||" => {
      let mid = c.new_block(if op == "&&" { "and.rhs" } else { "or.rhs" })
      if op == "&&" {
        c.gen_cond_branch(l, mid, f)
      } else {
        c.gen_cond_branch(l, t, mid)
      }
      c.open = false
      c.switch(mid)
      c.gen_cond_branch(r, t, f)
    }
    _ => {
      let v = c.gen_expr(e)
      c.b.jnz(c.fid, v, t, [], f, [])
      c.open = false
    }
  }
}

///|
fn Cg::gen_stmt(c : Cg, s : @sema.TStmt) -> Unit {
  match s.kind {
    @sema.KSBlock(ss) =>
      for x in ss {
        if !c.open {
          let dead = c.new_block("dead")
          c.switch(dead)
        }
        c.gen_stmt(x)
      }
    @sema.KSDecl(name, ty, init, _) =>
      match init {
        Some(e) => {
          let a = match c.locals.get(name) {
            Some(x) => x
            None => abort("qpcc: unbound local " + name)
          }
          if is_complex_ty(ty) && !is_composite(e.ty) {
            let elem = elem_of(ty)
            let esz = size_of(elem, c.layouts)
            let v = c.convert(c.gen_expr(e), e.ty, elem)
            c.store_scalar(elem, v, a)
            let off = c.b.arith(
              c.fid,
              @types.Add,
              @types.Kl,
              a,
              c.b.iconst(c.fid, esz.to_int64()),
            )
            c.store_scalar(elem, c.zero_elem(elem), off)
          } else if is_composite(ty) {
            let src = c.gen_expr(e)
            let sz = size_of(ty, c.layouts)
            if sz > 0 {
              c.emit_memcpy(a, src, sz)
            }
          } else {
            let v = c.gen_expr(e)
            let vv = c.convert(v, e.ty, ty)
            c.store_scalar(ty, vv, a)
          }
        }
        None => ()
      }
    @sema.KSAggInit(name, ty, items, _) => {
      let base = match c.locals.get(name) {
        Some(x) => x
        None => abort("qpcc: unbound local " + name)
      }
      c.zero_mem(base, size_of(ty, c.layouts))
      for entry in items {
        let (off, e, bo, bw) = entry
        let addr = if off == 0 {
          base
        } else {
          c.b.arith(
            c.fid,
            @types.Add,
            @types.Kl,
            base,
            c.b.iconst(c.fid, off.to_int64()),
          )
        }
        let v = c.gen_expr(e)
        if is_composite(e.ty) {
          c.emit_memcpy(addr, v, size_of(e.ty, c.layouts))
        } else {
          let vv = c.coerce(v, cls_of(e.ty), cls_of(e.ty))
          if bw > 0 {
            c.store_bitfield(e.ty, vv, addr, bo, bw)
          } else {
            c.store_scalar(e.ty, vv, addr)
          }
        }
      }
      let _ = ty
    }
    @sema.KSExpr(Some(e)) => {
      let _ = c.gen_expr(e)
    }
    @sema.KSExpr(None) => ()
    @sema.KSReturn(e) => {
      match e {
        Some(x) =>
          if c.ret_sret {
            let src = c.gen_expr(x)
            let sz = size_of(c.ret_ty, c.layouts)
            if sz > 0 {
              c.emit_memcpy(c.sret_ptr, src, sz)
            }
            c.b.ret(c.fid, -1)
          } else {
            let val = c.gen_expr(x)
            let v = c.convert(val, x.ty, c.ret_ty)
            c.b.ret(c.fid, v)
          }
        None => c.b.ret(c.fid, -1)
      }
      c.open = false
    }
    @sema.KSIf(cond, then_s, els) => {
      let t = c.new_block("if.then")
      let e = c.new_block("if.else")
      let end = c.new_block("if.end")
      c.gen_cond_branch(cond, t, e)
      c.switch(t)
      c.gen_stmt(then_s)
      if c.open {
        c.b.jmp(c.fid, end, [])
        c.open = false
      }
      c.switch(e)
      match els {
        Some(x) => c.gen_stmt(x)
        None => ()
      }
      if c.open {
        c.b.jmp(c.fid, end, [])
        c.open = false
      }
      c.switch(end)
    }
    @sema.KSWhile(cond, body) => {
      let cb = c.new_block("while.cond")
      let bb = c.new_block("while.body")
      let end = c.new_block("while.end")
      c.b.jmp(c.fid, cb, [])
      c.open = false
      c.switch(cb)
      c.gen_cond_branch(cond, bb, end)
      c.break_blks.push(end)
      c.cont_blks.push(cb)
      c.switch(bb)
      c.gen_stmt(body)
      if c.open {
        c.b.jmp(c.fid, cb, [])
        c.open = false
      }
      let _ = c.break_blks.pop()
      let _ = c.cont_blks.pop()
      c.switch(end)
    }
    @sema.KSDoWhile(body, cond) => {
      let bb = c.new_block("do.body")
      let cb = c.new_block("do.cond")
      let end = c.new_block("do.end")
      c.b.jmp(c.fid, bb, [])
      c.open = false
      c.break_blks.push(end)
      c.cont_blks.push(cb)
      c.switch(bb)
      c.gen_stmt(body)
      if c.open {
        c.b.jmp(c.fid, cb, [])
        c.open = false
      }
      let _ = c.break_blks.pop()
      let _ = c.cont_blks.pop()
      c.switch(cb)
      c.gen_cond_branch(cond, bb, end)
      c.switch(end)
    }
    @sema.KSFor(init, cond, step, body) => {
      match init {
        Some(s0) => c.gen_stmt(s0)
        None => ()
      }
      let cb = c.new_block("for.cond")
      let bb = c.new_block("for.body")
      let sb = c.new_block("for.step")
      let end = c.new_block("for.end")
      c.b.jmp(c.fid, cb, [])
      c.open = false
      c.switch(cb)
      match cond {
        Some(ce) => {
          let cv = c.gen_expr(ce)
          c.b.jnz(c.fid, cv, bb, [], end, [])
        }
        None => c.b.jmp(c.fid, bb, [])
      }
      c.open = false
      c.break_blks.push(end)
      c.cont_blks.push(sb)
      c.switch(bb)
      c.gen_stmt(body)
      if c.open {
        c.b.jmp(c.fid, sb, [])
        c.open = false
      }
      let _ = c.break_blks.pop()
      let _ = c.cont_blks.pop()
      c.switch(sb)
      match step {
        Some(se) => {
          let _ = c.gen_expr(se)
        }
        None => ()
      }
      c.b.jmp(c.fid, cb, [])
      c.open = false
      c.switch(end)
    }
    @sema.KSBreak => {
      let b = c.break_blks[c.break_blks.length() - 1]
      c.b.jmp(c.fid, b, [])
      c.open = false
    }
    @sema.KSContinue => {
      let b = c.cont_blks[c.cont_blks.length() - 1]
      c.b.jmp(c.fid, b, [])
      c.open = false
    }
    @sema.KSGoto(n) => {
      let blk = match c.labels.get(n) {
        Some(b) => b
        None => abort("qpcc: unknown label " + n)
      }
      c.b.jmp(c.fid, blk, [])
      c.open = false
    }
    @sema.KSGotoPtr(e) => {
      let v = c.gen_expr(e)
      let end = c.new_block("goto.end")
      let labels = c.cur_labels
      let n = labels.length()
      let mut i = 0
      while i < n {
        let name = labels[i]
        let blk = match c.labels.get(name) {
          Some(b) => b
          None => end
        }
        let id = match c.label_ids.get(name) {
          Some(x) => x
          None => 0
        }
        let cc = c.b.cmp(
          c.fid,
          @types.Ceql,
          @types.Kl,
          v,
          c.b.iconst(c.fid, id.to_int64()),
        )
        let next = if i + 1 < n { c.new_block("goto.next") } else { end }
        c.b.jnz(c.fid, cc, blk, [], next, [])
        c.open = false
        c.switch(next)
        i = i + 1
      }
      c.switch(end)
    }
    @sema.KSCaseMark(_, _, b) => c.gen_stmt(b)
    @sema.KSLabel(n, b) => {
      let blk = match c.labels.get(n) {
        Some(x) => x
        None => abort("qpcc: unknown label " + n)
      }
      if c.b.current_block(c.fid) != blk {
        if c.open {
          c.b.jmp(c.fid, blk, [])
          c.open = false
        }
        c.switch(blk)
      }
      c.gen_stmt(b)
    }
    @sema.KSSwitch(e, cases, dflt, dfpos) => c.gen_switch(e, cases, dflt, dfpos)
    @sema.KSEmpty => ()
  }
}

///|
fn le_bytes(v : Int64) -> Bytes {
  let out : Array[Byte] = []
  for i in 0..<8 {
    out.push(((v >> (i * 8)) & 0xFFL).to_int().to_byte())
  }
  Bytes::from_array(out[:])
}

///|
fn Cg::gen_func(c : Cg, f : @sema.CheckedFunc) -> Unit {
  let (ret, ptypes, _va) = match f.ty {
    @sema.CFunc(r, ps, v) => (r, ps, v)
    _ => (@sema.CVoid, [], false)
  }
  let ret_sret = is_composite(ret)
  c.ret_sret = ret_sret
  let pclasses : Array[@types.Class] = []
  if ret_sret {
    pclasses.push(@types.Kl)
  }
  for p in ptypes {
    if is_composite(p) {
      let sz = size_of(p, c.layouts)
      if sz > 16 {
        pclasses.push(@types.Kl)
      } else {
        let nw = param_words(sz)
        for _k in 0..<nw {
          pclasses.push(@types.Kl)
        }
      }
    } else {
      pclasses.push(cls_of(p))
    }
  }
  let fid = c.b.add_func(
    f.name,
    if ret_sret {
      @ir_builder.Void
    } else {
      ret_of(ret)
    },
    pclasses,
    f.is_export,
  )
  c.fid = fid
  c.ret_ty = ret
  c.open = true
  c.locals = Map::new()
  c.local_ty = Map::new()
  c.labels = Map::new()
  c.break_blks.clear()
  c.cont_blks.clear()
  let pvals : Array[Int] = []
  for j in 0..<pclasses.length() {
    pvals.push(c.b.param(fid, j))
  }
  let mut pi = 0
  c.sret_ptr = if ret_sret {
    let sp = pvals[0]
    pi = 1
    sp
  } else {
    -1
  }
  for i in 0..<f.params.length() {
    let (n, ty) = f.params[i]
    let raw = size_of(ty, c.layouts)
    let slot = c.alloc_slot(raw)
    if is_composite(ty) {
      if raw > 16 {
        let pv = pvals[pi]
        pi = pi + 1
        if raw > 0 {
          c.emit_memcpy(slot, pv, raw)
        }
      } else {
        let nw = param_words(raw)
        for k in 0..<nw {
          let pv = pvals[pi]
          pi = pi + 1
          let addr = if k == 0 {
            slot
          } else {
            c.b.arith(
              c.fid,
              @types.Add,
              @types.Kl,
              slot,
              c.b.iconst(c.fid, (k * 8).to_int64()),
            )
          }
          c.b.store(c.fid, @types.Storel, @types.Kl, pv, addr)
        }
      }
    } else {
      let pv = pvals[pi]
      pi = pi + 1
      c.store_scalar(ty, pv, slot)
    }
    if n != "" {
      c.locals.set(n, slot)
      c.local_ty.set(n, ty)
    }
  }
  for entry in f.locals {
    let (n, t, al) = entry
    let raw = size_of(t, c.layouts)
    let slot = c.alloc_slot_al(raw, al)
    c.locals.set(n, slot)
    c.local_ty.set(n, t)
  }
  let label_names : Array[String] = []
  collect_labels(f.body, label_names)
  c.cur_labels = []
  for n in label_names {
    if !c.labels.contains(n) {
      let blk = c.b.add_block(fid, "label_" + n)
      c.labels.set(n, blk)
    }
    if !c.label_ids.contains(n) {
      c.label_ids.set(n, c.label_seq)
      c.label_seq = c.label_seq + 1
    }
    c.cur_labels.push(n)
  }
  c.gen_stmt(f.body)
  if c.open {
    if c.ret_sret {
      c.b.ret(fid, -1)
    } else {
      let v = match ret_of(c.ret_ty) {
        @ir_builder.Void => -1
        _ => c.zero_of(cls_of(c.ret_ty))
      }
      c.b.ret(fid, v)
    }
    c.open = false
  }
}

///|
/// Lower a checked program to the QBE builder.
pub fn compile_program(p : @sema.CheckedProgram) -> @ir_builder.Builder raise {
  let b = @ir_builder.Builder::new()
  let strs : Array[String] = []
  for i in 0..<p.strings.length() {
    let label = "qpcc_str_" + i.to_string()
    b.data_string(label, false, p.strings[i] + "\\0")
    strs.push(label)
  }
  for g in p.globals {
    let sz = size_of(g.ty, p.layouts)
    if g.relocs.length() > 0 {
      if g.align > 8 {
        b.data_begin_aligned(g.name, g.is_export, g.align.to_int64())
      } else {
        b.data_begin(g.name, g.is_export)
      }
      // Relocations may be produced out of order (e.g. decreasing array
      // designators); the emission loop below walks offsets forwards.
      let rels : Array[(Int, @sema.GlobalReloc)] = []
      for entry in g.relocs {
        rels.push(entry)
      }
      for i in 1..<rels.length() {
        let k = rels[i]
        let mut j = i
        while j > 0 && rels[j - 1].0 > k.0 {
          rels[j] = rels[j - 1]
          j = j - 1
        }
        rels[j] = k
      }
      let mut pos = 0
      for entry in rels {
        let (off, r) = entry
        while pos < off {
          b.data_byte(
            if pos < g.bytes.length() {
              g.bytes[pos].to_int().to_int64()
            } else {
              0L
            },
          )
          pos = pos + 1
        }
        match r {
          @sema.RGlobal(t, k) => b.data_ref_item(t, k.to_int64())
          @sema.RString(idx, k) =>
            b.data_ref_item("qpcc_str_" + idx.to_string(), k.to_int64())
        }
        pos = pos + 8
      }
      let total = if g.bytes.length() > 0 { g.bytes.length() } else { sz }
      while pos < total {
        b.data_byte(
          if pos < g.bytes.length() {
            g.bytes[pos].to_int().to_int64()
          } else {
            0L
          },
        )
        pos = pos + 1
      }
      b.data_end()
    } else if g.bytes.length() > 0 {
      if g.align > 8 {
        b.data_begin_aligned(g.name, g.is_export, g.align.to_int64())
        for by in g.bytes {
          b.data_byte(by.to_int().to_int64())
        }
        b.data_end()
      } else {
        b.data_bytes(g.name, g.is_export, Bytes::from_array(g.bytes[:]))
      }
    } else {
      let v = match g.init {
        Some(x) => x
        None => 0L
      }
      let raw : Array[Byte] = []
      if is_composite(g.ty) {
        let mut i = 0
        while i < sz {
          raw.push((0).to_byte())
          i = i + 1
        }
      } else {
        let mut i = 0
        while i < 8 {
          raw.push(((v >> (i * 8)) & 0xFFL).to_int().to_byte())
          i = i + 1
        }
      }
      if g.align > 8 {
        b.data_begin_aligned(g.name, g.is_export, g.align.to_int64())
        for by in raw {
          b.data_byte(by.to_int().to_int64())
        }
        b.data_end()
      } else {
        b.data_bytes(g.name, g.is_export, Bytes::from_array(raw[:]))
      }
    }
  }
  let c = Cg::{
    b,
    layouts: p.layouts,
    strings: strs,
    locals: Map::new(),
    local_ty: Map::new(),
    labels: Map::new(),
    fid: 0,
    break_blks: [],
    cont_blks: [],
    ret_ty: @sema.CVoid,
    open: false,
    ret_sret: false,
    sret_ptr: -1,
    scratch: -1,
    bump: 0,
    block_seq: 0,
    label_ids: Map::new(),
    label_seq: 0,
    cur_labels: [],
  }
  for f in p.funcs {
    c.gen_func(f)
  }
  b
}
