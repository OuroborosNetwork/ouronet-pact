# SWPT

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWPT -->
**On chain**

| | |
|---|---|
| module hash | `-g_ye7oMhwnGmEdjZpQkC8C24VMmmkDTxDuOQvQklpk` |
| deployed size | 60,726 characters |
| implements | `OuronetPolicyV2`, `SwapTracerV3` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` |

**Tables it owns** — 5

`P|MT`, `P|T`, `SWPT|Graph`, `SWPT|PathCache`, `SWPT|TopologyVersion`

**Schemas** — 1

`SWPT|GraphSchema`

**Capabilities** — 4

`GOV`, `GOV|SWPT_ADMIN`, `P|SWPT|CALLER`, `SECURE`

**Functions** — 45, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 19 | read and derive; no enforce | `URC_ComputeAllRoutes`, `URC_ComputeAlternateRoutes`, `URC_ComputeAlternateRoutesFromRaw`, `URC_ComputeGraphPath`, `URC_ComputeGraphPathFromGraph`, `URC_ComputeGraphPathFromRaw` …+13 |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_ExcludeEdges`, `UC_FindNeighbourIndex`, `UC_MakeGraphFromRaw` |
| `UR_` readers | 3 | table reads; no enforce, no writes | `UR_Graph`, `UR_PathCacheRaw`, `UR_TopologyVersion` |
| `XI_` protected (internal) | 4 | this module only | `XI_BumpTopologyVersion`, `XI_RegisterPath`, `XI_UpdateGraphForSwpair`, `XI_UpdatePair` |
| `XE_` protected (external) | 2 | for other modules; opens with the IMC gate | `XE_RegisterPath`, `XE_UpdateGraph` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 5 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `URCx_ShortestChainToTarget`, `URCx_ShortestChainToTargetFromGraph`, `URCx_ShortestChainToTargetFromRaw` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `NeighbourEdge`, `PathCacheRow`, `RawGraphNode`, `TopologyVersionRow`

**Capabilities** -- 4

`GOV`, `GOV|SWPT_ADMIN`, `P|SWPT|CALLER`, `SECURE`

**Functions** -- 45, grouped by what the prefix promises

*Derived reads* (19) — read and compute; no enforce

`URC_ComputeAllRoutes`, `URC_ComputeAlternateRoutes`, `URC_ComputeAlternateRoutesFromRaw`, `URC_ComputeGraphPath`, `URC_ComputeGraphPathFromGraph`, `URC_ComputeGraphPathFromRaw`, `URC_EdgeConnects`, `URC_Edges`, `URC_EdgesActive`, `URC_FetchRawGraph`, `URC_MakeGraph`, `URC_ReadPathCache`, `URC_ReadPathCacheFresh`, `URC_RouteEdges`, `URC_ShortestChainPerNode`, `URC_ShortestChainPerNodeFromGraph`, `URC_ShortestChainPerNodeFromRaw`, `URC_TokenNeighbours`, `URC_ValidatePathStructure`

*Point reads* (4) — one row or field by key

`P|UR_IMP`, `UR_Graph`, `UR_PathCacheRaw`, `UR_TopologyVersion`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_ExcludeEdges`, `UC_FindNeighbourIndex`, `UC_MakeGraphFromRaw`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (2) — callable by other modules only

`XE_RegisterPath`, `XE_UpdateGraph`

*Internal writes* (4) — this module only; writes under a capability

`XI_BumpTopologyVersion`, `XI_RegisterPath`, `XI_UpdateGraphForSwpair`, `XI_UpdatePair`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (4) — no known prefix -- worth asking why

`CT_Bar`, `URCx_ShortestChainToTarget`, `URCx_ShortestChainToTargetFromGraph`, `URCx_ShortestChainToTargetFromRaw`
<!-- @end:module-page:SWPT -->

## Traps

_To be written._
