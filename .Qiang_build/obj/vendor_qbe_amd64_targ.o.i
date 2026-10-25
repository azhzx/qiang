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

Amd64Op amd64_op[NOp] = {
[Oadd] = { 2, 1, 0, },
[Osub] = { 2, 1, 0, },
[Oneg] = { 1, 1, 0, },
[Odiv] = { 0, 0, 0, },
[Orem] = { 0, 0, 0, },
[Oudiv] = { 0, 0, 0, },
[Ourem] = { 0, 0, 0, },
[Omul] = { 2, 0, 0, },
[Oand] = { 2, 1, 0, },
[Oor] = { 2, 1, 0, },
[Oxor] = { 2, 1, 0, },
[Osar] = { 1, 1, 0, },
[Oshr] = { 1, 1, 0, },
[Oshl] = { 1, 1, 0, },
[Oceqw] = { 0, 1, 0, },
[Ocnew] = { 0, 1, 0, },
[Ocsgew] = { 0, 1, 0, },
[Ocsgtw] = { 0, 1, 0, },
[Ocslew] = { 0, 1, 0, },
[Ocsltw] = { 0, 1, 0, },
[Ocugew] = { 0, 1, 0, },
[Ocugtw] = { 0, 1, 0, },
[Oculew] = { 0, 1, 0, },
[Ocultw] = { 0, 1, 0, },
[Oceql] = { 0, 1, 0, },
[Ocnel] = { 0, 1, 0, },
[Ocsgel] = { 0, 1, 0, },
[Ocsgtl] = { 0, 1, 0, },
[Ocslel] = { 0, 1, 0, },
[Ocsltl] = { 0, 1, 0, },
[Ocugel] = { 0, 1, 0, },
[Ocugtl] = { 0, 1, 0, },
[Oculel] = { 0, 1, 0, },
[Ocultl] = { 0, 1, 0, },
[Oceqs] = { 0, 1, 0, },
[Ocges] = { 0, 1, 0, },
[Ocgts] = { 0, 1, 0, },
[Ocles] = { 0, 1, 0, },
[Oclts] = { 0, 1, 0, },
[Ocnes] = { 0, 1, 0, },
[Ocos] = { 0, 1, 0, },
[Ocuos] = { 0, 1, 0, },
[Oceqd] = { 0, 1, 0, },
[Ocged] = { 0, 1, 0, },
[Ocgtd] = { 0, 1, 0, },
[Ocled] = { 0, 1, 0, },
[Ocltd] = { 0, 1, 0, },
[Ocned] = { 0, 1, 0, },
[Ocod] = { 0, 1, 0, },
[Ocuod] = { 0, 1, 0, },
[Ostoreb] = { 0, 0, 1, },
[Ostoreh] = { 0, 0, 1, },
[Ostorew] = { 0, 0, 1, },
[Ostorel] = { 0, 0, 1, },
[Ostores] = { 0, 0, 1, },
[Ostored] = { 0, 0, 1, },
[Oloadsb] = { 0, 0, 1, },
[Oloadub] = { 0, 0, 1, },
[Oloadsh] = { 0, 0, 1, },
[Oloaduh] = { 0, 0, 1, },
[Oloadsw] = { 0, 0, 1, },
[Oloaduw] = { 0, 0, 1, },
[Oload] = { 0, 0, 1, },
[Oextsb] = { 0, 0, 1, },
[Oextub] = { 0, 0, 1, },
[Oextsh] = { 0, 0, 1, },
[Oextuh] = { 0, 0, 1, },
[Oextsw] = { 0, 0, 1, },
[Oextuw] = { 0, 0, 1, },
[Oexts] = { 0, 0, 1, },
[Otruncd] = { 0, 0, 1, },
[Ostosi] = { 0, 0, 1, },
[Ostoui] = { 0, 0, 1, },
[Odtosi] = { 0, 0, 1, },
[Odtoui] = { 0, 0, 1, },
[Oswtof] = { 0, 0, 1, },
[Ouwtof] = { 0, 0, 1, },
[Osltof] = { 0, 0, 1, },
[Oultof] = { 0, 0, 1, },
[Ocast] = { 0, 0, 1, },
[Oalloc4] = { 0, 0, 0, },
[Oalloc8] = { 0, 0, 0, },
[Oalloc16] = { 0, 0, 0, },
[Ovaarg] = { 0, 0, 0, },
[Ovastart] = { 0, 0, 0, },
[Ocopy] = { 0, 0, 1, },
[Odbgloc] = { 0, 0, 1, },
[Onop] = { 0, 0, 1, },
[Oaddr] = { 0, 0, 1, },
[Oblit0] = { 0, 1, 0, },
[Oblit1] = { 0, 1, 0, },
[Osel0] = { 0, 0, 0, },
[Osel1] = { 0, 0, 0, },
[Oswap] = { 1, 0, 0, },
[Osign] = { 0, 0, 0, },
[Osalloc] = { 0, 0, 0, },
[Oxidiv] = { 1, 0, 0, },
[Oxdiv] = { 1, 0, 0, },
[Oxcmp] = { 1, 1, 0, },
[Oxtest] = { 1, 1, 0, },
[Oacmp] = { 0, 0, 0, },
[Oacmn] = { 0, 0, 0, },
[Oafcmp] = { 0, 0, 0, },
[Oreqz] = { 0, 0, 0, },
[Ornez] = { 0, 0, 0, },
[Opar] = { 0, 0, 0, },
[Oparsb] = { 0, 0, 0, },
[Oparub] = { 0, 0, 0, },
[Oparsh] = { 0, 0, 0, },
[Oparuh] = { 0, 0, 0, },
[Oparc] = { 0, 0, 0, },
[Opare] = { 0, 0, 0, },
[Oarg] = { 0, 0, 0, },
[Oargsb] = { 0, 0, 0, },
[Oargub] = { 0, 0, 0, },
[Oargsh] = { 0, 0, 0, },
[Oarguh] = { 0, 0, 0, },
[Oargc] = { 0, 0, 0, },
[Oarge] = { 0, 0, 0, },
[Oargv] = { 0, 0, 0, },
[Ocall] = { 0, 0, 0, },
[Oflagieq] = { 0, 0, 1, },
[Oflagine] = { 0, 0, 1, },
[Oflagisge] = { 0, 0, 1, },
[Oflagisgt] = { 0, 0, 1, },
[Oflagisle] = { 0, 0, 1, },
[Oflagislt] = { 0, 0, 1, },
[Oflagiuge] = { 0, 0, 1, },
[Oflagiugt] = { 0, 0, 1, },
[Oflagiule] = { 0, 0, 1, },
[Oflagiult] = { 0, 0, 1, },
[Oflagfeq] = { 0, 0, 1, },
[Oflagfge] = { 0, 0, 1, },
[Oflagfgt] = { 0, 0, 1, },
[Oflagfle] = { 0, 0, 1, },
[Oflagflt] = { 0, 0, 1, },
[Oflagfne] = { 0, 0, 1, },
[Oflagfo] = { 0, 0, 1, },
[Oflagfuo] = { 0, 0, 1, },
[Oxselieq] = { 0, 0, 0, },
[Oxseline] = { 0, 0, 0, },
[Oxselisge] = { 0, 0, 0, },
[Oxselisgt] = { 0, 0, 0, },
[Oxselisle] = { 0, 0, 0, },
[Oxselislt] = { 0, 0, 0, },
[Oxseliuge] = { 0, 0, 0, },
[Oxseliugt] = { 0, 0, 0, },
[Oxseliule] = { 0, 0, 0, },
[Oxseliult] = { 0, 0, 0, },
[Oxselfeq] = { 0, 0, 0, },
[Oxselfge] = { 0, 0, 0, },
[Oxselfgt] = { 0, 0, 0, },
[Oxselfle] = { 0, 0, 0, },
[Oxselflt] = { 0, 0, 0, },
[Oxselfne] = { 0, 0, 0, },
[Oxselfo] = { 0, 0, 0, },
[Oxselfuo] = { 0, 0, 0, },
};
static int
amd64_memargs(int op)
{
 return amd64_op[op].nmem;
}
Target T_amd64_sysv = {
 .name = "amd64_sysv",
 .emitfin = elf_emitfin,
 .asloc = ".L",
 .abi1 = amd64_sysv_abi,
 .rsave = amd64_sysv_rsave,
 .nrsave = {NGPS_SYSV, NFPS},
 .retregs = amd64_sysv_retregs,
 .argregs = amd64_sysv_argregs,
 .emitfn = amd64_sysv_emitfn,
 .gpr0 = RAX, .ngpr = NGPR, .fpr0 = XMM0, .nfpr = NFPR, .rglob = ((bits)1 << (RBP)) | ((bits)1 << (RSP)), .nrglob = 2, .memargs = amd64_memargs, .abi0 = elimsb, .isel = amd64_isel, .cansel = 1,
};
Target T_amd64_apple = {
 .name = "amd64_apple",
 .apple = 1,
 .emitfin = macho_emitfin,
 .asloc = "L",
 .assym = "_",
 .abi1 = amd64_sysv_abi,
 .rsave = amd64_sysv_rsave,
 .nrsave = {NGPS_SYSV, NFPS},
 .retregs = amd64_sysv_retregs,
 .argregs = amd64_sysv_argregs,
 .emitfn = amd64_sysv_emitfn,
 .gpr0 = RAX, .ngpr = NGPR, .fpr0 = XMM0, .nfpr = NFPR, .rglob = ((bits)1 << (RBP)) | ((bits)1 << (RSP)), .nrglob = 2, .memargs = amd64_memargs, .abi0 = elimsb, .isel = amd64_isel, .cansel = 1,
};
Target T_amd64_win = {
 .name = "amd64_win",
 .windows = 1,
 .emitfin = pe_emitfin,
 .asloc = "L",
 .abi1 = amd64_winabi_abi,
 .rsave = amd64_winabi_rsave,
 .nrsave = {NGPS_WIN, NFPS},
 .retregs = amd64_winabi_retregs,
 .argregs = amd64_winabi_argregs,
 .emitfn = amd64_winabi_emitfn,
 .gpr0 = RAX, .ngpr = NGPR, .fpr0 = XMM0, .nfpr = NFPR, .rglob = ((bits)1 << (RBP)) | ((bits)1 << (RSP)), .nrglob = 2, .memargs = amd64_memargs, .abi0 = elimsb, .isel = amd64_isel, .cansel = 1,
};
