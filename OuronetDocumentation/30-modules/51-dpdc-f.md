# DPDC-F

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-F -->
**On chain**

| | |
|---|---|
| module hash | `3Eppe7LGoy0Vh-1GMxQrUg4sK35Usgsvpv3il89VKR0` |
| deployed size | 27,966 characters |
| implements | `OuronetPolicyV2`, `DpdcFragmentsV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 10

`DPDC-F|C>ENABLE-FRAGMENTATION`, `DPDC-F|C>MERGE`, `DPDC-F|C>NONCE`, `DPDC-F|C>REPURPOSE`, `GOV`, `GOV|DPDC-F_ADMIN`, `P|DPDC-F|CALLER`, `P|DPDC-F|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 22, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 4 | returns what an operation will charge | `URCi_EnableNonceFragmentation`, `URCi_MakeFragments`, `URCi_MergeFragments`, `URCi_RepurposeCollectableFragments` |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_Fragmentation`, `UEV_IzNonceFragmented` |
| `XI_` protected (internal) | 1 | this module only | `XI_EnableNonceFragmentation` |
| `C_` client | 4 | reached via Talos, never called directly | `C_EnableNonceFragmentation`, `C_MakeFragments`, `C_MergeFragments`, `C_RepurposeCollectableFragments` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 10

`DPDC-F|C>ENABLE-FRAGMENTATION`, `DPDC-F|C>MERGE`, `DPDC-F|C>NONCE`, `DPDC-F|C>REPURPOSE`, `GOV`, `GOV|DPDC-F_ADMIN`, `P|DPDC-F|CALLER`, `P|DPDC-F|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 22, grouped by what the prefix promises

*Cost readers* (4) — price an operation; the exec path and the preview both call these

`URCi_EnableNonceFragmentation`, `URCi_MakeFragments`, `URCi_MergeFragments`, `URCi_RepurposeCollectableFragments`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Fragmentation`, `UEV_IzNonceFragmented`

*Client entry* (4) — builds the bill; reachable only through Talos

`C_EnableNonceFragmentation`, `C_MakeFragments`, `C_MergeFragments`, `C_RepurposeCollectableFragments`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_EnableNonceFragmentation`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-F -->

## Traps

_To be written._
