// std=cqe
// #pragma pack(N) lowers the alignment of the members of the structs that
// follow, and with it the alignment of the aggregate. QPCC has no
// preprocessor, so the driver keeps #pragma lines and the front end applies
// the directive. macOS Mach headers depend on this:
// mach_msg_context_trailer_t is declared under #pragma pack(4) and is 60 bytes.
#include <stddef.h>

#pragma pack(1)
struct packed1 {
  char c;
  int i;
};
#pragma pack()

#pragma pack(push, 2)
struct packed2 {
  char c;
  int i;
};
#pragma pack(pop)

struct natural {
  char c;
  int i;
};

struct natural_mach {
  unsigned int a;
  unsigned int b;
  unsigned int c;
  unsigned int sender[2];
  unsigned int audit[8];
  unsigned long long ctx;
};

#pragma pack(push, 4)
struct packed_mach {
  unsigned int a;
  unsigned int b;
  unsigned int c;
  unsigned int sender[2];
  unsigned int audit[8];
  unsigned long long ctx;
};
#pragma pack(pop)

int main(void) {
  if (sizeof(struct packed1) != 5) return 1;
  if (offsetof(struct packed1, i) != 1) return 2;
  if (sizeof(struct packed2) != 6) return 3;
  if (sizeof(struct natural) != 8) return 4;
  if (offsetof(struct natural, i) != 4) return 5;
  if (sizeof(struct natural_mach) != 64) return 6;
  if (sizeof(struct packed_mach) != 60) return 7;
  if (offsetof(struct packed_mach, ctx) != 52) return 8;
  return 0;
}
