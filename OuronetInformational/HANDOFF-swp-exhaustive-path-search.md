# Handoff: SWP exhaustive on-chain cheapest-path search (SmartSwap Phase 2)

## #34 — Master phase list (consolidated, 2026-08-21)

Everything in this document — the original best-of-3 approximation fix, the worst-case gas
crisis it led to discovering, and the dirty-read infrastructure now designed to fix that
crisis — is, at the owner's direction, one single issue: **#34** (`ISSUES-RANKED.md`/`M2`).
Fix #19 closed the *approximation* problem (best-of-3 instead of first-found) but was never
the full resolution the owner originally wanted (a genuinely exhaustive cheapest-path search);
everything below is the complete path from where Fix #19 left off to that original goal,
**13 phases, 5 done, 8 remaining.** Detailed design for each phase lives in the sections below
this list (old `P0.x` numbering for phases 1-5, `P3.x` for phases 6-10 — kept as-is rather than
renumbered, to avoid breaking existing cross-references); phases 11-13 are new, not yet
detailed below at the same depth, to be expanded when their turn comes.

- [x] **Phase 1 — Approximate fix: best-of-3 routing.** Fix #19 (`SWPT::URC_ComputeAlternateRoutes`,
      up to 3 edge-disjoint candidates, `SWPI::URCX_Hopper` picks the best by payout) + Fix #20/
      #34bM (Stable-pool anchoring requires direct principal adjacency). Shipped, adversarially
      proven, **stays live as the production default through every later phase** — nothing here
      removes it, later phases add alongside it.
- [x] **Phase 2 — Worst-case execution-gas discovery.** P0.5: built a real 6-hop/maximal-pool
      topology and found Liquid Boost alone pushes worst-case gas over the 2,000,000 ceiling —
      a problem unrelated to routing *quality*, purely about whether *any* route can execute.
- [x] **Phase 3 — First-round Liquid Boost gas fixes.** Direction 1 (`SWPI::URC_HopperActiveShortest`,
      single-shortest routing for the boost pump instead of best-of-3) + direction 5 (carry the
      boost value forward hop-by-hop, one search per swap instead of one per hop). Cut the
      Liquid-Boost-only worst case 3,039,431 → 1,963,025 gas.
- [x] **Phase 4 — Uncovering the real worst case.** Owner directly challenged the "special-fee
      transfers are cheap" claim; checked and found the worst-case test's special-fee *rate*
      had always been 0.0 — the expensive `C_MultiBulkTransfer(7 targets)` path had never once
      actually executed in any measurement. Fixed the test, found the real worst case blows the
      ceiling by 148,758 gas even with Phase 3's fixes. Rebuilt special-fee-target batching
      (real savings this time, 18,286 gas, confirmed with isolated component measurement) —
      still 130,472 gas over ceiling.
- [x] **Phase 5 — Real-scale topology proof.** Built a real (not synthetic) 22→102-active-pool
      topology. Worst-case gas balloons to 6-7 million — 3.5x over ceiling at just 42 pools.
      Decomposed the cost on request ("is it just the boost search?"): main routing search
      10.4%, Liquid Boost search 7.2%, **`XE_UpdateStoaValue`'s six per-pool searches 56.9% —
      previously unknown, now confirmed the dominant driver, bigger than the other two
      combined.**
- [ ] **Phase 6 — Dirty-read infrastructure: schemas + module placement.** Path-cache table
      (lives in `SWPT`), bundle input object, output-results mechanism. Resolve the open
      questions still listed in P3.10 (table-key canonicalization, whether the pool-count
      fast-path ships in v1, exact `OutputCumulator` extension mechanism) before/while building.
- [ ] **Phase 7 — Dirty-read infrastructure: core functions.** Structural + active/exists-mode
      validation (`SWPT` for exists-only, `SWPI` wrapping it with `SWP::UR_CanSwap` for
      active-required), reversed-lookup read helper, first-write-wins registration writer,
      dedup logic for stoa-value pricing (validated with real evidence — two pools sharing a
      first token cost an identical 673,080 gas each in the Phase 5 topology).
- [ ] **Phase 8 — New SmartSwap entrypoint.** New bundle-based `XI_SmartSwapCore` variant;
      `SWP|C_SmartSwapExplicitRoute` in Talos, **built alongside, not replacing,** the existing
      self-searching variants, for real A/B gas comparison; dumb-writer stoa-value updater
      (Talos maps over pre-computed results instead of calling `URC_PoolValue` itself); fixes
      the long-standing `XI_RawLiquidPump` crash bug as a natural side effect (same sentinel-
      handling the new design needs anyway); slippage + IGNIS billing wiring.
- [ ] **Phase 9 — Off-chain/UI orchestration + docs.** Spec for how a client constructs the
      bundle via dirty reads (P3.7); architecture doc (what P5.5 originally covered, now scoped
      to the whole redesign, not just the search primitives).
- [ ] **Phase 10 — Testing, adversarial proof, regression.** Real measured old-vs-new gas
      comparison (the actual number the owner asked for — "how much does outsourcing dirty
      reads bring us" — report once measured, not estimated); adversarial malformed-bundle
      proof; full regression (issuance-only, full `[6.2]`/`[6.3]`, `Z.repl`).
- [ ] **Phase 11 — The original #34 ask: genuine exhaustive route discovery.** Build
      `SWPT::URC_ComputeAllRoutes` (real parameterized fold over `max-attempts`, not a fixed
      best-of-3) — this is what actually finds the *true* cheapest path, not an approximation.
      Run via dirty read, feeds Phase 8's bundle's `swap-route` component. Depth-cap (7-token/
      6-hop) enforcement baked into the search itself. Hand-verified small-topology proof
      against the owner's own worked examples (was `P1` in the old roadmap below).
- [ ] **Phase 12 — Realistic-scale validation of the exhaustive search.** Measure
      `URC_ComputeAllRoutes`'s own cost/candidate-count at 50-100-pool scale via dirty read
      (was `P2` in the old roadmap below) — confirms the *whole* pipeline (exhaustive discovery
      + Phase 8's cheap injection) end to end, with real numbers, not estimates.
- [ ] **Phase 13 — Final audit trail + docs.** Update `ROUND-02-FIXES.md`, `README.md`,
      `ISSUES-RANKED.md`, `ROUND-01-OWNER-FEEDBACK.md` to reflect #34's full, 13-phase
      resolution; final "what was added/modified/where" summary per the owner's standing
      requirement from early in this effort, verified in REPL.

**Sequencing note:** phases 6-10 (the gas-ceiling infrastructure) are more urgent than 11-12
(the original routing-quality ask) — the protocol can't safely operate at scale without 6-10
regardless of routing quality, whereas 11-12 is the originally-requested improvement layered on
top once the foundation exists. Phase 8's new entrypoint can ship using Phase 1's existing
best-of-3 search to fill `swap-route` initially, and get upgraded to Phase 11's genuinely
exhaustive search later — 6-10 and 11-12 are not hard-blocked on each other, just naturally
sequenced by urgency.

**Status:** IN PROGRESS. P0.5 done. **P0.6 REOPENED, 2026-08-21 — was wrongly marked done.**
Direction 1 + direction 5 (single-shortest-path boost routing, then carrying the boost value
forward hop-by-hop so only the last hop searches) shipped and genuinely got the Liquid-Boost-
only worst case from 3,039,431 to 1,963,025 gas — real, still stands. But that figure turned
out to be measured against an **incomplete** worst-case test: `SWP|TX 032p` configured
special-fee-target accounts without ever activating the special-fee rate itself
(`fee-special` defaulted to 0.0), so the expensive `C_MultiBulkTransfer(7 targets)` payout
path had never once actually executed in any measurement taken during this whole effort —
confirmed only after the owner directly challenged the "it's all cheap" conclusion from a
special-target re-check. Isolated the real cost properly: one 7-target `C_MultiBulkTransfer`
= 38,125 gas; as 7 separate 1-target calls = 110,658 gas — the owner's original 20-30k/call
estimate was right. With the test corrected to actually exercise this path, the real
worst-case is **2,148,758 gas (148,758 over ceiling) unbatched, 2,130,472 gas (130,472 over
ceiling) after rebuilding and keeping the special-fee-target batching fix** (real, positive,
18,286 gas saved, not nearly enough alone). Separately, the earlier "super-linear pool-count
scaling" claim (from a 9-vs-22-pairs comparison) was found to be confounded (two different
source tokens, not a controlled test) and was withdrawn after a proper controlled
re-measurement showed sub-linear scaling instead — but that was superseded almost immediately
by a **much more severe, real (not synthetic) finding**: built an actual 22→102-active-pool
topology (80 new `OURO`-anchored pools) and re-measured the real worst case at each step —
**6,076,821 gas at 42 pools; 7,145,276 gas at 102 pools. Every checkpoint blows the ceiling,
up to 3.5x over.** Root mechanism confirmed, not just observed: every new pool must anchor to
a principal (structural requirement), `OURO` sits directly on the Liquid Boost search path, so
any organic protocol growth inflates the exact hub node that search has to traverse. **This
means none of P0.6's fixes so far are sufficient at realistic scale — the underlying live-
graph-search design itself doesn't hold up, not just this or that call site.** Full
chronological trace (what was claimed, disproven, corrected, and finally the real-topology
result) is in the dated entries below. Also still open: a separate, unfixed crash bug in
`XI_RawLiquidPump` (found alongside P0.5, not yet formally numbered in `ISSUES-RANKED.md`).
P1 (core search primitives) not started as its own workstream — its output (route discovery)
is still needed, but as an input to P3 below, not as the primary fix.

**Current plan, as of 2026-08-21, fully written down: `### P3 — SmartSwap redesign: dirty-read
path injection`** (scroll down). Push all path discovery off-chain via dirty reads; the real
transaction receives a bundle (swap route + boost's B→DLK path + deduped per-pool stoa-value
paths), validates structurally, executes, and only writes a shared any-token-to-any-token path
cache table when something was genuinely new. This single design targets all three cost
sources at once — the main routing search (10.4% of the 102-pool total), Liquid Boost's search
(7.2%), and `XE_UpdateStoaValue`'s six per-pool searches (**56.9%, the actual dominant cost,
not Liquid Boost** — found only because the owner asked "is it just the boost search?" and it
was checked, not assumed). Full schemas (path-cache table, bundle object, output-results
list), module placement respecting deploy order, security/abuse mitigations, an off-chain/UI
orchestration spec, and a testing plan are all written out in P3.0-P3.10. **Not yet built.**
P3.10 lists explicit open questions (table-key canonicalization, whether to include the
pool-count fast-path in v1, exact `OutputCumulator` extension mechanism) that need resolving
before or during implementation — everything else in P3 is settled enough to start coding
against once those are answered.

