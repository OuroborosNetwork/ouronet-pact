#!/usr/bin/env python3
"""Hoist every AQP-family defschema into one interface: AcquisitionSchemasV1.

WHY. The seven AQP core modules declare 74 schemas between them, 11 of which are
declared TWICE (RPS and FVT both carry them, field-for-field identical). Because a
schema lives in a module, any function returning `object{Schema}` cannot be declared
on that module's interface -- 106 such functions across the family are unreachable
through a modref today. That is also WHY the duplication exists: RPS has 10 UDC_
constructors and 0 of them on its interface, so FVT could not call them and copied
the schemas instead.

Precedent in this tree: DpdcUdcV2 (01_DPDC-UDC.pact) is exactly this -- 14 schemas in
a dedicated interface, its own file, deployed first in the family. 127 deftables across
1_SOVEREIGN already type from an interface-held schema.

WHAT IT DOES NOT DO. It does not merge tables that share a key, and it must not: row
EXISTENCE is used as a boolean signal in this codebase (URC_FvtScoreEntityLinkRowExists
and friends), so folding a sparse table into a dense one silently changes meaning.
Relocating a schema changes no stored bytes; merging a table changes the data layout.
One axis at a time.

  python3 REPL/tools/_aqpschemas.py            report only
  python3 REPL/tools/_aqpschemas.py --apply    rewrite the tree
"""
import os, re, sys, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
AQP  = os.path.join(ROOT, "1_SOVEREIGN", "STAGE_02", "2_Core", "03_AQP")
IFACE_NAME = "AcquisitionSchemasV1"
IFACE_FILE = os.path.join(AQP, "00_AQP-SCHEMAS.pact")

# Deploy order of the family; the interface groups schemas the same way.
ORDER = [("01_ANK.pact",   "ANK   — anchors, boost classes, user boost"),
         ("02_SCORE.pact", "SCORE — scores, per-asset score definitions, triplets"),
         ("03_AQP.pact",   "AQP   — pools, per-fungibility trackers, beneficiary totals"),
         ("04_RPS.pact",   "RPS   — reward engine: global/member/user/stream ledgers"),
         ("05_FVT.pact",   "FVT   — farms, vaults, treasuries"),
         ("06_VCT.pact",   "VCT   — vacate planning"),
         ("08_DSA.pact",   "DSA   — delegated staking agencies")]
TOUCH = [f for f, _ in ORDER] + ["07_MTX-AQP.pact", "09_AQP-INFO.pact"]
# Modules that own AQP schemas, for rewriting existing module-qualified references.
MODQ = ["AQP-ANK", "AQP-SCORE", "AQP-POOL", "RPS", "AQP-FVT", "AQP-VCT", "AQP-DSA"]


def balanced(s, i):
    """End index of the form starting at i, string- and comment-aware."""
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
    raise ValueError("unbalanced from %d" % i)


def extract(src):
    """[(name, text, start, end)] for every top-of-module defschema."""
    out = []
    for m in re.finditer(r'^([ \t]*)\(defschema\s+(\S+)', src, re.M):
        out.append((m.group(2), None, m.start(), balanced(src, m.start())))
    return [(n, src[a:b], a, b) for n, _, a, b in out]


