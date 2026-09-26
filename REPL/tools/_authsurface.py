#!/usr/bin/env python3
"""The AUTHORISATION SURFACE of every sovereign client entrypoint, captured transitively.

WHAT IT ANSWERS. For each `C_`/`A_` entrypoint: which ownership enforces does calling it actually
reach, anywhere in its call tree? That is the question a reader of a signature cannot answer today,
and the question the patron/executor refactor is about to change 89 times over.

WHY IT EXISTS BEFORE THE REFACTOR AND NOT AFTER. The refactor's failure mode is a diff that reads
as an improvement: add an `executor` parameter, enforce its ownership, and drop the derived check
it replaced. Tests stay green, because a caller passing the right account is the normal case. The
hole only opens for the caller who passes a different one. Across 72 functions that is 72 chances,
and nothing else in this repo would notice. So: baseline the surface FIRST, then require every
later run to be a SUPERSET. Adding an enforce is fine. Losing one is the gate going red.

WHY TRANSITIVE, EMPHATICALLY. The first scan written for the refactor plan stopped at each
entrypoint's own defcap and concluded "2 of 357 transfer paths require receiver consent". The true
answer is ALL of them: the check lives in the shared TFT transfer engine one level further down
(09_TFT.pact:414). A non-transitive analyser would have blessed the removal of every check it could
not see -- which is precisely the class of mistake it is supposed to prevent.

WHY COMMENTS ARE STRIPPED. An earlier pass reported `C_IssueDigitalCollection` as enforcing
ownership on an account called `below`. There is no such account: the regex had matched the words
"real CAP_EnforceAccountOwnership below" inside a @doc. Prose about a check is not a check.

  python3 REPL/tools/_authsurface.py           write the artefact
  python3 REPL/tools/_authsurface.py --check   exit 1 if the tree lost an enforce vs the artefact
"""
import os, re, sys, json, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT  = os.path.join(ROOT, "OuronetInformational", "ARCHITECTURE", "AUTH-SURFACE.md")
SRC  = [os.path.join(ROOT, "1_SOVEREIGN"), os.path.join(ROOT, "2_CITIZEN")]
# CORRECTED 2026-09-26. The previous pattern was
#   ^(?:[A-Za-z0-9_-]+\|)?(?:AA|A|CC|C)_[A-Za-z0-9|_-]+$
# and it silently excluded SEVENTEEN entrypoints through two independent gaps:
#
#   1. `(?:AA|A|CC|C)_` requires `_` immediately after the band letters, so it matched `C_` and
#      `CC_` but NOT `Cp_`/`CCp_`/`Ap_`/`AAp_` -- every MULTI-TRANSACTION RECIPE. Twelve of them:
#      the three `Cp_WipeSlice`s, six `AQP-POOL|CCp_Batch*`, three `AQP-FVT|CCp_*Chunk`/`UnstaleAll`.
#   2. `(?:[A-Za-z0-9_-]+\|)?` allows at most ONE `name|` segment, so two-segment names were
#      missed: `ATS|HOT-RBT|C_*` (three) and `MTX-AQP|2|CC_*` (two).
#
# This is the same blind-spot class CLAUDE.md records for `_bandplan.py` -- a filter that reported
# 89 entrypoints where there were 482 -- and it lands in the worst possible place. This tool's
# promise is "no entrypoint ever stops enforcing something"; an entrypoint it cannot SEE is one it
# cannot report as weakened, so for these seventeen the promise was vacuous. Recipes are the worst
# seventeen to lose, because a recipe runs N times per logical operation.
ENTRY = re.compile(r'^(?:[A-Za-z0-9_-]+\|)*(?:AA|A|CC|C)p?_[A-Za-z0-9|_-]+$')


def strip_code(s):
    """Remove `;;` comments and string literals, so only executable text is analysed."""
    out, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c == '"':
            i += 1
            while i < n:
                if s[i] == "\\":
                    i += 2; continue
                if s[i] == '"':
                    i += 1; break
                i += 1
            out.append(' ')
            continue
        if c == ";":
            j = s.find("\n", i)
            i = n if j < 0 else j
            continue
        out.append(c); i += 1
    return "".join(out)


def balanced(s, i):
    d = 0; j = i; instr = False
    while j < len(s):
        c = s[j]
        if instr:
            if c == "\\": j += 2; continue
            if c == '"': instr = False
        elif c == '"': instr = True
        elif c == ";":
            k = s.find("\n", j); j = len(s) if k < 0 else k; continue
        elif c == "(": d += 1
        elif c == ")":
            d -= 1
            if d == 0: return j + 1
        j += 1
    return len(s)


