enum { Kx = -1, Kw, Kl, Ks, Kd };
struct Op {
  char *name;
  short argcls[2][4];
  unsigned canfold:1; unsigned hasid:1; unsigned idval:1;
  unsigned commutes:1; unsigned assoc:1; unsigned idemp:1;
  unsigned cmpeqwl:1; unsigned cmplgtewl:1; unsigned eqval:1;
  unsigned pinned:1;
};
static struct Op optab[4] = {
  [1] = { .name = "add", .argcls = { { Kw, Kl, Ks, Kd }, { Kw, Kl, Ks, Kd } }, .canfold = 1, .commutes = 1 },
  [2] = { .name = "par", .argcls = { { Kx, Kx, Kx, Kx }, { Kx, Kx, Kx, Kx } }, .canfold = 0, .pinned = 1 },
};
int main() {
  if (sizeof(struct Op) != 32) return 9;
  if (optab[0].name != 0) return 1;
  if (optab[1].name[0] != 'a') return 2;
  if (optab[2].name[0] != 'p') return 3;
  if (optab[2].argcls[0][Kd] != Kx) return 4;
  if (optab[2].argcls[1][Kw] != Kx) return 5;
  if (optab[1].argcls[0][Kd] != Kd) return 6;
  if (optab[1].canfold != 1) return 7;
  if (optab[2].pinned != 1) return 8;
  return 0;
}
