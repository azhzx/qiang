int x = 0;
int main() {
  __atomic_store_n(&x, 5, 5);
  __atomic_load_n(&x, 5);
  __atomic_thread_fence(5);
  return __atomic_load_n(&x, 5);
}
