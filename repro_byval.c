/* Two shapes that appear in simpl.c: a function taking a struct by value,
 * and a function taking a small array by value, both called from a loop. */
int printf(char *, ...);

typedef struct { int op; int to; int a0; int a1; int cls; } Ins;

static int saw;

/* by-value struct parameter */
static void emit(Ins i) { saw += i.op + i.to + i.a0 + i.a1 + i.cls; }

/* by-value array parameter (Ref sd[2]) */
static void blit(int sd[2], int sz) { saw += sd[0] + sd[1] + sz; }

int main(void) {
  long i;
  long n = 3000000L;
  long want = 0;
  for (i = 0; i < n; i++) {
    Ins x;
    x.op = 1; x.to = 2; x.a0 = 3; x.a1 = 4; x.cls = 5;
    emit(x);
    {
      int sd[2];
      sd[0] = 6; sd[1] = 7;
      blit(sd, 8);
    }
    want += 15 + 21;
  }
  if (saw != want) {
    printf("WRONG saw=%d want=%ld\n", saw, want);
    return 1;
  }
  printf("OK\n");
  return 0;
}

