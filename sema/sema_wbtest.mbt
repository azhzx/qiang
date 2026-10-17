///|
test "sema: basic declarations" {
  let tu = @front.parse("int x; long y; unsigned z;")
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: _Generic rejects compatible associations and duplicates" {
  // C11 6.5.1.1p2: no two associations may specify compatible types, and a
  // generic selection has at most one default.
  let a = check(
    @front.parse("int f(int x) { return _Generic(x, int: 1, int: 2); }"),
  )
  assert_true(a.diags.length() > 0)
  let b = check(
    @front.parse(
      "int f(int x) { return _Generic(x, int: 1, default: 2, default: 3); }",
    ),
  )
  assert_true(b.diags.length() > 0)
  // A compatible-but-distinct pair (int vs signed int) is the same type.
  let c = check(
    @front.parse("int f(int x) { return _Generic(x, int: 1, signed: 2); }"),
  )
  assert_true(c.diags.length() > 0)
  // ... and a well-formed selection is still accepted.
  let d = check(
    @front.parse(
      "int f(int x) { return _Generic(x, int: 1, double: 2, default: 3); }",
    ),
  )
  assert_eq(d.diags.length(), 0)
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
test "sema: C23 char8_t is an unsigned 8-bit type" {
  let tu = @front.parse(
    "char8_t c = 65; int main() { return (int)c - 65; }",
    mode=@front.C23,
  )
  let r = check(tu)
  assert_eq(r.diags.length(), 0)
}

///|
test "sema: over-aligned declarations are diagnosed" {
  let tu = @front.parse("int main() { _Alignas(32) int x; return 0; }")
  let r = check(tu)
  assert_true(r.diags.length() > 0)
}

///|
test "sema: diagnostics carry a position" {
  let tu = @front.parse("int main() {\n  int x;\n  return y;\n}")
  let r = check(tu)
  assert_true(r.diags.length() > 0)
  assert_true(r.diags[0].line > 0)
}

///|
/// C99 6.7.4p6-7: an `inline` definition is an inline definition (no external
/// definition emitted) only while *every* declaration of it in the translation
/// unit carries `inline`. A plain prototype keeps the external definition,
/// which is what bzip2's bzlib_private.h does for BZ2_indexIntoF while
/// bzlib.c defines it `__inline__`.
test "sema: inline linkage follows C99 6.7.4p6" {
  // A plain prototype: external definition required (bzlib_private.h).
  let plain = check(
    @front.parse("__inline__ int g(int x) { return x * 2; }\nint g(int);"),
  )
  assert_eq(plain.diags.length(), 0)
  assert_true(plain.funcs[0].is_export)
  // Every declaration inline: an inline definition, so no external definition.
  // Emitting one used to duplicate Darwin <math.h> helpers across objects.
  let inl = check(
    @front.parse("inline int h(int x) { return x; }\ninline int h(int x);"),
  )
  assert_eq(inl.diags.length(), 0)
  assert_true(!inl.funcs[0].is_export)
  // static inline is internal regardless.
  let st = check(@front.parse("static inline int s(int x) { return x; }"))
  assert_eq(st.diags.length(), 0)
  assert_true(!st.funcs[0].is_export)
}
