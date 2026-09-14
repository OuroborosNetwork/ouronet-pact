#!/usr/bin/env python3
"""_fvtflip.py — Stage 3 flip: cut RPS-domain from 04_FVT.pact, rewire calls to ref-RPS::,
insert ref-RPS module bindings. Writes 04_FVT.pact in place (back up first!)."""
import importlib.util, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
F='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
s=open(F).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
RPS_TBL={'FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount','FVT|T|ScoreEntityLink','FVT|T|UserPresence','FVT|T|MultipletFamily','FVT|T|RewardAggregate','FVT|T|QualitySplit','FVT|T|AgencyFee','FVT|T|DsaOracleConfig'}
FVT_TBL={'FVT|T','FVT|T|VacateFreeze','FVT|T|SweepProgress'}
SCHEMAS=['FVT|RPS|Global','FVT|RPS|Member','FVT|RPS|User','FVT|RPS|Stream','FVT|MemberVault','FVT|MemberUserWeight','FVT|ForcedFixCount','FVT|RewardAggregate','FVT|ScoreEntityLink','FVT|MultipletFamily','FVT|UserPresence','FVT|AgencyFee','FVT|QualitySplit','FVT|DsaOracleConfig']
i=0
while not(toks[i][0]=='atom' and s[toks[i][1]:toks[i][2]]=='module'): i+=1
mo=i-1
while toks[mo][0]!='(': mo-=1
mc=match[mo]
mem={}; order=[]; caps=set(); st=[]
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
                nm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]
                mem[nm]=(idx,match[idx]); order.append(nm)
                if h!='defun': caps.add(nm)
    elif toks[idx][0]==')':
        if st: st.pop()
names=set(mem); direct={}; calls={}; wtbl={}
for n,(ot,ct) in mem.items():
    at=[s[toks[k][1]:toks[k][2]] for k in range(ot,ct+1) if toks[k][0]=='atom']
    direct[n]=set(a for a in at if a in RPS_TBL or a in FVT_TBL)
    calls[n]=set(a for a in at if a in names and a!=n)
    w=False
    for k in range(ot,ct):
        tk=s[toks[k][1]:toks[k][2]] if toks[k][0]=='atom' else ''
        # (a) direct RPS-table write
        if tk in ('insert','update','write'):
            m2=k+1
            while m2<ct and toks[m2][0]=='ws': m2+=1
            if toks[m2][0]=='atom' and s[toks[m2][1]:toks[m2][2]] in RPS_TBL: w=True; break
        # (b) (require-capability (SECURE)) -> needs SECURE in scope, must be reached via SECURE-granting XE_
        if tk=='require-capability':
            m2=k+1
            while m2<ct and toks[m2][0]=='ws': m2+=1
            if m2<ct and toks[m2][0]=='(':
                m3=m2+1
                while m3<ct and toks[m3][0]=='ws': m3+=1
                if toks[m3][0]=='atom' and s[toks[m3][1]:toks[m3][2]]=='SECURE': w=True; break
    wtbl[n]=w
# transitive: n needs SECURE directly (RPS-table write / require SECURE) OR calls a fn that does -> needs XE_
_wd=dict(wtbl)
def _isw(n,seen):
    if n in seen: return False
    seen.add(n)
    if _wd.get(n): return True
    return any(_isw(c,seen) for c in calls.get(n,()))
wtbl={n:_isw(n,set()) for n in mem}
def clo(n,seen):
    if n in seen: return set()
    seen.add(n); t=set(direct[n])
    for c in calls[n]: t|=clo(c,seen)
    return t
def dom(t):
    r=any(x in RPS_TBL for x in t); f=any(x in FVT_TBL for x in t)
    return 'SEAM' if r and f else 'RPS' if r else 'FVT' if f else 'FREE'
cls={n:dom(clo(n,set())) for n in mem}
rps=[n for n in order if cls[n]=='RPS' and not n.startswith(('C_','CC_','CCp_','A_','AA_'))]
seen=set()
def coll(n):
    for c in calls[n]:
        if c not in seen: seen.add(c); coll(c)
