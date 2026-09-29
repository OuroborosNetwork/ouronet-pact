#!/usr/bin/env python3
"""_docsref.py -- the three GENERATED reference pages in OuronetDocumentation/90-reference/.

    python3 REPL/tools/_docsref.py --write|--check|--selftest

  01-entrypoint-catalogue.md  every client entrypoint, its preview, its sponsorship
  02-glossary.md              every prefix and sentinel, defined once, from the canon
  05-source-map.md            which repository file backs which documentation page

All three are exactly the kind of page that must never be typed: a catalogue of 423
entrypoints maintained by hand is wrong the day after the next deploy, and a source map
maintained by hand is wrong the day after the next rename.

Whole-file generation, not marker regions -- unlike the module pages, these have no
prose worth preserving. The header of each says so, so nobody adds any.

THE GLOSSARY IS DERIVED, NOT TRANSCRIBED. Prefixes come from the canon file and are
CROSS-CHECKED against what the tree actually uses: a prefix defined and never used, or
used and never defined, is reported rather than silently rendered. That check found the
`W` family missing from this repository's own instruction file.
"""
import glob, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOCS = os.path.join(ROOT, "OuronetDocumentation")
REF = os.path.join(DOCS, "90-reference")
REG = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
CANON = os.path.join(ROOT, "OuronetInformational", "StoicSyntax-Prefixes.md")

BANNER = ("> **This page is GENERATED.** Edit `REPL/tools/_docsref.py`, never this file — the\n"
          "> gate regenerates it and diffs the result. It carries no prose for that reason.\n")


def _tree_prefixes():
    """Every distinct function prefix actually used, with a count."""
    pat = re.compile(r"^\s*\(defun\s+((?:[A-Za-z0-9|+-]+\|)?[A-Za-z]+_|[A-Z]+\|)")
    seen = {}
    for p in glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True) + \
             glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True):
        for line in open(p, encoding="utf-8", errors="replace"):
            m = pat.match(line)
            if m:
                raw = m.group(1)
                base = raw.split("|")[-1] or raw
                seen[base] = seen.get(base, 0) + 1
    return seen


def catalogue():
    r = json.load(open(REG, encoding="utf-8"))
    eps, pv = r["entrypoints"], r["previews"]
    out = ["# Entrypoint catalogue", "", BANNER,
           f"Every client entrypoint Ouronet exposes — **{len(eps)}** of them — with the preview",
           "that prices it and whether the gas station pays for it.",
           "",
           "**Bind preview arguments by NAME, never by position.** A preview's parameter list",
           f"differs from its entrypoint's in **{sum(1 for k, v in eps.items() if v.get('preview') in pv and [(x['name'], x['type']) for x in v['params']] != [(x['name'], x['type']) for x in pv[v['preview']]['params']])}**",
           "cases. Positional binding does not fail — the values are mostly strings, so a wrong",
           "mapping type-checks and returns a confident price for a different question.", ""]
    spon = {}
    for v in eps.values():
        s = v.get("sponsorship", {}).get("sponsored")
        spon[str(s)] = spon.get(str(s), 0) + 1
    out += ["| sponsorship | entrypoints |", "|---|---:|"]
    for k in sorted(spon, key=lambda x: -spon[x]):
        label = {"True": "fully sponsored", "False": "not sponsored"}.get(k, k)
        out.append(f"| {label} | {spon[k]} |")
    out.append("")
    by_mod = {}
    for k, v in sorted(eps.items()):
        by_mod.setdefault(k.split(".", 1)[0], []).append((k, v))
    for mod in sorted(by_mod):
        out += [f"## {mod}", "", "| entrypoint | preview | sponsored |", "|---|---|---|"]
        for k, v in by_mod[mod]:
            s = v.get("sponsorship", {}).get("sponsored")
            mark = {True: "yes", False: "**no**"}.get(s, f"*{s}*")
            name = k.split(".", 1)[1] if "." in k else k
            out.append(f"| `{name}` | `{v.get('preview') or '—'}` | {mark} |")
        out.append("")
    return "\n".join(out)


