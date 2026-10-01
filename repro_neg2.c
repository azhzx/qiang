/* KNOWN FAILURE, kept on purpose.
 *
 * static long long g;  g = -1;
 *
 * The store lands 0x00000000FFFFFFFF instead of -1.  A local long long,
 * a static int, and a store from an int variable are all correct, so the
 * trigger is narrow: a negative int literal stored into static 64-bit
 * storage.
 *
 * The IR QPCC prints with --emit qbe is right (%t.2 =l extsw %t.1), and
 * six extensions lower to identical assembly in both compilers, so the
 * damage happens in the optimizer, which --emit qbe does not run.  The
 * emitted code is mov w0, #-1 / str x0, which is a 32-bit constant.
 */
typedef long long i64;
int printf(char *, ...);

static i64 g;                  /* file static 64-bit */
static int  gi;                /* file static 32-bit */
static int  w;                 /* file static 32-bit */

static int t1(void) { g = -1; return g == -1; }          /* static i64 <- -1 */
static int t2(void) { i64 x; x = -1; return x == -1; }    /* local i64 <- -1 */
static int t3(void) { w = -1; return w == -1; }           /* static int <- -1 */
static int t4(void) { g = gi; return g == -1; }           /* static i64 <- static int */
static int t5(void) { g = -1; return (int)g == -1; }      /* read back as int */

int main(void) {
  int bad = 0;
  gi = -1;
  if (!t1()) { printf("t1 static i64 = -1 FAILED\n"); bad = 1; }
  if (!t2()) { printf("t2 local i64 = -1 FAILED\n"); bad = 1; }
  if (!t3()) { printf("t3 static int = -1 FAILED\n"); bad = 1; }
  if (!t4()) { printf("t4 static i64 <- static int FAILED\n"); bad = 1; }
  if (!t5()) { printf("t5 FAILED\n"); bad = 1; }
  if (!bad) printf("all ok\n");
  return bad;
}

