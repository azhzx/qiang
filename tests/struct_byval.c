// 16-byte structs passed and returned by value. A float in the second
// eightbyte used to be constant-folded to 0 by gvn (Con.bits is a union in
// the reference, separate fields here).
struct SI {
  int i;
  double d;
};
struct SD {
  double a;
  double b;
};
struct S4 {
  int a, b, c, d;
};

static double take_id(struct SI s) { return s.d; }
static double take_dd(struct SD s) { return s.b; }
static int take_4i(struct S4 s) { return s.d; }

static struct SI make_id(int i, double d) {
  struct SI s;
  s.i = i;
  s.d = d;
  return s;
}

int main(void) {
  struct SI a;
  a.i = 1;
  a.d = 9.25;
  if (take_id(a) != 9.25) return 1;

  struct SD b;
  b.a = 1.5;
  b.b = 2.5;
  if (take_dd(b) != 2.5) return 2;

  struct S4 c;
  c.a = 1;
  c.b = 2;
  c.c = 3;
  c.d = 4;
  if (take_4i(c) != 4) return 3;

  struct SI r = make_id(7, 0.5);
  if (r.i != 7 || r.d != 0.5) return 4;
  return 0;
}
