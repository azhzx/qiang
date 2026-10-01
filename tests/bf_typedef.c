typedef unsigned int uint;
struct A { uint op:30; uint cls:2; };
struct B { unsigned int op:30; unsigned int cls:2; };
struct D { unsigned op:30; unsigned cls:2; };
int main() {
  struct B b; b.op = 106; b.cls = 2;
  if ((int)b.cls != 2) return 20;
  struct D d; d.op = 106; d.cls = 2;
  if ((int)d.cls != 2) return 40;
  struct A a; a.op = 106; a.cls = 2;
  if ((int)a.cls != 2) return 10;
  return 0;
}
