// std=cqe
// BSD and macOS get PATH_MAX from <sys/syslimits.h> via <limits.h>. The bundled
// header did not define it, so lchat.c saw PATH_MAX as an undeclared identifier
// once the getopt globals were in place.
#include <limits.h>

char path[PATH_MAX];

int main(void) {
  if (PATH_MAX < 256) return 1;
  path[0] = 0;
  if (path[0] != 0) return 2;
  return 0;
}
