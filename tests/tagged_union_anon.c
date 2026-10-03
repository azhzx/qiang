// expect-exit 0
// tagged
// An anonymous tagged union plus a typedef: the tag is optional, and the
// typedef name then stands for the type.
typedef _Tagged_union {
  int as_int;
  float as_float;
} Value;

_Static_assert(sizeof(Value) == 8, "size");
_Static_assert(_Alignof(Value) == 4, "align");
_Static_assert(_Get_tag(Value, as_int) == 0, "tag as_int");
_Static_assert(_Get_tag(Value, as_float) == 1, "tag as_float");

static int tag_of(Value v) { return (int)_Tag_of(v); }

int main(void) {
  Value v = { .as_int = 5 };
  if (_Tag_of(v) != 0 || v.as_int != 5) return 1;

  v = (Value){ .as_float = 2.5f };
  if (tag_of(v) != 1 || v.as_float != 2.5f) return 2;

  Value arr[2];
  arr[0] = (Value){ .as_int = 9 };
  if (_Tag_of(arr[0]) != 0 || arr[0].as_int != 9) return 3;
  return 0;
}
