# AQP-INFO — acquisition previews

## What it is for

Operation previews for the acquisition family — what an operation will do and cost, before anything is signed.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

A leaf read-only module deployed after everything it describes. It has no interface, because nothing reaches it by reference.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-INFO -->
**On chain**

| | |
|---|---|
| module hash | `vENJazSL5VTJaynu7DJ39sNZHn7YzQG0Ci48_eqOsv0` |
| deployed size | 88,149 characters |
| implements | — |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact` |

**Capabilities** — 2

`GOV`, `GOV|INFO|AQP_ADMIN`

**Functions** — 86, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 86 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `INFO_AQP-ANK|IssueNonFungibleAnchor`, `INFO_AQP-ANK|IssueNonFungibleSetAnchor`, `INFO_AQP-ANK|IssueSemiFungibleAnchor`, `INFO_AQP-ANK|IssueTrueFungibleAnchor` …+80 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|INFO|AQP_ADMIN`

**Functions** -- 86, grouped by what the prefix promises

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Previews* (84) — operation previews for clients

`INFO_AQP-ANK|IssueNonFungibleAnchor`, `INFO_AQP-ANK|IssueNonFungibleSetAnchor`, `INFO_AQP-ANK|IssueSemiFungibleAnchor`, `INFO_AQP-ANK|IssueTrueFungibleAnchor`, `INFO_AQP-ANK|RevokeAnchor`, `INFO_AQP-ANK|RevokeBoostClass`, `INFO_AQP-DSA|BurnRoyalty`, `INFO_AQP-DSA|DefineDelegationVault`, `INFO_AQP-DSA|FuelRoyalty`, `INFO_AQP-DSA|OpenAgency`, `INFO_AQP-DSA|OracleWrite`, `INFO_AQP-DSA|RecomputeCapture`, `INFO_AQP-DSA|SetAgencyFee`, `INFO_AQP-DSA|SetOracleAuth`, `INFO_AQP-DSA|SetOracleValidity`, `INFO_AQP-DSA|ToggleExternalOracle`, `INFO_AQP-DSA|WithdrawRoyalty`, `INFO_AQP-FVT|AddRewardLink`, `INFO_AQP-FVT|AddScoreEntity`, `INFO_AQP-FVT|Collect`, `INFO_AQP-FVT|Control`, `INFO_AQP-FVT|Inject`, `INFO_AQP-FVT|InjectFinalize`, `INFO_AQP-FVT|InjectFixChunk`, `INFO_AQP-FVT|InjectStream`, `INFO_AQP-FVT|Issue`, `INFO_AQP-FVT|IssueGenericEarningVault`, `INFO_AQP-FVT|IssueMultipletFamily`, `INFO_AQP-FVT|RotateOwnership`, `INFO_AQP-FVT|SetCommonDenominator`, `INFO_AQP-FVT|SetMosaic`, `INFO_AQP-FVT|SetQualitySplit`, `INFO_AQP-FVT|SetSplitMode`, `INFO_AQP-FVT|SweepBegin`, `INFO_AQP-FVT|SweepRecomputeChunk`, `INFO_AQP-FVT|SweepRevokeAnchor`, `INFO_AQP-FVT|ToggleRewardLink`, `INFO_AQP-FVT|ToggleScoreEntityLink`, `INFO_AQP-FVT|UnstaleAll`, `INFO_AQP-FVT|UnstaleMyScores`, `INFO_AQP-MTX|2Inject`, `INFO_AQP-MTX|2SweepRevokeAnchor`, `INFO_AQP-POOL|AbortVacate`, `INFO_AQP-POOL|AddScore`, `INFO_AQP-POOL|BatchDrainCollectable`, `INFO_AQP-POOL|BatchDrainOrtoFungible`, `INFO_AQP-POOL|BatchDrainTrueFungible`, `INFO_AQP-POOL|BatchVacateCollectables`, `INFO_AQP-POOL|BatchVacateOrtoFungible`, `INFO_AQP-POOL|BatchVacateTrueFungible`, `INFO_AQP-POOL|DisablePoolStake`, `INFO_AQP-POOL|EnablePoolStake`, `INFO_AQP-POOL|FinalizeVacate`, `INFO_AQP-POOL|FullVacate`, `INFO_AQP-POOL|Issue`, `INFO_AQP-POOL|RevokeScore`, `INFO_AQP-POOL|StakeNonFungibleCollectable`, `INFO_AQP-POOL|StakeOrtoFungible`, `INFO_AQP-POOL|StakeSemiFungibleCollectable`, `INFO_AQP-POOL|StakeTrueFungible`, `INFO_AQP-POOL|SyncNonFungibleAnchors`, `INFO_AQP-POOL|SyncSemiFungibleAnchors`, `INFO_AQP-POOL|SyncTrueFungibleAnchors`, `INFO_AQP-POOL|UnstakeNonFungibleCollectable`, `INFO_AQP-POOL|UnstakeOrtoFungible`, `INFO_AQP-POOL|UnstakeSemiFungibleCollectable`, `INFO_AQP-POOL|UnstakeTrueFungible`, `INFO_AQP-SCR|CombineTripletScoreModel`, `INFO_AQP-SCR|ControlScore`, `INFO_AQP-SCR|CreateScoreBoostClassLink`, `INFO_AQP-SCR|CreateScoreBoostLink`, `INFO_AQP-SCR|EnableDebBoost`, `INFO_AQP-SCR|IssueLiquidityScore`, `INFO_AQP-SCR|IssueNonFungibleScore`, `INFO_AQP-SCR|IssueNonFungibleScoreDefinition`, `INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition`, `INFO_AQP-SCR|IssueOrtoFungibleScore`, `INFO_AQP-SCR|IssueScoreFromModel`, `INFO_AQP-SCR|IssueSemiFungibleScore`, `INFO_AQP-SCR|IssueSemiFungibleScoreDefinition`, `INFO_AQP-SCR|IssueSingleScoreModel`, `INFO_AQP-SCR|IssueTriplet`, `INFO_AQP-SCR|IssueTrueFungibleScore`, `INFO_AQP-SCR|RotateScoreOwnership`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:AQP-INFO -->

## Traps

**Nothing on chain calls a preview.** Every one is invoked off-chain, which is what permits it to be module-only rather than declared in an interface — and that in turn avoids a version bump and its cascade.

**A preview's parameter list usually differs from the operation's.** Bind by name; positional binding type-checks and prices a different question.
