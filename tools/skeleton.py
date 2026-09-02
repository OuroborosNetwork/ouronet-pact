#!/usr/bin/env python3
"""StoicSyntax full-skeleton classifier (canon §7) — DRY-RUN mapper (2b).

Parses ONE module's top-level forms and reports which canonical block/sub-block
each lands in. No rewrite yet — this is the validation lens before the emitter.

Block map:
  {0} IMPLEMENTERS  (implements)
  {1} GOVERNANCE    name == GOV or GOV|…  → G1 const · G2 schema · G3 table · G4 cap · G5 defun/defpact
  {2} POLICY        name P|…              → P1..P5 by type
  {3} CST           other defconst→3.1 · defschema→3.2 · deftable→3.3
  {4} CAPABILITIES  other defcap          → C1..C4 via cap_band.classify
  {5} FUNCTIONS     other defun/defpact   → 5.1..5.7 by prefix class (REPL_→{6})
  ?   UNCLASSIFIED  (needs a rule / manual — e.g. gas-station or unprefixed scoped)
"""
import re, sys
import cap_band

# function prefix → class 5.x  (build order)
FN_CLASS = [
    ("5.1", ["UDCx_","UDC_"]),
    ("5.2", ["UCkx_","UCxx_","UCk_","UCv_","UCx_","UC_"]),
    ("5.3", ["URHCx_","URHC_","URHx_","URH_","URCix_","URCi_","URCx_","URCv_","URC_","URU_","UR_","INFO_"]),
    ("5.4", ["UEV_","CAP_"]),
    ("5.5", ["WI_","WU7_","WU6_","WU5_","WU4_","WU3_","WU2_","WU_","WW_"]),
    ("5.6", ["XI_","XE_","XB_"]),
    ("5.7", ["AAp_","AA_","Ap_","AUx_","AU_","A_","CCp_","CC_","Cp_","C_"]),
]
REPL_PFX = "REPL_"

def prefix_of(name):
    us = name.find('_')
    if us == -1: return None
    before = name[:us]
    return (before.rsplit('|',1)[1] if '|' in before else before) + '_'

def fn_subblock(name):
    if name.startswith(REPL_PFX) or prefix_of(name)==REPL_PFX: return "6"
    tok = prefix_of(name)
    if tok:
        for sb, pfxs in FN_CLASS:
            if tok in pfxs: return sb
    if re.match(r'^A\d+[a-z]?_$', tok or ''): return "5.7"
    return None

def parse_forms(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    forms=[]; i=0
    while i < len(lines):
        m = re.match(r'\s*\((implements|use|defun|defpact|defcap|defconst|defschema|deftable)\b\s*([^\s()]*)', lines[i])
        if m and lines[i].startswith('    '):   # top-level (4-space indented) form
            kind=m.group(1); name=m.group(2)
            depth=0; in_str=False; j=i; body=[]
            while j < len(lines):
                body.append(lines[j])
                d,in_str = _pd(lines[j], in_str); depth+=d; j+=1
                if depth<=0: break
            forms.append((kind,name,body)); i=j; continue
        i+=1
    return forms

def _pd(line,in_str):
    d=0;i=0;n=len(line)
    while i<n:
        c=line[i]
        if in_str:
            if c=='\\':i+=2;continue
            if c=='"':in_str=False
            i+=1;continue
        if c=='"':in_str=True;i+=1;continue
        if c==';' and i+1<n and line[i+1]==';':break
        if c=='(':d+=1
        elif c==')':d-=1
        i+=1
    return d,in_str

def classify_form(kind, name, cap_bands):
    if kind in ('implements','use'): return "0"
    isgov = (name=='GOV' or name.startswith('GOV|'))
    ispol = name.startswith('P|')
    if isgov:
        return {'defconst':'G1','defschema':'G2','deftable':'G3','defcap':'G4','defun':'G5','defpact':'G5'}[kind]
    if ispol:
        return {'defconst':'P1','defschema':'P2','deftable':'P3','defcap':'P4','defun':'P5','defpact':'P5'}[kind]
    if kind=='defconst': return "3.1"
    if kind=='defschema': return "3.2"
    if kind=='deftable': return "3.3"
    if kind=='defcap':  return cap_bands.get(name, "C?")
    if kind in ('defun','defpact'):
        return fn_subblock(name) or "UNCLASSIFIED"
    return "UNCLASSIFIED"

def main(path):
    forms = parse_forms(path)
    # band ALL cap-block caps (every defcap that is NOT GOV|/P|), from anywhere in the module
    capcaps = [(n,body) for k,n,body in forms
               if k=='defcap' and not (n=='GOV' or n.startswith('GOV|') or n.startswith('P|'))]
    caps = cap_band.classify(capcaps)
    capband = {n:b for n,(b,_) in caps.items()}
    buckets={}
    unclass=[]
    for kind,name,_ in forms:
        b = classify_form(kind,name,capband)
        buckets.setdefault(b,[]).append(f"{kind} {name}")
        if b in ('UNCLASSIFIED','C?'): unclass.append(f"{kind} {name} -> {b}")
    order=["0","#","G1","G2","G3","G4","G5","P1","P2","P3","P4","P5","3.1","3.2","3.3","C1","C2","C3","C4","5.1","5.2","5.3","5.4","5.5","5.6","5.7","6"]
    print(f"== {path.split('/')[-1]} — {len(forms)} top-level forms ==")
    for b in order:
        if b in buckets: print(f"  {{{b}}}  {len(buckets[b])}")
    if unclass:
        print(f"  !! UNCLASSIFIED ({len(unclass)}):")
        for u in unclass[:40]: print("     "+u)

if __name__=='__main__':
    for p in sys.argv[1:]: main(p)
