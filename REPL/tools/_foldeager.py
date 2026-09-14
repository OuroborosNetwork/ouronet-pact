#!/usr/bin/env python3
"""[fold-eager] — a (fold (and) true [...]) whose LATER conjunct consumes a value an EARLIER
conjunct is still validating.

`fold` receives an ALREADY-BUILT list, so every conjunct is evaluated before `and` ever runs.
Verified, not assumed:

    (enforce (fold (and) true [false (enforce false "LATER-CONJUNCT-EVALUATED")]) "FOLD-MSG")
    => got 'LATER-CONJUNCT-EVALUATED'

So the idiom CLAUDE.md mandates for 3+ conditions -- `(enforce (fold (and) true [p q r]) "msg")` --
is NOT short-circuiting. That is usually harmless: the conjuncts are independent predicates. It is
a DEFECT when a later conjunct consumes the very value an earlier conjunct is validating, because
then the consumer raises first and the guard can never speak. TWO shapes are detected:

  [read]  a later conjunct HARD-READS a table with a value an earlier conjunct checks for BAR.
  [index] a later conjunct does (at <i> xs) while an earlier one checks (length xs). On an empty
          or short list the index raises "Array index out of bounds" -- an internal fault where the
          author clearly intended the length check to decide. Found in U|ATS::UEV_CRF|FeeArray,
          whose client ATS|C_SetColdRecoveryFees returns that raw fault for a plausible user input
          (fee-thresholds supplied, fee-array short). A VALIDATOR returning an index fault instead
          of its own message is the worst version of this: rejecting bad input is its only job.

Live instance that prompted this: RPS UEV_AddRewardLinkContext has
    [(!= multiplet-family-id BAR) (URC_MultipletFamilyExists …) (UR_FVT-MF|Active …) …]
and `UR_FVT-MF|Active` hard-reads FVT|T|MultipletFamily. Passing BAR aborts with
`No value found in table ... for key: |` instead of the written message, so the BAR case the first
conjunct exists to reject is unreachable.

Reported as an OBSERVATION, not a violation: the fix is per-site (hoist the BAR check into its own
enforce above the fold, or use a with-default-read reader), and some hits are benign.
"""
import re, glob, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _pactlex import strip_comments, balanced, split_top, reader_kinds, UR_CALL as READER

files = [f for f in sorted(glob.glob(f"{ROOT}/1_SOVEREIGN/**/*.pact", recursive=True)
                           + glob.glob(f"{ROOT}/2_CITIZEN/**/*.pact", recursive=True))
         if "/Audit/" not in f]

GUARDING = re.compile(r'\((?:!=|=)\s+([A-Za-z][A-Za-z0-9|_-]*)\s+(?:BAR|\(ref-[A-Za-z0-9|_-]+::CT_BAR\))\)')

# HARD vs SOFT reader classification lives in _pactlex.reader_kinds -- shared with _eagerlet.py.
# Without it this rule is noise: 3 of its first 4 hits passed the guarded value to
# UR_FVT-SEL|Enabled, which resolves through a with-default-read whose @doc says "absent rows read
# as disabled", so eager evaluation there is harmless.
HARD = reader_kinds(files)
total, hits, soft_skipped, index_hits = 0, [], 0, []
for f in files:
    src = strip_comments(open(f, encoding='utf8', errors='ignore').read())
    # name -> list, for `let` bindings of the form (l-fa:integer (length fee-array))
    LEN_ALIAS = {a: b for a, b in
                 re.findall(r'\(([A-Za-z][A-Za-z0-9|_-]*):integer\s+\(length\s+'
                            r'([A-Za-z][A-Za-z0-9|_-]*)\)\)', src)}
    for m in re.finditer(r'\(fold\s+\(and\)\s+true\s*\[', src):
        lb = src.index('[', m.start())
        rb = balanced(src, lb, '[', ']')
        if rb < 0: continue
        total += 1
        conjuncts = split_top(src[lb+1:rb])

        # [index] shape: an earlier conjunct measures (length xs); a later one indexes (at i xs).
        # `fold` builds the whole list first, so the index runs regardless of what the length says.
        # The length is usually LET-BOUND above the fold rather than written inline -- e.g.
        # (l-fa:integer (length fee-array)) -- so aliases are resolved first, or this finds nothing.
        for idx, c in enumerate(conjuncts):
            measured = {lm.group(1) for lm in
                        re.finditer(r'\(length\s+([A-Za-z][A-Za-z0-9|_-]*)\)', c)}
            for alias, lst in LEN_ALIAS.items():
                if re.search(r'\b' + re.escape(alias) + r'\b', c):
                    measured.add(lst)
            for lvar in measured:
                for later in conjuncts[idx+1:]:
                    if re.search(r'\(at\s+\d+\s+' + re.escape(lvar) + r'\b', later):
                        index_hits.append((os.path.relpath(f, ROOT),
                                           src[:m.start()].count('\n') + 1, lvar,
                                           later.strip()[:80]))
                        break

        for idx, c in enumerate(conjuncts):
            g = GUARDING.search(c)
            if not g: continue
            var = g.group(1)
            for later in conjuncts[idx+1:]:
                rd = READER.search(later)
                if rd and rd.group(1) not in HARD:
                    soft_skipped += 1; continue
                if rd and re.search(r'\b' + re.escape(var) + r'\b', later):
                    hits.append((os.path.relpath(f, ROOT), src[:m.start()].count('\n') + 1,
                                 var, rd.group(1), later.strip()[:80]))
                    break

print(f"(fold (and) true [...]) sites scanned: {total}")
print(f"hard readers identified: {len(HARD)}   soft-read conjuncts skipped: {soft_skipped}")
print(f"sites where a LATER conjunct HARD-READS the value an EARLIER one guards: {len(hits)}\n")
seen = set()
for f, line, var, rdr, snippet in hits:
    if (f, line) in seen: continue
    seen.add((f, line))
    print(f"  {f}:{line}")
    print(f"      guarded var : {var}   consumed by: {rdr}")
    print(f"      later conjunct: {snippet}")

seen_i = set()
print(f"\n[index] sites where a LATER conjunct INDEXES a list an EARLIER one measures: "
      f"{len({(h[0], h[1]) for h in index_hits})}\n")
for f, line, var, snippet in index_hits:
    if (f, line) in seen_i: continue
    seen_i.add((f, line))
    print(f"  {f}:{line}")
    print(f"      measured list: {var}   indexed before the length check can decide")
    print(f"      later conjunct: {snippet}")
