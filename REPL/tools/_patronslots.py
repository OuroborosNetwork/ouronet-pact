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

# WHICH ENTRYPOINTS ALREADY TAKE A `patron` -- DERIVED FROM THE SOURCE, not remembered here.
#
# This WAS a hand-maintained dict, and on 2026-09-22 it proved the failure mode CLAUDE.md already
# records three times over: a hardcoded list cannot report its own incompleteness. 06_DPDC-MNG's
# turn (2026-09-21) gave twelve entrypoints a `patron` and did not add the module to the list, so
# FOUR unregistered provisional slots in 11_EQUITY+ -- XI_ConvertPackageShares and
# XI_MakePackageShares calling C_AddQuantity, XI_BreakPackageShares and XI_ConvertPackageShares
# calling C_BurnSFT -- were invisible to the one tool whose entire job is to see them. They
# surfaced only because 07_DPDC-T's turn touched the same three functions.
#
# The fix is the same one applied to _executorenforced.SWEPT and _toolpaths: read the artefact
# that is already the single source of truth. A function "has been swept" iff its first parameter
# is literally `patron`, which is the canon (StoicSyntax-Prefixes.md 2.2) and is in the file.
# FAILS LOUD on an empty result, because an empty SWEPT makes every check below vacuous.
MODNAME = re.compile(r'^\(module\s+([A-Za-z0-9|_+\-]+)\s', re.M)
DEFUN_C = re.compile(r'^    \(defun\s+(C_[A-Za-z]+)[:\s(]', re.M)


def _swept(files):
    out = {}
    for f in files:
        src = open(f).read()
        m = MODNAME.search(src)
        if not m:
            continue
        mod, body = m.group(1), src[m.start():]
        for d in DEFUN_C.finditer(body):
            # the parameter list is the next `(` after the name, possibly after a return type
            k = body.index("(", d.end() - 1) if body[d.end() - 1] != "(" else d.end() - 1
            j = body.find("(", d.start() + 10)
            # walk forward from the defun name to the first top-level `(` that opens the params
            i = d.end() - 1
            while i < len(body) and body[i] != "(":
                i += 1
            close = body.find(")", i)
            first = body[i + 1:close].strip().split(":")[0].split()[0] if close > i else ""
            if first == "patron":
                out.setdefault(mod, []).append(d.group(1))
    if not out:
        sys.exit("_patronslots: no entrypoint in the tree takes `patron` first -- refusing to "
                 "run, because an empty SWEPT makes every check below vacuously clean.")
    return out


