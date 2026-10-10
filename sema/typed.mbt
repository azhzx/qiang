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
  // QPCC -f_tagged_union payload member: address is base + off, and a
  // store through it also writes the discriminator `tag` at base + 0.
  TTaggedMember(TExpr, Int, Int64)
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
  // QPCC closures: build the { fn, env } pair. The String is the hidden
  // function, the Int the environment layout, and each triple is a captured
  // field (offset, source variable, captured by reference).
  TLambda(String, Int, Array[(Int, TExpr, Bool)])
  // QPCC closures: the environment pointer of a closure value.
  TClosureEnv(TExpr)
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
  // The Int is how many break/continue frames to skip when the jump is
  // named (C2y N3355 named loops); 0 is the innermost.
  KSBreak(Int)
  KSContinue(Int)
  // TS 25755 _Defer: run this statement when the enclosing block exits.
  KSDefer(TStmt)
  KSLabel(String, TStmt)
  KSGoto(String)
  KSGotoPtr(TExpr)
  // The Int is how many cases precede the default label in the source. C
  // lets a case fall through into the default, so the generated fall-through
  // chain has to put the default back at its source position.
  KSSwitch(TExpr, Array[(Int64, TStmt)], TStmt?, Int)
  // A case (or default) label still attached to its statement. The label runs
  // nothing, so code generation just emits `body`; it exists so a switch can
  // find cases nested anywhere in its body, which is what a Duff's device needs.
  KSCaseMark(Array[Int64], Bool, TStmt)
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

///|
/// QPCC closures: one captured variable of a synthesized closure function.
/// The name is bound to the environment field at `off`, so a by-value capture
/// reads and writes its copy and a by-reference capture holds the pointer.
pub struct ClosureCapture {
  name : String
  off : Int
  ty : CType
}

///|
/// QPCC closures: what a synthesized closure function needs on top of an
/// ordinary function - the hidden first parameter holding the environment.
pub struct ClosureInfo {
  self_name : String
  captures : Array[ClosureCapture]
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
  // Some for the hidden function of a _Lambda expression.
  closure : ClosureInfo?
}
