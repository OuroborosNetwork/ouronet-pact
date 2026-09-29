# U|DPTF — the volumetric tax

## What it is for

The **progressive transfer tax** — a fee that grows with the size of the transfer, and not linearly.

The amount is decomposed into its decimal digits, and each digit position contributes a rate derived from a repunit logarithm at that position. Moving 10 costs proportionally less than moving 10,000,000.

## Where it sits

A utility below the true-fungible core, which applies the tax on transfer.

## What it owns, and what it exposes

<!-- @generated:module-page:U|DPTF -->
**On chain**

| | |
|---|---|
| module hash | `3o23KcKGZrJa7obju9cSBglhBr8CeqtAIeR20uioJwI` |
| deployed size | 7,017 characters |
| implements | `UtilityDptfV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|DPTF_ADMIN`

**Functions** — 7, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 1 | named object constructors | `UDC_EmptyDispo` |
| `UCx_` pure compute (auxiliary) | 1 | a private helper of the function above it | `UCx_VolumetricPermile` |
| `UC_` pure compute | 5 | arguments only -- no reads, no enforce | `UC_EightSplitter`, `UC_FourSplitter`, `UC_OuroDispo`, `UC_TwoSplitter`, `UC_VolumetricTax` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `DispoData`

**Capabilities** -- 2

`GOV`, `GOV|U|DPTF_ADMIN`

**Functions** -- 7, grouped by what the prefix promises

*Constructors* (1) — build objects

`UDC_EmptyDispo`

*Pure compute* (5) — arguments only; no reads, no enforce

`UC_EightSplitter`, `UC_FourSplitter`, `UC_OuroDispo`, `UC_TwoSplitter`, `UC_VolumetricTax`

*Unclassified* (1) — no known prefix -- worth asking why

`UCx_VolumetricPermile`
<!-- @end:module-page:U|DPTF -->

## Traps

**The arithmetic is the schedule.** There are no brackets to configure and no table to keep in step — which means there is also no way to adjust the curve without changing the function. That is a deliberate trade: a fee model nobody can misconfigure, and nobody can tune.
