typedef unsigned int uint;
typedef unsigned long ulong;

void exit(int);
int printf(char *, ...);

/* Ref, as in vendor/qbe/all.h */
typedef struct { uint type:3; uint val:29; } Ref;

#define RInt 1
#define INT(x)   (Ref){RInt, (x)&0x1fffffff}

/* util.c */
static int rsval(Ref r) {
  return ((int)r.val ^ 0x10000000) - 0x10000000;
}

/* simpl.c: an Ins with the arg array. */
typedef struct { uint op:30; uint cls:2; Ref to; Ref arg[2]; } Ins;

/* The exact shape of simpl.c:ins Oblit1. */
static int seen_sz;
static void blit(Ref sd[2], int sz, int *log) {
  log[0] = sz;
  seen_sz = sz;
  (void)sd;
}

static void ins_like(Ins *i, int *log) {
  Ref r = i->arg[0];
  int sz = rsval(r);
  blit((i - 1)->arg, sz, log);
}

int main(void) {
  Ins buf[4];
  int log[4];
  int sizes[7];
  int i;
  int bad = 0;
  Ref r;

  sizes[0] = 11; sizes[1] = -11; sizes[2] = 0; sizes[3] = 1;
  sizes[4] = 8;  sizes[5] = -1;  sizes[6] = 15;

  /* rsval round trip */
  r = INT(11);  if (rsval(r) != 11)  { printf("rsval(11) = %d\n", rsval(r));  bad = 1; }
  r = INT(-11); if (rsval(r) != -11) { printf("rsval(-11) = %d\n", rsval(r)); bad = 1; }
  r = INT(0);   if (rsval(r) != 0)   { printf("rsval(0) = %d\n", rsval(r));   bad = 1; }
  r = INT(-1);  if (rsval(r) != -1)  { printf("rsval(-1) = %d\n", rsval(r));  bad = 1; }

  /* the (i-1)->arg walk: i points at buf[k], arg lives in buf[k-1] */
  for (i = 0; i < 7; i++) {
    int k;
    for (k = 0; k < 4; k++) {
      buf[k].op = 0; buf[k].cls = 0;
      buf[k].to.type = 3; buf[k].to.val = (uint)(100 + k);
      buf[k].arg[0].type = 3; buf[k].arg[0].val = 0;
      buf[k].arg[1].type = 3; buf[k].arg[1].val = 0;
    }
    /* the blit size goes in the *following* instruction (Oblit1) */
    buf[2].arg[0] = INT(sizes[i]);
    ins_like(&buf[2], log);
    if (log[0] != sizes[i]) {
      printf("size %d came through as %d\n", sizes[i], log[0]);
      bad = 1;
    }
  }

  if (!bad) printf("all ok\n");
  return bad;
}

