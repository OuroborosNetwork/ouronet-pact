# BLOODSHED-C — Bloodshed — composition

## What it is for

Composition for the collection.

Part of the **Bloodshed** citizen collection — five modules issuing and managing a collectable set. A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the collectables family.

## What it owns, and what it exposes

<!-- @generated:module-page:BLOODSHED-C -->
**On chain**

| | |
|---|---|
| module hash | `vaiWBV3wS6OSKOvZDHGtlxin5b0kQMqJepPeKOXEwvI` |
| deployed size | 18,503 characters |
| implements | — |
| repository source | `2_CITIZEN/2_BloodshedMinter/04_BSD-C.pact` |

**Capabilities** — 3

`GOV`, `GOV|BLOODSHED-C_ADMIN`, `SECURE`

**Functions** — 9, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `A_` admin | 1 | admin-key mutations | `A_Common` |
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `C-x`, `CS`, `CT_Bar`, `CommonLink`, `CommonOM`, `GOV|Demiurgoi` …+2 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** on chain only: `C-x`, `CS`, `CommonLink`, `CommonOM`, `MD`, `OrderMultiplier`
> - **functions** in the repository only: `UC_CommonLink`, `UC_CommonOM`, `UC_CommonScore`, `UCv_OrderMultiplier`, `UDC_CommonByPosition`, `UDC_MetaData`

**Capabilities** -- 3

`GOV`, `GOV|BLOODSHED-C_ADMIN`, `SECURE`

**Functions** -- 9, grouped by what the prefix promises

*Admin* (1) — admin-key mutations

`A_Common`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (7) — no known prefix -- worth asking why

`C-x`, `CS`, `CT_Bar`, `CommonLink`, `CommonOM`, `MD`, `OrderMultiplier`
<!-- @end:module-page:BLOODSHED-C -->

## Traps

**Deployed before the naming sweep**, so the chain's function names differ from the repository's.
