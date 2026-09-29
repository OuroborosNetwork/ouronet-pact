# U|ST

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|ST -->
**On chain**

| | |
|---|---|
| module hash | `Bat28rAkhIAm1dlOoLtjU72YF-DbP4rzHomJwfCaDL0` |
| deployed size | 4,433 characters |
| implements | `OuronetGasStationV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/03_U_ST.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|ST_ADMIN`

**Functions** — 12, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_chain-gas-notional` |
| `UEV_` validators | 9 | read and enforce; may abort the transaction | `UEV_enforce-below-gas-limit`, `UEV_enforce-below-gas-notional`, `UEV_enforce-below-gas-price`, `UEV_enforce-below-or-at-gas-limit`, `UEV_enforce-below-or-at-gas-notional`, `UEV_enforce-below-or-at-gas-price` …+3 |
| `UR_` readers | 2 | table reads; no enforce, no writes | `UR_chain-gas-limit`, `UR_chain-gas-price` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|ST_ADMIN`

**Functions** -- 12, grouped by what the prefix promises

*Derived reads* (1) — read and compute; no enforce

`URC_chain-gas-notional`

*Point reads* (2) — one row or field by key

`UR_chain-gas-limit`, `UR_chain-gas-price`

*Validators* (9) — read and enforce; failure aborts

`UEV_enforce-below-gas-limit`, `UEV_enforce-below-gas-notional`, `UEV_enforce-below-gas-price`, `UEV_enforce-below-or-at-gas-limit`, `UEV_enforce-below-or-at-gas-notional`, `UEV_enforce-below-or-at-gas-price`, `UEV_max-gas-limit`, `UEV_max-gas-notional`, `UEV_max-gas-price`
<!-- @end:module-page:U|ST -->

## Traps

_To be written._
