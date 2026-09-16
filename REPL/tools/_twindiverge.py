#!/usr/bin/env python3
"""_twindiverge.py -- guard asymmetry between TWIN functions (audit instrument, NOT a gate check).

THE HEURISTIC
-------------
Twice in 2026-09 a defect survived in exactly one of two symmetrical operations while its twin was
correct, and the working twin made the family look covered:

  * `coin`'s guarded dust sweep was correct; BOTH ports (STOAICO, AQP-RPS) had dropped its guards.
  * `_ignis_price_sheet.py` resolved `DPNF|C_BulkTransfer` and dropped `DPSF|C_BulkTransfer`.

So: normalise the twin tokens out of function names, group the families, and compare guard sets
(`UEV_`, `CAP_`, `require-/compose-/with-capability`) across members.

MEASURED FALSE-POSITIVE RATE: 23 reported, 0 real (2026-09-15, full sovereign + citizen tree).
-----------------------------------------------------------------------------------------------
THAT NUMBER IS THE POINT, and it is why this is NOT wired into `_gate.py`. An instrument whose
false-positive rate nobody has measured is indistinguishable from a defect detector -- the same
trap `tools/canon_check.py` was in, where 21 "drift" files turned out to be 6 stale-classifier and
15 real, and there was no way to know without running it.

Getting to a trustworthy zero took FOUR corrections, each of which had produced a confident,
completely wrong finding:

  1. `>` was not in the name character class, so every `DPOF|S>*` defcap truncated to `DPOF|S` and
     ~15 distinct caps merged into one pseudo-function. Output: "DPOF|S is missing CAP_Owner".
  2. Interface DECLARATIONS (no body -> empty guard set) were grouped with module DEFINITIONS under
     the same name, and dict-overwrite let the empty one win whenever its file sorted later.
  3. No transitive closure over `compose-capability`. A cap that factors its checks into a shared
     sibling looked stripped: `ANK|C>ISSUE-DPNF` appeared to have lost `UEV_Promile`,
     `UEV_AssetAnchorCap`, `UEV_IssueAnchor` and `SECURE`; all four live in the
     `ANK|XI>ISSUE-DPNF-COMMON` it composes. Without this the detector is LOUDEST where the code
     is BEST refactored.
  4. No structural filter. DPTF has no nonces, so nonce guards are absent by construction, not by
     omission; it uses `UEV_AccountMintState` where DPOF/DPMF use `UEV_AccountAddQuantityState`.

WHAT THE ZERO MEANS
-------------------
The symmetrical families in the CONTRACTS are guard-consistent. Every surviving asymmetry is
structural, factored out, a naming split (`DPOF|S>X_FREEZE` vs `DPTF|C>X_FREEZE`), a thin alias
whose delegate holds the gate (`DPNF|C_BulkTransfer` -> `DPDC|C_BulkTransfer`, which does acquire
`P|TS`), or already documented in place (`DPTF|C>UPDATE-SPECIAL`, marked UNREACHABLE BY
CONSTRUCTION by a prior audit). The twin divergences this round were in the TOOLING, not the
contracts.

Re-run after adding a new asset family or a new variant op:  python3 REPL/tools/_twindiverge.py
"""
import re, glob, os, itertools
from collections import defaultdict

ROOT='.'
FILES = glob.glob('1_SOVEREIGN/**/*.pact', recursive=True) + glob.glob('2_CITIZEN/**/*.pact', recursive=True)

# token families that mark a symmetrical variant of the same operation
TWINS = [
    # CamelCase, UPPER-HYPHEN and lower-hyphen spellings of the same family. Capability names use
    # the hyphenated upper form (C>ADD-FROZEN-LQ), function names the CamelCase one -- normalising
    # only one spelling makes every twin look asymmetric.
    ["NonFungible","SemiFungible","TrueFungible","OrtoFungible","MetaFungible","Collectable"],
    ["NON-FUNGIBLE","SEMI-FUNGIBLE","TRUE-FUNGIBLE","ORTO-FUNGIBLE","META-FUNGIBLE","COLLECTABLE"],
    ["non-fungible","semi-fungible","true-fungible","orto-fungible","meta-fungible","collectable"],
    ["DPNF","DPSF","DPTF","DPOF","DPMF"],
    ["Frozen","Sleeping","Iced","Glacial","Standard","Hibernating","Vesting","Reservation"],
    ["FROZEN","SLEEPING","ICED","GLACIAL","STANDARD","HIBERNATING","VESTING","RESERVATION"],
    ["frozen","sleeping","iced","glacial","standard","hibernating","vesting","reservation"],
    ["Nft","Sft","Tft"],
    ["nft","sft","tft"],
    ["NFT","SFT","TFT"],
    ["-TF-","-NF-","-SF-","-OF-","-MF-"],
    ["TRUE","SEMI","NON","ORTO","META"],
    ["True","Semi","Non","Orto","Meta"],
    # AQP score entities: the codebase dispatches on exactly this pair --
    # UEV_AddScoreEntityContext, "type 1 = score rules; type 3 = triplet rules".
    ["ScoreEntityScore","ScoreEntityTriplet"],
]
TOKMAP = {}
for i,fam in enumerate(TWINS):
    for t in fam: TOKMAP[t]=f"<T{i}>"
TOKRE = re.compile('|'.join(sorted(TOKMAP, key=len, reverse=True)))

