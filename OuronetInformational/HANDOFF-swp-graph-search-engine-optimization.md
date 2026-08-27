# Handoff: SWP on-chain graph-search engine optimization (parked, pre-design)

## Status: **OPEN — parked for a dedicated design pass**

No code has changed for this issue. It is deliberately **not** being designed or implemented yet
— the owner's explicit direction (2026-08-27) was to finish the LOW-item queue (`#66L`–`#71L`)
first, then come back and "carefully churn over" this and any other complex issue that surfaced
along the way, the same way `#34` (`ISSUES-RANKED.md`/`M2`) got its own dedicated multi-phase
handoff once it outgrew a single-row fix. This document exists so the investigation that led here
isn't lost before that dedicated pass happens — see `HANDOFF-swp-exhaustive-path-search.md` for
the precedent this is deliberately mirroring.

## Origin

Surfaced during **`#65L`**'s fix (`Audit/SWP/ROUND-01-OWNER-FEEDBACK.md`, `Audit/SWP/ROUND-02-FIXES.md`
Fix #38): `CC_SmartSwap` (`19_SWPU.pact`) was calling `SWPI::URC_HopperActive` twice for the same
transaction — once in its defcap, once in execution. That specific double-call was fixed (computed
once, threaded through). In the follow-up discussion the owner asked two further questions that
this document answers and parks:

1. *"How many heavy reads does CC_SmartSwap actually have, and is 3 (best-of-3 routing) too many
   for a 1-2 pool swap?"*
2. *"Can't we rewrite the search engine to optimize it, or use a different search engine
   altogether?"*

## What CC_SmartSwap's heavy-read footprint actually is (confirmed, not the originally-assumed shape)

The owner's working memory was "3 searches for the path, then another search for path to DLK" (4
total). Traced the real call chain and found that's incomplete — there are 3 distinct heavy-read
categories, not the 2 the owner had in mind, and the missing one is the dominant cost:

1. **Main routing search** — `CC_SmartSwap` calls `SWPI::URC_HopperActive` exactly once (post-#65L
   fix). Internally, `URC_HopperActive` → `URCX_Hopper` (`16_SWPI.pact:1036`) →
   `SWPT::URC_ComputeAlternateRoutes` (`14_SWPT.pact:366`) runs **up to 3 full BFS graph
   traversals** (best-of-3, edge-disjoint), picking the best payout. This is the source of the
   owner's "3 searches" — they're sub-searches inside one call, not 3 separate top-level calls.
2. **Boost-path search to DLK** — `XI_RawLiquidPump` (`19_SWPU.pact:1693`) calls
   `SWPI::URC_HopperActiveShortest` once, last hop only — a single BFS, not best-of-3. Correctly
   remembered, correctly cheap.
3. **Missing from the owner's count — per-distinct-pool STOA-value repricing, the actual dominant
   cost.** Lives at the Talos layer (`04_TS01-C3.pact:877-882`/`927-932`), immediately after
   `CC_SmartSwap` returns: `map`s over every distinct pool the swap touched and calls
   `SWP::XE_UpdateStoaValue(sp, URC_PoolValue(sp))` for each — and `URC_PoolValue` →
   `URC_WorthDWK` (`16_SWPI.pact:1308`) runs **another full-universe best-of-3 BFS search per
   pool**. A 6-pool route triggers up to 18 more BFS traversals here alone. Per
   `HANDOFF-swp-exhaustive-path-search.md` Phase 5 (P0.6), this is **56.9% of total gas** at the
   102-pool worst-case benchmark — more than routing (10.4%) + boost (7.2%) combined. The
   bundle-based `C_SmartSwap` skips this entirely (pre-supplied `stoa-paths`, no live
   `URC_PoolValue` re-derivation); `CC_SmartSwap` still pays it live, today.

No other heavy reads found in the chain — fee lookups, pool-token-position lookups, and
`URC_DirectRefillAmounts` are all cheap single-key/small-array reads, not graph searches.

## Investigated and REJECTED: widening the search (raising K, or "search 10k")

The owner's first instinct was: since more candidates should be "dirt cheap once the graph is
already found," why not search much wider (10k, or scaled to pool count) instead of capping at 3?

