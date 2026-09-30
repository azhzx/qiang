///|
fn main {
  let args = @env.args()
  let mut mode = @front.C11
  let mut file = ""
  let mut i = 1
  while i < args.length() {
    let a = args[i]
    if a == "-std=c23" {
      mode = @front.C23
    } else if a.has_prefix("-std=") {
      mode = @front.C11
    } else if file == "" {
      file = a
    }
    i = i + 1
  }
  if file == "" {
    println("usage: sema [-std=c11|c23] <file>")
    return
  }
  let src = @fs.read_file_to_string(file) catch {
    _ => abort("sema: cannot read " + file)
  }
  let tu = @front.parse(src, mode~)
  let r = @sema.check(tu)
  let mut errs = 0
  for d in r.diags {
    match d.sev {
      @sema.SevError => errs = errs + 1
      _ => ()
    }
  }
  println(
    file +
    ": layouts=" +
    r.layouts.length().to_string() +
    " errors=" +
    errs.to_string(),
  )
  let mut shown = 0
  for d in r.diags {
    match d.sev {
      @sema.SevError =>
        if shown < 3 {
          println("  error: " + d.msg)
          shown = shown + 1
        }
      _ => ()
    }
  }
}
