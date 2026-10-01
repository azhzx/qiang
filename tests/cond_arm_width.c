/* Both arms of a conditional expression must reach the join at the common
   type.  QPCC used to jump with the arm values unconverted, so an `int` arm
   of a `long long` conditional was read as a zero-extended word.  QBE's
   fold.c has exactly this shape: (w ? l.s : (int32_t)l.s). */
typedef long long i64;
typedef unsigned long u64;

static i64 pick(i64 a, int w) { return w ? a : (int)a; }
static i64 sar(i64 x, u64 n, int w) { return (w ? x : (int)x) >> (n & 31); }

int main(void) {
  if (pick(2147483648LL, 0) != -2147483648LL) return 1;
  if (pick(2147483648LL, 1) != 2147483648LL) return 2;
  if (sar(2147483648LL, 31, 0) != -1LL) return 3;
  if (sar(-1LL, 31, 1) != -1LL) return 4;
  if (sar(1024LL, 3, 1) != 128LL) return 5;
  /* a narrow arm widening to a wider common type */
  {
    int n = -1;
    i64 r = 1 ? n : 0LL;
    if (r != -1LL) return 6;
  }
  return 0;
}
