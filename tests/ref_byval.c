struct Ref { unsigned type:3; unsigned val:29; };
static int rtype(struct Ref r) { return (int)r.type; }
static unsigned rval(struct Ref r) { return r.val; }
static struct Ref mk(unsigned t, unsigned v) { struct Ref r; r.type = t; r.val = v; return r; }
int main() {
  struct Ref a = mk(1, 5);
  struct Ref b = mk(3, 12345);
  if (rtype(a) != 1) return 1;
  if (rval(a) != 5) return 2;
  if (rtype(b) != 3) return 3;
  if (rval(b) != 12345) return 4;
  if (rtype(mk(0, 99)) != 0) return 5;
  if (rval(mk(7, 7)) != 7) return 6;
  return 0;
}
