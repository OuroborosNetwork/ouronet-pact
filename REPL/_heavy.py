#!/usr/bin/env python3
"""HEAVY-PREFIX CHECKER (G4 / plan step 2.5.3) — is the DOUBLED prefix telling the truth?

    cd REPL && python3 _heavy.py [--show N]

CLAUDE.md: "Doubled `AA_` = **heavy**: a heavy scan (`URH_*`/`URHC_*`/`URD_*`) is reached
**somewhere in the whole execution tree, at any depth** (transitive)." Same for `CC_`.

That is a claim about a CALL GRAPH, not about one function, so it needs whole-program reachability
rather than the per-member scan `_conformance.py` does. A mis-marked op is a GAS-MODEL LIE in
either direction:
  * a `CC_`/`AA_` with no heavy read overcharges and over-warns;
  * a single `C_`/`A_` that DOES reach one can blow the block gas limit in production on an input
    size nobody tested.

WHAT THIS CAN AND CANNOT SEE. Edges come from three syntactic forms: a bare `(NAME …)` resolving
inside the same module, a `(ref-X::NAME …)` where `ref-X` was bound by
`(ref-X:module{Iface} MODULE)` in that same file, and a qualified `(MODULE.NAME …)`. Modrefs
bound to an INTERFACE and supplied at runtime are invisible here — so a "no heavy read" result is
a statement about the static graph, not a proof. Reported accordingly.
"""
import argparse, collections, glob, os, re, sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))
ROOT = ".."

def strip(src):
    out, i, n, in_str, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            out.append('\n' if c == '\n' else ' ')
        elif c == '"': in_str = True; out.append(' ')
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
            continue
        else: out.append(c)
        i += 1
    return ''.join(out)

MEMBER  = re.compile(r'^\s{1,8}\((defun|defcap|defpact)\s+([^\s()]+)')
MODULE  = re.compile(r'^\(module\s+(\S+)')
IFACE   = re.compile(r'^\(interface\s')
REFBIND = re.compile(r'\((ref-[^\s:()]+)\s*:\s*module\{[^}]+\}\s+([^\s()]+)\)')
CALL_R  = re.compile(r'\((ref-[^\s:()]+)::([^\s()]+)')
CALL_Q  = re.compile(r'\(([A-Za-z][A-Za-z0-9|_-]*)\.([A-Za-z][^\s()]*)')
CALL_B  = re.compile(r'\(([A-Za-z][A-Za-z0-9|_-]*)[\s)]')

HEAVY = re.compile(r'^(URH_|URHC_|URD_)')
# One table scan measured at ~40,000 gas flat (STAGEZ-17); Kadena's per-tx limit is
# 150,000. Three scans fit, four do not.
SCAN_BUDGET = 4
def local(n): return n.split('|')[-1].split(':')[0]

def bare(n):
    """`CC_Collect:object{IgnisCollectorV2.OutputCumulator}` -> `CC_Collect`.

    Member names carry their RETURN TYPE in the source. Keying the graph on the raw name made
    every bare call to a typed member unresolvable, which silently produced 49 "doubled prefix
    with no heavy read" hits -- an artefact, not a finding. Normalise on both sides."""
    return n.split(':')[0]

