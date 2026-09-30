///|
/// QPCC driver.
///
/// Usage:
///   qpcc <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23] [--check]
///
/// The C preprocessor is external: run clang -E first when the input uses
/// #include/#define beyond simple directives (plain # lines are stripped here).
fn usage() -> Unit {
  println(
    "usage: qpcc <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23] [--check]",
  )
}

///|
fn strip_directives(src : String) -> String {
  let sb = StringBuilder::new()
  for line in src.split("\n") {
    if line.has_prefix("#") {
      sb.write_string("\n")
    } else {
      sb.write_string(line.to_string())
      sb.write_string("\n")
    }
  }
  sb.to_string()
}

///|
fn main {
  let args = @env.args()
  let mut input = ""
  let mut output = ""
  let mut emit = "obj"
  let mut mode = @front.C11
  let mut check_only = false
  let mut i = 1
  while i < args.length() {
    let a = args[i]
    if a == "-o" {
      if i + 1 < args.length() {
        output = args[i + 1]
        i = i + 2
        continue
      }
      abort("qpcc: -o needs a path")
    } else if a == "--emit" {
      if i + 1 < args.length() {
        emit = args[i + 1]
      }
      i = i + 2
      continue
    } else if a == "--check" {
      check_only = true
    } else if a == "-std=c23" {
      mode = @front.C23
    } else if a == "-std=c11" {
      mode = @front.C11
    } else if a.has_prefix("-std=") {

    } else if input == "" {
      input = a
    }
    i = i + 1
  }
  if input == "" {
    usage()
    return
  }
  let src = @fs.read_file_to_string(input) catch {
    _ => abort("qpcc: cannot read " + input)
  }
  let tu = @front.parse(strip_directives(src), mode~)
  let prog = @sema.check(tu)
  let mut errs = 0
  for d in prog.diags {
    match d.sev {
      @sema.SevError => {
        println(
          input +
          ":" +
          d.line.to_string() +
          ":" +
          d.col.to_string() +
          ": error: " +
          d.msg,
        )
        errs = errs + 1
      }
      _ => ()
    }
  }
  if errs > 0 {
    abort("qpcc: " + errs.to_string() + " error(s)")
  }
  if check_only {
    println("OK")
    return
  }
  let b = @codegen.compile_program(prog) catch {
    _ => abort("qpcc: codegen failed")
  }
  if emit == "asm" {
    println(b.emit_asm() catch { _ => abort("qpcc: asm emission failed") })
    return
  }
  if emit == "qbe" {
    println(b.emit_il())
    return
  }
  let obj = b.emit_object() catch {
    e =>
      abort(
        "qpcc: object emission failed: " +
        (match e {
          @util.QbeError::CompileError(m) => m
          _ => e.to_string()
        }),
      )
  }
  let out = if output == "" { input + ".o" } else { output }
  @fs.write_bytes_to_file(out, obj) catch {
    _ => abort("qpcc: cannot write " + out)
  }
}