def main():
    apply = "--apply" in sys.argv
    owned, first = {}, []          # name -> body ; declaration order per file
    per_file = {}
    for fn in TOUCH:
        p = os.path.join(AQP, fn)
        src = open(p, encoding="utf8").read()
        sch = extract(src)
        per_file[fn] = (p, src, sch)
        for n, body, _, _ in sch:
            norm = re.sub(r"\s+", " ", body)
            if n in owned:
                if re.sub(r"\s+", " ", owned[n]) != norm:
                    sys.exit("CONFLICT: %s differs between files -- refusing" % n)
            else:
                owned[n] = body
                first.append((fn, n))
    names = set(owned)
    print("%d declarations -> %d distinct schemas (%d duplicates collapsed)"
          % (sum(len(per_file[f][2]) for f in TOUCH), len(names),
             sum(len(per_file[f][2]) for f in TOUCH) - len(names)))

    # --- dependency check: a schema whose FIELD is object-typed must follow its target
    dep = collections.defaultdict(set)
    for n, body in owned.items():
        for t in re.findall(r'object\{([^}]+)\}', body):
            t = t.split(".")[-1]
            if t in names and t != n:
                dep[n].add(t)
    groups = {f: [n for g, n in first if g == f] for f, _ in ORDER}
    pos = {}
    for f, _ in ORDER:
        for n in groups[f]:
            pos[n] = (f, groups[f].index(n))
    forced = []
    for n, ts in dep.items():
        for t in ts:
            if pos.get(t, ("zz", 0)) > pos.get(n, ("zz", 0)):
                forced.append((n, t))
    if forced:
        print("  ordering: %d schema(s) must be preceded by a later-declared one:" % len(forced))
        for n, t in forced:
            print("     %s needs %s" % (n, t))
    # Stable topological sort WITHIN each group. Declaration order is kept except where a
    # schema's object-typed field names a sibling declared later -- Pact resolves top-down,
    # so the target has to come first or the interface will not load.
    for f, _ in ORDER:
        g, out, seen = groups[f], [], set()
        def visit(n, stack=()):
            if n in seen or n not in g: return
            if n in stack: sys.exit("CYCLE in %s: %s" % (f, " -> ".join(stack + (n,))))
            for t in sorted(dep.get(n, ())):
                visit(t, stack + (n,))
            if n not in seen:
                seen.add(n); out.append(n)
        for n in g: visit(n)
        if out != g:
            moved = [n for a, n in zip(g, out) if a != n]
            print("  reordered %s: %d position(s) changed" % (f, len(moved)))
        groups[f] = out

    if not apply:
        print("\nreport only -- pass --apply to rewrite")
        return

    # --- 1. emit the interface -------------------------------------------------------
    L = ['''\
;;<=============================================================================>
;;{0}  ACQUISITION SCHEMAS — the one place every AQP row shape is declared
;;
;; Generated by REPL/tools/_aqpschemas.py. Edit the SCHEMAS here, never a copy.
;;
;; WHY THIS FILE EXISTS
;;   The seven AQP core modules used to declare these 74 schemas between them, 11 of
;;   them twice (RPS and FVT both carried identical copies). A schema that lives in a
;;   module cannot appear in that module's interface, so every function returning one
;;   was locked out of the interface -- 106 of them across the family, unreachable
;;   through a modref. The duplication was a symptom: RPS keeps 10 UDC_ constructors
;;   and declares none of them, so FVT could not call them and copied the shapes.
;;
;;   Hoisting them here is the same shape as DpdcUdcV2 (01_DPDC-UDC.pact), which the
;;   DPDC family already deploys first for exactly this reason.
;;
;; DEPLOY ORDER: this interface loads BEFORE 01_ANK.pact and every AQP module after it.
;;
;; NOT DONE HERE, DELIBERATELY: tables that share a key are NOT merged. Row existence
;;   is used as a boolean signal in this family, so folding a sparse table into a dense
;;   one changes meaning silently. Moving a schema changes no stored bytes; merging a
;;   table changes the data layout. One axis at a time.
;;<=============================================================================>

(namespace "ouronet-ns")

(interface %s''' % IFACE_NAME]
    n_emit = 0
    for i, (fn, label) in enumerate(ORDER, start=1):
        if not groups[fn]:
            continue
        L.append("\n    ;;<=========================================================================>")
        L.append("    ;;{%d}  %s" % (i, label))
        L.append("    ;;      source: %s" % fn)
        L.append("    ;;")
        for n in groups[fn]:
            L.append(owned[n].rstrip())
            n_emit += 1
    L.append("\n)\n")
    if apply:
        open(IFACE_FILE, "w", encoding="utf8").write("\n".join(L))
    print("wrote %s  (%d schemas)" % (os.path.relpath(IFACE_FILE, ROOT), n_emit))

    # --- 2. strip + requalify every module -------------------------------------------
    rx_local = re.compile(r'\{(' + "|".join(re.escape(n) for n in sorted(names, key=len, reverse=True)) + r')\}')
    rx_modq  = re.compile(r'\{(?:' + "|".join(MODQ) + r')\.(' + "|".join(re.escape(n) for n in sorted(names, key=len, reverse=True)) + r')\}')
    for fn in TOUCH:
        p, src, sch = per_file[fn]
        for _, _, a, b in sorted(sch, key=lambda x: -x[2]):
            end = b
            while end < len(src) and src[end] == "\n":
                end += 1; break
            src = src[:a] + src[end:]
        src = rx_modq.sub(lambda m: "{%s.%s}" % (IFACE_NAME, m.group(1)), src)
        src = rx_local.sub(lambda m: "{%s.%s}" % (IFACE_NAME, m.group(1)), src)
        open(p, "w", encoding="utf8").write(src)
        print("  %-18s  -%d schemas" % (fn, len(sch)))


main()
