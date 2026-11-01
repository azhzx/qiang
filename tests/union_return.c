// A union returned by value, alone or as a struct member, is an ordinary
// aggregate for the platform C ABI: the return type table has to describe it
// so the register/memory classification matches clang's.
struct Small {
  int tag;
  union {
    int i;
    double d;
  } u;
};

union U {
  int i;
  double d;
};

union F {
  double a;
  double b;
};

union Big {
  char buf[32];
  long x;
};

struct HFA {
  union {
    float a;
    float b;
  } u;
  float c;
};

static struct Small make_small(int tag, int v) {
  struct Small s;
  s.tag = tag;
  s.u.i = v;
  return s;
}

static union U make_u(int v) {
  union U u;
  u.i = v;
  return u;
}

static union F make_f(double v) {
  union F f;
  f.a = v;
  return f;
}

static union Big make_big(int v) {
  union Big b;
  int i;
  for (i = 0; i < 32; i++) {
    b.buf[i] = (char)(v + i);
  }
  return b;
}

static struct HFA make_hfa(float a, float c) {
  struct HFA h;
  h.u.a = a;
  h.c = c;
  return h;
}

int main(void) {
  struct Small s;
  union U u;
  union F f;
  union Big b;
  struct HFA h;
  int i;

  s = make_small(3, 42);
  if (s.tag != 3 || s.u.i != 42) {
    return 1;
  }
  u = make_u(7);
  if (u.i != 7) {
    return 2;
  }
  f = make_f(2.5);
  if (f.a != 2.5) {
    return 3;
  }
  b = make_big(1);
  for (i = 0; i < 32; i++) {
    if (b.buf[i] != (char)(1 + i)) {
      return 4;
    }
  }
  h = make_hfa(1.5f, 2.5f);
  if (h.u.a != 1.5f || h.c != 2.5f) {
    return 5;
  }
  return 0;
}
