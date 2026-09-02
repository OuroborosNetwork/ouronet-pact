#!/usr/bin/env python3
"""StoicSyntax canon conformance CHECKER (Phase 7 drift-gate).

Read-only. For every module/interface .pact it runs the skeleton emitter in a temp
copy and asserts the file is ALREADY canonical — same content up to blank lines
(blank-line count is not a canon rule; the emitter's block spacing is cosmetic).
A real difference (member re-ordered, wrong marker, wrong cap band, unknown prefix,
CAP_ outside {5.4}, …) is a VIOLATION.

Exit code 0 = clean, 1 = one or more violations. Wire into the green-gate so future
work can't drift without the gate going red.

Usage: canon_check.py [paths...]   (default: all sovereign+citizen .pact)
"""
import sys, os, re, tempfile, subprocess, glob, shutil, difflib

HERE = os.path.dirname(os.path.abspath(__file__))
EMIT = os.path.join(HERE, 'skeleton_emit.py')

def norm(path):
    # non-blank lines only (canon compares structure/markers/order, not blank spacing)
    return [l for l in open(path, encoding='utf-8', errors='ignore').read().split('\n') if l.strip() != '']

def check(path):
    tmp = tempfile.mktemp(suffix='.pact')
    shutil.copy(path, tmp)
    r = subprocess.run([sys.executable, EMIT, tmp], capture_output=True, text=True)
    if r.returncode != 0 or 'UNPLACED' in (r.stdout + r.stderr):
        os.remove(tmp)
        return ['ABORT/UNPLACED: ' + (r.stdout + r.stderr).strip()[:200]]
    a, b = norm(path), norm(tmp)
    os.remove(tmp)
    if a == b:
        return []
    # produce a compact diff of the first few real differences
    diff = [d for d in difflib.unified_diff(a, b, lineterm='', n=0) if d and d[0] in '+-' and not d.startswith(('+++', '---'))]
    return diff[:8]

def main(paths):
    if not paths:
        paths = sorted(glob.glob('1_SOVEREIGN/**/*.pact', recursive=True) +
                       glob.glob('2_CITIZEN/**/*.pact', recursive=True))
    violations = 0
    for p in paths:
        v = check(p)
        if v:
            violations += 1
            print(f"✗ {p}")
            for l in v:
                print(f"    {l}")
    if violations:
        print(f"\ncanon_check: {violations} file(s) NOT canonical — run: python3 tools/skeleton_emit.py <file>")
        return 1
    print(f"canon_check: ✓ all {len(paths)} files canonical")
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
