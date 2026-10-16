// C promotes char and short to int before the usual arithmetic conversions, so
// a comparison between int and unsigned char is SIGNED. Taking "either operand
// is unsigned" as the rule made it unsigned: Lua's freereg tests
//   if (reg >= luaY_nvarstack(fs))
// with reg an int and luaY_nvarstack returning lu_byte, and a -1 register then
// compared as 0xFFFFFFFF, decremented freereg, and shifted every later register
// in the emitted bytecode.
int f(int a, unsigned char b) { return a >= b; }
int g(int a, unsigned short b) { return a >= b; }
int h(int a, unsigned int b) { return a >= b; }  /* this one IS unsigned */

int main(void) {
  int a = -1;
  unsigned char b = 1;
  unsigned short c = 1;
  unsigned int d = 1;
  if (a >= b) return 1;       /* -1 < 1 */
  if (f(a, b)) return 2;
  if (g(a, c)) return 3;
  if (!(a >= d)) return 4;    /* -1 >= 1u is true: unsigned comparison */
  if (a < b) { } else return 5;
  if (h(a, d) != 1) return 6;
  return 0;
}
