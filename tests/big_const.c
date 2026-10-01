struct Ins { unsigned op:30; unsigned cls:2; struct Ref { unsigned t:3; unsigned v:29; } to, arg[2]; };
struct Ins insb[1 << 20];
int main() {
  char *base = (char*)insb;
  char *p = base + 16777216UL;
  if (p != (char*)&insb[1 << 20]) return 1;
  unsigned long off = 16777216UL;
  char *q = base + off;
  if (q != (char*)&insb[1 << 20]) return 2;
  char *r = base + 4096;
  if (r != (char*)&insb[256]) return 3;
  char *s = base + 1048576;
  if (s != (char*)&insb[65536]) return 4;
  return 0;
}
