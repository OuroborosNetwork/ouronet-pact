#!/usr/bin/env python3
"""_nokey.py -- retired table keys must not come back into deployable source.

A key that no module reads is inert, and a key that ONE module reads is a second source of truth.
The difference between the two is a single line of code, and nothing in the toolchain noticed the
last time it was crossed.

RETIRED 2026-10-02 (owner ruling): `stoa|price`.

    "usage prices are just that, prices for some sort of usage, not for stoa itself,
     which is captured via a function in the U|CT module"

`IGNIS::UC_StoaPrice` divided the dollar deter by a row in the USAGE-PRICES table, while the
canonical STOA/USD reader -- `U|CT::UR_STOA-PID|Price`, the DIA oracle stub -- is read in ~40
places across the tree, including `OI|UDC_FullStoaCosts` a hundred lines above it in the SAME
module. One function against forty. Moving the peg therefore moved the CHARGE and not the
PREVIEW, and the key was never written on mainnet at all, so every STOA-charging operation died
on an uncatchable missing-row read while the REPL -- which seeded the row at boot -- stayed green.

WHY A GREP AND NOT A TEST. The obvious regression test writes the key and asserts nothing
changes. That proves the right property by the wrong means: it keeps the retired key alive in the
suite, which is a standing reason for it to come back. A source-level ban needs no fixture, holds
for code paths no test reaches, and fails before any suite runs.

Scope is `.pact` only -- what actually deploys. Prose in `.repl`, tools and docs may name a
retired key to explain why it is retired; that is the opposite of reintroducing it.

  python3 REPL/tools/_nokey.py --check     fatal on any hit
"""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOPS = ("1_SOVEREIGN", "2_CITIZEN")

# key -> why it is retired and what replaced it
RETIRED = {
    "stoa|price": "the STOA/USD peg -- use U|CT::UR_STOA-PID|Price (owner ruling 2026-10-02)",
}


def main():
    hits = []
    for top in TOPS:
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if not f.endswith(".pact"):
                    continue
                p = os.path.join(d, f)
                for i, ln in enumerate(open(p, encoding="utf8", errors="ignore"), 1):
                    for k in RETIRED:
                        if k in ln:
                            hits.append((os.path.relpath(p, ROOT), i, k, ln.strip()[:70]))
    if hits:
        print(f"!! {len(hits)} RETIRED KEY reference(s) in deployable source:")
        for p, i, k, ln in hits:
            print(f"   {p}:{i}  <{k}>\n      {ln}\n      -> {RETIRED[k]}")
        return 1
    print(f"retired keys: clean -- none of the {len(RETIRED)} retired key(s) appear in any .pact")
    return 0


if __name__ == "__main__":
    sys.exit(main())
