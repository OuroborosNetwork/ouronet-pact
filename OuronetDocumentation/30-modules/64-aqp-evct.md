# AQP-EVCT

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-EVCT -->
**On chain**

| | |
|---|---|
| module hash | `hfj0kPp3nbESLFKBJRRpxFheInBRcdM6SeyLGD_VqpU` |
| deployed size | 35,430 characters |
| implements | `OuronetPolicyV2`, `AcquisitionRewardEvictionV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08b_EVCT.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 8

`EVCT|C>EVICT-MULTI`, `EVCT|C>EVICT-SINGLE`, `EVCT|C>FULL-EVICT`, `GOV`, `GOV|EVCT_ADMIN`, `P|EVCT|CALLER`, `P|EVCT|RECIPE`, `SECURE`

**Functions** — 26, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 3 | returns what an operation will charge | `URCi_EvictMultiRewards`, `URCi_EvictSingleReward`, `URCi_FullEvictRewards` |
| `URHC_` heavy derived reads | 3 | a scan, then derivation | `URHC_BuildEvictPlans`, `URHC_BuildEvictSlicePlan`, `URHC_EvictLegCount` |
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_EvictInventory` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_EvictSliceShape` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_CeilDiv`, `UC_EmptyOc`, `UC_EvictLegsFromParallelArrays` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_EvctFvtOwner` |
| `XI_` protected (internal) | 1 | this module only | `XI_EvictLegs` |
| `CCp_` client recipe (heavy) | 1 | multi-transaction, reaches a scan | `CCp_EvictMultiRewards` |
| `CC_` client (heavy) | 2 | client entrypoint; reaches a scan | `CC_EvictSingleReward`, `CC_FullEvictRewards` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 8

`EVCT|C>EVICT-MULTI`, `EVCT|C>EVICT-SINGLE`, `EVCT|C>FULL-EVICT`, `GOV`, `GOV|EVCT_ADMIN`, `P|EVCT|CALLER`, `P|EVCT|RECIPE`, `SECURE`

**Functions** -- 26, grouped by what the prefix promises

*Cost readers* (3) — price an operation; the exec path and the preview both call these

`URCi_EvictMultiRewards`, `URCi_EvictSingleReward`, `URCi_FullEvictRewards`

*Heavy derived reads* (3) — scan and derive -- OFF the execution path

`URHC_BuildEvictPlans`, `URHC_BuildEvictSlicePlan`, `URHC_EvictLegCount`

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_EvictInventory`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_EvictSliceShape`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_CeilDiv`, `UC_EmptyOc`, `UC_EvictLegsFromParallelArrays`

*Ownership checks* (1) — account-ownership enforcement

`CAP_EvctFvtOwner`

*Heavy recipes* (1) — multi-transaction, reaches a heavy read

`CCp_EvictMultiRewards`

*Client entry (heavy)* (2) — reaches a heavy read somewhere in its tree

`CC_EvictSingleReward`, `CC_FullEvictRewards`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_EvictLegs`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:AQP-EVCT -->

## Traps

_To be written._
