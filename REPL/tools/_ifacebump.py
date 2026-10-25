#!/usr/bin/env python3
"""_ifacebump.py -- mechanically close an interface-membership gap for one module.

Companion to `_ifacemembership.py` (ground truth for WHAT is missing). This tool does the
MECHANICAL part of closing a gap, so 307 hand-written declarations across 36 modules is not
307 chances to mistype a signature:

  1. Finds the module's OWN co-located interface (the one declared in the SAME FILE -- house
     convention confirmed throughout this tree: "Deploy: load THIS file -- interface(s) + module
     ship together"). A module implementing OTHER, SHARED interfaces too (`OuronetPolicyV2`,
     `DemiourgosPactDigitalCollectibles`, `BrandingUsagePrimaryV2`, ...) never gets gap functions
     routed there -- those are structural/cross-module contracts defined elsewhere, not this
     module's own glossary.
  2. For each missing function, extracts its REAL signature (return type + full parameter list,
     VERBATIM including original multi-line formatting) from the module body by paren-balanced
     parsing -- not regex-guessing a reformatted stub, so a multi-line param list transplants
     exactly as the module already wrote it.
  3. Bumps the co-located interface's version suffix by exactly one (`FooV1` -> `FooV2`), inserts
     the new stubs under a dated banner comment, changes the module's `(implements FooV1)` to
     `(implements FooV2)`.
  4. Finds EVERY OTHER file in the tree holding `module{FooV1}` or `object{FooV1.Schema}` and
     rewrites it to `FooV2` -- this is NOT optional: once the module's `implements` clause drops
     V1, a consumer still typed `module{FooV1}` fails to type-check (the module no longer
     implements that interface at all), so a missed consumer is a hard break, not a stale read.

WHAT THIS TOOL DOES NOT DO: decide which modules to bump (that's `_ifacemembership.py`'s scan),
or compute deploy order / dot-pin re-pin cascades (`_deploybundle.py` / `_dotpin.py` already do
that correctly and this tool does not duplicate it). It also does not touch READER-band gaps
differently from RECIPE-band ones -- both get the same treatment, since StoicSyntax-Prefixes.md
Sec5's "must appear" corollary names both.

usage:
  python3 REPL/tools/_ifacebump.py --module AQP-FVT              preview the bump, do not write
  python3 REPL/tools/_ifacebump.py --module AQP-FVT --write       apply it
  python3 REPL/tools/_ifacebump.py --list                         which modules have a gap, and
                                                                    what their bumped interface
                                                                    name would be
"""
import re, sys, os, glob, importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.dirname(os.path.abspath(__file__))

_spec = importlib.util.spec_from_file_location("ifm", os.path.join(HERE, "_ifacemembership.py"))
ifm = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ifm)

DATE_BANNER = "2026-10-12"


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def write(path, text):
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)


def find_matching_paren(text, start):
    """Paren-balanced scan respecting both string literals AND `;` line comments. The comment
    skip was missing originally -- fine for a `defun` header's own param list (rarely spans a
    full-line comment) but WRONG once called on something as long as a whole interface body
    (`own_schema_names`, below): banner comments and prose routinely contain an unbalanced `(` or
    `)` in plain English ("e.g. (not that" ...), which silently corrupted the depth count and
    raised a spurious "unbalanced parens" on a file that parses fine."""
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


def bumped_name(iface):
    m = re.match(r"^(.*?)V(\d+)$", iface)
    if not m:
        raise ValueError(f"interface {iface!r} has no trailing Vn suffix to bump")
    base, n = m.group(1), int(m.group(2))
    return f"{base}V{n + 1}"


def extract_signature(module_text, fn_name):
    """-> (rettype_suffix_or_'', param_text_verbatim) by paren-balanced parse, or None."""
    pat = re.compile(r"\(defun\s+" + re.escape(fn_name) + r"(:[A-Za-z0-9_.\[\]{}|]+)?\s*\(")
    m = pat.search(module_text)
    if not m:
        return None
    rettype = m.group(1) or ""
    paren_start = m.end() - 1
    paren_end = find_matching_paren(module_text, paren_start)
    param_text = module_text[paren_start : paren_end + 1]
    return rettype, param_text


