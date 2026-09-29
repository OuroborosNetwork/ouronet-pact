# IGNIS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:IGNIS -->
**On chain**

| | |
|---|---|
| module hash | `R7i4tlilH8ARCNFy2h8HPHNrgQvGhgmrHcmLlvvpu50` |
| deployed size | 92,888 characters |
| implements | `OuronetPolicyV2`, `IgnisCollectorV3`, `OuronetInfoV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 12

`GOV`, `GOV|IGNIS_ADMIN`, `IGNIS|C>COLLECT`, `IGNIS|C>CREDIT`, `IGNIS|C>DC`, `IGNIS|C>DEBIT`, `IGNIS|C>TRANSFER`, `IGNIS|S>DISCOUNT`, `IGNIS|S>FREE`, `P|IGNIS|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 78, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 9 | returns what an operation will charge | `DALOS|URCi_ControlSmartAccount`, `DALOS|URCi_DeploySmartAccount`, `DALOS|URCi_DeployStandardAccount`, `DALOS|URCi_RotateGovernor`, `DALOS|URCi_RotateGuard`, `DALOS|URCi_RotateSovereign` …+3 |
| `URC_` derived reads | 7 | read and derive; no enforce | `URC_Exception`, `URC_IsNativeGasZero`, `URC_IsVirtualGasZero`, `URC_IsVirtualGasZeroAbsolutely`, `URC_ZeroEliteGAZ`, `URC_ZeroGAS` …+1 |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_Patron`, `UEV_TwentyFourPrecision` |
| `UDC_` constructors | 21 | named object constructors | `OI|UDC_ClientIgnisCosts`, `OI|UDC_ClientInfo`, `OI|UDC_ClientStoaCosts`, `OI|UDC_DynamicIgnisCost`, `OI|UDC_DynamicStoaCost`, `OI|UDC_FullStoaCosts` …+15 |
| `UC_` pure compute | 14 | arguments only -- no reads, no enforce | `OI|UC_ConvertPrice`, `OI|UC_FormatIndex`, `OI|UC_FormatTokenAmount`, `OI|UC_IfpFromOutputCumulator`, `OI|UC_ShortAccount`, `UC_FeeUnlockPrice` …+8 |
| `UR_` readers | 1 | table reads; no enforce, no writes | `OI|UR_StoaTargets` |
| `XI_` protected (internal) | 4 | this module only | `XI_IgnisCollector`, `XI_IgnisCredit`, `XI_IgnisDebit`, `XI_IgnisTransfer` |
| `XE_` protected (external) | 2 | for other modules; opens with the IMC gate | `XE_CollectIgnis`, `XE_CollectStoa` |
| `XB_` protected (both) | 5 | internal and external | `XB_CollectDalosFuel`, `XB_CollectStoaDiscountedFrom`, `XB_CollectStoaFull`, `XB_CollectStoaWithTrigger`, `XB_MoveDalosFuel` |
| `C_` client | 1 | reached via Talos, never called directly | `C_DonateStoa` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `CT_StoaPrec`, `GOV|Demiurgoi` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `ClientIgnisCosts`, `ClientInfo`, `ClientStoaCosts`, `CompressedCumulator`, `ModularCumulator`, `OutputCumulator`, `PrimedCumulator`

**Capabilities** -- 12

`GOV`, `GOV|IGNIS_ADMIN`, `IGNIS|C>COLLECT`, `IGNIS|C>CREDIT`, `IGNIS|C>DC`, `IGNIS|C>DEBIT`, `IGNIS|C>TRANSFER`, `IGNIS|S>DISCOUNT`, `IGNIS|S>FREE`, `P|IGNIS|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 78, grouped by what the prefix promises

*Cost readers* (9) — price an operation; the exec path and the preview both call these

`DALOS|URCi_ControlSmartAccount`, `DALOS|URCi_DeploySmartAccount`, `DALOS|URCi_DeployStandardAccount`, `DALOS|URCi_RotateGovernor`, `DALOS|URCi_RotateGuard`, `DALOS|URCi_RotateSovereign`, `DALOS|URCi_RotateStoa`, `DALOS|URCi_UpdateEliteAccount`, `DALOS|URCi_UpdateEliteAccountSquared`

*Derived reads* (7) — read and compute; no enforce

`URC_Exception`, `URC_IsNativeGasZero`, `URC_IsVirtualGasZero`, `URC_IsVirtualGasZeroAbsolutely`, `URC_ZeroEliteGAZ`, `URC_ZeroGAS`, `URC_ZeroGAZ`

*Point reads* (2) — one row or field by key

`OI|UR_StoaTargets`, `P|UR_IMP`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Patron`, `UEV_TwentyFourPrecision`

*Constructors* (21) — build objects

`OI|UDC_ClientIgnisCosts`, `OI|UDC_ClientInfo`, `OI|UDC_ClientStoaCosts`, `OI|UDC_DynamicIgnisCost`, `OI|UDC_DynamicStoaCost`, `OI|UDC_FullStoaCosts`, `OI|UDC_IgnisCosts`, `OI|UDC_NoIgnisCosts`, `OI|UDC_NoStoaCosts`, `OI|UDC_StoaCosts`, `UDC_BrandingCumulator`, `UDC_CompressOutputCumulator`, `UDC_ConcatenateOutputCumulators`, `UDC_ConstructOutputCumulator`, `UDC_CustomCodeCumulator`, `UDC_EmptyOutputCumulatorV2`, `UDC_LegCumulator`, `UDC_MakeIDP`, `UDC_MakeModularCumulator`, `UDC_MakeOutputCumulator`, `UDC_PrimeIgnisCumulator`

*Pure compute* (14) — arguments only; no reads, no enforce

`OI|UC_ConvertPrice`, `OI|UC_FormatIndex`, `OI|UC_FormatTokenAmount`, `OI|UC_IfpFromOutputCumulator`, `OI|UC_ShortAccount`, `UC_FeeUnlockPrice`, `UC_FindKeyIndex`, `UC_IgnisComponents`, `UC_IgnisDeter`, `UC_IgnisLeg`, `UC_IgnisPrice`, `UC_IgnisPriceScaled`, `UC_IgnisWeight`, `UC_StoaPrice`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_DonateStoa`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (2) — callable by other modules only

`XE_CollectIgnis`, `XE_CollectStoa`

*Internal + external* (5) — callable both ways

`XB_CollectDalosFuel`, `XB_CollectStoaDiscountedFrom`, `XB_CollectStoaFull`, `XB_CollectStoaWithTrigger`, `XB_MoveDalosFuel`

*Internal writes* (4) — this module only; writes under a capability

`XI_IgnisCollector`, `XI_IgnisCredit`, `XI_IgnisDebit`, `XI_IgnisTransfer`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_StoaPrec`
<!-- @end:module-page:IGNIS -->

## Traps

_To be written._
