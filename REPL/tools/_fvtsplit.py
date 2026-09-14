#!/usr/bin/env python3
"""
_fvtsplit.py — static manifest builder for the FVT → (RPS + FVT) extraction.

For every top-level defun/defcap in 04_FVT.pact:
  - direct table domain  = deftable-name atoms appearing in its body
  - transitive domain     = propagate over the intra-module call graph
Classifies each as RPS / FVT / SEAM (both) / FREE (neither), and flags any
RPS-classified function that DIRECTLY reads an FVT table (would break the DAG).
"""
import importlib.util, sys, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)

F='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
s=open(F).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)

RPS_TBL={'FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream',
         'FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount'}
FVT_TBL={'FVT|T','FVT|T|ScoreEntityLink','FVT|T|MultipletFamily','FVT|T|UserPresence',
         'FVT|T|AgencyFee','FVT|T|QualitySplit','FVT|T|DsaOracleConfig',
         'FVT|T|VacateFreeze','FVT|T|SweepProgress'}
POLICY={'P|T','P|MT'}
ALLTBL=RPS_TBL|FVT_TBL|POLICY

# locate the (module ...) span so we ignore the same-file interface decls
mod_open=None
for idx,(k,a,b) in enumerate(toks):
    if k=='(':
        j=idx+1
        while toks[j][0]=='ws': j+=1
        if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='module':
            mod_open=idx; break
mod_close=match[mod_open]

def bare(nm):                      # strip :type suffix (Pact type annotation)
    return nm.split(':',1)[0]

# collect module-body members: bare-name -> (open_tok, close_tok, kind)
members={}; order=[]
stack=[]
for idx in range(mod_open, mod_close+1):
    k=toks[idx][0]
    if k=='(':
        stack.append(idx)
        if len(stack)==2:
            j=idx+1
            while toks[j][0]=='ws': j+=1
            head=s[toks[j][1]:toks[j][2]] if toks[j][0]=='atom' else ''
            if head in ('defun','defcap','defpact'):
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                name=bare(s[toks[jj][1]:toks[jj][2]])
                members[name]=(idx, match[idx], head); order.append(name)
    elif k==')':
        if stack: stack.pop()

names=set(members)
# per-member: atoms in body -> direct tables + called member-names
direct={}; calls={}
for name,(ot,ct,kind) in members.items():
    body_atoms=[s[toks[i][1]:toks[i][2]] for i in range(ot,ct+1) if toks[i][0]=='atom']
    dt=set(a for a in body_atoms if a in ALLTBL)
    cl=set(a for a in body_atoms if a in names and a!=name)
    direct[name]=dt; calls[name]=cl

# transitive table closure over call graph
def closure(name, seen):
    if name in seen: return set()
    seen.add(name)
    t=set(direct[name])
    for c in calls[name]:
        t|=closure(c,seen)
    return t
trans={n:closure(n,set()) for n in members}

def domain(tbls):
    r=any(t in RPS_TBL for t in tbls); f=any(t in FVT_TBL for t in tbls)
    if r and f: return 'SEAM'
    if r: return 'RPS'
    if f: return 'FVT'
    return 'FREE'

cls={n:domain(trans[n]) for n in members}
# DAG hazard: an RPS-domain function that DIRECTLY touches an FVT table
hazard=[n for n in members if cls[n]=='RPS' and any(t in FVT_TBL for t in direct[n])]

from collections import Counter
c=Counter(cls.values())
print("=== classification (transitive) ===")
for k in ['RPS','FVT','SEAM','FREE']:
    print(f"  {k:5s}: {c.get(k,0)}")
print()
print("=== SEAM functions (touch BOTH domains — the XE_ boundary) ===")
for n in order:
    if cls[n]=='SEAM':
        rd=[t for t in direct[n] if t in RPS_TBL]; fd=[t for t in direct[n] if t in FVT_TBL]
        tag=[]
        if rd: tag.append('RPSdirect')
        if fd: tag.append('FVTdirect')
        print(f"  {n:42s} {','.join(tag) or 'via-calls'}")
print()
print("=== DAG HAZARD: RPS fns that directly read an FVT table (must arg-pass) ===")
print("  "+(", ".join(hazard) if hazard else "NONE — clean DAG"))
if len(sys.argv)>1 and sys.argv[1]=='list':
    print()
    for want in ['RPS','FVT','FREE']:
        print(f"=== {want} members ===")
        print("  "+" ".join(n for n in order if cls[n]==want))
