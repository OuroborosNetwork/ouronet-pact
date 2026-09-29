# SWPI

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWPI -->
**On chain**

| | |
|---|---|
| module hash | `jqBfiYRyhqH6NPpeQlRf_rDNjFbvXdZUquoAO0J--b8` |
| deployed size | 136,106 characters |
| implements | `OuronetPolicyV2`, `SwapperIssueV4` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 9

`GOV`, `GOV|SWPI_ADMIN`, `P|DT`, `P|SECURE-CALLER`, `P|SWPI|CALLER`, `P|SWPI|REMOTE-GOV`, `SECURE`, `SWPI|C>ISSUE`, `SWPI|XE>ISSUE-WRITE`

**Functions** — 77, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 3 | returns what an operation will charge | `URCi_Issue`, `URCi_IssuePool`, `URCi_IssueStoa` |
| `URCv_` derived reads (validating) | 2 | read + derive, with an intrinsic guard | `URCv_PoolTokenPositions`, `URCv_Swap` |
| `URC_` derived reads | 35 | read and derive; no enforce | `URC_BestEdge`, `URC_BestEdgeFiltered`, `URC_DirectRawSwapInput`, `URC_DirectRefillAmounts`, `URC_EliteFeeReduction`, `URC_Hopper` …+29 |
| `UEV_` validators | 3 | read and enforce; may abort the transaction | `UEV_InverseSwapData`, `UEV_Issue`, `UEV_SwapData` |
| `UDC_` constructors | 3 | named object constructors | `UDC_DirectRawSwapInput`, `UDC_Hopper`, `UDC_InverseRawSwapInput` |
| `UCv_` pure compute (validating) | 3 | compute with an intrinsic guard | `UCv_BareboneSwap`, `UCv_DeviationInValueShares`, `UCv_PoolTokenPositions` |
| `UC_` pure compute | 7 | arguments only -- no reads, no enforce | `UC_BareboneInverseSwap`, `UC_BareboneSwapWithFeez`, `UC_BestHopper`, `UC_DeviatedShares`, `UC_InverseBareboneSwapWithFeez`, `UC_PoolShares` …+1 |
| `XE_` protected (external) | 1 | for other modules; opens with the IMC gate | `XE_IssueWrite` |
| `A_` admin | 1 | admin-key mutations | `A_RebuildGraph` |
| `C_` client | 1 | reached via Talos, never called directly | `C_Issue` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 9 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `URCx_BestEdgeOf`, `URCx_Hopper`, `URCx_HopperForNodes` …+3 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `Hopper`

**Capabilities** -- 9

`GOV`, `GOV|SWPI_ADMIN`, `P|DT`, `P|SECURE-CALLER`, `P|SWPI|CALLER`, `P|SWPI|REMOTE-GOV`, `SECURE`, `SWPI|C>ISSUE`, `SWPI|XE>ISSUE-WRITE`

**Functions** -- 77, grouped by what the prefix promises

*Cost readers* (3) — price an operation; the exec path and the preview both call these

`URCi_Issue`, `URCi_IssuePool`, `URCi_IssueStoa`

*Derived reads* (35) — read and compute; no enforce

`URC_BestEdge`, `URC_BestEdgeFiltered`, `URC_DirectRawSwapInput`, `URC_DirectRefillAmounts`, `URC_EliteFeeReduction`, `URC_Hopper`, `URC_HopperActive`, `URC_HopperActiveShortest`, `URC_HopperExhaustive`, `URC_HopperForKnownRoute`, `URC_HopperFromGraph`, `URC_HopperFromRaw`, `URC_IndirectRefillAmounts`, `URC_InverseRawSwapInput`, `URC_InverseSwap`, `URC_IssuePoolIgnis`, `URC_OuroPrimordialPrice`, `URC_P-InverseSwap`, `URC_P-Swap`, `URC_PoolValue`, `URC_PoolValueFromGraph`, `URC_PoolValueFromRaw`, `URC_S-InverseSwap`, `URC_S-Swap`, `URC_SingleOuroWorthWSTOA`, `URC_SingleSSTOAWorthWSTOA`, `URC_SingleWorthWSTOA`, `URC_TokenDollarPrice`, `URC_TrimIdsWithZeroAmounts`, `URC_ValidatePathActive`, `URC_W-InverseSwap`, `URC_W-Swap`, `URC_WorthWSTOA`, `URC_WorthWSTOAFromGraph`, `URC_WorthWSTOAFromRaw`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (4) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_InverseSwapData`, `UEV_Issue`, `UEV_SwapData`

*Constructors* (3) — build objects

`UDC_DirectRawSwapInput`, `UDC_Hopper`, `UDC_InverseRawSwapInput`

*Pure compute (guarded)* (3) — compute with a guard intrinsic to the computation

`UCv_BareboneSwap`, `UCv_DeviationInValueShares`, `UCv_PoolTokenPositions`

*Pure compute* (7) — arguments only; no reads, no enforce

`UC_BareboneInverseSwap`, `UC_BareboneSwapWithFeez`, `UC_BestHopper`, `UC_DeviatedShares`, `UC_InverseBareboneSwapWithFeez`, `UC_PoolShares`, `UC_VirtualSwap`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_Issue`

*Admin* (6) — admin-key mutations

`A_RebuildGraph`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (1) — callable by other modules only

`XE_IssueWrite`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Unclassified* (9) — no known prefix -- worth asking why

`CT_Bar`, `URCv_PoolTokenPositions`, `URCv_Swap`, `URCx_BestEdgeOf`, `URCx_Hopper`, `URCx_HopperForNodes`, `URCx_HopperFromGraph`, `URCx_HopperFromRaw`, `URCx_PrimordialValueAndOuroSupply`
<!-- @end:module-page:SWPI -->

## Traps

_To be written._
