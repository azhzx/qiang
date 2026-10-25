#!/bin/sh
# Qiang C example runner: a thin wrapper over `Qiang run`, which preprocesses
# with clang, compiles with Qiang, links with clang and runs the program.
#
#   sh examples/c/run.sh                       # every bundled example
#   sh examples/c/run.sh hello.c               # one example
#   sh examples/c/run.sh -std=c2y lambda.c     # flags go to `Qiang run`
#   sh examples/c/run.sh args.c -- 1 2         # ... and after -- to the program
#
# Nothing is sniffed out of the sources: the flags an example needs are either
# given on the command line or listed in the table below, which is only used by
# the "run everything" pass. A relative source path is resolved against the
# caller's directory and then against this one.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
exe=$(find "$root/_build" "$root/../_build" -name "qiang.exe" -type f 2>/dev/null | head -n 1)
caller=$PWD

# `moon run` would re-print the compiler's build warnings on every example, so
# build once quietly and drive the binary, the way Qiang/test.sh does.
( cd "$root" && moon build --target native qiang >/dev/null 2>&1 )

if [ ! -x "$exe" ]; then
  echo "run.sh: Qiang was not built at $exe" >&2
  exit 1
fi

# Qiang is run from the repository root so it finds Qiang/include/qbe.
run_Qiang() {
  ( cd "$root" && "$exe" run "$@" )
}

# The flags each bundled example needs. Listed explicitly, so a change here is
# visible instead of hidden in a comment at the top of a source file.
flags_for() {
  case "$(basename "$1")" in
    lambda.c | taggedunion.c | onestop.c | template.c | function_pointer.c | rec_lambda.c | z.c)
      printf '%s' "-std=cqe"
      ;;
    fib.c | c2y.c) printf '%s' "-std=c2y" ;;
    *) printf '%s' "" ;;
  esac
}

run_one() {
  src=$1
  shift
  echo "=== $(basename "$src" .c) ==="
  # shellcheck disable=SC2086
  set +e
  run_Qiang $(flags_for "$src") "$src" -- "$@"
  rc=$?
  set -e
  echo "(exit $rc)"
  echo
  return $rc
}

# No arguments: run every *.c in this directory with the flags from the table.
if [ "$#" -eq 0 ]; then
  # A failing example must fail the run, or "run everything" is a green gate
  # that hides exactly what it exists to catch.
  fails=0
  for c in "$here"/*.c; do
    run_one "$c" || fails=$((fails + 1))
  done
  if [ "$fails" -ne 0 ]; then
    echo "run.sh: $fails example(s) failed" >&2
    exit 1
  fi
  exit 0
fi

# Leading options are passed through as written; the first argument that is not
# an option is the source.
opts=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -*) opts="$opts $1" ; shift ;;
    *) break ;;
  esac
done
src=""
if [ "$#" -gt 0 ] && [ "$1" != "--" ]; then
  src=$1
  shift
fi
if [ -z "$src" ]; then
  echo "run.sh: no source file" >&2
  exit 1
fi
if [ ! -f "$src" ] && [ -f "$caller/$src" ]; then
  src="$caller/$src"
fi
if [ ! -f "$src" ] && [ -f "$here/$src" ]; then
  src="$here/$src"
fi
if [ ! -f "$src" ]; then
  echo "run.sh: no such file: $src" >&2
  exit 1
fi

# shellcheck disable=SC2086
run_Qiang $opts "$src" "$@"
