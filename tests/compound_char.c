int firstbit(unsigned long b) {
  int n = 0;
  if (!(b & 0xffffffff)) { n += 32; b >>= 32; }
  if (!(b & 0xffff)) { n += 16; b >>= 16; }
  if (!(b & 0xff)) { n += 8; b >>= 8; }
  if (!(b & 0xf)) { n += 4; b >>= 4; }
  n += (char[16]){4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0}[b & 0xf];
  return n;
}
int main() { return firstbit(1) + firstbit(8) * 10 + firstbit(0x10) * 100; }
