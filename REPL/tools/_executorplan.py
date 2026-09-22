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
import ast, os, re, sys, glob, collections

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
    # THE FREE LINK, added 2026-09-22 at 22_PYTHIA's turn. Patronless by DESIGN, and unusually
    # well evidenced -- CLAUDE.md already carries the ruling ("One deliberately free op exists"),
    # both @docs say "(no fee)", and modules/PYTHIA.repl <<PYTHIA-LINK-ECON>> pins the economics
    # that make it safe: linking needs two deployed Apollo halves at 500 native STOA each,
    # UEV_DualPairForLink refuses a half whose counterpart is set, and counterparts are NEVER
    # cleared -- so ~1000 STOA buys exactly ONE free link, forever, per pair.
    #
    # It is bounded, not cheap. If counterparts ever become clearable this entry is wrong and the
    # op needs a patron; the test above is what would notice.
    "C_LinkDualApiKey", "PYTHIA|C_Link",
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
    # THE TWO ELITE MAINTENANCE OPS, added 2026-09-22 at 02_TS01-C1's turn. Both @docs say
    # "Can be used without account ownership by anyone", and that is TRUE, not aspirational --
    # verified by reading ELITE::XE_UpdateEliteSingle, which enforces nothing on <account>: only
    # P|UEV_IMC (the module-caller gate) and P|ELITE|CALLER. The op recomputes DERIVED elite data
    # from state already on chain, is idempotent, and is deliberately permissionless so anyone can
    # repair a stale row.
    #
    # So there is no actor to name. The accounts in the signature are SUBJECTS -- acted upon,
    # needing no signature -- and the only authenticated account in the call is the patron, who
    # pays. Renaming a subject to `executor` would have manufactured attribution out of a
    # parameter nobody checks, which the canon rates WORSE than having none: the emitted message
    # would name whoever the caller typed. The @docs now say this outright.
    "DALOS|C_UpdateEliteAccount", "DALOS|C_UpdateEliteAccountSquared",
    # Left non-empty-looking on purpose. The same stale-name failure hit the PRICE SHEET, whose
    # shape-B detector went on grepping for `C_Collect*` for a day after the rename and silently
    # stopped resolving three entrypoints. A rename pass has to carry the TOOLS that name the
    # old thing.
    #
    # ONE LIVE ENTRY, added 2026-09-21 at 13_OUROBOROS's turn. This is a DESIGN FACT with the
    # evidence attached, not a fallback for "no executor was found" -- the distinction this file
    # insists on everywhere else.
    #
    #   ORBR::C_Fuel sweeps the OUROBOROS smart account's OWN native STOA into the liquid index.
    #   The acting account is ORBR|SC_NAME, a module CONSTANT, and it already occupies the
    #   executor slot of both downstream calls -- LIQUID::C_WrapStoa, where LIQUID|C>X_WRAPPER
    #   proves it with CAP_EnforceAccountOwnership, and ATSU::C_Fuel, where TFT proves it. So the
    #   actor is named and proven; it simply is not a parameter, and making it one would create a
    #   slot that can hold exactly one legal value. That is ceremony, not attribution, and the
    #   canon's own rule -- "an unenforced executor is WORSE than none" -- is about attribution
    #   being real.
    #
    #   OPEN FOR THE OWNER, NOT DECIDED HERE: `C_Fuel` looks like it is in the wrong BAND. It has
    #   no Talos `C_` wrapper, it is reachable only from other sovereign modules (TS01-A's
    #   XI_DirectFuelSTOA and 20_MTX-SWP's defpact step 2), and BOTH callers DISCARD its
    #   OutputCumulator -- deliberately, since the gas station pays for the re-fuelling rather
    #   than the user. That is an `XE_`, by exactly the reasoning the 2026-09-20 owner ruling used
    #   to move the collectors out of the `C_` band. It is not changed here because a band change
    #   cascades the `OuroborosV2` interface, and the last one of these was an owner ruling.
    "13_OUROBOROS.pact::C_Fuel",
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


