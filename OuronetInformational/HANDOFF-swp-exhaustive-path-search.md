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

## Phased plan

**Phase 1 — build the exhaustive+pruned search in isolation, verify by hand.**
Extend `SWPT::URC_ComputeAlternateRoutes`'s exclusion-based approach to run until
exhaustion (not capped at 3), and add the same-pool-detour pruning rule (point 4 above).
Test against a small, fully hand-computable topology — the owner's own worked example
(`W|SSTOA-OURO-WSTOA`, `P|SSTOA-VST`, `S|VST-mVST-cVST`, `P|OURO-AKOSON`,
`S|AKOSON-PKOSON-EKOSON`) is a good candidate: known correct answer, easy to verify the
search finds the right candidate set and prunes what it should.

**Phase 2 — build a realistic 50-100 pool topology, measure for real.**
Deliberately include principal spokes, leaves, AND several bridge-style pools (the exact
mechanism identified in point 2 as the real risk for path-count explosion — this is the part
that needs empirical data, not more theory). Run the Phase 1 search against it via dirty-read
and measure: actual candidate route count found, actual total gas across all search
attempts, wall-clock/practicality. This is the go/no-go checkpoint.

**Phase 3 — decide based on Phase 2's numbers.**
If candidate count and cost are tractable: proceed to Phase 4. If not: figure out what
additional constraint is needed (this doc doesn't presume an answer — could be limiting
bridge-pool fan-out, could be something else; decide from real data, not speculation).

**Phase 4 — build the caller-supplied-route SmartSwap entrypoint.**
A new client function that accepts an explicit route (nodes/edges) instead of computing its
own — the execution machinery underneath (`XI_SmartSwap`/`XI_SmartSwapCore`) already accepts
nodes/edges directly, so this is a smaller lift than the search itself. Protected by the same
slippage floor as the existing `SmartSwapWithSlippage`. Wire into Talos, adversarially prove
end-to-end with a real REPL scenario (mirroring #34M/#34bM's proof methodology — revert the
fix, show the naive/old path wins, restore, show the new one wins), log to the SWP audit
trail (`ROUND-02-FIXES.md` next `Fix #`).

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
