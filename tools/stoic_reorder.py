#!/usr/bin/env python3
"""StoicSyntax FUNCTIONS-region reorder (§5.4). Groups defun/defpact forms into the
canonical 7/8-class order, gluing `…x` aux to its parent, regenerating ;;{Fx} markers.
ONLY reorders the FUNCTIONS region; preamble (gov/policy/schemas/caps) + trailing
(module close, create-table) are left byte-for-byte. Prints a summary; does not gate."""
import sys, re

# class label + rank. Longest-prefix-first matters for detection.
CLASSES = [
    ("F1", "Construct [UDC]",              ["UDCx_","UDC_"]),
    ("F2", "Compute [UC]",                 ["UCkx_","UCxx_","UCk_","UCv_","UCx_","UC_"]),
    ("F3", "Read [UR/URC/URH/URCi/INFO]",  ["URHCx_","URHC_","URHx_","URH_","URCix_","URCi_","URCx_","URCv_","URC_","URU_","UR_","INFO_"]),
    ("F4", "Validate [UEV/CAP]",           ["UEV_","CAP_"]),
    ("F5", "Write [W]",                    ["WI_","WU7_","WU6_","WU5_","WU4_","WU3_","WU2_","WU_","WW_"]),
    ("F6", "Aux/Protected [X]",            ["XI_","XE_","XB_"]),
    ("F7", "User [A]",                     ["AAp_","AA_","Ap_","AUx_","AU_","A_"]),
    ("F8", "User [C]",                     ["CCp_","CC_","Cp_","C_"]),
    ("F9", "REPL (test-only, stripped at mainnet) [REPL]", ["REPL_"]),
]

def paren_delta(line, in_str):
    """Net '(' - ')' over CODE only, skipping string contents and ;; line comments."""
    d=0; i=0; n=len(line)
    while i < n:
        c=line[i]
        if in_str:
            if c=='\\': i+=2; continue
            if c=='"': in_str=False
            i+=1; continue
        if c=='"': in_str=True; i+=1; continue
        if c==';' and i+1<n and line[i+1]==';': break  # rest is comment
        if c=='(': d+=1
        elif c==')': d-=1
        i+=1
    return d, in_str
AUX_MARK = ("UCx_","UCkx_","UCxx_","URCx_","URHx_","URHCx_","URCix_","UDCx_","AUx_")

def prefix_of(name):
    # strip leading MODULE| scopes (segments ending in | before the first _)
    us = name.find('_')
    if us == -1: return None
    before = name[:us]
    tok = (before.rsplit('|',1)[1] if '|' in before else before) + '_'
    return tok

def class_rank(name):
    tok = prefix_of(name)
    if tok is None: return (99, name)  # unknown -> keep at end of its neighbourhood
    for i,(fx,label,prefixes) in enumerate(CLASSES):
        if tok in prefixes: return (i, )
    # numbered-admin steps (A01_ … A11_, A09a_) are canon User [A]
    if re.match(r'^A\d+[a-z]?_$', tok):
        return (next(i for i,(fx,_,_) in enumerate(CLASSES) if fx=="F7"),)
    return (99,)

def is_aux(name):
    tok = prefix_of(name)
    return tok in AUX_MARK

def reorder_block(block):
    """Reorder the FUNCTIONS region of ONE module block (list of lines).
    Returns (new_block_lines, forms_count, ncls_dict, unknown_names)."""
    # locate ;;FUNCTIONS header and the module-close ')' at column 0 (within this block)
    fstart = next((i for i,l in enumerate(block) if l.strip()==';;FUNCTIONS'), None)
    if fstart is None:
        return block, 0, {}, []
    close = next((i for i in range(len(block)-1, fstart, -1) if block[i].startswith(')')), None)
    if close is None:
        return block, 0, {}, []
    preamble = block[:fstart+1]
    region   = block[fstart+1:close]
    trailing = block[close:]
    # parse region into forms with attached leading comments; drop old ;;{Fx} markers & blank noise
    forms=[]; i=0; pending_comments=[]
    def is_marker(s): return re.match(r';;\{F\d', s.strip())
    while i < len(region):
        line = region[i]; s = line.strip()
        m = re.match(r'\s*\(def(un|pact)\s+([^\s\(\):]+)', line)
        if m:
            name = m.group(2)
            # balanced-paren scan (string/comment-aware)
            depth=0; j=i; buf=[]; in_str=False
            while j < len(region):
                buf.append(region[j])
                dd,in_str = paren_delta(region[j], in_str)
                depth += dd
                j+=1
                if depth<=0: break
            forms.append({"name":name, "comments":pending_comments, "body":buf})
            pending_comments=[]; i=j; continue
        if s=='' :
            i+=1; continue
        if is_marker(s):
            i+=1; continue
        # a comment line (belongs to the next form)
        pending_comments.append(line); i+=1
    # build UNITS: a non-aux form + following aux forms glued
    units=[]
    for f in forms:
        if is_aux(f["name"]) and units:
            units[-1]["forms"].append(f)
        else:
            units.append({"key":class_rank(f["name"]), "forms":[f], "name":f["name"]})
    # stable sort units by class rank
    units_sorted = sorted(enumerate(units), key=lambda t:(t[1]["key"], t[0]))
    # emit
    out = preamble[:]
    ci = 0
    # group emitted forms by class to place markers
    by_class = {i:[] for i in range(len(CLASSES))}
    unknowns=[]
    for _,u in units_sorted:
        r = u["key"][0]
        if r==99: unknowns.append(u)
        else: by_class[r].append(u)
    for idx,(fx,label,_) in enumerate(CLASSES):
        out.append(f"    ;;{{{fx}}}  {label}")
        for u in by_class[idx]:
            for f in u["forms"]:
                out.extend(f["comments"])
                out.extend(f["body"])
    if unknowns:
        out.append("    ;;{F?}  UNCLASSIFIED (review)")
        for u in unknowns:
            for f in u["forms"]:
                out.extend(f["comments"]); out.extend(f["body"])
    out.append("    ;;")
    out += trailing
    ncls={CLASSES[k][0]:len(by_class[k]) for k in range(len(CLASSES)) if by_class[k]}
    return out, len(forms), ncls, [u['name'] for u in unknowns]

def main(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    # segment file into top-level (module …) blocks and raw lines; reorder each block
    segments=[]; i=0
    while i < len(lines):
        if lines[i].startswith('(module '):
            j=i+1
            while j < len(lines) and not lines[j].startswith(')'):
                j+=1
            segments.append(('mod', lines[i:j+1])); i=j+1
        else:
            segments.append(('raw',[lines[i]])); i+=1
    total=0; ncls_all={}; unknown_all=[]; nmods=0; new_lines=[]
    for kind, seg in segments:
        if kind=='mod':
            newseg, nf, ncls, unk = reorder_block(seg)
            new_lines += newseg
            if nf: nmods+=1
            total+=nf
            for k,v in ncls.items(): ncls_all[k]=ncls_all.get(k,0)+v
            unknown_all += unk
        else:
            new_lines += seg
    open(path,'w',encoding='utf-8').write('\n'.join(new_lines))
    tag = f" [{nmods} modules]" if nmods>1 else ""
    print(f"  {path.split('/')[-1]}: {total} forms{tag} -> {ncls_all}" + (f"  UNKNOWN={unknown_all}" if unknown_all else ""))

if __name__=="__main__":
    for p in sys.argv[1:]: main(p)
