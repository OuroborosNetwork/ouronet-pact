#!/usr/bin/env python3
"""EVERY `executor` IS PROVEN -- directly, or by a route its own `@doc` names.

WHY THIS EXISTS. The patron/executor/executee canon (StoicSyntax-Prefixes.md §2.2) says every
`A_`/`C_` names the Ouronet account performing the execution, and the REASON is attribution: the
ledger should be able to answer "who did what" from the operation's own arguments.

That only works if the executor is ENFORCED. A parameter nobody checks is one the caller chooses
freely, so an entrypoint taking `executor` and never proving it does not record who acted -- it
records whoever the caller felt like naming, and the event it emits can implicate an account that
was nowhere near the transaction. **That is worse than having no executor**, because a missing one
is visibly missing and a decorative one looks like attribution.

Admin ops are where this goes wrong. The `GOV|*_ADMIN` keyset already opened the door, so the
executor feels like a label -- and a label is what it becomes. Found on 2026-09-21 in exactly that
shape: three DPTF treasury admin ops took `executor` and never mentioned it again.

WHAT IT CHECKS. For each `A_`/`C_`/`AA_`/`CC_` with an `executor` parameter, one of:

  1. DIRECT      -- CAP_EnforceAccountOwnership / UEV_Executor* / CAP_Owner runs on it, in the
                    function or in a capability the function acquires (two levels of
                    compose-capability are followed);
  2. FORWARDED   -- it is handed to another module's entrypoint in the executor position, which
                    is the Talos-wrapper and cross-core shape;
  3. INDIRECT    -- registered below WITH the route, which must also appear in the function's own
                    `@doc` -- the canon's "the path MUST be named" clause, made checkable;
  4. SELF-PROVING -- account creation, where the executor is the account being created and proves
                    itself with the guard it supplies. Same @doc discipline as INDIRECT.

Anything else is a finding. `--module X` scopes to one file, which is how `_modulecomplete.py`
consumes it: a module's turn is not done while it holds an executor nobody proves.

    python3 REPL/tools/_executorenforced.py               whole tree
    python3 REPL/tools/_executorenforced.py --module 05_DPTF.pact
    python3 REPL/tools/_executorenforced.py --swept       only modules whose turn has been taken
"""
import os, re, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Modules whose sweep turn is DONE -- the only ones this is fair to judge. Grown per turn.
def _swept():
    """The modules whose turn is done -- READ FROM THE WORKLIST, not remembered here.

    This was a hardcoded list and it had stopped at 10_ATSU while five more modules had been
    swept, so `--swept` silently judged a stale subset. That is the third tool in this programme
    to carry a hardcoded list that cannot report its own incompleteness (_toolpaths, _bandplan,
    _executorplan), and the fix is the same one: derive it from the artefact that is already the
    single source of truth. The handoff's 4 table IS the progress tracker -- a ticked row is the
    definition of "swept", so read the ticks.

    FAILS LOUD if the worklist cannot be read. An empty SWEPT would make `--swept` report a
    confident clean zero, which is the failure mode this whole file exists to prevent.
    """
    plan = os.path.join(ROOT, "OuronetInformational", "HANDOFFS",
                        "HANDOFF-executor-canon-sweep.md")
    if not os.path.exists(plan):
        sys.exit(f"_executorenforced: cannot find the worklist at {plan} -- refusing to guess "
                 f"which modules are swept.")
    done = re.findall(r"^\|\s*\[x\]\s*\d+\s*\|\s*`([^`]+\.pact)`", open(plan, encoding="utf8").read(), re.M)
    if not done:
        sys.exit("_executorenforced: the worklist has no ticked rows -- either nothing is swept "
                 "or the table format changed. Refusing to report on an empty set.")
    return done


SWEPT = _swept()

# INDIRECT routes: fn -> the substring its @doc must contain. Registering a route here is not a
# waiver; the tool still requires the function to SAY it, so the justification lives next to the
# code and not only in this table.
INDIRECT = {
    "C_Transmute":            "XB_DebitTrueFungible",
    "A_UpdatePublicKey":      "GOV|DALOS_ADMIN",
    "C_DonateStoa":           "EXECUTOR",
    "C_Issue":                "executor",
    # ATSU's two KickStart variants. The executor FUNDS the kickstart and is proven by the
    # transfer that spends its tokens; the capability's CAP_Owner (owner path) / GOV|ATSU_ADMIN
    # (admin path) is a SEPARATE authority, over the POOL, held by a different account.
    # Conflating those two is exactly what the position-aware matcher was added to stop -- it
    # passed C_KickStart for a day on the strength of a CAP_Owner two arguments away.
    "C_KickStart":            "XI_KickStart",
    "A_KickStart":            "XI_KickStart",
    # ---- 19_SWPU (2026-09-22). These forward the executor into a SAME-MODULE `XI_`, which the
    # FORWARDED branch cannot see -- it looks for `ref-X::`, i.e. a CROSS-module hand-off. That
    # is the correct shape for FORWARDED to match (a foreign module is what does the proving);
    # an internal hop has to be traced by a human and written down, which is what INDIRECT is.
    # The proof is the debit inside XI_Swap.
    "19_SWPU.pact::C_Swap":       "TFT::C_MultiTransfer",
    "19_SWPU.pact::CC_SmartSwap": "TFT::C_MultiTransfer",
    "19_SWPU.pact::C_SmartSwap":  "XI_Swap",
}

