# QPCC - Qopple C Compiler

A small C compiler written in MoonBit. It targets the qbe.mbt programmatic QBE
IL builder (`azhzx/qbe`, package `ir_builder`) and emits a self-contained Mach-O
arm64 object in-process, which `clang` links into an executable.

QPCC is the "real-world user" exercise for the qbe.mbt builder. It is written
from scratch (design informed by chibicc and mbtcc); see the licensing note.

## Status: M0

Supported today:

    int main() { return 42; }

i.e. the lexer understands `int`, `return`, identifiers, decimal integers and
`( ) { } ;`; the parser accepts one or more such function definitions; codegen
emits a QBE function per definition with a constant `ret`.

Usage:

    moon build --target native qpcc/cmd
    _build/native/debug/build/qpcc/cmd/cmd.exe input.c -o input.o
    clang input.o -o input && ./input

    # print the generated QBE IL instead of an object:
    ... cmd.exe input.c --emit qbe

End-to-end check:

    sh qpcc/test.sh

## Roadmap

| Milestone | Scope |
| --- | --- |
| M0 (done) | `int f() { return N; }` -> object -> clang -> run |
| M1 | expressions and precedence, local variables, assignment, `if`/`while` |
| M2 | multiple functions, calls, recursion, libc (`putchar`/`printf`) |
| M3 | pointers, arrays, string literals, `sizeof` |
| M4 | structs, globals, minimal preprocessor (`#define`/`#include`) |
| M5 | run a chibicc test subset as an oracle |

## Layout

    qpcc/            library: lexer + parser + codegen over ir_builder
    qpcc/cmd/        executable driver (input .c -> .o / --emit qbe)
    qpcc/tests/      C fixtures
    qpcc/test.sh     end-to-end script

## Licensing

QPCC is original code licensed under the Apache License 2.0 (like qbe.mbt). Its
design is informed by [chibicc](https://github.com/rui314/chibicc) (MIT,
(c) 2019 Rui Ueyama) and [mbtcc](https://github.com/moonbitlang/mbtcc)
(Apache-2.0). No third-party source was copied; see
`../THIRD_PARTY_NOTICES.md`.
