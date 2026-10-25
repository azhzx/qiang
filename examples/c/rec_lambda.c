#include <stdio.h>
#include <lambda.h>

typedef lambda int (int) IntFn;

int main(void) {
  IntFn self = { 0, 0 };


  auto fact = lambda (&self) int (int n) {
    return n <= 1 ? 1 : n * (*self)(n - 1);
  };
  self = fact;

  printf("fact(5) = %d\n", fact(5));
  printf("fact(10) = %d\n", fact(10));
  return 0;
}
