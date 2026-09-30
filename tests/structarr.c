struct P { int x; int y; };
int main() {
  struct P a[2];
  a[0].x = 1; a[0].y = 2;
  a[1].x = 3; a[1].y = 4;
  return a[0].x + a[0].y + a[1].x + a[1].y;
}
