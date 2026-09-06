#!/usr/bin/env python3
"""
_fvtgen.py — materialize 04_RPS.pact from 04_FVT.pact (P1 extraction, first draft).
Extracts exact source spans of the RPS move-set (consts/schemas/tables/functions),
computes the public surface (moved fns called by staying fns = interface + XE_ candidates),
and emits the RPS module under a hand-authored header. Body text is preserved verbatim
except the P|FVT| -> P|RPS| cap-family rename (module-local caps).
"""
import importlib.util, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
F='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
s=open(F).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
RPS_TBL={'FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount','FVT|T|ScoreEntityLink','FVT|T|UserPresence','FVT|T|MultipletFamily','FVT|T|RewardAggregate','FVT|T|QualitySplit','FVT|T|AgencyFee','FVT|T|DsaOracleConfig'}
FVT_TBL={'FVT|T','FVT|T|VacateFreeze','FVT|T|SweepProgress'}

# locate module span
i=0
while not(toks[i][0]=='atom' and s[toks[i][1]:toks[i][2]]=='module'): i+=1
mo=i-1
while toks[mo][0]!='(': mo-=1
mc=match[mo]

# members (defun/defcap/defpact) with spans + kind
mem={}; order=[]; st=[]
for idx in range(mo,mc+1):
    t=toks[idx][0]
    if t=='(':
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
    elif t==')':
        if st: st.pop()

names=set(mem); direct={}; calls={}
for n,(ot,ct) in mem.items():
    at=[s[toks[k][1]:toks[k][2]] for k in range(ot,ct+1) if toks[k][0]=='atom']
    direct[n]=set(a for a in at if a in RPS_TBL or a in FVT_TBL)
    calls[n]=set(a for a in at if a in names and a!=n)
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
free_needed=[c for c in seen if cls.get(c)=='FREE']
# module-boilerplate names RPS defines itself (do NOT copy from FVT body extraction)
BOILER={'P|FVT|CALLER','P|FVT|REMOTE-GOV','P|SECURE-CALLER','P|UEV_IMC','P|UR_IMP','SECURE','P|Info','P|UR'}
_rpsset=set(rps)
move_fns=[n for n in order if (n in _rpsset) or (n in free_needed and n not in BOILER)]

# public surface = moved fns referenced by a NON-moved member
moveset=set(move_fns)
public=set()
for n in mem:
    if n not in moveset:
        for c in calls[n]:
            if c in moveset: public.add(c)

CONSTS=['AQP|SC_NAME','BAR','CT_FORCED_FIX_RATE','CT_REWARD_KIND_PLAIN','CT_SCORE_ENTITY_TRIPLET','STREAM_EPOCH','CT_MEMBERSHIP_MODE_BAR','CT_MEMBERSHIP_MODE_SCORE','CT_MEMBERSHIP_MODE_STANDARD_TRIPLET','CT_MEMBERSHIP_MODE_TRUE_TRIPLET','CT_REWARD_KIND_MULTIPLET_BASE','CT_REWARD_MODE_HETEROGENEOUS','CT_REWARD_MODE_HOMOGENEOUS','CT_SCORE_ENTITY_SCORE','CT_SPLIT_MODE_STAKED','CT_SPLIT_MODE_TVL','DSA_ORACLE_TTL','FVT|DSA-ORACLE-KEY','GAS|ADD-REWARD-LINK','GAS|ADD-SCORE-ENTITY','GAS|COLLECT','GAS|INJECT','GAS|ISSUE-MULTIPLET-FAMILY','GAS|SET-COMMON-DENOMINATOR','GAS|SET-MOSAIC','GAS|SET-QUALITY-SPLIT','GAS|SET-SPLIT-MODE','GAS|TOGGLE-REWARD-LINK','GAS|TOGGLE-SCORE-ENTITY-LINK','GAS|UNSTALE','STREAM_MAX_LANES','CT_FVT_RPS_PREC']
SCHEMAS=['FVT|RPS|Global','FVT|RPS|Member','FVT|RPS|User','FVT|RPS|Stream','FVT|MemberVault','FVT|MemberUserWeight','FVT|ForcedFixCount','FVT|RewardAggregate','FVT|ScoreEntityLink','FVT|MultipletFamily','FVT|UserPresence','FVT|AgencyFee','FVT|QualitySplit','FVT|DsaOracleConfig']
TABLES=['FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount','FVT|T|RewardAggregate','FVT|T|ScoreEntityLink','FVT|T|MultipletFamily','FVT|T|UserPresence','FVT|T|AgencyFee','FVT|T|QualitySplit','FVT|T|DsaOracleConfig']

def span_of(kind,name):
    # find top-level (kind name ...) at module depth
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
                    nm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]
                    if nm==name:
                        return s[toks[idx][1]:toks[match[idx]][2]]
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None

def rename(txt):
    return txt.replace('P|FVT|CALLER','P|RPS|CALLER').replace('P|FVT|REMOTE-GOV','P|RPS|REMOTE-GOV')

# emit report
print("move_fns:",len(move_fns)," public surface:",len(public))
print("PUBLIC (interface + XE_ candidates):")
for n in sorted(public): print("   ",n)

# build the bodies block (consts, schemas, tables, functions) in original file order
blocks=[]
for c in CONSTS:
    b=span_of('defconst',c);  blocks.append(('const',c,b)) if b else None
for sc in SCHEMAS:
    b=span_of('defschema',sc); blocks.append(('schema',sc,b)) if b else None
for tb in TABLES:
    b=span_of('deftable',tb);  blocks.append(('table',tb,b)) if b else None
fn_block=[]
for n in order:
    if n in moveset:
        b=span_of('defun',n) or span_of('defcap',n) or span_of('defpact',n)
        if b: fn_block.append(rename(b))

open('/tmp/rps_consts.txt','w').write("\n".join("    "+b for _,_,b in blocks if _=='const' and b))
open('/tmp/rps_schemas.txt','w').write("\n".join("    "+b for k,_,b in blocks if k=='schema'))
open('/tmp/rps_tables.txt','w').write("\n".join("    "+b for k,_,b in blocks if k=='table'))
open('/tmp/rps_fns.txt','w').write("\n\n".join("    "+b for b in fn_block))
print("\nwrote /tmp/rps_{consts,schemas,tables,fns}.txt")
print("fn bodies:",len(fn_block)," consts:",sum(1 for k,_,_ in blocks if k=='const')," schemas:",sum(1 for k,_,_ in blocks if k=='schema')," tables:",sum(1 for k,_,_ in blocks if k=='table'))
