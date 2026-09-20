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

    EXEMPT   `P|` policy functions -- setup, not client. Excluded entirely, by owner ruling.
    DONE     already named `executor`
    RENAME   an ACCOUNT under a bespoke name -- kickstarter / curler / coiler / fueler / account /
             owner-konto / client / injector / sender ... -> rename to `executor`
    ADD      an ENTITY id (id, ats, swpair, pool-id, fvt-id ...) -- there is no executor parameter
             at all and one must be added; the executor is currently derived inside a capability
    PATRON   the first parameter is not `patron` -- needs one (Talos supplies GASLESS-PATRON for A_)

POSITION IS CANON. patron 1st, executor 2nd, executee 3rd when present. A function whose executor
exists but sits fourth is NOT conforming. Pact arguments are positional, so a signature that has
to be reordered rewrites every call site -- which is why RENAME and ADD are counted separately
from the reorder they may also imply.

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

# PATRONLESS BY DESIGN (owner correction, 2026-09-20). PATRONLESS is not the same as GASLESS:
# gasless means a patron exists and the GASLESS-PATRON is supplied; patronless means no patron is
# needed AT ALL because there is none at that moment. Adding one to these is WRONG.
#
#   * account deployment -- the payer is the thing being created, so the account being deployed IS
#     the executor and there is nobody to pay yet
#   * the IGNIS source/collector primitives -- they MAKE virtual gas or compress it back to its
#     source, so they are what a patron would be paid FROM. CLAUDE.md already records that these
#     "are the collectors and cannot collect from themselves".
#
# This is a registry of DESIGN FACTS, discovered and recorded per function -- never a fallback for
# "no patron was found".
PATRONLESS = {
    "C_DeploySmartAccount", "A_DeploySmartAccount",
    "C_DeployStandardAccount", "A_DeployStandardAccount",
    "DALOS|C_DeploySmartAccount", "DALOS|A_DeploySmartAccount",
    "DALOS|C_DeployStandardAccount", "DALOS|A_DeployStandardAccount",
    "C_Collect", "C_TransferDalosFuel",
    "STOA|C_Collect", "STOA|C_CollectWT", "STOA|C_CollectFull", "STOA|C_CollectWTEx",
}
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
            # `P|` POLICY FUNCTIONS ARE EXEMPT (owner ruling 2026-09-20). They are not client
            # functions -- they are deploy-time setup and inter-module-guard registration, run by
            # the admin with special permissions. The `P|` denomination exists precisely to signal
            # that, which is why this is a blanket exclusion and not a per-function judgement.
            # P|A_Define takes no parameters at all: nothing to pay for, nobody to act upon.
            if n.startswith("P|"):
                continue
            ps = TYPED.findall(B._params(b))
            f = os.path.basename(p)
            # A TALOS A_ WRAPPER CORRECTLY HAS NO PATRON -- the blessed path supplies
            # GASLESS-PATRON itself, which is exactly why the parameter disappears from the
            # wrapper while remaining in the module. Without this rule the tool demands a patron on
            # 200+ Talos admin wrappers and "fixing" them would BREAK the canon it is checking.
            is_talos = os.sep + "3_Talos" + os.sep in p
            is_admin = re.search(r'(?:^|\|)(A|AA)_', n) is not None
            if is_talos and is_admin:
                rows.append((f, n, "DONE" if ps and ps[0] == "executor" else "ADD",
                             ps[0] if ps else ""))
                continue
            if n in PATRONLESS:
                rows.append((f, n, "DONE" if ps and ps[0] == "executor" else "ADD",
                             ps[0] if ps else ""))
                continue
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
