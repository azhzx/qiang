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

Blk *
newblk()
{
 static Blk z;
 Blk *b;
 b = alloc(sizeof *b);
 *b = z;
 b->ins = vnew(0, sizeof b->ins[0], PFn);
 b->pred = vnew(0, sizeof b->pred[0], PFn);
 return b;
}
static void
fixphis(Fn *f)
{
 Blk *b, *bp;
 Phi *p;
 uint n, n0;
 for (b=f->start; b; b=b->link) {
  ((void)0);
  for (p=b->phi; p; p=p->link) {
   for (n=n0=0; n<p->narg; n++) {
    bp = p->blk[n];
    if (bp->id != -1u)
    if (bp->s1 == b || bp->s2 == b) {
     p->blk[n0] = bp;
     p->arg[n0] = p->arg[n];
     n0++;
    }
   }
   ((void)0);
   p->narg = n0;
  }
 }
}
static void
addpred(Blk *bp, Blk *b)
{
 vgrow(&b->pred, ++b->npred);
 b->pred[b->npred-1] = bp;
}
void
fillpreds(Fn *f)
{
 Blk *b;
 for (b=f->start; b; b=b->link)
  b->npred = 0;
 for (b=f->start; b; b=b->link) {
  if (b->s1)
   addpred(b, b->s1);
  if (b->s2 && b->s2 != b->s1)
   addpred(b, b->s2);
 }
}
static void
porec(Blk *b, uint *npo)
{
 Blk *s1, *s2;
 if (!b || b->id != -1u)
  return;
 b->id = 0;
 s1 = b->s1;
 s2 = b->s2;
 if (s1 && s2 && s1->loop > s2->loop) {
  s1 = b->s2;
  s2 = b->s1;
 }
 porec(s1, npo);
 porec(s2, npo);
 b->id = (*npo)++;
}
static void
fillrpo(Fn *f)
{
 Blk *b, **p;
 for (b=f->start; b; b=b->link)
  b->id = -1u;
 f->nblk = 0;
 porec(f->start, &f->nblk);
 vgrow(&f->rpo, f->nblk);
 for (p=&f->start; (b=*p);) {
  if (b->id == -1u) {
   *p = b->link;
  } else {
   b->id = f->nblk-b->id-1;
   f->rpo[b->id] = b;
   p = &b->link;
  }
 }
}
void
fillcfg(Fn *f)
{
 fillrpo(f);
 fillpreds(f);
 fixphis(f);
}
static Blk *
inter(Blk *b1, Blk *b2)
{
 Blk *bt;
 if (b1 == 0)
  return b2;
 while (b1 != b2) {
  if (b1->id < b2->id) {
   bt = b1;
   b1 = b2;
   b2 = bt;
  }
  while (b1->id > b2->id) {
   b1 = b1->idom;
   ((void)0);
  }
 }
 return b1;
}
void
filldom(Fn *fn)
{
 Blk *b, *d;
 int ch;
 uint n, p;
 for (b=fn->start; b; b=b->link) {
  b->idom = 0;
  b->dom = 0;
  b->dlink = 0;
 }
 do {
  ch = 0;
  for (n=1; n<fn->nblk; n++) {
   b = fn->rpo[n];
   d = 0;
   for (p=0; p<b->npred; p++)
    if (b->pred[p]->idom
    || b->pred[p] == fn->start)
     d = inter(d, b->pred[p]);
   if (d != b->idom) {
    ch++;
    b->idom = d;
   }
  }
 } while (ch);
 for (b=fn->start; b; b=b->link)
  if ((d=b->idom)) {
   ((void)0);
   b->dlink = d->dom;
   d->dom = b;
  }
}
int
sdom(Blk *b1, Blk *b2)
{
 ((void)0);
 if (b1 == b2)
  return 0;
 while (b2->id > b1->id)
  b2 = b2->idom;
 return b1 == b2;
}
int
dom(Blk *b1, Blk *b2)
{
 return b1 == b2 || sdom(b1, b2);
}
static void
addfron(Blk *a, Blk *b)
{
 uint n;
 for (n=0; n<a->nfron; n++)
  if (a->fron[n] == b)
   return;
 if (!a->nfron)
  a->fron = vnew(++a->nfron, sizeof a->fron[0], PFn);
 else
  vgrow(&a->fron, ++a->nfron);
 a->fron[a->nfron-1] = b;
}
void
fillfron(Fn *fn)
{
 Blk *a, *b;
 for (b=fn->start; b; b=b->link)
  b->nfron = 0;
 for (b=fn->start; b; b=b->link) {
  if (b->s1)
   for (a=b; !sdom(a, b->s1); a=a->idom)
    addfron(a, b->s1);
  if (b->s2)
   for (a=b; !sdom(a, b->s2); a=a->idom)
    addfron(a, b->s2);
 }
}
static void
loopmark(Blk *hd, Blk *b, void f(Blk *, Blk *))
{
 uint p;
 if (b->id < hd->id || b->visit == hd->id)
  return;
 b->visit = hd->id;
 f(hd, b);
 for (p=0; p<b->npred; ++p)
  loopmark(hd, b->pred[p], f);
}
void
loopiter(Fn *fn, void f(Blk *, Blk *))
{
 uint n, p;
 Blk *b;
 for (b=fn->start; b; b=b->link)
  b->visit = -1u;
 for (n=0; n<fn->nblk; ++n) {
  b = fn->rpo[n];
  for (p=0; p<b->npred; ++p)
   if (b->pred[p]->id >= n)
    loopmark(b, b->pred[p], f);
 }
}
void
filldepth(Fn *fn)
{
 Blk *b, *d;
 int depth;
 for (b=fn->start; b; b=b->link)
  b->depth = -1;
 fn->start->depth = 0;
 for (b=fn->start; b; b=b->link) {
  if (b->depth != -1)
   continue;
  depth = 1;
  for (d=b->idom; d->depth==-1; d=d->idom)
   depth++;
  depth += d->depth;
  b->depth = depth;
  for (d=b->idom; d->depth==-1; d=d->idom)
   d->depth = --depth;
 }
}
Blk *
lca(Blk *b1, Blk *b2)
{
 if (!b1)
  return b2;
 if (!b2)
  return b1;
 while (b1->depth > b2->depth)
  b1 = b1->idom;
 while (b2->depth > b1->depth)
  b2 = b2->idom;
 while (b1 != b2) {
  b1 = b1->idom;
  b2 = b2->idom;
 }
 return b1;
}
void
multloop(Blk *hd, Blk *b)
{
 (void)hd;
 b->loop *= 10;
}
void
fillloop(Fn *fn)
{
 Blk *b;
 for (b=fn->start; b; b=b->link)
  b->loop = 1;
 loopiter(fn, multloop);
}
static void
uffind(Blk **pb, Blk **uf)
{
 Blk **pb1;
 pb1 = &uf[(*pb)->id];
 if (*pb1) {
  uffind(pb1, uf);
  *pb = *pb1;
 }
}
void
simpljmp(Fn *fn)
{
 Blk **uf;
 Blk **p, *b, *ret;
 ret = newblk();
 ret->id = fn->nblk++;
 ret->jmp.type = Jret0;
 uf = emalloc(fn->nblk * sizeof uf[0]);
 for (b=fn->start; b; b=b->link) {
  ((void)0);
  if (b->jmp.type == Jret0) {
   b->jmp.type = Jjmp;
   b->s1 = ret;
  }
  if (b->nins == 0)
  if (b->jmp.type == Jjmp) {
   uffind(&b->s1, uf);
   if (b->s1 != b)
    uf[b->id] = b->s1;
  }
 }
 for (p=&fn->start; (b=*p); p=&b->link) {
  if (b->s1)
   uffind(&b->s1, uf);
  if (b->s2)
   uffind(&b->s2, uf);
  if (b->s1 && b->s1 == b->s2) {
   b->jmp.type = Jjmp;
   b->s2 = 0;
  }
 }
 *p = ret;
 free(uf);
}
static int
reachrec(Blk *b, Blk *to)
{
 if (b == to)
  return 1;
 if (!b || b->visit)
  return 0;
 b->visit = 1;
 if (reachrec(b->s1, to))
  return 1;
 if (reachrec(b->s2, to))
  return 1;
 return 0;
}
int
reaches(Fn *fn, Blk *b, Blk *to)
{
 int r;
 ((void)0);
 r = reachrec(b, to);
 for (b=fn->start; b; b=b->link)
  b->visit = 0;
 return r;
}
int
reachesnotvia(Fn *fn, Blk *b, Blk *to, Blk *excl)
{
 excl->visit = 1;
 return reaches(fn, b, to);
}
int
ifgraph(Blk *ifb, Blk **pthenb, Blk **pelseb, Blk **pjoinb)
{
 Blk *s1, *s2, **t;
 if (ifb->jmp.type != Jjnz)
  return 0;
 s1 = ifb->s1;
 s2 = ifb->s2;
 if (s1->id > s2->id) {
  s1 = ifb->s2;
  s2 = ifb->s1;
  t = pthenb;
  pthenb = pelseb;
  pelseb = t;
 }
 if (s1 == s2)
  return 0;
 if (s1->jmp.type != Jjmp || s1->npred != 1)
  return 0;
 if (s1->s1 == s2) {
  if (s2->npred != 2)
   return 0;
  *pthenb = s1;
  *pelseb = ifb;
  *pjoinb = s2;
  return 1;
 }
 if (s2->jmp.type != Jjmp || s2->npred != 1)
  return 0;
 if (s1->s1 != s2->s1 || s1->s1->npred != 2)
  return 0;
 ((void)0);
 *pthenb = s1;
 *pelseb = s2;
 *pjoinb = s1->s1;
 return 1;
}
typedef struct Jmp Jmp;
struct Jmp {
 int type;
 Ref arg;
 Blk *s1, *s2;
};
static int
jmpeq(Jmp *a, Jmp *b)
{
 return a->type == b->type && req(a->arg, b->arg)
  && a->s1 == b->s1 && a->s2 == b->s2;
}
static int
jmpnophi(Jmp *j)
{
 if (j->s1 && j->s1->phi)
  return 0;
 if (j->s2 && j->s2->phi)
  return 0;
 return 1;
}
void
simplcfg(Fn *fn)
{
 Ins cpy, *i;
 Blk *b, *bb, **pb;
 Jmp *jmp, *j, *jj;
 Phi *p;
 int *empty, done;
 uint n;
 if (debug['C']) {
  fprintf(__stderrp, "\n> Before CFG simplification:\n");
  printfn(fn, __stderrp);
 }
 cpy = (Ins){.op = Ocopy};
 for (b=fn->start; b; b=b->link)
  if (b->npred == 1) {
   bb = b->pred[0];
   for (p=b->phi; p; p=p->link) {
    cpy.cls = p->cls;
    cpy.to = p->to;
    cpy.arg[0] = phiarg(p, bb);
    addins(&bb->ins, &bb->nins, &cpy);
   }
   b->phi = 0;
  }
 jmp = emalloc(fn->nblk * sizeof jmp[0]);
 empty = emalloc(fn->nblk * sizeof empty[0]);
 for (b=fn->start; b; b=b->link) {
  jmp[b->id].type = b->jmp.type;
  jmp[b->id].arg = b->jmp.arg;
  jmp[b->id].s1 = b->s1;
  jmp[b->id].s2 = b->s2;
  empty[b->id] = !b->phi;
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   if (i->op != Onop && i->op != Odbgloc) {
    empty[b->id] = 0;
    break;
   }
 }
 do {
  done = 1;
  for (b=fn->start; b; b=b->link) {
   if (b->id == -1u)
    continue;
   j = &jmp[b->id];
   if (j->type == Jjmp && j->s1->npred == 1) {
    ((void)0);
    addbins(&b->ins, &b->nins, j->s1);
    empty[b->id] &= empty[j->s1->id];
    jj = &jmp[j->s1->id];
    pb = (Blk*[]){jj->s1, jj->s2, 0};
    for (; (bb=*pb); pb++)
     for (p=bb->phi; p; p=p->link) {
      n = phiargn(p, j->s1);
      p->blk[n] = b;
     }
    j->s1->id = -1u;
    *j = *jj;
    done = 0;
   }
   else if (j->type == Jjnz
   && empty[j->s1->id] && empty[j->s2->id]
   && jmpeq(&jmp[j->s1->id], &jmp[j->s2->id])
   && jmpnophi(&jmp[j->s1->id])) {
    *j = jmp[j->s1->id];
    done = 0;
   }
  }
 } while (!done);
 for (b=fn->start; b; b=b->link)
  if (b->id != -1u) {
   j = &jmp[b->id];
   b->jmp.type = j->type;
   b->jmp.arg = j->arg;
   b->s1 = j->s1;
   b->s2 = j->s2;
   ((void)0);
   ((void)0);
  }
 fillcfg(fn);
 free(empty);
 free(jmp);
 if (debug['C']) {
  fprintf(__stderrp, "\n> After CFG simplification:\n");
  printfn(fn, __stderrp);
 }
}
