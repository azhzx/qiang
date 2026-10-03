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
- `constexpr` as a constant-expression object (usable in `static_assert`,
  array bounds, ...), and `_BitInt(N)`
- `typeof_unqual`, `alignas`/`alignof`
- C23 attributes (`[[maybe_unused]]`, `[[noreturn]]`, `[[fallthrough]]`, ...)
- `static_assert`
- binary integer literals (`0b1010`), `u8'x'` character literals and digit
  separators (`1'000`, `0xFF'FF`, `0b1'010`)
- `char8_t` (a built-in name for `unsigned char`)
- `auto` type inference, sharing its implementation with GNU `__auto_type`
- fixed underlying enum types (`enum E : T`); the enum is represented by its
  underlying integer type

Known limitations:

- `const` objects are not constant expressions (standard C): only `constexpr`
  is, so `const int N = 3; static_assert(N == 3, "N")` is rejected while
  `constexpr int N = 3; static_assert(N == 3, "N")` is accepted.
- `char8_t` is treated as a built-in type name rather than the `<uchar.h>`
  typedef, so it cannot be shadowed.
- The feature matrix (status per construct, with the oracle fixtures that
  cover each) is in `../doc/qpcc.md`.

## C2y status

C2y syntax is opt-in through `-std=c2y`; C11 and C23 are unchanged.

Supported:

- `_Maxof(type-name)` / `_Minof(type-name)` (N3628): an integer type is
  required (`_Bool` is rejected) and the result is a constant of that type.
- `_Countof(expr)` / `_Countof(type-name)` (N3369): the operand must have
  array type and the result is the element count.
- Named loops (N3355): a `label:` on a loop or switch, and
  `break label;` / `continue label;`. A chain of labels names the same
  statement, and a duplicate label on a nested loop binds to the innermost.
- `_Defer` statements (TS 25755 / N3590): the deferred statement runs when
  its enclosing block is left, in reverse order, on any exit (falling off
  the end, `return`, `break`, `continue`, `goto` out). A jump that would
  leave the `_Defer` statement itself, and a `goto` into it, are diagnosed.

The friendly spellings live in hand-written headers under
`qpcc/include/qbe/`:

| Header | Macro |
| --- | --- |
| `stdcountof.h` | `countof` -> `_Countof` (N3469) |
| `stddefer.h` | `defer` -> `_Defer` (TS 25755) |
| `stdmaxof.h` | `maxof` -> `_Maxof` (QPCC extension) |
| `stdminof.h` | `minof` -> `_Minof` (QPCC extension) |

The last two have no WG14 proposal behind them; they are a QPCC convenience.
Pass `-I <qpcc>/qpcc/include/qbe` to the external preprocessor, as
`qpcc/test.sh` does for `std=c2y` fixtures. QPCC itself only recognizes the
underscore keywords.

## _Tagged_union status

`-f_tagged_union` enables a QPCC extension (no WG14 proposal) for tagged
unions:

```c
_Tagged_union Value { int as_int; float as_float; };
_Tagged_union Value x = { .as_int = 100 };
x = (_Tagged_union Value){ .as_float = 1.5f };   // sets the tag
switch (_Tag_of(x)) {
  case _Get_tag(_Tagged_union Value, as_int): break;
  case _Get_tag(_Tagged_union Value, as_float): break;
}
```

- The tag is a synthetic `int` at offset 0 and the members overlap after
  it, so the layout is `struct { int tag; union { members } payload; }` with
  natural alignment.
- A member cannot be assigned directly; change the value as a whole, e.g.
  `x = (_Tagged_union T){ .m = v };`. Reading a member whose tag is not
  current is undefined behaviour (no runtime check), and `&x.m` bypasses the
  tag.
- An initializer must name a member; a positional or empty list is
  diagnosed.
- Only `_Tagged_union Tag` names the type. clang implements none of this, so
  its fixtures are QPCC-only (`// expect-exit N`).
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

- `sh qpcc/test.sh` — clang oracle over `qpcc/tests/*.c` (148 fixtures).
- `moon test --target native qpcc/front qpcc/sema` — front-end and sema tests.
- `qpcc/chibicc-tests/` — a vendored chibicc subset used for parsing and
  end-to-end checks.
- The full C feature matrix (types, aggregates, C23, GNU extensions, known
  gaps): [`../doc/qpcc.md`](../doc/qpcc.md).
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