# (file basename, enclosing function) -> (expression in the patron slot, why, clears-at)
# `clears-at` is None for a PERMANENT entry and a module name for a PROVISIONAL one.
REGISTRY = {
 ("13_OUROBOROS.pact", "C_Compress"):
   ("executor", "PATRONLESS by design -- IGNIS is being created, there is no patron yet. The "
              "initiating client occupies the slot, which is the convention this file already "
              "used for DPTF::C_Burn / C_Mint before the sweep.", None),
 ("13_OUROBOROS.pact", "C_Sublimate"):    ("executor", "patronless, as C_Compress", None),
 ("13_OUROBOROS.pact", "C_SublimateV2"):  ("executor", "patronless, as C_Compress", None),
 # C_WithdrawFees's entry was CLEARED at 13_OUROBOROS's turn (2026-09-21): the function gained a
 # real `patron` (with an `executor` and an `executee` beside it) and its TFT call site now threads
 # it, so the slot no longer needs explaining. The three siblings above stay: they are PATRONLESS,
 # which is a permanent design fact and not a turn waiting to happen. Their expression changed
 # `client` -> `executor` because the PARAMETER was renamed, not because the design moved -- and
 # the tool caught that itself, by refusing a registry whose text no longer matched the source.
 # 10_ATSU's five entries were CLEARED at its turn (2026-09-21): C_Cull, C_Fuel, C_Syphon,
 # C_WithdrawRoyalties and XI_RemoveSecondary all gained a real `patron` and their TFT call
 # sites were re-pointed to it. Removed rather than commented, which is the point of the
 # `clears-at` column -- it names the turn that retires the entry.
 # 18_SWPLC's C_Fuel entry was CLEARED at its own turn (2026-09-22). The call read
 # `C_MultiTransfer account account ...` -- the SAME account in both the patron and the executor
 # slot, which is the most invisible form this takes: the arity is right, the two values agree,
 # and only the registry remembered that one of them was a stand-in. It now threads a real patron.
 # FOUND BY THE DERIVATION, 2026-09-22, the moment SWEPT stopped being a hand list. The old
 # dict had no "SWP" key, so both of these were invisible. SWP|C_Firestarter is PATRONLESS by
 # design and is registered as such in _executorplan.PATRONLESS ("its patron was unused in the
 # body, threaded in only because C_SublimateV2 had temporarily acquired one") -- it takes
 # `(executor:string)` and nothing else, so the executor occupying the patron slot of its two
 # inner calls is PERMANENT, exactly as in the OUROBOROS family above, not a turn waiting to
 # happen.
 ("04_TS01-C3.pact", "SWP|C_Firestarter"):
   ("executor", "PATRONLESS by design -- the function makes IGNIS out of native STOA, so there "
                "is no patron to pay from yet; the executor funds and receives it.", None),
 ("03_AQP.pact", "XE_TrueFungibleTransfer"): ("owner-id", "provisional", "03_AQP"),
 ("06_VCT.pact", "XI_VacateTrueFungibleFromLegs"):
   ("AQP|SC_NAME", "provisional -- no user account is in scope at all here; the vault is the "
                   "only account the function knows.", "06_VCT"),
 ("06_VCT.pact", "XI_DrainTrueFungibleFromLegs"):
   ("AQP|SC_NAME", "provisional, as XI_VacateTrueFungibleFromLegs", "06_VCT"),
 # ---- 07_DPDC-T's turn, 2026-09-22. Twelve NEW provisional slots in one module's sweep, the
 # most any turn has produced, because DPDC-T::C_Transfer is the collectable movement primitive
 # and SIX unswept modules call it directly rather than through Talos.
 #
 # EVERY ONE PASSES THE USER ACCOUNT, INCLUDING ON THE RETURN LEG. The set/fragment/equity ops
 # are round trips -- <account> sends to the module's smart account and the smart account sends
 # back -- so the EXECUTOR alternates between the two while the PATRON does not: whoever pays
 # for the operation pays for both halves of it, and that is the user. Writing `dpdc` into the
 # patron slot of the return leg would have been the easy mirror of the executor and would have
 # meant "the module pays", which is not what happens.
 # 08_DPDC-S's four entries were CLEARED at its own turn (2026-09-22): all ten entrypoints gained
 # a real `patron`, so the seven DPDC-T call sites and the four C_CreateNewNonce ones thread it
 # instead of the acting account. Removed rather than commented, which is what the `clears-at`
 # column is for -- it names the turn that retires the entry.
 # 09_DPDC-F's two entries were CLEARED at its own turn (2026-09-22), same as 08_DPDC-S's four
 # the entry before: all four entrypoints gained a real `patron` and the four DPDC-T legs thread
 # it instead of the acting account.
 ("11_EQUITY+.pact", "XI_ConvertPackageShares"): ("account", "provisional", "11_EQUITY+"),
 ("11_EQUITY+.pact", "XI_MakePackageShares"):    ("account", "provisional", "11_EQUITY+"),
 ("11_EQUITY+.pact", "XI_BreakPackageShares"):   ("account", "provisional", "11_EQUITY+"),
 ("00_Demipad.pact", "XI_TransmitCollectables"):
   ("client", "provisional -- the launchpad moves the asset BETWEEN <client> and <lpad> in both "
              "directions; the client is the one buying, so the client is the one paying.",
    "00_Demipad"),
 ("03_AQP.pact", "XE_CollectableTransfer"):
   ("owner-id", "provisional, and deliberately the same expression its true-fungible twin "
                "XE_TrueFungibleTransfer already uses -- the two are the same op over two asset "
                "kinds and must not disagree about who pays.", "03_AQP"),
 ("06_VCT.pact", "XI_VacateCollectableBatch"):
   ("AQP|SC_NAME", "provisional -- no user account is in scope; same as the true-fungible "
                   "XI_VacateTrueFungibleFromLegs above.", "06_VCT"),
 ("06_VCT.pact", "XI_DrainCollectableBatch"):
   ("AQP|SC_NAME", "provisional, as XI_VacateCollectableBatch", "06_VCT"),
}

# WIDENED 2026-09-22, twice over, and both gaps were live.
#
#   * `C_[A-Za-z]+` could not match `CC_`, nor any name containing a digit or a hyphen. Every
#     heavy client op in the tree is a `CC_`, and this tool never looked at one.
#   * the first-argument group could not match a PARENTHESISED EXPRESSION, so a patron slot
#     holding `(ref-DPDC::GOV|DPDC|SC_NAME)` -- which is exactly what 08_DPDC-S's three
#     C_Define*Set variants passed before their turn -- was not merely unregistered, it was
#     INVISIBLE. The tool printed a clean "every non-`patron` patron slot is registered" over
#     three slots it had never seen. A checker that silently narrows its own input is worse than
#     no checker, because it reports the narrowing as a pass.
#
# Same class as _executorenforced's FORWARDED matcher, fixed for the same reason on the same day
# a week earlier: a matcher built from the argument shapes you happen to have seen is a hardcoded
# list wearing a regex.
CALL = re.compile(r'\(ref-([A-Za-z0-9|_\-]+)::(CC?_[A-Za-z0-9\-]+)'
                  r'\s+(\([^()]*\)|[A-Za-z0-9|_\-\.\[]+)')
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
    SWEPT = _swept(sorted(files))
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
