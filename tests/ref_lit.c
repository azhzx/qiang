struct Ref { unsigned type:3; unsigned val:29; };
static int rtype(struct Ref r) { return (int)r.type; }
static unsigned rval(struct Ref r) { return r.val; }
static struct Ref id(struct Ref r) { return r; }
int main() {
  if (rtype((struct Ref){0, 0}) != 0) return 1;
  if (rval((struct Ref){0, 0}) != 0) return 2;
  if (rtype((struct Ref){1, 5}) != 1) return 3;
  if (rval((struct Ref){1, 5}) != 5) return 4;
  if (rtype(id((struct Ref){2, 9})) != 2) return 5;
  if (rval(id((struct Ref){2, 9})) != 9) return 6;
  return 0;
}
