# ATSU

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:ATSU -->
**On chain**

| | |
|---|---|
| module hash | `ETxfRkJU8ZjBesAThHR06VRP1M3ClMS-gq6tcLg8dF0` |
| deployed size | 115,343 characters |
| implements | `OuronetPolicyV2`, `AutostakeUsageV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 27

`ATSU|C>ADMINISTRATIVE-KICKSTART`, `ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY`, `ATSU|C>COIL`, `ATSU|C>COLD_RECOVERY`, `ATSU|C>CULL`, `ATSU|C>CURL`, `ATSU|C>DEPLOY`, `ATSU|C>FUEL`, `ATSU|C>KICKSTART`, `ATSU|C>NORMALIZE_LEDGER`, `ATSU|C>REDEEM`, `ATSU|C>REMOVE-SECONDARY`, `ATSU|C>SYPHON`, `ATSU|C>WITHDRAW-ROYALTIES`, `ATSU|C>X_KICKSTART`, `ATSU|C>X_REMOVE-SECONDARY`, `ATS|C>DIRECT_RECOVERY`, `ATS|C>HOT_RECOVERY`, `ATS|C>RECOVER`, `GOV`, `GOV|ATSU_ADMIN`, `P|ATSU|CALLER`, `P|ATSU|REMOTE-GOV`, `P|DT1`, `P|DT2`, `P|TT`, `SECURE`

**Functions** — 53, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 14 | returns what an operation will charge | `URCi_Coil`, `URCi_ColdRecovery`, `URCi_Cull`, `URCi_Curl`, `URCi_DirectRecovery`, `URCi_Fuel` …+8 |
| `URC_` derived reads | 2 | read and derive; no enforce | `URC_MultiCull`, `URC_SingleCull` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_FuelableIndex` |
| `XI_` protected (internal) | 7 | this module only | `XI_DeployAccount`, `XI_KickStart`, `XI_MultiCull`, `XI_Normalize`, `XI_RemoveSecondary`, `XI_SingleCull` …+1 |
| `AA_` admin (heavy) | 1 | admin key; reaches a scan somewhere in its tree | `AA_RemoveSecondary` |
| `A_` admin | 1 | admin-key mutations | `A_KickStart` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_RemoveSecondary` |
| `C_` client | 12 | reached via Talos, never called directly | `C_Coil`, `C_ColdRecovery`, `C_Cull`, `C_Curl`, `C_DirectRecovery`, `C_Fuel` …+6 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 5 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|AutostakeKey`, `GOV|Demiurgoi`, `XIv_StoreUnstakeObject` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 27

`ATSU|C>ADMINISTRATIVE-KICKSTART`, `ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY`, `ATSU|C>COIL`, `ATSU|C>COLD_RECOVERY`, `ATSU|C>CULL`, `ATSU|C>CURL`, `ATSU|C>DEPLOY`, `ATSU|C>FUEL`, `ATSU|C>KICKSTART`, `ATSU|C>NORMALIZE_LEDGER`, `ATSU|C>REDEEM`, `ATSU|C>REMOVE-SECONDARY`, `ATSU|C>SYPHON`, `ATSU|C>WITHDRAW-ROYALTIES`, `ATSU|C>X_KICKSTART`, `ATSU|C>X_REMOVE-SECONDARY`, `ATS|C>DIRECT_RECOVERY`, `ATS|C>HOT_RECOVERY`, `ATS|C>RECOVER`, `GOV`, `GOV|ATSU_ADMIN`, `P|ATSU|CALLER`, `P|ATSU|REMOTE-GOV`, `P|DT1`, `P|DT2`, `P|TT`, `SECURE`

**Functions** -- 53, grouped by what the prefix promises

*Cost readers* (14) — price an operation; the exec path and the preview both call these

`URCi_Coil`, `URCi_ColdRecovery`, `URCi_Cull`, `URCi_Curl`, `URCi_DirectRecovery`, `URCi_Fuel`, `URCi_HotRecovery`, `URCi_KickStart`, `URCi_Recover`, `URCi_Redeem`, `URCi_RemoveSecondary`, `URCi_Syphon`, `URCi_UnlimitedUncoilCumulator`, `URCi_WithdrawRoyalties`

*Derived reads* (2) — read and compute; no enforce

`URC_MultiCull`, `URC_SingleCull`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_FuelableIndex`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_RemoveSecondary`

*Client entry* (12) — builds the bill; reachable only through Talos

`C_Coil`, `C_ColdRecovery`, `C_Cull`, `C_Curl`, `C_DirectRecovery`, `C_Fuel`, `C_HotRecovery`, `C_KickStart`, `C_Recover`, `C_Redeem`, `C_Syphon`, `C_WithdrawRoyalties`

*Admin (heavy)* (1) — admin mutation reaching a heavy read

`AA_RemoveSecondary`

*Admin* (6) — admin-key mutations

`A_KickStart`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (7) — this module only; writes under a capability

`XI_DeployAccount`, `XI_KickStart`, `XI_MultiCull`, `XI_Normalize`, `XI_RemoveSecondary`, `XI_SingleCull`, `XI_UUP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|AutostakeKey`, `GOV|Demiurgoi`

*Unclassified* (3) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `XIv_StoreUnstakeObject`
<!-- @end:module-page:ATSU -->

## Traps

_To be written._
