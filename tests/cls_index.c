struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
enum { Kx = -1, Kw, Kl, Ks, Kd };
static short argcls[2][4] = { { Kx, Kx, Kx, Kx }, { Kx, Kx, Kx, Kx } };
static int lookup(struct Ins i, int n) { return (int)argcls[n][i.cls]; }
static int rtype(struct Ref r) { return (r.type == 0 && r.val == 0) ? -1 : (int)r.type; }
int main() {
  struct Ins i = { 106, Ks, { 0, 0 }, { { 0, 0 }, { 0, 0 } } };
  if (i.op != 106) return 1;
  if (i.cls != 2) return 2;
  if (lookup(i, 0) != Kx) return 3;
  if (lookup(i, 1) != Kx) return 4;
  if (rtype(i.arg[0]) != -1) return 5;
  struct Ins j = { 106, Kd, { 0, 0 }, { { 0, 0 }, { 0, 0 } } };
  if (j.cls != 3) return 6;
  if (lookup(j, 0) != Kx) return 7;
  if (lookup(j, 0) == Kx) return 0;
  return 8;
}
