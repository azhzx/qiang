///|
/// Checked (typed) expression tree.
pub(all) enum TExprKind {
  TInt(Int64)
  TFlt(Double, Bool)
  TStr(Int)
  TVar(String)
  TLabelAddr(String)
  TBin(String, TExpr, TExpr)
  TUn(String, TExpr)
  TAssign(TExpr, TExpr)
  TCall(String, TExpr, Array[TExpr])
  TCond(TExpr, TExpr, TExpr)
  TCast(TExpr)
  TMember(TExpr, Int)
  TBitField(TExpr, Int, Int, Int)
  TIndex(TExpr, TExpr)
  TComma(TExpr, TExpr)
  TAddr(TExpr)
  TDeref(TExpr)
  TSizeof(Int)
  TAlignof(Int)
  TSizeofVLA(TExpr)
  TStmtExpr(Array[TStmt])
  TCompoundLit(Array[(Int, TExpr, Int, Int)])
  TVaArg(TExpr)
  TUnsupported(String)
}

///|
pub struct TExpr {
  kind : TExprKind
  ty : CType
  lvalue : Bool
}

///|
pub(all) enum TStmtKind {
  KSExpr(TExpr?)
  KSReturn(TExpr?)
  KSIf(TExpr, TStmt, TStmt?)
  KSWhile(TExpr, TStmt)
  KSDoWhile(TStmt, TExpr)
  KSFor(TStmt?, TExpr?, TExpr?, TStmt)
  KSBlock(Array[TStmt])
  KSBreak
  KSContinue
  KSLabel(String, TStmt)
  KSGoto(String)
  KSGotoPtr(TExpr)
  KSSwitch(TExpr, Array[(Int64, TStmt)], TStmt?)
  KSDecl(String, CType, TExpr?, Int)
  KSAggInit(String, CType, Array[(Int, TExpr, Int, Int)], Int)
  KSEmpty
}

///|
pub struct TStmt {
  kind : TStmtKind
}

///|
pub(all) enum GlobalReloc {
  RGlobal(String, Int)
  RString(Int, Int)
}

///|
pub struct CheckedGlobal {
  name : String
  ty : CType
  init : Int64?
  bytes : Array[Byte]
  relocs : Array[(Int, GlobalReloc)]
  is_export : Bool
  align : Int
}

///|
pub struct CheckedFunc {
  name : String
  ty : CType
  params : Array[(String, CType)]
  locals : Array[(String, CType, Int)]
  is_vararg : Bool
  is_export : Bool
  body : TStmt
}
