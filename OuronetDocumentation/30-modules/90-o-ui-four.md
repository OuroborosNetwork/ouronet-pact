# O-UI-FOUR — distribution-vault reads

## What it is for

Reads serving the distribution vault.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-FOUR -->
**On chain**

| | |
|---|---|
| module hash | `X1ju3aQh4tnCQHYhc5f-Mw16WJoCVnp1TZgS78n9-rQ` |
| deployed size | 3,711 characters |
| implements | `OUiFourV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/04_O-UI-FOUR.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_FOUR_ADMIN`

**Functions** — 3, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_Price` |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|Ico` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_FOUR_ADMIN`

**Functions** -- 3, grouped by what the prefix promises

*Derived reads* (1) — read and compute; no enforce

`URC_01|Ico`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:O-UI-FOUR -->

## Traps

**Three functions.** The smallest read module in the layer, and a good illustration of the sizing rule: modules are one per display entity, so a small surface gets a small module rather than being folded into a larger one. Folding would make the larger module's redeploy the smaller one's problem.
