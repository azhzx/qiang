// expect-exit 0
// std=c2y
// A _Defer body may declare its own locals: they must be collected like any
// other block's (collect_locals used to skip KSDefer, so codegen aborted
// with "unbound local").
static int order[4];
static int n;

int main(void) {
  {
    _Defer {
      int t = 7;
      order[n++] = t;
    }
    order[n++] = 1;
  }
  if (n != 2) return 1;
  if (order[0] != 1 || order[1] != 7) return 2;

  n = 0;
  for (int i = 0; i < 2; i++) {
    _Defer {
      int u = 10 + i;
      order[n++] = u;
    }
  }
  if (n != 2) return 3;
  if (order[0] != 10 || order[1] != 11) return 4;
  return 0;
}
