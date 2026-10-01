/* Known failure, not part of the oracle.
 *
 * A call immediately followed by a pointer-walking nested loop comes out
 * wrong: the loop never terminates.  Replacing `abs(sz)` with the equivalent
 * `sz < 0 ? -sz : sz` makes it pass, and so does declaring abs explicitly, so
 * it is not about the declaration -- it is about a call sitting right before
 * the loop while a pointer into a static table is live across it.
 *
 * This is the shape of vendor/qbe/simpl.c:blit, which is where the
 * self-hosted qbe hangs on mem1.ssa and friends.
 *
 * Expected: exits 0.  Actual: the guard fires (exit 255 / never returns).
 */
int abs(int);

static int probe(int sz) {
  static int tbl[4] = { 8, 4, 2, 1 };
  int *p;
  int n, c = 0, off = 0, fwd;

  fwd = sz >= 0;
  sz = abs(sz);
  off = fwd ? sz : 0;
  for (p = tbl; sz; p++)
    for (n = p[0]; sz >= n; sz -= n) {
      off -= fwd ? n : 0;
      if (++c > 64)
        return -1;
      off += fwd ? 0 : n;
    }
  return (c == 3 && off == 11) ? 0 : 1;
}

int main(void) { return probe(-11) + probe(11); }