def _slot(p):
    """Classify whatever occupies the EXECUTOR slot. ONE function, used by EVERY branch.

    ADDED 2026-09-21, and the reason is the same meta-finding for the third time. The REVIEW
    state was introduced that morning to stop this tool SILENTLY DECIDING "no executor here" on
    the strength of a name it had never seen -- but it was wired into the `patron`-first branch
    ONLY, because that is the branch where 11_VST exhibited the bug. The PATRONLESS and
    Talos-admin branches, where slot 0 IS the executor slot, went on hardcoding

        "DONE" if ps[0] == "executor" else "ADD"

    so an ACCOUNT sitting correctly in the executor slot reported ADD. ORBR::C_Compress
    (client:string ignis-amount:decimal) is the proof: `client` is IN the ACCT list, and the tool
    said "there is no executor parameter, add one" -- which, followed literally, bolts a second
    account beside the one already there. Exactly the 11_VST failure, in the branch the 11_VST
    fix did not touch.

    A fix applied to the OCCURRENCE rather than to the CLASS leaves the class intact.
    """
    if p == "executor":
        return "DONE"
    if ACCT.match(p):
        return "RENAME"
    if ENTITY.match(p):
        return "ADD"
    # An EMPTY slot is not an unknown name -- it is a definite absence, so ADD is a reading of
    # the evidence rather than a guess. Only a name matching NEITHER list is REVIEW.
    return "REVIEW" if p else "ADD"


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
                # A BILLED ADMIN WRAPPER KEEPS ITS PATRON, and this branch used to deny that.
                # The rule is "a Talos A_ wrapper has no patron BECAUSE the blessed path supplies
                # GASLESS-PATRON" -- it is a statement about GASLESS ops, not about admin ops.
                # Three wrappers in 01_TS01-A genuinely charge: DPTF|A_DeployAccount,
                # DPOF|A_DeployAccount and ATS|AA_RemoveSecondary all end in
                # `XE_CollectIgnis patron ...`. Classifying their slot 0 reported `patron` as a
                # RENAME candidate -- i.e. "rename the billing account to executor", which is the
                # handoff's own "executor = patron is not a safe default" mistake, prescribed by
                # a tool. ATS|AA_RemoveSecondary already had BOTH and was still reported unswept.
                #
                # So: if slot 0 is a real patron, this is an ordinary (patron, executor) shape and
                # the executor slot is slot 1. Otherwise slot 0 IS the executor slot.
                if ps and ps[0] == "patron":
                    p2 = ps[1] if len(ps) > 1 else ""
                    rows.append((f, n, _slot(p2), p2))
                else:
                    rows.append((f, n, _slot(ps[0] if ps else ""), ps[0] if ps else ""))
                continue
            if n in EXECUTORLESS or f"{f}::{n}" in EXECUTORLESS:
                rows.append((f, n, "DONE" if ps and ps[0] == "patron" else "PATRON",
                             ps[0] if ps else ""))
                continue
            if n in PATRONLESS or f"{f}::{n}" in PATRONLESS:
                rows.append((f, n, _slot(ps[0] if ps else ""), ps[0] if ps else ""))
                continue
            if not ps or ps[0] != "patron":
                rows.append((f, n, "PATRON", ps[0] if ps else ""))
                continue
            p2 = ps[1] if len(ps) > 1 else ""
            rows.append((f, n, _slot(p2), p2))

    return rows


def selftest():
    """PINS THE 2026-09-21 REGRESSION, because a repair that only I verified is a claim about
    the past. The gate runs every `--selftest` it finds, so from here on the tool re-derives
    this on every run.

    Case 1 is the bug itself: an ACCOUNT name in the executor slot must be RENAME. It reported
    ADD for every PATRONLESS and Talos-admin entrypoint, because the REVIEW fix earlier the same
    day was wired into one branch of three.
    Case 4 is the property REVIEW exists for: an unrecognised name is reported, never assumed.
    """
    cases = [
        ("client",              "RENAME", "ACCT name in the executor slot -- ORBR::C_Compress"),
        ("executor",            "DONE",   "already canon"),
        ("swpair",              "ADD",    "an entity id -- no executor parameter exists"),
        ("brumator",            "REVIEW", "matches NEITHER list -- read the body, do not assume"),
        ("",                    "ADD",    "a definite absence, not an unknown name"),
        ("dptf-to-repurpose",   "ADD",    "entity, via the -to-repurpose arm"),
    ]
    bad = []
    for arg, want, why in cases:
        got = _slot(arg)
        if got != want:
            bad.append(f"   _slot({arg!r}) = {got}, expected {want}  ({why})")
    # And the structural property that the bug violated: ONE classifier, used by every branch.
    # Checked on the AST, not on the text: the first version of this grepped the source for
    # `else "ADD"` and tripped on its own docstring, which QUOTES the broken form. A structural
    # property deserves a structural check.
    tree = ast.parse(open(os.path.abspath(__file__), encoding="utf8").read())
    fn = next(f for f in tree.body if isinstance(f, ast.FunctionDef) and f.name == "plan")
    for call in ast.walk(fn):
        if not (isinstance(call, ast.Call) and isinstance(call.func, ast.Attribute)
                and call.func.attr == "append"):
            continue
        tup = call.args[0]
        if not (isinstance(tup, ast.Tuple) and len(tup.elts) == 4):
            continue
        st = tup.elts[2]
        # Legitimate non-_slot states: the bare "PATRON" (no patron in slot 0, so the executor
        # slot has not been reached yet) and the EXECUTORLESS ternary, which classifies the
        # PATRON slot rather than the executor slot. Anything else is the bug coming back.
        consts = {c.value for c in ast.walk(st)
                  if isinstance(c, ast.Constant) and isinstance(c.value, str)}
        ok = (isinstance(st, ast.Call) and getattr(st.func, "id", None) == "_slot") \
             or consts <= {"DONE", "PATRON", "patron"}
        if not ok:
            bad.append(f"   plan() classifies the executor slot inline (line {st.lineno}) "
                       f"instead of via _slot()")
    # AMBIGUOUS BARE NAMES. Both registries are keyed by function name, and a name is not unique
    # across 46 modules: `C_Fuel` exists in 10_ATSU (which HAS an executor), 13_OUROBOROS (which
    # by design does not) and 18_SWPLC. Registering the bare name silenced ATSU's entrypoint
    # through the wrong branch -- same verdict, wrong reason, and the verdict would have survived
    # someone deleting ATSU's executor. A `file.pact::name` key is exact; this check is what stops
    # the next bare one being added.
    byname = collections.defaultdict(set)
    for f, n, _, _ in plan():
        byname[n].add(f)
    for entry in sorted(EXECUTORLESS | PATRONLESS):
        if "::" in entry:
            continue
        where = byname.get(entry, set())
        if len(where) > 1:
            bad.append(f"   registry key {entry!r} is ambiguous -- {sorted(where)}; "
                       f"use a 'file.pact::{entry}' key")
    if bad:
        print("SELFTEST FAILED -- _executorplan\n" + "\n".join(bad))
        return 1
    print(f"  _executorplan selftest: {len(cases)} slot classifications OK, single classifier")
    return 0


def main():
    if "--selftest" in sys.argv:
        return selftest()
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
