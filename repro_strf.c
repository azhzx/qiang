/* QPCC miscompiles the strf shape in vendor/qbe/util.c.
 *
 * strf is variadic; it sizes the buffer with vsnprintf(NULL, 0, ...) and
 * then allocates from a pool:
 *
 *     p = (pool == PFn ? alloc : emalloc)(n + 1);
 *
 * qpcc makes the pool branch return memory that is NOT in the pool, so the
 * buffer is wrong and the second vsnprintf overruns.  The self-hosted qbe
 * crashes inside strf, from newtmp, from blit:
 *
 *     frame #3: strf + 72
 *     frame #4: newtmp + 280
 *     frame #5: blit + 632
 *     frame #6: ins + 904
 *     frame #7: simpl + 168
 *
 * Build with the qpcc headers, not the system ones:
 *
 *     clang -E -P -nostdinc -I qpcc/include/qbe repro_strf.c > t.i
 *     _build/native/debug/build/qpcc/cmd/cmd.exe t.i -o t.o
 *     clang -w t.o -o t && ./t
 *
 * The original program exits 19 with qpcc and 0 with clang.
 */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char poolbuf[65536];
static size_t pooloff;

void *alloc(size_t n) {
  void *p = &poolbuf[pooloff];
  pooloff = pooloff + ((n + 7) & ~(size_t)7);
  return p;
}

void *emalloc(size_t n) { void *p = calloc(1, n); if (!p) abort(); return p; }

enum { PFn = 1, PHeap = 0 };
typedef int Pool;

/* verbatim strf: the ternary selects the allocator */
static char *strfA(Pool pool, char *s, ...) {
  va_list ap; int n; char *p;
  va_start(ap, s); n = vsnprintf(NULL, 0, s, ap); va_end(ap);
  p = (pool == PFn ? alloc : emalloc)(n + 1);
  va_start(ap, s); vsnprintf(p, n + 1, s, ap); va_end(ap);
  return p;
}

/* the same with if/else, to show the ternary is not the culprit */
static char *strfB(Pool pool, char *s, ...) {
  va_list ap; int n; char *p;
  va_start(ap, s); n = vsnprintf(NULL, 0, s, ap); va_end(ap);
  if (pool == PFn) p = alloc(n + 1); else p = emalloc(n + 1);
  va_start(ap, s); vsnprintf(p, n + 1, s, ap); va_end(ap);
  return p;
}

/* always emalloc: this one is correct */
static char *strfC(Pool pool, char *s, ...) {
  va_list ap; int n; char *p;
  va_start(ap, s); n = vsnprintf(NULL, 0, s, ap); va_end(ap);
  p = emalloc(n + 1);
  va_start(ap, s); vsnprintf(p, n + 1, s, ap); va_end(ap);
  return p;
}

static int inpool(char *p) { return p >= poolbuf && p < poolbuf + 65536; }

int main(void) {
  int f = 0, i;
  char *p;
  for (i = 0; i < 20; i++) {
    p = strfA(PFn, "%s.%d", "blt", i);
    if (!inpool(p)) { f |= 1; break; }
  }
  for (i = 0; i < 20; i++) {
    p = strfB(PFn, "%s.%d", "blt", i);
    if (!inpool(p)) { f |= 2; break; }
  }
  p = strfC(PFn, "%s", "abc");
  if (inpool(p)) f |= 4;
  p = strfA(PHeap, "%s", "abc");
  if (inpool(p)) f |= 8;
  p = strfA(PFn, "%s", "abcdefghijklmnopqrstuvwxyz0123456789");
  if (!inpool(p)) f |= 16;
  if (strlen(p) != 36) f |= 32;
  return f;
}
