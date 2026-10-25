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


typedef enum ArgPassStyle {
  APS_Invalid = 0,
  APS_Register,
  APS_InlineOnStack,
  APS_CopyAndPointerInRegister,
  APS_CopyAndPointerOnStack,
  APS_VarargsTag,
  APS_EnvTag,
} ArgPassStyle;
typedef struct ArgClass {
  Typ* type;
  ArgPassStyle style;
  int align;
  uint size;
  int cls;
  Ref ref;
} ArgClass;
typedef struct ExtraAlloc ExtraAlloc;
struct ExtraAlloc {
  Ins instr;
  ExtraAlloc* link;
};
int amd64_winabi_rsave[] = {RCX, RDX, R8, R9, R10, R11, RAX, XMM0,
                            XMM1, XMM2, XMM3, XMM4, XMM5, XMM6, XMM7, XMM8,
                            XMM9, XMM10, XMM11, XMM12, XMM13, XMM14, -1};
int amd64_winabi_rclob[] = {RBX, R12, R13, R14, R15, RSI, RDI, -1};
typedef char make_sure_winabi_arrays_ok[(sizeof amd64_winabi_rsave == (NGPS_WIN + NFPS + 1) * sizeof(int) && sizeof amd64_winabi_rclob == (NCLR_WIN + 1) * sizeof(int))?1:-1];
bits amd64_winabi_retregs(Ref r, int p[2]) {
  ((void)0);
  bits b = 0;
  int num_int_returns = r.val & 1;
  int num_float_returns = r.val & 2;
  if (num_int_returns == 1) {
    b |= ((bits)1 << (RAX));
  } else {
    b |= ((bits)1 << (XMM0));
  }
  if (p) {
    p[0] = num_int_returns;
    p[1] = num_float_returns;
  }
  return b;
}
static uint popcnt(bits b) {
  b = (b & 0x5555555555555555) + ((b >> 1) & 0x5555555555555555);
  b = (b & 0x3333333333333333) + ((b >> 2) & 0x3333333333333333);
  b = (b & 0x0f0f0f0f0f0f0f0f) + ((b >> 4) & 0x0f0f0f0f0f0f0f0f);
  b += (b >> 8);
  b += (b >> 16);
  b += (b >> 32);
  return b & 0xff;
}
bits amd64_winabi_argregs(Ref r, int p[2]) {
  ((void)0);
  int int_passed = (r.val >> 4) & 15;
  int float_passed = (r.val >> 8) & 15;
  _Bool env_param = (r.val >> 12) & 1;
  bits b = 0;
  b |= (int_passed & 1) ? ((bits)1 << (RCX)) : 0;
  b |= (int_passed & 2) ? ((bits)1 << (RDX)) : 0;
  b |= (int_passed & 4) ? ((bits)1 << (R8)) : 0;
  b |= (int_passed & 8) ? ((bits)1 << (R9)) : 0;
  b |= (float_passed & 1) ? ((bits)1 << (XMM0)) : 0;
  b |= (float_passed & 2) ? ((bits)1 << (XMM1)) : 0;
  b |= (float_passed & 4) ? ((bits)1 << (XMM2)) : 0;
  b |= (float_passed & 8) ? ((bits)1 << (XMM3)) : 0;
  b |= env_param ? ((bits)1 << (RAX)) : 0;
  if (p) {
    p[0] = popcnt(int_passed);
    p[1] = popcnt(float_passed);
  }
  return b;
}
typedef struct RegisterUsage {
  int num_regs_passed;
  _Bool regs_passed[2][4];
  _Bool rax_returned;
  _Bool xmm0_returned;
  int num_named_args_passed;
  _Bool is_varargs_call;
  _Bool has_env;
} RegisterUsage;
static int register_usage_to_call_arg_value(RegisterUsage reg_usage) {
  return (reg_usage.rax_returned << 0) |
         (reg_usage.xmm0_returned << 1) |
         (reg_usage.regs_passed[0][0] << 4) |
         (reg_usage.regs_passed[0][1] << 5) |
         (reg_usage.regs_passed[0][2] << 6) |
         (reg_usage.regs_passed[0][3] << 7) |
         (reg_usage.regs_passed[1][0] << 8) |
         (reg_usage.regs_passed[1][1] << 9) |
         (reg_usage.regs_passed[1][2] << 10) |
         (reg_usage.regs_passed[1][3] << 11) |
         (reg_usage.has_env << 12);
}
static void assign_register_or_stack(RegisterUsage* reg_usage,
                                     ArgClass* arg,
                                     _Bool is_float,
                                     _Bool by_copy) {
  if (reg_usage->num_regs_passed == 4) {
    arg->style = by_copy ? APS_CopyAndPointerOnStack : APS_InlineOnStack;
  } else {
    reg_usage->regs_passed[is_float][reg_usage->num_regs_passed] = 1;
    ++reg_usage->num_regs_passed;
    arg->style = by_copy ? APS_CopyAndPointerInRegister : APS_Register;
  }
  ++reg_usage->num_named_args_passed;
}
static _Bool type_is_by_copy(Typ* type) {
  return type->isdark || (type->size != 1 && type->size != 2 &&
                          type->size != 4 && type->size != 8);
}
static void classify_arguments(RegisterUsage* reg_usage,
                               Ins* begin_instr,
                               Ins* end_instr,
                               ArgClass* arg_classes,
                               Ref* env) {
  ArgClass* arg = arg_classes;
  for (Ins* instr = begin_instr; instr < end_instr; ++instr, ++arg) {
    switch (instr->op) {
      case Oarg:
      case Opar:
        assign_register_or_stack(reg_usage, arg, ((instr->cls)>>1),
                                             0);
        arg->cls = instr->cls;
        arg->align = 3;
        arg->size = 8;
        break;
      case Oargc:
      case Oparc: {
        int typ_index = instr->arg[0].val;
        Typ* type = &typ[typ_index];
        _Bool by_copy = type_is_by_copy(type);
        assign_register_or_stack(reg_usage, arg, 0, by_copy);
        arg->cls = Kl;
        if (!by_copy && type->size <= 4) {
          arg->cls = Kw;
        }
        arg->align = 3;
        arg->size = type->size;
        break;
      }
      case Oarge:
        *env = instr->arg[0];
        arg->style = APS_EnvTag;
        reg_usage->has_env = 1;
        break;
      case Opare:
        *env = instr->to;
        arg->style = APS_EnvTag;
        reg_usage->has_env = 1;
        break;
      case Oargv:
        reg_usage->is_varargs_call = 1;
        arg->style = APS_VarargsTag;
        break;
    }
  }
  if (reg_usage->has_env && reg_usage->is_varargs_call) {
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/winabi.c", "can't use env with varargs");
  }
  if (reg_usage->is_varargs_call) {
    for (int i = 0; i < 4; ++i) {
      if (reg_usage->regs_passed[ 1][i]) {
        reg_usage->regs_passed[ 0][i] = 1;
      }
    }
  }
}
static _Bool is_integer_type(int ty) {
  ((void)0);
  return ((ty)>>1) == 0;
}
static Ref register_for_arg(int cls, int counter) {
  ((void)0);
  if (is_integer_type(cls)) {
    return (Ref){RTmp, amd64_winabi_rsave[counter]};
  } else {
    return (Ref){RTmp, XMM0 + counter};
  }
}
static Ins* lower_call(Fn* func,
                       Blk* block,
                       Ins* call_instr,
                       ExtraAlloc** pextra_alloc) {
  Ins* instr_past_args = call_instr - 1;
  for (; instr_past_args >= block->ins; --instr_past_args) {
    if (!((unsigned)(instr_past_args->op) - Oarg <= Oargv - Oarg)) {
      break;
    }
  }
  Ins* earliest_arg_instr = instr_past_args + 1;
  uint num_args = call_instr - earliest_arg_instr;
  ArgClass* arg_classes = alloc(num_args * sizeof(ArgClass));
  RegisterUsage reg_usage = {0};
  ArgClass ret_arg_class = {0};
  _Bool il_has_struct_return = !req(call_instr->arg[1], (Ref){RTmp, 0});
  _Bool is_struct_return = 0;
  if (il_has_struct_return) {
    Typ* ret_type = &typ[call_instr->arg[1].val];
    is_struct_return = type_is_by_copy(ret_type);
    if (is_struct_return) {
      assign_register_or_stack(&reg_usage, &ret_arg_class, 0,
                                           1);
    }
    ret_arg_class.size = ret_type->size;
  }
  Ref env = (Ref){RTmp, 0};
  classify_arguments(&reg_usage, earliest_arg_instr, call_instr, arg_classes,
                     &env);
  uint stack_usage = 0;
  for (uint i = 0; i < num_args; ++i) {
    ArgClass* arg = &arg_classes[i];
    if (arg->style == APS_InlineOnStack) {
      if (arg->align > 4) {
        err("win abi cannot pass alignments > 16");
      }
      stack_usage += arg->size;
    } else if (arg->style == APS_CopyAndPointerOnStack) {
      stack_usage += 8;
    }
  }
  stack_usage = (((stack_usage) + (16)-1) & ~(((16))-1));
  Ref stack_size_ref =
      getcon(-(int64_t)(stack_usage + 32), func);
  emit(Osalloc, Kl, (Ref){RTmp, 0}, stack_size_ref, (Ref){RTmp, 0});
  ExtraAlloc* return_pad = ((void *)0);
  if (is_struct_return) {
    return_pad = alloc(sizeof(ExtraAlloc));
    Ref ret_pad_ref = newtmp("abi.ret_pad", Kl, func);
    return_pad->instr =
        (Ins){Oalloc8, Kl, ret_pad_ref, {getcon(ret_arg_class.size, func)}};
    return_pad->link = (*pextra_alloc);
    *pextra_alloc = return_pad;
    reg_usage.rax_returned = 1;
    emit(Ocopy, call_instr->cls, call_instr->to, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
  } else {
    if (il_has_struct_return) {
      ExtraAlloc* return_copy = alloc(sizeof(ExtraAlloc));
      return_copy->instr =
          (Ins){Oalloc8, Kl, call_instr->to, {getcon(8, func)}};
      return_copy->link = (*pextra_alloc);
      *pextra_alloc = return_copy;
      Ref copy = newtmp("abi.copy", Kl, func);
      emit(Ostorel, 0, (Ref){RTmp, 0}, copy, call_instr->to);
      emit(Ocopy, Kl, copy, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
      reg_usage.rax_returned = 1;
    } else if (is_integer_type(call_instr->cls)) {
      emit(Ocopy, call_instr->cls, call_instr->to, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
      reg_usage.rax_returned = 1;
    } else {
      emit(Ocopy, call_instr->cls, call_instr->to, (Ref){RTmp, XMM0}, (Ref){RTmp, 0});
      reg_usage.xmm0_returned = 1;
    }
  }
  emit(Ocall, call_instr->cls, (Ref){RTmp, 0}, call_instr->arg[0],
       (Ref){RCall, register_usage_to_call_arg_value(reg_usage)});
  if (!req((Ref){RTmp, 0}, env)) {
    emit(Ocopy, Kl, (Ref){RTmp, RAX}, env, (Ref){RTmp, 0});
  }
  if (reg_usage.is_varargs_call) {
    if (reg_usage.regs_passed[ 1][0]) { emit(Ocast, Kl, (Ref){RTmp, RCX}, (Ref){RTmp, XMM0}, (Ref){RTmp, 0}); };
    if (reg_usage.regs_passed[ 1][1]) { emit(Ocast, Kl, (Ref){RTmp, RDX}, (Ref){RTmp, XMM1}, (Ref){RTmp, 0}); };
    if (reg_usage.regs_passed[ 1][2]) { emit(Ocast, Kl, (Ref){RTmp, R8}, (Ref){RTmp, XMM2}, (Ref){RTmp, 0}); };
    if (reg_usage.regs_passed[ 1][3]) { emit(Ocast, Kl, (Ref){RTmp, R9}, (Ref){RTmp, XMM3}, (Ref){RTmp, 0}); };
  }
  int reg_counter = 0;
  if (is_struct_return) {
    Ref first_reg = register_for_arg(Kl, reg_counter++);
    emit(Ocopy, Kl, first_reg, return_pad->instr.to, (Ref){RTmp, 0});
  }
  Ref arg_stack_slots = newtmp("abi.args", Kl, func);
  uint slot_offset = 32;
  ArgClass* arg = arg_classes;
  for (Ins* instr = earliest_arg_instr; instr != call_instr; ++instr, ++arg) {
    switch (arg->style) {
      case APS_Register: {
        Ref into = register_for_arg(arg->cls, reg_counter++);
        if (instr->op == Oargc) {
          emit(Oload, arg->cls, into, instr->arg[1], (Ref){RTmp, 0});
        } else {
          emit(Ocopy, instr->cls, into, instr->arg[0], (Ref){RTmp, 0});
        }
        break;
      }
      case APS_InlineOnStack: {
        Ref slot = newtmp("abi.off", Kl, func);
        if (instr->op == Oargc) {
          Ref smalltmp = newtmp("abi.smalltmp", arg->cls, func);
          emit(Ostorel, 0, (Ref){RTmp, 0}, smalltmp, slot);
          emit(Oload, arg->cls, smalltmp, instr->arg[1], (Ref){RTmp, 0});
        } else {
          emit(Ostorel, 0, (Ref){RTmp, 0}, instr->arg[0], slot);
        }
        emit(Oadd, Kl, slot, arg_stack_slots, getcon(slot_offset, func));
        slot_offset += arg->size;
        break;
      }
      case APS_CopyAndPointerInRegister:
      case APS_CopyAndPointerOnStack: {
        ExtraAlloc* arg_copy = alloc(sizeof(ExtraAlloc));
        Ref copy_ref = newtmp("abi.copy", Kl, func);
        arg_copy->instr =
            (Ins){Oalloc8, Kl, copy_ref, {getcon(arg->size, func)}};
        arg_copy->link = (*pextra_alloc);
        *pextra_alloc = arg_copy;
        emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (arg->size)&0x1fffffff}, (Ref){RTmp, 0});
        emit(Oblit0, 0, (Ref){RTmp, 0}, instr->arg[1], copy_ref);
        if (arg->style == APS_CopyAndPointerInRegister) {
          Ref into = register_for_arg(arg->cls, reg_counter++);
          emit(Ocopy, Kl, into, copy_ref, (Ref){RTmp, 0});
        } else {
          ((void)0);
          Ref slot = newtmp("abi.off", Kl, func);
          emit(Ostorel, 0, (Ref){RTmp, 0}, copy_ref, slot);
          emit(Oadd, Kl, slot, arg_stack_slots, getcon(slot_offset, func));
          slot_offset += 8;
        }
        break;
      }
      case APS_EnvTag:
      case APS_VarargsTag:
        break;
      case APS_Invalid:
        die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/winabi.c", "unreachable");
    }
  }
  if (stack_usage) {
    emit(Osalloc, Kl, arg_stack_slots,
         getcon(stack_usage + 32, func), (Ref){RTmp, 0});
  } else {
    emit(Osalloc, Kl, (Ref){RTmp, 0}, getcon(32, func), (Ref){RTmp, 0});
  }
  return instr_past_args;
}
static void lower_block_return(Fn* func, Blk* block) {
  int jmp_type = block->jmp.type;
  if (!((unsigned)(jmp_type) - Jretw <= Jret0 - Jretw) || jmp_type == Jret0) {
    return;
  }
  Ref ret_arg = block->jmp.arg;
  block->jmp.type = Jret0;
  RegisterUsage reg_usage = {0};
  if (jmp_type == Jretc) {
    Typ* type = &typ[func->retty];
    if (type_is_by_copy(type)) {
      ((void)0);
      emit(Ocopy, Kl, (Ref){RTmp, RAX}, func->retr, (Ref){RTmp, 0});
      emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (type->size)&0x1fffffff}, (Ref){RTmp, 0});
      emit(Oblit0, 0, (Ref){RTmp, 0}, ret_arg, func->retr);
    } else {
      emit(Oload, Kl, (Ref){RTmp, RAX}, ret_arg, (Ref){RTmp, 0});
    }
    reg_usage.rax_returned = 1;
  } else {
    int k = jmp_type - Jretw;
    if (is_integer_type(k)) {
      emit(Ocopy, k, (Ref){RTmp, RAX}, ret_arg, (Ref){RTmp, 0});
      reg_usage.rax_returned = 1;
    } else {
      emit(Ocopy, k, (Ref){RTmp, XMM0}, ret_arg, (Ref){RTmp, 0});
      reg_usage.xmm0_returned = 1;
    }
  }
  block->jmp.arg = (Ref){RCall, register_usage_to_call_arg_value(reg_usage)};
}
static void lower_vastart(Fn* func,
                          RegisterUsage* param_reg_usage,
                          Ref valist) {
  ((void)0);
  Ref offset = newtmp("abi.vastart", Kl, func);
  emit(Ostorel, 0, (Ref){RTmp, 0}, offset, valist);
  emit(Oadd, Kl, offset, (Ref){RTmp, RBP},
       getcon(param_reg_usage->num_named_args_passed * 8 + 16, func));
}
static void lower_vaarg(Fn* func, Ins* vaarg_instr) {
  Ref inc = newtmp("abi.vaarg.inc", Kl, func);
  Ref ptr = newtmp("abi.vaarg.ptr", Kl, func);
  emit(Ostorel, 0, (Ref){RTmp, 0}, inc, vaarg_instr->arg[0]);
  emit(Oadd, Kl, inc, ptr, getcon(8, func));
  emit(Oload, vaarg_instr->cls, vaarg_instr->to, ptr, (Ref){RTmp, 0});
  emit(Oload, Kl, ptr, vaarg_instr->arg[0], (Ref){RTmp, 0});
}
static void lower_args_for_block(Fn* func,
                                 Blk* block,
                                 RegisterUsage* param_reg_usage,
                                 ExtraAlloc** pextra_alloc) {
  curi = &insb[NIns];
  lower_block_return(func, block);
  if (block->nins) {
    for (Ins* instr = &block->ins[block->nins - 1]; instr >= block->ins;) {
      switch (instr->op) {
        case Ocall:
          instr = lower_call(func, block, instr, pextra_alloc);
          break;
        case Ovastart:
          lower_vastart(func, param_reg_usage, instr->arg[0]);
          --instr;
          break;
        case Ovaarg:
          lower_vaarg(func, instr);
          --instr;
          break;
        case Oarg:
        case Oargc:
          die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/winabi.c", "unreachable");
        default:
          emiti(*instr);
          --instr;
          break;
      }
    }
  }
  _Bool is_start_block = block == func->start;
  if (is_start_block) {
    for (ExtraAlloc* ea = *pextra_alloc; ea; ea = ea->link) {
      emiti(ea->instr);
    }
  }
  block->nins = &insb[NIns] - curi;
  idup(block, curi, block->nins);
}
static Ins* find_end_of_func_parameters(Blk* start_block) {
  Ins* i;
  for (i = start_block->ins; i < &start_block->ins[start_block->nins]; ++i) {
    if (!((unsigned)(i->op) - Opar <= Opare - Opar)) {
      break;
    }
  }
  return i;
}
static RegisterUsage lower_func_parameters(Fn* func) {
  Blk* start_block = func->start;
  Ins* start_of_params = start_block->ins;
  Ins* end_of_params = find_end_of_func_parameters(start_block);
  size_t num_params = end_of_params - start_of_params;
  ArgClass* arg_classes = alloc(num_params * sizeof(ArgClass));
  ArgClass arg_ret = {0};
  curi = &insb[NIns];
  int reg_counter = 0;
  RegisterUsage reg_usage = {0};
  if (func->retty >= 0) {
    _Bool by_copy = type_is_by_copy(&typ[func->retty]);
    if (by_copy) {
      assign_register_or_stack(&reg_usage, &arg_ret, 0,
                               by_copy);
      Ref ret_ref = newtmp("abi.ret", Kl, func);
      emit(Ocopy, Kl, ret_ref, (Ref){RTmp, RCX}, (Ref){RTmp, 0});
      func->retr = ret_ref;
      ++reg_counter;
    }
  }
  Ref env = (Ref){RTmp, 0};
  classify_arguments(&reg_usage, start_of_params, end_of_params, arg_classes,
                     &env);
  func->reg = amd64_winabi_argregs(
      (Ref){RCall, register_usage_to_call_arg_value(reg_usage)}, ((void *)0));
  ArgClass* arg = arg_classes;
  uint slot_offset = 32 / 4 + 4;
  for (Ins* instr = start_of_params; instr < end_of_params; ++instr, ++arg) {
    switch (arg->style) {
      case APS_Register: {
        Ref from = register_for_arg(arg->cls, reg_counter++);
        if (instr->op == Oparc) {
          arg->ref = newtmp("abi", Kl, func);
          emit(Ostorel, 0, (Ref){RTmp, 0}, arg->ref, instr->to);
          emit(Ocopy, instr->cls, arg->ref, from, (Ref){RTmp, 0});
          emit(Oalloc8, Kl, instr->to, getcon(arg->size, func), (Ref){RTmp, 0});
        } else {
          emit(Ocopy, instr->cls, instr->to, from, (Ref){RTmp, 0});
        }
        break;
      }
      case APS_InlineOnStack:
        if (instr->op == Oparc) {
          arg->ref = newtmp("abi", Kl, func);
          emit(Ostorel, 0, (Ref){RTmp, 0}, arg->ref, instr->to);
          emit(Ocopy, instr->cls, arg->ref, (Ref){RSlot, (-slot_offset)&0x1fffffff}, (Ref){RTmp, 0});
          emit(Oalloc8, Kl, instr->to, getcon(arg->size, func), (Ref){RTmp, 0});
        } else {
          emit(Ocopy, Kl, instr->to, (Ref){RSlot, (-slot_offset)&0x1fffffff}, (Ref){RTmp, 0});
        }
        slot_offset += 2;
        break;
      case APS_CopyAndPointerOnStack:
        emit(Oload, Kl, instr->to, (Ref){RSlot, (-slot_offset)&0x1fffffff}, (Ref){RTmp, 0});
        slot_offset += 2;
        break;
      case APS_CopyAndPointerInRegister: {
        Ref from = register_for_arg(Kl, reg_counter++);
        emit(Ocopy, Kl, instr->to, from, (Ref){RTmp, 0});
        break;
      }
      case APS_EnvTag:
        break;
      case APS_VarargsTag:
      case APS_Invalid:
        die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/winabi.c", "unreachable");
    }
  }
  if (!req((Ref){RTmp, 0}, env)) {
    emit(Ocopy, Kl, env, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
  }
  int num_created_instrs = &insb[NIns] - curi;
  int num_other_after_instrs = (int)(start_block->nins - num_params);
  int new_total_instrs = num_other_after_instrs + num_created_instrs;
  Ins* new_instrs = vnew(new_total_instrs, sizeof(Ins), PFn);
  Ins* instr_p = icpy(new_instrs, curi, num_created_instrs);
  icpy(instr_p, end_of_params, num_other_after_instrs);
  start_block->nins = new_total_instrs;
  start_block->ins = new_instrs;
  return reg_usage;
}
void amd64_winabi_abi(Fn* func) {
  RegisterUsage param_reg_usage = lower_func_parameters(func);
  ExtraAlloc* extra_alloc = ((void *)0);
  for (Blk* block = func->start->link; block; block = block->link) {
    lower_args_for_block(func, block, &param_reg_usage, &extra_alloc);
  }
  lower_args_for_block(func, func->start, &param_reg_usage, &extra_alloc);
  if (debug['A']) {
    fprintf(__stderrp, "\n> After ABI lowering:\n");
    printfn(func, __stderrp);
  }
}
