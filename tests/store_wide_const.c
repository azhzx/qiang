/* A 64-bit constant that does not fit in a word must be stored whole.
   Two defects used to make it zero: gvn's normins masked the placeholder
   class Ke (-2) because -2 & 1 is 0, and arm64_argcls turned that placeholder
   into Kx, whose wide() is 0, so the value was materialised as a word. */
typedef unsigned long long bits;
typedef unsigned long u64;

static u64 g;

int main(void) {
  g = 0; g = 0x100000000ULL;  if (g != 0x100000000ULL) return 1;
  g = 0; g = (bits)1 << 31;   if (g != 0x80000000ULL) return 2;
  g = 0; g = (bits)1 << 32;   if (g != 0x100000000ULL) return 3;
  g = 0; g = (bits)1 << 33;   if (g != 0x200000000ULL) return 4;
  g = 0; g = (bits)3 << 32;   if (g != 0x300000000ULL) return 5;
  g = 0; g = (bits)0xFFFFFFFFFFFFFFFFULL;
  if (g != 0xFFFFFFFFFFFFFFFFULL) return 6;
  return 0;
}
