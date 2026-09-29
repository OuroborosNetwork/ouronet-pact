# O-UI-SEVEN — page reads — accounts

## What it is for

Reads serving account display data in the interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-SEVEN -->
**On chain**

| | |
|---|---|
| module hash | `VKP0sHFnSR3-AcyibfuiyxrXN3OtMtVq0YEYDT9E2_s` |
| deployed size | 11,728 characters |
| implements | `OUiSevenV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/07_O-UI-SEVEN.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_SEVEN_ADMIN`

**Functions** — 8, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|Accounts`, `URC_02|Account`, `URC_03|StoicTags`, `URC_04|StoicTag`, `URC_05|StoaAccounts` …+2 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_SEVEN_ADMIN`

**Functions** -- 8, grouped by what the prefix promises

*Derived reads* (7) — read and compute; no enforce

`URC_01|Accounts`, `URC_02|Account`, `URC_03|StoicTags`, `URC_04|StoicTag`, `URC_05|StoaAccounts`, `URC_06|StoaAccount`, `URC_07|Overview`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-SEVEN -->

## Traps

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
