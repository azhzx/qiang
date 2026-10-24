// std=cqe
// A local that is only ever read. That is legal C (a read of an
// uninitialised automatic object has an unspecified value), and the C front
// end can produce it in two ways: a read before any write, or an inline asm
// output operand, which this port parses but cannot execute:
//     __asm__("..." : "=&r"(result));   /* result is never stored */
// promote used to abort on such a slot with "slot ... is read but never
// stored to" - QBE treats that as impossible because its own front end never
// produces one. The slot is now left in memory instead.
unsigned long long acc10(unsigned long long acc, unsigned long long d) {
  unsigned long long result;
  __asm__("add %0, %2, %2, lsl #2\n\tadd %0, %1, %0, lsl #1"
          : "=&r"(result)
          : "r"(d), "r"(acc));
  return result;
}

int main(void) {
  // The asm result is not modelled, so it is only used in a way that does not
  // depend on its value: this test is about compiling, not about the result.
  unsigned long long v = acc10(1, 2);
  (void)v;
  return 0;
}
