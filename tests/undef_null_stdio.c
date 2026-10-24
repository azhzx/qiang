// std=cqe
// dash's bltin/bltin.h does "#undef NULL" and then includes <stdio.h>, relying
// on <stdio.h> to define NULL again. qpcc's bundled stdio.h only pulled it in
// through <stddef.h>, whose include guard was already set, so NULL stayed
// undefined and dash's printf.c failed with "use of undeclared identifier:
// NULL".
#undef NULL
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(void) {
  char *p = NULL;
  if (p != NULL) {
    return 1;
  }
  return 0;
}
