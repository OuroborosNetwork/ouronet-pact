# RPS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:RPS -->
**On chain**

| | |
|---|---|
| module hash | `0O5oyS6YnTNdQqKxF99zAzpYVApcHFAVhIn7NkXmitY` |
| deployed size | 289,703 characters |
| implements | `OuronetPolicyV2`, `AcquisitionRewardPerShareV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact` |

**Tables it owns** — 16

`FVT|T|AgencyFee`, `FVT|T|DsaOracleConfig`, `FVT|T|ForcedFixCount`, `FVT|T|MemberUserWeight`, `FVT|T|MemberVault`, `FVT|T|MultipletFamily`, `FVT|T|QualitySplit`, `FVT|T|RPS|Global`, `FVT|T|RPS|Member`, `FVT|T|RPS|Stream`, `FVT|T|RPS|User`, `FVT|T|RewardAggregate`, `FVT|T|ScoreEntityLink`, `FVT|T|UserPresence`, `P|MT`, `P|T`

**Capabilities** — 10

`FVT|XE>ADMIT-DELEGATION`, `FVT|XE>DISPOSE-ROYALTY`, `FVT|XE>SWEEP-FIX`, `GOV`, `GOV|RPS_ADMIN`, `P|RPS|CALLER`, `P|RPS|REMOTE-GOV`, `P|SECURE-CALLER`, `RPS|XE>WRITE`, `SECURE`

**Functions** — 341, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 20 | returns what an operation will charge | `URCi_AddRewardLink`, `URCi_AddScoreEntity`, `URCi_BurnRoyaltyCustody`, `URCi_Collect`, `URCi_CollectFull`, `URCi_CollectableStakeFlow` …+14 |
| `URHC_` heavy derived reads | 2 | a scan, then derivation | `URHC_BuildInjectScorePlans`, `URHC_BuildStakeSettleBundle` |
| `URH_` heavy reads | 3 | a scan -- expensive by construction | `URH_FvtEnabledScoreEntityIdsForFvt`, `URH_FvtPresentUsers`, `URH_FvtStalePresentUsers` |
| `URC_` derived reads | 62 | read and derive; no enforce | `URC_BookStakeUnclaimedIgnis`, `URC_BuildPreScoreNzFlags`, `URC_CheckpointStakeRpsIgnis`, `URC_CollectClaimableRewards`, `URC_CollectForcedFixIgnis`, `URC_CollectTransferLegIgnis` …+56 |
| `UEV_` validators | 5 | read and enforce; may abort the transaction | `UEV_AddRewardLinkContext`, `UEV_QualitySplitContext`, `UEV_TrueFungibleStakeBeneficiaryAccount`, `UEV_TrueFungibleStakeNotReserved`, `UEV_TrueFungibleStakeOwnerAccount` |
| `UCk_` pure compute (key) | 9 | builds a composite table key | `UCk_ForcedFixCount`, `UCk_MemberUserWeight`, `UCk_MultipletFamily`, `UCk_RpsGlobal`, `UCk_RpsMember`, `UCk_RpsStream` …+3 |
| `UC_` pure compute | 4 | arguments only -- no reads, no enforce | `UC_ComputeInjectGainedRps`, `UC_EmptyOc`, `UC_GasPrice`, `UC_PerMilleRow` |
| `UR_` readers | 2 | table reads; no enforce, no writes | `UR_ExternalOracle`, `UR_OracleValidity` |
| `WI_` writers (insert) | 7 | one write site each | `WI_FvtRewardAggregate`, `WI_MultipletFamily`, `WI_QualitySplit`, `WI_RpsGlobal`, `WI_RpsMember`, `WI_RpsUser` …+1 |
| `WU_` writers (update) | 1 | one write site each | `WU_AgencyFee` |
| `WW_` writers (upsert) | 4 | one write site each | `WW_MemberUserWeight`, `WW_RpsMember`, `WW_RpsStream`, `WW_UserPresence` |
| `XI_` protected (internal) | 33 | this module only | `XI_AddRewardLink`, `XI_AddScoreEntity`, `XI_BookCollectUnclaimed`, `XI_BookStakeUnclaimedCounts`, `XI_CheckpointStakeRps`, `XI_DistributeInjectAmount` …+27 |
| `XE_` protected (external) | 43 | for other modules; opens with the IMC gate | `XE_AdmitDelegationMember`, `XE_BankScorePendingRewards`, `XE_BookStakeUnclaimedCounts`, `XE_BurnRoyalty`, `XE_CheckpointStakeRps`, `XE_FuelRoyalty` …+37 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 137 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `GOV|Demiurgoi`, `UDC_FVT|MultipletFamily`, `UDC_FVT|RPS|Global`, `UDC_FVT|RPS|Member` …+131 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 10

