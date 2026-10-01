static int f(int t, int s) {
  static char *sec[2][3] = {
    [0][0] = "ab", [0][1] = "cd", [0][2] = "ef",
    [1][0] = "gh", [1][1] = "ij", [1][2] = "kl",
  };
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
