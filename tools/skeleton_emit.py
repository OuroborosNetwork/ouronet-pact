#!/usr/bin/env python3
"""StoicSyntax full-skeleton EMITTER (canon §7) — Phase 2c.

Re-lays each logical module in a .pact file into the canonical block skeleton
({0}/{#}/{1}-{6}) with markers, preserving every form's text verbatim (the
non-comment-char invariant proves zero code change; green-gate proves load).

Reuses skeleton.classify_form + cap_band. Within a sub-block, declaration order
is preserved (stable). Gas-station forms (GAS_PAYER cap, create-gas-payer-guard,
CT_VirtualGasData) are pulled into {#}.
"""
import sys, re
sys.path.insert(0, __file__.rsplit('/',1)[0])
import skeleton, cap_band

RULE = "    ;;<" + "="*73 + ">"
GAS_MEMBERS = {"GAS_PAYER", "create-gas-payer-guard", "CT_VirtualGasData"}

# ── Observational distancing (canon §7): a single-line form's second part opens
#    at this 0-based column, uniformly across every module. Heads longer than
#    ALIGN_COL-1 fall back to a 1-space gap. Whitespace-only → invariant-safe.
ALIGN_COL = 56
_ALIGN_RE = re.compile(r'^(    \((?:defun|defconst|defcap|defschema)\b.*?\S)( {2,})(\S.*)$')

# Tables cannot be declared in an interface; the marker is kept for structural
# parallelism but annotated so the reader knows it can never hold a form.
IFACE_NO_TABLE = {"G3", "3.3", "P3"}
IFACE_TABLE_NOTE = "⟨cannot exist in an interface⟩"

def _align(line):
    m = _ALIGN_RE.match(line)
    if not m: return line
    d, ins = _pd(line, False)
    if d != 0 or ins: return line               # only complete one-line forms
    head, body = m.group(1), m.group(3)
    pad = ALIGN_COL - len(head)
    if pad < 1: pad = 1
    return head + (' ' * pad) + body

SUBS = {
 "1":("GOVERNANCE",[("G1","constants"),("G2","schemas"),("G3","tables"),("G4","capabilities"),("G5","functions")]),
 "2":("POLICY",[("P1","constants"),("P2","schemas"),("P3","tables"),("P4","capabilities"),("P5","functions")]),
 "3":("CST",[("3.1","constants"),("3.2","schemas"),("3.3","tables")]),
 "4":("CAPABILITIES",[("C1","Trivial [bronze]"),("C2","Simple"),("C3","Composed"),("C4","Ownership [gold]")]),
 "5":("FUNCTIONS",[("5.1","Construct [CT/UDC]"),("5.2","Compute [UC]"),("5.3","Read [UR/URC/URH/URCi/INFO]"),
                   ("5.4","Validate [UEV/CAP]"),("5.5","Write [W]"),("5.6","Aux/X"),("5.7","User [A/C]")]),
}
FLAT = {"0":"IMPLEMENTERS","#":"GASSTATION","6":"REPL"}   # blocks with no sub-blocks

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

FORM_RE = re.compile(r'\s*\((implements|use|defun|defpact|defcap|defconst|defschema|deftable)\b\s*([^\s()]*)')
MARK_RE = re.compile(r'^\s*;;(<=|\{|[A-Z]{3,})')   # old block/sub markers to drop

