///|
fn main {
  let args = @env.args()
  if args.length() < 2 {
    println("usage: front <file>")
    return
  }
  let src = @fs.read_file_to_string(args[1]) catch {
    _ => abort("front: cannot read " + args[1])
  }
  let _tu = @front.parse(src)
  println("OK")
}
