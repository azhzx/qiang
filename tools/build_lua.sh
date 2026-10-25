#!/bin/sh
# Build Lua 5.5.1 with Qiang.
#
#   sh tools/build_lua.sh          # fetch the source once, then build
#   sh tools/build_lua.sh --clean  # rebuild every object from scratch
#
# Output: build/lua/lua   (the interpreter; no arguments starts a REPL)
#         build/lua/luac  (bytecode compiler; luac -l -p f.lua lists the bytecode)
#
# Qiang has no preprocessor of its own, so each file goes through
# clang -E -P first; parsing, semantic analysis and code generation are all
# done by Qiang. The bundled headers under Qiang/include/qbe are passed with -I
# and deliberately shadow the system ones.
set -e

repo=$(cd "$(dirname "$0")/.." && pwd)
work=$repo/build/lua
src=$work/lua-5.5.1
out=$work/obj
Qiang=$repo/_build/native/debug/build/qiang/cmd.exe

# Prefer Apple's clang: a conda clang on PATH passes -lto_library to the system
# ld, which rejects it ("must be libLTO.dylib").
if [ -z "$CC" ]; then
  if [ -x /usr/bin/clang ]; then CC=/usr/bin/clang; else CC=cc; fi
fi

clean=0
[ "$1" = "--clean" ] && clean=1

if [ ! -x "$Qiang" ]; then
  echo "building Qiang..."
  ( cd "$repo" && moon build --target native qiang )
fi

if [ ! -d "$src/src" ]; then
  echo "fetching lua-5.5.1..."
  mkdir -p "$work"
  ( cd "$work" && curl -fsSLO https://www.lua.org/ftp/lua-5.5.1.tar.gz \
      && tar xzf lua-5.5.1.tar.gz && rm -f lua-5.5.1.tar.gz )
fi

if [ "$clean" = 1 ]; then rm -rf "$out"; fi
mkdir -p "$out/tmp"

n=0
for f in "$src"/src/*.c; do
  base=$(basename "$f" .c)
  if [ -f "$out/$base.o" ]; then n=$((n + 1)); continue; fi
  clang -E -P -I "$repo/Qiang/include/qbe" -I "$src/src" "$f" > "$out/tmp/$base.i"
  "$Qiang" "$out/tmp/$base.i" -std=c11 -o "$out/$base.o" > /dev/null
  n=$((n + 1))
done
echo "compiled $n files with Qiang"

ls "$out"/*.o | grep -v "/luac\.o$" | tr "\n" " " > "$out/tmp/lua.list"
# shellcheck disable=SC2046
"$CC" $(cat "$out/tmp/lua.list") -lm -o "$work/lua"
ls "$out"/*.o | grep -v "/lua\.o$" | tr "\n" " " > "$out/tmp/luac.list"
"$CC" $(cat "$out/tmp/luac.list") -lm -o "$work/luac"

echo "built:"
"$work/lua" -v
echo "  $work/lua    (interpreter; run it with no arguments for a REPL)"
echo "  $work/luac   (bytecode compiler; luac -l -p file.lua lists the bytecode)"