#!/usr/bin/env python3
"""THE PATRON/EXECUTOR/EXECUTEE WORKLIST -- every A_/C_ entrypoint, classified.

Canon: StoicSyntax-Prefixes.md §2.2. Every A_/AA_/C_/CC_ function takes `patron:string
executor:string` as its FIRST TWO parameters, no exceptions.

WHY THIS EXISTS RATHER THAN _bandplan. _bandplan's entrypoint filter was

    re.match(r"^(A|AA|C|CC)_" + "|" + r"\\|(A|AA|C|CC)_", n)      # the broken form

and re.match anchors the WHOLE pattern at position 0, so the second alternative could only fire on
a name starting with a bar. Every Talos entrypoint -- ATS|A_KickStart, DPTF|C_Issue -- was
invisible. It reported 89 patron-taking entrypoints against an actual 482, and the refactor was
scoped and reported against that number for its entire first day. Talos is the ONLY client-facing
path in this system, so the blind spot was the client surface.

CLASSIFICATION, on the SECOND parameter (the executor slot):

    DONE     already named `executor`
    RENAME   an ACCOUNT under a bespoke name -- kickstarter / curler / coiler / fueler / account /
             owner-konto / client / injector / sender ... -> rename to `executor`
    ADD      an ENTITY id (id, ats, swpair, pool-id, fvt-id ...) -- there is no executor parameter
             at all and one must be added; the executor is currently derived inside a capability
    PATRON   the first parameter is not `patron` -- needs one (Talos supplies GASLESS-PATRON for A_)

The RENAME/ADD split matters: assuming "second parameter == executor" is wrong for 286 functions,
where that slot holds an entity id.

    python3 REPL/tools/_executorplan.py                 summary
    python3 REPL/tools/_executorplan.py --module F.pact per-file detail
    python3 REPL/tools/_executorplan.py --state RENAME  flat list of one class
"""
import os, re, sys, glob, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "REPL", "tools"))
import _bandplan as B

ENTRY = re.compile(r'(?:^|\|)(A|AA|C|CC)_')
ACCT = re.compile(r'^(account|konto|owner|client|sender|receiver|beneficiary|staker|user|operator|'
                  r'holder|injector|collector|executor|recoverer|remover|merger|wrapper|unwrapper|'
                  r'kickstarter|curler|coiler|fueler|swapper|swaper|minter|burner|depositor|'
                  r'withdrawer|creator|patron)')
TYPED = re.compile(r'([A-Za-z0-9|_-]+):(?:string|bool|integer|decimal|guard|\[[^\]]+\]|object[^\s)]*)')


def plan():
    rows = []
    for p in sorted(glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)):
        s = open(p, encoding="utf8").read()
        mi = s.find("\n(module ")
        if mi < 0:
            continue
        for n, b in B._forms(s[mi:], "defun"):
            if not ENTRY.search(n):
                continue
            ps = TYPED.findall(B._params(b))
            f = os.path.basename(p)
            if not ps or ps[0] != "patron":
                rows.append((f, n, "PATRON", ps[0] if ps else ""))
                continue
            p2 = ps[1] if len(ps) > 1 else ""
            if p2 == "executor":
                rows.append((f, n, "DONE", p2))
            elif ACCT.match(p2):
                rows.append((f, n, "RENAME", p2))
            else:
                rows.append((f, n, "ADD", p2))
    return rows


def main():
    rows = plan()
    if "--module" in sys.argv:
        want = sys.argv[sys.argv.index("--module") + 1]
        for f, n, st, p2 in rows:
            if f == want:
                print(f"  {st:7s} {n:38s} {p2}")
        return 0
    if "--state" in sys.argv:
        want = sys.argv[sys.argv.index("--state") + 1]
        for f, n, st, p2 in rows:
            if st == want:
                print(f"  {f:24s} {n:38s} {p2}")
        return 0
    c = collections.Counter(st for _, _, st, _ in rows)
    print(f"A_/C_ entrypoints in 1_SOVEREIGN modules: {len(rows)}")
    for st in ("DONE", "RENAME", "ADD", "PATRON"):
        print(f"   {st:8s} {c[st]:4d}")
    print(f"\n   remaining: {len(rows) - c['DONE']}")
    print("\nby module, remaining first:")
    per = collections.Counter(f for f, _, st, _ in rows if st != "DONE")
    for f, k in per.most_common(16):
        print(f"   {f:26s} {k}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
