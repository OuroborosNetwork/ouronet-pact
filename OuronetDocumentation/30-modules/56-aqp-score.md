# AQP-SCORE — scoring

## What it is for

The weighting rules. A score turns a stake into a number through three steps — base, boost, then the account's tier — and `deb` is what the reward model multiplies.

The boost is **additive, not a replacement**: the base is never dropped.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

Between the pools and the reward distributor.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-SCORE -->
**On chain**

| | |
|---|---|
| module hash | `RmDjpkZMHpkHobZLZFoFhPZgGe88E-bKLQG2I95gTsk` |
| deployed size | 295,523 characters |
| implements | `OuronetPolicyV2`, `AcquisitionScoresV5` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact` |

**Tables it owns** — 13

`P|MT`, `P|T`, `SCR|T|NF|ClassScore`, `SCR|T|NF|DefRevision`, `SCR|T|NF|TraitKeys`, `SCR|T|NF|TraitScore`, `SCR|T|SF|DefRevision`, `SCR|T|SF|Score`, `SCR|T|Score`, `SCR|T|ScoreEntityModel`, `SCR|T|SleepStake`, `SCR|T|Triplet`, `SCR|T|UserScore`

**Schemas** — 1

`SCR|SleepStake`

**Capabilities** — 40

`GOV`, `GOV|AQP-SCORE_ADMIN`, `P|AQP-SCORE|CALLER`, `P|SECURE-CALLER`, `SCR|C>COMBINE-TRIPLET-SCORE-MODEL`, `SCR|C>CONTROL-SCORE`, `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`, `SCR|C>CREATE-BOOST-LINK-SCORE`, `SCR|C>ENABLE-DEB-BOOST-SCORE`, `SCR|C>ISSUE-LIQUIDITY-SCORE`, `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `SCR|C>ISSUE-NF-SET-SCORE-DEFINITION`, `SCR|C>ISSUE-NON-FUNGIBLE-SCORE`, `SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SCORE-FROM-MODEL`, `SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SF-SCORE-DEFINITION`, `SCR|C>ISSUE-SINGLE-SCORE-MODEL`, `SCR|C>ISSUE-TRIPLET`, `SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE`, `SCR|C>LOCK-SCORE-DRIFT`, `SCR|C>ROTATE-OWNERSHIP-SCORE`, `SCR|C>UPDATE-MULTIPLIERS`, `SCR|XE>APPLY-RAW-BASE-DELTA`, `SCR|XE>CREATE-AQPOOL-LINK`, `SCR|XE>CREATE-FVT-LINK`, `SCR|XE>DRAIN-BASE`, `SCR|XE>NUKE-SCORE-FOR-VACATE`, `SCR|XE>REFRESH-USER-SCORE-DEB`, `SCR|XE>REVOKE-AQPOOL-LINK`, `SCR|XE>UPDATE-LP-STAKE-DPTF-LP`, `SCR|XE>UPDATE-LP-STAKE-ORTO-LP`, `SCR|XE>UPDATE-STAKE-DPNF`, `SCR|XE>UPDATE-STAKE-DPOF`, `SCR|XE>UPDATE-STAKE-DPOF-SPECIAL`, `SCR|XE>UPDATE-STAKE-DPSF`, `SCR|XE>UPDATE-STAKE-DPTF`, `SCR|XI>ISSUE-SCORE`, `SCR|XI>X_ISSUE-NF-SCORE-DEFINITION`, `SECURE`