# Interfaces that are SHARED structural contracts, never the target of a RECIPE/READER gap even
# when co-located with a module's own interface (DALOS hosts OuronetPolicyV2's declaration
# because DALOS deploys first, not because DALOS's own gaps belong there; same shape for
# OuronetInfoV2/IGNIS, BrandingUsage*/the branding-usage modules, DemiourgosPactDigitalCollectibles
# /the AQP family). Excluded from candidacy UNLESS a function's own signature explicitly
# references it (checked first, below) -- that would be a real, not a structural, dependency.
KNOWN_SHARED = {
    "OuronetPolicyV2", "OuronetInfoV2", "DemiourgosPactDigitalCollectibles",
    "BrandingUsagePrimaryV2", "BrandingUsageSecondaryV2", "BrandingUsageTertiaryV2", "stoa",
}

# Per-function manual routing for the handful of cases where a module has TWO of its OWN
# (non-shared) co-located interfaces and the function's signature carries no explicit
# `OtherIface.Schema` reference to resolve it automatically. Decided by reading each function's
# body/purpose directly (see HANDOFF-interface-membership-sweep.md for the reasoning) --
# NOT guessed, and refuses outright (plan() raises) if a function needs this and isn't listed.
MANUAL_ROUTE = {
    ("ATS", "UR_Properties"): "AutostakeV3",
    ("PYTHIA", "UC_AutonomousConsumerLane"): "PythiaV5",
    ("PYTHIA", "UC_MaxDay"): "PythiaLedgerV3",
    ("PYTHIA", "UC_PythDayOrdinal"): "PythiaLedgerV3",
    ("PYTHIA", "UCk_PythDaily"): "PythiaLedgerV3",
    ("PYTHIA", "UDC_AKY|Unregistered"): "PythiaV5",
    ("PYTHIA", "UDC_AKY|WithRegisteredFlag"): "PythiaV5",
    ("PYTHIA", "UDC_DLK|Unregistered"): "PythiaV5",
    ("PYTHIA", "UDC_DLK|WithRegisteredFlag"): "PythiaV5",
    ("PYTHIA", "UDC_DualLinkView"): "PythiaV5",
    ("PYTHIA", "UEV_DualPairForLink"): "PythiaV5",
    ("PYTHIA", "UEV_DualPairReadyForActivate"): "PythiaV5",
    ("PYTHIA", "UEV_ExecutorIsHalfOwner"): "PythiaV5",
    ("PYTHIA", "UEV_ValidateCompositeDualLinkKey"): "PythiaV5",
    ("PYTHIA", "UR_PythDailyExists"): "PythiaLedgerV3",
}


def own_schema_names(text, iface_name):
    """Schemas declared INSIDE this interface's own body (`defschema` between its header and
    closing paren). Needed because a signature extracted from the MODULE body always qualifies
    such a schema (`object{Iface.Schema}` -- required outside the interface), but CLAUDE.md's
    "Same-interface object types" rule requires the UNQUALIFIED form (`object{Schema}`) once the
    same text is pasted back INSIDE that interface -- interfaces load before module schemas
    exist, and self-qualifying is also simply wrong syntax-wise once relocated."""
    m = re.search(rf"^\(interface\s+{re.escape(iface_name)}\b", text, re.M)
    if not m:
        return set()
    close = find_matching_paren(text, m.start())
    body = text[m.start():close]
    return set(re.findall(r"\(defschema\s+([A-Za-z0-9_|-]+)", body))


def unqualify_own_schema(s, iface_name, schemas):
    for sch in schemas:
        s = re.sub(rf"\bobject\{{{re.escape(iface_name)}\.{re.escape(sch)}\}}",
                    f"object{{{sch}}}", s)
    return s


def co_located_interfaces(path, ifaces):
    """Every one of `ifaces` that is declared in THIS SAME FILE (a module may co-locate more
    than one of its own interfaces, e.g. ATS/AutostakeV3 + AutostakeComputerV2)."""
    t = read(path)
    declared_here = set(re.findall(r"^\(interface\s+([A-Za-z0-9_]+)", t, re.M))
    return sorted({i for i in ifaces if i in declared_here})


def route(module_name, fn_name, rettype, params, candidates):
    """Which candidate interface owns this one function."""
    explicit = [c for c in candidates if f"{c}." in rettype or f"{c}." in params]
    if len(explicit) == 1:
        return explicit[0]
    non_shared = [c for c in candidates if c not in KNOWN_SHARED]
    if len(non_shared) == 1:
        return non_shared[0]
    if (module_name, fn_name) in MANUAL_ROUTE:
        target = MANUAL_ROUTE[(module_name, fn_name)]
        if target not in candidates:
            raise SystemExit(f"{module_name}.{fn_name}: MANUAL_ROUTE target {target!r} is not "
                              f"even a candidate ({candidates}) -- stale override, fix it")
        return target
    raise SystemExit(
        f"{module_name}.{fn_name}: cannot resolve which of {candidates} owns this -- no explicit "
        f"type reference, more than one non-shared candidate, and no MANUAL_ROUTE entry. "
        f"Read the function and add one.")


