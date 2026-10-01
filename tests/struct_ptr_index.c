typedef struct { int a, b, c, d, e, f, g, h, i, j; } S;   /* 40 bytes */
typedef struct { char t[17]; } M;                          /* 17 bytes */
static S g[4];
static M gm[4];
int main() {
  if (sizeof(S) != 40) return 1;
  if ((char*)(g + 2) - (char*)g != 80) return 2;
  if ((char*)&g[3] - (char*)g != 120) return 3;
  for (int i = 0; i < 4; i++) { g[i].a = i; g[i].j = i + 100; }
  S *p = &g[1];
  if (p->a != 1) return 10;
  if (p->j != 101) return 11;
  if ((char*)p - (char*)g != 40) return 12;
  p--;
  if (p->a != 0) return 13;
  p++;
  p++;
  if (p->a != 2) return 14;
  if (p->j != 102) return 15;
  p += 1;
  if (p->a != 3) return 16;
  if (g[3].j != 103) return 17;
  if ((char*)(gm + 3) - (char*)gm != 51) return 20;
  return 0;
}
