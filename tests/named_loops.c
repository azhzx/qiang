// expect-exit 0
// std=c2y
// clang does not implement C2y named loops yet, so this is QPCC-only.
int main() {
  int n = 0;
  outer:
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++) {
      n++;
      if (i == 1 && j == 1) break outer;
    }
  if (n != 5) return 1;

  n = 0;
  cont:
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++) {
      n++;
      if (j == 0) continue cont;
    }
  if (n != 3) return 2;

  n = 0;
  sel:
  switch (1) {
    case 1:
      for (int i = 0; i < 3; i++) {
        n++;
        break sel;
      }
      n += 100;
  }
  if (n != 1) return 3;

  n = 0;
  A: B: for (int i = 0; i < 3; i++) { n++; break A; }
  if (n != 1) return 4;
  return 0;
}
