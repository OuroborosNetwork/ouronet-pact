#!/usr/bin/env python3
"""Regenerate TOOLS.md — an index of every REPL analysis script, from its first docstring line.

Exists because the same tools keep getting rebuilt. Run after adding one:

    python3 tools/_toolindex.py

PATHS ARE RESOLVED FROM __file__, NOT FROM THE CURRENT DIRECTORY (2026-09-14). They used to be
cwd-relative -- `glob.glob("_*.py")` -- which was correct for exactly as long as the tools sat in
REPL/ and were run from REPL/. The move to REPL/tools/ turned that glob into a match against an
empty directory, and this script's failure mode is the dangerous one: it did not error, it wrote a
TOOLS.md containing ZERO rows and printed "indexed 0 tools". Caught only by diffing every tool's
output across the move. A path that is right by coincidence of working directory is a latent break.
"""
import glob, os, re
HERE = os.path.dirname(os.path.abspath(__file__))           # REPL/tools
REPL = os.path.dirname(HERE)                                # REPL
rows=[]
for f in sorted(glob.glob(os.path.join(HERE, "_*.py"))):
    src=open(f,encoding='utf8',errors='ignore').read()
    m=re.search(r'"""(.*?)(?:\n|""")', src, re.S)
    one=(m.group(1).strip() if m else "")[:118]
    rows.append(("tools/" + os.path.basename(f), one or "(no docstring)"))
_md=os.path.join(REPL, "TOOLS.md")
hdr=open(_md,encoding='utf8').read().split("| script |")[0] if os.path.exists(_md) else ""
# The header carried a HAND-WRITTEN count ("There are 33 here") while the table below it listed 44.
# A number a human maintains next to a number a script generates will drift, and the drifted one
# reads exactly as authoritative. Rewrite it from the same list that builds the table.
hdr=re.sub(r'There are \d+ here', f'There are {len(rows)} here', hdr)
body="| script | what it answers |\n|---|---|\n" + "\n".join(f"| `{f}` | {d} |" for f,d in rows)
open(_md,"w",encoding='utf8').write(hdr+body+"\n")
print(f"indexed {len(rows)} tools")
