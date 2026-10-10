// expect-exit 0
// std=cqe
// QPCC pseudo-templates: Name_([T1, T2]) is an ordinary identifier spelled as
// the head plus a hash of the argument spelling, so the same instantiation
// names the same typedef in every translation unit. clang cannot read this,
// hence QPCC-only.
#include <taggedunion.h>

#define MkResult(T, E) typedef tagunion { T ok; E err; } Result_([T, E]);

MkResult(int, int)
MkResult(int, float)
/* Repeating an instantiation must reuse the first definition, not build a
   second layout, or uses on either side of it would not match. */
MkResult(int, int)

int main(void) {
  Result_([int, int]) a = { .ok = 100 };
  Result_([int, float]) b = { .err = 1.5f };
  Result_([int, int]) c = a;

  if (c.ok != 100) return 1;
  if (b.err != 1.5f) return 2;
  if (dynamic_tag(a) != static_tag(Result_([int, int]), ok)) return 3;
  if (dynamic_tag(b) != static_tag(Result_([int, float]), err)) return 4;

  /* the arguments are matched by spelling, so a pointer is distinct */
  Result_([int, int]) d = { .ok = 7 };
  Result_([int, int]) *pd = &d;
  if (pd->ok != 7) return 5;

  return 0;
}