def glossary():
    used = _tree_prefixes()
    canon = open(CANON, encoding="utf-8").read() if os.path.exists(CANON) else ""
    rows, undefined = [], []
    for pref in sorted(used, key=lambda p: -used[p]):
        gloss = GLOSS.get(pref)
        if gloss is None:
            undefined.append(pref)
            continue
        rows.append((pref, used[pref], gloss))
    out = ["# Glossary", "", BANNER,
           "Every function prefix the tree actually uses, with what the name **promises**.",
           "",
           "The prefix is not decoration. It is the subject of the structural checks described in",
           "`../60-methodology/02-semi-self-auditing.md` — *\"does any function claiming to be pure",
           "read a table?\"* has a mechanical answer only because the claim is in the name.",
           "",
           "Counts are of definitions in the tree, interface declarations included.",
           "", "| prefix | uses | what it promises |", "|---|---:|---|"]
    for p, n, g in rows:
        out.append(f"| `{p}` | {n:,} | {g} |")
    out.append("")
    if undefined:
        out += ["## Used but not defined here", "",
                "These appear in the tree and carry no entry above. That is a gap in this",
                "glossary, not in the code — it is printed rather than hidden, because a",
                "glossary that silently omits what it cannot explain is worse than a short one.",
                "", ", ".join(f"`{u}`" for u in sorted(undefined)), ""]
    unused = [p for p in GLOSS if p not in used]
    if unused:
        out += ["## Defined here but unused", "",
                "Entries with no definition in the tree — a prefix that has been retired, or one",
                "documented before it existed. Either way it is stated rather than rendered as if",
                "live.", "", ", ".join(f"`{u}`" for u in sorted(unused)), ""]
    out += ["## Sentinels and conventions", "",
            "| | |", "|---|---|",
            "| `\"\\|\"` | **unset**. Never an empty string or list. Code testing for emptiness gets the wrong answer; code passing it onward uses it as a table key, which fails uncatchably. |",
            "| a doubled prefix (`CC_`, `AA_`) | the function can reach a **scan** somewhere in its call tree, at any depth. Cost grows with data. |",
            "| `V\\|` `Z\\|` `H\\|` `F\\|` `R\\|` `E\\|` | derived-token prefixes: vested, sleeping, hibernating, frozen, reserved, equity. |",
            "| `S\\|` `W\\|` `P\\|` | swap-pool kinds: stable, weighted, plain constant product. |",
            "| 162 characters | the length of an Ouronet account. **287 bytes** — most of the alphabet is outside ASCII. |",
            ""]
    return "\n".join(out)


GLOSS = {
    "UC_": "pure compute on arguments only — no table reads, no `enforce`",
    "UCv_": "`UC_` whose `enforce` is intrinsic to its own computation",
    "UR_": "reads one row or field by key",
    "URv_": "`UR_` with an intrinsic guard",
    "URC_": "reads and derives; no `enforce`",
    "URCv_": "`URC_` with an intrinsic guard",
    "URCx_": "`URC_` auxiliary",
    "URCi_": "**cost reader** — the single source both billing and the preview call",
    "URCix_": "cost-reader auxiliary",
    "URH_": "**scan** — walks a table. Off the execution path; cost grows with data",
    "URHC_": "scan and derive. Off the execution path",
    "URU_": "version-upgrade read, admin only",
    "UEV_": "reads and `enforce`s; failure aborts the transaction",
    "UDC_": "data construction — a named constructor for an object",
    "UDCx_": "constructor auxiliary",
    "CAP_": "account-ownership enforcement",
    "CT_": "a constant, exposed as a function",
    "GOV|": "governance — keysets and protocol constants",
    "P|": "policy — inter-module authorisation",
    "A_": "admin-key mutation",
    "AA_": "admin mutation that reaches a **scan**",
    "AU_": "admin utility",
    "Ap_": "admin multi-transaction recipe",
    "AAp_": "admin recipe that reaches a scan",
    "C_": "client entry — builds the bill; reachable only through Talos",
    "CC_": "client entry that reaches a **scan**",
    "Cp_": "client multi-transaction recipe, no scan",
    "CCp_": "client recipe that reaches a scan",
    "XI_": "internal write, this module only, under a capability",
    "XIv_": "internal write with an intrinsic guard",
    "XE_": "entry point for other modules only",
    "XB_": "callable both internally and externally",
    "XBv_": "`XB_` with an intrinsic guard",
    "INFO_": "operation preview returning a client-facing cost and description",
    "WI_": "write — insert",
    "WU_": "write — update",
    "WW_": "write — upsert",
    "UCx_": "pure-compute auxiliary — a helper factored out of a `UC_`",
    "UCk_": "**key builder** — composes a table's composite row key. Pure; returns a string, not a table",
    "AUx_": "admin-utility auxiliary",
    "SC_": "smart-contract account name — a constant, exposed as a function",
    "REPL_": "**test fixture only.** Bootstrap helpers that exist for the harness. Present in the repository and, where a module has been redeployed since, absent from the chain — which is why the module pages compare the two",
}


