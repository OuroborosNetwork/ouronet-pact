#!/usr/bin/env python3
"""VACUOUS / WEAK POSITIVE ASSERTIONS — which `(expect ...)` cannot fail, or barely can?

    cd REPL && python3 _vacuous.py [--show N] [--weak]

`_expectfail.py` audits the NEGATIVE side: a 2-arg `expect-failure` passes on any error. Nothing
audited the POSITIVE side, and there are ~2,600 of them. A positive assertion has its own failure
mode: comparing something to itself, or to a bound it cannot miss. Both go green forever and read
in a diff exactly like a real test.

TWO CATEGORIES, deliberately separated -- the first is provable, the second is a judgement call:

  VACUOUS  cannot fail at all.
             * expected and actual are syntactically IDENTICAL (modulo whitespace)
             * both sides are literals -- (expect "..." true true)
           These are defects. There is no input that makes them red.

  WEAK     can fail in principle, but not for any realistic value. The common shape is
           `true` asserted against a bound the domain already guarantees --
           (>= price 0.0) on a price, (>= count 0) on a length. It says "the call returned"
           dressed as a check. Reported separately, and NOT called a defect: sometimes "it
           runs at all" is genuinely the thing being pinned, and the surrounding comment is
           the only way to tell. Read before changing.

           TWO KINDS OF HIT ARE LEGITIMATE AND WILL KEEP APPEARING:
             * a SENTINEL bound. `(> (UR_ScoreClass s) -1)` is not a trivial bound -- -1 is the
               "no such row" sentinel, so it is a real existence check (modules/AQP.repl AQP-G14).
             * an ACCEPTANCE check. `(>= (URCv_Sublimate 0.99) 0.0)` exists to prove the call is
               ACCEPTED rather than aborting; the return value is not the subject
               (modules/OUROBOROS.repl ORBR-G1, modules/ATS.repl ATS-G8).
             * `(>= <balance> 0.0)` IS A REAL CHECK IN THIS CODEBASE. An OURO balance is NOT
               domain-guaranteed non-negative: sublimating against a zero balance drives it
               negative, which is the Dispo/overdraft mechanism, and modules/OUROBOROS.repl
               ORBR-G2 asserts exactly that a few lines before the flagged assertion asserts the
               opposite about a different account. The generic "(>= x 0.0) is trivial" heuristic
               is wrong here; treat balance bounds as substantive unless the reader proves
               otherwise.
           Fix the ones where a real relationship was available and nobody wrote it. Two in
           modules/STAGE-Z.repl were mine and are now exact + linearity + agreement-with-DALOS.

WHAT THIS DOES NOT CATCH: an assertion whose expected value is computed by the very code under
test. That needs to know which function is under test, which is not recoverable syntactically.
Mutation -- break the expectation, confirm red, restore -- remains the only complete check.
"""
import argparse, glob, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _pactlex import strip_comments, balanced, split_top

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

LITERAL = re.compile(r'^(true|false|-?\d+(\.\d+)?|"[^"]*"|\[\s*\])$')
# `true` asserted against a bound the value's own domain already guarantees.
TRIVIAL_BOUND = re.compile(
    r'^\(\s*(>=)\s+\(?.*?\)?\s+(0|0\.0|0\.00+)\s*\)$|'      # (>= <expr> 0.0)
    r'^\(\s*(>)\s+\(?.*?\)?\s+(-1|-1\.0)\s*\)$'             # (> <expr> -1)
    , re.S)


def norm(s):
    return re.sub(r'\s+', ' ', s.strip())


