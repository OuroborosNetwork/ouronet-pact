# Handoff: SWP exhaustive on-chain cheapest-path search (SmartSwap Phase 2)

**Status:** PLANNING — not started. No code written yet. This document is the plan; work begins
next session.

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

### P0 — Groundwork / open decisions (resolve before or during P1, not silently assumed)
- [ ] **P0.1** Confirm Kadena's actual `/local` (dirty-read) resource/gas ceiling — chain-level
      property, not in this repo; research externally or ask the owner directly.
- [ ] **P0.2** Decide an absolute hard safety ceiling on `max-attempts` (e.g. 1000) enforced
      inside `URC_ComputeAllRoutes` regardless of what a caller requests — a UI bug or bad
      actor shouldn't be able to request an unbounded search against a node's `/local` endpoint.
- [ ] **P0.3** Decide: enforce "new principals must connect to an existing primordial
      principal" as an actual code check (in `A_UpdatePrincipal`/`A_RotatePrincipal`), or leave
      as a governance convention only. Not required for correctness of this feature (point 5,
      original doc) — purely a connectivity-maximizing choice, owner's call.

### P1 — Core search primitives, hand-verified on a small topology
- [ ] **P1.1** `SWPT::URC_ComputeAllRoutes(input, output, swpairs, max-attempts)` — generalize
      `URC_ComputeAlternateRoutes`'s 3 hardcoded sequential `let*` attempts into a real `fold`
      over `(enumerate 0 (- max-attempts 1))`, threading `(routes-found, remaining-universe)`
      as accumulator, same early-exit-once-empty short-circuit already proven in #34bM's fix.
      Respects P0.2's ceiling.
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

### P2 — Realistic-scale empirical measurement (the actual go/no-go checkpoint)
- [ ] **P2.1** Build a 50-100 pool REPL topology: principal spokes, 2-hop leaves, AND several
      deliberate bridge-style pools (the specific mechanism — any-position
      `contains-principals` — identified as the real path-count-explosion risk).
- [ ] **P2.2** Run P1.1 against several A→B pairs in P2.1's topology, record actual candidate
      route counts found.
- [ ] **P2.3** Measure real gas cost via `(env-gas)` for varying `max-attempts` (e.g. 10, 25,
      50, 100) at this scale — extends the per-attempt gas numbers already measured for #34M
      (single search ≈23,764 gas; ≈28,000 marginal per additional K) to confirm they still hold
      at realistic density, not just the sparse topology they were measured against.
- [ ] **P2.4** Go/no-go decision, from P2.2/P2.3's real numbers: tractable as-is, or does
      something need to change first? Decide from data, not more speculation.

### P3 — Caller-supplied-route execution path (contingent on P2.4 = go)
- [ ] **P3.1** Verify precisely (trace the code, don't assume) that `XI_SmartSwap`/
      `XI_SmartSwapCore` safely aborts on a malformed/incoherent caller-supplied route (e.g. a
      `nodes`/`edges` pair that doesn't actually connect, or references a non-existent swpair)
      rather than silently misbehaving.
- [ ] **P3.2** Design + build the new client entrypoint (e.g. `SWP|C_SmartSwapExplicitRoute`)
      that accepts a caller-supplied `nodes`/`edges` route directly, skipping internal BFS/
      best-of-K entirely.
- [ ] **P3.3** Slippage protection — reuse the existing `UC_SlippageMinMax`/floor-only pattern
      (Fix #16), not a new mechanism.
- [ ] **P3.4** IGNIS billing wiring, matching the existing `SmartSwapWithSlippage` pattern.
- [ ] **P3.5** Wire into Talos (`04_TS01-C3.pact`), matching the existing SmartSwap variants'
      shape.

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
