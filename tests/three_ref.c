struct Ref { unsigned type:3; unsigned val:29; };
static int seen[8];
static void emit(int op, int k, struct Ref to, struct Ref a0, struct Ref a1) {
  seen[0] = op;
  seen[1] = (int)k;
  seen[2] = (int)to.type;
  seen[3] = (int)to.val;
  seen[4] = (int)a0.type;
  seen[5] = (int)a0.val;
  seen[6] = (int)a1.type;
  seen[7] = (int)a1.val;
}
int main() {
  emit(1, 2, (struct Ref){ 1, 3 }, (struct Ref){ 2, 4 }, (struct Ref){ 0, 5 });
  if (seen[0] != 1) return 1;
  if (seen[1] != 2) return 2;
  if (seen[2] != 1) return 3;
  if (seen[3] != 3) return 4;
  if (seen[4] != 2) return 5;
  if (seen[5] != 4) return 6;
  if (seen[6] != 0) return 7;
  if (seen[7] != 5) return 8;
  return 0;
}
