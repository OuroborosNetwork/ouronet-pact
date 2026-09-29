# AQP-SCORE

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-SCORE -->
**On chain**

| | |
|---|---|
| module hash | `g7nAGCH06_ulMofU4XoN1ReUhdzDnBW1vs5To1ayzyA` |
| deployed size | 207,599 characters |
| implements | `OuronetPolicyV2`, `AcquisitionScoresV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact` |

**Tables it owns** — 12

`P|MT`, `P|T`, `SCR|T|NF|ClassScore`, `SCR|T|NF|DefRevision`, `SCR|T|NF|TraitKeys`, `SCR|T|NF|TraitScore`, `SCR|T|SF|DefRevision`, `SCR|T|SF|Score`, `SCR|T|Score`, `SCR|T|ScoreEntityModel`, `SCR|T|Triplet`, `SCR|T|UserScore`

**Capabilities** — 36

`GOV`, `GOV|AQP-SCORE_ADMIN`, `P|AQP-SCORE|CALLER`, `P|SECURE-CALLER`, `SCR|C>COMBINE-TRIPLET-SCORE-MODEL`, `SCR|C>CONTROL-SCORE`, `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`, `SCR|C>CREATE-BOOST-LINK-SCORE`, `SCR|C>ENABLE-DEB-BOOST-SCORE`, `SCR|C>ISSUE-LIQUIDITY-SCORE`, `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `SCR|C>ISSUE-NF-SET-SCORE-DEFINITION`, `SCR|C>ISSUE-NON-FUNGIBLE-SCORE`, `SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SCORE-FROM-MODEL`, `SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SF-SCORE-DEFINITION`, `SCR|C>ISSUE-SINGLE-SCORE-MODEL`, `SCR|C>ISSUE-TRIPLET`, `SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE`, `SCR|C>ROTATE-OWNERSHIP-SCORE`, `SCR|XE>CREATE-AQPOOL-LINK`, `SCR|XE>CREATE-FVT-LINK`, `SCR|XE>NUKE-SCORE-FOR-VACATE`, `SCR|XE>REFRESH-USER-SCORE-DEB`, `SCR|XE>REVOKE-AQPOOL-LINK`, `SCR|XE>UPDATE-LP-STAKE-DPTF-LP`, `SCR|XE>UPDATE-LP-STAKE-ORTO-LP`, `SCR|XE>UPDATE-STAKE-DPNF`, `SCR|XE>UPDATE-STAKE-DPOF`, `SCR|XE>UPDATE-STAKE-DPOF-SPECIAL`, `SCR|XE>UPDATE-STAKE-DPSF`, `SCR|XE>UPDATE-STAKE-DPTF`, `SCR|XI>ISSUE-SCORE`, `SCR|XI>X_ISSUE-NF-SCORE-DEFINITION`, `SECURE`

**Functions** — 217, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 13 | returns what an operation will charge | `URCi_CombineTripletModel`, `URCi_Control`, `URCi_CreateBoostClassLink`, `URCi_CreateBoostLink`, `URCi_EnableDebBoost`, `URCi_IssueNonFungibleScoreDefinition` …+7 |
| `URC_` derived reads | 20 | read and derive; no enforce | `URC_IsTrueTriplet`, `URC_LpAmountToLpDenominatorEquivalent`, `URC_NFTraitKeysList`, `URC_OrtoDpofIsSpecialLeg`, `URC_OrtoDpofUsesSleepingMultiplier`, `URC_ScoreEntityModelExists` …+14 |
| `UEV_` validators | 10 | read and enforce; may abort the transaction | `UEV_DpnfStakeScoreContext`, `UEV_DpofStakeScoreContext`, `UEV_DpsfStakeScoreContext`, `UEV_DptfStakeScoreContext`, `UEV_ExecutorIzScoreOwner`, `UEV_IzNonFungibleScoreDefinitionTraitBranch` …+4 |
| `UCx_` pure compute (auxiliary) | 1 | a private helper of the function above it | `UCx_StakeEqualNativeUnitRawWeight` |
| `UCk_` pure compute (key) | 9 | builds a composite table key | `UCk_NFClassScore`, `UCk_NFDefRevision`, `UCk_NFScore`, `UCk_NFTraitKeys`, `UCk_NFTraitScore`, `UCk_SFDefRevision` …+3 |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_ComputeTripletId` |
| `WI_` writers (insert) | 3 | one write site each | `WI_Score`, `WI_ScoreEntityModel`, `WI_Triplet` |
| `WW_` writers (upsert) | 7 | one write site each | `WW_NFClassScore`, `WW_NFDefRevision`, `WW_NFTraitKeys`, `WW_NFTraitScore`, `WW_SFDefRevision`, `WW_SFScore` …+1 |
| `XI_` protected (internal) | 10 | this module only | `XI_Control`, `XI_CreateBoostClassLink`, `XI_CreateBoostLink`, `XI_EnableDebBoost`, `XI_Issue`, `XI_IssueNonFungibleScoreDefinitionCore` …+4 |
| `XE_` protected (external) | 8 | for other modules; opens with the IMC gate | `XE_ApplyCollectableStakeDelta`, `XE_ApplyOrtoFungibleStakeDelta`, `XE_ApplyTrueFungibleStakeDelta`, `XE_CreateAqpoolLink`, `XE_CreateFvtLink`, `XE_NukeScoreForVacate` …+2 |
| `C_` client | 17 | reached via Talos, never called directly | `C_CombineTripletScoreModel`, `C_Control`, `C_CreateBoostClassLink`, `C_CreateBoostLink`, `C_EnableDebBoost`, `C_IssueLiquidityScore` …+11 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 109 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `UDC_SCR|NF|ClassSchema`, `UDC_SCR|NF|DefRevision` …+103 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 36

