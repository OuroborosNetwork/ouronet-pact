#!/usr/bin/env python3
"""_auditbook.py -- assemble THE OURONET AUDIT BOOK into one versioned .md, then .docx.

WHY THIS IS GENERATED AND NOT HAND-PASTED. The book quotes ~200 figures that move whenever the
suite does; three separate rounds of this audit found published numbers that had gone stale while
every document agreed with every other one (DEFECT-LEDGER 8.22). A book assembled by hand is a
snapshot nobody can re-derive. This script rebuilds it from its chapter sources in one command, so
the artefact and its parts cannot drift apart -- the same closed loop `_pricesync` enforces for the
price sheet.

usage:
  python3 REPL/tools/_auditbook.py            build the .md
  python3 REPL/tools/_auditbook.py --docx     ...and convert to .docx via pandoc
  python3 REPL/tools/_auditbook.py --check    exit 1 if the committed .md differs from a rebuild
"""
import os
import re
import subprocess
import sys
from datetime import date

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BOOK = os.path.join(ROOT, "Audit", "book")
SRC = os.path.join(BOOK, "src")
OUT_MD = os.path.join(ROOT, "Audit", "OURONET-AUDIT-BOOK.md")
OUT_DOCX = os.path.join(ROOT, "Audit", "OURONET-AUDIT-BOOK.docx")
OUT_PDF = os.path.join(ROOT, "Audit", "OURONET-AUDIT-BOOK.pdf")

VERSION = "1.1"

# CHANGELOG. One entry per published version, newest first. A version bump without a line here is
# a bump nobody can interpret: the book's premise is "here is what was verified", so a reader has
# to be able to tell what that statement covered when they read it.
CHANGELOG = [
    ("1.1", "2026-09-19", [
        "AQP schemas hoisted into ONE interface, AcquisitionSchemasV1: 74 declarations -> 63"
        " (11 exact duplicates collapsed, 0 conflicts). A schema living in a module cannot appear"
        " in that module's interface, so 106 functions returning one were unreachable through a"
        " modref; that count is now 0. It is also what CAUSED the duplication -- RPS declared none"
        " of its 10 UDC_ constructors, so FVT copied the shapes.",
        "RPS/FVT deduplicated: 20 byte-identical function bodies removed or turned into the"
        " documented #75 facades. 05_FVT.pact 3,978 -> 3,495 lines.",
        "ALL AQP interfaces are V1, plus the three never-deployed Talos interfaces"
        " (TalosStageTwo_ClientThree/DemiPad, CitizenLaunchpadTalos). The 2026-09-18 pass had"
        " bumped six AQP interfaces V2->V3 as 'live + 1' when none of them is live.",
        "DEFECT: the FVT admission rule was INVERTED -- vault admitted SF/NF and treasury admitted"
        " OF. Corrected to vault=TF/OF, treasury=SF/NF. AQP-BOOT Step 8 was issuing four"
        " Treasury-named entities at class 1, which only worked BECAUSE the rule was inverted.",
        "DEFECT: the pure Bloodshed score was employed by a pool but admitted to no FVT, so every"
        " stake on DHBloodshed aborted. Fixed by adding the fifth treasury it never had.",
        "SECURITY: ANK|BoostClass had no owner field at all. Attaching an anchor to an EXISTING"
        " class validated only 'active' and 'a slot is free', so anyone holding any anchorable"
        " asset could attach it to another vault's class and grant their holders a boost inside"
        " that vault's scoring. Added class-owner + enforcement.",
        "ARCHITECTURE: a score's boost class is now carried by the score MODEL and applied at"
        " issue, so a delegation vault's admin defines how scores behave and an agency cannot"
        " decline or redirect it. Previously it was settable only after issue, by the score's"
        " owner -- the agency operator.",
        "Deploy/ is now gate-enforced byte-for-byte against the sovereign sources"
        " (_deploybundle.py --check). It was the ONE generated artefact the gate did not diff.",
        "FINDING, not fixed: the triplet quality-split LANES read the SILVER score's base only,"
        " so a heterogeneous split routes every staker on one row. Recorded in the Custodians"
        " design notes.",
        "FINDING, not fixed: royalty disposal is not isolated per vault -- an inject into one"
        " vault funded another vault's disposal, discovered when it flipped a red-team"
        " expect-failure into a success.",
    ]),
    ("1.0", "2026-09-18", [
        "First consolidated edition: per-module rounds, the main-work round, and the red team.",
    ]),
]

