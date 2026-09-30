union U { int i; char c[4]; };
int main() { union U u; u.i = 0; u.c[0] = 5; return u.i; }
