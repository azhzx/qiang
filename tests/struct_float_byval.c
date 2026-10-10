// Regression: a float member of a struct passed by value used to be read with
// the wrong bits - the slot promotion turned `%t =s load` into a copy instead
// of a cast, and the load-elimination fold then read `bits.i` of a float
// constant (0) rather than its raw bits.
struct F { float f; };
struct S { int i; float f; };
struct T { int i; float f; long l; };

static double get_f(struct F s) { return s.f; }
static double get_sf(struct S s) { return s.f; }
static double get_tf(struct T s) { return s.f; }

int main(void) {
  struct F a = { .f = 3.14f };
  struct S b = { .i = 7, .f = 2.5f };
  struct T c = { .i = 9, .f = 1.25f, .l = 11 };

  if (get_f(a) != (double)3.14f) return 1;
  if (get_sf(b) != 2.5) return 2;
  if (b.i != 7) return 3;
  if (get_tf(c) != 1.25) return 4;
  if (c.i != 9 || c.l != 11) return 5;

  /* A float constant's raw bits, chained through a cast and an extend. */
  float f = 3.14f;
  unsigned w = *(unsigned *)&f;
  if (w != 0x4048F5C3u) return 6;
  long l = (long)w;
  if (l != 1078530011L) return 7;

  return 0;
}