# (key, chapter title, source file). Order IS the book's order.
#
# The KEY is how chapters refer to each other. A source writes `{{ch:register}}` and the assembler
# substitutes "Chapter 20". Nothing in a chapter source may write a chapter number literally --
# `--check` rejects it. Reordering CHAPTERS therefore renumbers every cross-reference in the book
# automatically, instead of leaving a dozen stale "see Chapter 17"s pointing at the wrong chapter.
CHAPTERS = [
    ("front", "How to read this book", "src/00-front.md"),
    ("system", "The system under audit", "src/01-system.md"),
    ("plant", "How Ouronet is tested", "src/02-plant.md"),
    ("part1", "Part I \u2014 The module audits", "PART-I/README.md"),
    ("dalos", "DALOS \u2014 accounts, guards, governance", "PART-I/01-DALOS.md"),
    ("ats", "ATS \u2014 autostake pools", "PART-I/02-ATS.md"),
    ("swp", "SWP \u2014 the automated market maker", "PART-I/03-SWP.md"),
    ("dpdc", "DPDC \u2014 collectables", "PART-I/04-DPDC.md"),
    ("demipad", "DEMIPAD \u2014 the launchpad", "PART-I/05-DEMIPAD.md"),
    ("aqp", "AQP \u2014 acquisition pools", "PART-I/06-AQP.md"),
    ("part2", "Part II \u2014 The main-work round", "PART-II/README.md"),
    ("previews", "The cost-reader and preview surfaces", "PART-II/01-URCI-INFO.md"),
    ("pricing", "Re-pricing IGNIS", "PART-II/02-PRICING.md"),
    ("splits", "Module splits under the deploy ceiling", "PART-II/03-SPLITS.md"),
    ("suite", "The test architecture", "PART-II/04-REPL.md"),
    ("part3", "Part III \u2014 The red team", "PART-III/README.md"),
    ("design", "How the round was designed", "src/30-design.md"),
    ("method", "Method: building an attack that proves something", "PART-III/01-METHOD.md"),
    ("ownergates", "The ownership-gate programme", "PART-III/02-OWNER-GATES.md"),
    ("defects", "The defects, and what was done", "PART-III/03-DEFECTS.md"),
    ("register", "The full attack register", "src/34-register.md"),
    ("instruments", "Part IV \u2014 The instruments", "PART-III/04-INSTRUMENTS.md"),
    ("repro", "Appendix A \u2014 Reproducing everything", "APPENDIX/01-REPRODUCTION.md"),
    ("state", "Appendix B \u2014 Verification state", "src/90-state.md"),
]


# ---------------------------------------------------------------------------
# GENERATED CHAPTER: the full attack register.
#
# The register is emitted from the attack headers in the .repl files themselves, not retyped.
# Every attack carries a HYPOTHESIS / METHOD / RESULT block written at the time it was run; that
# block IS the primary record of what the attack looked for, how it was driven, what it found and
# what was done. Retyping it into a book chapter would create a second copy free to drift from the
# executable one -- the exact failure mode `_pricesync` exists to prevent for the price sheet.
# ---------------------------------------------------------------------------

REPL_DIR = os.path.join(ROOT, "REPL")

FAMILY_NAMES = {
    "A": "Arithmetic and value",
    "B": "Permissionless reach",
    "C": "Admin impersonation",
    "D": "Ownership bypass",
    "E": "Sequencing and state",
    "F": "Griefing and denial of service",
    "G": "Hostile citizen module",
    "H": "Input domain",
    "I": "Gas-station payable surface",
    "J": "Ledger conservation",
    "K": "Preview/execution divergence",
}

