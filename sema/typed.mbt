///|
/// Checked (typed) expression tree.
pub(all) enum TExprKind {
  TInt(Int64)
  TFlt(Double, Bool)
  TStr(Int)
  TVar(String)
  TBin(String, TExpr, TExpr)
  TUn(String, TExpr)
  TAssign(TExpr, TExpr)
  TCall(String, TExpr, Array[TExpr])
  TCond(TExpr, TExpr, TExpr)
  TCast(TExpr)
  TMember(TExpr, Int)
  TIndex(TExpr, TExpr)
  TComma(TExpr, TExpr)
  TAddr(TExpr)
  TDeref(TExpr)
  TSizeof(Int)
  TAlignof(Int)
  TStmtExpr(Array[TStmt])
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
  KSLabel(String)
  KSGoto(String)
  KSDecl(String, CType, TExpr?)
  KSAggInit(String, CType, Array[(Int, TExpr)])
  KSEmpty
}

///|
pub struct TStmt {
  kind : TStmtKind
}

///|
pub struct CheckedFunc {
  name : String
  ty : CType
  body : TStmt
}
