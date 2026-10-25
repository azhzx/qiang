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

typedef struct Rv64Op Rv64Op;
enum Rv64Reg {
 T0 = RXX + 1, T1, T2, T3, T4, T5,
 A0, A1, A2, A3, A4, A5, A6, A7,
 S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,
 FP, SP, GP, TP, RA,
 FT0, FT1, FT2, FT3, FT4, FT5, FT6, FT7, FT8, FT9, FT10,
 FA0, FA1, FA2, FA3, FA4, FA5, FA6, FA7,
 FS0, FS1, FS2, FS3, FS4, FS5, FS6, FS7, FS8, FS9, FS10, FS11,
 T6, FT11,
 NFPR = FS11 - FT0 + 1,
 NGPR = RA - T0 + 1,
 NGPS = A7 - T0 + 1,
 NFPS = FA7 - FT0 + 1,
 NCLR = (S11 - S1 + 1) + (FS11 - FS0 + 1),
};
typedef char make_sure_reg_not_tmp[(FT11 < (int)Tmp0)?1:-1];
struct Rv64Op {
 char imm;
};
extern int rv64_rsave[];
extern int rv64_rclob[];
extern Rv64Op rv64_op[];
bits rv64_retregs(Ref, int[2]);
bits rv64_argregs(Ref, int[2]);
void rv64_abi(Fn *);
void rv64_isel(Fn *);
void rv64_emitfn(Fn *, FILE *);

