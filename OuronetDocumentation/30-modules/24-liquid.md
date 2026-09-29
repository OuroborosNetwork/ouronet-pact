# LIQUID — liquid staking

## What it is for

Liquid staking over the chain's native currency — wrapping a staked position into a token that remains transferable.

## Where it sits

A Stage-1 core near the top of the stack. It is one of the four recipients of protocol revenue, and the largest: **40% of every native fee** routes here.

## What it owns, and what it exposes

<!-- @generated:module-page:LIQUID -->
**On chain**

| | |
|---|---|
| module hash | `fPn76dBt1-u5WKQDDKFFDcevs86h1b_GgNUtBACjIBg` |
| deployed size | 27,612 characters |
| implements | `OuronetPolicyV2`, `StoaLiquidStakingV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 14

`GOV`, `GOV|LIQUID_ADMIN`, `GOV|MIGRATE`, `LIQUID|C>UNWRAP`, `LIQUID|C>UR-UNWRAP`, `LIQUID|C>UR-WRAP`, `LIQUID|C>WRAP`, `LIQUID|C>X_WRAPPER`, `LIQUID|CALLER`, `LIQUID|CONVERTER`, `LIQUID|GOV`, `LIQUID|NATIVE-AUTOMATIC`, `P|LQD|CALLER`, `SECURE`

**Functions** — 28, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 4 | returns what an operation will charge | `URCi_UnwrapStoa`, `URCi_UnwrapUrStoa`, `URCi_WrapStoa`, `URCi_WrapUrStoa` |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_Amount`, `UEV_IzLiquidStakingLive` |
| `UR_` readers | 1 | table reads; no enforce, no writes | `UR_IzOuronetAccountRegisteredForUrstoaHoldings` |
| `A_` admin | 1 | admin-key mutations | `A_MigrateLiquidFunds` |
| `C_` client | 4 | reached via Talos, never called directly | `C_UnwrapStoa`, `C_UnwrapUrStoa`, `C_WrapStoa`, `C_WrapUrStoa` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `GOV|Demiurgoi`, `GOV|LIQUID|GUARD`, `GOV|LIQUID|SC_NAME`, `GOV|LIQUID|SC_STOA-NAME` …+1 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 14

`GOV`, `GOV|LIQUID_ADMIN`, `GOV|MIGRATE`, `LIQUID|C>UNWRAP`, `LIQUID|C>UR-UNWRAP`, `LIQUID|C>UR-WRAP`, `LIQUID|C>WRAP`, `LIQUID|C>X_WRAPPER`, `LIQUID|CALLER`, `LIQUID|CONVERTER`, `LIQUID|GOV`, `LIQUID|NATIVE-AUTOMATIC`, `P|LQD|CALLER`, `SECURE`

**Functions** -- 28, grouped by what the prefix promises

*Cost readers* (4) — price an operation; the exec path and the preview both call these

`URCi_UnwrapStoa`, `URCi_UnwrapUrStoa`, `URCi_WrapStoa`, `URCi_WrapUrStoa`

*Point reads* (2) — one row or field by key

`P|UR_IMP`, `UR_IzOuronetAccountRegisteredForUrstoaHoldings`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Amount`, `UEV_IzLiquidStakingLive`

*Client entry* (4) — builds the bill; reachable only through Talos

`C_UnwrapStoa`, `C_UnwrapUrStoa`, `C_WrapStoa`, `C_WrapUrStoa`

*Admin* (6) — admin-key mutations

`A_MigrateLiquidFunds`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (5) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|LIQUID|GUARD`, `GOV|LIQUID|SC_NAME`, `GOV|LIQUID|SC_STOA-NAME`, `GOV|LiquidKey`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Info`
<!-- @end:module-page:LIQUID -->

## Traps

**It receives the biggest revenue share, and that share is not a parameter.** The four-way split is a constant, deliberately: the source records that it *used* to be a parameter, and that let a caller hand the function any four numbers.
