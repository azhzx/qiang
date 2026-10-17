// A string literal has array type, so sizeof("ab") is 3, not the pointer size.
// The sema used to type the literal as char* and answer 8.
//
// A declaration name is in scope from the end of its declarator (C11
// 6.2.1p7), so it is visible inside its own initializer: int x = sizeof(x);
// is valid C. Registering the symbol only after the initializer rejected it,
// which broke lz4 lib/lz4file.c and hiredis async.c in the wild.
int arr[7];

int main(void) {
  if (sizeof("ab") != 3) return 1;
  if (sizeof("abcdef") != 7) return 2;
  if (sizeof("") != 1) return 3;
  if (sizeof("a" "b") != 3) return 4; /* concatenation happens first */
  if (sizeof(arr) != 28) return 5;    /* arrays do not decay under sizeof */
  if (sizeof(arr) / sizeof(arr[0]) != 7) return 6;
  if (sizeof((char *)"ab") != sizeof(char *)) return 7; /* a cast does decay */

  int x = (int)sizeof(x);
  if (x != (int)sizeof(int)) return 8;

  int n = 5;
  int m = (int)sizeof(n);
  if (m != (int)sizeof(int)) return 9;

  return 0;
}
