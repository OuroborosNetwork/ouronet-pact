#!/usr/bin/env python3
"""EVERY PATRON SLOT THAT IS NOT THE WORD `patron` -- explained, or the tool fails.

WHY THIS EXISTS. The patron/executor sweep gives every `A_`/`C_` entrypoint a `patron` first
parameter, and callers thread their own `patron` into it. But some callers cannot:

  * a PATRONLESS function by design (ORBR::C_Sublimate / C_Compress -- there is no patron at
    the moment IGNIS is created), and
  * a caller in a module whose own sweep turn has NOT COME YET, which has no `patron` parameter
    to pass and must name the initiating account instead.

The second kind is the dangerous one. It is INVISIBLE once written: the arity is correct, so
`_callarity.py` cannot see it; the value is unused by every swept callee, so no assertion can
see it; and the diff that introduced it is long gone. It will quietly survive that module's own
turn unless something remembers it is there.

This is that something. The registry below names every site, and the tool FAILS on a site that
is not in it -- so a new unexplained patron slot cannot be added silently. It does NOT fail on
PROVISIONAL entries; those are expected, and the tool prints them grouped by the module whose
turn will clear them.

    python3 REPL/tools/_patronslots.py            report + fail on unregistered sites
    python3 REPL/tools/_patronslots.py --todo     just the per-module re-point list
"""
import os, re, sys, glob, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Entrypoints already swept: their first parameter IS `patron`. Grown as the sweep advances --
# a module's turn adds its entrypoints here.
SWEPT = {
    "TFT":  ["C_Transfer", "C_MultiTransfer", "C_MultiBulkTransfer", "C_Transmute",
             "C_ClearDispo"],
    "DPTF": ["C_Mint", "C_Burn", "C_WipeSlim", "C_Wipe", "C_ToggleFreezeAccount", "C_Issue",
             "C_Control", "C_RotateOwnership"],
    "DPOF": ["C_Transfer", "C_Mint", "C_Burn", "C_WipeClean", "C_ToggleFreezeAccount",
             "C_Control", "C_RotateOwnership"],
    "ATS":  ["C_Fuel"],
}

# (file basename, enclosing function) -> (expression in the patron slot, why, clears-at)
# `clears-at` is None for a PERMANENT entry and a module name for a PROVISIONAL one.
REGISTRY = {
 ("13_OUROBOROS.pact", "C_Compress"):
   ("client", "PATRONLESS by design -- IGNIS is being created, there is no patron yet. The "
              "initiating client occupies the slot, which is the convention this file already "
              "used for DPTF::C_Burn / C_Mint before the sweep.", None),
 ("13_OUROBOROS.pact", "C_Sublimate"):    ("client", "patronless, as C_Compress", None),
 ("13_OUROBOROS.pact", "C_SublimateV2"):  ("client", "patronless, as C_Compress", None),
 ("13_OUROBOROS.pact", "C_WithdrawFees"): ("target", "provisional", "13_OUROBOROS"),
 # 10_ATSU's five entries were CLEARED at its turn (2026-09-21): C_Cull, C_Fuel, C_Syphon,
 # C_WithdrawRoyalties and XI_RemoveSecondary all gained a real `patron` and their TFT call
 # sites were re-pointed to it. Removed rather than commented, which is the point of the
 # `clears-at` column -- it names the turn that retires the entry.
 ("18_SWPLC.pact", "C_Fuel"):             ("account", "provisional", "18_SWPLC"),
 ("03_AQP.pact", "XE_TrueFungibleTransfer"): ("owner-id", "provisional", "03_AQP"),
 ("06_VCT.pact", "XI_VacateTrueFungibleFromLegs"):
   ("AQP|SC_NAME", "provisional -- no user account is in scope at all here; the vault is the "
                   "only account the function knows.", "06_VCT"),
 ("06_VCT.pact", "XI_DrainTrueFungibleFromLegs"):
   ("AQP|SC_NAME", "provisional, as XI_VacateTrueFungibleFromLegs", "06_VCT"),
}

CALL = re.compile(r'\(ref-([A-Za-z0-9|_\-]+)::(C_[A-Za-z]+)\s+([A-Za-z0-9|_\-\.\[]+)')
DEF  = re.compile(r'^\s*\((?:defun|defpact)\s+([A-Za-z0-9|_\-\.]+)', re.M)


def mask(src):
    out = list(src); i = 0; n = len(src)
    while i < n:
        c = src[i]
        if c == '"':
            j = i + 1
            while j < n:
                if src[j] == '\\': j += 2; continue
                if src[j] == '"': break
                j += 1
            for k in range(i, min(j + 1, n)): out[k] = ' '
            i = j + 1; continue
        if c == ';':
            j = src.find('\n', i)
            if j < 0: j = n
            for k in range(i, j): out[k] = ' '
            i = j; continue
        i += 1
    return "".join(out)


def alias_target(src, alias):
    m = re.search(r'\(\s*' + re.escape(alias) + r'\s*:module\{[^}]*\}\s+([A-Za-z0-9|_\-]+)\s*\)', src)
    return m.group(1) if m else None


def main():
    hits, unregistered = [], []
    files = (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True))
    for f in sorted(files):
        src = open(f).read(); msk = mask(src); base = os.path.basename(f)
        defs = [(m.start(), m.group(1)) for m in DEF.finditer(msk)]
        for m in CALL.finditer(msk):
            alias, fn, first = m.groups()
            mod = alias_target(src, alias) or alias.replace("ref-", "")
            if fn not in SWEPT.get(mod, []):
                continue
            if first == "patron":
                continue
            encl = next((n for p, n in reversed(defs) if p < m.start()), "?")
            key = (base, encl)
            if key in REGISTRY:
                expr, why, clears = REGISTRY[key]
                if expr != first:
                    unregistered.append((base, encl, fn, first,
                                         f"registry says `{expr}`, source says `{first}`"))
                else:
                    hits.append((base, encl, fn, first, why, clears))
            else:
                unregistered.append((base, encl, fn, first, "NOT IN REGISTRY"))

    todo = collections.defaultdict(list)
    for base, encl, fn, first, why, clears in hits:
        if clears:
            todo[clears].append((base, encl, fn, first))

    if "--todo" not in sys.argv:
        perm = [h for h in hits if not h[5]]
        print(f"patron slots not named `patron`: {len(hits)} registered "
              f"({len(perm)} permanent, {len(hits) - len(perm)} provisional)")
        for base, encl, fn, first, why, clears in perm:
            print(f"  PERMANENT  {base:<22} {encl:<32} -> {fn:<22} patron={first}")

    print(f"\nPROVISIONAL -- re-point these when the module's own turn lands:")
    for mod in sorted(todo):
        print(f"  {mod}")
        for base, encl, fn, first in sorted(todo[mod]):
            print(f"      {encl:<34} -> {fn:<22} patron={first}")

    if unregistered:
        print(f"\n!! {len(unregistered)} UNREGISTERED patron slot(s):")
        for base, encl, fn, first, why in unregistered:
            print(f"     {base:<22} {encl:<32} -> {fn:<20} patron={first}   [{why}]")
        print("\n   Every patron slot that is not the word `patron` must be explained in")
        print("   REGISTRY. Add an entry (with `clears-at` set if it is provisional) or fix the")
        print("   call site.")
        return 1
    print("\nevery non-`patron` patron slot is registered.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
