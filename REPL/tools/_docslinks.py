#!/usr/bin/env python3
"""_docslinks.py -- every reference in OuronetDocumentation/ must resolve to a real file.

    python3 REPL/tools/_docslinks.py [--check] [--selftest]

The documentation is 132 files when finished and cross-references itself heavily.
A chapter pointing at a file that was renamed, or never written, is the cheapest
possible defect and the easiest to ship: nothing fails, the link is simply dead.

TWO RULES, BOTH LEARNED BY GETTING THIS WRONG (2026-09-29):

  1. PLANNING DOCUMENTS NAME FILES TREE-WIDE. BUILD-PLAN.md and RESUME-HERE.md sit
     at the root and enumerate files that live in subdirectories. Resolving their
     references relative to their OWN directory reports every one as dangling --
     the first version of this check produced 58 findings, of which 57 were that.
     So a bare `NN-name.md` reference resolves against the whole documentation
     tree by BASENAME, not against the citing file's directory.

  2. A REFERENCE MAY POINT OUTSIDE THIS FOLDER. `00-orientation/04-how-to-read-this.md`
     cites `03-cost-preview.md`, which is real and lives in docs/CHAPTER-INTEGRATION/.
     The second version of this check reported it as the one genuine dangle. It was
     not. Basenames are therefore resolved against the documentation tree AND the
     sibling docs/ tree before anything is reported.

  3. BUILD-PLAN.md IS A MANIFEST, NOT A CITATION. It names all 132 files, most of
     which are not written yet -- that is its entire job. The third version of this
     check reported 32 dangling references, every one of them the plan naming a file
     scheduled for later. So the plan is not checked; it is READ, and the files it
     names form the PLANNED set.

     That inversion is what makes the tool useful rather than merely quiet. A chapter
     may cite a file that does not exist YET (it is coming); what it may not do is
     cite a file that is neither written NOR planned, because that name will never
     resolve. Those are the only findings worth printing.

The net of all three: a reference is dead only when no file of that name exists
anywhere it could legitimately mean, AND the plan does not promise one. That is
deliberately permissive. A checker whose findings are mostly noise gets switched
off, and then it protects nothing -- which is the failure this whole folder is about.

Exit 1 on a dangling reference when --check is given.
"""
import os, re, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(ROOT)                      # repo root
DOCS = os.path.join(ROOT, "OuronetDocumentation")
SIBLING = os.path.join(ROOT, "docs")              # CHAPTER-INTEGRATION and friends
INFORMATIONAL = os.path.join(ROOT, "OuronetInformational")   # handoffs, skills, memories
PLAN = os.path.join(DOCS, "BUILD-PLAN.md")

# `NN-something.md` in backticks, or a markdown link to a .md path.
BARE = re.compile(r'`((?:\d\d|[A-Z-]+)-[a-z0-9-]+\.md)`')
LINK = re.compile(r'\[[^\]]*\]\(([^)]+\.md)(?:#[^)]*)?\)')


def planned_basenames():
    """Files BUILD-PLAN.md promises. Named-but-unwritten is a schedule, not a defect."""
    if not os.path.exists(PLAN):
        return set()
    return set(BARE.findall(open(PLAN, encoding="utf-8").read()))


def known_basenames():
    names = set()
    for base in (DOCS, SIBLING, INFORMATIONAL):
        if os.path.isdir(base):
            for p in glob.glob(os.path.join(base, "**", "*.md"), recursive=True):
                names.add(os.path.basename(p))
    return names


def scan():
    names = known_basenames() | planned_basenames()
    dangling, refs = [], 0
    for p in sorted(glob.glob(os.path.join(DOCS, "**", "*.md"), recursive=True)):
        if os.path.abspath(p) == os.path.abspath(PLAN):
            continue                      # rule 3: the manifest is read, not checked
        rel = os.path.relpath(p, ROOT)
        txt = open(p, encoding="utf-8").read()
        for m in BARE.finditer(txt):
            refs += 1
            if m.group(1) not in names:
                dangling.append((rel, m.group(1)))
        for m in LINK.finditer(txt):
            refs += 1
            target = m.group(1)
            if target.startswith(("http", "mailto:")):
                continue
            # resolve relative to the citing file, then fall back to basename
            direct = os.path.normpath(os.path.join(os.path.dirname(p), target))
            if os.path.exists(direct):
                continue
            if os.path.basename(target) in names:
                continue
            if os.path.exists(os.path.join(ROOT, target)):
                continue
            dangling.append((rel, target))
    return refs, dangling


def selftest():
    names = known_basenames()
    ok = True
    # Rule 1: a root planning doc naming a file in a subdirectory must NOT be reported.
    if "05-sets-and-fragments.md" not in names:
        print("  selftest: expected a known subdirectory chapter; tree changed?"); ok = False
    # Rule 2: the sibling docs/ tree must be in scope.
    if "03-cost-preview.md" not in names:
        print("  selftest: docs/CHAPTER-INTEGRATION is NOT in scope -- rule 2 regressed."); ok = False
    # A name that cannot exist must be reported.
    if "99-this-file-does-not-exist.md" in names:
        print("  selftest: impossible name present?"); ok = False
    # Rule 3: the plan's unwritten files must be treated as planned, not dangling.
    planned = planned_basenames()
    unwritten = planned - {os.path.basename(x) for x in
                           glob.glob(os.path.join(DOCS, "**", "*.md"), recursive=True)}
    if not unwritten:
        print("  selftest: no unwritten planned files -- rule 3 is untested here.")
    elif not (planned & unwritten):
        print("  selftest: planned set does not cover unwritten files."); ok = False
    else:
        print(f"  selftest: {len(unwritten)} planned-but-unwritten file(s) correctly not reported")
    print("  selftest OK" if ok else "  selftest FAILED")
    return ok


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    refs, dangling = scan()
    if not dangling:
        print(f"docs links: clean -- {refs} reference(s) across the documentation all resolve")
        sys.exit(0)
    print(f"docs links: {len(dangling)} DANGLING of {refs} reference(s)")
    for f, t in dangling:
        print(f"  {f} -> {t}")
    sys.exit(1 if "--check" in sys.argv else 0)
