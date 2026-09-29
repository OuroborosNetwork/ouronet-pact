#!/usr/bin/env python3
"""_docsblocks.py -- render one module's generated documentation block, from the DEPLOYED shape.

Consumed by `_docsmodules.py`, which owns the marker machinery. This file owns only the rendering,
and lives apart from it because the module map and the per-module block answer different questions
and will change for different reasons.

LIVE IS THE AUTHORITY. Everything here reads `Deploy/LIVE-MODULES.json`, which is what
`describe-module` returned from the chain. The repository is then compared and any difference is
STATED rather than resolved -- a reader of this documentation calls the chain, not the checkout.
See OuronetDocumentation/MAINTAINING.md section 2a.

A region is `module:<NAME>`, so a page may carry ONE block (a per-module page) or SEVERAL (an
entity chapter covering a subsystem). That is deliberate: the choice between those two shapes is
still open and this generator does not force it.
"""
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LIVE = os.path.join(ROOT, "Deploy", "LIVE-MODULES.json")

# Prefix families in the order StoicSyntax presents them.
#
# FIRST MATCH WINS OVER A LONGEST-FIRST LIST, and the order is load-bearing: `URCi_` must be tested
# before `URC_`, and `URC_` before `UR_`. Reverse any of those and a cost reader is filed as a
# plain read -- the grouping still renders, it is just quietly wrong, which is the failure mode
# this whole folder is built against.
FAMILIES = [
    ("URCi_", "cost readers",               "returns what an operation will charge"),
    ("URCv_", "derived reads (validating)",  "read + derive, with an intrinsic guard"),
    ("URHC_", "heavy derived reads",         "a scan, then derivation"),
    ("URH_",  "heavy reads",                 "a scan -- expensive by construction"),
    ("URC_",  "derived reads",               "read and derive; no enforce"),
    ("UEV_",  "validators",                  "read and enforce; may abort the transaction"),
    ("UDC_",  "constructors",                "named object constructors"),
    ("UCv_",  "pure compute (validating)",   "compute with an intrinsic guard"),
    ("UCx_",  "pure compute (auxiliary)",    "a private helper of the function above it"),
    ("UCk_",  "pure compute (key)",          "builds a composite table key"),
    ("UC_",   "pure compute",                "arguments only -- no reads, no enforce"),
    ("UM_",   "migrate-on-read",             "the only reader permitted to write"),
    ("UR_",   "readers",                     "table reads; no enforce, no writes"),
    ("CAP_",  "ownership gates",             "account-ownership enforcement"),
    ("INFO_", "cost previews",               "client-facing price preview"),
    ("WI_",   "writers (insert)",            "one write site each"),
    ("WU_",   "writers (update)",            "one write site each"),
    ("WW_",   "writers (upsert)",            "one write site each"),
    ("XI_",   "protected (internal)",        "this module only"),
    ("XE_",   "protected (external)",        "for other modules; opens with the IMC gate"),
    ("XB_",   "protected (both)",            "internal and external"),
    ("AAp_",  "admin recipe (heavy)",        "multi-transaction, reaches a scan"),
    ("AA_",   "admin (heavy)",               "admin key; reaches a scan somewhere in its tree"),
    ("Ap_",   "admin recipe",                "multi-transaction"),
    ("A_",    "admin",                       "admin-key mutations"),
    ("CCp_",  "client recipe (heavy)",       "multi-transaction, reaches a scan"),
    ("CC_",   "client (heavy)",              "client entrypoint; reaches a scan"),
    ("Cp_",   "client recipe",               "multi-transaction"),
    ("C_",    "client",                      "reached via Talos, never called directly"),
    ("P|",    "policy",                      "inter-module authorisation"),
]

SHAPE_PATTERNS = {
    "schemas":      r"\(defschema\s+([^\s)]+)",
    "tables":       r"\(deftable\s+([^\s:)]+)",
    "capabilities": r"\(defcap\s+([^\s(]+)",
    "functions":    r"\(defun\s+([^\s:(]+)",
    "pacts":        r"\(defpact\s+([^\s:(]+)",
    "constants":    r"\(defconst\s+([^\s:)]+)",
}


def family_of(fn):
    """The family of a function name, allowing a `SCOPE|` prefix. (None, None) when unclassified."""
    bare = fn.split("|", 1)[1] if "|" in fn and not fn.startswith("P|") else fn
    for pre, label, _ in FAMILIES:
        if bare.startswith(pre):
            return pre, label
    return None, None


def live_modules():
    if not os.path.exists(LIVE):
        return {}
    return json.load(open(LIVE, encoding="utf8")).get("modules", {})


