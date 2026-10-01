struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { int op; int cls; struct Ref to; struct Ref arg[2]; };
int main() { return (int)sizeof(struct Ins) * 10 + (int)sizeof(struct Ref); }
