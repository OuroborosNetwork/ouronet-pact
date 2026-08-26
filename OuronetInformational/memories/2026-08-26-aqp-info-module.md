# AQP-INFO module — status + handoff for the final 17

**Date:** 2026-08-26. **Module:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_AQP-INFO.pact`
**Procedure:** `OuronetInformational/skills/aqp-info-module-procedure.md`
**Surface catalog:** `OuronetInformational/skills/aqp-entrypoint-surface.md`
**Test:** `REPL/Kursan/aqp-info-tests.repl` (in `run-aqp-audit.sh`).

## What an AQP info function is
The read-only cost-preview counterpart of a TS02-C3 execution wrapper. `AQP-<MOD>|INFO_<Fn>` returns
`object{OuronetInfoV1.ClientInfo}` = pre/post text (incl. the execution function name) + exact `ignis` +
`kadena` costs for a given account + an `output` payload. It **mirrors the execution's cost logic byte-for-
byte**. Borrows INFO-ZERO's `OI|*` helpers via `(ref-…:module{OuronetInfoV1} INFO-ZERO)`; no interface
(leaf preview module, per INFO-TWO precedent). Fixed `GAS|` costs are read cross-module as `Module.CONST`
(e.g. `AQP-FVT.GAS|COLLECT`) — zero drift. Costs gate on `URC_IsVirtualGasZero`/`URC_IsNativeGasZero`
(billing is ON by default in the sandbox, so test magnitudes are real). Verify by asserting
`info.ignis-full == the exact GAS| const / UsagePrice formula`.

## DONE — 66 of ~79, exact + tested (79 asserts green)
ANK (6), SCORE (17), POOL-config (8), FVT (22), DSA (11), MTX (2). Committed across:
`06e35ea` (docs+skeleton+ANK), `1f1f6ab` (SCORE+POOL), `352e262` (FVT), `8853954` (DSA+MTX),
`0bc7fab` (pattern doc).

## TODO — the final 17 (multi-ICO, variable cost): stake/unstake (8) + vacate/drain (9)
Owner-approved approach: **read-only reconstruction**, adding a small `URC_…IgnisUnit` core cost-reader
**only where the read-only path can't be made exact** (see the two spots below). Prove each with a
**ground-truth test**: on a fully-provisioned staked/vacating pool, run the real Talos op, measure the
patron's IGNIS (GAS-98c486052a51) balance delta, and assert it equals `info.ignis-need`.

### stake/unstake (POOL wrappers `C_Stake*`/`C_Unstake*`, TF/OF/SF/NF)
The flow `C_TrueFungibleStakeFlow` (and OF/SF/NF siblings) concatenates these costed legs — **all but one
already have read-only cost-readers**, so reconstruct the total by summing:
- preflight bundle: `URHC_BuildStakeSettleBundle pool-id beneficiary-id` → `{settle-scores, distinct-fvts,
  settle-plans, …}`.
- RPS pre-score: `URC_SettleStakePendingIgnis(settle-scores, distinct-fvts)`.
- score-delta: `Σ URC_StakeScoreDeltaIgnisUnit(score-id)` over `URC_PoolActiveScoreIds pool-id`.
- unclaimed-count: `URC_BookStakeUnclaimedIgnis(distinct-fvts)`.
- checkpoint: `URC_CheckpointStakeRpsIgnis()`.
- custody transfer: reconstruct via `ref-TFT::UDC_TransferCumulator` (→ `OI|UC_IfpFromOutputCumulator`).
- **anchor-refresh (THE ONE GAP):** `XI_RefreshTrueFungibleStakeAnchors` = ANK
  `XE_UpdateTrueFungibleUserAnchorValues` + AQP `XB_SetBenDptfAnkSyncCount` — no clean read-only reader.
  Add a `URC_RefreshTrueFungibleAnchorsIgnis(beneficiary-id, dptf-id)` (mirroring the ANK promile-refresh +
  AQP sync-count cost) and consume it. (Same gap for OF/SF/NF anchor refresh.)

### vacate/drain (POOL wrappers `CC_FullVacate` / `CC_BatchVacate*` / `CC_BatchDrain*`)
Preflight = `URHC_BuildVacateSlicePlan(pool-id, asset-id, vacate-kind, slice-count)` +
`URHC_VacateUnitCountForKind(pool-id, asset-id, vacate-kind)` (TF→owner-count, OF/collectable→nonce-total).
Two info shapes:
- `AQP-POOL|INFO_VacateFull(pool-id, asset-id, vacate-kind)` → grand total = `base + unit × count`, plus the
  slice breakdown (batch count + per-batch cost) from the plan.
- `AQP-POOL|INFO_BatchVacate…(same slice args as the CC_ execution)` → that batch's exact cost from its own
  leg list.
The vacate cost is `bulk custody transfer + finalize base + per-leg increment × leg-count`. Determine the
per-leg unit from `CC_BatchVacateTrueFungible`'s cumulator construction (tracker-ocs + score-ocs +
unwind/bulk-oc, ~line 1900-2130 of `05_VCT.pact`); **add `URC_Vacate…IgnisUnit` on VCT if a clean unit isn't
already exposed**, and route the flow's own cost through it for drift-proofing.
- `C_AbortVacate` = empty cumulator (free); `C_FinalizeVacate` = `ignis|medium` tier (already a fixed-cost —
  can be done like the others).

### Also note
- Ladder-collect residual: `AQP-FVT|INFO_Collect` currently reports the `GAS|COLLECT` base only; a MULTIPLET
  triplet reward adds ATS Coil/Curl legs — reconstruct via `ref-ATS::URC_RewardBearingTokenAmounts` +
  `SIP|URC_*` if exact ladder-inclusive collect cost is wanted.
- POOL syncs (`INFO_Sync*Anchors`) report the `GAS|SYNC-*` base only; the per-anchor ANK repair is the same
  anchor-refresh cost as above — fold in once `URC_RefreshTrueFungibleAnchorsIgnis` exists.
