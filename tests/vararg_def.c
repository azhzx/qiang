typedef __builtin_va_list va_list;
int sum(int n, ...) {
  va_list ap;
  __builtin_va_start(ap, n);
  int s = 0;
  int i;
  for (i = 0; i < n; i = i + 1) s = s + __builtin_va_arg(ap, int);
  __builtin_va_end(ap);
  return s;
}
int main() { return sum(3, 1, 2, 3); }
