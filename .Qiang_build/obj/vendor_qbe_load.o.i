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
typedef struct Loc Loc;
typedef struct Slice Slice;
typedef struct Insert Insert;
struct Loc {
 enum {
  LRoot,
  LLoad,
  LNoLoad,
 } type;
 uint off;
 Blk *blk;
};
struct Slice {
 Ref ref;
 int off;
 short sz;
 short cls;
};
struct Insert {
 uint isphi:1;
 uint num:31;
 uint bid;
 uint off;
 union {
  Ins ins;
  struct {
   Slice m;
   Phi *p;
  } phi;
 } new;
};
static Fn *curf;
static uint inum;
static Insert *ilog;
static uint nlog;
int
loadsz(Ins *l)
{
 switch (l->op) {
 case Oloadsb: case Oloadub: return 1;
 case Oloadsh: case Oloaduh: return 2;
 case Oloadsw: case Oloaduw: return 4;
 case Oload: return ((l->cls)&1) ? 8 : 4;
 }
 die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
}
int
storesz(Ins *s)
{
 switch (s->op) {
 case Ostoreb: return 1;
 case Ostoreh: return 2;
 case Ostorew: case Ostores: return 4;
 case Ostorel: case Ostored: return 8;
 }
 die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
}
static Ref
iins(int cls, int op, Ref a0, Ref a1, Loc *l)
{
 Insert *ist;
 vgrow(&ilog, ++nlog);
 ist = &ilog[nlog-1];
 ist->isphi = 0;
 ist->num = inum++;
 ist->bid = l->blk->id;
 ist->off = l->off;
 ist->new.ins = (Ins){op, cls, (Ref){RTmp, 0}, {a0, a1}};
 return ist->new.ins.to = newtmp("ld", cls, curf);
}
static void
cast(Ref *r, int cls, Loc *l)
{
 int cls0;
 if (rtype(*r) == RCon)
  return;
 ((void)0);
 cls0 = curf->tmp[r->val].cls;
 if (cls0 == cls || (cls == Kw && cls0 == Kl))
  return;
 if (((cls0)&1) < ((cls)&1)) {
  if (cls0 == Ks)
   *r = iins(Kw, Ocast, *r, (Ref){RTmp, 0}, l);
  *r = iins(Kl, Oextuw, *r, (Ref){RTmp, 0}, l);
  if (cls == Kd)
   *r = iins(Kd, Ocast, *r, (Ref){RTmp, 0}, l);
 } else {
  if (cls0 == Kd && cls != Kl)
   *r = iins(Kl, Ocast, *r, (Ref){RTmp, 0}, l);
  if (cls0 != Kd || cls != Kw)
   *r = iins(cls, Ocast, *r, (Ref){RTmp, 0}, l);
 }
}
static inline void
mask(int cls, Ref *r, bits msk, Loc *l)
{
 cast(r, cls, l);
 *r = iins(cls, Oand, *r, getcon(msk, curf), l);
}
static Ref
load(Slice sl, bits msk, Loc *l)
{
 Alias *a;
 Ref r, r1;
 int ld, cls, all;
 Con c;
 ld = (int[]){
  [1] = Oloadub,
  [2] = Oloaduh,
  [4] = Oloaduw,
  [8] = Oload
 }[sl.sz];
 all = msk == (((bits)1 << (8*(sl.sz)-1))*2-1);
 if (all)
  cls = sl.cls;
 else
  cls = sl.sz > 4 ? Kl : Kw;
 r = sl.ref;
 if (rtype(r) == RTmp) {
  a = &curf->tmp[r.val].alias;
  switch (a->type) {
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
  case ALoc:
  case AEsc:
  case AUnk:
   r = (Ref){RTmp, a->base};
   if (!a->offset)
    break;
   r1 = getcon(a->offset, curf);
   r = iins(Kl, Oadd, r, r1, l);
   break;
  case ACon:
  case ASym:
   memset(&c, 0, sizeof c);
   c.type = CAddr;
   c.sym = a->u.sym;
   c.bits.i = a->offset;
   r = newcon(&c, curf);
   break;
  }
 }
 r = iins(cls, ld, r, (Ref){RTmp, 0}, l);
 if (!all)
  mask(cls, &r, msk, l);
 return r;
}
static void
rebase(Slice *sl)
{
 Alias *a;
 if (rtype(sl->ref) != RTmp)
  return;
 a = &curf->tmp[sl->ref.val].alias;
 if (a->offset == (short)a->offset)
 if (a->type == ALoc
 || a->type == AEsc
 || a->type == AUnk) {
  sl->ref = (Ref){RTmp, a->base};
  sl->off = a->offset;
 }
}
static int
killsl(Ref r, Slice sl)
{
 Alias *a;
 if (rtype(sl.ref) != RTmp)
  return 0;
 a = &curf->tmp[sl.ref.val].alias;
 switch (a->type) {
 default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
 case ALoc:
 case AEsc:
 case AUnk: return req((Ref){RTmp, a->base}, r);
 case ACon:
 case ASym: return 0;
 }
}
static Ref
def(Slice sl, bits msk, Blk *b, Ins *i, Loc *il)
{
 Slice sl1;
 Blk *bp;
 bits msk1, msks;
 int off, cls, cls1, op, sz, ld;
 uint np, oldl, oldt;
 Ref r, r1;
 Phi *p;
 Insert *ist;
 Loc l;
 ((void)0);
 oldl = nlog;
 oldt = curf->ntmp;
 if (0) {
 Load:
  curf->ntmp = oldt;
  nlog = oldl;
  if (il->type != LLoad)
   return (Ref){RTmp, 0};
  return load(sl, msk, il);
 }
 if (!i)
  i = &b->ins[b->nins];
 cls = sl.sz > 4 ? Kl : Kw;
 msks = (((bits)1 << (8*(sl.sz)-1))*2-1);
 while (i > b->ins) {
  --i;
  if (killsl(i->to, sl)
  || (i->op == Ocall && escapes(sl.ref, curf)))
   goto Load;
  ld = ((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb);
  if (ld) {
   sz = loadsz(i);
   r1 = i->arg[0];
   r = i->to;
  } else if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb)) {
   sz = storesz(i);
   r1 = i->arg[1];
   r = i->arg[0];
  } else if (i->op == Oblit1) {
   ((void)0);
   sz = abs(rsval(i->arg[0]));
   ((void)0);
   --i;
   ((void)0);
   r1 = i->arg[1];
  } else
   continue;
  switch (alias(sl.ref, sl.off, sl.sz, r1, sz, &off, curf)) {
  case MustAlias:
   if (i->op == Oblit0) {
    sl1 = sl;
    sl1.ref = i->arg[0];
    if (off >= 0) {
     ((void)0);
     sl1.off = off;
     sz -= off;
     off = 0;
    } else {
     sl1.off = 0;
     sl1.sz += off;
    }
    if (sz > sl1.sz)
     sz = sl1.sz;
    ((void)0);
    sl1.sz = sz;
   }
   if (off < 0) {
    off = -off;
    msk1 = ((((bits)1 << (8*(sz)-1))*2-1) << 8*off) & msks;
    op = Oshl;
   } else {
    msk1 = ((((bits)1 << (8*(sz)-1))*2-1) >> 8*off) & msks;
    op = Oshr;
   }
   if ((msk1 & msk) == 0)
    continue;
   if (i->op == Oblit0) {
    r = def(sl1, (((bits)1 << (8*(sz)-1))*2-1), b, i, il);
    if (req(r, (Ref){RTmp, 0}))
     goto Load;
   }
   if (off) {
    cls1 = cls;
    if (op == Oshr && off + sl.sz > 4)
     cls1 = Kl;
    cast(&r, cls1, il);
    r1 = getcon(8*off, curf);
    r = iins(cls1, op, r, r1, il);
   }
   if ((msk1 & msk) != msk1 || off + sz < sl.sz)
    mask(cls, &r, msk1 & msk, il);
   if ((msk & ~msk1) != 0) {
    r1 = def(sl, msk & ~msk1, b, i, il);
    if (req(r1, (Ref){RTmp, 0}))
     goto Load;
    r = iins(cls, Oor, r, r1, il);
   }
   if (msk == msks)
    cast(&r, sl.cls, il);
   return r;
  case MayAlias:
   if (ld)
    continue;
   else
    goto Load;
  case NoAlias:
   continue;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
  }
 }
 for (ist=ilog; ist<&ilog[nlog]; ++ist)
  if (ist->isphi && ist->bid == b->id)
  if (req(ist->new.phi.m.ref, sl.ref))
  if (ist->new.phi.m.off == sl.off)
  if (ist->new.phi.m.sz == sl.sz) {
   r = ist->new.phi.p->to;
   if (msk != msks)
    mask(cls, &r, msk, il);
   else
    cast(&r, sl.cls, il);
   return r;
  }
 for (p=b->phi; p; p=p->link)
  if (killsl(p->to, sl))
   goto Load;
 if (b->npred == 0)
  goto Load;
 if (b->npred == 1) {
  bp = b->pred[0];
  ((void)0);
  l = *il;
  if (bp->s2)
   l.type = LNoLoad;
  r1 = def(sl, msk, bp, 0, &l);
  if (req(r1, (Ref){RTmp, 0}))
   goto Load;
  return r1;
 }
 r = newtmp("ld", sl.cls, curf);
 p = alloc(sizeof *p);
 vgrow(&ilog, ++nlog);
 ist = &ilog[nlog-1];
 ist->isphi = 1;
 ist->bid = b->id;
 ist->new.phi.m = sl;
 ist->new.phi.p = p;
 p->to = r;
 p->cls = sl.cls;
 p->narg = b->npred;
 p->arg = vnew(p->narg, sizeof p->arg[0], PFn);
 p->blk = vnew(p->narg, sizeof p->blk[0], PFn);
 for (np=0; np<b->npred; ++np) {
  bp = b->pred[np];
  if (!bp->s2
  && il->type != LNoLoad
  && bp->loop < il->blk->loop)
   l.type = LLoad;
  else
   l.type = LNoLoad;
  l.blk = bp;
  l.off = bp->nins;
  r1 = def(sl, msks, bp, 0, &l);
  if (req(r1, (Ref){RTmp, 0}))
   goto Load;
  p->arg[np] = r1;
  p->blk[np] = bp;
 }
 if (msk != msks)
  mask(cls, &r, msk, il);
 return r;
}
static int
icmp(const void *pa, const void *pb)
{
 Insert *a, *b;
 int c;
 a = (Insert *)pa;
 b = (Insert *)pb;
 if ((c = a->bid - b->bid))
  return c;
 if (a->isphi && b->isphi)
  return 0;
 if (a->isphi)
  return -1;
 if (b->isphi)
  return +1;
 if ((c = a->off - b->off))
  return c;
 return a->num - b->num;
}
void
loadopt(Fn *fn)
{
 Ins *i, *ib;
 Blk *b;
 int sz;
 uint n, ni, ext, nt;
 Insert *ist;
 Slice sl;
 Loc l;
 curf = fn;
 ilog = vnew(0, sizeof ilog[0], PHeap);
 nlog = 0;
 inum = 0;
 for (b=fn->start; b; b=b->link)
  for (i=b->ins; i<&b->ins[b->nins]; ++i) {
   if (!((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb))
    continue;
   sz = loadsz(i);
   sl = (Slice){i->arg[0], 0, sz, i->cls};
   l = (Loc){LRoot, i-b->ins, b};
   rebase(&sl);
   i->arg[1] = def(sl, (((bits)1 << (8*(sz)-1))*2-1), b, i, &l);
  }
 qsort(ilog, nlog, sizeof ilog[0], icmp);
 vgrow(&ilog, nlog+1);
 ilog[nlog].bid = fn->nblk;
 ib = vnew(0, sizeof(Ins), PHeap);
 for (ist=ilog, n=0; n<fn->nblk; ++n) {
  b = fn->rpo[n];
  for (; ist->bid == n && ist->isphi; ++ist) {
   ist->new.phi.p->link = b->phi;
   b->phi = ist->new.phi.p;
  }
  ni = 0;
  nt = 0;
  for (;;) {
   if (ist->bid == n && ist->off == ni)
    i = &ist++->new.ins;
   else {
    if (ni == b->nins)
     break;
    i = &b->ins[ni++];
    if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb)
    && !req(i->arg[1], (Ref){RTmp, 0})) {
     ext = Oextsb + i->op - Oloadsb;
     switch (i->op) {
     default:
      die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/load.c", "unreachable");
     case Oloadsb:
     case Oloadub:
     case Oloadsh:
     case Oloaduh:
      i->op = ext;
      break;
     case Oloadsw:
     case Oloaduw:
      if (i->cls == Kl) {
       i->op = ext;
       break;
      }
     case Oload:
      i->op = Ocopy;
      break;
     }
     i->arg[0] = i->arg[1];
     i->arg[1] = (Ref){RTmp, 0};
    }
   }
   vgrow(&ib, ++nt);
   ib[nt-1] = *i;
  }
  idup(b, ib, nt);
 }
 vfree(ib);
 vfree(ilog);
 if (debug['M']) {
  fprintf(__stderrp, "\n> After load elimination:\n");
  printfn(fn, __stderrp);
 }
}
