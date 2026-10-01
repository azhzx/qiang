static int f(int t) {
  switch (t) {
  case 1: return 1;
  case 2:
  default:
    return 42;
  }
}
static int g(int t) {
  int n = 0;
  switch (t) {
  case 10: n = n + 1;
  default: n = n + 100;
  case 20: n = n + 2; break;
  case 30: n = n + 3;
  }
  return n;
}
int main() {
  if (f(1) != 1) return 1;
  if (f(2) != 42) return 2;
  if (f(3) != 42) return 3;
  if (f(99) != 42) return 4;
  if (g(10) != 103) return 10;
  if (g(20) != 2) return 20;
  if (g(30) != 3) return 30;
  if (g(77) != 102) return 77;
  return 0;
}
