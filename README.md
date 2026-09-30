# QPCC - Qopple C Compiler

A small C compiler written in MoonBit. It targets the qbe.mbt programmatic QBE
IL builder (the `ir_builder` package of `azhzx/qbe`) and emits a self-contained
Mach-O arm64 object in-process, which `clang` links into an executable.

QPCC is the "real-world user" exercise for the qbe.mbt builder. It is written
from scratch (design informed by chibicc and mbtcc; see the licensing note).

## Status

Working today:

- **M0/M1** - expressions with full precedence, local variables and
  initializers, assignment and compound assignment, `if`/`else`, `while`, `for`,
  `do`/`while`, `break`, `continue`, comparisons, `&&`/`||`/`!`, `? :`,
  `sizeof`, increment/decrement.
- **M2** - multiple functions, parameters, calls, recursion, libc calls
  (`putchar`); `int`/`char`/`long`/`void` return types.
- **M3** - pointers, address-of/deref, pointer arithmetic, one-dimensional
  arrays, string literals and `char*` indexing, `sizeof` of types/expressions.
- **M4 (partial)** - global variables (constant initializers) and a minimal
  preprocessor that drops `#` lines (so `#include`/`#define` do not break parsing;
  libc functions are implicitly declared). Structs are not yet supported.

All values are 64-bit-register based: `int`/`char` use narrow stores and
sign-extending loads, `long`/pointers use 64-bit loads. `&&`/`||` are evaluated
without short-circuiting.

## Usage

    moon build --target native qpcc/cmd
    _build/native/debug/build/qpcc/cmd/cmd.exe input.c -o input.o
    clang input.o -o input && ./input

    # print the generated QBE IL instead of an object:
    ... cmd.exe input.c --emit qbe

End-to-end check (compile each fixture, link with clang, run it):

    sh qpcc/test.sh

## Roadmap

| Milestone | Scope | State |
| --- | --- | --- |
| M0 | `int f() { return N; }` -> object -> clang -> run | done |
| M1 | expressions, locals, control flow | done |
| M2 | functions, calls, recursion, libc | done |
| M3 | pointers, arrays, strings, `sizeof` | done |
| M4 | structs; richer preprocessor | partial |
| M5 | chibicc test subset as an oracle | pending |

## Layout

    qpcc/lexer.mbt     tokens + tokenizer
    qpcc/ast.mbt       C types and AST
    qpcc/parser.mbt    recursive-descent parser
    qpcc/codegen.mbt   lowering onto ir_builder
    qpcc/qpcc.mbt      driver (compile_il / compile_object, preprocessor)
    qpcc/cmd/          executable CLI
    qpcc/tests/        C fixtures
    qpcc/test.sh       end-to-end script

## Licensing

QPCC is original code licensed under the Apache License 2.0 (like qbe.mbt). Its
design is informed by chibicc (MIT, (c) 2019 Rui Ueyama) and mbtcc (Apache-2.0).
No third-party source was copied; see ../THIRD_PARTY_NOTICES.md.
