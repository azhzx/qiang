#!/usr/bin/env python3
"""Run the three-layer scan described in doc/Qiang-external-scan.md.

Per file:
    clang -E -P -I Qiang/include/qbe -I <proj> f.c   -> f.i
    Qiang f.i -std=c11 --check     front end
    Qiang f.i -std=c11 -o f.o      code generation

Writes build/scan/detail_new.tsv and build/scan/summary_new.tsv, and prints a
per-file diff against the stage recorded in the report.
"""
import concurrent.futures as cf
import os
import sys, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC = os.path.join(ROOT, "doc", "qiang-external-scan.md")
BASE = os.path.join(ROOT, "build", "scan")
SRC = os.path.join(BASE, "src")
RAW = os.path.join(BASE, "raw")
def _find_exe():
    """Locate qiang.exe.

    The module builds into ./_build on its own, but into the workspace root's
    _build (under the module name) when it is a member of a moon.work, so try
    both trees instead of guessing the layout.
    """
    for root in (ROOT, os.path.dirname(ROOT)):
        for base, _dirs, files in os.walk(os.path.join(root, "_build")):
            if "qiang.exe" in files:
                return os.path.join(base, "qiang.exe")
    sys.exit("error: qiang.exe not found; run 'moon build --target native qiang'")

EXE = _find_exe()
INC = os.path.join(ROOT, "include", "qiang")
def _env_json():
    q = os.path.join(BASE, "env.json")
    if not os.path.exists(q):
        return {}
    try:
        return json.load(open(q, encoding="utf-8"))
    except Exception:
        return {}


ENV = _env_json()
# Third-party library headers (libpng, jpeg, openssl, X11) live outside the SDK.
EXTRA_INC = ENV.get("include_dirs") or [
    d
    for d in (
        "/Users/Admin/.homebrew/include",
        "/opt/homebrew/include",
        "/usr/local/include",
        "/opt/X11/include",
    )
    if os.path.isdir(d)
]
CC = "/usr/bin/clang" if os.path.exists("/usr/bin/clang") else "cc"
TIMEOUT = 240


def old_report():
    txt = open(DOC, encoding="utf-8").read()
    rows = re.findall(r"^\| ([a-z0-9]+) \| ([^|]+?) \| ([A-Z-]+) \| (OK|FAIL) \| ([^|]*)\|", txt, re.M)
    out = {}
    for proj, path, stage, _res, diag in rows:
        out[(proj, os.path.basename(path.strip()))] = (stage, diag.strip())
    return out


def run(cmd):
    """(rc, stdout, stderr).  They must stay apart: clang's warnings go to
    stderr, and writing them into the .i makes Qiang fail on text that is not C."""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=TIMEOUT)
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return 124, "", "timeout after %ds" % TIMEOUT


def first_error(text):
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("error:") or s.startswith("Qiang:") or s.startswith("PanicError"):
            return s
    for line in text.splitlines():
        if line.strip():
            return line.strip()
    return "(no message)"


def index_project(proj):
    """Find each .c in the project's own tree - the scan runs in place, because
    the sources use relative includes like "../slstatus.h"."""
    root = os.path.join(RAW, proj)
    out = {}
    for dirpath, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d != ".git"]
        for f in files:
            out.setdefault(f, os.path.join(dirpath, f))
    return out


# Some projects get their version from the Makefile, which this scan does not
# run (smu.c prints VERSION). Define the few that are needed here, quoted the
# way the Makefile quotes them.
DEFS = {
    "smu": ['-DVERSION="0"'],
    "sic": ['-DVERSION="0"'],
    # dash gets its config.h from the build system rather than from the
    # sources, so force it in: stat64 -> stat and USE_TEE live there.
    "dash": ["-include", os.path.join(RAW, "dash", "config.h")],
}

# Suckless-style projects take config.h from config.def.h and get VERSION from
# the Makefile. Without a config.h the file cannot be preprocessed at all, which
# used to hide the real Qiang result behind the PREPROCESS bucket (abduco's whole
# translation unit lives behind #include "config.h").
CFG = os.path.join(BASE, "cfg")


def config_dir(proj, root):
    d = os.path.join(CFG, proj)
    if os.path.isdir(d):
        return d
    src = None
    for cand in ("config.def.h", "config.h.in"):
        q = os.path.join(root, cand)
        if os.path.isfile(q):
            src = q
            break
    if src is None:
        return None
    os.makedirs(d, exist_ok=True)
    txt = open(src, encoding="utf-8", errors="replace").read()
    if "VERSION" not in txt:
        txt += '\n#ifndef VERSION\n#define VERSION "0"\n#endif\n'
    open(os.path.join(d, "config.h"), "w", encoding="utf-8").write(txt)
    return d


