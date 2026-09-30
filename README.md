# QPCC - Qopple C Compiler

A small C compiler written in MoonBit. It targets the qbe.mbt programmatic QBE
IL builder (the `ir_builder` package of `azhzx/qbe`) and emits a self-contained
Mach-O arm64 object in-process, which `clang` links into an executable.

QPCC is the "real-world user" exercise for the qbe.mbt builder. It is written
from scratch (design informed by chibicc and mbtcc; see the licensing note).

## Status

Supported:

- expressions with full precedence; local variables and initializers;
  assignment and compound assignment; `if`/`else`, `while`, `for`, `do`/`while`,
  `break`, `continue`; comparisons, `&&`/`||`/`!`, `? :`; `sizeof`;
  increment/decrement.
- multiple functions, parameters, calls, recursion, libc calls (e.g.
  `putchar`); `int`/`char`/`long`/`void` return types.
- pointers, address-of/deref, pointer arithmetic, arrays, string literals,
  character literals, `sizeof` of types and expressions.
- struct types with `.` and `->` member access and C layout/alignment; global
  variables with constant initializers.
- a minimal preprocessor that drops `#` directive lines, so `#include` is
  accepted (libc functions become implicit declarations). `#define` expansion is
  not implemented.

Not yet supported: `#define` macro expansion, variadic functions, floating point,
function pointers, `static`/`extern`, struct assignment/parameters,
union/enum/typedef.

## Usage

    moon build --target native qpcc/cmd
    _build/native/debug/build/qpcc/cmd/cmd.exe input.c -o input.o
    clang input.o -o input && ./input

    # print the generated QBE IL instead of an object:
    ... cmd.exe input.c --emit qbe

## Tests

    sh qpcc/test.sh

This is the oracle: for every `qpcc/tests/*.c` fixture it compiles once with
`clang` and once with QPCC, links both, runs both, and compares exit codes and
stdout. 25/25 fixtures pass.

## Layout

    qpcc/lexer.mbt     tokens + tokenizer
    qpcc/ast.mbt       C types and AST
    qpcc/parser.mbt    recursive-descent parser
    qpcc/codegen.mbt   lowering onto ir_builder
    qpcc/qpcc.mbt      driver + preprocessor
    qpcc/cmd/          executable CLI
    qpcc/tests/        C fixtures
    qpcc/test.sh       clang-oracle test runner

## Licensing

QPCC is original code licensed under the Apache License 2.0 (like qbe.mbt). Its
design is informed by chibicc (MIT, (c) 2019 Rui Ueyama) and mbtcc (Apache-2.0).
No third-party source or test files were copied; see ../THIRD_PARTY_NOTICES.md.