def plan(module_name):
    gaps = ifm.scan()
    g = gaps.get(module_name)
    if not g:
        return None
    path = os.path.join(ROOT, g["file"])
    text = read(path)
    candidates = co_located_interfaces(path, g["ifaces"])
    if not candidates:
        raise SystemExit(f"{module_name}: NO co-located interface among {g['ifaces']} -- "
                          f"its own interface must live in a DIFFERENT file, unsupported here")

    missing = sorted(g["recipe"]) + sorted(g["reader"])
    by_iface = {}   # old_iface -> [(name, stub_line), ...]
    for name in missing:
        sig = extract_signature(text, name)
        if sig is None:
            raise SystemExit(f"{module_name}: could not find defun {name} in {path} -- "
                              f"module body scan and interface-gap scan disagree, stop")
        rettype, params = sig
        target = candidates[0] if len(candidates) == 1 else route(
            module_name, name, rettype, params, candidates)
        own_schemas = own_schema_names(text, target)
        if own_schemas:
            rettype = unqualify_own_schema(rettype, target, own_schemas)
            params = unqualify_own_schema(params, target, own_schemas)
        stub = f"    (defun {name}{rettype} {params})"
        by_iface.setdefault(target, []).append((name, stub))

    bumps = []
    for old_iface, pairs in sorted(by_iface.items()):
        bumps.append({
            "old_iface": old_iface, "new_iface": bumped_name(old_iface),
            "missing": [n for n, _ in pairs], "stubs": [s for _, s in pairs],
        })
    return {"module": module_name, "path": path, "text": text, "bumps": bumps}


def _rename_one_interface(text, old, new, stubs):
    text2, n = re.subn(
        rf"^\(interface\s+{re.escape(old)}\b", f"(interface {new}", text, count=1, flags=re.M)
    if n != 1:
        raise SystemExit(f"expected exactly 1 interface header match for {old}, got {n}")
    m = re.search(rf"^\(interface\s+{re.escape(new)}\b", text2, re.M)
    close = text2.find("\n)", m.end())
    if close == -1:
        raise SystemExit(f"could not find {new}'s closing paren")
    banner = (
        f"\n\n    ;;<=========================================================================>\n"
        f"    ;; ADDED {DATE_BANNER} -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,\n"
        f"    ;; owner ruling). Every one of these was already live in the module body; this\n"
        f"    ;; closes the gap between what the module DOES and what its interface SAYS it does.\n"
        f"    ;;<=========================================================================>\n"
    )
    insertion = banner + "\n".join(stubs)
    return text2[:close] + insertion + text2[close:]


