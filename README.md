# QPCC — the Qopple C compiler

QPCC is the C11 front end and code generator that targets the qbe.mbt IR
builder. It is the only C compiler in this repository: the historical
parser/codegen that lived directly in `qpcc/` has been removed.

## Pipeline

```
source.c --(clang -E)--> tokens --(front)--> AST
         --(sema)--> CheckedProgram --(codegen)--> ir_builder --> Mach-O / asm
```

| Package | Role |
| --- | --- |
| `qpcc/front` | lexer, surface AST, full C11 + GNU-extension parser (`-std=c11|c23`) |
| `qpcc/sema` | name resolution, types, layout, constant evaluation, diagnostics |
| `qpcc/codegen` | lowers the checked AST onto `ir_builder` |
| `qpcc/cmd` | driver CLI |

## Usage

```sh
moon build --target native qpcc/cmd
qpcc input.c -o input.o [--emit obj|asm|qbe] [-std=c11|c23] [--check]
clang input.o -o a.out
```

The C preprocessor is external: run `clang -E -P` before `qpcc` when the input
uses `#include`/`#define`. Plain `#` lines are stripped by the driver for
convenience.

## Supported

- C11 syntax plus the GNU extensions the parser accepts, with `-std=c11|c23`.
- Types: `void`, `_Bool`, `char`/`short`/`int`/`long`/`long long`, `float`,
  `double`, `long double` (8 bytes on arm64), pointers, arrays including VLA,
  functions, `struct`/`union`/`enum`, bitfields, `_Atomic` (single-threaded
  semantics), `_Complex` (type and layout).
- Expressions, statements, `switch`, `goto`, statement expressions, compound
  literals, `__builtin_offsetof`, `__builtin_types_compatible_p`, designated
  initializers.
- Variadic function definitions (`va_start`/`va_arg`/`va_end`/`va_copy`).
- Bitfield reads and read-modify-write updates.
- Global aggregate, string, designated and address-constant initializers.
- Computed goto (`goto *p`) and arrays of label addresses (`&&label`).
- Sequentially consistent atomics: atomic load/store (`ldar`/`stlr`) and fences
  (`dmb ish`).
- Code generation for Mach-O arm64 through `ir_builder`.

## Limitations

- The preprocessor is external (`clang -E`); preprocessor tests are out of scope.
- Atomics currently cover sequentially consistent load/store and fences; the
  read-modify-write forms (exchange, compare-exchange, fetch-add, ...) still need
  LL/SC or LSE lowering.
- `_Complex` arithmetic and some aggregate initializer edge cases are
  incomplete.
- Diagnostics carry statement-level positions.

## Testing

- `sh qpcc/test.sh` — clang oracle over `qpcc/tests/*.c` (57 fixtures).
- `moon test --target native qpcc/front qpcc/sema` — front-end and sema tests.
- `qpcc/chibicc-tests/` — a vendored chibicc subset used for parsing and
  end-to-end checks.
