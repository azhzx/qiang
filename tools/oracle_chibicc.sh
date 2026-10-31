#!/bin/sh
# chibicc's C test suite, run through the same oracle idea as test.sh: compile
# every fixture with clang and with Qiang, link both, run them and compare exit
# code and stdout. The suite carries its own ASSERT macro; chibicc-tests/shim.c
# supplies the assert() it calls.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
exe=$(find "$here/_build" "$here/../_build" -name 'qiang.exe' -type f 2>/dev/null | head -n 1)
[ -n "$exe" ] || { echo 'error: qiang.exe not built' >&2; exit 1; }
inc="$here/include/qiang"
suite="$here/chibicc-tests"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

clang -w -c "$suite/shim.c" -o "$tmp/shim.o"

pass=0; fail=0; skip=0
for c in "$suite"/tests/*.c; do
  base=$(basename "$c" .c)
  # skip fixtures the reference compiler itself rejects (Qiang-only features)
  if ! clang -w -I "$suite" "$c" "$tmp/shim.o" -o "$tmp/$base.ref" 2>"$tmp/$base.referr"; then
    skip=$((skip + 1))
    continue
  fi
  if ! clang -E -P -I "$suite" -I "$inc" "$c" > "$tmp/$base.i" 2>/dev/null; then
    skip=$((skip + 1))
    continue
  fi
  if ! "$exe" "$tmp/$base.i" -o "$tmp/$base.o" 2>"$tmp/$base.err"; then
    echo "FAIL $base (Qiang compile)"
    sed -n '1,3p' "$tmp/$base.err"
    fail=$((fail + 1))
    continue
  fi
  if ! clang "$tmp/$base.o" "$tmp/shim.o" -o "$tmp/$base.q" 2>"$tmp/$base.linkerr"; then
    echo "FAIL $base (link)"
    fail=$((fail + 1))
    continue
  fi
  set +e
  "$tmp/$base.ref" > "$tmp/$base.co" 2>&1; crc=$?
  "$tmp/$base.q" > "$tmp/$base.qo" 2>&1; qrc=$?
  set -e
  if [ "$crc" = "$qrc" ] && cmp -s "$tmp/$base.co" "$tmp/$base.qo"; then
    pass=$((pass + 1))
  else
    echo "FAIL $base (ref rc=$crc, qiang rc=$qrc)"
    diff "$tmp/$base.co" "$tmp/$base.qo" 2>/dev/null | head -4
    fail=$((fail + 1))
  fi
done

echo "chibicc: $pass passed, $fail failed, $skip skipped"
[ "$fail" -eq 0 ]