# SELF-PROVING AT CREATION -- the base case of the attribution rule, resolved by the owner on
# 2026-09-21 after being raised as an open question.
#
# In the four deploy entrypoints the `executor` is the account BEING CREATED, so its ownership
# cannot be read from a table: there is no row yet. It does not need to be. The GUARD the account
# is being created WITH is enforced in the same transaction --
#
#     (defcap DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT (account:string guard:guard stoa:string)
#         (ref-U|G::UEV_Any [guard (create-capability-guard (GOV))])   ;; <- FIRST, before format
#
# and `UEV_Any` is enforce-one ("at least one guard in GUARDS is successfully enforced"). So
# whoever deploys an account must sign for the guard that account will be governed by -- which is
# exactly what UEV_StandardAccOwn's own `(enforce-guard account-guard)` does for an account that
# already exists. Same proof, same key; the guard simply travels with the call because there is
# nowhere else it could come from yet.
#
# The second element of that list is the governance door in-line: module `GOV` can create an
# account without its guard being signed, which is how genesis bootstraps the first one.
#
# The claim is load-bearing and is PINNED by REPL/modules/DALOS-ADMIN.repl <<DALOS-G4b>>: a deploy
# whose guard the caller does not hold is refused by UEV_Any, and refused BEFORE the format guards
# -- so if that first list element were ever dropped, account creation would become unauthenticated
# and this entry would silently become false.
SELF_PROVING = {
 "A_DeploySmartAccount":    "UEV_Any",
 "A_DeployStandardAccount": "UEV_Any",
 "C_DeploySmartAccount":    "UEV_Any",
 "C_DeployStandardAccount": "UEV_Any",
}

OWN = re.compile(r'(CAP_EnforceAccountOwnership|UEV_Executor\w*|UEV_StandardAccOwn'
                 r'|UEV_SmartAccOwn|CAP_Owner)')
ENTRY = re.compile(r'(?:^|\|)(A|AA|C|CC)_')
EXEC = r'(?<![A-Za-z0-9_\-])executor(?![A-Za-z0-9_\-])'


def forms(src, kind):
    for m in re.finditer(r'^    \(' + kind + r'\s+([A-Za-z0-9|_\->]+)', src, re.M):
        i = m.start(); d = 0; j = i; ins = False
        while j < len(src):
            c = src[j]
            if ins:
                if c == '\\': j += 2; continue
                if c == '"': ins = False
            elif c == '"': ins = True
            elif c == ';': j = src.index('\n', j); continue
            elif c == '(': d += 1
            elif c == ')':
                d -= 1
                if d == 0:
                    yield m.group(1), src[i:j + 1], i; break
            j += 1


def _cap_params(ct):
    m = re.match(r'\s*\(defcap\s+[A-Za-z0-9|_\->]+\s*\(([^)]*)\)', ct, re.S)
    if not m: return []
    return [p.split(":")[0] for p in m.group(1).split()]


def _proves(caps, cname, pos, seen):
    """Does capability `cname` enforce ownership of ITS OWN parameter at index `pos`?
    Follows compose-capability one hop at a time, RE-MAPPING the position at each hop."""
    if pos is None or cname in seen: return None
    seen = seen | {cname}
    ct = caps.get(cname, "")
    if not ct: return None
    params = _cap_params(ct)
    if pos >= len(params): return None
    nm = params[pos]
    if re.search(r'(CAP_EnforceAccountOwnership|UEV_StandardAccOwn|UEV_SmartAccOwn)\s+'
                 + re.escape(nm) + r'(?![A-Za-z0-9_\-])', ct):
        return f"via {cname} ({nm})"
    if re.search(r'UEV_Executor\w*\s+' + re.escape(nm) + r'(?![A-Za-z0-9_\-])', ct):
        return f"via {cname} (bound: {nm})"
    for sm in re.finditer(r'compose-capability\s*\(([A-Za-z0-9|_\->]+)([^\n]*)', ct):
        sub, sargs = sm.group(1), sm.group(2)
        spos = next((k for k, v in enumerate(sargs.replace(")", " ").split()) if v == nm), None)
        got = _proves(caps, sub, spos, seen)
        if got: return f"via {cname} -> " + got[4:]
    return None


