# Qiang — C language support

[中文版本 (Chinese Version)](zh/Qiang.md)

Qiang (`Qiang/`) is the C front end and code generator that lowers C to the
qbe.mbt IR builder and from there to Mach-O arm64. This page is the feature
matrix: what it accepts and lowers, what is partial, and what is missing.

## Evidence

- `sh Qiang/test.sh` — the clang oracle over `Qiang/tests/*.c` (134 fixtures):
  each file is compiled with clang and with Qiang, both objects are linked, both
  binaries run, and exit code and stdout are compared. All 134 pass.
- `moon test --target native Qiang/front Qiang/sema` — lexer/parser and semantic
  analyser whitebox tests.
- `examples/Qiang-selfhost/` — Qiang compiles the whole of vendored QBE and the
  resulting binary passes 58/58 semantic fixtures.
- `Qiang/chibicc-tests/` — a vendored chibicc subset kept as a reference corpus
  (not run by `test.sh`).

The fixture column below names the oracle cases that cover a feature, or
"sweep" for a hand-run end-to-end check.

## Modes

| Mode | Flag | Notes |
| --- | --- | --- |
| C11 | default, `-std=c11` | the baseline |
| C23 | `-std=c23` | C23 syntax on top of the same front end; partial (see below) |
| C2y | `-std=c2y` | C2y syntax on top of the same front end; see the C2y section |
| CQE | `-std=cqe` | C2y **plus the Qiang extensions** ("C with Qiang extensions"); non-standard, see the CQE section |

The C preprocessor is **external**: run `clang -E -P` before Qiang when the
input uses `#include`/`#define`. The driver only strips the remaining lines
that begin with `#`, so a bare `#define`d name is *not* expanded.

## Legend

- **yes** — compiled, linked and run correctly.
- **partial** — accepted, but a semantic or layout detail is missing.
- **no** — rejected or unsupported.

## Running a program

```sh
Qiang run hello.c            # preprocess, compile, link and run
Qiang run hello.c -- one two # ... with program arguments
```

`Qiang run` drives clang for the parts Qiang does not own: it preprocesses the
input with `clang -E -P` (so `#include` and `#define` work, and the headers
under `Qiang/include/qbe/` are on the include path when run from the
repository root; set `Qiang_INCLUDE` to override), compiles the result with
Qiang, links it with clang and executes it, forwarding the program's exit
status. `-I`, `-D` and `-U` are passed to the preprocessor, and everything
after `--` goes to the program. It needs clang on PATH and says so if it is
missing.

The plain form is still available and does not need clang: `Qiang input.c
--emit obj|asm|qbe` writes an object, assembly or QBE IL, and the preprocessor
is then external.

## Types

| Feature | Status | Evidence |
| --- | --- | --- |
| `void`, `_Bool` | yes | `bool` |
| `char`, `signed`/`unsigned char` | yes | `char`, `uchar` |
| `short`, `int`, `long`, `long long` | yes | `short`, `longlong`, `arith` |
| signed/unsigned arithmetic, conversions, usual arithmetic conversions | yes | `unsigned`, `ushr`, `uint_widen`, `shift_signedness`, `op_size` |
| `float`, `double` | yes | `float`, `float2` |
| `long double` (8 bytes on arm64) | yes | sweep |
| `_Complex` (arithmetic, literals, `__real__`/`__imag__`, mixed) | yes | `complex_add`, `complex_addmix`, `complex_cmp`, `complex_compound`, `complex_div`, `complex_float`, `complex_lit`, `complex_mixed`, `complex_mul`, `complex_real_imag`, `complex_sub`, `complex_unary` |
| `__int128` | yes | sweep |
| pointers | yes | `ptr`, `ptr2`, `ptr_index_diff`, `alias_shape` |
| arrays, including multi-dimensional | yes | `arr`, `arr_member`, `arr_member_loop`, `static_ptr2d`, `static_ptr2d_b`, `static_ptr2d_c` |
| variable-length arrays | partial | `sizeof_vec`; indexing works, but `sizeof` returns the pointer/element size, not the runtime length |
| functions and function pointers | yes | `fnptr`, `fnptr2`, `fnptr_param` |
| `_BitInt(N)` | yes (C23) | sweep |
| `char8_t` | yes (C23) | `char8_t`; a built-in name for `unsigned char` |
| `_Decimal*`, `_Fract`, `_Accum` | no | — |

