struct Ins { unsigned op:30; unsigned cls:2; struct Ref { unsigned t:3; unsigned v:29; } to, arg[2]; };
struct Ins insb[1 << 20];
int main() {
  unsigned long off = (unsigned long)(1 << 20) * 16;
  if (off != 16777216UL) return 1;
  unsigned long a = (unsigned long)(1 << 20);
  if (a != 1048576UL) return 2;
  unsigned long b = a * 16;
  if (b != 16777216UL) return 3;
  if ((char*)insb + off != (char*)&insb[1 << 20]) return 4;
  return 0;
}
