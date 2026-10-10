///|
/// QPCC driver.
///
/// Usage:
///   qpcc <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23] [--check]
///   qpcc run [-std=...] [-I dir]... [-D name[=v]]... <input.c> [-- args...]
///
/// Without \`run\` the C preprocessor is external: run clang -E first when the
/// input uses #include/#define beyond simple directives (plain # lines are
/// stripped here). \`qpcc run\` drives clang for the preprocessing and the
/// linking, so an ordinary C file can be compiled and executed in one step.
fn usage() -> Unit {
  println(
    "usage: qpcc <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23|c2y] [--check] [-f_tagged_union]",
  )
  println(
    "       qpcc run [-std=c11|c23|c2y] [-f_tagged_union] [-I dir] [-D name[=v]] <input.c> [-- args...]",
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
fn shell_quote(s : String) -> String {
  let sb = StringBuilder::new()
  sb.write_string("'")
  for ch in s {
    if ch == '\'' {
      sb.write_string("'\\''")
    } else {
      sb.write_char(ch)
    }
  }
  sb.write_string("'")
  sb.to_string()
}

///|
/// Read, parse and check one input, reporting diagnostics and aborting on
/// errors. Shared by the plain compile path and \`qpcc run\`.
fn front_end(
  input : String,
  display : String,
  mode : @front.StdMode,
  tagged_union : Bool,
) -> @sema.CheckedProgram? {
  let src = @fs.read_file_to_string(input) catch {
    _ => {
      println("qpcc: cannot read " + display)
      return None
    }
  }
  let tu = @front.parse(strip_directives(src), mode~, tagged_union~)
  let prog = @sema.check(tu, mode~)
  let mut errs = 0
  for d in prog.diags {
    match d.sev {
      @sema.SevError => {
        println(
          display +
          ":" +
          d.line.to_string() +
          ":" +
          d.col.to_string() +
          ": error: " +
          d.msg,
        )
        errs = errs + 1
      }
      @sema.SevWarning =>
        println(
          display +
          ":" +
          d.line.to_string() +
          ":" +
          d.col.to_string() +
          ": warning: " +
          d.msg,
        )
    }
  }
  if errs > 0 {
    println("qpcc: " + errs.to_string() + " error(s)")
    return None
  }
  Some(prog)
}

///|
fn emit_object(b : @ir_builder.Builder) -> Bytes {
  b.emit_object() catch {
    e =>
      abort(
        "qpcc: object emission failed: " +
        (match e {
          @util.QbeError::CompileError(m) => m
          @util.QbeError::Ice(m) => "ICE: " + m
          _ => e.to_string()
        }),
      )
  }
}

///|
/// Where the hand-written headers live. \`qpcc run\` appends this to the
/// preprocessor command line so \`#include <stddefer.h>\` and friends resolve;
/// set QPCC_INCLUDE to override, or pass -I yourself.
fn qpcc_include_dir() -> String? {
  let cands : Array[String] = []
  match @env.get_env_var("QPCC_INCLUDE") {
    Some(d) => cands.push(d)
    None => ()
  }
  cands.push("qpcc/include/qbe")
  cands.push("include/qbe")
  cands.push("../qpcc/include/qbe")
  for c in cands {
    let probe = @fs.read_file_to_string(c + "/stddefer.h") catch { _ => "" }
    if probe != "" {
      return Some(c)
    }
  }
  None
}

///|
/// \`qpcc run\`: preprocess with clang, compile with QPCC, link with clang and
/// run, forwarding the program's exit status.
fn run_subcommand(args : Array[String]) -> Unit {
  if @native.mbt_native_run(@native.cstr("command -v clang >/dev/null 2>&1")) !=
    0 {
    println(
      "qpcc run: clang is required (it does the preprocessing and the linking) but was not found on PATH; install clang and retry",
    )
    @native.mbt_native_exit(1)
  }
  let mut input = ""
  let mut mode = @front.C11
  let mut std_flag = ""
  let mut tagged_union = false
  let clang_flags : Array[String] = []
  let prog_args : Array[String] = []
  let mut i = 0
  while i < args.length() {
    let a = args[i]
    if a == "--" {
      i = i + 1
      while i < args.length() {
        prog_args.push(args[i])
        i = i + 1
      }
      break
    }
    if input == "" {
      if a == "-std=c2y" {
        mode = @front.C2y
        std_flag = a
      } else if a == "-std=c23" {
        mode = @front.C23
        std_flag = a
      } else if a == "-std=c11" {
        mode = @front.C11
        std_flag = a
      } else if a == "-std=cqe" {
        mode = @front.Cqe
        std_flag = a
      } else if a == "-f_tagged_union" {
        tagged_union = true
      } else if a == "-I" || a == "-D" || a == "-U" {
        // The separated form: the flag and its value are two arguments.
        if i + 1 >= args.length() {
          println("qpcc run: " + a + " needs a value")
          @native.mbt_native_exit(1)
        }
        clang_flags.push(a + args[i + 1])
        i = i + 1
      } else if a.has_prefix("-I") || a.has_prefix("-D") || a.has_prefix("-U") {
        clang_flags.push(a)
      } else if a.has_prefix("-") {
        println("qpcc run: unknown option " + a)
        @native.mbt_native_exit(1)
      } else {
        input = a
      }
    } else {
      prog_args.push(a)
    }
    i = i + 1
  }
  if input == "" {
    usage()
    println("qpcc run: no input file")
    @native.mbt_native_exit(1)
  }
  let i_path = @native.tmp_path(".i")
  let o_path = @native.tmp_path(".o")
  let exe_path = @native.tmp_path("")
  // clang has no -std=cqe, so the preprocessing step uses the C2y spelling;
  // only QPCC needs to know that the QPCC extensions are on.
  let clang_std = if std_flag == "-std=cqe" { "-std=c2y" } else { std_flag }
  let mut pp = "clang -E -P "
  if clang_std != "" {
    pp = pp + clang_std + " "
  }
  for f in clang_flags {
    pp = pp + shell_quote(f) + " "
  }
  match qpcc_include_dir() {
    Some(d) => pp = pp + "-I " + shell_quote(d) + " "
    None => ()
  }
  pp = pp + shell_quote(input) + " -o " + shell_quote(i_path)
  if @native.mbt_native_run(@native.cstr(pp)) != 0 {
    println("qpcc run: preprocessing failed")
    @native.mbt_native_exit(1)
  }
  let prog = match front_end(i_path, input, mode, tagged_union) {
    Some(p) => p
    None => {
      @native.mbt_native_exit(1)
      abort("qpcc run: cannot continue")
    }
  }
  let b = @codegen.compile_program(prog) catch {
    _ => {
      println("qpcc: codegen failed")
      @native.mbt_native_exit(1)
      abort("qpcc run: cannot continue")
    }
  }
  @native.write_file(o_path, emit_object(b)) catch {
    _ => {
      println("qpcc run: cannot write the temporary object")
      @native.mbt_native_exit(1)
      abort("qpcc run: cannot continue")
    }
  }
  let link = "clang " + shell_quote(o_path) + " -o " + shell_quote(exe_path)
  if @native.mbt_native_run(@native.cstr(link)) != 0 {
    println("qpcc run: linking failed")
    @native.mbt_native_exit(1)
  }
  let mut cmd = shell_quote(exe_path)
  for a in prog_args {
    cmd = cmd + " " + shell_quote(a)
  }
  let raw = @native.mbt_native_run(@native.cstr(cmd))
  // system() reports a wait status on POSIX; forward the child's exit code.
  let code = (raw >> 8) & 0xff
  ignore(@native.mbt_native_unlink(@native.cstr(i_path)))
  ignore(@native.mbt_native_unlink(@native.cstr(o_path)))
  ignore(@native.mbt_native_unlink(@native.cstr(exe_path)))
  @native.mbt_native_exit(code)
}

///|
fn main {
  let args = @env.args()
  if args.length() > 1 && args[1] == "run" {
    let rest : Array[String] = []
    for j in 2..<args.length() {
      rest.push(args[j])
    }
    run_subcommand(rest)
    return
  }
  let mut input = ""
  let mut output = ""
  let mut emit = "obj"
  let mut mode = @front.C11
  let mut check_only = false
  let mut tagged_union = false
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
    } else if a == "-f_tagged_union" {
      tagged_union = true
    } else if a == "-std=c2y" {
      mode = @front.C2y
    } else if a == "-std=c23" {
      mode = @front.C23
    } else if a == "-std=c11" {
      mode = @front.C11
    } else if a == "-std=cqe" {
      mode = @front.Cqe
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
  let prog = match front_end(input, input, mode, tagged_union) {
    Some(p) => p
    None => {
      @native.mbt_native_exit(1)
      abort("qpcc: cannot continue")
    }
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
  let out = if output == "" { input + ".o" } else { output }
  @fs.write_bytes_to_file(out, emit_object(b)) catch {
    _ => abort("qpcc: cannot write " + out)
  }
}
