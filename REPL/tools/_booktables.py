#!/usr/bin/env python3
"""_booktables.py -- do the Audit Book's own tables add up?

WHY THIS EXISTS. Part I's verification pass found that one of the audits being documented had a
tracker saying "FIXED: 19" while enumerating 18, with a compensating off-by-one elsewhere so that
the TOTAL RECONCILED. That is precisely why nobody re-counted the parts: a total that adds up is the
strongest possible signal that the parts were checked, and it is not evidence of anything.

The Audit Book states, as its third rule, that a count is reported with its exclusions or not at
all. A book making that claim should not contain a table whose own rows disagree with its own total.
This checks the two tables that carry the book's headline figures, and cross-checks them against the
tools that generate the underlying numbers.

It deliberately does NOT try to parse every table in 6,000 lines of prose. A checker that pattern-
matches loosely across a whole corpus produces false positives, gets ignored, and then gets deleted
-- which is worse than not having it. Two tables, checked exactly.

usage:
  python3 REPL/tools/_booktables.py            report
  python3 REPL/tools/_booktables.py --check    exit 1 on any inconsistency
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BOOK = os.path.join(ROOT, "Audit", "book")
TOOLS = os.path.join(ROOT, "REPL", "tools")


def _read(*parts):
    p = os.path.join(BOOK, *parts)
    return open(p, encoding="utf-8").read() if os.path.exists(p) else None


def check_partiii():
    """The attack family table: rows must sum to the stated total, and per-row to their own split."""
    t = _read("PART-III", "README.md")
    if t is None:
        return ["PART-III/README.md is missing"]
    rows = re.findall(r'^\| \*\*([A-K])\*\* — [^|]+\| *(\d+) *\| *(\d+) *\| *(\d+) *\|', t, re.M)
    if not rows:
        return ["PART-III/README.md: could not find the attack-family table"]
    errs = []
    for fam, n, found, refused in rows:
        if int(n) != int(found) + int(refused):
            errs.append(f"PART-III family {fam}: {n} attacks != {found} found + {refused} refused")
    a = sum(int(r[1]) for r in rows)
    d = sum(int(r[2]) for r in rows)
    m = re.search(r'\*\*(\d+) attacks across (\d+) families\. (\d+) found a defect', t)
    if not m:
        return errs + ["PART-III/README.md: could not find the headline attack sentence"]
    if int(m.group(1)) != a:
        errs.append(f"PART-III: headline says {m.group(1)} attacks, the table sums to {a}")
    if int(m.group(2)) != len(rows):
        errs.append(f"PART-III: headline says {m.group(2)} families, the table has {len(rows)}")
    if int(m.group(3)) != d:
        errs.append(f"PART-III: headline says {m.group(3)} found a defect, the table sums to {d}")
    # ...and against the generator, because a self-consistent table can still be self-consistently wrong.
    try:
        out = subprocess.run([sys.executable, os.path.join(TOOLS, "_redteam.py")],
                             capture_output=True, text=True, timeout=300).stdout
        g = re.search(r'TOTAL ATTACKS ATTEMPTED: (\d+)', out)
        if g and int(g.group(1)) != a:
            errs.append(f"PART-III: the table sums to {a}, but _redteam.py counts "
                        f"{g.group(1)} attacks in the tree")
    except Exception as e:                                    # pragma: no cover
        errs.append(f"PART-III: could not cross-check against _redteam.py ({e})")
    return errs


def check_defects_enumerated():
    """Every attack the register marks FIXED must be NAMED in the defects chapter.

    WHY THIS IS SEPARATE FROM check_partiii(). That check compares the summary TABLE against the
    register, and it passed for several days while the chapter under it enumerated eighteen defects,
    its own title said nineteen, and the register said twenty. A table can agree with the generator
    while the prose beneath it describes a different set -- which is the same off-by-one-with-a-
    reconciling-total that this whole tool was written about, reproduced inside the tool's own blind
    spot. Checking a total is not checking a list.

    A range written `RT-K-001` ... `RT-K-008` counts as naming every id between the endpoints; the
    chapter groups families that way deliberately and forcing it to spell out eight ids would make
    it worse to read for no gain in truth.
    """
    t = _read("PART-III", "03-DEFECTS.md")
    if t is None:
        return ["PART-III/03-DEFECTS.md is missing"]
    named = set(re.findall(r'RT-[A-K]-\d+', t))
    # expand `RT-K-001` <sep> `RT-K-008` ranges
    for m in re.finditer(r'`(RT-([A-K])-(\d+))`\s*(?:\.\.\.|…|–|—)\s*`RT-\2-(\d+)`', t):
        fam, lo, hi = m.group(2), int(m.group(3)), int(m.group(4))
        named |= {f"RT-{fam}-{i:03d}" for i in range(lo, hi + 1)}

    try:
        out = subprocess.run([sys.executable, os.path.join(TOOLS, "_redteam.py")],
                             capture_output=True, text=True, timeout=300).stdout
    except Exception as e:                                    # pragma: no cover
        return [f"defects chapter: could not run _redteam.py ({e})"]
    fixed = set(re.findall(r'^\s*(RT-[A-K]-\d+)\s+\[FIXED\]', out, re.M))
    if not fixed:
        return ["defects chapter: _redteam.py reported no FIXED attacks -- refusing to pass vacuously"]
    missing = sorted(fixed - named)
    errs = []
    if missing:
        errs.append("PART-III/03-DEFECTS.md does not name these FIXED attacks: "
                    + ", ".join(missing))
    # the chapter title states a count; it must match the register
    words = {"eighteen": 18, "nineteen": 19, "twenty": 20, "twenty-one": 21, "twenty-two": 22,
             "seventeen": 17, "sixteen": 16, "fifteen": 15}
    tm = re.search(r'#[^\n]*?The ([a-z-]+) defects', t)
    if tm:
        want = words.get(tm.group(1))
        if want is None:
            errs.append(f"defects chapter: title count '{tm.group(1)}' not recognised")
        elif want != len(fixed):
            errs.append(f"defects chapter: title says {tm.group(1)} ({want}) defects, "
                        f"the register marks {len(fixed)} attacks FIXED")
    return errs


def check_parti():
    """The module table: per-module findings must sum to the stated total."""
    t = _read("PART-I", "README.md")
    if t is None:
        return ["PART-I/README.md is missing"]
    rows = re.findall(r'^\| *\d+ *\| \*\*([A-Z-]+)\*\* \|[^|]*\| \*\*(\d+)\*\* \|', t, re.M)
    if not rows:
        return ["PART-I/README.md: could not find the module table"]
    s = sum(int(r[1]) for r in rows)
    m = re.search(r'^\| *\| *\| *\| \*\*(\d+)\*\* \| *\|', t, re.M)
    if not m:
        return [f"PART-I/README.md: found {len(rows)} module rows summing to {s}, "
                f"but no total row to check them against"]
    if int(m.group(1)) != s:
        return [f"PART-I: total row says {m.group(1)}, the {len(rows)} module rows sum to {s}"]
    return []


def main():
    errs = check_partiii() + check_parti() + check_defects_enumerated()
    if errs:
        print("AUDIT BOOK TABLE INCONSISTENCY:")
        for e in errs:
            print("   " + e)
        return 1
    print("audit book tables: clean -- Part I and Part III headline tables sum to their own totals,")
    print("  and Part III's total matches the attack register in the tree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
