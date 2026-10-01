struct T { char name[16]; char apple; int gpr0; char asloc[4]; char assym[4]; };
static struct T t = { .name = "amd64", .apple = 1, .gpr0 = 7, .asloc = ".L", .assym = "_" };
static int firstc(const char *s) { return s[0]; }
static int third(void) {
  int n = 0;
  for (int i = 0; i < 3; i++) {
    n = n + firstc(t.asloc);
  }
  return n;
}
int main() {
  if (third() != '.' * 3) return 1;
  int n = 0;
  for (int i = 0; i < 2; i++) {
    if (firstc(t.assym) != '_') return 2;
    n++;
  }
  return n == 2 ? 0 : 3;
}