`GOV`, `GOV|AQP-SCORE_ADMIN`, `P|AQP-SCORE|CALLER`, `P|SECURE-CALLER`, `SCR|C>COMBINE-TRIPLET-SCORE-MODEL`, `SCR|C>CONTROL-SCORE`, `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`, `SCR|C>CREATE-BOOST-LINK-SCORE`, `SCR|C>ENABLE-DEB-BOOST-SCORE`, `SCR|C>ISSUE-LIQUIDITY-SCORE`, `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `SCR|C>ISSUE-NF-SET-SCORE-DEFINITION`, `SCR|C>ISSUE-NON-FUNGIBLE-SCORE`, `SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SCORE-FROM-MODEL`, `SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SF-SCORE-DEFINITION`, `SCR|C>ISSUE-SINGLE-SCORE-MODEL`, `SCR|C>ISSUE-TRIPLET`, `SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE`, `SCR|C>ROTATE-OWNERSHIP-SCORE`, `SCR|XE>CREATE-AQPOOL-LINK`, `SCR|XE>CREATE-FVT-LINK`, `SCR|XE>NUKE-SCORE-FOR-VACATE`, `SCR|XE>REFRESH-USER-SCORE-DEB`, `SCR|XE>REVOKE-AQPOOL-LINK`, `SCR|XE>UPDATE-LP-STAKE-DPTF-LP`, `SCR|XE>UPDATE-LP-STAKE-ORTO-LP`, `SCR|XE>UPDATE-STAKE-DPNF`, `SCR|XE>UPDATE-STAKE-DPOF`, `SCR|XE>UPDATE-STAKE-DPOF-SPECIAL`, `SCR|XE>UPDATE-STAKE-DPSF`, `SCR|XE>UPDATE-STAKE-DPTF`, `SCR|XI>ISSUE-SCORE`, `SCR|XI>X_ISSUE-NF-SCORE-DEFINITION`, `SECURE`

**Functions** -- 217, grouped by what the prefix promises

*Cost readers* (13) — price an operation; the exec path and the preview both call these

`URCi_CombineTripletModel`, `URCi_Control`, `URCi_CreateBoostClassLink`, `URCi_CreateBoostLink`, `URCi_EnableDebBoost`, `URCi_IssueNonFungibleScoreDefinition`, `URCi_IssueNonFungibleSetScoreDefinition`, `URCi_IssueScore`, `URCi_IssueScoreModel`, `URCi_IssueScoreStoa`, `URCi_IssueSemiFungibleScoreDefinition`, `URCi_IssueTriplet`, `URCi_RotateOwnership`

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_SCR|AllScoreIds`

*Derived reads* (21) — read and compute; no enforce

