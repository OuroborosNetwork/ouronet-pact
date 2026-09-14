#!/usr/bin/env python3
"""
REPL/_ladder.py -- the citizen minters' BATCH LADDERS must tile their collection exactly once.

WHY THIS IS A STATIC CHECK AND NOT A .repl TEST.
The property lives in the SOURCE, not in any reachable state: `A_Fix07` is a one-line wrapper whose
entire content is three literals handed to `C_Fix`. A REPL cannot read those literals -- it can only
execute a rung and observe the write -- so pinning the whole ladder from a .repl would mean running
24 transactions per ladder and still not catching a rung that was never called. The bug class here
is arithmetic on literals, so the instrument is arithmetic on literals.

WHAT IT CHECKS, per ladder:
  1] every rarity is tiled CONTIGUOUSLY from position 1, with no gap and no overlap;
  2] no rung exceeds MAX_RUNG positions. That bound is not style. `C_Fix`/`C_Spawn` enforce
     (= (length mdm) number-of-positions), so the rung size IS the caller's list size, and the
     per-transaction gas budget is why the ladders carry split `a`/`b` rungs at rarity boundaries
     at all. A rung over the bound is a rung that may not fit on chain;
  3] the Fix ladder and the Spawn ladder are IDENTICAL rung-for-rung. Fix exists to re-write the
     metadata of tiles Spawn minted, so a Fix rung that does not correspond to a Spawn rung is
     addressing positions that were never minted the same way.

FOUND ON FIRST RUN (2026-09-14): NOSFERATU `A_Fix01` read `Legendary 1 100` where its twin
`A_Step01` reads `Legendary 1 70`. It double-covered Legendary 71-100 with `A_Fix02a` and demanded
a 100-row mdm list from a ladder built entirely out of <=70 rungs. Every other rung of both ladders
matched exactly, which is what made the single odd one invisible to review.

    python3 REPL/_ladder.py            # report
    python3 REPL/_ladder.py --check    # exit 1 on any violation (gate mode)
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAX_RUNG = 70

# (file, ladder-name, callee) -- the wrapper families that encode a tiling as literals.
# Two collection shapes exist and both are handled: NOSFERATU is RARITY-TIERED (each rung names a
# rarity and tiles within it), KBunnies is FLAT (one namespace, no rarity argument). The parser
# below accepts either; a ladder that parses ZERO rungs is a violation, not a skip, because the
# usual cause is that the call shape moved and the check silently stopped checking anything.
LADDERS = [
    ("2_CITIZEN/3_NosferatuMinter/01_NOSFERATU.pact", "A_Fix",  "C_Fix"),
    ("2_CITIZEN/3_NosferatuMinter/01_NOSFERATU.pact", "A_Step", "C_Spawn"),
    ("2_CITIZEN/4_BunniesMinter/02_KBunnies.pact",    "A_Step", "C_Spawn"),
]
FLAT = "(flat)"   # the pseudo-rarity used for collections with no rarity argument

def rungs(src, callee):
    """(rarity, start, count) per literal call. <rarity> is FLAT for rarity-less collections."""
    tiered = re.compile(r'\(' + re.escape(callee) + r'\s+patron\s+\S+\s+(?:\S+\s+)??"(\w+)"\s+(\d+)\s+(\d+)')
    plain  = re.compile(r'\(' + re.escape(callee) + r'\s+patron\s+\S+\s+(\d+)\s+(\d+)')
    out = [(m.group(1), int(m.group(2)), int(m.group(3))) for m in tiered.finditer(src)]
    if out:
        return out
    return [(FLAT, int(m.group(1)), int(m.group(2))) for m in plain.finditer(src)]

def check():
    problems, seen = [], {}
    for rel, name, callee in LADDERS:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            problems.append(f"{rel} -- configured ladder file does not exist (moved or renamed?)")
            continue
        L = rungs(open(path, errors="ignore").read(), callee)
        key = (rel, name)
        if not L:
            problems.append(f"{rel} :: {name} -- no rungs parsed (did the call shape change?)")
            continue
        seen[key] = L
        per = {}
        for r, st, c in L:
            per.setdefault(r, []).append((st, c))
            if c > MAX_RUNG:
                problems.append(f"{rel} :: {name} -- rung {r} {st}+{c} exceeds the {MAX_RUNG}-position budget")
        for r, segs in sorted(per.items()):
            cur = 1
            for st, c in sorted(segs):
                if st != cur:
                    problems.append(
                        f"{rel} :: {name} -- {r} {'GAP' if st > cur else 'OVERLAP'}: "
                        f"expected next rung to start at {cur}, found {st}")
                cur = st + c
        total = sum(c for _, _, c in L)
        print(f"  {rel.split('/')[-1]:<22} {name:<7} {len(L):>3} rungs  {total:>5} positions  "
              + "  ".join(f"{r}:{sum(c for s,c in v)}" for r, v in sorted(per.items())))
    # twin comparison -- only where BOTH families exist. KBunnies has no A_Fix family: its
    # metadata is set at spawn, so there is no second ladder to agree with.
    for rel in {r for r, _, _ in LADDERS}:
        f, s = seen.get((rel, "A_Fix")), seen.get((rel, "A_Step"))
        if f and s and f != s:
            for i, (a, b) in enumerate(zip(f, s)):
                if a != b:
                    problems.append(f"{rel} -- rung {i+1} differs: A_Fix {a} vs A_Step {b}")
            if len(f) != len(s):
                problems.append(f"{rel} -- ladder LENGTHS differ: A_Fix {len(f)} vs A_Step {len(s)}")
    return problems

if __name__ == "__main__":
    print("BATCH LADDER TILING")
    probs = check()
    if probs:
        print("\nVIOLATIONS:")
        for p in probs:
            print("   " + p)
    else:
        print("\n  clean -- every ladder tiles its collection exactly once, within budget, and "
              "each Fix ladder matches its Spawn twin.")
    sys.exit(1 if (probs and "--check" in sys.argv) else 0)
