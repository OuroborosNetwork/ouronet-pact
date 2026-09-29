# O-UI-ONE — the dashboard header

## What it is for

Reads serving the header strip — the few numbers every page shows at the top.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-ONE -->
**On chain**

| | |
|---|---|
| module hash | `5zBrzcIQZkdh6Avf0vDn52IcLCD0Yie8vn2LclKYPGM` |
| deployed size | 18,674 characters |
| implements | `OUiOneV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/01_O-UI-ONE.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_ONE_ADMIN`

**Functions** — 13, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 6 | read and derive; no enforce | `URC_IndexIds`, `URC_ResidentIgnis`, `URC_Zone1_Elite`, `URC_Zone2_Indices`, `URC_Zone3_Network`, `URC_Zone4_Prices` |
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroZone` |
| `UC_` pure compute | 4 | arguments only -- no reads, no enforce | `UC_Amount`, `UC_Index`, `UC_PickId`, `UC_Price` |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|Header` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_ONE_ADMIN`

**Functions** -- 13, grouped by what the prefix promises

*Derived reads* (7) — read and compute; no enforce

`URC_01|Header`, `URC_IndexIds`, `URC_ResidentIgnis`, `URC_Zone1_Elite`, `URC_Zone2_Indices`, `URC_Zone3_Network`, `URC_Zone4_Prices`

*Constructors* (1) — build objects

`UDC_ZeroZone`

*Pure compute* (4) — arguments only; no reads, no enforce

`UC_Amount`, `UC_Index`, `UC_PickId`, `UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-ONE -->

## Traps

**A field was deleted here rather than made heavy.** The header once carried a total account count, which required scanning every account. It worked, and it was removed anyway: *this is not a bug being fixed; it is a dependency being made deliberate.* Losing it bought no cross-module scan, no node-configuration dependency, no admin grant to test — and, the real prize, **every zone can now degrade independently**, where that one field could take the whole page down because a scan cannot live inside a `try`.
