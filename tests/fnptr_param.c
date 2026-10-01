int apply(int cb(int), int x) { return cb(x); }
int inc(int x) { return x + 1; }
int main() { return apply(inc, 3); }
