#!/usr/bin/env python3
"""Fetch the projects listed in doc/Qiang-external-scan.md.

The file list in the report is the comparison set, so the scanner and this
fetcher both read it back out of the report.  Everything lands under
build/scan/ (gitignored).
"""
import os, re, shutil, subprocess, sys, tarfile, zipfile, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC = os.path.join(ROOT, "doc", "Qiang-external-scan.md")
BASE = os.path.join(ROOT, "build", "scan")
RAW = os.path.join(BASE, "raw")
SRC = os.path.join(BASE, "src")

# name -> how to obtain it.  ("git", url) or ("tar", url) or ("zip", url).
SOURCES = {
    # dash, abduco and smu are gone from git.suckless.org; use their upstreams.
    "abduco":   ("git", "https://github.com/martanne/abduco.git"),
    "bzip2":    ("tar", "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"),
    "cjson":    ("git", "https://github.com/DaveGamble/cJSON.git"),
    "dash":     ("git", "https://git.kernel.org/pub/scm/utils/dash/dash.git"),
    "farbfeld": ("git", "https://git.suckless.org/farbfeld"),
    "hiredis":  ("git", "https://github.com/redis/hiredis.git"),
    "ii":       ("git", "https://git.suckless.org/ii"),
    "lchat":    ("git", "https://git.suckless.org/lchat"),
    "lua":      ("local", "build/lua/lua-5.5.1"),
    "lz4":      ("git", "https://github.com/lz4/lz4.git"),
    "miniz":    ("git", "https://github.com/richgel999/miniz.git"),
    "sic":      ("git", "https://git.suckless.org/sic"),
    "slstatus": ("git", "https://git.suckless.org/slstatus"),
    "smu":      ("git", "https://github.com/hXtreme/smu.git"),
    "sqlite":   ("zip", "https://www.sqlite.org/2024/sqlite-amalgamation-3460100.zip"),
    "yyjson":   ("git", "https://github.com/ibireme/yyjson.git"),
    # git rather than the 1.3.1 tarball: only git carries contrib/crc32vx,
    # contrib/blast/blast-test.c and contrib/puff/bin-writer.c, which the
    # earlier scan recorded.
    "zlib":     ("git", "https://github.com/madler/zlib.git"),
}


def report_files():
    """The per-project .c list recorded in the report (the comparison set)."""
    txt = open(DOC, encoding="utf-8").read()
    rows = re.findall(r"^\| ([a-z0-9]+) \| ([^|]+?) \| ([A-Z-]+) \| (?:OK|FAIL) \|", txt, re.M)
    out = {}
    for proj, path, _stage in rows:
        out.setdefault(proj, []).append(os.path.basename(path.strip()))
    return out


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def fetch(name):
    kind, url = SOURCES[name]
    dst = os.path.join(RAW, name)
    # Only a non-empty directory counts as fetched: an earlier failure can leave
    # an empty one behind, and skipping it silently loses the project.
    if os.path.isdir(dst) and os.listdir(dst):
        return dst
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst, exist_ok=True)
    if kind == "local":
        shutil.copytree(os.path.join(ROOT, url), dst, dirs_exist_ok=True)
    elif kind == "git":
        r = run(["git", "clone", "--depth", "1", url, dst])
        if r.returncode:
            print("  clone failed:", name, r.stderr.strip().splitlines()[-1:])
            return None
    else:
        fname = os.path.join(BASE, os.path.basename(url))
        if not os.path.exists(fname):
            urllib.request.urlretrieve(url, fname)
        if kind == "tar":
            with tarfile.open(fname) as t:
                t.extractall(dst)
        else:
            with zipfile.ZipFile(fname) as z:
                z.extractall(dst)
    return dst


def flatten(name, dst, want, with_headers):
    """Collect the listed .c files (and optionally every header) into one dir."""
    out = os.path.join(SRC, name)
    os.makedirs(out, exist_ok=True)
    index = {}
    for dirpath, _dirs, files in os.walk(dst):
        for f in files:
            index.setdefault(f, os.path.join(dirpath, f))
    missing = []
    for f in want:
        if f in index:
            shutil.copy2(index[f], os.path.join(out, f))
        else:
            missing.append(f)
    if with_headers:
        for f, path in index.items():
            if f.endswith(".h") and not os.path.exists(os.path.join(out, f)):
                shutil.copy2(path, os.path.join(out, f))
    return missing


def main():
    want = report_files()
    os.makedirs(SRC, exist_ok=True)
    for name in SOURCES:
        print("==", name, flush=True)
        dst = fetch(name)
        if not dst:
            continue
        files = want.get(name, [])
        missing = flatten(name, dst, files, with_headers=True)
        got = len([f for f in files if os.path.exists(os.path.join(SRC, name, f))])
        note = ("  missing: " + " ".join(missing)) if missing else ""
        print("   %d/%d files%s" % (got, len(files), note), flush=True)


if __name__ == "__main__":
    main()