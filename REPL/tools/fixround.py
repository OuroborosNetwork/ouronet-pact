#!/usr/bin/env python3
"""Carry the gate's canonical assertion figures into Audit/records/REPL-ROUND-REPORT.md.

Driven off `_figuresync.py --check`'s OWN drift lines rather than off a second parse of
the stats file: the checker already names the label, the stale value and the correct one,
so this cannot disagree with the tool that is fatal in the gate. Replacing only within the
row that carries the label keeps the edit off every other figure in the file -- a blanket
replace across this report is how a figure that existed to CHECK another one got destroyed
earlier in this work.
"""
import io, re, subprocess
ROOT="/home/ancientbox/ClaudeWS/OuroborosNetwork/_onchain/Ouronet"
REPORT=ROOT+"/Audit/records/REPL-ROUND-REPORT.md"
out=subprocess.run(["python3","REPL/tools/_figuresync.py","--check"],cwd=ROOT,
                   capture_output=True,text=True).stdout
drift=re.findall(r"REPL-ROUND-REPORT\.md: '([^']+)' = ([\d,]+) but .*? says ([\d,]+)", out)
if not drift:
    print("round report: no drift"); raise SystemExit(0)
lines=io.open(REPORT,encoding="utf-8").read().split("\n")
n=0
for label, old, new in drift:
    key=label.replace("`","")
    for i,l in enumerate(lines):
        if key in l.replace("`","") and old in l:
            lines[i]=l.replace(old,new); n+=1; break
io.open(REPORT,"w",encoding="utf-8").write("\n".join(lines))
print("round report: synced %d row(s): %s" % (n, [(a,b,c) for a,b,c in drift]))
