///|
/// Surface AST for the full C11 + GNU extension front end.
/// No semantic information: names/types are resolved later by sema.

///|
/// Source position (1-based).
pub struct Span {
  line : Int
  col : Int
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
  // tag, enumerators, C23 fixed underlying type (default int)
  TEnum(String?, Array[EnumItem], DeclSpec?)
  TTypedefName(String)
  TTypeofExpr(Expr)
  TTypeofType(DeclSpec, Declarator)
  TAtomicSpec(DeclSpec, Declarator)
  TBitInt(Expr)
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
  BDecl(DeclSpec, Array[InitDeclarator])
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
  ETemp
}

///|
pub struct GenericAssoc {
  spec : DeclSpec?
  decl : Declarator?
  expr : Expr
}
