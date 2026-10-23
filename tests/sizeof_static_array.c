// sizeof(expr) at file scope used to fold to 0: the constant evaluator that
// runs on file-scope initializers had no sizeof(expr) arm, so this stored zero
// and lz4's lorem.c reported "division by zero in constant expression" for
// sizeof(kWords) / sizeof(kWords[0]).
static int k[] = { 1, 2, 3 };
static const unsigned n = sizeof(k);
static const unsigned w = sizeof(k) / sizeof(k[0]);
static char s[] = "abc";
static const unsigned m = sizeof(s);

int main(void) {
  if (n != 12) return 1;
  if (w != 3) return 2;
  if (m != 4) return 3;
  return 0;
}