# A comparison whose two operands are TEXTUALLY IDENTICAL. `(= A A)` is always true, `(> A A)` always
# false -- either way the assertion's outcome does not depend on any state, so it cannot fail for a
# reason anyone cares about.
#
# ADDED 2026-09-12 after this tool MISSED one. I wrote `(expect "…supply is back to its pre-test
# value" true (= (UR_NonceSupply X) (UR_NonceSupply X)))` as a no-leakage check in
# modules/DPDC.repl, ran `_vacuous.py`, and got a clean 0. The existing VACUOUS test compares the
# EXPECTED against the ACTUAL and is blind to a self-comparison nested INSIDE the actual -- which is
# the shape a leakage check most naturally degrades into, because the two sides you want to compare
# are "the value now" and "the value before", and when you have no handle on "before" it is one
# keystroke to write "now" twice.
#
# Precise and false-positive-free: a literal self-comparison is vacuous by construction. No judgement
# call, so it belongs in VACUOUS rather than WEAK.
_CMP = ('=', '!=', '>=', '<=', '>', '<')


def self_comparison(expr):
    """The first `(op A A)` inside <expr> with syntactically identical operands, or None.

    Scans nested forms, not just the top level: the self-comparison is usually buried inside a
    `let`, a `map` or an `and`."""
    for m in re.finditer(r'\(\s*(=|!=|>=|<=|>|<)\s', expr):
        e = balanced(expr, m.start())
        if e < 0:
            continue
        args = split_top(expr[m.end():e])
        if len(args) == 2 and norm(args[0]) == norm(args[1]) and norm(args[0]):
            return f"({m.group(1)} {norm(args[0])} <same>)"
    return None


def _sites_in(path):
    """Sites in ONE file. Split out so --selftest exercises the SAME parser the real run uses --
    a self-test against a reimplementation would prove nothing about the shipped code path."""
    src = strip_comments(open(path, encoding='utf8', errors='ignore').read())
    return list(_extract(src, path))


def _extract(src, f):
    """Every (expect …) site in one already-stripped source. Factored out so --selftest drives the
    SAME parser the real run uses; a self-test against a reimplementation would prove nothing about
    the shipped path."""
    if True:
        for m in re.finditer(r'\(expect\s', src):
            e = balanced(src, m.start())
            if e < 0:
                continue
            inner = src[m.start() + len("(expect"):e]
            parts = []
            i = 0
            while i < len(inner) and len(parts) < 3:
                c = inner[i]
                if c.isspace():
                    i += 1; continue
                if c == '"':
                    j = i + 1
                    while j < len(inner) and not (inner[j] == '"' and inner[j-1] != '\\'):
                        j += 1
                    parts.append(inner[i:j+1]); i = j + 1
                elif c in '([':
                    j = balanced(inner, i, c, ')' if c == '(' else ']')
                    if j < 0: break
                    parts.append(inner[i:j+1]); i = j + 1
                else:
                    j = i
                    while j < len(inner) and not inner[j].isspace() and inner[j] not in '()[]':
                        j += 1
                    parts.append(inner[i:j]); i = j
            if len(parts) < 3:
                continue
            line = src[:m.start()].count('\n') + 1
            yield (os.path.relpath(f, ROOT), line, parts[0], norm(parts[1]), norm(parts[2]))


def sites():
    for f in sorted(glob.glob(os.path.join(ROOT, "**", "*.repl"), recursive=True)):
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        for rec in _extract(src, f):
            yield rec


# SELF-TEST (--selftest). This tool's HEALTHY state and its BROKEN state look identical: both
# report "VACUOUS: 0". The single real instance in the suite has been fixed, so there is no live
# canary to key on -- synthetic inputs it is.
SELFTEST = [
    ('(expect "d" (F x) (F x))',            1, "identical sides"),
    ('(expect "d" true true)',              1, "both literals"),
    ('(expect "d" 5.0 (F x))',              0, "literal vs call -- fine"),
    ('(expect "d" (F x) (G x))',            0, "different calls -- fine"),
    # the 2026-09-12 miss: a self-comparison NESTED in the actual. Both of these were reported
    # clean before `self_comparison` existed.
    ('(expect "d" true (= (F x) (F x)))',   1, "self-comparison inside the actual"),
    ('(expect "d" true (and p (= (F x y) (F x y))))', 1, "...even nested two levels down"),
    ('(expect "d" true (= (F x) (F y)))',   0, "different args -- fine"),
    ('(expect "d" true (>= (F x) 0.0))',    0, "real bound -- not a self-comparison"),
]


