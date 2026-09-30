///|
test "qpcc M0: IL names main and returns" {
  let il = compile_il("int main() { return 42; }") catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$main"))
  assert_true(il.contains("ret"))
}

///|
test "qpcc M0: object is not empty" {
  let obj = compile_object("int main() { return 42; }") catch {
    _ => fail("compile failed")
  }
  assert_true(obj.length() > 0)
}

///|
test "qpcc M0: multiple functions" {
  let il = compile_il("int main() { return 1; } int foo() { return 2; }") catch {
    _ => fail("compile failed")
  }
  assert_true(il.contains("$foo"))
}
