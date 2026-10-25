#!/bin/sh
# Fetch the sibling qbe.mbt checkout that moon.work points at.
#
# Qiang depends on the qbe module through a workspace, and the workspace
# manifest refers to ../qbe.mbt, so a fresh clone needs that checkout next to
# this one before `moon build` can resolve the dependency.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
dep=$(cd "$here/../qbe.mbt" 2>/dev/null && pwd) || true

if [ -n "$dep" ] && [ -f "$dep/moon.mod" ]; then
  echo "qbe.mbt is already at $dep"
  exit 0
fi

url="${QBE_GIT_URL:-https://github.com/azhzx/qbe.mbt.git}"
echo "cloning $url into $here/../qbe.mbt"
git clone --depth 1 "$url" "$here/../qbe.mbt"
echo "done; now run: moon build --target native"