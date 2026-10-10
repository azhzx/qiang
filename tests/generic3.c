// _Generic coverage beyond int/double: lvalue conversion, array decay,
// pointer association types, distinct char types, nested selections and a
// controlling expression that is not itself an association type.
int pick(int i, double d, int *p, const int ci, int arr[4]) {
  if (_Generic(i, int: 1, default: 0) != 1) return 1;
  if (_Generic(d, float: 2, double: 3, default: 0) != 3) return 2;
  if (_Generic(p, double *: 4, int *: 5, default: 0) != 5) return 3;
  /* the controlling expression decays an array */
  if (_Generic(arr, int *: 6, default: 0) != 6) return 4;
  /* ... so an array type is not what is matched */
  if (_Generic(arr, int[4]: 7, default: 0) != 0) return 5;
  /* lvalue conversion drops the qualifier */
  if (_Generic(ci, int: 8, default: 0) != 8) return 6;
  /* the selection picks the branch, not the controlling expression */
  if (_Generic((char)0, int: 11, char: 12, default: 0) != 12) return 8;
  /* a nested selection */
  if (_Generic(_Generic(i, int: d, default: i), double: 13, default: 0) != 13)
    return 9;
  return 0;
}

int main(void) {
  int arr[4];
  return pick(0, 0.0, arr, 0, arr);
}