**Functions** — 254, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 14 | returns what an operation will charge | `URCi_CombineTripletModel`, `URCi_Control`, `URCi_CreateBoostClassLink`, `URCi_CreateBoostLink`, `URCi_EnableDebBoost`, `URCi_IssueNonFungibleScoreDefinition` …+8 |
| `URC_` derived reads | 21 | read and derive; no enforce | `URC_HubsFirstScoreIds`, `URC_IsTrueTriplet`, `URC_LpAmountToLpDenominatorEquivalent`, `URC_NFTraitKeysList`, `URC_OrtoDpofIsSpecialLeg`, `URC_OrtoDpofUsesSleepingMultiplier` …+15 |
| `UEV_` validators | 12 | read and enforce; may abort the transaction | `UEV_DpnfStakeScoreContext`, `UEV_DpofSpecialStakeScoreContext`, `UEV_DpofStakeScoreContext`, `UEV_DpsfStakeScoreContext`, `UEV_DptfStakeScoreContext`, `UEV_ExecutorIzScoreOwner` …+6 |
| `UCx_` pure compute (auxiliary) | 1 | a private helper of the function above it | `UCx_StakeEqualNativeUnitRawWeight` |
| `UCk_` pure compute (key) | 10 | builds a composite table key | `UCk_NFClassScore`, `UCk_NFDefRevision`, `UCk_NFScore`, `UCk_NFTraitKeys`, `UCk_NFTraitScore`, `UCk_SFDefRevision` …+4 |
| `UC_` pure compute | 9 | arguments only -- no reads, no enforce | `UC_ComputeTripletId`, `UC_DecayMonthsRemaining`, `UC_MxAtMonths`, `UC_MxForRemaining`, `UC_MxFrozenFloor`, `UC_MxOrderingOk` …+3 |
| `WI_` writers (insert) | 3 | one write site each | `WI_Score`, `WI_ScoreEntityModel`, `WI_Triplet` |
| `WW_` writers (upsert) | 7 | one write site each | `WW_NFClassScore`, `WW_NFDefRevision`, `WW_NFTraitKeys`, `WW_NFTraitScore`, `WW_SFDefRevision`, `WW_SFScore` …+1 |
| `XI_` protected (internal) | 12 | this module only | `XI_Control`, `XI_CreateBoostClassLink`, `XI_CreateBoostLink`, `XI_EnableDebBoost`, `XI_Issue`, `XI_IssueNonFungibleScoreDefinitionCore` …+6 |
| `XE_` protected (external) | 11 | for other modules; opens with the IMC gate | `XE_ApplyCollectableStakeDelta`, `XE_ApplyOrtoFungibleStakeDelta`, `XE_ApplyRawBaseDelta`, `XE_ApplyTrueFungibleStakeDelta`, `XE_CreateAqpoolLink`, `XE_CreateFvtLink` …+5 |
| `AA_` admin (heavy) | 1 | admin key; reaches a scan somewhere in its tree | `AA_MigrateDriftLocked` |
| `C_` client | 18 | reached via Talos, never called directly | `C_CombineTripletScoreModel`, `C_Control`, `C_CreateBoostClassLink`, `C_CreateBoostLink`, `C_EnableDebBoost`, `C_IssueLiquidityScore` …+12 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 126 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `UDC_SCR|NF|ClassSchema`, `UDC_SCR|NF|DefRevision` …+120 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 40

