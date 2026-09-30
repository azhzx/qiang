///|
test "sema: basic declarations" {
  let tu = @front.parse("int x; long y; unsigned z;")
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: typedef and struct layout" {
  let tu = @front.parse(
    "typedef int T; struct S { char a; int b; }; T g; struct S s;",
  )
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
  assert_eq(r.layouts.length(), 1)
  assert_eq(r.layouts[0].size, 8)
}

///|
test "sema: enum constants" {
  let tu = @front.parse("enum E { A, B = 3, C }; int main() { return C; }")
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: declarator types" {
  let tu = @front.parse("int (*fp)(int, char *); int a[3][4]; int *p;")
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: complex and long double types" {
  let tu = @front.parse("_Complex double z; long double w; _Complex float q;")
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: VLA and _Atomic" {
  let tu = @front.parse(
    "int f(int n) { int a[n]; _Atomic int x = 0; return a[0] + x; }",
  )
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: switch keeps case structure" {
  let tu = @front.parse(
    "int f(int x) { switch (x) { case 1: return 1; case 2: return 2; default: return 0; } }",
  )
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
  assert_eq(r.funcs.length(), 1)
}

///|
test "sema: typedef redefinition and shadowing" {
  let tu = @front.parse(
    "int main() { typedef int t; typedef struct {int a;} t; t y; y.a = 1; return y.a; }",
  )
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: diagnostics carry a position" {
  let tu = @front.parse("int main() {\n  int x;\n  return y;\n}")
  let r = check(tu)
  assert_true(r.diags.length() > 0)
  assert_true(r.diags[0].line > 0)
}
