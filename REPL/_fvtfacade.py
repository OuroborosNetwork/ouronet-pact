#!/usr/bin/env python3
"""
_fvtfacade.py — restore FVT's public reader API after the RPS split.

Readers of moved tables had to move to RPS, but the test corpus + siblings call them
via ref-FVT::<reader>. Rather than repoint every caller (churn + equivalence risk),
FVT re-exports each such reader as a thin delegating wrapper (defun NAME (params) (RPS.NAME args))
and re-declares it in FVT's inline interface. Runs AFTER _fvtflip. Reproducible.

facade set = (defuns in RPS not in flipped FVT)  ∩  (fns called via ref-FVT:: in .repl/.pact)
             restricted to pure-reader prefixes (UR_/URC_/URH_/UEV_/UC_/UDC_).
"""
import importlib.util, glob, re
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
RPS='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact'
FVT='1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact'
READER_PREFIXES=('UR_','URC_','URH_','URCi_','UEV_','UC_','UDC_')

def defun_names(path):
    s=open(path).read(); toks=lf.tokenize(s)
    out=set()
    for k in range(len(toks)-2):
        if toks[k][0]=='atom' and s[toks[k][1]:toks[k][2]]=='defun':
            j=k+1
            while toks[j][0]=='ws': j+=1
            out.add(s[toks[j][1]:toks[j][2]].split(':',1)[0])
    return out

rps_defs=defun_names(RPS); fvt_defs=defun_names(FVT)
moved=rps_defs-fvt_defs
# fns called via ref-FVT::X (modref) OR AQP-FVT.X (dot) anywhere in repo (excl the 2 split files).
# modref callers need an interface decl; dot callers need only the wrapper (decl is harmless).
called=set()
for f in glob.glob('REPL/**/*.repl',recursive=True)+glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True):
    if f.endswith(('04_RPS.pact','05_FVT.pact')): continue
    txt=open(f).read()
    for m in re.findall(r'ref-FVT::([A-Za-z0-9_|.<>+-]+)',txt):      called.add(m)
    for m in re.findall(r'(?<![A-Za-z0-9_-])AQP-FVT\.([A-Za-z0-9_|.<>+-]+)',txt): called.add(m)
facade=sorted(n for n in (moved & called) if n.startswith(READER_PREFIXES))
print(f"[facade] moved={len(moved)} called-externally={len(called)} facade={len(facade)}")

# extract (name, ret, [(pname,ptype),...]) for each facade fn from RPS
s=open(RPS).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
def sig(name):
    for k in range(len(toks)-2):
        if toks[k][0]=='(' :
            j=k+1
            while j<len(toks) and toks[j][0]=='ws': j+=1
            if j<len(toks) and toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='defun':
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                raw=s[toks[jj][1]:toks[jj][2]]
                nm=raw.split(':',1)[0]
                if nm!=name: continue
                ret=raw.split(':',1)[1] if ':' in raw else 'string'
                # next token group = param list ( ... )
                pj=jj+1
                while toks[pj][0]=='ws': pj+=1
                assert toks[pj][0]=='(', name
                params=[]
                for a in range(pj+1,match[pj]):
                    if toks[a][0]=='atom':
                        at=s[toks[a][1]:toks[a][2]]
                        pn=at.split(':',1)[0]; pt=at.split(':',1)[1] if ':' in at else 'string'
                        params.append((pn,pt))
                return ret,params
    raise SystemExit(f"sig not found: {name}")

def q(n):  # keep pipes etc. verbatim (valid pact identifier chars)
    return n

decls=[]; wraps=[]
for n in facade:
    ret,params=sig(n)
    plist=" ".join(f"{pn}:{pt}" for pn,pt in params)
    args=" ".join(pn for pn,_ in params)
    call=f"(RPS.{n} {args})" if args else f"(RPS.{n})"
    decls.append(f"    (defun {n}:{ret} ({plist}))")
    wraps.append(f"    (defun {n}:{ret} ({plist})\n        @doc \"Facade: delegates to the RPS reward engine (post-#75 split).\"\n        {call}\n    )")

# ---- inject into FVT ----
fs=open(FVT).read(); ftoks=lf.tokenize(fs); fmatch=lf.match_parens(ftoks)
# 1) interface close: first top-level (interface ...) span end
iface_close=None; depth=0
for k in range(len(ftoks)):
    if ftoks[k][0]=='(':
        j=k+1
        while ftoks[j][0]=='ws': j+=1
        if ftoks[j][0]=='atom' and fs[ftoks[j][1]:ftoks[j][2]]=='interface':
            iface_close=fmatch[k]; break
ic=ftoks[iface_close][1]  # byte offset of the ')'
iface_block="\n    ;;<=====================================================================>\n    ;;  #75 FACADE — reward-engine readers re-exported from RPS (see 04_RPS.pact)\n"+"\n".join(decls)+"\n"
fs=fs[:ic]+iface_block+fs[ic:]
# recompute tokens after first insert
ftoks=lf.tokenize(fs); fmatch=lf.match_parens(ftoks)
# 2) module close: the (module AQP-FVT ...) span end
mod_close=None
for k in range(len(ftoks)):
    if ftoks[k][0]=='(':
        j=k+1
        while ftoks[j][0]=='ws': j+=1
        if ftoks[j][0]=='atom' and fs[ftoks[j][1]:ftoks[j][2]]=='module':
            mod_close=fmatch[k]; break
mc=ftoks[mod_close][1]
mod_block="\n    ;;<=====================================================================>\n    ;;  #75 FACADE — thin delegating wrappers onto the RPS reward engine\n"+"\n".join(wraps)+"\n"
fs=fs[:mc]+mod_block+fs[mc:]
open(FVT,'w').write(fs)
print(f"[facade] injected {len(decls)} iface decls + {len(wraps)} wrappers -> {FVT}")
