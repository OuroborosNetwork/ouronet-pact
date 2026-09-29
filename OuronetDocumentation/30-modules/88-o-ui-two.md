# O-UI-TWO — page reads

## What it is for

Reads serving a page's display data in the interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-TWO -->
**On chain**

| | |
|---|---|
| module hash | `AVjkbp63s1NHuXCqBDj5ww37pxIs2r62JdczrwnsbpY` |
| deployed size | 36,018 characters |
| implements | `OUiTwoV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/02_O-UI-TWO.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_TWO_ADMIN`

**Functions** — 19, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_GoldenStoaNonces` |
| `URC_` derived reads | 12 | read and derive; no enforce | `URC_Auryn`, `URC_Codex`, `URC_EliteAuryn`, `URC_GoldenStoa`, `URC_Ignis`, `URC_Ouro` …+6 |
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroCard` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_Amount`, `UC_PickId`, `UC_Price` |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|Dashboard` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_TWO_ADMIN`

**Functions** -- 19, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_GoldenStoaNonces`

*Derived reads* (13) — read and compute; no enforce

`URC_01|Dashboard`, `URC_Auryn`, `URC_Codex`, `URC_EliteAuryn`, `URC_GoldenStoa`, `URC_Ignis`, `URC_Ouro`, `URC_Prices`, `URC_SilverStoa`, `URC_Stoa`, `URC_Totals`, `URC_UrStoa`, `URC_Value`

*Constructors* (1) — build objects

`UDC_ZeroCard`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_Amount`, `UC_PickId`, `UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-TWO -->

## Traps

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