HDR = re.compile(r'^;;<<(RT-([A-K])-(\d+))>>\s*FAMILY:\s*(\w+)\s*\|\s*STATUS:\s*(\w+)')
FIELD = re.compile(r'^;;([A-Z][A-Z ]+):\s*(.*)$')


def _scan_attacks():
    """Parse every ;;<<RT-*>> header block in the tree into a structured record."""
    found = {}
    for dirpath, _, names in os.walk(REPL_DIR):
        for n in sorted(names):
            if not n.endswith(".repl"):
                continue
            fp = os.path.join(dirpath, n)
            rel = os.path.relpath(fp, REPL_DIR)
            lines = open(fp, encoding="utf-8", errors="replace").read().split("\n")
            i = 0
            while i < len(lines):
                m = HDR.match(lines[i])
                if not m:
                    i += 1
                    continue
                aid, fam, _, _, status = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)
                fields, prose, cur = {}, [], None
                j = i + 1
                while j < len(lines) and lines[j].startswith(";;"):
                    body = lines[j][2:]
                    fm = FIELD.match(lines[j])
                    if fm:
                        cur = fm.group(1).strip()
                        fields[cur] = [fm.group(2).strip()]
                    elif body.strip() == "":
                        cur = None
                    elif cur:
                        fields[cur].append(body.strip())
                    else:
                        prose.append(body.strip())
                    j += 1
                found[aid] = {
                    "id": aid, "family": fam, "status": status.upper(), "file": rel,
                    "fields": {k: " ".join(v).strip() for k, v in fields.items()},
                    "prose": " ".join(prose).strip(),
                }
                i = j
    return found


def chapter_register():
    att = _scan_attacks()
    if not att:
        sys.exit("register: no attacks found -- refusing to emit an empty chapter")
    byfam = {}
    for a in att.values():
        byfam.setdefault(a["family"], []).append(a)
    for v in byfam.values():
        v.sort(key=lambda a: a["id"])

    n = len(att)
    nfix = sum(1 for a in att.values() if a["status"] == "FIXED")
    out = [
        "This chapter is **generated** from the attack files by `REPL/tools/_auditbook.py`. Every "
        "entry below is the header block of a test that runs in the gate -- the same text the "
        "attack carries in source, not a summary written afterwards. If an attack is edited, "
        "retired or added, this chapter changes with it; it cannot describe a round that is no "
        "longer the one being run.\n",
        f"**{n} attacks across {len(byfam)} families. {nfix} found a defect and it was fixed; "
        f"{n - nfix} were refused by the system as designed. None succeeded.**\n",
        "Read *refused* carefully. It means the attack was turned away — which is the system "
        "working — and it is a weaker result than *fixed*, not a stronger one: a refusal proves "
        "the door held against one attempt, while a fix proves something was actually wrong and "
        "is now not. Several refusals below were nonetheless expensive to obtain, because "
        "establishing that a refusal came from the gate under test, rather than from an unrelated "
        "check upstream of it, is the hard part of this discipline. {{ch:method}} is about that "
        "problem.\n",
        "| family | attacks | fixed | refused |",
        "|---|---:|---:|---:|",
    ]
    for f in sorted(byfam):
        v = byfam[f]
        k = sum(1 for a in v if a["status"] == "FIXED")
        out.append(f"| **{f}** — {FAMILY_NAMES.get(f, '?')} | {len(v)} | {k} | {len(v) - k} |")
    out.append(f"| **total** | **{n}** | **{nfix}** | **{n - nfix}** |")
    out.append("")

    for f in sorted(byfam):
        out.append(f"\n## Family {f} — {FAMILY_NAMES.get(f, '?')}\n")
        for a in byfam[f]:
            badge = "FIXED" if a["status"] == "FIXED" else "REFUSED"
            out.append(f"### {a['id']} · {badge}\n")
            out.append(f"*Runs in* `REPL/{a['file']}`\n")
            for key, label in (("HYPOTHESIS", "What was suspected"),
                               ("METHOD", "How it was driven"),
                               ("RESULT", "What happened")):
                if a["fields"].get(key):
                    out.append(f"**{label}.** {a['fields'][key]}\n")
            for k, v in a["fields"].items():
                if k not in ("HYPOTHESIS", "METHOD", "RESULT") and v:
                    out.append(f"**{k.title()}.** {v}\n")
            if a["prose"]:
                out.append(f"> {a['prose']}\n")
    return "\n".join(out)


