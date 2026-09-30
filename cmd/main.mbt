///|
fn usage() -> Unit {
  println("usage: qpcc <input.c> [-o output.o] [--emit qbe|obj]")
}

///|
fn main {
  let args = @env.args()
  let mut input = ""
  let mut output = ""
  let mut emit_qbe = false
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
      if i + 1 < args.length() && args[i + 1] == "qbe" {
        emit_qbe = true
      }
      i = i + 2
      continue
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
  if emit_qbe {
    let il = @qpcc.compile_il(src) catch { _ => abort("qpcc: compile failed") }
    println(il)
    return
  }
  let obj = @qpcc.compile_object(src) catch {
    _ => abort("qpcc: compile failed")
  }
  let out = if output == "" { input + ".o" } else { output }
  @fs.write_bytes_to_file(out, obj) catch {
    _ => abort("qpcc: cannot write " + out)
  }
}
