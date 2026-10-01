struct L { int a; int b; int c; int thread; int d; };
int main() {
  struct L lnk;
  lnk = (struct L){0};
  if (lnk.thread != 0) return 1;
  if (lnk.a != 0 || lnk.b != 0 || lnk.c != 0 || lnk.d != 0) return 2;
  lnk.thread = 1;
  lnk = (struct L){0};
  if (lnk.thread != 0) return 3;
  struct L p = { .c = 7 };
  if (p.c != 7 || p.thread != 0 || p.a != 0) return 4;
  return 0;
}
