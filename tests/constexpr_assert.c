// std=c23
constexpr int N = 3;
static_assert(N == 3, "N");
constexpr int SIZE = 4;

int main() {
  int a[SIZE];
  constexpr int M = 2;
  static_assert(M == 2, "M");
  return (int)sizeof(a) - 16 + (N - 3) + (M - 2);
}
