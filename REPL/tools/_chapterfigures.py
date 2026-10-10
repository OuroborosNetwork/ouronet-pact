#!/usr/bin/env python3
"""_chapterfigures.py -- the Integration chapter quotes the registry; check it still says that.

    python3 REPL/tools/_chapterfigures.py [--check]

WHY. `docs/CHAPTER-INTEGRATION/` is written to a rule it states in its own front matter: "where a
figure appears, it was read from the source or a REPL run, not remembered". Fifteen of those
figures are derived from `Deploy/OURONET-REGISTRY.json`, which is REGENERATED from the chain. So
every one of them is a claim with an expiry date nobody can see.

That is the same shape as the price sheet and the ARCHITECTURE figures, and it gets the same
treatment: the number is recomputed here and compared to the prose. A stale figure reads exactly
as authoritative as a fresh one -- and this chapter is written to be published, where a wrong
number outlives anyone's memory of how it was obtained.

WHAT THIS DOES NOT DO. It does not check prose, only the figures it is told about. A claim added
to the chapter without a row here is unguarded, and that is a real gap rather than a silent one:
the tool reports how many rows it checked, so a chapter that grows while this does not is
visible in the diff.
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REG = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
CH = os.path.join(ROOT, "docs", "CHAPTER-INTEGRATION")


def figures():
    """Everything the chapter claims, recomputed from the registry."""
    d = json.load(open(REG, encoding="utf8"))
    eps, prev = d["entrypoints"], d["previews"]

    paired = same = diff = 0
    for v in eps.values():
        pv = prev.get(v.get("preview") or "")
        if not pv:
            continue
        paired += 1
        if [p["name"] for p in v["params"]] == [p["name"] for p in pv["params"]]:
            same += 1
        else:
            diff += 1

    sponsored = sum(1 for v in eps.values()
                    if (v.get("sponsorship") or {}).get("sponsored"))
    resolved = sum(1 for v in eps.values()
                   if (v.get("ownership") or {}).get("resolved"))
    always = cond = via_param = via_reader = 0
    for v in eps.values():
        for r in ((v.get("ownership") or {}).get("requires") or []):
            if r.get("when") == "ALWAYS": always += 1
            elif r.get("when") == "CONDITIONAL": cond += 1
            if r.get("via") == "parameter": via_param += 1
            elif r.get("via") == "reader": via_reader += 1

    fam = {}
    for k in eps:
        f = k.split(".", 1)[1].split("|")[0]
        fam[f] = fam.get(f, 0) + 1

    return {
        "entrypoints":        len(eps),
        "previews":           len(prev),
        "paired":             paired,
        "preview_params_same": same,
        "preview_params_diff": diff,
        "sponsored":          sponsored,
        "unsponsored":        len(eps) - sponsored,
        "ownership_resolved": resolved,
        "ownership_always":   always,
        "ownership_cond":     cond,
        "own_via_parameter":  via_param,
        "own_via_reader":     via_reader,
        "alias_paired":       sum(1 for v in eps.values() if v.get("previewVia")),
        "external_caps":      sum(1 for v in eps.values() if v.get("externalCaps")),
        "dpsf_dpnf":          fam.get("DPSF", 0) + fam.get("DPNF", 0),
        # The chapter tells a client the registry holds NO readers, which is why reader names
        # need their own existence check. If that ever stops being true the advice changes.
        "readers_indexed":    sum(1 for k in eps if any(t in k for t in
                                  ("|UR_", "|URC_", "|URH_", "|URD_", ".UR_", ".URC_"))),
    }


# (file, the exact substring the prose must contain, key into figures(), how it is written)
CLAIMS = [
    ("03-cost-preview.md", "**421 of the 437 entrypoints have a preview", "preview_params_diff", 421),
    ("03-cost-preview.md", "Only 16 match",                          "preview_params_same", 16),
    ("03-cost-preview.md", "carries **442** of them",                "previews",            442),
    # PAIRED IS NOT THE ENTRYPOINT COUNT, and conflating them is how this line went stale once
    # already. CORRECTED 2026-10-10: the gap it described is CLOSED -- all 437 entrypoints now
    # have an `INFO_` preview, because PureV6 gave the four `CC_Vacate*` the previews they had
    # been missing. So paired == entrypoints TODAY, which is exactly the coincidence that made
    # the two look interchangeable the first time. They are still different questions; this row
    # checks `paired`, and it will diverge again the next time an entrypoint ships ahead of its
    # preview.
    ("03-cost-preview.md", "**all 437** client",                     "paired",              437),
    ("03-cost-preview.md", "**Twenty-one** entrypoints have a reader", "alias_paired",      21),
    ("02-signing-and-caps.md", "429 of the 437 client entrypoints",  "sponsored",           429),
    ("02-signing-and-caps.md", "Every one of those 429",             "sponsored",           429),
    ("02-signing-and-caps.md", "### The eight that are NOT sponsored", "unsponsored",        8),
    ("02-signing-and-caps.md", "**397 of 437** entrypoints",         "ownership_resolved",  397),
    ("02-signing-and-caps.md", "184 requirements always bind",       "ownership_always",    184),
    ("02-signing-and-caps.md", "394 are reached inside an `if`",     "ownership_cond",      394),
    ("02-signing-and-caps.md", "418 requirements name an account",   "own_via_parameter",   418),
    ("02-signing-and-caps.md", "160 name one the contract",          "own_via_reader",      160),
    ("02-signing-and-caps.md", "Four launchpad purchases require",   "external_caps",       4),
    ("05-reading-data.md", "It contains\n**zero reader functions**",     "readers_indexed",     0),
]


def main():
    if not os.path.isfile(REG):
        sys.exit("chapter figures: registry not found -- refusing to report on nothing.")
    fig = figures()
    bad = []
    for fname, phrase, key, claimed in CLAIMS:
        path = os.path.join(CH, fname)
        if not os.path.isfile(path):
            bad.append(f"{fname}: file missing")
            continue
        text = open(path, encoding="utf8").read()
        actual = fig[key]
        if actual != claimed:
            bad.append(f"{fname}: {key} is now {actual}, the table here still says {claimed} "
                       f"(prose: \"{phrase}\")")
        elif phrase not in text:
            bad.append(f"{fname}: the prose no longer contains \"{phrase}\" -- it was reworded "
                       f"or removed, so this row guards nothing")
    if bad:
        print("CHAPTER FIGURE DRIFT:")
        for b in bad:
            print("   " + b)
        print("\nThe chapter's own rule is that a figure is read, not remembered. Re-read it.")
        return 1
    print(f"chapter figures: clean -- {len(CLAIMS)} claims checked against the registry "
          f"({fig['entrypoints']} entrypoints, {fig['previews']} previews)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
