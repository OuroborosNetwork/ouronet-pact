#!/usr/bin/env python3
"""Index the LOCAL Pact 5 source clone into the repo, so its reference is reachable offline.

    python3 REPL/tools/_pactsource.py            report what is in the clone
    python3 REPL/tools/_pactsource.py --write    regenerate OuronetInformational/pact5/BUILTINS.md
    python3 REPL/tools/_pactsource.py --check    warn if stale; NEVER fatal (see below)

THE GAP THIS CLOSES.  `~/ClaudeWS/_upstream/pact-5` holds the Pact 5 source: the builtin registry
(`Builtin.hs`), **175 markdown reference pages** under `docs/builtins/` -- the same pages served at
`docs.kadena.io/reference` -- and **368 executable `.repl` test files** under `pact-tests/`, which
are the only description of a builtin that cannot be wrong, because they run.

Measured 2026-10-25: **exactly ONE file in the whole Ouronet repo mentioned that clone**, and only
as a parenthetical aside in `pact5/README.md`.  So an agent had 250 condensed lines in `pact5/` and
no way to learn that 175 full reference pages sat one directory away.  Same failure as the orphaned
skills -- the content was present and unreachable, which is indistinguishable from absent.

NO WEB SCRAPER IS NEEDED, and that is the point worth recording.  The obvious instinct is to crawl
`docs.kadena.io/reference` into markdown.  Those pages are ALREADY markdown, already local, and --
decisively -- **versioned with the source they describe**, so they cannot drift from the compiler
the way a scrape taken on one day drifts from a release made the next.  Scraping would have
produced a worse artefact and a recurring job.

WHY THE INDEX IS SELF-CONTAINED.  The clone is OUTSIDE this repository and may legitimately be
absent -- a fresh checkout, another machine, CI.  So the generated `BUILTINS.md` carries the
signature and purpose of every builtin INLINE, and cites the clone path only for the full page.
It is useful with the clone missing; it is merely better with it present.

WHY `--check` IS A WARNING AND NEVER FATAL.  The gate must run offline and must not depend on a
sibling directory existing -- the same rule `_pkgsync.py` follows for the npm package it guards.
A missing clone is REPORTED and skipped.  A PRESENT clone that disagrees with the committed index
is also reported, because that means Pact itself moved.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "OuronetInformational", "pact5", "BUILTINS.md")
# Candidate clone locations, in order. Keeping this a LIST rather than one hard-coded path is
# deliberate: _toolpaths.py flags an absolute literal that does not resolve, and a path that is
# right only on one machine is the defect that tool exists to catch.
CANDIDATES = [
    os.path.join(os.path.expanduser("~"), "ClaudeWS", "_upstream", "pact-5"),
    os.path.join(os.path.dirname(os.path.dirname(ROOT)), "_upstream", "pact-5"),
]


def clone():
    for c in CANDIDATES:
        if os.path.isdir(os.path.join(c, "docs", "builtins")):
            return c
    return None


def parse(path):
    """name, signature, purpose -- from a docs/builtins page."""
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            text = fh.read()
    except OSError:
        return None
    name = os.path.splitext(os.path.basename(path))[0]
    sig = ""
    m = re.search(r"```pact\s*\n(.+?)\n```", text, re.S)
    if m:
        sig = " ".join(m.group(1).strip().splitlines()[0].split())
    purpose = ""
    for ln in text.splitlines():
        t = ln.strip()
        if not t or t.startswith(("#", "|", "```", ">", "-")):
            continue
        purpose = re.sub(r"[*`]", "", t)
        break
    if len(purpose) > 160:
        purpose = purpose[:160].rstrip() + "…"
    return name, sig, purpose


def collect(c):
    cats = {}
    base = os.path.join(c, "docs", "builtins")
    for r, _, fs in os.walk(base):
        cat = os.path.relpath(r, base).replace("\\", "/")
        if cat == ".":
            continue
        for f in sorted(fs):
            if not f.endswith(".md"):
                continue
            got = parse(os.path.join(r, f))
            if got:
                cats.setdefault(cat, []).append(got)
    return cats


def registry_names(c):
    """Builtin constructors declared in the source registry, for a coverage cross-check."""
    f = os.path.join(c, "pact", "Pact", "Core", "Builtin.hs")
    if not os.path.exists(f):
        return set()
    with open(f, encoding="utf-8", errors="replace") as fh:
        src = fh.read()
    # The registry is a Haskell case expression mapping constructors to their Pact names:
    #     CoreNegate -> "negate"
    # Matching bare quoted lowercase strings file-wide instead returns 0, because the pretty-printer
    # above it also quotes operator names -- the first cut of this did exactly that and reported
    # "0 registered names" while 276 sat in the file. Anchor on the constructor arrow.
    # TWO registries, two constructor prefixes. On-chain natives are `CoreXxx -> "name"`; REPL-only
    # natives are `RXxx -> "name"` (NOT `ReplXxx` -- assuming that returned 0 for all 40 of them).
    # The arity table alongside uses the same arrow with an INTEGER, so requiring a quoted string
    # separates them without a second pass.
    return set(re.findall(r'^\s*(?:Core|R)[A-Za-z0-9_\']+\s*->\s*"([^"]+)"', src, re.M))


def render(cats, c, regnames):
    docd = {n for v in cats.values() for n, _, _ in v}
    total = len(docd)
    # OPERATORS ARE DOCUMENTED UNDER DESCRIPTIVE NAMES, not under their symbol: `+` is `add.md`,
    # `&` is `bitwise-and.md`. Listing them as "undocumented" would be a confident wrong answer --
    # 14 of the 28 the first cut reported were this. Symbols are excluded and said to be excluded.
    symbols = {n for n in regnames if not re.match(r"^[a-z]", n)}
    undocumented = sorted(regnames - docd - symbols) if regnames else []
    rel = os.path.relpath(c, os.path.dirname(os.path.dirname(ROOT)))
    out = [
        "# Pact 5 builtins — indexed from the SOURCE clone",
        "",
        "<!-- purpose: Every Pact 5 builtin with its signature and purpose, generated from the local"
        " pact-5 source clone — the same pages as docs.kadena.io/reference, versioned with the compiler. -->",
        "",
        "> **GENERATED** by `REPL/tools/_pactsource.py`. Do not edit.",
        ">",
        f"> Source: the Pact 5 clone at `{rel}` — `docs/builtins/` ({total} reference pages, the same",
        "> content served at `docs.kadena.io/reference`) cross-checked against `pact/Pact/Core/Builtin.hs`",
        "> (the registry the compiler actually uses). **Where the docs and the source disagree, the",
        "> source wins** — the published docs still describe Pact-4 features Pact 5 dropped.",
        ">",
        "> **This page is self-contained**: signature and purpose are inline, so it is useful even",
        "> where the clone is absent. For the full page on any builtin — arguments, return value,",
        f"> worked examples — open `{rel}/docs/builtins/<Category>/<name>.md`.",
        ">",
        "> **The executable truth is `pact-tests/`** (368 `.repl` files in the clone). A test that runs",
        "> cannot be wrong about behaviour the way prose can. Read one when a builtin's edge case",
        "> matters — especially around `with-default-read` defaults, `select` cost, and `try` limits.",
        "",
    ]
    if undocumented:
        out += [
            f"## ⚠ {len(undocumented)} registered builtin(s) with NO reference page",
            "",
            "Named in `Builtin.hs` — so **the compiler accepts them** — but absent from",
            "`docs/builtins/`. Treat them as real and undocumented; confirm behaviour from",
            "`pact-tests/`, never from prose. This list is derived, and it independently reproduces",
            "the hand-written *\"source-only natives the docs omitted\"* note in `REFERENCE.md` —",
            "two methods agreeing is why it is worth printing.",
            "",
            "```", "  " + "  ".join(undocumented), "```",
            "",
            "*Operator symbols (`+`, `&`, `~`, …) are NOT listed here: they are documented under",
            "descriptive names (`add.md`, `bitwise-and.md`), so reporting them would be noise.*",
            "",
        ]
    for cat in sorted(cats):
        rows = sorted(cats[cat])
        out += [f"## {cat}  ({len(rows)})", "",
                "| builtin | signature | purpose |", "|---|---|---|"]
        for name, sig, purpose in rows:
            sig = sig.replace("|", "\\|") or "—"
            purpose = purpose.replace("|", "\\|")
            out.append(f"| `{name}` | `{sig}` | {purpose} |")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def main():
    c = clone()
    if not c:
        print("pact source: clone not found -- skipped (checked: "
              + ", ".join(CANDIDATES) + ")")
        print("   The committed OuronetInformational/pact5/BUILTINS.md stays authoritative.")
        return 0
    cats = collect(c)
    regnames = registry_names(c)
    body = render(cats, c, regnames)
    total = sum(len(v) for v in cats.values())
    if "--write" in sys.argv:
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        with open(OUT, "w", encoding="utf-8") as fh:
            fh.write(body)
        print(f"wrote OuronetInformational/pact5/BUILTINS.md  "
              f"({total} builtins across {len(cats)} categories)")
        return 0
    if "--check" in sys.argv:
        cur = ""
        if os.path.exists(OUT):
            with open(OUT, encoding="utf-8", errors="replace") as fh:
                cur = fh.read()
        if cur != body:
            print("pact source: BUILTINS.md differs from the local clone "
                  "(Pact moved, or the index was never regenerated).")
            print("   Regenerate with: python3 REPL/tools/_pactsource.py --write")
            print("   NOT fatal -- the gate must not depend on a sibling checkout.")
            return 0
        print(f"pact source: clean -- {total} builtins indexed from the clone")
        return 0
    print(f"pact source: clone at {c}")
    print(f"   docs/builtins : {total} reference page(s) across {len(cats)} categories")
    print(f"   Builtin.hs    : {len(regnames)} registered name(s)")
    tests = sum(1 for r, _, fs in os.walk(os.path.join(c, "pact-tests"))
                for f in fs if f.endswith(".repl"))
    print(f"   pact-tests    : {tests} executable .repl file(s)")
    undoc = sorted(regnames - {n for v in cats.values() for n, _, _ in v})
    if undoc:
        print(f"   UNDOCUMENTED  : {len(undoc)} registered builtin(s) have no reference page")
    return 0


if __name__ == "__main__":
    sys.exit(main())
