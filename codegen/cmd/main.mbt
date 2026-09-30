///|
fn main {
  let args = @env.args()
  let mut input = ""
  let mut output = ""
  let mut emit_asm = false
  let mut mode = @front.C11
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
      if i + 1 < args.length() && args[i + 1] == "asm" {
        emit_asm = true
      }
      i = i + 2
      continue
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
    println("usage: qpcc <input.c> [-o out.o] [--emit asm] [-std=c11|c23]")
    return
  }
  let src = @fs.read_file_to_string(input) catch {
    _ => abort("qpcc: cannot read " + input)
  }
  let tu = @front.parse(src, mode~)
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
  let b = @codegen.compile_program(prog) catch {
    _ => abort("qpcc: codegen failed")
  }
  if emit_asm {
    let text = b.emit_asm() catch { _ => abort("qpcc: asm emission failed") }
    println(text)
    return
  }
  let obj = b.emit_object() catch { _ => abort("qpcc: object emission failed") }
  let out = if output == "" { input + ".o" } else { output }
  @fs.write_bytes_to_file(out, obj) catch {
    _ => abort("qpcc: cannot write " + out)
  }
}