## Declarations and storage

| Feature | Status | Evidence |
| --- | --- | --- |
| `typedef`, typedef chains | yes | `typedef`, `typedefptr`, `typedefstruct`, `bf_typedef` |
| globals, tentative definitions, BSS | yes | `global`, `global2`, `globals`, `bss_zero`, `global_struct`, `global_ptr`, `global_stride`, `global_bitfield` |
| `static` locals and file-scope `static` | yes | `static_ptr`, `static_ptr2d`, `static_desig` |
| `extern` | yes | `chibicc-tests/tests/extern.c` |
| `const`, `volatile` | yes | sweep |
| `restrict` (and `__restrict`) | yes | sweep |
| `inline` (and `__inline`) | yes | sweep |
| `register`, `auto` | yes | sweep |
| `_Thread_local` / `__thread` | yes | sweep |
| `_Alignas` (locals and globals, up to 16-byte stack alignment) | partial | `alignas`, `alignas_global`; larger requests are diagnosed |
| `_Alignof` | yes | `alignof` |
| `_Noreturn` | yes | sweep |
| `__attribute__((unused))`, `((noreturn))` | yes | sweep |
| `__attribute__((packed))` | partial | parsed but ignored — it does not change `sizeof` |
| `__attribute__((aligned(N)))` | partial | parsed but ignored — it does not change alignment |
| `__auto_type` | no | explicit "not supported" error |
| `void x = expr;` — evaluates `expr` and declares nothing | yes | `void_init`; the name never reaches the local table, and a bare `void x;` is still rejected |
| K&R (old-style) function definitions | no | — |
| nested functions | no | parse error |

## Aggregates and layout

| Feature | Status | Evidence |
| --- | --- | --- |
| `struct` | yes | `struct`, `structarr`, `structptr`, `structsz`, `struct_ptr_index`, `global_struct` |
| `union` | yes | `union` |
| anonymous `struct`/`union` members | yes | sweep |
| empty `struct`/`union` (GNU extension, no members) | yes | a zero-sized type: `sizeof` is 0 and `_Alignof` is 1 |
| `enum` (explicit values, gaps, duplicates) | yes | `enum`, `enum_gap`, `shift_enum` |
| C23 `enum E : T` fixed underlying type | yes | `enum_fixed`; the enum is its underlying integer type |
| by-value struct arguments and returns, nested aggregates | yes | `ins_byval`, `ref_byval`, `nested`, `aggregate_double` |
| bitfields — unsigned fields, globals, arguments | yes | `bitfield`, `bitfield_2929`, `bitfield_top`, `bf_arg`, `bf_global`, `bf_pos`, `global_bitfield` |
| bitfields — some signed combinations | partial | `struct { int a:3; int b:2; }` misreads the field values |
| flexible array members | partial | `sizeof` is right, storage is the caller's job |
| `#pragma pack` | no | preprocessor is external |

## Initializers

| Feature | Status | Evidence |
| --- | --- | --- |
| scalar and aggregate initializers | yes | `initarr`, `initstruct`, `compound_char`, `compound_zero` |
| designated initializers (arrays, structs, order, gaps) | yes | `designated_dec`, `designated_gap`, `designated_inc`, `designated_int`, `designated_order`, `designated_ptr` |
| compound literals, including at file scope | yes | `file_compound_ptr` |
| string initializers | yes | `str`, `string` |
| address-constant initializers and relocations | yes | `static_desig`, `global_ptr` |
| `sizeof` of a string literal or a string-initialised `char[]` | partial | `sizeof("ab")` is 8 and `sizeof(char s[] = "ab")` is 0, not 3 |

## Expressions and operators

