int strcmp(const char*, const char*);
int main(int ac, char **av) {
  char *f = av[1];
  if (!f || strcmp(f, "-") == 0) return 1;
  return 2;
}
