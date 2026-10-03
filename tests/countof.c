// std=c2y
#include <stdcountof.h>

static int arr[7];

int main() {
  int local[5];
  int matrix[3][4];
  if (countof(arr) != 7) return 1;
  if (countof(local) != 5) return 2;
  if (countof(matrix) != 3) return 3;
  if (countof(int[9]) != 9) return 4;
  if (_Countof(arr) != 7) return 5;
  return 0;
}
