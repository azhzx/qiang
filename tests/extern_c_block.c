// std=cqe
// expect-exit 0
// N3458 ("Clearer C/C++ Headers Boilerplate with extern Blocks"): the linkage
// block groups declarations. qpcc has a single language, so the block is
// flattened into the surrounding declarations; nested blocks, extern {} with
// no string and extern "C" on a single declaration are all accepted.
// p.s. this comment is after the two marker lines on purpose: the harness only
// reads the first two lines.
extern "C" {
  int g(int);
  int counter;
  struct S {
    int a;
  };
}

extern "C" int h(int);

extern {
  int h2(int);
}

extern "C" {
  extern "C++" {
    typedef int myint;
  }
  myint twice(myint);
}

int g(int x) { return x + 1; }
int h(int x) { return x * 2; }
int h2(int x) { return x - 1; }
myint twice(myint x) { return x * 2; }

int main(void) {
  counter = 3;
  struct S s = {4};
  myint m = twice(5);
  if (g(1) != 2) return 1;
  if (h(2) != 4) return 2;
  if (h2(3) != 2) return 3;
  if (m != 10) return 4;
  if (s.a != 4) return 5;
  if (counter != 3) return 6;
  return 0;
}
