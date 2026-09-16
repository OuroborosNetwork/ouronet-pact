#!/usr/bin/env python3
"""UNVERIFIED @doc CLAIMS — a function whose doc promises a RULE that no test pins.

    cd REPL && python3 _docclaims.py [--show N] [--all]

WHY. TS01-A's `ORBR|A_Fuel` carried "As Stand-Alone Function, can only be used by the Admin" and
nothing enforced it -- `(with-capability (SECURE) …)` where that module's SECURE is
`(defcap SECURE () true)`. Any signer could fire it. It was found by hand, by probing Talos admin
entrypoints with a non-admin key during an unrelated sweep. `_conformance.py`'s admin-gate-terminal
rule now catches that STRUCTURE. This catches the other half: the CLAIM.

A `@doc` saying "only the owner can", "never", "must" is a specification. Unlike a comment it reads
as authoritative, it survives every refactor untouched, and nothing checks it. When the code drifts
the doc becomes a confident lie -- and reviewers trust it precisely because it sounds definite.

TIERS, strongest first:
  AUTHORITY   "only the admin/owner", "cannot be called", "not allowed" -- who may do this.
              A false one is a SECURITY claim. This is the ORBR|A_Fuel class.
  BOUND       "no more than", "at most", "between X and Y", "maximum" -- a numeric limit.
  INVARIANT   "always", "never", "must", "guaranteed" -- everything else.

COVERAGE is deliberately CRUDE and generous: a claim counts as touched if the name appears
anywhere in any .repl. That OVER-counts -- being called is not being verified -- so the list is a
floor: a name here is not merely unverified, it is never mentioned.

IT ALSO UNDER-COUNTS FOR DEFCAPS, which is the sharper trap. A `defcap` is never named by a test;
it is acquired by the defun that composes it. `FVT|C>UNSTALE-ALL` was reported as unmentioned while
its ownership gate WAS fully tested, via `CCp_UnstaleAll`, in
Stage_02/[6.2.8d]_AQP-UNSTALE-ALL-CC.repl. So a defcap hit means "check the acquirer", not
"untested". Only `defun` hits can be read at face value.

STATUS 2026-09-11: all 7 AUTHORITY claims are now verified. ORBR|A_Fuel (the claim was FALSE --
fixed); FVT|C>UNSTALE-ALL (already tested, see above); and five pinned in this pass --
ORBR|C_WithdrawFees, the three VST|C_Create*Link, and ATS|C_VestedCoil.
"""
import argparse, glob, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _pactlex import strip_comments, ident_re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.dirname(ROOT)

# The verb list is deliberately WIDE. The first version matched only "can only be used/called/
# invoked" and silently missed STOAICO::A_Stake's "Can only be DONE by the Admin" -- an unverified
# admin claim, the exact ORBR|A_Fuel shape, hiding behind one unlisted verb. Prefer a false
# positive here to a miss: a wrong hit costs one read, a miss costs a security claim.
AUTHORITY = re.compile(r'\b(can only be (used|called|invoked|done|executed|performed|run|fired)|'
                       r'only the (admin|owner|demiurgoi)|'
                       r'admin[- ]only|only by the (admin|owner)|'
                       r'cannot be (called|invoked|used|done|executed)|not allowed|'
                       r'only .{0,24}(admin|owner|sovereign|governor) )', re.I)
# Immutability is its own class and none of the patterns below caught it: "A Frozen Link is
# immutable" states a permanent property of stored state, which is the strongest kind of promise a
# contract can make and the most damaging to get wrong. Small tier by design -- 8 occurrences in
# the whole codebase -- so it can be triaged exhaustively rather than sampled.
IMMUTABLE = re.compile(r'\b(immutable|irreversible|permanently|cannot be (changed|modified|undone|'
                       r'reverted|reversed))\b', re.I)
BOUND     = re.compile(r'\b(no more than|at most|maximum of|must be between|no less than|'
                       r'cannot exceed|up to \d)', re.I)
INVARIANT = re.compile(r'\b(always|never|must not|is guaranteed|guarantees that)\b', re.I)

DOC = re.compile(r'\(def(?:un|cap)\s+([A-Za-z0-9|_>-]+)[^\n]*\n?\s*@doc\s+("(?:[^"\\]|\\.)*")', re.S)


