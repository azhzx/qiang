struct Ins { unsigned op:30; unsigned cls:2; };
static int seen;
static void takei(int x) { seen = x; }
static void takeu(unsigned x) { seen = (int)x; }
static int vari(int dummy, ...);
static int vari(int dummy, ...) { return dummy; }
int main() {
  struct Ins i;
  i.op = 106; i.cls = 2;
  takei(i.cls);
  if (seen != 2) return 1;
  takeu(i.cls);
  if (seen != 2) return 2;
  seen = i.cls;
  if (seen != 2) return 3;
  i.cls = 3;
  takei(i.cls);
  if (seen != 3) return 4;
  i.cls = 1;
  takei(i.cls);
  if (seen != 1) return 5;
  int arr[4];
  arr[i.cls] = 7;
  if (arr[1] != 7) return 6;
  return 0;
}
