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
typedef struct E E;
struct E {
 FILE *f;
 Fn *fn;
 int fp;
 uint64_t fsz;
 int nclob;
};
enum {
 SLong = 0,
 SWord = 1,
 SShort = 2,
 SByte = 3,
 Ki = -1,
 Ka = -2,
};
static struct {
 short op;
 short cls;
 char *fmt;
} omap[] = {
 { Oadd, Ka, "+add%k %1, %=" },
 { Osub, Ka, "-sub%k %1, %=" },
 { Oand, Ki, "+and%k %1, %=" },
 { Oor, Ki, "+or%k %1, %=" },
 { Oxor, Ki, "+xor%k %1, %=" },
 { Osar, Ki, "-sar%k %B1, %=" },
 { Oshr, Ki, "-shr%k %B1, %=" },
 { Oshl, Ki, "-shl%k %B1, %=" },
 { Omul, Ki, "+imul%k %1, %=" },
 { Omul, Ks, "+mulss %1, %=" },
 { Omul, Kd, "+mulsd %1, %=" },
 { Odiv, Ka, "-div%k %1, %=" },
 { Ostorel, Ka, "movq %L0, %M1" },
 { Ostorew, Ka, "movl %W0, %M1" },
 { Ostoreh, Ka, "movw %H0, %M1" },
 { Ostoreb, Ka, "movb %B0, %M1" },
 { Ostores, Ka, "movss %S0, %M1" },
 { Ostored, Ka, "movsd %D0, %M1" },
 { Oload, Ka, "mov%k %M0, %=" },
 { Oloadsw, Kl, "movslq %M0, %L=" },
 { Oloadsw, Kw, "movl %M0, %W=" },
 { Oloaduw, Ki, "movl %M0, %W=" },
 { Oloadsh, Ki, "movsw%k %M0, %=" },
 { Oloaduh, Ki, "movzw%k %M0, %=" },
 { Oloadsb, Ki, "movsb%k %M0, %=" },
 { Oloadub, Ki, "movzb%k %M0, %=" },
 { Oextsw, Kl, "movslq %W0, %L=" },
 { Oextuw, Kl, "movl %W0, %W=" },
 { Oextsh, Ki, "movsw%k %H0, %=" },
 { Oextuh, Ki, "movzw%k %H0, %=" },
 { Oextsb, Ki, "movsb%k %B0, %=" },
 { Oextub, Ki, "movzb%k %B0, %=" },
 { Oexts, Kd, "cvtss2sd %0, %=" },
 { Otruncd, Ks, "cvtsd2ss %0, %=" },
 { Ostosi, Ki, "cvttss2si%k %0, %=" },
 { Odtosi, Ki, "cvttsd2si%k %0, %=" },
 { Oswtof, Ka, "cvtsi2%k %W0, %=" },
 { Osltof, Ka, "cvtsi2%k %L0, %=" },
 { Ocast, Ki, "movq %D0, %L=" },
 { Ocast, Ka, "movq %L0, %D=" },
 { Oaddr, Ki, "lea%k %M0, %=" },
 { Oswap, Ki, "xchg%k %0, %1" },
 { Osign, Kl, "cqto" },
 { Osign, Kw, "cltd" },
 { Oxdiv, Ki, "div%k %0" },
 { Oxidiv, Ki, "idiv%k %0" },
 { Oxcmp, Ks, "ucomiss %S0, %S1" },
 { Oxcmp, Kd, "ucomisd %D0, %D1" },
 { Oxcmp, Ki, "cmp%k %0, %1" },
 { Oxtest, Ki, "test%k %0, %1" },
 { Oflag+Ciule, Ki, "set" "be" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Ciult, Ki, "set" "b" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cisle, Ki, "set" "le" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cislt, Ki, "set" "l" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cisgt, Ki, "set" "g" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cisge, Ki, "set" "ge" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Ciugt, Ki, "set" "a" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Ciuge, Ki, "set" "ae" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cieq, Ki, "set" "z" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+Cine, Ki, "set" "nz" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cfle, Ki, "set" "?" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cflt, Ki, "set" "?" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cfgt, Ki, "set" "a" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cfge, Ki, "set" "ae" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cfo, Ki, "set" "np" " %B=\n\tmovzb%k %B=, %=" }, { Oflag+NCmpI+Cfuo, Ki, "set" "p" " %B=\n\tmovzb%k %B=, %=" },
 { Oflagfeq, Ki, "setz %B=\n\tmovzb%k %B=, %=" },
 { Oflagfne, Ki, "setnz %B=\n\tmovzb%k %B=, %=" },
 { NOp, 0, 0 }
};
static char cmov[][2][16] = {
 [Ciule] = { "cmov" "be" " %0, %=", "cmov" "a" " %1, %=", }, [Ciult] = { "cmov" "b" " %0, %=", "cmov" "ae" " %1, %=", }, [Cisle] = { "cmov" "le" " %0, %=", "cmov" "g" " %1, %=", }, [Cislt] = { "cmov" "l" " %0, %=", "cmov" "ge" " %1, %=", }, [Cisgt] = { "cmov" "g" " %0, %=", "cmov" "le" " %1, %=", }, [Cisge] = { "cmov" "ge" " %0, %=", "cmov" "l" " %1, %=", }, [Ciugt] = { "cmov" "a" " %0, %=", "cmov" "be" " %1, %=", }, [Ciuge] = { "cmov" "ae" " %0, %=", "cmov" "b" " %1, %=", }, [Cieq] = { "cmov" "z" " %0, %=", "cmov" "nz" " %1, %=", }, [Cine] = { "cmov" "nz" " %0, %=", "cmov" "z" " %1, %=", }, [NCmpI+Cfle] = { "cmov" "?" " %0, %=", "cmov" "?" " %1, %=", }, [NCmpI+Cflt] = { "cmov" "?" " %0, %=", "cmov" "?" " %1, %=", }, [NCmpI+Cfgt] = { "cmov" "a" " %0, %=", "cmov" "be" " %1, %=", }, [NCmpI+Cfge] = { "cmov" "ae" " %0, %=", "cmov" "b" " %1, %=", }, [NCmpI+Cfo] = { "cmov" "np" " %0, %=", "cmov" "p" " %1, %=", }, [NCmpI+Cfuo] = { "cmov" "p" " %0, %=", "cmov" "np" " %1, %=", },
};
static char *rname[][4] = {
 [RAX] = {"rax", "eax", "ax", "al"},
 [RBX] = {"rbx", "ebx", "bx", "bl"},
 [RCX] = {"rcx", "ecx", "cx", "cl"},
 [RDX] = {"rdx", "edx", "dx", "dl"},
 [RSI] = {"rsi", "esi", "si", "sil"},
 [RDI] = {"rdi", "edi", "di", "dil"},
 [RBP] = {"rbp", "ebp", "bp", "bpl"},
 [RSP] = {"rsp", "esp", "sp", "spl"},
 [R8 ] = {"r8" , "r8d", "r8w", "r8b"},
 [R9 ] = {"r9" , "r9d", "r9w", "r9b"},
 [R10] = {"r10", "r10d", "r10w", "r10b"},
 [R11] = {"r11", "r11d", "r11w", "r11b"},
 [R12] = {"r12", "r12d", "r12w", "r12b"},
 [R13] = {"r13", "r13d", "r13w", "r13b"},
 [R14] = {"r14", "r14d", "r14w", "r14b"},
 [R15] = {"r15", "r15d", "r15w", "r15b"},
};
static int
slot(Ref r, E *e)
{
 int s;
 s = rsval(r);
 ((void)0);
 if (s < 0) {
  if (e->fp == RSP)
   return 4*-s - 8 + e->fsz + e->nclob*8;
  else
   return 4*-s;
 }
 else if (e->fp == RSP)
  return 4*s + e->nclob*8;
 else if (e->fn->vararg) {
  if (T.windows)
   return -4 * (e->fn->slot - s);
  else
   return -176 + -4 * (e->fn->slot - s);
 } else
  return -4 * (e->fn->slot - s);
}
static void
emitcon(Con *con, E *e)
{
 char *p, *l;
 switch (con->type) {
 case CAddr:
  l = str(con->sym.id);
  p = l[0] == '"' ? "" : T.assym;
  if (con->sym.type == SThr) {
   ((void)0);
   fprintf(e->f, "%%fs:%s%s@tpoff", p, l);
  } else {
   ((void)0);
   fprintf(e->f, "%s%s", p, l);
  }
  if (con->bits.i)
   fprintf(e->f, "%+""ld", con->bits.i);
  break;
 case CBits:
  fprintf(e->f, "%""ld", con->bits.i);
  break;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "unreachable");
 }
}
static char *
regtoa(int reg, int sz)
{
 static char buf[6];
 ((void)0);
 if (reg >= XMM0) {
  sprintf(buf, "xmm%d", reg-XMM0);
  return buf;
 } else
  return rname[reg][sz];
}
static Ref
getarg(char c, Ins *i)
{
 switch (c) {
 case '0':
  return i->arg[0];
 case '1':
  return i->arg[1];
 case '=':
  return i->to;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "invalid arg letter %c", c);
 }
}
static void emitins(Ins, E *);
static void
emitcopy(Ref r1, Ref r2, int k, E *e)
{
 Ins icp;
 icp.op = Ocopy;
 icp.arg[0] = r2;
 icp.to = r1;
 icp.cls = k;
 emitins(icp, e);
}
static void
emitf(char *s, Ins *i, E *e)
{
 static char clstoa[][3] = {"l", "q", "ss", "sd"};
 char c;
 int sz;
 Ref ref;
 Mem *m;
 Con off;
 switch (*s) {
 case '+':
  if (req(i->arg[1], i->to)) {
   ref = i->arg[0];
   i->arg[0] = i->arg[1];
   i->arg[1] = ref;
  }
 case '-':
  ((void)0);
  emitcopy(i->to, i->arg[0], i->cls, e);
  s++;
  break;
 }
 fputc('\t', e->f);
Next:
 while ((c = *s++) != '%')
  if (!c) {
   fputc('\n', e->f);
   return;
  } else
   fputc(c, e->f);
 switch ((c = *s++)) {
 case '%':
  fputc('%', e->f);
  break;
 case 'k':
  fputs(clstoa[i->cls], e->f);
  break;
 case '0':
 case '1':
 case '=':
  sz = ((i->cls)&1) ? SLong : SWord;
  s--;
  goto Ref;
 case 'D':
 case 'S':
  sz = SLong;
 Ref:
  c = *s++;
  ref = getarg(c, i);
  switch (rtype(ref)) {
  case RTmp:
   ((void)0);
   fprintf(e->f, "%%%s", regtoa(ref.val, sz));
   break;
  case RSlot:
   fprintf(e->f, "%d(%%%s)",
    slot(ref, e),
    regtoa(e->fp, SLong)
   );
   break;
  case RMem:
  Mem:
   m = &e->fn->mem[ref.val];
   if (rtype(m->base) == RSlot) {
    off.type = CBits;
    off.bits.i = slot(m->base, e);
    addcon(&m->offset, &off, 1);
    m->base = (Ref){RTmp, e->fp};
   }
   if (m->offset.type != CUndef)
    emitcon(&m->offset, e);
   fputc('(', e->f);
   if (!req(m->base, (Ref){RTmp, 0}))
    fprintf(e->f, "%%%s",
     regtoa(m->base.val, SLong)
    );
   else if (m->offset.type == CAddr)
    fprintf(e->f, "%%rip");
   if (!req(m->index, (Ref){RTmp, 0}))
    fprintf(e->f, ", %%%s, %d",
     regtoa(m->index.val, SLong),
     m->scale
    );
   fputc(')', e->f);
   break;
  case RCon:
   fputc('$', e->f);
   emitcon(&e->fn->con[ref.val], e);
   break;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "unreachable");
  }
  break;
 case 'L':
  sz = SLong;
  goto Ref;
 case 'W':
  sz = SWord;
  goto Ref;
 case 'H':
  sz = SShort;
  goto Ref;
 case 'B':
  sz = SByte;
  goto Ref;
 case 'M':
  c = *s++;
  ref = getarg(c, i);
  switch (rtype(ref)) {
  case RMem:
   goto Mem;
  case RSlot:
   fprintf(e->f, "%d(%%%s)",
    slot(ref, e),
    regtoa(e->fp, SLong)
   );
   break;
  case RCon:
   off = e->fn->con[ref.val];
   emitcon(&off, e);
   if (off.type == CAddr)
   if (off.sym.type != SThr)
    fprintf(e->f, "(%%rip)");
   break;
  case RTmp:
   ((void)0);
   fprintf(e->f, "(%%%s)", regtoa(ref.val, SLong));
   break;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "unreachable");
  }
  break;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "invalid format specifier %%%c", c);
 }
 goto Next;
}
static bits negmask[4] = {
 [Ks] = 0x80000000,
 [Kd] = 0x8000000000000000,
};
static void
emitins(Ins i, E *e)
{
 Ref r;
 int64_t val;
 int o, t0;
 Ins ineg;
 Con *con;
 char *sym;
 switch (i.op) {
 default:
  if (((unsigned)(i.op) - Oxsel <= Oxsel1 - Oxsel))
   goto case_Oxsel;
 Table:
  for (o=0;; o++) {
   if (omap[o].op == NOp)
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "no match for %s(%c)", optab[i.op].name, "wlsd"[i.cls]);
   if (omap[o].op == i.op)
   if (omap[o].cls == i.cls
   || (omap[o].cls == Ki && ((i.cls)>>1) == 0)
   || (omap[o].cls == Ka))
    break;
  }
  emitf(omap[o].fmt, &i, e);
  break;
 case Onop:
  break;
 case Omul:
  if (rtype(i.arg[1]) == RCon) {
   r = i.arg[0];
   i.arg[0] = i.arg[1];
   i.arg[1] = r;
  }
  if (((i.cls)>>1) == 0
  && rtype(i.arg[0]) == RCon
  && rtype(i.arg[1]) == RTmp) {
   emitf("imul%k %0, %1, %=", &i, e);
   break;
  }
  goto Table;
 case Osub:
  if (req(i.to, i.arg[1]) && !req(i.arg[0], i.to)) {
   ineg = (Ins){Oneg, i.cls, i.to, {i.to}};
   emitins(ineg, e);
   emitf("add%k %0, %=", &i, e);
   break;
  }
  goto Table;
 case Oneg:
  if (!req(i.to, i.arg[0]))
   emitf("mov%k %0, %=", &i, e);
  if (((i.cls)>>1) == 0)
   emitf("neg%k %=", &i, e);
  else
   fprintf(e->f,
    "\txorp%c %sfp%d(%%rip), %%%s\n",
    "xxsd"[i.cls],
    T.asloc,
    stashbits(negmask[i.cls], 16),
    regtoa(i.to.val, SLong)
   );
  break;
 case Odiv:
  if (req(i.to, i.arg[1])) {
   i.arg[1] = (Ref){RTmp, XMM0+15};
   emitf("mov%k %=, %1", &i, e);
   emitf("mov%k %0, %=", &i, e);
   i.arg[0] = i.to;
  }
  goto Table;
 case Ocopy:
  ((void)0);
  if (req(i.to, (Ref){RTmp, 0}) || req(i.arg[0], (Ref){RTmp, 0}))
   break;
  if (req(i.to, i.arg[0]))
   break;
  t0 = rtype(i.arg[0]);
  if (i.cls == Kl
  && t0 == RCon
  && e->fn->con[i.arg[0].val].type == CBits) {
   val = e->fn->con[i.arg[0].val].bits.i;
   if (isreg(i.to))
   if (val >= 0 && val <= 4294967295u) {
    emitf("movl %W0, %W=", &i, e);
    break;
   }
   if (rtype(i.to) == RSlot)
   if (val < (-2147483647-1) || val > 2147483647) {
    emitf("movl %0, %=", &i, e);
    emitf("movl %0>>32, 4+%=", &i, e);
    break;
   }
  }
  if (isreg(i.to)
  && t0 == RCon
  && e->fn->con[i.arg[0].val].type == CAddr) {
   emitf("lea%k %M0, %=", &i, e);
   break;
  }
  if (rtype(i.to) == RSlot
  && (t0 == RSlot || t0 == RMem)) {
   i.cls = ((i.cls)&1) ? Kd : Ks;
   i.arg[1] = (Ref){RTmp, XMM0+15};
   emitf("mov%k %0, %1", &i, e);
   emitf("mov%k %1, %=", &i, e);
   break;
  }
  emitf("mov%k %0, %=", &i, e);
  break;
 case Oaddr:
  if (rtype(i.arg[0]) != RCon)
   goto Table;
  con = &e->fn->con[i.arg[0].val];
  ((void)0);
  sym = str(con->sym.id);
  if (T.apple && (con->sym.type & SThr)) {
   fprintf(e->f,
    "\tmovq %s%s@tlvp(%%rip), %%%s\n",
    sym[0] == '"' ? "" : T.assym, sym,
    regtoa(i.to.val, SLong));
   break;
  }
  if (T.windows && con->sym.type != SGlo)
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "extern/thread unsupported on amd64_win");
  switch (con->sym.type) {
  case SThr:
   emitf("movq %%fs:0, %L=", &i, e);
   fprintf(e->f, "\tleaq %s%s@tpoff",
    sym[0] == '"' ? "" : T.assym, sym);
   if (con->bits.i)
    fprintf(e->f, "%+""ld",
     con->bits.i);
   fprintf(e->f, "(%%%s), %%%s\n",
    regtoa(i.to.val, SLong),
    regtoa(i.to.val, SLong));
   break;
  case SExtThr:
   ((void)0);
   emitf("movq %%fs:0, %L=", &i, e);
   fprintf(e->f,
    "\taddq %s%s@gottpoff(%%rip), %%%s\n",
    sym[0] == '"' ? "" : T.assym, sym,
    regtoa(i.to.val, SLong));
   break;
  case SExt:
   ((void)0);
   fprintf(e->f,
    "\tmovq %s%s@gotpcrel(%%rip), %%%s\n",
    sym[0] == '"' ? "" : T.assym, sym,
    regtoa(i.to.val, SLong));
   break;
  default:
   goto Table;
  }
  break;
 case Ocall:
  switch (rtype(i.arg[0])) {
  case RCon:
   con = &e->fn->con[i.arg[0].val];
   fprintf(e->f, "\tcallq ");
   emitcon(con, e);
   if (con->type == CAddr
   && (con->sym.type & SExt)
   && !T.apple)
    fprintf(e->f, "@plt");
   fprintf(e->f, "\n");
   break;
  case RTmp:
   emitf("callq *%L0", &i, e);
   break;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "invalid call argument");
  }
  break;
 case Osalloc:
  ((void)0);
  emitf("subq %L0, %%rsp", &i, e);
  if (!req(i.to, (Ref){RTmp, 0}))
   emitcopy(i.to, (Ref){RTmp, RSP}, Kl, e);
  break;
 case Oswap:
  if (((i.cls)>>1) == 0)
   goto Table;
  emitcopy((Ref){RTmp, XMM0+15}, i.arg[0], i.cls, e);
  emitcopy(i.arg[0], i.arg[1], i.cls, e);
  emitcopy(i.arg[1], (Ref){RTmp, XMM0+15}, i.cls, e);
  break;
 case Odbgloc:
  emitdbgloc(i.arg[0].val, i.arg[1].val, e->f);
  break;
 case_Oxsel:
  if (req(i.to, i.arg[1]))
   emitf(cmov[i.op-Oxsel][0], &i, e);
  else {
   if (!req(i.to, i.arg[0]))
    emitf("mov %0, %=", &i, e);
   emitf(cmov[i.op-Oxsel][1], &i, e);
  }
  break;
 }
}
static void
sysv_framesz(E *e)
{
 uint64_t i, o, f;
 o = 0;
 if (!e->fn->leaf) {
  for (i=0, o=0; i<NCLR_SYSV; i++)
   o ^= e->fn->reg >> amd64_sysv_rclob[i];
  o &= 1;
 }
 f = e->fn->slot;
 f = (f + 3) & -4;
 if (f > 0
 && e->fp == RSP
 && e->fn->salign == 4)
  f += 2;
 e->fsz = 4*f + 8*o + 176*e->fn->vararg;
}
void
amd64_sysv_emitfn(Fn *fn, FILE *f)
{
 static char *ctoa[][2] = {
  [Ciule] = {"be", "a"}, [Ciult] = {"b", "ae"}, [Cisle] = {"le", "g"}, [Cislt] = {"l", "ge"}, [Cisgt] = {"g", "le"}, [Cisge] = {"ge", "l"}, [Ciugt] = {"a", "be"}, [Ciuge] = {"ae", "b"}, [Cieq] = {"z", "nz"}, [Cine] = {"nz", "z"}, [NCmpI+Cfle] = {"?", "?"}, [NCmpI+Cflt] = {"?", "?"}, [NCmpI+Cfgt] = {"a", "be"}, [NCmpI+Cfge] = {"ae", "b"}, [NCmpI+Cfo] = {"np", "p"}, [NCmpI+Cfuo] = {"p", "np"},
 };
 static int id0;
 Blk *b, *s;
 Ins *i, itmp;
 int *r, c, o, n, lbl;
 uint p;
 E *e;
 e = &(E){.f = f, .fn = fn};
 emitfnlnk(fn->name, &fn->lnk, f);
 fputs("\tendbr64\n", f);
 if (!fn->leaf || fn->vararg || fn->dynalloc) {
  e->fp = RBP;
  fputs("\tpushq %rbp\n\tmovq %rsp, %rbp\n", f);
 } else
  e->fp = RSP;
 sysv_framesz(e);
 if (e->fsz)
  fprintf(f, "\tsubq $%""lu"", %%rsp\n", e->fsz);
 if (fn->vararg) {
  o = -176;
  for (r=amd64_sysv_rsave; r<&amd64_sysv_rsave[6]; r++, o+=8)
   fprintf(f, "\tmovq %%%s, %d(%%rbp)\n", rname[*r][0], o);
  for (n=0; n<8; ++n, o+=16)
   fprintf(f, "\tmovaps %%xmm%d, %d(%%rbp)\n", n, o);
 }
 for (r=amd64_sysv_rclob; r<&amd64_sysv_rclob[NCLR_SYSV]; r++)
  if (fn->reg & ((bits)1 << (*r))) {
   itmp.arg[0] = (Ref){RTmp, *r};
   emitf("pushq %L0", &itmp, e);
   e->nclob++;
  }
 for (lbl=0, b=fn->start; b; b=b->link) {
  if (lbl || b->npred > 1) {
   for (p=0; p<b->npred; p++)
    if (b->pred[p]->id >= b->id)
     break;
   if (p != b->npred)
    fprintf(f, ".p2align 4\n");
   fprintf(f, "%sbb%d:\n", T.asloc, id0+b->id);
  }
  for (i=b->ins; i!=&b->ins[b->nins]; i++)
   emitins(*i, e);
  lbl = 1;
  switch (b->jmp.type) {
  case Jhlt:
   fprintf(f, "\tud2\n");
   break;
  case Jret0:
   if (fn->dynalloc)
    fprintf(f,
     "\tmovq %%rbp, %%rsp\n"
     "\tsubq $%""lu"", %%rsp\n",
     e->fsz + e->nclob * 8);
   for (r=&amd64_sysv_rclob[NCLR_SYSV]; r>amd64_sysv_rclob;)
    if (fn->reg & ((bits)1 << (*--r))) {
     itmp.arg[0] = (Ref){RTmp, *r};
     emitf("popq %L0", &itmp, e);
    }
   if (e->fp == RBP)
    fputs("\tleave\n", f);
   else if (e->fsz)
    fprintf(f,
     "\taddq $%""lu"", %%rsp\n",
     e->fsz);
   fputs("\tret\n", f);
   break;
  case Jjmp:
  Jmp:
   if (b->s1 != b->link)
    fprintf(f, "\tjmp %sbb%d\n",
     T.asloc, id0+b->s1->id);
   else
    lbl = 0;
   break;
  default:
   c = b->jmp.type - Jjf;
   if (0 <= c && c <= NCmp) {
    if (b->link == b->s2) {
     s = b->s1;
     b->s1 = b->s2;
     b->s2 = s;
     n = 0;
    } else
     n = 1;
    fprintf(f, "\tj%s %sbb%d\n", ctoa[c][n],
     T.asloc, id0+b->s2->id);
    goto Jmp;
   }
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "unhandled jump %d", b->jmp.type);
  }
 }
 id0 += fn->nblk;
 if (!T.apple)
  elf_emitfnfin(fn->name, f);
}
static void
winabi_framesz(E *e)
{
 uint64_t i, o, f;
 o = 0;
 if (!e->fn->leaf) {
  for (i=0, o=0; i<NCLR_WIN; i++)
   o ^= e->fn->reg >> amd64_winabi_rclob[i];
  o &= 1;
 }
 f = e->fn->slot;
 f = (f + 3) & -4;
 if (f > 0
 && e->fp == RSP
 && e->fn->salign == 4)
  f += 2;
 e->fsz = 4*f + 8*o;
}
void
amd64_winabi_emitfn(Fn *fn, FILE *f)
{
 static char *ctoa[][2] = {
  [Ciule] = {"be", "a"}, [Ciult] = {"b", "ae"}, [Cisle] = {"le", "g"}, [Cislt] = {"l", "ge"}, [Cisgt] = {"g", "le"}, [Cisge] = {"ge", "l"}, [Ciugt] = {"a", "be"}, [Ciuge] = {"ae", "b"}, [Cieq] = {"z", "nz"}, [Cine] = {"nz", "z"}, [NCmpI+Cfle] = {"?", "?"}, [NCmpI+Cflt] = {"?", "?"}, [NCmpI+Cfgt] = {"a", "be"}, [NCmpI+Cfge] = {"ae", "b"}, [NCmpI+Cfo] = {"np", "p"}, [NCmpI+Cfuo] = {"p", "np"},
 };
 static int id0;
 Blk *b, *s;
 Ins *i, itmp;
 int *r, c, n, lbl;
 E *e;
 e = &(E){.f = f, .fn = fn};
 emitfnlnk(fn->name, &fn->lnk, f);
 fputs("\tendbr64\n", f);
 if (fn->vararg) {
  fprintf(f, "\tmovq %%rcx, 0x8(%%rsp)\n");
  fprintf(f, "\tmovq %%rdx, 0x10(%%rsp)\n");
  fprintf(f, "\tmovq %%r8, 0x18(%%rsp)\n");
  fprintf(f, "\tmovq %%r9, 0x20(%%rsp)\n");
 }
 if (!fn->leaf || fn->vararg || fn->dynalloc) {
  e->fp = RBP;
  fputs("\tpushq %rbp\n\tmovq %rsp, %rbp\n", f);
 } else
  e->fp = RSP;
 winabi_framesz(e);
 if (e->fsz)
  fprintf(f, "\tsubq $%""lu"", %%rsp\n", e->fsz);
 for (r=amd64_winabi_rclob; r<&amd64_winabi_rclob[NCLR_WIN]; r++)
  if (fn->reg & ((bits)1 << (*r))) {
   itmp.arg[0] = (Ref){RTmp, *r};
   emitf("pushq %L0", &itmp, e);
   e->nclob++;
  }
 for (lbl=0, b=fn->start; b; b=b->link) {
  if (lbl || b->npred > 1)
   fprintf(f, "%sbb%d:\n", T.asloc, id0+b->id);
  for (i=b->ins; i!=&b->ins[b->nins]; i++)
   emitins(*i, e);
  lbl = 1;
  switch (b->jmp.type) {
  case Jhlt:
   fprintf(f, "\tud2\n");
   break;
  case Jret0:
   if (fn->dynalloc)
    fprintf(f,
     "\tmovq %%rbp, %%rsp\n"
     "\tsubq $%""lu"", %%rsp\n",
     e->fsz + e->nclob * 8);
   for (r=&amd64_winabi_rclob[NCLR_WIN]; r>amd64_winabi_rclob;)
    if (fn->reg & ((bits)1 << (*--r))) {
     itmp.arg[0] = (Ref){RTmp, *r};
     emitf("popq %L0", &itmp, e);
    }
   if (e->fp == RBP)
    fputs("\tleave\n", f);
   else if (e->fsz)
    fprintf(f,
     "\taddq $%""lu"", %%rsp\n",
     e->fsz);
   fputs("\tret\n", f);
   break;
  case Jjmp:
  Jmp:
   if (b->s1 != b->link)
    fprintf(f, "\tjmp %sbb%d\n",
     T.asloc, id0+b->s1->id);
   else
    lbl = 0;
   break;
  default:
   c = b->jmp.type - Jjf;
   if (0 <= c && c <= NCmp) {
    if (b->link == b->s2 || c >= NCmpI) {
     s = b->s1;
     b->s1 = b->s2;
     b->s2 = s;
     n = 0;
    } else
     n = 1;
    fprintf(f, "\tj%s %sbb%d\n", ctoa[c][n],
     T.asloc, id0+b->s2->id);
    goto Jmp;
   }
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/emit.c", "unhandled jump %d", b->jmp.type);
  }
 }
 id0 += fn->nblk;
}
