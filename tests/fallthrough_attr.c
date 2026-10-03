// std=c23
int main() {
  int s = 0;
  switch (2) {
    case 1:
      s += 1;
      [[fallthrough]];
    case 2:
      s += 2;
      [[fallthrough]];
    case 3:
      s += 4;
      break;
    default:
      s = 99;
  }
  return s - 6;
}
