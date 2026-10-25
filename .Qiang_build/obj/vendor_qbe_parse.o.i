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
int isdigit(int);
int isalpha(int);
int isalnum(int);
int isspace(int);
int isprint(int);
int isupper(int);
int islower(int);
int ispunct(int);
int isxdigit(int);
int tolower(int);
int toupper(int);
int iscntrl(int);
int isgraph(int);
int isblank(int);
int isascii(int);
int toascii(int);
typedef __builtin_va_list va_list;

enum {
 Ksb = 4,
 Kub,
 Ksh,
 Kuh,
 Kc,
 K0,
 Ke = -2,
 Km = Kl,
};
Op optab[NOp] = {
[Oadd]={.name = "add", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 1, .assoc = 1, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Osub]={.name = "sub", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oneg]={.name = "neg", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Odiv]={.name = "div", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 1, .hasid = 1, .idval = 1, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Orem]={.name = "rem", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oudiv]={.name = "udiv", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 1, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ourem]={.name = "urem", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Omul]={.name = "mul", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 1, .hasid = 1, .idval = 1, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oand]={.name = "and", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 1, .idemp = 1, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oor]={.name = "or", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 1, .assoc = 1, .idemp = 1, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxor]={.name = "xor", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 1, .assoc = 1, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Osar]={.name = "sar", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oshr]={.name = "shr", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oshl]={.name = "shl", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oceqw]={.name = "ceqw", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 1, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 1, .cmplgtewl = 0, .eqval = 1, .pinned = 0},
[Ocnew]={.name = "cnew", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 1, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 1, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocsgew]={.name = "csgew", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocsgtw]={.name = "csgtw", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Ocslew]={.name = "cslew", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocsltw]={.name = "csltw", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Ocugew]={.name = "cugew", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocugtw]={.name = "cugtw", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Oculew]={.name = "culew", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocultw]={.name = "cultw", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Oceql]={.name = "ceql", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 1, .cmplgtewl = 0, .eqval = 1, .pinned = 0},
[Ocnel]={.name = "cnel", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 1, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocsgel]={.name = "csgel", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocsgtl]={.name = "csgtl", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Ocslel]={.name = "cslel", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocsltl]={.name = "csltl", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Ocugel]={.name = "cugel", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocugtl]={.name = "cugtl", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Oculel]={.name = "culel", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 1, .pinned = 0},
[Ocultl]={.name = "cultl", .argcls = { {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kl, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 1, .eqval = 0, .pinned = 0},
[Oceqs]={.name = "ceqs", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocges]={.name = "cges", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocgts]={.name = "cgts", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocles]={.name = "cles", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oclts]={.name = "clts", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocnes]={.name = "cnes", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocos]={.name = "cos", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocuos]={.name = "cuos", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oceqd]={.name = "ceqd", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocged]={.name = "cged", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocgtd]={.name = "cgtd", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocled]={.name = "cled", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocltd]={.name = "cltd", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocned]={.name = "cned", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocod]={.name = "cod", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocuod]={.name = "cuod", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 1, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ostoreb]={.name = "storeb", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ostoreh]={.name = "storeh", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ostorew]={.name = "storew", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ostorel]={.name = "storel", .argcls = { {[Kw]=Kl, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ostores]={.name = "stores", .argcls = { {[Kw]=Ks, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ostored]={.name = "stored", .argcls = { {[Kw]=Kd, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloadsb]={.name = "loadsb", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloadub]={.name = "loadub", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloadsh]={.name = "loadsh", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloaduh]={.name = "loaduh", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloadsw]={.name = "loadsw", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oloaduw]={.name = "loaduw", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oload]={.name = "load", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Km, [Kd]=Km}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oextsb]={.name = "extsb", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oextub]={.name = "extub", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oextsh]={.name = "extsh", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oextuh]={.name = "extuh", .argcls = { {[Kw]=Kw, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oextsw]={.name = "extsw", .argcls = { {[Kw]=Ke, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oextuw]={.name = "extuw", .argcls = { {[Kw]=Ke, [Kl]=Kw, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oexts]={.name = "exts", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ke, [Kd]=Ks}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ke, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Otruncd]={.name = "truncd", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Kd, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Kx, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ostosi]={.name = "stosi", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ostoui]={.name = "stoui", .argcls = { {[Kw]=Ks, [Kl]=Ks, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Odtosi]={.name = "dtosi", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Odtoui]={.name = "dtoui", .argcls = { {[Kw]=Kd, [Kl]=Kd, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oswtof]={.name = "swtof", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Kw, [Kd]=Kw}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ouwtof]={.name = "uwtof", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Kw, [Kd]=Kw}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Osltof]={.name = "sltof", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Kl, [Kd]=Kl}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oultof]={.name = "ultof", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Kl, [Kd]=Kl}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ocast]={.name = "cast", .argcls = { {[Kw]=Ks, [Kl]=Kd, [Ks]=Kw, [Kd]=Kl}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 1, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oalloc4]={.name = "alloc4", .argcls = { {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oalloc8]={.name = "alloc8", .argcls = { {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oalloc16]={.name = "alloc16", .argcls = { {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ovaarg]={.name = "vaarg", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Km, [Kd]=Km}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ovastart]={.name = "vastart", .argcls = { {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ocopy]={.name = "copy", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Odbgloc]={.name = "dbgloc", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Onop]={.name = "nop", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oaddr]={.name = "addr", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oblit0]={.name = "blit0", .argcls = { {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Km, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oblit1]={.name = "blit1", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Osel0]={.name = "sel0", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Osel1]={.name = "sel1", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oswap]={.name = "swap", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Osign]={.name = "sign", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Osalloc]={.name = "salloc", .argcls = { {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxidiv]={.name = "xidiv", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxdiv]={.name = "xdiv", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxcmp]={.name = "xcmp", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxtest]={.name = "xtest", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oacmp]={.name = "acmp", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oacmn]={.name = "acmn", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oafcmp]={.name = "afcmp", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oreqz]={.name = "reqz", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Ornez]={.name = "rnez", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Opar]={.name = "par", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oparsb]={.name = "parsb", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oparub]={.name = "parub", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oparsh]={.name = "parsh", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oparuh]={.name = "paruh", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oparc]={.name = "parc", .argcls = { {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Opare]={.name = "pare", .argcls = { {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oarg]={.name = "arg", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oargsb]={.name = "argsb", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oargub]={.name = "argub", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oargsh]={.name = "argsh", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oarguh]={.name = "arguh", .argcls = { {[Kw]=Kw, [Kl]=Ke, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oargc]={.name = "argc", .argcls = { {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oarge]={.name = "arge", .argcls = { {[Kw]=Ke, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Ke, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oargv]={.name = "argv", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Ocall]={.name = "call", .argcls = { {[Kw]=Km, [Kl]=Km, [Ks]=Km, [Kd]=Km}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Kx, [Kd]=Kx} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 1},
[Oflagieq]={.name = "flagieq", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagine]={.name = "flagine", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagisge]={.name = "flagisge", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagisgt]={.name = "flagisgt", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagisle]={.name = "flagisle", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagislt]={.name = "flagislt", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagiuge]={.name = "flagiuge", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagiugt]={.name = "flagiugt", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagiule]={.name = "flagiule", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagiult]={.name = "flagiult", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfeq]={.name = "flagfeq", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfge]={.name = "flagfge", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfgt]={.name = "flagfgt", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfle]={.name = "flagfle", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagflt]={.name = "flagflt", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfne]={.name = "flagfne", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfo]={.name = "flagfo", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oflagfuo]={.name = "flagfuo", .argcls = { {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kx, [Kl]=Kx, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselieq]={.name = "xselieq", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxseline]={.name = "xseline", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselisge]={.name = "xselisge", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselisgt]={.name = "xselisgt", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselisle]={.name = "xselisle", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselislt]={.name = "xselislt", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxseliuge]={.name = "xseliuge", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxseliugt]={.name = "xseliugt", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxseliule]={.name = "xseliule", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxseliult]={.name = "xseliult", .argcls = { {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke}, {[Kw]=Kw, [Kl]=Kl, [Ks]=Ke, [Kd]=Ke} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfeq]={.name = "xselfeq", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfge]={.name = "xselfge", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfgt]={.name = "xselfgt", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfle]={.name = "xselfle", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselflt]={.name = "xselflt", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfne]={.name = "xselfne", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfo]={.name = "xselfo", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},
[Oxselfuo]={.name = "xselfuo", .argcls = { {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd}, {[Kw]=Ke, [Kl]=Ke, [Ks]=Ks, [Kd]=Kd} }, .canfold = 0, .hasid = 0, .idval = 0, .commutes = 0, .assoc = 0, .idemp = 0, .cmpeqwl = 0, .cmplgtewl = 0, .eqval = 0, .pinned = 0},

};
typedef enum {
 PXXX,
 PLbl,
 PPhi,
 PIns,
 PEnd,
} PState;
enum Token {
 Txxx = 0,
 Tloadw = NPubOp,
 Tloadl,
 Tloads,
 Tloadd,
 Talloc1,
 Talloc2,
 Tblit,
 Tcall,
 Tenv,
 Tphi,
 Tjmp,
 Tjnz,
 Tret,
 Thlt,
 Texport,
 Tthread,
 Textern,
 Tcommon,
 Tfunc,
 Ttype,
 Tdata,
 Tsection,
 Talign,
 Tdbgfile,
 Tl,
 Tw,
 Tsh,
 Tuh,
 Th,
 Tsb,
 Tub,
 Tb,
 Td,
 Ts,
 Tz,
 Tint,
 Tflts,
 Tfltd,
 Ttmp,
 Tlbl,
 Tglo,
 Ttyp,
 Tstr,
 Tplus,
 Teq,
 Tcomma,
 Tlparen,
 Trparen,
 Tlbrace,
 Trbrace,
 Tnl,
 Tdots,
 Teof,
 Ntok
};
static char *kwmap[Ntok] = {
 [Tloadw] = "loadw",
 [Tloadl] = "loadl",
 [Tloads] = "loads",
 [Tloadd] = "loadd",
 [Talloc1] = "alloc1",
 [Talloc2] = "alloc2",
 [Tblit] = "blit",
 [Tcall] = "call",
 [Tenv] = "env",
 [Tphi] = "phi",
 [Tjmp] = "jmp",
 [Tjnz] = "jnz",
 [Tret] = "ret",
 [Thlt] = "hlt",
 [Texport] = "export",
 [Tthread] = "thread",
 [Textern] = "extern",
 [Tcommon] = "common",
 [Tfunc] = "function",
 [Ttype] = "type",
 [Tdata] = "data",
 [Tsection] = "section",
 [Talign] = "align",
 [Tdbgfile] = "dbgfile",
 [Tsb] = "sb",
 [Tub] = "ub",
 [Tsh] = "sh",
 [Tuh] = "uh",
 [Tb] = "b",
 [Th] = "h",
 [Tw] = "w",
 [Tl] = "l",
 [Ts] = "s",
 [Td] = "d",
 [Tz] = "z",
 [Tdots] = "...",
};
enum {
 NPred = 63,
 TMask = 16383,
 BMask = 8191,
 K = 11183273,
 M = 23,
};
static uchar lexh[1 << (32-M)];
static FILE *inf;
static char *inpath;
static int thead;
static struct {
 char chr;
 double fltd;
 float flts;
 int64_t num;
 char *str;
} tokval;
static int lnum;
static Fn *curf;
static int *tmph;
static int tmphcap;
static Phi **plink;
static Blk *curb;
static Blk **blink;
static Blk *blkh[BMask+1];
static int nblk;
static int rcls;
static uint ntyp;
void
err(char *s, ...)
{
 va_list ap;
 __builtin_va_start(ap, s);
 fprintf(__stderrp, "qbe:%s:%d: ", inpath, lnum);
 vfprintf(__stderrp, s, ap);
 fprintf(__stderrp, "\n");
 __builtin_va_end(ap);
 exit(1);
}
static void
lexinit()
{
 static int done;
 int i;
 long h;
 if (done)
  return;
 for (i=0; i<NPubOp; ++i)
  if (optab[i].name)
   kwmap[i] = optab[i].name;
 ((void)0);
 for (i=0; i<Ntok; ++i)
  if (kwmap[i]) {
   h = hash(kwmap[i])*K >> M;
   ((void)0);
   lexh[h] = i;
  }
 done = 1;
}
static int64_t
getint()
{
 uint64_t n;
 int c, m;
 n = 0;
 c = fgetc(inf);
 m = (c == '-');
 if (m) {
  c = fgetc(inf);
  if (!isdigit(c))
   err("integer expected");
 }
 do {
  n = 10*n + (c - '0');
  c = fgetc(inf);
 } while (isdigit(c));
 ungetc(c, inf);
 if (m)
  n = 1 + ~n;
 return *(int64_t *)&n;
}
static int
lex()
{
 int c, i, esc;
 int t;
 do
  c = fgetc(inf);
 while (isblank(c));
 t = Txxx;
 tokval.chr = c;
 switch (c) {
 case (-1):
  return Teof;
 case ',':
  return Tcomma;
 case '(':
  return Tlparen;
 case ')':
  return Trparen;
 case '{':
  return Tlbrace;
 case '}':
  return Trbrace;
 case '=':
  return Teq;
 case '+':
  return Tplus;
 case 's':
  if (fscanf(inf, "_%f", &tokval.flts) != 1)
   break;
  return Tflts;
 case 'd':
  if (fscanf(inf, "_%lf", &tokval.fltd) != 1)
   break;
  return Tfltd;
 case '%':
  t = Ttmp;
  c = fgetc(inf);
  goto Alpha;
 case '@':
  t = Tlbl;
  c = fgetc(inf);
  goto Alpha;
 case '$':
  t = Tglo;
  if ((c = fgetc(inf)) == '"')
   goto Quoted;
  goto Alpha;
 case ':':
  t = Ttyp;
  c = fgetc(inf);
  goto Alpha;
 case '#':
  while ((c=fgetc(inf)) != '\n' && c != (-1))
   ;
 case '\n':
  lnum++;
  return Tnl;
 }
 if (isdigit(c) || c == '-') {
  ungetc(c, inf);
  tokval.num = getint();
  return Tint;
 }
 if (c == '"') {
  t = Tstr;
 Quoted:
  tokval.str[0] = c;
  esc = 0;
  for (i=1;; i++) {
   c = fgetc(inf);
   if (c == (-1))
    err("unterminated string");
   vgrow(&tokval.str, i+2);
   tokval.str[i] = c;
   if (c == '"' && !esc) {
    tokval.str[i+1] = 0;
    return t;
   }
   esc = (c == '\\' && !esc);
  }
 }
Alpha:
 if (!isalpha(c) && c != '.' && c != '_')
  err("invalid character %c (%d)", c, c);
 i = 0;
 do {
  vgrow(&tokval.str, i+2);
  tokval.str[i++] = c;
  c = fgetc(inf);
 } while (isalpha(c) || c == '$' || c == '.' || c == '_' || isdigit(c));
 tokval.str[i] = 0;
 ungetc(c, inf);
 if (t != Txxx) {
  return t;
 }
 t = lexh[hash(tokval.str)*K >> M];
 if (t == Txxx || strcmp(kwmap[t], tokval.str) != 0) {
  err("unknown keyword %s", tokval.str);
  return Txxx;
 }
 return t;
}
static int
peek()
{
 if (thead == Txxx)
  thead = lex();
 return thead;
}
static int
next()
{
 int t;
 t = peek();
 thead = Txxx;
 return t;
}
static int
nextnl()
{
 int t;
 while ((t = next()) == Tnl)
  ;
 return t;
}
static void
expect(int t)
{
 static char *ttoa[] = {
  [Tlbl] = "label",
  [Tcomma] = ",",
  [Teq] = "=",
  [Tnl] = "newline",
  [Tlparen] = "(",
  [Trparen] = ")",
  [Tlbrace] = "{",
  [Trbrace] = "}",
  [Teof] = 0,
 };
 char buf[128], *s1, *s2;
 int t1;
 t1 = next();
 if (t == t1)
  return;
 s1 = ttoa[t] ? ttoa[t] : "??";
 s2 = ttoa[t1] ? ttoa[t1] : "??";
 sprintf(buf, "%s expected, got %s instead", s1, s2);
 err(buf);
}
static Ref
tmpref()
{
 int t, i;
 if (tmphcap/2 <= curf->ntmp-Tmp0) {
  free(tmph);
  tmphcap = tmphcap ? tmphcap*2 : TMask+1;
  tmph = emalloc(tmphcap * sizeof tmph[0]);
  for (t=Tmp0; t<curf->ntmp; t++) {
   i = hash(curf->tmp[t].name) & (tmphcap-1);
   for (; tmph[i]; i=(i+1) & (tmphcap-1))
    ;
   tmph[i] = t;
  }
 }
 i = hash(tokval.str) & (tmphcap-1);
 for (; tmph[i]; i=(i+1) & (tmphcap-1)) {
  t = tmph[i];
  if (strcmp(curf->tmp[t].name, tokval.str) == 0)
   return (Ref){RTmp, t};
 }
 t = curf->ntmp;
 tmph[i] = t;
 newtmp(0, Kx, curf);
 curf->tmp[t].name = strf(PFn, "%s", tokval.str);
 return (Ref){RTmp, t};
}
static Ref
parseref()
{
 Con c;
 int tok;
 memset(&c, 0, sizeof c);
 switch ((tok = next())) {
 case Ttmp:
  return tmpref();
 case Tint:
  c.type = CBits;
  c.bits.i = tokval.num;
  break;
 case Tflts:
  c.type = CBits;
  c.bits.s = tokval.flts;
  c.flt = 1;
  break;
 case Tfltd:
  c.type = CBits;
  c.bits.d = tokval.fltd;
  c.flt = 2;
  break;
 default:
  for (;; tok=next()) {
   switch (tok) {
   case Textern:
    c.sym.type |= SExt;
    continue;
   case Tthread:
    c.sym.type |= SThr;
    continue;
   }
   break;
  }
  if (tok != Tglo)
   return (Ref){RTmp, 0};
 case Tglo:
  c.type = CAddr;
  c.sym.id = intern(tokval.str);
  break;
 }
 return newcon(&c, curf);
}
static int
findtyp(int i)
{
 while (--i >= 0)
  if (strcmp(tokval.str, typ[i].name) == 0)
   return i;
 err("undefined type :%s", tokval.str);
}
static int
parsecls(int *tyn)
{
 switch (next()) {
 default:
  err("invalid class specifier");
 case Ttyp:
  *tyn = findtyp(ntyp);
  return Kc;
 case Tsb:
  return Ksb;
 case Tub:
  return Kub;
 case Tsh:
  return Ksh;
 case Tuh:
  return Kuh;
 case Tw:
  return Kw;
 case Tl:
  return Kl;
 case Ts:
  return Ks;
 case Td:
  return Kd;
 }
}
static int
parserefl(int arg)
{
 int k, ty, env, hasenv, vararg;
 Ref r;
 hasenv = 0;
 vararg = 0;
 expect(Tlparen);
 while (peek() != Trparen) {
  if (curi - insb >= NIns)
   err("too many instructions");
  if (!arg && vararg)
   err("no parameters allowed after '...'");
  switch (peek()) {
  case Tdots:
   if (vararg)
    err("only one '...' allowed");
   vararg = 1;
   if (arg) {
    *curi = (Ins){.op = Oargv};
    curi++;
   }
   next();
   goto Next;
  case Tenv:
   if (hasenv)
    err("only one environment allowed");
   hasenv = 1;
   env = 1;
   next();
   k = Kl;
   break;
  default:
   env = 0;
   k = parsecls(&ty);
   break;
  }
  r = parseref();
  if (req(r, (Ref){RTmp, 0}))
   err("invalid argument");
  if (!arg && rtype(r) != RTmp)
   err("invalid function parameter");
  if (env)
   if (arg)
    *curi = (Ins){Oarge, k, (Ref){RTmp, 0}, {r}};
   else
    *curi = (Ins){Opare, k, r, {(Ref){RTmp, 0}}};
  else if (k == Kc)
   if (arg)
    *curi = (Ins){Oargc, Kl, (Ref){RTmp, 0}, {(Ref){RType, ty}, r}};
   else
    *curi = (Ins){Oparc, Kl, r, {(Ref){RType, ty}}};
  else if (k >= Ksb)
   if (arg)
    *curi = (Ins){Oargsb+(k-Ksb), Kw, (Ref){RTmp, 0}, {r}};
   else
    *curi = (Ins){Oparsb+(k-Ksb), Kw, r, {(Ref){RTmp, 0}}};
  else
   if (arg)
    *curi = (Ins){Oarg, k, (Ref){RTmp, 0}, {r}};
   else
    *curi = (Ins){Opar, k, r, {(Ref){RTmp, 0}}};
  curi++;
 Next:
  if (peek() == Trparen)
   break;
  expect(Tcomma);
 }
 expect(Trparen);
 return vararg;
}
static Blk *
findblk()
{
 Blk *b;
 uint32_t h;
 h = hash(tokval.str) & BMask;
 for (b=blkh[h]; b; b=b->dlink)
  if (strcmp(b->name, tokval.str) == 0)
   return b;
 b = newblk();
 b->id = nblk++;
 b->name = strf(PFn, "%s", tokval.str);
 b->dlink = blkh[h];
 blkh[h] = b;
 return b;
}
static void
closeblk()
{
 idup(curb, insb, curi-insb);
 blink = &curb->link;
 curi = insb;
}
static PState
parseline(PState ps)
{
 Ref arg[NPred] = {(Ref){RTmp, 0}};
 Blk *blk[NPred];
 Phi *phi;
 Ref r;
 Blk *b;
 Con *c;
 int t, op, i, k, ty;
 t = nextnl();
 if (ps == PLbl && t != Tlbl && t != Trbrace)
  err("label or } expected");
 switch (t) {
 case Ttmp:
  r = tmpref();
  expect(Teq);
  k = parsecls(&ty);
  op = next();
  break;
 default:
  if (((unsigned)(t) - Ostoreb <= Ostored - Ostoreb)) {
  case Tblit:
  case Tcall:
  case Ovastart:
   r = (Ref){RTmp, 0};
   k = Kw;
   op = t;
   break;
  }
  err("label, instruction or jump expected");
 case Trbrace:
  return PEnd;
 case Tlbl:
  b = findblk();
  if (curb && curb->jmp.type == Jxxx) {
   closeblk();
   curb->jmp.type = Jjmp;
   curb->s1 = b;
  }
  if (b->jmp.type != Jxxx)
   err("multiple definitions of block @%s", b->name);
  *blink = b;
  curb = b;
  plink = &curb->phi;
  expect(Tnl);
  return PPhi;
 case Tret:
  curb->jmp.type = Jretw + rcls;
  if (peek() == Tnl)
   curb->jmp.type = Jret0;
  else if (rcls != K0) {
   r = parseref();
   if (req(r, (Ref){RTmp, 0}))
    err("invalid return value");
   curb->jmp.arg = r;
  }
  goto Close;
 case Tjmp:
  curb->jmp.type = Jjmp;
  goto Jump;
 case Tjnz:
  curb->jmp.type = Jjnz;
  r = parseref();
  if (req(r, (Ref){RTmp, 0}))
   err("invalid argument for jnz jump");
  curb->jmp.arg = r;
  expect(Tcomma);
 Jump:
  expect(Tlbl);
  curb->s1 = findblk();
  if (curb->jmp.type != Jjmp) {
   expect(Tcomma);
   expect(Tlbl);
   curb->s2 = findblk();
  }
  if (curb->s1 == curf->start || curb->s2 == curf->start)
   err("invalid jump to the start block");
  goto Close;
 case Thlt:
  curb->jmp.type = Jhlt;
 Close:
  expect(Tnl);
  closeblk();
  return PLbl;
 case Odbgloc:
  op = t;
  k = Kw;
  r = (Ref){RTmp, 0};
  expect(Tint);
  arg[0] = (Ref){RInt, (tokval.num)&0x1fffffff};
  if (arg[0].val != tokval.num)
   err("line number too big");
  if (peek() == Tcomma) {
   next();
   expect(Tint);
   arg[1] = (Ref){RInt, (tokval.num)&0x1fffffff};
   if (arg[1].val != tokval.num)
    err("column number too big");
  } else
   arg[1] = (Ref){RInt, (0)&0x1fffffff};
  goto Ins;
 }
 if (op == Tcall) {
  curf->leaf = 0;
  arg[0] = parseref();
  parserefl(1);
  op = Ocall;
  expect(Tnl);
  if (k == Kc) {
   k = Kl;
   arg[1] = (Ref){RType, ty};
  }
  if (k >= Ksb)
   k = Kw;
  goto Ins;
 }
 if (op == Tloadw)
  op = Oloadsw;
 if (op >= Tloadl && op <= Tloadd)
  op = Oload;
 if (op == Talloc1 || op == Talloc2)
  op = Oalloc;
 if (op == Ovastart && !curf->vararg)
  err("cannot use vastart in non-variadic function");
 if (k >= Ksb)
  err("size class must be w, l, s, or d");
 i = 0;
 if (peek() != Tnl)
  for (;;) {
   if (i == NPred)
    err("too many arguments");
   if (op == Tphi) {
    expect(Tlbl);
    blk[i] = findblk();
   }
   arg[i] = parseref();
   if (req(arg[i], (Ref){RTmp, 0}))
    err("invalid instruction argument");
   i++;
   t = peek();
   if (t == Tnl)
    break;
   if (t != Tcomma)
    err(", or end of line expected");
   next();
  }
 next();
 switch (op) {
 case Tphi:
  if (ps != PPhi || curb == curf->start)
   err("unexpected phi instruction");
  phi = alloc(sizeof *phi);
  phi->to = r;
  phi->cls = k;
  phi->arg = vnew(i, sizeof arg[0], PFn);
  memcpy(phi->arg, arg, i * sizeof arg[0]);
  phi->blk = vnew(i, sizeof blk[0], PFn);
  memcpy(phi->blk, blk, i * sizeof blk[0]);
  phi->narg = i;
  *plink = phi;
  plink = &phi->link;
  return PPhi;
 case Tblit:
  if (curi - insb >= NIns-1)
   err("too many instructions");
  memset(curi, 0, 2 * sizeof(Ins));
  curi->op = Oblit0;
  curi->arg[0] = arg[0];
  curi->arg[1] = arg[1];
  curi++;
  if (rtype(arg[2]) != RCon)
   err("blit size must be constant");
  c = &curf->con[arg[2].val];
  r = (Ref){RInt, (c->bits.i)&0x1fffffff};
  if (c->type != CBits
  || rsval(r) < 0
  || rsval(r) != c->bits.i)
   err("invalid blit size");
  curi->op = Oblit1;
  curi->arg[0] = r;
  curi++;
  return PIns;
 default:
  if (op >= NPubOp)
   err("invalid instruction");
 Ins:
  if (curi - insb >= NIns)
   err("too many instructions");
  curi->op = op;
  curi->cls = k;
  curi->to = r;
  curi->arg[0] = arg[0];
  curi->arg[1] = arg[1];
  curi++;
  return PIns;
 }
}
static int
usecheck(Ref r, int k, Fn *fn)
{
 return rtype(r) != RTmp || fn->tmp[r.val].cls == k
  || (fn->tmp[r.val].cls == Kl && k == Kw);
}
static void
typecheck(Fn *fn)
{
 Blk *b;
 Phi *p;
 Ins *i;
 uint n;
 int k;
 Tmp *t;
 Ref r;
 BSet pb[1], ppb[1];
 fillpreds(fn);
 bsinit(pb, fn->nblk);
 bsinit(ppb, fn->nblk);
 for (b=fn->start; b; b=b->link) {
  for (p=b->phi; p; p=p->link)
   fn->tmp[p->to.val].cls = p->cls;
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   if (rtype(i->to) == RTmp) {
    t = &fn->tmp[i->to.val];
    if (clsmerge(&t->cls, i->cls))
     err("temporary %%%s is assigned with"
      " multiple types", t->name);
   }
 }
 for (b=fn->start; b; b=b->link) {
  bszero(pb);
  for (n=0; n<b->npred; n++)
   bsset(pb, b->pred[n]->id);
  for (p=b->phi; p; p=p->link) {
   bszero(ppb);
   t = &fn->tmp[p->to.val];
   for (n=0; n<p->narg; n++) {
    k = t->cls;
    if (bshas(ppb, p->blk[n]->id))
     err("multiple entries for @%s in phi %%%s",
      p->blk[n]->name, t->name);
    if (!usecheck(p->arg[n], k, fn))
     err("invalid type for operand %%%s in phi %%%s",
      fn->tmp[p->arg[n].val].name, t->name);
    bsset(ppb, p->blk[n]->id);
   }
   if (!bsequal(pb, ppb))
    err("predecessors not matched in phi %%%s", t->name);
  }
  for (i=b->ins; i<&b->ins[b->nins]; i++)
   for (n=0; n<2; n++) {
    k = optab[i->op].argcls[n][i->cls];
    r = i->arg[n];
    t = &fn->tmp[r.val];
    if (k == Ke)
     err("invalid instruction type in %s",
      optab[i->op].name);
    if (rtype(r) == RType)
     continue;
    if (rtype(r) != -1 && k == Kx)
     err("no %s operand expected in %s",
      n == 1 ? "second" : "first",
      optab[i->op].name);
    if (rtype(r) == -1 && k != Kx)
     err("missing %s operand in %s",
      n == 1 ? "second" : "first",
      optab[i->op].name);
    if (!usecheck(r, k, fn))
     err("invalid type for %s operand %%%s in %s",
      n == 1 ? "second" : "first",
      t->name, optab[i->op].name);
   }
  r = b->jmp.arg;
  if (((unsigned)(b->jmp.type) - Jretw <= Jret0 - Jretw)) {
   if (b->jmp.type == Jretc)
    k = Kl;
   else if (b->jmp.type >= Jretsb)
    k = Kw;
   else
    k = b->jmp.type - Jretw;
   if (!usecheck(r, k, fn))
    goto JErr;
  }
  if (b->jmp.type == Jjnz && !usecheck(r, Kw, fn))
  JErr:
   err("invalid type for jump argument %%%s in block @%s",
    fn->tmp[r.val].name, b->name);
  if (b->s1 && b->s1->jmp.type == Jxxx)
   err("block @%s is used undefined", b->s1->name);
  if (b->s2 && b->s2->jmp.type == Jxxx)
   err("block @%s is used undefined", b->s2->name);
 }
}
static Fn *
parsefn(Lnk *lnk)
{
 Blk *b;
 int i;
 PState ps;
 curb = 0;
 nblk = 0;
 curi = insb;
 curf = alloc(sizeof *curf);
 curf->ntmp = 0;
 curf->ncon = 2;
 curf->tmp = vnew(curf->ntmp, sizeof curf->tmp[0], PFn);
 curf->con = vnew(curf->ncon, sizeof curf->con[0], PFn);
 for (i=0; i<Tmp0; ++i)
  if (T.fpr0 <= i && i < T.fpr0 + T.nfpr)
   newtmp(0, Kd, curf);
  else
   newtmp(0, Kl, curf);
 curf->con[0].type = CBits;
 curf->con[0].bits.i = 0xdeaddead;
 curf->con[1].type = CBits;
 curf->lnk = *lnk;
 curf->leaf = 1;
 blink = &curf->start;
 curf->retty = Kx;
 if (peek() != Tglo)
  rcls = parsecls(&curf->retty);
 else
  rcls = K0;
 if (next() != Tglo)
  err("function name expected");
 curf->name = strf(PFn, "%s", tokval.str);
 curf->vararg = parserefl(0);
 if (nextnl() != Tlbrace)
  err("function body must start with {");
 ps = PLbl;
 do
  ps = parseline(ps);
 while (ps != PEnd);
 if (!curb)
  err("empty function");
 if (curb->jmp.type == Jxxx)
  err("last block misses jump");
 curf->mem = vnew(0, sizeof curf->mem[0], PFn);
 curf->nmem = 0;
 curf->nblk = nblk;
 curf->rpo = vnew(nblk, sizeof curf->rpo[0], PFn);
 for (b=curf->start; b; b=b->link)
  b->dlink = 0;
 for (i=0; i<BMask+1; ++i)
  blkh[i] = 0;
 memset(tmph, 0, tmphcap * sizeof tmph[0]);
 typecheck(curf);
 return curf;
}
static void
parsefields(Field *fld, Typ *ty, int t)
{
 Typ *ty1;
 int n, c, a, al, type;
 uint64_t sz, s;
 n = 0;
 sz = 0;
 al = ty->align;
 while (t != Trbrace) {
  ty1 = 0;
  switch (t) {
  default: err("invalid type member specifier");
  case Td: type = Fd; s = 8; a = 3; break;
  case Tl: type = Fl; s = 8; a = 3; break;
  case Ts: type = Fs; s = 4; a = 2; break;
  case Tw: type = Fw; s = 4; a = 2; break;
  case Th: type = Fh; s = 2; a = 1; break;
  case Tb: type = Fb; s = 1; a = 0; break;
  case Ttyp:
   type = FTyp;
   ty1 = &typ[findtyp(ntyp-1)];
   s = ty1->size;
   a = ty1->align;
   break;
  }
  if (a > al)
   al = a;
  a = (1 << a) - 1;
  a = ((sz + a) & ~a) - sz;
  if (a) {
   if (n < NField) {
    fld[n].type = FPad;
    fld[n].len = a;
    n++;
   }
  }
  t = nextnl();
  if (t == Tint) {
   c = tokval.num;
   t = nextnl();
  } else
   c = 1;
  sz += a + c*s;
  if (type == FTyp)
   s = ty1 - typ;
  for (; c>0 && n<NField; c--, n++) {
   fld[n].type = type;
   fld[n].len = s;
  }
  if (t != Tcomma)
   break;
  t = nextnl();
 }
 if (t != Trbrace)
  err(", or } expected");
 fld[n].type = FEnd;
 a = 1 << al;
 if (sz < ty->size)
  sz = ty->size;
 ty->size = (sz + a - 1) & -a;
 ty->align = al;
}
static void
parsetyp()
{
 Typ *ty;
 int t, al;
 uint n;
 vgrow(&typ, ntyp+1);
 ty = &typ[ntyp++];
 ty->isdark = 0;
 ty->isunion = 0;
 ty->align = -1;
 ty->size = 0;
 if (nextnl() != Ttyp || nextnl() != Teq)
  err("type name and then = expected");
 ty->name = strf(PHeap, "%s", tokval.str);
 t = nextnl();
 if (t == Talign) {
  if (nextnl() != Tint)
   err("alignment expected");
  for (al=0; tokval.num /= 2; al++)
   ;
  ty->align = al;
  t = nextnl();
 }
 if (t != Tlbrace)
  err("type body must start with {");
 t = nextnl();
 if (t == Tint) {
  ty->isdark = 1;
  ty->size = tokval.num;
  if (ty->align == -1)
   err("dark types need alignment");
  if (nextnl() != Trbrace)
   err("} expected");
  return;
 }
 n = 0;
 ty->fields = vnew(1, sizeof ty->fields[0], PHeap);
 if (t == Tlbrace) {
  ty->isunion = 1;
  do {
   if (t != Tlbrace)
    err("invalid union member");
   vgrow(&ty->fields, n+1);
   parsefields(ty->fields[n++], ty, nextnl());
   t = nextnl();
  } while (t != Trbrace);
 } else
  parsefields(ty->fields[n++], ty, t);
 ty->nunion = n;
}
static void
parsedatref(Dat *d)
{
 int t;
 d->isref = 1;
 d->u.ref.name = strf(PFn, "%s", tokval.str);
 d->u.ref.off = 0;
 t = peek();
 if (t == Tplus) {
  next();
  if (next() != Tint)
   err("invalid token after offset in ref");
  d->u.ref.off = tokval.num;
 }
}
static void
parsedatstr(Dat *d)
{
 d->isstr = 1;
 d->u.str = strf(PFn, "%s", tokval.str);
}
static void
parsedat(void cb(Dat *), Lnk *lnk)
{
 char *name;
 int t;
 Dat d;
 if (nextnl() != Tglo || nextnl() != Teq)
  err("data name, then = expected");
 name = strf(PFn, "%s", tokval.str);
 t = nextnl();
 lnk->align = 8;
 if (t == Talign) {
  if (nextnl() != Tint)
   err("alignment expected");
  if (tokval.num <= 0 || tokval.num > 127
  || (tokval.num & (tokval.num-1)) != 0)
   err("invalid alignment");
  lnk->align = tokval.num;
  t = nextnl();
 }
 d.type = DStart;
 d.name = name;
 d.lnk = lnk;
 cb(&d);
 if (t != Tlbrace)
  err("expected data contents in { .. }");
 for (;;) {
  switch (nextnl()) {
  default: err("invalid size specifier %c in data", tokval.chr);
  case Trbrace: goto Done;
  case Tl: d.type = DL; break;
  case Tw: d.type = DW; break;
  case Th: d.type = DH; break;
  case Tb: d.type = DB; break;
  case Ts: d.type = DW; break;
  case Td: d.type = DL; break;
  case Tz: d.type = DZ; break;
  }
  t = nextnl();
  do {
   d.isstr = 0;
   d.isref = 0;
   memset(&d.u, 0, sizeof d.u);
   if (t == Tflts)
    d.u.flts = tokval.flts;
   else if (t == Tfltd)
    d.u.fltd = tokval.fltd;
   else if (t == Tint)
    d.u.num = tokval.num;
   else if (t == Tglo)
    parsedatref(&d);
   else if (t == Tstr)
    parsedatstr(&d);
   else
    err("constant literal expected");
   cb(&d);
   t = nextnl();
  } while (t == Tint || t == Tflts || t == Tfltd || t == Tstr || t == Tglo);
  if (t == Trbrace)
   break;
  if (t != Tcomma)
   err(", or } expected");
 }
Done:
 d.type = DEnd;
 cb(&d);
}
static int
parselnk(Lnk *lnk)
{
 int t, haslnk;
 for (haslnk=0;; haslnk=1)
  switch ((t=nextnl())) {
  case Texport:
   lnk->export = 1;
   break;
  case Tthread:
   lnk->thread = 1;
   break;
  case Tcommon:
   lnk->common = 1;
   break;
  case Tsection:
   if (lnk->sec)
    err("only one section allowed");
   if (next() != Tstr)
    err("section \"name\" expected");
   lnk->sec = strf(PFn, "%s", tokval.str);
   if (peek() == Tstr) {
    next();
    lnk->secf = strf(PFn, "%s", tokval.str);
   }
   break;
  default:
   if (t == Tfunc && lnk->thread)
    err("only data may have thread linkage");
   if (haslnk && t != Tdata && t != Tfunc)
    err("only data and function have linkage");
   return t;
  }
}
void
parse(FILE *f, char *path, void dbgfile(char *), void data(Dat *), void func(Fn *))
{
 Lnk lnk;
 uint n;
 lexinit();
 inf = f;
 inpath = path;
 lnum = 1;
 thead = Txxx;
 ntyp = 0;
 typ = vnew(0, sizeof typ[0], PHeap);
 tokval.str = vnew(128, 1, PHeap);
 for (;;) {
  lnk = (Lnk){0};
  switch (parselnk(&lnk)) {
  default:
   err("top-level definition expected");
  case Tdbgfile:
   expect(Tstr);
   dbgfile(tokval.str);
   break;
  case Tfunc:
   lnk.align = 16;
   func(parsefn(&lnk));
   break;
  case Tdata:
   parsedat(data, &lnk);
   break;
  case Ttype:
   parsetyp();
   break;
  case Teof:
   for (n=0; n<ntyp; n++) {
    free(typ[n].name);
    if (typ[n].nunion)
     vfree(typ[n].fields);
   }
   vfree(typ);
   return;
  }
 }
}
static void
printcon(Con *c, FILE *f)
{
 switch (c->type) {
 case CUndef:
  break;
 case CAddr:
  if (c->sym.type & SExt)
   fprintf(f, "extern ");
  if (c->sym.type & SThr)
   fprintf(f, "thread ");
  fprintf(f, "$%s", str(c->sym.id));
  if (c->bits.i)
   fprintf(f, "%+""li", c->bits.i);
  break;
 case CBits:
  if (c->flt == 1)
   fprintf(f, "s_%f", c->bits.s);
  else if (c->flt == 2)
   fprintf(f, "d_%lf", c->bits.d);
  else
   fprintf(f, "%""li", c->bits.i);
  break;
 }
}
void
printref(Ref r, Fn *fn, FILE *f)
{
 int i;
 Mem *m;
 switch (rtype(r)) {
 case RTmp:
  if (r.val < Tmp0)
   fprintf(f, "R%d", r.val);
  else
   fprintf(f, "%%%s", fn->tmp[r.val].name);
  break;
 case RCon:
  if (req(r, (Ref){RCon, 0}))
   fprintf(f, "UNDEF");
  else
   printcon(&fn->con[r.val], f);
  break;
 case RSlot:
  fprintf(f, "S%d", rsval(r));
  break;
 case RCall:
  fprintf(f, "%04x", r.val);
  break;
 case RType:
  fprintf(f, ":%s", typ[r.val].name);
  break;
 case RMem:
  i = 0;
  m = &fn->mem[r.val];
  fputc('[', f);
  if (m->offset.type != CUndef) {
   printcon(&m->offset, f);
   i = 1;
  }
  if (!req(m->base, (Ref){RTmp, 0})) {
   if (i)
    fprintf(f, " + ");
   printref(m->base, fn, f);
   i = 1;
  }
  if (!req(m->index, (Ref){RTmp, 0})) {
   if (i)
    fprintf(f, " + ");
   fprintf(f, "%d * ", m->scale);
   printref(m->index, fn, f);
  }
  fputc(']', f);
  break;
 case RInt:
  fprintf(f, "%d", rsval(r));
  break;
 case -1:
  fprintf(f, "R");
  break;
 }
}
void
printfn(Fn *fn, FILE *f)
{
 static char ktoc[] = "wlsd";
 static char *jtoa[NJmp] = {
  [Jretw] = "retw", [Jretl] = "retl", [Jrets] = "rets", [Jretd] = "retd", [Jretsb] = "retsb", [Jretub] = "retub", [Jretsh] = "retsh", [Jretuh] = "retuh", [Jretc] = "retc", [Jret0] = "ret0", [Jjmp] = "jmp", [Jjnz] = "jnz", [Jjfieq] = "jfieq", [Jjfine] = "jfine", [Jjfisge] = "jfisge", [Jjfisgt] = "jfisgt", [Jjfisle] = "jfisle", [Jjfislt] = "jfislt", [Jjfiuge] = "jfiuge", [Jjfiugt] = "jfiugt", [Jjfiule] = "jfiule", [Jjfiult] = "jfiult", [Jjffeq] = "jffeq", [Jjffge] = "jffge", [Jjffgt] = "jffgt", [Jjffle] = "jffle", [Jjfflt] = "jfflt", [Jjffne] = "jffne", [Jjffo] = "jffo", [Jjffuo] = "jffuo", [Jhlt] = "hlt",
 };
 Blk *b;
 Phi *p;
 Ins *i;
 uint n;
 fprintf(f, "function $%s() {\n", fn->name);
 for (b=fn->start; b; b=b->link) {
  fprintf(f, "@%s\n", b->name);
  for (p=b->phi; p; p=p->link) {
   fprintf(f, "\t");
   printref(p->to, fn, f);
   fprintf(f, " =%c phi ", ktoc[p->cls]);
   ((void)0);
   for (n=0;; n++) {
    fprintf(f, "@%s ", p->blk[n]->name);
    printref(p->arg[n], fn, f);
    if (n == p->narg-1) {
     fprintf(f, "\n");
     break;
    } else
     fprintf(f, ", ");
   }
  }
  for (i=b->ins; i<&b->ins[b->nins]; i++) {
   fprintf(f, "\t");
   if (!req(i->to, (Ref){RTmp, 0})) {
    printref(i->to, fn, f);
    fprintf(f, " =%c ", ktoc[i->cls]);
   }
   ((void)0);
   fprintf(f, "%s", optab[i->op].name);
   if (req(i->to, (Ref){RTmp, 0}))
    switch (i->op) {
    case Oarg:
    case Oswap:
    case Oxcmp:
    case Oacmp:
    case Oacmn:
    case Oafcmp:
    case Oxtest:
    case Oxdiv:
    case Oxidiv:
     fputc(ktoc[i->cls], f);
    }
   if (!req(i->arg[0], (Ref){RTmp, 0})) {
    fprintf(f, " ");
    printref(i->arg[0], fn, f);
   }
   if (!req(i->arg[1], (Ref){RTmp, 0})) {
    fprintf(f, ", ");
    printref(i->arg[1], fn, f);
   }
   fprintf(f, "\n");
  }
  switch (b->jmp.type) {
  case Jret0:
  case Jretsb:
  case Jretub:
  case Jretsh:
  case Jretuh:
  case Jretw:
  case Jretl:
  case Jrets:
  case Jretd:
  case Jretc:
   fprintf(f, "\t%s", jtoa[b->jmp.type]);
   if (b->jmp.type != Jret0 || !req(b->jmp.arg, (Ref){RTmp, 0})) {
    fprintf(f, " ");
    printref(b->jmp.arg, fn, f);
   }
   if (b->jmp.type == Jretc)
    fprintf(f, ", :%s", typ[fn->retty].name);
   fprintf(f, "\n");
   break;
  case Jhlt:
   fprintf(f, "\thlt\n");
   break;
  case Jjmp:
   if (b->s1 != b->link)
    fprintf(f, "\tjmp @%s\n", b->s1->name);
   break;
  default:
   fprintf(f, "\t%s ", jtoa[b->jmp.type]);
   if (b->jmp.type == Jjnz) {
    printref(b->jmp.arg, fn, f);
    fprintf(f, ", ");
   }
   ((void)0);
   fprintf(f, "@%s, @%s\n", b->s1->name, b->s2->name);
   break;
  }
 }
 fprintf(f, "}\n");
}