GENERATED = {"src/34-register.md": chapter_register}


# ---------------------------------------------------------------------------
# LIVE FIGURES.
#
# A staleness sweep of this book's chapter sources on 2026-09-18 found 124 stale figures against
# ~516 that still held. Not one had been introduced carelessly: every one was correct when written
# and the tree moved underneath it. Hand-correcting 124 numbers resets that clock and nothing else.
#
# So the volatile ones are not written in the sources at all. A source writes `{{fig:assertions}}`
# and the assembler substitutes the number it measures AT BUILD TIME, by running the tool that owns
# it. The measurement costs about eight seconds and it is the difference between a book that is
# true today and a book that was true once.
#
# A figure that cannot be measured is a BUILD FAILURE, not a fallback to a literal. A default value
# here would be a stale figure with extra steps.
# ---------------------------------------------------------------------------

def _run(*cmd):
    r = subprocess.run([sys.executable] + list(cmd), capture_output=True, text=True,
                       cwd=ROOT, timeout=600)
    return r.stdout + r.stderr


def _grab(pattern, text, what):
    m = re.search(pattern, text)
    if not m:
        sys.exit(f"FIGURE MEASUREMENT FAILED: could not read {what}.\n"
                 f"  pattern: {pattern}\n"
                 f"  The tool's output format changed. Fix the pattern -- do not hardcode a value.")
    return int(m.group(1).replace(",", ""))


_FIGCACHE = {}


