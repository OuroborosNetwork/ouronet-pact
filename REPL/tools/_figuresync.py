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
}
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

def scan(stats_text, docs):
    canon, errs = rows(stats_text), []
    want = {}
    for slabel, aliases in CANON.items():
        key = slabel.strip('*').replace("**", "")
        for k, v in canon.items():
            if k.replace("**", "") == key:
                for a in aliases:
                    want[a] = v
    for name, text in docs:
        for k, v in rows(text).items():
            k2 = k.replace("**", "")
            if k2 in want and want[k2] != v:
                errs.append(f"{name}: '{k2}' = {v:,} but REPL_SUITE_STATS.md says {want[k2]:,}")
    return want, errs

def main():
    stats = open(STATS, encoding="utf-8").read()
    docs = [(n, open(os.path.join(ARCH, n), encoding="utf-8").read()) for n in _narrative()]
    want, errs = scan(stats, docs)
    print(f"canonical figures from REPL_SUITE_STATS.md: "
          + ", ".join(f"{k}={v:,}" for k, v in sorted(want.items())))
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
    print("selftest ok (3 cases: match, drift, prose-exempt)")
    return 0

if __name__ == "__main__":
    sys.exit(selftest() if "--selftest" in sys.argv else main())
