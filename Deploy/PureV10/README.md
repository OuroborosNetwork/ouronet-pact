# Deploy/PureV10 — true-fungible beneficiary reassignment

**2 transactions. Send 01 then 02, in order.** ~571 KB total (per `_deploybundle.py --check`,
the authority on emitted size); 01 is 270,985 B / 203,548 gas, 02 is 299,457 B / 221,896 gas —
each well under the ~320 KB / 2.00M-gas single-transaction ceiling, so these are two independent
sends, not a batch that has to clear together.

## What this round adds

A new client operation: **`AQP-POOL|CCp_ReassignTrueFungibleStakeBeneficiary`** — the
true-fungible (native or frozen) counterpart to the OF/collectable beneficiary reassigns already
live. The owner of an already-staked TF leg can redirect part or all of its earnings to a
different beneficiary without unstaking and restaking it:

- Works on **either** leg of a pool's canonical asset — native or its `F|` frozen counterpart —
  since `dptf-id` is a free parameter, not a native-only assumption.
- **Partial by design.** A TF position carries no nonce (unlike OF/collectable, where the
  nonce IS the indivisible unit), so the owner may move any amount up to the current balance —
  splitting a position across two beneficiaries, or moving it whole.
- No asset ever moves — an ordinary TF unstake always returns the position to the owner
  regardless of who the beneficiary was, so this is pure earnings bookkeeping.
- Refuses a no-op self-reassign and an amount above the current staked/rollup balance.
- Requires the OWNER's signature, not the current beneficiary's — the owner is who is entitled
  to decide who earns, exactly as they decide it at the original stake.

## What ships, and why

| tx | module | bytes | ~gas | why it ships |
|---:|---|---:|---:|---|
| 01 | **AQP-FVT** | 270,985 | 203,548 | the new defcap/function pair, and `CC_TrueFungibleStakeFlow`'s body extracted into `XI_TrueFungibleStakePhases` so the ordinary stake/unstake path and the new reassign share one copy of the phase chain |
| 02 | **TS02-C3 + AQP-INFO + TS02-DPAD** | 299,457 | 221,896 | the Talos client wrapper + defcap in TS02-C3, and the cost-preview function in AQP-INFO (TS02-DPAD is bundled into this same transaction by the round's packing, unrelated to this change — it did not change) |

**No dot-pin cascade.** `_deploybundle.py --check` against the full `Deploy/1_Pure/` round found
exactly these two transactions stale and nothing else — no other module `dot`-calls into
`AQP-FVT`, `TS02-C3` or `AQP-INFO` in a way a hash re-pin would require. Six-transaction rounds
like `PureV9` needed the extra sends because OTHER modules dot-called the changed functions
directly; this one doesn't have that shape.

## The mechanism, mirroring the OF/collectable reassigns exactly

`CC_TrueFungibleStakeFlow`'s phase chain (custody transfer → per-pool tracker → cross-pool
`BenDptfTotal` rollup → RPS settle prelude → ANK anchor refresh → SCORE delta → checkpoint) is
now `XI_TrueFungibleStakePhases`, taking a `move-asset` flag that gates only the custody-transfer
leg — exactly the same extraction already done for `XI_OrtoStakePhases` and
`XI_CollectableStakePhases`. `CCp_ReassignTrueFungibleStakeBeneficiary` runs that chain TWICE
with the asset pinned: once with `direction` false to vacate the outgoing beneficiary (settling
what they earned first), once true to credit the incoming one — `owner` fixed on both runs,
never a pool account, because TF has no custodial variant.

The new `FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` defcap bounds `amount` by BOTH the current
tracker balance and the cross-pool rollup (the custody cap's own sufficiency check is skipped
when `move-asset` is false, so this defcap is the only place that still enforces it), requires
`CAP_EnforceAccountOwnership` on the owner, and validates the new beneficiary exists, is a
standard account, and differs from the current one.

## No new interface, and no reader-module changes needed

Neither `CCp_ReassignTrueFungibleStakeBeneficiary` nor `XI_TrueFungibleStakePhases` is declared
in any interface (matching the OF/collectable reassigns, which took the same path) — so there is
no interface version bump and no cascade into other modules' `implements` clauses.

No `UR_`/`URC_` reader changes were needed either: `UR_AQP|DPTFTrackerBalance` and
`UR_AQP|BenDptfTotalBalance` already existed (used throughout the ordinary TF stake/unstake
path) and were sufficient for the new defcap's sufficiency checks and the new `CCp_` function's
own balance reads.

## Verification

New REPL regression: `TX-FVT-11` in `[6.2.4]_AQP-FVT.repl` — stakes a fresh TF position,
reassigns 40.0 of it, then the remainder, checking the tracker rows, the score weight (via a
per-unit rate derived from the fresh stake itself, so the assertion does not assume a specific
multiplier), that no tokens move across either reassign, and that the final unstake still pays
the owner rather than the beneficiary. Both refusal paths (self-reassign, over-amount) are
pinned too. Delta-based throughout: an earlier draft that moved the pool's OBSERVED self-balance
instead of just this test's own contribution left a stray cross-beneficiary row behind that
collided with `[6.2.5]_AQP-VCT.repl`'s later full-pool vacate (two rows resolving to the same
owner account in one bulk-transfer's receiver list, rejected as a duplicate). Fixed by never
touching a leftover balance this test didn't create. Mutation-tested the new amount bound by
removing it and confirming the refusal assertion fails as expected. Gate green, 28,524
assertions.

Then: `python3 REPL/tools/_registrylive.py --record` and `python3 REPL/tools/_registry.py --write`
(the new entrypoint needs to reach the registry before any UI can wire a "reassign" button to
it — same step every round in this family needs).
