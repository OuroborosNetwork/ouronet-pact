#!/usr/bin/env python3
"""
_ignis_cost_classify.py — #76. Classify every client/admin core entrypoint by cost KIND
(DIRECT-IGNIS flat GAS| / COMPOSED fixed+variable / STOA usage-fee / none) and ROLE
(ISSUE/SETUP/USAGE), with complexity signals, so the price structure can be analysed vs the
"issue > setup > usage, usage scales with compute" gate philosophy. DPMF excluded (historic stub).
"""
import re, glob, importlib.util
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
PREF=('CCp_','CC_','Cp_','C_','AAp_','AA_','Ap_','A_')
GAS={}
for f in glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True):
    for m in re.finditer(r'\(defconst (GAS\|[A-Za-z0-9-]+)(?::decimal)?\s+([0-9.]+)', open(f).read()):
        GAS[m.group(1)]=m.group(2)

ISSUE=re.compile(r'^(C{1,2}p?_|A{1,2}p?_)(Issue|Create|Deploy|Open|Define|Mint|Make|IssueMultiplet|New)')
USAGE=re.compile(r'(Stake|Unstake|Collect|Inject|Transfer|Fuel|Retrieve|Coil|Curl|Vacate|Sweep|Fix|Drain|Flush|Unstale|Bulk|Swap|Liquidity|Compress|Wrap|Deposit|Withdraw|StakeFlow|Brumate|Constrict|Syphon)')
def role(nm):
    if ISSUE.match(nm): return 'ISSUE'
    if USAGE.search(nm): return 'USAGE'
    return 'SETUP'   # Set/Toggle/Rotate/Add*/Register/Control/Update/Wipe/Revoke/Link/…

def analyze(path):
    s=open(path).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
    ms=len(toks)
    for k in range(len(toks)):
        if toks[k][0]=='atom' and s[toks[k][1]:toks[k][2]]=='module': ms=k; break
    defs={}
    for k in range(ms,len(toks)):
        if toks[k][0]=='(':
            j=k+1
            while j<len(toks) and toks[j][0]=='ws': j+=1
            if j<len(toks) and toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]] in ('defun','defpact'):
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                nm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]; ct=match[k]
                ats=[s[toks[a][1]:toks[a][2]] for a in range(k,ct+1) if toks[a][0]=='atom']
                defs[nm]=(ats, s[toks[k][1]:toks[ct][2]])
    # full transitive closure of reachable module-internal fn NAMES (memoized, cycle-safe)
    callees={nm:set(a for a in ats if a in defs and a!=nm) for nm,(ats,_) in defs.items()}
    _memo={}
    def reach(nm,seen):
        if nm in _memo: return _memo[nm]
        if nm in seen: return set()
        seen=seen|{nm}; acc={nm}
        for c in callees[nm]: acc|=reach(c,seen)
        _memo[nm]=acc; return acc
    rows=[]
    for nm,(ats,body) in defs.items():
        if not nm.startswith(PREF): continue
        names=reach(nm,set())
        txt=' '.join(defs[n][1] for n in names)          # concatenated closure body text
        allats=set(); [allats.update(defs[n][0]) for n in names]
        gas=sorted(g for g in allats if g in GAS)
        composed='UDC_ConcatenateOutputCumulators' in txt
        flat='UDC_ConstructOutputCumulator' in txt
        stoa=('UR_UsagePrice' in txt) or ('STOA|C_Collect' in txt) or ('URC_SplitSTOAPrices' in txt)
        if composed: kind='COMPOSED'
        elif gas: kind='DIRECT'
        elif flat: kind='FLAT'          # single ConstructOutputCumulator, amount not a named GAS| const
        elif stoa: kind='STOA'
        else: kind='free'
        ignis=('+'.join(f"{g}={GAS[g]}" for g in gas) if gas else ('composed' if composed else ('flat-nonconst' if flat else ('stoa-fee' if stoa else 'free'))))
        writes=sum(1 for a in ats if a in ('insert','update','write'))
        heavy=sum(1 for a in ats if re.match(r'^(URH_|URHC_|URD_)',a))
        refs=len(re.findall(r'ref-[A-Za-z0-9|-]+::',body))
        rows.append((nm,role(nm),kind,ignis,writes,heavy,refs))
    return rows

MODS=[m for m in sorted(glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True)) if '00_DPMF' not in m]
allrows=[]
for p in MODS:
    for r in analyze(p): allrows.append((p.split('/')[-1],)+r)
# summary matrices
from collections import Counter
byrole=Counter(r[2] for r in allrows)
bykind=Counter(r[3] for r in allrows)
rk=Counter((r[2],r[3]) for r in allrows)
print("# IGNIS cost CLASSIFICATION (#76) — DPMF excluded\n")
print(f"Total client/admin core ops: {len(allrows)}\n")
print("## By ROLE\n", dict(byrole))
print("\n## By KIND\n", dict(bykind))
print("\n## ROLE x KIND (op counts)\n")
print("| role | DIRECT | FLAT | COMPOSED | STOA | free |")
print("|------|-------:|----:|--------:|----:|----:|")
for role_ in ('ISSUE','SETUP','USAGE'):
    print(f"| {role_} | {rk[(role_,'DIRECT')]} | {rk[(role_,'FLAT')]} | {rk[(role_,'COMPOSED')]} | {rk[(role_,'STOA')]} | {rk[(role_,'free')]} |")
print("\n## DIRECT-IGNIS ops (flat GAS| base) — role · cost · complexity\n")
print("| op | role | ignis-base | writes | heavy | ref:: |")
print("|----|------|-----------|-------:|-----:|------:|")
for m,nm,rl,kind,ig,w,h,rf in sorted(allrows,key=lambda x:(x[2],x[1])):
    if kind=='DIRECT': print(f"| `{nm}` | {rl} | {ig} | {w} | {h} | {rf} |")
print("\n## COMPOSED ops (fixed base + variable sub-costs) — the ones without a single flat price\n")
print("| op | role | writes | heavy | ref:: |")
print("|----|------|-------:|-----:|------:|")
for m,nm,rl,kind,ig,w,h,rf in sorted(allrows,key=lambda x:(-x[6])):
    if kind=='COMPOSED': print(f"| `{nm}` | {rl} | {w} | {h} | {rf} |")