`URC_IsTrueTriplet`, `URC_LpAmountToLpDenominatorEquivalent`, `URC_NFTraitKeysList`, `URC_OrtoDpofIsSpecialLeg`, `URC_OrtoDpofUsesSleepingMultiplier`, `URC_ScoreEntityModelExists`, `URC_SignedBaseDeltaForDpnfStake`, `URC_SignedBaseDeltaForDpofStake`, `URC_SignedBaseDeltaForDpsfStake`, `URC_SignedBaseDeltaForDptfLpStake`, `URC_SignedBaseDeltaForDptfStake`, `URC_SignedBaseDeltaForOrtoLpStake`, `URC_SignedBaseDeltaForSpecialDpofStake`, `URC_SingularUserScoreDeltaFromSignedUserBase`, `URC_StakeLpTokenToNativeLpDptf`, `URC_StakeScoreDeltaIgnisCumulator`, `URC_StakeScoreDeltaIgnisUnit`, `URC_TripletCategoryForClass`, `URC_TripletCategoryMatchesFvtClass`, `URC_TripletExists`, `URC_U-SCR|UserScoreDebStale`

*Point reads* (72) — one row or field by key

`P|UR_IMP`, `UR_N-DEF-REV|NFDefRevision`, `UR_N-DEF-REV|NFDefRevisionClassRevisionNonce`, `UR_N-DEF-REV|NFDefRevisionDpnfId`, `UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce`, `UR_N-DEF-REV|NFDefRevisionScoreId`, `UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce`, `UR_N-DEF|NFClassScore`, `UR_N-DEF|NFClassScoreDpnfId`, `UR_N-DEF|NFClassScoreNonceClass`, `UR_N-DEF|NFClassScoreScoreId`, `UR_N-DEF|NFClassScoreTraitScoreValue`, `UR_N-DEF|NFTraitScore`, `UR_N-DEF|NFTraitScoreDpnfId`, `UR_N-DEF|NFTraitScoreScoreId`, `UR_N-DEF|NFTraitScoreTraitKey`, `UR_N-DEF|NFTraitScoreTraitScoreValue`, `UR_N-DEF|NFTraitScoreTraitValue`, `UR_S-DEF-REV|SFDefRevision`, `UR_S-DEF-REV|SFDefRevisionDpsfId`, `UR_S-DEF-REV|SFDefRevisionRevisionNonce`, `UR_S-DEF-REV|SFDefRevisionScoreId`, `UR_S-DEF|SFScore`, `UR_S-DEF|SFScoreDpsfId`, `UR_S-DEF|SFScoreNonce`, `UR_S-DEF|SFScoreNonceScoreValue`, `UR_S-DEF|SFScoreScoreId`, `UR_SCR|ModelEntityType`, `UR_SCR|Score`, `UR_SCR|ScoreAqpoolLink`, `UR_SCR|ScoreBoostClassLink`, `UR_SCR|ScoreBoostLink`, `UR_SCR|ScoreCanChangeOwner`, `UR_SCR|ScoreCanUpgrade`, `UR_SCR|ScoreClass`, `UR_SCR|ScoreDebBoost`, `UR_SCR|ScoreEntityModel`, `UR_SCR|ScoreFvtLink`, `UR_SCR|ScoreLpDenominator`, `UR_SCR|ScoreMxFrozen`, `UR_SCR|ScoreMxHibernated`, `UR_SCR|ScoreMxSleeping`, `UR_SCR|ScoreNftScoreModel`, `UR_SCR|ScoreNzsCount`, `UR_SCR|ScoreOwnerKonto`, `UR_SCR|ScorePrecision`, `UR_SCR|ScoreScoreId`, `UR_SCR|ScoreSftEquality`, `UR_SCR|ScoreTotalBaseDebScore`, `UR_SCR|ScoreTotalBaseScore`, `UR_SCR|ScoreTotalBoostedDebScore`, `UR_SCR|ScoreTotalBoostedScore`, `UR_SCR|ScoreTotalDebScore`, `UR_SCR|ScoreTriplet`, `UR_SCR|ScoreTripletId`, `UR_SCR|ScoreVacateGeneration`, `UR_SCR|Triplet`, `UR_SCR|TripletBronzeScoreId`, `UR_SCR|TripletCategory`, `UR_SCR|TripletGoldenScoreId`, `UR_SCR|TripletId`, `UR_SCR|TripletSilverScoreId`, `UR_SCR|TripletTrueTriplet`, `UR_U-SCR|UserScore`, `UR_U-SCR|UserScoreBaseDebScore`, `UR_U-SCR|UserScoreBaseScore`, `UR_U-SCR|UserScoreBoostedDebScore`, `UR_U-SCR|UserScoreBoostedScore`, `UR_U-SCR|UserScoreDebScore`, `UR_U-SCR|UserScoreOuronetAccount`, `UR_U-SCR|UserScorePoolId`, `UR_U-SCR|UserScoreScoreId`

