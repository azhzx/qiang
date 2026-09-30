# QPCC TODO

Known gaps, roughly in planned order.

## Deferred (explicitly not implemented yet)

- Preprocessor: #include, #define/#undef, #if/#ifdef/#ifndef/#elif/#else/#endif,
  #error/#warning, #line, #pragma/_Pragma, token pasting ##, stringizing #.
  Today qpcc/qpcc.mbt strip_directives merely drops lines starting with '#'.
  See qpcc/preprocess.mbt (stub).
- long double: recognized and reported unsupported (QBE has no 80/128-bit float).
- _Complex / _Imaginary: recognized and reported unsupported.

## Skipped by decision

- Old-style (K&R) function definitions.

## Known limitations

- VLA storage is allocated at the declaration point and is not reclaimed at
  block exit (QBE has no explicit stack restore), so declaring one in a loop
  accumulates. Functionally correct for typical use.
- _Atomic: type qualifier plus aligned access only; the <stdatomic.h> API
  depends on the preprocessor (TODO above).
- _Thread_local: parsed with semantics; full Mach-O TLS codegen needs an
  arm64 emitter extension and is pending.

## Feature work

Full C11 (types, declarations, expressions, statements, semantics, arm64 ABI),
then a C23 subset. See the project plan.
