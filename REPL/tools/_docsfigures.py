#!/usr/bin/env python3
"""_docsfigures.py -- the PROSE figures in OuronetDocumentation/ must still be true.

    python3 REPL/tools/_docsfigures.py [--check] [--selftest]

The generated regions of the documentation are already diffed (`_docspages`,
`_docsmodules`). Nothing checked the figures quoted in PROSE -- and those are the ones
a reader actually carries away, because they appear in sentences rather than tables.

They are also the ones that spread. "423 entrypoints" appears in twelve sections;
"122,969 lines" in eight. A figure quoted in one place and wrong is an error. A figure
quoted in twelve places and wrong is a documentation set that agrees with itself about
something false -- which is exactly the failure `_figuresync` was built for one folder
over, and its own lesson:

    A consistency check between N documents and one source proves the N documents
    consistent. It says nothing whatever about the source.

So this tool does NOT compare documents to each other. Each figure is RE-DERIVED from
the tree or the registry, then searched for in the prose. A figure that no longer
matches is fatal; a figure that has stopped appearing anywhere is reported too, because
a claim silently dropped is not the same as a claim corrected.

Deliberately small. Only cross-cutting figures belong here -- ones repeated across
sections, where a stale copy survives in a chapter nobody re-read. A per-chapter number
lives next to its own evidence and does not need this.
"""
import glob, json, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOCS = os.path.join(ROOT, "OuronetDocumentation")
REG = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")


def _reg():
    return json.load(open(REG, encoding="utf-8"))


def _tree_lines():
    """NEWLINE count -- `cat **/*.pact | wc -l`, which is the rule the published figure
    used. Counting lines per file instead gives 123,042, because 73 files in this tree
    do not end with a newline and a per-file count charges each of them one extra.

    Both rules are defensible. Only one matches the number in print, and the first
    version of this tool used the other one and reported `ok` anyway -- see the header
    of run() for why that was possible."""
    n = 0
    for p in glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True) + \
             glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True):
        with open(p, "rb") as fh:
            n += fh.read().count(b"\n")
    return n


def _tree_defuns():
    n = 0
    pat = re.compile(r"^\s*\(defun ")
    for p in glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True) + \
             glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True):
        with open(p, encoding="utf-8", errors="replace") as fh:
            n += sum(1 for l in fh if pat.match(l))
    return n


def figures():
    """label -> (value, how it was derived). Every one RE-DERIVED, never read back
    from the documentation it is about to check."""
    r = _reg()
    eps, pv = r["entrypoints"], r["previews"]
    same = 0
    for v in eps.values():
        p = v.get("preview")
        if p in pv and [(x["name"], x["type"]) for x in v["params"]] == \
                       [(x["name"], x["type"]) for x in pv[p]["params"]]:
            same += 1
    return {
        "client entrypoints": (len(eps), "registry entrypoints"),
        "fully sponsored": (sum(1 for v in eps.values()
                                if v.get("sponsorship", {}).get("sponsored") is True),
                            "registry sponsorship.sponsored is true"),
        "previews with a DIFFERENT param list": (len(eps) - same,
                                                 "registry, compared by (name,type)"),
        "contract lines": (_tree_lines(), "wc -l over 1_SOVEREIGN + 2_CITIZEN"),
        "defun count": (_tree_defuns(), "^\\s*\\(defun over the same tree"),
    }


def prose():
    out = {}
    for p in glob.glob(os.path.join(DOCS, "**", "*.md"), recursive=True):
        t = open(p, encoding="utf-8").read()
        # strip generated regions: those are already diffed elsewhere, and a figure
        # that appears ONLY inside one is not a prose claim.
        t = re.sub(r"<!-- @generated:.*?-->.*?<!-- @end:.*?-->", "", t, flags=re.S)
        out[os.path.relpath(p, ROOT)] = t
    return out


def run():
    """Two distinct failures, and the first version of this tool could only see one.

    It searched for the CURRENT value and reported `ok` when it appeared -- so a figure
    that had drifted showed as absent, not as wrong, and one that had drifted to a value
    ALSO present elsewhere in the prose showed as fine. The `stale` branch was literally
    `extend([])`: a comparison that could not fail, in a tool whose whole job is
    comparison. Found on its first real run, because the line count disagreed and the
    tool said `ok`.

    Now: a figure must appear, AND no NEAR-MISS of it may appear. A near-miss is a
    number within 1% carrying the same label nearby -- which is what a stale copy of a
    drifting count looks like."""
    figs, docs = figures(), prose()
    stale, absent = [], []
    for label, (val, how) in figs.items():
        pat = re.compile(r"\b" + f"{val:,}".replace(",", "[,]?") + r"\b")
        where = [f for f, t in docs.items() if pat.search(t)]
        if not where:
            absent.append((label, val, how))
            continue
        lo, hi = int(val * 0.99), int(val * 1.01)
        near = re.compile(r"\b(\d{1,3}(?:,\d{3})+|\d{4,})\b")
        for f, t in docs.items():
            for line in t.splitlines():
                # A near-miss ON THE SAME LINE as the correct value is a deliberate
                # comparison, not a stale copy. The module map carries exactly this:
                # "122,969 | 123,042 | agree, deliberately ... a logical-lines count
                # gives 123,042, because 73 files lack a trailing newline."
                # The first version of this rule flagged it, which would have trained
                # whoever ran the tool to ignore its output -- the failure mode that
                # ends with a checker switched off and protecting nothing.
                if pat.search(line):
                    continue
                for m in near.finditer(line):
                    other = int(m.group(1).replace(",", ""))
                    if other != val and lo <= other <= hi:
                        stale.append((label, val, other, f))
    return figs, stale, absent


def selftest():
    ok = True
    figs = figures()
    if figs["client entrypoints"][0] <= 0:
        print("  selftest: registry yielded no entrypoints"); ok = False
    # The rule this tool exists to enforce: figures are derived, not read back.
    src = open(os.path.abspath(__file__), encoding="utf-8").read()
    if "OuronetDocumentation" in src.split("def figures", 1)[1].split("def prose", 1)[0]:
        print("  selftest: figures() reads the documentation -- circular"); ok = False
    # Generated regions must be stripped, or a prose check passes on generated text.
    d = prose()
    if any("@generated:module-page" in t for t in d.values()):
        print("  selftest: generated regions not stripped"); ok = False
    print("  selftest OK" if ok else "  selftest FAILED")
    return ok


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    figs, stale, absent = run()
    for label, (val, how) in figs.items():
        mark = "ABSENT" if any(a[0] == label for a in absent) else "ok"
        print(f"  {mark:6s} {label:38s} {val:>10,}   ({how})")
    for label, val, other, f in stale:
        print(f"\n  NEAR-MISS  {label}: tree says {val:,}, prose carries {other:,} in {f}")
    if absent or stale:
        print(f"\ndocs figures: {len(absent)} figure(s) NO LONGER APPEAR in prose.")
        print("Either the tree moved and the documentation was not updated, or the claim")
        print("was dropped. Both need a human; a silently dropped claim is not a correction.")
        sys.exit(1 if "--check" in sys.argv else 0)
    print(f"\ndocs figures: clean -- all {len(figs)} cross-cutting figures still match the tree")
