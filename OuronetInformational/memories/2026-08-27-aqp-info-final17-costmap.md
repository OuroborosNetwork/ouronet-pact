# AQP-INFO final 17 — exact cost-leg map + reconstruction formulas (2026-08-27)

Distilled from two read-only call-graph mappings of the execution flows. This is the
build spec for the last 17 info functions. Companion: `2026-08-26-aqp-info-module.md`.

## Consumption shape
`OI|UDC_DynamicIgnisCost(patron, ifp:decimal)` takes ONE total IFP decimal → derives
discount/full/need. So each info fn sums its legs into `ifp` and passes it.
`OI|UC_IfpFromOutputCumulator(oc):decimal` extracts the IFP from any OutputCumulator
(use for transfer + bulk-transfer legs). Flat tiers mirror exactly via `SIP|URC_Medium`
(=`UDC_MediumCumulator`=`UR_UsagePrice "ignis|medium"`), `SIP|URC_Biggest`(=biggest),
`SIP|URC_Small`(=small). Per-leg SIP| gating is consistent with existing fns; billing is
ON in tests so magnitudes match regardless.

## STAKE / UNSTAKE (8 fns) — NO core surgery; all legs have readers/tiers/token-cumulator
Talos wrappers (TS02-C3) are 1:1 thin `C_Collect` shells — wrapper cost == flow cost.
Stake vs unstake = same flow, `direction` flipped; only phase 1.1 transfer differs by dir.
Settle bundle once: `URHC_BuildStakeSettleBundle(pool-id, beneficiary-id)` → fields
`settle-scores:[string]`, `distinct-fvts:[string]`, `settle-plans`, `pre-member-debs`.

### FLOW 1 — CC_TrueFungibleStakeFlow (04_FVT.pact:6412; concat 6427-6469)
Total ifp =
  1.1 transfer: `OI|UC_IfpFromOutputCumulator (TFT::UDC_TransferCumulator type dptf-id S R)`
       where `type=(at "type" (TFT::URC_TransferClasses dptf-id S R amount))`,
       stake dir=true → S=owner-id,R=vault(AQP|SC_NAME); unstake → S=vault,R=owner-id.
       (XE_TrueFungibleTransfer 03_AQP.pact:2723; TFT C_Transfer 09_TFT:1288,
        UDC_TransferCumulator 09_TFT:992, URC_TransferClasses in 09_TFT.)
  + 1.2 tracker: `SIP|URC_Medium` (flat medium ×1)   [XE_TrueFungiblePoolTracker→UDC_MediumCumulator]
  + 1.3 rollup:  `SIP|URC_Biggest` (flat biggest ×1)  [XE_TrueFungibleBeneficiaryRollup→UDC_BiggestCumulator]
  + 2   RPS:     `URC_SettleStakePendingIgnis(settle-scores, distinct-fvts)`  (FVT:2451)
                 = biggest×|settle-scores| + medium×Σ EnabledRewardCount(distinct-fvts)
  + 3.1 anchor:  `ANK.URC_TrueFungibleStakeAnchorRefreshIgnis(n-live)` (01_ANK:1028)
                 [= small×n-live, n-live=length ANK.UR_ANK|AnchorsForAsset(dptf-id)]
                 + `SIP|URC_Biggest` (flat, the XB_SetBenDptfAnkSyncCount leg)
  + 4   delta:   Σ over `AQP-POOL.URC_PoolActiveScoreIds(pool-id)` of
                 `SCORE.URC_StakeScoreDeltaIgnisUnit(score-id)` (SCORE:2206)
                 [unit = biggest + (deb?biggest) + (bc-link≠BAR?biggest) + (b-link≠BAR?biggest) + (class0?2×biggest)]
  + 4.5/4.6/4.7 = 0 (UC_EmptyOc)
  + 5.1 book:    `URC_BookStakeUnclaimedIgnis(distinct-fvts)` (FVT:2479) = medium×|distinct-fvts|
  + 5.2 chkpt:   `URC_CheckpointStakeRpsIgnis()` (FVT:2489) = 2×biggest (flat)

