/* NEGATIVE RESULT, kept on purpose.
 *
 * vendor/qbe/simpl.c:blit, extracted verbatim (struct table, abs, p++ walk),
 * with stubs for newtmp/getcon/emit. QPCC and clang agree on all ten sizes
 * from 0 to 20, so blit itself is not what QPCC miscompiles. It only spins
 * when handed a bad size, which points at the caller.
 *
 * Run: cc repro_blit.c -o /tmp/r && /tmp/r <size>
 */
typedef unsigned int uint;
typedef unsigned long ulong;
typedef struct { uint type:3; uint val:29; } Ref;

void *calloc(ulong, ulong);
void *realloc(void *, ulong);
void free(void *);
void exit(int);
int printf(char *, ...);
int abs(int);
int atoi(char *);

typedef struct { Ref *con; int ncon; } Fn;
static int nevents;

static Ref newtmp(char *s, int k, Fn *fn) {
  Ref r; (void)s; (void)k; (void)fn;
  r.type = 3; r.val = 1;
  return r;
}

static Ref getcon(long long val, Fn *fn) {
  int c;
  Ref r;
  nevents++;
  for (c = 1; c < fn->ncon; c++) {
    (void)val;
  }
  fn->ncon = c + 1;
  fn->con = (Ref *)realloc(fn->con, (ulong)fn->ncon * 16);
  r.type = 1; r.val = (uint)c;
  return r;
}

static void emit(int op, int cls, Ref to, Ref a0, Ref a1) {
  (void)op; (void)cls; (void)to; (void)a0; (void)a1;
  nevents++;
}

/* ---- verbatim from vendor/qbe/simpl.c ---- */
static void
blit(Ref sd[2], int sz, Fn *fn)
{
  struct { int st, ld, cls, size; } *p, tbl[] = {
    { 1, 2, 3, 8 },
    { 4, 5, 6, 4 },
    { 7, 8, 9, 2 },
    { 10, 11, 12, 1 },
  };
  Ref r, r1, ro;
  int off, fwd, n;

  fwd = sz >= 0;
  sz = abs(sz);
  off = fwd ? sz : 0;
  for (p = tbl; sz; p++)
    for (n = p->size; sz >= n; sz -= n) {
      off -= fwd ? n : 0;
      r = newtmp("blt", 0, fn);
      r1 = newtmp("blt", 0, fn);
      ro = getcon(off, fn);
      emit(p->st, 0, r, r1, ro);
      r1 = newtmp("blt", 0, fn);
      emit(p->ld, p->cls, r, r1, ro);
      off += fwd ? 0 : n;
    }
}

int main(int argc, char **argv) {
  if (argc > 1) {
    Fn f2; Ref sd2[2];
    sd2[0].type = 3; sd2[0].val = 1; sd2[1].type = 3; sd2[1].val = 2;
    f2.con = 0; f2.ncon = 0;
    nevents = 0;
    blit(sd2, atoi(argv[1]), &f2);
    printf("sz=%s events=%d\n", argv[1], nevents);
    return 0;
  }
  Fn f;
  Ref sd[2];
  int sizes[8];
  int i;
  sd[0].type = 3; sd[0].val = 1;
  sd[1].type = 3; sd[1].val = 2;
  f.con = 0; f.ncon = 0;
  sizes[0]=8; sizes[1]=4; sizes[2]=2; sizes[3]=1;
  sizes[4]=11; sizes[5]=3; sizes[6]=15; sizes[7]=0;
  for (i = 0; i < 8; i++) {
    nevents = 0;
    blit(sd, sizes[i], &f);
    printf("sz=%d events=%d\n", sizes[i], nevents);
  }
  return 0;
}

