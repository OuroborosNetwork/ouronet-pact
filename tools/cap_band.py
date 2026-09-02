#!/usr/bin/env python3
"""StoicSyntax cap-band classifier (canon §7.5, settled 2026-09-02).

Classifies each capability in a module's CAPABILITIES block into C1..C4 by
COMPOSITION (not by name marker):
  C1 Trivial   — body is `true` (metadata ignored) OR composes ONLY bronze caps
                 (transitive fixpoint) with no other logic.            ⟨BRONZE⟩
  C2 Simple    — own logic, composes no caps, not C4.                  (silver)
  C3 Composed  — composes >=1 non-bronze cap.                          (silver)
  C4 Ownership — NON-composing, body is ONLY ownership validation:     ⟨GOLD⟩
                 every called module-function is CAP_* or UEV_EnforceAccountType,
                 and at least one CAP_* is present.  A cap that enforces ownership
                 PLUS other logic/validation is NOT C4 (-> C2).

Composition wins: a trivial/compose-only-bronze cap stays C1 even under a {C4}
marker. GOV|-prefixed caps belong in the GOVERNANCE block, not here.

Genuinely ambiguous caps (non-composing, has CAP_, but also calls outside the
ownership set) are returned classified C2 with a `review` flag so a human can confirm.
"""
import re

MODFN = re.compile(r'\((CAP_[A-Za-z0-9_|>-]*|UEV_[A-Za-z0-9_|>-]*|UR[CHUi]*_[A-Za-z0-9_|>-]*|UC[kxv]*_[A-Za-z0-9_|>-]*|UDC[x]*_[A-Za-z0-9_|>-]*|WI_[A-Za-z0-9_|>-]*|WU[0-9]*_[A-Za-z0-9_|>-]*|WW_[A-Za-z0-9_|>-]*|XI_[A-Za-z0-9_|>-]*|XE_[A-Za-z0-9_|>-]*|XB_[A-Za-z0-9_|>-]*)')
COMPOSE = re.compile(r'\(compose-capability\s+\(([A-Za-z0-9_|>-]+)')
OWNERSHIP_OK = lambda t: t.startswith('CAP_') or t == 'UEV_EnforceAccountType'

def _body_text(body):
    # drop the (defcap NAME (args) header line's sig + metadata lines
    lines = body[:]
    return ' '.join(l for l in lines if not re.search(r'@doc|@event|@managed', l))

def composes(body):   return COMPOSE.findall(' '.join(body))
def modfns(body):     return MODFN.findall(_body_text(body))
def is_trivial(body):
    inner = _body_text(body)
    inner = re.sub(r'\(defcap\s+[^\s()]+\s*\([^)]*\)', '', inner, count=1)  # strip header
    inner = COMPOSE.sub('', inner)
    inner = re.sub(r'[()]', ' ', inner).replace('true', ' ').strip()
    return inner == ''

def classify(caps):
    """caps: list of (name, body_lines). Returns dict name->(band, flag)."""
    comp = {n: composes(b) for n, b in caps}
    fns  = {n: modfns(b) for n, b in caps}
    trivial = {n: is_trivial(b) for n, b in caps}
    names = {n for n, _ in caps}
    # bronze fixpoint: trivial, or composes only-bronze with no modfns of its own
    bronze = set()
    for n in names:
        if trivial[n] and not comp[n] and not fns[n]:
            bronze.add(n)
    changed = True
    while changed:
        changed = False
        for n in names:
            if n in bronze: continue
            if comp[n] and not fns[n] and all(c in bronze for c in comp[n]):
                bronze.add(n); changed = True
    out = {}
    for n, b in caps:
        if n in bronze:
            out[n] = ('C1', None); continue
        if comp[n]:                                   # composes >=1 non-bronze
            out[n] = ('C3', None); continue
        f = fns[n]
        if f and any(t.startswith('CAP_') for t in f) and all(OWNERSHIP_OK(t) for t in f):
            out[n] = ('C4', None); continue
        # non-composing, not C4, not bronze
        flag = 'review-ownership+extra' if any(t.startswith('CAP_') for t in f) else None
        out[n] = ('C2', flag)
    return out

# ---- parse a module's CAPABILITIES block ----
def parse_cap_block(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    cs = next((i for i,l in enumerate(lines) if l.strip()==';;CAPABILITIES'), None)
    fs = next((i for i,l in enumerate(lines) if l.strip()==';;FUNCTIONS'), None)
    if cs is None or fs is None: return []
    blk = lines[cs:fs]; caps=[]; i=0
    while i < len(blk):
        m = re.match(r'\s*\(defcap\s+([^\s()]+)', blk[i])
        if m:
            name=m.group(1); depth=0; body=[]; j=i
            while j < len(blk):
                body.append(blk[j]); depth += blk[j].count('(')-blk[j].count(')'); j+=1
                if depth<=0: break
            caps.append((name, body)); i=j; continue
        i+=1
    return caps

if __name__ == '__main__':
    import sys
    for p in sys.argv[1:]:
        caps = parse_cap_block(p)
        res = classify(caps)
        print(f"== {p.split('/')[-1]} ==")
        for n,_ in caps:
            band, flag = res[n]
            print(f"  {band}{'  ⚑'+flag if flag else ''}  {n}")
