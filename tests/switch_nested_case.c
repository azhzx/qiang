// A case label nested inside a loop must stay attached to that loop, and the
// enclosing case must fall through to the next *sibling* case. Regression for
// bzip2's decompress.c, where a case label sits inside a GET_BIT loop and the
// statement after the loop used to jump back into the nested label's detached
// copy of the body, running the loop one extra time.
//
// f(0): the loop runs 4 times (g = 4), then g += 10, then falls into case 2.
// f(2): enters at case 2 directly, so g is still 0.
static int g;

static int f(int n) {
  int i, r = 0;
  g = 0;
  switch (n) {
  case 0:
    for (i = 0; i < 4; i++) {
  case 1:
      g = g + 1;
    }
    g = g + 10;
  case 2:
    r = g;
  }
  return r;
}

int main(void) {
  if (f(0) != 14) return 1;
  if (f(2) != 0) return 2;
  return 0;
}
