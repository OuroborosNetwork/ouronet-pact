#!/usr/bin/env python3
"""_ifacemembership.py -- every user/client function sits in its module's own interface.

GROUND TRUTH for the sweep this tool exists to drive. OWNER RULING, 2026-10-12 (see
StoicSyntax-Prefixes.md §5): a module's interface is the GLOSSARY of every function it exposes
-- not a Pact correctness requirement (modref calls resolve dynamically regardless, see
`OuronetInformational/memories/2026-08-29-modref-interface-semantics.md`), a GOVERNANCE one.
"I don't want the interfaces to miss functions just because it was inconvenient to add them due
to interface bump and refactoring" -- the owner's words. This tool measures the gap so it cannot
be forgotten the way it was: `_modulecomplete.py`'s own "interface declarations match module
defuns" check only compares names present on BOTH sides, so a function missing from the interface
ENTIRELY was invisible to it. This is the check that was missing.

WHAT COUNTS. Per StoicSyntax-Prefixes.md §5, every function matching one of the "must appear"
prefixes, EXCEPT the four documented exceptions:
  1. `...x` auxiliaries (UCx_/URCx_/URHCx_/UDCx_) -- private helpers, module-internal by design.
  2. `W...` writers (WI_/WU_/WU2_/WU3_/WU4_/WW_) -- raw persistence, never called via modref.
  3. `XI_` -- internal-only protected orchestration.
  4. A function whose RETURN or any PARAM type is `object{Schema}` where `Schema` is a
     module-local defschema (not the interface's) -- interface loads before module schemas
     exist, so it cannot be declared there, in either position (CORRECTED 2026-10-12: this used
     to check the return type only, which missed `CODEX::UDC_STG|WithRegisteredFlag`-shaped
     functions -- untyped `object` return, module-local schema in a PARAM -- and a stub built
     from that signature aborted the interface's own load with "Cannot find module"). Approximated
     here: an `object{Bare}` reference (no dot-qualifier) in return or param position AND `Bare`
     is NOT one of the interface's own `defschema` names.
ALSO EXCLUDED: `P|*`-namespaced functions (policy-table plumbing -- `P|UEV_IMC`, `P|TS`, ...).
`_modref.py` already measured 165 modref calls to undeclared `P|*` members and found it the
established, accepted convention for that band (CLAUDE.md's STRUCTURAL colour family, distinct
from RECIPE/READ) -- changing that is a materially different, much larger claim than the one the
owner ruled on here ("user/client function"), and is out of scope for this tool until ruled on
separately.

TWO BANDS REPORTED SEPARATELY, because the ruling's own words ("user/client function") name one
of them as primary:
  - RECIPE (primary): C_ CC_ A_ AA_ Cp_ CCp_ Ap_ AAp_ XE_ XB_ -- the user/admin-facing surface.
  - READER (secondary): UR_ URC_ URH_ URHC_ UEV_ CAP_ UDC_ UC_ UCk_ -- StoicSyntax-Prefixes.md
    §5's corollary also names these as "must appear"; reported for completeness, not conflated
    with the RECIPE count in the headline.

KNOWN IMPRECISION, stated rather than hidden: exception #4's approximation can mis-classify a
function whose return-type schema is declared in a DIFFERENT already-deployed interface that
this module does not itself own -- rare in this tree (checked: AQP-ANK/AQP-SCORE are the two
modules CLAUDE.md already names as hitting this rule for real) but not proven exhaustive. Treat
a reported gap as a strong signal, confirm the actual `defun`/`defschema` pair before bumping.

usage:
  python3 REPL/tools/_ifacemembership.py              full report, both bands, per-module
  python3 REPL/tools/_ifacemembership.py --check       exit 1 if any RECIPE-band gap exists
  python3 REPL/tools/_ifacemembership.py --module X    scope to one module name
"""
import re, sys, glob, os, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

