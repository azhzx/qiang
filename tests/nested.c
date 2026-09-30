int add(int a, int b) { return a + b; }
int mul(int a, int b) { return a * b; }
int main() { int s = 0; int i = 0; while (i < 10) { s = add(s, mul(i, i)); i = i + 1; } return s % 100; }
