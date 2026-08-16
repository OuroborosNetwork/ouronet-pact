# SWP Audit — issues ranked, highest → lowest severity

Flat ranking of every finding in `ROUND-01-FINDINGS.md` (Round I), numbered #1 → #71 continuously from highest
to lowest severity, with the severity letter appended to the number (C = Critical, H = High, M = Medium,
L = Low). The finding ID in italics at the end of each line (e.g. *C10*) is the cross-reference to look up full
detail (location, failure scenario, fix direction, interface implication) in `ROUND-01-FINDINGS.md`.

## CRITICAL

#1C **[SWPL]** ~~Asymmetric liquidity-add mints the naive (unreduced) LP amount instead of the invariant-fair
`taxd-lp`~~ — **REFUTED 2026-08-16.** Owner supplied a live transaction showing the deficit *is* priced and
charged via an oracle-based IGNIS tax (`URC|KDA-PID_LpToIgnis`, price input not caller-suppliable); the
original exploit walkthrough omitted this mandatory payment. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`.
Substance survives, narrowed, as the now-CONFIRMED **H8** (deficit tax goes to the shared `SWP|SC_NAME` vault,
not back to the specific pool's own diluted LPs — a design question, not a drain). — *C10 → see H8*

#2C **[SWPLC]** ~~`C_Fuel`'s indirect branch can credit unbacked reserves; sole gate is a trivially-true IMC
chain~~ — **REFUTED 2026-08-16.** Self-caught via a minimal Pact 5 REPL proof-of-concept: `with-capability` on
a foreign module's capability requires that module's own admin/internal code, not just a `true` defcap body —
the self-grant bypass this finding depended on isn't possible. Owner independently confirmed the branch's only
real callers (`19_SWPU.pact:687,858`) are safe. Full mechanism trace in `ROUND-01-OWNER-FEEDBACK.md`. No
finding survives at CRITICAL/HIGH/MEDIUM level. — *C13, retracted*

#3C **[U|SWP]** StableSwap Newton solver has no domain guard — oversized swaps converge to the wrong root and
can return more output than the pool actually holds. — *C2*

#4C **[SWPU]** `C_ToggleSwapCapability` has no ownership check anywhere in its call chain — any account can
disable swapping on any pool, a free, unauthenticated, protocol-wide DoS. — *C12*

#5C **[SWPU]** Slippage min/max bound is computed and checked against the fee-exclusive gross swap quote,
never against the actual fee-inclusive amount delivered — a user's declared minimum is not a real floor on
what they receive. — *C11*

#6C **[SWPI]** `URC_BestEdge` (multi-hop route edge selection) picks the pool with the *least* output, not
the most — every "Smart Swap" across a pair served by ≥2 pools is systematically routed through the worse
one. — *C1*

#7C **[U|SWP]** All six swap-amount formulas (stable/weighted/standard, direct+inverse) round toward the
trader, not the pool — a repeatable, fee-free round-trip profit. — *C3*

#8C **[SWP]** `C_ModifyWeights` has no pool-token-length check and a dead (never-enforced) precision check —
can brick a pool or let an owner instantly reweight and arbitrage LPs. — *C7*

#9C **[SWP]** `C_UpdateAmplifier` has zero bound-check on the new value, including the module's own "not a
stable pool" sentinel — can brick or silently mis-type a live stable pool. — *C8*

#10C **[SWP / MTX-SWP]** Pools issued through the MTX-SWP `defpact` path are never registered in `SWP|LP` —
every such pool's LP token permanently hard-aborts any AQP LP-stake admission attempt. — *C9*

#11C **[SWPI]** `UEV_Issue` never checks individual pool weights are `>0` — a `0.0`-weight token in a new W
pool is permanently untradeable (div-by-zero). — *C4*

#12C **[SWPI]** `UEV_Issue` never checks individual genesis reserves are `>0` — a `0`-reserve token in a new
pool permanently bricks that token (div-by-zero on first touching swap). — *C5*

#13C **[SWPT]** The routing graph's node set is narrower than its live edge set — paths of 4+ hops are
corrupted or silently lost, and the underlying crash (#20H) is triggered by this. — *C6*

## HIGH

#14H **[SWPU]** Reentrancy ordering window in `XI_Swap` — input debit (a smart-account guard callback point)
runs before the pool-reserve commit, after the swap's output is already fixed. — *H9*

#15H **[MTX-SWP / Talos]** Global Administrative Pause is not honored on any `defpact` continuation step — an
in-flight multi-step liquidity-add/issue completes even after an emergency pause. — *H10*

#16H **[SWP]** `SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values with zero enforcement — a
negative pool-token-supply can be persisted unchecked. — *H12*