RECIPE_RE = re.compile(r'^(?:[A-Za-z0-9+_-]+\|)?(C{1,2}p?_|A{1,2}p?_|X[EB]_)')
READER_RE = re.compile(r'^(?:[A-Za-z0-9+_-]+\|)?(URHC?_|UR_|UEV_|CAP_|UDC_|UCk?_)')
AUX_RE = re.compile(r'^(?:[A-Za-z0-9+_-]+\|)?(UCx_|URCx_|URHCx_|UDCx_)')
POLICY_RE = re.compile(r'^P\|')


def sources():
    return [p for d in ("1_SOVEREIGN", "2_CITIZEN")
            for p in glob.glob(os.path.join(ROOT, d, "**", "*.pact"), recursive=True)
            if "/Audit/" not in p and "/archive/" not in p]


def _top_level_block(text, start):
    nxt = text.find("\n)", start)
    return text[start:nxt if nxt != -1 else len(text)]


def _find_matching_paren(text, start):
    """Paren-balanced scan respecting string literals and `;` line comments (comments can
    contain an unbalanced paren in plain English prose, which corrupts a naive depth count)."""
    depth = 0
    i = start
    n = len(text)
    while i < n:
        c = text[i]
        if c == '"':
            i += 1
            while i < n and text[i] != '"':
                if text[i] == "\\":
                    i += 1
                i += 1
        elif c == ";":
            while i < n and text[i] != "\n":
                i += 1
        elif c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError(f"unbalanced parens from {start}")


def _band(name):
    if POLICY_RE.match(name) or AUX_RE.match(name):
        return None
    if RECIPE_RE.match(name):
        return "recipe"
    if READER_RE.match(name):
        return "reader"
    return None


def scan():
    """-> { module: { 'recipe': set(missing), 'reader': set(missing), 'file': path } }"""
    iface_members = collections.defaultdict(set)   # interface -> declared member names
    iface_schemas = collections.defaultdict(set)   # interface -> its own defschema names
    module_impl = collections.defaultdict(list)    # module -> [interface, ...] it implements
    module_defs = {}                                # module -> { name: (return-type-or-None, param-text) }
    module_file = {}

    for p in sources():
        t = open(p, errors="ignore").read()
        for m in re.finditer(r'^\(interface\s+([A-Za-z0-9_]+)', t, re.M):
            iname = m.group(1)
            block = _top_level_block(t, m.end())
            for d in re.finditer(r'\(defun\s+([A-Za-z0-9_|>\-]+)', block):
                iface_members[iname].add(d.group(1))
            for d in re.finditer(r'\(defschema\s+([A-Za-z0-9_|>\-]+)', block):
                iface_schemas[iname].add(d.group(1))
        for m in re.finditer(r'^\(module\s+([A-Za-z0-9_|+-]+)[^\n]*', t, re.M):
            mname = m.group(1)
            module_file[mname] = os.path.relpath(p, ROOT)
            body = _top_level_block(t, m.end())
            for im in re.finditer(r'\(implements\s+([A-Za-z0-9_]+)', body):
                module_impl[mname].append(im.group(1))
            defs = module_defs.setdefault(mname, {})
            # `(defun NAME:RETTYPE (...) ...)` or `(defun NAME (...) ...)` -- capture the return
            # annotation when present, AND the full param-list text (paren-balanced, verbatim),
            # for the #4 module-schema exception. That exception was originally checked against
            # the RETURN type only, which missed the equally-real case of a PARAM referencing a
            # module-local schema (`CODEX::UDC_STG|WithRegisteredFlag`'s `row:object{CODEX|S|
            # StoicTag}` -- untyped `object` return, module-only schema in the PARAM position).
            # Interface load order doesn't care which position the reference is in.
            for d in re.finditer(
                    r'\(defun\s+([A-Za-z0-9_|>\-]+)(?::(object\{[A-Za-z0-9_.]+\}|[A-Za-z0-9\[\]]+))?\s*\(',
                    body):
                name = d.group(1)
                paren_start = d.end() - 1
                try:
                    paren_end = _find_matching_paren(body, paren_start)
                    param_text = body[paren_start:paren_end + 1]
                except ValueError:
                    param_text = ""
                defs[name] = (d.group(2), param_text)

    gaps = {}
    for mname, defs in module_defs.items():
        ifaces = module_impl.get(mname, [])
        declared = set()
        own_schemas = set()
        for iname in ifaces:
            declared |= iface_members.get(iname, set())
            own_schemas |= iface_schemas.get(iname, set())
        recipe_missing, reader_missing = set(), set()
        for name, (rettype, param_text) in defs.items():
            band = _band(name)
            if band is None or name in declared:
                continue
            # exception #4: an unqualified object{Bare} reference -- return OR param position,
            # load order doesn't distinguish them -- where Bare is NOT one of this function's
            # own candidate interfaces' schemas, i.e. presumably module-local and thus unable to
            # be declared in an interface that loads before the module's schemas exist.
            bares = set()
            if rettype and rettype.startswith("object{") and "." not in rettype:
                bares.add(rettype[len("object{"):-1])
            bares |= {b for b in re.findall(r"object\{([A-Za-z0-9_|-]+)\}", param_text)}
            if bares and not (bares <= own_schemas):
                continue
            (recipe_missing if band == "recipe" else reader_missing).add(name)
        if recipe_missing or reader_missing:
            gaps[mname] = {"recipe": recipe_missing, "reader": reader_missing,
                           "file": module_file[mname], "ifaces": ifaces}
    return gaps