`FVT|XE>ADMIT-DELEGATION`, `FVT|XE>DISPOSE-ROYALTY`, `FVT|XE>SWEEP-FIX`, `GOV`, `GOV|RPS_ADMIN`, `P|RPS|CALLER`, `P|RPS|REMOTE-GOV`, `P|SECURE-CALLER`, `RPS|XE>WRITE`, `SECURE`

**Functions** -- 341, grouped by what the prefix promises

*Cost readers* (20) — price an operation; the exec path and the preview both call these

`URCi_AddRewardLink`, `URCi_AddScoreEntity`, `URCi_BurnRoyaltyCustody`, `URCi_Collect`, `URCi_CollectFull`, `URCi_CollectableStakeFlow`, `URCi_Control`, `URCi_FuelRoyaltyCustody`, `URCi_Inject`, `URCi_InjectFull`, `URCi_OrtoFungibleStakeFlow`, `URCi_RotateOwnership`, `URCi_SetCommonDenominator`, `URCi_SetMosaic`, `URCi_SetQualitySplit`, `URCi_SetSplitMode`, `URCi_ToggleRewardLink`, `URCi_ToggleScoreEntityLink`, `URCi_TrueFungibleStakeFlow`, `URCi_WithdrawRoyaltyCustody`

*Heavy derived reads* (2) — scan and derive -- OFF the execution path

`URHC_BuildInjectScorePlans`, `URHC_BuildStakeSettleBundle`

*Heavy reads* (5) — scan a table -- OFF the execution path, cost grows with data

`URH_FVT-RG|EnabledRewardRows`, `URH_FVT|SettleFvtRewardBundle`, `URH_FvtEnabledScoreEntityIdsForFvt`, `URH_FvtPresentUsers`, `URH_FvtStalePresentUsers`

*Derived reads* (62) — read and compute; no enforce

`URC_BookStakeUnclaimedIgnis`, `URC_BuildPreScoreNzFlags`, `URC_CheckpointStakeRpsIgnis`, `URC_CollectClaimableRewards`, `URC_CollectForcedFixIgnis`, `URC_CollectTransferLegIgnis`, `URC_CollectXferIgnis`, `URC_ComputeTripletLanes`, `URC_FarmInjectDenominatorFresh`, `URC_FvtExists`, `URC_FvtHasAnyMemberLink`, `URC_FvtHasEnabledRewardToken`, `URC_FvtHasScoreEntityLinks`, `URC_FvtMemberDebNeedsFix`, `URC_FvtResolveClass`, `URC_FvtRewardDptfIdsFromBundle`, `URC_FvtRpsGlobalRowExists`, `URC_FvtRpsMemberRowExists`, `URC_FvtRpsUserRowExists`, `URC_FvtScoreEntityLinkRowExists`, `URC_FvtSweepTotalPresent`, `URC_FvtTier1IndexRps`, `URC_FvtUserHasStaleMember`, `URC_FvtUserHasStaleMemberIn`, `URC_FvtUserStaleMemberCount`, `URC_FvtUserStaleMemberCountIn`, `URC_FvtUserStillPresent`, `URC_HeterogeneousLaneRouteIgnis`, `URC_InjectDenominator`, `URC_LiveClaimable`, `URC_MaxStreamLanes`, `URC_MemberEffectiveCapture`, `URC_MemberLevel2Weight`, `URC_MemberStakedStoaValue`, `URC_MultipletFamilyExists`, `URC_PoolEmployedScoresFvtStakeReady`, `URC_PreScoreWasNonZeroForScore`, `URC_ProjectedIndexAdvance`, `URC_ReleasableToNow`, `URC_ResolveEmployedScoreEntity`, `URC_ResolveScoreEntityGhostWeight`, `URC_ScoreEntityMemberDebWeight`, `URC_ScoreEntityMemberTier2Divisor`, `URC_ScoreEntityMemberWeight`, `URC_ScoreEntityUserWeight`, `URC_ScoreFvtStakeReady`, `URC_SettleDistinctFvtLinks`, `URC_SettleEligibleEmployedScores`, `URC_SettlePlanEmployedScoreIds`, `URC_SettleScorePlanRows`, `URC_SettleStakePendingIgnis`, `URC_StakeAnyPendingOnFvtRewardLine`, `URC_StakeScoreDeltaSum`, `URC_StakeScoreDeltaSumForClasses`, `URC_StreamStatus`, `URC_TierBiggest`, `URC_TierFixed`, `URC_TierMedium`, `URC_TripletUserDebSum`, `URC_TripletUserLaneWeightLive`, `URC_UserScoreTripleIsNonZero`, `URC_UserTier1AvailableRewards`

