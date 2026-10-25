#!/bin/sh
# Quick self-host build: compile and link vendor/qbe with Qiang, without the
# corpus comparison that build-qbe-with-Qiang.sh runs afterwards.
#
# POSIX sh on purpose, so `sh`, `bash` and `zsh` all behave the same. Nothing
# here relies on arrays or on word splitting of an unquoted variable, because
# zsh does not split those by default.
#
# Usage:  sh examples/selfhost/build-qbe-with-qiang-no-test.sh [output-dir]
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
out=${1:-"$root/.Qiang_build-quick"}

exe=$(find "$root/_build" "$root/../_build" -name "qiang.exe" -type f 2>/dev/null | head -n 1)

command -v moon >/dev/null || { echo "error: moon is not on PATH" >&2; exit 1; }
command -v clang >/dev/null || { echo "error: clang is not on PATH" >&2; exit 1; }

echo "== building Qiang"
(cd "$root" && moon build --target native qiang >/dev/null)
[ -x "$exe" ] || { echo "error: Qiang was not built at $exe" >&2; exit 1; }

echo "== compiling vendor/qbe with Qiang"
rm -rf "$out"
mkdir -p "$out/obj"
sources=$(ls "$qbe"/vendor/qbe/*.c "$qbe"/vendor/qbe/amd64/*.c "$qbe"/vendor/qbe/arm64/*.c "$qbe"/vendor/qbe/rv64/*.c)
n=0
for src in $sources; do
  obj=$(printf "%s" "$src" | sed "s|^$root/||; s|/|_|g; s|\.c$|.o|")
  clang -E -P -nostdinc -I "$root/include/qiang" -I "$qbe/vendor/qbe" -I "$qbe/vendor/qbe/amd64" -I "$qbe/vendor/qbe/arm64" -I "$qbe/vendor/qbe/rv64" "$src" > "$out/obj/$obj.i"
  "$exe" "$out/obj/$obj.i" -o "$out/obj/$obj"
  n=$((n + 1))
done
echo "    compiled $n translation units"

echo "== linking $out/qbe"
if command -v xcrun >/dev/null 2>&1 && [ "$(uname -s)" = Darwin ]; then
  xcrun ld -syslibroot "$(xcrun --show-sdk-path)" -o "$out/qbe" -lSystem "$out"/obj/*.o
elif [ "$(uname -s)" = Linux ]; then
  cc -o "$out/qbe" "$out"/obj/*.o
else
  echo "error: no linker recipe for this platform" >&2
  exit 1
fi
[ -x "$out/qbe" ] || { echo "error: link failed" >&2; exit 1; }

echo "artifacts:      $out/qbe"
