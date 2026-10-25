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

void
adduse(Tmp *tmp, int ty, Blk *b, ...)
{
 Use *u;
 int n;
 va_list ap;
 if (!tmp->use)
  return;
 __builtin_va_start(ap, b);
 n = tmp->nuse;
 vgrow(&tmp->use, ++tmp->nuse);
 u = &tmp->use[n];
 u->type = ty;
 u->bid = b->id;
 switch (ty) {
 case UPhi:
  u->u.phi = __builtin_va_arg(ap, Phi *);
  break;
 case UIns:
  u->u.ins = __builtin_va_arg(ap, Ins *);
  break;
 case UJmp:
  break;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/ssa.c", "unreachable");
 }
 __builtin_va_end(ap);
}
void
filluse(Fn *fn)
{
 Blk *b;
 Phi *p;
 Ins *i;
 int m, t, tp, w, x;
 uint a;
 Tmp *tmp;
 tmp = fn->tmp;
 for (t=Tmp0; t<fn->ntmp; t++) {
  tmp[t].def = 0;
  tmp[t].bid = -1u;
  tmp[t].ndef = 0;
  tmp[t].nuse = 0;
  tmp[t].cls = 0;
  tmp[t].phi = 0;
  tmp[t].width = WFull;
  if (tmp[t].use == 0)
   tmp[t].use = vnew(0, sizeof(Use), PFn);
 }
 for (b=fn->start; b; b=b->link) {
  for (p=b->phi; p; p=p->link) {
   ((void)0);
   tp = p->to.val;
   tmp[tp].bid = b->id;
   tmp[tp].ndef++;
   tmp[tp].cls = p->cls;
   tp = phicls(tp, fn->tmp);
   for (a=0; a<p->narg; a++)
    if (rtype(p->arg[a]) == RTmp) {
     t = p->arg[a].val;
     adduse(&tmp[t], UPhi, b, p);
     t = phicls(t, fn->tmp);
     if (t != tp)
      tmp[t].phi = tp;
    }
  }
  for (i=b->ins; i<&b->ins[b->nins]; i++) {
   if (!req(i->to, (Ref){RTmp, 0})) {
    ((void)0);
    w = WFull;
    if (((unsigned)(i->op) - Oparsb <= Oparuh - Oparsb))
     w = Wsb + (i->op - Oparsb);
    if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb) && i->op != Oload)
     w = Wsb + (i->op - Oloadsb);
    if (((unsigned)(i->op) - Oextsb <= Oextuw - Oextsb))
     w = Wsb + (i->op - Oextsb);
    if (iscmp(i->op, &x, &x))
     w = Wub;
    if (w == Wsw || w == Wuw)
    if (i->cls == Kw)
     w = WFull;
    t = i->to.val;
    tmp[t].width = w;
    tmp[t].def = i;
    tmp[t].bid = b->id;
    tmp[t].ndef++;
    tmp[t].cls = i->cls;
   }
   for (m=0; m<2; m++)
    if (rtype(i->arg[m]) == RTmp) {
     t = i->arg[m].val;
     adduse(&tmp[t], UIns, b, i);
    }
  }
  if (rtype(b->jmp.arg) == RTmp)
   adduse(&tmp[b->jmp.arg.val], UJmp, b);
 }
}
static Ref
refindex(int t, Fn *fn)
{
 return newtmp(fn->tmp[t].name, fn->tmp[t].cls, fn);
}
static void
phiins(Fn *fn)
{
 BSet u[1], defs[1];
 Blk *a, *b, **blist, **be, **bp;
 Ins *i;
 Phi *p;
 Use *use;
 Ref r;
 int t, nt, ok;
 uint n, defb;
 short k;
 bsinit(u, fn->nblk);
 bsinit(defs, fn->nblk);
 blist = emalloc(fn->nblk * sizeof blist[0]);
 be = &blist[fn->nblk];
 nt = fn->ntmp;
 for (t=Tmp0; t<nt; t++) {
  fn->tmp[t].visit = 0;
  if (fn->tmp[t].phi != 0)
   continue;
  if (fn->tmp[t].ndef == 1) {
   ok = 1;
   defb = fn->tmp[t].bid;
   use = fn->tmp[t].use;
   for (n=fn->tmp[t].nuse; n--; use++)
    ok &= use->bid == defb;
   if (ok || defb == fn->start->id)
    continue;
  }
  bszero(u);
  k = Kx;
  bp = be;
  for (b=fn->start; b; b=b->link) {
   b->visit = 0;
   r = (Ref){RTmp, 0};
   for (i=b->ins; i<&b->ins[b->nins]; i++) {
    if (!req(r, (Ref){RTmp, 0})) {
     if (req(i->arg[0], (Ref){RTmp, t}))
      i->arg[0] = r;
     if (req(i->arg[1], (Ref){RTmp, t}))
      i->arg[1] = r;
    }
    if (req(i->to, (Ref){RTmp, t})) {
     if (!bshas(b->out, t)) {
      r = refindex(t, fn);
      i->to = r;
     } else {
      if (!bshas(u, b->id)) {
       bsset(u, b->id);
       *--bp = b;
      }
      if (clsmerge(&k, i->cls))
       die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/ssa.c", "invalid input");
     }
    }
   }
   if (!req(r, (Ref){RTmp, 0}) && req(b->jmp.arg, (Ref){RTmp, t}))
    b->jmp.arg = r;
  }
  bscopy(defs, u);
  while (bp != be) {
   fn->tmp[t].visit = t;
   b = *bp++;
   bsclr(u, b->id);
   for (n=0; n<b->nfron; n++) {
    a = b->fron[n];
    if (a->visit++ == 0)
    if (bshas(a->in, t)) {
     p = alloc(sizeof *p);
     p->cls = k;
     p->to = (Ref){RTmp, t};
     p->link = a->phi;
     p->arg = vnew(0, sizeof p->arg[0], PFn);
     p->blk = vnew(0, sizeof p->blk[0], PFn);
     a->phi = p;
     if (!bshas(defs, a->id))
     if (!bshas(u, a->id)) {
      bsset(u, a->id);
      *--bp = a;
     }
    }
   }
  }
 }
 free(blist);
}
typedef struct Name Name;
struct Name {
 Ref r;
 Blk *b;
 Name *up;
};
static Name *namel;
static Name *
nnew(Ref r, Blk *b, Name *up)
{
 Name *n;
 if (namel) {
  n = namel;
  namel = n->up;
 } else
  n = emalloc(sizeof *n);
 n->r = r;
 n->b = b;
 n->up = up;
 return n;
}
static void
nfree(Name *n)
{
 n->up = namel;
 namel = n;
}
static void
rendef(Ref *r, Blk *b, Name **stk, Fn *fn)
{
 Ref r1;
 int t;
 t = r->val;
 if (req(*r, (Ref){RTmp, 0}) || !fn->tmp[t].visit)
  return;
 r1 = refindex(t, fn);
 fn->tmp[r1.val].visit = t;
 stk[t] = nnew(r1, b, stk[t]);
 *r = r1;
}
static Ref
getstk(int t, Blk *b, Name **stk)
{
 Name *n, *n1;
 n = stk[t];
 while (n && !dom(n->b, b)) {
  n1 = n;
  n = n->up;
  nfree(n1);
 }
 stk[t] = n;
 if (!n) {
  return (Ref){RCon, 0};
 } else
  return n->r;
}
static void
renblk(Blk *b, Name **stk, Fn *fn)
{
 Phi *p;
 Ins *i;
 Blk *s, **ps, *succ[3];
 int t, m;
 for (p=b->phi; p; p=p->link)
  rendef(&p->to, b, stk, fn);
 for (i=b->ins; i<&b->ins[b->nins]; i++) {
  for (m=0; m<2; m++) {
   t = i->arg[m].val;
   if (rtype(i->arg[m]) == RTmp)
   if (fn->tmp[t].visit)
    i->arg[m] = getstk(t, b, stk);
  }
  rendef(&i->to, b, stk, fn);
 }
 t = b->jmp.arg.val;
 if (rtype(b->jmp.arg) == RTmp)
 if (fn->tmp[t].visit)
  b->jmp.arg = getstk(t, b, stk);
 succ[0] = b->s1;
 succ[1] = b->s2 == b->s1 ? 0 : b->s2;
 succ[2] = 0;
 for (ps=succ; (s=*ps); ps++)
  for (p=s->phi; p; p=p->link) {
   t = p->to.val;
   if ((t=fn->tmp[t].visit)) {
    m = p->narg++;
    vgrow(&p->arg, p->narg);
    vgrow(&p->blk, p->narg);
    p->arg[m] = getstk(t, b, stk);
    p->blk[m] = b;
   }
  }
 for (s=b->dom; s; s=s->dlink)
  renblk(s, stk, fn);
}
void
ssa(Fn *fn)
{
 Name **stk, *n;
 int d, nt;
 Blk *b, *b1;
 nt = fn->ntmp;
 stk = emalloc(nt * sizeof stk[0]);
 d = debug['L'];
 debug['L'] = 0;
 filldom(fn);
 if (debug['N']) {
  fprintf(__stderrp, "\n> Dominators:\n");
  for (b1=fn->start; b1; b1=b1->link) {
   if (!b1->dom)
    continue;
   fprintf(__stderrp, "%10s:", b1->name);
   for (b=b1->dom; b; b=b->dlink)
    fprintf(__stderrp, " %s", b->name);
   fprintf(__stderrp, "\n");
  }
 }
 fillfron(fn);
 filllive(fn);
 phiins(fn);
 renblk(fn->start, stk, fn);
 while (nt--)
  while ((n=stk[nt])) {
   stk[nt] = n->up;
   nfree(n);
  }
 debug['L'] = d;
 free(stk);
 if (debug['N']) {
  fprintf(__stderrp, "\n> After SSA construction:\n");
  printfn(fn, __stderrp);
 }
}
static int
phicheck(Phi *p, Blk *b, Ref t)
{
 Blk *b1;
 uint n;
 for (n=0; n<p->narg; n++)
  if (req(p->arg[n], t)) {
   b1 = p->blk[n];
   if (b1 != b && !sdom(b, b1))
    return 1;
  }
 return 0;
}
void
ssacheck(Fn *fn)
{
 Tmp *t;
 Ins *i;
 Phi *p;
 Use *u;
 Blk *b, *bu;
 Ref r;
 for (t=&fn->tmp[Tmp0]; t-fn->tmp < fn->ntmp; t++) {
  if (t->ndef > 1)
   err("ssa temporary %%%s defined more than once",
    t->name);
  if (t->nuse > 0 && t->ndef == 0) {
   bu = fn->rpo[t->use[0].bid];
   goto Err;
  }
 }
 for (b=fn->start; b; b=b->link) {
  for (p=b->phi; p; p=p->link) {
   r = p->to;
   t = &fn->tmp[r.val];
   for (u=t->use; u<&t->use[t->nuse]; u++) {
    bu = fn->rpo[u->bid];
    if (u->type == UPhi) {
     if (phicheck(u->u.phi, b, r))
      goto Err;
    } else
     if (bu != b && !sdom(b, bu))
      goto Err;
   }
  }
  for (i=b->ins; i<&b->ins[b->nins]; i++) {
   if (rtype(i->to) != RTmp)
    continue;
   r = i->to;
   t = &fn->tmp[r.val];
   for (u=t->use; u<&t->use[t->nuse]; u++) {
    bu = fn->rpo[u->bid];
    if (u->type == UPhi) {
     if (phicheck(u->u.phi, b, r))
      goto Err;
    } else {
     if (bu == b) {
      if (u->type == UIns)
       if (u->u.ins <= i)
        goto Err;
     } else
      if (!sdom(b, bu))
       goto Err;
    }
   }
  }
 }
 return;
Err:
 if (t->visit)
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/ssa.c", "%%%s violates ssa invariant", t->name);
 else
  err("ssa temporary %%%s is used undefined in @%s",
   t->name, bu->name);
}
