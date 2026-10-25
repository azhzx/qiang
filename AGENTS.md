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