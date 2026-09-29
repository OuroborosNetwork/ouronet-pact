# U|VST

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|VST -->
**On chain**

| | |
|---|---|
| module hash | `He09OVJjpc4woXQ2Id-NRO44la6HeSt51cn2X7QPzEc` |
| deployed size | 7,362 characters |
| implements | `UtilityVstV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|VST_ADMIN`

**Functions** — 12, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_Milestone`, `UEV_MilestoneWithTime` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_SplitBalanceForVesting` |
| `UCx_` pure compute (auxiliary) | 1 | a private helper of the function above it | `UCx_SpecialID` |
| `UC_` pure compute | 7 | arguments only -- no reads, no enforce | `UC_EquityID`, `UC_FrozenID`, `UC_HibernationID`, `UC_MakeVestingDateList`, `UC_ReservedID`, `UC_SleepingID` …+1 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `CT_Bar` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|VST_ADMIN`

**Functions** -- 12, grouped by what the prefix promises

*Validators* (2) — read and enforce; failure aborts

`UEV_Milestone`, `UEV_MilestoneWithTime`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_SplitBalanceForVesting`

*Pure compute* (7) — arguments only; no reads, no enforce

`UC_EquityID`, `UC_FrozenID`, `UC_HibernationID`, `UC_MakeVestingDateList`, `UC_ReservedID`, `UC_SleepingID`, `UC_VestingID`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `UCx_SpecialID`
<!-- @end:module-page:U|VST -->

## Traps

_To be written._