def collect():
    """(file,name) -> code-only body, and module-name -> file.

    INDEXED BY FILE, NOT JUST NAME, and that is the difference between a usable tool and a useless
    one. The first version keyed on the bare name and kept every definition of it. `C_Transfer`
    alone is defined in six modules, so following a call by name pulled in all six and the union of
    everything they reach: 342 of 841 entrypoints came out with an IDENTICAL 7-target set. An
    analyser that says everything touches everything cannot tell you when something stops.
    """
    defs, modfile = {}, {}
    for root in SRC:
        for d, _, fs in os.walk(root):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if not f.endswith(".pact"):
                    continue
                fp = os.path.join(d, f)
                rel = os.path.relpath(fp, ROOT)
                s = open(fp, encoding="utf8", errors="replace").read()
                mi = s.find("\n(module ")
                body = s[mi:] if mi > 0 else s
                mm = re.match(r'\n\(module\s+(\S+)', body)
                if mm:
                    modfile[mm.group(1)] = rel
                for m in re.finditer(r'^[ \t]*\((?:defun|defcap)\s+(\S+?)[\s(:]', body, re.M):
                    a = m.start(); b = balanced(body, a)
                    defs[(rel, m.group(1))] = strip_code(body[a:b])
    return defs, modfile


# EVERY ownership idiom, not just DALOS's. A first version matched only
# CAP_EnforceAccountOwnership and therefore covered UNDER HALF the ownership enforcement in the
# tree: CAP_Owner alone appears 150 times against its 108, and six module-local variants carry the
# rest. The baseline's whole promise is "no entrypoint stopped enforcing something", and a promise
# that cannot see CAP_Owner is not the promise it claims to be. Found while classifying Band 1:
# DPTF authorises through UEV_ParentOwnership -> CAP_Owner, which the tool had reported as no
# ownership check at all.
OWN    = re.compile(r'(?:CAP_EnforceAccountOwnership|CAP_Owner|CAP_StakeOwner|CAP_PoolOwner|'
                    r'CAP_VctVacatePoolOwner|CAP_TF\|Owner|CAP_AqpAssetOwner|CAP_Creator)'
                    r'\s+\(?([A-Za-z0-9|_.:-]+)')
# The STRUCTURED half, added 2026-09-26. `OWN` above captures one identifier after an optional
# `(`, which is right for the markdown baseline but throws away the thing a CONSUMER needs: for
# `(UR_OwnerKonto swpair)` it yields `UR_OwnerKonto` -- the READER -- and discards `swpair`, the
# subject. That is why the registry's `ownership` field shipped unresolved: its input mixed
# account parameters with the readers used to derive them, and no filtering downstream can
# separate the two.
#
# OWN_AT finds the same sites; `own_expr_at` then reads the WHOLE argument, balanced, so a
# resolver can say "the account is the `executor` parameter" or "the account is whatever
# `UR_OwnerKonto` returns for `swpair`" -- which are different instructions to a client.
#
# The markdown artefact is NOT changed by any of this. It is gate-enforced as a SUPERSET, so
# churning it would either mask a real regression or manufacture a fake one.
# ONLY `CAP_EnforceAccountOwnership`. The markdown's `OWN` lists all eight CAP_ variants, which
# is right for a coverage baseline, but WRONG here -- only this one takes an ACCOUNT. Every other
# variant takes an ENTITY ID and looks the owner up itself:
#     CAP_Owner (swpair)   -> CAP_EnforceAccountOwnership (UR_OwnerKonto swpair)
#     CAP_StakeOwner (owner-id) -> CAP_EnforceAccountOwnership owner-id      (already an account)
# Counting the wrappers as well DOUBLE-COUNTS, and reports the entity id as though it were the
# account -- which is precisely the `ownership: ["patron","swpair"]` defect: nobody holds the key
# to a pool id. Verified that every wrapper bottoms out here, directly or through another
# wrapper, so the transitive walk loses nothing by ignoring them.
OWN_AT = re.compile(r'CAP_EnforceAccountOwnership\s*')

BARE   = re.compile(r'\(([A-Za-z][A-Za-z0-9|_>-]*)[\s)]')
VIAREF = re.compile(r'\(ref-([A-Za-z0-9|_-]+)::([A-Za-z0-9|_>-]+)')
VIAMOD = re.compile(r'\(([A-Z][A-Za-z0-9|_-]*)\.([A-Za-z0-9|_>-]+)')
MODREF = re.compile(r'\(ref-([A-Za-z0-9|_-]+):module\{[^}]*\}\s+([A-Za-z0-9|_-]+)\)')


