typedef unsigned int uint32_t;
uint32_t hash(char *s) { uint32_t h; for (h=0; *s; ++s) h = *s + 17*h; return h; }
int main() { long h = hash("function"); long a = h * 11183273; long b = a >> 10; return (int)(b & 0xFF) + (int)(h & 1); }
