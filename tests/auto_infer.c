// std=c23
int main() {
  auto i = 3;
  auto d = 1.5; /* double, not the implicit int C89 auto would give */
  auto s = "hi";
  __auto_type x = 4;
  if (d * 2.0 != 3.0) return 1;
  if (s[1] != 'i') return 2;
  if (i + x != 7) return 3;
  return 0;
}
