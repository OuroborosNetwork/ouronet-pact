# U|BFS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|BFS -->
**On chain**

| | |
|---|---|
| module hash | `AirILYZ2wfaXuhvEowb8vtNbcY14JnxtUOrvz0y1li0` |
| deployed size | 20,700 characters |
| implements | `BreadthFirstSearchV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|BFS_ADMIN`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UCx_` pure compute (auxiliary) | 8 | a private helper of the function above it | `UCx_ExQeLst`, `UCx_ExStrArrLst`, `UCx_ExStrLst`, `UCx_FilterVisited`, `UCx_GetChains`, `UCx_GraphNodeLinks` …+2 |
| `UC_` pure compute | 2 | arguments only -- no reads, no enforce | `UC_BFS`, `UC_BFSTargeted` |
| *(unclassified)* | 6 | carries no StoicSyntax prefix | `CT_Bar`, `UDCx_AddChains`, `UDCx_AddToQue`, `UDCx_AddVisited`, `UDCx_ExtendChain`, `UDCx_RmFromQue` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `BFS`, `GraphNode`, `QE`

**Capabilities** -- 2

`GOV`, `GOV|U|BFS_ADMIN`

**Functions** -- 16, grouped by what the prefix promises

*Pure compute* (2) — arguments only; no reads, no enforce

`UC_BFS`, `UC_BFSTargeted`

*Unclassified* (14) — no known prefix -- worth asking why

`CT_Bar`, `UCx_ExQeLst`, `UCx_ExStrArrLst`, `UCx_ExStrLst`, `UCx_FilterVisited`, `UCx_GetChains`, `UCx_GraphNodeLinks`, `UCx_PrimalQE`, `UCx_RmFirstQeList`, `UDCx_AddChains`, `UDCx_AddToQue`, `UDCx_AddVisited`, `UDCx_ExtendChain`, `UDCx_RmFromQue`
<!-- @end:module-page:U|BFS -->

## Traps

_To be written._
