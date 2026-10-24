// std=cqe
// gcm treated atomicstore as movable, so the value it uses was never
// scheduled, lateblk dropped the phi that defined it, and SSA verification
// then reported a dangling use ("b.N is used undefined in @logic.join.N").
// sqlite3_soft_heap_limit64 stores "n>0 && n<=nUsed" with __atomic_store_n and
// hit exactly this. QBE has no atomics, so the pinned column is written by
// hand in gvn/gcm.mbt: op_pinned.
static int flag;
static long long hard;
static int nUsed;

long long f(long long n) {
  long long prior = 7;
  if (n < 0) return prior;
  if (hard > 0 && (n > hard || n == 0)) n = hard;
  __atomic_store_n(&flag, (n > 0 && n <= nUsed), 0);
  return n;
}

int main(void) {
  if (f(1) != 1) return 1;
  if (f(-1) != 7) return 2;
  if (f(3) != 3) return 3;
  return 0;
}
