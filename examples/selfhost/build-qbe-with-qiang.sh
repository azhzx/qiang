#!/bin/sh
# Build QBE (vendor/qbe) with Qiang, then check the result against the reference.
#
# Qiang is the C compiler in this repository. This script exercises it on a real
# C program: QBE's own sources (about 17k lines of C plus three back ends).
#
#   step 1  compile every vendor/qbe source with Qiang into Mach-O arm64 objects
#   step 2  link those objects into ./qbe-Qiang
#   step 3  build the reference ./qbe with the system compiler
#   step 4  run both over QBE's test corpus and diff their assembly output
#
# Requires: moon, clang, and (on macOS) xcrun ld.
#
# Usage:  sh examples/selfhost/build-qbe-with-qiang.sh [output-dir]
#
# Everything is written under .Qiang_build/ at the repository root (already in
# .gitignore); pass a directory to put it elsewhere.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
# vendor/qbe lives in the qbe.mbt checkout next to this repository.
qbe_dir="$QBE_DIR"
if [ -z "$qbe_dir" ]; then
  qbe_dir="$root/../qbe.mbt"
fi
qbe=$(cd "$qbe_dir" && pwd) || {
  echo "error: set QBE_DIR to the qbe.mbt checkout (it holds vendor/qbe)" >&2
  exit 1
}
out=${1:-"$root/.Qiang_build"}

exe=$(find "$root/_build" "$root/../_build" -name "qiang.exe" -type f 2>/dev/null | head -n 1)

say() { printf "%s\n" "$*"; }
die() { printf "error: %s\n" "$*" >&2; exit 1; }

command -v moon >/dev/null || die "moon is not on PATH"
command -v clang >/dev/null || die "clang is not on PATH"
[ -d "$qbe/vendor/qbe" ] || die "vendor/qbe is missing (run: git submodule update --init)"

say "== 1/4  building Qiang"
(cd "$root" && moon build --target native qiang >/dev/null)
[ -x "$exe" ] || die "Qiang was not built at $exe"

say "== 2/4  compiling vendor/qbe with Qiang"
rm -rf "$out"
mkdir -p "$out/obj"
# QBE includes its own headers through these paths; Qiang takes preprocessed
# input, so clang -E runs first (the documented split: external preprocessor,
# Qiang front end). Exactly the sources the QBE build uses, minus
# vendor/qbe/tools, which holds host build tools that are not part of qbe.
incs="-I $root/Qiang/include/qbe -I $root/vendor/qbe -I $root/vendor/qbe/amd64 -I $root/vendor/qbe/arm64 -I $root/vendor/qbe/rv64"
sources=$(ls "$qbe"/vendor/qbe/*.c "$qbe"/vendor/qbe/amd64/*.c "$qbe"/vendor/qbe/arm64/*.c "$qbe"/vendor/qbe/rv64/*.c)
n=0
for src in $sources; do
  obj=$(printf "%s" "$src" | sed "s|^$root/||; s|/|_|g; s|\.c$|.o|")
  clang -E -P -nostdinc $incs "$src" > "$out/obj/$obj.i" 2>/dev/null \
    || die "preprocessing failed: $src"
  "$exe" "$out/obj/$obj.i" -o "$out/obj/$obj" || die "Qiang failed: $src"
  n=$((n + 1))
done
say "    compiled $n translation units"

say "== 3/4  linking $out/qbe-Qiang"
if command -v xcrun >/dev/null 2>&1 && [ "$(uname -s)" = Darwin ]; then
  sdk=$(xcrun --show-sdk-path)
  xcrun ld -syslibroot "$sdk" -o "$out/qbe-Qiang" -lSystem "$out"/obj/*.o
elif [ "$(uname -s)" = Linux ]; then
  cc -o "$out/qbe-Qiang" "$out"/obj/*.o
else
  die "no linker recipe for this platform"
fi
[ -x "$out/qbe-Qiang" ] || die "link failed"

say "== 4/4  reference build and corpus comparison"
make -C "$qbe/vendor/qbe" >/dev/null 2>&1 || die "could not build vendor/qbe"
ref="$qbe/vendor/qbe/qbe"
[ -x "$ref" ] || die "reference qbe is missing"

# QBE stores its test files with CRLF line endings.
mkdir -p "$out/corpus"
for f in "$qbe"/vendor/qbe/test/*.ssa; do
  [ -f "$f" ] || continue
  tr -d "\r" < "$f" > "$out/corpus/$(basename "$f")"
done

# macOS has no timeout(1), so cap each run with a background watchdog: a
# few fixtures loop forever when a compiler has a bug, and the comparison must
# not hang on them.
run_limited() {
  ( "$1" "$2" > "$out/.run.out" 2>&1 ) &
  p=$!
  ( sleep 8; kill -9 "$p" 2>/dev/null ) &
  w=$!
  wait "$p" 2>/dev/null
  rc=$?
  kill "$w" 2>/dev/null
  cat "$out/.run.out"
  return $rc
}

same=0
diffn=0
total=0
for f in "$out"/corpus/*.ssa; do
  [ -f "$f" ] || continue
  total=$((total + 1))
  # Both compilers may reject a fixture (some expect an error); the full
  # output, diagnostics included, has to match either way.
  a=$(run_limited "$ref" "$f" || true)
  b=$(run_limited "$out/qbe-Qiang" "$f" || true)
  if [ "$a" = "$b" ]; then
    same=$((same + 1))
  else
    diffn=$((diffn + 1))
    say "    DIFFER $(basename "$f")"
  fi
done

say ""
say "artifacts:      $out/qbe-Qiang"
say "test corpus:    $same identical, $diffn differing, $total total"
[ "$diffn" -eq 0 ] || exit 1
say "OK: the Qiang-built qbe matches the reference on every fixture"
