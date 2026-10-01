/* A 32-bit word widened to 64 bits must keep its value: Extsw for a signed
   source, Extuw for an unsigned one.  Using Extsw for both turned
   (long long)(unsigned)0x80000000 into -2147483648, which is what made the
   self-hosted qbe fold `sar 2147483648, 31` to 1 instead of -1. */
typedef unsigned int uint;

static int bad;

static void ck(long long got, long long want) {
  if (got != want) {
    bad = 1;
  }
}

static long long zexd(uint u) { return (long long)u; }
static long long sext(uint u) { return (long long)(int)u; }

int main(void) {
  uint u = 0x80000000u;
  uint v = 0x7fffffffu;

  ck((long long)u, 2147483648LL);
  ck((long long)(int)u, -2147483648LL);
  ck((long long)v, 2147483647LL);

  ck(zexd(u), 2147483648LL);
  ck(sext(u), -2147483648LL);
  ck(zexd(v), 2147483647LL);

  /* the fold.c shape */
  ck(((long long)u) >> 31, 1LL);
  ck(((long long)(int)u) >> 31, -1LL);

  /* unsigned arithmetic must not become signed either */
  ck((long long)(u >> 31), 1LL);
  ck((long long)(u / 2u), 1073741824LL);
  ck((long long)(u % 7u), 2147483648LL % 7LL);

  return bad;
}

