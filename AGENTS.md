# Agent guide for Qiang

Qiang is a C11 front end and code generator written in MoonBit. It lowers C to
the `ir_builder` of [qbe.mbt](https://github.com/azhzx/qbe.mbt), which turns that
IR into Mach-O objects or assembly.

## Layout

| Path | What it is |
| --- | --- |
| `front/` | lexer, surface AST, parser (C11 + C23 + C2y + CQE + GNU extensions) |
| `sema/` | name resolution, types, layout, constant evaluation, diagnostics |
| `codegen/` | lowers the checked AST onto `ir_builder` |
| `qiang/` | the driver CLI (the executable is named after this package) |
| `include/qiang/` | hand-written headers that shadow the system ones |
| `tests/` | clang-oracle fixtures, see `test.sh` |
| `chibicc-tests/` | vendored chibicc corpus (MIT) |
| `examples/` | runnable examples (`examples/c/run.sh`) and the self-host demo |
| `tools/` | external-scan harness, bootstrap |

## Building and testing

- `moon build --target native` - needs the sibling `../qbe.mbt` checkout, which
  `moon.work` lists as a workspace member; `tools/bootstrap.sh` clones it;
- `moon test` - the unit tests (front end and sema);
- `sh test.sh` - builds the compiler, compiles every fixture in `tests/` with
  both clang and Qiang, runs them and compares exit codes and stdout;
- `sh examples/c/run.sh` - runs the bundled C examples;
- `python3 tools/scan_external.py` - compiles a corpus of third-party C
  projects (needs `build/scan/raw/`, see the script).

## Conventions

- MoonBit files are organised in blocks separated by `///|`; blocks are
  independent, so they can be moved around freely;
- run `moon fmt` and `moon info` before committing: `moon info` refreshes the
  `.mbti` interfaces, and a diff there means the public API changed;
- the C front end talks to the back end only through `ir_builder`; do not reach
  into qbe.mbt internals;
- tests that record structured output use snapshots: `moon test --update`, or
  `assert_eq` where the value is stable;
- user-facing diagnostics say what is wrong and who can fix it, with a
  `file:line:column` prefix.
## No simplified implementations (project rule)

This project is a port: whenever upstream QBE (`vendor/qbe`) has an
implementation, the port must transcribe it, not re-derive it.

The rule exists because every re-derivation has been a bug source:

- `pinned` was hand-copied from `ops.h` and drifted, dropping `blit0`/`blit1`,
  so gvn deleted half of a blit; it is generated now;
- `cfg/alias.mbt`'s `fillalias` had dropped five things from `alias.c`
  (`loc.sz`, `store()`, the blit store, the plain-store bookkeeping, the Jretc
  guard and the phi-argument escape), and `mem` had grown a private second
  copy that drifted from it;
- Qiang implemented its own aggregate convention (hidden first argument plus
  `memcpy`) instead of emitting `function :type $f` and `ret %addr`, so its
  objects could not be linked against clang's;
- `typ_of` picked `:type` field kinds from member size, making a `double` an
  integer field, so an HFA return was read from x0/x1 instead of d0/d1.

Practical consequences:

1. Before writing a function, look for its counterpart in `vendor/qbe` and
   transcribe it, including the corner cases (unreachable blocks, empty
   blocks, `-1` sentinels, C's unsigned arithmetic).
2. Do not add conditions the C does not have. Three of the bugs above were
   'improvements' (a guard on `slot_load`'s `radd`, a skip for zero-use allocs
   in `promote`, an inferred fall-through jump in the parser).
3. Do not keep two copies of one algorithm. If a pass needs another package's
   helper, make it public instead of duplicating it; duplication drifts and a
   fix to one copy does not reach the other.
4. Hand-written tables are forbidden. Parse them from `vendor/qbe` with a
   generator in `tools/` (see `tools/gen_op_pinned.py`).
5. A deviation is allowed only if upstream has no counterpart (the object
   writer, the JIT, the interpreter, the extra targets), and then it needs its
   own tests.
6. When a mismatch is found, compare against the reference binary, not against
   the port: `cd vendor/qbe && make` builds it, and `compare.py` plus the
   oracle are the judges.