struct R { unsigned t:3; unsigned v:29; };
int main() {
  struct R r;
  r.v = 0x1234567;
  r.t = 5;
  if (r.t != 5) return 1;
  if (r.v != 0x1234567) return 2;
  return 0;
}
