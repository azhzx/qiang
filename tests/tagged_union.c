// expect-exit 0
// tagged
// QPCC -f_tagged_union extension: clang has no such keyword, so QPCC-only.
// A tagged-union member cannot be assigned directly; change the value as a
// whole, e.g. v = (_Tagged_union V){ .f = 1.5f }.
_Tagged_union Value {
  int as_int;
  float as_float;
};
_Tagged_union Mixed {
  int i;
  double d;
};
_Tagged_union Chars {
  char c;
};
_Tagged_union Nested {
  int tag_only;
  _Tagged_union Value inner;
};

_Static_assert(sizeof(_Tagged_union Value) == 8, "Value size");
_Static_assert(_Alignof(_Tagged_union Value) == 4, "Value align");
_Static_assert(sizeof(_Tagged_union Mixed) == 16, "Mixed size");
_Static_assert(_Alignof(_Tagged_union Mixed) == 8, "Mixed align");
_Static_assert(sizeof(_Tagged_union Chars) == 8, "Chars size");
_Static_assert(_Get_tag(_Tagged_union Value, as_int) == 0, "tag as_int");
_Static_assert(_Get_tag(_Tagged_union Value, as_float) == 1, "tag as_float");

static _Tagged_union Value make(int t) {
  _Tagged_union Value v;
  if (t) {
    v = (_Tagged_union Value){ .as_float = 3.5f };
  } else {
    v = (_Tagged_union Value){ .as_int = 42 };
  }
  return v;
}

static int take(_Tagged_union Value v) { return (int)_Tag_of(v); }

int main(void) {
  _Tagged_union Value a = { .as_int = 5 };
  if (_Tag_of(a) != _Get_tag(_Tagged_union Value, as_int)) return 1;
  if (take(a) != 0) return 2;
  if (a.as_int != 5) return 3;

  a = (_Tagged_union Value){ .as_float = 1.25f };
  if (_Tag_of(a) != 1) return 4;
  if (a.as_float != 1.25f) return 5;

  a = (_Tagged_union Value){ .as_int = 42 };
  if (a.as_int != 42) return 6;
  a = (_Tagged_union Value){ .as_int = a.as_int + 1 };
  if (a.as_int != 43) return 7;
  if (_Tag_of(a) != 0) return 8;

  _Tagged_union Value b = make(1);
  if (_Tag_of(b) != 1 || b.as_float != 3.5f) return 9;
  _Tagged_union Value c = make(0);
  if (_Tag_of(c) != 0 || c.as_int != 42) return 10;

  _Tagged_union Value d = { .as_float = 2.0f };
  if (_Tag_of(d) != 1 || d.as_float != 2.0f) return 11;

  _Tagged_union Value e = a;
  if (_Tag_of(e) != 0 || e.as_int != 43) return 12;

  _Tagged_union Value arr[3];
  arr[0] = (_Tagged_union Value){ .as_int = 1 };
  arr[1] = (_Tagged_union Value){ .as_float = 1.0f };
  if (_Tag_of(arr[0]) != 0 || arr[0].as_int != 1) return 13;
  if (_Tag_of(arr[1]) != 1 || arr[1].as_float != 1.0f) return 14;

  _Tagged_union Value *p = &a;
  if (_Tag_of(*p) != 0 || p->as_int != 43) return 15;
  *p = (_Tagged_union Value){ .as_float = 0.5f };
  if (_Tag_of(a) != 1 || a.as_float != 0.5f) return 16;

  _Tagged_union Nested n;
  n = (_Tagged_union Nested){ .inner = { .as_int = 3 } };
  if (_Tag_of(n.inner) != 0 || n.inner.as_int != 3) return 17;

  const _Tagged_union Value q = { .as_int = 9 };
  if (_Tag_of(q) != 0 || q.as_int != 9) return 18;

  switch (_Tag_of(a)) {
    case _Get_tag(_Tagged_union Value, as_int): return 19;
    case _Get_tag(_Tagged_union Value, as_float):
      if (a.as_float != 0.5f) return 20;
      break;
  }
  return 0;
}
