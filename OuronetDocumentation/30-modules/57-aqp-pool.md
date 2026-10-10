# AQP-POOL — the pools

## What it is for

Where you actually stake. A pool accepts one asset shape from five classes, tracks positions, and employs up to seven scores.

The separation that everything depends on: **users never stake "into the farm" — they stake into a pool**, and the distributor only accounts and pays.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

The family's state module for staking.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-POOL -->
**On chain**

| | |
|---|---|
| module hash | `aEnxclO_VtpCBm8I5jdBABDGVsTrt0YN8IdU6MTAEi8` |
| deployed size | 162,896 characters |
| implements | `OuronetPolicyV2`, `AcquisitionPoolsV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact` |

**Tables it owns** — 13

`AQP|T|BenDpnfAnkMeta`, `AQP|T|BenDpnfNonceTotal`, `AQP|T|BenDpsfAnkMeta`, `AQP|T|BenDpsfNonceTotal`, `AQP|T|BenDptfTotal`, `AQP|T|DPNFTracker`, `AQP|T|DPOFTracker`, `AQP|T|DPSFTracker`, `AQP|T|DPTFTracker`, `AQP|T|Pool`, `AQP|T|UserOccupancy`, `P|MT`, `P|T`

**Capabilities** — 19

`AQP|C>ADD-SCORE`, `AQP|C>DISABLE-POOL-STAKE`, `AQP|C>ENABLE-POOL-STAKE`, `AQP|C>ISSUE-POOL`, `AQP|C>REVOKE-SCORE`, `AQP|C>SYNC-COLLECTABLE-ANCHORS`, `AQP|C>SYNC-TF-ANCHORS`, `AQP|GOV`, `AQP|XE>COLLECTABLE-POOL-CUSTODY`, `AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY`, `AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC`, `AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC`, `AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`, `GOV`, `GOV|AQP_ADMIN`, `P|AQP|CALLER`, `P|AQP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 214, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 9 | returns what an operation will charge | `URCi_AddScore`, `URCi_Issue`, `URCi_IssueStoa`, `URCi_RevokeScore`, `URCi_SetPoolStake`, `URCi_SyncCollectableAnchors` …+3 |
| `URC_` derived reads | 31 | read and derive; no enforce | `URC_AqpOwnerKonto`, `URC_AqpOwnerKontoFromClassAndAsset`, `URC_BenCollectableHasStake`, `URC_BenDpnfAnchorsNeedSync`, `URC_BenDpnfHasStake`, `URC_BenDpsfAnchorsNeedSync` …+25 |
| `UEV_` validators | 9 | read and enforce; may abort the transaction | `UEV_AddScorePoolAndScore`, `UEV_ExecutorIzAqpAssetOwner`, `UEV_ExecutorIzPoolOwner`, `UEV_IssuePoolClassAndAsset`, `UEV_RevokeScorePoolAndScore`, `UEV_StakeBeneficiaryAccount` …+3 |
| `UCk_` pure compute (key) | 10 | builds a composite table key | `UCk_BenDpnfAnkMeta`, `UCk_BenDpnfNonceTotal`, `UCk_BenDpsfAnkMeta`, `UCk_BenDpsfNonceTotal`, `UCk_BenDptfTotal`, `UCk_DPNFTracker` …+4 |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_PoolScoreSlotPatch` |
| `CAP_` ownership gates | 3 | account-ownership enforcement | `CAP_AqpAssetOwner`, `CAP_PoolOwner`, `CAP_StakeOwner` |
| `WI_` writers (insert) | 1 | one write site each | `WI_Pool` |
| `WW_` writers (upsert) | 9 | one write site each | `WW_BenDpnfAnkMeta`, `WW_BenDpnfNonceTotal`, `WW_BenDpsfAnkMeta`, `WW_BenDpsfNonceTotal`, `WW_BenDptfTotal`, `WW_DPNFTracker` …+3 |
| `XI_` protected (internal) | 3 | this module only | `XI_AddScoreToPool`, `XI_IssuePool`, `XI_RevokeScoreFromPool` |
| `XE_` protected (external) | 11 | for other modules; opens with the IMC gate | `XE_CollectableBeneficiaryRollup`, `XE_CollectablePoolTracker`, `XE_CollectableTransfer`, `XE_OrtoFungiblePoolTracker`, `XE_OrtoFungibleTransfer`, `XE_SetSweepInProgress` …+5 |
| `XB_` protected (both) | 3 | internal and external | `XB_SetBenCollectableAnkSyncCount`, `XB_SetBenDptfAnkSyncCount`, `XB_SetPoolStakeEnabled` |
| `C_` client | 7 | reached via Talos, never called directly | `C_AddScore`, `C_DisablePoolStake`, `C_EnablePoolStake`, `C_Issue`, `C_RevokeScore`, `C_SyncCollectableAnchors` …+1 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 108 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `UDC_AQP|BenDpnfAnkMeta`, `UDC_AQP|BenDpnfNonceTotal` …+102 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **capabilities** in the repository only: `AQP|C>BACKFILL-SCORE-SLICE`, `AQP|C>BEGIN-SCORE-REVOKE`, `AQP|C>DRAIN-SCORE-SLICE`, `AQP|C>FINALIZE-SCORE-REVOKE`, `AQP|C>UPDATE-SCORE-MULTIPLIERS`
> - **functions** in the repository only: `CC_FinalizeScoreRevoke`, `CC_UpdateScoreMultipliers`, `CCp_BackfillScoreSlice`, `C_BeginScoreRevoke`, `Cp_DrainScoreSlice`, `UC_AQP|BackfillRowsForBeneficiary`, `UC_AQP|BackfillSumForBeneficiary`, `UC_AQP|BackfillUniqueBeneficiaries`

