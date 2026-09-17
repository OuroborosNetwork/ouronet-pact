#!/usr/bin/env python3
"""_modref.py -- modref member calls vs the interface they are typed to.

WHAT THIS IS FOR. Cross-module calls in this repo go through module references
(`(ref-X::member ...)` where `ref-X:module{SomeInterfaceV2}`). Pact 5 resolves those members
DYNAMICALLY, so a call to a member the interface never declares loads and runs perfectly. Nothing
in the gate could see it.

WHY IT IS NOT A DEFECT DETECTOR FOR CLASS A. Written 2026-09-17 after a reviewer found ONE instance
-- `FVT|C>ISSUE-FVT` calling `ref-RPS::URC_FvtExists`, undeclared on `AcquisitionRewardPerShareV1`
-- and filed it as a coupling defect. Measuring the population first: there are **165 live
instances across 20+ members**, `P|Info` alone accounting for 57. That is the repo's CONVENTION, and
CLAUDE.md says so in as many words -- interfaces carry "nearly the full public API", not all of it.
Fixing the one instance would have made the tree LESS consistent, and reported a practice as a bug.
Same lesson as the DPDC-S set-class sweep, where "1 of 8 call sites uses the domain guard" showed
the suspected outlier was the norm.

WHAT IS WORTH GATING IS CLASS B: a modref call to a member that does not exist in the implementing
module AT ALL. That is unambiguously dead -- it would raise at runtime if the branch were ever
taken. Measured at introduction: 13, every one of them inside the LEGACY `00_DPMF.pact`, which
CLAUDE.md marks KEEP AS IS. **Live code: zero.** That zero is the invariant this tool protects.

The residual risk in class A is real but hypothetical HERE: a SECOND implementer of an interface
would satisfy the type and fail at runtime on an undeclared member. Today every interface in the
tree has exactly one implementer, so it cannot bite. If that ever stops being true, class A becomes
a defect class and this tool already counts it.

usage:
  python3 REPL/tools/_modref.py            full report, both classes
  python3 REPL/tools/_modref.py --check    exit 1 if any LIVE class-B call exists
"""
import re, sys, glob, os, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEGACY = "00_DPMF.pact"          # CLAUDE.md: legacy MetaFungible module, KEEP AS IS


def sources():
    return [p for d in ("1_SOVEREIGN", "2_CITIZEN")
            for p in glob.glob(os.path.join(ROOT, d, "**", "*.pact"), recursive=True)
            if "/Audit/" not in p and "/archive/" not in p]


def _top_level_block(text, start):
    """From `start` to the next line that is exactly `)` -- how these files close a top form."""
    nxt = text.find("\n)", start)
    return text[start:nxt if nxt != -1 else len(text)]


def scan():
    decl = collections.defaultdict(set)     # interface -> declared members
    implementer = {}                        # interface -> module implementing it
    defs = collections.defaultdict(set)     # module    -> defined members
    for p in sources():
        t = open(p, errors="ignore").read()
        for m in re.finditer(r'^\(interface\s+([A-Za-z0-9_]+)', t, re.M):
            for d in re.finditer(r'\(def(?:un|cap|pact|const)\s+([A-Za-z0-9_|>\-]+)',
                                 _top_level_block(t, m.end())):
                decl[m.group(1)].add(d.group(1))
        for m in re.finditer(r'^\(module\s+([A-Za-z0-9_\-]+)[^\n]*', t, re.M):
            body = _top_level_block(t, m.end())
            for im in re.finditer(r'\(implements\s+([A-Za-z0-9_]+)', body):
                implementer[im.group(1)] = m.group(1)
            for d in re.finditer(r'\(def(?:un|cap|pact|const)\s+([A-Za-z0-9_|>\-]+)', body):
                defs[m.group(1)].add(d.group(1))

    undeclared, dead = [], []
    for p in sources():
        rel, t = os.path.relpath(p, ROOT), open(p, errors="ignore").read()
        binds = {m.group(1): m.group(2).split(".")[0]
                 for m in re.finditer(r'\((ref-[A-Za-z0-9_|\-]+):module\{([A-Za-z0-9_.]+)\}', t)}
        for m in re.finditer(r'\((ref-[A-Za-z0-9_|\-]+)::([A-Za-z0-9_|>\-]+)', t):
            r, mem = m.group(1), m.group(2)
            iface = binds.get(r)
            if not iface or iface not in decl or mem in decl[iface]:
                continue
            owner = implementer.get(iface)
            row = (rel, t[:m.start()].count("\n") + 1, iface, mem, owner)
            (undeclared if owner and mem in defs.get(owner, ()) else dead).append(row)
    return sorted(set(undeclared)), sorted(set(dead)), decl


def main():
    undeclared, dead, decl = scan()
    live_dead = [r for r in dead if LEGACY not in r[0]]
    quiet = "--check" in sys.argv

    if not quiet:
        print(f"interfaces scanned: {len(decl)}")
        print(f"\nCLASS A -- implemented, but NOT declared on the interface: {len(undeclared)}")
        print("  CONVENTION, not a defect: CLAUDE.md says interfaces carry \"nearly the full public")
        print("  API\". Listed so the scale is visible, and because it becomes a real defect class")
        print("  the day any interface gains a SECOND implementer.")
        for (mem, iface), n in collections.Counter(
                (r[3], r[2]) for r in undeclared if LEGACY not in r[0]).most_common(12):
            print(f"     {n:3}x  {mem:38} not on {iface}")
        print(f"\nCLASS B -- called through a modref, defined NOWHERE in the implementer: {len(dead)}")
        for r in dead:
            tag = "  (legacy, expected)" if LEGACY in r[0] else "  <-- LIVE"
            print(f"     {r[0]}:{r[1]}  {r[3]} on {r[2]}{tag}")

    if live_dead:
        print(f"\n{len(live_dead)} LIVE class-B call(s) -- a modref member that does not exist.")
        print("Pact resolves modref members dynamically, so this LOADS and only raises if the")
        print("branch is taken. Nothing else in the gate can see it.")
        for r in live_dead:
            print(f"  {r[0]}:{r[1]}  {r[3]} is not defined in {r[4]}")
        return 1
    if not quiet:
        print("\n  clean -- no LIVE call to a non-existent modref member")
    return 0


if __name__ == "__main__":
    sys.exit(main())
