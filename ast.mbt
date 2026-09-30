///|
/// C types for the QPCC subset.
pub(all) enum Ty {
  TVoid
  TChar
  TInt
  TLong
  TPtr(Ty)
  TArr(Ty, Int)
  TStruct(Int)
} derive(Eq, Debug)

///|
pub struct StructDef {
  name : String
  members : Array[(String, Ty, Int)]
  size : Int
  align : Int
}

///|
pub(all) enum EK {
  ENum(Int64)
  EVar(String)
  EStr(Int)
  EBin(String, Expr, Expr)
  EUn(String, Expr)
  EAssign(Expr, Expr)
  ECall(String, Array[Expr])
  ECond(Expr, Expr, Expr)
  EMember(Expr, Int)
  ECast(Expr)
  EAddr(Expr)
  EDeref(Expr)
  ESizeofE(Expr)
  ESizeofT(Ty)
  EComma(Expr, Expr)
}

///|
pub struct Expr {
  kind : EK
  ty : Ty
}

///|
pub(all) enum SK {
  SExpr(Expr)
  SReturn(Expr?)
  SIf(Expr, Stmt, Stmt?)
  SWhile(Expr, Stmt)
  SFor(Stmt?, Expr?, Expr?, Stmt)
  SDoWhile(Stmt, Expr)
  SBlock(Array[Stmt])
  SBreak
  SContinue
  SLocal(String, Ty, Expr?)
}

///|
pub struct Stmt {
  kind : SK
}

///|
pub struct Param {
  name : String
  ty : Ty
}

///|
pub struct FuncDef {
  name : String
  ret : Ty
  params : Array[Param]
  body : Stmt
}

///|
pub struct GlobalDef {
  name : String
  ty : Ty
  init : Int64?
}

///|
pub struct Program {
  funcs : Array[FuncDef]
  globals : Array[GlobalDef]
  strings : Array[String]
  structs : Array[StructDef]
}

///|
pub fn size_of(ty : Ty, structs : Array[StructDef]) -> Int {
  match ty {
    TVoid => 0
    TChar => 1
    TInt => 4
    TLong => 8
    TPtr(_) => 8
    TArr(e, n) => size_of(e, structs) * n
    TStruct(i) => structs[i].size
  }
}

///|
pub fn align_of(ty : Ty, structs : Array[StructDef]) -> Int {
  match ty {
    TVoid => 1
    TChar => 1
    TInt => 4
    TLong => 8
    TPtr(_) => 8
    TArr(e, _) => align_of(e, structs)
    TStruct(i) => structs[i].align
  }
}

///|
pub fn is_int(ty : Ty) -> Bool {
  match ty {
    TChar | TInt | TLong => true
    _ => false
  }
}

///|
pub fn decay(ty : Ty) -> Ty {
  match ty {
    TArr(e, _) => TPtr(e)
    _ => ty
  }
}
