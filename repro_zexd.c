typedef unsigned int uint;
int printf(char *, ...);

static int bad;
static void ck(long long got, long long want, char *what) {
  if (got != want) { printf("FAIL %s: got=%lld want=%lld\n", what, got, want); bad = 1; }
  else printf("ok   %s = %lld\n", what, got);
}

static long long f_sext(uint u) { return (long long)(int)u; }
static long long f_zexd(uint u) { return (long long)(uint)u; }

int main(void) {
  uint u = 0x80000000u;
  ck((long long)(uint)u, 2147483648LL, "cast uint to ll");
  ck((long long)(int)u, -2147483648LL, "cast int to ll");
  ck(f_zexd(u), 2147483648LL, "zexd helper");
  ck(f_sext(u), -2147483648LL, "sext helper");
  ck(((long long)(uint)u) >> 31, 1LL, "zexd shr 31");
  ck(((long long)(int)u) >> 31, -1LL, "sext shr 31");
  if (!bad) printf("all ok\n");
  return bad;
}

