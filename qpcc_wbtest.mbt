///|
test "qpcc: IL names main" {
  let il = compile_il("int main() { return 42; }") catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$main"))
}

///|
test "qpcc: object is not empty" {
  let obj = compile_object("int main() { return 42; }") catch {
    _ => fail("compile failed")
  }
  assert_true(obj.length() > 0)
}

///|
test "qpcc: recursion compiles" {
  let il = compile_il(
    "int fib(int n) { if (n < 2) { return n; } return fib(n - 1) + fib(n - 2); } int main() { return fib(10); }",
  ) catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$fib"))
}

///|
test "qpcc: preprocessor lines are ignored" {
  let il = compile_il("#include <stdio.h>\nint main() { return 0; }") catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$main"))
}

///|
test "qpcc: struct member access" {
  let il = compile_il(
    "struct P { int x; int y; }; int main() { struct P p; p.x = 3; p.y = 4; return p.x * 10 + p.y; }",
  ) catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$main"))
}
