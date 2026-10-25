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

enum Arm64Reg {
 R0 = RXX + 1,
      R1, R2, R3, R4, R5, R6, R7,
 R8, R9, R10, R11, R12, R13, R14, R15,
 IP0, IP1, R18, R19, R20, R21, R22, R23,
 R24, R25, R26, R27, R28, FP, LR, SP,
 V0, V1, V2, V3, V4, V5, V6, V7,
 V8, V9, V10, V11, V12, V13, V14, V15,
 V16, V17, V18, V19, V20, V21, V22, V23,
 V24, V25, V26, V27, V28, V29, V30,
 NFPR = V30 - V0 + 1,
 NGPR = SP - R0 + 1,
 NGPS = R18 - R0 + 1 + 1,
 NFPS = (V7 - V0 + 1) + (V30 - V16 + 1),
 NCLR = (R28 - R19 + 1) + (V15 - V8 + 1),
};
typedef char make_sure_reg_not_tmp[(V30 < (int)Tmp0)?1:-1];
extern int arm64_rsave[];
extern int arm64_rclob[];
bits arm64_retregs(Ref, int[2]);
bits arm64_argregs(Ref, int[2]);
void arm64_abi(Fn *);
void apple_extsb(Fn *);
int arm64_logimm(uint64_t, int);
void arm64_isel(Fn *);
void arm64_emitfn(Fn *, FILE *);