def callees(rel, body, modfile):
    """Resolved (file,name) targets. A bare name resolves in the SAME file; `ref-X::n` resolves
    through the let-bound modref to that module's file; `Mod.n` resolves directly. Anything that
    does not resolve is dropped rather than guessed -- a wrong edge is worse than a missing one
    here, because it inflates every caller's surface and buries real changes in noise."""
    out = set()
    local = dict(MODREF.findall(body))
    for n in BARE.findall(body):
        out.add((rel, n))
    for alias, n in VIAREF.findall(body):
        f = modfile.get(local.get(alias, ""))
        if f: out.add((f, n))
    for mod, n in VIAMOD.findall(body):
        f = modfile.get(mod)
        if f: out.add((f, n))
    return out


def own_expr_at(body, i):
    """The full, balanced account expression an ownership enforce was given, from offset i."""
    while i < len(body) and body[i] in " \n\t":
        i += 1
    if i < len(body) and body[i] == "(":
        # `balanced` returns an EXCLUSIVE index. Adding 1 to it swallowed the following
        # character, which turned `(UR_OwnerKonto swpair)` into a subject of `swpair)`.
        return " ".join(body[i:balanced(body, i)].split())
    j = i
    while j < len(body) and (body[j].isalnum() or body[j] in "-_|.:"):
        j += 1
    return body[i:j]


def conditional_at(body, idx):
    """The nearest enclosing conditional form at `idx`, or None.

    An ownership enforce inside an `if` / `cond` / `enforce-one` / `or` branch is CONDITIONAL --
    it binds on one path and not the other. `IGNIS.UEV_Patron` is the case that matters most:

        (if (UR_AccountType patron)
            (do (enforce (= patron DALOS|SC_NAME) ...)
                (CAP_EnforceAccountOwnership DALOS|SC_NAME))   ;; gas station signs
            (CAP_EnforceAccountOwnership patron))              ;; the user signs

    Reported flat, that reads as "the caller must hold the patron's key", which is FALSE on the
    gas-sponsored path -- the common one. CLAUDE.md already warns about this shape for the sweep
    ("if it sits in an `if`, `and`, `or` or `cond` branch, the authorisation is conditional");
    the same caution applies to REPORTING it.
    """
    depth, stack = 0, []
    j, instr = 0, False
    while j < idx and j < len(body):
        c = body[j]
        if instr:
            if c == "\\": j += 2; continue
            if c == '"': instr = False
        elif c == '"': instr = True
        elif c == "(":
            depth += 1
            m = re.match(r'\((if|cond|enforce-one|or|and)[\s(]', body[j:j + 14])
            stack.append((depth, m.group(1) if m else None))
        elif c == ")":
            while stack and stack[-1][0] >= depth:
                stack.pop()
            depth -= 1
        j += 1
    for _d, head in reversed(stack):
        if head:
            return head
    return None


def classify_own(expr):
    """{kind, subject, reader} for one account expression.

    Two families, and a consumer must tell them apart: a bare name IS the account, so the client
    readies that account's key; a call means the account must be LOOKED UP first, and the thing
    named in the expression is an entity id, not an account. Getting this backwards is what
    produced `ownership: ["patron", "swpair"]` -- `swpair` is a pool id and nobody holds its key.
    """
    if not expr.startswith("("):
        return {"kind": "parameter", "subject": expr, "reader": None}
    inner = expr[1:-1].strip().split()
    if not inner:
        return {"kind": "unknown", "subject": None, "reader": None}
    reader, args = inner[0], inner[1:]
    if reader.startswith("ref-") and "::" in reader:
        reader = reader.split("::", 1)[1]
    return {"kind": "reader", "reader": reader,
            "subject": args[0] if args else None, "readerArgs": args}


def surface_structured(key, defs, modfile, seen=None, depth=0):
    """Like surface(), but records the FULL expression and the DEPTH it was found at.

    Depth matters and is the reason this cannot be finished in one step. An expression found at
    depth 0 is written in the ENTRYPOINT's own parameters, so it resolves directly. At depth N it
    is written in that callee's parameters, and mapping it back needs the arguments threaded
    through each call -- which this does not do. Depth is therefore REPORTED, so a consumer can
    trust the depth-0 answers and see that the rest are unthreaded rather than assume they are.
    """
    if seen is None: seen = set()
    if key in seen or depth > 14 or key not in defs:
        return []
    seen.add(key)
    body, out = defs[key], []
    for m in OWN_AT.finditer(body):
        # SKIP THE DEFINITION SITE. `(defcap CAP_PoolOwner (swpair:string) ...)` matches the same
        # name, and reading its PARAMETER LIST as an account expression invents a reader called
        # `swpair:string`. A definition is not an enforcement.
        head = body[max(0, m.start() - 12):m.start()]
        if re.search(r'\((?:defcap|defun)\s+$', head):
            continue
        e = own_expr_at(body, m.end())
        if e:
            out.append(dict(classify_own(e), expr=e, depth=depth,
                            conditional=conditional_at(body, m.start()),
                            where=f"{key[0]}::{key[1]}"))
    for c in callees(key[0], body, modfile):
        if c != key and c in defs:
            out += surface_structured(c, defs, modfile, seen, depth + 1)
    return out


