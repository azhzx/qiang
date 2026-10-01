struct T { char name[16]; char apple; int gpr0; char asloc[4]; char assym[4]; };
static struct T t = { .name = "amd64", .apple = 1, .gpr0 = 7, .asloc = ".L", .assym = "_" };
static int firstc(const char *s) { return s[0]; }
static int secondc(const char *s) { return s[1]; }
static int sum(const char *a, const char *b) { return a[0] + b[0]; }
int main() {
  if (firstc(t.asloc) != '.') return 1;
  if (secondc(t.asloc) != 'L') return 2;
  if (firstc(t.assym) != '_') return 3;
  if (sum(t.asloc, t.assym) != '.' + '_') return 4;
  const char *p = t.asloc;
  if (p[1] != 'L') return 5;
  return 0;
}
