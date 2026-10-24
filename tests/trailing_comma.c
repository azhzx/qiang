// std=cqe
// expect-exit 0
// QPCC extension: a trailing comma is accepted before the closing delimiter of
// any comma separated list. Plain C only allows it in initialiser lists and
// enum bodies, so this fixture is QPCC-only (it cannot be compared with clang).
int add3(int a, int b, int c,) { return a + b + c; }

int take(int, int,);

int (*fp)(int, int, int,) = 0;

enum E { A, B, };

struct P {
  int x;
  int y;
};

int main(void) {
  int arr[] = {1, 2, 3,};
  int *p = (int[]){4, 5,};
  struct P s = {.x = 1, .y = 2,};
  int n = take(add3(1, 2, 3,), 4,);
  (void)fp;
  (void)p;
  if (arr[2] != 3) return 1;
  if (p[1] != 5) return 2;
  if (s.y != 2) return 3;
  if (n != 0) return 4;
  if (B != 1) return 5;
  return 0;
}

int take(int a, int b,) { (void)b; return 0; }
