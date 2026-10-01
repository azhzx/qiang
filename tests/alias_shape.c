typedef unsigned long long bits;
typedef unsigned int uint32_t;
typedef struct Sym Sym;
typedef struct Alias Alias;
struct Sym { enum { SGlo = 0, SThr = 1, SExt = 2, SExtThr = 3 } type; uint32_t id; };
struct Alias {
  enum { ABot = 0, ALoc = 1, ACon = 2, AEsc = 3, ASym = 4, AUnk = 6 } type;
  int base;
  long long offset;
  union { Sym sym; struct { int sz; bits m; } loc; } u;
  Alias *slot;
};
struct Tmp {
  char *name; void *def; void *use;
  unsigned int ndef, nuse; unsigned int bid; unsigned int cost;
  int slot; short cls;
  struct { int r; int w; bits m; } hint;
  int phi; Alias alias;
  enum { WFull, Wsb, Wub, Wsh, Wuh, Wsw, Wuw } width;
  int visit; unsigned int gcmbid;
};
int main() {
  if (sizeof(struct Sym) != 8) return 1;
  if (sizeof(struct Alias) != 40) return 2;
  if (__builtin_offsetof(struct Alias, u) != 16) return 3;
  if (__builtin_offsetof(struct Alias, slot) != 32) return 4;
  if (__builtin_offsetof(struct Tmp, hint) != 48) return 5;
  if (__builtin_offsetof(struct Tmp, alias) != 72) return 6;
  if (sizeof(struct Tmp) != 128) return 7;
  return 0;
}
