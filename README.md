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
  semantics), `_Complex` including single/double arithmetic, imaginary
  literals and `__real__`/`__imag__`, `_Alignas` on locals and globals.
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
- Some aggregate initializer edge cases are incomplete.
- Diagnostics carry statement-level positions.

## C23 status

`-std=c23` enables C23 syntax; the default standard is C11. Each item below
was checked end to end (compile, link with clang, run) unless noted otherwise.

Supported:

- `bool`/`true`/`false`, `nullptr`
- `constexpr`, `_BitInt(N)`
- `typeof_unqual`, `alignas`/`alignof`
- C23 attributes (`[[maybe_unused]]`, `[[noreturn]]`, ...)
- `static_assert` with literal constant expressions
- binary integer literals (`0b1010`) and `u8'x'` character literals
- `auto` type inference

Not supported (parse error):

- `char8_t`
- digit separators (`1'000`)
- fixed underlying enum types (`enum E : unsigned char`)
- `[[fallthrough]]` in statement position

Known limitations:

- `static_assert` does not evaluate named constants: `const int N = 3;
  static_assert(N == 3, "N")` fails, and `constexpr int N = 3` behaves the
  same, so `constexpr` currently acts as a constant expression in ordinary
  code but not in `static_assert`.
- The C23 tests in `qpcc/front/front_wbtest.mbt` cover parsing only, not code
  generation; the list above is from manual end-to-end checks.

## GNU extensions

Checked the same way. Supported:

- `__attribute__((unused))`, `__attribute__((noreturn))`
- `typeof`/`__typeof`/`__typeof__`, `__alignof__`
- statement expressions (`({ ... })`), including inside macros
- `__builtin_offsetof`, `__builtin_types_compatible_p`,
  `__builtin_constant_p`, `__builtin_expect`, `__builtin_unreachable`
- case ranges (`case 1 ... 5:`), `__extension__`, GNU `a ?: b`
- `__restrict`/`__const`/`__volatile`/`__signed`/`__inline`
- `__int128`, `__thread`
- `__real__`/`__imag__`
- `<stdarg.h>` (`va_list`, `va_start`, `va_arg`, `va_end`) after the
  external preprocessor

Parsed but ignored -- they do not change layout:

- `__attribute__((packed))`
- `__attribute__((aligned(N)))`

Not supported:

- `__auto_type` (rejected with an explicit error)
- assembly labels (`int f(void) __asm__("g");`) and nested functions
- `__builtin_va_list` as an assignable value (`aq = ap` hits an internal
  error)

## Testing

- `sh qpcc/test.sh` — clang oracle over `qpcc/tests/*.c` (73 fixtures).
- `moon test --target native qpcc/front qpcc/sema` — front-end and sema tests.
- `qpcc/chibicc-tests/` — a vendored chibicc subset used for parsing and
  end-to-end checks.
- `sh examples/qpcc-selfhost/build-qbe-with-qpcc.sh` — compiles the whole of
  `vendor/qbe` with QPCC, links it, and checks that the resulting `qbe` emits
  byte-identical assembly to a reference build over QBE's own test corpus.

## Self-hosting

QPCC builds QBE, and the binary it produces is itself a working QBE:

```sh
sh examples/qpcc-selfhost/build-qbe-with-qpcc.sh
# ... test corpus: 76 identical, 0 differing, 76 total
```

That is the large-scale check that the compiler is correct: about 17k lines of
ordinary C11, all three back ends, then 76 IL fixtures whose assembly output is
compared byte for byte against a clang-built reference. See
[`examples/qpcc-selfhost/`](../examples/qpcc-selfhost/README.md).
