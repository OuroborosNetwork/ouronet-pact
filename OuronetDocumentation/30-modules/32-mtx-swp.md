# MTX-SWP

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:MTX-SWP -->
**On chain**

| | |
|---|---|
| module hash | `IAHAD-gi2epkh6ya2iWlVvxXnwsT3l57c9MVUevjAiE` |
| deployed size | 58,471 characters |
| implements | `OuronetPolicyV2`, `SwapperMtxV4` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 20

`GOV`, `GOV|MTX-SWP_ADMIN`, `MTX-SWP|C-ADD-CHILLED-LQ`, `MTX-SWP|C-ADD-DORMANT-LQ`, `MTX-SWP|C>ADD-FROZEN-LQ`, `MTX-SWP|C>ADD-GLACIAL-LQ`, `MTX-SWP|C>ADD-ICED-LQ`, `MTX-SWP|C>ADD-SLEEPING-LQ`, `MTX-SWP|C>ADD-STANDARD-LQ`, `MTX-SWP|C>ISSUE`, `MTX-SWP|C>ISSUE-P-POOL`, `MTX-SWP|C>ISSUE-S-POOL`, `MTX-SWP|C>ISSUE-W-POOL`, `MTX-SWP|C>X-ADD-LQ`, `MTX-SWP|S>ADD-LQ`, `P|DT`, `P|MTX-SWP|CALLER`, `P|MTX-SWP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 25, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_AddLiquidityChurnRemainder`, `URCi_AddLiquidityInitiation` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_AddLiquidityChurnKey` |
| `UR_` readers | 1 | table reads; no enforce, no writes | `UR_PoolState` |
| `C_` client | 8 | reached via Talos, never called directly | `C_AddFrozenLiquidity`, `C_AddGlacialLiquidity`, `C_AddIcedLiquidity`, `C_AddSleepingLiquidity`, `C_AddStandardLiquidity`, `C_IssueStablePool` …+2 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME` |

**Multi-transaction (`defpact`)** — `MTX|C_AddFrozenLiquidity`, `MTX|C_AddLiquidity`, `MTX|C_AddSleepingLiquidity`, `MTX|C_Issue`

> Repository and chain agree on every declared shape.

**Capabilities** -- 20

`GOV`, `GOV|MTX-SWP_ADMIN`, `MTX-SWP|C-ADD-CHILLED-LQ`, `MTX-SWP|C-ADD-DORMANT-LQ`, `MTX-SWP|C>ADD-FROZEN-LQ`, `MTX-SWP|C>ADD-GLACIAL-LQ`, `MTX-SWP|C>ADD-ICED-LQ`, `MTX-SWP|C>ADD-SLEEPING-LQ`, `MTX-SWP|C>ADD-STANDARD-LQ`, `MTX-SWP|C>ISSUE`, `MTX-SWP|C>ISSUE-P-POOL`, `MTX-SWP|C>ISSUE-S-POOL`, `MTX-SWP|C>ISSUE-W-POOL`, `MTX-SWP|C>X-ADD-LQ`, `MTX-SWP|S>ADD-LQ`, `P|DT`, `P|MTX-SWP|CALLER`, `P|MTX-SWP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 25, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_AddLiquidityChurnRemainder`, `URCi_AddLiquidityInitiation`

*Point reads* (2) — one row or field by key

`P|UR_IMP`, `UR_PoolState`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_AddLiquidityChurnKey`

*Client entry* (8) — builds the bill; reachable only through Talos

`C_AddFrozenLiquidity`, `C_AddGlacialLiquidity`, `C_AddIcedLiquidity`, `C_AddSleepingLiquidity`, `C_AddStandardLiquidity`, `C_IssueStablePool`, `C_IssueStandardPool`, `C_IssueWeightedPool`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`
<!-- @end:module-page:MTX-SWP -->

## Traps

_To be written._
