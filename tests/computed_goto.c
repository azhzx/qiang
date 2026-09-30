int main() {
  static void *p[] = {&&v1, &&v2, &&v3};
  int i = 0;
  goto *p[1];
  v1: i = i + 1;
  v2: i = i + 2;
  v3: i = i + 4;
  return i;
}
