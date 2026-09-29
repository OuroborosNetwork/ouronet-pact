# BLOODSHED-E — Bloodshed — elements

## What it is for

Element definitions for the collection.

Part of the **Bloodshed** citizen collection — five modules issuing and managing a collectable set. A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the collectables family.

## What it owns, and what it exposes

<!-- @generated:module-page:BLOODSHED-E -->
**On chain**

| | |
|---|---|
| module hash | `WVkGNQd4A-_4e_DBZRaCwajgSxM88kz7yErNAJhXWic` |
| deployed size | 12,181 characters |
| implements | — |
| repository source | `2_CITIZEN/2_BloodshedMinter/02_BSD-E.pact` |

**Capabilities** — 3

`GOV`, `GOV|BLOODSHED-E_ADMIN`, `SECURE`

**Functions** — 9, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `A_` admin | 1 | admin-key mutations | `A_Epic` |
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `CT_Bar`, `E-x`, `ES`, `EpicLink`, `EpicOM`, `GOV|Demiurgoi` …+2 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** on chain only: `E-x`, `ES`, `EpicLink`, `EpicOM`, `MD`, `OrderMultiplier`
> - **functions** in the repository only: `UC_EpicLink`, `UC_EpicOM`, `UC_EpicScore`, `UCv_OrderMultiplier`, `UDC_EpicByPosition`, `UDC_MetaData`

**Capabilities** -- 3

`GOV`, `GOV|BLOODSHED-E_ADMIN`, `SECURE`

**Functions** -- 9, grouped by what the prefix promises

*Admin* (1) — admin-key mutations

`A_Epic`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (7) — no known prefix -- worth asking why

`CT_Bar`, `E-x`, `ES`, `EpicLink`, `EpicOM`, `MD`, `OrderMultiplier`
<!-- @end:module-page:BLOODSHED-E -->

## Traps

**Deployed before the naming sweep**, so the chain's function names differ from the repository's.
