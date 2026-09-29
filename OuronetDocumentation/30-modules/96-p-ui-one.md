# P-UI-ONE — external-data reads

## What it is for

Reads serving the external-data interface — keys, links and prices.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

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

**Four functions**, serving a different application from the other ten. That separation is the layer's organising rule: an app's reads are its own, because two apps showing the same number still want different shapes, and coupling them means a change for one is a redeploy for both.
