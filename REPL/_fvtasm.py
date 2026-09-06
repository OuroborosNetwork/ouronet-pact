#!/usr/bin/env python3
"""_fvtasm.py — assemble a first-draft 04_RPS.pact from 04_FVT.pact spans + a hand header."""
import importlib.util, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
F='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
s=open(F).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
i=0
while not(toks[i][0]=='atom' and s[toks[i][1]:toks[i][2]]=='module'): i+=1
mo=i-1
while toks[mo][0]!='(': mo-=1
mc=match[mo]

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
                        return s[toks[idx][1]:toks[match[idx]][2]]
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None

def R(t):
    if t is None: return "; MISSING\n"
    return (t.replace('GOV|MD_FVT','GOV|MD_RPS').replace('GOV|FVT_ADMIN','GOV|RPS_ADMIN')
             .replace('P|FVT|CALLER','P|RPS|CALLER').replace('P|FVT|REMOTE-GOV','P|RPS|REMOTE-GOV'))

HEADER_DEFS = ['GOV|MD_FVT','GOV|Demiurgoi']              # consts+fn via defconst/defun below
gov_consts=['GOV|MD_FVT']
gov_caps=['GOV','GOV|FVT_ADMIN']
gov_fns=['GOV|Demiurgoi']
pol_consts=['P|I']
pol_caps=['P|FVT|CALLER','P|FVT|REMOTE-GOV','P|SECURE-CALLER']
pol_fns=['P|Info','P|UR','P|UR_IMP','P|UEV_IMC','P|A_Add','P|A_AddIMP','P|A_Define']
cst_consts=['CT_FVT_RPS_PREC','STREAM_EPOCH','CT_FORCED_FIX_RATE','BAR','AQP|SC_NAME','CT_REWARD_KIND_PLAIN','CT_SCORE_ENTITY_TRIPLET','CT_MEMBERSHIP_MODE_BAR','CT_MEMBERSHIP_MODE_SCORE','CT_MEMBERSHIP_MODE_STANDARD_TRIPLET','CT_MEMBERSHIP_MODE_TRUE_TRIPLET','CT_REWARD_KIND_MULTIPLET_BASE','CT_REWARD_MODE_HETEROGENEOUS','CT_REWARD_MODE_HOMOGENEOUS','CT_SCORE_ENTITY_SCORE','CT_SPLIT_MODE_STAKED','CT_SPLIT_MODE_TVL','DSA_ORACLE_TTL','FVT|DSA-ORACLE-KEY','GAS|ADD-REWARD-LINK','GAS|ADD-SCORE-ENTITY','GAS|COLLECT','GAS|INJECT','GAS|ISSUE-MULTIPLET-FAMILY','GAS|SET-COMMON-DENOMINATOR','GAS|SET-MOSAIC','GAS|SET-QUALITY-SPLIT','GAS|SET-SPLIT-MODE','GAS|TOGGLE-REWARD-LINK','GAS|TOGGLE-SCORE-ENTITY-LINK','GAS|UNSTALE','STREAM_MAX_LANES']
cst_fns=['CT_Bar','CT_AqpScName']

# ---- DYNAMIC interface member computation (14-table wide scope) ----
import glob
RPS_TBL={'FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberVault','FVT|T|MemberUserWeight','FVT|T|ForcedFixCount','FVT|T|ScoreEntityLink','FVT|T|UserPresence','FVT|T|MultipletFamily','FVT|T|RewardAggregate','FVT|T|QualitySplit','FVT|T|AgencyFee','FVT|T|DsaOracleConfig'}
FVT_TBL={'FVT|T','FVT|T|VacateFreeze','FVT|T|SweepProgress'}
_mem={}; _order=[]; _stk=[]; _CAPS=set()
for _idx in range(mo,mc+1):
    if toks[_idx][0]=='(':
        _stk.append(_idx)
        if len(_stk)==2:
            _j=_idx+1
            while toks[_j][0]=='ws': _j+=1
            _h=s[toks[_j][1]:toks[_j][2]] if toks[_j][0]=='atom' else ''
            if _h in ('defun','defcap','defpact'):
                _jj=_j+1
                while toks[_jj][0]=='ws': _jj+=1
                _nm=s[toks[_jj][1]:toks[_jj][2]].split(':',1)[0]
                _mem[_nm]=(_idx,match[_idx]); _order.append(_nm)
                if _h!='defun': _CAPS.add(_nm)
    elif toks[_idx][0]==')':
        if _stk: _stk.pop()