*Point reads* (77) — one row or field by key

`P|UR_IMP`, `UR_ExternalOracle`, `UR_FVT-AF|FeePerMille`, `UR_FVT-AF|Operator`, `UR_FVT-FFC|Count`, `UR_FVT-MF|Active`, `UR_FVT-MF|Ats01Id`, `UR_FVT-MF|Ats12Id`, `UR_FVT-MF|MultipletFamily`, `UR_FVT-MF|MultipletFamilyId`, `UR_FVT-MF|Rank`, `UR_FVT-MF|Token0Id`, `UR_FVT-MF|Token1Id`, `UR_FVT-MF|Token2Id`, `UR_FVT-MUW|ContribWeight`, `UR_FVT-MV|AvailableRewards`, `UR_FVT-MV|UnclaimedCount`, `UR_FVT-QS|BronzeSplit`, `UR_FVT-QS|GoldSplit`, `UR_FVT-QS|Mode`, `UR_FVT-QS|SilverSplit`, `UR_FVT-RG|AvailableRewards`, `UR_FVT-RG|CurrentRps`, `UR_FVT-RG|DptfId`, `UR_FVT-RG|FvtId`, `UR_FVT-RG|MultipletFamilyId`, `UR_FVT-RG|RewardEnabled`, `UR_FVT-RG|RewardKind`, `UR_FVT-RG|RoyaltyRewards`, `UR_FVT-RG|RpsGlobal`, `UR_FVT-RG|Segmentation`, `UR_FVT-RG|StreamCount`, `UR_FVT-RG|StreamLastRelease`, `UR_FVT-RG|StreamUnreleased`, `UR_FVT-RG|UnclaimedCount`, `UR_FVT-RG|ZombieRewards`, `UR_FVT-RM|DptfId`, `UR_FVT-RM|FvtId`, `UR_FVT-RM|LastFarmRpsG`, `UR_FVT-RM|MemberDebRps`, `UR_FVT-RM|PendingMemberRewards`, `UR_FVT-RM|RpsMember`, `UR_FVT-RM|ScoreEntityId`, `UR_FVT-RS|Stream`, `UR_FVT-RU|DptfId`, `UR_FVT-RU|FvtId`, `UR_FVT-RU|LastRps`, `UR_FVT-RU|PendingRewards`, `UR_FVT-RU|RpsUser`, `UR_FVT-RU|ScoreEntityId`, `UR_FVT-RU|UserId`, `UR_FVT-SEL|CaptureUnits`, `UR_FVT-SEL|CaptureWeight`, `UR_FVT-SEL|Delegation`, `UR_FVT-SEL|Enabled`, `UR_FVT-SEL|FvtId`, `UR_FVT-SEL|GhostTvlWeight`, `UR_FVT-SEL|OracleTs`, `UR_FVT-SEL|ScoreEntityId`, `UR_FVT-SEL|ScoreEntityLink`, `UR_FVT-SEL|ScoreEntityType`, `UR_FVT-SEL|Swpair`, `UR_FVT-SEL|TotalLaneWeight`, `UR_FVT-UP|IsPresent`, `UR_FVT|EnabledRewardCount`, `UR_FVT|FvtClass`, `UR_FVT|MemberLinkCount`, `UR_FVT|MembershipMode`, `UR_FVT|Mosaic`, `UR_FVT|OwnerKonto`, `UR_FVT|SplitMode`, `UR_FVT|TotalBaseScore`, `UR_FVT|TotalBoostedScore`, `UR_FVT|TotalDebScore`, `UR_FVT|TotalGhostTvlWeight`, `UR_FVT|TotalNzsCount`, `UR_OracleValidity`

