#!/usr/bin/env python3
"""Can an agent actually REACH the guidance this repo tells it to follow?

    python3 REPL/tools/_skillreach.py            report
    python3 REPL/tools/_skillreach.py --check    exit 1 on a dangling CLAUDE.md path or a new orphan
    python3 REPL/tools/_skillreach.py --selftest prove both checks catch what they claim to

THE GAP THIS CLOSES.  Exactly ONE file is loaded automatically in this repo: CLAUDE.md.  Every other
piece of guidance -- StoicSyntax, the conventions, HOW-DEPLOY-ROUNDS-WORK, the AQP-INFO procedure --
is reached only by following a reference from it, transitively.  So a reference that does not resolve
does not degrade the guidance, it DELETES it, and nothing fails.

Measured 2026-10-25, before this tool existed: of 217 .md files under OuronetInformational/, **79
were reachable from CLAUDE.md and 138 were not.**  Most of that is archive by design.  But three of
CLAUDE.md's own explicit paths were dead -- including the one in the sentence that states the
interface CASCADE RULE and then says *"Details: ARCHITECTURE/INTERFACE_VERSIONING.md"*.  That file
had moved to ouronet/architecture/ in a reorganisation CLAUDE.md was never updated for.  The cascade
rule is the single thing the V13 round got wrong five times running.  Its detail doc had been
unreachable the whole time, and no check in the repo could see that.

WHY `_docslinks.py` DOES NOT COVER THIS, even though it names OuronetInformational.  That tool
validates references ORIGINATING in OuronetDocumentation/ and treats OuronetInformational merely as a
legitimate DESTINATION.  It never scans CLAUDE.md.  And -- deliberately, correctly for prose -- it
resolves BY BASENAME across trees, so `ARCHITECTURE/INTERFACE_VERSIONING.md` would have resolved to
the moved file and been reported FINE.

    CLAUDE.md IS INSTRUCTIONS, NOT PROSE.

An agent told to read a path runs that path.  A basename that happens to exist somewhere else is no
help to it.  So CHECK 1 resolves CLAUDE.md's paths LITERALLY, which is the one place in this repo
where permissive resolution is the wrong answer.

CHECK 2 is reachability, and it is a WARNING WITH A REGISTRY rather than a hard rule, because
"unreferenced" and "wrong" are different things.  Two orphans here are unreferenced ON PURPOSE and
must stay that way: LIVE-INTERFACE-VERSIONS.md is a cached 2026-08-30 snapshot of what was live, its
own header records that a wrong bump map was built from it, and CLAUDE.md now carries the rule "never
cache what is live" -- wiring it into the load order would REINTRODUCE the V13 failure.  So the
registry records WHY each accepted orphan is out, and an UNREGISTERED new orphan is the finding.

The registry also detects its own rot, which `_patronslots.py` had to learn the hard way (CLAUDE.md
records five of its entries outliving their sites): an entry naming a file that no longer exists is
reported, because a stale excuse is inherited by whatever takes that path next.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INFO = os.path.join(ROOT, "OuronetInformational")
ENTRY = os.path.join(ROOT, "CLAUDE.md")

# Archive directories: CLAUDE.md names the DIRECTORY and the files are write-mostly captures.
# Not orphans in any meaningful sense -- a dated memory is not meant to be individually linked.
ARCHIVE_DIRS = ("memories", "HANDOFFS", "kursan", "agents")

# GENERATED artefacts are not guidance, and the definition of "generated" is IMPORTED rather than
# restated. Two tools each keeping their own copy of this set is how they come to disagree -- the
# same reason _authsurface.strip_code is shared and never re-implemented. _skillindex.py owns it
# because it is the tool that must exclude them from the catalogue.
try:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from _skillindex import GENERATED as _GEN
except Exception:                                     # pragma: no cover - tool must still report
    _GEN = set()

# Accepted orphans. Key = path relative to OuronetInformational. Value = why it is NOT linked.
# An entry whose file has vanished is reported (see the docstring on registry rot).
# NOTE on two files that USED to be registered here and no longer need to be:
# LIVE-INTERFACE-VERSIONS.md and DEPLOY-READY-GATE.md now carry SUPERSEDED banners and are NAMED by
# CLAUDE.md, so they are reachable -- and reachable-via-a-warning beats unreachable, because a
# reader following the link lands on the banner. registered_but_reachable() caught both within an
# hour of being written. Their exclusion from the LOAD ORDER is still deliberate: do not add either
# to SKILL.md.
ACCEPTED_ORPHANS = {
    # EMPTY, AND THAT IS THE RESULT, NOT AN OVERSIGHT. Until 2026-10-25 this carried THIRTEEN
    # entries -- thirteen written excuses for guidance nothing pointed at. Generating
    # SKILL-INDEX.md from the tree made every one obsolete in a single step, and
    # registered_but_reachable() reported them rather than letting them sit. An exemption list is
    # what you maintain while capture is MANUAL; once capture is automatic, the list is the only
    # thing left that can rot.
    #
    # Add an entry only for a document that must NOT be reachable at all. If you are reaching for
    # one because a doc feels "not important enough to index", that is the wrong tool: write its
    # `<!-- purpose: ... -->` line and let _skillindex.py catalogue it.
}



# Paths CLAUDE.md quotes in order to say they are WRONG. A doc that teaches by naming the
# mistake will cite a path that must not resolve -- flagging those trains the reader to ignore
# this tool, which is the only way a checker actually fails. Same rot rule as ACCEPTED_ORPHANS:
# an entry whose quote has left CLAUDE.md is reported.
QUOTED_AS_WRONG = {
    "tools/_toolindex.py":
        "cited as the WRONG path by the 2026-09-16 correction at the same line, whose point is "
        "that the generator lives in REPL/tools/. It must NOT resolve.",
}

MD_REF = re.compile(r'`([A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:md|py|json|mjs|sh))`')
ANY_MD = re.compile(r'[\w./-]*?([\w.-]+\.md)')


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def claude_dangling(entry=ENTRY, root=ROOT, info=INFO):
    """CHECK 1 -- every explicit PATH reference in CLAUDE.md must resolve AS WRITTEN.

    A reference carrying a directory component is unambiguous: the agent will use it verbatim.
    Bare basenames are skipped on purpose -- `Z.repl` means REPL/Z.repl to a reader and resolving
    those would reproduce _docslinks.py's permissiveness in the one place it does not belong.
    Two roots are legitimate: the repo, and OuronetInformational (the doc list cites `ouronet/...`
    and `IGNIS-PRICING/...` relative to it).
    """
    out = []
    text = read(entry)
    for ref in sorted(set(MD_REF.findall(text))):
        if "/" not in ref:
            continue
        if any(os.path.exists(os.path.join(base, ref)) for base in (root, info)):
            continue
        if ref in QUOTED_AS_WRONG:
            continue
        line = next((i for i, l in enumerate(text.splitlines(), 1) if ref in l), 0)
        out.append((ref, line))
    return out


def reachable(entry=ENTRY, info=INFO):
    """CHECK 2 -- transitive closure of .md references starting at CLAUDE.md."""
    allmd = set()
    for r, _, fs in os.walk(info):
        for f in fs:
            if f.endswith(".md"):
                allmd.add(os.path.normpath(os.path.join(r, f)))
    by_base = {}
    for p in allmd:
        by_base.setdefault(os.path.basename(p), set()).add(p)

    def refs(path):
        hits = set()
        for m in ANY_MD.finditer(read(path)):
            frag, name = m.group(0), m.group(1)
            cands = set(by_base.get(name, ()))
            if len(cands) > 1:
                exact = {p for p in cands
                         if p.replace("\\", "/").endswith(frag.lstrip("./"))}
                cands = exact or cands
            hits |= cands
        return hits - {os.path.normpath(path)}

    seen = refs(entry)
    frontier = list(seen)
    while frontier:
        nxt = []
        for p in frontier:
            for q in refs(p):
                if q not in seen:
                    seen.add(q)
                    nxt.append(q)
        frontier = nxt
    return allmd, seen & allmd


def classify(allmd, reach, info=INFO):
    orphans = []
    for p in sorted(allmd - reach):
        rel = os.path.relpath(p, info).replace("\\", "/")
        if rel.split("/")[0] in ARCHIVE_DIRS:
            continue
        if rel in _GEN:
            continue
        orphans.append(rel)
    new = [o for o in orphans if o not in ACCEPTED_ORPHANS]
    stale = [k for k in sorted(ACCEPTED_ORPHANS)
             if not os.path.exists(os.path.join(info, k))]
    return orphans, new, stale


def registered_but_reachable(orphans):
    """An ACCEPTED_ORPHANS entry for a file that something now points at.

    The symmetric half of rot detection, and it fired the hour it was written: documenting in
    CLAUDE.md *why* LIVE-INTERFACE-VERSIONS.md must stay unlinked NAMED it, which made it
    reachable -- so its 'deliberately unlinked' excuse stopped describing reality. Reachable via a
    SUPERSEDED warning is a better outcome than unreachable, but an excuse that no longer applies
    is exactly what the _patronslots.py lesson is about: the next file to take that path inherits
    it. Checking only that the FILE still exists would have missed this entirely.
    """
    return [k for k in sorted(ACCEPTED_ORPHANS) if k not in orphans]


def stale_wrong_quotes(entry=ENTRY):
    """A QUOTED_AS_WRONG entry whose quote has left CLAUDE.md is an excuse with no sentence."""
    text = read(entry)
    return [k for k in sorted(QUOTED_AS_WRONG) if k not in text]


def main():
    check = "--check" in sys.argv
    if "--selftest" in sys.argv:
        return selftest()

    dangling = claude_dangling()
    allmd, reach = reachable()
    orphans, new, stale = classify(allmd, reach)

    print(f"skillreach: {len(allmd)} .md under OuronetInformational/ -- "
          f"{len(reach)} reachable from CLAUDE.md, {len(orphans)} non-archive orphan(s)")

    bad = False
    if dangling:
        bad = True
        print("\nDANGLING CLAUDE.md PATH(S) -- an agent told to read these reads nothing:")
        for ref, line in dangling:
            print(f"   CLAUDE.md:{line}  {ref}")
        print("   Fix the path, or move the file back. A basename that exists elsewhere is NOT a fix:")
        print("   CLAUDE.md is instructions, and the agent uses the path as written.")
    else:
        print("  ok   every explicit CLAUDE.md path resolves as written")

    if new:
        bad = True
        print("\nUNREGISTERED ORPHAN(S) -- guidance nothing reachable points at:")
        for o in new:
            print(f"   {o}")
        print("   Either link it (SKILL.md load order / INDEX.md), or add a reasoned")
        print("   ACCEPTED_ORPHANS entry. Unreachable guidance is deleted guidance.")
    else:
        print(f"  ok   all {len(orphans)} non-archive orphan(s) are registered with a reason")

    linked = registered_but_reachable(orphans)
    if linked:
        bad = True
        print("\nREGISTERED AS ORPHAN BUT NOW REACHABLE -- the excuse no longer applies:")
        for k in linked:
            print(f"   {k}")
        print("   Something points at this now. Drop the ACCEPTED_ORPHANS entry; a stale excuse")
        print("   is inherited by the next file to take that path.")

    gone = stale_wrong_quotes()
    if gone:
        bad = True
        print("\nSTALE QUOTED_AS_WRONG ENTRY(S) -- CLAUDE.md no longer quotes this path:")
        for k in gone:
            print(f"   {k}")
        print("   Remove the entry, or the next real dangling path at that name is excused.")

    if stale:
        bad = True
        print("\nSTALE ACCEPTED_ORPHANS ENTRY(S) -- registered file no longer exists:")
        for k in stale:
            print(f"   {k}")
        print("   Remove the entry. A written excuse with no file is inherited by the next")
        print("   file to take that path -- the _patronslots.py lesson, in CLAUDE.md.")

    if check and bad:
        return 1
    if not bad:
        print("\nskillreach: clean -- the guidance CLAUDE.md names is reachable.")
    return 0


def selftest():
    """Prove both checks FAIL when they should. A check never seen to fail is not known to work."""
    import tempfile
    ok = True

    with tempfile.TemporaryDirectory() as d:
        fake = os.path.join(d, "CLAUDE.md")
        with open(fake, "w", encoding="utf-8") as fh:
            fh.write("see `OuronetInformational/nope/does-not-exist.md` for details\n")
        got = claude_dangling(entry=fake)
        print(f"  {'ok  ' if got else 'FAIL'} check 1 flags a dangling explicit path  ({len(got)} found)")
        ok &= bool(got)

        with open(fake, "w", encoding="utf-8") as fh:
            fh.write("see `OuronetInformational/SKILL.md` for details\n")
        got = claude_dangling(entry=fake)
        print(f"  {'ok  ' if not got else 'FAIL'} check 1 passes a path that resolves  ({len(got)} found)")
        ok &= not got

    with tempfile.TemporaryDirectory() as d:
        hub = os.path.join(d, "CLAUDE.md")
        inf = os.path.join(d, "OuronetInformational")
        os.makedirs(os.path.join(inf, "memories"))
        with open(hub, "w", encoding="utf-8") as fh:
            fh.write("read `OuronetInformational/linked.md`\n")
        for name in ("linked.md", "stranded.md"):
            with open(os.path.join(inf, name), "w", encoding="utf-8") as fh:
                fh.write("# x\n")
        with open(os.path.join(inf, "memories", "2026-01-01-note.md"), "w", encoding="utf-8") as fh:
            fh.write("# archived\n")
        allmd, reach = reachable(entry=hub, info=inf)
        orphans, _, _ = classify(allmd, reach, info=inf)
        hit = orphans == ["stranded.md"]
        print(f"  {'ok  ' if hit else 'FAIL'} check 2 finds the orphan and excludes archive  (got {orphans})")
        ok &= hit

    print("\nselftest:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
