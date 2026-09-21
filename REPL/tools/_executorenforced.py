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
                    `@doc` -- the canon's "the path MUST be named" clause, made checkable.

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
         "08_ATS.pact", "09_TFT.pact"]

# INDIRECT routes: fn -> the substring its @doc must contain. Registering a route here is not a
# waiver; the tool still requires the function to SAY it, so the justification lives next to the
# code and not only in this table.
INDIRECT = {
    "C_Transmute":            "XB_DebitTrueFungible",
    "A_UpdatePublicKey":      "GOV|DALOS_ADMIN",
    "C_DonateStoa":           "EXECUTOR",
    "C_Issue":                "executor",
}

# OPEN -- a real question put to the owner, not a waiver and not a defect. Printed every run so
# it cannot be forgotten, but it does not fail: deciding it is the owner's call, and a red gate
# that nobody can clear teaches people to ignore the gate.
OPEN = {
 ("01_DALOS.pact", "A_DeploySmartAccount"):    "deploy-family",
 ("01_DALOS.pact", "A_DeployStandardAccount"): "deploy-family",
 ("01_DALOS.pact", "C_DeploySmartAccount"):    "deploy-family",
 ("01_DALOS.pact", "C_DeployStandardAccount"): "deploy-family",
}
OPEN_WHY = {
 "deploy-family":
   "THE BASE CASE OF THE ATTRIBUTION RULE. In all four the `executor` is the account BEING\n"
   "   CREATED, not an account that acted -- so its ownership cannot be proven: it does not exist\n"
   "   yet, and its guard arrives as an argument. Under the canon the new account is the EXECUTEE.\n"
   "   That leaves the real actor unnamed on the one path that creates accounts:\n"
   "     A_Deploy*  the ADMIN deploys for someone else (gasless). The admin is authenticated by\n"
   "                SECURE-ADMIN and recorded NOWHERE -- the ledger says an account appeared, not\n"
   "                who made it appear. Canon shape would be (executor executee guard stoa ...),\n"
   "                the self/foreign pair applied to account creation.\n"
   "     C_Deploy*  the user deploys for THEMSELVES (paid). executor == executee, the self case,\n"
   "                and the supplied guard is the only thing that could prove it.\n"
   "   Genesis is the reason this cannot simply be legislated: the FIRST account has no prior\n"
   "   account to name, so it comes through the governance door (REPL/Stage_01/[2.1]_Dalos.repl\n"
   "   calls DALOS.A_Deploy*Account directly under module admin). Changing the signature means\n"
   "   deciding what genesis does instead. OWNER DECISION REQUIRED.",
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


def classify(name, body, caps):
    """-> (verdict, detail). verdict in DIRECT / cap:… / FORWARDED / INDIRECT / UNPROVEN."""
    if re.search(OWN.pattern + r'\s+executor', body):
        return "DIRECT", ""
    for cm in re.finditer(r'with-capability\s*\(([A-Za-z0-9|_\->]+)([^\n]*)', body):
        cname, cargs = cm.group(1), cm.group(2)
        if not re.search(EXEC, cargs): continue
        ct = caps.get(cname, "")
        if OWN.search(ct):
            return "DIRECT", f"via {cname}"
        for sub in re.findall(r'compose-capability\s*\(([A-Za-z0-9|_\->]+)', ct):
            if OWN.search(caps.get(sub, "")):
                return "DIRECT", f"via {cname} -> {sub}"
    if re.search(r'ref-[A-Za-z0-9|_\-]+::[A-Za-z0-9|_]+\s+[\w\-|]+\s+executor', body):
        return "FORWARDED", ""
    bare = name.split("|")[-1]
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
    bad, open_q, ok = [], [], 0
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
                (open_q if (base, n) in OPEN else bad).append((base, n, d))
            else:
                ok += 1

    scope = f"--module {only}" if only else ("swept modules" if swept_only else "whole tree")
    print(f"executor enforcement -- {scope}:  {ok} proven, {len(bad)} UNPROVEN, "
          f"{len(open_q)} OPEN")
    if open_q:
        seen = set()
        for base, n, _ in open_q:
            print(f"   OPEN  {base:<22} {n}")
            seen.add(OPEN[(base, n)])
        for k in sorted(seen):
            print(f"\n   {OPEN_WHY[k]}\n")
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
