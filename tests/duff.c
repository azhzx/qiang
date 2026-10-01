static int f(int t) {
  switch (t) {
  case 1:
    return 1;
  default:
    if (t >= 10) {
    case 10:
    case 11:
      return 2;
    }
    return 3;
  }
}
int main() {
  if (f(1) != 1) return 1;
  if (f(10) != 2) return 2;
  if (f(11) != 2) return 3;
  if (f(5) != 3) return 4;
  if (f(2) != 3) return 5;
  return 0;
}
