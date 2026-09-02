#!/usr/bin/env python3
"""A4 Talos-wrapper flip (StoicSyntax §2.1): SCOPE|PREFIX_Name -> PREFIX_SCOPE|Name.

Safety: the flip map is built ONLY from real definition names (defun/defcap/defpact)
matching the wrapper pattern across sovereign+citizen+sample .pact — so no accidental
string/pattern gets flipped. Each exact token is then rewritten everywhere (pact+repl)
with identifier-boundary guards. The rewrite is character-preserving, so the usual
non-comment-char invariant cannot validate it — green-gate is the real check.

Usage: flip_talos.py --dry   (report map + counts, no writes)
       flip_talos.py --apply  (write changes)
"""
import sys, re, os, glob

PREFIX = r'(CCp|CC|Cp|C|AAp|AA|Ap|A)'
DEF_RE = re.compile(r'\(def(?:un|cap|pact)\s+([A-Za-z0-9-]+\|' + PREFIX + r'_[A-Za-z0-9|_-]*)')
# single-pipe scope, client/admin prefix, then name
TOKEN_RE = re.compile(r'^([A-Za-z0-9-]+)\|' + PREFIX + r'_(.+)$')
IDCHAR = r'[A-Za-z0-9|_>-]'

ROOTS_DEF = ['1_SOVEREIGN', '2_CITIZEN', '0_Sample']
ROOTS_APPLY = ['1_SOVEREIGN', '2_CITIZEN', '0_Sample', 'REPL']
SCRATCH = re.compile(r'_scratch|_probe|_audit_ats_baseline|_cov_draft|_iso_check|_baseline_66')

def flip(tok):
    m = TOKEN_RE.match(tok)
    if not m: return None
    scope, pfx, name = m.group(1), m.group(2), m.group(3)
    return f'{pfx}_{scope}|{name}'

def all_files(roots, exts):
    for r in roots:
        for e in exts:
            for p in glob.glob(f'{r}/**/*{e}', recursive=True):
                if not SCRATCH.search(p):
                    yield p

def build_map():
    m = {}
    for p in all_files(ROOTS_DEF, ['.pact']):
        txt = open(p, encoding='utf-8').read()
        for dm in DEF_RE.finditer(txt):
            tok = dm.group(1)
            f = flip(tok)
            if f and f != tok:
                m[tok] = f
    return m

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else '--dry'
    fmap = build_map()
    # guard-boundaried compiled patterns, longest token first
    toks = sorted(fmap, key=len, reverse=True)
    pats = [(re.compile(r'(?<!' + IDCHAR + ')' + re.escape(t) + r'(?!' + IDCHAR + ')'), fmap[t]) for t in toks]
    print(f"flip map: {len(fmap)} distinct definition tokens")
    # sanity: show a few + any suspicious (very short name, etc.)
    for t in toks[:6] + toks[-6:]:
        print(f"   {t}  ->  {fmap[t]}")
    total = 0; files_changed = 0
    for p in all_files(ROOTS_APPLY, ['.pact', '.repl']):
        txt = open(p, encoding='utf-8').read()
        new = txt; n = 0
        for rx, rep in pats:
            new, c = rx.subn(rep, new); n += c
        if n:
            total += n; files_changed += 1
            if mode == '--apply':
                open(p, 'w', encoding='utf-8').write(new)
    print(f"{'APPLIED' if mode=='--apply' else 'DRY'}: {total} occurrences across {files_changed} files")

if __name__ == '__main__':
    main()
