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
  labels : Map[String, Int]
  mut fid : Int
  break_blks : Array[Int]
  cont_blks : Array[Int]
  mut ret_ty : Ty
  mut open : Bool
}

///|
fn cls_of(ty : Ty) -> @types.Class {
  match ty {
    TVoid => @types.Kw
    TBool | TChar | TSChar | TUChar | TShort | TUShort | TInt | TUInt =>
      @types.Kw
    TLong
    | TULong
    | TLongLong
    | TULongLong
    | TPtr(_)
    | TFunc(_, _)
    | TArr(_, _)
    | TStruct(_) => @types.Kl
    TFloat => @types.Ks
    TDouble => @types.Kd
  }
}

///|
fn ret_of(ty : Ty) -> @ir_builder.Ret {
  match ty {
    TVoid => @ir_builder.Void
    TFloat => @ir_builder.Single
    TDouble => @ir_builder.Double
    TLong
    | TULong
    | TLongLong
    | TULongLong
    | TPtr(_)
    | TFunc(_, _)
    | TArr(_, _)
    | TStruct(_) => @ir_builder.Long
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
fn is_ptr(ty : Ty) -> Bool {
  match decay(ty) {
    TPtr(_) => true
    _ => false
  }
}

///|
fn wider(l : Ty, r : Ty) -> @types.Class {
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
fn is_lit(e : Expr) -> Bool {
  match e.kind {
    ENum(_) | EFlt(_, _) => true
    _ => false
  }
}

///|
fn Cg::norm_bool(c : Cg, v : Int) -> Int {
  c.b.cmp(c.fid, @types.Cnew, @types.Kw, v, c.b.iconst(c.fid, 0L))
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
fn Cg::coerce(c : Cg, v : Int, from : @types.Class, to : @types.Class) -> Int {
  if from == to {
    v
  } else if from == @types.Kw && to == @types.Kl {
    c.b.unop(c.fid, @types.Extsw, @types.Kl, @types.Kl, v)
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
fn Cg::load_scalar(c : Cg, ty : Ty, addr : Int) -> Int {
  match ty {
    TBool | TChar | TSChar => c.b.load(c.fid, @types.Loadsb, @types.Kw, addr)
    TUChar => c.b.load(c.fid, @types.Loadub, @types.Kw, addr)
    TShort => c.b.load(c.fid, @types.Loadsh, @types.Kw, addr)
    TUShort => c.b.load(c.fid, @types.Loaduh, @types.Kw, addr)
    TInt => c.b.load(c.fid, @types.Loadsw, @types.Kw, addr)
    TUInt => c.b.load(c.fid, @types.Loaduw, @types.Kw, addr)
    TLong | TULong | TLongLong | TULongLong | TPtr(_) =>
      c.b.load(c.fid, @types.Load, @types.Kl, addr)
    TFloat => c.b.load(c.fid, @types.Load, @types.Ks, addr)
    TDouble => c.b.load(c.fid, @types.Load, @types.Kd, addr)
    _ => addr
  }
}

///|
fn Cg::store_scalar(c : Cg, ty : Ty, val : Int, addr : Int) -> Unit {
  match ty {
    TBool | TChar | TSChar | TUChar =>
      c.b.store(c.fid, @types.Storeb, @types.Kw, val, addr)
    TShort | TUShort => c.b.store(c.fid, @types.Storeh, @types.Kw, val, addr)
    TInt | TUInt => c.b.store(c.fid, @types.Storew, @types.Kw, val, addr)
    TLong | TULong | TLongLong | TULongLong | TPtr(_) =>
      c.b.store(c.fid, @types.Storel, @types.Kl, val, addr)
    TFloat => c.b.store(c.fid, @types.Stores, @types.Ks, val, addr)
    TDouble => c.b.store(c.fid, @types.Stored, @types.Kd, val, addr)
    _ => abort("qpcc: cannot store an aggregate")
  }
}

///|
fn Cg::new_block(c : Cg, name : String) -> Int {
  c.b.add_block(c.fid, name)
}

///|
fn Cg::switch(c : Cg, blk : Int) -> Unit {
  c.b.switch_to(c.fid, blk)
  c.open = true
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
    EFlt(v, is_f) =>
      if is_f {
        c.b.sconst(c.fid, Float::from_double(v))
      } else {
        c.b.fconst(c.fid, v)
      }
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
        None =>
          match e.ty {
            TFunc(_, _) => c.b.global(c.fid, n)
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
      let vv = if is_lit(r) {
        v
      } else {
        c.coerce(v, cls_of(r.ty), cls_of(l.ty))
      }
      if l.ty == TBool {
        let b = c.norm_bool(vv)
        c.store_scalar(TBool, b, a)
        b
      } else {
        c.store_scalar(l.ty, vv, a)
        vv
      }
    }
    EComma(a, b) => {
      let _ = c.gen_expr(a)
      c.gen_expr(b)
    }
    EBin(op, l, r) => c.gen_bin(op, l, r)
    EUn(op, x) => c.gen_un(op, x)
    ECall(callee, args) => {
      let arglist : Array[(@types.Class, Int)] = []
      for a in args {
        arglist.push((cls_of(a.ty), c.gen_expr(a)))
      }
      let rty = match decay(callee.ty) {
        TFunc(r, _) => r
        TPtr(TFunc(r, _)) => r
        _ => TInt
      }
      match callee.kind {
        EVar(name) =>
          match callee.ty {
            TPtr(TFunc(_, _)) => {
              let fp = c.gen_expr(callee)
              c.b.call_value(c.fid, fp, arglist, ret_of(rty))
            }
            _ => c.b.call(c.fid, name, arglist, ret_of(rty))
          }
        _ => {
          let fp = c.gen_expr(callee)
          c.b.call_value(c.fid, fp, arglist, ret_of(rty))
        }
      }
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
    EAlignofT(t) => c.b.iconst(c.fid, align_of(t, c.structs).to_int64())
    ESizeofE(x) => c.b.iconst(c.fid, size_of(decay(x.ty), c.structs).to_int64())
    ECast(x) => {
      let v = c.gen_expr(x)
      if e.ty == TBool {
        let cls = cls_of(x.ty)
        let z = c.zero_of(cls)
        c.b.cmp(
          c.fid,
          cmp_op("!=", cls, is_unsigned(x.ty), is_float(x.ty)),
          cls,
          v,
          z,
        )
      } else {
        c.coerce(v, cls_of(x.ty), cls_of(e.ty))
      }
    }
  }
}

///|
fn Cg::gen_bin(c : Cg, op : String, l : Expr, r : Expr) -> Int {
  let lt = decay(l.ty)
  let rt = decay(r.ty)
  let cls = wider(lt, rt)
  let fl = is_float(lt) || is_float(rt)
  let uns = is_unsigned(lt) || is_unsigned(rt)
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
  } else if prec_of(op) <= 7 &&
    op != "+" &&
    op != "-" &&
    op != "<<" &&
    op != ">>" {
    let a = c.gen_expr(l)
    let av = c.coerce(a, cls_of(lt), cls)
    let b = c.gen_expr(r)
    let bv = c.coerce(b, cls_of(rt), cls)
    c.b.cmp(c.fid, cmp_op(op, cls, uns, fl), cls, av, bv)
  } else if (op == "+" || op == "-") && !fl {
    match (lt, rt) {
      (TPtr(el), _) if !is_ptr(r.ty) => {
        let base = c.gen_expr(l)
        let idx = c.coerce(c.gen_expr(r), cls_of(rt), @types.Kl)
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
        let idx = c.coerce(c.gen_expr(l), cls_of(lt), @types.Kl)
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
fn Cg::gen_un(c : Cg, op : String, x : Expr) -> Int {
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
      c.b.cmp(
        c.fid,
        cmp_op("==", cls, is_unsigned(x.ty), is_float(x.ty)),
        cls,
        v,
        z,
      )
    }
    _ => {
      let pre = op == "pre++" || op == "pre--"
      let inc = op == "pre++" || op == "post++"
      let a = c.gen_addr(x)
      let ty = x.ty
      let old = c.load_scalar(ty, a)
      let cls = cls_of(ty)
      let one = match decay(ty) {
        TPtr(el) => c.b.iconst(c.fid, size_of(el, c.structs).to_int64())
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
fn collect_locals(s : Stmt, out : Array[(String, Ty)]) -> Unit {
  match s.kind {
    SBlock(ss) =>
      for x in ss {
        collect_locals(x, out)
      }
    SLocal(n, t, _) => out.push((n, t))
    SAggInit(n, t, _) => out.push((n, t))
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
    SSwitch(_, b) => collect_locals(b, out)
    SLabel(_, b) => collect_locals(b, out)
    _ => ()
  }
}

///|
fn collect_labels(s : Stmt, out : Array[String]) -> Unit {
  match s.kind {
    SBlock(ss) =>
      for x in ss {
        collect_labels(x, out)
      }
    SLabel(n, b) => {
      out.push(n)
      collect_labels(b, out)
    }
    SIf(_, a, b) => {
      collect_labels(a, out)
      match b {
        Some(x) => collect_labels(x, out)
        None => ()
      }
    }
    SWhile(_, b) => collect_labels(b, out)
    SFor(i, _, _, b) => {
      match i {
        Some(x) => collect_labels(x, out)
        None => ()
      }
      collect_labels(b, out)
    }
    SDoWhile(b, _) => collect_labels(b, out)
    SSwitch(_, b) => collect_labels(b, out)
    _ => ()
  }
}

///|
fn Cg::gen_switch(c : Cg, e : Expr, body : Stmt) -> Unit {
  let stmts = match body.kind {
    SBlock(ss) => ss
    _ => [body]
  }
  let end = c.new_block("switch.end")
  let cases : Array[(Int64, Int)] = []
  let mut default_blk = -1
  for s in stmts {
    match s.kind {
      SCase(v) => {
        let blk = c.new_block("switch.case")
        cases.push((v, blk))
      }
      SDefault => default_blk = c.new_block("switch.default")
      _ => ()
    }
  }
  if default_blk == -1 {
    default_blk = end
  }
  let v = c.gen_expr(e)
  let cls = cls_of(e.ty)
  let n = cases.length()
  let tests : Array[Int] = []
  for _i in 0..<n {
    tests.push(c.new_block("switch.test"))
  }
  if n == 0 {
    c.b.jmp(c.fid, default_blk, [])
  } else {
    c.b.jmp(c.fid, tests[0], [])
  }
  c.open = false
  for i in 0..<n {
    c.switch(tests[i])
    let (val, blk) = cases[i]
    let cv = c.b.iconst(c.fid, val)
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
    let next = if i + 1 < n { tests[i + 1] } else { default_blk }
    c.b.jnz(c.fid, cc, blk, [], next, [])
    c.open = false
  }
  c.break_blks.push(end)
  let mut ci = 0
  for s in stmts {
    match s.kind {
      SCase(_) => {
        let (_, blk) = cases[ci]
        ci = ci + 1
        if c.open {
          c.b.jmp(c.fid, blk, [])
          c.open = false
        }
        c.switch(blk)
      }
      SDefault => {
        if c.open {
          c.b.jmp(c.fid, default_blk, [])
          c.open = false
        }
        c.switch(default_blk)
      }
      _ => c.gen_stmt(s)
    }
  }
  if c.open {
    c.b.jmp(c.fid, end, [])
    c.open = false
  }
  let _ = c.break_blks.pop()
  c.switch(end)
}

///|
fn Cg::gen_stmt(c : Cg, s : Stmt) -> Unit {
  match s.kind {
    SBlock(ss) =>
      for x in ss {
        if !c.open {
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
          let vv = if is_lit(e) {
            v
          } else {
            c.coerce(v, cls_of(e.ty), cls_of(ty))
          }
          let vv2 = if ty == TBool { c.norm_bool(vv) } else { vv }
          c.store_scalar(ty, vv2, a)
        }
        None => ()
      }
    SAggInit(name, ty, items) => {
      let base = match c.locals.get(name) {
        Some(x) => x
        None => abort("qpcc: unbound local")
      }
      for i in 0..<items.length() {
        let (off, ety) = match ty {
          TArr(e, _) => (i * size_of(e, c.structs), e)
          TStruct(idx) => {
            let m = c.structs[idx].members[i]
            (m.2, m.1)
          }
          _ => (0, ty)
        }
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
        let v = c.gen_expr(items[i])
        let vv = if is_lit(items[i]) {
          v
        } else {
          c.coerce(v, cls_of(items[i].ty), cls_of(ety))
        }
        c.store_scalar(ety, vv, addr)
      }
    }
    SExpr(e) => {
      let _ = c.gen_expr(e)
    }
    SReturn(e) => {
      let v = match e {
        Some(x) => {
          let val = c.gen_expr(x)
          let want = ret_of(c.ret_ty).cls()
          if is_lit(x) {
            val
          } else {
            c.coerce(val, cls_of(x.ty), want)
          }
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
    SGoto(n) => {
      let blk = match c.labels.get(n) {
        Some(b) => b
        None => abort("qpcc: unknown label " + n)
      }
      c.b.jmp(c.fid, blk, [])
      c.open = false
    }
    SLabel(n, b) => {
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
    SSwitch(e, body) => c.gen_switch(e, body)
    SCase(_) => abort("qpcc: case outside switch")
    SDefault => abort("qpcc: default outside switch")
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
  for i in 0..<f.params.length() {
    let p = f.params[i]
    if p.name != "" {
      let raw = size_of(p.ty, c.structs)
      let sz = if raw < 8 { 8 } else { raw }
      let sv = c.b.iconst(fid, sz.to_int64())
      let slot = c.b.emit_ins(fid, @types.Alloc8, @types.Kl, @types.Kl, sv, -1)
      let pv = c.b.param(fid, i)
      c.store_scalar(p.ty, pv, slot)
      c.locals.set(p.name, slot)
      c.local_ty.set(p.name, p.ty)
    }
  }
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
  let label_names : Array[String] = []
  collect_labels(f.body, label_names)
  for n in label_names {
    if !c.labels.contains(n) {
      let blk = c.b.add_block(fid, "label_" + n)
      c.labels.set(n, blk)
    }
  }
  c.gen_stmt(f.body)
  if c.open {
    let v = if ret_of(c.ret_ty) == @ir_builder.Void {
      -1
    } else {
      c.zero_of(ret_of(c.ret_ty).cls())
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
    let v = match g.init {
      Some(x) => x
      None => 0L
    }
    b.data_bytes(g.name, false, le_bytes(v))
  }
  let fmap : Map[String, (Ty, Array[Ty])] = Map::new()
  for f in p.funcs {
    let ptypes : Array[Ty] = []
    for pp in f.params {
      ptypes.push(pp.ty)
    }
    fmap.set(f.name, (f.ret, ptypes))
  }
  let c = Cg::{
    b,
    structs: p.structs,
    locals: Map::new(),
    local_ty: Map::new(),
    globals: Map::new(),
    funcs: fmap,
    str_labels: strs,
    labels: Map::new(),
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
