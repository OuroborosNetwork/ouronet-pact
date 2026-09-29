# U|SWP — the three swap curves

## What it is for

All three swap-pool curve families, and the function that decides which a pool runs.

**Stable** pools use the Curve StableSwap invariant, solved by Newton iteration. **Weighted** pools use the Balancer-style weighted product, closed-form. **Plain** pools are the same with every exponent one. Which you get is derived from the pool's own weights and amplifier, not chosen by name.

## Where it sits

A utility below the entire swap family. The mathematics is here; the state, routing and client surface are above.

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

**The solvers run a fixed iteration count** because Pact has no dynamic loop and no early exit on convergence. Measured: six iterations were off by 0.0078 at 1000× reserve skew; bit-identical to a 255-iteration reference by ten; set to twelve for margin at a cost of 64 gas.

**The amplifier ceiling is where the arithmetic stops being trustworthy**, not a round number — round-trip convergence degrades sharply above it precisely because the iteration count is fixed.

**Weighted pools carry a permanent, bounded precision loss.** The native power operator drops to double precision for fractional exponents, which weighted pools genuinely need. The fix was assessed and declined as disproportionate. The audit's phrasing is the one a liquidity provider should read: *a real, permanent, bounded arbitrage against weighted-pool LPs.*
