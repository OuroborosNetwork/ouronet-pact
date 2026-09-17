#!/usr/bin/env python3
"""FIGURE SYNC — do the narrative audit documents quote the GENERATED figures?

WHY THIS EXISTS. `REPL_SUITE_STATS.md` is generated from a live gate; the narrative documents
(`REPL-ROUND-REPORT.md` and friends) restate its headline numbers inline, because a published paper
wants the figure on the page rather than a cross-reference. Those two copies drifted apart FOUR
TIMES in a single working session on 2026-09-14/15 -- each time because the suite changed and only
one of the two was regenerated. Every time, the stale number read exactly as authoritative as the
fresh one.

The project already has the rule this enforces:

    A number quoted in an audit document as evidence of a repair must be one the gate re-derives
    on every run. Otherwise it is a claim about the past.

WHAT IT CHECKS, deliberately narrowly. Only LABELLED TABLE ROWS of the form

    | <label> | <number> |

whose label matches one this tool knows how to derive from REPL_SUITE_STATS.md. A prose mention is
NOT checked, and that is not laziness -- prose legitimately carries HISTORICAL figures ("no other
failure in the 21,732 the suite executed at that moment"), and a checker that flagged those would
be wrong more often than right, get overridden, and then be ignored when it mattered.

    python3 tools/_figuresync.py            # report
    python3 tools/_figuresync.py --check    # exit 1 on any drift (gate mode)
    python3 tools/_figuresync.py --selftest
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPL = os.path.dirname(HERE)
ARCH = os.path.join(os.path.dirname(REPL), "OuronetInformational", "ARCHITECTURE")
STATS = os.path.join(ARCH, "REPL_SUITE_STATS.md")

# label-in-stats  ->  labels that may restate it elsewhere
CANON = {
    "distinct assertions written":            ["distinct assertions written"],
    "assertions **executed** per full gate run": ["assertions executed per full gate run"],
    "gate entrypoints":                       ["gate entrypoints"],
    "per-function rows":                      ["per-function rows"],
    # THE SUB-ROWS. Added 2026-09-15 after they were found stale by 926 and 175 respectively,
    # sitting DIRECTLY BENEATH two rows this tool was already checking. Nothing had ever compared
    # them, and their position made that invisible: a checker that covers some rows of a table
    # reads, to anyone glancing at it, as covering the table.
    "positive (`expect`)":                    ["positive (`expect`)"],
    "negative (`expect-failure`)":            ["negative (`expect-failure`)"],
}

# WHY PROSE IS DELIBERATELY OUT OF SCOPE, and why this is not an oversight to be "fixed" later.
# Extending this checker to figures written in prose ("N assertions", "N entrypoints") was tried on
# 2026-09-15 and abandoned after a dry run, because most such numerals are FROZEN HISTORICAL RECORD
# and rewriting them would destroy the audit trail:
#
#   DEFECT-LEDGER.md:238          "86 entrypoints, 21,527 assertions, still GREEN"  — a dated result
#   REPL_TEST_ARCHITECTURE.md:262 "9209 assertions in 166 seconds"                  — a parallel run
#   RED-TEAM-REPORT.md:850        "gate green at 21,588 assertions"                 — that stage
#   REPL-ROUND-REPORT.md:69,82    "21,732 -> 21,511"                                — a worked example
#
# The last one matters most: it sits in the CURRENT-STATE document, so not even a per-document
# opt-in separates live figures from frozen ones. The safe boundary is a LABELLED TABLE ROW, whose
# label states that it is the current value. A figure written in prose is human-maintained here;
# the honest move is to say so rather than to assume coverage that does not exist.
# EVERY .md in ARCHITECTURE/ except the generated source itself. Deliberately a GLOB rather than a
# list: at the time of writing only REPL-ROUND-REPORT.md carries labelled figure rows, so a list
# would have been complete AND silently wrong the day someone adds a statistics table to another
# document. A checker whose coverage depends on a human remembering to extend it is the shape of
# defect this tool exists to catch.
def _narrative():
    return sorted(f for f in os.listdir(ARCH)
                  if f.endswith(".md") and f != os.path.basename(STATS))

def rows(text):
    out = {}
    for m in re.finditer(r'^\|\s*(?:&nbsp;)*\s*(.+?)\s*\|\s*\*{0,2}([\d,]+)\*{0,2}\s*\|\s*$', text, re.M):
        out[m.group(1).strip().strip('*').strip()] = int(m.group(2).replace(",", ""))
    return out

def scan(stats_text, docs, strict=False):
    canon, errs = rows(stats_text), []
    want = {}
    for slabel, aliases in CANON.items():
        key = slabel.strip('*').replace("**", "")
        for k, v in canon.items():
            if k.replace("**", "") == key:
                for a in aliases:
                    want[a] = v
    # A CANONICAL FIGURE THAT VANISHES FROM THE SOURCE MUST BE AN ERROR, NOT A QUIET NARROWING.
    # 2026-09-15: _suite_stats.py globbed /tmp/gate*.out while the convention is /tmp/gate*.log, so
    # it found no gate output, skipped its `if ex_tot:` block, and wrote a report with neither
    # "assertions executed per full gate run" nor "gate entrypoints". This checker then reported
    # CLEAN -- truthfully, about the one figure it could still find. Coverage had silently dropped
    # from three figures to one, and nothing said so.
    # `strict` only for the REAL stats file: the selftest feeds a synthetic table that
    # deliberately carries one figure, and a missing-figure error there would be noise.
    missing = ([a for slabel, aliases in CANON.items() for a in aliases if a not in want]
               if strict else [])
    if missing:
        print(f"\n{len(missing)} CANONICAL FIGURE(S) MISSING from {os.path.basename(STATS)}:")
        for a in missing:
            print(f"   {a}")
        print("\nThe generated source no longer carries these, so nothing is checking the\n"
              "documents' claims about them. Regenerate with:\n"
              "   python3 REPL/tools/_gate.py && python3 REPL/tools/_suite_stats.py")
        errs += [f"{os.path.basename(STATS)}: canonical figure '{a}' is MISSING" for a in missing]
        return want, errs

    for name, text in docs:
        for k, v in rows(text).items():
            k2 = k.replace("**", "")
            if k2 in want and want[k2] != v:
                errs.append(f"{name}: '{k2}' = {v:,} but REPL_SUITE_STATS.md says {want[k2]:,}")
    return want, errs

ROW = re.compile(r'^(\|\s*(?:&nbsp;)*\s*)(.+?)(\s*\|\s*)(\*{0,2})([\d,]+)(\*{0,2})\s*\|\s*$', re.M)

def rewrite(text, want):
    """Rewrite every canonical LABELLED ROW to its canonical value, preserving that row's own
    formatting -- the leading &nbsp; indent and whatever ** bolding it already carries. Rows whose
    label is not canonical, and every figure written in prose, are left exactly as they were."""
    n = [0]
    def sub(m):
        head, label, mid, pre, num, post = m.groups()
        k = label.replace("**", "").strip()
        if k not in want or int(num.replace(",", "")) == want[k]:
            return m.group(0)
        n[0] += 1
        return f"{head}{label}{mid}{pre}{want[k]:,}{post} |"
    return ROW.sub(sub, text), n[0]

def stats_staleness():
    """Is REPL_SUITE_STATS.md itself still true of the tree?

    ADDED 2026-09-17. This tool checked that every narrative doc AGREES WITH the stats file, and
    never that the stats file agrees with the TREE. So a stale stats file propagated consistently
    into every document and nothing turned red -- measured at the time of writing: the file claimed
    5,555 distinct assertions and 22,454 executed, against ~5,800 and 24,972 actual. Every figure in
    every doc matched, and all of them were wrong together.

    Contrast `_pricesync`, which regenerates its artefact IN MEMORY and diffs -- a closed loop. This
    is the same loop for the one figure that can be derived statically. The EXECUTED count cannot be
    (it needs a live gate), so it is deliberately not checked here; `_gate.py` is the only thing that
    knows it, and the honest move is to say so rather than to check a number this tool cannot see.

    THE WORKFLOW THIS IMPOSES, stated so it is not mistaken for a nuisance and removed. The check is
    EXACT-MATCH, so any commit that adds or removes an assertion fails the gate until
    `tools/_suite_stats.py` is re-run. That is the point, and it is the same contract `_pricesync`
    already imposes on the price artefacts: a generated figure that is allowed to lag is a figure
    nobody can cite. It caught its own first drift within the hour -- three assertions, added after
    the regeneration that had just fixed a 275-assertion gap.
    """
    import re as _re
    live = 0
    for dirpath, _d, fnames in os.walk(REPL):
        for fn in fnames:
            if fn.endswith(".repl"):
                live += len(_re.findall(r"\(expect(?:-failure)?\b",
                                        open(os.path.join(dirpath, fn), encoding="utf8",
                                             errors="ignore").read()))
    txt = open(STATS, encoding="utf-8").read()
    m = _re.search(r"distinct assertions written\*\*\s*\|\s*\*\*([\d,]+)\*\*", txt)
    if not m:
        return [f"{os.path.basename(STATS)}: could not find the distinct-assertion row"]
    claimed = int(m.group(1).replace(",", ""))
    if claimed != live:
        return [f"{os.path.basename(STATS)} is STALE against the tree: claims {claimed:,} distinct "
                f"assertions, the tree has {live:,}. Regenerate with "
                f"`cd REPL && python3 tools/_suite_stats.py` (add --gate for a live executed count)."]
    return []


def main():
    stats = open(STATS, encoding="utf-8").read()
    docs = [(n, open(os.path.join(ARCH, n), encoding="utf-8").read()) for n in _narrative()]
    want, errs = scan(stats, docs, strict=True)
    if "--write" in sys.argv and not [e for e in errs if "MISSING" in e]:
        total = 0
        for name, text in docs:
            out, n = rewrite(text, want)
            if n:
                open(os.path.join(ARCH, name), "w", encoding="utf-8").write(out)
                print(f"  rewrote {n} figure row(s) in {name}")
                total += n
        print(f"figure sync: wrote {total} row(s). "
              f"NOTE: figures in PROSE are not touched -- see the header comment.")
        return 0
    print(f"canonical figures from REPL_SUITE_STATS.md: "
          + ", ".join(f"{k}={v:,}" for k, v in sorted(want.items())))
    # The stats file is this tool's SOURCE OF TRUTH, so it has to be checked against the tree or the
    # whole comparison is circular -- every doc agreeing with a stale file reads exactly like every
    # doc being right.
    errs = errs + stats_staleness()
    if errs:
        print("\nFIGURE DRIFT:")
        for e in errs:
            print("   " + e)
        return 1 if "--check" in sys.argv else 0
    print("figure sync: clean -- every labelled table figure matches the generated source")
    return 0

def selftest():
    s = "| **distinct assertions written** | **5,417** |\n| gate entrypoints | 86 |\n"
    ok = "| **distinct assertions written** | **5,417** |\n"
    bad = "| **distinct assertions written** | **5,399** |\n"
    _, e = scan(s, [("ok.md", ok)])
    if e:
        print("SELFTEST FAILED: matching figure reported as drift"); return 1
    _, e = scan(s, [("bad.md", bad)])
    if not e:
        print("SELFTEST FAILED: drifted figure NOT detected"); return 1
    # a prose mention of a stale number must NOT trip it
    _, e = scan(s, [("prose.md", "the suite executed 21,732 assertions at that moment\n")])
    if e:
        print("SELFTEST FAILED: prose flagged as drift"); return 1
    # --write must FIX a drifted row, PRESERVE its formatting, and LEAVE PROSE ALONE. The last
    # clause is the one worth a test: a rewriter that also "helpfully" corrected prose would
    # silently rewrite every dated measurement in the defect ledger.
    want = {"distinct assertions written": 5417, "gate entrypoints": 86}
    mixed = ("| **distinct assertions written** | **5,399** |\n"
             "| &nbsp;&nbsp;gate entrypoints | 12 |\n"
             # a NON-canonical row that still ends in a number: spared by the LABEL whitelist,
             # which is the real protection here -- not the row regex.
             "| `.repl` files reachable from the gate | 306 |\n"
             "the suite executed 21,732 assertions at that moment\n")
    out, n = rewrite(mixed, want)
    if n != 2:
        print(f"SELFTEST FAILED: --write changed {n} rows, expected 2"); return 1
    if "**5,417**" not in out:
        print("SELFTEST FAILED: --write lost the ** bolding"); return 1
    if "| &nbsp;&nbsp;gate entrypoints | 86 |" not in out:
        print("SELFTEST FAILED: --write lost the &nbsp; indent"); return 1
    if "21,732 assertions at that moment" not in out:
        print("SELFTEST FAILED: --write rewrote a figure in PROSE"); return 1
    if "| `.repl` files reachable from the gate | 306 |" not in out:
        print("SELFTEST FAILED: --write touched a NON-canonical row"); return 1
    print("selftest ok (6 cases: match, drift, prose-exempt, write-fixes, write-keeps-format, write-spares-prose+non-canonical rows)")
    return 0

if __name__ == "__main__":
    sys.exit(selftest() if "--selftest" in sys.argv else main())
