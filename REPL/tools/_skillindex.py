#!/usr/bin/env python3
"""Regenerate SKILL-INDEX.md -- every piece of Ouronet guidance, captured AUTOMATICALLY.

    python3 REPL/tools/_skillindex.py            report what would be written
    python3 REPL/tools/_skillindex.py --write    regenerate OuronetInformational/SKILL-INDEX.md
    python3 REPL/tools/_skillindex.py --check    offline; fatal inside _gate.py when stale

WHY THIS IS GENERATED AND NOT HAND-WRITTEN.  Exactly one file loads automatically in this repo:
CLAUDE.md.  Everything else is reached by following a reference from it.  A HAND-MAINTAINED list of
guidance is therefore a list that silently stops being complete the first time someone writes a doc
and forgets to add a line -- and the symptom is not an error, it is an agent that never learns the
rule.  Measured 2026-10-25: of 217 .md files under OuronetInformational/, **79 were reachable** and
among the unreachable were a 1,318-line document calling itself *"the standard for how Ouronet is
tested"* and a 366-line `INFO_` construction procedure.  Both were skipped in real work that same
week by an agent that had no way to know they existed.

So the catalogue is DERIVED from the tree, exactly as `TOOLS.md` is derived by `_toolindex.py` and
`MODULE-INDEX.md` by its generator.  Add a `.md` under a guidance directory, run `--write`, and it
is captured.  Forget to run it and `--check` fails the gate.  **That is the whole mechanism**: new
guidance cannot be forgotten, because being on disk is what puts it in the index.

WHAT IS EXCLUDED, AND WHY EACH EXCLUSION IS NOT A JUDGEMENT CALL.

  ARCHIVE_DIRS      dated captures and handovers -- `memories/`, `HANDOFFS/`, `kursan/`,
                    `agents/`.  CLAUDE.md names these DIRECTORIES deliberately; a dated memory is
                    a record of a conversation, not a rule to follow, and indexing 98 of them
                    would bury the 70-odd documents that ARE rules.  This is the one place the
                    tool draws a line, and it draws it by directory so it cannot drift per-file.
  GENERATED         artefacts written by other tools (`AUTH-SURFACE.md` by `_authsurface.py`,
                    `REPL_SUITE_STATS.md` by `_suite_stats.py`, `MODULE-INDEX.md` by its own
                    generator, `IGNIS-PRICE-SHEET.md` / `IGNIS-DETER-WORKSHEET.md` by
                    `_pricesync.py`).  Indexing a generated file as guidance invites editing it.
  SELF              this index.

SUPERSEDED DOCUMENTS ARE INDEXED, NOT HIDDEN.  A doc carrying a `SUPERSEDED` banner is listed with
a marker.  Dropping it would be worse than listing it: `LIVE-INTERFACE-VERSIONS.md` is a cached
"what is live" snapshot that already produced one wrong interface-bump map, and a reader who cannot
see it in the index may still find the file.  Better that the catalogue says what it is.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
INFO = os.path.join(ROOT, "OuronetInformational")
OUT = os.path.join(INFO, "SKILL-INDEX.md")

ARCHIVE_DIRS = {"memories", "HANDOFFS", "kursan", "agents", "tools"}
GENERATED = {
    "ARCHITECTURE/AUTH-SURFACE.md", "ARCHITECTURE/REPL_SUITE_STATS.md",
    "MODULE-INDEX.md", "IGNIS-PRICING/IGNIS-PRICE-SHEET.md",
    "IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md", "SKILL-INDEX.md",
}
# Directory -> the heading it appears under, and a line saying what the group is FOR. Unlisted
# directories fall through to OTHER, which is reported rather than silently dropped -- a new
# guidance directory is a thing a human should see once.
GROUPS = [
    ("",                     "Start here",                "the hub, the canon, the vocabulary"),
    ("pact",                 "Pact language mechanics",   "how to write the form correctly"),
    ("pact5",                "Pact 5 language layer",     "how Pact ITSELF behaves — source-verified"),
    ("ouronet",              "Ouronet architecture",      "prefixes, capability bands, Talos, the UR/W layers"),
    ("ouronet/conventions",  "Day-to-day conventions",    "the rules you apply while editing a module"),
    ("ouronet/architecture", "Inventories and specs",     "what exists, interface versioning, REPL layout"),
    ("modules",              "Per-module procedures",     "domain detail for a specific module family"),
    ("modules/aqp",          "AQP",                       "acquisition pools, scores, FVT, INFO previews"),
    ("modules/stage01",      "Stage 1",                   "DALOS, DPTF, ATS, SWP, CODEX"),
    ("modules/deploy",       "Deploy",                    "handoff, ClientInfo pairing"),
    ("ARCHITECTURE",         "Test architecture",         "the testing standard (stays here — _figuresync.py globs this dir)"),
    ("IGNIS-PRICING",        "Pricing",                   "the single authoritative cost reference"),
    ("skills",               "Legacy pointer",            "migration table only"),
]
SUPERSEDED = re.compile(r"SUPERSEDED|HISTORICAL RECORD", re.I)

CLAUDE_SKILLS = os.path.join(ROOT, ".claude", "skills")

# ROUTES -- topic -> the documents that answer it. These GENERATE .claude/skills/<name>/SKILL.md,
# the only mechanism that makes Claude Code surface guidance WITHOUT being asked: it reads each
# stub's YAML `description` at session start and offers the skill by relevance.
#
# GENERATED, NOT HAND-WRITTEN, for the same reason the index is: a hand-kept stub silently points
# at a moved file. Migrated 2026-10-25 from .cursor/skills/, which held 16 pointer stubs with no
# unique content -- Cursor is no longer used here, and two parallel pointer sets is two things to
# forget. Every target is verified to exist by --check, so a stub cannot outlive its document.
#
# The DESCRIPTION is the load-bearing field: it is matched against the task, so it must name the
# TRIGGERS ("when adding a C_", "when a suite reports BROKEN"), not summarise the content.
ROUTES = [
    ("ouronet-pact",
     "START HERE for any Ouronet Pact work - writing, reviewing or wiring a module, capability, "
     "reader or Talos entrypoint. Loads the hub with the load order, the StoicSyntax prefix "
     "discipline and the module map. Use before touching any .pact under 1_SOVEREIGN or 2_CITIZEN.",
     ["SKILL.md", "SKILL-INDEX.md", "MODULE-INDEX.md"]),
    ("ouronet-prefixes",
     "Use when choosing or auditing a function name or prefix (UC_, UR_, URC_, UEV_, UDC_, CAP_, "
     "A_, C_, X_), deciding if something is heavy (doubled AA_/CC_), or placing code in the right "
     "module section. The prefix IS the contract.",
     ["StoicSyntax-Prefixes.md", "StoicSyntax.md", "MODULE_ARCHITECTURE.md"]),
    ("ouronet-deploy-round",
     "Use when building, reviewing or sending a Deploy/PureVn round to StoaChain, or when asked "
     "'can I deploy this' or 'make a deploy pipeline'. Covers the parity model, schema backfill "
     "transactions and the post-deploy registry/npm sequence. Mandatory before creating a round.",
     ["HOW-DEPLOY-ROUNDS-WORK.md", "SPEC-round-simulator.md", "modules/deploy/handoff.md"]),
    ("ouronet-interface-cascade",
     "Use when changing a Pact interface, bumping a version suffix, editing a defschema an "
     "interface names, or when a module reports 'does not correctly implement X from Interface Y'. "
     "The cascade is TRANSITIVE and one grep does not find it.",
     ["ouronet/architecture/INTERFACE_VERSIONING.md", "HOW-DEPLOY-ROUNDS-WORK.md"]),
    ("ouronet-repl-tests",
     "Use when writing or fixing any .repl test - a begin-tx/commit-tx suite, an expect or "
     "expect-failure assertion, a fixture - or when a gate suite reports BROKEN. Z.repl is the "
     "fast path, not the gate.",
     ["ARCHITECTURE/REPL_TEST_ARCHITECTURE.md",
      "ouronet/conventions/repl-integration-test-layout.md",
      "ouronet/architecture/REPL_AND_TESTS.md"]),
    ("ouronet-info-preview",
     "Use when adding or changing a priced client entrypoint (C_, CC_, Cp_, CCp_) that needs an "
     "INFO_ cost preview, or when the registry gate reports an entrypoint with no cost preview.",
     ["modules/aqp/info-module-procedure.md", "modules/aqp/entrypoint-surface.md",
      "modules/deploy/info-one-clientinfo.md"]),
    ("ouronet-enforce-and-defcap",
     "Use when writing a defcap or combining validation checks: how to group 1, 2 or 3+ booleans "
     "into one enforce, the strict defcap body order, and why AUTHORISATION must precede "
     "validation (a shadowed gate is indistinguishable from an absent one).",
     ["pact/enforce.md", "pact/enforce-boolean-grouping.md", "pact/defcap-body-order.md"]),
    ("ouronet-reads-and-writes",
     "Use when adding a table read or write: where UR_ reads may live and how they are ordered "
     "against the schema, the W_ write layer, and which layer may touch a table at all.",
     ["ouronet/conventions/ur-layout.md", "ouronet/conventions/w-writes.md",
      "ouronet/conventions/ur-and-w-writes.md"]),
    ("ouronet-x-guards",
     "Use when writing a protected XI_/XE_/XB_ function: which guard it needs (SECURE, UEV_IMC), "
     "why it must not enforce or return an OutputCumulator, and when a shared write needs XB_ "
     "rather than XI_.",
     ["ouronet/conventions/x-function-guards.md",
      "ouronet/conventions/x-writes-no-cumulator.md",
      "ouronet/conventions/xb-imc-cross-module.md"]),
    ("ouronet-module-load-order",
     "Use when adding a module, a cross-module call or a modref binding, or when a deploy fails on "
     "load order. Cross-module calls use module references with :: - not module.function.",
     ["ouronet/conventions/module-load-order-and-pact-refs.md"]),
    ("ouronet-pact5-language",
     "Use when the question is how PACT ITSELF behaves rather than the Ouronet discipline: "
     "capability mechanics, defpact, database and type semantics, gas, the builtin catalogue, and "
     "Pact 5 footguns including natives the docs list that Pact 5 does NOT have.",
     ["pact5/BUILTINS.md", "pact5/SEMANTICS.md", "pact5/REFERENCE.md",
      "pact5/STORAGE-PATTERNS.md"]),
    ("ouronet-code-layout",
     "Use when laying out a defun or interface: parameter layout, function body order, let-binding "
     "layout, and the interface object-return rule (a function returning a module-defined schema "
     "must NOT be declared in the interface).",
     ["pact/defun-parameter-layout.md", "pact/function-body-order.md",
      "pact/let-binding-layout.md", "pact/interface-object-return-rule.md"]),
    ("ouronet-aqp",
     "Use when working in the AQP family (acquisition pools, scores, anchors, FVT farms/vaults/"
     "treasuries, RPS, vacate): score link fields XI vs XE, Talos stake phases, TFT vault IMC, and "
     "recipe capability validation.",
     ["modules/aqp/score-links.md", "modules/aqp/talos-orchestrator-events.md",
      "modules/aqp/tft-vault-imc.md", "modules/aqp/recipe-cap-validation.md"]),
    ("ouronet-pricing",
     "Use when adding or changing what an operation CHARGES - an IGNIS price key, a STOA "
     "collection, a cumulator leg - or when a price-sweep assertion fails. Pricing changes must be "
     "verified with the full gate, not Z.repl.",
     ["IGNIS-PRICING/IGNIS-PRICING.md"]),
]


def render_stub(name, desc, targets):
    rel = "../../../OuronetInformational"
    lines = [
        "---",
        f"name: {name}",
        f"description: {desc}",
        "---",
        "",
        f"# {name}",
        "",
        "> **GENERATED** by `REPL/tools/_skillindex.py` from its `ROUTES` table. Do not edit — change",
        "> the route there and run `--write`. `--check` verifies every target below still exists.",
        "",
        "**Read these. Canonical text lives in `OuronetInformational/` and is never duplicated here.**",
        "",
    ]
    for t in targets:
        lines.append(f"- [`{t}`]({rel}/{t})")
    lines += [
        "",
        f"Full catalogue: [`SKILL-INDEX.md`]({rel}/SKILL-INDEX.md) — every guidance document, "
        "generated from the tree.",
    ]
    return "\n".join(lines) + "\n"


def stub_targets_missing():
    bad = []
    for name, _, targets in ROUTES:
        for t in targets:
            if not os.path.exists(os.path.join(INFO, t)):
                bad.append((name, t))
    return bad

# A document may declare its own one-line purpose. PREFERRED over extraction, because the
# authority on what a document is for is the document -- not a curated map in this tool, which
# would be the hand-maintained list this whole generator exists to avoid.
PURPOSE_TAG = re.compile(r"<!--\s*purpose:\s*(.+?)\s*-->", re.I | re.S)
# Extractions that are probably NOT a purpose. `_toolindex.py` shipped for weeks printing an empty
# capture as a confident description for thirteen tools; the lesson is that a heuristic which can
# produce a wrong answer must be able to SAY it did. These are reported, never silently kept.
WEAK = (
    re.compile(r"^\d+[.)]"),                      # a numbered list item
    re.compile(r"^Last updated", re.I),
    re.compile(r":$"),                            # a lead-in to a list or table
    re.compile(r"^\(def"),                        # a code line
    re.compile(r"^(?:same|reading|it is tied|these are|every function below)\b", re.I),
)


def purpose(path):
    """One line saying what this document is for: the first real prose after the H1.

    Skips blockquote banners (`>`), tables, code fences and headings. Falls back to the H1 text,
    which is never empty -- the `_toolindex.py` lesson: an extraction that can come back blank
    will print a confident lie for every file written in the style it does not handle.
    """
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            lines = fh.read().splitlines()
    except OSError:
        return "(unreadable)"
    tag = PURPOSE_TAG.search("\n".join(lines[:40]))
    if tag:
        return " ".join(tag.group(1).split())
    h1 = ""
    for ln in lines:
        if ln.startswith("# ") and not h1:
            h1 = ln[2:].strip()
            continue
        if not h1:
            continue
        t = ln.strip()
        if (not t or t.startswith((">", "|", "#", "```", "---", "*", "-", "1.", "<"))):
            continue
        t = re.sub(r"[*`_]", "", t)
        return (t[:150].rstrip() + "…") if len(t) > 150 else t
    return re.sub(r"[*`_]", "", h1) or "(no description)"


def weak_descriptions(docs):
    """Documents whose description was GUESSED and looks wrong. Fix by adding to the document:
        <!-- purpose: one line saying what this is for -->
    """
    out = []
    for d, items in docs.items():
        for rel, desc in items:
            body = ""
            try:
                with open(os.path.join(INFO, rel), encoding="utf-8", errors="replace") as fh:
                    body = fh.read(4000)
            except OSError:
                pass
            if PURPOSE_TAG.search(body):
                continue
            if any(w.search(desc) for w in WEAK):
                out.append((rel, desc))
    return sorted(out)


def collect():
    docs = {}
    for r, ds, fs in os.walk(INFO):
        rel_dir = os.path.relpath(r, INFO).replace("\\", "/")
        rel_dir = "" if rel_dir == "." else rel_dir
        top = rel_dir.split("/")[0] if rel_dir else ""
        if top in ARCHIVE_DIRS:
            ds[:] = []
            continue
        for f in sorted(fs):
            if not f.endswith(".md"):
                continue
            rel = f"{rel_dir}/{f}" if rel_dir else f
            if rel in GENERATED:
                continue
            docs.setdefault(rel_dir, []).append((rel, purpose(os.path.join(r, f))))
    return docs


def render(docs):
    known = {d for d, _, _ in GROUPS}
    total = sum(len(v) for v in docs.values())
    out = [
        "# SKILL-INDEX — every piece of Ouronet guidance",
        "",
        "> **GENERATED** by `REPL/tools/_skillindex.py`. Do not edit — add the document, then run",
        "> `python3 REPL/tools/_skillindex.py --write`. `--check` is fatal inside `_gate.py`, so a",
        "> new guidance file cannot stay uncatalogued.",
        ">",
        "> **Why this is generated.** Exactly one file loads automatically in this repo: `CLAUDE.md`.",
        "> A hand-maintained list of what to read stops being complete the first time someone forgets",
        "> a line, and the symptom is not an error — it is an agent that never learns the rule. On",
        "> 2026-10-25 only 79 of 217 files here were reachable from `CLAUDE.md`, and the unreachable",
        "> set included the canonical testing standard and the `INFO_` construction procedure.",
        ">",
        "> Dated captures (`memories/`, `HANDOFFS/`, `kursan/`, `agents/`) are **records, not rules**,",
        "> and are excluded by directory. Generated artefacts are excluded so nobody edits them.",
        "",
        f"**{total} guidance documents.** Read [`SKILL.md`](SKILL.md) first — it gives the ORDER.",
        "This page gives the COVERAGE.",
        "",
    ]
    for d, title, blurb in GROUPS:
        if d not in docs:
            continue
        out += [f"## {title}", "", f"*{blurb}*", "",
                "| document | what it is for |", "|---|---|"]
        for rel, desc in sorted(docs[d]):
            name = os.path.basename(rel)
            sup = ""
            try:
                with open(os.path.join(INFO, rel), encoding="utf-8", errors="replace") as fh:
                    if SUPERSEDED.search(fh.read(1800)):
                        sup = " ⛔ **superseded**"
            except OSError:
                pass
            out.append(f"| [`{name}`]({rel}){sup} | {desc} |")
        out.append("")
    extra = sorted(set(docs) - known)
    if extra:
        out += ["## Uncategorised", "",
                "*New directory not in `_skillindex.py`'s `GROUPS` — add it there so the heading",
                "says what the group is for.*", "",
                "| document | what it is for |", "|---|---|"]
        for d in extra:
            for rel, desc in sorted(docs[d]):
                out.append(f"| [`{rel}`]({rel}) | {desc} |")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def main():
    docs = collect()
    body = render(docs)
    total = sum(len(v) for v in docs.values())
    missing = stub_targets_missing()
    stubs = {n: render_stub(n, d, t) for n, d, t in ROUTES}

    if "--write" in sys.argv:
        if missing:
            for n, t in missing:
                print(f"   route {n} -> MISSING {t}")
            print("skill index: refusing to write stubs that point at missing documents.")
            return 1
        with open(OUT, "w", encoding="utf-8") as fh:
            fh.write(body)
        for name, text in stubs.items():
            d = os.path.join(CLAUDE_SKILLS, name)
            os.makedirs(d, exist_ok=True)
            with open(os.path.join(d, "SKILL.md"), "w", encoding="utf-8") as fh:
                fh.write(text)
        # a route REMOVED from the table must lose its directory, or it outlives its decision
        if os.path.isdir(CLAUDE_SKILLS):
            for ent in sorted(os.listdir(CLAUDE_SKILLS)):
                if ent.startswith("ouronet-") and ent not in stubs:
                    import shutil
                    shutil.rmtree(os.path.join(CLAUDE_SKILLS, ent))
                    print(f"   removed stale route stub: {ent}")
        print(f"wrote OuronetInformational/SKILL-INDEX.md  ({total} guidance documents)")
        print(f"wrote .claude/skills/  ({len(stubs)} route stub(s))")
        return 0

    if "--check" in sys.argv:
        bad = False
        if missing:
            bad = True
            print("skill index: a .claude/skills route points at a document that does not exist:")
            for n, t in missing:
                print(f"   {n} -> {t}")
        cur = ""
        if os.path.exists(OUT):
            with open(OUT, encoding="utf-8", errors="replace") as fh:
                cur = fh.read()
        if cur != body:
            bad = True
            print("skill index: SKILL-INDEX.md is STALE against OuronetInformational/.")
            print(f"   the tree has {total} guidance document(s).")
        for name, text in stubs.items():
            f = os.path.join(CLAUDE_SKILLS, name, "SKILL.md")
            on_disk = ""
            if os.path.exists(f):
                with open(f, encoding="utf-8", errors="replace") as fh:
                    on_disk = fh.read()
            if on_disk != text:
                bad = True
                print(f"skill index: .claude/skills/{name}/SKILL.md is STALE or missing.")
        extra = []
        if os.path.isdir(CLAUDE_SKILLS):
            extra = [e for e in sorted(os.listdir(CLAUDE_SKILLS))
                     if e.startswith("ouronet-") and e not in stubs]
        for e in extra:
            bad = True
            print(f"skill index: .claude/skills/{e} has no ROUTES entry -- stale stub.")
        if bad:
            print("   Regenerate with: python3 REPL/tools/_skillindex.py --write")
            return 1
        print(f"skill index: clean -- {total} guidance document(s) catalogued, "
              f"{len(stubs)} route stub(s) in sync")
        return 0
    print(f"skill index: {total} guidance document(s) across {len(docs)} directory(s)")
    for d in sorted(docs):
        print(f"   {d or '.'}/  ({len(docs[d])})")
    weak = weak_descriptions(docs)
    if weak:
        print(f"\n{len(weak)} description(s) were GUESSED and look wrong. Add to each document:")
        print("    <!-- purpose: one line saying what this is for -->")
        for rel, desc in weak:
            print(f"   {rel}\n       got: {desc[:90]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