static int
memarg(Ref *r, int op, Ins *i)
{
 if (((unsigned)(op) - Oloadsb <= Oload - Oloadsb) || op == Ocall)
  return r == &i->arg[0];
 if (((unsigned)(op) - Ostoreb <= Ostored - Ostoreb))
  return r == &i->arg[1];
 return 0;
}
static int
immarg(Ref *r, int op, Ins *i)
{
 return rv64_op[op].imm && r == &i->arg[1];
}
static void
fixarg(Ref *r, int k, Ins *i, Fn *fn)
{
 char buf[32];
 Ref r0, r1;
 int s, n, op;
 Con *c;
 r0 = r1 = *r;
 op = i ? i->op : Ocopy;
 switch (rtype(r0)) {
 case RCon:
  c = &fn->con[r0.val];
  if (c->type == CAddr && memarg(r, op, i))
   break;
  if (((k)>>1) == 0)
  if (c->type == CBits && immarg(r, op, i))
  if (-2048 <= c->bits.i && c->bits.i < 2048)
   break;
  r1 = newtmp("isel", k, fn);
  if (((k)>>1) == 1) {
   ((void)0);
   n = stashbits(c->bits.i, ((k)&1) ? 8 : 4);
   vgrow(&fn->con, ++fn->ncon);
   c = &fn->con[fn->ncon-1];
   sprintf(buf, "\"%sfp%d\"", T.asloc, n);
   *c = (Con){.type = CAddr};
   c->sym.id = intern(buf);
   emit(Oload, k, r1, (Ref){RCon, c-fn->con}, (Ref){RTmp, 0});
   break;
  }
  emit(Ocopy, k, r1, r0, (Ref){RTmp, 0});
  break;
 case RTmp:
  if (isreg(r0))
   break;
  s = fn->tmp[r0.val].slot;
  if (s != -1) {
   if (memarg(r, op, i)) {
    r1 = (Ref){RSlot, (s)&0x1fffffff};
    break;
   }
   r1 = newtmp("isel", k, fn);
   emit(Oaddr, k, r1, (Ref){RSlot, (s)&0x1fffffff}, (Ref){RTmp, 0});
   break;
  }
  if (k == Kw && fn->tmp[r0.val].cls == Kl) {
   r1 = newtmp("isel", k, fn);
   emit(Oextsw, Kl, r1, r0, (Ref){RTmp, 0});
  } else {
   ((void)0);
  }
  break;
 }
 *r = r1;
}
static void
negate(Ref *pr, Fn *fn)
{
 Ref r;
 r = newtmp("isel", Kw, fn);
 emit(Oxor, Kw, *pr, r, getcon(1, fn));
 *pr = r;
}
static void
selcmp(Ins i, int k, int op, Fn *fn)
{
 Ins *icmp;
 Ref r, r0, r1;
 int sign, swap, neg;
 switch (op) {
 case Cieq:
  r = newtmp("isel", k, fn);
  emit(Oreqz, i.cls, i.to, r, (Ref){RTmp, 0});
  emit(Oxor, k, r, i.arg[0], i.arg[1]);
  icmp = curi;
  fixarg(&icmp->arg[0], k, icmp, fn);
  fixarg(&icmp->arg[1], k, icmp, fn);
  return;
 case Cine:
  r = newtmp("isel", k, fn);
  emit(Ornez, i.cls, i.to, r, (Ref){RTmp, 0});
  emit(Oxor, k, r, i.arg[0], i.arg[1]);
  icmp = curi;
  fixarg(&icmp->arg[0], k, icmp, fn);
  fixarg(&icmp->arg[1], k, icmp, fn);
  return;
 case Cisge: sign = 1, swap = 0, neg = 1; break;
 case Cisgt: sign = 1, swap = 1, neg = 0; break;
 case Cisle: sign = 1, swap = 1, neg = 1; break;
 case Cislt: sign = 1, swap = 0, neg = 0; break;
 case Ciuge: sign = 0, swap = 0, neg = 1; break;
 case Ciugt: sign = 0, swap = 1, neg = 0; break;
 case Ciule: sign = 0, swap = 1, neg = 1; break;
 case Ciult: sign = 0, swap = 0, neg = 0; break;
 case NCmpI+Cfeq:
 case NCmpI+Cfge:
 case NCmpI+Cfgt:
 case NCmpI+Cfle:
 case NCmpI+Cflt:
  swap = 0, neg = 0;
  break;
 case NCmpI+Cfuo:
  negate(&i.to, fn);
 case NCmpI+Cfo:
  r0 = newtmp("isel", i.cls, fn);
  r1 = newtmp("isel", i.cls, fn);
  emit(Oand, i.cls, i.to, r0, r1);
  op = ((k)&1) ? Oceqd : Oceqs;
  emit(op, i.cls, r0, i.arg[0], i.arg[0]);
  icmp = curi;
  fixarg(&icmp->arg[0], k, icmp, fn);
  fixarg(&icmp->arg[1], k, icmp, fn);
  emit(op, i.cls, r1, i.arg[1], i.arg[1]);
  icmp = curi;
  fixarg(&icmp->arg[0], k, icmp, fn);
  fixarg(&icmp->arg[1], k, icmp, fn);
  return;
 case NCmpI+Cfne:
  swap = 0, neg = 1;
  i.op = ((k)&1) ? Oceqd : Oceqs;
  break;
 default:
  ((void)0);
 }
 if (op < NCmpI)
  i.op = sign ? Ocsltl : Ocultl;
 if (swap) {
  r = i.arg[0];
  i.arg[0] = i.arg[1];
  i.arg[1] = r;
 }
 if (neg)
  negate(&i.to, fn);
 emiti(i);
 icmp = curi;
 fixarg(&icmp->arg[0], k, icmp, fn);
 fixarg(&icmp->arg[1], k, icmp, fn);
}
static void
sel(Ins i, Fn *fn)
{
 Ins *i0;
 int ck, cc;
 if (((unsigned)(i.op) - Oalloc <= Oalloc1 - Oalloc)) {
  i0 = curi - 1;
  salloc(i.to, i.arg[0], fn);
  fixarg(&i0->arg[0], Kl, i0, fn);
  return;
 }
 if (iscmp(i.op, &ck, &cc)) {
  selcmp(i, ck, cc, fn);
  return;
 }
 if (i.op != Onop) {
  emiti(i);
  i0 = curi;
  fixarg(&i0->arg[0], argcls(&i, 0), i0, fn);
  fixarg(&i0->arg[1], argcls(&i, 1), i0, fn);
 }
}
static void
seljmp(Blk *b, Fn *fn)
{
 if (b->jmp.type == Jjnz)
  fixarg(&b->jmp.arg, Kw, 0, fn);
}
void
rv64_isel(Fn *fn)
{
 Blk *b, **sb;
 Ins *i;
 Phi *p;
 uint n;
 int al;
 int64_t sz;
 b = fn->start;
 for (al=Oalloc, n=4; al<=Oalloc1; al++, n*=2)
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   if (i->op == al) {
    if (rtype(i->arg[0]) != RCon)
     break;
    sz = fn->con[i->arg[0].val].bits.i;
    if (sz < 0 || sz >= 2147483647 -15)
     err("invalid alloc size %""ld", sz);
    sz = (sz + n-1) & -n;
    sz /= 4;
    if (sz > 2147483647 - fn->slot)
     die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/isel.c", "alloc too large");
    fn->tmp[i->to.val].slot = fn->slot;
    fn->slot += sz;
    *i = (Ins){.op = Onop};
   }
 for (b=fn->start; b; b=b->link) {
  curi = &insb[NIns];
  for (sb=(Blk*[3]){b->s1, b->s2, 0}; *sb; sb++)
   for (p=(*sb)->phi; p; p=p->link) {
    for (n=0; p->blk[n] != b; n++)
     ((void)0);
    fixarg(&p->arg[n], p->cls, 0, fn);
   }
  seljmp(b, fn);
  for (i=&b->ins[b->nins]; i!=b->ins;)
   sel(*--i, fn);
  idup(b, curi, &insb[NIns]-curi);
 }
 if (debug['I']) {
  fprintf(__stderrp, "\n> After instruction selection:\n");
  printfn(fn, __stderrp);
 }
}
