enum { A, B, C, D, N };
char *m[N] = { [B] = "bb", [D] = "dd" };
int main() { int r = 0; if (m[A] == 0) r += 1; if (m[B] && m[B][0] == 98 && m[B][1] == 98) r += 2; if (m[C] == 0) r += 4; if (m[D] && m[D][0] == 100) r += 8; return r; }
