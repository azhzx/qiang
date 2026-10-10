// expect-exit 0
// std=c2y
// QPCC closures: _Lambda / the _Lambda T (params) type / _Closure_environment.
// The environment is a local of the enclosing function, so an escaping
// closure is undefined behaviour, as documented.

static int sink(int v) { return v; }

int main(void) {
  int a = 100;
  int b = 20;
  int c = 3;

  /* a by value, b by reference; the body sees a as int and b as int *. */
  auto f = _Lambda(a, &b) int (int x, int y) {
    return a + (*b) + x + y;
  };
  if (f(1, 2) != 123) return 1;
  /* A closure is an ordinary value and can be passed along. */
  if (sink(f(1, 2)) != 123) return 11;

  /* Two closures of the same signature are the same type. */
  _Lambda int (int, int) g = _Lambda(a, &c) int (int x, int y) {
    return x * y;
  };
  if (g(6, 7) != 42) return 2;

  /* Writing a by-value capture changes only the copy. */
  auto h = _Lambda(a) int (void) {
    a = 7;
    return a;
  };
  if (h() != 7) return 3;
  if (a != 100) return 4;

  /* Writing through a by-reference capture reaches the original, and the
     environment pointer names the captured field. */
  auto k = _Lambda(&b) int (void) {
    *b = *b + 5;
    return *b;
  };
  if (k() != 25) return 5;
  if (b != 25) return 6;

  int *pb = _Closure_environment(k)->b;
  if (*pb != 25) return 7;
  *pb = 99;
  if (b != 99) return 8;

  /* Copying a closure copies both words, so the copy still works. */
  _Lambda int (void) k2 = k;
  if (k2() != 104) return 9;
  if (b != 104) return 10;

  return 0;
}
