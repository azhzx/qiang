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

static int Result_([int, int])_is_ok(Result_([int, int]) r) {
  return r.ok != 0;
}

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

  /* A compound literal, with and without the usual parentheses: the `_([`
     shape cannot start anything else, so the parentheses are optional. */
  auto e = Result_([int, int]) { .ok = 11 };
  if (e.ok != 11) return 6;
  auto f = (Result_([int, int])){ .ok = 12 };
  if (f.ok != 12) return 7;

  /* Identifier characters glued to the instantiation join the name, so one
     instantiation can carry a family of associated declarations. */
  if (!Result_([int, int])_is_ok(d)) return 8;
  Result_([int, int]) zero = { .ok = 0 };
  if (Result_([int, int])_is_ok(zero)) return 9;

  return 0;
}
