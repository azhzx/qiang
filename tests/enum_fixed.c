// std=c23
enum Small : unsigned char { S_A = 200, S_B };
enum Wide : unsigned { W_A = 4000000000u };
enum Signed : signed char { N_A = -5 };

struct Packed {
  char c;
  enum Small s;
  int i;
};

int main() {
  enum Small s = S_A;
  enum Wide w = W_A;
  enum Signed n = N_A;
  if (sizeof(enum Small) != 1) return 1;
  if (sizeof(enum Wide) != 4) return 2;
  if (sizeof(enum Signed) != 1) return 3;
  if (sizeof(struct Packed) != 8) return 4;
  if ((int)s != 200) return 5;
  if (S_B != 201) return 6;
  if (w != 4000000000u) return 7;
  if ((int)n != -5) return 8;
  return 0;
}
