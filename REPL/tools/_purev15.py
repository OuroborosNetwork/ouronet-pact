#!/usr/bin/env python3
"""_purev15.py -- emit and verify the PureV15 hand-deploy round.

    python3 REPL/tools/_purev15.py --write    emit Deploy/PureV15/
    python3 REPL/tools/_purev15.py --check    verify the emitted round (fatal on drift)

ROUND V15 -- COLLECT AND INJECT STOP PAYING A CREATION-TIER FLAT FEE.

Owner ruling, 2026-10-26, after collecting from a 5-score / 2-token aggregator quoted 557 IGNIS
PER ROW and 10 rows for a Collect All:

    aqp-collect   500.0 -> 0.0
    aqp-inject    500.0 -> 0.0
    unstale       100.0 -> 50.0

WHY THESE WERE WRONG RATHER THAN MERELY HIGH. Both AQP keys sat in the block `02_IGNIS.pact`
itself labels "legacy-honored flat values (owner batch did NOT reprice these -- values
preserved)", among `issue-fvt`, `issue-pool` and `add-reward-link`. Deterrence pricing exists to
make SPAM CREATION expensive; those neighbours are one-off creations and deserve it. Collect and
inject are the opposite -- the most routine actions in the system, a holder claiming earnings he
has already accrued and an owner funding the lane he created. They inherited an issuance tier by
never having been considered, which is a different thing from having been judged.

ZERO IS THE DETERRENCE, NOT THE PRICE. `UC_IgnisPrice` is (deter + components), so both ops
still pay their real computed work -- `CC_Collect` keeps its 57. What is removed is the flat
charge on top. `unstale` moves to sit beside `sync-anchors` (50), which is the same kind of
permissionless maintenance.

ONE MODULE, ONE TRANSACTION, AND NO CASCADE.

`IG|DETER` is a `defconst` inside the module body. A defconst is not interface surface, so
`IgnisCollectorV4` is untouched, no consumer's modref rebinds, and nothing else redeploys --
the single most important property of this round, and the reason it is one file rather than
fifteen. Verified by `--check`: the emitted source must contain no `(interface ` form.

MODULE-ONLY, WITH `create-table` STRIPPED. `02_IGNIS.pact` carries two, and `create-table`
ABORTS THE WHOLE TRANSACTION on a table that already exists -- which every one of them does on
a live chain. The strip is asserted rather than assumed, for the same reason `_purev11.py`
asserts it: the failure arrives as a rejected transaction after the gas is spent.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, "1_SOVEREIGN", "STAGE_01", "2_Core", "02_IGNIS.pact")
OUT_DIR = os.path.join(ROOT, "Deploy", "PureV15")
OUT = os.path.join(OUT_DIR, "01_deploy_IGNIS.pact")

# A `create-table` form, including any trailing `;;` comment. See the header.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

# The three values this round exists to change, and what they must read AFTER it.
EXPECTED = {"aqp-collect": "0.0", "aqp-inject": "0.0", "unstale": "50.0"}

HEADER = """;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- PureV15, file 1 of 1
;;
;; ROUND V15: collect and inject stop paying a creation-tier flat deterrence.
;;     aqp-collect  500.0 -> 0.0
;;     aqp-inject   500.0 -> 0.0
;;     unstale      100.0 -> 50.0
;;
;; ONE MODULE, NO CASCADE. `IG|DETER` is a defconst in the module body, so the
;; `IgnisCollectorV4` interface is UNCHANGED -- no consumer's modref rebinds and
;; nothing else needs redeploying. The interface is deliberately NOT included
;; here: it is already live, and re-sending it would be a no-op at best.
;;
;; UPGRADE SOURCE -- `create-table` forms are STRIPPED. They abort the whole
;; transaction on a table that already exists, which both of IGNIS's do.
;;
;; Sign with: GOV|IGNIS_ADMIN (the module's own governance capability).
;; ---------------------------------------------------------------------------
"""


def build() -> str:
    text = open(SRC, encoding="utf8").read()
    k = text.index("\n(module IGNIS GOV")
    body = re.sub(CT_RE, "", text[k:], flags=re.M).rstrip()
    return HEADER + "\n(namespace \"ouronet-ns\")\n" + body + "\n"


def verify(emitted: str) -> list:
    """Everything that would make this transaction fail, or succeed wrongly."""
    bad = []
    if re.search(r'^\(create-table ', emitted, flags=re.M):
        bad.append("a create-table form survived -- it aborts the tx on a live table")
    if "(interface " in emitted:
        bad.append("an interface form is present -- this round must not touch the interface, "
                   "because doing so forces every consumer to rebind and redeploy")
    if "(module IGNIS GOV" not in emitted:
        bad.append("the IGNIS module is missing from the emitted source")
    for key, want in EXPECTED.items():
        # The value AS IT WILL BE ON CHAIN, read out of the bytes being shipped rather than out
        # of the source file -- those are the same today and the point is that they must be.
        m = re.search(r'^\s*,?"' + re.escape(key) + r'"\s*:\s*([0-9.]+)', emitted, flags=re.M)
        if not m:
            bad.append(f'`{key}` is not in the emitted IG|DETER map')
        elif m.group(1) != want:
            bad.append(f'`{key}` ships as {m.group(1)}, this round says {want}')
    # 320,000 is the conservative per-transaction cap `_deploybundle.py` uses, justified by
    # `04_RPS.pact` (304,738 bytes) having deployed.
    if len(emitted.encode()) > 320_000:
        bad.append(f"{len(emitted.encode()):,} bytes exceeds the 320,000 cap")
    return bad


def main():
    write = "--write" in sys.argv
    check = "--check" in sys.argv
    if not (write or check):
        sys.exit(__doc__)

    emitted = build()
    bad = verify(emitted)
    if bad:
        for b in bad:
            print(f"  PUREV15 {b}")
        sys.exit("PureV15: refusing to emit a round that would fail or mislead.")

    if write:
        os.makedirs(OUT_DIR, exist_ok=True)
        with open(OUT, "w", encoding="utf8") as fh:
            fh.write(emitted)
        print(f"wrote {os.path.relpath(OUT, ROOT)}  ({len(emitted.encode()):,} bytes)")
        return

    if not os.path.isfile(OUT):
        sys.exit(f"PureV15: {os.path.relpath(OUT, ROOT)} is MISSING -- run --write.")
    if open(OUT, encoding="utf8").read() != emitted:
        sys.exit(f"PureV15: {os.path.relpath(OUT, ROOT)} is STALE against the source -- "
                 "run --write.")
    print(f"PureV15: clean -- 1 file, {len(emitted.encode()):,} bytes, "
          f"{', '.join(f'{k}={v}' for k, v in EXPECTED.items())}")


if __name__ == "__main__":
    main()