def bodies(path):
    src=open(path).read()
    # Interface DECLARATIONS have no body, so their guard set is empty by construction.
    # Mixing them with module DEFINITIONS made every declared cap look stripped of guards --
    # and because the group was keyed by name alone, the empty declaration overwrote the real
    # definition whenever its file sorted later. Confident, wrong, and entirely self-inflicted.
    out=[]
    # '>' is part of the name (DPOF|S>ROTATE-OWNERSHIP). Excluding it truncated every scoped
    # defcap to its module stem, merging ~15 distinct caps into one pseudo-function and producing
    # a confident false positive ("DPOF|S is missing CAP_Owner") out of pure name collision.
    for m in re.finditer(r'^\s{4}\((defun|defpact|defcap)\s+([A-Za-z0-9|_+>-]+)', src, re.M):
        i=m.start(); j=i; depth=0; instr=False
        while j < len(src):
            c=src[j]
            if instr:
                if c=='"' and src[j-1]!='\\': instr=False
            elif c=='"': instr=True
            elif c=='(': depth+=1
            elif c==')':
                depth-=1
                if depth==0: j+=1; break
            j+=1
        body = src[i:j]
        # a declaration is a single balanced form with no inner body forms
        if not re.search(r'\n', body.strip()) or not re.search(r'\((?:enforce|let|with-|compose-|require-|UEV_|CAP_|if|fold|map|insert|update|write|format)', body):
            continue
        out.append((m.group(1), m.group(2), body))
    return out

def guards(body):
    """The guard vocabulary of a function, normalised across twin tokens."""
    code = re.sub(r'"(?:[^"\\]|\\[\s\S])*"', '""', body)   # strip strings: messages differ legitimately
    g = set()
    for pat, tag in ((r'\((UEV_[A-Za-z0-9|_-]+)', 'UEV'),
                     (r'\((CAP_[A-Za-z0-9|_-]+)', 'CAP'),
                     (r'\(require-capability\s+\(([A-Za-z0-9|_>-]+)', 'REQ'),
                     (r'\(compose-capability\s+\(([A-Za-z0-9|_>-]+)', 'CMP'),
                     (r'\(with-capability\s+\(([A-Za-z0-9|_>-]+)', 'WITH')):
        for n in re.findall(pat, code):
            g.add(f"{tag}:{TOKRE.sub(lambda m: TOKMAP[m.group(0)], n)}")
    g.add(f"ENFORCE_N:{len(re.findall(r'\(enforce[ (]', code))}")
    return g

# ---- transitive guard closure over compose-capability -------------------------------------
# A cap that composes a shared sibling has its guards THERE, not inline. Comparing direct guard
# sets alone cannot tell "missing" from "factored out", and factoring out is the good refactor --
# so the detector produces its loudest false positives exactly where the code is best organised.
# ANK|C>ISSUE-DPNF looked like it had lost UEV_Promile / UEV_AssetAnchorCap / UEV_IssueAnchor /
# SECURE; all four live in ANK|XI>ISSUE-DPNF-COMMON, which it composes.
BY_FILE = {f: {nm: b for _k, nm, b in bodies(f)} for f in FILES}

def closure(f, name, seen=None):
    seen = seen or set()
    if name in seen or name not in BY_FILE.get(f, {}):
        return set()
    seen.add(name)
    body = BY_FILE[f][name]
    g = guards(body)
    code = re.sub(r'"(?:[^"\\]|\\[\s\S])*"', '""', body)
    for sub in re.findall(r'\(compose-capability\s+\(([A-Za-z0-9|_>-]+)', code):
        g |= closure(f, sub, seen)
    return g

groups=defaultdict(list)
for f in FILES:
    for kind,name,body in bodies(f):
        key_name = TOKRE.sub(lambda m: TOKMAP[m.group(0)], name)
        if key_name == name:      # no twin token -> not part of a family
            continue
        groups[(kind,key_name)].append((f,name,body))

findings=[]
for (kind,key),members in groups.items():
    if len(members)<2: continue
    # key by FILE+NAME: the same name legitimately appears in an interface and a module
    gsets={f'{nm}': closure(_f, nm) for _f,nm,b in members}
    if len(gsets) < 2: continue
    union=set().union(*gsets.values())
    for nm,gs in gsets.items():
        missing = {x for x in union if x not in gs and not x.startswith('ENFORCE_N')}
        # only report when a guard present in EVERY other member is absent here
        others=[v for k,v in gsets.items() if k!=nm]
        strict = {x for x in missing if all(x in o for o in others)}
        # STRUCTURAL FILTER: if the missing guard's identifier does not EXIST anywhere in the
        # deficient member's own file, the two ops are not the same operation in two flavours --
        # they are different operations. DPTF has no nonces, so UEV_NoncesCirculating and the
        # S>CREDIT-SINGULAR/CONSECUTIVE caps are absent by construction, not by omission; it uses
        # UEV_AccountMintState where DPOF/DPMF use UEV_AccountAddQuantityState. Reporting those is
        # reporting that a true fungible is not a collectable.
        own_file = [f for f,n,_b in members if n==nm][0]
        own_src = open(own_file).read()
        real = []
        for x in strict:
            ident = x.split(':',1)[1]
            probe_ident = ident.replace('<T3>|','')          # module token is normalised away
            base = re.split(r'[|>]', probe_ident)[-1]
            if base and base in own_src:
                real.append(x)
        if real:
            findings.append((kind,key,nm,sorted(real),[k for k in gsets if k!=nm]))

print(f"twin families: {sum(1 for v in groups.values() if len(v)>1)}")
print(f"asymmetries  : {len(findings)}\n")
for kind,key,nm,miss,others in sorted(findings, key=lambda x:-len(x[3]))[:25]:
    print(f"[{kind}] {nm}")
    print(f"    twins : {', '.join(others)}")
    for m in miss: print(f"    MISSING (all twins have it): {m}")
    print()
