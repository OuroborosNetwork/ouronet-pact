# Architectural rethink: IGNIS cost of ALL client functions (owner directive, 2026-08-27)

**Status:** deferred design task — start AFTER the AQP-INFO functions are finished.

## The directive (verbatim intent)
"We should rethink, architecturally, how much IGNIS the operations cost. We have stake /
unstake / inject / collect — and depending how they're run, they cost more or less STOA gas.
So once we're done with [the info functions], we need to rethink the IGNIS cost of all client
functions. Because if a function uses hard-read functions, that makes everything more
expensive — since the gas station pays the STOA gas, the user has to pay with IGNIS."

## Why this matters (the mechanism)
- The Ouronet **gas station pays the native STOA/KDA gas** for Talos-defined client paths.
- The user is charged **IGNIS** (virtual-chain gas) to compensate — IGNIS cost is assembled
  from the `OutputCumulator` legs each operation builds (the exact thing the AQP-INFO
  cost-preview functions now reconstruct byte-for-byte).
- **Heavy reads inflate the real STOA gas** the station pays → the operation *should* cost the
  user more IGNIS, or the station eats an unfair subsidy. This is exactly the **transitive
  heavy rule** (`CC_`/`AA_` = a `URH_*`/`URHC_*`/`URD_*` scan reached anywhere in the tree):
  the naming already flags where cost balloons; the pricing should follow.

## What the INFO work gives us to build on
The AQP-INFO reconstruction already made every operation's IGNIS cost **explicit and
leg-attributed** (transfer, tracker, rollup, RPS-settle, anchor, score-delta, book, checkpoint,
+ the heavy scans for vacate/drain). That per-leg cost map is the raw material for re-pricing:
we can now *see* which legs dominate and which are subsidised too cheaply/expensively.

## The rethink (scope to define later)
1. **Audit** the real STOA gas each client op consumes vs the IGNIS it charges the user —
   per run-shape (e.g. stake with N active scores, inject over M stale members, vacate over K legs).
2. Decide the **fairness model**: should IGNIS charged ≈ station's STOA outlay (cost-recovery),
   or a tiered/subsidised schedule? Heavy (`CC_`/`AA_`) paths especially.
3. Ensure the **UsagePrice tiers** (`ignis|small/medium/big/biggest`) and the per-leg
   cumulator weights actually reflect the underlying STOA cost — today they're hand-set constants.
4. Tie into **variant A**: one shared cost function per complicated op (exec + info) makes
   re-pricing a single-point change with zero drift.

## Related
- Module-sizing hard rule: `OuronetInformational/MODULE-SIZING.md` (also owner-directed 2026-08-27).
- Transitive heavy rule + recipe axes: `OuronetInformational/StoicSyntax-Prefixes.md`.
- Per-op IGNIS leg map: `OuronetInformational/memories/2026-08-27-aqp-info-final17-costmap.md`.
