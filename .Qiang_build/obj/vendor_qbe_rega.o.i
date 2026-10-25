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
typedef struct RMap RMap;
struct RMap {
 int t[Tmp0];
 int r[Tmp0];
 int w[Tmp0];
 BSet b[1];
 int n;
};
enum {
 NPm = 64,
};
static bits regu;
static Tmp *tmp;
static Mem *mem;
static struct {
 Ref src, dst;
 int cls;
} pm[NPm];
static int npm;
static int loop;
static uint stmov;
static uint stblk;
static int *
hint(int t)
{
 return &tmp[phicls(t, tmp)].hint.r;
}
static void
sethint(int t, int r)
{
 Tmp *p;
 p = &tmp[phicls(t, tmp)];
 if (p->hint.r == -1 || p->hint.w > loop) {
  p->hint.r = r;
  p->hint.w = loop;
  tmp[t].visit = -1;
 }
}
static void
rcopy(RMap *ma, RMap *mb)
{
 memcpy(ma->t, mb->t, sizeof ma->t);
 memcpy(ma->r, mb->r, sizeof ma->r);
 memcpy(ma->w, mb->w, sizeof ma->w);
 bscopy(ma->b, mb->b);
 ma->n = mb->n;
}
static int
rfind(RMap *m, int t)
{
 int i;
 for (i=0; i<m->n; i++)
  if (m->t[i] == t)
   return m->r[i];
 return -1;
}
static Ref
rref(RMap *m, int t)
{
 int r, s;
 r = rfind(m, t);
 if (r == -1) {
  s = tmp[t].slot;
  ((void)0);
  return (Ref){RSlot, (s)&0x1fffffff};
 } else
  return (Ref){RTmp, r};
}
static void
radd(RMap *m, int t, int r)
{
 ((void)0);
 ((void)0);
 ((void)0);
 ((void)0);
 ((void)0);
 bsset(m->b, t);
 bsset(m->b, r);
 m->t[m->n] = t;
 m->r[m->n] = r;
 m->n++;
 regu |= ((bits)1 << (r));
}
static Ref
ralloctry(RMap *m, int t, int try)
{
 bits regs;
 int h, r, r0, r1;
 if (t < Tmp0) {
  ((void)0);
  return (Ref){RTmp, t};
 }
 if (bshas(m->b, t)) {
  r = rfind(m, t);
  ((void)0);
  return (Ref){RTmp, r};
 }
 r = tmp[t].visit;
 if (r == -1 || bshas(m->b, r))
  r = *hint(t);
 if (r == -1 || bshas(m->b, r)) {
  if (try)
   return (Ref){RTmp, 0};
  regs = tmp[phicls(t, tmp)].hint.m;
  regs |= m->b->t[0];
  if (((tmp[t].cls)>>1) == 0) {
   r0 = T.gpr0;
   r1 = r0 + T.ngpr;
  } else {
   r0 = T.fpr0;
   r1 = r0 + T.nfpr;
  }
  for (r=r0; r<r1; r++)
   if (!(regs & ((bits)1 << (r))))
    goto Found;
  for (r=r0; r<r1; r++)
   if (!bshas(m->b, r))
    goto Found;
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rega.c", "no more regs");
 }
Found:
 radd(m, t, r);
 sethint(t, r);
 tmp[t].visit = r;
 h = *hint(t);
 if (h != -1 && h != r)
  m->w[h] = t;
 return (Ref){RTmp, r};
}
static inline Ref
ralloc(RMap *m, int t)
{
 return ralloctry(m, t, 0);
}
static int
rfree(RMap *m, int t)
{
 int i, r;
 ((void)0);
 if (!bshas(m->b, t))
  return -1;
 for (i=0; m->t[i] != t; i++)
  ((void)0);
 r = m->r[i];
 bsclr(m->b, t);
 bsclr(m->b, r);
 m->n--;
 memmove(&m->t[i], &m->t[i+1], (m->n-i) * sizeof m->t[0]);
 memmove(&m->r[i], &m->r[i+1], (m->n-i) * sizeof m->r[0]);
 ((void)0);
 return r;
}
static void
mdump(RMap *m)
{
 int i;
 for (i=0; i<m->n; i++)
  if (m->t[i] >= Tmp0)
   fprintf(__stderrp, " (%s, R%d)",
    tmp[m->t[i]].name,
    m->r[i]);
 fprintf(__stderrp, "\n");
}
static void
pmadd(Ref src, Ref dst, int k)
{
 if (npm == NPm)
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rega.c", "no more pm slots");
 pm[npm].src = src;
 pm[npm].dst = dst;
 pm[npm].cls = k;
 npm++;
}
enum PMStat { ToMove, Moving, Moved };
static int
pmrec(enum PMStat *status, int i, int *k)
{
 int j, c;
 if (req(pm[i].src, pm[i].dst)) {
  status[i] = Moved;
  return -1;
 }
 ((void)0);
 ((void)0);
 *k |= pm[i].cls;
 for (j=0; j<npm; j++)
  if (req(pm[j].dst, pm[i].src))
   break;
 switch (j == npm ? Moved : status[j]) {
 case Moving:
  c = j;
  emit(Oswap, *k, (Ref){RTmp, 0}, pm[i].src, pm[i].dst);
  break;
 case ToMove:
  status[i] = Moving;
  c = pmrec(status, j, k);
  if (c == i) {
   c = -1;
   break;
  }
  if (c != -1) {
   emit(Oswap, *k, (Ref){RTmp, 0}, pm[i].src, pm[i].dst);
   break;
  }
 case Moved:
  c = -1;
  emit(Ocopy, pm[i].cls, pm[i].dst, pm[i].src, (Ref){RTmp, 0});
  break;
 default:
  die_("/Users/Admin/Desktop/qbe.mbt/vendor/qbe/rega.c", "unreachable");
 }
 status[i] = Moved;
 return c;
}
static void
pmgen()
{
 int i;
 enum PMStat *status;
 status = alloc(npm * sizeof status[0]);
 ((void)0);
 for (i=0; i<npm; i++)
  if (status[i] == ToMove)
   pmrec(status, i, (int[]){pm[i].cls});
}
static void
move(int r, Ref to, RMap *m)
{
 int n, t, r1;
 r1 = req(to, (Ref){RTmp, 0}) ? -1 : rfree(m, to.val);
 if (bshas(m->b, r)) {
  ((void)0);
  for (n=0; m->r[n] != r; n++)
   ((void)0);
  t = m->t[n];
  rfree(m, t);
  bsset(m->b, r);
  ralloc(m, t);
  bsclr(m->b, r);
 }
 t = req(to, (Ref){RTmp, 0}) ? r : to.val;
 radd(m, t, r);
}
static int
regcpy(Ins *i)
{
 return i->op == Ocopy && isreg(i->arg[0]);
}
static Ins *
dopm(Blk *b, Ins *i, RMap *m)
{
 RMap m0;
 int n, r, r1, t, s;
 Ins *i1, *ip;
 bits def;
 m0 = *m;
 m0.b->t = 0;
 i1 = ++i;
 do {
  i--;
  move(i->arg[0].val, i->to, m);
 } while (i != b->ins && regcpy(i-1));
 ((void)0);
 if (i != b->ins && (i-1)->op == Ocall) {
  def = T.retregs((i-1)->arg[1], 0) | T.rglob;
  for (r=0; T.rsave[r]>=0; r++)
   if (!(((bits)1 << (T.rsave[r])) & def))
    move(T.rsave[r], (Ref){RTmp, 0}, m);
 }
 for (npm=0, n=0; n<m->n; n++) {
  t = m->t[n];
  s = tmp[t].slot;
  r1 = m->r[n];
  r = rfind(&m0, t);
  if (r != -1)
   pmadd((Ref){RTmp, r1}, (Ref){RTmp, r}, tmp[t].cls);
  else if (s != -1)
   pmadd((Ref){RTmp, r1}, (Ref){RSlot, (s)&0x1fffffff}, tmp[t].cls);
 }
 for (ip=i; ip<i1; ip++) {
  if (!req(ip->to, (Ref){RTmp, 0}))
   rfree(m, ip->to.val);
  r = ip->arg[0].val;
  if (rfind(m, r) == -1)
   radd(m, r, r);
 }
 pmgen();
 return i;
}
static int
prio1(Ref r1, Ref r2)
{
 (void) r2;
 return *hint(r1.val) != -1;
}
static void
insert(Ref *r, Ref **rs, int p)
{
 int i;
 rs[i = p] = r;
 while (i-- > 0 && prio1(*r, *rs[i])) {
  rs[i+1] = rs[i];
  rs[i] = r;
 }
}
static void
doblk(Blk *b, RMap *cur)
{
 int t, x, r, rf, rt, nr;
 bits rs;
 Ins *i, *i1;
 Mem *m;
 Ref *ra[4];
 if (rtype(b->jmp.arg) == RTmp)
  b->jmp.arg = ralloc(cur, b->jmp.arg.val);
 curi = &insb[NIns];
 for (i1=&b->ins[b->nins]; i1!=b->ins;) {
  emiti(*--i1);
  i = curi;
  rf = -1;
  switch (i->op) {
  case Ocall:
   rs = T.argregs(i->arg[1], 0) | T.rglob;
   for (r=0; T.rsave[r]>=0; r++)
    if (!(((bits)1 << (T.rsave[r])) & rs))
     rfree(cur, T.rsave[r]);
   break;
  case Ocopy:
   if (regcpy(i)) {
    curi++;
    i1 = dopm(b, i1, cur);
    stmov += i+1 - curi;
    continue;
   }
   if (isreg(i->to))
   if (rtype(i->arg[0]) == RTmp)
    sethint(i->arg[0].val, i->to.val);
  default:
   if (!req(i->to, (Ref){RTmp, 0})) {
    ((void)0);
    r = i->to.val;
    if (r < Tmp0 && (((bits)1 << (r)) & T.rglob))
     break;
    rf = rfree(cur, r);
    if (rf == -1) {
     ((void)0);
     curi++;
     continue;
    }
    i->to = (Ref){RTmp, rf};
   }
   break;
  }
  for (x=0, nr=0; x<2; x++)
   switch (rtype(i->arg[x])) {
   case RMem:
    m = &mem[i->arg[x].val];
    if (rtype(m->base) == RTmp)
     insert(&m->base, ra, nr++);
    if (rtype(m->index) == RTmp)
     insert(&m->index, ra, nr++);
    break;
   case RTmp:
    insert(&i->arg[x], ra, nr++);
    break;
   }
  for (r=0; r<nr; r++)
   *ra[r] = ralloc(cur, ra[r]->val);
  if (i->op == Ocopy && req(i->to, i->arg[0]))
   curi++;
  if (rf != -1 && (t = cur->w[rf]) != 0)
  if (!bshas(cur->b, rf) && *hint(t) == rf
  && (rt = rfree(cur, t)) != -1) {
   tmp[t].visit = -1;
   ralloc(cur, t);
   ((void)0);
   emit(Ocopy, tmp[t].cls, (Ref){RTmp, rt}, (Ref){RTmp, rf}, (Ref){RTmp, 0});
   stmov += 1;
   cur->w[rf] = 0;
   for (r=0; r<nr; r++)
    if (req(*ra[r], (Ref){RTmp, rt}))
     *ra[r] = (Ref){RTmp, rf};
  }
 }
 idup(b, curi, &insb[NIns]-curi);
}
static int
carve(const void *a, const void *b)
{
 Blk *ba, *bb;
 ba = *(Blk**)a;
 bb = *(Blk**)b;
 if (ba->loop == bb->loop)
  return ba->id > bb->id ? -1 : ba->id < bb->id;
 return ba->loop > bb->loop ? -1 : +1;
}
static int
prio2(int t1, int t2)
{
 if ((tmp[t1].visit ^ tmp[t2].visit) < 0)
  return tmp[t1].visit != -1 ? +1 : -1;
 if ((*hint(t1) ^ *hint(t2)) < 0)
  return *hint(t1) != -1 ? +1 : -1;
 return tmp[t1].cost - tmp[t2].cost;
}
void
rega(Fn *fn)
{
 int j, t, r, x, rl[Tmp0];
 Blk *b, *b1, *s, ***ps, *blist, **blk, **bp;
 RMap *end, *beg, cur, old, *m;
 Ins *i;
 Phi *p;
 uint u, n;
 Ref src, dst;
 stmov = 0;
 stblk = 0;
 regu = 0;
 tmp = fn->tmp;
 mem = fn->mem;
 blk = alloc(fn->nblk * sizeof blk[0]);
 end = alloc(fn->nblk * sizeof end[0]);
 beg = alloc(fn->nblk * sizeof beg[0]);
 for (n=0; n<fn->nblk; n++) {
  bsinit(end[n].b, fn->ntmp);
  bsinit(beg[n].b, fn->ntmp);
 }
 bsinit(cur.b, fn->ntmp);
 bsinit(old.b, fn->ntmp);
 loop = 2147483647;
 for (t=0; t<fn->ntmp; t++) {
  tmp[t].hint.r = t < Tmp0 ? t : -1;
  tmp[t].hint.w = loop;
  tmp[t].visit = -1;
 }
 for (bp=blk, b=fn->start; b; b=b->link)
  *bp++ = b;
 qsort(blk, fn->nblk, sizeof blk[0], carve);
 for (b=fn->start, i=b->ins; i<&b->ins[b->nins]; i++)
  if (i->op != Ocopy || !isreg(i->arg[0]))
   break;
  else {
   ((void)0);
   sethint(i->to.val, i->arg[0].val);
  }
 for (bp=blk; bp<&blk[fn->nblk]; bp++) {
  b = *bp;
  n = b->id;
  loop = b->loop;
  cur.n = 0;
  bszero(cur.b);
  memset(cur.w, 0, sizeof cur.w);
  for (x=0, t=Tmp0; bsiter(b->out, &t); t++) {
   j = x++;
   rl[j] = t;
   while (j-- > 0 && prio2(t, rl[j]) > 0) {
    rl[j+1] = rl[j];
    rl[j] = t;
   }
  }
  for (r=0; bsiter(b->out, &r) && r<Tmp0; r++)
   radd(&cur, r, r);
  for (j=0; j<x; j++)
   ralloctry(&cur, rl[j], 1);
  for (j=0; j<x; j++)
   ralloc(&cur, rl[j]);
  rcopy(&end[n], &cur);
  doblk(b, &cur);
  bscopy(b->in, cur.b);
  for (p=b->phi; p; p=p->link)
   if (rtype(p->to) == RTmp)
    bsclr(b->in, p->to.val);
  rcopy(&beg[n], &cur);
 }
 for (s=fn->start; s; s=s->link) {
  if (s->npred <= 1)
   continue;
  m = &beg[s->id];
  memset(rl, 0, sizeof rl);
  for (p=s->phi; p; p=p->link) {
   if (rtype(p->to) != RTmp
   || (r=rfind(m, p->to.val)) == -1)
    continue;
   for (u=0; u<p->narg; u++) {
    b = p->blk[u];
    src = p->arg[u];
    if (rtype(src) != RTmp)
     continue;
    x = rfind(&end[b->id], src.val);
    if (x == -1)
     continue;
    rl[r] = (!rl[r] || rl[r] == x) ? x : -1;
   }
   if (rl[r] == 0)
    rl[r] = -1;
  }
  for (j=0; j<m->n; j++) {
   t = m->t[j];
   r = m->r[j];
   if (rl[r] || t < Tmp0 )
    continue;
   for (bp=s->pred; bp<&s->pred[s->npred]; bp++) {
    x = rfind(&end[(*bp)->id], t);
    if (x == -1)
     continue;
    rl[r] = (!rl[r] || rl[r] == x) ? x : -1;
   }
   if (rl[r] == 0)
    rl[r] = -1;
  }
  npm = 0;
  for (j=0; j<m->n; j++) {
   t = m->t[j];
   r = m->r[j];
   x = rl[r];
   ((void)0);
   if (x > 0 && !bshas(m->b, x)) {
    pmadd((Ref){RTmp, x}, (Ref){RTmp, r}, tmp[t].cls);
    m->r[j] = x;
    bsset(m->b, x);
   }
  }
  curi = &insb[NIns];
  pmgen();
  j = &insb[NIns] - curi;
  if (j == 0)
   continue;
  stmov += j;
  s->nins += j;
  i = alloc(s->nins * sizeof(Ins));
  icpy(icpy(i, curi, j), s->ins, s->nins-j);
  s->ins = i;
 }
 if (debug['R']) {
  fprintf(__stderrp, "\n> Register mappings:\n");
  for (n=0; n<fn->nblk; n++) {
   b = fn->rpo[n];
   fprintf(__stderrp, "\t%-10s beg", b->name);
   mdump(&beg[n]);
   fprintf(__stderrp, "\t           end");
   mdump(&end[n]);
  }
  fprintf(__stderrp, "\n");
 }
 blist = 0;
 for (b=fn->start;; b=b->link) {
  ps = (Blk**[3]){&b->s1, &b->s2, (Blk*[1]){0}};
  for (; (s=**ps); ps++) {
   npm = 0;
   for (p=s->phi; p; p=p->link) {
    dst = p->to;
    ((void)0);
    if (rtype(dst) == RTmp) {
     r = rfind(&beg[s->id], dst.val);
     if (r == -1)
      continue;
     dst = (Ref){RTmp, r};
    }
    for (u=0; p->blk[u]!=b; u++)
     ((void)0);
    src = p->arg[u];
    if (rtype(src) == RTmp)
     src = rref(&end[b->id], src.val);
    pmadd(src, dst, p->cls);
   }
   for (t=Tmp0; bsiter(s->in, &t); t++) {
    src = rref(&end[b->id], t);
    dst = rref(&beg[s->id], t);
    pmadd(src, dst, tmp[t].cls);
   }
   curi = &insb[NIns];
   pmgen();
   if (curi == &insb[NIns])
    continue;
   b1 = newblk();
   b1->loop = (b->loop+s->loop) / 2;
   b1->link = blist;
   blist = b1;
   fn->nblk++;
   b1->name = strf(PFn, "%s_%s", b->name, s->name);
   stmov += &insb[NIns]-curi;
   stblk += 1;
   idup(b1, curi, &insb[NIns]-curi);
   b1->jmp.type = Jjmp;
   b1->s1 = s;
   **ps = b1;
  }
  if (!b->link) {
   b->link = blist;
   break;
  }
 }
 for (b=fn->start; b; b=b->link)
  b->phi = 0;
 fn->reg = regu;
 if (debug['R']) {
  fprintf(__stderrp, "\n> Register allocation statistics:\n");
  fprintf(__stderrp, "\tnew moves:  %d\n", stmov);
  fprintf(__stderrp, "\tnew blocks: %d\n", stblk);
  fprintf(__stderrp, "\n> After register allocation:\n");
  printfn(fn, __stderrp);
 }
}
