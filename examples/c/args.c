#include <stdio.h>

int main(int argc, char **argv) {
  printf("argc = %d\n", argc);
  for (int i = 0; i < argc; i++) {
    printf("argv[%d] = %s\n", i, argv[i]);
  }
  if (argc > 1) {
    int sum = 0;
    for (int i = 1; i < argc; i++) {
      int v = 0;
      for (const char *p = argv[i]; *p; p++) {
        v = v * 10 + (*p - '0');
      }
      sum += v;
    }
    printf("sum     = %d\n", sum);
  }
  return 0;
}
