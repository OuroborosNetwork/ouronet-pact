# BLOODSHED-SETS — Bloodshed — sets

## What it is for

Set definitions for the collection.

Part of the **Bloodshed** citizen collection — five modules issuing and managing a collectable set. A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the collectables family.

## What it owns, and what it exposes

<!-- @generated:module-page:BLOODSHED-SETS -->
**On chain**

| | |
|---|---|
| module hash | `nU1q2xjZLaeAtR_jRQo1VMPI050rtu1uVmrX5s63uNM` |
| deployed size | 52,647 characters |
| implements | — |
| repository source | `2_CITIZEN/2_BloodshedMinter/05_BSD-SETS.pact` |

**Capabilities** — 3

`GOV`, `GOV|BLOODSHED-SETS_ADMIN`, `SECURE`

**Functions** — 17, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 17 | carries no StoicSyntax prefix | `A01_TierOneCommonComati`, `A02_TierOneCommonUrsoi`, `A03_TierOneCommonPileati`, `A04_TierOneCommonSmardoi`, `A05_TierOneCommonCarpian`, `A06_TierOneCommonTarabostes` …+11 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** on chain only: `C`, `N`, `SetLink`
> - **functions** in the repository only: `UC_SetLink`, `UDC_AllowedClass`, `UDC_AllowedNonce`, `UR_DhbOwner`

**Capabilities** -- 3

`GOV`, `GOV|BLOODSHED-SETS_ADMIN`, `SECURE`

**Functions** -- 17, grouped by what the prefix promises

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (16) — no known prefix -- worth asking why

`A01_TierOneCommonComati`, `A02_TierOneCommonUrsoi`, `A03_TierOneCommonPileati`, `A04_TierOneCommonSmardoi`, `A05_TierOneCommonCarpian`, `A06_TierOneCommonTarabostes`, `A07_TierOneCommonCostoboc`, `A08_TierOneCommonBuridavensRareComati`, `A09a_TierOneRare`, `A09b_TierOneRare`, `A10_TierOneEpic`, `A11_TierTwoThreeFour`, `C`, `CT_Bar`, `N`, `SetLink`
<!-- @end:module-page:BLOODSHED-SETS -->

## Traps

**Deployed before the naming sweep**, so the chain's function names differ from the repository's. This divergence is visible only because the documentation is generated from the chain rather than from the checkout.