`GOV`, `GOV|AQP-SCORE_ADMIN`, `P|AQP-SCORE|CALLER`, `P|SECURE-CALLER`, `SCR|C>COMBINE-TRIPLET-SCORE-MODEL`, `SCR|C>CONTROL-SCORE`, `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`, `SCR|C>CREATE-BOOST-LINK-SCORE`, `SCR|C>ENABLE-DEB-BOOST-SCORE`, `SCR|C>ISSUE-LIQUIDITY-SCORE`, `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `SCR|C>ISSUE-NF-SET-SCORE-DEFINITION`, `SCR|C>ISSUE-NON-FUNGIBLE-SCORE`, `SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SCORE-FROM-MODEL`, `SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE`, `SCR|C>ISSUE-SF-SCORE-DEFINITION`, `SCR|C>ISSUE-SINGLE-SCORE-MODEL`, `SCR|C>ISSUE-TRIPLET`, `SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE`, `SCR|C>LOCK-SCORE-DRIFT`, `SCR|C>ROTATE-OWNERSHIP-SCORE`, `SCR|C>UPDATE-MULTIPLIERS`, `SCR|XE>APPLY-RAW-BASE-DELTA`, `SCR|XE>CREATE-AQPOOL-LINK`, `SCR|XE>CREATE-FVT-LINK`, `SCR|XE>DRAIN-BASE`, `SCR|XE>NUKE-SCORE-FOR-VACATE`, `SCR|XE>REFRESH-USER-SCORE-DEB`, `SCR|XE>REVOKE-AQPOOL-LINK`, `SCR|XE>UPDATE-LP-STAKE-DPTF-LP`, `SCR|XE>UPDATE-LP-STAKE-ORTO-LP`, `SCR|XE>UPDATE-STAKE-DPNF`, `SCR|XE>UPDATE-STAKE-DPOF`, `SCR|XE>UPDATE-STAKE-DPOF-SPECIAL`, `SCR|XE>UPDATE-STAKE-DPSF`, `SCR|XE>UPDATE-STAKE-DPTF`, `SCR|XI>ISSUE-SCORE`, `SCR|XI>X_ISSUE-NF-SCORE-DEFINITION`, `SECURE`

**Functions** -- 254, grouped by what the prefix promises

*Cost readers* (14) — price an operation; the exec path and the preview both call these

`URCi_CombineTripletModel`, `URCi_Control`, `URCi_CreateBoostClassLink`, `URCi_CreateBoostLink`, `URCi_EnableDebBoost`, `URCi_IssueNonFungibleScoreDefinition`, `URCi_IssueNonFungibleSetScoreDefinition`, `URCi_IssueScore`, `URCi_IssueScoreModel`, `URCi_IssueScoreStoa`, `URCi_IssueSemiFungibleScoreDefinition`, `URCi_IssueTriplet`, `URCi_LockScoreDrift`, `URCi_RotateOwnership`

*Heavy reads* (8) — scan a table -- OFF the execution path, cost grows with data

`URH_SCR|AllScoreIds`, `URH_SCR|NFClassScoreDefinition`, `URH_SCR|NFTraitScoreDefinition`, `URH_SCR|PoolScoreIdsWithHolders`, `URH_SCR|SFScoreDefinition`, `URH_SCR|ScoreDefinedNonFungibles`, `URH_SCR|ScoreDefinedSemiFungibles`, `URH_SCR|ScoreHolderAccounts`

*Derived reads* (26) — read and compute; no enforce

`URC_HubsFirstScoreIds`, `URC_IsTrueTriplet`, `URC_LpAmountToLpDenominatorEquivalent`, `URC_NFTraitKeysList`, `URC_OrtoDpofIsSpecialLeg`, `URC_OrtoDpofUsesSleepingMultiplier`, `URC_SCR|LiveRemainingTerm`, `URC_SCR|SleepingLegHeldMultiplier`, `URC_SCR|SleepingLegHeldWeight`, `URC_SCR|SleepingLegWeight`, `URC_ScoreEntityModelExists`, `URC_SignedBaseDeltaForDpnfStake`, `URC_SignedBaseDeltaForDpofStake`, `URC_SignedBaseDeltaForDpsfStake`, `URC_SignedBaseDeltaForDptfLpStake`, `URC_SignedBaseDeltaForDptfStake`, `URC_SignedBaseDeltaForOrtoLpStake`, `URC_SignedBaseDeltaForSpecialDpofStake`, `URC_SingularUserScoreDeltaFromSignedUserBase`, `URC_StakeLpTokenToNativeLpDptf`, `URC_StakeScoreDeltaIgnisCumulator`, `URC_StakeScoreDeltaIgnisUnit`, `URC_TripletCategoryForClass`, `URC_TripletCategoryMatchesFvtClass`, `URC_TripletExists`, `URC_U-SCR|UserScoreDebStale`

*Point reads* (74) — one row or field by key

`P|UR_IMP`, `UR_N-DEF-REV|NFDefRevision`, `UR_N-DEF-REV|NFDefRevisionClassRevisionNonce`, `UR_N-DEF-REV|NFDefRevisionDpnfId`, `UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce`, `UR_N-DEF-REV|NFDefRevisionScoreId`, `UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce`, `UR_N-DEF|NFClassScore`, `UR_N-DEF|NFClassScoreDpnfId`, `UR_N-DEF|NFClassScoreNonceClass`, `UR_N-DEF|NFClassScoreScoreId`, `UR_N-DEF|NFClassScoreTraitScoreValue`, `UR_N-DEF|NFTraitScore`, `UR_N-DEF|NFTraitScoreDpnfId`, `UR_N-DEF|NFTraitScoreScoreId`, `UR_N-DEF|NFTraitScoreTraitKey`, `UR_N-DEF|NFTraitScoreTraitScoreValue`, `UR_N-DEF|NFTraitScoreTraitValue`, `UR_S-DEF-REV|SFDefRevision`, `UR_S-DEF-REV|SFDefRevisionDpsfId`, `UR_S-DEF-REV|SFDefRevisionRevisionNonce`, `UR_S-DEF-REV|SFDefRevisionScoreId`, `UR_S-DEF|SFScore`, `UR_S-DEF|SFScoreDpsfId`, `UR_S-DEF|SFScoreNonce`, `UR_S-DEF|SFScoreNonceScoreValue`, `UR_S-DEF|SFScoreScoreId`, `UR_SCR|ModelEntityType`, `UR_SCR|Score`, `UR_SCR|ScoreAqpoolLink`, `UR_SCR|ScoreBoostClassLink`, `UR_SCR|ScoreBoostLink`, `UR_SCR|ScoreCanChangeOwner`, `UR_SCR|ScoreCanUpgrade`, `UR_SCR|ScoreClass`, `UR_SCR|ScoreDebBoost`, `UR_SCR|ScoreDriftLocked`, `UR_SCR|ScoreEntityModel`, `UR_SCR|ScoreFvtLink`, `UR_SCR|ScoreLpDenominator`, `UR_SCR|ScoreMxFrozen`, `UR_SCR|ScoreMxHibernated`, `UR_SCR|ScoreMxSleeping`, `UR_SCR|ScoreNftScoreModel`, `UR_SCR|ScoreNzsCount`, `UR_SCR|ScoreOwnerKonto`, `UR_SCR|ScorePrecision`, `UR_SCR|ScoreScoreId`, `UR_SCR|ScoreSftEquality`, `UR_SCR|ScoreTotalBaseDebScore`, `UR_SCR|ScoreTotalBaseScore`, `UR_SCR|ScoreTotalBoostedDebScore`, `UR_SCR|ScoreTotalBoostedScore`, `UR_SCR|ScoreTotalDebScore`, `UR_SCR|ScoreTriplet`, `UR_SCR|ScoreTripletId`, `UR_SCR|ScoreVacateGeneration`, `UR_SCR|SleepRemainingAtStake`, `UR_SCR|Triplet`, `UR_SCR|TripletBronzeScoreId`, `UR_SCR|TripletCategory`, `UR_SCR|TripletGoldenScoreId`, `UR_SCR|TripletId`, `UR_SCR|TripletSilverScoreId`, `UR_SCR|TripletTrueTriplet`, `UR_U-SCR|UserScore`, `UR_U-SCR|UserScoreBaseDebScore`, `UR_U-SCR|UserScoreBaseScore`, `UR_U-SCR|UserScoreBoostedDebScore`, `UR_U-SCR|UserScoreBoostedScore`, `UR_U-SCR|UserScoreDebScore`, `UR_U-SCR|UserScoreOuronetAccount`, `UR_U-SCR|UserScorePoolId`, `UR_U-SCR|UserScoreScoreId`

*Validators* (13) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_DpnfStakeScoreContext`, `UEV_DpofSpecialStakeScoreContext`, `UEV_DpofStakeScoreContext`, `UEV_DpsfStakeScoreContext`, `UEV_DptfStakeScoreContext`, `UEV_ExecutorIzScoreOwner`, `UEV_IzNonFungibleScoreDefinitionTraitBranch`, `UEV_LpStakeScoreContext`, `UEV_NonFungibleScoreDefinition`, `UEV_NonFungibleScoreDefinitionSet`, `UEV_NonFungibleScoreDefinitionTrait`, `UEV_SemiFungibleScoreDefinition`