for n in rps: coll(n)
nonrps=set()
def coll2(n):
    for c in calls[n]:
        if c not in nonrps: nonrps.add(c); coll2(c)
for n in mem:
    if cls[n] in ('FVT','SEAM'): coll2(n)
free_moveonly=[c for c in seen if cls.get(c)=='FREE' and c not in nonrps]
DELETE=set(rps)|set(free_moveonly)
# caps are module-scoped: keep any cap that a STAYING member still references (with/compose/require)
staying=set(mem)-DELETE
DELETE=set(n for n in DELETE if not (n in caps and any(n in calls[m] for m in staying)))
# writers that need XE_ (dynamic, non-XE, non-cap, direct RPS writer)
WRITERS=set(n for n in DELETE if wtbl.get(n) and not n.startswith('XE_') and n not in caps)

# --- 1. cut: delete moved defs + schemas + tables ---
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
                    if s[toks[jj][1]:toks[jj][2]].split(':',1)[0]==name: return (idx,match[idx])
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None
cuts=[mem[n] for n in DELETE]
# also remove moved members' declarations from the inline FVT interface (before the module)
io=None
for idx in range(mo):
    if toks[idx][0]=='(':
        j=idx+1
        while toks[j][0]=='ws': j+=1
        if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='interface': io=idx; break
if io is not None:
    ic=match[io]; istk=[]
    for idx in range(io,ic+1):
        if toks[idx][0]=='(':
            istk.append(idx)
            if len(istk)==2:
                j=idx+1
                while toks[j][0]=='ws': j+=1
                if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]] in ('defun','defcap','defpact'):
                    jj=j+1
                    while toks[jj][0]=='ws': jj+=1
                    inm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]
                    if inm in DELETE: cuts.append((idx,match[idx]))
        elif toks[idx][0]==')':
            if istk: istk.pop()
for sc in SCHEMAS:
    sp=span('defschema',sc); cuts.append(sp) if sp else None
for tb in RPS_TBL:
    sp=span('deftable',tb); cuts.append(sp) if sp else None
ranges=sorted(((toks[o][1], toks[c][2]) for o,c in cuts), reverse=True)
out=s
for a,b in ranges:
    nl=out.find('\n',b)
    if nl!=-1 and out[b:nl].strip()=='': b=nl+1
    ls=out.rfind('\n',0,a)+1
    if out[ls:a].strip()=='': a=ls
    out=out[:a]+out[b:]
# remove ALL create-table lines for moved tables
for tb in RPS_TBL:
    out=re.sub(r'^\(create-table '+re.escape(tb)+r'\).*\n','',out,flags=re.M)

# --- 2. rewire calls: moved fn -> ref-RPS::(XE_)fn  (defs are gone, so global replace is safe) ---
MOVED_CALLABLE=[n for n in DELETE if not n.startswith(('P|','GOV','SECURE','CT_')) and n not in caps]
for n in sorted(MOVED_CALLABLE,key=len,reverse=True):
    tgt=('ref-RPS::XE_'+n) if n in WRITERS else ('ref-RPS::'+n)
    out=re.sub(r'\('+re.escape(n)+r'(?=[\s)])','('+tgt,out)

# --- 2.5 duplicate schemas referenced by staying FVT but cut (structural types) ---
srefs=set(re.findall(r'\{(FVT\|[A-Za-z0-9|]+)\}',out))
sdef=set(re.findall(r'\(defschema\s+(FVT\|[A-Za-z0-9|]+)',out))
missing=sorted(srefs-sdef)
if missing:
    dparts=[]
    for m in missing:
        sp=span('defschema',m)
        if sp: dparts.append("    "+s[toks[sp[0]][1]:toks[sp[1]][2]])
    dup="\n".join(dparts)
    # insert after FVT|Schema close (locate in out via re-tokenize)
    ot2=lf.tokenize(out); om2=lf.match_parens(ot2)
    for idx in range(len(ot2)):
        if ot2[idx][0]=='(' and out[ot2[idx][1]:ot2[idx][1]+22].startswith('(defschema FVT|Schema'):
            ins=ot2[om2[idx]][2]
            out=out[:ins]+"\n    ;; duplicate copies of moved schemas (structural types referenced by staying FVT — #75 B' Stage 3)\n"+dup+out[ins:]
            break
