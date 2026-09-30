int main() { double d = 0.0; return _Generic(d, int: 7, double: 8, default: 9); }
