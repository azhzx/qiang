typedef unsigned int uint32_t;
uint32_t hash(char *s) { uint32_t h; for (h=0; *s; ++s) h = *s + 17*h; return h; }
int main() { uint32_t h = hash("function"); uint32_t p = h * 11183273; if (p > 4294967295u) return 99; return (int)((p >> 23) & 511); }
