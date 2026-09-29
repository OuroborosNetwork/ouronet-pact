# SWPU

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWPU -->
**On chain**

| | |
|---|---|
| module hash | `3MDyxoGaDge26FYI1VgqwY_lzuJB13PwUXOB2TzYwaE` |
| deployed size | 132,572 characters |
| implements | `OuronetPolicyV2`, `SwapperUsageV3` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 24

`GOV`, `GOV|SWPU_ADMIN`, `P|DT`, `P|SWPU|CALLER`, `P|SWPU|REMOTE-GOV`, `SECURE`, `SPWU|C>TOGGLE-SWAP`, `SWPU|C>MULTI-SWAP-NO-SLIPPAGE`, `SWPU|C>MULTI-SWAP-WITH-SLIPPAGE`, `SWPU|C>SINGL-SWAP-NO-SLIPPAGE`, `SWPU|C>SINGL-SWAP-WITH-SLIPPAGE`, `SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE`, `SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE`, `SWPU|C>SMART-SWAP-NO-SLIPPAGE`, `SWPU|C>SMART-SWAP-WITH-SLIPPAGE`, `SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE`, `SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE`, `SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE`, `SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE`, `SWPU|S>FEED-SPECIAL-TARGETS`, `SWPU|S>LIQUID-BOOST`, `SWPU|X>SMART-SWAP`, `SWPU|X>SMART-SWAP-EXPLICIT-ROUTE`, `SWPU|X>SWAP`

**Functions** — 48, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 8 | returns what an operation will charge | `URCi_RawLiquidPump`, `URCi_SmartSwap`, `URCi_SmartSwapCore`, `URCi_SmartSwapExec`, `URCi_SmartSwapWithBundle`, `URCi_Swap` …+2 |
| `URC_` derived reads | 3 | read and derive; no enforce | `URC_ComputeStoaValueResults`, `URC_DedupFirstTokens`, `URC_PoolStoaValueFromPath` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_Slippage` |
| `UDC_` constructors | 4 | named object constructors | `UDC_Slippage`, `UDC_SlippageObject`, `UDC_SpawnSlippageBounds`, `UDC_SpawnSmartSwapSlippageBounds` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_FilterSelfFromTargets`, `UC_FindStoaPath`, `UC_SlippageMinMax` |
| `XI_` protected (internal) | 10 | this module only | `XI_LiquidIndexPump`, `XI_Pumpdate`, `XI_RawLiquidPump`, `XI_RegisterBundlePaths`, `XI_SmartSwap`, `XI_SmartSwapAndRegister` …+4 |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_SmartSwap` |
| `C_` client | 3 | reached via Talos, never called directly | `C_SmartSwap`, `C_Swap`, `C_ToggleSwapCapability` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 6 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `XI_STOA-PID|OPU`, `XI_STOA-PID|Swap` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `CachedPathOrMiss`, `Slippage`, `SmartSwapPathBundle`, `SwapRoute`, `TokenPathPair`

**Capabilities** -- 24

`GOV`, `GOV|SWPU_ADMIN`, `P|DT`, `P|SWPU|CALLER`, `P|SWPU|REMOTE-GOV`, `SECURE`, `SPWU|C>TOGGLE-SWAP`, `SWPU|C>MULTI-SWAP-NO-SLIPPAGE`, `SWPU|C>MULTI-SWAP-WITH-SLIPPAGE`, `SWPU|C>SINGL-SWAP-NO-SLIPPAGE`, `SWPU|C>SINGL-SWAP-WITH-SLIPPAGE`, `SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE`, `SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE`, `SWPU|C>SMART-SWAP-NO-SLIPPAGE`, `SWPU|C>SMART-SWAP-WITH-SLIPPAGE`, `SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE`, `SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE`, `SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE`, `SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE`, `SWPU|S>FEED-SPECIAL-TARGETS`, `SWPU|S>LIQUID-BOOST`, `SWPU|X>SMART-SWAP`, `SWPU|X>SMART-SWAP-EXPLICIT-ROUTE`, `SWPU|X>SWAP`

**Functions** -- 48, grouped by what the prefix promises

*Cost readers* (8) — price an operation; the exec path and the preview both call these

`URCi_RawLiquidPump`, `URCi_SmartSwap`, `URCi_SmartSwapCore`, `URCi_SmartSwapExec`, `URCi_SmartSwapWithBundle`, `URCi_Swap`, `URCi_SwapCore`, `URCi_ToggleSwapCapability`

*Derived reads* (3) — read and compute; no enforce

`URC_ComputeStoaValueResults`, `URC_DedupFirstTokens`, `URC_PoolStoaValueFromPath`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Slippage`

*Constructors* (4) — build objects

`UDC_Slippage`, `UDC_SlippageObject`, `UDC_SpawnSlippageBounds`, `UDC_SpawnSmartSwapSlippageBounds`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_FilterSelfFromTargets`, `UC_FindStoaPath`, `UC_SlippageMinMax`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_SmartSwap`

*Client entry* (3) — builds the bill; reachable only through Talos

`C_SmartSwap`, `C_Swap`, `C_ToggleSwapCapability`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (12) — this module only; writes under a capability

`XI_LiquidIndexPump`, `XI_Pumpdate`, `XI_RawLiquidPump`, `XI_RegisterBundlePaths`, `XI_STOA-PID|OPU`, `XI_STOA-PID|Swap`, `XI_SmartSwap`, `XI_SmartSwapAndRegister`, `XI_SmartSwapCore`, `XI_SmartSwapExplicitRoute`, `XI_SmartSwapRouter`, `XI_Swap`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`
<!-- @end:module-page:SWPU -->

## Traps

_To be written._
