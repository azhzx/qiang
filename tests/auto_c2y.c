// expect-exit 0
// std=c2y
// C2y includes C23, so `auto` must infer the type here as well (the parser
// only rewrote it in C23 mode, leaving `auto x` as int in C2y).
struct S {
  int a;
  float f;
};

int main(void) {
  auto s = (struct S){ .a = 7 };
  if (s.a != 7) return 1;

  auto n = 5;
  if (n != 5) return 2;

  auto d = 1.5;
  if (d != 1.5) return 3;

  auto p = &s;
  if (p->a != 7) return 4;
  return 0;
}
