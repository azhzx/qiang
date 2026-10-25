#!/usr/bin/env python3
"""Provision the build environment the external scan needs.

The scan compiles third-party projects that were written for their own build
system: some need headers generated at build time, some need library headers
that are not part of the macOS SDK (libpng, jpeg, openssl, X11). This script
produces those headers into build/scan/cfg/<project>/ and records the extra
include directories in build/scan/env.json, which scan_external.py reads.

Everything here is best effort: whatever cannot be found is simply not added,
and the affected files keep landing in the PREPROCESS bucket with a reason.
"""
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(ROOT, "build", "scan")
RAW = os.path.join(BASE, "raw")
CFG = os.path.join(BASE, "cfg")

# Libraries that the projects link against but that the SDK does not ship.
# Homebrew keeps them outside the default search path.
LIB_INC = [
    "/Users/Admin/.homebrew/include",
    "/opt/homebrew/include",
    "/usr/local/include",
    "/opt/X11/include",
]
# Only directories that actually contain headers are kept.
WANT = ["png.h", "jpeglib.h", "openssl/ssl.h", "X11/Xlib.h", "grapheme.h", "tls.h"]


def extra_incs():
    out = []
    for d in LIB_INC:
        if not os.path.isdir(d):
            continue
        if any(os.path.exists(os.path.join(d, h)) for h in WANT):
            out.append(d)
    return out


def write_cfg(proj, name, text):
    d = os.path.join(CFG, proj)
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, name)
    if os.path.exists(p):
        return p
    open(p, "w", encoding="utf-8").write(text)
    return p


# miniz's CMake build generates miniz_export.h (visibility attributes).
MINIZ_EXPORT = """#ifndef MINIZ_EXPORT_H
#define MINIZ_EXPORT_H
#define MINIZ_EXPORT
#define MINIZ_NO_EXPORT
#endif
"""


def provision_miniz():
    root = os.path.join(RAW, "miniz")
    if not os.path.isdir(root):
        return False
    write_cfg("miniz", "miniz_export.h", MINIZ_EXPORT)
    return True


# dash generates nodes.h/syntax.h/token.h/builtins.h with its own helper
# programs. Running its build once is the only reliable way to get them.
def provision_dash():
    root = os.path.join(RAW, "dash")
    src = os.path.join(root, "src")
    if not os.path.isdir(src):
        return False
    # config.h lands in the top directory (AC_CONFIG_HEADERS), the rest in src/.
    need_src = ["nodes.h", "syntax.h", "token.h", "builtins.h"]
    if all(os.path.exists(os.path.join(src, n)) for n in need_src) and os.path.exists(
        os.path.join(root, "config.h")
    ):
        return True
    steps = [
        ["./autogen.sh"],
        ["autoconf"],
        ["./configure"],
        ["make", "-j4"],
    ]
    for cmd in steps:
        try:
            r = subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=600)
        except Exception:
            return False
        if r.returncode == 0 and cmd[0] in ("./configure", "make"):
            break
    return all(os.path.exists(os.path.join(src, n)) for n in need_src) and os.path.exists(
        os.path.join(root, "config.h")
    )


def main():
    incs = extra_incs()
    miniz = provision_miniz()
    dash = provision_dash()
    env = {"include_dirs": incs, "miniz": miniz, "dash": dash}
    open(os.path.join(BASE, "env.json"), "w", encoding="utf-8").write(json.dumps(env, indent=2))
    print(json.dumps(env, indent=2))


if __name__ == "__main__":
    main()
