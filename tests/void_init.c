// expect-exit 0
// std=cqe
// QPCC: `void x = f();` evaluates the call and declares nothing, so the
// variable never reaches the local table.
static int calls = 0;

static void bump(int n) { calls += n; }

static int twice(int v) { return v * 2; }

int main(void) {
  void a = bump(3);
  void b = bump(4);
  if (calls != 7) return 1;

  // The declared name is not an object, so it cannot be read back.
  void c = (void)twice(21);
  if (calls != 7) return 2;

  // A void initializer may also be a plain expression with no effect.
  void d = 1 + 1;
  if (calls != 7) return 3;
  return 0;
}
