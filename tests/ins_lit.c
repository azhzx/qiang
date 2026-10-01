struct Ins { unsigned op:30; unsigned cls:2; long to; long arg[2]; };
static struct Ins buf[4];
static struct Ins *cur = &buf[4];
static void emit(int op, int k, long to, long a0, long a1) {
  if (cur == buf) return;
  *--cur = (struct Ins){ .op = op, .cls = k, .to = to, .arg = { a0, a1 } };
}
int main() {
  emit(7, 1, 11, 22, 33);
  if (buf[3].op != 7) return 1;
  if (buf[3].cls != 1) return 2;
  if (buf[3].to != 11) return 3;
  if (buf[3].arg[0] != 22) return 4;
  if (buf[3].arg[1] != 33) return 5;
  emit(9, 2, 44, 55, 66);
  if (buf[2].op != 9) return 6;
  if (buf[2].cls != 2) return 7;
  if (buf[2].arg[1] != 66) return 8;
  return 0;
}
