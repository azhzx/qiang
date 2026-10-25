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

typedef struct E E;
struct E {
 FILE *f;
 Fn *fn;
 uint64_t frame;
 uint padding;
};
enum {
 Ki = -1,
 Ka = -2,
};
static struct {
 short op;
 short cls;
 char *fmt;
} omap[] = {
 { Oadd, Ki, "add %=, %0, %1" },
 { Oadd, Ka, "fadd %=, %0, %1" },
 { Osub, Ki, "sub %=, %0, %1" },
 { Osub, Ka, "fsub %=, %0, %1" },
 { Oneg, Ki, "neg %=, %0" },
 { Oneg, Ka, "fneg %=, %0" },
 { Oand, Ki, "and %=, %0, %1" },
 { Oor, Ki, "orr %=, %0, %1" },
 { Oxor, Ki, "eor %=, %0, %1" },
 { Osar, Ki, "asr %=, %0, %1" },
 { Oshr, Ki, "lsr %=, %0, %1" },
 { Oshl, Ki, "lsl %=, %0, %1" },
 { Omul, Ki, "mul %=, %0, %1" },
 { Omul, Ka, "fmul %=, %0, %1" },
 { Odiv, Ki, "sdiv %=, %0, %1" },
 { Odiv, Ka, "fdiv %=, %0, %1" },
 { Oudiv, Ki, "udiv %=, %0, %1" },
 { Orem, Ki, "sdiv %?, %0, %1\n\tmsub\t%=, %?, %1, %0" },
 { Ourem, Ki, "udiv %?, %0, %1\n\tmsub\t%=, %?, %1, %0" },
 { Ocopy, Ki, "mov %=, %0" },
 { Ocopy, Ka, "fmov %=, %0" },
 { Oswap, Ki, "mov %?, %0\n\tmov\t%0, %1\n\tmov\t%1, %?" },
 { Oswap, Ka, "fmov %?, %0\n\tfmov\t%0, %1\n\tfmov\t%1, %?" },
 { Ostoreb, Kw, "strb %W0, %M1" },
 { Ostoreh, Kw, "strh %W0, %M1" },
 { Ostorew, Kw, "str %W0, %M1" },
 { Ostorel, Kw, "str %L0, %M1" },
 { Ostores, Kw, "str %S0, %M1" },
 { Ostored, Kw, "str %D0, %M1" },
 { Oloadsb, Ki, "ldrsb %=, %M0" },
 { Oloadub, Ki, "ldrb %W=, %M0" },
 { Oloadsh, Ki, "ldrsh %=, %M0" },
 { Oloaduh, Ki, "ldrh %W=, %M0" },
 { Oloadsw, Kw, "ldr %=, %M0" },
 { Oloadsw, Kl, "ldrsw %=, %M0" },
 { Oloaduw, Ki, "ldr %W=, %M0" },
 { Oload, Ka, "ldr %=, %M0" },
 { Oextsb, Ki, "sxtb %=, %W0" },
 { Oextub, Ki, "uxtb %W=, %W0" },
 { Oextsh, Ki, "sxth %=, %W0" },
 { Oextuh, Ki, "uxth %W=, %W0" },
 { Oextsw, Ki, "sxtw %L=, %W0" },
 { Oextuw, Ki, "mov %W=, %W0" },
 { Oexts, Kd, "fcvt %=, %S0" },
 { Otruncd, Ks, "fcvt %=, %D0" },
 { Ocast, Kw, "fmov %=, %S0" },
 { Ocast, Kl, "fmov %=, %D0" },
 { Ocast, Ks, "fmov %=, %W0" },
 { Ocast, Kd, "fmov %=, %L0" },
 { Ostosi, Ka, "fcvtzs %=, %S0" },
 { Ostoui, Ka, "fcvtzu %=, %S0" },
 { Odtosi, Ka, "fcvtzs %=, %D0" },
 { Odtoui, Ka, "fcvtzu %=, %D0" },
 { Oswtof, Ka, "scvtf %=, %W0" },
 { Ouwtof, Ka, "ucvtf %=, %W0" },
 { Osltof, Ka, "scvtf %=, %L0" },
 { Oultof, Ka, "ucvtf %=, %L0" },
 { Ocall, Kw, "blr %L0" },
 { Oacmp, Ki, "cmp %0, %1" },
 { Oacmn, Ki, "cmn %0, %1" },
 { Oafcmp, Ka, "fcmpe %0, %1" },
 { Oflag+Cieq, Ki, "cset %=, " "eq" }, { Oflag+Cine, Ki, "cset %=, " "ne" }, { Oflag+Cisge, Ki, "cset %=, " "ge" }, { Oflag+Cisgt, Ki, "cset %=, " "gt" }, { Oflag+Cisle, Ki, "cset %=, " "le" }, { Oflag+Cislt, Ki, "cset %=, " "lt" }, { Oflag+Ciuge, Ki, "cset %=, " "cs" }, { Oflag+Ciugt, Ki, "cset %=, " "hi" }, { Oflag+Ciule, Ki, "cset %=, " "ls" }, { Oflag+Ciult, Ki, "cset %=, " "cc" }, { Oflag+NCmpI+Cfeq, Ki, "cset %=, " "eq" }, { Oflag+NCmpI+Cfge, Ki, "cset %=, " "ge" }, { Oflag+NCmpI+Cfgt, Ki, "cset %=, " "gt" }, { Oflag+NCmpI+Cfle, Ki, "cset %=, " "ls" }, { Oflag+NCmpI+Cflt, Ki, "cset %=, " "mi" }, { Oflag+NCmpI+Cfne, Ki, "cset %=, " "ne" }, { Oflag+NCmpI+Cfo, Ki, "cset %=, " "vc" }, { Oflag+NCmpI+Cfuo, Ki, "cset %=, " "vs" },
 { NOp, 0, 0 }
};
enum {
 V31 = 0x1fffffff,
};
static char *
rname(int r, int k)
{
 static char buf[4];
 if (r == SP) {
  ((void)0);
  sprintf(buf, "sp");
 }
 else if (R0 <= r && r <= LR)
  switch (k) {
  default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid class");
  case Kw: sprintf(buf, "w%d", r-R0); break;
  case Kx:
  case Kl: sprintf(buf, "x%d", r-R0); break;
  }
 else if (V0 <= r && r <= V30)
  switch (k) {
  default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid class");
  case Ks: sprintf(buf, "s%d", r-V0); break;
  case Kx:
  case Kd: sprintf(buf, "d%d", r-V0); break;
  }
 else if (r == V31)
  switch (k) {
  default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid class");
  case Ks: sprintf(buf, "s31"); break;
  case Kd: sprintf(buf, "d31"); break;
  }
 else
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid register");
 return buf;
}
static uint64_t
slot(Ref r, E *e)
{
 int s;
 s = rsval(r);
 if (s == -1)
  return 16 + e->frame;
 if (s < 0) {
  if (e->fn->vararg && !T.apple)
   return 16 + e->frame + 192 - (s+2);
  else
   return 16 + e->frame - (s+2);
 } else
  return 16 + e->padding + 4 * s;
}
static void
emitf(char *s, Ins *i, E *e)
{
 Ref r;
 int k, c;
 Con *pc;
 uint64_t n;
 uint sp;
 fputc('\t', e->f);
 sp = 0;
 for (;;) {
  k = i->cls;
  while ((c = *s++) != '%')
   if (c == ' ' && !sp) {
    fputc('\t', e->f);
    sp = 1;
   } else if (!c) {
    fputc('\n', e->f);
    return;
   } else
    fputc(c, e->f);
 Switch:
  switch ((c = *s++)) {
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid escape");
  case 'W':
   k = Kw;
   goto Switch;
  case 'L':
   k = Kl;
   goto Switch;
  case 'S':
   k = Ks;
   goto Switch;
  case 'D':
   k = Kd;
   goto Switch;
  case '?':
   if (((k)>>1) == 0)
    fputs(rname(IP1, k), e->f);
   else
    fputs(rname(V31, k), e->f);
   break;
  case '=':
  case '0':
   r = c == '=' ? i->to : i->arg[0];
   ((void)0);
   fputs(rname(r.val, k), e->f);
   break;
  case '1':
   r = i->arg[1];
   switch (rtype(r)) {
   default:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid second argument");
   case RTmp:
    ((void)0);
    fputs(rname(r.val, k), e->f);
    break;
   case RCon:
    pc = &e->fn->con[r.val];
    n = pc->bits.i;
    ((void)0);
    if (n >> 24) {
     ((void)0);
     fprintf(e->f, "#%""lu", n);
    } else if (n & 0xfff000) {
     ((void)0);
     fprintf(e->f, "#%""lu"", lsl #12",
      n>>12);
    } else {
     ((void)0);
     fprintf(e->f, "#%""lu", n);
    }
    break;
   }
   break;
  case 'M':
   c = *s++;
   ((void)0);
   r = c == '=' ? i->to : i->arg[c - '0'];
   switch (rtype(r)) {
   default:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "todo (arm emit): unhandled ref");
   case RTmp:
    ((void)0);
    fprintf(e->f, "[%s]", rname(r.val, Kl));
    break;
   case RSlot:
    fprintf(e->f, "[x29, %""lu""]", slot(r, e));
    break;
   }
   break;
  }
 }
}
static void
loadaddr(Con *c, char *rn, E *e)
{
 char *p, *l, *s;
 switch (c->sym.type) {
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "unreachable");
 case SGlo:
  if (T.apple)
   s = "\tadrp\tR, S@pageO\n"
       "\tadd\tR, R, S@pageoffO\n";
  else
   s = "\tadrp\tR, SO\n"
       "\tadd\tR, R, #:lo12:SO\n";
  break;
 case SExtThr:
  if (!T.apple)
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "extern thread unavailable on arm64");
 case SThr:
  if (T.apple)
   s = "\tadrp\tR, S@tlvppage\n"
       "\tldr\tR, [R, S@tlvppageoff]\n";
  else
   s = "\tmrs\tR, tpidr_el0\n"
       "\tadd\tR, R, #:tprel_hi12:SO, lsl #12\n"
       "\tadd\tR, R, #:tprel_lo12_nc:SO\n";
  break;
 case SExt:
  ((void)0);
  if (T.apple)
   s = "\tadrp\tR, S@gotpage\n"
       "\tldr\tR, [R, S@gotpageoff]\n";
  else
   s = "\tadrp\tR, :got:S\n"
       "\tldr\tR, [R, #:got_lo12:S]\n";
  break;
 }
 l = str(c->sym.id);
 p = l[0] == '"' ? "" : T.assym;
 for (; *s; s++)
  switch (*s) {
  default:
   fputc(*s, e->f);
   break;
  case 'R':
   fputs(rn, e->f);
   break;
  case 'S':
   fputs(p, e->f);
   fputs(l, e->f);
   break;
  case 'O':
   if (c->bits.i)
    fprintf(e->f, "+%""li", c->bits.i);
   break;
  }
}
static void
loadcon(Con *c, int r, int k, E *e)
{
 char *rn;
 int64_t n;
 int w, sh;
 w = ((k)&1);
 rn = rname(r, k);
 n = c->bits.i;
 if (c->type == CAddr) {
  rn = rname(r, Kl);
  loadaddr(c, rn, e);
  return;
 }
 ((void)0);
 if (!w)
  n = (int32_t)n;
 if ((n | 0xffff) == -1 || arm64_logimm(n, k)) {
  fprintf(e->f, "\tmov\t%s, #%""li""\n", rn, n);
 } else {
  fprintf(e->f, "\tmov\t%s, #%d\n",
   rn, (int)(n & 0xffff));
  for (sh=16; n>>=16; sh+=16) {
   if ((!w && sh == 32) || sh == 64)
    break;
   fprintf(e->f, "\tmovk\t%s, #0x%x, lsl #%d\n",
    rn, (uint)(n & 0xffff), sh);
  }
 }
}
static void emitins(Ins *, E *);
static int
fixarg(Ref *pr, int sz, int t, E *e)
{
 Ins *i;
 Ref r;
 uint64_t s;
 r = *pr;
 if (rtype(r) == RSlot) {
  s = slot(r, e);
  if (s > sz * 4095u) {
   if (t < 0)
    return 1;
   i = &(Ins){Oaddr, Kl, (Ref){RTmp, t}, {r}};
   emitins(i, e);
   *pr = (Ref){RTmp, t};
  }
 }
 return 0;
}
static void
emitins(Ins *i, E *e)
{
 char *l, *p, *rn;
 uint64_t s;
 int o, t;
 Ref r;
 Con *c;
 switch (i->op) {
 default:
  if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb))
   fixarg(&i->arg[0], loadsz(i), IP1, e);
  if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb)) {
   t = T.apple ? -1 : R18;
   if (fixarg(&i->arg[1], storesz(i), t, e)) {
    if (req(i->arg[0], (Ref){RTmp, IP1})) {
     fprintf(e->f,
      "\tfmov\t%c31, %c17\n",
      "ds"[i->cls == Kw],
      "xw"[i->cls == Kw]);
     i->arg[0] = (Ref){RTmp, V31};
     i->op = Ostores + (i->cls-Kw);
    }
    fixarg(&i->arg[1], storesz(i), IP1, e);
   }
  }
 Table:
  for (o=0;; o++) {
   if (omap[o].op == NOp)
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "no match for %s(%c)", optab[i->op].name, "wlsd"[i->cls]);
   if (omap[o].op == i->op)
   if (omap[o].cls == i->cls || omap[o].cls == Ka
   || (omap[o].cls == Ki && ((i->cls)>>1) == 0))
    break;
  }
  emitf(omap[o].fmt, i, e);
  break;
 case Onop:
  break;
 case Ocopy:
  if (req(i->to, i->arg[0]))
   break;
  if (rtype(i->to) == RSlot) {
   r = i->to;
   if (!isreg(i->arg[0])) {
    i->to = (Ref){RTmp, IP1};
    emitins(i, e);
    i->arg[0] = i->to;
   }
   i->op = Ostorew + i->cls;
   i->cls = Kw;
   i->arg[1] = r;
   emitins(i, e);
   break;
  }
  ((void)0);
  switch (rtype(i->arg[0])) {
  case RCon:
   c = &e->fn->con[i->arg[0].val];
   loadcon(c, i->to.val, i->cls, e);
   break;
  case RSlot:
   i->op = Oload;
   emitins(i, e);
   break;
  default:
   ((void)0);
   goto Table;
  }
  break;
 case Oaddr:
  ((void)0);
  rn = rname(i->to.val, Kl);
  s = slot(i->arg[0], e);
  if (s <= 4095)
   fprintf(e->f, "\tadd\t%s, x29, #%""lu""\n", rn, s);
  else if (s <= 65535)
   fprintf(e->f,
    "\tmov\t%s, #%""lu""\n"
    "\tadd\t%s, x29, %s\n",
    rn, s, rn, rn
   );
  else
   fprintf(e->f,
    "\tmov\t%s, #%""lu""\n"
    "\tmovk\t%s, #%""lu"", lsl #16\n"
    "\tadd\t%s, x29, %s\n",
    rn, s & 0xFFFF, rn, s >> 16, rn, rn
   );
  break;
 case Ocall:
  if (rtype(i->arg[0]) != RCon)
   goto Table;
  c = &e->fn->con[i->arg[0].val];
  if (c->type != CAddr
  || (c->sym.type & SThr)
  || c->bits.i)
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "invalid call argument");
  l = str(c->sym.id);
  p = l[0] == '"' ? "" : T.assym;
  fprintf(e->f, "\tbl\t%s%s\n", p, l);
  break;
 case Osalloc:
  emitf("sub sp, sp, %0", i, e);
  if (!req(i->to, (Ref){RTmp, 0}))
   emitf("mov %=, sp", i, e);
  break;
 case Odbgloc:
  emitdbgloc(i->arg[0].val, i->arg[1].val, e->f);
  break;
 }
}
static void
framelayout(E *e)
{
 int *r;
 uint o;
 uint64_t f;
 for (o=0, r=arm64_rclob; *r>=0; r++)
  o += 1 & (e->fn->reg >> *r);
 f = e->fn->slot;
 f = (f + 3) & -4;
 o += o & 1;
 e->padding = 4*(f-e->fn->slot);
 e->frame = 4*f + 8*o;
}
void
arm64_emitfn(Fn *fn, FILE *out)
{
 static char *ctoa[][2] = {
  [Cieq] = {"eq", "ne"}, [Cine] = {"ne", "eq"}, [Cisge] = {"ge", "lt"}, [Cisgt] = {"gt", "le"}, [Cisle] = {"le", "gt"}, [Cislt] = {"lt", "ge"}, [Ciuge] = {"cs", "cc"}, [Ciugt] = {"hi", "ls"}, [Ciule] = {"ls", "hi"}, [Ciult] = {"cc", "cs"}, [NCmpI+Cfeq] = {"eq", "ne"}, [NCmpI+Cfge] = {"ge", "lt"}, [NCmpI+Cfgt] = {"gt", "le"}, [NCmpI+Cfle] = {"ls", "hi"}, [NCmpI+Cflt] = {"mi", "pl"}, [NCmpI+Cfne] = {"ne", "eq"}, [NCmpI+Cfo] = {"vc", "vs"}, [NCmpI+Cfuo] = {"vs", "vc"},
 };
 static int id0;
 int s, n, c, lbl, *r;
 uint64_t o;
 Blk *b, *t;
 Ins *i;
 E *e;
 e = &(E){.f = out, .fn = fn};
 if (T.apple)
  e->fn->lnk.align = 4;
 emitfnlnk(e->fn->name, &e->fn->lnk, e->f);
 fputs("\thint\t#34\n", e->f);
 framelayout(e);
 if (e->fn->vararg && !T.apple) {
  for (n=7; n>=0; n--)
   fprintf(e->f, "\tstr\tq%d, [sp, -16]!\n", n);
  for (n=7; n>=0; n-=2)
   fprintf(e->f, "\tstp\tx%d, x%d, [sp, -16]!\n", n-1, n);
 }
 if (e->frame + 16 <= 512)
  fprintf(e->f,
   "\tstp\tx29, x30, [sp, -%""lu""]!\n",
   e->frame + 16
  );
 else if (e->frame <= 4095)
  fprintf(e->f,
   "\tsub\tsp, sp, #%""lu""\n"
   "\tstp\tx29, x30, [sp, -16]!\n",
   e->frame
  );
 else if (e->frame <= 65535)
  fprintf(e->f,
   "\tmov\tx16, #%""lu""\n"
   "\tsub\tsp, sp, x16\n"
   "\tstp\tx29, x30, [sp, -16]!\n",
   e->frame
  );
 else
  fprintf(e->f,
   "\tmov\tx16, #%""lu""\n"
   "\tmovk\tx16, #%""lu"", lsl #16\n"
   "\tsub\tsp, sp, x16\n"
   "\tstp\tx29, x30, [sp, -16]!\n",
   e->frame & 0xFFFF, e->frame >> 16
  );
 fputs("\tmov\tx29, sp\n", e->f);
 s = (e->frame - e->padding) / 4;
 for (r=arm64_rclob; *r>=0; r++)
  if (e->fn->reg & ((bits)1 << (*r))) {
   s -= 2;
   i = &(Ins){.arg = {(Ref){RTmp, *r}, (Ref){RSlot, (s)&0x1fffffff}}};
   i->op = *r >= V0 ? Ostored : Ostorel;
   emitins(i, e);
  }
 for (lbl=0, b=e->fn->start; b; b=b->link) {
  if (lbl || b->npred > 1)
   fprintf(e->f, "%s%d:\n", T.asloc, id0+b->id);
  for (i=b->ins; i!=&b->ins[b->nins]; i++)
   emitins(i, e);
  lbl = 1;
  switch (b->jmp.type) {
  case Jhlt:
   fprintf(e->f, "\tbrk\t#1000\n");
   break;
  case Jret0:
   s = (e->frame - e->padding) / 4;
   for (r=arm64_rclob; *r>=0; r++)
    if (e->fn->reg & ((bits)1 << (*r))) {
     s -= 2;
     i = &(Ins){Oload, 0, (Ref){RTmp, *r}, {(Ref){RSlot, (s)&0x1fffffff}}};
     i->cls = *r >= V0 ? Kd : Kl;
     emitins(i, e);
    }
   if (e->fn->dynalloc)
    fputs("\tmov sp, x29\n", e->f);
   o = e->frame + 16;
   if (e->fn->vararg && !T.apple)
    o += 192;
   if (o <= 504)
    fprintf(e->f,
     "\tldp\tx29, x30, [sp], %""lu""\n",
     o
    );
   else if (o - 16 <= 4095)
    fprintf(e->f,
     "\tldp\tx29, x30, [sp], 16\n"
     "\tadd\tsp, sp, #%""lu""\n",
     o - 16
    );
   else if (o - 16 <= 65535)
    fprintf(e->f,
     "\tldp\tx29, x30, [sp], 16\n"
     "\tmov\tx16, #%""lu""\n"
     "\tadd\tsp, sp, x16\n",
     o - 16
    );
   else
    fprintf(e->f,
     "\tldp\tx29, x30, [sp], 16\n"
     "\tmov\tx16, #%""lu""\n"
     "\tmovk\tx16, #%""lu"", lsl #16\n"
     "\tadd\tsp, sp, x16\n",
     (o - 16) & 0xFFFF, (o - 16) >> 16
    );
   fprintf(e->f, "\tret\n");
   break;
  case Jjmp:
  Jmp:
   if (b->s1 != b->link)
    fprintf(e->f,
     "\tb\t%s%d\n",
     T.asloc, id0+b->s1->id
    );
   else
    lbl = 0;
   break;
  default:
   c = b->jmp.type - Jjf;
   if (c < 0 || c > NCmp)
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/emit.c", "unhandled jump %d", b->jmp.type);
   if (b->link == b->s2) {
    t = b->s1;
    b->s1 = b->s2;
    b->s2 = t;
    n = 0;
   } else
    n = 1;
   fprintf(e->f,
    "\tb%s\t%s%d\n",
    ctoa[c][n], T.asloc, id0+b->s2->id
   );
   goto Jmp;
  }
 }
 id0 += e->fn->nblk;
 if (!T.apple)
  elf_emitfnfin(fn->name, out);
}