def emit_module(block):
    """block = lines from '(module …' through its closing ')'.  Returns new lines."""
    # header: module-open line + the module @doc (which may be a multi-line string)
    hdr=[block[0]]; i=1
    while i < len(block) and block[i].strip()=='':
        hdr.append(block[i]); i+=1
    if i < len(block) and block[i].strip().startswith('@doc'):
        in_str=False
        while i < len(block):
            hdr.append(block[i]); _,in_str=_pd(block[i],in_str); i+=1
            if not in_str: break
    close_i = max(j for j in range(len(block)) if block[j].startswith(')'))
    body = block[i:close_i]; trailing = block[close_i:]
    # parse forms with attached leading comments; drop old markers/blank noise
    forms=[]; pend=[]; k=0
    while k < len(body):
        line=body[k]; m=FORM_RE.match(line)
        if m and line.startswith('    '):
            name=m.group(2); kind=m.group(1)
            depth=0;in_str=False;j=k;buf=[]
            while j<len(body):
                buf.append(body[j]); d,in_str=_pd(body[j],in_str); depth+=d; j+=1
                if depth<=0: break
            forms.append({'kind':kind,'name':name,'comments':pend,'body':buf}); pend=[]; k=j; continue
        s=line.strip()
        if s=='' or MARK_RE.match(line): k+=1; continue
        pend.append(line); k+=1
    # classify caps then all forms
    is_iface = block[0].startswith('(interface')
    capcaps=[(f['name'],f['body']) for f in forms if f['kind']=='defcap'
             and not (f['name']=='GOV' or f['name'].startswith('GOV|') or f['name'].startswith('P|'))]
    cb={n:v for n,(v,_) in cap_band.classify(capcaps).items()}
    base=lambda n: n.split(':')[0]
    has_gas = (not is_iface) and any(base(f['name']) in GAS_MEMBERS for f in forms)
    buckets={}
    for f in forms:
        if has_gas and base(f['name']) in GAS_MEMBERS: b="#"
        else: b=skeleton.classify_form(f['kind'],f['name'],cb)
        buckets.setdefault(b,[]).append(f)
    # safety: never silently drop a form — unknown buckets error out loudly
    valid={"0","#","G1","G2","G3","G4","G5","P1","P2","P3","P4","P5","3.1","3.2","3.3","C1","C2","C3","C4","5.1","5.2","5.3","5.4","5.5","5.6","5.7","6"}
    bad={b:[f['name'] for f in fs] for b,fs in buckets.items() if b not in valid}
    if bad: raise SystemExit(f"  UNPLACED forms in {block[0].strip()}: {bad}")
    # emit
    out=hdr[:]
    def emit_forms(fs):
        for f in fs:
            out.extend(f['comments']); out.extend(f['body'])
    if is_iface:
        order=[("1",True),("2",True),("3",True),("4",True),("5",True)]   # interfaces: no {0}/{#}/{6}
    else:
        order=[("0",False)]
        if has_gas: order.append(("#",False))
        order += [("1",True),("2",True),("3",True),("4",True),("5",True)]
        if "6" in buckets: order.append(("6",False))
    for blk,hassub in order:
        out.append(""); out.append(RULE)
        name = SUBS[blk][0] if hassub else FLAT[blk]
        out.append(f"    ;;{{{blk}}}  {name}")
        if not hassub:
            emit_forms(buckets.get(blk,[]))
        else:
            for tag,label in SUBS[blk][1]:
                note = f"  {IFACE_TABLE_NOTE}" if (is_iface and tag in IFACE_NO_TABLE) else ""
                out.append(f"    ;;{{{tag}}}  {label}{note}")
                emit_forms(buckets.get(tag,[]))
    out.append(""); out += trailing
    return [_align(l) for l in out]

def main(path):
    lines=open(path,encoding='utf-8').read().split('\n')
    segs=[]; i=0
    while i<len(lines):
        if lines[i].startswith('(module ') or lines[i].startswith('(interface '):
            j=i+1
            while j<len(lines) and not lines[j].startswith(')'): j+=1
            segs.append(('mod',lines[i:j+1])); i=j+1
        else: segs.append(('raw',[lines[i]])); i+=1
    out=[]
    for kind,seg in segs:
        out += emit_module(seg) if kind=='mod' else seg
    open(path,'w',encoding='utf-8').write('\n'.join(out))
    print(f"  emitted {path.split('/')[-1]}")

if __name__=='__main__':
    for p in sys.argv[1:]: main(p)
