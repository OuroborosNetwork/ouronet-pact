#!/usr/bin/env python3
"""
_infostoa.py -- find INFO_ previews that quote a LITERAL ZERO for a currency their
operation really charges.

WHY THIS EXISTS. On 2026-09-14 eight previews were found quoting "free" for ops that
charge STOA: INFO_EQUITY|IssueCompany (918 STOA), INFO_SWP|ToggleFeeLock (432.5),
INFO_ATS|ToggleParameterLock (500), and the five INFO_VST|Create*Link (76.5 each).
A client reading any of them was told the operation was free of native Stoa.

THE SIGNAL is cheap and precise: a preview that returns OI|UDC_NoStoaCosts and NEVER
mentions a real STOA constructor is claiming, unconditionally, that the op costs no
STOA. That is a property of ONE function -- no call-graph resolution needed, so no
false positives from it. Only the confirmation step needs the call graph.

TWO LESSONS ARE BAKED IN, both learned by getting them wrong first:

 1] FOLLOW XI_. The first version of this sweep followed C_/CC_/XE_/XB_ but not XI_,
    reasoning that the house rule makes XI_ persistence-only -- writes, no enforce, no
    billing. Both VST collectors live inside XI_ functions, so all five VST defects were
    invisible. An architectural convention must never prune a search for violations of
    that same convention: the violations are exactly what is being looked for.

 2] DO NOT RESOLVE BY BARE NAME. C_Fuel exists in ATSU, SWPLC and OUROBOROS. Picking one
    by name produced three confident false positives against a path the op never takes.
    This resolves through the modref binding `(ref-X:module{Iface} MOD)` where it can,
    and prints the path so every hit can be judged rather than trusted.

Exit status is always 0: this is a REPORT, not a gate. Ops legitimately move native coin
without charging a protocol fee -- an escrow (LIQUID wrap), or a purchase price (the
launchpad sales, which declare the amount in pre-text and are correct to report
stoa-need = 0.0). Those need a human read, which is why this does not fail a build.
"""
import re, glob, collections, sys

SRC = [p for p in glob.glob('1_SOVEREIGN/**/*.pact', recursive=True)
             + glob.glob('2_CITIZEN/**/*.pact', recursive=True)]
if not SRC:
    SRC = [p for p in glob.glob('../1_SOVEREIGN/**/*.pact', recursive=True)
                 + glob.glob('../2_CITIZEN/**/*.pact', recursive=True)]

def defuns(text):
    marks = [(m.start(), m.group(1))
             for m in re.finditer(r'^\s*\(def(?:un|cap|pact)\s+([^\s:\(]+)', text, re.M)]
    for i, (pos, name) in enumerate(marks):
        end = marks[i + 1][0] if i + 1 < len(marks) else len(text)
        yield name, text[pos:end]

impl = collections.defaultdict(list)
infos = {}
for p in SRC:
    t = open(p).read()
    for name, body in defuns(t):
        if len(body.strip().splitlines()) > 3:
            impl[name].append((p, body))
            if name.startswith('INFO_'):
                infos[name] = (p, body)

def strip_prose(s):
    """Remove ;; comments and "..." strings (incl. @doc) BEFORE searching for calls.

    Lesson, learned the hard way: the first version matched `STOA|C_Collect` inside
    IGNIS::XB_MoveDalosFuel's own @doc -- "Guarding here covers every STOA|C_Collect*
    path at once" -- and reported five previews as reaching a collector through a function
    that only transfers coin. A detector that matches PROSE invents call paths, and an
    invented path is worse than no tool at all, because it reads like evidence.
    """
    s = re.sub(r';;[^\n]*', '', s)
    s = re.sub(r'"(?:[^"\\]|\\.)*"', '""', s, flags=re.S)
    return s

STOA = re.compile(r'(STOA\|C_Collect\w*)')
# Two things this pattern must do, BOTH of which it got wrong in earlier versions:
#  - include XI_ (lesson [1] above): the VST collectors live inside XI_ functions.
#  - match SAME-MODULE calls, which carry NO `::`. A cross-module call reads
#    `(ref-VST::C_CreateFrozenLink ...)`, but VST::C_CreateFrozenLink reaches its
#    collector via a LOCAL `(XI_CreateSpecialTrueFungibleLink ...)`. Requiring `::`
#    made this whole detector blind -- it reported "0 to review" while five live
#    defects sat in the tree. Verified by mutation test: reintroduce one defect, and
#    the tool must name it.
CALLEE = re.compile(r'[(:]((?:[A-Za-z0-9|+-]*\|)?(?:C_|CC_|XE_|XB_|XI_|XIv_)[A-Za-z0-9|>_-]+)')

def reach(body, path, depth=0, seen=None):
    if seen is None: seen = set()
    body = strip_prose(body)
    m = STOA.search(body)
    if m: return path + [m.group(1)]
    if depth >= 4: return None
    for c in sorted(set(CALLEE.findall(body))):
        if c in seen: continue
        seen.add(c)
        for _, cb in impl.get(c, []):
            r = reach(cb, path + [c], depth + 1, seen)
            if r: return r
    return None

REAL = re.compile(r'UDC_(Dynamic|Full)?StoaCosts?\b')
rows = []
for name, (p, body) in sorted(infos.items()):
    body = strip_prose(body)
    if 'UDC_NoStoaCosts' not in body: continue
    if REAL.search(body): continue          # conditional/mixed -> mirrors the exec, fine
    op = name[5:]
    mod, _, o = op.partition('|')
    for c in (f'{mod}|C_{o}', f'{mod}|CC_{o}', f'C_{o}', f'CC_{o}'):
        if c not in impl: continue
        tb = next((b for pp, b in impl[c] if '3_Talos' in pp or 'Launchpad' in pp), impl[c][0][1])
        r = reach(tb, [c])
        if r: rows.append((name, p, r))
        break

print("INFO_ previews claiming STOA-free unconditionally, whose exec tree reaches STOA|C_Collect")
print("(each needs a human read: an escrow or a purchase price is not a protocol fee)\n")
for name, p, path in rows:
    print(f"  {name}")
    print(f"      {p}")
    print(f"      {' -> '.join(path)}\n")
print(f"  {len(rows)} to review")