_names=set(_mem); _direct={}; _calls={}; _wtbl={}
for _n,(_ot,_ct) in _mem.items():
    _ats=[s[toks[k][1]:toks[k][2]] for k in range(_ot,_ct+1) if toks[k][0]=='atom']
    _direct[_n]=set(a for a in _ats if a in RPS_TBL or a in FVT_TBL)
    _calls[_n]=set(a for a in _ats if a in _names and a!=_n)
    _w=False
    for k in range(_ot,_ct):
        _tk=s[toks[k][1]:toks[k][2]] if toks[k][0]=='atom' else ''
        if _tk in ('insert','update','write'):
            m2=k+1
            while m2<_ct and toks[m2][0]=='ws': m2+=1
            if toks[m2][0]=='atom' and s[toks[m2][1]:toks[m2][2]] in RPS_TBL: _w=True; break
        if _tk=='require-capability':
            m2=k+1
            while m2<_ct and toks[m2][0]=='ws': m2+=1
            if m2<_ct and toks[m2][0]=='(':
                m3=m2+1
                while m3<_ct and toks[m3][0]=='ws': m3+=1
                if toks[m3][0]=='atom' and s[toks[m3][1]:toks[m3][2]]=='SECURE': _w=True; break
    _wtbl[_n]=_w
# transitive writer: n writes an RPS table directly OR calls a (transitive) writer -> needs SECURE-granting XE_
_wd=dict(_wtbl)
def _isw(n,seen):
    if n in seen: return False
    seen.add(n)
    if _wd.get(n): return True
    return any(_isw(c,seen) for c in _calls.get(n,()))
_wtbl={n:_isw(n,set()) for n in _mem}
def _clo(n,seen):
    if n in seen: return set()
    seen.add(n); t=set(_direct[n])
    for c in _calls[n]: t|=_clo(c,seen)
    return t
def _dom(t):
    r=any(x in RPS_TBL for x in t); f=any(x in FVT_TBL for x in t)
    return 'SEAM' if r and f else 'RPS' if r else 'FVT' if f else 'FREE'
_cls={n:_dom(_clo(n,set())) for n in _mem}
_rps=[n for n in _order if _cls[n]=='RPS' and not n.startswith(('C_','CC_','CCp_','A_','AA_'))]
_seen=set()
def _coll(n):
    for c in _calls[n]:
        if c not in _seen: _seen.add(c); _coll(c)
for _n in _rps: _coll(_n)
BOILER={'P|FVT|CALLER','P|FVT|REMOTE-GOV','P|SECURE-CALLER','P|UEV_IMC','P|UR_IMP','SECURE','P|Info','P|UR','GOV|Demiurgoi','P|A_Add','P|A_AddIMP','P|A_Define','CT_Bar','CT_AqpScName'}
MOVESET=set(n for n in _order if (n in set(_rps)) or (n in _seen and _cls.get(n)=='FREE' and n not in BOILER))
_public=set()
for n in _mem:
    if n not in MOVESET:
        for c in _calls[n]:
            if c in MOVESET: _public.add(c)
for f2 in glob.glob('1_SOVEREIGN/STAGE_02/2_Core/03_AQP/*.pact')+glob.glob('1_SOVEREIGN/STAGE_02/3_Talos/*.pact'):
    if '04_RPS' in f2 or '04_FVT' in f2: continue
    txt=open(f2).read()
    for fn in MOVESET:
        if ('::'+fn) in txt: _public.add(fn)
WRITERS=sorted(n for n in _public if _wtbl.get(n) and not n.startswith('XE_') and n not in _CAPS)
IFACE_READERS=sorted(n for n in _public if n not in set(WRITERS) and not n.startswith('XE_') and n not in _CAPS)
IFACE_EXT=sorted(n for n in _public if n.startswith('XE_') and n not in _CAPS)
print(f"[dyn] moveset={len(MOVESET)} public={len(_public)} readers={len(IFACE_READERS)} writers={len(WRITERS)} ext-XE={len(IFACE_EXT)}")

