# AQP Entrypoint Surface — coverage catalog

> Companion to `aqp-info-module-procedure.md`. The complete list of AQP user/admin entrypoints (the info-
> function coverage list) + the readers an owner/management UI needs. Core modules under
> `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`; **all** AQP Talos wrappers live in `3_Talos/04_TS02-C3.pact`.
> "IGNIS" = the `GAS|<OP>` const (value) passed to `UDC_ConstructOutputCumulator`; "STOA" = a native
> `UR_UsagePrice` charge. Custody token moves (inject/collect/vacate/royalty payouts) are **not** STOA.

## 01_ANK — Anchors  (`AcquisitionAnchorsV1`)
IGNIS on issue = inline `1000.0` (no defconst); revokes = biggest-tier.

| Execution (Talos `AQP-ANK|…`) | Params (Talos) | IGNIS | STOA |
|---|---|---|---|
| `C_IssueTrueFungibleAnchor` | patron, anchor-name, dptf-id, acnoi, boost-class-name-or-id, anchor-precision, anchor-promile, dptf-amount | inline 1000 | `standard` ×(2 if acnoi else 1) |
| `C_IssueSemiFungibleAnchor` | …, dpsf-id, …, dpsf-nonce | inline 1000 | `standard` ×(1/2) |
| `C_IssueNonFungibleAnchor` | …, dpnf-id, …, dpnf-trait-key, dpnf-trait-value | inline 1000 | `standard` ×(1/2) |
| `C_IssueNonFungibleSetAnchor` | …, dpnf-id, …, dpnf-nonce-class | inline 1000 | `standard` ×(1/2) |
| `C_RevokeAnchor` | anchor-id | biggest-tier | — |
| `C_RevokeBoostClass` | boost-class-id | biggest-tier | — |

## 02_SCORE — Scores  (`AcquisitionScoresV1`; Talos prefix `AQP-SCR|`)
`GAS|ISSUE-SCORE 1000`, `GAS|ISSUE-TRIPLET 500`, `GAS|ISSUE-SCORE-MODEL 500`.

| Execution `AQP-SCR|…` | IGNIS | STOA |
|---|---|---|
| `C_IssueLiquidityScore` / `…TrueFungible…` / `…OrtoFungible…` / `…SemiFungible…` / `…NonFungibleScore` | `GAS|ISSUE-SCORE` 1000 | `smart` |
| `C_RotateScoreOwnership`, `C_ControlScore` | medium-tier | — |
| `C_CreateScoreBoostClassLink`, `C_CreateScoreBoostLink` | biggest-tier | — |
| `C_EnableDebBoost` | medium-tier | — |
| `C_IssueTriplet` | `GAS|ISSUE-TRIPLET` 500 | — |
| `C_IssueSemiFungibleScoreDefinition` | `len × UsagePrice "ignis|big"` | — |
| `C_IssueNonFungibleScoreDefinition` / `…NonFungibleSetScoreDefinition` | `len × UsagePrice "ignis|biggest"` | — |
| `C_IssueSingleScoreModel`, `C_CombineTripletScoreModel`, `C_IssueScoreFromModel` | 500 | — |

## 03_AQP — POOL  (`AcquisitionPoolsV1`)
`GAS|ISSUE-POOL 1000`, `GAS|ADD-SCORE 500`, `GAS|REVOKE-SCORE 500`, `GAS|SET-POOL-STAKE 500`, `GAS|SYNC-TF-ANCHORS 50`, `GAS|SYNC-COLLECTABLE-ANCHORS 50`.

| Execution `AQP-POOL|…` | IGNIS | STOA |
|---|---|---|
| `C_Issue` | `GAS|ISSUE-POOL` 1000 | `smart` |
| `C_AddScore` / `C_RevokeScore` | 500 | — |
| `C_EnablePoolStake` / `C_DisablePoolStake` | `GAS|SET-POOL-STAKE` 500 | — |
| `C_SyncTrueFungibleAnchors` | `GAS|SYNC-TF-ANCHORS` 50 (+ANK ICO) | — |
| `C_SyncSemiFungibleAnchors` / `C_SyncNonFungibleAnchors` | `GAS|SYNC-COLLECTABLE-ANCHORS` 50 (+ANK ICO) | — |
| `C_StakeTrueFungible` / `C_UnstakeTrueFungible` | multi-ICO (FVT flow) | custody only |
| `C_StakeOrtoFungible` / `C_UnstakeOrtoFungible` | multi-ICO | custody only |
| `C_Stake/UnstakeSemiFungibleCollectable` / `…NonFungibleCollectable` | multi-ICO | custody only |

