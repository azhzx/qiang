# Qiang C examples

Small C programs compiled by Qiang (the C front end in `Qiang/`) and linked
with clang.

```sh
sh examples/c/run.sh                          # run every *.c in this directory
sh examples/c/run.sh hello.c                  # run one file (C11)
sh examples/c/run.sh lambda.c        # flags are passed to `Qiang run`
sh examples/c/run.sh args.c -- 1 2            # ... and after -- to the program
```

Exactly one source file is compiled per invocation; the first argument that
is not an option is the file, and everything after `--` is passed to the
compiled program rather than treated as more C files. A relative file
argument is tried against the current directory first and then against this
directory, so both `run.sh c2y.c` and `run.sh examples/c/c2y.c` work. A
missing file is reported with a non-zero exit.

The script is a thin wrapper over `Qiang run`, which preprocesses with
`clang -E -P`, compiles with Qiang, links with clang and runs the result,
printing the exit code. The bundled `Qiang/include/qbe` is on the include
path, so the hand-written `stddefer.h`, `stdcountof.h`, `taggedunion.h`,
`function_pointer.h` and `lambda.h` aliases resolve.

**Nothing is sniffed out of the sources**: an example that needs a mode says
so on the command line, or is listed in the table inside `run.sh`, which is
what the "run everything" pass uses.

| File | Shows |
| --- | --- |
| `hello.c` | a first program: `printf` through the bundled `stdio.h` |
| `fib.c` | recursion and a loop |
| `args.c` | `argc`/`argv` and passing arguments through `run.sh` |
| `taggedunion.c` | `-std=cqe`: a tagged union through the `<taggedunion.h>` aliases, with `_Dynamic_tag` / `_Static_tag` |
| `onestop.c` | `-std=cqe`: the same, plus a closure through `<lambda.h>` |
| `lambda.c` | `-std=cqe`: a closure with `_Lambda` / `lambda`, and `_Closure_environment` reaching the captured environment |
| `function_pointer.c` | `-std=cqe`: `_Function_pointer`, both the bare storage type and the prefix spelling with a signature |
| `template.c` | `-std=cqe`: pseudo-templates - one `MakeResult(T, E)` macro producing `Result_([T, E])` plus a derived `Result_([T, E])_is_ok` |
| `rec_lambda.c` | `-std=cqe`: recursion with the knot tied by hand, a closure capturing a pointer to itself |
| `z.c` | `-std=cqe`: the Z combinator - self-application `x x` with the self type-erased, and a capture-less core so no environment dangles. One core drives both `fact` and `fib`, and neither step mentions recursion |
| `c2y.c` | `-std=c2y`: `_Countof` / `countof`, `_Maxof` / `maxof`, `_Minof` / `minof`, a named loop and `_Defer` / `defer` |