**Capabilities** -- 19

`AQP|C>ADD-SCORE`, `AQP|C>DISABLE-POOL-STAKE`, `AQP|C>ENABLE-POOL-STAKE`, `AQP|C>ISSUE-POOL`, `AQP|C>REVOKE-SCORE`, `AQP|C>SYNC-COLLECTABLE-ANCHORS`, `AQP|C>SYNC-TF-ANCHORS`, `AQP|GOV`, `AQP|XE>COLLECTABLE-POOL-CUSTODY`, `AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY`, `AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC`, `AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC`, `AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`, `GOV`, `GOV|AQP_ADMIN`, `P|AQP|CALLER`, `P|AQP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 214, grouped by what the prefix promises

*Cost readers* (9) — price an operation; the exec path and the preview both call these

`URCi_AddScore`, `URCi_Issue`, `URCi_IssueStoa`, `URCi_RevokeScore`, `URCi_SetPoolStake`, `URCi_SyncCollectableAnchors`, `URCi_SyncCollectableAnchorsFull`, `URCi_SyncTrueFungibleAnchors`, `URCi_SyncTrueFungibleAnchorsFull`

*Heavy reads* (15) — scan a table -- OFF the execution path, cost grows with data

`URH_AQP|ActiveDpnfTrackerRows`, `URH_AQP|ActiveDpofTrackerRows`, `URH_AQP|ActiveDpsfTrackerRows`, `URH_AQP|ActiveDptfTrackerRows`, `URH_AQP|AllPoolIds`, `URH_AQP|BenDpnfActiveNonceSupplies`, `URH_AQP|BenDpsfActiveNonceSupplies`, `URH_AQP|DpnfStakesByBeneficiary`, `URH_AQP|DpnfStakesByOwner`, `URH_AQP|DpofStakesByBeneficiary`, `URH_AQP|DpofStakesByOwner`, `URH_AQP|DpsfStakesByBeneficiary`, `URH_AQP|DpsfStakesByOwner`, `URH_AQP|DptfStakesByBeneficiary`, `URH_AQP|DptfStakesByOwner`

*Derived reads* (31) — read and compute; no enforce

`URC_AqpOwnerKonto`, `URC_AqpOwnerKontoFromClassAndAsset`, `URC_BenCollectableHasStake`, `URC_BenDpnfAnchorsNeedSync`, `URC_BenDpnfHasStake`, `URC_BenDpsfAnchorsNeedSync`, `URC_BenDpsfHasStake`, `URC_BenDptfAnchorsNeedSync`, `URC_CollectableUnstakeNoncesSufficient`, `URC_CollectableUnstakeRollupSufficient`, `URC_DpofLegPrefix`, `URC_DptfIsLpNomenclature`, `URC_DptfLegPrefix`, `URC_DptfStakeIsNativeLeg`, `URC_DptfStakeIsReservedLeg`, `URC_FirstFreeScoreSlotIndex`, `URC_NoEmployedBoostLinkTarget`, `URC_OrtoUnstakeNoncesSufficient`, `URC_PoolActiveScoreIds`, `URC_PoolHasEmployedScores`, `URC_PoolScoreSlotValue`, `URC_PoolStakeAdmissionOk`, `URC_PoolUnstakeAdmissionOk`, `URC_PriorScoreSlotsOccupied`, `URC_ScoreSlotIndexForScore`, `URC_StakeCollectableMatchesPool`, `URC_StakeCollectablePoolClassOk`, `URC_StakeOrtoFungibleDpofMatchesPool`, `URC_StakeOrtoFungiblePoolClassOk`, `URC_StakeTrueFungibleDptfMatchesPool`, `URC_StakeTrueFungiblePoolClassOk`

*Point reads* (58) — one row or field by key

`P|UR_IMP`, `UR_AQP|BenDpnfActiveNonceCount`, `UR_AQP|BenDpnfAnkMeta`, `UR_AQP|BenDpnfLastAnkSyncCount`, `UR_AQP|BenDpnfNonceAmount`, `UR_AQP|BenDpnfNonceTotal`, `UR_AQP|BenDpsfActiveNonceCount`, `UR_AQP|BenDpsfAnkMeta`, `UR_AQP|BenDpsfLastAnkSyncCount`, `UR_AQP|BenDpsfNonceAmount`, `UR_AQP|BenDpsfNonceTotal`, `UR_AQP|BenDptfLastAnkSyncCount`, `UR_AQP|BenDptfTotal`, `UR_AQP|BenDptfTotalBalance`, `UR_AQP|DPNFTracker`, `UR_AQP|DPNFTrackerBalance`, `UR_AQP|DPNFTrackerBeneficiaryId`, `UR_AQP|DPNFTrackerDpnfId`, `UR_AQP|DPNFTrackerNonce`, `UR_AQP|DPNFTrackerOwnerId`, `UR_AQP|DPNFTrackerPoolId`, `UR_AQP|DPOFTracker`, `UR_AQP|DPOFTrackerBalance`, `UR_AQP|DPOFTrackerBeneficiaryId`, `UR_AQP|DPOFTrackerDpofId`, `UR_AQP|DPOFTrackerNonce`, `UR_AQP|DPOFTrackerOwnerId`, `UR_AQP|DPOFTrackerPoolId`, `UR_AQP|DPSFTracker`, `UR_AQP|DPSFTrackerBalance`, `UR_AQP|DPSFTrackerBeneficiaryId`, `UR_AQP|DPSFTrackerDpsfId`, `UR_AQP|DPSFTrackerNonce`, `UR_AQP|DPSFTrackerOwnerId`, `UR_AQP|DPSFTrackerPoolId`, `UR_AQP|DPTFTracker`, `UR_AQP|DPTFTrackerBalance`, `UR_AQP|DPTFTrackerBeneficiaryId`, `UR_AQP|DPTFTrackerDptfId`, `UR_AQP|DPTFTrackerOwnerId`, `UR_AQP|DPTFTrackerPoolId`, `UR_AQP|Pool`, `UR_AQP|PoolAqpClass`, `UR_AQP|PoolAqpId`, `UR_AQP|PoolAssetId`, `UR_AQP|PoolNns`, `UR_AQP|PoolScorePrimary`, `UR_AQP|PoolScoreQuaternary`, `UR_AQP|PoolScoreQuinary`, `UR_AQP|PoolScoreSecondary`, `UR_AQP|PoolScoreSenary`, `UR_AQP|PoolScoreSeptenary`, `UR_AQP|PoolScoreTertiary`, `UR_AQP|PoolStakeEnabled`, `UR_AQP|PoolSweepInProgress`, `UR_AQP|PoolVacateInProgress`, `UR_AQP|PoolVacateSession`, `UR_AQP|UserUnn`

*Validators* (10) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AddScorePoolAndScore`, `UEV_ExecutorIzAqpAssetOwner`, `UEV_ExecutorIzPoolOwner`, `UEV_IssuePoolClassAndAsset`, `UEV_RevokeScorePoolAndScore`, `UEV_StakeBeneficiaryAccount`, `UEV_StakeCollectableLeg`, `UEV_StakeOrtoFungibleDpofLeg`, `UEV_StakeTrueFungibleDptfLeg`

