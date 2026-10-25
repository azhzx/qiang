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

typedef struct Range Range;
typedef struct Store Store;
typedef struct Slot Slot;
void
promote(Fn *fn)
{
 Blk *b;
 Ins *i, *l;
 Tmp *t;
 Use *u, *ue;
 int s, k;
 b = fn->start;
 for (i=b->ins; i<&b->ins[b->nins]; i++) {
  if (Oalloc > i->op || i->op > Oalloc1)
   continue;
  ((void)0);
  t = &fn->tmp[i->to.val];
  if (t->ndef != 1)
   goto Skip;
  k = -1;
  s = -1;
  for (u=t->use; u<&t->use[t->nuse]; u++) {
   if (u->type != UIns)
    goto Skip;
   l = u->u.ins;
   if (((unsigned)(l->op) - Oloadsb <= Oload - Oloadsb))
   if (s == -1 || s == loadsz(l)) {
    s = loadsz(l);
    continue;
   }
   if (((unsigned)(l->op) - Ostoreb <= Ostored - Ostoreb))
   if (req(i->to, l->arg[1]) && !req(i->to, l->arg[0]))
   if (s == -1 || s == storesz(l))
   if (k == -1 || k == optab[l->op].argcls[0][0]) {
    s = storesz(l);
    k = optab[l->op].argcls[0][0];
    continue;
   }
   goto Skip;
  }
  *i = (Ins){.op = Onop};
  t->ndef--;
  ue = &t->use[t->nuse];
  for (u=t->use; u!=ue; u++) {
   l = u->u.ins;
   if (((unsigned)(l->op) - Ostoreb <= Ostored - Ostoreb)) {
    l->cls = k;
    l->op = Ocopy;
    l->to = l->arg[1];
    l->arg[1] = (Ref){RTmp, 0};
    t->nuse--;
    t->ndef++;
   } else {
    if (k == -1)
     err("slot %%%s is read but never stored to",
      fn->tmp[l->arg[0].val].name);
    switch(l->op) {
    case Oloadsw:
    case Oloaduw:
     if (k == Kl)
      goto Extend;
    case Oload:
     if (((k)>>1) != ((l->cls)>>1))
      l->op = Ocast;
     else
      l->op = Ocopy;
     break;
    default:
    Extend:
     l->op = Oextsb + (l->op - Oloadsb);
     break;
    }
   }
  }
 Skip:;
 }
 if (debug['M']) {
  fprintf(__stderrp, "\n> After slot promotion:\n");
  printfn(fn, __stderrp);
 }
}
struct Range {
 int a, b;
};
struct Store {
 int ip;
 Ins *i;
};
struct Slot {
 int t;
 int sz;
 bits m;
 bits l;
 Range r;
 Slot *s;
 Store *st;
 int nst;
};
static inline int
rin(Range r, int n)
{
 return r.a <= n && n < r.b;
}
static inline int
rovlap(Range r0, Range r1)
{
 return r0.b && r1.b && r0.a < r1.b && r1.a < r0.b;
}
static void
radd(Range *r, int n)
{
 if (!r->b)
  *r = (Range){n, n+1};
 else if (n < r->a)
  r->a = n;
 else if (n >= r->b)
  r->b = n+1;
}
static int
slot(Slot **ps, int64_t *off, Ref r, Fn *fn, Slot *sl)
{
 Alias a;
 Tmp *t;
 getalias(&a, r, fn);
 if (a.type != ALoc)
  return 0;
 t = &fn->tmp[a.base];
 if (t->visit < 0)
  return 0;
 *off = a.offset;
 *ps = &sl[t->visit];
 return 1;
}
static void
load(Ref r, bits x, int ip, Fn *fn, Slot *sl)
{
 int64_t off;
 Slot *s;
 if (slot(&s, &off, r, fn, sl)) {
  s->l |= x << off;
  s->l &= s->m;
  if (s->l)
   radd(&s->r, ip);
 }
}
static void
store(Ref r, bits x, int ip, Ins *i, Fn *fn, Slot *sl)
{
 int64_t off;
 Slot *s;
 if (slot(&s, &off, r, fn, sl)) {
  if (s->l) {
   radd(&s->r, ip);
   s->l &= ~(x << off);
  } else {
   vgrow(&s->st, ++s->nst);
   s->st[s->nst-1].ip = ip;
   s->st[s->nst-1].i = i;
  }
 }
}
static int
scmp(const void *pa, const void *pb)
{
 Slot *a, *b;
 a = (Slot *)pa, b = (Slot *)pb;
 if (a->sz != b->sz)
  return b->sz - a->sz;
 return a->r.a - b->r.a;
}
static void
maxrpo(Blk *hd, Blk *b)
{
 if (hd->loop < (int)b->id)
  hd->loop = b->id;
}
void
coalesce(Fn *fn)
{
 Range r, *br;
 Slot *s, *s0, *sl;
 Blk *b, **ps, *succ[3];
 Ins *i, **bl;
 Use *u;
 Tmp *t, *ts;
 Ref *arg;
 bits x;
 int64_t off0, off1;
 int n, m, ip, sz, nsl, nbl, *stk;
 uint total, freed, fused;
 nsl = 0;
 sl = vnew(0, sizeof sl[0], PHeap);
 for (n=Tmp0; n<fn->ntmp; n++) {
  t = &fn->tmp[n];
  t->visit = -1;
  if (t->alias.type == ALoc)
  if (t->alias.slot == &t->alias)
  if (t->bid == fn->start->id)
  if (t->alias.u.loc.sz != -1) {
   t->visit = nsl;
   vgrow(&sl, ++nsl);
   s = &sl[nsl-1];
   s->t = n;
   s->sz = t->alias.u.loc.sz;
   s->m = t->alias.u.loc.m;
   s->s = 0;
   s->st = vnew(0, sizeof s->st[0], PHeap);
   s->nst = 0;
  }
 }
 for (b=fn->start; b; b=b->link)
  b->loop = -1;
 loopiter(fn, maxrpo);
 nbl = 0;
 bl = vnew(0, sizeof bl[0], PHeap);
 br = emalloc(fn->nblk * sizeof br[0]);
 ip = 2147483647 - 1;
 for (n=fn->nblk-1; n>=0; n--) {
  b = fn->rpo[n];
  succ[0] = b->s1;
  succ[1] = b->s2;
  succ[2] = 0;
  br[n].b = ip--;
  for (s=sl; s<&sl[nsl]; s++) {
   s->l = 0;
   for (ps=succ; *ps; ps++) {
    m = (*ps)->id;
    if (m > n && rin(s->r, br[m].a)) {
     s->l = s->m;
     radd(&s->r, ip);
    }
   }
  }
  if (b->jmp.type == Jretc)
   load(b->jmp.arg, -1, --ip, fn, sl);
  for (i=&b->ins[b->nins]; i!=b->ins;) {
   --i;
   arg = i->arg;
   if (i->op == Oargc) {
    load(arg[1], -1, --ip, fn, sl);
   }
   if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb)) {
    x = ((bits)1 << (loadsz(i))) - 1;
    load(arg[0], x, --ip, fn, sl);
   }
   if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb)) {
    x = ((bits)1 << (storesz(i))) - 1;
    store(arg[1], x, ip--, i, fn, sl);
   }
   if (i->op == Oblit0) {
    ((void)0);
    ((void)0);
    sz = abs(rsval((i+1)->arg[0]));
    x = sz >= NBit ? (bits)-1 : ((bits)1 << (sz)) - 1;
    store(arg[1], x, ip--, i, fn, sl);
    load(arg[0], x, ip, fn, sl);
    vgrow(&bl, ++nbl);
    bl[nbl-1] = i;
   }
  }
  for (s=sl; s<&sl[nsl]; s++)
   if (s->l) {
    radd(&s->r, ip);
    if (b->loop != -1) {
     ((void)0);
     radd(&s->r, br[b->loop].b - 1);
    }
   }
  br[n].a = ip;
 }
 free(br);
 for (s=sl; s<&sl[nsl]; s++)
  for (n=0; n<s->nst; n++)
   if (!rin(s->r, s->st[n].ip)) {
    i = s->st[n].i;
    if (i->op == Oblit0)
     *(i+1) = (Ins){.op = Onop};
    *i = (Ins){.op = Onop};
   }
 total = 0;
 freed = 0;
 stk = vnew(0, sizeof stk[0], PHeap);
 n = 0;
 for (s=s0=sl; s<&sl[nsl]; s++) {
  total += s->sz;
  if (!s->r.b) {
   vfree(s->st);
   vgrow(&stk, ++n);
   stk[n-1] = s->t;
   freed += s->sz;
  } else
   *s0++ = *s;
 }
 nsl = s0-sl;
 if (debug['M']) {
  fputs("\n> Slot coalescing:\n", __stderrp);
  if (n) {
   fputs("\tkill [", __stderrp);
   for (m=0; m<n; m++)
    fprintf(__stderrp, " %%%s",
     fn->tmp[stk[m]].name);
   fputs(" ]\n", __stderrp);
  }
 }
 while (n--) {
  t = &fn->tmp[stk[n]];
  ((void)0);
  i = t->def;
  if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb)) {
   i->op = Ocopy;
   i->arg[0] = (Ref){RCon, 0};
   continue;
  }
  *i = (Ins){.op = Onop};
  for (u=t->use; u<&t->use[t->nuse]; u++) {
   if (u->type == UJmp) {
    b = fn->rpo[u->bid];
    ((void)0);
    b->jmp.type = Jret0;
    b->jmp.arg = (Ref){RTmp, 0};
    continue;
   }
   ((void)0);
   i = u->u.ins;
   if (!req(i->to, (Ref){RTmp, 0})) {
    ((void)0);
    vgrow(&stk, ++n);
    stk[n-1] = i->to.val;
   } else if (((unsigned)(i->op) - Oarg <= Oargv - Oarg)) {
    ((void)0);
    i->arg[1] = (Ref){RCon, 1};
   } else {
    if (i->op == Oblit0)
     *(i+1) = (Ins){.op = Onop};
    *i = (Ins){.op = Onop};
   }
  }
 }
 vfree(stk);
 qsort(sl, nsl, sizeof *sl, scmp);
 fused = 0;
 for (n=0; n<nsl; n++) {
  s0 = &sl[n];
  if (s0->s)
   continue;
  s0->s = s0;
  r = s0->r;
  for (s=s0+1; s<&sl[nsl]; s++) {
   if (s->s || !s->r.b)
    goto Skip;
   if (rovlap(r, s->r))
    for (m=n; &sl[m]<s; m++)
     if (sl[m].s == s0)
     if (rovlap(sl[m].r, s->r))
      goto Skip;
   radd(&r, s->r.a);
   radd(&r, s->r.b - 1);
   s->s = s0;
   fused += s->sz;
  Skip:;
  }
 }
 for (s=sl; s<&sl[nsl]; s++) {
  t = &fn->tmp[s->t];
  t->visit = s-sl;
  ((void)0);
  if (s->s == s)
   continue;
  *t->def = (Ins){.op = Onop};
  ts = &fn->tmp[s->s->t];
  ((void)0);
  if (t->def < ts->def) {
   *t->def = *ts->def;
   *ts->def = (Ins){.op = Onop};
   ts->def = t->def;
  }
  for (u=t->use; u<&t->use[t->nuse]; u++) {
   if (u->type == UJmp) {
    b = fn->rpo[u->bid];
    b->jmp.arg = (Ref){RTmp, s->s->t};
    continue;
   }
   ((void)0);
   arg = u->u.ins->arg;
   for (n=0; n<2; n++)
    if (req(arg[n], (Ref){RTmp, s->t}))
     arg[n] = (Ref){RTmp, s->s->t};
  }
 }
 for (n=0; n<nbl; n++) {
  i = bl[n];
  if (i->op == Oblit0)
  if (slot(&s, &off0, i->arg[0], fn, sl))
  if (slot(&s0, &off1, i->arg[1], fn, sl))
  if (s->s == s0->s) {
   if (off0 < off1) {
    sz = rsval((i+1)->arg[0]);
    ((void)0);
    (i+1)->arg[0] = (Ref){RInt, (-sz)&0x1fffffff};
   } else if (off0 == off1) {
    *i = (Ins){.op = Onop};
    *(i+1) = (Ins){.op = Onop};
   }
  }
 }
 vfree(bl);
 if (debug['M']) {
  for (s0=sl; s0<&sl[nsl]; s0++) {
   if (s0->s != s0)
    continue;
   fprintf(__stderrp, "\tfuse (% 3db) [", s0->sz);
   for (s=s0; s<&sl[nsl]; s++) {
    if (s->s != s0)
     continue;
    fprintf(__stderrp, " %%%s", fn->tmp[s->t].name);
    if (s->r.b)
     fprintf(__stderrp, "[%d,%d)",
      s->r.a-ip, s->r.b-ip);
    else
     fputs("{}", __stderrp);
   }
   fputs(" ]\n", __stderrp);
  }
  fprintf(__stderrp, "\tsums %u/%u/%u (killed/fused/total)\n\n",
   freed, fused, total);
  printfn(fn, __stderrp);
 }
 for (s=sl; s<&sl[nsl]; s++)
  vfree(s->st);
 vfree(sl);
}
