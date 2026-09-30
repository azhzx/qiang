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
test "sema: unsupported complex type reports an error" {
  let tu = @front.parse("_Complex double z;")
  let r = check(tu)
  assert_true(r.diags.length() > 0)
}
