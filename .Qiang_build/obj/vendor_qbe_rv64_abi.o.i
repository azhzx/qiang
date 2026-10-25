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
typedef struct Class Class;
typedef struct Insl Insl;
typedef struct Params Params;
enum {
 Cptr = 1,
 Cstk1 = 2,
 Cstk2 = 4,
 Cstk = Cstk1 | Cstk2,
 Cfpint = 8,
};
struct Class {
 char class;
 Typ *type;
 int reg[2];
 int cls[2];
 int off[2];
 char ngp;
 char nfp;
 char nreg;
};
struct Insl {
 Ins i;
 Insl *link;
};
struct Params {
 int ngp;
 int nfp;
 int stk;
};
static int gpreg[10] = {A0, A1, A2, A3, A4, A5, A6, A7};
static int fpreg[10] = {FA0, FA1, FA2, FA3, FA4, FA5, FA6, FA7};
bits
rv64_retregs(Ref r, int p[2])
{
 bits b;
 int ngp, nfp;
 ((void)0);
 ngp = r.val & 3;
 nfp = (r.val >> 2) & 3;
 if (p) {
  p[0] = ngp;
  p[1] = nfp;
 }
 b = 0;
 while (ngp--)
  b |= ((bits)1 << (A0+ngp));
 while (nfp--)
  b |= ((bits)1 << (FA0+nfp));
 return b;
}
bits
rv64_argregs(Ref r, int p[2])
{
 bits b;
 int ngp, nfp, t5;
 ((void)0);
 ngp = (r.val >> 4) & 15;
 nfp = (r.val >> 8) & 15;
 t5 = (r.val >> 12) & 1;
 if (p) {
  p[0] = ngp + t5;
  p[1] = nfp;
 }
 b = 0;
 while (ngp--)
  b |= ((bits)1 << (A0+ngp));
 while (nfp--)
  b |= ((bits)1 << (FA0+nfp));
 return b | ((bits)t5 << T5);
}
static int
fpstruct(Typ *t, int off, Class *c)
{
 Field *f;
 int n;
 if (t->isunion)
  return -1;
 for (f=*t->fields; f->type != FEnd; f++)
  if (f->type == FPad)
   off += f->len;
  else if (f->type == FTyp) {
   if (fpstruct(&typ[f->len], off, c) == -1)
    return -1;
  }
  else {
   n = c->nfp + c->ngp;
   if (n == 2)
    return -1;
   switch (f->type) {
   default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/abi.c", "unreachable");
   case Fb:
   case Fh:
   case Fw: c->cls[n] = Kw; c->ngp++; break;
   case Fl: c->cls[n] = Kl; c->ngp++; break;
   case Fs: c->cls[n] = Ks; c->nfp++; break;
   case Fd: c->cls[n] = Kd; c->nfp++; break;
   }
   c->off[n] = off;
   off += f->len;
  }
 return c->nfp;
}
static void
typclass(Class *c, Typ *t, int fpabi, int *gp, int *fp)
{
 uint n;
 int i;
 c->type = t;
 c->class = 0;
 c->ngp = 0;
 c->nfp = 0;
 if (t->align > 4)
  err("alignments larger than 16 are not supported");
 if (t->isdark || t->size > 16 || t->size == 0) {
  c->class |= Cptr;
  *c->cls = Kl;
  *c->off = 0;
  c->ngp = 1;
 }
 else if (!fpabi || fpstruct(t, 0, c) <= 0) {
  for (n=0; 8*n<t->size; n++) {
   c->cls[n] = Kl;
   c->off[n] = 8*n;
  }
  c->nfp = 0;
  c->ngp = n;
 }
 c->nreg = c->nfp + c->ngp;
 for (i=0; i<c->nreg; i++)
  if (((c->cls[i])>>1) == 0)
   c->reg[i] = *gp++;
  else
   c->reg[i] = *fp++;
}
static void
sttmps(Ref tmp[], int ntmp, Class *c, Ref mem, Fn *fn)
{
 static int st[] = {
  [Kw] = Ostorew, [Kl] = Ostorel,
  [Ks] = Ostores, [Kd] = Ostored
 };
 int i;
 Ref r;
 ((void)0);
 ((void)0);
 for (i=0; i<ntmp; i++) {
  tmp[i] = newtmp("abi", c->cls[i], fn);
  r = newtmp("abi", Kl, fn);
  emit(st[c->cls[i]], 0, (Ref){RTmp, 0}, tmp[i], r);
  emit(Oadd, Kl, r, mem, getcon(c->off[i], fn));
 }
}
static void
ldregs(Class *c, Ref mem, Fn *fn)
{
 int i;
 Ref r;
 for (i=0; i<c->nreg; i++) {
  r = newtmp("abi", Kl, fn);
  emit(Oload, c->cls[i], (Ref){RTmp, c->reg[i]}, r, (Ref){RTmp, 0});
  emit(Oadd, Kl, r, mem, getcon(c->off[i], fn));
 }
}
static void
selret(Blk *b, Fn *fn)
{
 int j, k, cty;
 Ref r;
 Class cr;
 j = b->jmp.type;
 if (!((unsigned)(j) - Jretw <= Jret0 - Jretw) || j == Jret0)
  return;
 r = b->jmp.arg;
 b->jmp.type = Jret0;
 if (j == Jretc) {
  typclass(&cr, &typ[fn->retty], 1, gpreg, fpreg);
  if (cr.class & Cptr) {
   ((void)0);
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (cr.type->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, r, fn->retr);
   cty = 0;
  } else {
   ldregs(&cr, r, fn);
   cty = (cr.nfp << 2) | cr.ngp;
  }
 } else {
  k = j - Jretw;
  if (((k)>>1) == 0) {
   emit(Ocopy, k, (Ref){RTmp, A0}, r, (Ref){RTmp, 0});
   cty = 1;
  } else {
   emit(Ocopy, k, (Ref){RTmp, FA0}, r, (Ref){RTmp, 0});
   cty = 1 << 2;
  }
 }
 b->jmp.arg = (Ref){RCall, cty};
}
static int
argsclass(Ins *i0, Ins *i1, Class *carg, int retptr)
{
 int ngp, nfp, *gp, *fp, vararg, envc;
 Class *c;
 Typ *t;
 Ins *i;
 gp = gpreg;
 fp = fpreg;
 ngp = 8;
 nfp = 8;
 vararg = 0;
 envc = 0;
 if (retptr) {
  gp++;
  ngp--;
 }
 for (i=i0, c=carg; i<i1; i++, c++) {
  switch (i->op) {
  case Opar:
  case Oarg:
   *c->cls = i->cls;
   if (!vararg && ((i->cls)>>1) == 1 && nfp > 0) {
    nfp--;
    *c->reg = *fp++;
   } else if (ngp > 0) {
    if (((i->cls)>>1) == 1)
     c->class |= Cfpint;
    ngp--;
    *c->reg = *gp++;
   } else
    c->class |= Cstk1;
   break;
  case Oargv:
   vararg = 1;
   break;
  case Oparc:
  case Oargc:
   t = &typ[i->arg[0].val];
   typclass(c, t, 1, gp, fp);
   if (c->nfp > 0)
   if (c->nfp >= nfp || c->ngp >= ngp)
    typclass(c, t, 0, gp, fp);
   ((void)0);
   if (c->ngp <= ngp) {
    ngp -= c->ngp;
    nfp -= c->nfp;
    gp += c->ngp;
    fp += c->nfp;
   } else if (ngp > 0) {
    ((void)0);
    ((void)0);
    c->class |= Cstk2;
    c->nreg = 1;
    ngp--;
    gp++;
   } else {
    c->class |= Cstk1;
    if (c->nreg > 1)
     c->class |= Cstk2;
    c->nreg = 0;
   }
   break;
  case Opare:
  case Oarge:
   *c->reg = T5;
   *c->cls = Kl;
   envc = 1;
   break;
  }
 }
 return envc << 12 | (gp-gpreg) << 4 | (fp-fpreg) << 8;
}
static void
stkblob(Ref r, Typ *t, Fn *fn, Insl **ilp)
{
 Insl *il;
 int al;
 uint64_t sz;
 il = alloc(sizeof *il);
 al = t->align - 2;
 if (al < 0)
  al = 0;
 sz = (t->size + 7) & ~7;
 il->i = (Ins){Oalloc+al, Kl, r, {getcon(sz, fn)}};
 il->link = *ilp;
 *ilp = il;
}
static void
selcall(Fn *fn, Ins *i0, Ins *i1, Insl **ilp)
{
 Ins *i;
 Class *ca, *c, cr;
 int j, k, cty;
 uint64_t stk, off;
 Ref r, r1, r2, tmp[2];
 ca = alloc((i1-i0) * sizeof ca[0]);
 cr.class = 0;
 if (!req(i1->arg[1], (Ref){RTmp, 0}))
  typclass(&cr, &typ[i1->arg[1].val], 1, gpreg, fpreg);
 cty = argsclass(i0, i1, ca, cr.class & Cptr);
 stk = 0;
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (i->op == Oargv)
   continue;
  if (c->class & Cptr) {
   i->arg[0] = newtmp("abi", Kl, fn);
   stkblob(i->arg[0], c->type, fn, ilp);
   i->op = Oarg;
  }
  if (c->class & Cstk1)
   stk += 8;
  if (c->class & Cstk2)
   stk += 8;
 }
 stk += stk & 15;
 if (stk)
  emit(Osalloc, Kl, (Ref){RTmp, 0}, getcon(-stk, fn), (Ref){RTmp, 0});
 if (!req(i1->arg[1], (Ref){RTmp, 0})) {
  stkblob(i1->to, cr.type, fn, ilp);
  cty |= (cr.nfp << 2) | cr.ngp;
  if (cr.class & Cptr)
   emit(Ocopy, Kw, (Ref){RTmp, 0}, (Ref){RTmp, A0}, (Ref){RTmp, 0});
  else {
   sttmps(tmp, cr.nreg, &cr, i1->to, fn);
   for (j=0; j<cr.nreg; j++) {
    r = (Ref){RTmp, cr.reg[j]};
    emit(Ocopy, cr.cls[j], tmp[j], r, (Ref){RTmp, 0});
   }
  }
 } else if (((i1->cls)>>1) == 0) {
  emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, A0}, (Ref){RTmp, 0});
  cty |= 1;
 } else {
  emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, FA0}, (Ref){RTmp, 0});
  cty |= 1 << 2;
 }
 emit(Ocall, 0, (Ref){RTmp, 0}, i1->arg[0], (Ref){RCall, cty});
 if (cr.class & Cptr)
  emit(Ocopy, Kl, (Ref){RTmp, A0}, i1->to, (Ref){RTmp, 0});
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (i->op == Oargv || c->class & Cstk1)
   continue;
  if (i->op == Oargc) {
   ldregs(c, i->arg[1], fn);
  } else if (c->class & Cfpint) {
   k = ((*c->cls)&1) ? Kl : Kw;
   r = newtmp("abi", k, fn);
   emit(Ocopy, k, (Ref){RTmp, *c->reg}, r, (Ref){RTmp, 0});
   *c->reg = r.val;
  } else {
   emit(Ocopy, *c->cls, (Ref){RTmp, *c->reg}, i->arg[0], (Ref){RTmp, 0});
  }
 }
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (c->class & Cfpint) {
   k = ((*c->cls)&1) ? Kl : Kw;
   emit(Ocast, k, (Ref){RTmp, *c->reg}, i->arg[0], (Ref){RTmp, 0});
  }
  if (c->class & Cptr) {
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (c->type->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, i->arg[1], i->arg[0]);
  }
 }
 if (!stk)
  return;
 off = 0;
 r = newtmp("abi", Kl, fn);
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (i->op == Oargv || !(c->class & Cstk))
   continue;
  if (i->op == Oarg) {
   r1 = newtmp("abi", Kl, fn);
   emit(Ostorew+i->cls, Kw, (Ref){RTmp, 0}, i->arg[0], r1);
   if (i->cls == Kw) {
    curi->op = Ostorel;
    curi->arg[0] = newtmp("abi", Kl, fn);
    emit(Oextsw, Kl, curi->arg[0], i->arg[0], (Ref){RTmp, 0});
   }
   emit(Oadd, Kl, r1, r, getcon(off, fn));
   off += 8;
  }
  if (i->op == Oargc) {
   if (c->class & Cstk1) {
    r1 = newtmp("abi", Kl, fn);
    r2 = newtmp("abi", Kl, fn);
    emit(Ostorel, 0, (Ref){RTmp, 0}, r2, r1);
    emit(Oadd, Kl, r1, r, getcon(off, fn));
    emit(Oload, Kl, r2, i->arg[1], (Ref){RTmp, 0});
    off += 8;
   }
   if (c->class & Cstk2) {
    r1 = newtmp("abi", Kl, fn);
    r2 = newtmp("abi", Kl, fn);
    emit(Ostorel, 0, (Ref){RTmp, 0}, r2, r1);
    emit(Oadd, Kl, r1, r, getcon(off, fn));
    r1 = newtmp("abi", Kl, fn);
    emit(Oload, Kl, r2, r1, (Ref){RTmp, 0});
    emit(Oadd, Kl, r1, i->arg[1], getcon(8, fn));
    off += 8;
   }
  }
 }
 emit(Osalloc, Kl, r, getcon(stk, fn), (Ref){RTmp, 0});
}
static Params
selpar(Fn *fn, Ins *i0, Ins *i1)
{
 Class *ca, *c, cr;
 Insl *il;
 Ins *i;
 int j, k, s, cty, nt;
 Ref r, tmp[17], *t;
 ca = alloc((i1-i0) * sizeof ca[0]);
 cr.class = 0;
 curi = &insb[NIns];
 if (fn->retty >= 0) {
  typclass(&cr, &typ[fn->retty], 1, gpreg, fpreg);
  if (cr.class & Cptr) {
   fn->retr = newtmp("abi", Kl, fn);
   emit(Ocopy, Kl, fn->retr, (Ref){RTmp, A0}, (Ref){RTmp, 0});
  }
 }
 cty = argsclass(i0, i1, ca, cr.class & Cptr);
 fn->reg = rv64_argregs((Ref){RCall, cty}, 0);
 il = 0;
 t = tmp;
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (c->class & Cfpint) {
   r = i->to;
   k = *c->cls;
   *c->cls = ((k)&1) ? Kl : Kw;
   i->to = newtmp("abi", k, fn);
   emit(Ocast, k, r, i->to, (Ref){RTmp, 0});
  }
  if (i->op == Oparc)
  if (!(c->class & Cptr))
  if (c->nreg != 0) {
   nt = c->nreg;
   if (c->class & Cstk2) {
    c->cls[1] = Kl;
    c->off[1] = 8;
    ((void)0);
    nt = 2;
   }
   sttmps(t, nt, c, i->to, fn);
   stkblob(i->to, c->type, fn, &il);
   t += nt;
  }
 }
 for (; il; il=il->link)
  emiti(il->i);
 t = tmp;
 s = 2 + 8*fn->vararg;
 for (i=i0, c=ca; i<i1; i++, c++)
  if (i->op == Oparc && !(c->class & Cptr)) {
   if (c->nreg == 0) {
    fn->tmp[i->to.val].slot = -s;
    s += (c->class & Cstk2) ? 2 : 1;
    continue;
   }
   for (j=0; j<c->nreg; j++) {
    r = (Ref){RTmp, c->reg[j]};
    emit(Ocopy, c->cls[j], *t++, r, (Ref){RTmp, 0});
   }
   if (c->class & Cstk2) {
    emit(Oload, Kl, *t, (Ref){RSlot, (-s)&0x1fffffff}, (Ref){RTmp, 0});
    t++, s++;
   }
  } else if (c->class & Cstk1) {
   emit(Oload, *c->cls, i->to, (Ref){RSlot, (-s)&0x1fffffff}, (Ref){RTmp, 0});
   s++;
  } else {
   emit(Ocopy, *c->cls, i->to, (Ref){RTmp, *c->reg}, (Ref){RTmp, 0});
  }
 return (Params){
  .stk = s,
  .ngp = (cty >> 4) & 15,
  .nfp = (cty >> 8) & 15,
 };
}
static void
selvaarg(Fn *fn, Ins *i)
{
 Ref loc, newloc;
 loc = newtmp("abi", Kl, fn);
 newloc = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, newloc, i->arg[0]);
 emit(Oadd, Kl, newloc, loc, getcon(8, fn));
 emit(Oload, i->cls, i->to, loc, (Ref){RTmp, 0});
 emit(Oload, Kl, loc, i->arg[0], (Ref){RTmp, 0});
}
static void
selvastart(Fn *fn, Params p, Ref ap)
{
 Ref rsave;
 int s;
 rsave = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, rsave, ap);
 s = p.stk > 2 + 8 * fn->vararg ? p.stk : 2 + p.ngp;
 emit(Oaddr, Kl, rsave, (Ref){RSlot, (-s)&0x1fffffff}, (Ref){RTmp, 0});
}
void
rv64_abi(Fn *fn)
{
 Blk *b;
 Ins *i, *i0;
 Insl *il;
 int n0, n1, ioff;
 Params p;
 for (b=fn->start; b; b=b->link)
  b->visit = 0;
 for (b=fn->start, i=b->ins; i<&b->ins[b->nins]; i++)
  if (!((unsigned)(i->op) - Opar <= Opare - Opar))
   break;
 p = selpar(fn, b->ins, i);
 n0 = &insb[NIns] - curi;
 ioff = i - b->ins;
 n1 = b->nins - ioff;
 vgrow(&b->ins, n0+n1);
 icpy(b->ins+n0, b->ins+ioff, n1);
 icpy(b->ins, curi, n0);
 b->nins = n0+n1;
 il = 0;
 b = fn->start;
 do {
  if (!(b = b->link))
   b = fn->start;
  if (b->visit)
   continue;
  curi = &insb[NIns];
  selret(b, fn);
  for (i=&b->ins[b->nins]; i!=b->ins;)
   switch ((--i)->op) {
   default:
    emiti(*i);
    break;
   case Ocall:
    for (i0=i; i0>b->ins; i0--)
     if (!((unsigned)((i0-1)->op) - Oarg <= Oargv - Oarg))
      break;
    selcall(fn, i0, i, &il);
    i = i0;
    break;
   case Ovastart:
    selvastart(fn, p, i->arg[0]);
    break;
   case Ovaarg:
    selvaarg(fn, i);
    break;
   case Oarg:
   case Oargc:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rv64/abi.c", "unreachable");
   }
  if (b == fn->start)
   for (; il; il=il->link)
    emiti(il->i);
  idup(b, curi, &insb[NIns]-curi);
 } while (b != fn->start);
 if (debug['A']) {
  fprintf(__stderrp, "\n> After ABI lowering:\n");
  printfn(fn, __stderrp);
 }
}