## 04_FVT — Farms/Vaults/Treasuries  (`AcquisitionFarmsVaultsTreasuriesV1`)
`GAS|ISSUE-FVT 1000`, `GAS|ADD-SCORE-ENTITY 500`, `GAS|ISSUE-MULTIPLET-FAMILY 500`, `GAS|TOGGLE-SCORE-ENTITY-LINK 500`, `GAS|SET-MOSAIC 500`, `GAS|ADD-REWARD-LINK 500`, `GAS|TOGGLE-REWARD-LINK 500`, `GAS|SET-QUALITY-SPLIT 500`, `GAS|SET-COMMON-DENOMINATOR 500`, `GAS|INJECT 500`, `GAS|COLLECT 500`, `GAS|UNSTALE 500`.

Config: `C_Issue` (1000, STOA `smart`), `C_RotateOwnership`/`C_Control` (medium), `C_SetCommonDenominator`, `C_SetMosaic`, `C_AddScoreEntity`, `C_ToggleScoreEntityLink`, `C_IssueMultipletFamily`, `C_AddRewardLink`, `C_ToggleRewardLink`, `C_SetQualitySplit` (each its named 500 const).
Rewards: `C_Inject` / `C_InjectStream` / `CC_Inject` / `CC_InjectFinalize` (`GAS|INJECT` 500, custody), `CC_InjectFixChunk` / `CC_UnstaleAll` (subsidised, no IGNIS), `C_UnstaleMyScores` (`GAS|UNSTALE` 500), `C_Collect` (`GAS|COLLECT` 500, custody).
Sweep: `CC_SweepRevokeAnchor` / `CC_SweepBegin` / `CC_SweepRecomputeChunk` (subsidised).

## 05_VCT — Vacate  (via `AQP-POOL|…` wrappers)
No `GAS|` consts; batch/full return concatenated XI ICOs, custody only.
`CC_FullVacate`, `CC_BatchVacateTrueFungible` / `…OrtoFungible` / `…Collectables`, `CC_BatchDrainTrueFungible` / `…OrtoFungible` / `…Collectable`, `C_AbortVacate` (empty cumulator), `C_FinalizeVacate` (medium-tier).

## 06_MTX-AQP — Matrix defpacts  (`MTX-AQP|…`)
`C_2|Inject` (2-step fresh inject; inner `GAS|INJECT` 500), `C_2|SweepRevokeAnchor` (subsidised). Underlying `defpact MTX|2|C_Inject` / `MTX|2|C_SweepRevokeAnchor`.

## 07_DSA — Delegated Staking Agencies  (`AQP-DSA|…`)
`GAS|DEFINE-VAULT 500`, `GAS|OPEN-AGENCY 500`, `GAS|RECOMPUTE-CAPTURE 300`, `GAS|SET-ORACLE-AUTH 300`, `GAS|ORACLE-WRITE 200`, `GAS|WITHDRAW-ROYALTY 400`, `GAS|BURN-ROYALTY 400`, `GAS|FUEL-ROYALTY 500`, `GAS|SET-AGENCY-FEE 300`.

| Execution `AQP-DSA|…` | IGNIS |
|---|---|
| `A_DefineDelegationVault` | 500 |
| `A_SetOracleAuth` | 300 |
| `A_OracleWrite` | 200 |
| `A_ToggleExternalOracle` / `A_SetOracleValidity` | GOV, no IGNIS |
| `A_WithdrawRoyalty` / `A_BurnRoyalty` | 400 (+custody) |
| `A_FuelRoyalty` | 500 (+custody) |
| `A_SetAgencyFee` | 300 |
| `C_OpenAgency` (core `C_AdmitAgency`) | `GAS|OPEN-AGENCY` 500 |
| `C_RecomputeCapture` | 300 |

---

## Readers for the owner / management UI (grouped by module)

**ANK:** `UR_ANK|Data/ID/State`, `UR_ANK|AnchoredAsset/Fungibility/Precision/Promile/TFAmount/SFNonce/NFTraitKey/NFTraitValue/NFNonceClass/BoostClassId/AnchorsForAsset`; `UR_BC|Data/ID/Active/Anchors/ScoreLinks/ScoreLinkCount`; `UR_AA|Data/AnchorsActive/GroupsActive`; per-user `UR_ANK-U|*`, `UR_UB|AggregatePromile/Data`; `URC_TrueFungibleAnchorPromile`, `URC_SemiFungibleAnchorPromile(Absolute)`, `URC_NonFungibleAnchorPromile(Absolute)`.

