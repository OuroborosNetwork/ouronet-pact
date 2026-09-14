#!/usr/bin/env python3
"""_fvtcut.py — remove the RPS-exclusive defs/tables/schemas from 04_FVT.pact (in place)."""
import importlib.util, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
F='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
s=open(F).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
RPS_TBL={'FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount','FVT|T|ScoreEntityLink','FVT|T|UserPresence','FVT|T|MultipletFamily','FVT|T|RewardAggregate','FVT|T|QualitySplit','FVT|T|AgencyFee','FVT|T|DsaOracleConfig'}
FVT_TBL={'FVT|T','FVT|T|VacateFreeze','FVT|T|SweepProgress'}
i=0
while not(toks[i][0]=='atom' and s[toks[i][1]:toks[i][2]]=='module'): i+=1
mo=i-1
while toks[mo][0]!='(': mo-=1
mc=match[mo]
members={}; st=[]
for idx in range(mo,mc+1):
    if toks[idx][0]=='(':
        st.append(idx)
        if len(st)==2:
            j=idx+1
            while toks[j][0]=='ws': j+=1
            h=s[toks[j][1]:toks[j][2]] if toks[j][0]=='atom' else ''
            if h in ('defun','defcap','defpact'):
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                members[s[toks[jj][1]:toks[jj][2]].split(':',1)[0]]=(idx,match[idx])
    elif toks[idx][0]==')':
        if st: st.pop()
names=set(members); direct={}; calls={}
for n,(ot,ct) in members.items():
    at=[s[toks[k][1]:toks[k][2]] for k in range(ot,ct+1) if toks[k][0]=='atom']
    direct[n]=set(a for a in at if a in RPS_TBL or a in FVT_TBL); calls[n]=set(a for a in at if a in names and a!=n)
def clo(n,seen):
    if n in seen: return set()
    seen.add(n); t=set(direct[n])
    for c in calls[n]: t|=clo(c,seen)
    return t
def dom(t):
    r=any(x in RPS_TBL for x in t); f=any(x in FVT_TBL for x in t)
    return 'SEAM' if r and f else 'RPS' if r else 'FVT' if f else 'FREE'
cls={n:dom(clo(n,set())) for n in members}
rps=[n for n in members if cls[n]=='RPS' and not n.startswith(('C_','CC_','CCp_','A_','AA_'))]
# move-only FREE = FREE reached only by RPS
seen=set()
def coll(n):
    for c in calls[n]:
        if c not in seen: seen.add(c); coll(c)
for n in rps: coll(n)
nonrps=set()
def coll2(n):
    for c in calls[n]:
        if c not in nonrps: nonrps.add(c); coll2(c)
for n in members:
    if cls[n] in ('FVT','SEAM'): coll2(n)
free_moveonly=[c for c in seen if cls.get(c)=='FREE' and c not in nonrps]
DELETE=set(rps)|set(free_moveonly)
# spans to cut: functions + 7 table schemas + 7 deftables
cuts=[]
for n in DELETE:
    cuts.append(members[n])
# schemas + tables via span search
def span(kind,name):
    stk=[]
    for idx in range(mo,mc+1):
        if toks[idx][0]=='(':
            stk.append(idx)
            if len(stk)==2:
                j=idx+1
                while toks[j][0]=='ws': j+=1
                if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]==kind:
                    jj=j+1
                    while toks[jj][0]=='ws': jj+=1
                    if s[toks[jj][1]:toks[jj][2]].split(':',1)[0]==name:
                        return (idx,match[idx])
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None
for sc in ['FVT|RPS|Global','FVT|RPS|Member','FVT|RPS|User','FVT|RPS|Stream','FVT|MemberVault','FVT|MemberUserWeight','FVT|ForcedFixCount','FVT|RewardAggregate','FVT|ScoreEntityLink','FVT|MultipletFamily','FVT|UserPresence','FVT|AgencyFee','FVT|QualitySplit','FVT|DsaOracleConfig']:
    sp=span('defschema',sc);  cuts.append(sp) if sp else None
for tb in sorted(RPS_TBL):
    sp=span('deftable',tb);   cuts.append(sp) if sp else None
# convert token spans to char ranges, remove (with trailing newline), right-to-left
ranges=sorted(((toks[o][1], toks[c][2]) for o,c in cuts), reverse=True)
out=s
for a,b in ranges:
    # extend b to end of line
    nl=out.find('\n',b)
    if nl!=-1 and out[b:nl].strip()=='': b=nl+1
    # trim leading indent on the line
    ls=out.rfind('\n',0,a)+1
    if out[ls:a].strip()=='': a=ls
    out=out[:a]+out[b:]
# also remove the 7 create-table lines
out=re.sub(r'^\(create-table (FVT\|T\|RPS\|Global|FVT\|T\|RPS\|Member|FVT\|T\|RPS\|User|FVT\|T\|RPS\|Stream|FVT\|T\|MemberUserWeight|FVT\|T\|MemberVault|FVT\|T\|ForcedFixCount)\).*\n', '', out, flags=re.M)
open(F,'w').write(out)
print(f"deleted {len(DELETE)} fns ({len(rps)} RPS + {len(free_moveonly)} move-only-FREE) + 7 schemas + 7 tables + 7 create-tables")
print("move-only FREE:", free_moveonly)
print("new FVT line count:", out.count('\n'))
