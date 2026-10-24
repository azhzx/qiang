#ifndef __QPCC_QBE_INTTYPES_H
#define __QPCC_QBE_INTTYPES_H

#include <stdint.h>

// Format specifiers for the <stdint.h> types. Values follow the Darwin ABI,
// where int64_t is long: the 64-bit forms use "l", while the 8/16/32-bit
// arguments are promoted to int and use "hh", "h" and "" respectively.
// The whole set has to be present: a project that prints a uint16_t with
// PRIu16 would otherwise fail to compile at the call site (abduco does).
#define PRId8 "hhd"
#define PRIi8 "hhi"
#define PRIu8 "hhu"
#define PRIo8 "hho"
#define PRIx8 "hhx"
#define PRIX8 "hhX"

#define PRId16 "hd"
#define PRIi16 "hi"
#define PRIu16 "hu"
#define PRIo16 "ho"
#define PRIx16 "hx"
#define PRIX16 "hX"

#define PRId32 "d"
#define PRIi32 "i"
#define PRIu32 "u"
#define PRIo32 "o"
#define PRIx32 "x"
#define PRIX32 "X"

#define PRId64 "ld"
#define PRIi64 "li"
#define PRIu64 "lu"
#define PRIo64 "lo"
#define PRIx64 "lx"
#define PRIX64 "lX"

#define PRIdPTR "ld"
#define PRIiPTR "li"
#define PRIuPTR "lu"
#define PRIoPTR "lo"
#define PRIxPTR "lx"
#define PRIXPTR "lX"

#define PRIdMAX "ld"
#define PRIiMAX "li"
#define PRIuMAX "lu"
#define PRIoMAX "lo"
#define PRIxMAX "lx"
#define PRIXMAX "lX"

#endif /* __QPCC_QBE_INTTYPES_H */