def classify(name, body, caps, base=""):
    """-> (verdict, detail). verdict in DIRECT / cap:… / FORWARDED / INDIRECT / UNPROVEN."""
    if re.search(OWN.pattern + r'\s+executor', body):
        return "DIRECT", ""
    for cm in re.finditer(r'with-capability\s*\(([A-Za-z0-9|_\->]+)([^\n]*)', body):
        cname, cargs = cm.group(1), cm.group(2)
        if not re.search(EXEC, cargs): continue
        # WHICH capability parameter did `executor` land in? Matching an ownership call
        # anywhere in the capability is not good enough -- `CAP_Owner ats` proves the POOL
        # OWNER while the executor sits unproven two arguments away, which is precisely the
        # "authority proven, actor unnamed" shape this tool exists to catch. It passed
        # ATSU::C_KickStart on that basis until 2026-09-21.
        pos = next((k for k, v in enumerate(cargs.replace(")", " ").split())
                    if v == "executor"), None)
        hit = _proves(caps, cname, pos, set())
        if hit:
            return "DIRECT", hit
    # THE MEMBER NAME MAY CONTAIN A HYPHEN. This read `[A-Za-z0-9|_]+` for the member, and Pact
    # identifiers contain `-`: every `ref-SWPL::XE_STOA-PID|AddLiquidity patron executor …` and
    # every `HOT-RBT|C_*` call was invisible to this branch, so three of 18_SWPLC's entrypoints
    # reported "used 5x, never proven" while forwarding the executor in the correct slot.
    #
    # THIRD TIME THIS EXACT MISTAKE HAS SURFACED IN ONE DAY -- _deadbind.py's `\b` (twice, in
    # scan() and in twins()) and here. `\b` and `[A-Za-z0-9|_]` both encode a PYTHON notion of a
    # word, and a Pact identifier is not one. Anything matching a Pact name needs `|`, `_` AND
    # `-`; pinned by --selftest below so the fourth time fails loudly instead of silently.
    if re.search(r'ref-[A-Za-z0-9|_\-]+::[A-Za-z0-9|_\-]+\s+[\w\-|]+\s+executor', body):
        return "FORWARDED", ""
    bare = name.split("|")[-1]
    if bare in SELF_PROVING:
        need = SELF_PROVING[bare]
        doc = re.search(r'@doc\s+"(.*?)(?<!\\)"', body, re.S)
        if doc and need.lower() in doc.group(1).lower():
            return "SELF-PROVING", f'@doc names "{need}"'
        return "UNPROVEN", (f'registered SELF-PROVING but its @doc does not name "{need}" '
                            f'-- the canon requires the proof to be written in the function')
    # FILE-QUALIFIED KEYS TAKE PRECEDENCE. A bare name is not unique across 46 modules --
    # `C_Issue` alone exists in DPTF, DPOF, ATS, SWPI and FVT, so an entry meant for one of them
    # silently applies to all five. It is a weaker hazard here than in _executorplan (a module
    # that does not NAME the route in its own @doc still fails), but it is the same hazard, and
    # the selftest below refuses any new ambiguous bare key.
    key = f"{base}::{bare}" if f"{base}::{bare}" in INDIRECT else bare
    if key in INDIRECT:
        need = INDIRECT[key]
        doc = re.search(r'@doc\s+"(.*?)(?<!\\)"', body, re.S)
        if doc and need.lower() in doc.group(1).lower():
            return "INDIRECT", f'@doc names "{need}"'
        return "UNPROVEN", (f'registered INDIRECT but its @doc does not name "{need}" '
                            f'-- the canon requires the route to be written in the function')
    uses = len(re.findall(EXEC, body)) - 1
    return "UNPROVEN", ("DECORATIVE -- `executor` never appears in the body"
                        if uses <= 0 else f"used {uses}x, never proven")


