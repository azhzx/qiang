struct Ref { unsigned t:3; unsigned v:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
static struct Ins insb[8];
static struct Ins *curi = &insb[8];
static short argcls[2][4] = { { -1, -1, -1, -1 }, { -1, -1, -1, -1 } };
int main() {
  *--curi = (struct Ins){ 106, 2, { 0, 7 }, { { 0, 9 }, { 0, 0 } } };
  if (curi->cls != 2) return 1;
  if ((int)curi->cls != 2) return 2;
  if (curi->op != 106) return 3;
  int c = (int)curi->cls;
  if (c != 2) return 4;
  if (argcls[0][curi->cls] != -1) return 5;
  if (argcls[1][curi->cls] != -1) return 6;
  *--curi = (struct Ins){ 5, 3, { 0, 1 }, { { 0, 2 }, { 0, 0 } } };
  if (curi->cls != 3) return 7;
  if ((int)curi->cls != 3) return 8;
  if (argcls[0][curi->cls] != -1) return 9;
  return 0;
}
