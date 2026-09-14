#!/usr/bin/env python3
"""DEAD LET-BINDINGS — a `let` binding that COMPUTES something and is then never read.

    cd REPL && python3 _deadbind.py [--show N] [--all]

The value is computed -- often a table read -- and discarded. Not a correctness bug: nothing
downstream sees a wrong answer. It is WASTE on live paths, and it is a reliable sign that a
function was edited without cleaning up behind the edit.

Distinct from the three neighbouring tools, none of which sees this:
  _letfix.py   formats let forms (vertical staircase); says nothing about use.
  _eagerlet.py a guard whose own SUBJECT is hard-read in the binding group above it.
  _foldeager.py a later `fold` conjunct consuming what an earlier one validates.
  `_conformance.py --rule shadowed-let-binding` catches a name bound TWICE; this catches a name
  bound ONCE and never read.

SELF-TEST, AND WHY IT IS NOT OPTIONAL
------------------------------------
Three scans written during this work returned a confident clean 0 over a class already reproduced
by hand: one matched a quote that an earlier `strip` had already blanked; one looked for
`(length (UR_X …))` when the real code binds the list first; one filtered to calls with an
UPPERCASE head and so missed `(length rt-ats-pairs)`, a native. Each looked like a clean result.

So this tool verifies itself on every run against two bindings confirmed by hand --
`TFT::URCx_CPF_RT-RBT`'s `length-rt` and `length-rbt` -- and EXITS NON-ZERO if it cannot find them.
A detector that cannot find a known instance is reporting its own bug, not the codebase's.
"""
import argparse, collections, glob, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _pactlex import strip_comments, balanced, split_top

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CANARY = [("09_TFT.pact", "length-rt"), ("09_TFT.pact", "length-rbt")]


def scan():
    out = []
    files = sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                   + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
    for f in files:
        if "/Audit/" in f:
            continue
        src = strip_comments(open(f, encoding="utf8", errors="ignore").read())
        for m in re.finditer(r"\(let\*?\s*\(", src):
            g = m.end() - 1
            e = balanced(src, g)
            be = balanced(src, m.start())
            if e < 0 or be < 0:
                continue
            body = src[e + 1:be]
            binds = split_top(src[g + 1:e])
            for i, b in enumerate(binds):
                nm = re.match(r"\(\s*([A-Za-z][A-Za-z0-9|_-]*)\s*:", b)
                if not nm:
                    continue
                name = nm.group(1)
                if name.startswith("ref-"):
                    continue           # modref bindings: _conformance's dead-modref-binding owns these
                if re.search(r"\b" + re.escape(name) + r"\b", "".join(binds[i + 1:]) + body):
                    continue
                val = b[nm.end():]
                if "(" not in val:
                    continue           # a bound literal costs nothing; not worth reporting
                # Cost class. HEAVY matters most: one scan is ~40,000 gas (see STAGEZ-17).
                if re.search(r"\b(URH_|URHC_|URD_|keys|select|fold-db)\b", val):
                    kind = "HEAVY"
                elif re.search(r"\b(UR_|URC_|read|with-read|with-default-read)", val):
                    kind = "read"
                else:
                    kind = "pure"
                out.append((os.path.relpath(f, ROOT), src[:m.start()].count("\n") + 1, name, kind))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=15)
    ap.add_argument("--all", action="store_true")
    a = ap.parse_args()

    hits = scan()
    found = {(os.path.basename(h[0]), h[2]) for h in hits}
    missing = [c for c in CANARY if c not in found]
    if missing:
        sys.exit(f"_deadbind.py SELF-TEST FAILED: known dead bindings not detected: {missing}\n"
                 f"  The scan is broken, not the codebase. Do NOT trust the count.")

    by = collections.Counter(h[3] for h in hits)
    print(f"dead let-bindings (computed, never read): {len(hits)}")
    print(f"  HEAVY (a scan, ~40,000 gas each): {by['HEAVY']}")
    print(f"  table read (point read)         : {by['read']}")
    print(f"  pure compute                    : {by['pure']}")
    print(f"  self-test: OK -- both canaries detected\n")

    rows = [h for h in hits if h[3] == "HEAVY"] + [h for h in hits if h[3] != "HEAVY"]
    per = collections.Counter(os.path.basename(h[0]) for h in hits)
    print("  most affected files:")
    for f, c in per.most_common(8):
        print(f"    {c:3}  {f}")
    print()
    for f, line, name, kind in (rows if a.all else rows[:a.show]):
        print(f"  {kind:5} {os.path.basename(f):24}:{line:<6} {name}")
    if not a.all and len(rows) > a.show:
        print(f"  … and {len(rows)-a.show} more (--all)")
    return 0


sys.exit(main())
