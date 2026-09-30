struct P { int x; int y; };
int main() { struct P p; struct P *q; q = &p; q->x = 5; q->y = 6; return q->x * 10 + q->y; }
