enum { A = 0, B = 10, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R };
char *m[32] = { [B] = "b", [C] = "c", [D] = "d", [G] = "g", [P] = "p" };
int main() { if (m[B]==0||m[B][0]!=98) return 2; if (m[C]==0||m[C][0]!=99) return 4; if (m[D]==0||m[D][0]!=100) return 6; if (m[G]==0||m[G][0]!=103) return 3; if (m[P]==0||m[P][0]!=112) return 5; return 0; }
