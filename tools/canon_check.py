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

def doc_violations(path):
    # §7.15: every sovereign (module)/(interface) must carry a @doc right after the
    # header. Citizen @doc is optional (need-basis) — skip 2_CITIZEN.
    if '2_CITIZEN' in path:
        return []
    L = open(path, encoding='utf-8', errors='ignore').read().split('\n')
    out = []
    for i, l in enumerate(L):
        if not (l.startswith('(module ') or l.startswith('(interface ')):
            continue
        j = i + 1
        while j < len(L) and L[j].strip() == '':
            j += 1
        if not (j < len(L) and L[j].strip().startswith('@doc')):
            out.append(f"MISSING @doc: {l.split()[1] if len(l.split())>1 else l.strip()}")
    return out

def check(path):
    tmp = tempfile.mktemp(suffix='.pact')
    shutil.copy(path, tmp)
    r = subprocess.run([sys.executable, EMIT, tmp], capture_output=True, text=True)
    if r.returncode != 0 or 'UNPLACED' in (r.stdout + r.stderr):
        os.remove(tmp)
        return ['ABORT/UNPLACED: ' + (r.stdout + r.stderr).strip()[:200]]
    a, b = norm(path), norm(tmp)
    os.remove(tmp)
    docs = doc_violations(path)
    if a == b:
        return docs
    # produce a compact diff of the real differences, AND report net content loss.
    #
    # `diff[:8]` (2026-09-15) truncated every file to eight lines, so seven of the fifteen
    # offenders all reported exactly "8" and the real scale was invisible. Worse, a positional
    # diff cannot tell a MOVE from a DELETE -- which is the only question that matters before
    # running the fixer on live core. Measured properly (whitespace-normalised multiset
    # difference): skeleton_emit moves 251 forms and deletes ZERO of them, but it DROPS 24 lines
    # of comment -- and every one is an audit annotation recording a prior investigation
    # ("NEVER COMPOSED, and the asymmetry it would close is INTENTIONAL", "TESTED, AND THE
    # HYPOTHESIS WAS WRONG", "NINE FVT|C>* defcaps were REMOVED here on 2026-09-10"). Losing those
    # is how the next person re-runs an experiment that has already been done.
    diff = [d for d in difflib.unified_diff(a, b, lineterm='', n=0) if d and d[0] in '+-' and not d.startswith(('+++', '---'))]
    import collections, re as _re
    _n = lambda t: _re.sub(r'\s+', ' ', t.strip())
    lost = list((collections.Counter(_n(x) for x in a if x.strip())
                 - collections.Counter(_n(x) for x in b if x.strip())).elements())
    _com = [x for x in lost if x.startswith(';;')]
    head = []
    if lost:
        head = [f"!! NET CONTENT LOSS if fixed: {len(lost)} line(s), of which {len(_com)} are COMMENTS"]
        head += [f"   LOST COMMENT: {c[:100]}" for c in _com]
    return head + diff[:8]

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
        print(f"\ncanon_check: {violations} file(s) NOT canonical.")
        print("DO NOT run tools/skeleton_emit.py on them blind -- it MOVES forms correctly but\n"
              "DROPS adjacent comment lines, and in this tree every dropped line is an audit\n"
              "annotation recording a prior investigation. Any !! NET CONTENT LOSS line above is\n"
              "content that will not come back. Move the forms BY HAND, carrying their commentary,\n"
              "or fix skeleton_emit to keep comments attached to the form beneath them.")
        return 1
    print(f"canon_check: ✓ all {len(paths)} files canonical")
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
