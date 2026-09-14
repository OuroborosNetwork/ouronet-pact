#!/usr/bin/env python3
"""
REPL/_info_measured.py -- how many INFO_* previews are MEASURED, not merely named.

WHY THIS EXISTS, separately from `_scale_report.py --untested`.
`_scale_report` answers "is this function reached at all", which is the right question for most
prefixes. For INFO_ previews it is the WRONG question, and quietly so: a preview is "reached" by

    (expect "..." true (contains "ignis" (INFO-ONE.INFO_DPTF|Control p ouro)))   ;; shape only
    (expect-failure "..." "No value found in table" (AQP-INFO.INFO_AQP-FVT|Inject p "FVT-x" ...))

Neither of those compares the quote to a charge. The owner's spec is "the INFO function must output
the exact same cost as the real execution function", and only a balance-delta can test that.

The proxy used here: a preview counts as MEASURED when its name appears, uncommented, inside a
`begin-tx` block that also extracts "ignis-need" or "stoa-need". That is the shape every cost proof
in this suite uses, and the transaction is the right scope because the binding and the assertion are
routinely 20+ lines apart.

It is a PROXY, and it is deliberately generous in one direction: a block that extracts `ignis-need`
but forgets to `expect` it would still count. It is not generous in the other -- nothing shape-only
can pass. Read the number as an upper bound on measured coverage, not a certificate.

    python3 REPL/_info_measured.py            # summary
    python3 REPL/_info_measured.py --gaps     # + the named-but-unmeasured and never-named lists
"""
import re, glob, os, sys

PREVIEW_SOURCES = [
    "../1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact",
    "../1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact",
    "../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact",
]
NAME_RE = re.compile(r'INFO_[A-Za-z0-9|_\-]+')

def declared():
    out = {}
    for f in PREVIEW_SOURCES:
        p = os.path.join(os.path.dirname(os.path.abspath(__file__)), f)
        for m in re.finditer(r'^\s+\(defun (INFO_[^\s:]+)', open(p).read(), re.M):
            out[m.group(1)] = os.path.basename(f)
    return out

def scan():
    named, measured = {}, {}
    root = os.path.dirname(os.path.abspath(__file__))
    for f in glob.glob(os.path.join(root, "**", "*.repl"), recursive=True):
        rel = os.path.relpath(f, root)
        if rel.startswith("archive" + os.sep):
            continue
        txt = open(f, errors="ignore").read()
        for block in re.split(r'\(begin-tx', txt):
            code = "\n".join(l.split(";;")[0] for l in block.split("\n"))
            hits = set(NAME_RE.findall(code))
            is_cost = ('"ignis-need"' in code) or ('"stoa-need"' in code)
            for n in hits:
                named.setdefault(n, set()).add(rel)
                if is_cost:
                    measured.setdefault(n, set()).add(rel)
    return named, measured

def main():
    dec = declared()
    named, measured = scan()
    d = set(dec)
    n = set(named) & d
    m = set(measured) & d
    print(f"declared previews      : {len(d)}")
    print(f"named in a live .repl  : {len(n)}")
    print(f"MEASURED (cost proof)  : {len(m)}   <-- the number that answers the owner's spec")
    print(f"named but NOT measured : {len(n - m)}")
    print(f"never named at all     : {len(d - n)}")
    if "--gaps" in sys.argv:
        print("\n-- named but NOT measured (shape-check / abort-pin only) --")
        for x in sorted(n - m):
            print(f"   {x:<52} {sorted(named[x])[0]}")
        print("\n-- never named --")
        for x in sorted(d - n):
            print(f"   {x:<52} {dec[x]}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
