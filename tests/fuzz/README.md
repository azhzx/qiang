# Differential-fuzzing reproducers

`tools/fuzz_diff.py` generates random programs with fully defined behaviour and
compares clang's run against Qiang's. These files are cases where the two
disagree, kept so they can be re-run as regression tests.

## crash_shift.c / crash_shift.ssa

Qiang segfaults (SIGSEGV) on this 9-line input. The front end and the IR are
fine: `--check` passes, and `--emit qbe` produces IR that the reference
`vendor/qbe/qbe` compiles without complaint. The fault is therefore in the
arm64 object emitter that `ir_builder.emit_object` reaches
(`@qbe.compile_ir_object`), i.e. in qbe.mbt.

Minimised from a 26-line generated program by deleting lines while it kept
crashing (see /tmp/delta_min.py in that session; the predicate must match
SIGSEGV specifically, because an ordinary diagnostic panics with SIGABRT).