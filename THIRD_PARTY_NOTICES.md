# Third-party notices

Qiang is licensed under the Apache License 2.0 (see LICENSE). It uses other
open-source software; the notices below are reproduced as their licenses
require.

## qbe.mbt

The ir_builder API this compiler lowers to, and the QBE IR it emits, come from
qbe.mbt (https://github.com/azhzx/qbe.mbt), which is licensed under the Apache
License 2.0 and itself reimplements QBE:

    (c) 2015-2026 Quentin Carbonneaux <quentin@c9x.me>

## chibicc

chibicc-tests/ is a vendored subset of chibicc
(https://github.com/rui314/chibicc), used as a parsing and end-to-end corpus:

    MIT License
    Copyright (c) 2019 Rui Ueyama

The full licence text is in chibicc-tests/LICENSE.

## Bundled C headers

include/qiang/*.h are hand-written for this project. They shadow the system
headers of the same name so that the compiler sees a stable, self-contained
libc surface; no third-party source code was copied into them.