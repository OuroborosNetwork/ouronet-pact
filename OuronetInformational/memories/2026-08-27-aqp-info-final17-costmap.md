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
