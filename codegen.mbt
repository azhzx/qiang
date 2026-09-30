///|
/// Code generator: lowers the QPCC AST onto the qbe.mbt ir_builder.
priv struct Cg {
  b : @ir_builder.Builder
  structs : Array[StructDef]
  locals : Map[String, Int]
  local_ty : Map[String, Ty]
  globals : Map[String, Ty]
  funcs : Map[String, (Ty, Array[Ty])]
  str_labels : Array[String]
  mut fid : Int
  break_blks : Array[Int]
  cont_blks : Array[Int]
  mut ret_ty : Ty
  mut open : Bool
}

///|
fn cls_of(ty : Ty) -> @types.Class {
  match decay(ty) {
    TLong | TPtr(_) => @types.Kl
    _ => @types.Kw
  }
}

///|
fn ret_of(ty : Ty) -> @ir_builder.Ret {
  match ty {
    TVoid => @ir_builder.Void
    TLong | TPtr(_) => @ir_builder.Long
    _ => @ir_builder.Word
  }
}

///|
fn is_aggregate(ty : Ty) -> Bool {
  match ty {
    TArr(_, _) | TStruct(_) => true
    _ => false
  }
}

///|
fn Cg::emit(c : Cg, f : () -> Unit) -> Unit {
  if !c.open {
    return
  }
  f()
}

///|
fn Cg::switch(c : Cg, blk : Int) -> Unit {
  c.b.switch_to(c.fid, blk)
  c.open = true
}

///|
fn Cg::new_block(c : Cg, name : String) -> Int {
  c.b.add_block(c.fid, name)
}

///|
fn Cg::load_scalar(c : Cg, ty : Ty, addr : Int) -> Int {
  match ty {
    TChar => c.b.load(c.fid, @types.Loadsb, @types.Kw, addr)
    TInt => c.b.load(c.fid, @types.Loadsw, @types.Kw, addr)
    TLong | TPtr(_) => c.b.load(c.fid, @types.Load, @types.Kl, addr)
    _ => addr
  }
}

///|
fn Cg::store_scalar(c : Cg, ty : Ty, val : Int, addr : Int) -> Unit {
  match ty {
    TChar => c.b.store(c.fid, @types.Storeb, @types.Kw, val, addr)
    TInt => c.b.store(c.fid, @types.Storew, @types.Kw, val, addr)
    TLong | TPtr(_) => c.b.store(c.fid, @types.Storel, @types.Kl, val, addr)
    _ => abort("qpcc: cannot store an aggregate")
  }
}

///|
fn promote(c : Cg, v : Int, from : @types.Class, to : @types.Class) -> Int {
  if from == to {
    v
  } else if from == @types.Kw && to == @types.Kl {
    c.b.unop(c.fid, @types.Extsw, @types.Kw, @types.Kl, v)
  } else {
    v
  }
}

///|
fn wider(l : Ty, r : Ty) -> @types.Class {
  if cls_of(l) == @types.Kl || cls_of(r) == @types.Kl {
    @types.Kl
  } else {
    @types.Kw
  }
}

