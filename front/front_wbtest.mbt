///|
test "front: parse C11 basics" {
  let _tu = parse(
    "int main(void) { int x = 1; if (x) { return x; } else { return 0; } }",
  )
  assert_true(true)
}

///|
test "front: parse declarators" {
  let _tu = parse(
    "int (*fp)(int, char *); int a[3][4]; struct S { int x : 3; }; union U { int i; char c[4]; };",
  )
  assert_true(true)
}

///|
test "front: parse enum and typedef" {
  let _tu = parse(
    "typedef int T; enum E { A, B = 3, C }; int f() { T x = A; return x; }",
  )
  assert_true(true)
}

///|
test "front: parse GNU extensions" {
  let _tu = parse(
    "__attribute__((packed)) struct S { int x; }; int f() { return ({ int y = 1; y; }); } int g() { return __builtin_offsetof(struct S, x); }",
  )
  assert_true(true)
}

///|
test "front: parse _Generic, _Static_assert, typeof, attributes" {
  let _tu = parse(
    "_Static_assert(sizeof(int) == 4, \"int\"); int f() { typeof(int) x = 0; return _Generic(x, int: 1, default: 0); } typedef int *p __attribute__((unused));",
  )
  assert_true(true)
}
