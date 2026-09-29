# O-UI-TWELVE

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-TWELVE -->
**On chain**

| | |
|---|---|
| module hash | `oTg2iNNyuDndRptAKRFxA4tROJJm_XXLa2lRxb1fM3Y` |
| deployed size | 22,685 characters |
| implements | `OUiTwelveV1` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/12_O-UI-TWELVE.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_TWELVE_ADMIN`

**Functions** — 20, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 7 | read and derive; no enforce | `URC_FeeSettings`, `URC_PoolCore`, `URC_PoolDashboard`, `URC_PoolInternal`, `URC_PoolSettings`, `URC_PoolTypeWord` …+1 |
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroPanel` |
| `UC_` pure compute | 4 | arguments only -- no reads, no enforce | `UC_Amount`, `UC_AmountList`, `UC_MaxSpecialFeeTargets`, `UC_Price` |
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_01|Global`, `URC_02|PoolList`, `URC_03|Pool`, `URC_04|AccountSupplies`, `URC_07|MaxOutputAmount` …+2 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_TWELVE_ADMIN`

**Functions** -- 20, grouped by what the prefix promises

*Derived reads* (12) — read and compute; no enforce

`URC_01|Global`, `URC_02|PoolList`, `URC_03|Pool`, `URC_04|AccountSupplies`, `URC_07|MaxOutputAmount`, `URC_FeeSettings`, `URC_PoolCore`, `URC_PoolDashboard`, `URC_PoolInternal`, `URC_PoolSettings`, `URC_PoolTypeWord`, `URC_ShortAccounts`

*Constructors* (1) — build objects

`UDC_ZeroPanel`

*Pure compute* (4) — arguments only; no reads, no enforce

`UC_Amount`, `UC_AmountList`, `UC_MaxSpecialFeeTargets`, `UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`URCv_05|DirectSwap`, `URCv_06|InverseSwap`
<!-- @end:module-page:O-UI-TWELVE -->

## Traps

_To be written._
