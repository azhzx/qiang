///|
/// C types for the QPCC subset.
pub(all) enum Ty {
  TVoid
  TBool
  TChar
  TSChar
  TUChar
  TShort
  TUShort
  TInt
  TUInt
  TLong
  TULong
  TLongLong
  TULongLong
  TFloat
  TDouble
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
  is_union : Bool
}

///|
pub(all) enum EK {
  ENum(Int64)
  EFlt(Double, Bool)
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
  SSwitch(Expr, Stmt)
  SCase(Int64)
  SDefault
  SGoto(String)
  SLabel(String, Stmt)
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
    TVoid => 1
    TBool | TChar | TSChar | TUChar => 1
    TShort | TUShort => 2
    TInt | TUInt => 4
    TLong | TULong | TLongLong | TULongLong => 8
    TFloat => 4
    TDouble => 8
    TPtr(_) => 8
    TArr(e, n) => size_of(e, structs) * n
    TStruct(i) => structs[i].size
  }
}

///|
pub fn align_of(ty : Ty, structs : Array[StructDef]) -> Int {
  match ty {
    TVoid => 1
    TBool | TChar | TSChar | TUChar => 1
    TShort | TUShort => 2
    TInt | TUInt => 4
    TLong | TULong | TLongLong | TULongLong => 8
    TFloat => 4
    TDouble => 8
    TPtr(_) => 8
    TArr(e, _) => align_of(e, structs)
    TStruct(i) => structs[i].align
  }
}

///|
/// True for integer types (including _Bool and char).
pub fn is_int(ty : Ty) -> Bool {
  match ty {
    TBool
    | TChar
    | TSChar
    | TUChar
    | TShort
    | TUShort
    | TInt
    | TUInt
    | TLong
    | TULong
    | TLongLong
    | TULongLong => true
    _ => false
  }
}

///|
pub fn is_float(ty : Ty) -> Bool {
  match ty {
    TFloat | TDouble => true
    _ => false
  }
}

///|
pub fn is_arith(ty : Ty) -> Bool {
  is_int(ty) || is_float(ty)
}

///|
pub fn is_unsigned(ty : Ty) -> Bool {
  match ty {
    TBool | TUChar | TUShort | TUInt | TULong | TULongLong | TPtr(_) => true
    _ => false
  }
}

///|
pub fn is_signed(ty : Ty) -> Bool {
  is_arith(ty) && !is_unsigned(ty)
}

///|
pub fn decay(ty : Ty) -> Ty {
  match ty {
    TArr(e, _) => TPtr(e)
    _ => ty
  }
}