def apply_module(p):
    """Apply EVERY bump for this module's file (it may touch more than one of its own
    co-located interfaces), write it once, then sweep the WHOLE tree for every renamed
    interface's consumers. Returns {old_iface: new_iface} and the set of touched consumer files."""
    text = p["text"]
    renames = {}
    for b in p["bumps"]:
        text = _rename_one_interface(text, b["old_iface"], b["new_iface"], b["stubs"])
        renames[b["old_iface"]] = b["new_iface"]

    for old, new in renames.items():
        # NOTE: count was previously 1, which is wrong whenever the literal text
        # "(implements OLD)" also appears inside an @doc string BEFORE the real structural
        # clause (e.g. "...math library (implements UtilitySwpV2). Defines...") -- the budget
        # of 1 gets spent on the textually-first (prose) hit and the real `(implements OLD)`
        # declaration below it is left stale, which is a silent hard-break (module no longer
        # implements OLD at all, so every `module{OLD}` consumer fails to type-check) that the
        # old `n != 1` check could not catch because exactly 1 substitution DID happen.
        # Replacing ALL occurrences is correct either way: a prose mention of the old name is
        # stale documentation and should say the new name too.
        text, n = re.subn(rf"\(implements\s+{re.escape(old)}\)", f"(implements {new})", text)
        if n < 1:
            raise SystemExit(f"{p['module']}: expected >=1 (implements {old}), got {n}")
        # a module may ALSO hold a self-modref (rare, but AcquisitionPoolsV1-style self-reference
        # patterns exist) -- module{OLD} inside the module's OWN file, same rewrite as elsewhere.
        text = re.sub(rf"\bmodule\{{{re.escape(old)}\}}", f"module{{{new}}}", text)
        # Schema names in this tree routinely carry `|` and `-` (DPTF|BalanceSchema,
        # DPDC-MNG|WipeSlicePlan, ...) -- `\w+` silently failed to match any of those, so
        # `object{OLD.Pipe|Named}` refs were never rewritten anywhere, module file or consumer.
        # And the qualified form is NOT always preceded by the `object` keyword -- a `deftable`
        # row-type annotation writes the bare form, `:{OLD.Schema}` (e.g.
        # `(deftable DPTF|BalanceTable:{OuronetDalosV2.DPTF|BalanceSchema})`), so anchoring on
        # `\bobject\{` missed every one of those. `{` cannot appear inside a Pact identifier, so
        # matching on the brace alone (no prefix requirement) is sufficient and safe.
        text = re.sub(rf"\{{{re.escape(old)}\.([A-Za-z0-9_|-]+)\}}", rf"{{{new}.\1}}", text)

    write(p["path"], text)

    touched = []
    patterns = (
        [os.path.join(ROOT, d, "**", "*.pact") for d in ("1_SOVEREIGN", "2_CITIZEN")]
        # REPL test/tool harnesses bind the SAME `module{Iface}` typed refs and are not deployed,
        # but they still have to PARSE -- a stale V1 ref aborts load the instant the module no
        # longer implements it. Excludes Deploy/ (generated, regenerated separately) and
        # Audit/ (frozen records).
        + [os.path.join(ROOT, "REPL", "**", "*.repl")]
    )
    for pat in patterns:
        for f in glob.glob(pat, recursive=True):
            if os.path.abspath(f) == os.path.abspath(p["path"]):
                continue
            t = read(f)
            t2 = t
            for old, new in renames.items():
                t2 = re.sub(rf"\bmodule\{{{re.escape(old)}\}}", f"module{{{new}}}", t2)
                t2 = re.sub(rf"\{{{re.escape(old)}\.([A-Za-z0-9_|-]+)\}}", rf"{{{new}.\1}}", t2)
            if t2 != t:
                write(f, t2)
                touched.append(os.path.relpath(f, ROOT))
    return renames, touched


def sovereign_gapped_modules():
    gaps = ifm.scan()
    return sorted((m for m, g in gaps.items() if "1_SOVEREIGN" in g["file"]),
                  key=lambda m: gaps[m]["file"])


def main():
    write_mode = "--write" in sys.argv

    if "--list" in sys.argv:
        for mname in sovereign_gapped_modules():
            g = ifm.scan()[mname]
            try:
                p = plan(mname)
                tag = ", ".join(f"{b['old_iface']}->{b['new_iface']} ({len(b['missing'])})"
                                 for b in p["bumps"])
            except SystemExit as e:
                tag = f"ERROR: {e}"
            print(f"  {mname:16} {g['file']:58} "
                  f"{len(g['recipe'])+len(g['reader']):3} gap(s) -> {tag}")
        return 0

    if "--all" in sys.argv:
        modules = sovereign_gapped_modules()
        all_renames = {}
        for mname in modules:
            p = plan(mname)
            print(f"{p['module']}:")
            for b in p["bumps"]:
                print(f"   {b['old_iface']} -> {b['new_iface']}  ({len(b['missing'])} stub(s))")
            if write_mode:
                renames, touched = apply_module(p)
                all_renames.update(renames)
                print(f"   wrote {p['path']}, touched {len(touched)} consumer file(s)")
        if write_mode:
            print(f"\n{len(modules)} module(s), {len(all_renames)} interface(s) bumped.")
        else:
            print("\n(preview only -- pass --write to apply)")
        return 0

    if "--module" not in sys.argv:
        print(__doc__)
        return 0
    mname = sys.argv[sys.argv.index("--module") + 1]
    p = plan(mname)
    if p is None:
        print(f"{mname}: no gap found (nothing to do)")
        return 0

    print(f"{p['module']}  ({p['path']})")
    for b in p["bumps"]:
        print(f"  {b['old_iface']} -> {b['new_iface']}  ({len(b['missing'])} stub(s))")
        for s in b["stubs"]:
            print(f"   {s}")

    if write_mode:
        renames, touched = apply_module(p)
        print(f"\n  wrote {p['path']}")
        print(f"  rewrote {len(touched)} consumer(s): {', '.join(touched) if touched else '(none)'}")
    else:
        print("\n  (preview only -- pass --write to apply)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