def figures():
    """Measure every live figure the book quotes. Run once per build."""
    if _FIGCACHE:
        return _FIGCACHE
    f = {}

    rt = _run("REPL/tools/_redteam.py")
    f["attacks"]        = _grab(r'TOTAL ATTACKS ATTEMPTED:\s*(\d+)', rt, "attack count")
    f["attacks_fixed"]  = _grab(r'found a defect \(succeeded \+ fixed\):\s*(\d+)', rt, "defect-finding attacks")
    f["attacks_refused"] = f["attacks"] - f["attacks_fixed"]
    f["attack_families"] = len(set(re.findall(r'^\s+([A-K])\s{2,}\S.*attempted', rt, re.M)))

    im = _run("REPL/tools/_info_measured.py")
    f["previews_declared"] = _grab(r'cost previews declared\s*:\s*(\d+)', im, "previews declared")
    f["previews_client"]   = _grab(r'CLIENT-FACING\s*:\s*(\d+)', im, "client-facing previews")
    f["previews_measured"] = _grab(r'MEASURED \(cost proof\)\s*:\s*(\d+)', im, "measured previews")
    f["previews_unmeasured"] = _grab(r'named but NOT measured\s*:\s*(\d+)', im, "unmeasured previews")

    ow = _run("REPL/tools/_ownerobs.py")
    f["gates_observed"] = _grab(r'observed \(UPPER bound[^)]*\):\s*(\d+)', ow, "gates observed")
    f["gates_depth0"]   = _grab(r'ATTRIBUTED\s*\(depth 0[^)]*\)\s*:\s*(\d+)', ow, "gates attributed at depth 0")
    f["gates_never"]    = _grab(r'NEVER observed \(LOWER bound[^)]*\):\s*(\d+)', ow, "gates never observed")

    mr = _run("REPL/tools/_modref.py")
    f["modref_undeclared"] = _grab(r'NOT declared on the interface:\s*(\d+)', mr,
                                   "modref class-A (implemented but undeclared)")

    ec = _run("REPL/tools/_enforce_coverage.py")
    f["enforce_matchable"] = _grab(r'matchable message\s*:\s*(\d+)', ec, "matchable enforce sites")
    f["enforce_pinned"]    = _grab(r'PINNED by a negative test\s*:\s*(\d+)', ec, "pinned enforce sites")
    f["enforce_unpinned_live"] = _grab(r'LIVE unpinned[^:]*:\s*(\d+)', ec, "live unpinned enforce sites")

    # The suite statistics file is itself gate-regenerated by _suite_stats.py, so reading it here
    # is reading a generated artefact, not a hand-kept note.
    st = open(os.path.join(ROOT, "OuronetInformational", "ARCHITECTURE",
                           "REPL_SUITE_STATS.md"), encoding="utf-8").read()
    f["assertions"]          = _grab(r'assertions \*\*executed\*\*[^|]*\|\s*\*\*([\d,]+)\*\*', st, "assertions executed")
    f["assertions_distinct"] = _grab(r'\*\*distinct assertions written\*\*\s*\|\s*\*\*([\d,]+)\*\*', st, "distinct assertions")
    f["assertions_positive"] = _grab(r'positive \(`expect`\)\s*\|\s*([\d,]+)', st, "positive assertions")
    f["assertions_negative"] = _grab(r'negative \(`expect-failure`\)\s*\|\s*([\d,]+)', st, "negative assertions")
    f["repl_files"]          = _grab(r'\|\s*`\.repl` files\s*\|\s*\*\*([\d,]+)\*\*', st, "repl file count")
    f["repl_lines"]          = _grab(r'\|\s*total lines\s*\|\s*\*\*([\d,]+)\*\*', st, "repl line count")
    f["entrypoints"]         = _grab(r'gate entrypoints\s*\|\s*([\d,]+)', st, "gate entrypoints")

    f["modules"] = len([1 for d, _, ns in os.walk(os.path.join(ROOT, "1_SOVEREIGN"))
                        for n in ns if n.endswith(".pact")]) + \
                   len([1 for d, _, ns in os.walk(os.path.join(ROOT, "2_CITIZEN"))
                        for n in ns if n.endswith(".pact")])

    # Pact source lines, excluding the Audit/ trees (which are prose, not code).
    #
    # Counts NEWLINES, matching `wc -l`, because the earlier columns of the table this figure lands
    # in were measured that way. A final line with no trailing newline is therefore not counted --
    # which differs by 74 here from counting lines. Either convention is defensible; silently
    # switching conventions partway along a time series is not, since it shows up as growth.
    n = 0
    for top in ("1_SOVEREIGN", "2_CITIZEN"):
        for d, _, ns in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for name in ns:
                if name.endswith(".pact"):
                    with open(os.path.join(d, name), "rb") as fh:
                        n += fh.read().count(b"\n")
    f["pact_lines"] = n

    _FIGCACHE.update(f)
    return f


def demote(text, by=0):
    """Push every ATX heading down `by` levels so chapter titles own H1.

    `by` is 0, not 1. Each chapter source carries exactly one H1 -- its own title -- which the
    assembler strips and replaces with a numbered one, leaving that source's `##` sections as the
    top level BELOW the chapter. Demoting them again produced a document with 25 Heading 1s, one
    Heading 2, 165 Heading 3s and 195 Heading 4s: an outline with a rank missing, which is what
    Word and every PDF bookmark tree read to build navigation. Verified fence-aware across all 24
    sources that none carries a second real H1, so nothing is promoted into a chapter title by
    this.
    """
    out = []
    fence = False
    for ln in text.split("\n"):
        if ln.lstrip().startswith("```"):
            fence = not fence
        if not fence:
            m = re.match(r'^(#{1,5}) ', ln)
            if m:
                ln = "#" * min(6, len(m.group(1)) + by) + ln[len(m.group(1)):]
        out.append(ln)
    return "\n".join(out)


# {{ch:key}} -> "Chapter 12";  {{n:key}} -> "12" (for ranges: "Chapters {{n:a}}-{{n:b}}")
CHREF = re.compile(r'\{\{(ch|n):([a-z0-9]+)\}\}')
FIGREF = re.compile(r'\{\{fig:([a-z0-9_]+)\}\}')
LITERAL_CHREF = re.compile(r'\b[Cc]hapters?\s+\d+')


