/* A pointer difference is ptrdiff_t, an integer.  Typing it as a pointer made
   the code generator treat `p[a - b]` as a pointer-plus-pointer and skip the
   element scaling, so the offset came out as a byte count. */
typedef unsigned int uint;
typedef struct { uint op:30; uint cls:2; uint to; uint a0, a1; } Ins;
typedef struct { void *type; int inmem; int align; uint size; int cls[2]; uint ref[2]; } AClass;
static AClass store[4];
static Ins ins[4];
static int check(Ins *i0, Ins *i1) {
  AClass *ac = store;
  long n = i1 - i0;
  if (n != 3) return 1;
  if (sizeof(AClass) != 40) return 2;
  if ((char*)&ac[i1 - i0] - (char*)ac != 120) return 3;
  if ((char*)&ac[n] - (char*)ac != 120) return 4;
  if ((char*)&ac[3] - (char*)ac != 120) return 5;
  ac[i1 - i0 - 1].inmem = 7;
  if (store[2].inmem != 7) return 6;
  return 0;
}
int main() {
  return check(ins, ins + 3);
}
