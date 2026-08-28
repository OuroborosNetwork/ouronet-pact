# Handoff: SWP on-chain graph-search engine optimization

## Status: **CLOSED — implemented, measured, proven (2026-08-28); Phase 8 addendum shipped same day, tracked as `#65fL`**

**Naming note (`#65gL`, same day, after Phase 8):** every `DWK`/`DLK` reference below (including
function names like `URC_WorthDWK`) describes the code **as it was at the time each phase shipped** —
left as-is, not rewritten, per this repo's append-only audit convention. The actual current names
in `16_SWPI.pact` are `URC_WorthWSTOA`/`URC_WorthWSTOAFromRaw`/`URC_WorthWSTOAFromGraph`/
`URC_SingleWorthWSTOA`/`URC_SingleSSTOAWorthWSTOA`/`URC_SingleOuroWorthWSTOA` — `DWK`/`DLK` were a
leftover "wrapped/liquid Kadena" naming, renamed to `WSTOA`/`SSTOA` (wrapped/silver STOA, the
already-established real ticker prefixes elsewhere in this codebase). See `ROUND-02-FIXES.md` Fix #46
and `ROUND-01-OWNER-FEEDBACK.md`'s `#65gL` entry for the full writeup, including a real near-miss
(a hardcoded genesis ticker string almost got renamed by mistake) caught before it shipped.

