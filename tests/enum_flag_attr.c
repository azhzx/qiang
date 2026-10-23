// C23 fixed underlying type with a clang attribute in front of the colon:
// macOS <mach/mach_types.h> writes
//   typedef enum __attribute__((__flag_enum__)) : uint64_t { ... }
// The attribute used to break the enum specifier parse.
typedef enum __attribute__((__flag_enum__)) : unsigned long long {
  OPT_NONE = 0u,
  OPT_ONE = 1u,
  OPT_TWO = 2u,
  OPT_ALL = 0xffffffffffffffffULL,
} opt_t;

int main(void) {
  opt_t o = OPT_ONE | OPT_TWO;
  if ((int)o != 3) return 1;
  if (OPT_NONE != 0) return 2;
  if (sizeof(opt_t) != 8) return 3;
  if (OPT_ALL == 0) return 4;
  return 0;
}
