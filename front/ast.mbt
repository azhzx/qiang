///|
/// Surface AST for the full C11 + GNU extension front end.
/// No semantic information: names/types are resolved later by sema.

///|
/// Source position (1-based).
pub struct Span {
  line : Int
  col : Int
  // Length in bytes of the construct, for the caret run in a diagnostic.
  len : Int
}

///|
pub struct TranslationUnit {
  decls : Array[ExternalDecl]
}

///|
pub(all) enum AlignmentSpec {
  AlignType(DeclSpec, Declarator)
  AlignExpr(Expr)
}

///|
pub struct DeclSpec {
  storage : Array[String]
  qualifiers : Array[String]
  type_specs : Array[TypeSpec]
  func_specs : Array[String]
  align : Array[AlignmentSpec]
  attrs : Array[String]
}

///|
pub(all) enum TypeSpec {
  TKw(String)
  TStruct(String?, Array[StructDecl])
  TUnion(String?, Array[StructDecl])
  // QPCC -f_tagged_union: _Tagged_union Tag { members }. The tag is a
  // synthetic int at offset 0, the members overlap after it.
  TTaggedUnion(String?, Array[StructDecl])
  // tag, enumerators, C23 fixed underlying type (default int)
  TEnum(String?, Array[EnumItem], DeclSpec?)
  TTypedefName(String)
  TTypeofExpr(Expr)
  TTypeofType(DeclSpec, Declarator)
  TAtomicSpec(DeclSpec, Declarator)
  TBitInt(Expr)
  // QPCC: `_Function_pointer T (params)` is the prefix spelling of the
  // function pointer type `T (*)(params)`: the return type and the parameter
  // list are written in the order they are read.
  TFuncPtr(DeclSpec, Array[ParamDecl], Bool)
  // QPCC: a bare `_Function_pointer` is the storage type for any function
  // pointer (N3914's `_Any_func*`). It converts to and from every function
  // pointer type and to and from `void *`, but it cannot be called.
  TFuncPtrAny
  // QPCC closures: the written closure type `_Lambda T (params)`.
  TClosure(DeclSpec, Array[ParamDecl], Bool)
}

///|
pub(all) enum StructDecl {
  SDecl(DeclSpec, Array[InitDeclarator])
  SStaticAssert(Expr, String?)
  SPragma(String)
  SAnon(DeclSpec)
}

///|
pub struct EnumItem {
  name : String
  value : Expr?
}

///|
pub(all) enum Declarator {
  DName(String)
  DAbstract
  DPointer(Array[String], Declarator)
  DArray(Declarator, Expr?, Bool)
  DFunction(Declarator, Array[ParamDecl], Bool)
}

///|
pub struct ParamDecl {
  spec : DeclSpec
  decl : Declarator
}

///|
/// QPCC closures: one entry of a `_Lambda(...)` capture list. `&x` captures
/// the variable itself (the environment stores its address), a bare `x`
/// captures its current value.
pub struct Capture {
  name : String
  by_ref : Bool
}

///|
pub struct InitDeclarator {
  decl : Declarator
  init : Initializer?
  bits : Expr?
}

///|
pub(all) enum Initializer {
  IExpr(Expr)
  IList(Array[DesignatedInit])
}

///|
pub struct DesignatedInit {
  designators : Array[Designator]
  init : Initializer
}

///|
pub(all) enum Designator {
  DField(String)
  DIndex(Expr)
  DRange(Expr, Expr)
}

///|
pub(all) enum ExternalDeclKind {
  EFunc(DeclSpec, Declarator, Stmt)
  EDecl(DeclSpec, Array[InitDeclarator])
  EStaticAssert(Expr, String?)
  EAsm(String)
  EPragma(String)
  EEmpty
}

///|
pub struct ExternalDecl {
  kind : ExternalDeclKind
  pos : Span
}

///|
pub(all) enum BlockItem {
  BStmt(Stmt)
  BDecl(DeclSpec, Array[InitDeclarator], Span)
}

///|
pub(all) enum ForInit {
  FDecl(DeclSpec, Array[InitDeclarator])
  FExpr(Expr)
}

///|
pub(all) enum StmtKind {
  SCompound(Array[BlockItem])
  SExpr(Expr?)
  SIf(Expr, Stmt, Stmt?)
  SSwitch(Expr, Stmt)
  SWhile(Expr, Stmt)
  SDoWhile(Stmt, Expr)
  SFor(ForInit?, Expr?, Expr?, Stmt)
  SGoto(String)
  SGotoPtr(Expr)
  SContinue(String?)
  SBreak(String?)
  // TS 25755 / N3590: _Defer statement runs when the enclosing block exits.
  SDefer(Stmt)
  SReturn(Expr?)
  SLabel(String, Stmt?)
  SCase(Expr, Stmt?)
  SCaseRange(Expr, Expr, Stmt?)
  SDefault(Stmt?)
  SDecl(DeclSpec, Array[InitDeclarator])
  SStaticAssert(Expr, String?)
  SAsm(String)
  SPragma(String)
  SEmpty
}

///|
pub struct Stmt {
  kind : StmtKind
  pos : Span
}

///|
pub(all) enum Expr {
  EInt(String)
  EFloat(String)
  EImag(String)
  EChar(String)
  EString(Array[String])
  EIdent(String)
  EBool(Bool)
  ENullptr
  EBinary(String, Expr, Expr)
  EUnary(String, Expr)
  EPostfix(String, Expr)
  ECond(Expr, Expr, Expr)
  EAssign(String, Expr, Expr)
  ECast(DeclSpec, Declarator, Expr)
  ESizeofExpr(Expr)
  ESizeofType(DeclSpec, Declarator)
  EAlignofType(DeclSpec, Declarator)
  // C2y N3628: _Maxof(type-name) / _Minof(type-name)
  EMaxofType(DeclSpec, Declarator)
  EMinofType(DeclSpec, Declarator)
  // C2y N3369: _Countof(expression) / _Countof(type-name)
  ECountofExpr(Expr)
  ECountofType(DeclSpec, Declarator)
  EAlignofExpr(Expr)
  // QPCC -f_tagged_union: runtime tag and compile-time discriminator.
  EDynamicTag(Expr)
  EStaticTag(DeclSpec, Declarator, String)
  ETypesCompatible(DeclSpec, Declarator, DeclSpec, Declarator)
  ECall(Expr, Array[Expr])
  EIndex(Expr, Expr)
  EMember(Expr, String, Bool)
  ECompound(DeclSpec, Declarator, Initializer)
  EGeneric(Expr, Array[GenericAssoc])
  EComma(Expr, Expr)
  EStmtExpr(Array[BlockItem])
  EOffsetof(DeclSpec, Declarator, Array[Designator])
  EVaArg(Expr, DeclSpec, Declarator)
  // QPCC closures: `_Lambda(a, &b) T (params) { body }`.
  ELambda(Array[Capture], DeclSpec, Array[ParamDecl], Bool, Stmt)
  // QPCC closures: `_Closure_environment(e)`, the captured environment.
  EClosureEnv(Expr)
  ETemp
}

///|
pub struct GenericAssoc {
  spec : DeclSpec?
  decl : Declarator?
  expr : Expr
}