| Feature | Status | Evidence |
| --- | --- | --- |
| arithmetic, bitwise, comparison, logical operators | yes | `arith`, `logic`, `op_tab`, `optab_shape` |
| short-circuit `&&` / `\|\|` and `\|\|` chains | yes | `shortcircuit`, `or_short` |
| conditional `?:`, including the GNU `a ?: b` | yes | `cond`, `cond_arm_width` |
| assignment and compound assignment, `++`/`--` | yes | sweep |
| casts, integer promotions, word/wide conversions | yes | `cast`, `widen_word_const`, `store_wide_const`, `uint_widen` |
| `sizeof` of types, expressions and arrays | yes | `sizeof`, `sizeof_ins`, `sizeof_vec`, `op_size` |
| `_Generic` | yes | `generic`, `generic2` |
| `_Static_assert` | yes | `staticassert` |
| C2y `_Countof(expr)` / `_Countof(type-name)` | yes | `countof` |
| C2y `_Maxof(type-name)` / `_Minof(type-name)` | yes | `maxminof` |
| `__builtin_offsetof`, `__builtin_types_compatible_p`, `__builtin_constant_p`, `__builtin_expect`, `__builtin_unreachable` | yes | sweep |
| `typeof`/`__typeof__`/`typeof_unqual`, `__alignof__` | yes | sweep |
| statement expressions `({ ... })`, including inside macros | yes | sweep |
| `__extension__` | yes | sweep |
| `__real__`, `__imag__` | yes | `complex_real_imag` |
| `__builtin_va_arg`, `<stdarg.h>` | yes | after `clang -E`; sweep |
| `__builtin_va_list` as an assignable value | no | `aq = ap` hits an internal error |
| C23 `auto` inference and `__auto_type` | yes | `auto_infer`; a single plain declarator with an initializer |

## Statements and control flow

| Feature | Status | Evidence |
| --- | --- | --- |
| `if`/`else`, `for`, `while`, `do`/`while` | yes | `if`, `for`, `while`, `dowhile` |
| `switch`/`case`/`default`, fallthrough, jump into `default` | yes | `switch`, `switchfall`, `switch_into_default`, `switch_duff2` |
| `break`, `continue`, `goto` (forward and loops) | yes | `gotofwd`, `gotoloop` |
| computed goto `goto *p` and `&&label` | yes | `computed_goto` |
| Duff's device | yes | `duff`, `switch_duff2` |
| case ranges `case 1 ... 5:` | yes | sweep |
| C2y named loops: `label:` on a loop/switch, `break label;`, `continue label;` | yes | `named_loops` |
| C2y `_Defer` statements | yes | `defer_basic`, `defer_header` |
| C23 `[[fallthrough]]` in statement position | yes | `fallthrough_attr` |

## Functions

| Feature | Status | Evidence |
| --- | --- | --- |
| definitions, prototypes, K&R-free declarations | yes | `fib`, `m0_return42`, `three_ref` |
| variadic definitions (`va_start`/`va_arg`/`va_end`/`va_copy`) | yes | `vararg`, `vararg_def` |
| indirect calls | yes | `fnptr`, `fnptr2`, `fnptr_param` |
| inline assembly / `asm` labels | no | `asm` label panics; inline `asm` is not lowered |

## Literals and strings

| Feature | Status | Evidence |
| --- | --- | --- |
| integer literals (decimal, hex, octal, binary), suffixes | yes | `big_const`, `widen_word_const` |
| floating literals | yes | `float`, `float2` |
| character literals, `u8'x'` | yes | sweep |
| string literals with escapes | partial | a plain string works; `"a\nb"` can fail to parse |
| wide/UTF strings `L`, `u`, `U` | no | parses, but the elements are wrong at run time |
| C23 digit separators (`1'000`) | no | parse error |

## Atomics

| Feature | Status | Evidence |
| --- | --- | --- |
| sequentially consistent load/store (`ldar`/`stlr`) and fences (`dmb ish`) | yes | `atomics` |
| read-modify-write forms (exchange, compare-exchange, fetch-add, ...) | no | needs LL/SC or LSE lowering |

## C23 (`-std=c23`)

| Feature | Status | Evidence |
| --- | --- | --- |
| `bool`/`true`/`false`, `nullptr` | yes | sweep |
| `constexpr` | yes | `constexpr_assert`; an object usable in constant expressions |
| `_BitInt(N)` | yes | sweep |
| `typeof_unqual`, `alignas`/`alignof` | yes | sweep |
| C23 attributes `[[...]]` (`[[maybe_unused]]`, `[[noreturn]]`) | yes | sweep |
| `static_assert` over literal constants | yes | sweep |
| binary literals `0b1010`, `u8'x'` | yes | sweep |
| `auto` type inference | yes | `auto_infer` |
| `char8_t` | yes | `char8_t` |
| digit separators (`1'000`) | yes | `digit_sep` |
| fixed underlying enum types (`enum E : unsigned char`) | yes | `enum_fixed` |
| `[[fallthrough]]` in statement position | yes | `fallthrough_attr` |

