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

# one step: preprocess, compile, link and run
qpcc run hello.c [-- args...]

# or drive the pieces yourself
qpcc input.c -o input.o [--emit obj|asm|qbe] [-std=c11|c23|c2y] [--check]
clang input.o -o a.out
```

`qpcc run` drives clang for the parts QPCC does not own: it preprocesses with
`clang -E -P` (so `#include`/`#define` work and the headers under
`qpcc/include/qbe/` are found when run from the repository root; `QPCC_INCLUDE`
overrides that), compiles with QPCC, links with clang, runs the program and
forwards its exit status. `-I`/`-D`/`-U` go to the preprocessor and everything
after `--` goes to the program. It needs clang on PATH and says so if it is
missing.

Without `run` the C preprocessor is external: run `clang -E -P` before `qpcc`
when the input uses `#include`/`#define`. Plain `#` lines are stripped by the
driver for convenience.

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
The QPCC-only keywords are not part of this mode: see `-std=cqe` below.

The friendly spellings live in hand-written headers under
`qpcc/include/qbe/`:

| Header | Macro |
| --- | --- |
| `stdcountof.h` | `countof` -> `_Countof` (N3469) |
| `stddefer.h` | `defer` -> `_Defer` (TS 25755) |
| `stdmaxof.h` | `maxof` -> `_Maxof` (QPCC extension) |
| `stdminof.h` | `minof` -> `_Minof` (QPCC extension) |
| `taggedunion.h` | `tagunion` -> `_Tagged_union`, `static_tag` -> `_Static_tag`, `dynamic_tag` -> `_Dynamic_tag` (QPCC extension) |
| `function_pointer.h` | `function_pointer` -> `_Function_pointer` (N3914) |
| `lambda.h` | `lambda` -> `_Lambda`, `closure_environment` -> `_Closure_environment` (QPCC extension) |

The tagged-union, maxof/minof and lambda headers have no WG14 proposal behind
them; they are a QPCC convenience.
Pass `-I <qpcc>/qpcc/include/qbe` to the external preprocessor, as
`qpcc/test.sh` does for `std=c2y` fixtures. QPCC itself only recognizes the
underscore keywords.

## CQE status

`-std=cqe` is **C2y plus the QPCC extensions**, so `-std=c2y` stays exactly
C2y:

- `_Function_pointer`, the prefix spelling of a function pointer type, and the
  bare form as the storage type for any function pointer (N3914).
- `_Lambda` closures, with by-value and by-reference captures, and
  `_Closure_environment` for the captured environment.
- `_Tagged_union` / `_Static_tag` / `_Dynamic_tag` (also available on their
  own through `-f_tagged_union` in any mode).
- `void x = expr;`, which declares no object.

Using a QPCC keyword under `-std=c2y` is diagnosed with a pointer at
`-std=cqe`.

## _Tagged_union status

`-f_tagged_union` enables a QPCC extension (no WG14 proposal) for tagged
unions:

```c
_Tagged_union Value { int as_int; float as_float; };
_Tagged_union Value x = { .as_int = 100 };
x = (_Tagged_union Value){ .as_float = 1.5f };   // sets the tag
switch (_Dynamic_tag(x)) {
  case _Static_tag(_Tagged_union Value, as_int): break;
  case _Static_tag(_Tagged_union Value, as_float): break;
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
- The tag is optional, so `typedef _Tagged_union { ... } Value;` defines an
  anonymous one and `Value` stands for the type. clang implements none of
  this, so its fixtures are QPCC-only (`// expect-exit N`).
## _Function_pointer status

The prefix spelling of a function pointer type, plus the storage type for any
function pointer from [N3914](https://open-std.org/Jtc1/Sc22/WG14/www/docs/n3914.htm):

```c
_Function_pointer int (int, char *) a;   /* int (*a)(int, char *) */
_Function_pointer b = a;                 /* stores any function pointer */
int (*c)(int, char *) = b;               /* ... and converts back */
```

- `_Function_pointer T (params)` is exactly `T (*)(params)`, so it composes
  with declarators and arrays.
- The bare form is N3914's `_Any_func*`: it converts implicitly to and from
  every function pointer type and to and from `void *` (the target platforms
  have a unified address space, so the optional conversions are supported).
- It is deliberately **not callable** (N3914 4.1): there is no single ABI for
  "all function calls", so a cast to the concrete signature is required first.
  Calling one is diagnosed.
- `_Generic` still tells it apart from a real function pointer type
  (N3914 4.6), so adding it changes no existing compatible type.

## _Lambda status

```c
int a = 100, b = 20;
auto f = _Lambda(a, &b) int (int x, int y) { return a + (*b) + x + y; };
int *pb = _Closure_environment(f)->b;
```

- A closure is a two-word `{ function pointer, environment pointer }` value.
  The written type `_Lambda T (params)` is just the signature, so two
  closures with the same signature are the same type and can be assigned and
  copied.
- The environment is a synthesized struct with one field per capture, in
  capture order: a by-value capture stores the variable's value at creation
  time, a by-reference capture stores its address.
- The body becomes a hidden function whose leading parameter is the
  environment. Inside it a capture name is bound to its environment field, so
  a by-value capture is the copy (`a` has type `int` above) and a
  by-reference capture is the stored pointer (`b` has type `int *`).
- The environment is a local of the enclosing function, so a closure that
  outlives the scope it was created in is undefined behaviour.
- Calling a closure supplies the environment as the hidden leading argument;
  the closure must be an lvalue.
- `_Closure_environment` needs a closure whose captured environment is known,
  which is what the type of a `_Lambda` expression (and so `auto`) carries;
  the written type names no environment and is diagnosed.

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

- `sh qpcc/test.sh` — clang oracle over `qpcc/tests/*.c` (151 fixtures).
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