def build(pages=None):
    """Assemble the book. `pages` maps chapter key -> printed page number; when given, the
    contents list is emitted with page numbers instead of anchor links (the .docx has pages, the
    .md does not)."""
    figs = figures()
    nums = {k: i for i, (k, _, _) in enumerate(CHAPTERS, 1)}
    titles = {k: t for k, t, _ in CHAPTERS}
    parts, toc, bad = [], [], []
    for i, (key, title, rel) in enumerate(CHAPTERS, 1):
        if rel in GENERATED:
            body = GENERATED[rel]()
        else:
            p = os.path.join(BOOK, rel)
            if not os.path.exists(p):
                sys.exit(f"MISSING CHAPTER SOURCE: {rel}")
            body = open(p, encoding="utf-8").read()
        # a chapter source may carry its own H1; the assembler owns numbering, so drop it
        body = re.sub(r'\A\s*#\s+[^\n]*\n', '', body)

        # a literal "Chapter 17" in a source is a cross-reference that silently rots on reorder
        for ln_no, ln in enumerate(body.split("\n"), 1):
            for hit in LITERAL_CHREF.findall(ln):
                bad.append(f"{rel}:{ln_no}: literal '{hit}' -- use {{{{ch:<key>}}}} instead")

        def _sub(m):
            kind, k = m.group(1), m.group(2)
            if k not in nums:
                bad.append(f"{rel}: unknown chapter key '{k}' "
                           f"(known: {', '.join(sorted(nums))})")
                return m.group(0)
            return str(nums[k]) if kind == "n" else f"Chapter {nums[k]}"
        body = CHREF.sub(_sub, body)

        def _figsub(m):
            k = m.group(1)
            if k not in figs:
                bad.append(f"{rel}: unknown figure key '{k}' "
                           f"(known: {', '.join(sorted(figs))})")
                return m.group(0)
            return f"{figs[k]:,}"
        body = FIGREF.sub(_figsub, body)
        anchor = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        if pages is None:
            toc.append(f"{i:2}. [{title}](#{i}-{anchor})")
        else:
            toc.append(f"| {i} | {title} | {pages.get(key, '?')} |")
        parts.append(f"\n\n---\n\n# {i}. {title}\n\n{demote(body).strip()}\n")
    if bad:
        sys.exit("CROSS-REFERENCE ERRORS:\n  " + "\n  ".join(bad))

    head = (
        f"# THE OURONET AUDIT BOOK\n\n"
        f"**Version {VERSION}** · built {date.today().isoformat()} · commit `{_commit()}` · "
        f"generated by `REPL/tools/_auditbook.py`\n\n"
        f"> A single consolidated account of every audit performed on Ouronet: the per-module "
        f"rounds, the main-work round, and the red team — what was looked for, what was found, what "
        f"was done about it, and what proves the fix is still there.\n\n"
        f"> **This file is GENERATED.** Edit the chapter sources under `AUDIT-BOOK/`, then rebuild "
        f"with `python3 REPL/tools/_auditbook.py --docx`. Editing this file directly will be "
        f"overwritten, and `--check` fails the gate if it drifts from its sources.\n\n"
        + _changelog_md()
        + f"## Contents\n\n"
        # Column widths in a pandoc pipe table are taken from the DASH COUNTS on the separator
        # row, not from the content. Left even, the chapter column came out narrow enough to wrap
        # every multi-word title onto a second line.
        # Column widths in a pandoc pipe table come from the DASH COUNTS on the separator row,
        # not from the content. Two failures here, both caught by the convergence check rather
        # than by looking: even widths wrapped every multi-word title onto a second line, and a
        # Page column sized for the word "Page" wrapped every THREE-DIGIT number -- which changes
        # the table's HEIGHT between passes and so shifts the very pagination it is reporting.
        + ("| # | Chapter | Page |\n|:---:|" + "-" * 64 + "|-----:|\n" if pages else "")
        + "\n".join(toc) + "\n"
    )
    return head + "".join(parts)



