// expect-exit 139
// A null function pointer call must be reported the way a shell reports it
// (128 + SIGSEGV), not swallowed into exit 0 by `qpcc run`.
int main(void) {
  int (*f)(void) = 0;
  return f();
}
