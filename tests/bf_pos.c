struct Ref { unsigned t:3; unsigned v:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
static int seen[4];
static void take(struct Ins i) {
  seen[0] = (int)i.op;
  seen[1] = (int)i.cls;
  seen[2] = (int)i.to.v;
  seen[3] = (int)i.arg[0].v;
}
int main() {
  struct Ins i;
  i = (struct Ins){ 106, 2, { 0, 7 }, { { 0, 9 }, { 0, 0 } } };
  take(i);
  if (seen[0] != 106) return 1;
  if (seen[1] != 2) return 2;
  if (seen[2] != 7) return 3;
  if (seen[3] != 9) return 4;
  struct Ins j;
  j = (struct Ins){ 5, 3, { 0, 1 }, { { 0, 2 }, { 0, 3 } } };
  if (j.cls != 3) return 5;
  if ((int)j.cls != 3) return 6;
  if (j.op != 5) return 7;
  return 0;
}