def selftest():
    """Pins the two repairs of 2026-09-22 so neither can quietly return.

    1. FORWARDED must see a hyphenated modref member. Pact identifiers contain `-`, `|` and `_`;
       a pattern built from a Python notion of "word" misses them. This exact mistake appeared
       three times in one day across two tools, always as a SILENT under-report -- the tool says
       "never proven" about code that proves it, or says nothing at all.
    2. SWEPT must be derived from the worklist, and must be non-empty.
    """
    bad = []
    cases = [
        ("(ref-SWPL::XE_STOA-PID|AddLiquidity patron executor swpair true)", True,
         "hyphenated member -- the 18_SWPLC regression"),
        ("(ref-ATS::HOT-RBT|C_Repurpose patron executor id)", True,
         "hyphenated PREFIX -- the HOT-RBT family"),
        ("(ref-TFT::C_Transfer patron executor receiver id amt true)", True,
         "the ordinary shape, which always worked"),
        ("(ref-TFT::C_Transfer patron sender executor id amt true)", False,
         "executor in slot 3 is the EXECUTEE position -- must NOT count as forwarded"),
        ("(ref-IGNIS::UC_IgnisPrice \"STOA-PID|C_AddIcedLiquidity\" executor)", False,
         "a price-table KEY in a string is not a call"),
    ]
    pat = r'ref-[A-Za-z0-9|_\-]+::[A-Za-z0-9|_\-]+\s+[\w\-|]+\s+executor'
    for src, want, why in cases:
        got = bool(re.search(pat, src))
        if got != want:
            bad.append(f"   FORWARDED match on {src!r} = {got}, expected {want}  ({why})")
    # AMBIGUOUS BARE KEYS. Promised in the comment beside the lookup, so it has to be real:
    # a bare INDIRECT key that matches entrypoints in more than one SWEPT module is applying a
    # route-claim written for one module to functions in another. Reported, not fatal, for the
    # pre-existing ones -- each still has to NAME its route in its own @doc, so the hazard is
    # bounded -- but a NEW one has to be file-qualified.
    import glob as _g
    where = {}
    for f in _g.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True):
        b = os.path.basename(f)
        if b not in SWEPT:
            continue
        for m in re.finditer(r"\(defun\s+([A-Za-z0-9|_\-]+)", open(f, encoding="utf8").read()):
            where.setdefault(m.group(1).split("|")[-1], set()).add(b)
    ambiguous = sorted(k for k in INDIRECT if "::" not in k and len(where.get(k, ())) > 1)
    if ambiguous:
        print("  _executorenforced: NOTE -- bare INDIRECT key(s) matching >1 swept module: "
              + ", ".join(f"{k} {sorted(where[k])}" for k in ambiguous))
    if not SWEPT:
        bad.append("   SWEPT is empty -- --swept would report a confident clean zero")
    if "01_DALOS.pact" not in SWEPT:
        bad.append("   SWEPT does not contain 01_DALOS.pact -- the worklist parse is broken")
    if bad:
        print("SELFTEST FAILED -- _executorenforced\n" + "\n".join(bad))
        return 1
    print(f"  _executorenforced selftest: {len(cases)} forwarding shapes OK, "
          f"SWEPT derived ({len(SWEPT)} modules)")
    return 0


def main():
    if "--selftest" in sys.argv:
        return selftest()
    only = None
    if "--module" in sys.argv:
        only = sys.argv[sys.argv.index("--module") + 1]
    swept_only = "--swept" in sys.argv

    files = sorted(glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
                   + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True))
    bad, ok = [], 0
    for f in files:
        base = os.path.basename(f)
        if only and base != only: continue
        if swept_only and base not in SWEPT: continue
        src = open(f).read()
        ms = re.search(r'^\(module\s', src, re.M)
        ms = ms.start() if ms else 0
        caps = {n: t for n, t, i in forms(src, "defcap") if i >= ms}
        defs = {}
        for n, t, i in forms(src, "defun"):
            if i >= ms: defs[n] = t          # module copy wins over the interface declaration
        for n, body in defs.items():
            if not ENTRY.search(n) or n.startswith("P|"): continue
            if "executor:string" not in body[:500]: continue
            v, d = classify(n, body, caps, base)
            if v == "UNPROVEN":
                bad.append((base, n, d))
            else:
                ok += 1

    scope = f"--module {only}" if only else ("swept modules" if swept_only else "whole tree")
    print(f"executor enforcement -- {scope}:  {ok} proven, {len(bad)} UNPROVEN")
    for base, n, d in bad:
        print(f"   {base:<22} {n:<38} {d}")
    if bad:
        print("\n   The canon (StoicSyntax §2.2) requires an executor to be proven directly, or")
        print("   indirectly BY A ROUTE THE FUNCTION'S OWN @doc NAMES. An unenforced executor is")
        print("   not an audit trail -- the caller picks the name, so the event can implicate an")
        print("   account that was never involved.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