enum Imm {
 Iother,
 Iplo12,
 Iphi12,
 Iplo24,
 Inlo12,
 Inhi12,
 Inlo24
};
static enum Imm
imm(Con *c, int k, int64_t *pn)
{
 int64_t n;
 int i;
 if (c->type != CBits)
  return Iother;
 n = c->bits.i;
 if (k == Kw)
  n = (int32_t)n;
 i = Iplo12;
 if (n < 0) {
  i = Inlo12;
  n = -(uint64_t)n;
 }
 *pn = n;
 if ((n & 0x000fff) == n)
  return i;
 if ((n & 0xfff000) == n)
  return i + 1;
 if ((n & 0xffffff) == n)
  return i + 2;
 return Iother;
}
int
arm64_logimm(uint64_t x, int k)
{
 uint64_t n;
 if (k == Kw)
  x = (x & 0xffffffff) | x << 32;
 if (x & 1)
  x = ~x;
 if (x == 0)
  return 0;
 if (x == 0xaaaaaaaaaaaaaaaa)
  return 1;
 n = x & 0xf;
 if (0x1111111111111111 * n == x)
  goto Check;
 n = x & 0xff;
 if (0x0101010101010101 * n == x)
  goto Check;
 n = x & 0xffff;
 if (0x0001000100010001 * n == x)
  goto Check;
 n = x & 0xffffffff;
 if (0x0000000100000001 * n == x)
  goto Check;
 n = x;
Check:
 return (n & (n + (n & -n))) == 0;
}
static void
fixarg(Ref *pr, int k, int phi, Fn *fn)
{
 char buf[32];
 Con *c, cc;
 Ref r0, r1, r2, r3;
 int s, n;
 r0 = *pr;
 switch (rtype(r0)) {
 case RCon:
  c = &fn->con[r0.val];
  if (c->type == CAddr && ((c->sym.type & SExt)
   || (T.apple && (c->sym.type & SThr)))) {
   r1 = newtmp("isel", Kl, fn);
   *pr = r1;
   if (c->bits.i) {
    r2 = newtmp("isel", Kl, fn);
    cc = (Con){.type = CBits};
    cc.bits.i = c->bits.i;
    r3 = newcon(&cc, fn);
    emit(Oadd, Kl, r1, r2, r3);
    r1 = r2;
   }
   if (T.apple && (c->sym.type & SThr)) {
    emit(Ocopy, Kl, r1, (Ref){RTmp, R0}, (Ref){RTmp, 0});
    r1 = newtmp("isel", Kl, fn);
    r2 = newtmp("isel", Kl, fn);
    emit(Ocall, 0, (Ref){RTmp, 0}, r1, (Ref){RCall, 33});
    emit(Ocopy, Kl, (Ref){RTmp, R0}, r2, (Ref){RTmp, 0});
    emit(Oload, Kl, r1, r2, (Ref){RTmp, 0});
    r1 = r2;
   }
   cc = *c;
   cc.bits.i = 0;
   r3 = newcon(&cc, fn);
   emit(Ocopy, Kl, r1, r3, (Ref){RTmp, 0});
   break;
  }
  if (((k)>>1) == 0 && phi)
   return;
  r1 = newtmp("isel", k, fn);
  if (((k)>>1) == 0) {
   emit(Ocopy, k, r1, r0, (Ref){RTmp, 0});
  } else {
   n = stashbits(c->bits.i, ((k)&1) ? 8 : 4);
   vgrow(&fn->con, ++fn->ncon);
   c = &fn->con[fn->ncon-1];
   sprintf(buf, "\"%sfp%d\"", T.asloc, n);
   *c = (Con){.type = CAddr};
   c->sym.id = intern(buf);
   r2 = newtmp("isel", Kl, fn);
   emit(Oload, k, r1, r2, (Ref){RTmp, 0});
   emit(Ocopy, Kl, r2, (Ref){RCon, c-fn->con}, (Ref){RTmp, 0});
  }
  *pr = r1;
  break;
 case RTmp:
  s = fn->tmp[r0.val].slot;
  if (s == -1)
   break;
  r1 = newtmp("isel", Kl, fn);
  emit(Oaddr, Kl, r1, (Ref){RSlot, (s)&0x1fffffff}, (Ref){RTmp, 0});
  *pr = r1;
  break;
 }
}
static int
selcmp(Ref arg[2], int k, Fn *fn)
{
 Ref r, *iarg;
 Con *c;
 int swap, cmp, fix;
 int64_t n;
 if (((k)>>1) == 1) {
  emit(Oafcmp, k, (Ref){RTmp, 0}, arg[0], arg[1]);
  iarg = curi->arg;
  fixarg(&iarg[0], k, 0, fn);
  fixarg(&iarg[1], k, 0, fn);
  return 0;
 }
 swap = rtype(arg[0]) == RCon;
 if (swap) {
  r = arg[1];
  arg[1] = arg[0];
  arg[0] = r;
 }
 fix = 1;
 cmp = Oacmp;
 r = arg[1];
 if (rtype(r) == RCon) {
  c = &fn->con[r.val];
  switch (imm(c, k, &n)) {
  default:
   break;
  case Iplo12:
  case Iphi12:
   fix = 0;
   break;
  case Inlo12:
  case Inhi12:
   cmp = Oacmn;
   r = getcon(n, fn);
   fix = 0;
   break;
  }
 }
 emit(cmp, k, (Ref){RTmp, 0}, arg[0], r);
 iarg = curi->arg;
 fixarg(&iarg[0], k, 0, fn);
 if (fix)
  fixarg(&iarg[1], k, 0, fn);
 return swap;
}
static int
callable(Ref r, Fn *fn)
{
 Con *c;
 if (rtype(r) == RTmp)
  return 1;
 if (rtype(r) == RCon) {
  c = &fn->con[r.val];
  if (c->type == CAddr)
  if (c->bits.i == 0)
   return 1;
 }
 return 0;
}
static void
sel(Ins i, Fn *fn)
{
 Ref *iarg;
 Ins *i0;
 int ck, cc;
 if (((unsigned)(i.op) - Oalloc <= Oalloc1 - Oalloc)) {
  i0 = curi - 1;
  salloc(i.to, i.arg[0], fn);
  fixarg(&i0->arg[0], Kl, 0, fn);
  return;
 }
 if (iscmp(i.op, &ck, &cc)) {
  emit(Oflag, i.cls, i.to, (Ref){RTmp, 0}, (Ref){RTmp, 0});
  i0 = curi;
  if (selcmp(i.arg, ck, fn))
   i0->op += cmpop(cc);
  else
   i0->op += cc;
  return;
 }
 if (i.op == Ocall)
 if (callable(i.arg[0], fn)) {
  emiti(i);
  return;
 }
 if (i.op != Onop) {
  emiti(i);
  iarg = curi->arg;
  fixarg(&iarg[0], argcls(&i, 0), 0, fn);
  fixarg(&iarg[1], argcls(&i, 1), 0, fn);
 }
}
static void
seljmp(Blk *b, Fn *fn)
{
 Ref r;
 Ins *i, *ir;
 int ck, cc, use;
 if (b->jmp.type == Jret0
 || b->jmp.type == Jjmp
 || b->jmp.type == Jhlt)
  return;
 ((void)0);
 r = b->jmp.arg;
 use = -1;
 b->jmp.arg = (Ref){RTmp, 0};
 ir = 0;
 i = &b->ins[b->nins];
 while (i > b->ins)
  if (req((--i)->to, r)) {
   use = fn->tmp[r.val].nuse;
   ir = i;
   break;
  }
 if (ir && use == 1
 && iscmp(ir->op, &ck, &cc)) {
  if (selcmp(ir->arg, ck, fn))
   cc = cmpop(cc);
  b->jmp.type = Jjf + cc;
  *ir = (Ins){.op = Onop};
 }
 else {
  selcmp((Ref[]){r, (Ref){RCon, 1}}, Kw, fn);
  b->jmp.type = Jjfine;
 }
}
void
arm64_isel(Fn *fn)
{
 Blk *b, **sb;
 Ins *i;
 Phi *p;
 uint n, al;
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
    fixarg(&p->arg[n], p->cls, 1, fn);
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
