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
    (registries) PATRONLESS = no patron exists (deploy, the fuel transfer); EXECUTORLESS = the
                 collector primitives, which keep `patron` and have no separate actor.
    DONE     already named `executor`
    RENAME   an ACCOUNT under a bespoke name -- kickstarter / curler / coiler / fueler / account /
             owner-konto / client / injector / sender ... -> rename to `executor`
    ADD      an ENTITY id (id, ats, swpair, pool-id, fvt-id ...) -- there is no executor parameter
    REVIEW   the 2nd parameter matches NEITHER list -- READ THE BODY, do not assume. Added
             2026-09-21. This used to fall through to ADD, i.e. the tool silently DECIDED "no
             executor here" on the strength of a name it had simply never seen. 11_VST.pact is the
             proof: freezer / reserver / vester / sleeper / hibernator / awaker / constricter /
             brumator are all ACCOUNTS and every one reported ADD -- following that would have
             bolted a second account parameter beside the executor already present, in 11
             signatures. 36 entrypoints tree-wide were in that state. ACCT is a hardcoded list and
             a hardcoded list cannot report its own incompleteness; the fallback is now LOUD.
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
    # RECLASSIFIED 2026-09-20: `C_TransferDalosFuel` is now `XB_MoveDalosFuel`, out of the `C_`
    # band entirely, so it is out of this sweep's scope and no longer needs an entry here. Kept as
    # a comment because the NAME is what future greps will look for.
    "C_DonateStoa",
    # THE GAS-SOURCE FAMILY, added 2026-09-21 after it was broken. The owner's ruling named
    # "sublimate and compress ... because they either make gas or compress it back to its gas
    # source", and this registry did not contain them -- so DPTF's threading pass gave all three
    # a patron and nothing objected. The proof they are patronless is in the wrapper:
    # ORBR|C_Sublimate COLLECTS NOTHING, binding the returned cumulator only to read its output
    # for the result string. A registry that is missing an entry is not neutral; it is a rule
    # that silently does not apply.
    "C_Sublimate", "C_SublimateV2", "C_Compress",
    "ORBR|C_Sublimate", "ORBR|C_SublimateV2", "ORBR|C_Compress",
    # verified 2026-09-21: its patron was unused in the body, threaded in only because
    # C_SublimateV2 had temporarily acquired one.
    "SWP|C_Firestarter",
}

# EXECUTORLESS -- distinct from PATRONLESS, and the distinction matters. These functions ARE the
# collection: charging the named account is their entire job, so there is no separate actor and an
# `executor` would just be a second word for the same account. They keep `patron` and take NO
# executor. (Engineering inference, 2026-09-20, NOT an owner ruling -- it follows CLAUDE.md's note
# that these primitives "are the collectors and cannot collect from themselves".)
EXECUTORLESS = {
    # RETIRED 2026-09-21, kept as a tombstone rather than deleted. Every name that was here --
    # C_Collect, STOA|C_Collect{,WT,Full,WTEx} -- NO LONGER EXISTS: the collectors were
    # reclassified out of the C_ band on 2026-09-20 into XE_CollectIgnis / XE_CollectStoa /
    # XB_Collect*, behind P|UEV_IMC. An X_ is outside the patron/executor canon entirely, so the
    # "executorless" category dissolved with the misclassification that created it -- which is
    # the right outcome: a category that exists only to explain functions that do not fit their
    # prefix is describing a naming error, not a shape.
    #
    # Left non-empty-looking on purpose. The same stale-name failure hit the PRICE SHEET, whose
    # shape-B detector went on grepping for `C_Collect*` for a day after the rename and silently
    # stopped resolving three entrypoints. A rename pass has to carry the TOOLS that name the
    # old thing.
}
ACCT = re.compile(r'^(account|konto|owner|client|sender|receiver|beneficiary|staker|user|operator|'
                  r'holder|injector|collector|executor|recoverer|remover|merger|wrapper|unwrapper|'
                  r'kickstarter|curler|coiler|fueler|swapper|swaper|minter|burner|depositor|'
                  r'withdrawer|creator|patron)')
# ENTITY ids -- the shapes that legitimately mean "there is no executor parameter here".
# Kept EXPLICIT for the same reason ACCT is: so that a name matching NEITHER list is reported
# rather than assumed. See REVIEW below.
ENTITY = re.compile(r'^(id|ats|swpair|pool-id|fvt-id|score-id|anchor-id|dptf|dpof|dpsf|dpnf|'
                    r's-dptf|s-dpof|nonce|set-class|model-id|triplet-id|link-id|lp-id|'
                    r'.*-to-repurpose|.*-id|.*-pair|.*-token|.*-output)$')

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
            if n in EXECUTORLESS:
                rows.append((f, n, "DONE" if ps and ps[0] == "patron" else "PATRON",
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
            elif ENTITY.match(p2):
                rows.append((f, n, "ADD", p2))
            else:
                # NEITHER a known account name NOR a recognisable entity id. Previously this fell
                # through to ADD, which is a DECISION -- "there is no executor here, add one" --
                # taken silently on the strength of a name the list had simply never seen.
                # 11_VST.pact is the proof: freezer / reserver / vester / sleeper / hibernator /
                # awaker / constricter / brumator are all ACCOUNTS, every one reported ADD, and
                # following that would have bolted a second account parameter beside the executor
                # that was already there, in 11 signatures. ACCT is a hardcoded list and a
                # hardcoded list cannot report its own incompleteness -- CLAUDE.md records exactly
                # this about _toolpaths.py. So the fallback is now LOUD: REVIEW means "read the
                # body", not "assume".
                rows.append((f, n, "REVIEW", p2))
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
    for st in ("DONE", "RENAME", "ADD", "REVIEW", "PATRON"):
        print(f"   {st:8s} {c[st]:4d}")
    print(f"\n   remaining: {len(rows) - c['DONE']}")
    print("\nby module, remaining first:")
    per = collections.Counter(f for f, _, st, _ in rows if st != "DONE")
    for f, k in per.most_common(16):
        print(f"   {f:26s} {k}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
