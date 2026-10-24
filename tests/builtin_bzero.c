// std=cqe
// __builtin_bzero is Darwin's inline for bzero; without the rewrite it stayed
// an undefined symbol and the link failed (abduco/join.c uses it on fd_sets).
#include <string.h>

struct big {
  int a[16];
};

int main(void) {
  struct big b;
  b.a[3] = 42;
  __builtin_bzero(&b, sizeof(b));
  for (int i = 0; i < 16; i++) {
    if (b.a[i] != 0) {
      return 1;
    }
  }
  return 0;
}