*Validators* (6) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AddRewardLinkContext`, `UEV_QualitySplitContext`, `UEV_TrueFungibleStakeBeneficiaryAccount`, `UEV_TrueFungibleStakeNotReserved`, `UEV_TrueFungibleStakeOwnerAccount`

*Constructors* (10) — build objects

`UDC_FVT|MultipletFamily`, `UDC_FVT|RPS|Global`, `UDC_FVT|RPS|Member`, `UDC_FVT|RPS|Stream`, `UDC_FVT|RPS|User`, `UDC_FVT|ScoreEntityLink`, `UDC_FVT|ScorePreNzFlag`, `UDC_FVT|SettleFvtRewards`, `UDC_FVT|SettleScorePlan`, `UDC_FVT|StakeSettleBundle`

*Pure compute* (4) — arguments only; no reads, no enforce

`UC_ComputeInjectGainedRps`, `UC_EmptyOc`, `UC_GasPrice`, `UC_PerMilleRow`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (49) — callable by other modules only

`XE_AdmitDelegationMember`, `XE_BankScorePendingRewards`, `XE_BookStakeUnclaimedCounts`, `XE_BurnRoyalty`, `XE_CheckpointStakeRps`, `XE_FuelRoyalty`, `XE_FvtFixUserChunk`, `XE_FvtSweepRecomputeChunk`, `XE_SetAgencyFee`, `XE_SetExternalOracle`, `XE_SetMemberCapture`, `XE_SetMemberDelegation`, `XE_SetOracleValidity`, `XE_SweepSyncTripletLaneWeights`, `XE_WI_FvtRewardAggregate`, `XE_WI_QualitySplit`, `XE_WI_RpsGlobal`, `XE_WI_ScoreEntityLink`, `XE_WU_FvtForcedFixCount|Zero`, `XE_WU_MemberVault|AvailableRewards`, `XE_WU_RpsGlobal|AvailableRewards`, `XE_WU_RpsUser|LastRps`, `XE_WU_RpsUser|PendingRewards`, `XE_WithdrawRoyalty`, `XE_XI_2|SettleMemberTier2`, `XE_XI_AddRewardLink`, `XE_XI_AddScoreEntity`, `XE_XI_BookCollectUnclaimed`, `XE_XI_BookStakeUnclaimedCounts`, `XE_XI_CheckpointStakeRps`, `XE_XI_FixUserFvtDeb`, `XE_XI_FixUserFvtDebPenalizedIn`, `XE_XI_FixUserMemberDeb`, `XE_XI_FvtAddStream`, `XE_XI_FvtInjectCore`, `XE_XI_FvtSweepRecomputeChunk`, `XE_XI_FvtSweepRecomputeWindow`, `XE_XI_IssueMultipletFamily`, `XE_XI_ReleaseStream`, `XE_XI_RotateOwnership`, `XE_XI_RpsPreScore`, `XE_XI_SetMosaic`, `XE_XI_SetSplitMode`, `XE_XI_SyncFvtPresence`, `XE_XI_SyncFvtTotalDebMirrors`, `XE_XI_SyncTripletLaneWeights`, `XE_XI_ToggleRewardLink`, `XE_XI_ToggleScoreEntityLink`, `XE_XI_TransferRewardDptfFromVault`

*Internal writes* (45) — this module only; writes under a capability

`XI_1|BankScorePendingRewards`, `XI_1|BookCollectUnclaimed`, `XI_1|BookUnclaimedForFvtRewardLine`, `XI_1|EnsureScoreRewardRows`, `XI_1|FarmSplitInject`, `XI_1|HeterogeneousLaneRoute`, `XI_1|SyncFarmGhostTvlForEmployedScores`, `XI_2|BankUserTier1Pending`, `XI_2|BumpRpsGlobalUnclaimed`, `XI_2|EnsureRpsMemberRow`, `XI_2|EnsureRpsUserRow`, `XI_2|SettleMemberTier2`, `XI_AddRewardLink`, `XI_AddScoreEntity`, `XI_BookCollectUnclaimed`, `XI_BookStakeUnclaimedCounts`, `XI_CheckpointStakeRps`, `XI_DistributeInjectAmount`, `XI_FixUserFvtDeb`, `XI_FixUserFvtDebIn`, `XI_FixUserFvtDebPenalized`, `XI_FixUserFvtDebPenalizedIn`, `XI_FixUserMemberDeb`, `XI_FixUserMemberDebIn`, `XI_FvtInjectCore`, `XI_FvtSweepRecomputeChunk`, `XI_FvtSweepRecomputeWindow`, `XI_IssueMultipletFamily`, `XI_MarkFvtPresence`, `XI_NormalizeRoyalty`, `XI_RecomputeFvtPresence`, `XI_ReleaseStream`, `XI_RotateOwnership`, `XI_RpsPreScore`, `XI_SetMosaic`, `XI_SetSplitMode`, `XI_SweepRecomputeUserMember`, `XI_SweepRecomputeUserMemberIn`, `XI_SyncFarmGhostTvlForInject`, `XI_SyncFvtPresence`, `XI_SyncFvtTotalDebMirrors`, `XI_SyncTripletLaneWeights`, `XI_ToggleRewardLink`, `XI_ToggleScoreEntityLink`, `XI_TransferRewardDptfFromVault`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (53) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`, `UCk_ForcedFixCount`, `UCk_MemberUserWeight`, `UCk_MultipletFamily`, `UCk_RpsGlobal`, `UCk_RpsMember`, `UCk_RpsStream`, `UCk_RpsUser`, `UCk_ScoreEntityLink`, `UCk_UserPresence`, `WI_FvtRewardAggregate`, `WI_MultipletFamily`, `WI_QualitySplit`, `WI_RpsGlobal`, `WI_RpsMember`, `WI_RpsUser`, `WI_ScoreEntityLink`, `WU2_Fvt|MosaicPolicy`, `WU_AgencyFee`, `WU_FvtForcedFixCount|Add`, `WU_FvtForcedFixCount|Zero`, `WU_Fvt|EnabledRewardCount`, `WU_Fvt|MemberLinkCount`, `WU_Fvt|MembershipMode`, `WU_Fvt|Mosaic`, `WU_Fvt|OwnerKonto`, `WU_Fvt|SplitMode`, `WU_Fvt|TotalDebScore`, `WU_Fvt|TotalGhostTvlWeight`, `WU_MemberVault|AvailableRewards`, `WU_MemberVault|UnclaimedCount`, `WU_RpsGlobal|AvailableRewards`, `WU_RpsGlobal|CurrentRps`, `WU_RpsGlobal|RewardEnabled`, `WU_RpsGlobal|RoyaltyRewards`, `WU_RpsGlobal|StreamCount`, `WU_RpsGlobal|StreamLastRelease`, `WU_RpsGlobal|StreamUnreleased`, `WU_RpsGlobal|UnclaimedCount`, `WU_RpsGlobal|ZombieRewards`, `WU_RpsUser|LastRps`, `WU_RpsUser|PendingRewards`, `WU_ScoreEntityLink|Capture`, `WU_ScoreEntityLink|Delegation`, `WU_ScoreEntityLink|Enabled`, `WU_ScoreEntityLink|GhostTvlWeight`, `WU_ScoreEntityLink|TotalLaneWeight`, `WW_MemberUserWeight`, `WW_RpsMember`, `WW_RpsStream`, `WW_UserPresence`, `XIv_FvtAddStream`
<!-- @end:module-page:RPS -->

## Traps

_To be written._
