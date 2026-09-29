# BLOODSHED-R — Bloodshed — roles

## What it is for

Role management for the collection.

Part of the **Bloodshed** citizen collection — five modules issuing and managing a collectable set. A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the collectables family.

## What it owns, and what it exposes

<!-- @generated:module-page:BLOODSHED-R -->
**On chain**

| | |
|---|---|
| module hash | `CQSvs1Ik7LHw1cYGRj9sMrd4gZn2Msi8AzR75lyvMoA` |
| deployed size | 13,742 characters |
| implements | — |
| repository source | `2_CITIZEN/2_BloodshedMinter/03_BSD-R.pact` |

**Capabilities** — 3

`GOV`, `GOV|BLOODSHED-R_ADMIN`, `SECURE`

**Functions** — 9, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `A_` admin | 1 | admin-key mutations | `A_Rare` |
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `MD`, `OrderMultiplier`, `R-x`, `RS` …+2 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** on chain only: `MD`, `OrderMultiplier`, `R-x`, `RS`, `RareLink`, `RareOM`
> - **functions** in the repository only: `UC_RareLink`, `UC_RareOM`, `UC_RareScore`, `UCv_OrderMultiplier`, `UDC_MetaData`, `UDC_RareByPosition`

**Capabilities** -- 3

`GOV`, `GOV|BLOODSHED-R_ADMIN`, `SECURE`

**Functions** -- 9, grouped by what the prefix promises

*Admin* (1) — admin-key mutations

`A_Rare`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (7) — no known prefix -- worth asking why

`CT_Bar`, `MD`, `OrderMultiplier`, `R-x`, `RS`, `RareLink`, `RareOM`
<!-- @end:module-page:BLOODSHED-R -->

## Traps

**Deployed before the naming sweep**, so the chain's function names differ from the repository's.
