int main() { _Alignas(16) int a; a = 1; return a + (int)((long)&a & 15); }