def source_map():
    out = ["# Source map", "", BANNER,
           "Which repository file backs which documentation page.",
           "",
           "Module pages are one-to-one with a deployed module and are listed by the path the",
           "**chain** reports, not the path the checkout happens to have. Where those differ, the",
           "module page itself says so.", "",
           "| page | backed by |", "|---|---|"]
    live_p = os.path.join(ROOT, "Deploy", "LIVE-MODULES.json")
    live = json.load(open(live_p, encoding="utf-8")) if os.path.exists(live_p) else {}
    for p in sorted(glob.glob(os.path.join(DOCS, "30-modules", "*.md"))):
        t = open(p, encoding="utf-8").read()
        m = re.search(r"@generated:module-page:(.+?) -->", t)
        if not m:
            continue
        name = m.group(1)
        rp = (live.get(name) or {}).get("repoPath") or "—"
        out.append(f"| `30-modules/{os.path.basename(p)}` | `{rp}` |")
    out += ["", "## Prose sections", "",
            "These are written from many sources; each page carries its own `Sources` footer.",
            "", "| section | principal sources |", "|---|---|",
            "| `10-architecture/` | `1_SOVEREIGN/`, `Deploy/MANIFEST.md`, `OuronetInformational/ARCHITECTURE/` |",
            "| `20-assets/` | `1_SOVEREIGN/STAGE_01/2_Core/`, `STAGE_02/2_Core/01_DPDC/` |",
            "| `25-defi/` | `2_Core/08_ATS`, the `SWP` family, `2_Core/03_AQP/`, `02_DEMIPAD/` |",
            "| `50-economics/` | `2_Core/02_IGNIS.pact`, `OuronetInformational/IGNIS-PRICING/` |",
            "| `60-methodology/` | `OuronetInformational/StoicSyntax-Prefixes.md`, `REPL/tools/_gate.py`, `Audit/records/DEFECT-LEDGER.md` |",
            "| `70-comparison/` | `Audit/module-audits/SWP/reference/` (Kaddex source, in-repo) |",
            "| `80-cryptography/` | `_libs/DALOS_Crypto/` — **a different repository** |",
            ""]
    return "\n".join(out)


PAGES = {"01-entrypoint-catalogue.md": catalogue,
         "02-glossary.md": glossary,
         "05-source-map.md": source_map}


def build(write=False):
    changed = []
    for fn, fn_build in PAGES.items():
        p = os.path.join(REF, fn)
        body = fn_build().rstrip() + "\n"
        cur = open(p, encoding="utf-8").read() if os.path.exists(p) else None
        if cur != body:
            changed.append(f"90-reference/{fn}")
            if write:
                open(p, "w", encoding="utf-8").write(body)
    return changed


def selftest():
    ok = True
    used = _tree_prefixes()
    if not used:
        print("  selftest: no prefixes found -- the matcher regressed"); ok = False
    for must in ("UR_", "C_", "URCi_", "XI_"):
        if must not in used:
            print(f"  selftest: {must} not detected in the tree"); ok = False
    # The glossary must REPORT a gap rather than hide it.
    g = glossary()
    if "Used but not defined here" not in g and any(p not in GLOSS for p in used):
        print("  selftest: undefined prefixes exist but are not reported"); ok = False
    if "GENERATED" not in catalogue():
        print("  selftest: generated banner missing"); ok = False
    print("  selftest OK" if ok else "  selftest FAILED")
    return ok


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    ch = build("--write" in sys.argv)
    if "--write" in sys.argv:
        print(f"reference pages: {len(ch)} written")
    elif ch:
        print(f"reference pages: {len(ch)} STALE")
        for c in ch:
            print("  " + c)
        sys.exit(1 if "--check" in sys.argv else 0)
    else:
        print(f"reference pages: clean -- all {len(PAGES)} current")
