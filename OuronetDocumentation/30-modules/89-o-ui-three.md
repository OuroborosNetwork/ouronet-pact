# O-UI-THREE — account standing and recovery

## What it is for

Reads serving elite standing and the recovery options an account has.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

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

**Its rich-list read is the heaviest in the application**, and its own source states the ceiling: it walks every account then insertion-sorts, so it is **O(n²) under a 10,000,000 gas ceiling — comfortable at ~195 accounts, and it will not always be.** The stated remedy is pagination in the caller, not a bigger ceiling. A known limit with a named remedy is a specification, not debt.

It also cannot sit inside a `try`, because it scans across a module boundary.
