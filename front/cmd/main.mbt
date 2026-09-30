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
    } else if a == "-std=c11" {
      mode = @front.C11
    } else if a.has_prefix("-std=") {
      mode = @front.C11
    } else if file == "" {
      file = a
    }
    i = i + 1
  }
  if file == "" {
    println("usage: front [-std=c11|c23] <file>")
    return
  }
  let src = @fs.read_file_to_string(file) catch {
    _ => abort("front: cannot read " + file)
  }
  let _tu = @front.parse(src, mode~)
  println("OK")
}