## C2y (`-std=c2y`)

C2y syntax is opt-in through `-std=c2y`; C11 and C23 are unchanged.

| Feature | Status | Evidence |
| --- | --- | --- |
| `_Maxof(type-name)` / `_Minof(type-name)` (N3628) | yes | `maxminof`; an integer type is required, `_Bool` is rejected, and the result is a constant of that same type |
| `_Countof(expr)` / `_Countof(type-name)` (N3369) | yes | `countof`; the operand must have array type |
| named loops (N3355): `label:` on a loop or switch, `break label;`, `continue label;` | yes | `named_loops` |
| `_Defer` statements (TS 25755 / N3590) | yes | `defer_basic`, `defer_header` |
The Qiang-only keywords are **not** part of this mode; see CQE below.

The friendly spellings come from hand-written headers under
`Qiang/include/qbe/`: `stddefer.h` (`defer` -> `_Defer`), `stdcountof.h`
(`countof` -> `_Countof`), the Qiang extensions `stdmaxof.h`
(`maxof` -> `_Maxof`) and `stdminof.h` (`minof` -> `_Minof`), and the
headers for this repository's own extensions: `taggedunion.h`
(`tagunion` -> `_Tagged_union`, `static_tag` -> `_Static_tag`,
`dynamic_tag` -> `_Dynamic_tag`), `function_pointer.h`
(`function_pointer` -> `_Function_pointer`) and `lambda.h` (`lambda` ->
`_Lambda`, `closure_environment` -> `_Closure_environment`). The external
preprocessor finds them with `clang -E -P -I <Qiang>/Qiang/include/qbe`;
Qiang itself only knows the underscore keywords.

Known limitations:

- `_Defer` runs when its enclosing block is left, in reverse order, on any
  exit (falling off the end, `return`, `break`, `continue`, `goto` out).
  A jump that would leave the `_Defer` statement itself, and a `goto` into
  it, are diagnosed; `longjmp` past a defer is undefined, as the TS says.
- clang does not implement `_Maxof`/`_Minof`, named loops or `_Defer` yet,
  so those fixtures are Qiang-only (`// expect-exit N`), checked against their
  expected exit code rather than a clang reference.

## CQE (`-std=cqe`)

`-std=cqe` is **C2y plus the Qiang extensions**. It exists so that
`-std=c2y` stays exactly C2y: everything below is non-standard and needs the
Qiang mode, while the C2y proposals above (`_Countof`, `_Maxof`/`_Minof`,
named loops, `_Defer`) work under plain `-std=c2y`.

| Feature | Status | Evidence |
| --- | --- | --- |
| `_Function_pointer T (params) name` and bare `_Function_pointer` | yes | `function_pointer` |
| `_Lambda(captures) T (params) { body }` closures, `_Closure_environment` | yes | `lambda` |
| `_Tagged_union` / `_Static_tag` / `_Dynamic_tag` | yes | `tagged_union`, `taggedunion_header` |
| `void x = expr;` declares nothing and only evaluates `expr` | yes | `void_init` |

The tagged union is also available on its own in any mode through
`-f_tagged_union`. Using a Qiang keyword under `-std=c2y` is diagnosed with a
pointer at `-std=cqe` rather than left as a plain syntax error.

## `_Tagged_union` (`-f_tagged_union`, or `-std=cqe`)

A Qiang extension with no WG14 proposal behind it. It is opt-in through
`-f_tagged_union`; without the flag the three keywords are ordinary
identifiers, so C11/C23/C2y are unchanged.

```c
_Tagged_union Value {
  int as_int;
  float as_float;
};

_Tagged_union Value x = { .as_int = 100 };
x = (_Tagged_union Value){ .as_float = 1.5f };  /* sets the tag */
switch (_Dynamic_tag(x)) {
  case _Static_tag(_Tagged_union Value, as_int): break;
  case _Static_tag(_Tagged_union Value, as_float): break;
}
```

