enum { NIns = 1 << 20, M = 1 << 12, K = 1 << 24 };
int main() {
  if (NIns != 1048576) return 1;
  if (M != 4096) return 2;
  if (K != 16777216) return 3;
  if (NIns / 1024 != 1024) return 4;
  return 0;
}
