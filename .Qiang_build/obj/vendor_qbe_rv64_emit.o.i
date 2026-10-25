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

enum {
 Ki = -1,
 Ka = -2,
};
static struct {
 short op;
 short cls;
 char *fmt;
} omap[] = {
 { Oadd, Ki, "add%k %=, %0, %1" },
 { Oadd, Ka, "fadd.%k %=, %0, %1" },
 { Osub, Ki, "sub%k %=, %0, %1" },
 { Osub, Ka, "fsub.%k %=, %0, %1" },
 { Oneg, Ki, "neg%k %=, %0" },
 { Oneg, Ka, "fneg.%k %=, %0" },
 { Odiv, Ki, "div%k %=, %0, %1" },
 { Odiv, Ka, "fdiv.%k %=, %0, %1" },
 { Orem, Ki, "rem%k %=, %0, %1" },
 { Orem, Kl, "rem %=, %0, %1" },
 { Oudiv, Ki, "divu%k %=, %0, %1" },
 { Ourem, Ki, "remu%k %=, %0, %1" },
 { Omul, Ki, "mul%k %=, %0, %1" },
 { Omul, Ka, "fmul.%k %=, %0, %1" },
 { Oand, Ki, "and %=, %0, %1" },
 { Oor, Ki, "or %=, %0, %1" },
 { Oxor, Ki, "xor %=, %0, %1" },
 { Osar, Ki, "sra%k %=, %0, %1" },
 { Oshr, Ki, "srl%k %=, %0, %1" },
 { Oshl, Ki, "sll%k %=, %0, %1" },
 { Ocsltl, Ki, "slt %=, %0, %1" },
 { Ocultl, Ki, "sltu %=, %0, %1" },
 { Oceqs, Ki, "feq.s %=, %0, %1" },
 { Ocges, Ki, "fge.s %=, %0, %1" },
 { Ocgts, Ki, "fgt.s %=, %0, %1" },
 { Ocles, Ki, "fle.s %=, %0, %1" },
 { Oclts, Ki, "flt.s %=, %0, %1" },
 { Oceqd, Ki, "feq.d %=, %0, %1" },
 { Ocged, Ki, "fge.d %=, %0, %1" },
 { Ocgtd, Ki, "fgt.d %=, %0, %1" },
 { Ocled, Ki, "fle.d %=, %0, %1" },
 { Ocltd, Ki, "flt.d %=, %0, %1" },
 { Ostoreb, Kw, "sb %0, %M1" },
 { Ostoreh, Kw, "sh %0, %M1" },
 { Ostorew, Kw, "sw %0, %M1" },
 { Ostorel, Ki, "sd %0, %M1" },
 { Ostores, Kw, "fsw %0, %M1" },
 { Ostored, Kw, "fsd %0, %M1" },
 { Oloadsb, Ki, "lb %=, %M0" },
 { Oloadub, Ki, "lbu %=, %M0" },
 { Oloadsh, Ki, "lh %=, %M0" },
 { Oloaduh, Ki, "lhu %=, %M0" },
 { Oloadsw, Ki, "lw %=, %M0" },
 { Oloaduw, Kw, "lw %=, %M0" },
 { Oloaduw, Kl, "lwu %=, %M0" },
 { Oload, Kw, "lw %=, %M0" },
 { Oload, Kl, "ld %=, %M0" },
 { Oload, Ks, "flw %=, %M0" },
 { Oload, Kd, "fld %=, %M0" },
 { Oextsb, Ki, "sext.b %=, %0" },
 { Oextub, Ki, "zext.b %=, %0" },
 { Oextsh, Ki, "sext.h %=, %0" },
 { Oextuh, Ki, "zext.h %=, %0" },
 { Oextsw, Kl, "sext.w %=, %0" },
 { Oextuw, Kl, "zext.w %=, %0" },
 { Otruncd, Ks, "fcvt.s.d %=, %0" },
 { Oexts, Kd, "fcvt.d.s %=, %0" },
 { Ostosi, Kw, "fcvt.w.s %=, %0, rtz" },
 { Ostosi, Kl, "fcvt.l.s %=, %0, rtz" },
 { Ostoui, Kw, "fcvt.wu.s %=, %0, rtz" },
 { Ostoui, Kl, "fcvt.lu.s %=, %0, rtz" },
 { Odtosi, Kw, "fcvt.w.d %=, %0, rtz" },
 { Odtosi, Kl, "fcvt.l.d %=, %0, rtz" },
 { Odtoui, Kw, "fcvt.wu.d %=, %0, rtz" },
 { Odtoui, Kl, "fcvt.lu.d %=, %0, rtz" },
 { Oswtof, Ka, "fcvt.%k.w %=, %0" },
 { Ouwtof, Ka, "fcvt.%k.wu %=, %0" },
 { Osltof, Ka, "fcvt.%k.l %=, %0" },
 { Oultof, Ka, "fcvt.%k.lu %=, %0" },
 { Ocast, Kw, "fmv.x.w %=, %0" },
 { Ocast, Kl, "fmv.x.d %=, %0" },
 { Ocast, Ks, "fmv.w.x %=, %0" },
 { Ocast, Kd, "fmv.d.x %=, %0" },
 { Ocopy, Ki, "mv %=, %0" },
 { Ocopy, Ka, "fmv.%k %=, %0" },
 { Oswap, Ki, "mv %?, %0\n\tmv %0, %1\n\tmv %1, %?" },
 { Oswap, Ka, "fmv.%k %?, %0\n\tfmv.%k %0, %1\n\tfmv.%k %1, %?" },
 { Oreqz, Ki, "seqz %=, %0" },
 { Ornez, Ki, "snez %=, %0" },
 { Ocall, Kw, "jalr %0" },
 { NOp, 0, 0 }
};
static char *rname[] = {
 [FP] = "fp",
 [SP] = "sp",
 [GP] = "gp",
 [TP] = "tp",
 [RA] = "ra",
 [T0] = "t0", "t1", "t2", "t3", "t4", "t5",
 [A0] = "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
 [S1] = "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8",
        "s9", "s10", "s11",
 [FT0] = "ft0", "ft1", "ft2", "ft3", "ft4", "ft5", "ft6", "ft7",
         "ft8", "ft9", "ft10",
 [FA0] = "fa0", "fa1", "fa2", "fa3", "fa4", "fa5", "fa6", "fa7",
 [FS0] = "fs0", "fs1", "fs2", "fs3", "fs4", "fs5", "fs6", "fs7",
         "fs8", "fs9", "fs10", "fs11",
 [T6] = "t6",
 [FT11] = "ft11",
};
static int64_t
slot(Ref r, Fn *fn)
{
 int s;
 s = rsval(r);
 ((void)0);
 if (s < 0)
  return 8 * -s;
 else
  return -4 * (fn->slot - s);
}
static void
emitaddr(Con *c, FILE *f)
{
 ((void)0);
 fputs(str(c->sym.id), f);
 if (c->bits.i) {
  if (c->sym.type & SExt)
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "extern with offset is not supported");
  fprintf(f, "+%""li", c->bits.i);
 }
}
static void
emitf(char *s, Ins *i, Fn *fn, FILE *f)
{
 static char clschr[] = {'w', 'l', 's', 'd'};
 Ref r;
 int k, c;
 Con *pc;
 int64_t offset;
 fputc('\t', f);
 for (;;) {
  k = i->cls;
  while ((c = *s++) != '%')
   if (!c) {
    fputc('\n', f);
    return;
   } else
    fputc(c, f);
  switch ((c = *s++)) {
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "invalid escape");
  case '?':
   if (((k)>>1) == 0)
    fputs("t6", f);
   else
    fputs("ft11", f);
   break;
  case 'k':
   if (i->cls != Kl)
    fputc(clschr[i->cls], f);
   break;
  case '=':
  case '0':
   r = c == '=' ? i->to : i->arg[0];
   ((void)0);
   fputs(rname[r.val], f);
   break;
  case '1':
   r = i->arg[1];
   switch (rtype(r)) {
   default:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "invalid second argument");
   case RTmp:
    ((void)0);
    fputs(rname[r.val], f);
    break;
   case RCon:
    pc = &fn->con[r.val];
    ((void)0);
    ((void)0);
    fprintf(f, "%d", (int)pc->bits.i);
    break;
   }
   break;
  case 'M':
   c = *s++;
   ((void)0);
   r = i->arg[c - '0'];
   switch (rtype(r)) {
   default:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "invalid address argument");
   case RTmp:
    fprintf(f, "0(%s)", rname[r.val]);
    break;
   case RCon:
    pc = &fn->con[r.val];
    ((void)0);
    emitaddr(pc, f);
    if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb)
    || (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb) && ((i->cls)>>1) == 1)) {
     fprintf(f, ", t6");
    }
    break;
   case RSlot:
    offset = slot(r, fn);
    ((void)0);
    fprintf(f, "%d(fp)", (int)offset);
    break;
   }
   break;
  }
 }
}
static void
loadaddr(Con *c, char *rn, FILE *f)
{
 char off[32];
 switch (c->sym.type) {
 case SGlo:
 case SExt:
  fprintf(f, "\t%s %s, ", c->sym.type == SExt ? "lga" : "lla", rn);
  emitaddr(c, f);
  fputc('\n', f);
  break;
 case SThr:
  if (c->bits.i)
   sprintf(off, "+%""li", c->bits.i);
  else
   off[0] = 0;
  fprintf(f, "\tlui %s, %%tprel_hi(%s)%s\n",
   rn, str(c->sym.id), off);
  fprintf(f, "\tadd %s, %s, tp, %%tprel_add(%s)%s\n",
   rn, rn, str(c->sym.id), off);
  fprintf(f, "\taddi %s, %s, %%tprel_lo(%s)%s\n",
   rn, rn, str(c->sym.id), off);
  break;
 case SExtThr:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "extern thread unavailable on rv64");
 }
}
static void
loadcon(Con *c, int r, int k, FILE *f)
{
 char *rn;
 int64_t n;
 rn = rname[r];
 switch (c->type) {
 case CAddr:
  loadaddr(c, rn, f);
  break;
 case CBits:
  n = c->bits.i;
  if (!((k)&1))
   n = (int32_t)n;
  fprintf(f, "\tli %s, %""li""\n", rn, n);
  break;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "invalid constant");
 }
}
static void
fixmem(Ref *pr, Fn *fn, FILE *f)
{
 Ref r;
 int64_t s;
 Con *c;
 r = *pr;
 if (rtype(r) == RCon) {
  c = &fn->con[r.val];
  if (c->type == CAddr)
  if (c->sym.type != SGlo) {
   loadcon(c, T6, Kl, f);
   *pr = (Ref){RTmp, T6};
  }
 }
 if (rtype(r) == RSlot) {
  s = slot(r, fn);
  if (s < -2048 || s > 2047) {
   fprintf(f, "\tli t6, %""ld""\n", s);
   fprintf(f, "\tadd t6, fp, t6\n");
   *pr = (Ref){RTmp, T6};
  }
 }
}
static void
emitins(Ins *i, Fn *fn, FILE *f)
{
 int o;
 char *rn;
 int64_t s;
 Con *con;
 switch (i->op) {
 default:
  if (((unsigned)(i->op) - Oloadsb <= Oload - Oloadsb))
   fixmem(&i->arg[0], fn, f);
  else if (((unsigned)(i->op) - Ostoreb <= Ostored - Ostoreb))
   fixmem(&i->arg[1], fn, f);
 Table:
  for (o=0;; o++) {
   if (omap[o].op == NOp)
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "no match for %s(%c)", optab[i->op].name, "wlsd"[i->cls]);
   if (omap[o].op == i->op)
   if (omap[o].cls == i->cls || omap[o].cls == Ka
   || (omap[o].cls == Ki && ((i->cls)>>1) == 0))
    break;
  }
  emitf(omap[o].fmt, i, fn, f);
  break;
 case Ocopy:
  if (req(i->to, i->arg[0]))
   break;
  if (rtype(i->to) == RSlot) {
   switch (rtype(i->arg[0])) {
   case RSlot:
   case RCon:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "unimplemented");
    break;
   default:
    ((void)0);
    i->arg[1] = i->to;
    i->to = (Ref){RTmp, 0};
    switch (i->cls) {
    case Kw: i->op = Ostorew; break;
    case Kl: i->op = Ostorel; break;
    case Ks: i->op = Ostores; break;
    case Kd: i->op = Ostored; break;
    }
    fixmem(&i->arg[1], fn, f);
    goto Table;
   }
   break;
  }
  ((void)0);
  switch (rtype(i->arg[0])) {
  case RCon:
   loadcon(&fn->con[i->arg[0].val], i->to.val, i->cls, f);
   break;
  case RSlot:
   i->op = Oload;
   fixmem(&i->arg[0], fn, f);
   goto Table;
  default:
   ((void)0);
   goto Table;
  }
  break;
 case Onop:
  break;
 case Oaddr:
  ((void)0);
  rn = rname[i->to.val];
  s = slot(i->arg[0], fn);
  if (-s < 2048) {
   fprintf(f, "\tadd %s, fp, %""ld""\n", rn, s);
  } else {
   fprintf(f,
    "\tli %s, %""ld""\n"
    "\tadd %s, fp, %s\n",
    rn, s, rn, rn
   );
  }
  break;
 case Ocall:
  switch (rtype(i->arg[0])) {
  case RCon:
   con = &fn->con[i->arg[0].val];
   if (con->type != CAddr
   || (con->sym.type & SThr)
   || con->bits.i)
    goto Invalid;
   fprintf(f, "\tcall %s\n", str(con->sym.id));
   break;
  case RTmp:
   emitf("jalr %0", i, fn, f);
   break;
  default:
  Invalid:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/emit.c", "invalid call argument");
  }
  break;
 case Osalloc:
  emitf("sub sp, sp, %0", i, fn, f);
  if (!req(i->to, (Ref){RTmp, 0}))
   emitf("mv %=, sp", i, fn, f);
  break;
 case Odbgloc:
  emitdbgloc(i->arg[0].val, i->arg[1].val, f);
  break;
 }
}
void
rv64_emitfn(Fn *fn, FILE *f)
{
 static int id0;
 int lbl, neg, off, frame, *pr, r;
 Blk *b, *s;
 Ins *i, ii;
 emitfnlnk(fn->name, &fn->lnk, f);
 if (fn->vararg) {
  fprintf(f, "\tadd sp, sp, -64\n");
  for (r=A0; r<=A7; r++)
   fprintf(f,
    "\tsd %s, %d(sp)\n",
    rname[r], 8 * (r - A0)
   );
 }
 fprintf(f, "\tsd fp, -16(sp)\n");
 fprintf(f, "\tsd ra, -8(sp)\n");
 fprintf(f, "\tadd fp, sp, -16\n");
 frame = (16 + 4 * fn->slot + 15) & ~15;
 for (pr=rv64_rclob; *pr>=0; pr++) {
  if (fn->reg & ((bits)1 << (*pr)))
   frame += 8;
 }
 frame = (frame + 15) & ~15;
 if (frame <= 2048)
  fprintf(f,
   "\tadd sp, sp, -%d\n",
   frame
  );
 else
  fprintf(f,
   "\tli t6, %d\n"
   "\tsub sp, sp, t6\n",
   frame
  );
 for (pr=rv64_rclob, off=0; *pr>=0; pr++) {
  if (fn->reg & ((bits)1 << (*pr))) {
   fprintf(f,
    "\t%s %s, %d(sp)\n",
    *pr < FT0 ? "sd" : "fsd",
    rname[*pr], off
   );
   off += 8;
  }
 }
 for (lbl=0, b=fn->start; b; b=b->link) {
  if (lbl || b->npred > 1)
   fprintf(f, ".L%d:\n", id0+b->id);
  for (i=b->ins; i!=&b->ins[b->nins]; i++)
   emitins(i, fn, f);
  lbl = 1;
  switch (b->jmp.type) {
  case Jhlt:
   fprintf(f, "\tebreak\n");
   break;
  case Jret0:
   if (fn->dynalloc) {
    if (frame - 16 <= 2048)
     fprintf(f,
      "\tadd sp, fp, -%d\n",
      frame - 16
     );
    else
     fprintf(f,
      "\tli t6, %d\n"
      "\tsub sp, fp, t6\n",
      frame - 16
     );
   }
   for (pr=rv64_rclob, off=0; *pr>=0; pr++) {
    if (fn->reg & ((bits)1 << (*pr))) {
     fprintf(f,
      "\t%s %s, %d(sp)\n",
      *pr < FT0 ? "ld" : "fld",
      rname[*pr], off
     );
     off += 8;
    }
   }
   fprintf(f,
    "\tadd sp, fp, %d\n"
    "\tld ra, 8(fp)\n"
    "\tld fp, 0(fp)\n"
    "\tret\n",
    16 + fn->vararg * 64
   );
   break;
  case Jjmp:
  Jmp:
   if (b->s1 != b->link)
    fprintf(f, "\tj .L%d\n", id0+b->s1->id);
   else
    lbl = 0;
   break;
  case Jjnz:
   neg = 0;
   if (b->link == b->s2) {
    s = b->s1;
    b->s1 = b->s2;
    b->s2 = s;
    neg = 1;
   }
   if (rtype(b->jmp.arg) == RSlot) {
    ii.arg[0] = b->jmp.arg;
    emitf("lw t6, %M0", &ii, fn, f);
    b->jmp.arg = (Ref){RTmp, T6};
   }
   ((void)0);
   fprintf(f,
    "\tb%sz %s, .L%d\n",
    neg ? "ne" : "eq",
    rname[b->jmp.arg.val],
    id0+b->s2->id
   );
   goto Jmp;
  }
 }
 id0 += fn->nblk;
 elf_emitfnfin(fn->name, f);
}
