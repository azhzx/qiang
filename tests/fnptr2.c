int inc(int x) { return x + 1; }
int apply(int (*f)(int), int v) { return f(v); }
int main() { return apply(inc, 10); }