| Feature | Status | Evidence |
| --- | --- | --- |
| `_Tagged_union Tag { members }` | yes | `tagged_union` |
| natural layout: an `int` tag at offset 0, the members overlapping after it | yes | `{ int; float }` is 8 bytes, `{ int; double }` is 16 |
| `x.m` read | yes | `tagged_union` |
| `_Dynamic_tag(x)`, an `int` rvalue | yes | `tagged_union` |
| `_Static_tag(_Tagged_union T, m)`, an integer constant expression | yes | `tagged_union` (`_Static_assert` and `case`) |
| designated initializers: local, compound literal, global, static | yes | `tagged_union`, `tagged_union_static` |

Semantics and limitations:

- The tag is a synthetic `int` at offset 0 and the members overlap after it,
  so the layout is exactly `struct { int tag; union { members } payload; }`.
- A member cannot be assigned directly: `x.m = v`, `x.m += v`, `x.m++` and a
  store to a nested member are all diagnosed. Change the value as a whole
  instead, e.g. `x = (_Tagged_union T){ .m = v };`, which sets the tag.
  Discriminators are the member declaration order, 0-based.
- Reading a member whose tag is not current is undefined behaviour; there is
  no runtime check. Taking the address of a member and writing through it
  also bypasses the tag: `&x.m` is allowed, but the invariant is then the
  programmer's responsibility.
- An initializer must name a member, as in `{ .as_int = 100 }`. A positional
  element (`{ 1 }`, `{ 0 }`) or an empty list (`{}`) is diagnosed. The last
  designator wins, as for a union.
- A tagged union is named either as `_Tagged_union Tag` or through a typedef:
  the tag is optional, so `typedef _Tagged_union { ... } Value;` defines an
  anonymous one and `Value` then stands for the type everywhere (including
  `_Static_tag`). There is no bare alias for a tag that was written.
- clang implements none of this, so the fixtures are Qiang-only
  (`// expect-exit N`) and are checked against their expected exit code.
## `_Function_pointer` (`-std=cqe`)

