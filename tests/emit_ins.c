struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
static struct Ins buf[4];
static struct Ins *cur = &buf[4];
static void emit(int op, int k, struct Ref to, struct Ref a0, struct Ref a1) {
  if (cur == buf) return;
  *--cur = (struct Ins){ .op = (unsigned)op, .cls = (unsigned)k, .to = to, .arg = { a0, a1 } };
}
int main() {
  emit(1, 2, (struct Ref){ 1, 3 }, (struct Ref){ 2, 4 }, (struct Ref){ 0, 5 });
  if (buf[3].op != 1) return 1;
  if (buf[3].cls != 2) return 2;
  if (buf[3].to.type != 1) return 3;
  if (buf[3].to.val != 3) return 4;
  if (buf[3].arg[0].type != 2) return 5;
  if (buf[3].arg[0].val != 4) return 6;
  if (buf[3].arg[1].type != 0) return 7;
  if (buf[3].arg[1].val != 5) return 8;
  return 0;
}
