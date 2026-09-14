#!/usr/bin/env python3
"""
_letfix.py — canon §7.16 let/let* vertical-staircase normalizer (surgical).

MODES:
  analyze  <files...>  : classify every (let/(let* form; report inline vs vertical, binding counts
  fix-oneliner <files> : expand ONLY fully-single-line (let ...) forms to canonical vertical layout

A "let form" = a '(' immediately followed (ws only) by the atom 'let' or 'let*'.
Tokenizer respects "..." strings (with \\ escapes) and ';' line comments.
Non-let text is preserved byte-for-byte; only the targeted let-forms are re-emitted.
"""
import sys, re

def tokenize(s):
    """Yield (kind, start, end) over s. kind in {'(',')','str','comment','atom','ws'}."""
    i, n = 0, len(s)
    toks = []
    while i < n:
        c = s[i]
        if c == '"':
            j = i + 1
            while j < n:
                if s[j] == '\\':
                    j += 2; continue
                if s[j] == '"':
                    j += 1; break
                j += 1
            toks.append(('str', i, j)); i = j
        elif c == ';':
            j = i
            while j < n and s[j] != '\n':
                j += 1
            toks.append(('comment', i, j)); i = j
        elif c == '(':
            toks.append(('(', i, i+1)); i += 1
        elif c == ')':
            toks.append((')', i, i+1)); i += 1
        elif c in ' \t\r\n':
            j = i
            while j < n and s[j] in ' \t\r\n':
                j += 1
            toks.append(('ws', i, j)); i = j
        else:
            j = i
            while j < n and s[j] not in '()"; \t\r\n':
                j += 1
            toks.append(('atom', i, j)); i = j
    return toks

def match_parens(toks):
    """Return dict: index-of-'(' -> index-of-matching-')' (over token list)."""
    stack, match = [], {}
    for idx, (k, a, b) in enumerate(toks):
        if k == '(':
            stack.append(idx)
        elif k == ')':
            if stack:
                o = stack.pop(); match[o] = idx
    return match

def find_let_forms(toks, match):
    """Return list of (open_idx, close_idx, letkind_tokidx) for each let/let* form."""
    out = []
    for idx, (k, a, b) in enumerate(toks):
        if k != '(':
            continue
        # next non-ws token
        j = idx + 1
        while j < len(toks) and toks[j][0] == 'ws':
            j += 1
        if j < len(toks) and toks[j][0] == 'atom':
            atom = None  # filled by caller with src
            out.append((idx, match.get(idx), j))
    return out

def analyze(path):
    s = open(path).read()
    toks = tokenize(s)
    match = match_parens(toks)
    lets = []
    for idx, (k, a, b) in enumerate(toks):
        if k != '(':
            continue
        j = idx + 1
        while j < len(toks) and toks[j][0] == 'ws':
            j += 1
        if j < len(toks) and toks[j][0] == 'atom' and s[toks[j][1]:toks[j][2]] in ('let', 'let*'):
            close = match.get(idx)
            if close is None:
                continue
            open_off, close_off = toks[idx][1], toks[close][2]
            oneline = '\n' not in s[open_off:close_off]
            lets.append((idx, close, oneline, open_off, close_off))
    total = len(lets)
    oneliners = sum(1 for L in lets if L[2])
    return total, oneliners

def toks_nonws(s):
    return [(k, s[a:b]) for (k, a, b) in tokenize(s) if k != 'ws']

def top_forms(toks, match, lo_tok, hi_tok, s):
    """Return list of source substrings for each top-level sub-form in token range (lo_tok, hi_tok) exclusive of the bounding parens. lo_tok/hi_tok are the '(' and ')' token indices."""
    out = []
    j = lo_tok + 1
    while j < hi_tok:
        k = toks[j][0]
        if k == 'ws':
            j += 1; continue
        if k == '(':
            close = match[j]
            out.append(s[toks[j][1]:toks[close][2]])
            j = close + 1
        elif k in ('atom', 'str', 'comment'):
            out.append(s[toks[j][1]:toks[j][2]])
            j += 1
        else:  # stray ')'
            j += 1
    return out

def reprint_let(s, toks, match, open_tok, close_tok, base):
    """Return canonical multi-line string for the let-form [open_tok..close_tok]; first line '(let' carries NO leading indent (caller supplies `base` spaces already)."""
    I = ' ' * base; I4 = ' ' * (base + 4); I8 = ' ' * (base + 8)
    # keyword
    j = open_tok + 1
    while toks[j][0] == 'ws':
        j += 1
    kw = s[toks[j][1]:toks[j][2]]           # let / let*
    if kw not in ('let', 'let*'):
        return None
    # binding-list open
    j += 1
    while j < close_tok and toks[j][0] == 'ws':
        j += 1
    if j >= close_tok or toks[j][0] != '(':
        return None
    bl_open = j; bl_close = match[bl_open]
    bindings = top_forms(toks, match, bl_open, bl_close, s)
    body = top_forms(toks, match, bl_close, close_tok, s)
    if not body:
        return None
    lines = [f"({kw}"]
    lines.append(f"{I4}(")
    for b in bindings:
        lines.append(f"{I8}{b}")
    lines.append(f"{I4})")
    for bd in body:
        lines.append(f"{I4}{bd}")
    lines.append(f"{I})")
    return '\n'.join(lines)

