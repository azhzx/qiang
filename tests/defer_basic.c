// expect-exit 0
// std=c2y
// clang has not implemented TS 25755 defer yet, so this is QPCC-only.
static int order[8];
static int n;
static int note(int c) {
  order[n++] = c;
  return c;
}
static int f(void) {
  _Defer note(50);
  return 7;
}

int main() {
  /* LIFO within a block */
  n = 0;
  {
    _Defer note(1);
    _Defer note(2);
    note(3);
  }
  if (n != 3) return 1;
  if (order[0] != 3 || order[1] != 2 || order[2] != 1) return 2;

  /* break runs the loop body's defer */
  n = 0;
  for (int i = 0; i < 3; i++) {
    _Defer note(10 + i);
    if (i == 1) break;
  }
  if (n != 2 || order[0] != 10 || order[1] != 11) return 3;

  /* continue runs it too */
  n = 0;
  for (int i = 0; i < 3; i++) {
    _Defer note(20 + i);
    continue;
  }
  if (n != 3) return 4;
  if (order[0] != 20 || order[1] != 21 || order[2] != 22) return 5;

  /* goto out of a block runs its defers */
  n = 0;
  {
    _Defer note(30);
    goto out;
  }
out:
  if (n != 1 || order[0] != 30) return 6;

  /* nested frames run innermost first */
  n = 0;
  {
    _Defer note(40);
    {
      _Defer note(41);
      note(42);
    }
    note(43);
  }
  if (n != 4) return 7;
  if (order[0] != 42 || order[1] != 41 || order[2] != 43 || order[3] != 40) {
    return 8;
  }

  /* return runs the defer of the function body */
  n = 0;
  if (f() != 7) return 9;
  if (n != 1 || order[0] != 50) return 10;
  return 0;
}
