# AQP-FVT — farms, vaults and treasuries

## What it is for

The reward distributor. One field selects which of three it is, and the difference is structural: a **farm** has two-level accounting, splitting first across member pools by weight and then across each pool's stakers; a **vault** or **treasury** has one index.

The two levels exist because a farm's members are pools of different sizes, and splitting by size first is the only way a large pool does not swallow a small one.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

Above the reward engine, which it drives through external entry points.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-FVT -->
**On chain**

| | |
|---|---|
| module hash | `Z3R291CrNeLTi0_Zn3UrkicpHR3zE2VT2Z0UXiaJaV8` |
| deployed size | 189,257 characters |
| implements | `OuronetPolicyV2`, `AcquisitionFarmsVaultsTreasuriesV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact` |

**Tables it owns** — 5

`FVT|T`, `FVT|T|SweepProgress`, `FVT|T|VacateFreeze`, `P|MT`, `P|T`

**Capabilities** — 30

`FVT|C>ADD-REWARD-LINK`, `FVT|C>ADD-SCORE-ENTITY`, `FVT|C>COLLECT`, `FVT|C>COLLECTABLE-STAKE-FLOW`, `FVT|C>CONTROL-FVT`, `FVT|C>INJECT`, `FVT|C>INJECT-FIX`, `FVT|C>INJECT-STREAM`, `FVT|C>ISSUE-FVT`, `FVT|C>ISSUE-MULTIPLET-FAMILY`, `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW`, `FVT|C>ROTATE-OWNERSHIP-FVT`, `FVT|C>SET-COMMON-DENOMINATOR`, `FVT|C>SET-MOSAIC`, `FVT|C>SET-QUALITY-SPLIT`, `FVT|C>SET-SPLIT-MODE`, `FVT|C>SWEEP-DRAIN`, `FVT|C>SWEEP-REVOKE`, `FVT|C>TOGGLE-REWARD-LINK`, `FVT|C>TOGGLE-SCORE-ENTITY-LINK`, `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`, `FVT|C>UNSTALE-ALL`, `FVT|C>UNSTALE-MY-SCORES`, `FVT|XE>SWEEP-BRACKET`, `GOV`, `GOV|FVT_ADMIN`, `P|FVT|CALLER`, `P|FVT|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 142, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 5 | returns what an operation will charge | `URCi_CollectFull`, `URCi_Issue`, `URCi_IssueMultipletFamily`, `URCi_IssueStoa`, `URCi_UnstaleMyScores` |
| `URH_` heavy reads | 3 | a scan -- expensive by construction | `URH_FvtEnabledScoreEntityIdsForFvt`, `URH_FvtPresentUsers`, `URH_FvtStalePresentUsers` |
| `URC_` derived reads | 15 | read and derive; no enforce | `URC_CollectClaimableRewards`, `URC_FvtUserStillPresent`, `URC_InjectDenominator`, `URC_LiveClaimable`, `URC_MaxStreamLanes`, `URC_MemberEffectiveCapture` …+9 |
| `UEV_` validators | 10 | read and enforce; may abort the transaction | `UEV_AddScoreEntityContext`, `UEV_AddScoreEntityScoreContext`, `UEV_AddScoreEntityTripletContext`, `UEV_CollectContext`, `UEV_ExecutorIzFvtOwner`, `UEV_InjectContext` …+4 |
| `UCk_` pure compute (key) | 4 | builds a composite table key | `UCk_RpsGlobal`, `UCk_RpsMember`, `UCk_RpsUser`, `UCk_ScoreEntityLink` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_EmptyOc` |
| `UR_` readers | 2 | table reads; no enforce, no writes | `UR_ExternalOracle`, `UR_OracleValidity` |
| `WI_` writers (insert) | 1 | one write site each | `WI_Fvt` |
| `WU_` writers (update) | 2 | one write site each | `WU_FvtSweepProgress`, `WU_FvtVacateFreeze` |
| `XI_` protected (internal) | 5 | this module only | `XI_Control`, `XI_IssueFvt`, `XI_RefreshCollectableStakeAnchors`, `XI_RefreshTrueFungibleStakeAnchors`, `XI_SetCommonDenominator` |
| `XE_` protected (external) | 6 | for other modules; opens with the IMC gate | `XE_RefreshCollectableStakeAnchors`, `XE_RefreshTrueFungibleStakeAnchors`, `XE_SetFvtOracleOn`, `XE_SetFvtVacateFrozen`, `XE_SweepBegin`, `XE_SweepEnd` |
| `XB_` protected (both) | 1 | internal and external | `XB_FvtInject` |
| `CCp_` client recipe (heavy) | 3 | multi-transaction, reaches a scan | `CCp_InjectFixChunk`, `CCp_SweepRecomputeChunk`, `CCp_UnstaleAll` |
| `CC_` client (heavy) | 10 | client entrypoint; reaches a scan | `CC_Collect`, `CC_CollectableStakeFlow`, `CC_Inject`, `CC_InjectFinalize`, `CC_InjectStream`, `CC_OrtoFungibleStakeFlow` …+4 |
| `C_` client | 12 | reached via Talos, never called directly | `C_AddRewardLink`, `C_AddScoreEntity`, `C_Control`, `C_Issue`, `C_IssueMultipletFamily`, `C_RotateOwnership` …+6 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 53 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `GOV|Demiurgoi`, `UDC_FVT|RewardAggregate`, `UDC_FVT|Schema`, `UR_FVT-FFC|Count` …+47 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **capabilities** in the repository only: `FVT|C>CLEAR-POOL-SWEEP`, `FVT|C>REASSIGN-CUSTODIAL-BENEFICIARY`, `FVT|C>RELEASE-SPECIAL-CUSTODIAL`
> - **functions** in the repository only: `CC_ClearPoolSweep`, `CCp_FvtFixSlice`, `CCp_ReassignCustodialBeneficiary`, `CCp_ReleaseSpecialCustodial`, `CCp_StakeSpecialCustodial`, `REPL_BootstrapTreasury`, `REPL_BootstrapVault`, `UEV_FVT|PoolReleasable`

