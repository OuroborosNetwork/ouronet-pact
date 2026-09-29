# SWP

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWP -->
**On chain**

| | |
|---|---|
| module hash | `vrGyFrynLlEB57ujiG438aENUasqHI2_ppDhLJ6coRg` |
| deployed size | 100,437 characters |
| implements | `OuronetPolicyV2`, `BrandingUsagePrimaryV2`, `SwapperV4` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact` |

**Tables it owns** — 7

`P|MT`, `P|T`, `SWP|Asymmetry`, `SWP|LP`, `SWP|Pairs`, `SWP|Pools`, `SWP|Properties`

**Schemas** — 5

`SWP|AsymmetrySchema`, `SWP|LpTracker`, `SWP|PairsSchemaV3`, `SWP|PoolsSchema`, `SWP|PropertiesSchema`

**Capabilities** — 29

`AHU`, `GOV`, `GOV|SWP_ADMIN`, `P|GOVERNING-CALLER`, `P|SECURE-CALLER`, `P|SWP|CALLER`, `SECURE`, `SPW|S>UPDATE_SPECIAL-FEE-TARGETS`, `SWP|C>ADD-OR-SWAP`, `SWP|C>DEFINE-PRIMORDIAL-POOL`, `SWP|C>ENABLE-FROZEN`, `SWP|C>ENABLE-SLEEPING`, `SWP|C>LIMIT`, `SWP|C>LQBOOST`, `SWP|C>PRINCIPAL`, `SWP|C>ROTATE-PRINCIPAL`, `SWP|C>TG-ASYMETRIC-LQ`, `SWP|C>TG_FEE-LOCK`, `SWP|C>UPDATE-BRD`, `SWP|C>UPGRADE-BRD`, `SWP|GOV`, `SWP|NATIVE-AUTOMATIC`, `SWP|S>RT_CAN-CHANGE`, `SWP|S>RT_OWN`, `SWP|S>UPDATE-AMPLIFIER`, `SWP|S>UPDATE-FEE`, `SWP|S>UPDATE-SUPPLIES`, `SWP|S>UPDATE-SUPPLY`, `SWP|S>WEIGHTS`

**Functions** — 130, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 13 | returns what an operation will charge | `URCi_ChangeOwnership`, `URCi_EnableFrozenLP`, `URCi_EnableSleepingLP`, `URCi_ModifyCanChangeOwner`, `URCi_ModifyWeights`, `URCi_ToggleAddOrSwap` …+7 |
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_OwnedSwapPairs` |
| `URC_` derived reads | 9 | read and derive; no enforce | `URC_ActiveSwpairs`, `URC_AllPoolTokens`, `URC_CheckID`, `URC_IsMajorPrincipal`, `URC_LiquidityFee`, `URC_LpCapacity` …+3 |
| `UEV_` validators | 13 | read and enforce; may abort the transaction | `UEV_AsymetricState`, `UEV_CanChangeOwnerON`, `UEV_CheckAgainst`, `UEV_CheckAgainstMass`, `UEV_CheckTwo`, `UEV_ExecutorIsOwnerKonto` …+7 |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_PoolTokenPosition` |
| `UC_` pure compute | 5 | arguments only -- no reads, no enforce | `UC_CustomSpecialFeeTargets`, `UC_CustomSpecialFeeTargetsProportions`, `UC_ExtractTokenSupplies`, `UC_ExtractTokens`, `UC_PoolTokenPrecisions` |
| `UR_` readers | 34 | table reads; no enforce, no writes | `UR_Amplifier`, `UR_Asymetric`, `UR_CanAdd`, `UR_CanChangeOwner`, `UR_CanSwap`, `UR_FeeLP` …+28 |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Owner` |
| `XI_` protected (internal) | 10 | this module only | `XI_ChangeOwnership`, `XI_EnableFrozenLP`, `XI_EnableSleepingLP`, `XI_IncrementFeeUnlocks`, `XI_ModifyCanChangeOwner`, `XI_SavePool` …+4 |
| `XE_` protected (external) | 6 | for other modules; opens with the IMC gate | `XE_AddLPTracker`, `XE_CanAddOrSwapToggle`, `XE_Issue`, `XE_UpdateStoaValue`, `XE_UpdateSupplies`, `XE_UpdateSupply` |
| `XB_` protected (both) | 1 | internal and external | `XB_ModifyWeights` |
| `A_` admin | 6 | admin-key mutations | `A_DefinePrimordialPool`, `A_RotatePrincipal`, `A_ToggleAsymetricLiquidityAddition`, `A_UpdateLimit`, `A_UpdateLiquidBoost`, `A_UpdatePrincipal` |
| `C_` client | 12 | reached via Talos, never called directly | `C_ChangeOwnership`, `C_EnableFrozenLP`, `C_EnableSleepingLP`, `C_ModifyCanChangeOwner`, `C_ModifyWeights`, `C_ToggleAddOrSwap` …+6 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 9 | carries no StoicSyntax prefix | `AU_SwapPair`, `AU_SwapPairs`, `CT_Bar`, `CT_EmptyCumulator`, `CT_Info`, `GOV|Demiurgoi` …+3 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `FeeSplit`, `PoolTokens`

**Capabilities** -- 29

