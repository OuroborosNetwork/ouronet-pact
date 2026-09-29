# O-UI-FOUR — page reads

## What it is for

Reads serving a page's display data in the interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

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

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
