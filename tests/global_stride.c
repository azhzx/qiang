struct Ref { unsigned type:3; unsigned val:29; };
struct Ins { int op; int cls; struct Ref to; struct Ref arg[2]; };
struct Ins arr[4096];
int main() { return (int)((char*)&arr[1] - (char*)&arr[0]) * 10 + (int)sizeof(struct Ins); }
