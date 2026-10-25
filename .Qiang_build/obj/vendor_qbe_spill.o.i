typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long int64_t;
typedef unsigned long uint64_t;
typedef long intptr_t;
typedef unsigned long uintptr_t;
typedef long intmax_t;
typedef unsigned long uintmax_t;
typedef unsigned long size_t;
typedef long ptrdiff_t;
typedef unsigned int wchar_t;
typedef struct _IO_FILE FILE;
extern FILE *__stdinp;
extern FILE *__stdoutp;
extern FILE *__stderrp;
int printf(char *, ...);
int fprintf(FILE *, char *, ...);
int sprintf(char *, char *, ...);
int snprintf(char *, size_t, char *, ...);
int vfprintf(FILE *, char *, __builtin_va_list);
int vprintf(char *, __builtin_va_list);
int vsnprintf(char *, size_t, char *, __builtin_va_list);
int vsprintf(char *, char *, __builtin_va_list);
int puts(char *);
int fputs(char *, FILE *);
int fputc(int, FILE *);
int putchar(int);
int fgetc(FILE *);
int getc(FILE *);
int ungetc(int, FILE *);
int fscanf(FILE *, char *, ...);
int sscanf(char *, char *, ...);
int scanf(char *, ...);
int fputc(int, FILE *);
int putc(int, FILE *);
char *fgets(char *, int, FILE *);
FILE *fopen(char *, char *);
int fclose(FILE *);
int fflush(FILE *);
size_t fread(void *, size_t, size_t, FILE *);
size_t fwrite(void *, size_t, size_t, FILE *);
int remove(char *);
int rename(char *, char *);
int fseek(FILE *, long, int);
long ftell(FILE *);
int feof(FILE *);
int ferror(FILE *);
void clearerr(FILE *);
int setvbuf(FILE *, char *, int, size_t);
FILE *freopen(char *, char *, FILE *);
FILE *tmpfile(void);
char *tmpnam(char *);
int system(char *);
void *malloc(size_t);
void *calloc(size_t, size_t);
void *realloc(void *, size_t);
void free(void *);
void exit(int);
void abort(void);
int abs(int);
int atoi(char *);
long atol(char *);
long strtol(char *, char **, int);
unsigned long strtoul(char *, char **, int);
double strtod(char *, char **);
void qsort(void *, size_t, size_t, int (*)(void *, void *));
char *getenv(char *);
int atexit(void (*)(void));
void *memcpy(void *, void *, size_t);
void *memmove(void *, void *, size_t);
void *memset(void *, int, size_t);
int memcmp(void *, void *, size_t);
size_t strlen(char *);
char *strcpy(char *, char *);
char *strncpy(char *, char *, size_t);
char *strcat(char *, char *);
int strcmp(char *, char *);
int strncmp(char *, char *, size_t);
char *strchr(char *, int);
char *strrchr(char *, int);
char *strstr(char *, char *);
char *strdup(char *);
char *strerror(int);
void *memchr(const void *, int, size_t);
char *strncat(char *, const char *, size_t);
char *strpbrk(const char *, const char *);
size_t strspn(const char *, const char *);
size_t strcspn(const char *, const char *);
char *strtok(char *, const char *);
int strcoll(const char *, const char *);
size_t strxfrm(char *, const char *, size_t);
int strcasecmp(const char *, const char *);
int strncasecmp(const char *, const char *, size_t);
char *strsignal(int);
void *memmem(const void *, size_t, const void *, size_t);
void bzero(void *, size_t);
typedef unsigned char uchar;
typedef unsigned int uint;
typedef unsigned long ulong;
typedef unsigned long long bits;
typedef struct BSet BSet;
typedef struct Ref Ref;
typedef struct Op Op;
typedef struct Ins Ins;
typedef struct Phi Phi;
typedef struct Blk Blk;
typedef struct Use Use;
typedef struct Sym Sym;
typedef struct Num Num;
typedef struct Alias Alias;
typedef struct Tmp Tmp;
typedef struct Con Con;
typedef struct Addr Mem;
typedef struct Fn Fn;
typedef struct Typ Typ;
typedef struct Field Field;
typedef struct Dat Dat;
typedef struct Lnk Lnk;
typedef struct Target Target;
enum {
 NIns = 1 << 20,
 NAlign = 3,
 NField = 32,
 NBit = 8 * sizeof(bits),
};
struct Target {
 char name[16];
 char apple;
 char windows;
 int gpr0;
 int ngpr;
 int fpr0;
 int nfpr;
 bits rglob;
 int nrglob;
 int *rsave;
 int nrsave[2];
 bits (*retregs)(Ref, int[2]);
 bits (*argregs)(Ref, int[2]);
 int (*memargs)(int);
 void (*abi0)(Fn *);
 void (*abi1)(Fn *);
 void (*isel)(Fn *);
 void (*emitfn)(Fn *, FILE *);
 void (*emitfin)(FILE *);
 char asloc[4];
 char assym[4];
 uint cansel:1;
};
enum {
 RXX = 0,
 Tmp0 = NBit,
};
struct BSet {
 uint nt;
 bits *t;
};
struct Ref {
 uint type:3;
 uint val:29;
};
enum {
 RTmp,
 RCon,
 RInt,
 RType,
 RSlot,
 RCall,
 RMem,
};
static inline int req(Ref a, Ref b)
{
 return a.type == b.type && a.val == b.val;
}
static inline int rtype(Ref r)
{
 if (req(r, (Ref){RTmp, 0}))
  return -1;
 return r.type;
}
static inline int rsval(Ref r)
{
 return ((int)r.val ^ 0x10000000) - 0x10000000;
}
enum CmpI {
 Cieq,
 Cine,
 Cisge,
 Cisgt,
 Cisle,
 Cislt,
 Ciuge,
 Ciugt,
 Ciule,
 Ciult,
 NCmpI,
};
enum CmpF {
 Cfeq,
 Cfge,
 Cfgt,
 Cfle,
 Cflt,
 Cfne,
 Cfo,
 Cfuo,
 NCmpF,
 NCmp = NCmpI + NCmpF,
};
enum O {
 Oxxx,
Oadd,
Osub,
Oneg,
Odiv,
Orem,
Oudiv,
Ourem,
Omul,
Oand,
Oor,
Oxor,
Osar,
Oshr,
Oshl,
Oceqw,
Ocnew,
Ocsgew,
Ocsgtw,
Ocslew,
Ocsltw,
Ocugew,
Ocugtw,
Oculew,
Ocultw,
Oceql,
Ocnel,
Ocsgel,
Ocsgtl,
Ocslel,
Ocsltl,
Ocugel,
Ocugtl,
Oculel,
Ocultl,
Oceqs,
Ocges,
Ocgts,
Ocles,
Oclts,
Ocnes,
Ocos,
Ocuos,
Oceqd,
Ocged,
Ocgtd,
Ocled,
Ocltd,
Ocned,
Ocod,
Ocuod,
Ostoreb,
Ostoreh,
Ostorew,
Ostorel,
Ostores,
Ostored,
Oloadsb,
Oloadub,
Oloadsh,
Oloaduh,
Oloadsw,
Oloaduw,
Oload,
Oextsb,
Oextub,
Oextsh,
Oextuh,
Oextsw,
Oextuw,
Oexts,
Otruncd,
Ostosi,
Ostoui,
Odtosi,
Odtoui,
Oswtof,
Ouwtof,
Osltof,
Oultof,
Ocast,
Oalloc4,
Oalloc8,
Oalloc16,
Ovaarg,
Ovastart,
Ocopy,
Odbgloc,
Onop,
Oaddr,
Oblit0,
Oblit1,
Osel0,
Osel1,
Oswap,
Osign,
Osalloc,
Oxidiv,
Oxdiv,
Oxcmp,
Oxtest,
Oacmp,
Oacmn,
Oafcmp,
Oreqz,
Ornez,
Opar,
Oparsb,
Oparub,
Oparsh,
Oparuh,
Oparc,
Opare,
Oarg,
Oargsb,
Oargub,
Oargsh,
Oarguh,
Oargc,
Oarge,
Oargv,
Ocall,
Oflagieq,
Oflagine,
Oflagisge,
Oflagisgt,
Oflagisle,
Oflagislt,
Oflagiuge,
Oflagiugt,
Oflagiule,
Oflagiult,
Oflagfeq,
Oflagfge,
Oflagfgt,
Oflagfle,
Oflagflt,
Oflagfne,
Oflagfo,
Oflagfuo,
Oxselieq,
Oxseline,
Oxselisge,
Oxselisgt,
Oxselisle,
Oxselislt,
Oxseliuge,
Oxseliugt,
Oxseliule,
Oxseliult,
Oxselfeq,
Oxselfge,
Oxselfgt,
Oxselfle,
Oxselflt,
Oxselfne,
Oxselfo,
Oxselfuo,
 NOp,
};
enum J {
 Jxxx,
 Jretw, Jretl, Jrets, Jretd, Jretsb, Jretub, Jretsh, Jretuh, Jretc, Jret0, Jjmp, Jjnz, Jjfieq, Jjfine, Jjfisge, Jjfisgt, Jjfisle, Jjfislt, Jjfiuge, Jjfiugt, Jjfiule, Jjfiult, Jjffeq, Jjffge, Jjffgt, Jjffle, Jjfflt, Jjffne, Jjffo, Jjffuo, Jhlt,
 NJmp
};
enum {
 Ocmpw = Oceqw,
 Ocmpw1 = Ocultw,
 Ocmpl = Oceql,
 Ocmpl1 = Ocultl,
 Ocmps = Oceqs,
 Ocmps1 = Ocuos,
 Ocmpd = Oceqd,
 Ocmpd1 = Ocuod,
 Oalloc = Oalloc4,
 Oalloc1 = Oalloc16,
 Oflag = Oflagieq,
 Oflag1 = Oflagfuo,
 Oxsel = Oxselieq,
 Oxsel1 = Oxselfuo,
 NPubOp = Onop,
 Jjf = Jjfieq,
 Jjf1 = Jjffuo,
};
enum {
 Kx = -1,
 Kw,
 Kl,
 Ks,
 Kd
};
struct Op {
 char *name;
 short argcls[2][4];
 uint canfold:1;
 uint hasid:1;
 uint idval:1;
 uint commutes:1;
 uint assoc:1;
 uint idemp:1;
 uint cmpeqwl:1;
 uint cmplgtewl:1;
 uint eqval:1;
 uint pinned:1;
};
struct Ins {
 uint op:30;
 uint cls:2;
 Ref to;
 Ref arg[2];
};
struct Phi {
 Ref to;
 short cls;
 int visit;
 uint narg;
 Ref *arg;
 Blk **blk;
 Phi *link;
};
struct Blk {
 Phi *phi;
 Ins *ins;
 uint nins;
 struct {
  short type;
  Ref arg;
 } jmp;
 Blk *s1;
 Blk *s2;
 Blk *link;
 uint id;
 uint visit;
 Blk *idom;
 Blk *dom, *dlink;
 Blk **fron;
 uint nfron;
 int depth;
 Blk **pred;
 uint npred;
 BSet in[1], out[1], gen[1];
 int nlive[2];
 int loop;
 char *name;
};
struct Use {
 enum {
  UXXX,
  UPhi,
  UIns,
  UJmp,
 } type;
 uint bid;
 union {
  Ins *ins;
  Phi *phi;
 } u;
};
struct Sym {
 enum {
  SGlo = 0,
  SThr = 1,
  SExt = 2,
  SExtThr = SExt|SThr,
 } type;
 uint32_t id;
};
struct Num {
 uchar n;
 uchar nl, nr;
 Ref l, r;
};
enum {
 NoAlias,
 MayAlias,
 MustAlias
};
struct Alias {
 enum {
  ABot = 0,
  ALoc = 1,
  ACon = 2,
  AEsc = 3,
  ASym = 4,
  AUnk = 6,
 } type;
 int base;
 int64_t offset;
 union {
  Sym sym;
  struct {
   int sz;
   bits m;
  } loc;
 } u;
 Alias *slot;
};
struct Tmp {
 char *name;
 Ins *def;
 Use *use;
 uint ndef, nuse;
 uint bid;
 uint cost;
 int slot;
 short cls;
 struct {
  int r;
  int w;
  bits m;
 } hint;
 int phi;
 Alias alias;
 enum {
  WFull,
  Wsb,
  Wub,
  Wsh,
  Wuh,
  Wsw,
  Wuw
 } width;
 int visit;
 uint gcmbid;
};
struct Con {
 enum {
  CUndef,
  CBits,
  CAddr,
 } type;
 Sym sym;
 union {
  int64_t i;
  double d;
  float s;
 } bits;
 char flt;
};
typedef struct Addr Addr;
struct Addr {
 Con offset;
 Ref base;
 Ref index;
 int scale;
};
struct Lnk {
 char export;
 char thread;
 char common;
 char align;
 char *sec;
 char *secf;
};
struct Fn {
 Blk *start;
 Tmp *tmp;
 Con *con;
 Mem *mem;
 int ntmp;
 int ncon;
 int nmem;
 uint nblk;
 int retty;
 Ref retr;
 Blk **rpo;
 bits reg;
 int slot;
 int salign;
 char vararg;
 char dynalloc;
 char leaf;
 char *name;
 Lnk lnk;
};
struct Typ {
 char *name;
 char isdark;
 char isunion;
 int align;
 uint64_t size;
 uint nunion;
 struct Field {
  enum {
   FEnd,
   Fb,
   Fh,
   Fw,
   Fl,
   Fs,
   Fd,
   FPad,
   FTyp,
  } type;
  uint len;
 } (*fields)[NField+1];
};
struct Dat {
 enum {
  DStart,
  DEnd,
  DB,
  DH,
  DW,
  DL,
  DZ
 } type;
 char *name;
 Lnk *lnk;
 union {
  int64_t num;
  double fltd;
  float flts;
  char *str;
  struct {
   char *name;
   int64_t off;
  } ref;
 } u;
 char isref;
 char isstr;
};
extern Target T;
extern char debug['Z'+1];
typedef enum {
 PHeap,
 PFn,
} Pool;
extern Typ *typ;
extern Ins insb[NIns], *curi;
uint32_t hash(char *);
void die_(char *, char *, ...) __attribute__((noreturn));
void *emalloc(size_t);
void *alloc(size_t);
void freeall(void);
void *vnew(ulong, size_t, Pool);
void vfree(void *);
void vgrow(void *, ulong);
void addins(Ins **, uint *, Ins *);
void addbins(Ins **, uint *, Blk *);
char *strf(Pool, char *, ...);
uint32_t intern(char *);
char *str(uint32_t);
int argcls(Ins *, int);
int isreg(Ref);
int iscmp(int, int *, int *);
void igroup(Blk *, Ins *, Ins **, Ins **);
void emit(int, int, Ref, Ref, Ref);
void emiti(Ins);
void idup(Blk *, Ins *, ulong);
Ins *icpy(Ins *, Ins *, ulong);
int cmpop(int);
int cmpwlneg(int);
int clsmerge(short *, short);
int phicls(int, Tmp *);
uint phiargn(Phi *, Blk *);
Ref phiarg(Phi *, Blk *);
Ref newtmp(char *, int, Fn *);
void chuse(Ref, int, Fn *);
int symeq(Sym, Sym);
Ref newcon(Con *, Fn *);
Ref getcon(int64_t, Fn *);
int addcon(Con *, Con *, int);
int isconbits(Fn *fn, Ref r, int64_t *v);
void salloc(Ref, Ref, Fn *);
void dumpts(BSet *, Tmp *, FILE *);
void runmatch(uchar *, Num *, Ref, Ref *);
void bsinit(BSet *, uint);
void bszero(BSet *);
uint bscount(BSet *);
void bsset(BSet *, uint);
void bsclr(BSet *, uint);
void bscopy(BSet *, BSet *);
void bsunion(BSet *, BSet *);
void bsinter(BSet *, BSet *);
void bsdiff(BSet *, BSet *);
int bsequal(BSet *, BSet *);
int bsiter(BSet *, int *);
static inline int
bshas(BSet *bs, uint elt)
{
 ((void)0);
 return (bs->t[elt/NBit] & ((bits)1 << (elt%NBit))) != 0;
}
extern Op optab[NOp];
void parse(FILE *, char *, void (char *), void (Dat *), void (Fn *));
void printfn(Fn *, FILE *);
void printref(Ref, Fn *, FILE *);
void err(char *, ...) __attribute__((noreturn));
void elimsb(Fn *);
Blk *newblk(void);
void fillpreds(Fn *);
void fillcfg(Fn *);
void filldom(Fn *);
int sdom(Blk *, Blk *);
int dom(Blk *, Blk *);
void fillfron(Fn *);
void loopiter(Fn *, void (*)(Blk *, Blk *));
void filldepth(Fn *);
Blk *lca(Blk *, Blk *);
void fillloop(Fn *);
void simpljmp(Fn *);
int reaches(Fn *, Blk *, Blk *);
int reachesnotvia(Fn *, Blk *, Blk *, Blk *);
int ifgraph(Blk *, Blk **, Blk **, Blk **);
void simplcfg(Fn *);
void promote(Fn *);
void coalesce(Fn *);
void fillalias(Fn *);
void getalias(Alias *, Ref, Fn *);
int alias(Ref, int, int, Ref, int, int *, Fn *);
int escapes(Ref, Fn *);
int loadsz(Ins *);
int storesz(Ins *);
void loadopt(Fn *);
void adduse(Tmp *, int, Blk *, ...);
void filluse(Fn *);
void ssa(Fn *);
void ssacheck(Fn *);
void narrowpars(Fn *fn);
Ref copyref(Fn *, Blk *, Ins *);
Ref phicopyref(Fn *, Blk *, Phi *);
int foldint(Con *, int, int, Con *, Con *);
Ref foldref(Fn *, Ins *);
extern Ref con01[2];
int zeroval(Fn *, Blk *, Ref, int, int *);
void gvn(Fn *);
int pinned(Ins *);
void gcm(Fn *);
void ifconvert(Fn *fn);
void simpl(Fn *);
void liveon(BSet *, Blk *, Blk *);
void filllive(Fn *);
void fillcost(Fn *);
void spill(Fn *);
void rega(Fn *);
void emitfnlnk(char *, Lnk *, FILE *);
void emitdat(Dat *, FILE *);
void emitdbgfile(char *, FILE *);
void emitdbgloc(uint, uint, FILE *);
int stashbits(bits, int);
void elf_emitfnfin(char *, FILE *);
void elf_emitfin(FILE *);
void macho_emitfin(FILE *);
void pe_emitfin(FILE *);