**This premise was checked and found false.** Pact 5 has no per-transaction read cache — every
`read`/`with-read` is charged independently regardless of whether that exact row was read moments
earlier (`OuronetInformational/pact5/SEMANTICS.md:41`). Measured evidence from
`HANDOFF-swp-exhaustive-path-search.md` (lines 331-345, 540-543): additional best-of-K attempts
cost **roughly linear marginal gas (~28k–420k per attempt depending on topology)**, not flattening,
*until* the search structurally exhausts every real route between the two tokens (an early-exit
fold short-circuits once no more distinct routes exist — that's what makes very-high `max-attempts`
values look "free" in the Phase-5 measurement, not caching). A flat "search 10k" on any topology
with real route diversity would cost tens of millions of gas — 10-100x over the real StoaChain
~2,000,000 gas ceiling (`CONTEXT.md`, `HANDOFF-swp-smartswap-bundle-architecture.md:17,215`). "Scale
with pool count" doesn't fix this either — pool count doesn't predict how many distinct routes exist
between two *specific* tokens.

**Conclusion:** widening K is the wrong lever. The real opportunity is eliminating redundant work
within and across the existing (small) K, not doing more of it.

## What's confirmed real and unexploited: read/compute redundancy in the engine itself

Traced `URC_ComputeAlternateRoutes` (`14_SWPT.pact:366-421`) and its full call chain
(`URC_ComputeGraphPath` → `URC_ShortestChainPerNode` → `URC_MakeGraph`,
`URC_TokenNeighbours`/`URC_Edges` reading `SWPT|Graph`). Confirmed, with evidence, two real and
previously-unconsidered redundancies (not a rejected idea — the silence in the code/docs is
absence of thought, not a decision):

1. **Cross-attempt:** each of the K attempts independently re-reads and rebuilds the *entire*
   graph from `SWPT|Graph`, even though the raw table rows are identical across all K attempts —
   only the downstream edge-exclusion filter (which shrinks `swpairs` each round) genuinely
   differs. Nothing in Pact 5 prevents hoisting the raw read/build out of the K-loop and doing
   only the cheap in-memory filtering per attempt.
2. **Within a single attempt:** for a node of degree `d`, `URC_MakeGraph` re-fetches the same row
   `d` times (once per candidate neighbor, `14_SWPT.pact:259-283,550-553`) instead of once.
   Multiplied by K on top of redundancy #1.

**Evidence the compute layer (not just reads) has real headroom too:** Fix #24 (`M4`/`#38M`,
`ROUND-02-FIXES.md`) already proved this shape of win is achievable — rewriting
`UCX_GraphNodeLinks` (`13_U_BFS.pact:144-172`, pure in-memory logic, zero table reads touched) from
a rebuild+linear-search+reindex chain to a single pass cut one `URC_ComputeGraphPath` call by
**39%** (423,762 → 256,867 gas) at the 102-pool topology, with zero change to the reads. So both
the read layer and the traversal/bookkeeping layer independently have real, evidenced gains still
on the table.

**`URC_HopperActiveShortest`'s existing cheapness comes purely from K=1, not a smarter engine** —
confirmed it goes through the exact same `URC_MakeGraph` rebuild-from-reads path, just once instead
of three times.

## Open questions for the dedicated design pass (none answered yet)

- How to restructure `URC_MakeGraph`/`URC_ComputeGraphPath`/`URC_ComputeAlternateRoutes` so the raw
  graph read happens once per transaction and all K attempts (and the per-node d-times refetch)
  operate on that one in-memory structure, while still correctly deriving each attempt's
  edge-exclusion-filtered view.
- Whether the same treatment should extend to the STOA-repricing loop
  (`URC_WorthDWK`/`URC_PoolValue`, the actual dominant 56.9% cost) — it shares the same
  `URC_Hopper`/`URCX_Hopper` core, so a shared-graph fix to routing likely also benefits repricing,
  but this needs to be traced concretely, not assumed.
- Full blast-radius enumeration: every caller of the shared BFS/graph primitives
  (`URC_Hopper`, `URC_HopperActive`, `URC_HopperActiveShortest`, `URC_ComputeAllRoutes`,
  `URC_WorthDWK`) across `13_U_BFS.pact`, `14_SWPT.pact`, `16_SWPI.pact` — a change to shared
  graph-building machinery needs full regression across all of them, not just `CC_SmartSwap`.
- Whether this is scoped as a standalone LOW-queue-adjacent fix, or graduates to its own
  multi-phase master issue the way `#34`/M2 did, once real design work starts.

## Affected files (once design starts — nothing touched yet)

`1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact`, `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`,
`1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`, and transitively `19_SWPU.pact`/`04_TS01-C3.pact`
wherever the shared graph primitives are consumed.