**Capabilities** -- 30

`FVT|C>ADD-REWARD-LINK`, `FVT|C>ADD-SCORE-ENTITY`, `FVT|C>COLLECT`, `FVT|C>COLLECTABLE-STAKE-FLOW`, `FVT|C>CONTROL-FVT`, `FVT|C>INJECT`, `FVT|C>INJECT-FIX`, `FVT|C>INJECT-STREAM`, `FVT|C>ISSUE-FVT`, `FVT|C>ISSUE-MULTIPLET-FAMILY`, `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW`, `FVT|C>ROTATE-OWNERSHIP-FVT`, `FVT|C>SET-COMMON-DENOMINATOR`, `FVT|C>SET-MOSAIC`, `FVT|C>SET-QUALITY-SPLIT`, `FVT|C>SET-SPLIT-MODE`, `FVT|C>SWEEP-DRAIN`, `FVT|C>SWEEP-REVOKE`, `FVT|C>TOGGLE-REWARD-LINK`, `FVT|C>TOGGLE-SCORE-ENTITY-LINK`, `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`, `FVT|C>UNSTALE-ALL`, `FVT|C>UNSTALE-MY-SCORES`, `FVT|XE>SWEEP-BRACKET`, `GOV`, `GOV|FVT_ADMIN`, `P|FVT|CALLER`, `P|FVT|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 142, grouped by what the prefix promises

*Cost readers* (5) — price an operation; the exec path and the preview both call these

`URCi_CollectFull`, `URCi_Issue`, `URCi_IssueMultipletFamily`, `URCi_IssueStoa`, `URCi_UnstaleMyScores`

*Heavy reads* (3) — scan a table -- OFF the execution path, cost grows with data

`URH_FvtEnabledScoreEntityIdsForFvt`, `URH_FvtPresentUsers`, `URH_FvtStalePresentUsers`

*Derived reads* (15) — read and compute; no enforce

`URC_CollectClaimableRewards`, `URC_FvtUserStillPresent`, `URC_InjectDenominator`, `URC_LiveClaimable`, `URC_MaxStreamLanes`, `URC_MemberEffectiveCapture`, `URC_MemberLevel2Weight`, `URC_PoolEmployedScoresFvtStakeReady`, `URC_ResolvePoolScoreId`, `URC_ResolveScoreEntitySwpair`, `URC_ScoreClassMatchesFvtClass`, `URC_ScoreEntityUserWeight`, `URC_StakeScoreDeltaSum`, `URC_StreamStatus`, `URC_UserTier1AvailableRewards`

*Point reads* (48) — one row or field by key

`P|UR_IMP`, `UR_ExternalOracle`, `UR_FVT-FFC|Count`, `UR_FVT-MV|AvailableRewards`, `UR_FVT-QS|BronzeSplit`, `UR_FVT-QS|GoldSplit`, `UR_FVT-QS|Mode`, `UR_FVT-RG|AvailableRewards`, `UR_FVT-RG|CurrentRps`, `UR_FVT-RG|RewardEnabled`, `UR_FVT-RG|RewardKind`, `UR_FVT-RG|RoyaltyRewards`, `UR_FVT-RG|StreamCount`, `UR_FVT-RG|StreamUnreleased`, `UR_FVT-RG|UnclaimedCount`, `UR_FVT-RG|ZombieRewards`, `UR_FVT-RM|LastFarmRpsG`, `UR_FVT-RM|MemberDebRps`, `UR_FVT-RU|LastRps`, `UR_FVT-RU|PendingRewards`, `UR_FVT-SEL|CaptureUnits`, `UR_FVT-SEL|CaptureWeight`, `UR_FVT-SEL|Delegation`, `UR_FVT-SEL|Enabled`, `UR_FVT-SEL|GhostTvlWeight`, `UR_FVT-SEL|OracleTs`, `UR_FVT-SEL|ScoreEntityType`, `UR_FVT-SEL|Swpair`, `UR_FVT-SEL|TotalLaneWeight`, `UR_FVT-UP|IsPresent`, `UR_FVT|CanChangeOwner`, `UR_FVT|CanUpgrade`, `UR_FVT|CommonDenominator`, `UR_FVT|EnabledRewardCount`, `UR_FVT|Fvt`, `UR_FVT|FvtClass`, `UR_FVT|FvtId`, `UR_FVT|MembershipMode`, `UR_FVT|Mosaic`, `UR_FVT|OracleOn`, `UR_FVT|OwnerKonto`, `UR_FVT|SplitMode`, `UR_FVT|SweepActive`, `UR_FVT|SweepProgress`, `UR_FVT|TotalDebScore`, `UR_FVT|TotalGhostTvlWeight`, `UR_FVT|VacateFrozen`, `UR_OracleValidity`

*Validators* (11) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AddScoreEntityContext`, `UEV_AddScoreEntityScoreContext`, `UEV_AddScoreEntityTripletContext`, `UEV_CollectContext`, `UEV_ExecutorIzFvtOwner`, `UEV_InjectContext`, `UEV_IssueMultipletFamilyContext`, `UEV_SetCommonDenominatorContext`, `UEV_SetMosaicContext`, `UEV_StreamParams`

