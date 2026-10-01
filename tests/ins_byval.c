struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
static int seen[6];
static void take(struct Ins i) {
  seen[0] = (int)i.op;
  seen[1] = (int)i.cls;
  seen[2] = (int)i.to.val;
  seen[3] = (int)i.arg[0].val;
  seen[4] = (int)i.arg[1].val;
  seen[5] = (int)i.arg[1].type;
}
static void take16(struct Ins i, int extra) {
  seen[5] = (int)i.arg[1].val + extra;
}
int main() {
  struct Ins x = { 0 };
  x.op = 7; x.cls = 1; x.to = (struct Ref){ 2, 11 };
  x.arg[0] = (struct Ref){ 2, 22 }; x.arg[1] = (struct Ref){ 2, 33 };
  take(x);
  if (seen[0] != 7) return 1;
  if (seen[1] != 1) return 2;
  if (seen[2] != 11) return 3;
  if (seen[3] != 22) return 4;
  if (seen[4] != 33) return 5;
  if (seen[5] != 2) return 6;
  take16(x, 100);
  if (seen[5] != 133) return 7;
  return 0;
}
