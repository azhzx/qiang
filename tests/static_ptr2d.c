static int f(int t, int s) {
  static char *sec[2][3] = {
    [0][0] = "ab", [0][1] = "cd", [0][2] = "ef",
    [1][0] = "gh", [1][1] = "ij", [1][2] = "kl",
  };
  return sec[t][s][0] + sec[t][s][1];
}
int main() {
  if (f(0,0) != 'a' + 'b') return 1;
  if (f(0,2) != 'e' + 'f') return 2;
  if (f(1,0) != 'g' + 'h') return 3;
  if (f(1,2) != 'k' + 'l') return 4;
  return 0;
}