### FLOW 2 — CC_OrtoFungibleStakeFlow (04_FVT:6478; concat 6502-6535)
Same as TF MINUS anchor (phase 3 N/A) and 1.3 rollup (N/A). Changes:
  1.1 transfer: DPOF::C_Transfer (06_DPOF:2096) via UC_MoveCumulator (per-nonce). Reconstruct
      via DPOF pure cumulator ctor; S/R flip by dir. 1.2 tracker: `SIP|URC_Medium × |nonces|`.
  Phase 4 delta: class-2 non-special score leg emits 0.0 (SCORE:3453) — replicate branch.
  2 / 5.1 / 5.2 identical to TF.

### FLOW 3 — CC_CollectableStakeFlow (04_FVT:6544; concat 6580-6617) SF son=true / NF son=false
  1.1 transfer: DPDC-T::C_Transfer (07_DPDC-T:655) via UDC_MultiTransferCumulator (07_DPDC-T:529)
      / URC_TotalTransferPrice (07_DPDC-T:432). S/R flip by dir.
  1.2 tracker:  `SIP|URC_Medium × |nonces|`   (son picks DPSF/DPNF table)
  1.3 rollup:   `SIP|URC_Medium × |nonces|`   [XE_CollectableBeneficiaryRollup→medium×|nonces|]
  2   RPS:      URC_SettleStakePendingIgnis (same)
  3.2/3.3 anchor: FLAT `SIP|URC_Medium + SIP|URC_Biggest` (NO per-unit; the ANK
      XE_Update{Semi,Non}FungibleUserAnchorValues returns are DISCARDED — FVT:5013-5027).
  4   delta:    Σ URC_StakeScoreDeltaIgnisUnit over PoolActiveScoreIds; non-matching target-class
      (3 SF / 4 NF) emits 0.0 (SCORE:3504) — replicate.
  5.1 / 5.2 identical.

### Readerless legs handled (flag list, all resolved)
transfer (token pure ctor), tracker/rollup (flat SIP|URC_* × count), anchor flats (SIP|URC_*).
Everything else = named URC. NO new core reader required for stake/unstake.

## VACATE / DRAIN (9 fns)
- `C_FinalizeVacate` = ONE `SIP|URC_Medium` (05_VCT:3016 UDC_MediumCumulator). Build now.
- `C_AbortVacate` = FREE → `OI|UDC_NoIgnisCosts` (05_VCT:2989 UC_EmptyOc). Build now.
- 6× `CCp_BatchVacate/Drain*` + `CC_FullVacate`: **NO VCT-local cost reader.** Cost = a
  two-map concat of downstream-priced forward-XE cumulators + one bulk-transfer cumulator:
    · per-LEG map (count = URHC_VacateUnitCountForKind = owner-rows TF / nonce-total OF·coll):
      tracker + rollup (flat medium/biggest, same tiers as stake 1.2/1.3).
    · per-BENEFICIARY map (count = distinct beneficiary-ids from URHC_BuildVacateSlicePlan):
      free-RPS(0) + [anchor refresh] + ApplyStakeDelta + BookUnclaimed + CheckpointRps —
      SAME primitives as stake phases 3/4/5 (URC_*Ignis readers reusable).
      VACATE includes ApplyStakeDelta; DRAIN omits it AND fires the settle-triple ONLY for
      beneficiaries whose UserUnn hits 0 (data-dependent subset — the hard part).
    · bulk transfer: TFT::C_MultiBulkTransfer / DPOF::C_BulkTransfer / DPDC-T::C_BulkTransfer
      over receiver/amount arrays → reconstruct via token bulk pure ctor + OI|UC_Ifp….
  Concat order per variant documented in the map (TF: [unwind, bulk]; OF/coll: [bulk, unwind]).
  Ranges: TF unwind XI_1|VacateTrueFungibleUnwindFromLegs 05_VCT:1975-2013; drain
  XI_1|DrainTrueFungibleFromLegs 2044-2109; OF 2309-2369; coll 2370-2455.

