# EXPLORER — block-explorer reads

## What it is for

Reads serving a block explorer.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

A citizen read module.

## What it owns, and what it exposes

<!-- @generated:module-page:EXPLORER -->
**On chain**

| | |
|---|---|
| module hash | `H_34KIUASRoIwu_yV1rev_EIGGfRDHIxrWR_LDrWMoA` |
| deployed size | 7,817 characters |
| implements | — |
| repository source | `2_CITIZEN/Stage_Z/02_EXPLORER.pact` |

**Capabilities** — 2

`GOV`, `GOV|EXPLORER_ADMIN`

**Functions** — 7, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_0001_LandingPage` |
| `UC_` pure compute | 2 | arguments only -- no reads, no enforce | `UC_FormatIndex`, `UC_FormatTokenAmount` |
| `UR_` readers | 1 | table reads; no enforce, no writes | `UR_0001_AccountNonce` |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|EXPLORER_ADMIN`

**Functions** -- 7, grouped by what the prefix promises

*Derived reads* (1) — read and compute; no enforce

`URC_0001_LandingPage`

*Point reads* (1) — one row or field by key

`UR_0001_AccountNonce`

*Pure compute* (2) — arguments only; no reads, no enforce

`UC_FormatIndex`, `UC_FormatTokenAmount`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`
<!-- @end:module-page:EXPLORER -->

## Traps

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.
