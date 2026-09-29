# DPDC-T

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-T -->
**On chain**

| | |
|---|---|
| module hash | `RZEeQgiEpyInidQmQnW2Rj3Wnori6vlDmYwuMHBaViY` |
| deployed size | 47,216 characters |
| implements | `OuronetPolicyV2`, `DpdcTransferV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 13

`DPDC-T|C>BULK-TRANSFER`, `DPDC-T|C>REPURPOSE`, `DPDC-T|C>TRANSFER`, `DPDC-T|S>BULK-TRANSFER`, `GOV`, `GOV|DPDC-T_ADMIN`, `IGNIS|C>CREDIT`, `IGNIS|C>DEBIT`, `IGNIS|C>NO-ROYALTY`, `IGNIS|C>ROYALTY`, `P|DPDC-T|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 32, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 3 | returns what an operation will charge | `URCi_BulkTransferCumulator`, `URCi_MultiTransferCumulator`, `URCi_RepurposeCollectable` |
| `URC_` derived reads | 3 | read and derive; no enforce | `URC_SummedIgnisRoyalty`, `URC_TotalTransferPrice`, `URC_TransferRoleChecker` |
| `UEV_` validators | 3 | read and enforce; may abort the transaction | `UEV_AmountsForTransfer`, `UEV_TransferRoleChecker`, `UEV_TransferRoles` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_AggregateRoyalties`, `UC_AndTruths`, `UC_CleanseAggregatedRoyalties` |
| `XI_` protected (internal) | 4 | this module only | `XI_IgnisCredit`, `XI_IgnisDebit`, `XI_IgnisTransfer`, `XI_TransferNonces` |
| `C_` client | 4 | reached via Talos, never called directly | `C_BulkTransfer`, `C_IgnisRoyaltyCollector`, `C_RepurposeCollectable`, `C_Transfer` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `UDCx_AggregatedRoyalties` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `AggregatedRoyalties`

**Capabilities** -- 13

`DPDC-T|C>BULK-TRANSFER`, `DPDC-T|C>REPURPOSE`, `DPDC-T|C>TRANSFER`, `DPDC-T|S>BULK-TRANSFER`, `GOV`, `GOV|DPDC-T_ADMIN`, `IGNIS|C>CREDIT`, `IGNIS|C>DEBIT`, `IGNIS|C>NO-ROYALTY`, `IGNIS|C>ROYALTY`, `P|DPDC-T|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 32, grouped by what the prefix promises

*Cost readers* (3) — price an operation; the exec path and the preview both call these

`URCi_BulkTransferCumulator`, `URCi_MultiTransferCumulator`, `URCi_RepurposeCollectable`

*Derived reads* (3) — read and compute; no enforce

`URC_SummedIgnisRoyalty`, `URC_TotalTransferPrice`, `URC_TransferRoleChecker`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (4) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AmountsForTransfer`, `UEV_TransferRoleChecker`, `UEV_TransferRoles`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_AggregateRoyalties`, `UC_AndTruths`, `UC_CleanseAggregatedRoyalties`

*Client entry* (4) — builds the bill; reachable only through Talos

`C_BulkTransfer`, `C_IgnisRoyaltyCollector`, `C_RepurposeCollectable`, `C_Transfer`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (4) — this module only; writes under a capability

`XI_IgnisCredit`, `XI_IgnisDebit`, `XI_IgnisTransfer`, `XI_TransferNonces`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `UDCx_AggregatedRoyalties`
<!-- @end:module-page:DPDC-T -->

## Traps

_To be written._
