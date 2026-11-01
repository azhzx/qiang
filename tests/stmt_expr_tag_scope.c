int main() {
  int first = ({ struct T { struct T *next; int x; } a; sizeof(struct T); });
  int second = ({ typedef struct T T; struct T { int x; }; sizeof(T); });
  return first == 16 && second == 4 ? 0 : 1;
}
