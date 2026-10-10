#!/usr/bin/env python3
"""Carry the generated price sheet's two tallies into IGNIS-PRICING.md's prose.

`_pricesync.py --check` regenerates the sheet and then checks that the hand-written
narrative quotes its tally line and its Talos client-function total. Both move whenever a
priced op is added, and both are fatal in the gate. Driven off the checker's own output so
the prose cannot disagree with the artefact the gate trusts.
"""
import io, re, subprocess
ROOT="/home/ancientbox/ClaudeWS/OuroborosNetwork/_onchain/Ouronet"
DOC=ROOT+"/OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md"
out=subprocess.run(["python3","REPL/tools/_pricesync.py","--check"],cwd=ROOT,
                   capture_output=True,text=True).stdout
tally=re.search(r"expected line:\s*(.+)$", out, re.M)
total=re.search(r"Talos client-function total \((\d+)\)", out)
if not tally and not total:
    print("pricing prose: no drift"); raise SystemExit(0)
s=io.open(DOC,encoding="utf-8").read(); n=0
if tally:
    want=tally.group(1).strip()
    # the narrative carries ONE line of the shape "N exact  ·  N floor  ·  ..."
    pat=re.compile(r"^\d+ exact\s+·\s+\d+ floor\s+·.*$", re.M)
    s=pat.sub(lambda m: want, s)
    n+=1
if total:
    s=re.sub(r"(\*\*)\d+(\*\* Talos client functions carry a price)", r"\g<1>"+total.group(1)+r"\g<2>", s)
    n+=1
io.open(DOC,"w",encoding="utf-8").write(s)
print("pricing prose: updated %d item(s)" % n)
