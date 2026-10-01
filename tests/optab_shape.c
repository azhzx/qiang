enum { Kx = -1, Kw, Kl, Ks, Kd };
struct Op {
  char *name;
  short argcls[2][4];
  unsigned canfold:1;
  unsigned hasid:1;
  unsigned commutes:1;
  unsigned pinned:1;
};
static struct Op optab[2] = {
  [0] = { .name = "par", .argcls = { { [Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx },
                                     { [Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx } },
          .canfold = 0 },
  [1] = { .name = "add", .argcls = { { [Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx },
                                     { [Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd } },
          .canfold = 1 },
};
int main() {
  if (optab[0].argcls[0][Kd] != Kx) return 1;
  if (optab[0].argcls[1][Kw] != Kx) return 2;
  if (optab[1].argcls[1][Kd] != Kd) return 3;
  if (optab[1].argcls[0][Ks] != Kx) return 4;
  if (optab[1].canfold != 1) return 5;
  if (optab[0].canfold != 0) return 6;
  return 0;
}
