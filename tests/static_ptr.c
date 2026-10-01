static char *one(void) { static char *p = "ab"; return p; }
static char *arr[] = { "gh", "ij" };
static int f(int i) { return arr[i][0]; }
static char *loc(void) { static char *a[2] = { "cd", "ef" }; return a[1]; }
int main() {
  if (one()[0] != 'a' || one()[1] != 'b') return 1;
  if (f(0) != 'g' || f(1) != 'i') return 2;
  if (loc()[0] != 'e' || loc()[1] != 'f') return 3;
  return 0;
}
