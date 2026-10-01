static unsigned char lexh[512];
static int tab[64];
static char *p[8];
int main() { int s = 0; int i; for (i = 0; i < 512; i++) s += lexh[i]; for (i = 0; i < 64; i++) s += tab[i]; for (i = 0; i < 8; i++) if (p[i]) s += 1000; return s; }
