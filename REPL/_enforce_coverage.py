#!/usr/bin/env python3
"""ENFORCE COVERAGE (plan step 3.2) — which guards has a test actually PINNED?

    cd REPL && python3 _enforce_coverage.py [--module M] [--list]

G2 asks "is the guard we wrote working?" and is enumerable from the `enforce` statements. The
ledger cannot answer it: it credits assertions by TRANSACTION BLOCK, so an `expect-failure`
anywhere in a block counts for every op called in that block. That measures a neighbourhood, not
a guard.

This measures the guard directly, and it only became possible after 3.1: now that negative tests
carry the REAL message, an `enforce`'s own message text is the join key. If some
`expect-failure`'s expected-message is a substring of an `enforce`'s message, that test pins THAT
enforce and no other.

MATCHING AGAINST `(format …)` MESSAGES: the template's literal segments are fixed and its `{}`
holes are not, so only the literal runs can be matched. The longest literal segment of >= 12
characters is used; a template with no such segment is reported as UNMATCHABLE rather than
counted either way -- an honest third category instead of a guess.
"""
import argparse, collections, glob, os, re, sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))
ROOT = ".."

def strip_comments(src):
    out, i, n, in_str, esc = [], 0, len(src), False, False
    while i < n:
        c = src[i]
        if in_str:
            out.append(c)
            if esc: esc = False
            elif c == '\\': esc = True
            elif c == '"': in_str = False
            i += 1
        elif c == '"': in_str = True; out.append(c); i += 1
        elif c == ';':
            while i < n and src[i] != '\n': out.append(' '); i += 1
        else: out.append(c); i += 1
    return ''.join(out)

MEMBER  = re.compile(r'^\s{1,8}\((defun|defcap|defpact)\s+([^\s()]+)', re.M)
# An enforce plus the first string literal that follows it, within a bounded window.
#
# THE LOOKAHEAD IS LFAD-BEARING. `\b` after `enforce` matches inside `enforce-guard` too --
# `-` is a non-word character, so the boundary is right there. That silently pulled all 136
# `(enforce-guard g)` sites into the denominator and handed each one whatever string literal
# happened to follow within 900 characters, which is a MIS-ATTRIBUTED message: enforce-guard
# takes no message at all, Pact generates the keyset-failure text itself. Some of those
# borrowed strings then matched a real test's expected-message and were counted as PINNED.
# `(?![-\w])` keeps `enforce` and `enforce-one` and excludes every hyphenated relative.
ENF = re.compile(r'\((enforce|enforce-one)(?![-\w])(.{0,900}?)"((?:[^"\\]|\\.){4,})"', re.S)

def enforce_one_spans(src):
    """(start, end) of every (enforce-one …) form, balanced, string-aware."""
    spans = []
    for m in re.finditer(r'\(enforce-one\b', src):
        i, d, j, instr, esc = m.start(), 0, m.start(), False, False
        while j < len(src):
            c = src[j]
            if instr:
                if esc: esc = False
                elif c == '\\': esc = True
                elif c == '"': instr = False
            elif c == '"': instr = True
            elif c == '(': d += 1
            elif c == ')':
                d -= 1
                if d == 0: break
            j += 1
        spans.append((i, j))
    return spans

