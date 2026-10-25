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

typedef struct Amd64Op Amd64Op;
enum Amd64Reg {
 RAX = RXX+1,
 RCX,
 RDX,
 RSI,
 RDI,
 R8,
 R9,
 R10,
 R11,
 RBX,
 R12,
 R13,
 R14,
 R15,
 RBP,
 RSP,
 XMM0,
 XMM1,
 XMM2,
 XMM3,
 XMM4,
 XMM5,
 XMM6,
 XMM7,
 XMM8,
 XMM9,
 XMM10,
 XMM11,
 XMM12,
 XMM13,
 XMM14,
 XMM15,
 NFPR = XMM14 - XMM0 + 1,
 NGPR = RSP - RAX + 1,
 NFPS = NFPR,
 NGPS_SYSV = R11 - RAX + 1,
 NCLR_SYSV = R15 - RBX + 1,
 NGPS_WIN = R11 - RAX + 1 - 2,
 NCLR_WIN = R15 - RBX + 1 + 2,
};
typedef char make_sure_reg_not_tmp[(XMM15 < (int)Tmp0)?1:-1];
struct Amd64Op {
 char nmem;
 char zflag;
 char lflag;
};
extern Amd64Op amd64_op[];
extern int amd64_sysv_rsave[];
extern int amd64_sysv_rclob[];
bits amd64_sysv_retregs(Ref, int[2]);
bits amd64_sysv_argregs(Ref, int[2]);
void amd64_sysv_abi(Fn *);
extern int amd64_winabi_rsave[];
extern int amd64_winabi_rclob[];
bits amd64_winabi_retregs(Ref, int[2]);
bits amd64_winabi_argregs(Ref, int[2]);
void amd64_winabi_abi(Fn *);
void amd64_isel(Fn *);
void amd64_sysv_emitfn(Fn *, FILE *);
void amd64_winabi_emitfn(Fn *, FILE *);
static int amatch(Addr *, Num *, Ref, Fn *);
static int
noimm(Ref r, Fn *fn)
{
 int64_t val;
 if (rtype(r) != RCon)
  return 0;
 switch (fn->con[r.val].type) {
 case CAddr:
  return 0;
 case CBits:
  val = fn->con[r.val].bits.i;
  return (val < (-2147483647-1) || val > 2147483647);
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/isel.c", "invalid constant");
 }
}
static int
rslot(Ref r, Fn *fn)
{
 if (rtype(r) != RTmp)
  return -1;
 return fn->tmp[r.val].slot;
}
static int
hascon(Ref r, Con **pc, Fn *fn)
{
 switch (rtype(r)) {
 case RCon:
  *pc = &fn->con[r.val];
  return 1;
 case RMem:
  *pc = &fn->mem[r.val].offset;
  return 1;
 default:
  return 0;
 }
}
static void
fixarg(Ref *r, int k, Ins *i, Fn *fn)
{
 char buf[32];
 Addr a, *m;
 Con cc, *c;
 Ref r0, r1, r2, r3;
 int s, n, op;
 r1 = r0 = *r;
 s = rslot(r0, fn);
 op = i ? i->op : Ocopy;
 if (((k)>>1) == 1 && rtype(r0) == RCon) {
  r1 = (Ref){RMem, fn->nmem};
  vgrow(&fn->mem, ++fn->nmem);
  memset(&a, 0, sizeof a);
  a.offset.type = CAddr;
  n = stashbits(fn->con[r0.val].bits.i, ((k)&1) ? 8 : 4);
  sprintf(buf, "\"%sfp%d\"", T.asloc, n);
  a.offset.sym.id = intern(buf);
  fn->mem[fn->nmem-1] = a;
 }
 else if (op == Ocall && r == &i->arg[0]
 && rtype(r0) == RCon && fn->con[r0.val].type != CAddr) {
  r1 = newtmp("isel", Kl, fn);
  emit(Ocopy, Kl, r1, r0, (Ref){RTmp, 0});
 }
 else if (op != Ocopy && k == Kl && noimm(r0, fn)) {
  r1 = newtmp("isel", Kl, fn);
  emit(Ocopy, Kl, r1, r0, (Ref){RTmp, 0});
 }
 else if (s != -1) {
  r1 = newtmp("isel", Kl, fn);
  emit(Oaddr, Kl, r1, (Ref){RSlot, (s)&0x1fffffff}, (Ref){RTmp, 0});
 }
 else if (op != Ocall && hascon(r0, &c, fn)
 && c->type == CAddr && ((c->sym.type & SExt)
  || (T.apple && c->sym.type == SThr))) {
  r1 = newtmp("isel", Kl, fn);
  if (c->bits.i) {
   r2 = newtmp("isel", Kl, fn);
   cc = (Con){.type = CBits};
   cc.bits.i = c->bits.i;
   r3 = newcon(&cc, fn);
   emit(Oadd, Kl, r1, r2, r3);
  } else
   r2 = r1;
  if (T.apple && (c->sym.type & SThr)) {
   emit(Ocopy, Kl, r2, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
   r2 = newtmp("isel", Kl, fn);
   r3 = newtmp("isel", Kl, fn);
   emit(Ocall, 0, (Ref){RTmp, 0}, r3, (Ref){RCall, 17});
   emit(Ocopy, Kl, (Ref){RTmp, RDI}, r2, (Ref){RTmp, 0});
   emit(Oload, Kl, r3, r2, (Ref){RTmp, 0});
  }
  cc = *c;
  cc.bits.i = 0;
  r3 = newcon(&cc, fn);
  emit(Oaddr, Kl, r2, r3, (Ref){RTmp, 0});
  if (rtype(r0) == RMem) {
   m = &fn->mem[r0.val];
   m->offset.type = CUndef;
   m->base = r1;
   r1 = r0;
  }
 }
 else if (!(((unsigned)(op) - Ostoreb <= Ostored - Ostoreb) && r == &i->arg[1])
 && !((unsigned)(op) - Oloadsb <= Oload - Oloadsb) && op != Ocall && rtype(r0) == RCon
 && fn->con[r0.val].type == CAddr) {
  r1 = newtmp("isel", Kl, fn);
  emit(Oaddr, Kl, r1, r0, (Ref){RTmp, 0});
 }
 else if (rtype(r0) == RMem) {
  m = &fn->mem[r0.val];
  if (req(m->base, (Ref){RTmp, 0}))
  if (m->offset.type == CAddr) {
   r0 = newtmp("isel", Kl, fn);
   emit(Oaddr, Kl, r0, newcon(&m->offset, fn), (Ref){RTmp, 0});
   m->offset.type = CUndef;
   m->base = r0;
  }
 }
 else if (((unsigned)(op) - Oxsel <= Oxsel1 - Oxsel) && rtype(*r) == RCon) {
  r1 = newtmp("isel", i->cls, fn);
  emit(Ocopy, i->cls, r1, *r, (Ref){RTmp, 0});
 }
 *r = r1;
}
static void
seladdr(Ref *r, Num *tn, Fn *fn)
{
 Addr a;
 Ref r0;
 r0 = *r;
 if (rtype(r0) == RTmp) {
  memset(&a, 0, sizeof a);
  if (!amatch(&a, tn, r0, fn))
   return;
  if (!req(a.base, (Ref){RTmp, 0}))
  if (a.offset.type == CAddr) {
   if (!req(a.index, (Ref){RTmp, 0}) || rtype(a.base) != RTmp)
    return;
   else {
    a.index = a.base;
    a.scale = 1;
    a.base = (Ref){RTmp, 0};
   }
  }
  chuse(r0, -1, fn);
  vgrow(&fn->mem, ++fn->nmem);
  fn->mem[fn->nmem-1] = a;
  chuse(a.base, +1, fn);
  chuse(a.index, +1, fn);
  *r = (Ref){RMem, fn->nmem-1};
 }
}
static int
cmpswap(Ref arg[2], int op)
{
 switch (op) {
 case NCmpI+Cflt:
 case NCmpI+Cfle:
  return 1;
 case NCmpI+Cfgt:
 case NCmpI+Cfge:
  return 0;
 }
 return rtype(arg[0]) == RCon;
}
static void
selcmp(Ref arg[2], int k, int swap, Fn *fn)
{
 Ref r;
 Ins *icmp;
 if (swap) {
  r = arg[1];
  arg[1] = arg[0];
  arg[0] = r;
 }
 emit(Oxcmp, k, (Ref){RTmp, 0}, arg[1], arg[0]);
 icmp = curi;
 if (rtype(arg[0]) == RCon) {
  ((void)0);
  icmp->arg[1] = newtmp("isel", k, fn);
  emit(Ocopy, k, icmp->arg[1], arg[0], (Ref){RTmp, 0});
  fixarg(&curi->arg[0], k, curi, fn);
 }
 fixarg(&icmp->arg[0], k, icmp, fn);
 fixarg(&icmp->arg[1], k, icmp, fn);
}
static void
sel(Ins i, Num *tn, Fn *fn)
{
 Ref r0, r1, tmp[7];
 int x, j, k, kc, sh, swap;
 Ins *i0, *i1;
 if (rtype(i.to) == RTmp)
 if (!isreg(i.to) && !isreg(i.arg[0]) && !isreg(i.arg[1]))
 if (fn->tmp[i.to.val].nuse == 0) {
  chuse(i.arg[0], -1, fn);
  chuse(i.arg[1], -1, fn);
  return;
 }
 i0 = curi;
 k = i.cls;
 switch (i.op) {
 case Odiv:
 case Orem:
 case Oudiv:
 case Ourem:
  if (((k)>>1) == 1)
   goto Emit;
  if (i.op == Odiv || i.op == Oudiv)
   r0 = (Ref){RTmp, RAX}, r1 = (Ref){RTmp, RDX};
  else
   r0 = (Ref){RTmp, RDX}, r1 = (Ref){RTmp, RAX};
  emit(Ocopy, k, i.to, r0, (Ref){RTmp, 0});
  emit(Ocopy, k, (Ref){RTmp, 0}, r1, (Ref){RTmp, 0});
  if (rtype(i.arg[1]) == RCon) {
   r0 = newtmp("isel", k, fn);
  } else
   r0 = i.arg[1];
  if (fn->tmp[r0.val].slot != -1)
   err("unlikely argument %%%s in %s",
    fn->tmp[r0.val].name, optab[i.op].name);
  if (i.op == Odiv || i.op == Orem) {
   emit(Oxidiv, k, (Ref){RTmp, 0}, r0, (Ref){RTmp, 0});
   emit(Osign, k, (Ref){RTmp, RDX}, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
  } else {
   emit(Oxdiv, k, (Ref){RTmp, 0}, r0, (Ref){RTmp, 0});
   emit(Ocopy, k, (Ref){RTmp, RDX}, (Ref){RCon, 1}, (Ref){RTmp, 0});
  }
  emit(Ocopy, k, (Ref){RTmp, RAX}, i.arg[0], (Ref){RTmp, 0});
  fixarg(&curi->arg[0], k, curi, fn);
  if (rtype(i.arg[1]) == RCon)
   emit(Ocopy, k, r0, i.arg[1], (Ref){RTmp, 0});
  break;
 case Osar:
 case Oshr:
 case Oshl:
  r0 = i.arg[1];
  if (rtype(r0) == RCon)
   goto Emit;
  if (fn->tmp[r0.val].slot != -1)
   err("unlikely argument %%%s in %s",
    fn->tmp[r0.val].name, optab[i.op].name);
  i.arg[1] = (Ref){RTmp, RCX};
  emit(Ocopy, Kw, (Ref){RTmp, 0}, (Ref){RTmp, RCX}, (Ref){RTmp, 0});
  emiti(i);
  i1 = curi;
  emit(Ocopy, Kw, (Ref){RTmp, RCX}, r0, (Ref){RTmp, 0});
  fixarg(&i1->arg[0], argcls(&i, 0), i1, fn);
  break;
 case Ouwtof:
  r0 = newtmp("utof", Kl, fn);
  emit(Osltof, k, i.to, r0, (Ref){RTmp, 0});
  emit(Oextuw, Kl, r0, i.arg[0], (Ref){RTmp, 0});
  fixarg(&curi->arg[0], k, curi, fn);
  break;
 case Oultof:
  r0 = newtmp("utof", k, fn);
  if (k == Ks)
   kc = Kw, sh = 23;
  else
   kc = Kl, sh = 52;
  for (j=0; j<4; j++)
   tmp[j] = newtmp("utof", Kl, fn);
  for (; j<7; j++)
   tmp[j] = newtmp("utof", kc, fn);
  emit(Ocast, k, i.to, tmp[6], (Ref){RTmp, 0});
  emit(Oadd, kc, tmp[6], tmp[4], tmp[5]);
  emit(Oshl, kc, tmp[5], tmp[1], getcon(sh, fn));
  emit(Ocast, kc, tmp[4], r0, (Ref){RTmp, 0});
  emit(Osltof, k, r0, tmp[3], (Ref){RTmp, 0});
  emit(Oor, Kl, tmp[3], tmp[0], tmp[2]);
  emit(Oshr, Kl, tmp[2], i.arg[0], tmp[1]);
  sel(*curi++, 0, fn);
  emit(Oshr, Kl, tmp[1], i.arg[0], getcon(63, fn));
  fixarg(&curi->arg[0], Kl, curi, fn);
  emit(Oand, Kl, tmp[0], i.arg[0], getcon(1, fn));
  fixarg(&curi->arg[0], Kl, curi, fn);
  break;
 case Ostoui:
  i.op = Ostosi;
  kc = Ks;
  tmp[4] = getcon(0xdf000000, fn);
  goto Oftoui;
 case Odtoui:
  i.op = Odtosi;
  kc = Kd;
  tmp[4] = getcon(0xc3e0000000000000, fn);
 Oftoui:
  if (k == Kw) {
   r0 = newtmp("ftou", Kl, fn);
   emit(Ocopy, Kw, i.to, r0, (Ref){RTmp, 0});
   i.cls = Kl;
   i.to = r0;
   goto Emit;
  }
  r0 = newtmp("ftou", kc, fn);
  for (j=0; j<4; j++)
   tmp[j] = newtmp("ftou", Kl, fn);
  emit(Oor, Kl, i.to, tmp[0], tmp[3]);
  emit(Oand, Kl, tmp[3], tmp[2], tmp[1]);
  emit(i.op, Kl, tmp[2], r0, (Ref){RTmp, 0});
  emit(Oadd, kc, r0, tmp[4], i.arg[0]);
  i1 = curi;
  fixarg(&i1->arg[0], kc, i1, fn);
  fixarg(&i1->arg[1], kc, i1, fn);
  emit(Osar, Kl, tmp[1], tmp[0], getcon(63, fn));
  emit(i.op, Kl, tmp[0], i.arg[0], (Ref){RTmp, 0});
  fixarg(&curi->arg[0], Kl, curi, fn);
  break;
 case Onop:
  break;
 case Ostored:
 case Ostores:
 case Ostorel:
 case Ostorew:
 case Ostoreh:
 case Ostoreb:
  if (rtype(i.arg[0]) == RCon) {
   if (i.op == Ostored)
    i.op = Ostorel;
   if (i.op == Ostores)
    i.op = Ostorew;
  }
  seladdr(&i.arg[1], tn, fn);
  goto Emit;
 case_Oload:
  seladdr(&i.arg[0], tn, fn);
  goto Emit;
 case Odbgloc:
 case Ocall:
 case Osalloc:
 case Ocopy:
 case Oadd:
 case Osub:
 case Oneg:
 case Omul:
 case Oand:
 case Oor:
 case Oxor:
 case Oxtest:
 case Ostosi:
 case Odtosi:
 case Oswtof:
 case Osltof:
 case Oexts:
 case Otruncd:
 case Ocast:
 case_Oxsel:
 case_Oext:
Emit:
  emiti(i);
  i1 = curi;
  fixarg(&i1->arg[0], argcls(&i, 0), i1, fn);
  fixarg(&i1->arg[1], argcls(&i, 1), i1, fn);
  break;
 case Oalloc4:
 case Oalloc8:
 case Oalloc16:
  salloc(i.to, i.arg[0], fn);
  break;
 default:
  if (((unsigned)(i.op) - Oextsb <= Oextuw - Oextsb))
   goto case_Oext;
  if (((unsigned)(i.op) - Oxsel <= Oxsel1 - Oxsel))
   goto case_Oxsel;
  if (((unsigned)(i.op) - Oloadsb <= Oload - Oloadsb))
   goto case_Oload;
  if (iscmp(i.op, &kc, &x)) {
   switch (x) {
   case NCmpI+Cfeq:
    r0 = newtmp("isel", Kw, fn);
    r1 = newtmp("isel", Kw, fn);
    emit(Oand, Kw, i.to, r0, r1);
    emit(Oflagfo, k, r1, (Ref){RTmp, 0}, (Ref){RTmp, 0});
    i.to = r0;
    break;
   case NCmpI+Cfne:
    r0 = newtmp("isel", Kw, fn);
    r1 = newtmp("isel", Kw, fn);
    emit(Oor, Kw, i.to, r0, r1);
    emit(Oflagfuo, k, r1, (Ref){RTmp, 0}, (Ref){RTmp, 0});
    i.to = r0;
    break;
   }
   swap = cmpswap(i.arg, x);
   if (swap)
    x = cmpop(x);
   emit(Oflag+x, k, i.to, (Ref){RTmp, 0}, (Ref){RTmp, 0});
   selcmp(i.arg, kc, swap, fn);
   break;
  }
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/isel.c", "unknown instruction %s", optab[i.op].name);
 }
 while (i0>curi && --i0) {
  ((void)0);
  ((void)0);
 }
}
static Ins *
flagi(Ins *i0, Ins *i)
{
 while (i>i0) {
  i--;
  if (amd64_op[i->op].zflag)
   return i;
  if (amd64_op[i->op].lflag)
   continue;
  return 0;
 }
 return 0;
}
static Ins*
selsel(Fn *fn, Blk *b, Ins *i, Num *tn)
{
 Ref r, cr[2];
 int c, k, swap, gencmp, gencpy;
 Ins *isel0, *isel1, *fi;
 Tmp *t;
 ((void)0);
 for (isel0=i; b->ins<isel0; isel0--) {
  if (isel0->op == Osel0)
   break;
  ((void)0);
 }
 ((void)0);
 r = isel0->arg[0];
 ((void)0);
 t = &fn->tmp[r.val];
 fi = flagi(b->ins, isel0);
 cr[0] = cr[1] = (Ref){RTmp, 0};
 gencmp = gencpy = swap = 0;
 k = Kw;
 c = Cine;
 if (!fi || !req(fi->to, r)) {
  gencmp = 1;
  cr[0] = r;
  cr[1] = (Ref){RCon, 1};
 }
 else if (iscmp(fi->op, &k, &c)) {
  if (c == NCmpI+Cfeq
  || c == NCmpI+Cfne) {
   c = Cine;
   goto Other;
  }
  swap = cmpswap(fi->arg, c);
  if (swap)
   c = cmpop(c);
  if (t->nuse == 1) {
   gencmp = 1;
   cr[0] = fi->arg[0];
   cr[1] = fi->arg[1];
   *fi = (Ins){.op = Onop};
  }
 }
 else if (fi->op == Oand && t->nuse == 1
      && (rtype(fi->arg[0]) == RTmp ||
          rtype(fi->arg[1]) == RTmp)) {
  fi->op = Oxtest;
  fi->to = (Ref){RTmp, 0};
  if (rtype(fi->arg[1]) == RCon) {
   r = fi->arg[1];
   fi->arg[1] = fi->arg[0];
   fi->arg[0] = r;
  }
 }
 else {
 Other:
  if (t->nuse == 1)
   gencpy = 1;
 }
 for (isel1=i; isel0<isel1; --isel1) {
  isel1->op = Oxsel+c;
  sel(*isel1, tn, fn);
 }
 ((void)0);
 if (gencmp)
  selcmp(cr, k, swap, fn);
 if (gencpy)
  emit(Ocopy, Kw, (Ref){RTmp, 0}, r, (Ref){RTmp, 0});
 *isel0 = (Ins){.op = Onop};
 return isel0;
}
static void
seljmp(Blk *b, Fn *fn)
{
 Ref r;
 int c, k, swap;
 Ins *fi;
 Tmp *t;
 if (b->jmp.type == Jret0
 || b->jmp.type == Jjmp
 || b->jmp.type == Jhlt)
  return;
 ((void)0);
 r = b->jmp.arg;
 t = &fn->tmp[r.val];
 b->jmp.arg = (Ref){RTmp, 0};
 ((void)0);
 if (b->s1 == b->s2) {
  chuse(r, -1, fn);
  b->jmp.type = Jjmp;
  b->s2 = 0;
  return;
 }
 fi = flagi(b->ins, &b->ins[b->nins]);
 if (!fi || !req(fi->to, r)) {
  selcmp((Ref[2]){r, (Ref){RCon, 1}}, Kw, 0, fn);
  b->jmp.type = Jjf + Cine;
 }
 else if (iscmp(fi->op, &k, &c)
      && c != NCmpI+Cfeq
      && c != NCmpI+Cfne) {
  swap = cmpswap(fi->arg, c);
  if (swap)
   c = cmpop(c);
  if (t->nuse == 1) {
   selcmp(fi->arg, k, swap, fn);
   *fi = (Ins){.op = Onop};
  }
  b->jmp.type = Jjf + c;
 }
 else if (fi->op == Oand && t->nuse == 1
      && (rtype(fi->arg[0]) == RTmp ||
          rtype(fi->arg[1]) == RTmp)) {
  fi->op = Oxtest;
  fi->to = (Ref){RTmp, 0};
  b->jmp.type = Jjf + Cine;
  if (rtype(fi->arg[1]) == RCon) {
   r = fi->arg[1];
   fi->arg[1] = fi->arg[0];
   fi->arg[0] = r;
  }
 }
 else {
  if (t->nuse == 1)
   emit(Ocopy, Kw, (Ref){RTmp, 0}, r, (Ref){RTmp, 0});
  b->jmp.type = Jjf + Cine;
 }
}
enum {
 Pob,
 Pbis,
 Pois,
 Pobis,
 Pbi1,
 Pobi1,
};
static int
opn(int op, int l, int r)
{
 static uchar Oaddtbl[91] = {
  2,
  2,2,
  4,4,5,
  6,6,8,8,
  4,4,9,10,9,
  7,7,5,8,9,5,
  4,4,12,10,12,12,12,
  4,4,9,10,9,9,12,9,
  11,11,5,8,9,5,12,9,5,
  7,7,5,8,9,5,12,9,5,5,
  11,11,5,8,9,5,12,9,5,5,5,
  4,4,9,10,9,9,12,9,9,9,9,9,
  7,7,5,8,9,5,12,9,5,5,5,9,5,
 };
 int t;
 if (l < r)
  t = l, l = r, r = t;
 switch (op) {
 case Omul:
  if (2 <= l)
  if (r == 0) {
   return 3;
  }
  return 2;
 case Oadd:
  return Oaddtbl[(l + l*l)/2 + r];
 default:
  return 2;
 }
}
static int
refn(Ref r, Num *tn, Con *con)
{
 int64_t n;
 switch (rtype(r)) {
 case RTmp:
  if (!tn[r.val].n)
   tn[r.val].n = 2;
  return tn[r.val].n;
 case RCon:
  if (con[r.val].type != CBits)
   return 1;
  n = con[r.val].bits.i;
  if (n == 8 || n == 4 || n == 2 || n == 1)
   return 0;
  return 1;
 default:
  return (-2147483647-1);
 }
}
static bits match[13] = {
 [4] = ((bits)1 << (Pob)),
 [5] = ((bits)1 << (Pbi1)),
 [6] = ((bits)1 << (Pob)) | ((bits)1 << (Pois)),
 [7] = ((bits)1 << (Pob)) | ((bits)1 << (Pobi1)),
 [8] = ((bits)1 << (Pbi1)) | ((bits)1 << (Pbis)),
 [9] = ((bits)1 << (Pbi1)) | ((bits)1 << (Pobi1)),
 [10] = ((bits)1 << (Pbi1)) | ((bits)1 << (Pbis)) | ((bits)1 << (Pobi1)) | ((bits)1 << (Pobis)),
 [11] = ((bits)1 << (Pob)) | ((bits)1 << (Pobi1)) | ((bits)1 << (Pobis)),
 [12] = ((bits)1 << (Pbi1)) | ((bits)1 << (Pobi1)) | ((bits)1 << (Pobis)),
};
static uchar *matcher[] = {
 [Pbi1] = (uchar[]){
  1,3,1,3,2,0
 },
 [Pbis] = (uchar[]){
  5,1,8,5,27,1,5,1,2,5,13,3,1,1,3,3,3,2,0,1,
  3,3,3,2,3,1,0,1,29
 },
 [Pob] = (uchar[]){
  1,3,0,3,1,0
 },
 [Pobi1] = (uchar[]){
  5,3,9,9,10,33,12,35,45,1,5,3,11,9,7,9,4,9,
  17,1,3,0,3,1,3,2,0,3,1,1,3,0,34,1,37,1,5,2,
  5,7,2,7,8,37,29,1,3,0,1,32
 },
 [Pobis] = (uchar[]){
  5,2,10,7,11,19,49,1,1,3,3,3,2,1,3,0,3,1,0,
  1,3,0,5,1,8,5,25,1,5,1,2,5,13,3,1,1,3,3,3,
  2,0,1,3,3,3,2,26,1,51,1,5,1,6,5,9,1,3,0,51,
  3,1,1,3,0,45
 },
 [Pois] = (uchar[]){
  1,3,0,1,3,3,3,2,0
 },
};
static void
anumber(Num *tn, Blk *b, Con *con)
{
 Ins *i;
 Num *n;
 for (i=b->ins; i<&b->ins[b->nins]; i++) {
  if (rtype(i->to) != RTmp)
   continue;
  n = &tn[i->to.val];
  n->l = i->arg[0];
  n->r = i->arg[1];
  n->nl = refn(n->l, tn, con);
  n->nr = refn(n->r, tn, con);
  n->n = opn(i->op, n->nl, n->nr);
 }
}
static Ref
adisp(Con *c, Num *tn, Ref r, Fn *fn, int s)
{
 Ref v[2];
 int n;
 while (!req(r, (Ref){RTmp, 0})) {
  ((void)0);
  n = refn(r, tn, fn->con);
  if (!(match[n] & ((bits)1 << (Pob))))
   break;
  runmatch(matcher[Pob], tn, r, v);
  ((void)0);
  addcon(c, &fn->con[v[0].val], s);
  r = v[1];
 }
 return r;
}
static int
amatch(Addr *a, Num *tn, Ref r, Fn *fn)
{
 static int pat[] = {Pobis, Pobi1, Pbis, Pois, Pbi1, -1};
 Ref ro, rb, ri, rs, v[4];
 Con *c, co;
 int s, n, *p;
 if (rtype(r) != RTmp)
  return 0;
 n = refn(r, tn, fn->con);
 memset(v, 0, sizeof v);
 for (p=pat; *p>=0; p++)
  if (match[n] & ((bits)1 << (*p))) {
   runmatch(matcher[*p], tn, r, v);
   break;
  }
 if (*p < 0)
  v[1] = r;
 memset(&co, 0, sizeof co);
 ro = v[0];
 rb = adisp(&co, tn, v[1], fn, 1);
 ri = v[2];
 rs = v[3];
 s = 1;
 if (*p < 0 && co.type != CUndef)
 if (amatch(a, tn, rb, fn))
  return addcon(&a->offset, &co, 1);
 if (!req(ro, (Ref){RTmp, 0})) {
  ((void)0);
  c = &fn->con[ro.val];
  if (!addcon(&co, c, 1))
   return 0;
 }
 if (!req(rs, (Ref){RTmp, 0})) {
  ((void)0);
  c = &fn->con[rs.val];
  ((void)0);
  s = c->bits.i;
 }
 ri = adisp(&co, tn, ri, fn, s);
 *a = (Addr){co, rb, ri, s};
 if (rtype(ri) == RTmp)
 if (fn->tmp[ri.val].slot != -1) {
  if (a->scale != 1
  || fn->tmp[rb.val].slot != -1)
   return 0;
  a->base = ri;
  a->index = rb;
 }
 if (!req(a->base, (Ref){RTmp, 0})) {
  ((void)0);
  s = fn->tmp[a->base.val].slot;
  if (s != -1)
   a->base = (Ref){RSlot, (s)&0x1fffffff};
 }
 return 1;
}
void
amd64_isel(Fn *fn)
{
 Blk *b, **sb;
 Ins *i;
 Phi *p;
 uint a;
 int n, al;
 int64_t sz;
 Num *num;
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
     die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/isel.c", "alloc too large");
    fn->tmp[i->to.val].slot = fn->slot;
    fn->slot += sz;
    fn->salign = 2 + al - Oalloc;
    *i = (Ins){.op = Onop};
   }
 n = fn->ntmp;
 num = emalloc(n * sizeof num[0]);
 for (b=fn->start; b; b=b->link) {
  curi = &insb[NIns];
  for (sb=(Blk*[3]){b->s1, b->s2, 0}; *sb; sb++)
   for (p=(*sb)->phi; p; p=p->link) {
    for (a=0; p->blk[a] != b; a++)
     ((void)0);
    fixarg(&p->arg[a], p->cls, 0, fn);
   }
  memset(num, 0, n * sizeof num[0]);
  anumber(num, b, fn->con);
  seljmp(b, fn);
  for (i=&b->ins[b->nins]; i!=b->ins;) {
   --i;
   ((void)0);
   if (i->op == Osel1)
    i = selsel(fn, b, i, num);
   else
    sel(*i, num, fn);
  }
  idup(b, curi, &insb[NIns]-curi);
 }
 free(num);
 if (debug['I']) {
  fprintf(__stderrp, "\n> After instruction selection:\n");
  printfn(fn, __stderrp);
 }
}
