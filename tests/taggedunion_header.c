// expect-exit 0
// std=c2y tagged
// <taggedunion.h>: the friendly spellings tagunion / static_tag / dynamic_tag
// over -f_tagged_union.
#include <taggedunion.h>

tagunion Value {
  int as_int;
  float as_float;
};

static int value_tag(tagunion Value v) {
  return (int)dynamic_tag(v);
}

int main(void) {
  _Static_assert(static_tag(tagunion Value, as_int) == 0, "as_int");
  _Static_assert(static_tag(tagunion Value, as_float) == 1, "as_float");

  tagunion Value v = { .as_int = 7 };
  if (dynamic_tag(v) != static_tag(tagunion Value, as_int)) return 1;
  if (v.as_int != 7) return 2;

  v = (tagunion Value){ .as_float = 2.5f };
  if (dynamic_tag(v) != 1) return 3;
  if (v.as_float != 2.5f) return 4;
  if (value_tag(v) != 1) return 5;

  switch (dynamic_tag(v)) {
    case 1: break;
    default: return 6;
  }
  return 0;
}
