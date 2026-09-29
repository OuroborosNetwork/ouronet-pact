# U|ST — gas-station helpers

## What it is for

Helpers for the gas station — the mechanism by which Ouronet pays the host chain's fee on a user's behalf.

## Where it sits

A utility consumed by the account core, which implements the host chain's own gas-payer interface. The station's decision logic lives there; the reusable parts live here.

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

**Sponsorship is conditional on what the transaction contains**, not on who sends it. The station reads the transaction's code and accepts three specific shapes. A transaction that is valid but shaped differently is simply not sponsored — see `10-architecture/06-ignis-and-the-gas-station.md`.
