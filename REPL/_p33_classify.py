#!/usr/bin/env python3
"""P3.3 residue classifier — WHY each remaining guard is unpinned, not just that it is.

Run from REPL/:  python3 _p33_classify.py

SEE ALSO `_cheapseam.py`, which predates this and goes deeper on ONE of the buckets below: it lists
the plain-callable guards (bucket D) ranked by how many enforces sit ABOVE the target in the same
function. Use that to pick the next guard; use this to decide whether picking one is worth it at
all. This script's contribution is the PARTITION -- how much of the residue is reachable by any
means -- not the per-guard detail.

Written after a pass that produced one pin from a full budget. At that point the useful question
stopped being "which guard next" and became "which of these are reachable AT ALL". The buckets:

  A  protected body (XI_/XB_/XE_ with require-capability)
       Reachable only from inside its own module's capability scope -- structurally unpinnable
       by a negative test.

  B  REPL-only helper
       Post-condition self-checks in REPL_Bootstrap*. Trippable only by breaking the function
       under them. Good assertions; not coverage.

  C  @event defcap
       test-capability CANNOT acquire these -- Pact takes the install path and fails with
       "capability is not managed and cannot be installed". Reachable ONLY through the Talos
       client wrapper, which costs one real client call each (fees, signatures, state).

  D  ordinary function (UEV_/UCv_/URCv_/URC_/UC_)
       Directly callable. Whatever blocks these is STATE, not access -- the cheapest bucket, and
       the one worth checking fixture availability for BEFORE probing (an ANK sweep cost a whole
       pass discovering its boost classes live in a suite the tester does not load).

  E  non-@event capability
       Acquirable directly with test-capability. If one of these is unpinned it is because its
       guard sits behind a table read needing a real row.

The bucket sizes are the point: they say what KIND of work the remainder is, and therefore whether
more grinding is worth it.
"""
import re, subprocess, os, collections
ROOT=".."
out=subprocess.run(["python3","_enforce_coverage.py","--list"],capture_output=True,text=True).stdout
rows=[];lines=out.split("\n")
for i,l in enumerate(lines):
    m=re.match(r'^  (1_SOVEREIGN|2_CITIZEN)(/\S+?):(\d+)\s+(\S.*)$', l)
    if m: rows.append((m.group(1)+m.group(2), int(m.group(3)), m.group(4).strip(),
                       lines[i+1].strip() if i+1<len(lines) else ""))
def strip_c(src):
    o=[];i=0;n=len(src);ins=False;esc=False
    while i<n:
        c=src[i]
        if ins:
            o.append(c)
            if esc: esc=False
            elif c=='\\': esc=True
            elif c=='"': ins=False
            i+=1
        elif c=='"': ins=True;o.append(c);i+=1
        elif c==';':
            while i<n and src[i]!='\n': o.append(' ');i+=1
        else: o.append(c);i+=1
    return ''.join(o)
CACHE={}
def blocks(path):
    if path in CACHE: return CACHE[path]
    src=strip_c(open(os.path.join(ROOT,path),encoding='utf8',errors='ignore').read())
    best={}
    for m in re.finditer(r'\((defun|defcap)\s+([A-Za-z0-9|_>-]+)', src):
        i=m.start();d=0;j=i
        while j<len(src):
            if src[j]=='(': d+=1
            elif src[j]==')':
                d-=1
                if d==0:
                    b=src[i:j+1]
                    if m.group(2) not in best or len(b)>len(best[m.group(2)]): best[m.group(2)]=b
                    break
            j+=1
    CACHE[path]=best; return best
cat=collections.Counter(); detail=collections.defaultdict(list)
for path,line,owner,msg in rows:
    if "00_DPMF" in path: continue
    nm=owner.split(':')[0]; b=blocks(path).get(nm,"")
    local=nm.split('|')[-1]
    if re.match(r'^(XI|XB|XE)v?_', local) and 'require-capability' in b:
        k="A · protected body (needs SECURE in-module)"
    elif re.match(r'^REPL_', local):
        k="B · REPL-only helper"
    elif '@event' in b.split('(let')[0]:
        k="C · @event defcap (Talos client path only)"
    elif re.match(r'^(UEV|UCv|URCv|URC|UC)_', local):
        k="D · ordinary function — reachable, needs state"
    else:
        k="E · non-event cap — test-capability reachable"
    cat[k]+=1; detail[k].append(f"{os.path.basename(path)}:{line} {nm}")
for k in sorted(cat): print(f"{cat[k]:4}  {k}")
print()
for x in detail["E · non-event cap — test-capability reachable"][:14]: print("   E:",x)