The prefix spelling of a function pointer type, together with the storage type
for any function pointer described by
[N3914](https://open-std.org/Jtc1/Sc22/WG14/www/docs/n3914.htm)
("Any func* - A Universal Function Pointer Storage Type"):

```c
_Function_pointer int (int, char *) a;   /* int (*a)(int, char *) */
_Function_pointer b = a;                 /* stores any function pointer */
int (*c)(int, char *) = b;               /* ... and comes back out */
```

| Feature | Status | Evidence |
| --- | --- | --- |
| `_Function_pointer T (params) name` | yes | `function_pointer` |
| bare `_Function_pointer`, convertible to and from every function pointer type | yes | `function_pointer` |
| `_Function_pointer` <-> `void *` both ways | yes | `function_pointer`; the target platforms have a unified address space, so the optional N3914 conversions are supported |
| not callable without a cast (N3914 4.1) | yes | diagnosed: "a _Function_pointer cannot be called" |
| `_Generic` still tells the storage type apart from a real function pointer type (N3914 4.6) | yes | `function_pointer` |

The written type is exactly `T (*)(params)`, so `_Function_pointer` composes
with declarators and arrays: `_Function_pointer int (int) table[2];`.
`<function_pointer.h>` provides the friendly `function_pointer` spelling.

## `_Lambda` closures (`-std=cqe`)

```c
int a = 100, b = 20;
auto f = _Lambda(a, &b) int (int x, int y) { return a + (*b) + x + y; };
int *pb = _Closure_environment(f)->b;   /* the captured environment */
```

| Feature | Status | Evidence |
| --- | --- | --- |
| `_Lambda(captures) T (params) { body }` | yes | `lambda` |
| the closure type `_Lambda T (params)` | yes | `lambda` |
| `_Closure_environment(e)`, the environment pointer | yes | `lambda` |
| by-value and by-reference captures | yes | `lambda` |

A closure is a two-word `{ function pointer, environment pointer }` value; the
written type is just the signature, so two closures with the same signature have
the same type and can be assigned and copied. The environment is a synthesized
struct with one field per capture, in capture order: a by-value capture stores
the variable's value at creation time, a by-reference capture stores its
address. The body becomes a hidden function whose leading parameter is the
environment, and inside it a capture name is bound to its environment field, so
a by-value capture reads and writes the copy and a by-reference capture is the
stored pointer:

```c
_Lambda(a, &b) int (void) { ... }
/* in the body: a has type int, b has type int * */
```

Semantics and limitations:

- The environment is a local of the enclosing function, so a closure that
  outlives the scope it was created in is undefined behaviour.
- Calling a closure supplies the environment as the hidden leading argument;
  the closure must be an lvalue.
- Assigning a closure whose captures differ from the one that created it is
  not diagnosed; reading the environment is then undefined behaviour, in the
  same spirit as reading the wrong member of a tagged union.
- `_Closure_environment` needs a closure whose captured environment is known,
  which the type of a `_Lambda` expression (and so `auto`) carries; the
  written type `_Lambda T (params)` names no environment and is diagnosed.

### Closures cannot live in globals

A `_Lambda` expression builds a `{ function, environment }` pair whose
environment is a local of the enclosing function. A file-scope variable has no
enclosing function, so a global cannot be initialised with a closure:

```c
static _Lambda int (int, int) add = _Lambda int (int x, int y) { ... };
/* error: a global variable cannot be initialised with a closure */
```

Move the closure inside a function, or store a plain function pointer instead.
The front end reports this rather than emitting a null function pointer, which
would compile, link and then segfault on the first call.

## Pseudo-templates

A Qiang extension, available in `-std=cqe`. An identifier that ends in `_`
followed by `([` takes a comma-separated list of type spellings and stands for
the identifier with a hash of that spelling appended:

```c
#define MkResult(T, E) typedef tagunion { T ok; E err; } Result_([T, E]);

MkResult(int, int)
MkResult(int, float)

Result_([int, int]) a = { .ok = 100 };
```

The arguments are matched **by spelling**, not resolved, so `int` and
`signed int` are different instantiations, and a typo silently names a type
that no declaration ever defined. This is what makes the feature "pseudo": it
is a naming convention the front end understands, not a generic type system.

Identifier characters glued to an instantiation without whitespace join the
name, the way the preprocessor pastes tokens, so one instantiation can carry a
family of associated declarations:

```c
#define MkResult(T, E) \
  typedef tagunion { T value; E error; } Result_([T, E]); \
  _Bool Result_([T, E])_is_ok(Result_([T, E]) r) { ... }
```

`Result_([T, E])_is_ok` is one identifier; `Result_([T, E]) r` is two.

The name is a stable hash of the spelling, so the same instantiation spells the
same identifier in every translation unit - the typedef can be written in a
header and used in any `.c` file with no per-TU state. Repeating an
instantiation is a no-op: the second definition is dropped rather than building
a second layout, which keeps uses on either side of it compatible.

## Diagnostics

Errors come out rustc-shaped: the message, a `-->` location, the offending
source line and a caret run under the span.

```
error: use of undeclared identifier: undefined_thing
  --> bad.c:3:3
  |
3 |   int y = undefined_thing;
  |   ^^^^^^
```

Syntax errors use the same layout (the parser is fatal, so there is only ever
one). A diagnostic raised while checking a declaration points at the
declaration, not the exact sub-expression, because expressions do not carry
spans yet.

## Known gaps at a glance

- The plain form has no preprocessor of its own: `Qiang input.c` strips `#`
  lines and expects `clang -E` to have run first. Use `Qiang run`, which does
  the preprocessing (and the linking) for you.
- `sizeof` of a string literal or a string-initialised `char[]`.
- VLA `sizeof`.
- Some signed bitfield widths.
- `__attribute__((packed))` and `__attribute__((aligned(N)))` are ignored.
- Wide/UTF string literals, string escapes in some cases.
- Atomics: no read-modify-write.
- `asm` labels and nested functions.
- Diagnostics carry statement-level positions.
- Types are per translation unit. A struct declared in two files is laid out the
  same way from the same declaration, so the ABI agrees, but nothing compares
  the two declarations; a mismatch is undefined behaviour, as in C.
- A file-scope variable cannot be initialised with a closure: a `_Lambda`
  expression's environment is a local of the enclosing function, so there is
  none at file scope. It is diagnosed rather than turned into a null function
  pointer.

## See also

- `Qiang/README.md` — pipeline, usage and limitations.
- `examples/Qiang-selfhost/` — the self-host build and semantic check.
