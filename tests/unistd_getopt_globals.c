// std=cqe
// BSD/macOS <unistd.h> declares the getopt globals. The bundled header used to
// leave them out, so lchat.c (which never includes <getopt.h>) saw optarg as an
// undeclared identifier. The std=cqe first line makes the oracle preprocess
// with qpcc's own headers, which is the path this fixes.
#include <unistd.h>

int main(void) {
  optarg = 0;
  if (optarg != 0) return 1;
  return 0;
}
