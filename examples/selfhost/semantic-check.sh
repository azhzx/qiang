#!/bin/sh
# Semantic check of the Qiang-built qbe.
#
# The byte-for-byte comparison in build-qbe-with-Qiang.sh says "the two
# compilers emit the same assembly". That is a stricter question than the one
# that matters, and a compiler that emits different but equally correct code
# fails it. This script asks the question that matters instead:
#
#   build each fixture with both qbe binaries, assemble and link each result
#   with the driver the fixture carries, run it, and compare the run against
#   the output the fixture says it should produce.
#
# Modeled on vendor/qbe/tools/test.sh. On Apple Silicon the two compilers
# default to amd64_sysv, so the assembly is x86-64 and the runner needs
# -arch x86_64 (Rosetta).
#
# Usage: sh examples/Qiang-selfhost/semantic-check.sh [fixture ...]
set -u

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

ref=${QBE_REF:-"$qbe/vendor/qbe/qbe"}
new=${QBE_NEW:-"$root/.Qiang_build/qbe-Qiang"}
[ -x "$ref" ] || { echo "missing reference qbe: $ref" >&2; exit 1; }
[ -x "$new" ] || { echo "missing Qiang qbe (run build-qbe-with-Qiang.sh first): $new" >&2; exit 1; }

cc="cc"
target="arm64_apple"
# arm64_apple is the only target whose assembly this machine can both
# assemble and run: the default amd64_sysv emits Linux x86-64.
arch=""

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

extract() {
  awk -v w="$1" '$0 ~ "^# >>> " w { p = 1; next } /^# <<</ { p = 0 } p' "$2" \
    | sed -e 's/# //' -e 's/#$//'
}

# build_run <qbe> <fixture> <tag> <outdir>; echoes "rc<TAB>output"
build_run() {
  qbe=$1; f=$2; tag=$3; d=$4
  mkdir -p "$d"
  # the compiler itself can hang on a fixture, so cap it here too
  ( "$qbe" -t $target "$f" > "$d/$tag.s" 2>"$d/$tag.err" ) & cp=$!
  ( sleep 20; kill -9 $cp 2>/dev/null ) & cw=$!
  wait $cp 2>/dev/null; crc=$?
  kill $cw 2>/dev/null
  if [ $crc -ne 0 ]; then

    printf "COMPILE-FAIL(rc=%s)\t%s\n" "$crc" "$(head -1 "$d/$tag.err")"
    return
  fi
  extract driver "$f" > "$d/$tag.drv.c"
  extract output "$f" > "$d/$tag.want"
  if [ -s "$d/$tag.drv.c" ]; then src="$d/$tag.drv.c $d/$tag.s"; else src="$d/$tag.s"; fi
  if ! $cc $arch -w -o "$d/$tag.exe" $src 2>"$d/$tag.cerr"; then
    printf "LINK-FAIL\t%s\n" "$(head -1 "$d/$tag.cerr")"
    return
  fi
  ( "$d/$tag.exe" a b c > "$d/$tag.out" 2>&1 ) & p=$!
  ( sleep 8; kill -9 $p 2>/dev/null ) & w=$!
  wait $p 2>/dev/null; rc=$?
  kill $w 2>/dev/null
  printf "%s\t%s\n" "$rc" "$(cat "$d/$tag.out")"
}

both_ok=0; ref_ok=0; new_ok=0; neither=0; skipped=0; total=0
strong=0; agreeonly=0
printf "%-14s %-8s %-8s %s\n" fixture ref new note
if [ "$#" -gt 0 ]; then
  selected=$*
  set --
  for b in $selected; do
    f="$qbe/vendor/qbe/test/$b.ssa"
    [ -f "$f" ] || { echo "missing fixture: $b" >&2; exit 1; }
    set -- "$@" "$f"
  done
else
  set -- "$qbe"/vendor/qbe/test/[!_]*.ssa
fi
for f do
  b=$(basename "$f" .ssa)
  # QBE's own suite marks the fixtures that do not apply to a target with a
  # "# skip <targets>" first line.  dark.ssa does exactly that for arm64_apple,
  # and the reference build crashes on it too, so running it here would charge
  # the self-hosted build for a test that was never meant to run on this
  # target.  Honor the directive the way vendor/qbe/tools/test.sh does.
  skip=$(head -1 "$f" | tr -d '\r')
  case "$skip" in
    "# skip"*)
      skipit=no
      for t in ${skip#\# skip}; do
        [ "$t" = "$target" ] && skipit=yes
      done
      if [ "$skipit" = yes ]; then
        skipped=$((skipped + 1))
        printf "%-14s %-8s %-8s %s\n" "$b" "-" "-" "skipped: fixture skips $target"
        continue
      fi
      ;;
  esac
  total=$((total + 1))
  f="$f"
  # the fixtures are CRLF
  fixture="$work/$b.ssa"
  tr -d '\r' < "$f" > "$fixture"
  want=$(extract output "$fixture")
  r=$(build_run "$ref" "$fixture" ref "$work/$b.r"); rr=${r%%	*}
  n=$(build_run "$new" "$fixture" new "$work/$b.n"); nr=${n%%	*}
  ro=${r#*	}; no=${n#*	}
  rok=no; nok=yes; nok=no
  # 43 of the 59 fixtures carry no "# >>> output" block.  Judging those on
  # "the program exited 0" alone accepts a self-hosted build that runs but
  # computes something else, so require the two builds to agree on what the
  # program printed as well.
  if [ -n "$want" ]; then
    [ "$ro" = "$want" ] && rok=yes
    [ "$no" = "$want" ] && nok=yes
    strong=$((strong + 1))
    crit="declared output"
  else
    if [ "$ro" = "$no" ]; then
      [ "$rr" = "0" ] && rok=yes
      [ "$nr" = "0" ] && nok=yes
    fi
    agreeonly=$((agreeonly + 1))
    crit="output agreement"
  fi
  note=""
  case "$rok:$nok" in
    yes:yes) both_ok=$((both_ok + 1)); note="both correct" ;;
    yes:no)  ref_ok=$((ref_ok + 1));  note="only reference correct" ;;
    no:yes)  new_ok=$((new_ok + 1));  note="ONLY Qiang CORRECT" ;;
    no:no)   neither=$((neither + 1)); note="rc=$rr/$nr out-agree=$([ "$ro" = "$no" ] && echo yes || echo no) [$crit]" ;;
  esac
  [ "$rok" = yes ] && [ "$nok" = yes ] && note="both correct [$crit]"
  printf "%-14s %-8s %-8s %s\n" "$b" "$rok" "$nok" "$note"
done

echo
echo "total $total: both correct $both_ok, only reference $ref_ok, only Qiang $new_ok, neither $neither, skipped $skipped"
echo "  criterion strength: declared output $strong, reference/self-hosted output agreement $agreeonly"