**SCORE:** `UR_SCR|Score` + config `…ScoreClass/ScorePrecision/ScoreOwnerKonto/ScoreCanUpgrade/ScoreCanChangeOwner/ScoreDebBoost/ScoreSftEquality/ScoreNftScoreModel/ScoreLpDenominator/ScoreMx{Frozen,Sleeping,Hibernated}`; links `…ScoreAqpoolLink/ScoreFvtLink/ScoreBoostClassLink/ScoreBoostLink/ScoreTriplet(Id)`; aggregates `…ScoreTotal{Base,Boosted,BaseDeb,BoostedDeb,Deb}Score/ScoreNzsCount/ScoreVacateGeneration`; user rows `UR_U-SCR|UserScore{,BaseScore,BoostedScore,DebScore,BaseDebScore,BoostedDebScore,OuronetAccount,PoolId}`, `URC_U-SCR|UserScoreDebStale`; triplet `UR_SCR|Triplet{,BronzeScoreId,SilverScoreId,GoldenScoreId,Category,TrueTriplet}`, `URC_IsTrueTriplet/TripletExists`; defs `UR_S-DEF|SFScore*`, `UR_N-DEF|NF{Trait,Class}Score*`, `UR_{S,N}-DEF-REV|*`; models `UR_SCR|ScoreEntityModel/ModelEntityType`, `URC_ScoreEntityModelExists`.

**POOL:** `UR_AQP|Pool` + `…PoolAqpClass/AqpId/AssetId/StakeEnabled/VacateInProgress/SweepInProgress/VacateSession/Nns`; slots `…PoolScore{Primary…Septenary}`, `URC_PoolActiveScoreIds/PoolScoreSlotValue/PoolHasEmployedScores/AqpOwnerKonto`; trackers `UR_AQP|{DPTF,DPOF,DPSF,DPNF}Tracker*`; rollups `UR_AQP|Ben*{Total,NonceAmount,NonceTotal,ActiveNonceCount,AnkMeta,LastAnkSyncCount}`, `URC_Ben*{AnchorsNeedSync,HasStake}`, `UR_AQP|UserUnn`.

**FVT:** `UR_FVT|Fvt` + `…FvtClass/OwnerKonto/CanUpgrade/CanChangeOwner/CommonDenominator/Mosaic/MembershipMode/MemberLinkCount/EnabledRewardCount/OracleOn/VacateFrozen/SweepActive/SweepProgress`; aggregates `…Total{Base,Boosted,Deb}Score/TotalGhostTvlWeight/TotalNzsCount`; links `UR_FVT-SEL|{ScoreEntityLink,Enabled,ScoreEntityType,Swpair,GhostTvlWeight,TotalLaneWeight,Delegation,CaptureWeight,CaptureUnits,OracleTs}`; reward globals `UR_FVT-RG|{RpsGlobal,CurrentRps,AvailableRewards,RewardEnabled,RewardKind,Segmentation,MultipletFamilyId,UnclaimedCount,RoyaltyRewards,ZombieRewards,StreamCount,StreamUnreleased,StreamLastRelease}`; member/user `UR_FVT-RM|*`, `UR_FVT-RU|*`, `UR_FVT-MV|AvailableRewards/UnclaimedCount`, `UR_FVT-MUW|ContribWeight`; streams `UR_FVT-RS|Stream`, `URC_LiveClaimable/StreamStatus/ReleasableToNow`; quality split `UR_FVT-QS|Mode/BronzeSplit/SilverSplit/GoldSplit`; family `UR_FVT-MF|{MultipletFamily,Token0Id,Token1Id,Token2Id,Ats01Id,Ats12Id,Rank,Active}`; fee `UR_FVT-AF|Operator/FeePerMille`; presence/staleness `UR_FVT-UP|IsPresent`, `URC_Fvt{UserStillPresent,UserHasStaleMember(In),UserStaleMemberCount(In),SweepTotalPresent,MemberDebNeedsFix}`; collect/reward `URC_{CollectClaimableRewards,UserTier1AvailableRewards,MemberEffectiveCapture,MemberStakedStoaValue,InjectDenominator,FarmInjectDenominatorFresh,FvtTier1IndexRps}`; global oracle `UR_ExternalOracle/UR_OracleValidity`.

**VCT:** `UR_VacateInProgress`, `UR_VacateSessionFields`, `URC_PoolFullyVacated`, `URC_VacatePool{Tf,Of,Collectable}Ids`, `URC_ResolveOfDecimalAmountsFromTracker`.

**DSA:** `UR_DSA-TMP|Template{,ModelId,UnitScore,Active}`, `URC_DsaTemplateExists/Active`; `UR_DSA-AGN|Agency{,Operator,FeePerMille,Nodes,Uptime}`; `UR_DSA-ORA|Guard`; `URC_AgencyQuintessence/CaptureUnits`.