*Constructors* (2) — build objects

`UDC_FVT|RewardAggregate`, `UDC_FVT|Schema`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_EmptyOc`

*Heavy recipes* (3) — multi-transaction, reaches a heavy read

`CCp_InjectFixChunk`, `CCp_SweepRecomputeChunk`, `CCp_UnstaleAll`

*Client entry (heavy)* (10) — reaches a heavy read somewhere in its tree

`CC_Collect`, `CC_CollectableStakeFlow`, `CC_Inject`, `CC_InjectFinalize`, `CC_InjectStream`, `CC_OrtoFungibleStakeFlow`, `CC_SweepBegin`, `CC_SweepRevokeAnchor`, `CC_TrueFungibleStakeFlow`, `CC_UnstaleMyScores`

*Client entry* (12) — builds the bill; reachable only through Talos

`C_AddRewardLink`, `C_AddScoreEntity`, `C_Control`, `C_Issue`, `C_IssueMultipletFamily`, `C_RotateOwnership`, `C_SetCommonDenominator`, `C_SetMosaic`, `C_SetQualitySplit`, `C_SetSplitMode`, `C_ToggleRewardLink`, `C_ToggleScoreEntityLink`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (6) — callable by other modules only

`XE_RefreshCollectableStakeAnchors`, `XE_RefreshTrueFungibleStakeAnchors`, `XE_SetFvtOracleOn`, `XE_SetFvtVacateFrozen`, `XE_SweepBegin`, `XE_SweepEnd`

*Internal + external* (1) — callable both ways

`XB_FvtInject`

*Internal writes* (5) — this module only; writes under a capability

`XI_Control`, `XI_IssueFvt`, `XI_RefreshCollectableStakeAnchors`, `XI_RefreshTrueFungibleStakeAnchors`, `XI_SetCommonDenominator`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (12) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`, `UCk_RpsGlobal`, `UCk_RpsMember`, `UCk_RpsUser`, `UCk_ScoreEntityLink`, `WI_Fvt`, `WU2_Fvt|Control`, `WU_FvtSweepProgress`, `WU_FvtVacateFreeze`, `WU_Fvt|CommonDenominator`, `WU_Fvt|OracleOn`
<!-- @end:module-page:AQP-FVT -->

## Traps

**The admission rule from score class to distributor class was inverted** — collectables went to the vault, orto-fungibles to the treasury. The reason nobody noticed is the instructive part: *the bootstrap issued its four entities NAMED Treasury at class 1, so the broken rule was exactly what let them work.* A fixture built to match the bug confirms the bug.

**A farm's denominator is computed fresh at injection** and cannot be cached, because the value is base-dependent and the cached copy is stale by construction.

**Streams are capped per owner by account tier**, up to 49.