*Constructors* (10) — build objects

`UDC_SCR|NF|ClassSchema`, `UDC_SCR|NF|DefRevision`, `UDC_SCR|NF|TraitSchema`, `UDC_SCR|SF|DefRevision`, `UDC_SCR|SF|Schema`, `UDC_SCR|Schema`, `UDC_SCR|ScoreEntityModel`, `UDC_SCR|SingularUserScoreDelta`, `UDC_SCR|Triplet`, `UDC_SCR|UserSchema`

*Pure compute* (9) — arguments only; no reads, no enforce

`UC_ComputeTripletId`, `UC_DecayMonthsRemaining`, `UC_MxAtMonths`, `UC_MxForRemaining`, `UC_MxFrozenFloor`, `UC_MxOrderingOk`, `UC_MxSleepIntervalOk`, `UC_SleepMonthsRemaining`, `UC_SleepMxAtMonths`

*Client entry* (18) — builds the bill; reachable only through Talos

`C_CombineTripletScoreModel`, `C_Control`, `C_CreateBoostClassLink`, `C_CreateBoostLink`, `C_EnableDebBoost`, `C_IssueLiquidityScore`, `C_IssueNonFungibleScore`, `C_IssueNonFungibleScoreDefinition`, `C_IssueNonFungibleSetScoreDefinition`, `C_IssueOrtoFungibleScore`, `C_IssueScoreFromModel`, `C_IssueSemiFungibleScore`, `C_IssueSemiFungibleScoreDefinition`, `C_IssueSingleScoreModel`, `C_IssueTriplet`, `C_IssueTrueFungibleScore`, `C_LockScoreDrift`, `C_RotateOwnership`

