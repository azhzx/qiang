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

typedef struct AClass AClass;
typedef struct RAlloc RAlloc;
struct AClass {
 Typ *type;
 int inmem;
 int align;
 uint size;
 int cls[2];
 Ref ref[2];
};
struct RAlloc {
 Ins i;
 RAlloc *link;
};
static void
classify(AClass *a, Typ *t, uint s)
{
 Field *f;
 int *cls;
 uint n, s1;
 for (n=0, s1=s; n<t->nunion; n++, s=s1)
  for (f=t->fields[n]; f->type!=FEnd; f++) {
   ((void)0);
   cls = &a->cls[s/8];
   switch (f->type) {
   case FEnd:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/sysv.c", "unreachable");
   case FPad:
    s += f->len;
    break;
   case Fs:
   case Fd:
    if (*cls == Kx)
     *cls = Kd;
    s += f->len;
    break;
   case Fb:
   case Fh:
   case Fw:
   case Fl:
    *cls = Kl;
    s += f->len;
    break;
   case FTyp:
    classify(a, &typ[f->len], s);
    s += typ[f->len].size;
    break;
   }
  }
}
static void
typclass(AClass *a, Typ *t)
{
 uint sz, al;
 sz = t->size;
 al = 1u << t->align;
 if (al < 8)
  al = 8;
 sz = (sz + al-1) & -al;
 a->type = t;
 a->size = sz;
 a->align = t->align;
 if (t->isdark || sz > 16 || sz == 0) {
  a->inmem = 1;
  return;
 }
 a->cls[0] = Kx;
 a->cls[1] = Kx;
 a->inmem = 0;
 classify(a, t, 0);
}
static int
retr(Ref reg[2], AClass *aret)
{
 static int retreg[2][2] = {{RAX, RDX}, {XMM0, XMM0+1}};
 int n, k, ca, nr[2];
 nr[0] = nr[1] = 0;
 ca = 0;
 for (n=0; (uint)n*8<aret->size; n++) {
  k = ((aret->cls[n])>>1);
  reg[n] = (Ref){RTmp, retreg[k][nr[k]++]};
  ca += 1 << (2 * k);
 }
 return ca;
}
static void
selret(Blk *b, Fn *fn)
{
 int j, k, ca;
 Ref r, r0, reg[2];
 AClass aret;
 j = b->jmp.type;
 if (!((unsigned)(j) - Jretw <= Jret0 - Jretw) || j == Jret0)
  return;
 r0 = b->jmp.arg;
 b->jmp.type = Jret0;
 if (j == Jretc) {
  typclass(&aret, &typ[fn->retty]);
  if (aret.inmem) {
   ((void)0);
   emit(Ocopy, Kl, (Ref){RTmp, RAX}, fn->retr, (Ref){RTmp, 0});
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (aret.type->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, r0, fn->retr);
   ca = 1;
  } else {
   ca = retr(reg, &aret);
   if (aret.size > 8) {
    r = newtmp("abi", Kl, fn);
    emit(Oload, Kl, reg[1], r, (Ref){RTmp, 0});
    emit(Oadd, Kl, r, r0, getcon(8, fn));
   }
   emit(Oload, Kl, reg[0], r0, (Ref){RTmp, 0});
  }
 } else {
  k = j - Jretw;
  if (((k)>>1) == 0) {
   emit(Ocopy, k, (Ref){RTmp, RAX}, r0, (Ref){RTmp, 0});
   ca = 1;
  } else {
   emit(Ocopy, k, (Ref){RTmp, XMM0}, r0, (Ref){RTmp, 0});
   ca = 1 << 2;
  }
 }
 b->jmp.arg = (Ref){RCall, ca};
}
static int
argsclass(Ins *i0, Ins *i1, AClass *ac, int op, AClass *aret, Ref *env)
{
 int varc, envc, nint, ni, nsse, ns, n, *pn;
 AClass *a;
 Ins *i;
 if (aret && aret->inmem)
  nint = 5;
 else
  nint = 6;
 nsse = 8;
 varc = 0;
 envc = 0;
 for (i=i0, a=ac; i<i1; i++, a++)
  switch (i->op - op + Oarg) {
  case Oarg:
   if (((i->cls)>>1) == 0)
    pn = &nint;
   else
    pn = &nsse;
   if (*pn > 0) {
    --*pn;
    a->inmem = 0;
   } else
    a->inmem = 2;
   a->align = 3;
   a->size = 8;
   a->cls[0] = i->cls;
   break;
  case Oargc:
   n = i->arg[0].val;
   typclass(a, &typ[n]);
   if (a->inmem)
    continue;
   ni = ns = 0;
   for (n=0; (uint)n*8<a->size; n++)
    if (((a->cls[n])>>1) == 0)
     ni++;
    else
     ns++;
   if (nint >= ni && nsse >= ns) {
    nint -= ni;
    nsse -= ns;
   } else
    a->inmem = 1;
   break;
  case Oarge:
   envc = 1;
   if (op == Opar)
    *env = i->to;
   else
    *env = i->arg[0];
   break;
  case Oargv:
   varc = 1;
   break;
  default:
   die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/sysv.c", "unreachable");
  }
 if (varc && envc)
  err("sysv abi does not support variadic env calls");
 return ((varc|envc) << 12) | ((6-nint) << 4) | ((8-nsse) << 8);
}
int amd64_sysv_rsave[] = {
 RDI, RSI, RDX, RCX, R8, R9, R10, R11, RAX,
 XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6, XMM7,
 XMM8, XMM9, XMM10, XMM11, XMM12, XMM13, XMM14, -1
};
int amd64_sysv_rclob[] = {RBX, R12, R13, R14, R15, -1};
typedef char make_sure_sysv_arrays_ok[(sizeof amd64_sysv_rsave == (NGPS_SYSV+NFPS+1) * sizeof(int) && sizeof amd64_sysv_rclob == (NCLR_SYSV+1) * sizeof(int))?1:-1];
bits
amd64_sysv_retregs(Ref r, int p[2])
{
 bits b;
 int ni, nf;
 ((void)0);
 b = 0;
 ni = r.val & 3;
 nf = (r.val >> 2) & 3;
 if (ni >= 1)
  b |= ((bits)1 << (RAX));
 if (ni >= 2)
  b |= ((bits)1 << (RDX));
 if (nf >= 1)
  b |= ((bits)1 << (XMM0));
 if (nf >= 2)
  b |= ((bits)1 << (XMM1));
 if (p) {
  p[0] = ni;
  p[1] = nf;
 }
 return b;
}
bits
amd64_sysv_argregs(Ref r, int p[2])
{
 bits b;
 int j, ni, nf, ra;
 ((void)0);
 b = 0;
 ni = (r.val >> 4) & 15;
 nf = (r.val >> 8) & 15;
 ra = (r.val >> 12) & 1;
 for (j=0; j<ni; j++)
  b |= ((bits)1 << (amd64_sysv_rsave[j]));
 for (j=0; j<nf; j++)
  b |= ((bits)1 << (XMM0+j));
 if (p) {
  p[0] = ni + ra;
  p[1] = nf;
 }
 return b | (ra ? ((bits)1 << (RAX)) : 0);
}
static Ref
rarg(int ty, int *ni, int *ns)
{
 if (((ty)>>1) == 0)
  return (Ref){RTmp, amd64_sysv_rsave[(*ni)++]};
 else
  return (Ref){RTmp, XMM0 + (*ns)++};
}
static void
selcall(Fn *fn, Ins *i0, Ins *i1, RAlloc **rap)
{
 Ins *i;
 AClass *ac, *a, aret;
 int ca, ni, ns, al;
 uint stk, off;
 Ref r, r1, r2, reg[2], env;
 RAlloc *ra;
 env = (Ref){RTmp, 0};
 ac = alloc((i1-i0) * sizeof ac[0]);
 if (!req(i1->arg[1], (Ref){RTmp, 0})) {
  ((void)0);
  typclass(&aret, &typ[i1->arg[1].val]);
  ca = argsclass(i0, i1, ac, Oarg, &aret, &env);
 } else
  ca = argsclass(i0, i1, ac, Oarg, 0, &env);
 for (stk=0, a=&ac[i1-i0]; a>ac;)
  if ((--a)->inmem) {
   if (a->align > 4)
    err("sysv abi requires alignments of 16 or less");
   stk += a->size;
   if (a->align == 4)
    stk += stk & 15;
  }
 stk += stk & 15;
 if (stk) {
  r = getcon(-(int64_t)stk, fn);
  emit(Osalloc, Kl, (Ref){RTmp, 0}, r, (Ref){RTmp, 0});
 }
 if (!req(i1->arg[1], (Ref){RTmp, 0})) {
  if (aret.inmem) {
   r1 = newtmp("abi", Kl, fn);
   emit(Ocopy, Kl, i1->to, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
   ca += 1;
  } else {
   if (aret.size > 8) {
    r = newtmp("abi", Kl, fn);
    aret.ref[1] = newtmp("abi", aret.cls[1], fn);
    emit(Ostorel, 0, (Ref){RTmp, 0}, aret.ref[1], r);
    emit(Oadd, Kl, r, i1->to, getcon(8, fn));
   }
   aret.ref[0] = newtmp("abi", aret.cls[0], fn);
   emit(Ostorel, 0, (Ref){RTmp, 0}, aret.ref[0], i1->to);
   ca += retr(reg, &aret);
   if (aret.size > 8)
    emit(Ocopy, aret.cls[1], aret.ref[1], reg[1], (Ref){RTmp, 0});
   emit(Ocopy, aret.cls[0], aret.ref[0], reg[0], (Ref){RTmp, 0});
   r1 = i1->to;
  }
  ra = alloc(sizeof *ra);
  al = aret.align >= 2 ? aret.align - 2 : 0;
  ra->i = (Ins){Oalloc+al, Kl, r1, {getcon(aret.size, fn)}};
  ra->link = (*rap);
  *rap = ra;
 } else {
  ra = 0;
  if (((i1->cls)>>1) == 0) {
   emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
   ca += 1;
  } else {
   emit(Ocopy, i1->cls, i1->to, (Ref){RTmp, XMM0}, (Ref){RTmp, 0});
   ca += 1 << 2;
  }
 }
 emit(Ocall, i1->cls, (Ref){RTmp, 0}, i1->arg[0], (Ref){RCall, ca});
 if (!req((Ref){RTmp, 0}, env))
  emit(Ocopy, Kl, (Ref){RTmp, RAX}, env, (Ref){RTmp, 0});
 else if ((ca >> 12) & 1)
  emit(Ocopy, Kw, (Ref){RTmp, RAX}, getcon((ca >> 8) & 15, fn), (Ref){RTmp, 0});
 ni = ns = 0;
 if (ra && aret.inmem)
  emit(Ocopy, Kl, rarg(Kl, &ni, &ns), ra->i.to, (Ref){RTmp, 0});
 for (i=i0, a=ac; i<i1; i++, a++) {
  if (i->op >= Oarge || a->inmem)
   continue;
  r1 = rarg(a->cls[0], &ni, &ns);
  if (i->op == Oargc) {
   if (a->size > 8) {
    r2 = rarg(a->cls[1], &ni, &ns);
    r = newtmp("abi", Kl, fn);
    emit(Oload, a->cls[1], r2, r, (Ref){RTmp, 0});
    emit(Oadd, Kl, r, i->arg[1], getcon(8, fn));
   }
   emit(Oload, a->cls[0], r1, i->arg[1], (Ref){RTmp, 0});
  } else
   emit(Ocopy, i->cls, r1, i->arg[0], (Ref){RTmp, 0});
 }
 if (!stk)
  return;
 r = newtmp("abi", Kl, fn);
 for (i=i0, a=ac, off=0; i<i1; i++, a++) {
  if (i->op >= Oarge || !a->inmem)
   continue;
  r1 = newtmp("abi", Kl, fn);
  if (i->op == Oargc) {
   if (a->align == 4)
    off += off & 15;
   emit(Oblit1, 0, (Ref){RTmp, 0}, (Ref){RInt, (a->type->size)&0x1fffffff}, (Ref){RTmp, 0});
   emit(Oblit0, 0, (Ref){RTmp, 0}, i->arg[1], r1);
  } else
   emit(Ostorel, 0, (Ref){RTmp, 0}, i->arg[0], r1);
  emit(Oadd, Kl, r1, r, getcon(off, fn));
  off += a->size;
 }
 emit(Osalloc, Kl, r, getcon(stk, fn), (Ref){RTmp, 0});
}
static int
selpar(Fn *fn, Ins *i0, Ins *i1)
{
 AClass *ac, *a, aret;
 Ins *i;
 int ni, ns, s, al, fa;
 Ref r, env;
 env = (Ref){RTmp, 0};
 ac = alloc((i1-i0) * sizeof ac[0]);
 curi = &insb[NIns];
 ni = ns = 0;
 if (fn->retty >= 0) {
  typclass(&aret, &typ[fn->retty]);
  fa = argsclass(i0, i1, ac, Opar, &aret, &env);
 } else
  fa = argsclass(i0, i1, ac, Opar, 0, &env);
 fn->reg = amd64_sysv_argregs((Ref){RCall, fa}, 0);
 for (i=i0, a=ac; i<i1; i++, a++) {
  if (i->op != Oparc || a->inmem)
   continue;
  if (a->size > 8) {
   r = newtmp("abi", Kl, fn);
   a->ref[1] = newtmp("abi", Kl, fn);
   emit(Ostorel, 0, (Ref){RTmp, 0}, a->ref[1], r);
   emit(Oadd, Kl, r, i->to, getcon(8, fn));
  }
  a->ref[0] = newtmp("abi", Kl, fn);
  emit(Ostorel, 0, (Ref){RTmp, 0}, a->ref[0], i->to);
  al = a->align >= 2 ? a->align - 2 : 0;
  emit(Oalloc+al, Kl, i->to, getcon(a->size, fn), (Ref){RTmp, 0});
 }
 if (fn->retty >= 0 && aret.inmem) {
  r = newtmp("abi", Kl, fn);
  emit(Ocopy, Kl, r, rarg(Kl, &ni, &ns), (Ref){RTmp, 0});
  fn->retr = r;
 }
 for (i=i0, a=ac, s=4; i<i1; i++, a++) {
  switch (a->inmem) {
  case 1:
   if (a->align > 4)
    err("sysv abi requires alignments of 16 or less");
   if (a->align == 4)
    s = (s+3) & -4;
   fn->tmp[i->to.val].slot = -s;
   s += a->size / 4;
   continue;
  case 2:
   emit(Oload, i->cls, i->to, (Ref){RSlot, (-s)&0x1fffffff}, (Ref){RTmp, 0});
   s += 2;
   continue;
  }
  if (i->op == Opare)
   continue;
  r = rarg(a->cls[0], &ni, &ns);
  if (i->op == Oparc) {
   emit(Ocopy, a->cls[0], a->ref[0], r, (Ref){RTmp, 0});
   if (a->size > 8) {
    r = rarg(a->cls[1], &ni, &ns);
    emit(Ocopy, a->cls[1], a->ref[1], r, (Ref){RTmp, 0});
   }
  } else
   emit(Ocopy, i->cls, i->to, r, (Ref){RTmp, 0});
 }
 if (!req((Ref){RTmp, 0}, env))
  emit(Ocopy, Kl, env, (Ref){RTmp, RAX}, (Ref){RTmp, 0});
 return fa | (s*4)<<12;
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
selvaarg(Fn *fn, Blk *b, Ins *i)
{
 Ref loc, lreg, lstk, nr, r0, r1, c4, c8, c16, c, ap;
 Blk *b0, *bstk, *breg;
 int isint;
 c4 = getcon(4, fn);
 c8 = getcon(8, fn);
 c16 = getcon(16, fn);
 ap = i->arg[0];
 isint = ((i->cls)>>1) == 0;
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
 emit(Oadd, Kl, r1, ap, isint ? (Ref){RCon, 1} : c4);
 emit(Oadd, Kw, r0, nr, isint ? c8 : c16);
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Oadd, Kl, lreg, r1, nr);
 emit(Oload, Kl, r1, r0, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, c16);
 breg = split(fn, b);
 breg->jmp.type = Jjmp;
 breg->s1 = b0;
 lstk = newtmp("abi", Kl, fn);
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r1, r0);
 emit(Oadd, Kl, r1, lstk, c8);
 emit(Oload, Kl, lstk, r0, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, c8);
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
 c = getcon(isint ? 48 : 176, fn);
 emit(Ocmpw+Ciult, Kw, r1, nr, c);
 emit(Oloadsw, Kl, nr, r0, (Ref){RTmp, 0});
 emit(Oadd, Kl, r0, ap, isint ? (Ref){RCon, 1} : c4);
}
static void
selvastart(Fn *fn, int fa, Ref ap)
{
 Ref r0, r1;
 int gp, fp, sp;
 gp = ((fa >> 4) & 15) * 8;
 fp = 48 + ((fa >> 8) & 15) * 16;
 sp = fa >> 12;
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r1, r0);
 emit(Oadd, Kl, r1, (Ref){RTmp, RBP}, getcon(-176, fn));
 emit(Oadd, Kl, r0, ap, getcon(16, fn));
 r0 = newtmp("abi", Kl, fn);
 r1 = newtmp("abi", Kl, fn);
 emit(Ostorel, Kw, (Ref){RTmp, 0}, r1, r0);
 emit(Oadd, Kl, r1, (Ref){RTmp, RBP}, getcon(sp, fn));
 emit(Oadd, Kl, r0, ap, getcon(8, fn));
 r0 = newtmp("abi", Kl, fn);
 emit(Ostorew, Kw, (Ref){RTmp, 0}, getcon(fp, fn), r0);
 emit(Oadd, Kl, r0, ap, getcon(4, fn));
 emit(Ostorew, Kw, (Ref){RTmp, 0}, getcon(gp, fn), ap);
}
void
amd64_sysv_abi(Fn *fn)
{
 Blk *b;
 Ins *i, *i0;
 RAlloc *ral;
 int n0, n1, ioff, fa;
 for (b=fn->start; b; b=b->link)
  b->visit = 0;
 for (b=fn->start, i=b->ins; i<&b->ins[b->nins]; i++)
  if (!((unsigned)(i->op) - Opar <= Opare - Opar))
   break;
 fa = selpar(fn, b->ins, i);
 n0 = &insb[NIns] - curi;
 ioff = i - b->ins;
 n1 = b->nins - ioff;
 vgrow(&b->ins, n0+n1);
 icpy(b->ins+n0, b->ins+ioff, n1);
 icpy(b->ins, curi, n0);
 b->nins = n0+n1;
 ral = 0;
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
    selcall(fn, i0, i, &ral);
    i = i0;
    break;
   case Ovastart:
    selvastart(fn, fa, i->arg[0]);
    break;
   case Ovaarg:
    selvaarg(fn, b, i);
    break;
   case Oarg:
   case Oargc:
    die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/amd64/sysv.c", "unreachable");
   }
  if (b == fn->start)
   for (; ral; ral=ral->link)
    emiti(ral->i);
  idup(b, curi, &insb[NIns]-curi);
 } while (b != fn->start);
 if (debug['A']) {
  fprintf(__stderrp, "\n> After ABI lowering:\n");
  printfn(fn, __stderrp);
 }
}
