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
SWEPT = ["01_DALOS.pact", "02_IGNIS.pact", "04_BRD.pact", "05_DPTF.pact", "06_DPOF.pact",
         "08_ATS.pact", "09_TFT.pact", "10_ATSU.pact"]

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


def classify(name, body, caps):
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
    if re.search(r'ref-[A-Za-z0-9|_\-]+::[A-Za-z0-9|_]+\s+[\w\-|]+\s+executor', body):
        return "FORWARDED", ""
    bare = name.split("|")[-1]
    if bare in SELF_PROVING:
        need = SELF_PROVING[bare]
        doc = re.search(r'@doc\s+"(.*?)(?<!\\)"', body, re.S)
        if doc and need.lower() in doc.group(1).lower():
            return "SELF-PROVING", f'@doc names "{need}"'
        return "UNPROVEN", (f'registered SELF-PROVING but its @doc does not name "{need}" '
                            f'-- the canon requires the proof to be written in the function')
    if bare in INDIRECT:
        need = INDIRECT[bare]
        doc = re.search(r'@doc\s+"(.*?)(?<!\\)"', body, re.S)
        if doc and need.lower() in doc.group(1).lower():
            return "INDIRECT", f'@doc names "{need}"'
        return "UNPROVEN", (f'registered INDIRECT but its @doc does not name "{need}" '
                            f'-- the canon requires the route to be written in the function')
    uses = len(re.findall(EXEC, body)) - 1
    return "UNPROVEN", ("DECORATIVE -- `executor` never appears in the body"
                        if uses <= 0 else f"used {uses}x, never proven")


def main():
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
            v, d = classify(n, body, caps)
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