def scan(proj, fname, path):
    if path is None:
        return (proj, fname, "NO-SOURCE", "FAIL", "not found in the project tree")
    d = os.path.dirname(path)
    root = os.path.join(RAW, proj)
    i = os.path.join(BASE, "i", proj + "__" + fname[:-2] + ".i")
    o = os.path.join(BASE, "o", proj + "__" + fname[:-2] + ".o")
    inc = ["-I", INC, "-I", d]
    for x in EXTRA_INC:
        inc += ["-I", x]
    cfg = config_dir(proj, root) or (os.path.join(CFG, proj) if os.path.isdir(os.path.join(CFG, proj)) else None)
    if cfg:
        inc = ["-I", cfg] + inc
    for sub in ("", "src", "lib", "include", "src/lua"):
        p = os.path.join(root, sub) if sub else root
        if os.path.isdir(p) and p != d:
            inc += ["-I", p]
    rc, out, err = run([CC, "-E", "-P", "-U__BLOCKS__"] + inc + DEFS.get(proj, []) + [path])
    if rc != 0:
        return (proj, fname, "PREPROCESS", "FAIL", first_error(err))
    open(i, "w").write(out)
    rc, out, err = run([EXE, i, "-std=c11", "--check"])
    msg = out + err
    if rc != 0 or re.search(r"^error:", msg, re.M):
        m = first_error(msg)
        body = m[len("error:"):].strip() if m.startswith("error:") else m
        if body.startswith("expected"):
            stage = "PARSE"
        elif m.startswith("error:") or m.startswith("Qiang:"):
            stage = "SEMA"
        else:
            # Qiang aborts on every front-end error, so a PanicError stack is
            # only interesting when there is no diagnostic to classify.
            stage = "FRONT-PANIC"
        return (proj, fname, stage, "FAIL", m)
    rc, out, err = run([EXE, i, "-std=c11", "-o", o])
    if rc != 0:
        return (proj, fname, "CODEGEN-PANIC", "FAIL", first_error(out + err))
    os.remove(i)
    return (proj, fname, "OK", "OK", "-")


def main():
    os.makedirs(os.path.join(BASE, "i"), exist_ok=True)
    os.makedirs(os.path.join(BASE, "o"), exist_ok=True)
    old = old_report()
    jobs = sorted(old.keys())
    print("scanning %d files" % len(jobs), flush=True)
    indexes = {}
    for p, _f in jobs:
        if p not in indexes:
            indexes[p] = index_project(p)
    results = []
    with cf.ThreadPoolExecutor(max_workers=8) as ex:
        futs = {ex.submit(scan, p, f, indexes[p].get(f)): (p, f) for p, f in jobs}
        for k, fut in enumerate(cf.as_completed(futs), 1):
            results.append(fut.result())
            if k % 25 == 0:
                print("  %d/%d" % (k, len(jobs)), flush=True)
    order = {k: n for n, k in enumerate(jobs)}
    results.sort(key=lambda r: order[(r[0], r[1])])
    with open(os.path.join(BASE, "detail_new.tsv"), "w") as fh:
        for r in results:
            fh.write("\t".join(r) + "\n")
    projs = []
    for p, _f in jobs:
        if p not in projs: projs.append(p)
    with open(os.path.join(BASE, "summary_new.tsv"), "w") as fh:
        fh.write("project\tfiles\tok\tpreprocess\tparse\tsema\tcodegen\tfrontpanic\n")
        for p in projs:
            rs = [r for r in results if r[0] == p]
            cnt = lambda s: len([r for r in rs if r[2] == s])
            fh.write("%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n" % (
                p, len(rs), cnt("OK"), cnt("PREPROCESS"), cnt("PARSE"),
                cnt("SEMA"), cnt("CODEGEN-PANIC"), cnt("FRONT-PANIC")))
    print()
    tot = {}
    for r in results:
        tot[r[2]] = tot.get(r[2], 0) + 1
    print("new:", ", ".join("%s=%d" % (k, v) for k, v in sorted(tot.items())))
    print()
    print("changed vs report:")
    for r in results:
        key = (r[0], r[1])
        oldstage = old.get(key, ("?",))[0]
        if oldstage != r[2]:
            print("  %-8s %-28s %-13s -> %-13s %s" % (r[0], r[1], oldstage, r[2], r[4][:60]))


if __name__ == "__main__":
    main()