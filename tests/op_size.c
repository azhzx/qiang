struct Op {
  char *name;
  short argcls[2][4];
  unsigned canfold:1; unsigned hasid:1; unsigned idval:1;
  unsigned commutes:1; unsigned assoc:1; unsigned idemp:1;
  unsigned cmpeqwl:1; unsigned cmplgtewl:1; unsigned eqval:1;
  unsigned pinned:1;
};
struct A { char *name; short argcls[2][4]; unsigned a:1; };
struct B { char *name; short argcls[2][4]; };
struct C { char *name; short a[2][4]; unsigned x:1; };
int main() {
  if (sizeof(struct Op) != 32) return 1;
  if (sizeof(struct A) != 32) return 2;
  if (sizeof(struct B) != 24) return 3;
  if (sizeof(struct C) != 32) return 4;
  if (sizeof(short[2][4]) != 16) return 5;
  return 0;
}
