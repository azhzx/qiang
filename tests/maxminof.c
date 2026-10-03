// expect-exit 0
// std=c2y
// clang does not implement _Maxof/_Minof yet, so this is a QPCC-only fixture.
#include <limits.h>

int main() {
  if (_Maxof(char) != CHAR_MAX) return 1;
  if (_Minof(char) != CHAR_MIN) return 2;
  if (_Maxof(short) != SHRT_MAX) return 3;
  if (_Minof(short) != SHRT_MIN) return 4;
  if (_Maxof(unsigned char) != UCHAR_MAX) return 5;
  if (_Maxof(int) != INT_MAX) return 6;
  if (_Minof(int) != INT_MIN) return 7;
  if (_Maxof(_BitInt(8)) != 127) return 8;
  if (_Minof(_BitInt(8)) != -128) return 9;
  return 0;
}