# CANARIES. Claims confirmed by hand; if a pattern edit stops matching them the tool is broken and
# must say so rather than report a smaller, cleaner-looking number. This tool has ALREADY shipped
# two silent blind spots: an AUTHORITY verb list that matched "used/called/invoked" but not "done"
# (hiding STOAICO::A_Stake's admin claim), and no IMMUTABLE pattern at all (hiding the VST link
# claims). Both produced confident, wrong totals. A canary cannot catch a MISSING CLASS -- nothing
# can -- but it does stop a working class from silently narrowing.
CANARY = {
    "AUTHORITY": ["ORBR|A_Fuel", "A_Stake", "VST|C_CreateFrozenLink"],
    "IMMUTABLE": ["VST|C_CreateSleepingLink"],
}


def selftest(classified):
    missing = []
    for tier, names in CANARY.items():
        have = classified.get(tier, set())
        missing += [f"{tier}:{n}" for n in names if n not in have]
    if missing:
        sys.exit("_docclaims.py SELF-TEST FAILED -- known claims no longer matched: "
                 + ", ".join(missing) +
                 "\n  The pattern is broken, not the codebase. Do NOT trust the totals.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show", type=int, default=10)
    ap.add_argument("--all", action="store_true", help="include claims whose function IS mentioned")
    a = ap.parse_args()

    repl = " ".join(open(f, encoding='utf8', errors='ignore').read()
                    for f in glob.glob(os.path.join(ROOT, "**", "*.repl"), recursive=True))

    files = sorted(glob.glob(f"{REPO}/1_SOVEREIGN/**/*.pact", recursive=True)
                   + glob.glob(f"{REPO}/2_CITIZEN/**/*.pact", recursive=True))
    tiers = {"AUTHORITY": [], "IMMUTABLE": [], "BOUND": [], "INVARIANT": []}
    classified = {}
    total = 0
    for f in files:
        if "/Audit/" in f:
            continue
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        for m in DOC.finditer(src):
            name, doc = m.group(1), m.group(2)
            flat = re.sub(r'\\\s*\\?', ' ', doc)          # undo Pact's `\`-continuation
            flat = re.sub(r'\s+', ' ', flat).strip('" ')
            tier = ("AUTHORITY" if AUTHORITY.search(flat) else
                    "IMMUTABLE" if IMMUTABLE.search(flat) else
                    "BOUND" if BOUND.search(flat) else
                    "INVARIANT" if INVARIANT.search(flat) else None)
            if not tier:
                continue
            total += 1
            # Canary source: classification BEFORE the mention filter. The canary must test what
            # the PATTERNS matched, not what survived filtering -- a first version checked the
            # filtered list and failed in default mode precisely because the canary functions are
            # now tested, so they are filtered out. It was reporting the tool healthy-or-broken
            # based on test coverage, which is the opposite of what it is for.
            classified.setdefault(tier, set()).add(name)
            # identifier-aware boundary (see _pactlex.ident_re): with `\b`, a hyphenated name is a
            # PREFIX match against every longer name containing it, so a function would be counted
            # as "mentioned in the REPL corpus" because a DIFFERENT, longer function is. That
            # direction under-reports unverified doc claims, which is the wrong way for this tool
            # to be wrong.
            mentioned = ident_re(name.split('|')[-1]).search(repl) is not None
            if mentioned and not a.all:
                continue
            tiers[tier].append((os.path.relpath(f, REPO),
                                src[:m.start()].count('\n') + 1, name, flat[:150]))

    selftest(classified)
    shown = sum(len(v) for v in tiers.values())
    print(f"@doc claims found: {total}")
    # The label must follow the MODE. In --all the filter is off, so `shown` is every claim, not
    # the unmentioned ones -- printing the strict label there reported "100 never mentioned" when
    # the real answer was 100 TOTAL and far fewer unmentioned.
    if a.all:
        print(f"listing ALL of them (--all); the 'never mentioned' filter is OFF\n")
    else:
        print(f"claims whose function is NEVER mentioned in any .repl: {shown}\n")
    for tier in ("AUTHORITY", "IMMUTABLE", "BOUND", "INVARIANT"):
        hits = tiers[tier]
        print(f"[{tier}] {len(hits)}")
        for f, line, name, doc in hits[:a.show]:
            print(f"  {f}:{line}  {name}")
            print(f"      \"{doc}\"")
        if len(hits) > a.show:
            print(f"  … and {len(hits)-a.show} more")
        print()
    return 0


sys.exit(main())
