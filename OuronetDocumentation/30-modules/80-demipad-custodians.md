# DEMIPAD-CUSTODIANS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DEMIPAD-CUSTODIANS -->
**On chain**

| | |
|---|---|
| module hash | `HSABls9p5hiaRIVxVYOLlBGcJhGEXJCzaHgeutlUxiQ` |
| deployed size | 22,054 characters |
| implements | `OuronetPolicyV2`, `SaleCustodiansV2` |
| repository source | `2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact` |

**Tables it owns** — 3

`CUSTODIANS|T|Properties`, `P|MT`, `P|T`

**Schemas** — 1

`CUSTODIANS|PropertiesSchema`

**Capabilities** — 8

`CUSTODIANS|ACQUIRE`, `CUSTODIANS|C>INITIALISE`, `GOV`, `GOV|CUSTODIANS_ADMIN`, `P|CUSTODIANS|CALLER`, `P|CUSTODIANS|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 28, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 1 | returns what an operation will charge | `URCi_Acquire` |
| `URC_` derived reads | 4 | read and derive; no enforce | `URC_Acquire`, `URC_NonceAmountCosts`, `URC_NonceCosts`, `URC_QuintessenceCosts` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_AcquisitionNonce` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_NonceQuintessence` |
| `UR_` readers | 3 | table reads; no enforce, no writes | `UR_AssetID`, `UR_NonceSaleAvailability`, `UR_QuitessencePrice` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Acquire` |
| `INFO_` cost previews | 1 | client-facing price preview | `INFO_Acquire` |
| `A_` admin | 1 | admin-key mutations | `A_UpdateQuintessencePrice` |
| `C_` client | 1 | reached via Talos, never called directly | `C_Acquire` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 5 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`, `XI_I|AssetId` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 8

`CUSTODIANS|ACQUIRE`, `CUSTODIANS|C>INITIALISE`, `GOV`, `GOV|CUSTODIANS_ADMIN`, `P|CUSTODIANS|CALLER`, `P|CUSTODIANS|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 28, grouped by what the prefix promises

*Cost readers* (1) — price an operation; the exec path and the preview both call these

`URCi_Acquire`

*Derived reads* (4) — read and compute; no enforce

`URC_Acquire`, `URC_NonceAmountCosts`, `URC_NonceCosts`, `URC_QuintessenceCosts`

*Point reads* (4) — one row or field by key

`P|UR_IMP`, `UR_AssetID`, `UR_NonceSaleAvailability`, `UR_QuitessencePrice`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AcquisitionNonce`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_NonceQuintessence`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Acquire`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_Acquire`

*Admin* (6) — admin-key mutations

`A_UpdateQuintessencePrice`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_I|AssetId`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`

*Previews* (1) — operation previews for clients

`INFO_Acquire`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Info`
<!-- @end:module-page:DEMIPAD-CUSTODIANS -->

## Traps

_To be written._
