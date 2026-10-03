// std=c23
int main() {
  int a = 1'000;
  int b = 0xFF'FF;
  int c = 0b1010'1010;
  double d = 1'0.5;
  unsigned long e = 1'000UL;
  if (a != 1000) return 1;
  if (b != 65535) return 2;
  if (c != 170) return 3;
  if (d != 10.5) return 4;
  if (e != 1000) return 5;
  return 0;
}