*Constructors* (13) — build objects

`UDC_AQP|BenDpnfAnkMeta`, `UDC_AQP|BenDpnfNonceTotal`, `UDC_AQP|BenDpsfAnkMeta`, `UDC_AQP|BenDpsfNonceTotal`, `UDC_AQP|BenDptfTotal`, `UDC_AQP|NonFungibleTracker`, `UDC_AQP|OrtoFungibleTracker`, `UDC_AQP|Schema`, `UDC_AQP|SchemaWithScoreAtSlot`, `UDC_AQP|SchemaWithScoreSlots`, `UDC_AQP|SemiFungibleTracker`, `UDC_AQP|TrueFungibleTracker`, `UDC_AQP|UserOccupancy`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_PoolScoreSlotPatch`

*Ownership checks* (3) — account-ownership enforcement

`CAP_AqpAssetOwner`, `CAP_PoolOwner`, `CAP_StakeOwner`

*Client entry* (7) — builds the bill; reachable only through Talos

`C_AddScore`, `C_DisablePoolStake`, `C_EnablePoolStake`, `C_Issue`, `C_RevokeScore`, `C_SyncCollectableAnchors`, `C_SyncTrueFungibleAnchors`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (11) — callable by other modules only

`XE_CollectableBeneficiaryRollup`, `XE_CollectablePoolTracker`, `XE_CollectableTransfer`, `XE_OrtoFungiblePoolTracker`, `XE_OrtoFungibleTransfer`, `XE_SetSweepInProgress`, `XE_SetVacateJobState`, `XE_TrueFungibleBeneficiaryRollup`, `XE_TrueFungiblePoolTracker`, `XE_TrueFungibleTransfer`, `XE_ZeroDptfTrackerSlot`

*Internal + external* (3) — callable both ways

`XB_SetBenCollectableAnkSyncCount`, `XB_SetBenDptfAnkSyncCount`, `XB_SetPoolStakeEnabled`

*Internal writes* (11) — this module only; writes under a capability

`XI_1|BumpBenCollectableNonceTotalSlot`, `XI_1|BumpBenDptfTotalSlot`, `XI_1|WriteCollectableTrackerSlot`, `XI_1|WriteDpofTrackerSlot`, `XI_1|WriteDptfTrackerSlot`, `XI_1|ZeroDptfTrackerSlot`, `XI_2|BumpBenDpnfNonceTotal`, `XI_2|BumpBenDpsfNonceTotal`, `XI_AddScoreToPool`, `XI_IssuePool`, `XI_RevokeScoreFromPool`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (34) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `UCk_BenDpnfAnkMeta`, `UCk_BenDpnfNonceTotal`, `UCk_BenDpsfAnkMeta`, `UCk_BenDpsfNonceTotal`, `UCk_BenDptfTotal`, `UCk_DPNFTracker`, `UCk_DPOFTracker`, `UCk_DPSFTracker`, `UCk_DPTFTracker`, `UCk_UserOccupancy`, `WI_Pool`, `WU4_Pool|VacateJobState`, `WU7_Pool|ScoreSlots`, `WU_BenDpnfAnkMeta|LastAnkSyncCount`, `WU_BenDpsfAnkMeta|LastAnkSyncCount`, `WU_BenDptfTotal|LastAnkSyncCount`, `WU_Pool|Nns`, `WU_Pool|Occupancy`, `WU_Pool|ScoreSlot`, `WU_Pool|StakeEnabled`, `WU_Pool|SweepInProgress`, `WU_User|Unn`, `WW_BenDpnfAnkMeta`, `WW_BenDpnfNonceTotal`, `WW_BenDpsfAnkMeta`, `WW_BenDpsfNonceTotal`, `WW_BenDptfTotal`, `WW_DPNFTracker`, `WW_DPOFTracker`, `WW_DPSFTracker`, `WW_DPTFTracker`
<!-- @end:module-page:AQP-POOL -->

## Traps

**Owner and beneficiary are separate.** The owner signs and gets custody back; the beneficiary earns the score and the boost. One party can stake on another's behalf without surrendering the asset.

**Special variants are first-class stake legs**, admitted or refused per pool class — but reserved tokens are rejected outright everywhere.

**A merge-order bug once made a seven-slot setter a no-op** that, as the source puts it, *flatly contradicted its own docstring*.