def oneline_lets(s):
    """Return list of (open_tok, close_tok, open_off, close_off) for fully-one-line let-forms, outermost-first."""
    toks = tokenize(s); match = match_parens(toks)
    res = []
    for idx, (k, a, b) in enumerate(toks):
        if k != '(':
            continue
        j = idx + 1
        while j < len(toks) and toks[j][0] == 'ws':
            j += 1
        if j < len(toks) and toks[j][0] == 'atom' and s[toks[j][1]:toks[j][2]] in ('let', 'let*'):
            close = match.get(idx)
            if close is None:
                continue
            oo, co = toks[idx][1], toks[close][2]
            if '\n' not in s[oo:co]:
                res.append((idx, close, oo, co))
    return toks, match, res

DEFUN_HEAD = re.compile(r'^(\s*)\((?:defun|defconst)\s.*\s$')

def fix_file(path, apply):
    s = open(path).read()
    changed = 0
    # iterate to fixpoint (handles nested one-liners), re-tokenizing each pass
    for _ in range(5000):
        toks, match, lets = oneline_lets(s)
        # pick the FIRST actionable let (line-start Case A or accessor-defun Case B), leftmost
        target = None
        for (ot, ct, oo, co) in lets:
            linestart = s.rfind('\n', 0, oo) + 1
            lineend = s.find('\n', co)
            if lineend == -1:
                lineend = len(s)
            prefix = s[linestart:oo]
            suffix = s[co:lineend]
            if prefix.strip() == '':           # Case A: let starts its line
                base = len(prefix)
                rep = reprint_let(s, toks, match, ot, ct, base)
                if rep is None:
                    continue
                new = s[:oo] + rep + s[co:]
                target = ('A', new); break
            m = DEFUN_HEAD.match(prefix)
            if m and suffix == ')':            # Case B: accessor one-line defun, let is its body
                indent = m.group(1)
                header = prefix.strip()        # "(defun NAME ARGS"
                rep = reprint_let(s, toks, match, ot, ct, len(indent) + 4)
                if rep is None:
                    continue
                block = f"{indent}{header}\n{indent}    {rep}\n{indent})"
                new = s[:linestart] + block + s[lineend:]
                target = ('B', new); break
        if target is None:
            break
        s = target[1]; changed += 1
    if changed:
        # SAFETY: token-invariance
        orig = open(path).read()
        if toks_nonws(orig) != toks_nonws(s):
            print(f"  !! TOKEN MISMATCH, refusing: {path}")
            return 0
        if apply:
            open(path, 'w').write(s)
    return changed

def let_forms_all(s):
    """(open_tok, close_tok) for every let/let* form."""
    toks = tokenize(s); match = match_parens(toks)
    out = []
    for idx, (k, a, b) in enumerate(toks):
        if k != '(':
            continue
        j = idx + 1
        while j < len(toks) and toks[j][0] == 'ws':
            j += 1
        if j < len(toks) and toks[j][0] == 'atom' and s[toks[j][1]:toks[j][2]] in ('let', 'let*'):
            close = match.get(idx)
            if close is not None:
                out.append((idx, close))
    return toks, match, out

def noncanonical(s, toks, match, ot, ct):
    """True if let-form [ot..ct] has inline-open OR crammed-close (canon §7.16 forbidden)."""
    j = ot + 1
    while toks[j][0] == 'ws':
        j += 1
    kw = j                                   # let / let*
    j += 1
    while j < ct and toks[j][0] == 'ws':
        j += 1
    if j >= ct or toks[j][0] != '(':
        return False                         # malformed; leave alone
    bl_open = j
    opener_ok = '\n' in s[toks[kw][2]:toks[bl_open][1]]
    close_off = toks[ct][1]
    linestart = s.rfind('\n', 0, close_off) + 1
    closer_ok = s[linestart:close_off].strip() == ''
    return not (opener_ok and closer_ok)

def fix_open_file(path, apply):
    s = open(path).read()
    orig = s
    changed = 0
    for _ in range(6000):
        toks, match, lets = let_forms_all(s)
        target = None
        for (ot, ct) in lets:
            if not noncanonical(s, toks, match, ot, ct):
                continue
            oo, co = toks[ot][1], toks[ct][2]
            linestart = s.rfind('\n', 0, oo) + 1
            base = oo - linestart            # column of '(let' (assumes leading ws only)
            if s[linestart:oo].strip() != '':
                continue                     # let not at line start (mid-line) — skip this pass
            rep = reprint_let(s, toks, match, ot, ct, base)
            if rep is None:
                continue
            new = s[:oo] + rep + s[co:]
            target = new; break
        if target is None:
            break
        s = target; changed += 1
    if changed:
        if toks_nonws(orig) != toks_nonws(s):
            print(f"  !! TOKEN MISMATCH, refusing: {path}")
            return 0
        if apply:
            open(path, 'w').write(s)
    return changed

if __name__ == '__main__':
    mode = sys.argv[1]
    files = sys.argv[2:]
    if mode == 'analyze':
        gt = go = 0
        for f in files:
            t, o = analyze(f)
            gt += t; go += o
            if t:
                print(f"  {t:4d} lets  {o:4d} one-line   {f}")
        print(f"TOTAL: {gt} let-forms, {go} fully-one-line")
    elif mode in ('fix', 'dry'):
        apply = (mode == 'fix')
        tot = 0
        for f in files:
            c = fix_file(f, apply)
            if c:
                tot += c
                print(f"  {c:4d} fixed   {f}")
        print(f"TOTAL fixed: {tot}  ({'APPLIED' if apply else 'DRY-RUN'})")
    elif mode in ('fixopen', 'dryopen'):
        apply = (mode == 'fixopen')
        tot = 0
        for f in files:
            c = fix_open_file(f, apply)
            if c:
                tot += c
                print(f"  {c:4d} fixed   {f}")
        print(f"TOTAL open-fixed: {tot}  ({'APPLIED' if apply else 'DRY-RUN'})")
