struct Ref { unsigned t:3; unsigned v:29; };
struct Ins { unsigned op:30; unsigned cls:2; struct Ref to; struct Ref arg[2]; };
struct Ins insb[1 << 20];
struct Ins *curi;
int main() {
  curi = &insb[1 << 20];
  if (curi == insb) return 1;
  if (curi != &insb[1 << 20]) return 2;
  curi = &insb[5];
  if (curi != &insb[5]) return 3;
  if ((char*)curi - (char*)insb != 5 * 16) return 4;
  return 0;
}
