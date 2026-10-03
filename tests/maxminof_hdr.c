// expect-exit 0
// std=c2y
// QPCC extension headers: no WG14 proposal defines <stdmaxof.h>/<stdminof.h>.
#include <limits.h>
#include <stdmaxof.h>
#include <stdminof.h>

int main() {
  if (maxof(int) != INT_MAX) return 1;
  if (minof(int) != INT_MIN) return 2;
  if (maxof(unsigned char) != UCHAR_MAX) return 3;
  if (minof(short) != SHRT_MIN) return 4;
  if (maxof(_BitInt(8)) != 127) return 5;
  if (minof(_BitInt(8)) != -128) return 6;
  return 0;
}