`AHU`, `GOV`, `GOV|SWP_ADMIN`, `P|GOVERNING-CALLER`, `P|SECURE-CALLER`, `P|SWP|CALLER`, `SECURE`, `SPW|S>UPDATE_SPECIAL-FEE-TARGETS`, `SWP|C>ADD-OR-SWAP`, `SWP|C>DEFINE-PRIMORDIAL-POOL`, `SWP|C>ENABLE-FROZEN`, `SWP|C>ENABLE-SLEEPING`, `SWP|C>LIMIT`, `SWP|C>LQBOOST`, `SWP|C>PRINCIPAL`, `SWP|C>ROTATE-PRINCIPAL`, `SWP|C>TG-ASYMETRIC-LQ`, `SWP|C>TG_FEE-LOCK`, `SWP|C>UPDATE-BRD`, `SWP|C>UPGRADE-BRD`, `SWP|GOV`, `SWP|NATIVE-AUTOMATIC`, `SWP|S>RT_CAN-CHANGE`, `SWP|S>RT_OWN`, `SWP|S>UPDATE-AMPLIFIER`, `SWP|S>UPDATE-FEE`, `SWP|S>UPDATE-SUPPLIES`, `SWP|S>UPDATE-SUPPLY`, `SWP|S>WEIGHTS`

**Functions** -- 130, grouped by what the prefix promises

*Cost readers* (13) — price an operation; the exec path and the preview both call these

`URCi_ChangeOwnership`, `URCi_EnableFrozenLP`, `URCi_EnableSleepingLP`, `URCi_ModifyCanChangeOwner`, `URCi_ModifyWeights`, `URCi_ToggleAddOrSwap`, `URCi_ToggleFeeLock`, `URCi_ToggleFeeLockStoa`, `URCi_UpdateAmplifier`, `URCi_UpdateFee`, `URCi_UpdatePendingBranding`, `URCi_UpdateSpecialFeeTargets`, `URCi_UpgradeBranding`

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_OwnedSwapPairs`

*Derived reads* (9) — read and compute; no enforce

`URC_ActiveSwpairs`, `URC_AllPoolTokens`, `URC_CheckID`, `URC_IsMajorPrincipal`, `URC_LiquidityFee`, `URC_LpCapacity`, `URC_LpComposer`, `URC_PoolTotalFee`, `URC_Swpairs`

*Point reads* (35) — one row or field by key

`P|UR_IMP`, `UR_Amplifier`, `UR_Asymetric`, `UR_CanAdd`, `UR_CanChangeOwner`, `UR_CanSwap`, `UR_FeeLP`, `UR_FeeLock`, `UR_FeeSP`, `UR_FeeSPT`, `UR_FeeUnlocks`, `UR_GenesisRatio`, `UR_GenesisWeigths`, `UR_GetLpSwpair`, `UR_InactiveLimit`, `UR_IzFrozenLP`, `UR_IzSleepingLP`, `UR_LiquidBoost`, `UR_OwnerKonto`, `UR_PoolGenesisSupplies`, `UR_PoolTokenObject`, `UR_PoolTokenPrecisions`, `UR_PoolTokenSupplies`, `UR_PoolTokenSupply`, `UR_PoolTokens`, `UR_Pools`, `UR_Primality`, `UR_PrimordialPool`, `UR_Principals`, `UR_SpawnLimit`, `UR_SpecialFeeTargets`, `UR_SpecialFeeTargetsProportions`, `UR_StoaValue`, `UR_TokenLP`, `UR_Weigths`

*Validators* (14) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AsymetricState`, `UEV_CanChangeOwnerON`, `UEV_CheckAgainst`, `UEV_CheckAgainstMass`, `UEV_CheckTwo`, `UEV_ExecutorIsOwnerKonto`, `UEV_FeeLockState`, `UEV_FeeSplit`, `UEV_FrozenLP`, `UEV_New`, `UEV_PoolFee`, `UEV_SleepingLP`, `UEV_id`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_PoolTokenPosition`

*Pure compute* (5) — arguments only; no reads, no enforce

`UC_CustomSpecialFeeTargets`, `UC_CustomSpecialFeeTargetsProportions`, `UC_ExtractTokenSupplies`, `UC_ExtractTokens`, `UC_PoolTokenPrecisions`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Owner`

*Client entry* (12) — builds the bill; reachable only through Talos

`C_ChangeOwnership`, `C_EnableFrozenLP`, `C_EnableSleepingLP`, `C_ModifyCanChangeOwner`, `C_ModifyWeights`, `C_ToggleAddOrSwap`, `C_ToggleFeeLock`, `C_UpdateAmplifier`, `C_UpdateFee`, `C_UpdatePendingBranding`, `C_UpdateSpecialFeeTargets`, `C_UpgradeBranding`

*Admin* (11) — admin-key mutations

`A_DefinePrimordialPool`, `A_RotatePrincipal`, `A_ToggleAsymetricLiquidityAddition`, `A_UpdateLimit`, `A_UpdateLiquidBoost`, `A_UpdatePrincipal`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (6) — callable by other modules only

`XE_AddLPTracker`, `XE_CanAddOrSwapToggle`, `XE_Issue`, `XE_UpdateStoaValue`, `XE_UpdateSupplies`, `XE_UpdateSupply`

*Internal + external* (1) — callable both ways

`XB_ModifyWeights`

*Internal writes* (10) — this module only; writes under a capability

`XI_ChangeOwnership`, `XI_EnableFrozenLP`, `XI_EnableSleepingLP`, `XI_IncrementFeeUnlocks`, `XI_ModifyCanChangeOwner`, `XI_SavePool`, `XI_ToggleFeeLock`, `XI_UpdateAmplifier`, `XI_UpdateFee`, `XI_UpdateSpecialFeeTargets`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (3) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `GOV|SwapKey`

*Unclassified* (6) — no known prefix -- worth asking why

`AU_SwapPair`, `AU_SwapPairs`, `CT_Bar`, `CT_EmptyCumulator`, `CT_Info`, `URv_PoolTokenPosition`
<!-- @end:module-page:SWP -->

## Traps

_To be written._
