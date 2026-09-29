# U|VST — the special-variant prefixes

## What it is for

The prefix family for derived tokens — `V|` vested, `Z|` sleeping, `H|` hibernating, `F|` frozen, `R|` reserved, `E|` equity — and the arithmetic behind vesting schedules and release dates.

It builds a derived token's name and ticker from its parent's, truncating so the result still fits the length limits.

## Where it sits

A utility below the vesting core, which performs the transitions.

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

**Sleeping and hibernating are one family, two prefixes.** Code testing only for `Z|` sent every hibernating token down the wrong branch and failed looking up an `H|` identifier in the wrong table. Always test against both.

**A prefix does not always mean what it looks like.** Multi-token pool families use `F|` and `T|` as plain string separators, so `F|TOKEN-A|TOKEN-B|TOKEN-C` is not a frozen token. Count the separators before reading the prefix.
