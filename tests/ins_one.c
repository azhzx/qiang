struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
static int seen_op, seen_to, seen_a0, seen_a1, seen_cls;
static void take(struct Ins i) {
  seen_op = (int)i.op; seen_cls = (int)i.cls;
  seen_to = (int)i.to.val; seen_a0 = (int)i.arg[0].val; seen_a1 = (int)i.arg[1].val;
}
static void emitcopy(int x, int y, int k) {
  struct Ins i;
  i = (struct Ins){ .op = 1, .to = { 2, (unsigned)x }, .cls = (unsigned)k, .arg = { { 2, (unsigned)y } } };
  take(i);
}
int main() {
  emitcopy(11, 22, 3);
  if (seen_op != 1) return 1;
  if (seen_cls != 3) return 2;
  if (seen_to != 11) return 3;
  if (seen_a0 != 22) return 4;
  if (seen_a1 != 0) return 5;
  return 0;
}
