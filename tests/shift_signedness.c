/* The signedness of a shift is decided by the left operand alone.  QPCC used
   to OR in the right operand's signedness, so `x >> (n & 31)` with an
   unsigned n compiled a signed x to a logical shift and produced
   0x1FFFFFFFF instead of -1.  This is the shape QBE's fold.c uses for its
   word-width arithmetic shift. */
typedef long long i64;
typedef unsigned long u64;

static i64 sar(i64 x, u64 n) { return x >> (n & 31); }
static i64 sar2(i64 x, u64 n, int w) { return x >> (n & (31 | (w << 5))); }
static i64 shr(u64 x, i64 n) { return (i64)(x >> (n & 31)); }

int main(void) {
  if (sar(-1LL, 31) != -1LL) return 1;
  if (sar2(-1LL, 31, 0) != -1LL) return 2;
  if (sar2(-1LL, 31, 1) != -1LL) return 3;
  if (sar(0x80000000LL >> 0, 31) != 0x80000000LL >> 31) return 4;
  /* a genuinely unsigned left operand still shifts logically */
  if (shr(0xFFFFFFFFFFFFFFFFUL, 31) != 0x1FFFFFFFFLL) return 5;
  if (sar(1024LL, 3) != 128LL) return 6;
  return 0;
}
