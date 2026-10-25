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
typedef __builtin_va_list va_list;

typedef struct Bitset Bitset;
typedef struct Vec Vec;
typedef struct Bucket Bucket;
struct Vec {
 ulong mag;
 Pool pool;
 size_t esz;
 ulong cap;
 union {
  long long ll;
  long double ld;
  void *ptr;
 } align[];
};
struct Bucket {
 uint nstr;
 char **str;
};
enum {
 VMin = 2,
 VMag = 0xcabba9e,
 NPtr = 256,
 IBits = 12,
 IMask = (1<<IBits) - 1,
};
Typ *typ;
Ins insb[NIns], *curi;
static void *ptr[NPtr];
static void **pool = ptr;
static int nptr = 1;
static Bucket itbl[IMask+1];
uint32_t
hash(char *s)
{
 uint32_t h;
 for (h=0; *s; ++s)
  h = *s + 17*h;
 return h;
}
void
die_(char *file, char *s, ...)
{
 va_list ap;
 fprintf(__stderrp, "%s: dying: ", file);
 __builtin_va_start(ap, s);
 vfprintf(__stderrp, s, ap);
 __builtin_va_end(ap);
 fputc('\n', __stderrp);
 abort();
}
void *
emalloc(size_t n)
{
 void *p;
 p = calloc(1, n);
 if (!p)
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/util.c", "emalloc, out of memory");
 return p;
}
void *
alloc(size_t n)
{
 void **pp;
 if (n == 0)
  return 0;
 if (nptr >= NPtr) {
  pp = emalloc(NPtr * sizeof(void *));
  pp[0] = pool;
  pool = pp;
  nptr = 1;
 }
 return pool[nptr++] = emalloc(n);
}
void
freeall()
{
 void **pp;
 for (;;) {
  for (pp = &pool[1]; pp < &pool[nptr]; pp++)
   free(*pp);
  pp = pool[0];
  if (!pp)
   break;
  free(pool);
  pool = pp;
  nptr = NPtr;
 }
 nptr = 1;
}
void *
vnew(ulong len, size_t esz, Pool pool)
{
 void *(*f)(size_t);
 ulong cap;
 Vec *v;
 for (cap=VMin; cap<len; cap*=2)
  ;
 f = pool == PHeap ? emalloc : alloc;
 v = f(cap * esz + sizeof(Vec));
 v->mag = VMag;
 v->cap = cap;
 v->esz = esz;
 v->pool = pool;
 return v + 1;
}
void
vfree(void *p)
{
 Vec *v;
 v = (Vec *)p - 1;
 ((void)0);
 if (v->pool == PHeap) {
  v->mag = 0;
  free(v);
 }
}
void
vgrow(void *vp, ulong len)
{
 Vec *v;
 void *v1;
 v = *(Vec **)vp - 1;
 ((void)0);
 if (v->cap >= len)
  return;
 v1 = vnew(len, v->esz, v->pool);
 memcpy(v1, v+1, v->cap * v->esz);
 vfree(v+1);
 *(Vec **)vp = v1;
}
void
addins(Ins **pvins, uint *pnins, Ins *i)
{
 if (i->op == Onop)
  return;
 vgrow(pvins, ++(*pnins));
 (*pvins)[(*pnins)-1] = *i;
}
void
addbins(Ins **pvins, uint *pnins, Blk *b)
{
 Ins *i;
 for (i=b->ins; i<&b->ins[b->nins]; i++)
  addins(pvins, pnins, i);
}
char *
strf(Pool pool, char *s, ...)
{
 va_list ap;
 int n;
 char *p;
 __builtin_va_start(ap, s);
 n = vsnprintf(((void *)0), 0, s, ap);
 __builtin_va_end(ap);
 p = (pool == PFn ? alloc : emalloc)(n + 1);
 __builtin_va_start(ap, s);
 vsnprintf(p, n + 1, s, ap);
 __builtin_va_end(ap);
 return p;
}
uint32_t
intern(char *s)
{
 Bucket *b;
 uint32_t h;
 uint i, n;
 h = hash(s) & IMask;
 b = &itbl[h];
 n = b->nstr;
 for (i=0; i<n; i++)
  if (strcmp(s, b->str[i]) == 0)
   return h + (i<<IBits);
 if (n == 1<<(32-IBits))
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/util.c", "interning table overflow");
 if (n == 0)
  b->str = vnew(1, sizeof b->str[0], PHeap);
 else if ((n & (n-1)) == 0)
  vgrow(&b->str, n+n);
 b->str[n] = emalloc(strlen(s)+1);
 b->nstr = n + 1;
 strcpy(b->str[n], s);
 return h + (n<<IBits);
}
char *
str(uint32_t id)
{
 ((void)0);
 return itbl[id&IMask].str[id>>IBits];
}
int
isreg(Ref r)
{
 return rtype(r) == RTmp && r.val < Tmp0;
}
int
iscmp(int op, int *pk, int *pc)
{
 if (Ocmpw <= op && op <= Ocmpw1) {
  *pc = op - Ocmpw;
  *pk = Kw;
 }
 else if (Ocmpl <= op && op <= Ocmpl1) {
  *pc = op - Ocmpl;
  *pk = Kl;
 }
 else if (Ocmps <= op && op <= Ocmps1) {
  *pc = NCmpI + op - Ocmps;
  *pk = Ks;
 }
 else if (Ocmpd <= op && op <= Ocmpd1) {
  *pc = NCmpI + op - Ocmpd;
  *pk = Kd;
 }
 else
  return 0;
 return 1;
}
void
igroup(Blk *b, Ins *i, Ins **i0, Ins **i1)
{
 Ins *ib, *ie;
 ib = b->ins;
 ie = ib + b->nins;
 switch (i->op) {
 case Oblit0:
  *i0 = i;
  *i1 = i + 2;
  return;
 case Oblit1:
  *i0 = i - 1;
  *i1 = i + 1;
  return;
 case_Opar:
  for (; i>ib && ((unsigned)((i-1)->op) - Opar <= Opare - Opar); i--)
   ;
  *i0 = i;
  for (; i<ie && ((unsigned)(i->op) - Opar <= Opare - Opar); i++)
   ;
  *i1 = i;
  return;
 case Ocall:
 case_Oarg:
  for (; i>ib && ((unsigned)((i-1)->op) - Oarg <= Oargv - Oarg); i--)
   ;
  *i0 = i;
  for (; i<ie && i->op != Ocall; i++)
   ;
  ((void)0);
  *i1 = i + 1;
  return;
 case Osel1:
  for (; i>ib && (i-1)->op == Osel1; i--)
   ;
  ((void)0);
 case Osel0:
  *i0 = i++;
  for (; i<ie && i->op == Osel1; i++)
   ;
  *i1 = i;
  return;
 default:
  if (((unsigned)(i->op) - Opar <= Opare - Opar))
   goto case_Opar;
  if (((unsigned)(i->op) - Oarg <= Oargv - Oarg))
   goto case_Oarg;
  *i0 = i;
  *i1 = i + 1;
  return;
 }
}
int
argcls(Ins *i, int n)
{
 return optab[i->op].argcls[n][i->cls];
}
void
emit(int op, int k, Ref to, Ref arg0, Ref arg1)
{
 if (curi == insb)
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/util.c", "emit, too many instructions");
 *--curi = (Ins){
  .op = op, .cls = k,
  .to = to, .arg = {arg0, arg1}
 };
}
void
emiti(Ins i)
{
 emit(i.op, i.cls, i.to, i.arg[0], i.arg[1]);
}
void
idup(Blk *b, Ins *s, ulong n)
{
 vgrow(&b->ins, n);
 icpy(b->ins, s, n);
 b->nins = n;
}
Ins *
icpy(Ins *d, Ins *s, ulong n)
{
 if (n)
  memmove(d, s, n * sizeof(Ins));
 return d + n;
}
static int cmptab[][2] ={
 [Ciule] = {Ciugt, Ciuge},
 [Ciult] = {Ciuge, Ciugt},
 [Ciugt] = {Ciule, Ciult},
 [Ciuge] = {Ciult, Ciule},
 [Cisle] = {Cisgt, Cisge},
 [Cislt] = {Cisge, Cisgt},
 [Cisgt] = {Cisle, Cislt},
 [Cisge] = {Cislt, Cisle},
 [Cieq] = {Cine, Cieq},
 [Cine] = {Cieq, Cine},
 [NCmpI+Cfle] = {-1, NCmpI+Cfge},
 [NCmpI+Cflt] = {-1, NCmpI+Cfgt},
 [NCmpI+Cfgt] = {-1, NCmpI+Cflt},
 [NCmpI+Cfge] = {-1, NCmpI+Cfle},
 [NCmpI+Cfeq] = {-1, NCmpI+Cfeq},
 [NCmpI+Cfne] = {-1, NCmpI+Cfne},
 [NCmpI+Cfo] = {-1, NCmpI+Cfo},
 [NCmpI+Cfuo] = {-1, NCmpI+Cfuo},
};
int
cmpop(int c)
{
 ((void)0);
 return cmptab[c][1];
}
int
cmpwlneg(int op)
{
 if (((unsigned)(op) - Ocmpw <= Ocmpw1 - Ocmpw))
  return cmptab[op - Ocmpw][0] + Ocmpw;
 if (((unsigned)(op) - Ocmpl <= Ocmpl1 - Ocmpl))
  return cmptab[op - Ocmpl][0] + Ocmpl;
 die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/util.c", "not a wl comparison");
}
int
clsmerge(short *pk, short k)
{
 short k1;
 k1 = *pk;
 if (k1 == Kx) {
  *pk = k;
  return 0;
 }
 if ((k1 == Kw && k == Kl) || (k1 == Kl && k == Kw)) {
  *pk = Kw;
  return 0;
 }
 return k1 != k;
}
int
phicls(int t, Tmp *tmp)
{
 int t1;
 t1 = tmp[t].phi;
 if (!t1)
  return t;
 t1 = phicls(t1, tmp);
 tmp[t].phi = t1;
 return t1;
}
uint
phiargn(Phi *p, Blk *b)
{
 uint n;
 if (p)
  for (n=0; n<p->narg; n++)
   if (p->blk[n] == b)
    return n;
 return -1;
}
Ref
phiarg(Phi *p, Blk *b)
{
 uint n;
 n = phiargn(p, b);
 ((void)0);
 return p->arg[n];
}
Ref
newtmp(char *prfx, int k, Fn *fn)
{
 static int n;
 int t;
 t = fn->ntmp++;
 vgrow(&fn->tmp, fn->ntmp);
 memset(&fn->tmp[t], 0, sizeof(Tmp));
 if (prfx)
  fn->tmp[t].name = strf(PFn, "%s.%d", prfx, ++n);
 fn->tmp[t].cls = k;
 fn->tmp[t].slot = -1;
 fn->tmp[t].nuse = +1;
 fn->tmp[t].ndef = +1;
 return (Ref){RTmp, t};
}
void
chuse(Ref r, int du, Fn *fn)
{
 if (rtype(r) == RTmp)
  fn->tmp[r.val].nuse += du;
}
int
symeq(Sym s0, Sym s1)
{
 return s0.type == s1.type && s0.id == s1.id;
}
Ref
newcon(Con *c0, Fn *fn)
{
 Con *c1;
 int i;
 for (i=1; i<fn->ncon; i++) {
  c1 = &fn->con[i];
  if (c0->type == c1->type
  && symeq(c0->sym, c1->sym)
  && c0->bits.i == c1->bits.i)
   return (Ref){RCon, i};
 }
 vgrow(&fn->con, ++fn->ncon);
 fn->con[i] = *c0;
 return (Ref){RCon, i};
}
Ref
getcon(int64_t val, Fn *fn)
{
 int c;
 for (c=1; c<fn->ncon; c++)
  if (fn->con[c].type == CBits
  && fn->con[c].bits.i == val)
   return (Ref){RCon, c};
 vgrow(&fn->con, ++fn->ncon);
 fn->con[c] = (Con){.type = CBits, .bits.i = val};
 return (Ref){RCon, c};
}
int
addcon(Con *c0, Con *c1, int m)
{
 if (m != 1 && c1->type == CAddr)
  return 0;
 if (c0->type == CUndef) {
  *c0 = *c1;
  c0->bits.i *= m;
 } else {
  if (c1->type == CAddr) {
   if (c0->type == CAddr)
    return 0;
   c0->type = CAddr;
   c0->sym = c1->sym;
  }
  c0->bits.i += c1->bits.i * m;
 }
 return 1;
}
int
isconbits(Fn *fn, Ref r, int64_t *v)
{
 Con *c;
 if (rtype(r) == RCon) {
  c = &fn->con[r.val];
  if (c->type == CBits) {
   *v = c->bits.i;
   return 1;
  }
 }
 return 0;
}
void
salloc(Ref rt, Ref rs, Fn *fn)
{
 Ref r0, r1;
 int64_t sz;
 fn->dynalloc = 1;
 if (rtype(rs) == RCon) {
  sz = fn->con[rs.val].bits.i;
  if (sz < 0 || sz >= 2147483647 -15)
   err("invalid alloc size %""ld", sz);
  sz = (sz + 15) & -16;
  emit(Osalloc, Kl, rt, getcon(sz, fn), (Ref){RTmp, 0});
 } else {
  r0 = newtmp("isel", Kl, fn);
  r1 = newtmp("isel", Kl, fn);
  emit(Osalloc, Kl, rt, r0, (Ref){RTmp, 0});
  emit(Oand, Kl, r0, r1, getcon(-16, fn));
  emit(Oadd, Kl, r1, rs, getcon(15, fn));
  if (fn->tmp[rs.val].slot != -1)
   err("unlikely alloc argument %%%s for %%%s",
    fn->tmp[rs.val].name, fn->tmp[rt.val].name);
 }
}
void
bsinit(BSet *bs, uint n)
{
 n = (n + NBit-1) / NBit;
 bs->nt = n;
 bs->t = alloc(n * sizeof bs->t[0]);
}
typedef char make_sure_NBit_is_64[(NBit == 64)?1:-1];
inline static uint
popcnt(bits b)
{
 b = (b & 0x5555555555555555) + ((b>>1) & 0x5555555555555555);
 b = (b & 0x3333333333333333) + ((b>>2) & 0x3333333333333333);
 b = (b & 0x0f0f0f0f0f0f0f0f) + ((b>>4) & 0x0f0f0f0f0f0f0f0f);
 b += (b>>8);
 b += (b>>16);
 b += (b>>32);
 return b & 0xff;
}
inline static int
firstbit(bits b)
{
 int n;
 n = 0;
 if (!(b & 0xffffffff)) {
  n += 32;
  b >>= 32;
 }
 if (!(b & 0xffff)) {
  n += 16;
  b >>= 16;
 }
 if (!(b & 0xff)) {
  n += 8;
  b >>= 8;
 }
 if (!(b & 0xf)) {
  n += 4;
  b >>= 4;
 }
 n += (char[16]){4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0}[b & 0xf];
 return n;
}
uint
bscount(BSet *bs)
{
 uint i, n;
 n = 0;
 for (i=0; i<bs->nt; i++)
  n += popcnt(bs->t[i]);
 return n;
}
static inline uint
bsmax(BSet *bs)
{
 return bs->nt * NBit;
}
void
bsset(BSet *bs, uint elt)
{
 ((void)0);
 bs->t[elt/NBit] |= ((bits)1 << (elt%NBit));
}
void
bsclr(BSet *bs, uint elt)
{
 ((void)0);
 bs->t[elt/NBit] &= ~((bits)1 << (elt%NBit));
}
void bscopy(BSet *a, BSet *b) { uint i; ((void)0); for (i=0; i<a->nt; i++) a->t[i] = b->t[i]; }
void bsunion(BSet *a, BSet *b) { uint i; ((void)0); for (i=0; i<a->nt; i++) a->t[i] |= b->t[i]; }
void bsinter(BSet *a, BSet *b) { uint i; ((void)0); for (i=0; i<a->nt; i++) a->t[i] &= b->t[i]; }
void bsdiff(BSet *a, BSet *b) { uint i; ((void)0); for (i=0; i<a->nt; i++) a->t[i] &= ~ b->t[i]; }
int
bsequal(BSet *a, BSet *b)
{
 uint i;
 ((void)0);
 for (i=0; i<a->nt; i++)
  if (a->t[i] != b->t[i])
   return 0;
 return 1;
}
void
bszero(BSet *bs)
{
 memset(bs->t, 0, bs->nt * sizeof bs->t[0]);
}
int
bsiter(BSet *bs, int *elt)
{
 bits b;
 uint t, i;
 i = *elt;
 t = i/NBit;
 if (t >= bs->nt)
  return 0;
 b = bs->t[t];
 b &= ~(((bits)1 << (i%NBit)) - 1);
 while (!b) {
  ++t;
  if (t >= bs->nt)
   return 0;
  b = bs->t[t];
 }
 *elt = NBit*t + firstbit(b);
 return 1;
}
void
dumpts(BSet *bs, Tmp *tmp, FILE *f)
{
 int t;
 fprintf(f, "[");
 for (t=Tmp0; bsiter(bs, &t); t++)
  fprintf(f, " %s", tmp[t].name);
 fprintf(f, " ]\n");
}
void
runmatch(uchar *code, Num *tn, Ref ref, Ref *var)
{
 Ref stkbuf[20], *stk;
 uchar *s, *pc;
 int bc, i;
 int n, nl, nr;
 ((void)0);
 stk = stkbuf;
 pc = code;
 while ((bc = *pc))
  switch (bc) {
  case 1:
  case 2:
   ((void)0);
   ((void)0);
   nl = tn[ref.val].nl;
   nr = tn[ref.val].nr;
   if (bc == 1 && nl > nr) {
    *stk++ = tn[ref.val].l;
    ref = tn[ref.val].r;
   } else {
    *stk++ = tn[ref.val].r;
    ref = tn[ref.val].l;
   }
   pc++;
   break;
  case 3:
   var[*++pc] = ref;
   if (*(pc + 1) == 0)
    return;
  case 4:
   ((void)0);
   ref = *--stk;
   pc++;
   break;
  case 5:
   ((void)0);
   n = tn[ref.val].n;
   s = pc + 1;
   for (i=*s++; i>0; i--, s++)
    if (n == *s++)
     break;
   pc += *s;
   break;
  default:
   ((void)0);
   pc = code + (bc - 10);
   break;
  }
}
