#!/usr/bin/env python3
"""Regenerate TOOLS.md — an index of every REPL analysis script, from its first docstring line.

Exists because the same tools keep getting rebuilt. Run after adding one:

    python3 REPL/tools/_toolindex.py

PATHS ARE RESOLVED FROM __file__, NOT FROM THE CURRENT DIRECTORY (2026-09-14). They used to be
cwd-relative -- `glob.glob("_*.py")` -- which was correct for exactly as long as the tools sat in
REPL/ and were run from REPL/. The move to REPL/tools/ turned that glob into a match against an
empty directory, and this script's failure mode is the dangerous one: it did not error, it wrote a
TOOLS.md containing ZERO rows and printed "indexed 0 tools". Caught only by diffing every tool's
output across the move. A path that is right by coincidence of working directory is a latent break.
"""
import ast, glob, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))           # REPL/tools
REPL = os.path.dirname(HERE)                                # REPL
rows=[]
for f in sorted(glob.glob(os.path.join(HERE, "_*.py"))):
    src=open(f,encoding='utf8',errors='ignore').read()
    # FIRST NON-EMPTY LINE OF THE MODULE DOCSTRING, VIA ast (2026-09-16). This used to be
    # `re.search(r'"""(.*?)(?:\n|""")')` -- "the first docstring line" -- which stops at the first
    # NEWLINE. For the ordinary style where `"""` is followed by a newline and the text starts on
    # the line below, the captured group is EMPTY, and `one or "(no docstring)"` then printed a
    # confident lie. THIRTEEN of the tools indexed here are written that way, including _redteam.py,
    # _fvtgen.py and _fvtfacade.py -- and TOOLS.md is what CLAUDE.md tells you to read INSTEAD of
    # running a tool to find out what it does, so the failure degraded the control that replaced
    # the dangerous behaviour. Same silent-degradation class as the zero-rows bug in the docstring
    # above: a confident wrong answer where the extraction, not the tool, was empty.
    # `ast` rather than a looser regex because a regex scanning for the first `"""` anywhere in the
    # file will happily report some FUNCTION's docstring as the tool's purpose when the module has
    # none. A parse failure is reported loudly instead of silently becoming "(no docstring)".
    try:
        doc = ast.get_docstring(ast.parse(src)) or ""
        one = next((l.strip() for l in doc.splitlines() if l.strip()), "")[:118]
    except SyntaxError as e:
        one = f"(UNPARSEABLE: {e.__class__.__name__} line {e.lineno})"
    rows.append(("tools/" + os.path.basename(f), one or "(no docstring)"))
_md=os.path.join(REPL, "TOOLS.md")
hdr=open(_md,encoding='utf8').read().split("| script |")[0] if os.path.exists(_md) else ""
# The header carried a HAND-WRITTEN count ("There are 33 here") while the table below it listed 44.
# A number a human maintains next to a number a script generates will drift, and the drifted one
# reads exactly as authoritative. Rewrite it from the same list that builds the table.
hdr=re.sub(r'There are \d+ here', f'There are {len(rows)} here', hdr)
body="| script | what it answers |\n|---|---|\n" + "\n".join(f"| `{f}` | {d} |" for f,d in rows)
_out = hdr + body + "\n"

# --check, added 2026-09-18. TOOLS.md had drifted to 50 rows against 53 tools on disk, and the
# three missing ones -- _auditbook, _booktables, _modref -- are all GATE-FATAL. An index that omits
# a mandatory check is worse than no index: CLAUDE.md tells a reader to consult TOOLS.md instead of
# running a tool to find out what it does, so a missing row sends them to run it.
if "--check" in sys.argv:
    cur = open(_md, encoding='utf8').read() if os.path.exists(_md) else ""
    if cur != _out:
        print(f"TOOLS.md is STALE: {len(rows)} tools on disk, index does not match.")
        print("Regenerate with: python3 REPL/tools/_toolindex.py")
        sys.exit(1)
    print(f"tool index: clean -- {len(rows)} tools, every one indexed")
    sys.exit(0)

open(_md,"w",encoding='utf8').write(_out)
print(f"indexed {len(rows)} tools")
