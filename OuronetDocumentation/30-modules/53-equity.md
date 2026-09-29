# EQUITY

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:EQUITY -->
**On chain**

| | |
|---|---|
| module hash | `hGPNFoA8xk3_PckYuuvMqDKfm33vepnWcNTdPq7DUpk` |
| deployed size | 43,388 characters |
| implements | `OuronetPolicyV2`, `EquityV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 10

`EQUITY|C>BREAK`, `EQUITY|C>CONVERT`, `EQUITY|C>MAKE`, `GOV`, `GOV|EQUITY_ADMIN`, `P|EQUITY|CALLER`, `P|EQUITY|REMOTE-GOV`, `P|GOV-CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 31, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_IssueShareholderCollection`, `URCi_MorphPackageShares` |
| `URC_` derived reads | 4 | read and derive; no enforce | `URC_CombineCapacity`, `URC_MakeSharePackage`, `URC_SharesPerMillion`, `URC_SingleSharePerMillions` |
| `UEV_` validators | 5 | read and enforce; may abort the transaction | `UEV_Convert`, `UEV_EquitySemiFungibleID`, `UEV_Morph`, `UEV_ShareAmountsForMaking`, `UEV_SharePackageTier` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_Convert`, `UC_Description`, `UC_Name` |
| `UR_` readers | 1 | table reads; no enforce, no writes | `UR_TierSupplies` |
| `XI_` protected (internal) | 3 | this module only | `XI_BreakPackageShares`, `XI_ConvertPackageShares`, `XI_MakePackageShares` |
| `C_` client | 2 | reached via Talos, never called directly | `C_IssueShareholderCollection`, `C_MorphPackageShares` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 10

`EQUITY|C>BREAK`, `EQUITY|C>CONVERT`, `EQUITY|C>MAKE`, `GOV`, `GOV|EQUITY_ADMIN`, `P|EQUITY|CALLER`, `P|EQUITY|REMOTE-GOV`, `P|GOV-CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 31, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_IssueShareholderCollection`, `URCi_MorphPackageShares`

*Derived reads* (4) — read and compute; no enforce

`URC_CombineCapacity`, `URC_MakeSharePackage`, `URC_SharesPerMillion`, `URC_SingleSharePerMillions`

*Point reads* (2) — one row or field by key

`P|UR_IMP`, `UR_TierSupplies`

*Validators* (6) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Convert`, `UEV_EquitySemiFungibleID`, `UEV_Morph`, `UEV_ShareAmountsForMaking`, `UEV_SharePackageTier`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_Convert`, `UC_Description`, `UC_Name`

*Client entry* (2) — builds the bill; reachable only through Talos

`C_IssueShareholderCollection`, `C_MorphPackageShares`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (3) — this module only; writes under a capability

`XI_BreakPackageShares`, `XI_ConvertPackageShares`, `XI_MakePackageShares`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:EQUITY -->

## Traps

_To be written._