*Validators* (11) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_DpnfStakeScoreContext`, `UEV_DpofStakeScoreContext`, `UEV_DpsfStakeScoreContext`, `UEV_DptfStakeScoreContext`, `UEV_ExecutorIzScoreOwner`, `UEV_IzNonFungibleScoreDefinitionTraitBranch`, `UEV_LpStakeScoreContext`, `UEV_NonFungibleScoreDefinition`, `UEV_NonFungibleScoreDefinitionSet`, `UEV_NonFungibleScoreDefinitionTrait`

*Constructors* (10) — build objects

`UDC_SCR|NF|ClassSchema`, `UDC_SCR|NF|DefRevision`, `UDC_SCR|NF|TraitSchema`, `UDC_SCR|SF|DefRevision`, `UDC_SCR|SF|Schema`, `UDC_SCR|Schema`, `UDC_SCR|ScoreEntityModel`, `UDC_SCR|SingularUserScoreDelta`, `UDC_SCR|Triplet`, `UDC_SCR|UserSchema`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_ComputeTripletId`

*Client entry* (17) — builds the bill; reachable only through Talos

`C_CombineTripletScoreModel`, `C_Control`, `C_CreateBoostClassLink`, `C_CreateBoostLink`, `C_EnableDebBoost`, `C_IssueLiquidityScore`, `C_IssueNonFungibleScore`, `C_IssueNonFungibleScoreDefinition`, `C_IssueNonFungibleSetScoreDefinition`, `C_IssueOrtoFungibleScore`, `C_IssueScoreFromModel`, `C_IssueSemiFungibleScore`, `C_IssueSemiFungibleScoreDefinition`, `C_IssueSingleScoreModel`, `C_IssueTriplet`, `C_IssueTrueFungibleScore`, `C_RotateOwnership`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (8) — callable by other modules only

`XE_ApplyCollectableStakeDelta`, `XE_ApplyOrtoFungibleStakeDelta`, `XE_ApplyTrueFungibleStakeDelta`, `XE_CreateAqpoolLink`, `XE_CreateFvtLink`, `XE_NukeScoreForVacate`, `XE_RefreshUserScoreDeb`, `XE_RevokeAqpoolLink`

*Internal writes* (18) — this module only; writes under a capability

`XI_1|UpdateScoreDataForNonFungible`, `XI_1|UpdateScoreDataForOrtoFungible`, `XI_1|UpdateScoreDataForOrtoFungibleLP`, `XI_1|UpdateScoreDataForSemiFungible`, `XI_1|UpdateScoreDataForSpecialOrtoFungible`, `XI_1|UpdateScoreDataForTrueFungible`, `XI_1|UpdateScoreDataForTrueFungibleLP`, `XI_2|ApplySingularUserScoreDelta`, `XI_Control`, `XI_CreateBoostClassLink`, `XI_CreateBoostLink`, `XI_EnableDebBoost`, `XI_Issue`, `XI_IssueNonFungibleScoreDefinitionCore`, `XI_IssueOneFromModel`, `XI_IssueSemiFungibleScoreDefinition`, `XI_IssueTriplet`, `XI_RotateOwnership`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (37) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `UCk_NFClassScore`, `UCk_NFDefRevision`, `UCk_NFScore`, `UCk_NFTraitKeys`, `UCk_NFTraitScore`, `UCk_SFDefRevision`, `UCk_SFScore`, `UCk_Triplet`, `UCk_UserScore`, `UCx_StakeEqualNativeUnitRawWeight`, `URCx_DpnfModelOneScrDefinitionRawWeight`, `URCx_DpnfModelZeroDpdcNativeRawWeight`, `URCx_SfStakeDefinitionWeightedRawWeight`, `WI_Score`, `WI_ScoreEntityModel`, `WI_Triplet`, `WU2_Score|Control`, `WU2_Score|TripletMembership`, `WU3_Score|VaultTotals`, `WU_Score|AqpoolLink`, `WU_Score|BoostClassLink`, `WU_Score|BoostLink`, `WU_Score|DebBoost`, `WU_Score|FvtLink`, `WU_Score|Nuke`, `WU_Score|NzsCount`, `WU_Score|OwnerKonto`, `WW_NFClassScore`, `WW_NFDefRevision`, `WW_NFTraitKeys`, `WW_NFTraitScore`, `WW_SFDefRevision`, `WW_SFScore`, `WW_UserScore`
<!-- @end:module-page:AQP-SCORE -->

## Traps

_To be written._
