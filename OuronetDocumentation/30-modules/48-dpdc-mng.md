# DPDC-MNG

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-MNG -->
**On chain**

| | |
|---|---|
| module hash | `AY_6AZS-OL1SmgnHwZJ0UH5YebfIxZQh7cbFp8BOMJw` |
| deployed size | 57,849 characters |
| implements | `OuronetPolicyV2`, `DpdcManagementV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 20

`DPDC-MNG|C>ADD-QUANTITY`, `DPDC-MNG|C>BURN-NFT`, `DPDC-MNG|C>BURN-SFT`, `DPDC-MNG|C>IZ-CLASS-ZERO`, `DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES`, `DPDC-MNG|C>RESPAWN-NFT`, `DPDC-MNG|C>WIPE-NFT`, `DPDC-MNG|C>WIPE-NFT-NONCE`, `DPDC-MNG|C>WIPE-NFT-NONCES`, `DPDC-MNG|C>WIPE-SFT`, `DPDC-MNG|C>WIPE-SFT-NONCE-PARTIALLY`, `DPDC-MNG|C>WIPE-SFT-NONCE-TOTALLY`, `DPDC-MNG|C>WIPE-SFT-NONCES`, `DPDC-MNG|S>CTRL`, `DPDC-MNG|S>TG_PAUSE`, `GOV`, `GOV|DPDC-MNG_ADMIN`, `P|DPDC-MNG|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 49, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 9 | returns what an operation will charge | `URCi_AddQuantity`, `URCi_BurnNFT`, `URCi_BurnSFT`, `URCi_Control`, `URCi_RespawnNFT`, `URCi_TogglePause` …+3 |
| `URHC_` heavy derived reads | 2 | a scan, then derivation | `URHC_BuildWipeSlicePlan`, `URHC_WipePure` |
| `URC_` derived reads | 2 | read and derive; no enforce | `URC_FilterAccountViableNonces`, `URC_FilterClassZeroNonces` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_ExecutorIsCollectionOwner` |
| `UDC_` constructors | 2 | named object constructors | `UDC_RemovableNonces`, `UDC_WipeSlicePlan` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_TakePureWipe` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_BuildWipeSlicePlan`, `UC_CeilDiv`, `UC_ComputeMinWipeSliceCount` |
| `XI_` protected (internal) | 5 | this module only | `XI_Control`, `XI_DecreaseClassZeroNonFungibles`, `XI_DecreaseClassZeroSemiFungibles`, `XI_IncreaseClassZeroSemiFungible`, `XI_TogglePause` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_WipeHeavy` |
| `Cp_` client recipe | 1 | multi-transaction | `Cp_WipeSlice` |
| `C_` client | 11 | reached via Talos, never called directly | `C_AddQuantity`, `C_BurnNFT`, `C_BurnSFT`, `C_Control`, `C_RespawnNFT`, `C_TogglePause` …+5 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `DPDC-MNG|WipeSlicePlan`, `RemovableNonces`

**Capabilities** -- 20

`DPDC-MNG|C>ADD-QUANTITY`, `DPDC-MNG|C>BURN-NFT`, `DPDC-MNG|C>BURN-SFT`, `DPDC-MNG|C>IZ-CLASS-ZERO`, `DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES`, `DPDC-MNG|C>RESPAWN-NFT`, `DPDC-MNG|C>WIPE-NFT`, `DPDC-MNG|C>WIPE-NFT-NONCE`, `DPDC-MNG|C>WIPE-NFT-NONCES`, `DPDC-MNG|C>WIPE-SFT`, `DPDC-MNG|C>WIPE-SFT-NONCE-PARTIALLY`, `DPDC-MNG|C>WIPE-SFT-NONCE-TOTALLY`, `DPDC-MNG|C>WIPE-SFT-NONCES`, `DPDC-MNG|S>CTRL`, `DPDC-MNG|S>TG_PAUSE`, `GOV`, `GOV|DPDC-MNG_ADMIN`, `P|DPDC-MNG|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 49, grouped by what the prefix promises

*Cost readers* (9) — price an operation; the exec path and the preview both call these

`URCi_AddQuantity`, `URCi_BurnNFT`, `URCi_BurnSFT`, `URCi_Control`, `URCi_RespawnNFT`, `URCi_TogglePause`, `URCi_WipeCumulator`, `URCi_WipeNonce`, `URCi_WipeSlim`

*Heavy derived reads* (2) — scan and derive -- OFF the execution path

`URHC_BuildWipeSlicePlan`, `URHC_WipePure`

*Derived reads* (2) — read and compute; no enforce

`URC_FilterAccountViableNonces`, `URC_FilterClassZeroNonces`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_ExecutorIsCollectionOwner`

*Constructors* (2) — build objects

`UDC_RemovableNonces`, `UDC_WipeSlicePlan`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_TakePureWipe`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_BuildWipeSlicePlan`, `UC_CeilDiv`, `UC_ComputeMinWipeSliceCount`

*Recipes* (1) — multi-transaction, no heavy read

`Cp_WipeSlice`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_WipeHeavy`

*Client entry* (11) — builds the bill; reachable only through Talos

`C_AddQuantity`, `C_BurnNFT`, `C_BurnSFT`, `C_Control`, `C_RespawnNFT`, `C_TogglePause`, `C_WipeClean`, `C_WipeDirty`, `C_WipeNonce`, `C_WipePure`, `C_WipeSlim`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (5) — this module only; writes under a capability

`XI_Control`, `XI_DecreaseClassZeroNonFungibles`, `XI_DecreaseClassZeroSemiFungibles`, `XI_IncreaseClassZeroSemiFungible`, `XI_TogglePause`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-MNG -->

## Traps

_To be written._