///|
fn Cg::gen_addr(c : Cg, e : Expr) -> Int {
  match e.kind {
    EVar(n) =>
      match c.locals.get(n) {
        Some(a) => a
        None => c.b.global(c.fid, n)
      }
    EDeref(p) => c.gen_expr(p)
    EMember(b, off) => {
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
    _ => abort("qpcc: not an lvalue")
  }
}

///|
fn Cg::gen_expr(c : Cg, e : Expr) -> Int {
  match e.kind {
    ENum(n) => c.b.iconst(c.fid, n)
    EStr(id) => c.b.global(c.fid, c.str_labels[id])
    EVar(n) =>
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
        None => {
          let a = c.b.global(c.fid, n)
          if is_aggregate(e.ty) {
            a
          } else {
            c.load_scalar(e.ty, a)
          }
        }
      }
    EAddr(x) => c.gen_addr(x)
    EDeref(p) => {
      let a = c.gen_expr(p)
      if is_aggregate(e.ty) {
        a
      } else {
        c.load_scalar(e.ty, a)
      }
    }
    EMember(b, off) => {
      let base = c.gen_addr(b)
      let a = if off == 0 {
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
      if is_aggregate(e.ty) {
        a
      } else {
        c.load_scalar(e.ty, a)
      }
    }
    EAssign(l, r) => {
      let a = c.gen_addr(l)
      let v = c.gen_expr(r)
      c.store_scalar(l.ty, v, a)
      v
    }
    EComma(a, b) => {
      let _ = c.gen_expr(a)
      c.gen_expr(b)
    }
    EBin(op, l, r) => c.gen_bin(op, l, r)
    EUn(op, x) => c.gen_un(op, x)
    ECall(name, args) => {
      let arglist : Array[(@types.Class, Int)] = []
      for a in args {
        arglist.push((cls_of(a.ty), c.gen_expr(a)))
      }
      let rty = match c.funcs.get(name) {
        Some((rt, _)) => rt
        None => TInt
      }
      c.b.call(c.fid, name, arglist, ret_of(rty))
    }
    ECond(cond, t, f) => {
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
    ESizeofT(t) => c.b.iconst(c.fid, size_of(t, c.structs).to_int64())
    ESizeofE(x) => c.b.iconst(c.fid, size_of(decay(x.ty), c.structs).to_int64())
    ECast(x) => {
      let v = c.gen_expr(x)
      let want = cls_of(e.ty)
      let have = cls_of(x.ty)
      if want == @types.Kl && have == @types.Kw {
        c.b.unop(c.fid, @types.Extsw, @types.Kw, @types.Kl, v)
      } else {
        v
      }
    }
  }
}

///|
fn Cg::gen_bin(c : Cg, op : String, l : Expr, r : Expr) -> Int {
  let lt = decay(l.ty)
  let rt = decay(r.ty)
  if op == "&&" || op == "||" {
    let cls = wider(lt, rt)
    let a = promote(c, c.gen_expr(l), cls_of(lt), cls)
    let b = promote(c, c.gen_expr(r), cls_of(rt), cls)
    let z = c.b.iconst(c.fid, 0L)
    let nz = if cls == @types.Kl { @types.Cnel } else { @types.Cnew }
    let ca = c.b.cmp(c.fid, nz, cls, a, z)
    let cb = c.b.cmp(c.fid, nz, cls, b, z)
    let o = if op == "&&" { @types.And } else { @types.Or }
    c.b.arith(c.fid, o, @types.Kw, ca, cb)
  } else if prec_of(op) <= 7 &&
    op != "+" &&
    op != "-" &&
    op != "<<" &&
    op != ">>" {
    let cls = wider(lt, rt)
    let a = promote(c, c.gen_expr(l), cls_of(lt), cls)
    let b = promote(c, c.gen_expr(r), cls_of(rt), cls)
    c.b.cmp(c.fid, cmp_op(op, cls), cls, a, b)
  } else if op == "+" || op == "-" {
    match (lt, rt) {
      (TPtr(el), _) if !is_ptr(r.ty) => {
        let base = c.gen_expr(l)
        let idx = promote(c, c.gen_expr(r), cls_of(rt), @types.Kl)
        let sz = size_of(el, c.structs)
        let off = c.b.arith(
          c.fid,
          @types.Mul,
          @types.Kl,
          idx,
          c.b.iconst(c.fid, sz.to_int64()),
        )
        c.b.arith(c.fid, @types.Add, @types.Kl, base, off)
      }
      (TPtr(el), TPtr(_)) if op == "-" => {
        let a = c.gen_expr(l)
        let b = c.gen_expr(r)
        let d = c.b.arith(c.fid, @types.Sub, @types.Kl, a, b)
        let sz = size_of(el, c.structs)
        c.b.arith(
          c.fid,
          @types.Div,
          @types.Kl,
          d,
          c.b.iconst(c.fid, sz.to_int64()),
        )
      }
      (_, TPtr(el)) => {
        let base = c.gen_expr(r)
        let idx = promote(c, c.gen_expr(l), cls_of(lt), @types.Kl)
        let sz = size_of(el, c.structs)
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
        let cls = wider(lt, rt)
        let a = promote(c, c.gen_expr(l), cls_of(lt), cls)
        let b = promote(c, c.gen_expr(r), cls_of(rt), cls)
        c.b.arith(c.fid, arith_op(op), cls, a, b)
      }
    }
  } else {
    let cls = wider(lt, rt)
    let a = promote(c, c.gen_expr(l), cls_of(lt), cls)
    let b = promote(c, c.gen_expr(r), cls_of(rt), cls)
    c.b.arith(c.fid, arith_op(op), cls, a, b)
  }
}

///|
fn is_ptr(ty : Ty) -> Bool {
  match decay(ty) {
    TPtr(_) => true
    _ => false
  }
}

///|
fn arith_op(op : String) -> @types.Op {
  match op {
    "+" => @types.Add
    "-" => @types.Sub
    "*" => @types.Mul
    "/" => @types.Div
    "%" => @types.Rem
    "&" => @types.And
    "|" => @types.Or
    "^" => @types.Xor
    "<<" => @types.Shl
    ">>" => @types.Sar
    _ => abort("qpcc: unknown binary operator " + op)
  }
}

///|
fn cmp_op(op : String, cls : @types.Class) -> @types.Op {
  let l = cls == @types.Kl
  match op {
    "==" => if l { @types.Ceql } else { @types.Ceqw }
    "!=" => if l { @types.Cnel } else { @types.Cnew }
    "<" => if l { @types.Csltl } else { @types.Csltw }
    "<=" => if l { @types.Cslel } else { @types.Cslew }
    ">" => if l { @types.Csgtl } else { @types.Csgtw }
    ">=" => if l { @types.Csgel } else { @types.Csgew }
    _ => abort("qpcc: unknown comparison " + op)
  }
}

///|
fn Cg::gen_un(c : Cg, op : String, x : Expr) -> Int {
  match op {
    "-" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      c.b.arith(c.fid, @types.Sub, cls, c.b.iconst(c.fid, 0L), v)
    }
    "~" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      c.b.arith(c.fid, @types.Xor, cls, v, c.b.iconst(c.fid, -1L))
    }
    "!" => {
      let cls = cls_of(x.ty)
      let v = c.gen_expr(x)
      let z = c.b.iconst(c.fid, 0L)
      c.b.cmp(
        c.fid,
        if cls == @types.Kl {
          @types.Ceql
        } else {
          @types.Ceqw
        },
        cls,
        v,
        z,
      )
    }
    _ => {
      // pre++/pre--/post++/post--
      let pre = op == "pre++" || op == "pre--"
      let inc = op == "pre++" || op == "post++"
      let a = c.gen_addr(x)
      let ty = x.ty
      let old = c.load_scalar(ty, a)
      let one = match decay(ty) {
        TPtr(el) => c.b.iconst(c.fid, size_of(el, c.structs).to_int64())
        _ => c.b.iconst(c.fid, 1L)
      }
      let nv = c.b.arith(
        c.fid,
        if inc {
          @types.Add
        } else {
          @types.Sub
        },
        cls_of(ty),
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
fn collect_locals(s : Stmt, out : Array[(String, Ty)]) -> Unit {
  match s.kind {
    SBlock(ss) =>
      for x in ss {
        collect_locals(x, out)
      }
    SLocal(n, t, _) => out.push((n, t))
    SIf(_, a, b) => {
      collect_locals(a, out)
      match b {
        Some(x) => collect_locals(x, out)
        None => ()
      }
    }
    SWhile(_, b) => collect_locals(b, out)
    SFor(i, _, _, b) => {
      match i {
        Some(x) => collect_locals(x, out)
        None => ()
      }
      collect_locals(b, out)
    }
    SDoWhile(b, _) => collect_locals(b, out)
    _ => ()
  }
}

///|
fn Cg::gen_stmt(c : Cg, s : Stmt) -> Unit {
  match s.kind {
    SBlock(ss) =>
      for x in ss {
        if !c.open {
          // unreachable statement: start a fresh dead block
          let dead = c.new_block("dead")
          c.switch(dead)
        }
        c.gen_stmt(x)
      }
    SLocal(name, ty, init) =>
      match init {
        Some(e) => {
          let a = match c.locals.get(name) {
            Some(x) => x
            None => abort("qpcc: unbound local")
          }
          let v = c.gen_expr(e)
          c.store_scalar(ty, v, a)
        }
        None => ()
      }
    SExpr(e) => {
      let _ = c.gen_expr(e)
    }
    SReturn(e) => {
      let v = match e {
        Some(x) => {
          let val = c.gen_expr(x)
          let want = ret_of(c.ret_ty)
          let have = cls_of(x.ty)
          let wc = if want == @ir_builder.Long { @types.Kl } else { @types.Kw }
          promote(c, val, have, wc)
        }
        None => -1
      }
      c.b.ret(c.fid, v)
      c.open = false
    }
    SIf(cond, then_s, els) => {
      let t = c.new_block("if.then")
      let e = c.new_block("if.else")
      let end = c.new_block("if.end")
      let cv = c.gen_expr(cond)
      c.b.jnz(c.fid, cv, t, [], e, [])
      c.open = false
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
    SWhile(cond, body) => {
      let cb = c.new_block("while.cond")
      let bb = c.new_block("while.body")
      let end = c.new_block("while.end")
      c.b.jmp(c.fid, cb, [])
      c.open = false
      c.switch(cb)
      let cv = c.gen_expr(cond)
      c.b.jnz(c.fid, cv, bb, [], end, [])
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
      c.switch(end)
    }
    SDoWhile(body, cond) => {
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
      let cv = c.gen_expr(cond)
      c.b.jnz(c.fid, cv, bb, [], end, [])
      c.open = false
      c.switch(end)
    }
    SFor(init, cond, step, body) => {
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
    SBreak => {
      let b = c.break_blks[c.break_blks.length() - 1]
      c.b.jmp(c.fid, b, [])
      c.open = false
    }
    SContinue => {
      let b = c.cont_blks[c.cont_blks.length() - 1]
      c.b.jmp(c.fid, b, [])
      c.open = false
    }
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
fn Cg::gen_func(c : Cg, f : FuncDef) -> Unit {
  let pclasses : Array[@types.Class] = []
  for p in f.params {
    pclasses.push(cls_of(p.ty))
  }
  let fid = c.b.add_func(f.name, ret_of(f.ret), pclasses, true)
  c.fid = fid
  c.ret_ty = f.ret
  c.open = true
  // parameters
  for i in 0..<f.params.length() {
    let p = f.params[i]
    if p.name != "" {
      let sz = if size_of(p.ty, c.structs) < 8 {
        8
      } else {
        size_of(p.ty, c.structs)
      }
      let sv = c.b.iconst(fid, sz.to_int64())
      let slot = c.b.emit_ins(fid, @types.Alloc8, @types.Kl, @types.Kl, sv, -1)
      let pv = c.b.param(fid, i)
      c.store_scalar(p.ty, pv, slot)
      c.locals.set(p.name, slot)
      c.local_ty.set(p.name, p.ty)
    }
  }
  // locals
  let locs : Array[(String, Ty)] = []
  collect_locals(f.body, locs)
  for (n, t) in locs {
    let raw = size_of(t, c.structs)
    let sz = if raw < 8 { 8 } else { raw }
    let sv = c.b.iconst(fid, sz.to_int64())
    let slot = c.b.emit_ins(fid, @types.Alloc8, @types.Kl, @types.Kl, sv, -1)
    c.locals.set(n, slot)
    c.local_ty.set(n, t)
  }
  c.gen_stmt(f.body)
  if c.open {
    let v = if ret_of(c.ret_ty) == @ir_builder.Void {
      -1
    } else {
      c.b.iconst(fid, 0L)
    }
    c.b.ret(fid, v)
    c.open = false
  }
}

///|
pub fn compile_program(p : Program) -> @ir_builder.Builder raise {
  let b = @ir_builder.Builder::new()
  let strs : Array[String] = []
  for i in 0..<p.strings.length() {
    let label = "qpcc_str_" + i.to_string()
    b.data_string(label, false, p.strings[i])
    strs.push(label)
  }
  for g in p.globals {
    let raw = size_of(g.ty, p.structs)
    let n = if raw < 8 { 8 } else { raw }
    let v = match g.init {
      Some(x) => x
      None => 0L
    }
    b.data_bytes(g.name, false, le_bytes(v))
    let _ = n
  }
  let c = Cg::{
    b,
    structs: p.structs,
    locals: Map::new(),
    local_ty: Map::new(),
    globals: Map::new(),
    funcs: Map::new(),
    str_labels: strs,
    fid: 0,
    break_blks: [],
    cont_blks: [],
    ret_ty: TVoid,
    open: false,
  }
  for f in p.funcs {
    c.gen_func(f)
  }
  b
}
