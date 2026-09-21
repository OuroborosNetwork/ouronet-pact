#!/usr/bin/env python3
"""DEAD LET-BINDINGS — a `let` binding that COMPUTES something and is then never read.

    cd REPL && python3 _deadbind.py [--show N] [--all]

The value is computed -- often a table read -- and discarded. USUALLY waste rather than a wrong
answer, and a reliable sign that a function was edited without cleaning up behind the edit.

CORRECTED 2026-09-21. This used to say flatly "Not a correctness bug: nothing downstream sees a
wrong answer." 15_SWP::A_ToggleAsymetricLiquidityAddition is the counterexample. It bound

    (ignis-fee-exemption-role  : … SWP|SC_NAME)      ;; read TWICE
    (ignis-fee-exemption-roleV2: … vst-sc)           ;; read NEVER

and the second guard tested the FIRST name while guarding a call about the SECOND account. The
dead binding was not leftover waste -- it was the correct name, dropped by a copy-paste that kept
the wrong one. So the deadness was a symptom of a live correctness bug, and worse, anyone
"cleaning up dead code" on this tool's say-so would have DELETED THE EVIDENCE and left the defect.

That is what `--twins` is for. A dead binding whose name is a near-twin of a binding in the SAME
`let` that is read MORE THAN ONCE is not noise: it is this shape, and the tool found exactly one
instance in the whole tree. `--twins` is the gate-fatal mode; the plain listing stays advisory
because 150 bindings of genuine waste would make it unusable and therefore ignored.

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


def _uses(name, text):
    """Count real uses of a Pact binding name.

    `\\b` IS WRONG FOR PACT IDENTIFIERS and both call sites here used it. Pact names contain
    `-`, `|` and `_`, none of which Python treats as word characters, so `\\blst\\b` MATCHES INSIDE
    `lst-v2`. Two opposite faults followed from the one mistake:
      * scan() then thinks a genuinely dead `lst` is used whenever any `lst-*` name appears --
        a false NEGATIVE, so the dead-binding count is a floor, not a total;
      * twins() reported `lst` as "read 7x" in 03_AQP::XI_RevokeScoreFromPool when every one of
        those seven was `lst-v2`.
    Found by reading the very first thing --twins printed, which was a false positive for BOTH
    this reason and the one fixed beside it. A detector's first output is a test of the detector.
    """
    return len(re.findall(r"(?<![A-Za-z0-9|_-])" + re.escape(name) + r"(?![A-Za-z0-9|_-])", text))


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
                if _uses(name, "".join(binds[i + 1:]) + body):
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


def _bindex(binds, name):
    for i, b in enumerate(binds):
        m = re.match(r"\(\s*([A-Za-z][A-Za-z0-9|_-]*)\s*:", b)
        if m and m.group(1) == name:
            return i
    return -1


def _twin(a, b):
    """Are these two binding names near-twins? Deliberately NARROW. The point is a detector with
    no noise, so it only fires on the shapes a copy-paste actually produces: one name is the
    other plus a version-ish suffix (V2, 2, -2, -b, -new, -alt)."""
    lo, hi = sorted((a, b), key=len)
    if lo == hi or not hi.startswith(lo):
        return False
    return re.fullmatch(r"[-_]?([Vv]?\d+|b|alt|new|old|bis)", hi[len(lo):]) is not None


def twins():
    """Dead bindings that are near-twins of an OVER-read sibling in the same `let`.

    Both halves of the condition carry weight. Dead alone is waste (150 of those). Read-twice
    alone is normal. Dead BESIDE a twin that is read twice is the fingerprint of a guard that was
    duplicated and not re-pointed -- one of those two reads belongs to the dead name.
    """
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
            names = []
            for b in binds:
                nm = re.match(r"\(\s*([A-Za-z][A-Za-z0-9|_-]*)\s*:", b)
                if nm and not nm.group(1).startswith("ref-"):
                    names.append(nm.group(1))
            # LATER BINDINGS COUNT AS USES. The first version of this looked only at the body,
            # so a binding consumed by the very next binding read as dead -- which is what
            # 03_AQP's `lst-v1` is: `(lst-v2 (UC_AppL lst-v1 BAR))` on the following line.
            # scan() had this right; twins() was written fresh and did not.
            uses = {}
            for i, n in enumerate(names):
                later = "".join(binds[j] for j in range(len(binds)) if j > _bindex(binds, n))
                uses[n] = _uses(n, later + body)
            for dead in [n for n in names if uses[n] == 0]:
                for live in names:
                    if live != dead and uses[live] > 1 and _twin(dead, live):
                        out.append((os.path.relpath(f, ROOT),
                                    src[:m.start()].count("\n") + 1, dead, live, uses[live]))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=15)
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--twins", action="store_true",
                    help="gate mode: only dead bindings that are near-twins of an over-read "
                         "sibling. Exits non-zero on any hit.")
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args()

    if a.selftest:
        # the CANARY check below is the scan's selftest; this adds the twin predicate's, because
        # a detector whose whole value is PRECISION has to be shown to still fire at all.
        cases = [("ignis-fee-exemption-role", "ignis-fee-exemption-roleV2", True),
                 ("x", "x2", True), ("x", "x-b", True), ("amount", "amount-new", True),
                 ("sender", "receiver", False), ("lp-id", "lp-id-frozen", False),
                 ("fee", "fee-target", False), ("a", "a", False)]
        bad = [f"   _twin({x!r},{y!r}) = {_twin(x, y)}, expected {w}"
               for x, y, w in cases if _twin(x, y) != w]
        if bad:
            print("SELFTEST FAILED -- _deadbind --twins\n" + "\n".join(bad))
            return 1
        print(f"  _deadbind selftest: {len(cases)} twin predicates OK")
        return 0

    if a.twins:
        t = twins()
        if not t:
            print("dead-binding twins: clean -- no dead binding shadows an over-read sibling")
            return 0
        print(f"!! {len(t)} DEAD BINDING(S) BESIDE AN OVER-READ NEAR-TWIN:")
        for f, line, dead, live, n in t:
            print(f"   {f}:{line}\n      `{dead}` is never read, while its twin `{live}` is read "
                  f"{n}x. One of those {n} reads probably belongs to `{dead}`.")
        return 1

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
