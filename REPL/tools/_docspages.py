#!/usr/bin/env python3
"""_docspages.py -- emit one reference page per deployed module, in deploy order.

    python3 REPL/tools/_docspages.py --write|--check|--selftest [--only NAME]

79 pages is the bulk of OuronetDocumentation/. Hand-writing the ENUMERATION for each --
every schema, table, capability, function, Talos entrypoint and price -- is both the
largest part of the work and the part that rots first, which is the exact combination
MAINTAINING.md says must be generated.

So each page is TWO THINGS, and the split is the whole design:

  GENERATED   everything derivable: the on-chain block, the data it owns, the
              capabilities, the functions grouped by what their prefix promises, the
              client entrypoints with their prices, and the live-vs-repo comparison.
  PROSE       what it is FOR, how and why it works, and the traps. A generator cannot
              write these and must not pretend to.

The generated regions sit between `<!-- @generated:module-page:NAME -->` markers and are
rewritten in place. Everything outside them is never touched, so prose survives every
regeneration. That is what makes a signature sweep cost one command instead of a week --
the measured failure of the June whitepaper, 55 of 58 signatures wrong after one refactor
(MAINTAINING.md section 0).

A page that has not been given prose yet still says so, visibly, rather than reading as
finished. An empty section that looks complete is worse than an obvious gap.
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _docsblocks as B

PAGES = os.path.join(ROOT, "OuronetDocumentation", "30-modules")
REGISTRY = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
BEGIN = "<!-- @generated:module-page:%s -->"
END = "<!-- @end:module-page:%s -->"

# Prefix -> what the name PROMISES. Order matters: longest/most specific first, or a
# cost reader files as a plain read and the grouping silently lies.
FAMILIES = [
    ("URCi_", "Cost readers", "price an operation; the exec path and the preview both call these"),
    ("URHC_", "Heavy derived reads", "scan and derive -- OFF the execution path"),
    ("URH_",  "Heavy reads", "scan a table -- OFF the execution path, cost grows with data"),
    ("URC_",  "Derived reads", "read and compute; no enforce"),
    ("UR_",   "Point reads", "one row or field by key"),
    ("UEV_",  "Validators", "read and enforce; failure aborts"),
    ("UDC_",  "Constructors", "build objects"),
    ("UCv_",  "Pure compute (guarded)", "compute with a guard intrinsic to the computation"),
    ("UC_",   "Pure compute", "arguments only; no reads, no enforce"),
    ("CAP_",  "Ownership checks", "account-ownership enforcement"),
    ("CCp_",  "Heavy recipes", "multi-transaction, reaches a heavy read"),
    ("Cp_",   "Recipes", "multi-transaction, no heavy read"),
    ("CC_",   "Client entry (heavy)", "reaches a heavy read somewhere in its tree"),
    ("C_",    "Client entry", "builds the bill; reachable only through Talos"),
    ("AA_",   "Admin (heavy)", "admin mutation reaching a heavy read"),
    ("A_",    "Admin", "admin-key mutations"),
    ("XE_",   "External entry", "callable by other modules only"),
    ("XB_",   "Internal + external", "callable both ways"),
    ("XI_",   "Internal writes", "this module only; writes under a capability"),
    ("P|",    "Policy", "inter-module authorisation"),
    ("GOV|",  "Governance", "keysets and protocol constants"),
    ("INFO_", "Previews", "operation previews for clients"),
]


def registry_entrypoints():
    """module -> [(entrypoint, preview)] from the generated consumer registry."""
    if not os.path.exists(REGISTRY):
        return {}
    reg = json.load(open(REGISTRY, encoding="utf-8"))
    out = {}
    for key, v in reg.get("entrypoints", {}).items():
        src = v.get("source") or ""
        path = v.get("modulePath") or ""
        mod = os.path.basename(path).split("_", 1)[-1].replace(".pact", "") if path else ""
        out.setdefault(mod, []).append((key, v.get("preview")))
    return out


def group_functions(fns):
    """Bucket by prefix. A name matches the FIRST family whose prefix it carries,
    which is why FAMILIES is ordered specific-first."""
    buckets, seen = [], set()
    for pref, title, gloss in FAMILIES:
        hit = sorted(f for f in fns
                     if f not in seen and (f.startswith(pref) or ("|" + pref) in f))
        if hit:
            seen.update(hit)
            buckets.append((title, gloss, hit))
    rest = sorted(f for f in fns if f not in seen)
    if rest:
        buckets.append(("Unclassified", "no known prefix -- worth asking why", rest))
    return buckets


def render_page_body(name, live, eps):
    m = live[name]
    shapes = m.get("shapes", {})
    out = [B.render(name), ""]

    caps = sorted(shapes.get("capabilities", []))
    if caps:
        out += [f"**Capabilities** -- {len(caps)}", "",
                ", ".join(f"`{c}`" for c in caps), ""]

    fns = shapes.get("functions", [])
    if fns:
        out += [f"**Functions** -- {len(fns)}, grouped by what the prefix promises", ""]
        for title, gloss, hit in group_functions(fns):
            out += [f"*{title}* ({len(hit)}) — {gloss}", "",
                    ", ".join(f"`{f}`" for f in hit), ""]

    mine = eps.get(name, [])
    if mine:
        out += [f"**Client entrypoints** -- {len(mine)}", "",
                "| entrypoint | preview |", "|---|---|"]
        for k, p in sorted(mine):
            out.append(f"| `{k}` | `{p}` |" if p else f"| `{k}` | — |")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def page_path(idx, name):
    return os.path.join(PAGES, f"{idx:02d}-{name.lower().replace('|', '-')}.md")


def build(write=False, only=None):
    live = B.live_modules()
    eps = registry_entrypoints()
    order = [n for n in live if live[n].get("deployed")]
    order.sort(key=lambda n: (live[n].get("repoPath") or "zzz", n))
    changed, made = [], 0
    for i, name in enumerate(order, 1):
        if only and name != only:
            continue
        p = page_path(i, name)
        body = render_page_body(name, live, eps)
        block = f"{BEGIN % name}\n{body}{END % name}\n"
        if os.path.exists(p):
            cur = open(p, encoding="utf-8").read()
            new = re.sub(re.escape(BEGIN % name) + r".*?" + re.escape(END % name) + r"\n",
                         block, cur, flags=re.S)
            if new == cur:
                continue
        else:
            new = (f"# {name}\n\n"
                   f"> **PROSE NOT YET WRITTEN.** This page currently carries only its generated\n"
                   f"> enumeration. What this module is *for*, how it works and what has bitten\n"
                   f"> people are written by hand and are missing.\n\n"
                   f"## What it is for\n\n_To be written._\n\n"
                   f"## Where it sits\n\n_To be written._\n\n"
                   f"## What it owns, and what it exposes\n\n{block}\n"
                   f"## Traps\n\n_To be written._\n")
            made += 1
        changed.append(os.path.relpath(p, ROOT))
        if write:
            os.makedirs(PAGES, exist_ok=True)
            open(p, "w", encoding="utf-8").write(new)
    return order, changed, made


def selftest():
    live = B.live_modules()
    ok = True
    fns = ["URCi_Price", "UR_Thing", "URC_Derived", "C_Do", "CC_Heavy", "XI_Write", "Weird"]
    got = {t: h for t, _g, h in group_functions(fns)}
    # The ordering trap this tool exists to avoid.
    if "URCi_Price" not in got.get("Cost readers", []):
        print("  selftest: URCi_ mis-filed -- FAMILIES order regressed"); ok = False
    if "URC_Derived" not in got.get("Derived reads", []):
        print("  selftest: URC_ mis-filed"); ok = False
    if "CC_Heavy" not in got.get("Client entry (heavy)", []):
        print("  selftest: CC_ mis-filed as C_"); ok = False
    if "Weird" not in got.get("Unclassified", []):
        print("  selftest: unknown prefix silently dropped"); ok = False
    # Every function must land in exactly one bucket, or the page under-reports.
    total = sum(len(h) for _t, _g, h in group_functions(live["DPTF"]["shapes"]["functions"]))
    if total != len(live["DPTF"]["shapes"]["functions"]):
        print(f"  selftest: grouping lost functions ({total} of "
              f"{len(live['DPTF']['shapes']['functions'])})"); ok = False
    print("  selftest OK" if ok else "  selftest FAILED")
    return ok


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    order, changed, made = build("--write" in sys.argv, only)
    if "--write" in sys.argv:
        print(f"module pages: {len(order)} deployed module(s); "
              f"{len(changed)} written ({made} new)")
    elif changed:
        print(f"module pages: {len(changed)} STALE or missing of {len(order)}")
        for c in changed[:10]:
            print("  " + c)
        if len(changed) > 10:
            print(f"  ... and {len(changed)-10} more")
        sys.exit(1 if "--check" in sys.argv else 0)
    else:
        print(f"module pages: clean -- all {len(order)} generated regions current")
