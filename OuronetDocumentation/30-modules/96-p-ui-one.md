# P-UI-ONE — page reads — external data

## What it is for

Reads serving the external-data interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

The read layer's only non-interface application module.

## What it owns, and what it exposes

<!-- @generated:module-page:P-UI-ONE -->
**On chain**

| | |
|---|---|
| module hash | `S5a-TYdndz3L1JmROLg4cdYTaGELZoa5A3mFk0SOBOY` |
| deployed size | 3,121 characters |
| implements | `PUiOneV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/Pythia/01_P-UI-ONE.pact` |

**Capabilities** — 2

`GOV`, `GOV|P_UI_ONE_ADMIN`

**Functions** — 4, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|ApiKeys`, `URC_02|DualLinks`, `URC_03|Prices` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|P_UI_ONE_ADMIN`

**Functions** -- 4, grouped by what the prefix promises

*Derived reads* (3) — read and compute; no enforce

`URC_01|ApiKeys`, `URC_02|DualLinks`, `URC_03|Prices`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:P-UI-ONE -->

## Traps

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