def parse(path):
    """-> (module_name, {member: [body lines]}, {ref-alias: module})"""
    lines = strip(open(path, encoding='utf8', errors='ignore').read()).splitlines()
    mod, mems, cur, inmod = None, {}, None, False
    aliases = {}
    for ln in lines:
        m = MODULE.match(ln)
        if m: mod, inmod, cur = m.group(1), True, None
        elif IFACE.match(ln): inmod, cur = False, None
        if not inmod: continue
        for a in REFBIND.finditer(ln): aliases[a.group(1)] = a.group(2)
        mm = MEMBER.match(ln)
        if mm:
            cur = bare(mm.group(2)); mems.setdefault(cur, [])
        if cur: mems[cur].append(ln)
    return mod, mems, aliases

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--show", type=int, default=8)
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if a single-prefixed C_/A_ reaches a heavy read (gate mode)")
    a = ap.parse_args()
    files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                               + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
             if "/Audit/" not in f]

    own, where, alias = {}, {}, {}
    bodies = {}
    for f in files:
        mod, mems, al = parse(f)
        if not mod: continue
        own.setdefault(mod, set()).update(mems)
        alias[mod] = al
        for k, v in mems.items():
            bodies[(mod, k)] = v; where[(mod, k)] = f

    # --- edges -----------------------------------------------------------------------------
    graph = collections.defaultdict(set)
    for (mod, name), body in bodies.items():
        al = alias.get(mod, {})
        for ln in body:
            for m in CALL_R.finditer(ln):
                tgt = al.get(m.group(1))
                if tgt: graph[(mod, name)].add((tgt, bare(m.group(2))))
            for m in CALL_Q.finditer(ln):
                if m.group(1) in own: graph[(mod, name)].add((m.group(1), bare(m.group(2))))
            for m in CALL_B.finditer(ln):
                c = m.group(1)
                if c in own.get(mod, ()) and c != name: graph[(mod, name)].add((mod, c))

    def reaches_heavy(start, limit=40000):
        seen, stack, steps = set(), [start], 0
        while stack and steps < limit:
            n = stack.pop(); steps += 1
            if n in seen: continue
            seen.add(n)
            if HEAVY.match(local(n[1])) and n != start: return n
            for t in graph.get(n, ()):
                if t in bodies and t not in seen: stack.append(t)
        return None

    def all_heavy(start, limit=40000):
        """Every distinct heavy reader reachable from <start>. UPPER BOUND, not a prediction:
        branches mean one call need not execute them all, and a heavy read inside a `map`/`fold`
        executes MORE times than it appears here. Use it to rank what to read, not to cost."""
        seen, stack, steps, found = set(), [start], 0, set()
        while stack and steps < limit:
            n = stack.pop(); steps += 1
            if n in seen: continue
            seen.add(n)
            if HEAVY.match(local(n[1])) and n != start: found.add(n)
            for t in graph.get(n, ()):
                if t in bodies and t not in seen: stack.append(t)
        return found

    doubled_no_heavy, single_has_heavy, over_budget = [], [], []
    for (mod, name) in sorted(bodies):
        l = local(name)
        if not (l.startswith(("CC_", "AA_", "CCp_", "AAp_")) or
                l.startswith(("C_", "A_", "Cp_", "Ap_"))): continue
        if not bodies[(mod, name)][0].lstrip().startswith("(defun"): continue
        heavy = reaches_heavy((mod, name))
        if l.startswith(("CC_", "AA_", "CCp_", "AAp_")):
            if not heavy: doubled_no_heavy.append((mod, name, where[(mod, name)]))
        else:
            if heavy: single_has_heavy.append((mod, name, where[(mod, name)], heavy))
        if heavy:
            hs = all_heavy((mod, name))
            if len(hs) >= SCAN_BUDGET:
                over_budget.append((mod, name, where[(mod, name)], sorted(hs)))

    print(f"HEAVY-PREFIX — {len(files)} files, {len(bodies)} members, "
          f"{sum(len(v) for v in graph.values())} static call edges\n")

    print(f"[doubled-without-heavy] {len(doubled_no_heavy)}")
    print("    A `CC_`/`AA_` whose static tree reaches NO URH_/URHC_/URD_ read. Either the")
    print("    prefix overstates the cost, or the heavy read is behind a runtime-supplied modref")
    print("    this graph cannot follow — check before believing.")
    for mod, name, f in doubled_no_heavy[:a.show]:
        print(f"    {f.replace(ROOT+'/',''):56s} {mod}.{name}")
    if len(doubled_no_heavy) > a.show: print(f"    … and {len(doubled_no_heavy)-a.show} more")

    print(f"\n[scan-budget] {len(over_budget)}")
    print(f"    An entrypoint whose tree reaches {SCAN_BUDGET}+ DISTINCT heavy readers. Measured cost of one")
    print( "    table scan: ~40,000 gas, FLAT -- `keys`, `select` and `fold-db` all charge the same")
    print( "    ~40,000 base with only a trivial per-row term (40,001 at 50 rows, 40,000 at 500 for")
    print( "    `keys`), against 7 gas for a point read. Kadena's per-tx limit is 150,000, so THREE")
    print( "    scans is the practical ceiling and a fourth cannot fit. Pinned by STAGEZ-17.")
    print( "    UPPER BOUND, so a REVIEW LIST not a defect list: branches mean one call need not hit")
    print( "    them all -- and a heavy read inside a map/fold runs MORE often than it appears here.")
    print( "    MEASURED AND CLEARED 2026-09-11: both current hits are CC_FullVacate and its Talos")
    print( "    wrapper. Static reach says 10 heavy readers; the function dispatches on aqp-class so")
    print( "    one call takes ONE branch. Executed on a real class-1 pool it cost 43,187 gas -- about")
    print( "    ONE scan, well inside 150,000. Pinned as a standing regression guard by AQP-VAC-GAS in")
    print( "    modules/AQP.repl. Do not re-investigate these two; a THIRD entry here would be new.")
    for mod, name, f, hs in over_budget[:a.show]:
        print(f"    {f.replace(ROOT+'/',''):56s} {mod}.{name}")
        print(f"        reaches {len(hs)} heavy readers: {', '.join(h[1] for h in hs[:5])}"
              + (" …" if len(hs) > 5 else ""))
    if len(over_budget) > a.show: print(f"    … and {len(over_budget)-a.show} more")

    print(f"\n[single-reaches-heavy] {len(single_has_heavy)}")
    print("    A single `C_`/`A_` that DOES reach a heavy read. This is the dangerous direction:")
    print("    the name promises bounded cost and the tree does not deliver it.")
    for mod, name, f, h in single_has_heavy[:a.show]:
        print(f"    {f.replace(ROOT+'/',''):56s} {mod}.{name}")
        print(f"        reaches -> {h[0]}.{h[1]}")
    if len(single_has_heavy) > a.show: print(f"    … and {len(single_has_heavy)-a.show} more")

    # --check: the ONE class here that is a defect rather than an observation.
    # ADDED 2026-09-14. A fix-verification pass found that this tool's "0" was a HAND-MEASURED
    # figure: the gate byte-compiled this file but never ran it, so re-introducing the X-04 defect
    # (a single `C_`/`A_` whose tree reaches a heavy URH_ scan) would have left the gate GREEN.
    # A number quoted in an audit document as evidence of a repair must be one the gate re-derives.
    # Only `single-reaches-heavy` is fatal -- `over_budget` and the doubled-prefix inventory are
    # observations, and failing on those would make the check unusable and therefore ignored.
    if a.check and single_has_heavy:
        print("\nCHECK FAILED: a single-prefixed C_/A_ reaches a heavy read -- the name promises "
              "bounded cost and the call tree does not deliver it.")
        return 1
    return 0

sys.exit(main())
