struct Op {
  char *name;
  unsigned argcls:3;
  unsigned canfold:1;
  unsigned hasid:1;
  unsigned commutes:1;
  unsigned pinned:1;
};
static struct Op optab[4] = {
  [1] = { .name = "add", .argcls = 1, .canfold = 1, .hasid = 0, .commutes = 1, .pinned = 0 },
  [2] = { .name = "sub", .argcls = 1, .canfold = 0, .commutes = 0, .pinned = 1 },
};
static struct Op plain[2] = { { "ab", 5, 1, 1, 0, 1 }, { "cd", 2, 0, 0, 1, 0 } };
int main() {
  if (optab[1].canfold != 1) return 1;
  if (optab[1].commutes != 1) return 2;
  if (optab[1].pinned != 0) return 3;
  if (optab[1].argcls != 1) return 4;
  if (optab[2].canfold != 0) return 5;
  if (optab[2].pinned != 1) return 6;
  if (optab[2].name[0] != 's') return 7;
  if (optab[0].canfold != 0) return 8;
  if (plain[0].argcls != 5 || plain[0].canfold != 1 || plain[0].pinned != 1) return 9;
  if (plain[1].argcls != 2 || plain[1].canfold != 0 || plain[1].commutes != 1) return 10;
  return 0;
}