All 32 LOW findings closed first (per the owner's 2026-08-27 sequencing), then this got its own
dedicated design-and-implementation pass, the same way `#34` (`ISSUES-RANKED.md`/`M2`) got its own
multi-phase handoff once it outgrew a single-row fix — see `HANDOFF-swp-exhaustive-path-search.md`
for the precedent this deliberately mirrors. Seven phases were scoped; 6 shipped, 1 was investigated,
measured, and deliberately NOT shipped after the real data contradicted the design intent. Real,
measured cumulative result on the established P2-scale benchmark (`SWP|TX 032z2`, `CC_SmartSwap`,
~102 active pools), cold (zero cache) worst case: **5,094,054 → 1,687,556 gas, a 66.9% reduction**
from the pre-`#65L` baseline — the worst-of-the-worst-case scenario this codebase can construct now
fits **under** the real ~2,000,000 gas ceiling, which it did not before this work. With the cache
warmed by prior bundle-based (dirty-read) swap activity for the same pair — the realistic steady-state
once the system's been running — the same self-searching call drops further to **1,143,255 gas, a
77.6% reduction** from the original baseline (unaffected by Phase 7 — the bundle-based flow never
calls the repricing loop's own self-searching code path).

## Final outcome — all 7 phases

| Phase | What | Result |
|---|---|---|
| **1** | Wire `URCX_Hopper` to the pre-existing-but-unused `SWPT\|PathCache`, plus the topology-versioning fix needed to make a cache entry ever refreshable (previously insert-only, permanent) | **Shipped.** Measured: 477,825 gas (forced miss) → 11,491 gas (real cache hit) for the identical lookup — **~41.6x** on a warm cache. |
| **2 (Tier 1)** | Stop `URC_ComputeAlternateRoutes`'s 3 best-of-K attempts from each independently re-reading and rebuilding the whole graph — fetch each candidate node's raw `SWPT\|Graph` row once, filter in-memory per attempt | **Shipped.** Measured on the P2-scale checkpoint: 4,593,400 → 2,216,311 gas, a **51.7%** reduction. |
| **3** | Binary search over a sorted raw-graph list instead of `UCX_GraphNodeLinks`'s linear scan | **Investigated, built, measured, NOT shipped.** An isolated synthetic benchmark showed binary search winning 2.3-4.9x at 100-300 elements. The real integrated measurement, at the actual P2-scale 143-node graph, showed a net **regression** (+27,527 gas) — isolated and confirmed (reverted only the lookup call, kept everything else) before ruling it out. Reverted cleanly; the real measurement was trusted over the synthetic one. Recorded as a genuine negative result, not silently dropped. |
| **4 (Tier 2)** | Share ONE raw-graph fetch across the STOA-repricing loop's multiple distinct-pool queries (Talos layer), not just within one query's own best-of-3 attempts — enabled by `SWPT::UC_MakeGraphNodes` being provably input/output-independent (one fetch against a given `swpairs` universe is valid for every query against that universe) | **Shipped.** Measured: 2,216,311 → 2,129,569 gas, a further **3.9%**. Correctness proven directly: `URC_PoolValueFromRaw` (shared fetch) returns byte-identical output to the original `URC_PoolValue` (self-fetch) for a real pool, adversarially proven (corrupted the expectation, got a genuine `FAILURE`, restored). |
| **5** | Is best-of-3 still earning its cost at this codebase's real scale? Measured first-found vs best-of-3 directly against the real, organically-grown ~102-pool topology (not a hand-engineered one) across 7 representative pairs (1-8 hops) — best-of-3 beat first-found in zero of them. Switched the live default (`URCX_Hopper`/`URCX_HopperFromRaw`) to first-found only | **Shipped.** Caught and fixed a real bug before shipping: the first attempt used the original, never-Phase-2-optimized self-fetching `URC_ComputeGraphPath` instead of the raw-graph-once path, measured as briefly *more* expensive than best-of-3 — isolated, confirmed, corrected. `SWPT::URC_ComputeAlternateRoutes`/`FromRaw` kept, not deleted, just no longer the default. Original `#34M/M2` adversarial proof (`SWP\|TX 032g`) updated to honestly show the live path now takes the worse route on that deliberately-engineered topology, while a direct call to `URC_ComputeAlternateRoutes` still finds the better one. Measured: 2,129,569 → 1,837,000 gas, a further **13.7%**. |
| **6** | The dirty-read/bundle-based UI flow warms `SWPT\|PathCache` for `boost-path`/`stoa-paths` but NEVER the main `swap-route` — a real, existing gap, not something this session introduced. Owner: the writer wasn't properly set up; it should cache every path it detects and update on a real topology change. `SwapRoute`'s own original doc said it could never be safely cached (best-of-3 was value-comparing, hence amount-sensitive) — checked whether Phase 5 changed that: `SWPT::URC_ComputeGraphPath` takes no amount parameter at all, so the structural first-found route is now provably amount-independent, resolving the original concern | **Shipped.** `XI_RegisterBundlePaths` now also registers `swap-route` (`input-id→output-id`), same version-checked-refresh machinery as the other two categories, correctness re-validated via `URC_ValidatePathActive` before every write. Measured: a self-search for the same pair, after a prior bundle-based swap warmed the cache, dropped from 1,352,614 gas (partial warmth — only the repricing loop benefited) to **1,143,255 gas** once the main route was cached too. Adversarially proven the cache hit returns exactly the cached path. |
| **7** | Owner asked about the repricing loop's own per-pool search cost, observing that a pool's first token is either a Principal itself (`W`/`P` pools, structural) or one hop from *some* Principal (`S` pools, `UEV_Issue`'s `contains-principals` check) — so first-token→DWK searches should usually be short. Checked against the actual P0.5 worst-case topology first: the guarantee bounds Principal *adjacency*, not a Principal's own distance to DWK (Principals aren't required to connect to each other — still-open `P0.3` below), and P0.5's own topology proves this bites (the whole 6-hop chain reaches DWK through one narrow bridge, making `W7`'s repricing search *longer* than the main route) — a Principal-adjacency shortcut wasn't safe to assume in general. Investigating this surfaced a real, assumption-free win instead: `SWPT::UC_BFS`'s cost scales with full graph size regardless of true path depth, and the repricing loop's `URC_PoolValueFromRaw` was rebuilding `SWPT::UC_MakeGraphFromRaw`'s `[GraphNode]` graph (input/output-independent, same as `UC_MakeGraphNodes` underneath it) from scratch on every one of its N distinct-pool queries, despite byte-identical output every time | **Shipped.** Added `URC_ComputeGraphPathFromGraph`/`URC_ShortestChainPerNodeFromGraph` (`SWPT`) and `URCX_HopperFromGraph`/`URC_HopperFromGraph`/`URC_WorthDWKFromGraph`/`URC_PoolValueFromGraph` (`SWPI`) — the `...FromRaw` family, one layer deeper, sourced from an already-built graph. `04_TS01-C3.pact`'s repricing loop builds the graph once, reused across every pool. Correctness adversarially proven byte-identical against `URC_PoolValue`. Measured via controlled before/after (`git stash`): 965,197 → 931,103 gas (**3.5%**) on the P0.5 37-token scenario; 1,837,000 → **1,687,556 gas (8.1% further)** on the P2-scale checkpoint — larger shared universe, bigger win, consistent with the mechanism. Phase 6's warm-cache number is unaffected (bundle-based flow never touches this code path). |
| **8** (tracked as `#65fL`, `#65bL`/Fix #42 was already closed) | Owner asked about direct-pool-swap costs (confirmed already zero pathfinding) and proposed DLK/OURO get zero-search worth shortcuts — DLK already did (index-based, "liquid staking backwards"); OURO didn't, always fell through to the full graph search. Also found, unprompted, that `URC_HopperActiveShortest` (Liquid Boost's own DLK search) was the one Hopper variant Phases 1-7 never touched — no cache check at all | **Shipped (both sub-phases).** 8a: wired `URC_HopperActiveShortest` to `SWPT\|PathCache`, identical Phase 1 pattern — isolated forced-miss-vs-hit: 276,994 → **26,783 gas (90.3%)**. 8b: new `URC_SingleOuroWorthDWK` (off the primordial pool's own reserves) wired as a new `id==OURO` shortcut in `URC_WorthDWK`/`FromRaw`/`FromGraph`. Caught and fixed a real static recursive-cycle compile error and a real pre-bootstrap crash (OURO branch reachable via `UEV_Issue` before any primordial pool exists) before shipping. Caught a real ~928 gas regression on `SWP\|TX 032q`/`032z2` via `git stash` bisection (a naive extra `UR_OuroborosID` read tripling independent reads of the same DALOS row) — fixed with new `DALOS::UR_CanonicalStoaIds` (DWK/DLK/OURO in ONE read). Net effect on the tracked checkpoints (neither shortcut exercised there): **-878/-895 gas**. Isolated 8b win: 110,099 → **2,452 gas (97.8%)** — but flagged explicitly: the shortcut (spot-ratio) and graph-search (simulated-swap) values genuinely differ (~38% apart at a 100-unit test amount), a real values decision left open for owner review, not hidden as equivalent. |

## New functions/tables shipped

- `14_SWPT.pact`: `SWPT|TopologyVersion` table + `TopologyVersionRow` schema; `topology-version` field
  added to `PathCacheRow`; `UR_TopologyVersion`; `XI_BumpTopologyVersion`; `XI_UpdatePair` now bumps
  it on genuine change only; `XI_RegisterPath` now version-checked refresh instead of insert-only;
  `URC_ReadPathCacheFresh`; `RawGraphNode` schema; `URC_FetchRawGraph`; `UC_MakeGraphFromRaw`;
  `URC_ShortestChainPerNodeFromRaw`; `URC_ComputeGraphPathFromRaw`; `URC_ComputeAlternateRoutesFromRaw`
  (`URC_ComputeAlternateRoutes` is now a thin wrapper over it, kept but no longer the live default).
  Phase 7: `URC_ShortestChainPerNodeFromGraph`; `URC_ComputeGraphPathFromGraph` — same shape as the
  `...FromRaw` pair, sourced from an already-built `[GraphNode]` graph instead.
- `16_SWPI.pact`: `URCX_HopperFromRaw`; `URC_HopperFromRaw`; `URC_WorthDWKFromRaw`;
  `URC_PoolValueFromRaw`. `URCX_Hopper`/`URCX_HopperFromRaw` switched from best-of-3
  (`URC_ComputeAlternateRoutes`/`FromRaw`) to single-shot (`URC_ComputeGraphPath`/`FromRaw`) — Phase
  5. Explicit `@doc` caveat added: per-hop greedy edge selection is locally optimal, not a guarantee
  of a globally-optimal path — always true, not introduced by Phase 5. Phase 7:
  `URCX_HopperFromGraph`; `URC_HopperFromGraph`; `URC_WorthDWKFromGraph`; `URC_PoolValueFromGraph` —
  the `...FromRaw` family one layer deeper, sourced from an already-built graph. Phase 8:
  `URC_HopperActiveShortest` gained the same PathCache check (8a). New `URC_SingleDlkWorthDWK`
  (extracted from `URC_WorthDWK`'s own DLK branch, cycle-breaking), `URCX_PrimordialValueAndOuroSupply`
  (shared core extracted from `URC_OuroPrimordialPrice`), `URC_SingleOuroWorthDWK` (8b) — wired as a
  new `id==OURO` shortcut in `URC_WorthDWK`/`FromRaw`/`FromGraph`, gated on the primordial pool
  actually being defined.
- `04_TS01-C3.pact`: `SWP|CC_SmartSwap{With,No}Slippage`'s STOA-repricing loop fetches the raw graph
  once and calls `URC_PoolValueFromRaw` per pool instead of `URC_PoolValue` (Phase 4). Phase 7: also
  builds the `[GraphNode]` graph once (`SWPT::UC_MakeGraphFromRaw`) alongside the raw-graph fetch and
  calls `URC_PoolValueFromGraph` instead.
- `19_SWPU.pact` (Phase 6): `XI_RegisterBundlePaths` gained an `input-id` parameter and now also
  registers the bundle's `swap-route` into `SWPT|PathCache` (validated via
  `SWPI::URC_ValidatePathActive`, same version-checked-refresh path as `boost-path`/`stoa-paths`).
  `SwapRoute`'s own interface doc updated — the original "never cached, amount-sensitive" reasoning
  is now explicitly marked superseded, with the Phase 5 reasoning that resolves it recorded inline.
- `01_DALOS.pact` (Phase 8b): new `CanonicalStoaIds` schema + `UR_CanonicalStoaIds` — DWK/DLK/OURO's
  ids in ONE read of the shared `DALOS|PropertiesTable` row instead of 3 independent single-field
  reads, added after a naive 3-separate-reads first attempt regressed the tracked checkpoints.
- `REPL/Stage_01/[6.3]_SWP.repl`: `SWP|TX 032z6b` (Phase 1 warm-cache proof), `SWP|TX 032z6c`
  (Phase 4 correctness proof), `SWP|TX 032z6d` (Phase 6 swap-route cache proof), `SWP|TX 032z6e`
  (Phase 7 correctness proof), `SWP|TX 032z6f` (Phase 8b shortcut gas+value comparison), `SWP|TX
  032z8a` (Phase 8a warm-cache proof), all adversarially proven and kept permanently. `SWP|TX 032g`
  (`#34M/M2`'s original adversarial proof) updated, not removed, to honestly assert Phase 5's real
  tradeoff on that deliberately-engineered topology, plus a direct proof `URC_ComputeAlternateRoutes`
  still finds the better route when called explicitly.

**UI-design note recorded for the capstone phase** (not a code change in this repo): part of the
reasoning for Phase 5 was that a meaningful share of SmartSwap's real traffic is arguably direct,
single-pool swaps that don't need SmartSwap's routing complexity at all — the UI currently funnels
them through the SmartSwap tab regardless. See
`OuronetInformational/memories/2026-08-28-capstone-ui-needs-a-simplified-direct-pool-swap-interface.md`.

Full suite (`[6.2]`+`[6.3]`) and default issuance-only (`[6.2+3]`) pipelines both verified clean
(exit 0, 0 `FAILURE`) throughout every phase, with `Stage01_Tester.repl` reverted to its default
afterward (zero drift).

---

## Original pre-implementation investigation (kept for context)

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
