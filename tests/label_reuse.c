// Two functions that use the same goto label name. Label blocks are per
// function; a leftover entry in the label map made the second function label
// take the "already emitted" path, so its block was never switched to and
// stayed unterminated (Jxxx), which the arm64 emitters reject. Lua hits this:
// luaD_precall and luaD_pretailcall both use a retry label.
static int first(int x) {
retry:
  switch (x) {
    case 0: return 0;
    default: x = 0; goto retry;
  }
}

static int second(int x) {
retry:
  switch (x) {
    case 1: return 1;
    default: x = 1; goto retry;
  }
}

int main(void) {
  if (first(5) != 0) return 1;
  if (second(5) != 1) return 2;
  return 0;
}
