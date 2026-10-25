// std=c2y
#include <stdio.h>
#include <stdcountof.h>
#include <stddefer.h>
#include <stdmaxof.h>
#include <stdminof.h>

int main(void) {
  int xs[6] = { 3, 1, 4, 1, 5, 9 };

  printf("countof(xs)   = %d\n", (int)countof(xs));
  printf("_Maxof(int)   = %d\n", (int)_Maxof(int));
  printf("_Minof(short) = %d\n", (int)_Minof(short));
  printf("maxof(int)    = %d\n", (int)maxof(int));
  printf("minof(short)  = %d\n", (int)minof(short));

  int first_dup = -1;
  outer:
  for (int i = 0; i < (int)countof(xs); i++) {
    for (int j = i + 1; j < (int)countof(xs); j++) {
      if (xs[i] == xs[j]) {
        first_dup = xs[i];
        break outer;
      }
    }
  }
  printf("first dup     = %d\n", first_dup);

  {
    defer { printf("cleanup A\n"); }
    defer { printf("cleanup B\n"); }
    printf("body\n");
  }
  return 0;
}
