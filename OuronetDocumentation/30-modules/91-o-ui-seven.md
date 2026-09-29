# O-UI-SEVEN — account reads

## What it is for

Reads serving account pages — accounts, a single account, and registered names.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

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

**Its activation test is `public != "|"`**, wrapped in a `try` defaulting to the sentinel. A non-sentinel result means activated. That works because the public-key field is never validated on write, so its *presence* is the only signal available — see `80-cryptography/04-what-is-not-on-chain.md`.
