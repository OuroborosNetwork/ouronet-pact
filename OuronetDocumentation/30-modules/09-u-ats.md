# U|ATS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|ATS -->
**On chain**

| | |
|---|---|
| module hash | `77TiFr56DkqjkowPqH2Luj06bDvUuL9G6gRR2_N_NBs` |
| deployed size | 34,319 characters |
| implements | `UtilityAtsV3` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|ATS_ADMIN`

**Functions** — 24, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 7 | read and enforce; may abort the transaction | `UEV_AutostakeIndex`, `UEV_ColdDurationParameters`, `UEV_Decay`, `UEV_Fee`, `UEV_HibernationFees`, `UEV_StoicTagIndex` …+1 |
| `UDC_` constructors | 1 | named object constructors | `UDC_Elite` |
| `UCv_` pure compute (validating) | 4 | compute with an intrinsic guard | `UCv_MakeHardIntervals`, `UCv_MakeSoftIntervals`, `UCv_SolidifyUnstakeObject`, `UCv_SplitBalanceWithBooleans` |
| `UC_` pure compute | 9 | arguments only -- no reads, no enforce | `UC_IzCullable`, `UC_IzStoicTagIndex`, `UC_IzStoicTagIndexChar`, `UC_IzUnstakeObjectValid`, `UC_KickStartIndex`, `UC_MultiReshapeUnstakeObject` …+3 |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `UEV_CRF|FeeArray`, `UEV_CRF|FeeThresholds`, `UEV_CRF|Positions` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `Awo`

**Capabilities** -- 2

`GOV`, `GOV|U|ATS_ADMIN`

**Functions** -- 24, grouped by what the prefix promises

*Validators* (10) — read and enforce; failure aborts

`UEV_AutostakeIndex`, `UEV_CRF|FeeArray`, `UEV_CRF|FeeThresholds`, `UEV_CRF|Positions`, `UEV_ColdDurationParameters`, `UEV_Decay`, `UEV_Fee`, `UEV_HibernationFees`, `UEV_StoicTagIndex`, `UEV_UniqueAtspair`

*Constructors* (1) — build objects

`UDC_Elite`

*Pure compute (guarded)* (4) — compute with a guard intrinsic to the computation

`UCv_MakeHardIntervals`, `UCv_MakeSoftIntervals`, `UCv_SolidifyUnstakeObject`, `UCv_SplitBalanceWithBooleans`

*Pure compute* (9) — arguments only; no reads, no enforce

`UC_IzCullable`, `UC_IzStoicTagIndex`, `UC_IzStoicTagIndexChar`, `UC_IzUnstakeObjectValid`, `UC_KickStartIndex`, `UC_MultiReshapeUnstakeObject`, `UC_PromilleSplit`, `UC_ReshapeUnstakeObject`, `UC_SplitByIndexedRBT`
<!-- @end:module-page:U|ATS -->

## Traps

_To be written._
