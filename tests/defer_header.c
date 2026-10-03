// expect-exit 0
// std=c2y
// Uses the hand-written <stddefer.h> alias (defer -> _Defer), TS 25755.
#include <stddefer.h>

static int order[4];
static int n;

int main() {
  {
    defer { order[n++] = 1; }
    order[n++] = 2;
  }
  if (n != 2) return 1;
  if (order[0] != 2 || order[1] != 1) return 2;
  return 0;
}
