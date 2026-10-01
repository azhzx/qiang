int side;
int hit(int x) { side = side + 1; return x; }
int main() { int r = 0; if (!r && hit(1)) r = 7; if (r || hit(9)) r = r + 1; return r + side; }