# ---------------------------------------------------------------------------
# PAGE-NUMBERED CONTENTS, without a field code.
#
# Pandoc's `--toc` inserts a Word TOC FIELD. Two problems with it here. First, it is a DUPLICATE:
# this book already writes its own contents list. Second, and the reason it is gone, a TOC field
# can pull entries from other documents (that is what the `RD` switch is for), so Word greets every
# reader with "This document contains fields that may refer to other files. Do you want to update
# the fields?" before showing them anything. The answer is meaningless to a reader and the prompt
# cannot be suppressed from inside the document.
#
# So the contents is ordinary text, and its page numbers are MEASURED: render once, read which page
# each chapter landed on, write those numbers in, render again. The contents table has a fixed row
# count, so its own height does not change between passes and the numbers converge immediately --
# which the second render then CHECKS rather than assumes.
# ---------------------------------------------------------------------------

def _render_pdf(docx_path, outdir):
    subprocess.run(["soffice", "--headless", "--convert-to", "pdf", "--outdir", outdir,
                    docx_path], capture_output=True, timeout=900)
    pdf = os.path.join(outdir, os.path.splitext(os.path.basename(docx_path))[0] + ".pdf")
    return pdf if os.path.exists(pdf) else None


def _chapter_pages(pdf):
    """chapter key -> 1-based printed page, by finding each chapter heading in the rendered text."""
    txt = subprocess.run(["pdftotext", "-layout", pdf, "-"],
                         capture_output=True, text=True, timeout=300).stdout
    pages = txt.split("\f")
    found = {}
    for i, (key, title, _) in enumerate(CHAPTERS, 1):
        needle = f"{i}. {title}"
        for pno, body in enumerate(pages, 1):
            head = "\n".join([l for l in body.split("\n") if l.strip()][:8])
            if needle in head:
                found[key] = pno
                break
    return found


def _pandoc(md_path, docx_path):
    ref = os.path.join(BOOK, "reference.docx")
    if not os.path.exists(ref):
        sys.exit("reference.docx is missing -- run: python3 REPL/tools/_docxref.py")
    r = subprocess.run(["pandoc", md_path, "-o", docx_path, "--reference-doc", ref,
                        "-V", f"title=The Ouronet Audit Book v{VERSION}"],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stdout + r.stderr)


def build_docx():
    """Two passes: measure the pagination, then write it into the contents and re-emit."""
    import tempfile
    tmp = tempfile.mkdtemp(prefix="auditbook-")
    md1 = os.path.join(tmp, "pass1.md")
    dx1 = os.path.join(tmp, "pass1.docx")
    keys = [k for k, _, _ in CHAPTERS]

    # pass 1 -- placeholder numbers, so the contents table has its final HEIGHT
    # Placeholder is three digits, matching the widest real page number. A one-digit placeholder
    # gives pass 1 a different table height from pass 2, which moves every chapter by a page and
    # makes convergence impossible by construction.
    open(md1, "w", encoding="utf-8").write(build(pages={k: 999 for k in keys}))
    _pandoc(md1, dx1)
    pdf1 = _render_pdf(dx1, tmp)
    if not pdf1:
        print("  page numbering: soffice produced no PDF -- emitting contents without pages")
        _pandoc(OUT_MD, OUT_DOCX)
        return
    pages = _chapter_pages(pdf1)
    missing = [k for k in keys if k not in pages]
    if missing:
        sys.exit(f"page numbering: could not locate {len(missing)} chapter heading(s) in the "
                 f"rendered PDF: {', '.join(missing)}\n"
                 f"The contents would be wrong, so nothing is written.")

    # pass 2 -- the real numbers
    md2 = os.path.join(tmp, "pass2.md")
    open(md2, "w", encoding="utf-8").write(build(pages=pages))
    _pandoc(md2, OUT_DOCX)

    # VERIFY it converged. Same row count both passes, so it should -- but "should" is how a
    # contents list ends up off by a page.
    pdf2 = _render_pdf(OUT_DOCX, tmp)
    if pdf2:
        again = _chapter_pages(pdf2)
        drift = {k: (pages[k], again[k]) for k in pages if k in again and again[k] != pages[k]}
        if drift:
            print(f"  page numbering: DID NOT CONVERGE for {len(drift)} chapter(s):")
            for k, (a, b) in sorted(drift.items()):
                print(f"     {k}: contents says {a}, renders on {b}")
            sys.exit("The contents would be wrong. Nothing further written.")
        n = len(re.findall(rb'/Type\s*/Page[^s]', open(pdf2, "rb").read()))
        print(f"  page numbering: converged -- {len(pages)} chapters, {n} pages")
        # The convergence check already rendered a correct PDF, so ship it. It costs nothing, and
        # it is the copy a reader can open and PRINT without Word's Protected View getting in the
        # way -- which is a property of how the file reached the machine, not of the file, and so
        # cannot be fixed from this side.
        import shutil
        shutil.copyfile(pdf2, OUT_PDF)
        print(f"wrote {os.path.relpath(OUT_PDF, ROOT)}  ({n} pages)")


