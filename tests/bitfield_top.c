struct Ins { unsigned op:30; unsigned cls:2; };
struct S { unsigned a:2; unsigned b:30; };
int main() {
  struct Ins i;
  i.op = 106; i.cls = 2;
  if (i.op != 106) return 1;
  if (i.cls != 2) return 2;
  if ((int)i.cls != 2) return 3;
  int c = (int)i.cls;
  if (c != 2) return 4;
  i.cls = 3;
  if (i.cls != 3) return 5;
  i.cls = 0;
  if (i.cls != 0) return 6;
  struct S s;
  s.a = 2; s.b = 5;
  if (s.a != 2) return 7;
  if ((int)s.a != 2) return 8;
  if (s.b != 5) return 9;
  return 0;
}
