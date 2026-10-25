#include <stdio.h>
#include <lambda.h>

/*
 *     Z = Lf. (Lx. f (Lv. x x v)) (Lx. f (Lv. x x v))
 */

typedef lambda int (int) IntFn;
typedef lambda int (IntFn, int) Step;


typedef lambda int (void *, void *, int) XFn;

static int x_apply(XFn *self, Step *f, int n) {
  auto rec = lambda (self, f) int (int v) { return x_apply(self, f, v); };
  return (*f)(rec, n);
}

int main(void) {
  XFn x = lambda () int (void *self, void *f, int n) {
    return x_apply((XFn *)self, (Step *)f, n);
  };
  Step fact_step = lambda () int (IntFn rec, int n) {
    return n <= 1 ? 1 : n * rec(n - 1);
  };
  auto fact = lambda (&x, &fact_step) int (int n) {
    return x_apply(x, fact_step, n);
  };

  Step fib_step = lambda () int (IntFn rec, int n) {
    return n < 2 ? n : rec(n - 1) + rec(n - 2);
  };
  auto fib = lambda (&x, &fib_step) int (int n) {
    return x_apply(x, fib_step, n);
  };

  printf("fact(5) = %d\n", fact(5));
  printf("fact(10) = %d\n", fact(10));
  printf("fib(10) = %d\n", fib(10));
  printf("fib(15) = %d\n", fib(15));

  return fact(5) == 120 && fib(10) == 55 && fib(15) == 610 ? 0 : 1;
}
