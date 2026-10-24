// std=cqe
// A goto that jumps into the body of a do-while loop (dash's setjobctl does
// this). simplcfg folds a block into its single-predecessor successor and
// rewrites the phi arguments of that successor's successors; when the merges
// chain, an argument could still name a block that no longer existed, and the
// SSA checker then rejected the function with "violates ssa invariant".
int g(int x) {
  int p = -1;
  if (x) {
    if (x > 3) goto out;
    do {
      if ((p = x) < 0) {
out:
        if (x == 2) break;
        return p;
      }
      if (p == 1) break;
      x = x + 1;
    } while (1);
  }
  return p;
}

int main(void) {
  if (g(1) != 1) return 1;
  if (g(4) != -1) return 2;
  return 0;
}
