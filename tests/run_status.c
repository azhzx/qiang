// expect-exit 7
// std=c2y
// `qpcc run` must forward the program's exit status, so this fixture returns
// 7 and the driver is expected to exit 7 as well.
#include <stdio.h>

int main(void) {
  printf("run-status\n");
  return 7;
}