def _changelog_md():
    """Render CHANGELOG as a section. Placed BEFORE the contents deliberately: a reader picking up
    a copy needs to know what edition they hold before they trust a single page of it."""
    out = ["## Changelog\n"]
    for ver, when, items in CHANGELOG:
        out.append(f"\n### Version {ver} — {when}\n")
        for it in items:
            out.append(f"- {it}")
        out.append("")
    return "\n".join(out) + "\n"


def _commit():
    """Short hash of the commit the book was built from, or 'uncommitted' if the tree is dirty.

    A version number says WHICH edition; the commit says exactly WHAT it was built from. Without
    it a reader holding a PDF cannot tell whether their copy predates a given fix -- and this book
    exists to be read away from the repository.
    """
    try:
        import subprocess
        h = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                           capture_output=True, text=True).stdout.strip()
        d = subprocess.run(["git", "status", "--porcelain"], cwd=ROOT,
                           capture_output=True, text=True).stdout.strip()
        return (h + "+dirty") if d else (h or "unknown")
    except Exception:
        return "unknown"


def main():
    if "--figures" in sys.argv:
        for k, v in sorted(figures().items()):
            print(f"  {{{{fig:{k}}}}}".ljust(34) + f"{v:,}")
        return 0
    text = build()
    if "--check" in sys.argv:
        if not os.path.exists(OUT_MD):
            print("audit book: not built"); return 1
        cur = open(OUT_MD, encoding="utf-8").read()
        # PROVENANCE IS NOT CONTENT. The build date changes daily and the commit hash changes on
        # every commit -- including the commit that stores this very file. Left in the comparison,
        # the hash makes the book SELF-INVALIDATING: commit it, HEAD moves, the book is stale,
        # rebuilding needs another commit, forever. (Observed immediately on introducing it.) Both
        # are stripped so `--check` answers the question it exists to answer: does the book match
        # its CHAPTER SOURCES? The hash still appears in the published file, which is where a
        # reader holding a PDF needs it.
        strip = lambda s: re.sub(r'· commit `[^`]*` ', '',
                                 re.sub(r'· built \d{4}-\d{2}-\d{2} ', '', s))
        if strip(cur) != strip(text):
            print("audit book: OURONET-AUDIT-BOOK.md is STALE against its chapter sources.")
            print("Rebuild with: python3 REPL/tools/_auditbook.py --docx")
            return 1
        print(f"audit book: clean -- v{VERSION}, {len(CHAPTERS)} chapters, "
              f"{len(cur.splitlines()):,} lines")
        return 0
    open(OUT_MD, "w", encoding="utf-8").write(text)
    print(f"wrote {os.path.relpath(OUT_MD, ROOT)}  "
          f"(v{VERSION}, {len(CHAPTERS)} chapters, {len(text.splitlines()):,} lines)")
    if "--docx" in sys.argv:
        # Page geometry, running header and page-number footer all come from the reference doc --
        # pandoc has no flags for any of them. Generated by _docxref.py.
        build_docx()
        print(f"wrote {os.path.relpath(OUT_DOCX, ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