print("duplicated schemas:", missing)

# --- 3. bind ref-RPS: insert into an existing let, or wrap the body in a let ---
RPSBIND='(ref-RPS:module{AcquisitionRewardPerShareV1} RPS)'
t2=lf.tokenize(out); m2=lf.match_parens(t2)
i=0
while not(t2[i][0]=='atom' and out[t2[i][1]:t2[i][2]]=='module'): i+=1
mo2=i-1
while t2[mo2][0]!='(': mo2-=1
mc2=m2[mo2]
inserts=[]; nwrap=0; nlet=0; st=[]
for idx in range(mo2,mc2+1):
    if t2[idx][0]=='(':
        st.append(idx)
        if len(st)==2:
            j=idx+1
            while t2[j][0]=='ws': j+=1
            h=out[t2[j][1]:t2[j][2]] if t2[j][0]=='atom' else ''
            if h in ('defun','defcap','defpact'):
                mclose=m2[idx]; a=t2[idx][1]; b=t2[mclose][2]
                body=out[a:b]
                # real ref-RPS:: call = an atom token containing it (not just a @doc-string mention)
                has_ref=any(t2[k][0]=='atom' and 'ref-RPS::' in out[t2[k][1]:t2[k][2]] for k in range(idx,mclose))
                if has_ref and 'ref-RPS:module{' not in body:
                    # ALWAYS wrap the whole body in a ref-RPS let (nesting an inner let is fine, and
                    # avoids the partial-let trap where ref-RPS:: appears in sibling forms).
                    jj=j+1
                    while t2[jj][0]=='ws': jj+=1        # name
                    p=jj+1
                    while t2[p][0]=='ws': p+=1          # param '('
                    bk=m2[p]+1                          # after params
                    while t2[bk][0] in ('ws','comment'): bk+=1
                    while t2[bk][0]=='atom' and out[t2[bk][1]:t2[bk][2]] in ('@doc','@event','@managed','@model'):
                        meta=out[t2[bk][1]:t2[bk][2]]; bk+=1
                        while t2[bk][0] in ('ws','comment'): bk+=1
                        if meta=='@doc' and t2[bk][0]=='str':
                            bk+=1
                            while t2[bk][0] in ('ws','comment'): bk+=1
                        elif meta=='@managed':
                            for _ in range(2):
                                if t2[bk][0]=='atom': bk+=1
                                while t2[bk][0] in ('ws','comment'): bk+=1
                    bs=t2[bk][1]; fc=t2[mclose][1]
                    inserts.append((fc,")\n    "))
                    inserts.append((bs,"(let\n            (\n                "+RPSBIND+"\n            )\n            ")); nwrap+=1
    elif t2[idx][0]==')':
        if st: st.pop()
inserts.sort(key=lambda x:x[0],reverse=True)
for pos,txt in inserts:
    out=out[:pos]+txt+out[pos:]
print(f"ref-RPS bindings: {nlet} into-let + {nwrap} body-wrap")
open(F,'w').write(out)
print(f"CUT {len(DELETE)} fns + {len(SCHEMAS)} schemas + {len(RPS_TBL)} tables")
print(f"WRITERS (->XE_): {len(WRITERS)}  bindings inserted: {len(inserts)}")
print("new FVT lines:", out.count('\n'))
# sanity: any moved fn still called WITHOUT ref-RPS:: ?
resid=[n for n in MOVED_CALLABLE if re.search(r'(?<!:)\('+re.escape(n)+r'[ )]',out)]
print("residual un-rewired calls:", resid[:15])
