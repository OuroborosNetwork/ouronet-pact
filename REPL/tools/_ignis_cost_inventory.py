#!/usr/bin/env python3
"""
_ignis_cost_inventory.py — #76 prep. Static cost-vs-complexity inventory of every client/admin
core entrypoint (C_/CC_/CCp_/A_/AA_) across sovereign + citizen modules.

For each op: the IGNIS base cost it charges (GAS| constant value, or 'computed' when the URCi_/C_
builds it from a formula) alongside objective complexity signals from its OWN body (not transitive):
writes, heavy reads (URH_/URHC_/URD_), plain reads (UR_/URC_), cross-module ref calls, XI/XE calls,
and whether it is a heavy (doubled CC_/AA_) or defpact op. Output: a markdown table sorted by module.
Prints to stdout; redirect into the audit doc.
"""
import re, glob, importlib.util
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)

PREF=('CCp_','CC_','Cp_','C_','AAp_','AA_','Ap_','A_')
CLIENT_PREFIXED=re.compile(r'^([A-Za-z0-9-]+)\|(CCp_|CC_|Cp_|C_|AAp_|AA_|Ap_|A_)([A-Za-z0-9|]+)$')  # scope-first Talos wrappers
# collect GAS| constants (name->value) across the tree
GAS={}
for f in glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True):
    for m in re.finditer(r'\(defconst (GAS\|[A-Za-z0-9-]+)(?::decimal)?\s+([0-9.]+)', open(f).read()):
        GAS[m.group(1)]=m.group(2)

def urci_gas(s, suffix):
    # find (defun URCi_<suffix> ...) and return the GAS| constants referenced in its body
    m=re.search(r'\(defun URCi_'+re.escape(suffix)+r'[\s:(]', s)
    if not m: return None
    # crude brace-match from the defun open paren
    i=s.rfind('(', 0, m.start()+1); depth=0; j=i
    while j < len(s):
        if s[j]=='(': depth+=1
        elif s[j]==')':
            depth-=1
            if depth==0: break
        j+=1
    body=s[i:j+1]
    gas=sorted(set(re.findall(r'GAS\|[A-Za-z0-9-]+', body)))
    return gas or None

def analyze(path):
    s=open(path).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
    mod_start=len(toks)
    for k in range(len(toks)):
        if toks[k][0]=='atom' and s[toks[k][1]:toks[k][2]]=='module':
            mod_start=k; break
    # 1) build name -> (atoms, body, is_defpact) for ALL module-body defuns
    defs={}
    for k in range(mod_start,len(toks)):
        if toks[k][0]=='(':
            j=k+1
            while j<len(toks) and toks[j][0]=='ws': j+=1
            if j<len(toks) and toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]] in ('defun','defpact'):
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                nm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]
                ct=match[k]
                ats=[s[toks[a][1]:toks[a][2]] for a in range(k,ct+1) if toks[a][0]=='atom']
                defs[nm]=(ats, s[toks[k][1]:toks[ct][2]], s[toks[j][1]:toks[j][2]]=='defpact')
    rows=[]
    for nm,(ats,body,isdp) in defs.items():
        if not nm.startswith(PREF): continue
        writes=sum(1 for a in ats if a in ('insert','update','write'))
        heavy=sum(1 for a in ats if re.match(r'^(URH_|URHC_|URD_)',a))
        reads=sum(1 for a in ats if re.match(r'^(UR_|URC_)',a))
        xe=sum(1 for a in ats if re.match(r'^(XI_|XE_|XB_|W[IU]_)',a))
        refs=len(re.findall(r'ref-[A-Za-z0-9|-]+::',body))
        # cost: GAS| in op body OR in any directly-called module fn body (1-level transitive)
        gas=set(a for a in ats if a in GAS)
        for callee in set(a for a in ats if a in defs and a!=nm):
            gas |= set(a for a in defs[callee][0] if a in GAS)
        cost = ('+'.join(f"{g}={GAS.get(g,'?')}" for g in sorted(gas)) if gas else 'computed')
        heavyflag='HEAVY' if (nm.startswith(('CC_','AAp_','AA_','CCp_')) and heavy>0) else ''
        rows.append((nm,cost,writes,heavy,reads,xe,refs,(heavyflag+(' defpact' if isdp else '')).strip()))
    return rows

MODS=sorted(glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True))
print("# IGNIS cost-vs-complexity inventory (#76 prep, static)\n")
print("Per client/admin **core** entrypoint: base cost + own-body complexity signals. `computed` cost =")
print("built from a formula in URCi_/C_ (not a flat GAS| constant). Heavy = doubled CC_/AA_ reaching a")
print("URH_/URHC_/URD_ scan. Use to spot cost that doesn't track complexity.\n")
total=0
for path in MODS:
    rows=analyze(path)
    if not rows: continue
    total+=len(rows)
    print(f"\n## {path.split('/')[-1]}  ({len(rows)} ops)\n")
    print("| op | cost | writes | heavy-rd | reads | XI/XE | ref:: | flag |")
    print("|----|------|-------:|-------:|------:|------:|------:|------|")
    for nm,cost,w,h,r,xe,refs,fl in rows:
        print(f"| `{nm}` | {cost} | {w} | {h} | {r} | {xe} | {refs} | {fl} |")
print(f"\n---\n**Total client/admin core entrypoints inventoried: {total}**")
