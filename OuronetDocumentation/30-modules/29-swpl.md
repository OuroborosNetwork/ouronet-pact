# SWPL

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWPL -->
**On chain**

| | |
|---|---|
| module hash | `fb9yb4TOkESqB4QK4jNUgP-_3PLUtzc704q4UtpacWg` |
| deployed size | 96,884 characters |
| implements | `OuronetPolicyV2`, `SwapperLiquidityV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 12

`GOV`, `GOV|SWPL_ADMIN`, `P|SECURE-CALLER`, `P|SWPL|CALLER`, `SECURE`, `SWPL|S>ADD_ASYMMETRIC-LQ`, `SWPL|S>ADD_BALANCED-LQ`, `SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX`, `SWPL|S>ASYMMETRIC-LQ-FUELING-TAX`, `SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX`, `SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX`, `SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX`

**Functions** — 47, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCv_` derived reads (validating) | 2 | read + derive, with an intrinsic guard | `URCv_AreAmountsBalanced`, `URCv_CustomLpBreakAmounts` |
| `URC_` derived reads | 8 | read and derive; no enforce | `URC_AsymmetricTax`, `URC_BalancedLiquidity`, `URC_D1forWP`, `URC_IgnisPrecision`, `URC_LD`, `URC_LpBreakAmounts` …+2 |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_BalancedLiquidity`, `UEV_Liquidity` |
| `UDC_` constructors | 12 | named object constructors | `UDC_AsymmetricTax`, `UDC_CladOperation`, `UDC_CompleteLiquidityAdditionData`, `UDC_LiquidityComputationData`, `UDC_LiquidityData`, `UDC_LiquiditySplit` …+6 |
| `UCx_` pure compute (auxiliary) | 1 | a private helper of the function above it | `UCx_Step2AsymmetricTaxVirtualSwapper` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_DetermineLiquidity` |
| `XI_` protected (internal) | 1 | this module only | `XI_AddLiqSendAndMint` |
| `XE_` protected (external) | 1 | for other modules; opens with the IMC gate | `XE_AutonomousSwapManagement` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 10 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `URC_STOA-PID|CLAD`, `URC_STOA-PID|LpToIgnis` …+4 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `AsymmetricTax`, `CladOperation`, `CompleteLiquidityAdditionData`, `LiquidityComputationData`, `LiquidityData`, `LiquiditySplit`, `LiquiditySplitType`, `OutputLP`

**Capabilities** -- 12

`GOV`, `GOV|SWPL_ADMIN`, `P|SECURE-CALLER`, `P|SWPL|CALLER`, `SECURE`, `SWPL|S>ADD_ASYMMETRIC-LQ`, `SWPL|S>ADD_BALANCED-LQ`, `SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX`, `SWPL|S>ASYMMETRIC-LQ-FUELING-TAX`, `SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX`, `SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX`, `SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX`

**Functions** -- 47, grouped by what the prefix promises

*Derived reads* (11) — read and compute; no enforce

`URC_AsymmetricTax`, `URC_BalancedLiquidity`, `URC_D1forWP`, `URC_IgnisPrecision`, `URC_LD`, `URC_LpBreakAmounts`, `URC_STOA-PID|CLAD`, `URC_STOA-PID|LpToIgnis`, `URC_STOA-PID|TokenToIgnis`, `URC_SortLiquidity`, `URC_TokenPrecision`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_BalancedLiquidity`, `UEV_Liquidity`

*Constructors* (12) — build objects

`UDC_AsymmetricTax`, `UDC_CladOperation`, `UDC_CompleteLiquidityAdditionData`, `UDC_LiquidityComputationData`, `UDC_LiquidityData`, `UDC_LiquiditySplit`, `UDC_LiquiditySplitType`, `UDC_OutputLP`, `UDC_PoolFees`, `UDC_PoolState`, `UDC_VirtualSwapEngine`, `UDC_VirtualSwapEngineSwpair`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_DetermineLiquidity`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (2) — callable by other modules only

`XE_AutonomousSwapManagement`, `XE_STOA-PID|AddLiquidity`

*Internal writes* (1) — this module only; writes under a capability

`XI_AddLiqSendAndMint`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Unclassified* (7) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `UCx_Step2AsymmetricTaxVirtualSwapper`, `URCv_AreAmountsBalanced`, `URCv_CustomLpBreakAmounts`, `URCx_AsymmetricLP`, `URCx_BalancedLP`
<!-- @end:module-page:SWPL -->

## Traps

_To be written._