def sig2(name):
    """(rettype_or_None, params_text) for a defun in FVT source."""
    stk=[]
    for idx in range(mo,mc+1):
        if toks[idx][0]=='(':
            stk.append(idx)
            if len(stk)==2:
                j=idx+1
                while toks[j][0]=='ws': j+=1
                if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='defun':
                    jj=j+1
                    while toks[jj][0]=='ws': jj+=1
                    nm=s[toks[jj][1]:toks[jj][2]]
                    if nm.split(':',1)[0]==name:
                        rett=nm.split(':',1)[1] if ':' in nm else None
                        p=jj+1
                        while toks[p][0]=='ws': p+=1
                        pclose=match[p]
                        return rett, s[toks[p][1]+1:toks[pclose][2]-1].strip()
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None,None

iface=[]; iface_skip=[]
def iface_decl(name):
    rt,pt=sig2(name)
    # object-return/param rule: any module-schema in signature => stays module-internal
    if (rt and '{FVT|' in rt) or (pt and '{FVT|' in pt):
        iface_skip.append(name); return
    rts=(":"+rt) if rt else ""
    iface.append(f"    (defun {name}{rts} ({pt or ''}))")
for n in IFACE_READERS: iface_decl(n)
# generated XE_ writer wrappers (built later as WRITERS) — appended after WRITERS defined
for n in IFACE_EXT: iface_decl(n)

out=[]
out.append('''(interface AcquisitionRewardPerShareV1
    @doc "RPS reward-per-share ledger interface (extracted from AQP-FVT, #75). Per-field \\
        \\ global/member/user/stream + member-vault + forced-fix readers, the SECURE-composed \\
        \\ IMC-gated XE_ writer entrypoints FVT drives, and the royalty-custody XE_/URCi that \\
        \\ DSA consumes. Object-returning full-row readers/constructors stay in the RPS module."
__IFACE_MEMBERS__
)

(module RPS GOV
    @doc "Reward-per-share (RPS) ledger/accountant extracted from AQP-FVT (task #75). \\
        \\ Owns the RPS global/member/user/stream tables, member vaults, member-user \\
        \\ weight mirror, forced-fix counts and royalty custody, plus the settle / inject / \\
        \\ drip / deb-fix math. Leaf module: FVT drives it via XE_ entrypoints; structure \\
        \\ fields are arg-passed so RPS reads no FVT table."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements OuronetPolicyV2)
    (implements AcquisitionRewardPerShareV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE''')
for n in gov_consts: out.append("    "+R(span('defconst',n)))
for n in gov_caps:   out.append("    "+R(span('defcap',n)))
for n in gov_fns:    out.append("    "+R(span('defun',n)))
out.append("    ;;<=========================================================================>\n    ;;{2}  POLICY")
for n in pol_consts: out.append("    "+R(span('defconst',n)))
out.append("    (deftable P|T:{OuronetPolicyV2.P|S})\n    (deftable P|MT:{OuronetPolicyV2.P|MS})")
for n in pol_caps:   out.append("    "+R(span('defcap',n)))
for n in pol_fns:
    _t=R(span('defun',n))
    if n=='P|A_Define':
        # FVT's P|A_Define registers FVT's SECURE guard on RPS (ref-P|RPS::P|A_AddIMP dg).
        # In RPS's OWN P|A_Define that line would be a self-registration -> strip it + its comment.
        _t="\n".join(_l for _l in _t.split("\n")
                     if 'ref-P|RPS::P|A_AddIMP dg' not in _l
                     and 'register FVT' not in _l
                     and 'ref-P|RPS:module' not in _l)
    out.append("    "+_t)
out.append("    ;;<=========================================================================>\n    ;;{3}  CST")
for n in cst_consts: out.append("    "+R(span('defconst',n)))
for n in cst_fns:    out.append("    "+R(span('defun',n)))
out.append("    ;;<=========================================================================>\n    ;;{4}  CAPABILITIES")
out.append("    "+R(span('defcap','SECURE')))
out.append('''    (defcap RPS|XE>WRITE ()
        @doc "Forward entry: FVT (registered IMC caller) drives one RPS ledger write. Composes SECURE."
        (compose-capability (SECURE))
    )''')

