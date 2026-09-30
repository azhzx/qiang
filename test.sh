#!/bin/sh
# QPCC end-to-end: .c -> QBE builder -> Mach-O arm64 object -> clang -> run,
# then compare the exit code (and putchar output).
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
exe="$root/_build/native/debug/build/qpcc/cmd/cmd.exe"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cd "$root"
moon build --target native qpcc/cmd >/dev/null

check() {
  c="$1"; want="$2"
  base=$(basename "$c" .c)
  "$exe" "$c" -o "$tmp/$base.o"
  clang "$tmp/$base.o" -o "$tmp/$base"
  set +e
  "$tmp/$base" >"$tmp/$base.out" 2>/dev/null
  got=$?
  set -e
  if [ "$got" -ne "$want" ]; then
    echo "FAIL $base: expected $want, got $got"
    exit 1
  fi
  echo "ok   $base (exit $got)"
}

check "$here/tests/m0_return42.c" 42
check "$here/tests/arith.c" 9
check "$here/tests/if.c" 1
check "$here/tests/while.c" 10
check "$here/tests/for.c" 10
check "$here/tests/fib.c" 55
check "$here/tests/ptr.c" 7
check "$here/tests/arr.c" 6
check "$here/tests/str.c" 104
check "$here/tests/sizeof.c" 13
check "$here/tests/global.c" 7
check "$here/tests/logic.c" 1
check "$here/tests/cond.c" 10

"$exe" "$here/tests/putchar.c" -o "$tmp/putchar.o"
clang "$tmp/putchar.o" -o "$tmp/putchar"
out=$("$tmp/putchar")
if [ "$out" != "AB" ]; then
  echo "FAIL putchar: got '$out'"
  exit 1
fi
echo "ok   putchar (output AB)"
echo "qpcc tests passed"
