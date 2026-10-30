#!/usr/bin/env python3
"""Random differential testing for Qiang.

Generates C programs whose behaviour is fully defined (unsigned arithmetic
wraps, shifts are masked, loops have bounded trip counts, no uninitialised
reads), compiles each one with clang and with Qiang, runs both and compares the
exit status and stdout. A mismatch is a compiler bug, not a source bug, because
the program has exactly one legal behaviour.

Usage: tools/fuzz_diff.py [--count N] [--seed S] [--keep DIR]
"""
import argparse, os, random, subprocess, sys, tempfile


class Gen:
    def __init__(self, rng):
        self.rng = rng
        self.nfunc = 0

    def uexpr(self, scope, depth):
        r = self.rng
        if depth <= 0 or r.random() < 0.35:
            if scope and r.random() < 0.6:
                return r.choice(scope)
            return r.choice(['1u', '2u', '3u', '0u', '7u', '255u', '65535u', '0xdeadbeefu'])
        op = r.choice(['+', '-', '*', '&', '|', '^', '<<', '>>'])
        a = self.uexpr(scope, depth - 1)
        b = self.uexpr(scope, depth - 1)
        if op in ('<<', '>>'):
            return '(%s %s (%s & 15u))' % (a, op, b)
        return '(%s %s %s)' % (a, op, b)

    def cmp(self, scope, depth):
        return '(%s < %s)' % (self.uexpr(scope, depth), self.uexpr(scope, depth))

    def func(self):
        r = self.rng
        n = self.nfunc
        self.nfunc += 1
        params = r.randint(0, 3)
        pnames = ['p%d' % i for i in range(params)]
        body = []
        scope = list(pnames)
        for i in range(r.randint(1, 6)):
            v = 'v%d' % i
            body.append('    unsigned %s = %s;' % (v, self.uexpr(scope, r.randint(1, 3))))
            scope.append(v)
        trip = r.randint(1, 5)
        loopv = 'acc%d' % n
        body.append('    unsigned %s = 0;' % loopv)
        body.append('    for (unsigned i = 0; i < %du; i++) {' % trip)
        body.append('        %s = %s + %s;' % (loopv, loopv, self.uexpr(scope, 2)))
        body.append('        if (%s) %s = %s ^ i;' % (self.cmp(scope, 1), loopv, loopv))
        body.append('    }')
        body.append('    printf("%s: %%u\\n", %s);' % ('f' + str(n), loopv))
        body.append('    return %s;' % loopv)
        head = 'static unsigned f%d(%s) {' % (n, ', '.join('unsigned ' + p for p in pnames))
        return head, body, params

    def program(self):
        r = self.rng
        funcs = [self.func() for _ in range(r.randint(1, 3))]
        out = ['#include <stdio.h>', '']
        for head, body, _ in funcs:
            out.append(head)
            out.extend(body)
            out.append('}')
            out.append('')
        out.append('int main(void) {')
        out.append('    unsigned total = 0;')
        total = 0
        for i, (_, _, params) in enumerate(funcs):
            args = ', '.join(str(r.randint(0, 1000)) + 'u' for _ in range(params))
            out.append('    unsigned r%d = f%d(%s);' % (i, i, args))
            out.append('    total = total + r%d;' % i)
        out.append('    printf("total: %u\\n", total);')
        out.append('    return 0;')
        out.append('}')
        return '\n'.join(out) + '\n'


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, timeout=60, **kw)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--count', type=int, default=100)
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--keep', default=None)
    a = ap.parse_args()
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    qiang = None
    for base in (os.path.join(root, '_build'), os.path.join(os.path.dirname(root), '_build')):
        for dirpath, _dirs, files in os.walk(base) if os.path.isdir(base) else []:
            if 'qiang.exe' in files:
                qiang = os.path.join(dirpath, 'qiang.exe')
                break
        if qiang:
            break
    if not qiang:
        sys.exit('error: qiang.exe not built')
    inc = os.path.join(root, 'include', 'qiang')
    ok = bad = skipped = 0
    fails = []
    tmp = tempfile.mkdtemp()
    for i in range(a.count):
        rng = random.Random(a.seed + i)
        src = os.path.join(tmp, 'p%d.c' % i)
        open(src, 'w').write(Gen(rng).program())
        ref = os.path.join(tmp, 'ref')
        if run(['clang', '-w', '-O0', src, '-o', ref]).returncode != 0:
            skipped += 1
            continue
        pre = os.path.join(tmp, 'p%d.i' % i)
        with open(pre, 'w') as fh:
            if subprocess.run(['clang', '-E', '-P', '-I', inc, src],
                                  stdout=fh, stderr=subprocess.DEVNULL,
                                  timeout=60).returncode != 0:
                skipped += 1
                continue
        obj = os.path.join(tmp, 'p%d.o' % i)
        c = run([qiang, pre, '-o', obj])
        if c.returncode != 0:
            bad += 1
            fails.append((src, 'qiang failed rc=%d: %r' % (c.returncode, c.stderr.decode()[:200])))
            continue
        exe = os.path.join(tmp, 'p%d' % i)
        if run(['clang', obj, '-o', exe]).returncode != 0:
            bad += 1
            fails.append((src, 'link failed'))
            continue
        try:
            r1 = run([ref])
            r2 = run([exe])
        except subprocess.TimeoutExpired:
            bad += 1
            fails.append((src, 'timeout'))
            continue
        if r1.returncode != r2.returncode or r1.stdout != r2.stdout:
            bad += 1
            fails.append((src, 'ref rc=%d out=%r / qiang rc=%d out=%r' % (
                r1.returncode, r1.stdout[:120], r2.returncode, r2.stdout[:120])))
        else:
            ok += 1
    print('fuzz: %d agree, %d disagree, %d skipped (of %d)' % (ok, bad, skipped, a.count))
    for src, why in fails[:5]:
        print('  FAIL', src, '->', why)
        keep = a.keep or os.path.join(root, 'build', 'fuzz')
        os.makedirs(keep, exist_ok=True)
        dest = os.path.join(keep, os.path.basename(src))
        open(dest, 'w').write(open(src).read())
        print('    saved', dest)
    sys.exit(0 if bad == 0 else 1)


if __name__ == '__main__':
    main()