static void
aggreg(Blk *hd, Blk *b)
{
 int k;
 bsunion(hd->gen, b->gen);
 for (k=0; k<2; k++)
  if (b->nlive[k] > hd->nlive[k])
   hd->nlive[k] = b->nlive[k];
}
static void
tmpuse(Ref r, int use, int loop, Fn *fn)
{
 Mem *m;
 Tmp *t;
 if (rtype(r) == RMem) {
  m = &fn->mem[r.val];
  tmpuse(m->base, 1, loop, fn);
  tmpuse(m->index, 1, loop, fn);
 }
 else if (rtype(r) == RTmp && r.val >= Tmp0) {
  t = &fn->tmp[r.val];
  t->nuse += use;
  t->ndef += !use;
  t->cost += loop;
 }
}
void
fillcost(Fn *fn)
{
 int n;
 uint a;
 Blk *b;
 Ins *i;
 Tmp *t;
 Phi *p;
 loopiter(fn, aggreg);
 if (debug['S']) {
  fprintf(__stderrp, "\n> Loop information:\n");
  for (b=fn->start; b; b=b->link) {
   for (a=0; a<b->npred; ++a)
    if (b->id <= b->pred[a]->id)
     break;
   if (a != b->npred) {
    fprintf(__stderrp, "\t%-10s", b->name);
    fprintf(__stderrp, " (% 3d ", b->nlive[0]);
    fprintf(__stderrp, "% 3d) ", b->nlive[1]);
    dumpts(b->gen, fn->tmp, __stderrp);
   }
  }
 }
 for (t=fn->tmp; t-fn->tmp < fn->ntmp; t++) {
  t->cost = t-fn->tmp < Tmp0 ? 4294967295u : 0;
  t->nuse = 0;
  t->ndef = 0;
 }
 for (b=fn->start; b; b=b->link) {
  for (p=b->phi; p; p=p->link) {
   t = &fn->tmp[p->to.val];
   tmpuse(p->to, 0, 0, fn);
   for (a=0; a<p->narg; a++) {
    n = p->blk[a]->loop;
    t->cost += n;
    tmpuse(p->arg[a], 1, n, fn);
   }
  }
  n = b->loop;
  for (i=b->ins; i<&b->ins[b->nins]; i++) {
   tmpuse(i->to, 0, n, fn);
   tmpuse(i->arg[0], 1, n, fn);
   tmpuse(i->arg[1], 1, n, fn);
  }
  tmpuse(b->jmp.arg, 1, n, fn);
 }
 if (debug['S']) {
  fprintf(__stderrp, "\n> Spill costs:\n");
  for (n=Tmp0; n<fn->ntmp; n++)
   fprintf(__stderrp, "\t%-10s %d\n",
    fn->tmp[n].name,
    fn->tmp[n].cost);
  fprintf(__stderrp, "\n");
 }
}
static BSet *fst;
static Tmp *tmp;
static int ntmp;
static int locs;
static int slot4;
static int slot8;
static BSet mask[2][1];
static int
tcmp0(const void *pa, const void *pb)
{
 uint ca, cb;
 ca = tmp[*(int *)pa].cost;
 cb = tmp[*(int *)pb].cost;
 return (cb < ca) ? -1 : (cb > ca);
}
static int
tcmp1(const void *pa, const void *pb)
{
 int c;
 c = bshas(fst, *(int *)pb) - bshas(fst, *(int *)pa);
 return c ? c : tcmp0(pa, pb);
}
static Ref
slot(int t)
{
 int s;
 ((void)0);
 s = tmp[t].slot;
 if (s == -1) {
  if (((tmp[t].cls)&1)) {
   s = slot8;
   if (slot4 == slot8)
    slot4 += 2;
   slot8 += 2;
  } else {
   s = slot4;
   if (slot4 == slot8) {
    slot8 += 2;
    slot4 += 1;
   } else
    slot4 = slot8;
  }
  s += locs;
  tmp[t].slot = s;
 }
 return (Ref){RSlot, (s)&0x1fffffff};
}
static void
limit(BSet *b, int k, BSet *f)
{
 static int *tarr, maxt;
 int i, t, nt;
 nt = bscount(b);
 if (nt <= k)
  return;
 if (nt > maxt) {
  free(tarr);
  tarr = emalloc(nt * sizeof tarr[0]);
  maxt = nt;
 }
 for (i=0, t=0; bsiter(b, &t); t++) {
  bsclr(b, t);
  tarr[i++] = t;
 }
 if (nt > 1) {
  if (!f)
   qsort(tarr, nt, sizeof tarr[0], tcmp0);
  else {
   fst = f;
   qsort(tarr, nt, sizeof tarr[0], tcmp1);
  }
 }
 for (i=0; i<k && i<nt; i++)
  bsset(b, tarr[i]);
 for (; i<nt; i++)
  slot(tarr[i]);
}
static void
limit2(BSet *b1, int k1, int k2, BSet *f)
{
 BSet b2[1];
 bsinit(b2, ntmp);
 bscopy(b2, b1);
 bsinter(b1, mask[0]);
 bsinter(b2, mask[1]);
 limit(b1, T.ngpr - k1, f);
 limit(b2, T.nfpr - k2, f);
 bsunion(b1, b2);
}
static void
sethint(BSet *u, bits r)
{
 int t;
 for (t=Tmp0; bsiter(u, &t); t++)
  tmp[phicls(t, tmp)].hint.m |= r;
}
static void
reloads(BSet *u, BSet *v)
{
 int t;
 for (t=Tmp0; bsiter(u, &t); t++)
  if (!bshas(v, t))
   emit(Oload, tmp[t].cls, (Ref){RTmp, t}, slot(t), (Ref){RTmp, 0});
}
static void
store(Ref r, int s)
{
 if (s != -1)
  emit(Ostorew + tmp[r.val].cls, 0, (Ref){RTmp, 0}, r, (Ref){RSlot, (s)&0x1fffffff});
}
static int
regcpy(Ins *i)
{
 return i->op == Ocopy && isreg(i->arg[0]);
}
static Ins *
dopm(Blk *b, Ins *i, BSet *v)
{
 int n, t;
 BSet u[1];
 Ins *i1;
 bits r;
 bsinit(u, ntmp);
 i1 = ++i;
 do {
  i--;
  t = i->to.val;
  if (!req(i->to, (Ref){RTmp, 0}))
  if (bshas(v, t)) {
   bsclr(v, t);
   store(i->to, tmp[t].slot);
  }
  bsset(v, i->arg[0].val);
 } while (i != b->ins && regcpy(i-1));
 bscopy(u, v);
 if (i != b->ins && (i-1)->op == Ocall) {
  v->t[0] &= ~T.retregs((i-1)->arg[1], 0);
  limit2(v, T.nrsave[0], T.nrsave[1], 0);
  for (n=0, r=0; T.rsave[n]>=0; n++)
   r |= ((bits)1 << (T.rsave[n]));
  v->t[0] |= T.argregs((i-1)->arg[1], 0);
 } else {
  limit2(v, 0, 0, 0);
  r = v->t[0];
 }
 sethint(v, r);
 reloads(u, v);
 do
  emiti(*--i1);
 while (i1 != i);
 return i;
}
static void
merge(BSet *u, Blk *bu, BSet *v, Blk *bv)
{
 int t;
 if (bu->loop <= bv->loop)
  bsunion(u, v);
 else
  for (t=0; bsiter(v, &t); t++)
   if (tmp[t].slot == -1)
    bsset(u, t);
}
void
spill(Fn *fn)
{
 Blk *b, *s1, *s2, *hd, **bp;
 int j, l, t, k, lvarg[2];
 uint n;
 BSet u[1], v[1], w[1];
 Ins *i;
 Phi *p;
 Mem *m;
 bits r;
 tmp = fn->tmp;
 ntmp = fn->ntmp;
 bsinit(u, ntmp);
 bsinit(v, ntmp);
 bsinit(w, ntmp);
 bsinit(mask[0], ntmp);
 bsinit(mask[1], ntmp);
 locs = fn->slot;
 slot4 = 0;
 slot8 = 0;
 for (t=0; t<ntmp; t++) {
  k = 0;
  if (t >= T.fpr0 && t < T.fpr0 + T.nfpr)
   k = 1;
  if (t >= Tmp0)
   k = ((tmp[t].cls)>>1);
  bsset(mask[k], t);
 }
 for (bp=&fn->rpo[fn->nblk]; bp!=fn->rpo;) {
  b = *--bp;
  curi = 0;
  s1 = b->s1;
  s2 = b->s2;
  hd = 0;
  if (s1 && s1->id <= b->id)
   hd = s1;
  if (s2 && s2->id <= b->id)
  if (!hd || s2->id >= hd->id)
   hd = s2;
  if (hd) {
   bszero(v);
   hd->gen->t[0] |= T.rglob;
   for (k=0; k<2; k++) {
    n = k == 0 ? T.ngpr : T.nfpr;
    bscopy(u, b->out);
    bsinter(u, mask[k]);
    bscopy(w, u);
    bsinter(u, hd->gen);
    bsdiff(w, hd->gen);
    if (bscount(u) < n) {
     j = bscount(w);
     l = hd->nlive[k];
     limit(w, n - (l - j), 0);
     bsunion(u, w);
    } else
     limit(u, n, 0);
    bsunion(v, u);
   }
  } else if (s1) {
   bszero(v);
   liveon(w, b, s1);
   merge(v, b, w, s1);
   if (s2) {
    liveon(u, b, s2);
    merge(v, b, u, s2);
    bsinter(w, u);
   }
   limit2(v, 0, 0, w);
  } else {
   bscopy(v, b->out);
   if (rtype(b->jmp.arg) == RCall)
    v->t[0] |= T.retregs(b->jmp.arg, 0);
  }
  if (rtype(b->jmp.arg) == RTmp) {
   t = b->jmp.arg.val;
   ((void)0);
   bsset(v, t);
   limit2(v, 0, 0, ((void *)0));
   if (!bshas(v, t))
    b->jmp.arg = slot(t);
  }
  for (t=Tmp0; bsiter(b->out, &t); t++)
   if (!bshas(v, t))
    slot(t);
  bscopy(b->out, v);
  curi = &insb[NIns];
  for (i=&b->ins[b->nins]; i!=b->ins;) {
   i--;
   if (regcpy(i)) {
    i = dopm(b, i, v);
    continue;
   }
   bszero(w);
   if (!req(i->to, (Ref){RTmp, 0})) {
    ((void)0);
    t = i->to.val;
    if (bshas(v, t))
     bsclr(v, t);
    else {
     ((void)0);
     bsset(v, t);
     bsset(w, t);
    }
   }
   j = T.memargs(i->op);
   for (n=0; n<2; n++)
    if (rtype(i->arg[n]) == RMem)
     j--;
   for (n=0; n<2; n++)
    switch (rtype(i->arg[n])) {
    case RMem:
     t = i->arg[n].val;
     m = &fn->mem[t];
     if (rtype(m->base) == RTmp) {
      bsset(v, m->base.val);
      bsset(w, m->base.val);
     }
     if (rtype(m->index) == RTmp) {
      bsset(v, m->index.val);
      bsset(w, m->index.val);
     }
     break;
    case RTmp:
     t = i->arg[n].val;
     lvarg[n] = bshas(v, t);
     bsset(v, t);
     if (j-- <= 0)
      bsset(w, t);
     break;
    }
   bscopy(u, v);
   limit2(v, 0, 0, w);
   for (n=0; n<2; n++)
    if (rtype(i->arg[n]) == RTmp) {
     t = i->arg[n].val;
     if (!bshas(v, t)) {
      if (!lvarg[n])
       bsclr(u, t);
      i->arg[n] = slot(t);
     }
    }
   reloads(u, v);
   if (!req(i->to, (Ref){RTmp, 0})) {
    t = i->to.val;
    store(i->to, tmp[t].slot);
    if (t >= Tmp0)
     bsclr(v, t);
   }
   emiti(*i);
   r = v->t[0];
   if (r)
    sethint(v, r);
  }
  if (b == fn->start)
   ((void)0);
  else
   ((void)0);
  for (p=b->phi; p; p=p->link) {
   ((void)0);
   t = p->to.val;
   if (bshas(v, t)) {
    bsclr(v, t);
    store(p->to, tmp[t].slot);
   } else if (bshas(b->in, t))
    p->to = slot(p->to.val);
  }
  bscopy(b->in, v);
  idup(b, curi, &insb[NIns]-curi);
 }
 slot8 += slot8 & 3;
 fn->slot += slot8;
 if (debug['S']) {
  fprintf(__stderrp, "\n> Block information:\n");
  for (b=fn->start; b; b=b->link) {
   fprintf(__stderrp, "\t%-10s (% 5d) ", b->name, b->loop);
   dumpts(b->out, fn->tmp, __stderrp);
  }
  fprintf(__stderrp, "\n> After spilling:\n");
  printfn(fn, __stderrp);
 }
}