def repo_shapes(rel_path):
    """The repo's copy, parsed with the SAME patterns the live prober used -- so a difference in
    the RESULT is a difference in the CODE and never in the reading of it."""
    txt = open(os.path.join(ROOT, rel_path), encoding="utf8", errors="replace").read()
    return {k: sorted(set(re.findall(v, txt, re.M))) for k, v in SHAPE_PATTERNS.items()}


def render(name):
    m = live_modules().get(name)
    if not m:
        return ("> **No live record for `" + name + "`.** Run "
                "`python3 REPL/tools/_livemodules.py --probe`. A module this generator has never "
                "seen is not 'unchanged' -- it is unknown, and the difference matters.")

    if not m.get("deployed"):
        return ("> **`" + name + "` is declared in the repository and is NOT deployed.**\n>\n"
                "> Nothing is generated for it, because everything below would describe code that "
                "is not running. Source: `" + m.get("repoPath", "?") + "`.")

    sh, out = m["shapes"], []

    out.append("**On chain**")
    out.append("")
    out.append("| | |")
    out.append("|---|---|")
    out.append("| module hash | `" + m["hash"] + "` |")
    out.append("| deployed size | " + format(m["chars"], ",") + " characters |")
    ifaces = ", ".join("`" + i.split(".")[-1] + "`" for i in m.get("interfaces", []))
    out.append("| implements | " + (ifaces or "—") + " |")
    out.append("| repository source | `" + m["repoPath"] + "` |")
    out.append("")

    if sh["tables"]:
        out.append("**Tables it owns** — " + str(len(sh["tables"])))
        out.append("")
        out.append(", ".join("`" + t + "`" for t in sh["tables"]))
        out.append("")
        if sh["schemas"]:
            out.append("**Schemas** — " + str(len(sh["schemas"])))
            out.append("")
            out.append(", ".join("`" + s + "`" for s in sh["schemas"]))
            out.append("")
    elif sh["schemas"]:
        out.append("**Schemas** — " + str(len(sh["schemas"])) + ", with no tables of its own")
        out.append("")
        out.append(", ".join("`" + s + "`" for s in sh["schemas"]))
        out.append("")

    if sh["capabilities"]:
        out.append("**Capabilities** — " + str(len(sh["capabilities"])))
        out.append("")
        out.append(", ".join("`" + c + "`" for c in sh["capabilities"]))
        out.append("")

    fns = sh["functions"]
    if fns:
        grouped, unclassified = {}, []
        for f in fns:
            pre, label = family_of(f)
            if pre:
                grouped.setdefault(pre, []).append(f)
            else:
                unclassified.append(f)
        out.append("**Functions** — " + str(len(fns)) + ", grouped by what their prefix promises")
        out.append("")
        out.append("| family | n | the promise | names |")
        out.append("|---|---:|---|---|")
        for pre, label, promise in FAMILIES:
            got = grouped.get(pre)
            if not got:
                continue
            shown = ", ".join("`" + g + "`" for g in got[:6])
            if len(got) > 6:
                shown += " …+" + str(len(got) - 6)
            out.append("| `" + pre + "` " + label + " | " + str(len(got)) + " | "
                       + promise + " | " + shown + " |")
        if unclassified:
            shown = ", ".join("`" + u + "`" for u in unclassified[:6])
            if len(unclassified) > 6:
                shown += " …+" + str(len(unclassified) - 6)
            out.append("| *(unclassified)* | " + str(len(unclassified))
                       + " | carries no StoicSyntax prefix | " + shown + " |")
        out.append("")

    if sh["pacts"]:
        out.append("**Multi-transaction (`defpact`)** — "
                   + ", ".join("`" + p + "`" for p in sh["pacts"]))
        out.append("")

    # LIVE VS REPO -- reported, never reconciled.
    try:
        repo = repo_shapes(m["repoPath"])
    except OSError:
        out.append("> Repository source not found, so the live shape is shown without comparison.")
        return "\n".join(out)

    diffs = []
    for kind in ("schemas", "tables", "capabilities", "functions", "pacts"):
        only_live = sorted(set(sh[kind]) - set(repo[kind]))
        only_repo = sorted(set(repo[kind]) - set(sh[kind]))
        if only_live or only_repo:
            diffs.append((kind, only_live, only_repo))

    if not diffs:
        out.append("> Repository and chain agree on every declared shape.")
        return "\n".join(out)

    out.append("> **The repository differs from what is deployed.** Everything above describes "
               "the CHAIN, which is what a caller actually reaches. The difference is stated "
               "rather than resolved:")
    out.append(">")
    for kind, only_live, only_repo in diffs:
        if only_live:
            out.append("> - **" + kind + "** on chain only: "
                       + ", ".join("`" + x + "`" for x in only_live[:8]))
        if only_repo:
            out.append("> - **" + kind + "** in the repository only: "
                       + ", ".join("`" + x + "`" for x in only_repo[:8]))
    return "\n".join(out)
