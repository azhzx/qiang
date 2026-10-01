typedef unsigned char uchar;
enum { P0, P1, P2, P3 };
static uchar *tab[] = {
  [P1] = (uchar[]){ 1, 2, 3, 0 },
  [P2] = (uchar[]){ 9, 8, 0 },
  [P3] = (uchar[]){ 7, 0 },
};
static uchar *single = (uchar[]){ 4, 5, 0 };
static const char *names[] = { [P0] = "zero", [P1] = (char[]){ 'a', 'b', 0 } };
int main() {
  if (tab[0] != 0) return 1;
  if (tab[P1] == 0) return 2;
  if (tab[P1][0] != 1) return 3;
  if (tab[P1][2] != 3) return 4;
  if (tab[P2][0] != 9) return 5;
  if (tab[P3][0] != 7) return 6;
  if (single[0] != 4) return 7;
  if (single[1] != 5) return 8;
  if (names[P0][0] != 'z') return 9;
  if (names[P1][1] != 'b') return 10;
  return 0;
}
