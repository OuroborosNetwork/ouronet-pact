# O-UI-ONE — page reads — header

## What it is for

Reads serving the dashboard header in the interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

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

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
