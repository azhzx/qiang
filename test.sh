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
  # A fixture may pin the language mode with a `// std=c23` or `// std=c2y`
  # first line. C2y fixtures also see QPCC's hand-written headers and are fed
  # through the external preprocessor, the same way the real driver expects.
  # `// expect-exit N` makes a fixture QPCC-only (no clang reference) for
  # keywords clang does not implement yet; its exit code must be N.
  hdr=$(head -2 "$c")
  std=""
  inc=""
  exp=""
  case "$hdr" in
    *"std=c2y"*)
      std="-std=c2y"
      inc="$here/include/qbe"
      ;;
    *"std=c23"*) std="-std=c23" ;;
  esac
  case "$hdr" in
    *"expect-exit"*)
      exp=$(printf '%s\n' "$hdr" | sed -n 's/.*expect-exit[^0-9-]*\([-0-9]*\).*/\1/p' | head -1)
      ;;
  esac
  extra=""
  case "$hdr" in
    *"tagged"*) extra="-f_tagged_union" ;;
  esac
  qpcc_src=$c
  if [ -n "$inc" ]; then
    clang -E -P $std -I "$inc" "$c" > "$tmp/$base.i"
    qpcc_src=$tmp/$base.i
  fi
  if [ -n "$exp" ]; then
    if ! "$exe" "$qpcc_src" $std $extra -o "$tmp/$base.o" 2>"$tmp/$base.err"; then
      echo "FAIL $base (qpcc compile)"
      fail=$((fail + 1))
      continue
    fi
    clang "$tmp/$base.o" -o "$tmp/$base.qpcc"
    set +e
    "$tmp/$base.qpcc" >/dev/null 2>&1
    gotcode=$?
    set -e
    if [ "$gotcode" -ne "$exp" ]; then
      echo "FAIL $base: qpcc exit $gotcode, want $exp"
      fail=$((fail + 1))
    else
      echo "ok   $base (exit $gotcode)"
      pass=$((pass + 1))
    fi
    continue
  fi
  if [ -n "$inc" ]; then
    clang $std -I "$inc" "$c" -o "$tmp/$base.ref"
  else
    clang $std "$c" -o "$tmp/$base.ref"
  fi
  set +e
  "$tmp/$base.ref" >"$tmp/$base.ref.out" 2>&1
  refcode=$?
  set -e
  if ! "$exe" "$qpcc_src" $std $extra -o "$tmp/$base.o" 2>"$tmp/$base.err"; then
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
