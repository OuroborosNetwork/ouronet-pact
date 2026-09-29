# U|BFS — breadth-first search

## What it is for

A general breadth-first search over a graph, with an early-exit variant that stops once the target is reached.

The swap layer uses it to find trade routes across the pool graph, where tokens are nodes and pools are edges.

## Where it sits

A leaf utility. Deliberately generic — it knows nothing about pools, which is why the swap layer's depth cap is applied outside it rather than within.

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

**The depth cap is not in the search.** It is a post-discovery filter, and the deviation is documented at the site: baking a bound into a shared utility would change a lower layer with other callers. The consequence is worth knowing — the submitted-route swap variant validates against a 7-node cap explicitly, while the self-searching variant is bounded by the **size of the graph** rather than by a hop count. Different guarantees.

**A node set narrower than the edge set corrupts long routes.** An earlier version built nodes from a filtered list while edges came from the full one, so the search could expand into a token with no node entry. Both now derive from the same source by construction.
