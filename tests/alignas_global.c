_Alignas(16) int g = 7;
int main() { return g + (int)((long)&g & 15); }
