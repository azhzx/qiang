// Two same-named locals in sibling scopes are distinct objects. The code
// generator binds locals by name in one flat map, so a shadowing declaration
// used to share a slot with the other one and be read through its type:
// Lua's forprep has an integer and a floating-point `step` in the two arms of
// one `if`, which came out as `ceql` on a double.
static long pick(int c) {
  if (c) {
    long v = 5;
    if (v == 0) return 1;
    return v;
  } else {
    double v = 2.5;
    if (v == 0) return 2;
    return (long)(v * 4);
  }
}

int main(void) {
  if (pick(1) != 5) return 1;
  if (pick(0) != 10) return 2;
  return 0;
}
