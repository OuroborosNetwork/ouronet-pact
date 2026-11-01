# O-UI-THREE

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-THREE -->
**On chain**

| | |
|---|---|
| module hash | `Ynxy2t2NLw-Ay188xHOaiNrq5JD0VBoH61kxQtBJU5w` |
| deployed size | 29,942 characters |
| implements | `OUiThreeV2` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/03_O-UI-THREE.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_THREE_ADMIN`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 7 | read and derive; no enforce | `URC_Discounts`, `URC_Dispo`, `URC_Indices`, `URC_PosObjSt`, `URC_Standing`, `URC_Unlocks` …+1 |
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroCard` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_Amount`, `UC_Index`, `UC_MaxSpecialFeeTargets` |
| *(unclassified)* | 5 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|EliteAccount`, `URC_03|Recovery`, `URC_04|MaxRecovery`, `URH_02|RichList` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_THREE_ADMIN`

**Functions** -- 16, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_02|RichList`

*Derived reads* (10) — read and compute; no enforce

`URC_01|EliteAccount`, `URC_03|Recovery`, `URC_04|MaxRecovery`, `URC_Discounts`, `URC_Dispo`, `URC_Indices`, `URC_PosObjSt`, `URC_Standing`, `URC_Unlocks`, `URC_Variants`

*Constructors* (1) — build objects

`UDC_ZeroCard`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_Amount`, `UC_Index`, `UC_MaxSpecialFeeTargets`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-THREE -->

## Traps

_To be written._