def sig(name):
    """return (rettype_or_None, params_text, [param_names]) for a defun in FVT."""
    stk=[]
    for idx in range(mo,mc+1):
        if toks[idx][0]=='(':
            stk.append(idx)
            if len(stk)==2:
                j=idx+1
                while toks[j][0]=='ws': j+=1
                if toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='defun':
                    jj=j+1
                    while toks[jj][0]=='ws': jj+=1
                    nm_full=s[toks[jj][1]:toks[jj][2]]
                    if nm_full.split(':',1)[0]==name:
                        rett=nm_full.split(':',1)[1] if ':' in nm_full else None
                        p=jj+1
                        while toks[p][0]=='ws': p+=1
                        # param list '(' at p
                        pclose=match[p]
                        ptext=s[toks[p][1]+1:toks[pclose][2]-1].strip()
                        pnames=[a.split(':',1)[0] for a in
                                [s[toks[k][1]:toks[k][2]] for k in range(p+1,pclose) if toks[k][0]=='atom']
                                if ':' in a or a]  # atoms; take name part
                        # param names = first atom of each top-level param (heuristic: atoms containing ':')
                        pnames=[s[toks[k][1]:toks[k][2]].split(':',1)[0] for k in range(p+1,pclose)
                                if toks[k][0]=='atom' and ':' in s[toks[k][1]:toks[k][2]]]
                        return rett, ptext, pnames
        elif toks[idx][0]==')':
            if stk: stk.pop()
    return None,None,None

# (old hardcoded WRITERS removed — now computed dynamically above)
XE=[]
for w in WRITERS:
    rett,ptext,pnames=sig(w)
    rt=(":"+rett) if rett else ""
    call=f"({w} {' '.join(pnames)})"
    XE.append(f'''    (defun XE_{w}{rt} ({ptext})
        (P|UEV_IMC)
        (with-capability (RPS|XE>WRITE)
            {call}
        )
    )''')
    if ('{FVT|' in (rt or '')) or ('{FVT|' in (ptext or '')):
        iface_skip.append('XE_'+w)
    else:
        iface.append(f"    (defun XE_{w}{rt} ({ptext}))")
out.append("    ;;<=========================================================================>\n    ;;{S}  SCHEMAS")
out.append(open('/tmp/rps_schemas.txt').read())
for sc in ['FVT|ScorePreNzFlag','FVT|SettleFvtRewards','FVT|SettleScorePlan','FVT|StakeSettleBundle','FVT|MemberPreDeb']:
    out.append("    "+R(span('defschema',sc)))
out.append("    ;;<=========================================================================>\n    ;;{T}  TABLES")
out.append(open('/tmp/rps_tables.txt').read())
out.append("    ;;<=========================================================================>\n    ;;{5}  FUNCTIONS")
out.append(open('/tmp/rps_fns.txt').read())
out.append("    ;;{5-XE}  FORWARD ENTRYPOINTS (writer wrappers for FVT)")
out.append("\n".join(XE))
out.append(")")
out.append("")
for tb in ['P|T','P|MT','FVT|T|RPS|Global','FVT|T|RPS|Member','FVT|T|RPS|User','FVT|T|RPS|Stream','FVT|T|MemberUserWeight','FVT|T|MemberVault','FVT|T|ForcedFixCount','FVT|T|RewardAggregate','FVT|T|ScoreEntityLink','FVT|T|MultipletFamily','FVT|T|UserPresence','FVT|T|AgencyFee','FVT|T|QualitySplit','FVT|T|DsaOracleConfig']:
    out.append(f"(create-table {tb})")
full="\n".join(out)+"\n"
full=full.replace("__IFACE_MEMBERS__","\n".join(iface))
open('1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact','w').write(full)
print("interface members:",len(iface)," object-return skipped:",iface_skip)
print("wrote 04_RPS.pact:", sum(1 for _ in open('1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact'))," lines")
# report any MISSING
txt=open('1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact').read()
print("MISSING markers:", txt.count('; MISSING'))
