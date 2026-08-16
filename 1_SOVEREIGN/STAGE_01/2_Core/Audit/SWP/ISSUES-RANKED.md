# SWP Audit — issues ranked, highest → lowest severity

Flat, numbered ranking of every finding in `ROUND-01-FINDINGS.md` (Round I). Numbering is severity-tier
first (CRITICAL → HIGH → MEDIUM → LOW), then rough impact/exploitability within each tier. Each line cites the
module, one-line description, and the finding ID to look up full detail (location, failure scenario, fix
direction, interface implication) in `ROUND-01-FINDINGS.md`.

## CRITICAL

1. **[SWPL]** Asymmetric liquidity-add mints the naive (unreduced) LP amount instead of the invariant-fair
   `taxd-lp` — worked numeric exploit: deposit one token only, mint-then-burn immediately extracts value from
   other LPs, same block. — *C10*
2. **[SWPLC]** `C_Fuel`'s indirect branch can credit a pool's reserves with zero token backing; its only gate
   is a trivially-true capability chain — a shared-vault cross-pool drain if the IMC bypass is confirmed live.
   Also flags a codebase-wide question about whether `UEV_IMC` actually restricts callers anywhere. — *C13*
3. **[U\|SWP]** StableSwap Newton solver has no domain guard — oversized swaps converge to the wrong root and
   can return more output than the pool actually holds. — *C2*
4. **[SWPU]** `C_ToggleSwapCapability` has no ownership check anywhere in its call chain — any account can
   disable swapping on any pool, a free, unauthenticated, protocol-wide DoS. — *C12*
5. **[SWPU]** Slippage min/max bound is computed and checked against the fee-exclusive gross swap quote, never
   against the actual fee-inclusive amount delivered — a user's declared minimum is not a real floor on what
   they receive. — *C11*
6. **[SWPI]** `URC_BestEdge` (multi-hop route edge selection) picks the pool with the *least* output, not the
   most — every "Smart Swap" across a pair served by ≥2 pools is systematically routed through the worse one.
   — *C1*
7. **[U\|SWP]** All six swap-amount formulas (stable/weighted/standard, direct+inverse) round toward the
   trader, not the pool — a repeatable, fee-free round-trip profit. — *C3*
8. **[SWP]** `C_ModifyWeights` has no pool-token-length check and a dead (never-enforced) precision check —
   can brick a pool or let an owner instantly reweight and arbitrage LPs. — *C7*
9. **[SWP]** `C_UpdateAmplifier` has zero bound-check on the new value, including the module's own "not a
   stable pool" sentinel — can brick or silently mis-type a live stable pool. — *C8*
10. **[SWP / MTX-SWP]** Pools issued through the MTX-SWP `defpact` path are never registered in `SWP|LP` —
    every such pool's LP token permanently hard-aborts any AQP LP-stake admission attempt. — *C9*
11. **[SWPI]** `UEV_Issue` never checks individual pool weights are `>0` — a `0.0`-weight token in a new W
    pool is permanently untradeable (div-by-zero). — *C4*
12. **[SWPI]** `UEV_Issue` never checks individual genesis reserves are `>0` — a `0`-reserve token in a new
    pool permanently bricks that token (div-by-zero on first touching swap). — *C5*
