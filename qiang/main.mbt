///|
/// Qiang driver.
///
/// Usage:
///   Qiang <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23] [--check]
///   Qiang run [-std=...] [-I dir]... [-D name[=v]]... <input.c> [-- args...]
///
/// Without \`run\` the C preprocessor is external: run clang -E first when the
/// input uses #include/#define beyond simple directives (plain # lines are
/// stripped here). \`Qiang run\` drives clang for the preprocessing and the
/// linking, so an ordinary C file can be compiled and executed in one step.

///|
// Diagnostics go to stderr. stdout carries the compiler real output
// (--emit qbe, --emit asm, the object), and 2>/dev/null must not swallow errors.
fn eprint(s : String) -> Unit {
  @native.mbt_native_eprint(@native.cstr(s))
}

///|
fn usage() -> Unit {
  eprint(
    "usage: Qiang <input.c> [-o out.o] [--emit obj|asm|qbe] [-std=c11|c23|c2y] [--check] [-f_tagged_union]",
  )
  eprint(
    "       Qiang run [-std=c11|c23|c2y] [-f_tagged_union] [-I dir] [-D name[=v]] <input.c> [-- args...]",
  )
}

///|
fn strip_directives(src : String) -> String {
  let sb = StringBuilder::new()
  for line in src.split("\n") {
    // Qiang has no preprocessor: #pragma pack changes the layout of the
    // structs after it, so the line is kept for the parser. Every other
    // directive is still blanked, which keeps diagnostic line numbers.
    if line.has_prefix("#pragma") {
      sb.write_string(line.to_string())
      sb.write_string("\n")
    } else if line.has_prefix("#") {
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
/// errors. Shared by the plain compile path and \`Qiang run\`.
fn front_end(
  input : String,
  display : String,
  mode : @front.StdMode,
  tagged_union : Bool,
  strict~ : Bool = false,
) -> @sema.CheckedProgram? {
  let src = @fs.read_file_to_string(input) catch {
    _ => {
      eprint("Qiang: cannot read " + display)
      return None
    }
  }
  // Line numbers refer to what the parser saw, so the snippet must come from
  // the same text.
  let shown = strip_directives(src)
  let tu = @front.parse(shown, mode~, tagged_union~, display~)
  let prog = @sema.check(tu, mode~, strict~)
  let mut errs = 0
  for d in prog.diags {
    match d.sev {
      @sema.SevError => {
        eprint(
          @front.render_diag(
            display,
            shown,
            "error",
            d.msg,
            d.line,
            d.col,
            d.len,
          ),
        )
        errs = errs + 1
      }
      @sema.SevWarning =>
        eprint(
          @front.render_diag(
            display,
            shown,
            "warning",
            d.msg,
            d.line,
            d.col,
            d.len,
          ),
        )
    }
  }
  if errs > 0 {
    eprint("Qiang: " + errs.to_string() + " error(s)")
    return None
  }
  Some(prog)
}

///|
fn emit_object(b : @ir_builder.Builder) -> Bytes {
  b.emit_object() catch {
    e =>
      abort(
        "Qiang: object emission failed: " +
        (match e {
          @util.QbeError::CompileError(m) => m
          @util.QbeError::Ice(m) => "ICE: " + m
          _ => e.to_string()
        }),
      )
  }
}

///|
/// Where the hand-written headers live. \`Qiang run\` appends this to the
/// preprocessor command line so \`#include <stddefer.h>\` and friends resolve;
/// set qiang_INCLUDE to override, or pass -I yourself.
fn qiang_include_dir() -> String? {
  let cands : Array[String] = []
  match @env.get_env_var("qiang_INCLUDE") {
    Some(d) => cands.push(d)
    None => ()
  }
  cands.push("Qiang/include/qbe")
  cands.push("include/qbe")
  cands.push("../Qiang/include/qbe")
  for c in cands {
    let probe = @fs.read_file_to_string(c + "/stddefer.h") catch { _ => "" }
    if probe != "" {
      return Some(c)
    }
  }
  None
}

///|
/// N3914's predefined macros. The target platforms have a unified address
/// space, so every conversion is supported and each macro is the integer
/// literal 1. They belong to C2y and to -std=cqe.
fn ptr_conv_macros() -> String {
  "-D__STDC_PTR_CONV_ANY_FUNC_TO_VOID__=1 " +
  "-D__STDC_PTR_CONV_VOID_TO_ANY_FUNC__=1 " +
  "-D__STDC_PTR_CONV_FUNC_TO_VOID__=1 " +
  "-D__STDC_PTR_CONV_VOID_TO_FUNC__=1 "
}

///|
/// \`Qiang run\`: preprocess with clang, compile with Qiang, link with clang and
/// run, forwarding the program's exit status.
fn run_subcommand(args : Array[String]) -> Unit {
  if @native.mbt_native_run(@native.cstr("command -v clang >/dev/null 2>&1")) !=
    0 {
    eprint(
      "Qiang run: clang is required (it does the preprocessing and the linking) but was not found on PATH; install clang and retry",
    )
    @native.mbt_native_exit(1)
  }
  let mut input = ""
  let mut mode = @front.C11
  let mut std_flag = ""
  let mut tagged_union = false
  let clang_flags : Array[String] = []
  let prog_args : Array[String] = []
  let mut strict = false
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
      if a == "--strict" {
        strict = true
      } else if a == "-std=c2y" {
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
          eprint("Qiang run: " + a + " needs a value")
          @native.mbt_native_exit(1)
        }
        clang_flags.push(a + args[i + 1])
        i = i + 1
      } else if a.has_prefix("-I") || a.has_prefix("-D") || a.has_prefix("-U") {
        clang_flags.push(a)
      } else if a.has_prefix("-") {
        eprint("Qiang run: unknown option " + a)
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
    eprint("Qiang run: no input file")
    @native.mbt_native_exit(1)
  }
  // A .cqe file is C with the Qiang extensions on, so the suffix picks the mode
  // when no -std was given.
  if std_flag == "" && input.has_suffix(".cqe") {
    mode = @front.Cqe
    std_flag = "-std=cqe"
  }
  let i_path = @native.tmp_path(".i")
  let o_path = @native.tmp_path(".o")
  let exe_path = @native.tmp_path("")
  // clang has no -std=cqe, so the preprocessing step uses the C2y spelling;
  // only Qiang needs to know that the Qiang extensions are on.
  let clang_std = if std_flag == "-std=cqe" { "-std=c2y" } else { std_flag }
  // Qiang does not implement Blocks, so preprocess the way a compiler without
  // them would: Apple's headers guard every block declaration with
  // `__BLOCKS__`, and clang defines it. Leaving it defined made the front end
  // parse `(^)(...)` declarations from <sys/dirent.h> and fail.
  let mut pp = "clang -E -P -U__BLOCKS__ "
  if clang_std != "" {
    pp = pp + clang_std + " "
  }
  // N3914's convertibility macros. They are Qiang's, and clang has no idea
  // about them, so the driver has to define them for the preprocessing step.
  if mode == @front.C2y || mode == @front.Cqe {
    pp = pp + ptr_conv_macros()
  }
  for f in clang_flags {
    pp = pp + shell_quote(f) + " "
  }
  match qiang_include_dir() {
    Some(d) => pp = pp + "-I " + shell_quote(d) + " "
    None => ()
  }
  // clang does not know the .cqe suffix either, so name the language.
  if input.has_suffix(".cqe") {
    pp = pp + "-x c "
  }
  pp = pp + shell_quote(input) + " -o " + shell_quote(i_path)
  if @native.mbt_native_run(@native.cstr(pp)) != 0 {
    eprint("Qiang run: preprocessing failed")
    @native.mbt_native_exit(1)
  }
  let prog = match front_end(i_path, input, mode, tagged_union, strict~) {
    Some(p) => p
    None => {
      @native.mbt_native_exit(1)
      abort("Qiang run: cannot continue")
    }
  }
  let b = @codegen.compile_program(prog) catch {
    _ => {
      eprint("Qiang: codegen failed")
      @native.mbt_native_exit(1)
      abort("Qiang run: cannot continue")
    }
  }
  @native.write_file(o_path, emit_object(b)) catch {
    _ => {
      eprint("Qiang run: cannot write the temporary object")
      @native.mbt_native_exit(1)
      abort("Qiang run: cannot continue")
    }
  }
  let link = "clang " + shell_quote(o_path) + " -o " + shell_quote(exe_path)
  if @native.mbt_native_run(@native.cstr(link)) != 0 {
    eprint("Qiang run: linking failed")
    @native.mbt_native_exit(1)
  }
  let mut cmd = shell_quote(exe_path)
  for a in prog_args {
    cmd = cmd + " " + shell_quote(a)
  }
  let raw = @native.mbt_native_run(@native.cstr(cmd))
  // system() reports the raw wait status on POSIX. A status whose low seven
  // bits are non-zero means the child died from a signal, and shifting that
  // right yields zero - which is how a segfault used to be reported as a
  // successful run. Report it the way a shell does instead.
  let code = if raw == -1 {
    1
  } else if (raw & 0x7f) != 0 {
    128 + (raw & 0x7f)
  } else {
    (raw >> 8) & 0xff
  }
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
  let mut strict = false
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
      abort("Qiang: -o needs a path")
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

    } else if a == "--strict" {
      strict = true
    } else if input == "" {
      input = a
    }
    i = i + 1
  }
  if input == "" {
    usage()
    return
  }
  // A .cqe file is C with the Qiang extensions on (see the run path).
  let mode = if input.has_suffix(".cqe") { @front.Cqe } else { mode }
  let prog = match front_end(input, input, mode, tagged_union, strict~) {
    Some(p) => p
    None => {
      @native.mbt_native_exit(1)
      abort("Qiang: cannot continue")
    }
  }
  if check_only {
    println("OK")
    return
  }
  let b = @codegen.compile_program(prog) catch {
    _ => abort("Qiang: codegen failed")
  }
  if emit == "asm" {
    // Surface the underlying error: abort() prints only "PanicError", which
    // made an ICE here indistinguishable from a crash.
    let asm = b.emit_asm() catch {
      @util.QbeError::Ice(msg) => {
        eprintln("Qiang: asm emission ICE: " + msg)
        @native.mbt_native_exit(1)
        ""
      }
      @util.QbeError::CompileError(msg) => {
        eprintln("Qiang: asm emission failed: " + msg)
        @native.mbt_native_exit(1)
        ""
      }
      @util.QbeError::ParseError(_f, _l, msg) => {
        eprintln("Qiang: asm emission failed: " + msg)
        @native.mbt_native_exit(1)
        ""
      }
      _ => {
        eprintln("Qiang: asm emission failed")
        @native.mbt_native_exit(1)
        ""
      }
    }
    println(asm)
    return
  }
  if emit == "qbe" {
    println(b.emit_il())
    return
  }
  let out = if output == "" { input + ".o" } else { output }
  @fs.write_bytes_to_file(out, emit_object(b)) catch {
    _ => abort("Qiang: cannot write " + out)
  }
}
