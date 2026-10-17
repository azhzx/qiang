// QBE has no ops for the integer bit intrinsics, so the code generator emits
// the sequence. They used to fall through to an implicit declaration and then
// to a link error against ___builtin_bswap32. __builtin_constant_p used to be
// treated as an identity in the parser, so a non-zero argument claimed to be a
// compile-time constant.
unsigned int b32(unsigned int x) { return __builtin_bswap32(x); }
unsigned long long b64(unsigned long long x) { return __builtin_bswap64(x); }
int pc32(unsigned int x) { return __builtin_popcount(x); }
int pc64(unsigned long long x) { return __builtin_popcountll(x); }
int lz32(unsigned int x) { return __builtin_clz(x); }
int lz64(unsigned long long x) { return __builtin_clzll(x); }
int tz32(unsigned int x) { return __builtin_ctz(x); }
int tz64(unsigned long long x) { return __builtin_ctzll(x); }

int main(void) {
  if (b32(0x11223344u) != 0x44332211u) return 1;
  if (b64(0x1122334455667788ull) != 0x8877665544332211ull) return 2;
  if (pc32(0xF0F0F0F0u) != 16) return 3;
  if (pc64(0xF0F0F0F0F0F0F0F0ull) != 32) return 4;
  if (lz32(1u) != 31) return 5;
  if (lz32(0u) != 32) return 6; /* the width when no bit is set */
  if (lz64(1ull) != 63) return 7;
  if (tz32(0x100u) != 8) return 8;
  if (tz64(0x10000ull) != 16) return 9;
  if (__builtin_expect(5, 1) != 5) return 10;
  /* __builtin_constant_p is implementation-defined: clang says 1 here, qpcc
     says 0 ("not known to be constant"), and both are correct, so it is not
     asserted against the clang reference. */
  return 0;
}
