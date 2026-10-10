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
  # clang has no -std=cqe (it only knows c2y), so the preprocessing step and
  # the reference build use cstd while QPCC gets std. N3914's convertibility
  # macros are QPCC's, so they are defined on the preprocessing command line.
  cstd=""
  defs=""
  case "$hdr" in
    *"std=cqe"*)
      std="-std=cqe"
      cstd="-std=c2y"
      inc="$here/include/qbe"
      defs="-D__STDC_PTR_CONV_ANY_FUNC_TO_VOID__=1 -D__STDC_PTR_CONV_VOID_TO_ANY_FUNC__=1 -D__STDC_PTR_CONV_FUNC_TO_VOID__=1 -D__STDC_PTR_CONV_VOID_TO_FUNC__=1"
      ;;
    *"std=c2y"*)
      std="-std=c2y"
      cstd="-std=c2y"
      inc="$here/include/qbe"
      defs="-D__STDC_PTR_CONV_ANY_FUNC_TO_VOID__=1 -D__STDC_PTR_CONV_VOID_TO_ANY_FUNC__=1 -D__STDC_PTR_CONV_FUNC_TO_VOID__=1 -D__STDC_PTR_CONV_VOID_TO_FUNC__=1"
      ;;
    *"std=c23"*)
      std="-std=c23"
      cstd="-std=c23"
      ;;
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
    clang -E -P $cstd $defs -I "$inc" "$c" > "$tmp/$base.i"
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
    clang $cstd -I "$inc" "$c" -o "$tmp/$base.ref"
  else
    clang $cstd "$c" -o "$tmp/$base.ref"
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

# `qpcc run` drives clang for the preprocessing and the linking as well, so
# the driver can compile and execute a normal C file in one step. Reuse a
# fixture that already returns 0 on success.
if "$exe" run -std=cqe "$here/tests/void_init.c" >/dev/null 2>&1; then
  echo "ok   run (exit 0)"
  pass=$((pass + 1))
else
  echo "FAIL run: qpcc run did not exit 0"
  fail=$((fail + 1))
fi

# ... and it forwards the program's exit status.
if "$exe" run "$here/tests/run_status.c" >/dev/null 2>&1; then
  echo "FAIL run-status: expected a non-zero exit"
  fail=$((fail + 1))
elif [ $? -eq 7 ]; then
  echo "ok   run-status (exit 7)"
  pass=$((pass + 1))
else
  echo "FAIL run-status: wrong exit status"
  fail=$((fail + 1))
fi

echo "qpcc oracle: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