def surface(key, defs, modfile, seen=None, depth=0):
    """Every ownership enforce reachable from (file,name), transitively."""
    if seen is None: seen = set()
    if key in seen or depth > 14 or key not in defs:
        return set()
    seen.add(key)
    body = defs[key]
    found = {(key[0], key[1], a) for a in OWN.findall(body)}
    for c in callees(key[0], body, modfile):
        if c != key and c in defs:
            found |= surface(c, defs, modfile, seen, depth + 1)
    return found


def build():
    defs, modfile = collect()
    rows = []
    for (rel, name) in sorted(defs):
        if not ENTRY.match(name):
            continue
        s = surface((rel, name), defs, modfile, set(), 0)
        rows.append((name, rel, sorted({a for _, _, a in s}), sorted(s)))
    return rows


def render(rows):
    L = ["# Authorisation surface — every sovereign client entrypoint",
         "",
         "> **GENERATED** by `REPL/tools/_authsurface.py`. Do not edit.",
         "> For each `C_`/`A_`, the accounts whose ownership is enforced ANYWHERE in its call tree.",
         "> The gate requires this set to only ever GROW: an entrypoint that stops enforcing"
         " something it used to enforce is an authorisation regression, and nothing else here"
         " would catch it.",
         ""]
    withc = [r for r in rows if r[2]]
    L += [f"| metric | value |", "|---|---|",
          f"| entrypoints scanned | {len(rows)} |",
          f"| reaching at least one ownership enforce | {len(withc)} |",
          f"| reaching NONE | {len(rows) - len(withc)} |", ""]
    # KEYED BY module+name, NOT name alone. A first version keyed on the bare name and 1,104
    # entrypoints collapsed into 841 rows -- `C_Transfer` exists in six modules and only the last
    # survived, so a regression in any of the other five would have been invisible to --check.
    L += ["## Per entrypoint", "", "| module | entrypoint | enforced ownership on |", "|---|---|---|"]
    for name, f, args, _ in rows:
        mod = os.path.basename(f).replace(".pact", "")
        L.append(f"| `{mod}` | `{name}` | {', '.join('`%s`' % a for a in args) if args else '—'} |")
    L.append("")
    return "\n".join(L) + "\n"


def signature(rows):
    return {os.path.basename(f).replace(".pact", "") + "::" + name: sorted(args)
            for name, f, args, _ in rows}


def main():
    rows = build()
    text = render(rows)
    if "--check" in sys.argv:
        if not os.path.exists(OUT):
            print("auth surface: no baseline -- run without --check to create it"); return 1
        old = {}
        for m in re.finditer(r'^\| `([^`]+)` \| `([^`]+)` \| (.*) \|$',
                             open(OUT, encoding="utf8").read(), re.M):
            old[m.group(1) + "::" + m.group(2)] = sorted(re.findall(r'`([^`]+)`', m.group(3)))
        new = signature(rows)
        lost = []
        for name, args in old.items():
            if name not in new:
                lost.append(f"GONE     {name}  (was enforcing {args})")
            else:
                missing = set(args) - set(new[name])
                if missing:
                    lost.append(f"WEAKENED {name}  no longer enforces {sorted(missing)}")
        if lost:
            print("\nAUTHORISATION REGRESSION — an entrypoint lost an ownership enforce:")
            for l in lost: print("   " + l)
            print("\nIf this is intended, regenerate: python3 REPL/tools/_authsurface.py")
            return 1
        gained = sum(1 for n, a in new.items() if set(a) - set(old.get(n, [])))
        print(f"auth surface: clean -- {len(new)} entrypoints, none weakened"
              + (f", {gained} strengthened" if gained else ""))
        return 0
    open(OUT, "w", encoding="utf8").write(text)
    print(f"wrote {os.path.relpath(OUT, ROOT)}  ({len(rows)} entrypoints, "
          f"{sum(1 for r in rows if r[2])} enforcing ownership)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
