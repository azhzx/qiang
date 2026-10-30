#!/bin/sh
# ABI interoperability matrix.
#
# A compiler is only usable industrially if its objects can be linked against
# objects another compiler produced, and against the C library. That is not the
# same question as 'does the compiler agree with itself', which is what the
# clang oracle tests. Every case below is compiled four ways and the program's
# output must match clang's in all four:
#
#   all-clang   lib=Qiang   main=Qiang   all-Qiang
#
# A row that fails the middle two columns is an ABI mismatch, not a bug in this
# project's own conventions.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
qiang=$(find "$here/_build" "$here/../_build" -name 'qiang.exe' -type f 2>/dev/null | head -n 1)
[ -n "$qiang" ] || { echo 'error: qiang.exe not built' >&2; exit 1; }
inc="$here/include/qiang"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/lib.c" <<'EOF'
#include <stdarg.h>
typedef struct { long a, b, c; } Big;
typedef struct { int x; double y; } Mix;
typedef struct { long a; } One;
typedef struct { double a, b; } Hfa;
long sum3(long a, long b, long c) { return a + b + c; }
Big bigmake(long a, long b, long c) { Big r = {a, b, c}; return r; }
Mix mixmake(int x, double y) { Mix m = {x, y}; return m; }
One onemake(long a) { One o = {a}; return o; }
Hfa hfamake(double a, double b) { Hfa h = {a, b}; return h; }
double vsum(int n, ...) { va_list ap; va_start(ap, n); double s = 0;
  for (int i = 0; i < n; i++) s += va_arg(ap, double); va_end(ap); return s; }
int apply(int (*f)(int), int v) { return f(v); }
long many(int a,int b,int c,int d,int e,int f,int g,int h,int i) {
  return a+b*2+c*3+d*4+e*5+f*6+g*7+h*8+i*9; }
EOF

cat > "$tmp/main.c" <<'EOF'
#include <stdio.h>
#include <stdarg.h>
typedef struct { long a, b, c; } Big;
typedef struct { int x; double y; } Mix;
typedef struct { long a; } One;
typedef struct { double a, b; } Hfa;
long sum3(long, long, long);
Big bigmake(long, long, long);
Mix mixmake(int, double);
One onemake(long);
Hfa hfamake(double, double);
double vsum(int, ...);
int apply(int (*)(int), int);
long many(int,int,int,int,int,int,int,int,int);
static int dbl(int v) { return v * 2; }
int main(int argc, char **argv) {
  char c = argc > 1 ? argv[1][0] : 'z';
  switch (c) {
  case 'a': printf("%ld\n", sum3(1,2,3)); break;
  case 'b': { Big b = bigmake(1,2,3); printf("%ld %ld %ld\n", b.a,b.b,b.c); break; }
  case 'c': { Mix m = mixmake(7,2.5); printf("%d %.1f\n", m.x, m.y); break; }
  case 'd': { One o = onemake(9); printf("%ld\n", o.a); break; }
  case 'e': { Hfa h = hfamake(1.5, 2.5); printf("%.1f %.1f\n", h.a, h.b); break; }
  case 'f': printf("%.1f\n", vsum(3, 1.0, 2.0, 3.5)); break;
  case 'g': printf("%d\n", apply(dbl, 21)); break;
  case 'h': printf("%ld\n", many(1,2,3,4,5,6,7,8,9)); break;
  }
  return 0;
}
EOF

clang -E -P -I "$inc" "$tmp/lib.c"  > "$tmp/lib.i"
clang -E -P -I "$inc" "$tmp/main.c" > "$tmp/main.i"
clang -w -c "$tmp/lib.c"  -o "$tmp/libc.o"
clang -w -c "$tmp/main.c" -o "$tmp/mainc.o"
"$qiang" "$tmp/lib.i"  -o "$tmp/libq.o"
"$qiang" "$tmp/main.i" -o "$tmp/mainq.o"

link() { o=$1; shift; clang "$@" -o "$o" 2>/dev/null; }
link "$tmp/allc"  "$tmp/libc.o"  "$tmp/mainc.o"
link "$tmp/libq"  "$tmp/libq.o"  "$tmp/mainc.o"
link "$tmp/mainq" "$tmp/libc.o"  "$tmp/mainq.o"
link "$tmp/allq"  "$tmp/libq.o"  "$tmp/mainq.o"

printf '%-4s %-16s %-16s %-16s %-16s\n' case all-clang lib=Qiang main=Qiang all-Qiang
fail=0
for c in a b c d e f g h; do
  ref=$("$tmp/allc" "$c" 2>/dev/null || echo CRASH)
  a=$("$tmp/libq" "$c" 2>/dev/null || echo CRASH)
  b=$("$tmp/mainq" "$c" 2>/dev/null || echo CRASH)
  d=$("$tmp/allq" "$c" 2>/dev/null || echo CRASH)
  mark() { [ "$1" = "$ref" ] && printf '%s' "$2" || printf '%s' 'MISMATCH'; }
  printf '%-4s %-16s %-16s %-16s %-16s\n' "$c" "$ref" "$(mark "$a" "$a")" "$(mark "$b" "$b")" "$(mark "$d" "$d")"
  [ "$a" = "$ref" ] && [ "$b" = "$ref" ] && [ "$d" = "$ref" ] || fail=$((fail + 1))
done

echo ""
if [ "$fail" -eq 0 ]; then
  echo "OK: every case agrees in all four builds"
else
  echo "$fail case(s) disagree across builds (ABI)"
  exit 1
fi