typedef unsigned int uint;
typedef unsigned long ulong;
typedef long long llong;
int printf(char *, ...);

static int bad;
static void ck(long long got, long long want, char *what) {
  if (got != want) { printf("%s got=%lld want=%lld\n", what, got, want); bad = 1; }
}

static long long sar64(long long x, int y) { return x >> (y & 63); }
static int      sar32(int x, int y)       { return x >> (y & 31); }

int main(void) {
  long long x;
  int a, b;

  /* the shape fold.c uses on a 32-bit constant held in a 64-bit word */
  x = (long long)0x80000000LL;
  ck(x >> 31, -1LL, "ll 0x80000000 >> 31");

  x = (llong)(uint)2147483648u;
  ck(x >> 31, -1LL, "sext(0x80000000) >> 31");

  ck(sar64(0x80000000LL, 31), -1LL, "sar64");

  a = (int)0x80000000u;
  b = 31;
  ck((long long)(a >> b), -1LL, "int sar");

  ck((long long)((int)0x80000000u >> 31), -1LL, "inline int sar");
  ck((long long)((uint)0x80000000u >> 31), 1LL,  "uint shr (control)");
  ck(((long long)(uint)0x80000000u) >> 31, 1LL,  "zexd then shr (control)");

  if (!bad) printf("all ok\n");
  return bad;
}

