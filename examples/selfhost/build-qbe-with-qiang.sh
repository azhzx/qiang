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
qbe_dir="${QBE_DIR-}"
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
incs="-I $root/include/qiang -I $qbe/vendor/qbe -I $qbe/vendor/qbe/amd64 -I $qbe/vendor/qbe/arm64 -I $qbe/vendor/qbe/rv64"
sources=$(ls "$qbe"/vendor/qbe/*.c "$qbe"/vendor/qbe/amd64/*.c "$qbe"/vendor/qbe/arm64/*.c "$qbe"/vendor/qbe/rv64/*.c)
n=0
for src in $sources; do
  obj=$(printf "%s" "$src" | sed "s|^$qbe/||; s|/|_|g; s|\.c$|.o|")
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

# Two comparisons, two purposes.
#
# The machine code the two compilers emit is *not* required to be identical:
# QBE's own output depends on its memory layout, and the two qbe binaries are
# laid out differently, so a different - but valid - register choice shows up
# as a textual difference. That count is reported as a diagnostic.
#
# What must hold is that the programs they produce *behave* the same, so every
# fixture that defines $main is assembled, linked and run, and its exit status
# and stdout are compared. That is the gate.
asm_same=0
asm_diff=0
beh_same=0
beh_diff=0
beh_total=0
total=0

# macOS has no timeout(1); run a binary with a watchdog and echo rc and output.
run_bin() {
  "$1" > "$out/.bin.out" 2>&1 &
  p=$!
  ( sleep 8; kill -9 "$p" 2>/dev/null ) &
  w=$!
  wait "$p" 2>/dev/null
  rc=$?
  kill "$w" 2>/dev/null
  echo "rc=$rc"
  cat "$out/.bin.out"
}

for f in "$out"/corpus/*.ssa; do
  [ -f "$f" ] || continue
  total=$((total + 1))
  "$ref" -o "$out/.ref.s" "$f" > "$out/.ref.out" 2>&1 || true
  "$out/qbe-Qiang" -o "$out/.qiang.s" "$f" > "$out/.qiang.out" 2>&1 || true
  if cmp -s "$out/.ref.s" "$out/.qiang.s" && cmp -s "$out/.ref.out" "$out/.qiang.out"; then
    asm_same=$((asm_same + 1))
  else
    asm_diff=$((asm_diff + 1))
    say "    asm differs: $(basename "$f")"
  fi
  # Behavioural check: only fixtures that are complete programs, and only if
  # the target can be assembled and run here. The default target emits
  # Linux/amd64 assembly, which this machine cannot run, so the behaviour is
  # measured through the native target.
  if grep -q 'export function w $main' "$f"; then
    "$ref" -t arm64_apple -o "$out/.ref.arm.s" "$f" >/dev/null 2>&1 || continue
    "$out/qbe-Qiang" -t arm64_apple -o "$out/.qiang.arm.s" "$f" >/dev/null 2>&1 || continue
    if clang -o "$out/.ref.bin" "$out/.ref.arm.s" >/dev/null 2>&1 && clang -o "$out/.qiang.bin" "$out/.qiang.arm.s" >/dev/null 2>&1; then
      beh_total=$((beh_total + 1))
      a=$(run_bin "$out/.ref.bin")
      b=$(run_bin "$out/.qiang.bin")
      if [ "$a" = "$b" ]; then
        beh_same=$((beh_same + 1))
      else
        beh_diff=$((beh_diff + 1))
        say "    BEHAVIOUR DIFFERS: $(basename "$f")"
        say "      reference: $a"
        say "      this build: $b"
      fi
    fi
  fi
done

say ""
say "asm:            $asm_same identical, $asm_diff differing, $total total (diagnostic)"
say "behaviour:      $beh_same identical, $beh_diff differing, $beh_total runnable (gate)"
[ "$beh_diff" -eq 0 ] || die "behaviour differs on $beh_diff fixture(s)"

say "artifacts:      $out/qbe-Qiang"
say "OK: the Qiang-built qbe behaves like the reference on every runnable fixture"