### VACATE DECISION (open — owner)
The handoff assumed a "small URC unit" on VCT; the reality is a two-map concat with a
data-dependent drain subset. Three ways to make the 6 batch + FullVacate exact:
  (A) drift-proof: add shared `URC_…VacateCost` estimator(s) on VCT that BOTH the exec flow
      and info call (single source of truth). Correct; refactors VCT cost assembly. Owner-sanctioned in spirit.
  (B) in-INFO reconstruct the two-map concat from cross-module primitives + preflight counts;
      drain UserUnn==0 subset computed by reading each beneficiary's unn. No core change; drift risk; drain fragile.
  (C) structural preview: report exact COUNTS (legs, beneficiaries, bulk size) + fixed parts,
      not one exact IGNIS total. Cheapest, honest, still UI-useful.
Recommendation: build stake/unstake + Finalize + Abort now (all exact, no core change);
take (A) for the batch vacate/drain if exactness required, else (C).

## OWNER DECISION (2026-08-27): VARIANT A is the standing principle
"Where things get complicated, write ONE function used by BOTH the execute and info
functions → zero drift + shorter code." Apply to the vacate/drain family: add shared
`URC_*VacateCost` estimator(s) on AQP-VCT; refactor the exec to BILL through them; the info
fn calls the same. Reserve for the complicated cases — stake/unstake already reuse the
shared pricers (URC_SettleStakePendingIgnis, UsagePrice tiers, transfer ctors) so their
parallel reconstruction is acceptable.

## BUILT SO FAR (committed 3348179) — 4 of 17, compiling green
`AQP-POOL|INFO_StakeTrueFungible` / `INFO_UnstakeTrueFungible` (via URC_TrueFungibleStakeFlowIfp
+ URC_StakeScoreDeltaSum), `AQP-POOL|INFO_FinalizeVacate` (SIP|URC_Medium),
`AQP-POOL|INFO_AbortVacate` (NoIgnisCosts). Loads green in light aqp-info-tests (95 asserts).
NOT yet ground-truth-verified (needs full-boot staked pool).

## OF / SF / NF transfer-leg ctors (for the next 6 stake/unstake fns)
All flip owner↔vault by direction (vault = AQP-POOL.AQP|SC_NAME), reconstruct IFP via
`OI|UC_IfpFromOutputCumulator (<ctor>)` wrapped in SIP|URC_Fixed:
- OF  (CC_OrtoFungibleStakeFlow FVT:6478): `DPOF.UC_MoveCumulator dpof-id nonces false`
  (interface 06_DPOF:23) — NOTE direction-INDEPENDENT (no sender/receiver in the ctor).
  Legs: transfer + tracker(SIP|URC_Medium × |nonces|) + RPS + score-delta + book + checkpoint.
  NO 1.3 rollup, NO anchor.
- SF/NF (CC_CollectableStakeFlow FVT:6544, son=true SF / false NF):
  `DPDC-T.UDC_MultiTransferCumulator [collectable-id] [son] sender receiver [nonces] [nonce-amounts]`
  (interface 07_DPDC-T:30) — direction-DEPENDENT. Legs: transfer + tracker(medium×|nonces|)
  + rollup(medium×|nonces|) + RPS + anchor(FLAT SIP|URC_Medium + SIP|URC_Biggest) + score-delta
  + book + checkpoint.

## ⚠ GOTCHA — OF/SF/NF phase-4 score-delta is CLASS-MATCHED (do NOT reuse URC_StakeScoreDeltaSum as-is)
TF phase 4 = clean Σ URC_StakeScoreDeltaIgnisUnit over ALL URC_PoolActiveScoreIds. But the OF
apply (XE_ApplyOrtoFungibleStakeDelta) emits 0.0 for class-2 non-special scores (SCORE:3453),
and the collectable apply emits 0.0 for scores whose class ≠ target (3 SF / 4 NF) (SCORE:3504).
So a naive full sum OVER-counts for OF/SF/NF. Options: (a) filter PoolActiveScoreIds by the
matching class before summing (need a per-score class reader), or (b) VARIANT A — extract the
exact charged sum used by XE_Apply*StakeDelta into a shared `URC_*StakeScoreDeltaIgnis(pool-id,…)`
that both exec and info call (cleanest, owner-sanctioned). Resolve with a ground-truth test.

