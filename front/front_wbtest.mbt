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
test "front: mangled name shape" {
  let n = template_mangled("R_", "int,float")
  assert_eq(n.length(), 18)
  assert_true(is_template_name(n))
}

///|
test "front: a template instantiation lexes as one identifier" {
  let toks = tokenize("R_([int, float]) x;", C11)
  assert_true(
    match toks[0].kind {
      Ident(n) => is_template_name(n)
      _ => false
    },
  )
  // The same spelling with different whitespace mangles the same.
  let a = tokenize("R_([int,float]) x;", C11)
  let b = tokenize("R_([int, float]) x;", C11)
  assert_true(
    match (a[0].kind, b[0].kind) {
      (Ident(x), Ident(y)) => x == y
      _ => false
    },
  )
}

///|
test "front: parse _Generic, _Static_assert, typeof, attributes" {
  let _tu = parse(
    "_Static_assert(sizeof(int) == 4, \"int\"); int f() { typeof(int) x = 0; return _Generic(x, int: 1, default: 0); } typedef int *p __attribute__((unused));",
  )
  assert_true(true)
}

///|
test "front: C23 keywords in C23 mode" {
  let _tu = parse(
    "bool b = true; int main() { constexpr int x = 1; return nullptr == 0; }",
    mode=C23,
  )
  assert_true(true)
}

///|
test "front: C23-only names remain identifiers in C11 mode" {
  let _tu = parse("int bool = 1; int main() { return bool; }")
  assert_true(true)
}

///|
test "front: C23 attributes, _BitInt and static_assert" {
  let _tu = parse(
    "[[noreturn]] void f(void); _BitInt(8) g; static_assert(1, \"x\");",
    mode=C23,
  )
  assert_true(true)
}

///|
test "front: C23 typeof_unqual, alignas and alignof" {
  let _tu = parse(
    "int main() { typeof_unqual(int) x = 1; alignas(16) int y = 2; return alignof(int) + x + y; }",
    mode=C23,
  )
  assert_true(true)
}

///|
test "front: C23 char8_t, digit separators and [[fallthrough]]" {
  let _tu = parse(
    "int main() { char8_t c = 65; int x = 1'000; int y = 0xFF'FF; double d = 1'0.5; switch (x) { case 1: [[fallthrough]]; default: break; } return (int)c + x + y + (int)d; }",
    mode=C23,
  )
  assert_true(true)
}

///|
test "front: C23 attribute before a statement declaration" {
  let _tu = parse(
    "int main() { [[maybe_unused]] int y = 0; return y; }",
    mode=C23,
  )
  assert_true(true)
}