13. **[SWPT]** The routing graph's node set is narrower than its live edge set — paths of 4+ hops are
    corrupted or silently lost, and the underlying crash (see #20) is triggered by this. — *C6*

## HIGH

14. **[SWPU]** Reentrancy ordering window in `XI_Swap` — input debit (a smart-account guard callback point)
    runs before the pool-reserve commit, after the swap's output is already fixed. — *H9*
15. **[MTX-SWP / Talos]** Global Administrative Pause is not honored on any `defpact` continuation step —
    an in-flight multi-step liquidity-add/issue completes even after an emergency pause. — *H10*
16. **[SWP]** `SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values with zero enforcement — a
    negative pool-token-supply can be persisted unchecked. — *H12*
17. **[SWPLC]** `can-add` gates both deposits *and* withdrawals — a single owner key can freeze every LP's
    principal indefinitely with no escape hatch. — *H11*
18. **[SWP]** `A_DefinePrimordialPool` reads the pool's `primality` flag but never actually enforces it — any
    matching 3-token pool can be substituted as the canonical primordial pool. — *H6*
19. **[SWPT]** Tracer graph is append-only forever; disabled/frozen/sleeping pools are never filtered from
    routing and there's no fallback — a maintenance toggle can hard-reject an entire Smart Swap that has a
    valid, slightly-longer alternate route. — *H4*
20. **[SWPT]** `URC_ComputeGraphPath` crashes (out-of-bounds `at` on an empty list) instead of returning the
    documented clean "no path" result — also breaks pre-flight quote calls. — *H2*
21. **[SWPT]** Removing a principal token permanently orphans every Tracer entry filed under it — no resync
    path exists anywhere in the module. — *H3*
22. **[SWPL]** Two independent, unreconciled asymmetric-deficit pricing models both fire for Standard-mode
    liquidity adds — possible double-charging honest depositors. — *H7*
23. **[SWPI]** Weight-precision validation in `UEV_Issue` is computed and then discarded — dead code that
    looks like a check but performs none. — *H5*
24. **[U\|SWP]** `UC_ComputeD`/`UC_ComputeY` use a fixed iteration count with no convergence check — silently
    under-converges on heavily skewed pools. — *H1*
25. **[SWPL]** Asymmetric-deficit tax compensation is never returned to the specific pool's own diluted LP
    holders — routed to generic ecosystem sinks instead (design question, not clearly a bug). — *H8*

## MEDIUM

26. **[SWPU]** Slippage bound is symmetric (min *and* max) — a swap can revert just because the price moved
    *favorably* beyond tolerance. — *M9*
27. **[Talos]** `SmartSwapNoSlippage` recomputes which pools to refresh via a fresh post-swap BFS instead of
    using the swap's own traversed-edge list — can update the wrong pools' cached Stoa value. — *M13*
28. **[MTX-SWP]** `kda-pid` price is snapshotted at defpact Step 0 and reused unchanged at Step 1 with no
    re-validation or time bound — stale-price fee/tax mispricing. — *M10*
29. **[SWPL]** Draining a pool's LP supply to exactly zero re-triggers genesis-ratio pricing regardless of any
    dust left in tracked reserves. — *M8*
30. **[SWP]** `C_ChangeOwnership` is one-phase/unilateral — a fat-fingered destination account permanently
    strips the true owner of all admin levers. — *M6*
31. **[SWP]** `C_EnableFrozenLP`/`C_EnableSleepingLP` have no pool-owner authorization at all. — *M7*
32. **[MTX-SWP]** Permissioned pool issuance charges IGNIS+KDA fees *before* the admin gate that can reject
    the request — a non-refundable sunk cost if the admin never signs off. — *M11*
33. **[MTX-SWP]** Explicit rollback costs strictly more than silently abandoning an open `defpact`, and no
    pact has a TTL/expiry. — *M12*
34. **[U\|SWP / SWPT]** BFS keeps only one chain per node and routing does zero amount-out/liquidity
    comparison across candidate paths — "Smart Swap" is pure hop-count routing. — *M2*
35. **[SWPI]** Stable-pool swap math silently drops all but the first input position despite the schema
    supporting multiple. — *M1*
36. **[SWPI / MTX-SWP]** `C_Issue` and `MTX|C_Issue` duplicate the entire write-side issuance sequence
    (including a duplicated hardcoded genesis-mint constant) instead of sharing one chokepoint. — *M5*
37. **[U\|SWP]** Several helpers crash on an empty-list input (`enumerate 0 -1`) instead of returning `[]`.
    — *M3*
38. **[SWPT]** BFS graph-node lookup is a linear scan on every pop (O(V²) in practice) with no explicit
    gas/size cap. — *M4*
39. **[Talos / interfaces]** `ClientThreeV2`/`ClientPactsV2` were overwritten in place instead of archived,
    unlike the sibling `ClientFour` interfaces in the same file — an audit-trail gap, not a live bug. — *M14*

## LOW (discipline / hygiene — grouped, see `ROUND-01-FINDINGS.md` § LOW for full detail)

40. **[U\|SWP]** `UC_LpID` calls a cross-module `UEV_*` directly from inside a nominally pure `UC_*` function.
41. **[U\|SWP]** The module's `UC_*` surface transitively inherits `enforce` from `U|LST` helpers — purity
    contract not fully honored end-to-end.
42. **[U\|SWP]** `UC_ComputeWP`/`InverseWP` divide by a token's weight with no zero-guard of their own.
43. **[U\|SWP]** `UC_ComputeD`'s docstring claims 5 iterations; the code runs 6.
44. **[U\|BFS]** `UCX_*`/`UDCX_*` is a locally-invented naming tier not codified in `StoicSyntax.md`.
45. **[SWPT]** `URC_AllGraphPaths` is misleadingly named — returns one shortest chain per node, not all paths.
46. **[SWPT]** The REPL suite's "Smart Swap" coverage is a single transaction with no assertions on the
    chosen route — none of findings #6/#13/#19–21 are caught by existing tests.
47. **[SWPI]** Unrecognized pool-type falls back to a silent `-1.0` sentinel instead of aborting.
48. **[SWPI]** Undocumented, unrelated-looking magic constants (`5040000.0`, `10000000.0`).
49. **[SWPI]** `URC_Hopper`'s doc says "cheapest available edge" — imprecise framing for what should mean
    "maximizes output" (see #6).
50. **[SWP]** `UR_StoaValue` performs an ungated table write as a side effect of a nominal "read".
51. **[SWP]** `C_ModifyWeights` composes a bare `(SECURE)` cap directly instead of a named master client cap.
52. **[SWP]** `XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no documenting `@doc`.
53. **[SWP]** `UEV_PoolFee`'s upper bound (320.0) has units that aren't self-evidently sane — needs
    cross-check against SWPU's fee formula.
54. **[SWP]** Admin migration utility `AHU`/`AUP_SwapPair(s)` falls outside the module's own prefix
    vocabulary.
55. **[SWP]** `XE_CanAddOrSwapToggle` redundantly re-derives a check `UEV_IMC` already performed.
56. **[SWPL]** `URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*` (belongs in `UEV_*`).
57. **[SWPL]** `XI_AddLiqSendAndMint` performs two distinct writes (transfer + mint) in one `XI_*`.
58. **[SWPL]** `|KDA-PID`-qualified `defun` names deviate from the "prefix-only" naming convention.
59. **[SWPL]** Reserve bump happens before the actual token transfer inside `XE|KDA-PID_AddLiqudity` — safe
    only by same-tx atomicity; worth a defensive comment given MTX-SWP elsewhere *is* multi-step.
60. **[SWPLC]** LP-branding fee attribution resolves via DPTF/DPOF `Konto`, not `SWP::UR_OwnerKonto` directly
    — a potential (not confirmed) billing-attribution mismatch.
61. **[SWPLC]** `C_UpgradeBrandingLPs` is commented out in the REPL suite — untested.
62. **[SWPLC]** `C_Fuel` has zero REPL coverage of any kind despite moving real funds.
63. **[SWPLC]** The module defines no `XI_*` at all — every `C_*` orchestrates peer calls inline.
64. **[SWPU]** `URC_Swap`'s `validation:bool` parameter name is misleading (toggles enforcement, not
    gross-vs-net — directly contributed to #5 being easy to miss).
65. **[SWPU]** `URC_Hopper` is computed twice for the same Smart Swap transaction (wasted gas only).
66. **[SWPU]** Failure-branch `OutputCumulator` objects are hand-built instead of via a `UDC_*` constructor.
67. **[MTX-SWP]** `MTX|C_AddSleepingLiquidity` burns a Step-0-cached nonce amount instead of re-reading it at
    Step 1 (believed safe only because `DPOF::C_Burn` is assumed to enforce sufficiency).
68. **[MTX-SWP]** No TTL/expiry on any of the 8 `defpact` flows — open pacts persist forever, state bloat.
69. **[MTX-SWP]** `MTX-SWP|S>ADD-LQ`'s own doc implies a short, bounded `kda-pid` lock window the code doesn't
    actually enforce (see #28).
70. **[Talos]** `SWP|C_Fuel`/`SWP|C_Firestarter` are public on `TS01-C3` but not declared on its own
    interface — reachable only via the concrete module reference.
71. **[Talos]** `SWPU::C_ToggleSwapCapability`/`SWPLC::C_ToggleAddLiquidity` call `SWP::C_ToggleAddOrSwap`
    directly (core-to-core `C_`→`C_`) instead of through the `XE_*` forward entrypoint that already exists for
    exactly this purpose.

---

**Totals:** 13 CRITICAL · 12 HIGH · 14 MEDIUM · 32 LOW = **71 findings** across 11 modules. Full detail
(exact location, failure scenario, invariant violated, fix direction, interface-version implication) for every
item above is in `ROUND-01-FINDINGS.md`; live status/owner verdicts are tracked in `README.md`.