#17H **[SWPLC]** `can-add` gates both deposits *and* withdrawals — a single owner key can freeze every LP's
principal indefinitely with no escape hatch. — *H11*

#18H **[SWP]** `A_DefinePrimordialPool` reads the pool's `primality` flag but never actually enforces it —
any matching 3-token pool can be substituted as the canonical primordial pool. — *H6*

#19H **[SWPT]** Tracer graph is append-only forever; disabled/frozen/sleeping pools are never filtered from
routing and there's no fallback — a maintenance toggle can hard-reject an entire Smart Swap that has a valid,
slightly-longer alternate route. — *H4*

#20H **[SWPT]** `URC_ComputeGraphPath` crashes (out-of-bounds `at` on an empty list) instead of returning the
documented clean "no path" result — also breaks pre-flight quote calls. — *H2*

#21H **[SWPT]** Removing a principal token permanently orphans every Tracer entry filed under it — no resync
path exists anywhere in the module. — *H3*

#22H **[SWPL]** Two independent, unreconciled asymmetric-deficit pricing models both fire for Standard-mode
liquidity adds — possible double-charging honest depositors. — *H7*

#23H **[SWPI]** Weight-precision validation in `UEV_Issue` is computed and then discarded — dead code that
looks like a check but performs none. — *H5*

#24H **[U|SWP]** `UC_ComputeD`/`UC_ComputeY` use a fixed iteration count with no convergence check — silently
under-converges on heavily skewed pools. — *H1*