def main():
    only = None
    if "--module" in sys.argv:
        only = sys.argv[sys.argv.index("--module") + 1]
    quiet = "--check" in sys.argv
    gaps = scan()
    if only:
        gaps = {k: v for k, v in gaps.items() if k == only}

    # OUT OF SCOPE, same shape and same convention `_executorplan.py` settled on for the
    # patron/executor canon sweep (CLAUDE.md, owner ruling 2026-09-26): "citizen modules are
    # free to construct functions as they please." That ruling was about a DIFFERENT canon, but
    # this sweep hit the identical shape (HANDOFF-interface-membership-sweep.md flagged it as an
    # open question before the 2026-10-12 sweep ran) and the 2026-10-12 owner instruction that
    # triggered the sweep named only "the whole pact code stage 1 and stage 2 modules" --
    # 1_SOVEREIGN. So: sovereign is the report: citizen prints separately, uncounted, as a
    # stated boundary rather than a silent omission.
    sov = {k: v for k, v in gaps.items() if "1_SOVEREIGN" in v["file"]}
    cit = {k: v for k, v in gaps.items() if "1_SOVEREIGN" not in v["file"]}

    total_recipe = sum(len(v["recipe"]) for v in sov.values())
    total_reader = sum(len(v["reader"]) for v in sov.values())

    if not quiet:
        print(f"modules scanned with a gap: {len(sov)}")
        print(f"RECIPE-band gaps (user/client functions -- the primary ruling): {total_recipe}")
        print(f"READER-band gaps (UR_/URC_/etc -- §5's fuller corollary): {total_reader}\n")
        for mname in sorted(sov, key=lambda k: -len(sov[k]["recipe"]) - len(sov[k]["reader"])):
            g = sov[mname]
            ifaces = ", ".join(g["ifaces"]) or "(implements nothing -- cannot be modref'd)"
            print(f"  {mname}  ({g['file']}, implements {ifaces})")
            for n in sorted(g["recipe"]):
                print(f"     RECIPE  {n}")
            for n in sorted(g["reader"]):
                print(f"     reader  {n}")
        print(f"\n{len(sov)} module(s), {total_recipe} recipe-band + {total_reader} reader-band gap(s).")
        if cit:
            cit_recipe = sum(len(v["recipe"]) for v in cit.values())
            cit_reader = sum(len(v["reader"]) for v in cit.values())
            print(f"\nOUT OF SCOPE (2_CITIZEN) -- {len(cit)} module(s), {cit_recipe} recipe-band "
                  f"+ {cit_reader} reader-band gap(s), not counted above. NOT a backlog -- "
                  f"citizen modules are free to construct functions as they please.")
            for mname in sorted(cit, key=lambda k: -len(cit[k]["recipe"]) - len(cit[k]["reader"])):
                print(f"   {mname:20s} {len(cit[mname]['recipe'])} recipe + "
                      f"{len(cit[mname]['reader'])} reader")

    if total_recipe:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
