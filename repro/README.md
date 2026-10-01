# Reproducers for known QPCC bugs

These are **not** part of the oracle (`qpcc/test.sh` only reads `qpcc/tests/*.c`).
Each one is a minimal program that QPCC still compiles wrongly. When a bug is
fixed, move the file into `qpcc/tests/` so the oracle keeps it fixed.

| File | Symptom |
| --- | --- |
| `call_before_loop.c` | A call right before a pointer-walking nested loop makes the loop never terminate. This is the shape of `vendor/qbe/simpl.c:blit`, where the self-hosted qbe hangs on `mem1.ssa` and eight other fixtures. |

```sh
cc -c qpcc/repro/call_before_loop.c -o /tmp/r.o
qpcc qpcc/repro/call_before_loop.c -o /tmp/rq.o
cc /tmp/rq.o -o /tmp/rq && /tmp/rq; echo $?   # expected 0
```

