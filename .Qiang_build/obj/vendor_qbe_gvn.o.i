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

Ref con01[2];
static inline uint
mix(uint x0, uint x1)
{
 return x0 + 17*x1;
}
static inline uint
rhash(Ref r)
{
 return mix(r.type, r.val);
}
static uint
ihash(Ins *i)
{
 uint h;
 h = mix(i->op, i->cls);
 h = mix(h, rhash(i->arg[0]));
 h = mix(h, rhash(i->arg[1]));
 return h;
}
static int
ieq(Ins *ia, Ins *ib)
{
 if (ia->op == ib->op)
 if (ia->cls == ib->cls)
 if (req(ia->arg[0], ib->arg[0]))
 if (req(ia->arg[1], ib->arg[1]))
  return 1;
 return 0;
}
static Ins **gvntbl;
static uint gvntbln;
static Ins *
gvndup(Ins *i, int insert)
{
 uint idx;
 Ins *ii;
 idx = ihash(i) % gvntbln;
 for (;;) {
  ii = gvntbl[idx];
  if (!ii)
   break;
  if (ieq(i, ii))
   return ii;
  idx++;
  if (gvntbln <= idx)
   idx = 0;
 }
 if (insert)
  gvntbl[idx] = i;
 return 0;
}
static void
replaceuse(Fn *fn, Use *u, Ref r1, Ref r2)
{
 Blk *b;
 Ins *i;
 Phi *p;
 Ref *pr;
 Tmp *t2;
 int n;
 t2 = 0;
 if (rtype(r2) == RTmp)
  t2 = &fn->tmp[r2.val];
 b = fn->rpo[u->bid];
 switch (u->type) {
 case UPhi:
  p = u->u.phi;
  for (pr=p->arg; pr<&p->arg[p->narg]; pr++)
   if (req(*pr, r1))
    *pr = r2;
  if (t2)
   adduse(t2, UPhi, b, p);
  break;
 case UIns:
  i = u->u.ins;
  for (n=0; n<2; n++)
   if (req(i->arg[n], r1))
    i->arg[n] = r2;
  if (t2)
   adduse(t2, UIns, b, i);
  break;
 case UJmp:
  if (req(b->jmp.arg, r1))
   b->jmp.arg = r2;
  if (t2)
   adduse(t2, UJmp, b);
  break;
 case UXXX:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/gvn.c", "unreachable");
 }
}
static void
replaceuses(Fn *fn, Ref r1, Ref r2)
{
 Tmp *t1;
 Use *u;
 ((void)0);
 t1 = &fn->tmp[r1.val];
 for (u=t1->use; u<&t1->use[t1->nuse]; u++)
  replaceuse(fn, u, r1, r2);
 t1->nuse = 0;
}
static void
dedupphi(Fn *fn, Blk *b)
{
 Phi *p, **pp;
 Ref r;
 for (pp=&b->phi; (p=*pp);) {
  r = phicopyref(fn, b, p);
  if (!req(r, (Ref){RTmp, 0})) {
   replaceuses(fn, p->to, r);
   p->to = (Ref){RTmp, 0};
   *pp = p->link;
  } else
   pp = &p->link;
 }
}
static int
rcmp(Ref a, Ref b)
{
 if (rtype(a) != rtype(b))
  return rtype(a) - rtype(b);
 return a.val - b.val;
}
static void
normins(Fn *fn, Ins *i)
{
 uint n;
 int64_t v;
 Ref r;
 for (n=0; n<2; n++) {
  if (!((argcls(i, n))&1))
  if (isconbits(fn, i->arg[n], &v))
  if ((v & 0xffffffff) != v)
   i->arg[n] = getcon(v & 0xffffffff, fn);
 }
 if (optab[i->op].commutes)
 if (rcmp(i->arg[0], i->arg[1]) > 0) {
  r = i->arg[1];
  i->arg[1] = i->arg[0];
  i->arg[0] = r;
 }
}
static int
negcon(int cls, Con *c)
{
 static Con z = {.type = CBits, .bits.i = 0};
 return foldint(c, Osub, cls, &z, c);
}
static void
assoccon(Fn *fn, Blk *b, Ins *i1)
{
 Tmp *t2;
 Ins *i2;
 int op, fail;
 Con c, c1, c2;
 op = i1->op;
 if (op == Osub)
  op = Oadd;
 if (!optab[op].assoc
 || ((i1->cls)>>1) != 0
 || rtype(i1->arg[0]) != RTmp
 || rtype(i1->arg[1]) != RCon)
  return;
 c1 = fn->con[i1->arg[1].val];
 t2 = &fn->tmp[i1->arg[0].val];
 if (t2->def == 0)
  return;
 i2 = t2->def;
 if (op != (i2->op == Osub ? Oadd : i2->op)
 || rtype(i2->arg[1]) != RCon)
  return;
 c2 = fn->con[i2->arg[1].val];
 ((void)0);
 ((void)0);
 if (i1->op == Osub && negcon(i1->cls, &c1))
  return;
 if (i2->op == Osub && negcon(i2->cls, &c2))
  return;
 if (foldint(&c, op, i1->cls, &c1, &c2))
  return;
 if (op == Oadd && c.type == CBits)
 if ((i1->cls == Kl && c.bits.i < 0)
 || (i1->cls == Kw && (int32_t)c.bits.i < 0)) {
  fail = negcon(i1->cls, &c);
  ((void)0);
  op = Osub;
 }
 i1->op = op;
 i1->arg[0] = i2->arg[0];
 i1->arg[1] = newcon(&c, fn);
 adduse(&fn->tmp[i1->arg[0].val], UIns, b, i1);
}
static void
killins(Fn *fn, Ins *i, Ref r)
{
 replaceuses(fn, i->to, r);
 *i = (Ins){.op = Onop};
}
static void
dedupins(Fn *fn, Blk *b, Ins *i)
{
 Ref r;
 Ins *i1;
 normins(fn, i);
 if (i->op == Onop || pinned(i))
  return;
 ((void)0);
 ((void)0);
 assoccon(fn, b, i);
 r = copyref(fn, b, i);
 if (!req(r, (Ref){RTmp, 0})) {
  killins(fn, i, r);
  return;
 }
 r = foldref(fn, i);
 if (!req(r, (Ref){RTmp, 0})) {
  killins(fn, i, r);
  return;
 }
 i1 = gvndup(i, 1);
 if (i1) {
  killins(fn, i, i1->to);
  return;
 }
}
int
cmpeqz(Fn *fn, Ref r, Ref *arg, int *cls, int *eqval)
{
 Ins *i;
 if (rtype(r) != RTmp)
  return 0;
 i = fn->tmp[r.val].def;
 if (i)
 if (optab[i->op].cmpeqwl)
 if (req(i->arg[1], (Ref){RCon, 1})) {
  *arg = i->arg[0];
  *cls = argcls(i, 0);
  *eqval = optab[i->op].eqval;
  return 1;
 }
 return 0;
}
static int
branchdom(Fn *fn, Blk *bif, Blk *bbr1, Blk *bbr2, Blk *b)
{
 ((void)0);
 if (b != bif
 && dom(bbr1, b)
 && !reachesnotvia(fn, bbr2, b, bif))
  return 1;
 return 0;
}
static int
domzero(Fn *fn, Blk *d, Blk *b, int *z)
{
 if (branchdom(fn, d, d->s1, d->s2, b)) {
  *z = 0;
  return 1;
 }
 if (branchdom(fn, d, d->s2, d->s1, b)) {
  *z = 1;
  return 1;
 }
 return 0;
}
int
zeroval(Fn *fn, Blk *b, Ref r, int cls, int *z)
{
 Blk *d;
 Ref arg;
 int cls1, eqval;
 for (d=b->idom; d; d=d->idom) {
  if (d->jmp.type != Jjnz)
   continue;
  if (req(r, d->jmp.arg)
  && cls == Kw
  && domzero(fn, d, b, z)) {
   return 1;
  }
  if (cmpeqz(fn, d->jmp.arg, &arg, &cls1, &eqval)
  && req(r, arg)
  && cls == cls1
  && domzero(fn, d, b, z)) {
   *z ^= eqval;
   return 1;
  }
 }
 return 0;
}
static int
usecls(Use *u, Ref r, int cls)
{
 int k;
 switch (u->type) {
 case UIns:
  k = Kx;
  if (req(u->u.ins->arg[0], r))
   k = argcls(u->u.ins, 0);
  if (req(u->u.ins->arg[1], r))
  if (k == Kx || !((k)&1))
   k = argcls(u->u.ins, 1);
  return k == Kx ? cls : k;
 case UPhi:
  if (req(u->u.phi->to, (Ref){RTmp, 0}))
   return cls;
  return u->u.phi->cls;
 case UJmp:
  return Kw;
 default:
  break;
 }
 die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/gvn.c", "unreachable");
}
static void
propjnz0(Fn *fn, Blk *bif, Blk *s0, Blk *snon0, Ref r, int cls)
{
 Blk *b;
 Tmp *t;
 Use *u;
 if (s0->npred != 1 || rtype(r) != RTmp)
  return;
 t = &fn->tmp[r.val];
 for (u=t->use; u<&t->use[t->nuse]; u++) {
  b = fn->rpo[u->bid];
  if (usecls(u, r, cls) == cls)
  if (branchdom(fn, bif, s0, snon0, b))
   replaceuse(fn, u, r, (Ref){RCon, 1});
 }
}
static void
dedupjmp(Fn *fn, Blk *b)
{
 Blk **ps;
 int64_t v;
 Ref arg;
 int cls, eqval, z;
 if (b->jmp.type != Jjnz)
  return;
 propjnz0(fn, b, b->s2, b->s1, b->jmp.arg, Kw);
 if (cmpeqz(fn, b->jmp.arg, &arg, &cls, &eqval)) {
  ps = (Blk*[]){b->s1, b->s2};
  propjnz0(fn, b, ps[eqval^1], ps[eqval], arg, cls);
 }
 v = 1;
 z = 0;
 if (b->s1 == b->s2
 || isconbits(fn, b->jmp.arg, &v)
 || zeroval(fn, b, b->jmp.arg, Kw, &z)) {
  if (v == 0 || z)
   b->s1 = b->s2;
  b->s2 = 0;
  b->jmp.type = Jjmp;
  b->jmp.arg = (Ref){RTmp, 0};
 }
}
static void
rebuildcfg(Fn *fn)
{
 uint n, nblk;
 Blk *b, *s, **rpo;
 Ins *i;
 nblk = fn->nblk;
 rpo = emalloc(nblk * sizeof rpo[0]);
 memcpy(rpo, fn->rpo, nblk * sizeof rpo[0]);
 fillcfg(fn);
 s = fn->start;
 for (n=0; n<nblk; n++) {
  b = rpo[n];
  if (b->id != -1u)
   continue;
  ((void)0);
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   if (!optab[i->op].pinned)
   if (gvndup(i, 0) == i)
    addins(&s->ins, &s->nins, i);
 }
 free(rpo);
}
void
gvn(Fn *fn)
{
 Blk *b;
 Phi *p;
 Ins *i;
 uint n, nins;
 con01[0] = getcon(0, fn);
 con01[1] = getcon(1, fn);
 for (b=fn->start; b; b=b->link)
  for (p=b->phi; p; p=p->link)
   p->visit = 0;
 fillloop(fn);
 narrowpars(fn);
 filluse(fn);
 ssacheck(fn);
 nins = 0;
 for (b=fn->start; b; b=b->link) {
  b->visit = 0;
  nins += b->nins;
 }
 gvntbln = nins + nins/2;
 gvntbl = emalloc(gvntbln * sizeof gvntbl[0]);
 for (n=0; n<fn->nblk; n++) {
  b = fn->rpo[n];
  dedupphi(fn, b);
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   dedupins(fn, b, i);
  dedupjmp(fn, b);
 }
 rebuildcfg(fn);
 free(gvntbl);
 gvntbl = 0;
 if (debug['G']) {
  fprintf(__stderrp, "\n> After GVN:\n");
  printfn(fn, __stderrp);
 }
}
