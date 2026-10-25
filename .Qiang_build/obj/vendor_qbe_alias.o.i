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

void
getalias(Alias *a, Ref r, Fn *fn)
{
 Con *c;
 switch (rtype(r)) {
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/alias.c", "unreachable");
 case RTmp:
  *a = fn->tmp[r.val].alias;
  if (((a->type) & 1))
   a->type = a->slot->type;
  ((void)0);
  break;
 case RCon:
  c = &fn->con[r.val];
  if (c->type == CAddr) {
   a->type = ASym;
   a->u.sym = c->sym;
  } else
   a->type = ACon;
  a->offset = c->bits.i;
  a->slot = 0;
  break;
 }
}
int
alias(Ref p, int op, int sp, Ref q, int sq, int *delta, Fn *fn)
{
 Alias ap, aq;
 int ovlap;
 getalias(&ap, p, fn);
 getalias(&aq, q, fn);
 ap.offset += op;
 *delta = ap.offset - aq.offset;
 ovlap = ap.offset < aq.offset + sq && aq.offset < ap.offset + sp;
 if (((ap.type) & 1) && ((aq.type) & 1)) {
  if (ap.base == aq.base && ovlap)
   return MustAlias;
  return NoAlias;
 }
 if (ap.type == ASym && aq.type == ASym) {
  if (!symeq(ap.u.sym, aq.u.sym))
   return MayAlias;
  if (ovlap)
   return MustAlias;
  return NoAlias;
 }
 if ((ap.type == ACon && aq.type == ACon)
 || (ap.type == aq.type && ap.base == aq.base)) {
  ((void)0);
  if (ovlap)
   return MustAlias;
  return NoAlias;
 }
 if (ap.type == AUnk && aq.type != ALoc)
  return MayAlias;
 if (aq.type == AUnk && ap.type != ALoc)
  return MayAlias;
 return NoAlias;
}
int
escapes(Ref r, Fn *fn)
{
 Alias *a;
 if (rtype(r) != RTmp)
  return 1;
 a = &fn->tmp[r.val].alias;
 return !((a->type) & 1) || a->slot->type == AEsc;
}
static void
esc(Ref r, Fn *fn)
{
 Alias *a;
 ((void)0);
 if (rtype(r) == RTmp) {
  a = &fn->tmp[r.val].alias;
  if (((a->type) & 1))
   a->slot->type = AEsc;
 }
}
static void
store(Ref r, int sz, Fn *fn)
{
 Alias *a;
 int64_t off;
 bits m;
 if (rtype(r) == RTmp) {
  a = &fn->tmp[r.val].alias;
  if (a->slot) {
   ((void)0);
   off = a->offset;
   if (sz >= NBit
   || (off < 0 || off >= NBit))
    m = -1;
   else
    m = (((bits)1 << (sz)) - 1) << off;
   a->slot->u.loc.m |= m;
  }
 }
}
void
fillalias(Fn *fn)
{
 uint n;
 int t, sz;
 int64_t x;
 Blk *b;
 Phi *p;
 Ins *i;
 Con *c;
 Alias *a, a0, a1;
 for (t=0; t<fn->ntmp; t++)
  fn->tmp[t].alias.type = ABot;
 for (n=0; n<fn->nblk; ++n) {
  b = fn->rpo[n];
  for (p=b->phi; p; p=p->link) {
   ((void)0);
   a = &fn->tmp[p->to.val].alias;
   ((void)0);
   a->type = AUnk;
   a->base = p->to.val;
   a->offset = 0;
   a->slot = 0;
  }
  for (i=b->ins; i<&b->ins[b->nins]; ++i) {
   a = 0;
   if (!req(i->to, (Ref){RTmp, 0})) {
    ((void)0);
    a = &fn->tmp[i->to.val].alias;
    ((void)0);
    if (Oalloc <= i->op && i->op <= Oalloc1) {
     a->type = ALoc;
     a->slot = a;
     a->u.loc.sz = -1;
     if (rtype(i->arg[0]) == RCon) {
      c = &fn->con[i->arg[0].val];
      x = c->bits.i;
      if (c->type == CBits)
      if (0 <= x && x <= NBit)
       a->u.loc.sz = x;
     }
    } else {
     a->type = AUnk;
     a->slot = 0;
    }
    a->base = i->to.val;
    a->offset = 0;
   }
   if (i->op == Ocopy) {
    ((void)0);
    getalias(a, i->arg[0], fn);
   }
   if (i->op == Oadd) {
    getalias(&a0, i->arg[0], fn);
    getalias(&a1, i->arg[1], fn);
    if (a0.type == ACon) {
     *a = a1;
     a->offset += a0.offset;
    }
    else if (a1.type == ACon) {
     *a = a0;
     a->offset += a1.offset;
    }
   }
   if (req(i->to, (Ref){RTmp, 0}) || a->type == AUnk)
   if (i->op != Oblit0) {
    if (!((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb))
     esc(i->arg[0], fn);
    if (!((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb))
    if (i->op != Oargc)
     esc(i->arg[1], fn);
   }
   if (i->op == Oblit0) {
    ++i;
    ((void)0);
    ((void)0);
    sz = abs(rsval(i->arg[0]));
    store((i-1)->arg[1], sz, fn);
   }
   if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb))
    store(i->arg[1], storesz(i), fn);
  }
  if (b->jmp.type != Jretc)
   esc(b->jmp.arg, fn);
 }
 for (b=fn->start; b; b=b->link)
  for (p=b->phi; p; p=p->link)
   for (n=0; n<p->narg; n++)
    esc(p->arg[n], fn);
}
