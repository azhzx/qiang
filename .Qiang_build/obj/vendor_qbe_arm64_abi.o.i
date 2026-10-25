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

typedef struct Abi Abi;
typedef struct Class Class;
typedef struct Insl Insl;
typedef struct Params Params;
enum {
 Cstk = 1,
 Cptr = 2,
};
struct Class {
 char class;
 char ishfa;
 struct {
  char base;
  uchar size;
 } hfa;
 uint size;
 uint align;
 Typ *t;
 uchar nreg;
 uchar ngp;
 uchar nfp;
 int reg[4];
 int cls[4];
};
struct Insl {
 Ins i;
 Insl *link;
};
struct Params {
 uint ngp;
 uint nfp;
 uint stk;
};
static int gpreg[12] = {R0, R1, R2, R3, R4, R5, R6, R7};
static int fpreg[12] = {V0, V1, V2, V3, V4, V5, V6, V7};
static int store[] = {
 [Kw] = Ostorew, [Kl] = Ostorel,
 [Ks] = Ostores, [Kd] = Ostored
};
static int
isfloatv(Typ *t, char *cls)
{
 Field *f;
 uint n;
 for (n=0; n<t->nunion; n++)
  for (f=t->fields[n]; f->type != FEnd; f++)
   switch (f->type) {
   case Fs:
    if (*cls == Kd)
     return 0;
    *cls = Ks;
    break;
   case Fd:
    if (*cls == Ks)
     return 0;
    *cls = Kd;
    break;
   case FTyp:
    if (isfloatv(&typ[f->len], cls))
     break;
   default:
    return 0;
   }
 return 1;
}
static void
typclass(Class *c, Typ *t, int *gp, int *fp)
{
 uint64_t sz, hfasz;
 uint n;
 sz = (t->size + 7) & -8;
 c->t = t;
 c->class = 0;
 c->ngp = 0;
 c->nfp = 0;
 c->align = 8;
 if (t->align > 3)
  err("alignments larger than 8 are not supported");
 c->size = sz;
 c->hfa.base = Kx;
 c->ishfa = isfloatv(t, &c->hfa.base);
 hfasz = t->size/(((c->hfa.base)&1) ? 8 : 4);
 c->ishfa &= !t->isdark && hfasz <= 4;
 c->hfa.size = hfasz;
 if (c->ishfa) {
  for (n=0; n<hfasz; n++, c->nfp++) {
   c->reg[n] = *fp++;
   c->cls[n] = c->hfa.base;
  }
  c->nreg = n;
 }
 else if (t->isdark || sz > 16 || sz == 0) {
  c->class |= Cptr;
  c->size = 8;
  c->ngp = 1;
  *c->reg = *gp;
  *c->cls = Kl;
 }
 else {
  for (n=0; n<sz/8; n++, c->ngp++) {
   c->reg[n] = *gp++;
   c->cls[n] = Kl;
  }
  c->nreg = n;
 }
}
static void
sttmps(Ref tmp[], int cls[], uint nreg, Ref mem, Fn *fn)
{
 uint n;
 uint64_t off;
 Ref r;
 ((void)0);
 off = 0;
 for (n=0; n<nreg; n++) {
  tmp[n] = newtmp("abi", cls[n], fn);
  r = newtmp("abi", Kl, fn);
  emit(store[cls[n]], 0, (Ref){RTmp, 0}, tmp[n], r);
  emit(Oadd, Kl, r, mem, getcon(off, fn));
  off += ((cls[n])&1) ? 8 : 4;
 }
}
static void
ldregs(int reg[], int cls[], int n, Ref mem, Fn *fn)
{
 int i;
 uint64_t off;
 Ref r;
 off = 0;
 for (i=0; i<n; i++) {
  r = newtmp("abi", Kl, fn);
  emit(Oload, cls[i], (Ref){RTmp, reg[i]}, r, (Ref){RTmp, 0});
  emit(Oadd, Kl, r, mem, getcon(off, fn));
  off += ((cls[i])&1) ? 8 : 4;
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
  typclass(&cr, &typ[fn->retty], gpreg, fpreg);
  if (cr.class & Cptr) {
   ((void)0);
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (cr.t->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, r, fn->retr);
   cty = 0;
  } else {
   ldregs(cr.reg, cr.cls, cr.nreg, r, fn);
   cty = (cr.nfp << 2) | cr.ngp;
  }
 } else {
  k = j - Jretw;
  if (((k)>>1) == 0) {
   emit(Ocopy, k, (Ref){RTmp, R0}, r, (Ref){RTmp, 0});
   cty = 1;
  } else {
   emit(Ocopy, k, (Ref){RTmp, V0}, r, (Ref){RTmp, 0});
   cty = 1 << 2;
  }
 }
 b->jmp.arg = (Ref){RCall, cty};
}
static int
argsclass(Ins *i0, Ins *i1, Class *carg)
{
 int va, envc, ngp, nfp, *gp, *fp;
 Class *c;
 Ins *i;
 va = 0;
 envc = 0;
 gp = gpreg;
 fp = fpreg;
 ngp = 8;
 nfp = 8;
 for (i=i0, c=carg; i<i1; i++, c++)
  switch (i->op) {
  case Oargsb:
  case Oargub:
  case Oparsb:
  case Oparub:
   c->size = 1;
   goto Scalar;
  case Oargsh:
  case Oarguh:
  case Oparsh:
  case Oparuh:
   c->size = 2;
   goto Scalar;
  case Opar:
  case Oarg:
   c->size = 8;
   if (T.apple && !((i->cls)&1))
    c->size = 4;
  Scalar:
   c->align = c->size;
   *c->cls = i->cls;
   if (va) {
    c->class |= Cstk;
    c->size = 8;
    c->align = 8;
    break;
   }
   if (((i->cls)>>1) == 0 && ngp > 0) {
    ngp--;
    *c->reg = *gp++;
    break;
   }
   if (((i->cls)>>1) == 1 && nfp > 0) {
    nfp--;
    *c->reg = *fp++;
    break;
   }
   c->class |= Cstk;
   break;
  case Oparc:
  case Oargc:
   typclass(c, &typ[i->arg[0].val], gp, fp);
   if (c->ngp <= ngp) {
    if (c->nfp <= nfp) {
     ngp -= c->ngp;
     nfp -= c->nfp;
     gp += c->ngp;
     fp += c->nfp;
     break;
    } else
     nfp = 0;
   } else
    ngp = 0;
   c->class |= Cstk;
   break;
  case Opare:
  case Oarge:
   *c->reg = R9;
   *c->cls = Kl;
   envc = 1;
   break;
  case Oargv:
   va = T.apple != 0;
   break;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/abi.c", "unreachable");
  }
 return envc << 14 | (gp-gpreg) << 5 | (fp-fpreg) << 9;
}
bits
arm64_retregs(Ref r, int p[2])
{
 bits b;
 int ngp, nfp;
 ((void)0);
 ngp = r.val & 3;
 nfp = (r.val >> 2) & 7;
 if (p) {
  p[0] = ngp;
  p[1] = nfp;
 }
 b = 0;
 while (ngp--)
  b |= ((bits)1 << (R0+ngp));
 while (nfp--)
  b |= ((bits)1 << (V0+nfp));
 return b;
}
bits
arm64_argregs(Ref r, int p[2])
{
 bits b;
 int ngp, nfp, x8, x9;
 ((void)0);
 ngp = (r.val >> 5) & 15;
 nfp = (r.val >> 9) & 15;
 x8 = (r.val >> 13) & 1;
 x9 = (r.val >> 14) & 1;
 if (p) {
  p[0] = ngp + x8 + x9;
  p[1] = nfp;
 }
 b = 0;
 while (ngp--)
  b |= ((bits)1 << (R0+ngp));
 while (nfp--)
  b |= ((bits)1 << (V0+nfp));
 return b | ((bits)x8 << R8) | ((bits)x9 << R9);
}
static void
stkblob(Ref r, Class *c, Fn *fn, Insl **ilp)
{
 Insl *il;
 int al;
 uint64_t sz;
 il = alloc(sizeof *il);
 al = c->t->align - 2;
 if (al < 0)
  al = 0;
 sz = c->class & Cptr ? c->t->size : c->size;
 il->i = (Ins){Oalloc+al, Kl, r, {getcon(sz, fn)}};
 il->link = *ilp;
 *ilp = il;
}
static uint
align(uint x, uint al)
{
 return (x + al-1) & -al;
}
static void
selcall(Fn *fn, Ins *i0, Ins *i1, Insl **ilp)
{
 Ins *i;
 Class *ca, *c, cr;
 int op, cty;
 uint n, stk, off;;
 Ref r, rstk, tmp[4];
 ca = alloc((i1-i0) * sizeof ca[0]);
 cty = argsclass(i0, i1, ca);
 stk = 0;
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (c->class & Cptr) {
   i->arg[0] = newtmp("abi", Kl, fn);
   stkblob(i->arg[0], c, fn, ilp);
   i->op = Oarg;
  }
  if (c->class & Cstk) {
   stk = align(stk, c->align);
   stk += c->size;
  }
 }
 stk = align(stk, 16);
 rstk = getcon(stk, fn);
 if (stk)
  emit(Oadd, Kl, (Ref){RTmp, SP}, (Ref){RTmp, SP}, rstk);
 if (!req(i1->arg[1], (Ref){RTmp, 0})) {
  typclass(&cr, &typ[i1->arg[1].val], gpreg, fpreg);
  stkblob(i1->to, &cr, fn, ilp);
  cty |= (cr.nfp << 2) | cr.ngp;
  if (cr.class & Cptr) {
   cty |= 1 << 13 | 1;
   emit(Ocopy, Kw, (Ref){RTmp, 0}, (Ref){RTmp, R0}, (Ref){RTmp, 0});
  } else {
   sttmps(tmp, cr.cls, cr.nreg, i1->to, fn);
   for (n=0; n<cr.nreg; n++) {
    r = (Ref){RTmp, cr.reg[n]};
    emit(Ocopy, cr.cls[n], tmp[n], r, (Ref){RTmp, 0});
   }
  }
 } else {
  if (((i1->cls)>>1) == 0) {
   emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, R0}, (Ref){RTmp, 0});
   cty |= 1;
  } else {
   emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, V0}, (Ref){RTmp, 0});
   cty |= 1 << 2;
  }
 }
 emit(Ocall, 0, (Ref){RTmp, 0}, i1->arg[0], (Ref){RCall, cty});
 if (cty & (1 << 13))
  emit(Ocopy, Kl, (Ref){RTmp, R8}, i1->to, (Ref){RTmp, 0});
 for (i=i0, c=ca; i<i1; i++, c++) {
  if ((c->class & Cstk) != 0)
   continue;
  if (i->op == Oarg || i->op == Oarge || ((unsigned)(i->op) - Oargsb <= Oarguh - Oargsb))
   emit(Ocopy, *c->cls, (Ref){RTmp, *c->reg}, i->arg[0], (Ref){RTmp, 0});
  if (i->op == Oargc)
   ldregs(c->reg, c->cls, c->nreg, i->arg[1], fn);
 }
 off = 0;
 for (i=i0, c=ca; i<i1; i++, c++) {
  if ((c->class & Cstk) == 0)
   continue;
  off = align(off, c->align);
  r = newtmp("abi", Kl, fn);
  if (i->op == Oarg || ((unsigned)(i->op) - Oargsb <= Oarguh - Oargsb)) {
   switch (c->size) {
   case 1: op = Ostoreb; break;
   case 2: op = Ostoreh; break;
   case 4:
   case 8: op = store[*c->cls]; break;
   default: die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/abi.c", "unreachable");
   }
   emit(op, 0, (Ref){RTmp, 0}, i->arg[0], r);
  } else {
   ((void)0);
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (c->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, i->arg[1], r);
  }
  emit(Oadd, Kl, r, (Ref){RTmp, SP}, getcon(off, fn));
  off += c->size;
 }
 if (stk)
  emit(Osub, Kl, (Ref){RTmp, SP}, (Ref){RTmp, SP}, rstk);
 for (i=i0, c=ca; i<i1; i++, c++)
  if (c->class & Cptr) {
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (c->t->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, i->arg[1], i->arg[0]);
  }
}
static Params
selpar(Fn *fn, Ins *i0, Ins *i1)
{
 Class *ca, *c, cr;
 Insl *il;
 Ins *i;
 int op, n, cty;
 uint off;
 Ref r, tmp[16], *t;
 ca = alloc((i1-i0) * sizeof ca[0]);
 curi = &insb[NIns];
 cty = argsclass(i0, i1, ca);
 fn->reg = arm64_argregs((Ref){RCall, cty}, 0);
 il = 0;
 t = tmp;
 for (i=i0, c=ca; i<i1; i++, c++) {
  if (i->op != Oparc || (c->class & (Cptr|Cstk)))
   continue;
  sttmps(t, c->cls, c->nreg, i->to, fn);
  stkblob(i->to, c, fn, &il);
  t += c->nreg;
 }
 for (; il; il=il->link)
  emiti(il->i);
 if (fn->retty >= 0) {
  typclass(&cr, &typ[fn->retty], gpreg, fpreg);
  if (cr.class & Cptr) {
   fn->retr = newtmp("abi", Kl, fn);
   emit(Ocopy, Kl, fn->retr, (Ref){RTmp, R8}, (Ref){RTmp, 0});
   fn->reg |= ((bits)1 << (R8));
  }
 }
 t = tmp;
 off = 0;
 for (i=i0, c=ca; i<i1; i++, c++)
  if (i->op == Oparc && !(c->class & Cptr)) {
   if (c->class & Cstk) {
    off = align(off, c->align);
    fn->tmp[i->to.val].slot = -(off+2);
    off += c->size;
   } else
    for (n=0; n<c->nreg; n++) {
     r = (Ref){RTmp, c->reg[n]};
     emit(Ocopy, c->cls[n], *t++, r, (Ref){RTmp, 0});
    }
  } else if (c->class & Cstk) {
   off = align(off, c->align);
   if (((unsigned)(i->op) - Oparsb <= Oparuh - Oparsb))
    op = Oloadsb + (i->op - Oparsb);
   else
    op = Oload;
   emit(op, *c->cls, i->to, (Ref){RSlot, (-(off+2))&0x1fffffff}, (Ref){RTmp, 0});
   off += c->size;
  } else {
   emit(Ocopy, *c->cls, i->to, (Ref){RTmp, *c->reg}, (Ref){RTmp, 0});
  }
 return (Params){
  .stk = align(off, 8),
  .ngp = (cty >> 5) & 15,
  .nfp = (cty >> 9) & 15
 };
}
static Blk *
split(Fn *fn, Blk *b)
{
 Blk *bn;
 ++fn->nblk;
 bn = newblk();
 idup(bn, curi, &insb[NIns]-curi);
 curi = &insb[NIns];
 bn->visit = ++b->visit;
 bn->name = strf(PFn, "%s.%d", b->name, b->visit);
 bn->loop = b->loop;
 bn->link = b->link;
 b->link = bn;
 return bn;
}
static void
chpred(Blk *b, Blk *bp, Blk *bp1)
{
 Phi *p;
 uint a;
 for (p=b->phi; p; p=p->link) {
  for (a=0; p->blk[a]!=bp; a++)
   ((void)0);
  p->blk[a] = bp1;
 }
}
static void
apple_selvaarg(Fn *fn, Blk *b, Ins *i)
{
 Ref ap, stk, stk8, c8;
 (void)b;
 c8 = getcon(8, fn);
 ap = i->arg[0];
 stk8 = newtmp("abi", Kl, fn);
 stk = newtmp("abi", Kl, fn);
 emit(Ostorel, 0, (Ref){RTmp, 0}, stk8, ap);
 emit(Oadd, Kl, stk8, stk, c8);
 emit(Oload, i->cls, i->to, stk, (Ref){RTmp, 0});
 emit(Oload, Kl, stk, ap, (Ref){RTmp, 0});
}
static void
arm64_selvaarg(Fn *fn, Blk *b, Ins *i)
{
 Ref loc, lreg, lstk, nr, r0, r1, c8, c16, c24, c28, ap;
 Blk *b0, *bstk, *breg;
 int isgp;
 c8 = getcon(8, fn);
 c16 = getcon(16, fn);
 c24 = getcon(24, fn);
 c28 = getcon(28, fn);
 ap = i->arg[0];
 isgp = ((i->cls)>>1) == 0;
 loc = newtmp("abi", Kl, fn);
 emit(Oload, i->cls, i->to, loc, (Ref){RTmp, 0});
 b0 = split(fn, b);
 b0->jmp = b->jmp;
 b0->s1 = b->s1;
 b0->s2 = b->s2;
 if (b->s1)
  chpred(b->s1, b, b0);
 if (b->s2 && b->s2 != b->s1)
  chpred(b->s2, b, b0);
 lreg = newtmp("abi", Kl, fn);
 nr = newtmp("abi", Kl, fn);
 r0 = newtmp("abi", Kw, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorew, Kw, (Ref){RTmp, 0}, r0, r1);
 emit(Oadd, Kl, r1, ap, isgp ? c24 : c28);
 emit(Oadd, Kw, r0, nr, isgp ? c8 : c16);
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Oadd, Kl, lreg, r1, nr);
 emit(Oload, Kl, r1, r0, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, isgp ? c8 : c16);
 breg = split(fn, b);
 breg->jmp.type = Jjmp;
 breg->s1 = b0;
 lstk = newtmp("abi", Kl, fn);
 r0 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r0, ap);
 emit(Oadd, Kl, r0, lstk, c8);
 emit(Oload, Kl, lstk, ap, (Ref){RTmp, 0});
 bstk = split(fn, b);
 bstk->jmp.type = Jjmp;
 bstk->s1 = b0;
 b0->phi = alloc(sizeof *b0->phi);
 *b0->phi = (Phi){
  .cls = Kl, .to = loc,
  .narg = 2,
  .blk = vnew(2, sizeof b0->phi->blk[0], PFn),
  .arg = vnew(2, sizeof b0->phi->arg[0], PFn),
 };
 b0->phi->blk[0] = bstk;
 b0->phi->blk[1] = breg;
 b0->phi->arg[0] = lstk;
 b0->phi->arg[1] = lreg;
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kw, fn);
 b->jmp.type = Jjnz;
 b->jmp.arg = r1;
 b->s1 = breg;
 b->s2 = bstk;
 emit(Ocmpw+Cislt, Kw, r1, nr, (Ref){RCon, 1});
 emit(Oloadsw, Kl, nr, r0, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, isgp ? c24 : c28);
}
static void
apple_selvastart(Fn *fn, Params p, Ref ap)
{
 Ref off, stk, arg;
 off = getcon(p.stk, fn);
 stk = newtmp("abi", Kl, fn);
 arg = newtmp("abi", Kl, fn);
 emit(Ostorel, 0, (Ref){RTmp, 0}, arg, ap);
 emit(Oadd, Kl, arg, stk, off);
 emit(Oaddr, Kl, stk, (Ref){RSlot, (-1)&0x1fffffff}, (Ref){RTmp, 0});
}
static void
arm64_selvastart(Fn *fn, Params p, Ref ap)
{
 Ref r0, r1, rsave;
 rsave = newtmp("abi", Kl, fn);
 r0 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r0, ap);
 emit(Oadd, Kl, r0, rsave, getcon(p.stk + 192, fn));
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r1, r0);
 emit(Oadd, Kl, r1, rsave, getcon(64, fn));
 emit(Oadd, Kl, r0, ap, getcon(8, fn));
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r1, r0);
 emit(Oadd, Kl, r1, rsave, getcon(192, fn));
 emit(Oaddr, Kl, rsave, (Ref){RSlot, (-1)&0x1fffffff}, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, getcon(16, fn));
 r0 = newtmp("abi", Kl, fn);
 emit(Ostorew, Kw, (Ref){RTmp, 0}, getcon((p.ngp-8)*8, fn), r0);
 emit(Oadd, Kl, r0, ap, getcon(24, fn));
 r0 = newtmp("abi", Kl, fn);
 emit(Ostorew, Kw, (Ref){RTmp, 0}, getcon((p.nfp-8)*16, fn), r0);
 emit(Oadd, Kl, r0, ap, getcon(28, fn));
}
void
arm64_abi(Fn *fn)
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
    if (T.apple)
     apple_selvastart(fn, p, i->arg[0]);
    else
     arm64_selvastart(fn, p, i->arg[0]);
    break;
   case Ovaarg:
    if (T.apple)
     apple_selvaarg(fn, b, i);
    else
     arm64_selvaarg(fn, b, i);
    break;
   case Oarg:
   case Oargc:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/arm64/abi.c", "unreachable");
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
void
apple_extsb(Fn *fn)
{
 Blk *b;
 Ins *i0, *i1, *i;
 int j, op;
 Ref r;
 for (b=fn->start; b; b=b->link) {
  curi = &insb[NIns];
  j = b->jmp.type;
  if (((unsigned)(j) - Jretsb <= Jretuh - Jretsb)) {
   r = newtmp("abi", Kw, fn);
   op = Oextsb + (j - Jretsb);
   emit(op, Kw, r, b->jmp.arg, (Ref){RTmp, 0});
   b->jmp.arg = r;
   b->jmp.type = Jretw;
  }
  for (i=&b->ins[b->nins]; i>b->ins;) {
   emiti(*--i);
   if (i->op != Ocall)
    continue;
   for (i0=i1=i; i0>b->ins; i0--)
    if (!((unsigned)((i0-1)->op) - Oarg <= Oargv - Oarg))
     break;
   for (i=i1; i>i0;) {
    emiti(*--i);
    if (((unsigned)(i->op) - Oargsb <= Oarguh - Oargsb)) {
     i->to = newtmp("abi", Kl, fn);
     curi->arg[0] = i->to;
    }
   }
   for (i=i1; i>i0;)
    if (((unsigned)((--i)->op) - Oargsb <= Oarguh - Oargsb)) {
     op = Oextsb + (i->op - Oargsb);
     emit(op, Kw, i->to, i->arg[0], (Ref){RTmp, 0});
    }
  }
  idup(b, curi, &insb[NIns]-curi);
 }
 if (debug['A']) {
  fprintf(__stderrp, "\n> After Apple pre-ABI:\n");
  printfn(fn, __stderrp);
 }
}
