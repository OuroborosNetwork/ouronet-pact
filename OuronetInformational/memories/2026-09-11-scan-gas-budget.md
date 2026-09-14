# A table scan costs ~40,000 gas FLAT — so three is the per-transaction ceiling

**Date:** 2026-09-11 · **Status:** measured; check added to `_heavy.py`; current hits cleared

## The measurement

Controlled REPL module, row counts verified, `table` gas model:

| operation | 50 rows | 500 rows |
|---|---|---|
| point read | 7 | 7 |
| `keys` | 40,001 | 40,000 |
| `select` | 40,016 | 40,156 |
| `fold-db` | 40,010 | 40,100 |

**All three scan primitives charge the same ~40,000 base**, with only a trivial per-row term
(`select` ≈ 0.3 gas/row; `keys` essentially none). The base dominates completely at any realistic
size. Against Kadena's **150,000** per-tx limit: **three scans fit, a fourth does not.**

**I had hypothesised linear scaling with row count. Wrong** — measured at 10/100/400/1000 rows, it
is flat. That matters: the linear story makes this a future problem, the flat one makes it a
present, fixed-size budget. Pinned as `STAGEZ-17` in `modules/STAGE-Z.repl`, with *thresholds*
rather than exact figures so it signals a real change instead of churning on gas-schedule drift.

## What it is good for

`_heavy.py` gained a `[scan-budget]` section: entrypoints whose call tree reaches **4+ distinct**
heavy readers (`URH_`/`URHC_`/`URD_`). It is an **UPPER BOUND, not a cost prediction** — branches
mean one call need not hit them all, and a heavy read inside a `map`/`fold` runs *more* often than
it appears.

## Current hits: 2, both measured and CLEARED — do not re-investigate

`AQP-VCT::CC_FullVacate` and its Talos wrapper. Static reach says **10** heavy readers, which would
be ~400,000 gas if they all ran — and the batched `CCp_Batch*` slices sitting beside it make that
story look plausible. It is wrong: the function dispatches on `aqp-class` and one call takes **one**
branch. Executed on a real class-1 pool it cost **43,187 gas** — about one scan. The `@doc`'s claim
of an *"AGNOSTIC single-tx full vacate"* is TRUE.

A good illustration that a static upper bound can overstate by 10×, and that the cheap move is to
run the thing.

Converted into a standing guard rather than left as a one-off number: **`AQP-VAC-GAS`** in
`modules/AQP.repl` asserts the vacate stays under 100,000 gas (two thirds of the limit, generous on
purpose) **and** that it used more than 1,000 — so a no-op regression cannot pass the budget
trivially. The risk it guards is a future edit adding a second asset-lane scan to a branch: still
correct, still passing every functional test, and silently unable to fit in a transaction.

**A THIRD entry in `[scan-budget]` would be new and worth investigating.** These two are not.
