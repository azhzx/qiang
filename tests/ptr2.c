int main() { int a[4]; int i = 0; int *p = a; while (i < 4) { *p = i * 2; p = p + 1; i = i + 1; } return a[3]; }
