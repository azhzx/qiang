/* A word-width fold whose value has the top bit set must not be used by a
   consumer that needs 64 bits: 0xFFFFFFFF is 4294967295 as a word but -1
   once sign-extended, and both uses share one constant.  This is the shape
   that made the self-hosted qbe emit mov w0,#-1 before a 64-bit store. */
typedef long long i64;

static i64 g;
static int w;

int main(void) {
  /* word fold with a wide consumer: the store must widen */
  g = -1;
  if (g != -1) return 1;

  /* the same constant feeding a word consumer must still be a word */
  w = -1;
  if (w != -1) return 2;
  if ((unsigned)w != 4294967295u) return 3;

  /* positive word folds are unaffected */
  if ((i64)(2000000000 + 2000000000) != 4000000000LL) return 4;

  /* a wide fold keeps its own con */
  if ((i64)-1 != -1LL) return 5;
  return 0;
}
