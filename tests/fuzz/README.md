# Differential-fuzzing reproducers

`tools/fuzz_diff.py` generates random programs with fully defined behaviour and
compares clang's run against Qiang's. These files are cases where the two
disagreed, kept so they can be re-run as regression tests.

## crash_shift.c / crash_shift_min.ssa - fixed

Qiang used to segfault on this input. The front end and the IR were fine,
which made it look like the object emitter; a probe bisect put the fault in
`gvn`'s prologue, inside `narrowpars`, in the `usewidthle` query loop.

The cause was a data-structure difference from C. C's `Use` holds a pointer
into the instruction array, and `narrowpars` reorders that array without
touching the use table: the old array stays alive in the function arena, so
the pointers still name what they were built for. This port stores
`(block, index)`, so after the tail of the start block moves up by `npar` the
same index names a different instruction; `uwl` followed it, walked into a
cycle and recursed until the stack was gone.

`gvn.mbt` now re-addresses those use indices after the surgery, which is what
the pointer version gets for free. Fixed by `0bc2d3f`; the fuzzer went from
57/60 agreeing to 60/60 on the same seed.

`crash_shift_min.ssa` is the 22-line IR form, every block terminated, which the
reference `vendor/qbe` compiles without complaint.