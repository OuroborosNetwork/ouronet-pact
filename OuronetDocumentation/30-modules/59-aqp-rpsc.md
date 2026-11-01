# AQP-RPSC

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-RPSC -->
**On chain**

| | |
|---|---|
| module hash | `meIcpLzGn0VRD9KY7erIeC-IL3_u8RMHuy3Yqam5wjY` |
| deployed size | 43,004 characters |
| implements | `AcquisitionRewardCostsV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04b_RPSC.pact` |

**Capabilities** — 2

`GOV`, `GOV|RPSC_ADMIN`

**Functions** — 28, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 19 | returns what an operation will charge | `URCi_AddRewardLink`, `URCi_AddScoreEntity`, `URCi_BurnRoyaltyCustody`, `URCi_Collect`, `URCi_CollectFull`, `URCi_CollectableStakeFlow` …+13 |
| `URC_` derived reads | 5 | read and derive; no enforce | `URC_CollectForcedFixIgnis`, `URC_CollectLadderPreview`, `URC_CollectTransferLegIgnis`, `URC_CollectXferIgnis`, `URC_HeterogeneousLaneRouteIgnis` |
| `UDC_` constructors | 1 | named object constructors | `UDC_LadderPreview` |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|RPSC_ADMIN`

**Functions** -- 28, grouped by what the prefix promises

*Cost readers* (19) — price an operation; the exec path and the preview both call these

`URCi_AddRewardLink`, `URCi_AddScoreEntity`, `URCi_BurnRoyaltyCustody`, `URCi_Collect`, `URCi_CollectFull`, `URCi_CollectableStakeFlow`, `URCi_Control`, `URCi_FuelRoyaltyCustody`, `URCi_InjectFull`, `URCi_OrtoFungibleStakeFlow`, `URCi_RotateOwnership`, `URCi_SetCommonDenominator`, `URCi_SetMosaic`, `URCi_SetQualitySplit`, `URCi_SetSplitMode`, `URCi_ToggleRewardLink`, `URCi_ToggleScoreEntityLink`, `URCi_TrueFungibleStakeFlow`, `URCi_WithdrawRoyaltyCustody`

*Derived reads* (5) — read and compute; no enforce

`URC_CollectForcedFixIgnis`, `URC_CollectLadderPreview`, `URC_CollectTransferLegIgnis`, `URC_CollectXferIgnis`, `URC_HeterogeneousLaneRouteIgnis`

*Constructors* (1) — build objects

`UDC_LadderPreview`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`
<!-- @end:module-page:AQP-RPSC -->

## Traps

_To be written._
