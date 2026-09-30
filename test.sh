#!/bin/sh
# QPCC oracle: for every fixture compile with clang and with qpcc, link both,
# run them, and compare exit codes and stdout.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
exe="$root/_build/native/debug/build/qpcc/cmd/cmd.exe"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cd "$root"
moon build --target native qpcc/cmd >/dev/null

pass=0
fail=0
for c in "$here"/tests/*.c; do
  base=$(basename "$c" .c)
  clang "$c" -o "$tmp/$base.ref"
  set +e
  "$tmp/$base.ref" >"$tmp/$base.ref.out" 2>&1
  refcode=$?
  set -e
  if ! "$exe" "$c" -o "$tmp/$base.o" 2>"$tmp/$base.err"; then
    echo "FAIL $base (qpcc compile)"
    fail=$((fail + 1))
    continue
  fi
  clang "$tmp/$base.o" -o "$tmp/$base.qpcc"
  set +e
  "$tmp/$base.qpcc" >"$tmp/$base.qpcc.out" 2>&1
  gotcode=$?
  set -e
  if [ "$refcode" -ne "$gotcode" ] || ! cmp -s "$tmp/$base.ref.out" "$tmp/$base.qpcc.out"; then
    echo "FAIL $base: clang exit $refcode vs qpcc exit $gotcode"
    fail=$((fail + 1))
  else
    echo "ok   $base (exit $gotcode)"
    pass=$((pass + 1))
  fi
done

echo "qpcc oracle: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
