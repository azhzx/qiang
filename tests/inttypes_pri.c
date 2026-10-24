// std=cqe
// inttypes.h has to provide the whole PRI* family. Only the 32/64-bit forms
// used to be defined; the bundled header shadows the system one, so a project
// printing a uint16_t with PRIu16 failed to compile (abduco does).
// The 8/16/32-bit spellings are ABI-independent, so they are checked exactly;
// the 64-bit ones only have to exist (qpcc's int64_t is long, Darwin's is
// long long, and both are 64-bit here).
#include <inttypes.h>
#include <string.h>

int main(void) {
  char *u8 = "%" PRIu8;
  char *u16 = "%" PRIu16;
  char *d16 = "%" PRId16;
  char *x16 = "%" PRIx16;
  char *d32 = "%" PRId32;
  char *u32 = "%" PRIu32;
  char *x32 = "%" PRIx32;
  char *d64 = "%" PRId64;
  char *u64 = "%" PRIu64;
  char *x64 = "%" PRIx64;
  if (strcmp(u8, "%hhu") != 0) return 1;
  if (strcmp(u16, "%hu") != 0) return 2;
  if (strcmp(d16, "%hd") != 0) return 3;
  if (strcmp(x16, "%hx") != 0) return 4;
  if (strcmp(d32, "%d") != 0) return 5;
  if (strcmp(u32, "%u") != 0) return 6;
  if (strcmp(x32, "%x") != 0) return 7;
  for (int i = 0; i < 3; i++) {
    char *s = i == 0 ? d64 : (i == 1 ? u64 : x64);
    if (s[0] != '%' || s[1] == 0) return 8 + i;
  }
  return 0;
}
