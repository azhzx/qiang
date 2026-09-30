struct R { unsigned int a : 3; unsigned int b : 5; int c : 4; };
int main() {
  struct R r;
  r.a = 5;
  r.b = 17;
  r.c = -3;
  return r.a + r.b + r.c + 100;
}
