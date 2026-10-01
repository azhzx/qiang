static char *sec[2][3] = { { "ab", "cd", "ef" }, { "gh", "ij", "kl" } };
int main() {
  if (sec[0][0][0] != 'a') return 1;
  if (sec[0][2][0] != 'e') return 2;
  if (sec[1][1][0] != 'i') return 3;
  if (sec[1][2][0] != 'k') return 4;
  return 0;
}