def run_selftest():
    import tempfile, shutil
    bad = []
    tmp = tempfile.mkdtemp()
    for src, want, why in SELFTEST:
        fn = os.path.join(tmp, "t.repl")
        open(fn, "w").write(src + "\n")
        got = 0
        for _f, _l, _doc, exp, act in _sites_in(fn):
            if (exp == act or (LITERAL.match(exp) and LITERAL.match(act))
                    or self_comparison(act)):
                got += 1
        ok = got == want
        if not ok:
            bad.append(f"{why}: want {want}, got {got}  [{src}]")
        print(f"  {'ok ' if ok else 'BAD'} want={want} got={got}   {why}")
    shutil.rmtree(tmp, ignore_errors=True)
    if bad:
        sys.exit("_vacuous.py SELF-TEST FAILED:\n  " + "\n  ".join(bad) +
                 "\n  The detector is broken, not the suite. A clean 0 means nothing right now.")
    print("\nvacuous self-test: OK")
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=12)
    ap.add_argument("--weak", action="store_true", help="list the WEAK sites too")
    ap.add_argument("--selftest", action="store_true",
                    help="run the detector against synthetic inputs and exit")
    # VACUOUS is a hard invariant and WEAK is not, so only VACUOUS is fatal. Wired into _gate.py
    # 2026-09-15: a suite whose assertions cannot fail reports clean about a region it has stopped
    # testing, which is the deepest version of the failure this whole round has been about. I wrote
    # a toothless assertion myself this month (`step1 > discount x 951`, which the defect it was
    # written for would have passed); nothing but a detector catches that, because a green test and
    # a green non-test look identical from the outside.
    ap.add_argument("--check", action="store_true",
                    help="exit non-zero if any positive assertion is VACUOUS (WEAK is advisory)")
    a = ap.parse_args()
    if a.selftest:
        return run_selftest()

    total, vac, weak = 0, [], []
    for f, line, doc, exp, act in sites():
        total += 1
        if exp == act:
            vac.append((f, line, doc, exp, "expected and actual are IDENTICAL"))
        elif LITERAL.match(exp) and LITERAL.match(act):
            vac.append((f, line, doc, exp, f"both sides are literals ({exp} vs {act})"))
        elif self_comparison(act):
            vac.append((f, line, doc, exp,
                        f"the actual compares something to ITSELF: {self_comparison(act)}"))
        elif exp == "true" and TRIVIAL_BOUND.match(act):
            weak.append((f, line, doc, act))

    print(f"positive `expect` sites: {total}")
    print(f"  VACUOUS (cannot fail)        : {len(vac)}")
    print(f"  WEAK    (bound the domain guarantees): {len(weak)}\n")

    if vac:
        print("VACUOUS -- these are defects; no input makes them red:")
        for f, line, doc, exp, why in vac[:a.show]:
            print(f"  {f}:{line}\n      {doc[:88]}\n      {why}")
        if len(vac) > a.show:
            print(f"  … and {len(vac)-a.show} more")
    else:
        print("VACUOUS: none -- every positive assertion can be made to fail by some input.")

    if a.weak and weak:
        print("\nWEAK -- read the surrounding comment before changing; 'it runs at all' is")
        print("sometimes genuinely the point:")
        for f, line, doc, act in weak[:a.show]:
            print(f"  {f}:{line}\n      {doc[:88]}\n      {act[:96]}")
        if len(weak) > a.show:
            print(f"  … and {len(weak)-a.show} more")
    if a.check:
        return 1 if vac else 0
    return 0


sys.exit(main())