#25H **[SWPL]** Asymmetric-deficit tax compensation is never returned to the specific pool's own diluted LP
holders — confirmed routed to the shared `SWP|SC_NAME` vault instead (real IGNIS transfer, traced 2026-08-16
while re-verifying #1C/C10). Design question for the owner: is protocol-wide value capture instead of
per-pool LP protection intentional? — *H8*

## MEDIUM

#26M **[SWPU]** Slippage bound is symmetric (min *and* max) — a swap can revert just because the price moved
*favorably* beyond tolerance. — *M9*

#27M **[Talos]** `SmartSwapNoSlippage` recomputes which pools to refresh via a fresh post-swap BFS instead of
using the swap's own traversed-edge list — can update the wrong pools' cached Stoa value. — *M13*

#28M **[MTX-SWP]** `kda-pid` price is snapshotted at defpact Step 0 and reused unchanged at Step 1 with no
re-validation or time bound — stale-price fee/tax mispricing. — *M10*

#29M **[SWPL]** Draining a pool's LP supply to exactly zero re-triggers genesis-ratio pricing regardless of
any dust left in tracked reserves. — *M8*

#30M **[SWP]** `C_ChangeOwnership` is one-phase/unilateral — a fat-fingered destination account permanently
strips the true owner of all admin levers. — *M6*

#31M **[SWP]** `C_EnableFrozenLP`/`C_EnableSleepingLP` have no pool-owner authorization at all. — *M7*

#32M **[MTX-SWP]** Permissioned pool issuance charges IGNIS+KDA fees *before* the admin gate that can reject
the request — a non-refundable sunk cost if the admin never signs off. — *M11*

#33M **[MTX-SWP]** Explicit rollback costs strictly more than silently abandoning an open `defpact`, and no
pact has a TTL/expiry. — *M12*

#34M **[U|SWP / SWPT]** BFS keeps only one chain per node and routing does zero amount-out/liquidity
comparison across candidate paths — "Smart Swap" is pure hop-count routing. — *M2*

#35M **[SWPI]** Stable-pool swap math silently drops all but the first input position despite the schema
supporting multiple. — *M1*

#36M **[SWPI / MTX-SWP]** `C_Issue` and `MTX|C_Issue` duplicate the entire write-side issuance sequence
(including a duplicated hardcoded genesis-mint constant) instead of sharing one chokepoint. — *M5*

#37M **[U|SWP]** Several helpers crash on an empty-list input (`enumerate 0 -1`) instead of returning `[]`.
— *M3*

#38M **[SWPT]** BFS graph-node lookup is a linear scan on every pop (O(V²) in practice) with no explicit
gas/size cap. — *M4*

#39M **[Talos / interfaces]** `ClientThreeV2`/`ClientPactsV2` were overwritten in place instead of archived,
unlike the sibling `ClientFour` interfaces in the same file — an audit-trail gap, not a live bug. — *M14*

## LOW (discipline / hygiene)

#40L **[U|SWP]** `UC_LpID` calls a cross-module `UEV_*` directly from inside a nominally pure `UC_*` function.

#41L **[U|SWP]** The module's `UC_*` surface transitively inherits `enforce` from `U|LST` helpers — purity
contract not fully honored end-to-end.

#42L **[U|SWP]** `UC_ComputeWP`/`InverseWP` divide by a token's weight with no zero-guard of their own.

#43L **[U|SWP]** `UC_ComputeD`'s docstring claims 5 iterations; the code runs 6.

#44L **[U|BFS]** `UCX_*`/`UDCX_*` is a locally-invented naming tier not codified in `StoicSyntax.md`.

#45L **[SWPT]** `URC_AllGraphPaths` is misleadingly named — returns one shortest chain per node, not all
paths.

#46L **[SWPT]** The REPL suite's "Smart Swap" coverage is a single transaction with no assertions on the
chosen route — none of #6C/#13C/#19H–21H are caught by existing tests.

#47L **[SWPI]** Unrecognized pool-type falls back to a silent `-1.0` sentinel instead of aborting.

#48L **[SWPI]** Undocumented, unrelated-looking magic constants (`5040000.0`, `10000000.0`).

#49L **[SWPI]** `URC_Hopper`'s doc says "cheapest available edge" — imprecise framing for what should mean
"maximizes output" (see #6C).

#50L **[SWP]** `UR_StoaValue` performs an ungated table write as a side effect of a nominal "read".

#51L **[SWP]** `C_ModifyWeights` composes a bare `(SECURE)` cap directly instead of a named master client
cap.

#52L **[SWP]** `XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no documenting `@doc`.

#53L **[SWP]** `UEV_PoolFee`'s upper bound (320.0) has units that aren't self-evidently sane — needs
cross-check against SWPU's fee formula.

#54L **[SWP]** Admin migration utility `AHU`/`AUP_SwapPair(s)` falls outside the module's own prefix
vocabulary.

#55L **[SWP]** `XE_CanAddOrSwapToggle` redundantly re-derives a check `UEV_IMC` already performed.

#56L **[SWPL]** `URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*` (belongs in `UEV_*`).

#57L **[SWPL]** `XI_AddLiqSendAndMint` performs two distinct writes (transfer + mint) in one `XI_*`.

#58L **[SWPL]** `|KDA-PID`-qualified `defun` names deviate from the "prefix-only" naming convention.

#59L **[SWPL]** Reserve bump happens before the actual token transfer inside `XE|KDA-PID_AddLiqudity` — safe
only by same-tx atomicity; worth a defensive comment given MTX-SWP elsewhere *is* multi-step.

#60L **[SWPLC]** LP-branding fee attribution resolves via DPTF/DPOF `Konto`, not `SWP::UR_OwnerKonto`
directly — a potential (not confirmed) billing-attribution mismatch.

#61L **[SWPLC]** `C_UpgradeBrandingLPs` is commented out in the REPL suite — untested.

#62L **[SWPLC]** `C_Fuel` has zero REPL coverage of any kind despite moving real funds.

#63L **[SWPLC]** The module defines no `XI_*` at all — every `C_*` orchestrates peer calls inline.

#64L **[SWPU]** `URC_Swap`'s `validation:bool` parameter name is misleading (toggles enforcement, not
gross-vs-net — directly contributed to #5C being easy to miss).

#65L **[SWPU]** `URC_Hopper` is computed twice for the same Smart Swap transaction (wasted gas only).

#66L **[SWPU]** Failure-branch `OutputCumulator` objects are hand-built instead of via a `UDC_*` constructor.

#67L **[MTX-SWP]** `MTX|C_AddSleepingLiquidity` burns a Step-0-cached nonce amount instead of re-reading it
at Step 1 (believed safe only because `DPOF::C_Burn` is assumed to enforce sufficiency).

#68L **[MTX-SWP]** No TTL/expiry on any of the 8 `defpact` flows — open pacts persist forever, state bloat.

#69L **[MTX-SWP]** `MTX-SWP|S>ADD-LQ`'s own doc implies a short, bounded `kda-pid` lock window the code
doesn't actually enforce (see #28M).

#70L **[Talos]** `SWP|C_Fuel`/`SWP|C_Firestarter` are public on `TS01-C3` but not declared on its own
interface — reachable only via the concrete module reference.

#71L **[Talos]** `SWPU::C_ToggleSwapCapability`/`SWPLC::C_ToggleAddLiquidity` call `SWP::C_ToggleAddOrSwap`
directly (core-to-core `C_`→`C_`) instead of through the `XE_*` forward entrypoint that already exists for
exactly this purpose.

---

**Totals:** 13 CRITICAL (#1C–#13C) · 12 HIGH (#14H–#25H) · 14 MEDIUM (#26M–#39M) · 32 LOW (#40L–#71L) = **71
findings** across 11 modules. Full detail (exact location, failure scenario, invariant violated, fix
direction, interface-version implication) for every item above is in `ROUND-01-FINDINGS.md`; live
status/owner verdicts are tracked in `README.md`.
