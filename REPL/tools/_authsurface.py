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
ENTRY = re.compile(r'^(?:[A-Za-z0-9_-]+\|)?(?:AA|A|CC|C)_[A-Za-z0-9|_-]+$')


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


OWN    = re.compile(r'CAP_EnforceAccountOwnership\s+([A-Za-z0-9|_-]+)')
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
