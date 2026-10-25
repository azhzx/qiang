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
static int
iscon(Con *c, int w, uint64_t k)
{
 if (c->type != CBits)
  return 0;
 if (w)
  return (uint64_t)c->bits.i == k;
 else
  return (uint32_t)c->bits.i == (uint32_t)k;
}
int
foldint(Con *res, int op, int w, Con *cl, Con *cr)
{
 union {
  int64_t s;
  uint64_t u;
  float fs;
  double fd;
 } l, r;
 uint64_t x;
 Sym sym;
 int typ;
 memset(&sym, 0, sizeof sym);
 typ = CBits;
 l.s = cl->bits.i;
 r.s = cr->bits.i;
 if (op == Oadd) {
  if (cl->type == CAddr) {
   if (cr->type == CAddr)
    return 1;
   typ = CAddr;
   sym = cl->sym;
  }
  else if (cr->type == CAddr) {
   typ = CAddr;
   sym = cr->sym;
  }
 }
 else if (op == Osub) {
  if (cl->type == CAddr) {
   if (cr->type != CAddr) {
    typ = CAddr;
    sym = cl->sym;
   } else if (!symeq(cl->sym, cr->sym))
    return 1;
  }
  else if (cr->type == CAddr)
   return 1;
 }
 else if (cl->type == CAddr || cr->type == CAddr)
  return 1;
 if (op == Odiv || op == Orem || op == Oudiv || op == Ourem) {
  if (iscon(cr, w, 0))
   return 1;
  if (op == Odiv || op == Orem) {
   x = w ? (-9223372036854775807L-1) : (-2147483647-1);
   if (iscon(cr, w, -1))
   if (iscon(cl, w, x))
    return 1;
  }
 }
 switch (op) {
 case Oadd: x = l.u + r.u; break;
 case Osub: x = l.u - r.u; break;
 case Oneg: x = -l.u; break;
 case Odiv: x = w ? l.s / r.s : (int32_t)l.s / (int32_t)r.s; break;
 case Orem: x = w ? l.s % r.s : (int32_t)l.s % (int32_t)r.s; break;
 case Oudiv: x = w ? l.u / r.u : (uint32_t)l.u / (uint32_t)r.u; break;
 case Ourem: x = w ? l.u % r.u : (uint32_t)l.u % (uint32_t)r.u; break;
 case Omul: x = l.u * r.u; break;
 case Oand: x = l.u & r.u; break;
 case Oor: x = l.u | r.u; break;
 case Oxor: x = l.u ^ r.u; break;
 case Osar: x = (w ? l.s : (int32_t)l.s) >> (r.u & (31|w<<5)); break;
 case Oshr: x = (w ? l.u : (uint32_t)l.u) >> (r.u & (31|w<<5)); break;
 case Oshl: x = l.u << (r.u & (31|w<<5)); break;
 case Oextsb: x = (int8_t)l.u; break;
 case Oextub: x = (uint8_t)l.u; break;
 case Oextsh: x = (int16_t)l.u; break;
 case Oextuh: x = (uint16_t)l.u; break;
 case Oextsw: x = (int32_t)l.u; break;
 case Oextuw: x = (uint32_t)l.u; break;
 case Ostosi: x = w ? (int64_t)cl->bits.s : (int32_t)cl->bits.s; break;
 case Ostoui: x = w ? (uint64_t)cl->bits.s : (uint32_t)cl->bits.s; break;
 case Odtosi: x = w ? (int64_t)cl->bits.d : (int32_t)cl->bits.d; break;
 case Odtoui: x = w ? (uint64_t)cl->bits.d : (uint32_t)cl->bits.d; break;
 case Ocast:
  x = l.u;
  if (cl->type == CAddr) {
   typ = CAddr;
   sym = cl->sym;
  }
  break;
 default:
  if (Ocmpw <= op && op <= Ocmpl1) {
   if (op <= Ocmpw1) {
    l.u = (int32_t)l.u;
    r.u = (int32_t)r.u;
   } else
    op -= Ocmpl - Ocmpw;
   switch (op - Ocmpw) {
   case Ciule: x = l.u <= r.u; break;
   case Ciult: x = l.u < r.u; break;
   case Cisle: x = l.s <= r.s; break;
   case Cislt: x = l.s < r.s; break;
   case Cisgt: x = l.s > r.s; break;
   case Cisge: x = l.s >= r.s; break;
   case Ciugt: x = l.u > r.u; break;
   case Ciuge: x = l.u >= r.u; break;
   case Cieq: x = l.u == r.u; break;
   case Cine: x = l.u != r.u; break;
   default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
   }
  }
  else if (Ocmps <= op && op <= Ocmps1) {
   switch (op - Ocmps) {
   case Cfle: x = l.fs <= r.fs; break;
   case Cflt: x = l.fs < r.fs; break;
   case Cfgt: x = l.fs > r.fs; break;
   case Cfge: x = l.fs >= r.fs; break;
   case Cfne: x = l.fs != r.fs; break;
   case Cfeq: x = l.fs == r.fs; break;
   case Cfo: x = l.fs < r.fs || l.fs >= r.fs; break;
   case Cfuo: x = !(l.fs < r.fs || l.fs >= r.fs); break;
   default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
   }
  }
  else if (Ocmpd <= op && op <= Ocmpd1) {
   switch (op - Ocmpd) {
   case Cfle: x = l.fd <= r.fd; break;
   case Cflt: x = l.fd < r.fd; break;
   case Cfgt: x = l.fd > r.fd; break;
   case Cfge: x = l.fd >= r.fd; break;
   case Cfne: x = l.fd != r.fd; break;
   case Cfeq: x = l.fd == r.fd; break;
   case Cfo: x = l.fd < r.fd || l.fd >= r.fd; break;
   case Cfuo: x = !(l.fd < r.fd || l.fd >= r.fd); break;
   default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
   }
  }
  else
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
 }
 *res = (Con){.type=typ, .sym=sym, .bits={.i=x}};
 return 0;
}
static void
foldflt(Con *res, int op, int w, Con *cl, Con *cr)
{
 float xs, ls, rs;
 double xd, ld, rd;
 if (cl->type != CBits || cr->type != CBits)
  err("invalid address operand for '%s'", optab[op].name);
 *res = (Con){.type = CBits};
 memset(&res->bits, 0, sizeof(res->bits));
 if (w) {
  ld = cl->bits.d;
  rd = cr->bits.d;
  switch (op) {
  case Oadd: xd = ld + rd; break;
  case Osub: xd = ld - rd; break;
  case Oneg: xd = -ld; break;
  case Odiv: xd = ld / rd; break;
  case Omul: xd = ld * rd; break;
  case Oswtof: xd = (int32_t)cl->bits.i; break;
  case Ouwtof: xd = (uint32_t)cl->bits.i; break;
  case Osltof: xd = (int64_t)cl->bits.i; break;
  case Oultof: xd = (uint64_t)cl->bits.i; break;
  case Oexts: xd = cl->bits.s; break;
  case Ocast: xd = ld; break;
  default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
  }
  res->bits.d = xd;
  res->flt = 2;
 } else {
  ls = cl->bits.s;
  rs = cr->bits.s;
  switch (op) {
  case Oadd: xs = ls + rs; break;
  case Osub: xs = ls - rs; break;
  case Oneg: xs = -ls; break;
  case Odiv: xs = ls / rs; break;
  case Omul: xs = ls * rs; break;
  case Oswtof: xs = (int32_t)cl->bits.i; break;
  case Ouwtof: xs = (uint32_t)cl->bits.i; break;
  case Osltof: xs = (int64_t)cl->bits.i; break;
  case Oultof: xs = (uint64_t)cl->bits.i; break;
  case Otruncd: xs = cl->bits.d; break;
  case Ocast: xs = ls; break;
  default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/fold.c", "unreachable");
  }
  res->bits.s = xs;
  res->flt = 1;
 }
}
static Ref
opfold(int op, int cls, Con *cl, Con *cr, Fn *fn)
{
 Ref r;
 Con c;
 if (cls == Kw || cls == Kl) {
  if (foldint(&c, op, cls == Kl, cl, cr))
   return (Ref){RTmp, 0};
 } else
  foldflt(&c, op, cls == Kd, cl, cr);
 if (!((cls)&1))
  c.bits.i &= 0xffffffff;
 r = newcon(&c, fn);
 ((void)0);
 return r;
}
Ref
foldref(Fn *fn, Ins *i)
{
 Ref rr;
 Con *cl, *cr;
 if (rtype(i->to) != RTmp)
  return (Ref){RTmp, 0};
 if (optab[i->op].canfold) {
  if (rtype(i->arg[0]) != RCon)
   return (Ref){RTmp, 0};
  cl = &fn->con[i->arg[0].val];
  rr = i->arg[1];
  if (req(rr, (Ref){RTmp, 0}))
      rr = (Ref){RCon, 1};
  if (rtype(rr) != RCon)
   return (Ref){RTmp, 0};
  cr = &fn->con[rr.val];
  return opfold(i->op, i->cls, cl, cr, fn);
 }
 return (Ref){RTmp, 0};
}