## UPDATE (2026-08-27, later): TF PROVEN + OF/SF/NF built + class rule CORRECTED
- TF stake/unstake ground-truth EXACT: predicted 23.32 == real GAS delta 23.3200 (both dirs),
  0 fail. Harness: REPL/aqp-info-groundtruth.repl + Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl
  (commit aab1531). The multi-leg approach is certified.
- OF/SF/NF stake+unstake (6) BUILT + compiling green (light boot, 95 asserts). Helpers:
  URC_OrtoFungibleStakeFlowIfp, URC_CollectableStakeFlowIfp, URC_StakeScoreDeltaSumForClasses.
- CLASS-MATCH RULE (read from SCORE:3405/3467, corrects the earlier mapping agent):
  OF charges scores whose ScoreClass ∈ {0,2} (sc==2 ALWAYS charges — the "class-2 non-special
  → 0" claim was WRONG; only sc∉{0,2} skips). SF charges class==3, NF charges class==4.
  Filter: URC_StakeScoreDeltaSumForClasses pool-id [classes] over URC_PoolActiveScoreIds,
  filtered by AQP-SCORE.UR_SCR|ScoreClass.
- Transfer ctors used: OF `DPOF.UC_MoveCumulator dpof-id nonces false` (dir-indep);
  collectable `DPDC-T.UDC_MultiTransferCumulator [id][son] sender receiver [nonces][amts]`,
  amts via `DPDC.UR_AccountNoncesSupplies owner-id id son nonces`.
- STILL PENDING: ground-truth for OF/SF/NF (needs staked OF/SF/NF fixtures — [6.2.4] provides
  them; extend [6.5.1] with OF/SF/NF stake+delta asserts), then vacate ×7 (variant A).

## UPDATE (2026-08-27, later-2): collectable unstake nonce-amounts FIXED + fixtures found
- FIX (commit f2c9606): CC_Unstake{Semi,Non}FungibleCollectable take nonce-amounts:[integer]
  explicitly; for UNSTAKE the vault (not owner) holds the staked nonces so deriving amounts from
  DPDC.UR_AccountNoncesSupplies owner-id reads 0 → mis-prices the DPDC-T transfer. URC_Collectable
  StakeFlowIfp now takes nonce-amounts as a param (stake derives from owner supply; unstake gets
  it from the caller). All 10 stake/unstake compile green (95 asserts).
- OF/SF/NF fixture ids (in the [6.2.4] sub-suites; patron=owner=ben=KST.ANHD):
  OF pool "OfStakePool", dpof "MVST-98c486052a51"; SF pool "SfStakePool", dpsf "DHCD-98c486052a51";
  NF pool "NfSyncPool", dpnf "DHB-98c486052a51".
- ⚠ GOTCHA for OF/SF/NF ground-truth: [6.2.4]_AQP-FVT-OF/DC/NF run their OWN vacate tests, so those
  pools end VACATED + stake-DISABLED. Cannot naively restake into them (unlike TfStakePool which
  [6.2.5] proves restakeable). The OF/SF/NF ground-truth needs a DEDICATED FRESH fixture: mint fresh
  MVST/DHCD/DHB to ANHD + issue a fresh score + fresh pool + enable-stake + add-score, then stake
  with the INFO cost-equality assert. Model the fixture on the top of each [6.2.4] sub-suite
  (issue-score → issue-pool → add-score → enable-pool-stake) but with fresh names so no vacate collision.
  Alternatively insert the assert INSIDE [6.2.4] right BEFORE its vacate section (lower-churn but edits a reference suite).

## NEXT STEPS (ordered)
1. TF ground-truth: full-boot staked pool → `INFO_StakeTrueFungible.ignis-need` == real IGNIS
   (token GAS-98c486052a51) balance delta of `AQP-POOL|CC_StakeTrueFungible`. Prove the TF pattern
   (clean, no class-match subtlety) FIRST. Dedicated [6.x] scenario appended to a full boot; do
   NOT edit the reference exhaustive suites.
2. OF/SF/NF stake/unstake ×6 — using the ctors above; resolve the class-matched score-delta via
   variant A (shared reader) or class-filter; ground-truth each family.
3. Vacate/drain ×7 via VARIANT A: shared URC_*VacateCost on AQP-VCT, exec bills through it, info
   calls it. Two-map concat + drain UserUnn==0 subset (see the VACATE section above).
