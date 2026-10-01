enum { A = 0, B = 10, C, D, E, F, G, H };
int m[32] = { [G] = 7, [D] = 4, [B] = 2 };
int main() { return (m[B]==2) + (m[D]==4)*2 + (m[G]==7)*4 + (m[C]==0)*8; }
