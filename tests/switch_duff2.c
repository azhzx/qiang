static int isst(int t) { return t >= 100 && t <= 110; }
static int parseline(int t, int *op) {
  switch (t) {
  case 1:
    *op = 1; return 0;
  default:
    if (isst(t)) {
    case 11:
    case 12:
    case 85:
      *op = t; return 0;
    }
    return -1;
  case 2:
    return 2;
  }
}
int main() {
  int op = -1;
  if (parseline(85, &op) != 0) return 1;
  if (op != 85) return 2;
  if (parseline(11, &op) != 0) return 3;
  if (op != 11) return 4;
  if (parseline(1, &op) != 0) return 5;
  if (parseline(2, &op) != 2) return 6;
  if (parseline(50, &op) != -1) return 7;
  if (parseline(105, &op) != 0) return 8;
  if (op != 105) return 9;
  return 0;
}
