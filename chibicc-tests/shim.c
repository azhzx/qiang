// chibicc's tests call an `assert(expected, actual, code)` helper that lives in
// chibicc's own driver. The oracle links this file with every fixture so the
// same test can be built by clang and by Qiang and the two runs compared:
// printing every assertion makes a wrong value visible even when the exit code
// agrees.
#include <stdio.h>
#include <stdlib.h>

void assert(int expected, int actual, char *code) {
  if (expected == actual) {
    printf("%s => %d\n", code, actual);
  } else {
    printf("%s => %d expected but got %d\n", code, expected, actual);
    exit(1);
  }
}