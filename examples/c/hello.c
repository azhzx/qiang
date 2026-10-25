#include <stdio.h>

int main(void) {
  auto txt = ({
    printf("A\n");
    printf("B\n");
    "hello from Qiang\n";
  });
  printf("%s", txt);
  return 0;
}
