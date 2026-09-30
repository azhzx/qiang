int table[4] = {10, 20, 30, 40};
char msg[] = "hi";
char *sp = "world";
struct P { int x; char *s; };
struct P gp = {7, "abc"};
int main() { return table[2] + msg[1] + sp[0] + gp.x + gp.s[1]; }
