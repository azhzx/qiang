struct T { char chr; double fltd; float flts; long num; char *str; };
struct T tok;
int main() { return (int)sizeof(struct T) * 100 + (int)((char*)&tok.str - (char*)&tok); }