**To:** whoever picks up SWP audit follow-up work next.
**From:** 2026-08-20 SWP audit session (#34M/M2 follow-up discussion).

## The issue, precisely

The current `SmartSwap` routing (`SWP|C_SmartSwapWithSlippage`/`NoSlippage`, via
`SWPI::URCX_Hopper` → `SWPT::URC_ComputeAlternateRoutes`) does **not** find the true
cheapest route between two tokens. It's a bounded best-of-3 heuristic: it finds up to 3
edge-disjoint candidate routes (fixed cap, `ROUND-02-FIXES.md` Fix #19) and picks the best
of those. If a 4th (or 40th) genuinely different route exists and it's cheaper, SmartSwap
will never find it.

The owner's original intent — confirmed explicit in this session — is a fully on-chain
mechanic that finds the **actual** cheapest path, not a bounded approximation. That's the
target of this effort. Fix #19 (best-of-3) stays live in production as the current
default/fallback; this is an additive Phase 2, not a replacement in progress.

## What we established this session (read before starting)

1. **#34bM (already shipped, `Fix #20`)** made `UEV_Issue`'s Stable-pool anchoring check
   require *direct* (one-hop) principal adjacency instead of transitive multi-hop BFS
   reachability. This genuinely bounds **path depth**: owner's own worked example
   (`EKOSON→AKOSON→OURO→SSTOA→VST→cVST`, 5 hops with 2 principals; add a 3rd principal
   bridge and it's 6) — max realistic depth is **5-6 hops**, not unbounded. This part is
   solid and confirmed.

2. **Depth-bounded does NOT mean path-*count*-bounded.** This was the key correction this
   session landed on. `UEV_Issue`'s `contains-principals` check fires true if a principal
   appears **anywhere** in a new pool's token list, not just position 0 — so *any* existing
   token can get a brand-new direct pool straight to *any* principal at any time, with zero
   prior connection required. Nothing bounds how many different "bridge" tokens/pools people
   create this way. So the number of *distinct candidate routes* between two tokens can grow
   with however many bridge-style pools exist — not with a small function of hop count.
   Earlier claim in this session that "paths ≤ pools" was **wrong** for this reason (though a
   related, weaker claim about *economically-relevant* paths being bounded may still hold —
   see the pruning rule below).

3. **Shortest path is NOT always cheapest — proven with a concrete counter-example,**
   not just argued: a badly-imbalanced direct 1-hop pool (reserves 100,000/100) gives ~0.99
   output for a 1000-unit input; a 2-hop route through two balanced pools (1000/1000 each)
   gives ~333.3 for the same input — over 300x more, despite paying two fee-hops instead of
   one. Fee cost per hop is small and bounded (~0.1-1% typically); pool mispricing is
   unbounded. **The search must compare routes by actual computed output, never by hop count
   as a proxy.** Hop count only bounds *how far the search needs to look* (see point 1), it
   must never be used to decide *which route wins*.

4. **One legitimate, provably-safe pruning rule exists:** never consider a candidate route
   that uses 2+ edges from the *same originating pool* when that pool already offers a direct
   edge between the same two tokens — such a route is always dominated (you'd be paying that
   pool's fee/slippage twice for no benefit, since the direct edge from the same pool was
   already available in one hop). This eliminates the *combinatorial* explosion a single
   large multi-token pool's internal clique would otherwise create (a 7-token pool has up to
   ~300+ internal simple paths between two of its own members). It does **not** eliminate the
   bridge-pool explosion from point 2 — that one is real and needs to be measured, not proven
   away.

5. **Dirty-read + locked-function is the right architecture, and it's already
   precedented in this codebase** (`OuronetInformational/memories/2026-08-14-selects-dirty-
   read-and-purpose-built-tables.md`, from the AQP audit's prior work): run the expensive
   enumeration in dirty-read/local mode (free, non-consensus — no gas cost to the caller),
   then feed the discovered result as an argument into a real, capability-locked transaction
   that just executes it. Safe because a stale/wrong candidate route can only make the
   *outcome* worse (caught by the existing slippage floor), never corrupt state. Real gas
   numbers already measured this session for the search primitives: one `URC_ComputeGraphPath`
   call ≈ 23,764 gas; each additional best-of-K attempt ≈ 28,000 gas marginal — cheap
   individually, the open question is purely *how many* attempts an exhaustive search needs
   at realistic scale.

## Purpose (restate before building anything)

Build a genuinely exhaustive (not fixed-K), pruned, on-chain-state-driven search that finds
the *actual* cheapest route between any two tokens — using dirty-read/local execution so the
search itself costs the caller nothing — then feed that discovered route into a real,
slippage-protected transaction. This is "on-chain mechanics doing what others do off-chain,"
except the search queries live canonical chain state directly instead of a separately-
maintained off-chain index that can go stale.

## Correction (2026-08-20, later same session): the "same-pool-detour" pruning rule is NOT needed

Point 4 above proposed a pruning rule for candidates that reuse the same originating pool
across 2+ hops. Verified `SWPT::XI_UpdateGraphForSwpair` directly: a k-token pool's issuance
does a full `i × j` double loop registering an edge for **every** pair of its tokens — a
complete clique, not a chain. Combined with `U|BFS::UC_BFS` always finding the *shortest*
path to any node, this means BFS can never route `A→Y→W` through the same pool for both legs
when that pool already offers a direct `A→W` edge — it would find the direct edge first, at a
shorter distance. A single discovered route structurally cannot reuse the same pool twice.
No separate pruning mechanism needed for this — it falls out of BFS + the clique property for
free. Don't build it.

## Full roadmap (granular, checkable, referenced by tag going forward)

Every future turn on this project should name the tag(s) it's working on (e.g. "building
P1.2"). Update the checkboxes here as items land.

### P0 — Groundwork / open decisions / foundational validation (resolve before or during P1)
- [ ] **P0.1** Confirm Kadena's actual `/local` (dirty-read) resource/gas ceiling — chain-level
      property, not in this repo; research externally or ask the owner directly.
- [x] **P0.2** Settled (2026-08-20): `max-attempts` escalation is a plain caller-side retry —
      try 1000; if the result hit exactly 1000 with no natural exhaustion (meaning there may be
      more), retry with 2000; then 3000; flat `+1000` steps, no doubling (dropped — the
      short-circuit already makes a fresh 1000-attempt search cheap when the real count is
      low, which is the expected common case, so a more complex growth curve isn't worth it).
      A genuine **outer hard stop** still exists above this escalation — placeholder value
      **50,000**, proposed as a backstop default, not researched/considered — owner may
      override. `URC_ComputeAllRoutes` enforces this outer stop regardless of requested
      `max-attempts`.
      **On-chain path-count caching (proposed, then evaluated and dropped):** would have
      needed a table keyed by canonicalized `TokenA-BAR-TokenB` storing last-known path count,
      to skip straight to a good starting `max-attempts` instead of 1000. Rejected for now:
      (a) dirty-read/`/local` execution is non-consensus, so the cache could never be written
      *during* the free searches themselves — only as a side effect of the real committed
      execute-route transaction (P3.2), adding real complexity to that path; (b) the
      short-circuit already makes a fresh 1000-attempt search cheap for the expected common
      case (path count well under 1000); (c) caching only pays for itself if path counts
      routinely exceed 1000, which is unconfirmed — P2 will show this empirically. Revisit only
      if P2's real numbers justify it; it's a pure add-on, not a foundational decision, so
      nothing else here needs to change to add it later.
- [ ] **P0.3** Decide: enforce "new principals must connect to an existing primordial
      principal" as an actual code check (in `A_UpdatePrincipal`/`A_RotatePrincipal`), or leave
      as a governance convention only. Not required for correctness of this feature (point 5,
      original doc) — purely a connectivity-maximizing choice, owner's call.
- [x] **P0.4** Max path depth decided by owner (2026-08-20): **hard cap of 7 tokens / 6 hops
      per candidate route** ("the sexy number 7," matching the existing 2-7-tokens-per-pool
      convention). Still needs an enforcement *design*: ideally baked into the BFS/graph-walk
      itself (bound the traversal depth directly, cheaper) rather than only as a post-discovery
      filter (wasteful — would still pay to explore and discard depth-8+ candidates). Land this
      as part of building P1.1.
- [x] **P0.5 — DONE, 2026-08-20. Two numbers, not one — the second one is the real problem.**
      Built a real 7-token/6-hop chain (`W1→W2→...→W7`, `W1`/`W4`/`W7` registered as real
      principals at the start/middle/end so every pool's anchoring requirement is satisfied by
      tokens already on the route, no accidental shortcut), every one of the 6 pools maximally
      sized (7 members: the 2 route tokens + 5 unique per-pool filler tokens, never shared
      across pools — sharing them would itself create a hub shortcut, caught before building),
      each with 7 special fee targets configured, issued via the `p=true` permissioned bypass
      (brand-new principals have no prior trading history to price against the spawn-limit
      check; the anchoring rule itself still applies regardless of `p`). One wrinkle found and
      fixed along the way: `URC_PoolValue` prices a pool using only its *first* token's DWK
      worth (`URC_WorthDWK`→`URC_Hopper(token, DWK, ...)`, a real reachability search), and
      `SWP|C_ToggleSwapCapability` requires that worth clear an inactive-limit floor — fixed
      with one small throwaway `{OURO, W1}` pool giving the whole transitively-connected chain
      real priceable worth without touching the route itself.
      - **With `SWP::UR_LiquidBoost` off (the pipeline's default at that point, confirmed via
        diagnostic, not assumed): 1,694,006 gas.** Fits under ~2,000,000, ~15% headroom.
      - **With Liquid Boost explicitly turned on (owner-flagged: this was missing from the
        first measurement and matters): 3,039,431 gas — exceeds the ~2,000,000 ceiling by
        over 1,000,000 gas.** `UDC_PoolFees` (`17_SWPL.pact`) sets `boost-fee = (if
        UR_LiquidBoost lp-fee 0.0)` — a *global* toggle, not per-pool — so when it's on, every
        hop of a SmartSwap fires `XI_LiquidIndexPump`/`XI_RawLiquidPump`, each of which runs
        its *own* full `URC_HopperActive(hop-token, DLK, amount)` search plus a real DPTF burn.
        6 hops × a real BFS search each is where the extra ~1.3M gas comes from. This cost also
        scales with *total active pool count in the whole protocol* (same reason plain BFS
        search cost does) — as the real system grows, this gap only widens, it doesn't stay
        fixed at 1.3M forever.
      - **A real, separate bug found while measuring this, not fixed here:**
        `XI_RawLiquidPump` (`19_SWPU.pact:993-997`) does
        `(final-boost-output:decimal (at 0 (take -1 ovs)))` on the `URC_HopperActive` search
        result with no empty-check — if a hop's token has no *active* route to DLK (exactly
        what happened here before the anchor pool was activated), this crashes
        ("Array index out of bounds") instead of failing cleanly or skipping the boost. Same
        *class* of bug as the M3 finding (unguarded indexing into a search result that can
        legitimately come back empty), not yet reviewed in this audit pass — worth its own
        tracked finding, not addressed here since fixing it wasn't this task's job, only
        working around it (activating the anchor pool) to get the measurement to complete.
      Real swap executed "via 6 Swaps over 6 Pools" in both cases (confirmed no shortcut taken
      either way). `SWP|TX 032l`-`032q` in `[6.3]_SWP.repl`, kept as a permanent regression —
      the Liquid-Boost-on measurement toggles it on and back off within the same transaction so
      it doesn't leak into any later test. Full `[6.2]`/`[6.3]` suite, issuance-only regression,
      and `Z.repl` (Stage 1 + Stage 2) all exit 0, 0 `FAILURE` afterward.
      **Conclusion: the worst case does NOT reliably fit in one transaction once Liquid Boost
      is on. Owner confirmed (2026-08-20) Liquid Boost is meant to be always on in production —
      so this is not an edge case, it's the real number. Promoted to `P0.6` below.**

- [ ] **P0.6 — REOPENED, 2026-08-21. Was marked DONE, wrongly — the "1,963,025 gas, fits"
      figure was measured against an incomplete worst case that never exercised the
      special-fee-target payout path at all. Real corrected worst case: 2,130,472 gas —
      130,472 OVER the ~2,000,000 ceiling, even after batching. Still open, bigger than
      previously understood. Blocks P3 and P1 until resolved.**
      **How this was found:** owner pushed back hard on the earlier claim that special-fee-
      target transfers are cheap ("that's a multitransfer send function, at least 20k-30k gas
      ... are you sure you're looking at the right place?"), and separately asked to double-
      check the reverted batching finding. Checked `SWP::UR_FeeSP`/`UR_FeeLP` directly on the
      real `SWP|TX 032q` pools: `lp-fee = 10.0`, `special-fee = 0.0`. `SWP|TX 032p` configures
      special-fee-target *accounts* (`C_UpdateSpecialFeeTargets`) but never activates the
      special-fee *rate* itself — it defaults to 0.0 at issuance and stays there unless
      explicitly set via `C_UpdateFee`. **Every worst-case gas measurement taken in this whole
      P0.6 effort, including the "DONE" 1,963,025 figure, had `o-id-special == 0.0` on every
      hop — the expensive `C_MultiBulkTransfer(7 targets)` path had never once actually
      executed.** The owner's gas estimate was correct; the "it's all cheap" conclusion from
      the first re-check was an artifact of testing an unexercised code path, not a real
      measurement of the thing in question.
      **Isolated the real transfer cost properly this time** (`acquire-module-admin` +
      `with-capability(SWPU.P|SWPU|CALLER)` to legally call the protected `C_*` function, real
      `KST.*` target accounts, real token balances): one `C_MultiBulkTransfer` call, 7 targets
      = **38,125 gas**. The same 7 payouts as 7 separate 1-target calls = **110,658 gas**.
      Confirms the owner's estimate and confirms real batching headroom exists — just not
      where the first (buggy-test) measurement said it didn't.
      **Fixed `SWP|TX 032p`** to also call `SWP|C_UpdateFee(pool, 10.0, false)` on all 6 pools
      (mirrors `lp-fee`, matching how Liquid Boost already mirrors `lp-fee` when its own toggle
      is on) — this worst-case test now actually stresses the path it claims to.
      **Re-measured `SWP|TX 032q` with the corrected fee config: 2,148,758 gas — 148,758 OVER
      the ceiling, independent of any pool-count-scaling question.** This is a materially
      bigger and more urgent problem than anything previously closed under P0.6.
      **Rebuilt special-fee-target batching** in `XI_SmartSwapCore` (same design as the earlier
      reverted attempt — carry non-last hops' targets/amounts forward, one combined multi-token
      `C_MultiBulkTransfer` on the last hop, per-hop `SWPU|S>FEED-SPECIAL-TARGETS` event
      unchanged) — this time with real work to remove. **Re-measured: 2,130,472 gas — saves
      18,286 gas over the corrected unbatched baseline, kept (real, positive, correctness-
      preserving), but far short of closing the gap. Still 130,472 gas over the ceiling.**
      Smaller savings than the isolated 1-token benchmark suggested (72,533 gas potential) —
      likely because the real batched call spans multiple *tokens* (up to 5, one per non-last
      hop), not multiple targets of one token like the isolated benchmark tested; multi-token
      consolidation apparently doesn't save as much per-entry as multi-target-same-token
      consolidation. Not independently re-isolated — flagged as the next thing to check if
      more savings are needed here specifically.
      Full `[6.2]`+`[6.3]` suite and default `Z.repl` regression both exit 0, 0 `FAILURE`,
      before and after both changes.
      **Not resolved. 130,472 more gas needs to be found before P0.6 can be called done again.
      Owner has a separate proposed solution not yet evaluated — see status line at top.**

      **P2-scale probe, 2026-08-21 — the single most severe finding of this entire effort.**
      Owner asked to build a real (not synthetic) 50-100-active-pool topology and re-measure.
      Built it: 80 new `OURO`-anchored 2-token noise pools (`SWP|TX 032r`-`032z2` in
      `[6.3]_SWP.repl`, permanent), activated in 4 batches of 20, re-measuring the real
      corrected worst case (Liquid Boost + real special-fee rate, batched) at each step:
      | active swpairs | gas | Δ gas from prior checkpoint | Δ gas / added pool |
      |---|---|---|---|
      | 22 (baseline) | 2,130,472 | — | — |
      | 42 | 6,076,821 | +3,946,349 | ~197,317 |
      | 62 | 6,327,258 | +250,437 | ~12,522 |
      | 82 | 6,677,807 | +350,549 | ~17,527 |
      | 102 | 7,145,276 | +467,469 | ~23,373 |
      **Every single checkpoint blows the ~2,000,000 ceiling, most of them catastrophically —
      by 3.5x at just 42 active pools.** 0 `FAILURE` throughout (this is purely a gas problem,
      not a correctness one — the swap still executes correctly, it just costs far more than a
      real transaction could ever pay for).
      **Why the jump is front-loaded, not uniform (confirmed by mechanism, not just the
      numbers):** the new noise pools all anchor to `OURO` (required — `W`/`P` pools must have
      a principal as their first token, and `OURO` is the natural, near-universal choice any
      real protocol growth would keep using). `OURO` also sits directly on the Liquid Boost
      pump's own DLK-search path (the full `W7→W6→…→W1→OURO→DLK` chain the last hop's
      `URC_HopperActiveShortest` call must traverse). Every noise pool added therefore
      increases `OURO`'s own node-degree in the graph that search walks through — this is a
      fundamentally different, much more direct effect than the earlier controlled experiment's
      "unrelated background pool count" test (which used a much smaller, pre-existing 14-pool
      noise set not concentrated on a path-critical hub). **The real lesson: cost isn't driven
      by total protocol pool count in a generic, uniform sense — it's driven by the degree of
      whichever hub node the search has to pass through, and any principal token (`OURO`
      included) is structurally guaranteed to become exactly that kind of hub as the protocol
      grows, because the anchoring rule requires new pools to attach to one.** This is not a
      one-off edge case or an unlikely adversarial construction — it is the *default, required*
      shape of organic growth under the current anchoring design.
      **Decomposition, 2026-08-21 — owner asked "why, is it just the boost search?" Checked
      directly rather than assume yes.** Isolated all three live-search sources at the 102-pool
      checkpoint:
      - Main SmartSwap routing search (best-of-3, `URC_HopperActive`, `W1→W7`, runs once at
        the very start of every SmartSwap): **739,917 gas.**
      - Liquid Boost's own final search (single-shortest, `URC_HopperActiveShortest`,
        `W7→DLK`, runs once on the last hop, post-direction-5): **515,879 gas.**
      - **`XE_UpdateStoaValue`'s post-swap step (Talos, `TS01-C3.pact`) — previously
        unidentified in this whole P0.6 investigation.** Calls `SWPI::URC_PoolValue` once for
        *every distinct pool actually traversed* (up to 6 for this route), and
        `URC_PoolValue` → `URC_WorthDWK` → `URC_Hopper` — the **unfiltered, still-best-of-3**
        variant (never touched by direction 1's `URC_HopperActiveShortest` fix, which only
        optimized `URC_HopperActive`'s callers). Measured all 6 individually: 698,451 / 691,912
        / 673,080 / 673,080 / 668,309 / 662,141 gas — **sum: 4,066,973 gas, 56.9% of the total
        7,145,276.**
      **This is the actual dominant driver — bigger than the main routing search and the
      boost search combined (1,255,796) by more than 3x.** Answering the owner's question
      directly: no, it is not "just" the boost search — the boost search is real but not even
      the largest single contributor. The three sources sum to 5,322,769 of the 7,145,276
      total (~1.82M still unaccounted for, likely smaller real per-hop costs — fuel, table
      writes, transfers — that weren't individually isolated; not chased further, the picture
      is already clear enough to act on). **`XE_UpdateStoaValue` was never previously discussed
      or targeted by any P0.6 fix — it is a genuinely new, load-bearing finding, not a
      refinement of something already known.**
      **Conclusion: none of P0.6's fixes so far (direction 1, direction 5, special-fee-target
      batching) are sufficient at realistic future scale — none of them address the underlying
      mechanism (per-hop, once-per-swap, *and post-swap-per-pool* live graph searches through
      an ever-growing hub). A structurally different approach is needed, not further
      incremental optimization of the current search-based design — and any such redesign must
      account for `XE_UpdateStoaValue`'s cost explicitly, since it's now known to be the
      largest single piece of the problem, not an afterthought.** This is very likely what
      motivated the owner's own separate proposed solution — see the top status line; that
      idea should now be evaluated as the primary path forward, not as an optional extra.

      ---
      *(Below is the now-superseded "DONE" writeup from earlier the same day, kept for the
      record — its P0.5-topology-only worst-case figures were real measurements, just of an
      incomplete scenario. Superseded by the reopened analysis above.)*

      **Root cause, more specific than P0.5's writeup:** `XI_RawLiquidPump` (`19_SWPU.pact`)
      routes its DLK-conversion quote through `SWPI::URC_HopperActive` → `URCX_Hopper`, which
      is the **same best-of-3 alternate-route search** Fix #19 built for real swap routing
      (`SWPT::URC_ComputeAlternateRoutes`, up to 3 full `URC_ComputeGraphPath` BFS searches,
      each followed by a full `URCX_HopperForNodes` best-edge-per-hop pass, compared via
      `UC_BestHopper`). Liquid Boost fires this **once per hop** (`XI_LiquidIndexPump`, called
      from `XI_SmartSwapCore`'s per-hop fold whenever `o-id-liquid != 0.0`, which is every hop
      while the global toggle is on) — so a 6-hop SmartSwap can trigger **up to 18** full
      alternate-route searches (6 hops × up to 3 candidates each) purely for pricing a small
      residual fee slice into DLK, on top of the **one** alternate-route search the main swap
      routing itself already paid for. This 6×(up to 3x) multiplier, not a single BFS per hop,
      is almost certainly the dominant driver of the ~1.3M gas gap between the boost-off and
      boost-on measurements — **not yet confirmed by direct profiling, only by reading the call
      graph; profile before committing to a fix** (matches the session's own rule: measure,
      don't just derive).
      **Candidate fix directions (not decided, not started — owner input wanted on which to
      pursue, and in what order):**
      1. **DONE, 2026-08-20 — cheap, low-risk, tried first: gave the boost pump a lighter
         routing call than `URC_HopperActive`.** New `SWPI::URC_HopperActiveShortest`
         (`16_SWPI.pact`, plus its `SwapperIssueV3` interface declaration) calls
         `SWPT::URC_ComputeGraphPath` directly (single shortest BFS route, no alternate-route
         comparison) and feeds the result straight to the existing `URCX_HopperForNodes`,
         skipping `URC_ComputeAlternateRoutes`/`UC_BestHopper` entirely. `XI_RawLiquidPump`
         (`19_SWPU.pact`) now calls this instead of `URC_HopperActive`.
         **Re-measured (`SWP|TX 032q`, same topology, Liquid Boost on): 2,759,838 gas — down
         from 3,039,431, a real 279,593-gas saving, but nowhere near enough.** Still 759,838
         over the ~2,000,000 ceiling. Full `[6.2]`+`[6.3]` suite (temporarily switched on in
         `Stage01_Tester.repl`, then reverted back to the checked-in issuance-only default) and
         default `Z.repl` regression both exit 0, 0 `FAILURE`, before and after.
         **Why the saving was small:** removing the best-of-3 comparison only removes the
         *2nd and 3rd* alternate-route attempts' cost — and at this topology those attempts are
         mostly cheap short-circuits already (few genuinely-disjoint alternates exist along a
         mostly-linear 6-pool chain), so there wasn't much redundant best-of-3 cost to remove
         in the first place. The real cost is the **one** full-graph BFS scan each hop still
         pays for regardless — 6 independent hops × ~177k gas/hop ≈ the ~1.06M that's still
         there. That's the number direction 2 has to attack.
      2. **Considered (a reverse-BFS-from-`lkda`, precomputed once and threaded through the
         fold) — superseded by direction 5 before being built, since 5 needs no extra graph
         search at all, not even one.** Left here for the record: `U|BFS::UC_BFS` computes
         shortest paths from a source to every reachable node in one pass, so a single
         `URC_AllGraphPaths(lkda, _, swpairs)` call would have contained the path to every hop
         token, reversed. Real and would likely have worked, but direction 5 (below) is cheaper
         and far less invasive, so this was never implemented.
      3. **Not recommended, listed for completeness: reduce how often boost fires (e.g. only on
         the swap's final hop) instead of making each firing cheaper.** Would have changed what
         Liquid Boost economically does (less value diverted to the index over a multi-hop swap
         than today) as a side effect of a gas fix. Superseded by direction 5, which achieves
         "fires once" *without* changing the total value diverted — see below.
      5. **DONE, 2026-08-21 — shipped, closes P0.6. Owner's own design, from the "round of
         discussion" requested before building anything further:** carry the boost value
         forward hop-by-hop along the swap's *own* route instead of pricing each hop's own
         token independently. Traced the token flow first (owner asked whether the boost cut is
         physically set aside or virtual — neither exactly: `XI_Swap`'s `dra-o` accounting
         *does* remove it from the pool's tracked reserves, real economic effect, but no
         `TFT` transfer ever moves it anywhere — it's un-attributed float sitting in
         `SWP|SC_NAME`'s real balance; the Hopper route search that prices it is a pure quote,
         never actually executed; only the final `DPTF::C_Burn` is a real, destructive
         operation). Since the routing was already just a quote, there was no reason it needed
         a live graph search *per hop* at all.
         **Mechanism, built in `XI_SmartSwapCore` (`19_SWPU.pact`):** the fold's accumulator
         gained a 3rd element, the running carried-boost amount. Each hop converts the
         carried-in amount (denominated in that hop's own input token) into its own output
         token via `SWPI::URC_Swap` over the *same* `swpair` edge the hop's real swap already
         executed through (raw, fee-free curve math — the identical primitive `URCX_HopperForNodes`
         already uses for its own quoting, so no new kind of computation, and no search: the
         edge is already known, sitting in scope) — then adds that hop's own `o-id-liquid` cut,
         and passes the total forward. Only the **last** hop (`iz-last`, a flag the fold already
         had for special-fee-target settlement timing) actually calls `XI_LiquidIndexPump`,
         against the single fully-accumulated total. `XI_LiquidIndexPump`/`XI_RawLiquidPump`
         needed **zero** changes — genuinely generic `(id, amount)` already. One graph search
         per SmartSwap (via direction 1's `URC_HopperActiveShortest`, on the last hop only)
         instead of one per hop.
         **Measured (`SWP|TX 032q`, same worst-case 6-hop/maximal-pool topology, Liquid Boost
         on): 1,963,025 gas — under the ~2,000,000 ceiling, ~37k headroom.** (2,759,838 →
         1,963,025 direction-5 saving alone: 796,813 gas. Full chain from the original
         unoptimized figure: 3,039,431 → 1,963,025, a 1,076,406-gas reduction.) Confirmed the
         swap still executes the real full 6-hop route (`"via 6 Swaps"`, no shortcut). Added a
         diagnostic print of the actual DLK burned by the single end-of-route pump (reads
         `SWP|SC_NAME`'s DLK balance before/after via `DPTF::UR_AccountSupply`) so the total —
         which, as expected going in, does **not** match the old per-hop-independent-search
         total (this design follows the swap's own route rather than each hop's individually-
         best route to DLK) — is visible in the regression output, not a silent behavior
         change. Full `[6.2]`+`[6.3]` suite (temporarily switched on, then reverted to the
         checked-in issuance-only default) and default `Z.repl` regression both exit 0,
         0 `FAILURE`, before and after.
         **Old-vs-new DLK-burn total, measured directly (2026-08-21):** surgically reverted
         `19_SWPU.pact` to its pre-P0.6 state (commit `0feda9f`), re-ran `SWP|TX 032q` with the
         same diagnostic print, restored. Old model (independent per-hop best-of-3 search):
         **0.309547343688240083859530 DLK.** New model (direction 5, carried forward):
         **0.309547469126880789399107 DLK.** Difference: ~0.000000125 DLK, ~0.00004% —
         negligible **in this specific test topology**, but that's an artifact of how P0.5's
         topology was deliberately built (each intermediate token W2–W6 has *no* route to DLK
         except through the linear W1→W7 chain itself, by construction — so "each token's best
         individual route" and "follow the swap's own route" happen to be the same route here).
         In a topology where an intermediate hop token has a genuinely better *direct* route to
         DLK bypassing the rest of the swap's path, the two models would diverge by more than
         this — not measured, flagged honestly rather than assumed negligible in general.
         **Pool-count scaling — measured 2026-08-21, and this is a real concern, not just a
         theoretical one.** Isolated `SWPI::URC_HopperActiveShortest` to a single call (fresh
         `env-gas 0` immediately before) at two real points in the pipeline: at 9 active
         swpairs, one search = **42,998 gas**; at 22 active swpairs (`SWP|TX 032q`'s point),
         one search = **153,420 gas**. That's pool count growing 2.44x but gas growing 3.57x —
         **super-linear**, not proportional. Fit crudely to a power law from just these two
         points (`gas ≈ C·n^1.42`): extrapolating (not measured, wide error bars on a 2-point
         fit) suggests ~50 active pairs could cost somewhere around ~500k for this ONE search
         alone, and ~100 pairs somewhere around ~1.3M+ — either would blow well past the
         current ~37k headroom for the *whole transaction*, not just this one search. **This
         means the current ~1,963,025 figure is not a stable, permanent number — it will
         degrade as the protocol's total pool count grows, and the current fix alone does not
         make Liquid Boost's cost pool-complexity-independent, only hop-count-independent.**
         This raises the priority of P2's planned 50-100-pool empirical sweep — it's no longer
         just validating the exhaustive-search feature's search cost, it now also needs to
         answer whether P0.6 holds at realistic future scale, or whether a genuinely
         pool-complexity-independent approach (e.g. the cached/stored DWK-price-per-token idea
         raised during the P0.6 discussion, still undesigned) becomes necessary. Not yet acted
         on — real P2-scale topology needed for a trustworthy number, this is 2 data points,
         not a curve fit.
         **Headroom is thin (~37k, under 2%) even before accounting for the above.** Deeper
         routes beyond the current 7-token/6-hop cap, or added per-hop overhead elsewhere in
         the fold, would erode it further — worth remeasuring `SWP|TX 032q` (and the boost-off
         baseline) whenever something changes upstream of it, not treating this as permanently
         settled.
         **Known, deliberately accepted minor inefficiency:** if an *intermediate* hop's own
         output token happens to be `lkda` itself, today's design would burn it immediately at
         that hop (1:1, no search needed); this design carries it past that point and only
         settles at the swap's actual final hop, paying for one extra unnecessary raw-swap leg
         in that specific case. Not fixed — rare in practice (the worst-case topology that
         actually needs this fix is the deep, DLK-avoiding kind), and not a correctness issue,
         just a small missed optimization.

      **Tried and reverted, 2026-08-21 — special-fee-target payout batching, does NOT help.**
      Owner's follow-up idea: carry each non-last hop's special-fee-target
      targets/amounts forward instead of paying immediately (`ico-special`'s non-last branch),
      flush everything in ONE combined multi-token `TFT::C_MultiBulkTransfer` on the last hop
      — same shape as direction 5, applied to a different per-hop cost. Built it (extended the
      fold's accumulator with 3 more elements: running `sp-id-lst`/`sp-receiver-arr`/
      `sp-amount-arr`; kept firing `SWPU|S>FEED-SPECIAL-TARGETS`'s event on every hop, unchanged
      audit trail; only the underlying transfer moved to a single end-of-route call), measured
      against the same `SWP|TX 032q` topology (all 6 pools configured with 7 special-fee-targets
      each, so every hop has a nonzero cut to batch): **1,966,113 gas — 114 gas WORSE than the
      1,965,999 pre-batching baseline, reproduced identically on a second run (Pact's gas model
      is deterministic).** Correctness unaffected (0 `FAILURE` across the full suite — same
      recipients, same amounts, just fewer calls). Reverted rather than kept, since it achieved
      the opposite of its purpose while adding real code complexity (3 extra accumulator
      elements, a second special-fee-target code path to maintain).
      **Why it didn't work, best understanding:** unlike the boost fix (which removed an
      O(graph-size) full search, 5 times over), this only ever removed fixed per-call overhead
      (`UEV_IMC`, capability composition) — apparently smaller in Pact's actual gas model than
      the cost of growing 3 accumulator lists via `+` (list concatenation) once per hop. The
      lesson: **removing redundant expensive work (searches) pays off; removing redundant cheap
      work (small transfer calls) can cost more in bookkeeping than it saves.** Don't re-attempt
      this without a different mechanism (e.g. avoiding the list-growth pattern) — the call-count
      reduction alone is not where the gas is.

      **Double-checked, 2026-08-21, at the owner's explicit request ("are you sure we can't do
      any improvements here? check again").** Isolated every individual moving part with direct
      micro-benchmarks (`acquire-module-admin` + real `with-capability` calls against
      `SWPU|S>FEED-SPECIAL-TARGETS`, 7-target payload matching the real config) instead of just
      trusting the net before/after number:
      - ONE `with-capability(FEED-SPECIAL-TARGETS, 7 targets)` call: **4 gas.**
      - SIX such calls in a row (today's real per-hop pattern): **22 gas total.**
      - Growing a 6-element nested list via `(+ acc [x])` six times (the batching attempt's
        accumulator pattern): **8 gas total.**
      All three are single-digit-to-tens of gas — negligible next to even the ~37k headroom,
      let alone the ~150k a single graph search costs. This confirms precisely *why* the
      reverted batching attempt netted -114 gas rather than a saving: none of the "expensive-
      looking" per-hop machinery (capability composition, event emission, list growth) is
      actually expensive in Pact's real gas model — the extra bindings/branches the batching
      code added cost about as much as the calls it removed. **Re-confirmed: there is no
      meaningful improvement available in the special-fee-target payout path.** The entire
      per-hop cost budget here is small enough that no restructuring of it — batching,
      deduping repeat targets across hops, or otherwise — would move the needle. This is now
      based on isolated component measurement, not just a single net comparison, so it should
      be considered a settled answer, not just a repeat of the earlier finding.

      **Investigated and disproven, 2026-08-21 — the `URC_EdgesActive` `contains`-scan theory
      from the earlier pool-count-scaling writeup does NOT hold up.** That writeup claimed
      `URC_EdgesActive`'s `(contains swpair whitelist)` — an O(n) list scan repeated inside
      `URC_MakeGraph`'s node/neighbour loops — was "almost certainly the dominant driver" of the
      measured super-linear scaling (9→22 pairs: 2.44x pool growth, 3.57x gas growth). Verified
      directly with a standalone Pact 5 gas micro-benchmark (`contains` on plain string lists,
      isolated from the rest of the module): n=50 → 6 gas, n=200 → 23 gas, n=800 → 89 gas.
      Confirms `contains` genuinely is O(n) (roughly linear, as expected) — but the *absolute*
      cost is tiny even at n=800, nowhere near enough to explain a 110,422-gas jump between two
      *much smaller* real universes (n=9, n=22). Filtering 5 candidates against an 800-entry
      whitelist cost only 4 gas. **This theory was real reasoning from reading the code, but
      wrong on the numbers — flagged and NOT built, rather than shipping a fix that wouldn't
      have helped** (would also have needed real architectural work: SWPT deploys before SWP in
      this codebase's deploy order, so `URC_EdgesActive` structurally cannot call
      `SWP::UR_CanSwap` directly — any real fix needed the whitelist reshaped by the *caller*
      instead, which is moot now that the theory itself didn't survive measurement).
      **Follow-up data point, not yet conclusive:** measured `SWPT::URC_AllGraphPaths`'s own
      returned chain (path) count at the same two scale points — 9 active pairs (from
      `AKOSON`) → 19 chains; 22 active pairs (from `W7`) → 60 chains. Chain count grew 3.16x
      against 2.44x pool growth — closer to the 3.57x gas growth than raw pool count is, and
      consistent with the earlier #34M-adjacent concern about single richly-connected pools
      generating disproportionately many internal paths. Not a clean, controlled comparison
      though (different source tokens, different local topology) — real next step is an
      apples-to-apples measurement (same source token, only pool count varying) before
      committing to a fix aimed at `UC_BFS`'s chain-tracking (`UCX_GetChains`/`UDCX_AddChains`)
      as the real driver.

      **Corrected, 2026-08-21 — ran the controlled comparison, and the "quadratic pool-count
      scaling" conclusion itself does NOT survive it. The original 9-vs-22-pairs measurement
      was confounded (different source tokens, `AKOSON` vs `W7`, each with its own inherent
      local branching), not a clean pool-count scaling test.** Built one: fixed `W7` as the
      source throughout, fixed the 8 pools genuinely needed for `W7→lkda` reachability (the 6
      `W1`-`W7` chain pools + the `OURO`-`W1` anchor + one `OURO`-`DLK` connector) as a constant
      "core," then varied only how many *unrelated* "noise" pools (AKOSON/EUR/USD/PKOSON/etc.,
      nothing to do with the route) were also present in the search universe:
      - core only (8 pools): 39 chains, 61,251 gas
      - core + 5 noise (13 pools): 43 chains, 65,881 gas
      - core + 10 noise (18 pools): 52 chains, 80,688 gas
      - core + all 14 noise (22 pools): 60 chains, 94,423 gas
      Pool count grew 2.75x (8→22) but gas grew only **1.54x** (61,251→94,423) — sub-linear,
      not super-linear, once source token is held constant. And the gas-per-chain ratio is
      remarkably stable across all four points (1,571 / 1,532 / 1,552 / 1,574 gas per chain) —
      **gas cost tracks chain count almost exactly linearly; chain count itself grows
      sub-linearly with unrelated background pool count.** The earlier "up to ~1.3M at 100
      pools" extrapolation was built on the confounded, wrong premise and should be discarded.
      **Revised understanding:** there is no demonstrated quadratic blow-up from total protocol
      pool count. What actually drives a search's cost is how many distinct paths (`chains`)
      BFS enumerates near the *specific* source/route being searched — driven by local
      branching (how richly-connected the pools immediately around that route are), not by how
      many unrelated pools exist elsewhere in the protocol. This is a real, still-worth-watching
      sensitivity (a popular token surrounded by many densely-interconnected large pools could
      still generate a lot of chains), but it is a fundamentally different, more bounded concern
      than "cost blows up as the whole protocol grows" — and does not currently justify building
      a dedicated fix. **No fix built or needed here based on current evidence.** If this needs
      revisiting, the right lever (per the gas-per-chain finding) would be reducing chain
      *enumeration* itself (e.g. an early-exit/shortest-only BFS variant), not anything to do
      with `URC_EdgesActive`'s whitelist check.

### P1 — Core search primitives, hand-verified on a small topology
- [ ] **P1.1** `SWPT::URC_ComputeAllRoutes(input, output, swpairs, max-attempts)` — generalize
      `URC_ComputeAlternateRoutes`'s 3 hardcoded sequential `let*` attempts into a real `fold`
      over `(enumerate 0 (- max-attempts 1))`, threading `(routes-found, remaining-universe)`
      as accumulator, same early-exit-once-empty short-circuit already proven in #34bM's fix.
      Respects P0.2's ceiling AND P0.4's 6-hop depth cap (design per P0.4).
- [ ] **P1.2** Add `URC_ComputeAllRoutes` to the `SwapTracerV2` interface (additive, no version
      bump — pre-mainnet policy).
- [ ] **P1.3** `SWPI::URC_HopperExhaustive(input, output, amount, swpairs, max-attempts)` —
      mirrors existing `URCX_Hopper`, calls P1.1 instead of the K=3-capped
      `URC_ComputeAlternateRoutes`; reuses the *already-shipped* `URCX_HopperForNodes` (per-
      candidate value) and `UC_BestHopper` (pick best) unchanged — no new value-computation
      logic needed.
- [ ] **P1.4** Add `URC_HopperExhaustive` to the `SwapperIssueV3` interface (additive).
- [ ] **P1.5** Build the owner's small hand-computable topology in a scratch REPL fixture:
      `W|SSTOA-OURO-WSTOA`, `P|SSTOA-VST`, `S|VST-mVST-cVST`, `P|OURO-AKOSON`,
      `S|AKOSON-PKOSON-EKOSON`.
- [ ] **P1.6** Hand-compute the expected route set/count for a chosen A→B pair in that topology
      (e.g. EKOSON→cVST) before running anything, so there's an independent expected answer.
- [ ] **P1.7** Run P1.1 against P1.5's topology, confirm actual output matches P1.6 by hand.
- [ ] **P1.8** Run P1.3, confirm it picks the genuinely-best candidate by real computed output.
- [ ] **P1.9** Explicit edge-case requirement (owner-flagged): the whole mechanism must also
      work correctly when only a single pool exists in the entire universe — 1 route found (or
      0, if the pair isn't connected), no crash, no special-casing needed by the caller. Add
      this as its own small test case, don't just assume the multi-hop topology test covers it.

### P2 — Realistic-scale empirical measurement (the actual go/no-go checkpoint)
- [ ] **P2.1** Build a 50-100 pool REPL topology: principal spokes, 2-hop leaves, AND several
      deliberate bridge-style pools (the specific mechanism — any-position
      `contains-principals` — identified as the real path-count-explosion risk). To test at
      *varying* scales without rebuilding separate topologies each time: `URC_ComputeAllRoutes`
      already takes `swpairs` as a plain parameter (same as the existing
      `URC_ComputeAlternateRoutes`) — build the topology once, then pass different *subsets* of
      the full pool-id list (e.g. `(take 20 all-pool-ids)` vs `(take 80 all-pool-ids)`) for
      different-scale test runs. No toggle, no table manipulation, no new mechanism — just the
      function called the way it's meant to be (considered and rejected two other approaches
      for this before landing here: a mainnet-shippable "hide this pool" toggle meant to be
      commented out before deploy, rejected as exactly the kind of thing that gets forgotten
      and ships; and direct REPL-side table manipulation, rejected as unnecessary once realized
      the existing parameter already does this).
- [ ] **P2.2** Run P1.1 against several A→B pairs in P2.1's topology, record actual candidate
      route counts found.
- [ ] **P2.3** Measure real gas cost via `(env-gas)` for varying `max-attempts` (e.g. 10, 25,
      50, 100) at this scale — extends the per-attempt gas numbers already measured for #34M
      (single search ≈23,764 gas; ≈28,000 marginal per additional K) to confirm they still hold
      at realistic density, not just the sparse topology they were measured against.
- [ ] **P2.4** Go/no-go decision, from P2.2/P2.3's real numbers: tractable as-is, or does
      something need to change first? Decide from data, not more speculation.

### P3 — SmartSwap redesign: dirty-read path injection (full design, 2026-08-21)

**This section supersedes and massively expands the original P3.2 scope.** What started as
"accept a caller-supplied route" grew, over the course of the P0.6 investigation and a long
owner discussion, into a redesign covering all three identified live-search cost sources at
once (main routing search 10.4%, Liquid Boost search 7.2%, `XE_UpdateStoaValue`'s six searches
56.9% — see P0.6's writeup above for the real numbers this is responding to). **Written down in
full before any code gets touched, per the owner's explicit instruction.** Anything marked
"proposed" below is a concrete-enough-to-implement starting point, not a final, unchallengeable
spec — flagged separately from things that are genuinely settled.

**Core principle, settled:** the real (paid) transaction never performs a live graph search,
under any circumstance — not even on a cache miss. All discovery happens off-chain, in
dirty-read/`/local` mode (free). The on-chain function's only jobs are: validate what it was
given is structurally legitimate, execute, and — only when told to — persist a newly-discovered
path so future callers don't have to rediscover it. This is what actually bounds the worst
case, not just the average case; caching alone (discover-and-write inside the real tx on a
miss) would still leave a first-ever-combination transaction paying full search cost.

#### P3.0 — Two independent kinds of path need, not one generic cache

- **A→B (the swap's own route).** Amount-sensitive — the truly cheapest route can change with
  trade size because of AMM slippage curves. Must be freshly discovered by the exhaustive-
  search work (P1/P2) every time, via dirty read. **Not cacheable** the way the other two are.
- **X→DLK, for any token X (Liquid Boost's burn valuation, and `XE_UpdateStoaValue`'s per-pool
  first-token pricing).** Amount-agnostic — boost/stoa-value pricing never needed the *optimal*
  route (established back in direction 1/5), only *a* valid, currently-walkable one. **This is
  the cacheable one**, and it's the same underlying "is there a path from X to Y" primitive in
  both consumers — one shared table serves both, not two separate mechanisms.

#### P3.1 — The shared path-cache table (owner's design, generalized from token→DLK to
      any-token-to-any-token during discussion — better, since it's not just reusable beyond
      boost/stoa-value, and the primordial-pool example shows some entries are trivially
      permanent: if `OURO`/`SSTOA`/`WSTOA` share one pool, that 1-hop entry can never be beaten
      by anything longer, no re-verification of "is this still shortest" ever needed again)

**Schema, proposed:**
```
(deftable SWPT|PathCache:{PathCacheRow})
(defschema PathCacheRow
    nodes:[string]              ;; the cached route, token-id sequence, e.g. [B, X, Y, DLK]
    edges:[string]              ;; the swpair used for each hop, parallel to nodes
    registered-at-pool-count:integer  ;; cheap staleness pre-filter, see below — optional
)
```
Row key: canonicalized token pair, e.g. `(+ (+ token-a "|") token-b)` — canonicalization
direction (which token goes first) still open, see P3.10.

**Lives in `SWPT`** (`14_SWPT.pact`) — the existing home for graph/tracer concerns
(`URC_Edges`, `URC_ComputeGraphPath`, `URC_AllGraphPaths`, `URC_ComputeAlternateRoutes` already
live here). Table read/write functions here don't need anything from `SWP` (deployed after
SWPT) for the "exists-only" mode — pure graph-structure concerns. The "active-required" mode
(needs `SWP::UR_CanSwap`) has to live downstream in `SWPI` (deployed after `SWP`), wrapping
SWPT's structural check with an extra active-check pass — same deploy-order constraint already
hit once this session (`URC_EdgesActive`'s whitelist check couldn't live in SWPT either, for
the identical reason).

**Lookup, settled:** check `A→B` first; if no entry, check `B→A` and derive by reversal before
concluding "no cached path exists" (graph is confirmed bidirectional —
`XI_UpdateGraphForSwpair`'s symmetric `i×j` registration, verified earlier this session) — this
roughly halves what ever needs storing.

**Write policy, settled:**
- **First-write-wins, no overwrites, ever.** Trades "cache self-improves if a shorter path is
  found later" for "nobody can grief a good entry by overwriting it with a worse one." Free
  trade given optimality was never required for this use case (only validity).
- **Writes only ever happen as an internal side-effect of a real transaction that has already
  validated and used the path.** No standalone public "register a path" entrypoint, ever — this
  is the main abuse-resistance mechanism. A submitted path that doesn't pass structural
  validation (below) simply can't be written, full stop.
- Table growth (many distinct pairs) is real but self-limiting — the writer pays real gas for
  their own write, and entries are demand-driven off actual swaps, not a free combinatorial
  blow-up. Worth a line in the eventual architecture doc (P5.5), not a design blocker.

**Validation on every read, settled — even a cache "hit" always re-validates, nothing is ever
trusted blindly:**
1. **Structural connectivity**: for every consecutive `(nodes[i], nodes[i+1])`, confirm
   `edges[i]` is a real, registered swpair that actually connects that exact pair — not just
   "some active pool exists somewhere." Prevents a submitted bundle from containing genuinely-
   active-but-unrelated edges that don't form a real connected path.
2. **Active-or-exists**, mode-dependent (see P3.0's split and the "active vs exists" point
   below): for the A→B execution route, every edge must be `can-swap=true`; for X→DLK pricing
   paths, edges only need to structurally exist (mirrors `URC_Hopper` vs `URC_HopperActive`'s
   existing split — reuse it, don't invent a third mode).
This makes a bad-but-structurally-valid entry self-limiting rather than a lasting problem: if a
pool along a cached path later gets disabled, the next reader's cheap validation catches it and
falls back to a fresh dirty-read trace — no proactive invalidation logic needed anywhere.

**Optional fast-path, not required for correctness:** `registered-at-pool-count` lets a reader
skip straight past full per-edge validation when the global active-pool count hasn't moved
since registration — cheap (one counter read vs N edge reads), but *not* airtight on its own
(count can stay identical while a different pool got disabled and another enabled), so it can
only ever be a pre-filter *in addition to*, never a replacement for, per-edge validation
whenever the counter has moved. Barely matters for 1-hop entries (checking 1 counter isn't
meaningfully cheaper than checking the 1 edge it would gate). **Open: include in v1, or defer?**
(P3.10)

#### P3.2 — The bundle input object (proposed schema, needs confirmation before coding)

```
(defschema SmartSwapPathBundle
    swap-route:object{Hopper}          ;; A->B, from P1/P2's exhaustive dirty-read search
    boost-path:object{CachedPathOrMiss}  ;; B->DLK (B = swap's LAST token, matches direction 5)
    stoa-paths:[object{TokenPathPair}]  ;; deduped {first-token, path-to-DLK-or-miss} — ONE
                                         ;; entry per DISTINCT first-token among touched pools,
                                         ;; not one per pool
)
(defschema CachedPathOrMiss
    nodes:[string]      ;; [BAR] sentinel if genuinely no path exists anywhere
    edges:[string]
    is-new:bool         ;; true = cache miss, this was freshly traced off-chain, please
                         ;; register it after use; false = cache hit, already known, don't
                         ;; write anything
)
(defschema TokenPathPair
    first-token:string
    path:object{CachedPathOrMiss}
)
```
The `is-new` flag is the "sentinel object" mechanism from the owner's own framing: when nothing
needs writing (cache hit), the bundle still carries the path (needed to execute/price with),
just tagged so the real transaction knows to skip the write step entirely.

#### P3.3 — Dedup for stoa-value pricing (owner's core insight this round, confirmed with real
      evidence — see P0.6's decomposition: pool3 and pool4 in the P2-scale topology both have
      first-token `W4` and cost an *identical* 673,080 gas each, proving today's per-pool loop
      redundantly retraces the same path)

The off-chain dirty-read layer is responsible for building `stoa-paths` already deduped by
first-token (a UI doing 6 lookups for a 6-hop route should recognize 2 of them share a first
token and only trace once) — but the on-chain side should **not blindly trust that dedup
happened correctly**; the new `XI_SmartSwapCore` variant (or a helper it calls) still needs to
map `distinct-edges → first-token → (index into stoa-paths)` itself and tolerate a bundle that
wasn't perfectly deduped (worst case, it just does redundant *cheap* lookups against an
already-supplied path — no correctness risk, only a missed optimization if the caller's own
dedup was sloppy). Must still work correctly in the worst case (6-7 genuinely distinct first
tokens, no dedup benefit available at all) — dedup is a bonus, not something the function can
assume.

#### P3.4 — Output side: `XI_SmartSwapCore`/`XI_SmartSwap` must report pool-value results, not
      just gas/netto

Today's `OutputCumulator` chain only carries `[final-netto, hops, pools, distinct-edges]`
upward to Talos, which then *redoes* the expensive work itself (`URC_PoolValue` per pool) —
this is the actual design flaw underlying `XE_UpdateStoaValue`'s cost, independent of whether
individual searches are optimized. The new execution path must instead compute each distinct
pool's stoa-value **using the already-validated `stoa-paths` bundle data** (cheap — walk the
supplied path with live `URC_Swap` math, same pattern as direction 5's carry-forward, no
search) and emit `[{pool: string, stoa-value: decimal}, ...]` as part of what it returns. Talos
then becomes a dumb writer: `(map (lambda (pv) (ref-SWP::XE_UpdateStoaValue (at "pool" pv) (at
"stoa-value" pv))) results-list)` — no `URC_PoolValue` call at the Talos level at all, ever,
for this new path. Exact mechanism for extending `OutputCumulator` itself vs. returning a
parallel value alongside it — still open, see P3.10.

#### P3.5 — The new client entrypoint

- [ ] **P3.5.1** Name: **`SWP|C_SmartSwapExplicitRoute`** (reusing the name already chosen when
      P3.2 was first scoped, before this session's discussion expanded it — no new prefix
      invented; considered and rejected a fresh `CC_`-style prefix since prefixes in this repo
      describe *capability*, not *cost*, and this repo's prefix set is closed/documented).
      Accepts the `SmartSwapPathBundle` (P3.2) as input instead of computing anything itself.
- [ ] **P3.5.2** **Built alongside, not replacing, the existing `SWP|C_SmartSwapNoSlippage`/
      `WithSlippage`** — those stay exactly as they are, self-searching, for direct A/B
      comparison. Decide later (real numbers in hand) whether the new path fully replaces the
      old one or they coexist long-term.
- [ ] **P3.5.3** Verify precisely (trace the code, don't assume) that the new
      `XI_SmartSwapCore` variant safely aborts / falls back cleanly on a malformed or
      incoherent bundle (route that doesn't connect, non-existent swpair, stale/inactive edge)
      rather than silently misbehaving. This is also where the long-standing, still-unfixed
      `XI_RawLiquidPump` crash bug (unguarded index into a possibly-empty search result) gets
      naturally fixed as a side effect — the new design already needs a clean "no valid path"
      sentinel path (`[BAR]`/`is-new` handling), so handling it gracefully here isn't extra
      scope, it's the same work.
- [ ] **P3.5.4** Slippage protection — reuse the existing `UC_SlippageMinMax`/floor-only
      pattern (Fix #16), not a new mechanism.
- [ ] **P3.5.5** IGNIS billing wiring, matching the existing `SmartSwapWithSlippage` pattern —
      needs to also account for whatever gas the new cache-write step costs when `is-new=true`.
- [ ] **P3.5.6** Wire into Talos (`04_TS01-C3.pact`), including the new dumb-writer stoa-value
      updater from P3.4 (replaces the `map URC_PoolValue` loop for this path only — the old
      SmartSwap variants' Talos wrappers stay unchanged, still doing the expensive version, for
      comparison per P3.5.2).

#### P3.6 — Module placement summary (deploy order: `SWPT(14)→SWP(15)→SWPI(16)→SWPL(17)→
      SWPLC(18)→SWPU(19)→MTX-SWP(20)`, Talos after all Core)
- `SWPT` — the path-cache table itself; "exists-only" structural validation; the reversed-
  lookup read helper; the first-write-wins registration writer (all pure graph-structure,
  needs nothing from `SWP`).
- `SWPI` (or `SWPU`) — the "active-required" validation wrapper (structural check from SWPT +
  `SWP::UR_CanSwap` per edge, same reason `URC_EdgesActive` couldn't live in SWPT either).
- `SWPU` — the new `XI_SmartSwapCore` bundle-based variant, the dedup-tolerant stoa-pricing
  step, the results-list emission.
- Talos (`TS01-C3` or similar) — `SWP|C_SmartSwapExplicitRoute`, and the dumb-writer
  stoa-value updater consuming the results list.

#### P3.7 — Off-chain/UI orchestration (what a caller must do before calling
      `SWP|C_SmartSwapExplicitRoute`)
1. Dirty-read the exhaustive-search mechanism (P1/P2) for `A→B` → `swap-route`.
2. Dirty-read the path-cache table for `B→DLK` (`B` = the route's last token): hit → use as-is,
   `is-new=false`; miss (both directions) → dirty-read a fresh trace, `is-new=true`.
3. For each **distinct** pool the discovered `swap-route` will actually traverse, resolve its
   first token, dedupe, and repeat step 2's cache-check per unique first-token.
4. Assemble `SmartSwapPathBundle`, submit as the real (paid) transaction's input.
This whole sequence costs the caller nothing (all dirty reads) except node/wallet-side latency
— exactly the "hammering and polling, shown live to the user" UX already anticipated back when
this effort started (P0.2's discussion).

#### P3.8 — Security/abuse summary (answers the owner's explicit "how do we make sure this
      can't be abused" question)
- No standalone public write entrypoint — writes only as a validated side-effect of real use.
- First-write-wins — no griefing via overwrite.
- Every read re-validates structurally, every time, even cache hits — bad entries are
  self-healing (next reader's cheap check catches and re-traces), never a lasting corruption.
- Structural connectivity check (not just "edge is active somewhere") prevents fabricated,
  disconnected paths from ever being accepted for use or registration.
- Storage/spam is economically self-limiting (writer pays their own gas).
- **Not claimed:** that the table guarantees genuinely-shortest paths as an enforced invariant
  — it guarantees *valid*, and *tends toward* short because an off-chain dirty-read search has
  no gas constraint pushing it toward laziness. Enforcing provable shortest-ness on-chain would
  require exactly the expensive computation this whole redesign exists to avoid. Said
  explicitly so nobody later assumes a stronger guarantee than what's actually built.

#### P3.9 — Testing/comparison plan
- [ ] Build both old (self-searching) and new (bundle-based) SmartSwap variants live
      side-by-side in the same REPL topology (reuse the existing P0.5/P2-scale pools —
      `[6.3]_SWP.repl`'s permanent fixtures already cover 22 and 102-active-pool states).
- [ ] Measure real gas: old vs new, at both 22 and 102 pools, cache-cold vs cache-warm for the
      new path. This is the actual "how much does outsourcing dirty reads save us" number the
      owner asked for — report it once measured, don't estimate it in advance.
- [ ] Adversarial proof: malformed bundle (disconnected route, inactive edge, fabricated path)
      is rejected/falls back safely, doesn't corrupt state or crash.
- [ ] Full regression: issuance-only, full `[6.2]`/`[6.3]`, `Z.repl` — 0 `FAILURE` before and
      after, per this session's standing discipline.

#### P3.10 — Open questions, explicitly not yet decided (owner input wanted before or during
      build, not resolved unilaterally)
- Table key canonicalization: fixed ordering (e.g. lexicographically-smaller-token-first) vs.
  whichever direction happens to get registered first, relying purely on the reversal-lookup at
  read time. Leaning toward the latter (simpler, no extra canonicalization logic needed) but
  not decided.
- `registered-at-pool-count` fast-path: include in v1, or defer as a later optimization once
  the core mechanism is proven?
- Exact mechanism for extending `OutputCumulator` to carry the P3.4 results list — a new field
  on the existing schema, or a second parallel return value threaded alongside it? Needs
  checking against `IgnisCollectorV1`'s existing shape before deciding.
- Whether `SWP|C_SmartSwapExplicitRoute` eventually fully replaces the self-searching variants
  or the two coexist long-term (deliberately deferred to post-measurement, per P3.5.2).

### P4 — Adversarial proof + full regression
- [ ] **P4.1** REPL proof: construct a scenario with 4+ genuinely distinct routes where the
      *best* one is not among the first 3 BFS would find — prove the exhaustive path (P1.3)
      finds it and the existing best-of-3 (Fix #19) doesn't, on the same topology.
- [ ] **P4.2** Adversarial revert/restore cycle for whatever code changes land, per this
      session's established discipline.
- [ ] **P4.3** Full regression: issuance-only suite, full `[6.2]`/`[6.3]` suite, `Z.repl`
      (Stage 1 + Stage 2) — all exit 0, 0 `FAILURE`.

### P5 — Audit trail + docs
- [ ] **P5.1** Log as a new tracked `Fix #` in `ROUND-02-FIXES.md` (this is additive new
      capability, not a bug fix against a numbered finding — frame accordingly).
- [ ] **P5.2** Update `README.md` tracker, `ISSUES-RANKED.md` cross-reference (M2/#34M entry),
      `ROUND-01-OWNER-FEEDBACK.md`.
- [ ] **P5.3** Update this HANDOFF doc's status line and checkboxes as work lands.
- [ ] **P5.5** **Architecture doc:** write up exactly how the finished mechanism works end to
      end — the two-call shape (P1.1 alone for a cheap probe, or P1.3 for probe+pick-best in
      one call), why it's a dirty-read/local call and not a committed transaction, how the
      discovered route then gets fed into P3.2's execute-only entrypoint, and why that's safe
      even if the route goes stale between discovery and execution (slippage floor, not trust).
- [ ] **P5.6** **UI integration guide:** how a UI is supposed to call P1.1/P1.3, what
      `max-attempts` means and how to choose it, and — important, owner-flagged — that search
      time/cost is **not constant**: it grows as the total number of pools in the protocol
      grows, since each attempt re-walks the graph (real measured numbers from P2.3 go here
      once collected, not estimates). Also documents the manual-path-selection UI feature from
      P3.2(b): how to let a user browse/pick their own pools for a swap instead of using the
      auto-discovered route, and feed that selection into the same execute-only entrypoint.
- [ ] **P5.4** Commit.

## Do not lose these facts across a context reset

- #34M (Fix #19) and #34bM (Fix #20) are both **already shipped and proven** — this is
  additive work on top, not a re-fix of either.
- The "paths ≤ pools" claim is **wrong**; don't re-derive it and rely on it.
- The "shortest path is safe to prefer" claim is **wrong**, proven with the concrete
  1-hop-vs-2-hop numeric counter-example above; don't re-litigate it, build the real REPL
  proof in Phase 1/4 if it needs re-demonstrating to anyone.
- The one pruning rule that *is* provably safe is the same-pool-detour rule (point 4).
- Real gas numbers already exist for the base search primitives (point 5) — reuse them
  rather than re-measuring from scratch; only Phase 2's *aggregate* cost at 50-100 pools is
  genuinely new data to collect.
- **P0.6's fixes (direction 1, direction 5, special-fee-target batching) are real and stay
  shipped, but they are not sufficient at realistic scale — confirmed with a real 22-102-pool
  topology, not a synthetic one.** Don't re-derive this; the numbers are in P0.6's writeup.
- **The dominant cost at scale is `XE_UpdateStoaValue`, not Liquid Boost** — 56.9% of the
  102-pool total (4,066,973 of 7,145,276 gas), more than 3x the main routing search and boost
  search combined. This was undiscovered until the owner explicitly asked "is it just the
  boost search?" and it was checked rather than assumed. Any fix that only targets Liquid Boost
  is solving the smaller part of the problem.
- **P3 (below) is now the primary path forward, not P1's exhaustive-search work.** The owner's
  own design — push all path discovery off-chain via dirty reads, inject results as input,
  cache amount-agnostic paths (not values) in a shared table, validate structurally on every
  use — covers all three cost sources at once and has a fully written-down design (P3.0-P3.10)
  as of 2026-08-21, pending only the open questions in P3.10 before code starts. P1's own
  exhaustive-route-discovery work still matters (it's what fills `swap-route` in P3.2's bundle)
  but is no longer the part expected to move the gas-ceiling needle by itself.
- **`XI_RawLiquidPump`'s crash bug (unguarded index into a possibly-empty search result,
  flagged during P0.5) gets fixed as a natural side effect of P3.5.3**, not a separate task —
  don't lose track of it as "still open" once P3 lands; verify it's actually closed then.
