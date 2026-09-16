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
import os as _os2, sys as _sys2
_sys2.path.insert(0, _os2.path.dirname(_os2.path.abspath(__file__)))
from _pactlex import strip_comments

PREVIEW_SOURCES = [
    "../1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact",
    "../1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact",
    "../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact",
]
NAME_RE = re.compile(r'INFO_[A-Za-z0-9|_\-]+')

def declared():
    out = {}
    for f in PREVIEW_SOURCES:
        p = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), f)
        # ONLY ClientInfo-returning previews. The owner's rule -- "the INFO function must output
        # the exact same cost as the real execution function" -- is about COST previews. Matching
        # every INFO_ defun swept in display readers that quote no cost at all
        # (INFO_VST|HibernatedNonceDisplay / |HibernatedNoncesDisplay return HibernatedNoncesView),
        # which inflated the denominator and reported two permanent "gaps" that were never in
        # scope. A coverage figure is only meaningful if its denominator is the thing being covered.
        for m in re.finditer(r'^\s+\(defun (INFO_[^\s:(]+)(:[^\s(]+)?', open(p).read(), re.M):
            if 'ClientInfo' not in (m.group(2) or ''):
                continue
            out[m.group(1)] = os.path.basename(f)
    return out

def internal_helpers(dec):
    """Previews that exist only to be called by OTHER previews, and are therefore exercised
    transitively whenever a caller is measured.

    2026-09-15: the "never named" bucket read 14 and looked like 14 holes in the owner's first
    rule. Two were display readers returning HibernatedNoncesView, not cost previews at all. NINE
    of the remaining twelve were the `INFO_DPDC-*` family -- son-discriminated SHARED
    IMPLEMENTATIONS, called 48/32/14/9/7/5/2/2/2 times by the `INFO_DPNF|*` / `INFO_DPSF|*`
    wrappers that ARE measured. INFO_DPNF|Issue is literally
    `(INFO_DPDC-I|Issue patron owner-account collection-name false)`.

    Counting them as gaps buried the ONE real gap among nine non-gaps -- and a coverage report
    that cries wolf nine times is a coverage report nobody reads to the end.
    """
    helpers = set()
    for f in PREVIEW_SOURCES:
        p = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), f)
        src = open(p).read()
        for name in dec:
            if dec[name] != os.path.basename(f):
                continue
            # a CALL, not the defun: "(NAME " with a space, never "(defun NAME"
            if re.search(r'(?<!defun )\(' + re.escape(name) + r'[\s)]', src):
                helpers.add(name)
    return helpers


def scan():
    named, measured = {}, {}
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for f in glob.glob(os.path.join(root, "**", "*.repl"), recursive=True):
        rel = os.path.relpath(f, root)
        if rel.startswith("archive" + os.sep):
            continue
        txt = open(f, errors="ignore").read()
        for block in re.split(r'\(begin-tx', txt):
            # PER-LINE `;;` splitting is the exact bug `_pactlex` was extracted to prevent: it
            # cannot see that a `;;` inside a STRING is not a comment, and 100 string literals in
            # this corpus contain one (the file headers' Legend/Source lines quote `;;|| NEXT >`).
            # On those lines it deletes real code. Measured 2026-09-16: the result is unchanged
            # here, because the affected lines are banner strings carrying no INFO_ name and no
            # "ignis-need" -- but the number this tool prints is cited as the proof of the owner's
            # first rule, so it should not rest on a strip that is known-wrong in general.
            code = strip_comments(block)
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
    helpers = internal_helpers(dec) - n
    client = d - helpers
    print(f"cost previews declared : {len(d)}   (ClientInfo-returning only)")
    print(f"  INFO-internal helpers: {len(helpers)}   (called by another preview; exercised transitively)")
    print(f"  CLIENT-FACING        : {len(client)}   <-- the denominator the owner's rule is about")
    print(f"named in a live .repl  : {len(n)}")
    print(f"MEASURED (cost proof)  : {len(m)}   <-- the number that answers the owner's spec")
    print(f"named but NOT measured : {len(n - m)}")
    print(f"client-facing, NEVER named: {len(client - n)}")
    if "--gaps" in sys.argv:
        print("\n-- named but NOT measured (shape-check / abort-pin only) --")
        for x in sorted(n - m):
            print(f"   {x:<52} {sorted(named[x])[0]}")
        print("\n-- CLIENT-FACING, never named (real gaps) --")
        for x in sorted(client - n):
            print(f"   {x:<52} {dec[x]}")
        print("\n-- INFO-internal helpers, never named directly (exercised via their callers) --")
        for x in sorted(helpers):
            print(f"   {x:<52} {dec[x]}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