*Admin (heavy)* (1) — admin mutation reaching a heavy read

`AA_MigrateDriftLocked`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (11) — callable by other modules only

`XE_ApplyCollectableStakeDelta`, `XE_ApplyOrtoFungibleStakeDelta`, `XE_ApplyRawBaseDelta`, `XE_ApplyTrueFungibleStakeDelta`, `XE_CreateAqpoolLink`, `XE_CreateFvtLink`, `XE_DrainBase`, `XE_NukeScoreForVacate`, `XE_RefreshUserScoreDeb`, `XE_RevokeAqpoolLink`, `XE_SetScoreMultipliers`

*Internal writes* (20) — this module only; writes under a capability

`XI_1|UpdateScoreDataForNonFungible`, `XI_1|UpdateScoreDataForOrtoFungible`, `XI_1|UpdateScoreDataForOrtoFungibleLP`, `XI_1|UpdateScoreDataForSemiFungible`, `XI_1|UpdateScoreDataForSpecialOrtoFungible`, `XI_1|UpdateScoreDataForTrueFungible`, `XI_1|UpdateScoreDataForTrueFungibleLP`, `XI_2|ApplySingularUserScoreDelta`, `XI_Control`, `XI_CreateBoostClassLink`, `XI_CreateBoostLink`, `XI_EnableDebBoost`, `XI_Issue`, `XI_IssueNonFungibleScoreDefinitionCore`, `XI_IssueOneFromModel`, `XI_IssueSemiFungibleScoreDefinition`, `XI_IssueTriplet`, `XI_LockScoreDrift`, `XI_RotateOwnership`, `XI_SleepStakeRecord`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (42) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`, `CT_EmptyCumulator`, `UCk_NFClassScore`, `UCk_NFDefRevision`, `UCk_NFScore`, `UCk_NFTraitKeys`, `UCk_NFTraitScore`, `UCk_SFDefRevision`, `UCk_SFScore`, `UCk_SleepStake`, `UCk_Triplet`, `UCk_UserScore`, `UCx_StakeEqualNativeUnitRawWeight`, `URCx_DpnfModelOneScrDefinitionRawWeight`, `URCx_DpnfModelZeroDpdcNativeRawWeight`, `URCx_EquityShareRawWeight`, `URCx_SfStakeDefinitionWeightedRawWeight`, `WI_Score`, `WI_ScoreEntityModel`, `WI_Triplet`, `WU2_Score|Control`, `WU2_Score|TripletMembership`, `WU3_Score|VaultTotals`, `WU_Score|AqpoolLink`, `WU_Score|BoostClassLink`, `WU_Score|BoostLink`, `WU_Score|DebBoost`, `WU_Score|DriftLocked`, `WU_Score|FvtLink`, `WU_Score|Multipliers`, `WU_Score|Nuke`, `WU_Score|NzsCount`, `WU_Score|OwnerKonto`, `WU_Score|SleepStake`, `WW_NFClassScore`, `WW_NFDefRevision`, `WW_NFTraitKeys`, `WW_NFTraitScore`, `WW_SFDefRevision`, `WW_SFScore`, `WW_UserScore`
<!-- @end:module-page:AQP-SCORE -->

## Traps

**The multipliers are immutable once positions exist.** Changing one would leave every existing row wrong; the migration path is a *new* score, not an edit.

**The frozen multiplier defaults to 2.0** against 1.0 for sleeping and hibernated. The economics follow the lock: frozen has no exit at all.

**A score may take its base from another score**, and then stores zero for its own base — the canonical value lives on the linked one. Summing base, boosted and deb across linked entities does **not** reconstruct a total; they are views, not addends.

**The base is the stable staked amount, not its market value**, so a full unstake reverses exactly and nets to zero. Valuation happens later and is never stored here.
