static int f(int t, int s) {
  static char *sec[2][3] = { { "ab", "cd", "ef" }, { "gh", "ij", "kl" } };
  return sec[t][s][0];
}
int main() {
  if (f(0,0) != 'a') return 1;
  if (f(0,1) != 'c') return 2;
  if (f(0,2) != 'e') return 3;
  if (f(1,0) != 'g') return 4;
  if (f(1,2) != 'k') return 5;
  return 0;
}
