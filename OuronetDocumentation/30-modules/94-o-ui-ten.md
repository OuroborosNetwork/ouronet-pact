# O-UI-TEN — collectable reads

## What it is for

Reads serving the collectable pages — semi-fungible and non-fungible lists.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-TEN -->
**On chain**

| | |
|---|---|
| module hash | `G2NpjCXfBAxx8MQyAK9j_HlVmY-2ykggvW-b6cRVTO0` |
| deployed size | 14,305 characters |
| implements | `OUiTenV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/10_O-UI-TEN.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_TEN_ADMIN`

**Functions** — 12, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_IzNonceTaken` |
| *(unclassified)* | 11 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_02|Entry`, `URC_03|SemiFungibleList`, `URC_04|NonFungibleList`, `URC_05|NonceData`, `URC_06|Sets` …+5 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_TEN_ADMIN`

**Functions** -- 12, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_01|Header`

*Derived reads* (10) — read and compute; no enforce

`URC_02|Entry`, `URC_03|SemiFungibleList`, `URC_04|NonFungibleList`, `URC_05|NonceData`, `URC_06|Sets`, `URC_07|FilterByClass`, `URC_08|FilterByClasses`, `URC_09|Buttons`, `URC_10|Wallet`, `URC_IzNonceTaken`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-TEN -->

## Traps

**Its header performs four cross-module scans**, the most of any read in the layer. Cross-module scans are permitted only in read-only queries on a node configured for them — not inside a transaction, and not inside a `try`.
