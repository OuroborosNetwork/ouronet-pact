# U|SWP

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|SWP -->
**On chain**

| | |
|---|---|
| module hash | `qVgNWdtqTADrrWB4PXjOrsSMoPrKTCc63xa2D3qKlDc` |
| deployed size | 43,510 characters |
| implements | `UtilitySwpV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|SWP_ADMIN`

**Functions** — 39, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 8 | named object constructors | `UDC_DirectRawSwapInput`, `UDC_DirectSwapInputData`, `UDC_DirectTaxedSwapOutput`, `UDC_InverseRawSwapInput`, `UDC_InverseTaxedSwapOutput`, `UDC_ReverseSwapInputData` …+2 |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_ComputeInverseY` |
| `UC_` pure compute | 29 | arguments only -- no reads, no enforce | `UC_AddSupply`, `UC_AreOnPools`, `UC_BalancedLiquidity`, `UC_ComputeD`, `UC_ComputeEP`, `UC_ComputeInverseEP` …+23 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `CT_Bar` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `DirectRawSwapInput`, `DirectSwapInputData`, `DirectTaxedSwapOutput`, `InverseRawSwapInput`, `InverseTaxedSwapOutput`, `ReverseSwapInputData`, `SwapFeez`, `VirtualSwapEngine`

**Capabilities** -- 2

`GOV`, `GOV|U|SWP_ADMIN`

**Functions** -- 39, grouped by what the prefix promises

*Constructors* (8) — build objects

`UDC_DirectRawSwapInput`, `UDC_DirectSwapInputData`, `UDC_DirectTaxedSwapOutput`, `UDC_InverseRawSwapInput`, `UDC_InverseTaxedSwapOutput`, `UDC_ReverseSwapInputData`, `UDC_SwapFeez`, `UDC_VirtualSwapEngine`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_ComputeInverseY`

*Pure compute* (29) — arguments only; no reads, no enforce

`UC_AddSupply`, `UC_AreOnPools`, `UC_BalancedLiquidity`, `UC_ComputeD`, `UC_ComputeEP`, `UC_ComputeInverseEP`, `UC_ComputeInverseWP`, `UC_ComputeWP`, `UC_ComputeY`, `UC_DNext`, `UC_FilterOne`, `UC_FilterTwo`, `UC_IntPow`, `UC_IzOnPool`, `UC_IzOnPools`, `UC_LP`, `UC_LpID`, `UC_MakeGraphNodes`, `UC_MakeLiquidityList`, `UC_PoolID`, `UC_PoolTokensFromPairs`, `UC_PoolType`, `UC_Prefix`, `UC_RemoveSupply`, `UC_SpecialFeeOutputs`, `UC_TokensFromSwpairString`, `UC_UniqueTokens`, `UC_YNext`, `UC_ZNext`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:U|SWP -->

## Traps

_To be written._
