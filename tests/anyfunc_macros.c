// expect-exit 0
// std=cqe
// N3914's convertibility macros. QPCC predefines them (C2y and CQE); clang
// does not know them, which is why this fixture is QPCC-only.
#include <function_pointer.h>

static int seven(int v) { return v + 7; }

int main(void) {
  if (!__STDC_PTR_CONV_ANY_FUNC_TO_VOID__) return 1;
  if (!__STDC_PTR_CONV_VOID_TO_ANY_FUNC__) return 2;
  if (!__STDC_PTR_CONV_FUNC_TO_VOID__) return 3;
  if (!__STDC_PTR_CONV_VOID_TO_FUNC__) return 4;

  /* The storage type round trips through void *. */
  function_pointer any = seven;
  void *vp = any;
  function_pointer back = vp;
  int (*fp)(int) = back;
  if (fp(0) != 7) return 5;

  /* ... and so does a concrete function pointer. */
  void *vp2 = (void *)seven;
  int (*fp2)(int) = (int (*)(int))vp2;
  return fp2(1) == 8 ? 0 : 6;
}
