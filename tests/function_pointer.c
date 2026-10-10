// expect-exit 0
// std=cqe
// <function_pointer.h>: the _Function_pointer prefix form for a typed function
// pointer, and the bare form for the any-function-pointer storage type.
#include <function_pointer.h>

static int add1(int v) { return v + 1; }
static int twice(int v) { return v * 2; }
static int neg(int v) { return -v; }
static int apply(int (*f)(int), int v) { return f(v); }

/* Typed form: the return type and the parameter list come first. */
function_pointer int (int) g_typed = add1;

/* The any-function-pointer storage type. */
function_pointer g_any = neg;

int main(void) {
  /* function_pointer T (params) is exactly T (*)(params). */
  function_pointer int (int) p = add1;
  if (p(1) != 2) return 1;
  if (g_typed(41) != 42) return 2;

  /* The classic spelling is the same type. */
  int (*q)(int) = twice;
  if (q(3) != 6) return 3;
  function_pointer int (int) r = q;
  if (r(3) != 6) return 4;

  /* The typed form is accepted where a function pointer is expected. */
  if (apply(p, 1) != 2) return 5;

  /* Any function pointer stores into the bare form and comes back out. */
  function_pointer a = p;
  function_pointer b = q;
  function_pointer c = g_any;
  if ((a == b) || (a == c) || (b == c)) return 6;

  int (*back)(int) = a;
  if (back(1) != 2) return 7;
  int (*back2)(int) = (function_pointer int (int))b;
  if (back2(3) != 6) return 8;
  int (*back3)(int) = c;
  if (back3(3) != -3) return 9;

  /* void * round trip goes through the storage type. */
  void *vp = a;
  function_pointer vq = vp;
  int (*back4)(int) = vq;
  if (back4(10) != 11) return 10;

  /* N3914 4.6: _Generic must not confuse the storage type with a real
     function pointer type. */
  if (_Generic(p, int (*)(int): 1, function_pointer: 2, default: 0) != 1)
    return 11;
  if (_Generic(a, int (*)(int): 1, function_pointer: 2, default: 0) != 2)
    return 12;

  /* Arrays of them. */
  function_pointer int (int) table[2] = { add1, twice };
  if (table[0](1) != 2) return 13;
  if (table[1](3) != 6) return 14;

  return 0;
}
