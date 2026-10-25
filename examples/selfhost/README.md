# Building QBE with Qiang

`build-qbe-with-Qiang.sh` compiles the vendored QBE C sources with **Qiang**, the
C compiler in this repository, and then checks the resulting binary against a
reference build.

The interesting part is the second half: the binary Qiang produced is itself a
working QBE, so it is asked to compile QBE's own test corpus, and its assembly
output is compared byte for byte with the assembly the reference QBE emits.

## Run it

```sh
git submodule update --init          # if vendor/qbe is empty
sh examples/Qiang-selfhost/build-qbe-with-Qiang.sh
```

The script writes everything under `.Qiang_build/` at the repository root
(already in `.gitignore`; pass a directory as the first argument to put it
elsewhere). It exits non-zero if any fixture differs.

```
== 1/4  building Qiang
== 2/4  compiling vendor/qbe with Qiang
    compiled 32 translation units
== 3/4  linking ./qbe-Qiang
== 4/4  reference build and corpus comparison

artifacts:      /…/.Qiang_build/qbe-Qiang
test corpus:    55 identical, 21 differing, 76 total
```

The corpus line is read as a scoreboard: a fixture counts as identical only if
both compilers produce exactly the same output and the same exit status, so
anything the script still reports as differing is a real gap. The script exits
non-zero whenever anything differs, so a non-zero status here is the scoreboard
reporting open gaps, not a failing unit test - it is deliberately not part of
CI, which runs `Qiang/test.sh` (151 fixtures) and `semantic-check.sh` instead.

The 21 remaining differences are code-generation choices, not miscompiles:
`semantic-check.sh` reports 58/58 "both correct" and 0 one-sided failures over
the same corpus, and the diffs are extra `mov`s and different `cmov`/scratch
registers, i.e. register allocation rather than wrong code.

## What each step shows

1. **Building Qiang** — `moon build --target native Qiang/cmd` produces
   `_build/native/debug/build/Qiang/cmd/cmd.exe`.

2. **Compiling the corpus** — QBE is ordinary C11: about 17k lines spread over
   the core, the shared `emit.c`, and the `amd64`/`arm64`/`rv64` back ends.
   Qiang has an external preprocessor by design, so each source is first run
   through `clang -E -P -nostdinc` with the QBE include paths, then compiled to
   a Mach-O arm64 object.

3. **Linking** — on macOS the objects are linked with
   `xcrun ld -lSystem`; on Linux a plain `cc` link is enough.

4. **Comparison** — the reference `qbe` is built with the system compiler from
   the same sources. Both binaries then compile every `vendor/qbe/test/*.ssa`
   fixture (stored with CRLF endings, hence the `tr`), and the full output,
   including diagnostics, must match exactly.

## Using Qiang on your own C

```sh
# 1. preprocess (Qiang does not run cpp itself)
clang -E -P your.c > your.i

# 2. compile
moon build --target native Qiang/cmd
_build/native/debug/build/Qiang/cmd/cmd.exe your.i -o your.o

# 3. link and run
clang your.o -o your
./your
```

```sh
# no separate preprocessing step if the file has no directives:
Qiang your.c -o your.o
```

Useful flags: `--emit obj|asm|qbe` to see Qiang's IR instead of an object,
`-std=c11` or `-std=c23` to pick the dialect, and `--check` for
parse/semantic checking only.

## Pitfalls

The exercise is as much a test of the tooling as of the compiler, and several
of the traps are easy to fall into twice: `timeout` does not exist on macOS, so
a comparison script can silently report success by comparing two empty strings;
zsh does not word-split an unquoted variable; `vendor/qbe` is a submodule, so
reverting a debug patch means `cd vendor/qbe` first. All of that, plus the
compiler bugs the self-host exposed and how each was found, is written up in
[`doc/pitfalls.md`](../../doc/pitfalls.md).

## Regression suite

`sh Qiang/test.sh` compiles every fixture under `Qiang/tests/` with both clang
and Qiang, links both, runs both, and compares exit codes and stdout. This script
is the large-scale version of the same idea.
