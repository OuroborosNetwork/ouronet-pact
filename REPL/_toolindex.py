#!/usr/bin/env python3
"""Regenerate TOOLS.md — an index of every REPL analysis script, from its first docstring line.

Exists because the same tools keep getting rebuilt. Run after adding one:  python3 _toolindex.py
"""
import glob, os, re
rows=[]
for f in sorted(glob.glob("_*.py")):
    src=open(f,encoding='utf8',errors='ignore').read()
    m=re.search(r'"""(.*?)(?:\n|""")', src, re.S)
    one=(m.group(1).strip() if m else "")[:118]
    rows.append((f, one or "(no docstring)"))
hdr=open("TOOLS.md",encoding='utf8').read().split("| script |")[0] if os.path.exists("TOOLS.md") else ""
body="| script | what it answers |\n|---|---|\n" + "\n".join(f"| `{f}` | {d} |" for f,d in rows)
open("TOOLS.md","w",encoding='utf8').write(hdr+body+"\n")
print(f"indexed {len(rows)} tools")
