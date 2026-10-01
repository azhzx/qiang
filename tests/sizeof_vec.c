typedef struct { unsigned mag; unsigned cap; unsigned long esz; int pool; } V;
int main() { V v; return (int)sizeof(V) + (int)((char*)&v + 1 - (char*)&v) + (int)((char*)(&v + 1) - (char*)&v); }
