#!/bin/sh
# QPCC M0 end-to-end: .c -> QBE builder -> Mach-O arm64 object -> clang -> run,
# then compare the exit code.
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
  "$tmp/$base"
  got=$?
  set -e
  if [ "$got" -ne "$want" ]; then
    echo "FAIL $base: expected exit $want, got $got"
    exit 1
  fi
  echo "ok   $base (exit $got)"
}

check "$here/tests/m0_return42.c" 42
echo "qpcc M0 tests passed"
