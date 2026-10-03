// expect-exit 0
// tagged
// Global and static _Tagged_union initializers, written into .data.
_Tagged_union Value {
  int as_int;
  float as_float;
};

_Tagged_union Value g_int = { .as_int = 100 };
_Tagged_union Value g_flt = { .as_float = 2.5f };
static _Tagged_union Value s_flt = { .as_float = 3.75f };

int main(void) {
  if (_Tag_of(g_int) != 0 || g_int.as_int != 100) return 1;
  if (_Tag_of(g_flt) != 1 || g_flt.as_float != 2.5f) return 2;
  if (_Tag_of(s_flt) != 1 || s_flt.as_float != 3.75f) return 3;

  g_int.as_float = 1.0f;
  if (_Tag_of(g_int) != 1 || g_int.as_float != 1.0f) return 4;
  return 0;
}