def literal_segments(msg):
    """The fixed runs of a (format …) template: everything between the {} holes."""
    return [p for p in re.split(r'\{\}', msg) if len(p.strip()) >= 12]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--module"); ap.add_argument("--list", action="store_true")
    a = ap.parse_args()

    # --- every expected-message a negative test pins -------------------------------------------
    # The first version required the message to sit on its OWN line (`"…"` followed by a
    # newline). Nine assertions written inline -- `"cannot be wiped" (ref-DPTF::UEV_CanWipeON b))`
    # -- were invisible to it, so a real coverage gain read as almost none and nearly got the
    # whole guard-family approach discarded. Extract the THIRD ARGUMENT structurally instead of
    # pattern-matching the layout.
    pinned = []
    for f in glob.glob("**/*.repl", recursive=True):
        if f.startswith("archive" + os.sep): continue
        src = open(f, encoding='utf8', errors='ignore').read()
        for m in re.finditer(r'\(expect-failure[\s\n]', src):
            # walk the form; collect top-level string literals. arg2 = doc, arg3 = expected msg.
            depth, i, n, strs, cur, in_str, esc = 0, m.start(), len(src), [], None, False, False
            while i < n:
                c = src[i]
                if in_str:
                    if esc: esc = False
                    elif c == '\\': esc = True
                    elif c == '"':
                        in_str = False
                        if depth == 1: strs.append(cur)
                        cur = None
                    if in_str and cur is not None: cur += c
                elif c == '"': in_str = True; cur = ''
                elif c == '(': depth += 1
                elif c == ')':
                    depth -= 1
                    if depth == 0: break
                i += 1
            if len(strs) >= 2:
                pinned.append(strs[1].replace('\\"', '"').replace('\\\\', '\\'))
    pinned = [p for p in pinned if len(p) >= 8]

    # --- every enforce site --------------------------------------------------------------------
    # DEAD MODULES — counted, reported, but kept OUT of the P3.3 worklist. Pinning a guard that
    # no caller can reach is not coverage, it is ceremony. Each entry needs a reason and a check
    # that the reason still holds; this is not a place to park anything merely inconvenient.
    #
    #   00_DPMF  the original MetaFungible, superseded by DPOF (CLAUDE.md § "Historical note").
    #            It IS deployed by [2.2]_Core -- it has to be, for migration provenance -- but
    #            grep finds exactly ONE call anywhere in the tree: P|A_Define, the policy
    #            boilerplate every module carries. No business function is reached by any module
    #            or any test. Owner's standing instruction: leave DPMF alone, it is dead code.
    DEAD = {"00_DPMF.pact": "superseded by DPOF; deployed for provenance, never called"}

    files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                               + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
             if "/Audit/" not in f]
    sites, covered, unmatchable, nested = [], [], [], []
    for f in files:
        src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        owners = [(m.start(), m.group(2)) for m in MEMBER.finditer(src)]
        eo = enforce_one_spans(src)
        for m in ENF.finditer(src):
            msg = m.group(3)
            owner = next((n for off, n in reversed(owners) if off < m.start()), "?")
            line = src[:m.start()].count('\n') + 1
            rec = (os.path.relpath(f, ROOT), line, owner, msg[:70])
            # UNREACHABLE BY CONSTRUCTION: an enforce nested inside an enforce-one branch list.
            # Pact tries each branch and, when every one fails, raises the enforce-one's OWN
            # message -- the inner messages are never surfaced. Verified rather than assumed:
            #
            #   (enforce-one "OUTER" [(enforce false "INNER-ONE") (enforce false "INNER-TWO")])
            #   => expected error message 'INNER-ONE', got 'OUTER-MESSAGE'
            #
            # So these messages document intent inside the branch list and nothing more. No
            # caller can see them and no test can pin them. Counting them as "unpinned" inflates
            # the worklist with work that cannot be done -- the same reason the {}-holes category
            # exists. The enforce-one's own message IS matchable and is counted normally.
            if m.group(1) == "enforce" and any(a < m.start() < b for a, b in eo):
                nested.append(rec); continue
            segs = literal_segments(msg)
            if not segs:
                unmatchable.append(rec); continue
            sites.append(rec)
            if any(any(p in s or s in p for p in pinned) for s in segs):
                covered.append(rec)

    tot = len(sites)
    print(f"ENFORCE COVERAGE — {len(files)} modules\n")
    print(f"  enforce sites with a matchable message : {tot}")
    print(f"  PINNED by a negative test              : {len(covered)} "
          f"({100*len(covered)//max(tot,1)}%)")
    print(f"  not pinned                             : {tot - len(covered)}")
    print(f"  message is all {{}} holes (unmatchable) : {len(unmatchable)}")
    print(f"  nested in an enforce-one (UNREACHABLE)  : {len(nested)}")
    print(f"  distinct expected-messages in the suite: {len(set(pinned))}")

    # PRECISION CAVEAT, measured rather than asserted. Attribution is by MESSAGE TEXT, and some
    # messages are worded identically in several modules -- "must be set to" appears in 7,
    # "cannot be wiped" in 4. Pinning one module's copy therefore credits every module's copy,
    # so PINNED is an upper bound for those. Quoting the headline without this number is the
    # same mistake as quoting coverage without its gated companion (RULE 11).
    allsegs = collections.defaultdict(set)
    for f in files:
        s2 = strip_comments(open(f, encoding='utf8', errors='ignore').read())
        for m in ENF.finditer(s2):
            for seg in literal_segments(m.group(3)):
                allsegs[seg.strip()].add(os.path.basename(f))
    shared = sum(1 for v in allsegs.values() if len(v) > 1)
    amb = sum(1 for r in covered
              if any(len(allsegs.get(seg.strip(), ())) > 1
                     for seg in literal_segments(r[3])))
    print(f"  ...of which pinned only via wording SHARED across modules: {amb} "
          f"({shared}/{len(allsegs)} segments are non-unique) -- PINNED is an upper bound\n")

    cov = {(f, l) for f, l, _, _ in covered}
    gaps = [r for r in sites if (r[0], r[1]) not in cov]
    per = collections.Counter(r[0].split('/')[-1] for r in gaps)
    dead_n = sum(c for f, c in per.items() if f in DEAD)
    if dead_n:
        print(f"\n  of the unpinned, {dead_n} sit in DEAD modules and are NOT worklist items:")
        for f, why in DEAD.items():
            if per.get(f): print(f"    {per[f]:4d}  {f}  — {why}")
        print(f"  LIVE unpinned (the real worklist total): {sum(per.values()) - dead_n}")

    print("\nunpinned enforce sites by module (the P3.3 worklist):")
    for f, c in per.most_common(20 if not a.list else 999):
        if f in DEAD: continue
        print(f"  {c:4d}  {f}")
    if a.list:
        print()
        for f, l, o, msg in gaps:
            if a.module and a.module not in f: continue
            print(f"  {f}:{l}  {o}\n        {msg}")
    return 0

sys.exit(main())
