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

#3C **[U|SWP]** ~~StableSwap Newton solver has no domain guard — oversized swaps converge to the wrong root and
can return more output than the pool actually holds.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-17**
(`ROUND-02-FIXES.md` Fix #1) — scope narrowed to stable pools (W/P are closed-form, no seed-dependent root);
`UC_ComputeY` reseeded `y0 = D` (Curve-style), permanent REPL regression (`[6.2+3]…repl` `SWP|TX 015`) proven
to fail pre-fix, pass post-fix. `UC_ComputeInverseY`'s sibling issue (different failure mode) explicitly
**not** covered by this fix — still open. — *C2*

#4C **[SWPU]** ~~`C_ToggleSwapCapability` has no ownership check anywhere in its call chain — any account
can disable swapping on any pool, a free, unauthenticated, protocol-wide DoS.~~ — **REFUTED 2026-08-17.**
The write path (`SWP::C_ToggleAddOrSwap` → `XE_CanAddOrSwapToggle`) is gated by `SWP|C>ADD-OR-SWAP`, which
composes real `CAP_Owner` unconditionally on both toggle directions — the original trace stopped one
`with-capability` block too early. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *C12, retracted*

#5C **[SWPU]** ~~Slippage min/max bound is computed and checked against the fee-exclusive gross swap quote,
never against the actual fee-inclusive amount delivered — a user's declared minimum is not a real floor on
what they receive.~~ — **DESIGN, confirmed intentional 2026-08-17.** Feeless-vs-feeless correctly protects
against reserve/price movement; the residual fee-rate-change gap is fully answered by the real, enforced,
publicly-queryable `fee-lock` primitive — opt-in, unlocked-by-default is a deliberate trust-boundary choice.
Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *C11, closed as DESIGN*

#6C **[SWPI]** `URC_BestEdge` (multi-hop route edge selection) picks the pool with the *least* output, not
the most — every "Smart Swap" across a pair served by ≥2 pools is systematically routed through the worse
one. — **FIXED ✅ AND PROVEN ✅ 2026-08-17** (`ROUND-02-FIXES.md` Fix #2) — live-reproduced in REPL per
owner requirement before any code change (18.70 vs 10.00 real output, worse edge picked), one-char
comparator flip, same block now proves the fix. — *C1*

#7C **[U|SWP]** ~~All six swap-amount formulas (stable/weighted/standard, direct+inverse) round toward the
trader, not the pool — a repeatable, fee-free round-trip profit.~~ — **STABLE FIXED ✅ AND PROVEN ✅
2026-08-17** (`ROUND-02-FIXES.md` Fix #3): true root cause was Pact's native `^` silently using float64 for
decimal exponentiation, not floor/ceiling placement — fixed via exact-multiplication `UC_IntPow` for
whole-number exponents, both directions proven exact (0 bias) live. **WEIGHTED: ACCEPTED KNOWN LIMITATION**
— `x^weight` is a genuine fraction with no exact-multiplication fix available in Pact; confirmed bounded
(~1e-16 relative), confirmed non-solvency-threatening, documented in-source. — *C3*

#8C **[SWP]** ~~`C_ModifyWeights` has no pool-token-length check and a dead (never-enforced) precision
check — can brick a pool or let an owner instantly reweight and arbitrage LPs.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-17** (`ROUND-02-FIXES.md` Fix #4): length-parity + real per-weight enforce (precision + `>=0.1`
floor) added to `SWP|S>WEIGHTS`; adversarially proven (pre-fix all 4 attacks succeeded, post-fix all
rejected, legitimate reweight still works). Time-lock for instant-reweight arbitrage left as a separate
design decision. Same bug duplicated in `UEV_Issue` — see H5. — *C7*

#9C **[SWP]** ~~`C_UpdateAmplifier` has zero bound-check on the new value, including the module's own "not
a stable pool" sentinel — can brick or silently mis-type a live stable pool.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-17** (`ROUND-02-FIXES.md` Fix #5): floor `>=1.0` + ceiling `<=2000.0`, ceiling evidence-backed via
a REPL convergence-degradation sweep, not guessed. Live-proven pre-fix (`0.0` bricked the pool — even more
permanently than originally stated, since it also blocks any further fix via the same cap); post-fix all
bad values rejected, legitimate updates still work. — *C8*

#10C **[SWP / MTX-SWP]** ~~Pools issued through the MTX-SWP `defpact` path are never registered in
`SWP|LP` — every such pool's LP token permanently hard-aborts any AQP LP-stake admission attempt.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-17** (`ROUND-02-FIXES.md` Fix #6): registration folded into `XE_Issue`
(shared by both issuance paths); reproduced against pool7 (a real pool actually issued via the buggy path
in this same REPL suite) — hard-aborted pre-fix, resolves correctly post-fix. — *C9*

#11C **[SWPI]** ~~`UEV_Issue` never checks individual pool weights are `>0` — a `0.0`-weight token in a new W
pool is permanently untradeable (div-by-zero).~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-18**
(`ROUND-02-FIXES.md` Fix #11): dead precision-check map now wraps a real `enforce` + `>=0.1` floor
(matches C7/#8C's bound). Adversarially proven: reverted, a literal `0.0` weight still crashed elsewhere,
but a sub-floor `0.05` weight sailed through and issued a real, live, badly-conditioned pool — the sharper
half of the bug. Also closes H5/#23H's duplicate instance in the same function. — *C4*

#12C **[SWPI]** ~~`UEV_Issue` never checks individual genesis reserves are `>0` — a `0`-reserve token in a new
pool permanently bricks that token (div-by-zero on first touching swap).~~ — **REFUTED 2026-08-18.**
Genesis reserves are validated on every issuance path via the mandatory funding transfer itself
(`TFT::C_MultiTransfer` → `XB_DebitTrueFungible` → `DPTF|C>DEBIT`, whose first line is `UEV_Amount`,
enforcing `>0.0` + precision), unconditionally, on both the single-tx and MTX-SWP defpact paths — just
not inside `UEV_Issue` itself. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *C5, retracted*

#13C **[SWPT]** ~~The routing graph's node set is narrower than its live edge set — paths of 4+ hops are
corrupted or silently lost, and the underlying crash (#20H) is triggered by this.~~ — **FIXED ✅ AND
PROVEN ✅ 2026-08-18** (`ROUND-02-FIXES.md` Fix #10, combined with #19H/#20H): `UC_MakeGraphNodes` now
builds nodes from the full caller-supplied swpairs universe instead of a ≤1-hop filter. Adversarially
reproduced live — reverting only this function broke pool *issuance* itself (3-hop-deep DLK-connectivity
check failed); restored, full 4-hop chain discovered intact, 4 real edges, no `BAR` corruption. — *C6*

## HIGH

#14H **[SWPU]** ~~Reentrancy ordering window in `XI_Swap` — input debit (a smart-account guard callback
point) runs before the pool-reserve commit, after the swap's output is already fixed.~~ — **REFUTED
2026-08-17.** Callback is reachable (governor rotation to a user-guard), but an isolated Pact 5 REPL proof
confirmed any write attempted from a guard-evaluation callback is blocked at the VM level, not even
`try`-catchable — no reentrant write is possible from this position. Full trace in
`ROUND-01-OWNER-FEEDBACK.md`. — *H9, retracted*

#15H **[MTX-SWP / Talos]** ~~Global Administrative Pause is not honored on any `defpact` continuation step
— an in-flight multi-step liquidity-add/issue completes even after an emergency pause.~~ — **DESIGN,
closed 2026-08-17.** Step-0-only GAP gating confirmed intentional and consistent across all 6 codebase
`defpact` flows, not SWP-specific. Residual time-window exposure rides on L68 (no TTL) separately, not
independently closed here. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *H10*

#16H **[SWP]** ~~`SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values with zero enforcement —
a negative pool-token-supply can be persisted unchecked.~~ — **FIXED ✅ 2026-08-17** (`ROUND-02-FIXES.md`
Fix #7): real `enforce (>= val 0.0)` added, defensive hardening per owner request. Live external repro
attempted and confirmed blocked by Pact's foreign-module-admin rule (same as C13/H9); C2 (already fixed)
was the main practical route in. — *H12*

#17H **[SWPLC]** ~~`can-add` gates both deposits *and* withdrawals — a single owner key can freeze every
LP's principal indefinitely with no escape hatch.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-17**
(`ROUND-02-FIXES.md` Fix #8): owner decided after industry research (Curve/Balancer both structurally
exempt LP exit from pause) that `can-add` must never block removal — `UEV_RemoveLiquidity`'s check
removed entirely. Proven live pre/post against the real production call chain. — *H11*

#18H **[SWP]** ~~`A_DefinePrimordialPool` reads the pool's `primality` flag but never actually enforces
it — any matching 3-token pool can be substituted as the canonical primordial pool.~~ — **FIXED ✅
2026-08-17** (`ROUND-02-FIXES.md` Fix #9): `primality` added to the enforce fold. Live repro attempted and
found structurally impossible — `UEV_CheckAgainstMass` blocks any duplicate-token-set pool once the real
one exists; only exposure was a one-time bootstrap race, already closed on mainnet. — *H6*

#19H **[SWPT]** ~~Tracer graph is append-only forever; disabled/frozen/sleeping pools are never filtered from
routing and there's no fallback — a maintenance toggle can hard-reject an entire Smart Swap that has a valid,
slightly-longer alternate route.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-18** (`ROUND-02-FIXES.md` Fix #10,
combined with #13C/#20H): new `URC_ActiveSwpairs`/`URC_HopperActive` route only over `can-swap=true` pools
(`URC_Hopper` kept unfiltered for internal issuance-time pricing). Needed a 2nd layer (`URC_EdgesActive`/
`URC_BestEdgeFiltered`) after adversarial testing caught a disabled *parallel* pool still being selected.
Live-reproduced (disabled shortcut still picked pre-fix, real pool state); restored, correct fallback to
the active 4-hop route. — *H4*

#20H **[SWPT]** ~~`URC_ComputeGraphPath` crashes (out-of-bounds `at` on an empty list) instead of returning the
documented clean "no path" result — also breaks pre-flight quote calls.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-18** (`ROUND-02-FIXES.md` Fix #10): pulled forward and fixed alongside #13C/#19H (flagged
explicitly, not silently bundled), since their fix makes "no active path" a normal outcome for the first
time. `(at 0 fp)` guarded. First repro scenario was wrong (hit the pre-existing `[[BAR]]` short-circuit
instead of the crash line) — corrected and reproduced the real `Array index out of bounds` crash live;
restored, clean empty result. — *H2*

#21H **[SWPT]** ~~Removing a principal token permanently orphans every Tracer entry filed under it — no
resync path exists anywhere in the module.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-19** (`ROUND-02-FIXES.md`
Fix #12): full redesign, not a patch — `SwapTracerV1`→`V2`, principal-keyed storage replaced with plain
token-adjacency (`SWPT|Graph`); nothing is keyed by principal identity anymore, so orphaning is
structurally impossible. Migration utility `SWPI::A_RebuildGraph` added and proven idempotent; every
prior #13C/#19H/#20H/#11C proof re-confirmed byte-identical post-redesign. — *H3*

#22H **[SWPL]** ~~Two independent, unreconciled asymmetric-deficit pricing models both fire for Standard-mode
liquidity adds — possible double-charging honest depositors.~~ — **DESIGN, confirmed intentional
2026-08-19.** Both charges are meant to stack; verified both are scoped exclusively to the asymmetric
portion of a deposit (never the balanced portion) — two distinct levies, not the same deficit billed
twice. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *H7*

#23H **[SWPI]** ~~Weight-precision validation in `UEV_Issue` is computed and then discarded — dead code that
looks like a check but performs none.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-18** (`ROUND-02-FIXES.md`
Fix #11): closed as a byproduct of #11C — this finding's exact location *is* the map #11C's fix wraps in
a real `enforce`. Logged same turn per README's hard rule rather than left showing stale `_pending_`. — *H5*

#24H **[U|SWP]** ~~`UC_ComputeD`/`UC_ComputeY` use a fixed iteration count with no convergence check —
silently under-converges on heavily skewed pools.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-19**
(`ROUND-02-FIXES.md` Fix #15). Measured directly (not the finding's own claim taken on faith):
`UC_ComputeD` (6 iter) really was 0.0078 short at 1000x skew, fully converged by iteration 10;
`UC_ComputeY`/`InverseY` (11 iter) already fully converged. Pact can't do a dynamic convergence-break
(Turing-incomplete) — bumped all three to a fixed 12 iterations; measured gas cost +64 flat per stable
swap. Adversarially reverted `UC_ComputeD` alone, reconfirmed the exact gap reproduces; restored. — *H1*

#25H **[SWPL]** ~~Asymmetric-deficit tax compensation is never returned to the specific pool's own diluted LP
holders — confirmed routed to the shared `SWP|SC_NAME` vault instead.~~ — **DESIGN, confirmed intentional
2026-08-19.** Protocol-wide value capture, not per-pool LP protection, is the intended model. Full trace
in `ROUND-01-OWNER-FEEDBACK.md`. — *H8*

## MEDIUM

#26M **[SWPU]** ~~Slippage bound is symmetric (min *and* max) — a swap can revert just because the price
moved *favorably* beyond tolerance.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-19** (`ROUND-02-FIXES.md`
Fix #16). Researched industry standard first (Uniswap V2/V3, Curve, Balancer, SushiSwap, PancakeSwap —
zero counter-examples, floor-only everywhere). Upper bound commented out (not deleted) at both
`UC_SlippageMinMax` consumer sites. Caught a real Pact 5 runtime bug along the way (single-arg `and`
fails at execution despite parsing fine) — only surfaced via full swap-execution testing. Adversarially
proven live. — *M9*

#27M **[Talos]** ~~`SmartSwapNoSlippage` recomputes which pools to refresh via a fresh post-swap BFS instead
of using the swap's own traversed-edge list — can update the wrong pools' cached Stoa value.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-19** (`ROUND-02-FIXES.md` Fix #17). Both `SmartSwap*` functions now use
`(at 3 out)`, the swap's own recorded `distinct-edges`, instead of a second post-swap `URC_Hopper` query.
Owner asked for forced reproduction (Option B) — issued two brand-new parallel pools with engineered
reserves guaranteeing a pre/post-swap BFS flip; reverted the fix and reproduced the exact bug (stale
actually-swapped pool, spuriously-updated untouched pool), restored, reconfirmed correct. — *M13*

#28M **[MTX-SWP]** ~~`kda-pid` price is snapshotted at defpact Step 0 and reused unchanged at Step 1 with no
re-validation or time bound — stale-price fee/tax mispricing.~~ — **DESIGN, confirmed intentional
2026-08-19.** Fixed price across one logical multi-step event is correct (re-pricing mid-flow would be
internally inconsistent); `PoolState`'s drift-detection check is a deliberately different, already-
adequate guard for reserves/weights/fees, not an oversight that happens to miss price. Residual
time-window exposure explicitly rides on **L68** (no TTL) — same linkage as H10. Full trace in
`ROUND-01-OWNER-FEEDBACK.md`. — *M10*

#29M **[SWPL]** ~~Draining a pool's LP supply to exactly zero re-triggers genesis-ratio pricing regardless
of any dust left in tracked reserves.~~ — **REFUTED (owner, 2026-08-19).** "If dust is left, it hasn't
been drained to zero." `URC_CustomLpBreakAmounts`'s full-drain special case returns the literal current
reserves (not a floored ratio) whenever the removed amount equals the entire LP supply — the only way
supply can reach exactly `0.0`. Reserves and LP supply are proven to hit zero together, by construction —
the finding describes a state the code cannot produce. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *M8*

#30M **[SWP]** ~~`C_ChangeOwnership` is one-phase/unilateral — a fat-fingered destination account
permanently strips the true owner of all admin levers.~~ — **DESIGN, non-issue (owner, 2026-08-19).**
Real-world addresses are copy-pasted/Stoic-tagged, not hand-typed, and the UI previews the destination
pre-sign — a genuine (client-side) confirmation step. On-chain mechanics confirmed accurate, but the
mitigation fully answers the specific threat, consistent with every other one-shot transfer in this
codebase. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *M6*

#31M **[SWP]** ~~`C_EnableFrozenLP`/`C_EnableSleepingLP` have no pool-owner authorization at all.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-19** (`ROUND-02-FIXES.md` Fix #18). Owner: Sleeping/Frozen LP must be
owner-only and irreversible by design — irreversibility was already correct, only the owner gate was
missing. `CAP_Owner swpair` added to both defcaps. Adversarially proven: non-owner rejected with zero
state mutation, true owner succeeds, reverted the fix and reproduced the exact unauthorized flip. — *M7*

#32M **[MTX-SWP]** ~~Permissioned pool issuance charges IGNIS+KDA fees *before* the admin gate that can
reject the request — a non-refundable sunk cost if the admin never signs off.~~ — **DESIGN, accepted and
confirmed non-live (owner, 2026-08-19).** Fee-before-gate is a deliberate anti-abandonment incentive for
defpact flows. Independently confirmed `MTX|C_Issue` has zero Talos wiring anywhere in the codebase —
unreachable through the only supported client path. The real, live single-tx path (`SWPI::C_Issue`)
already gates correctly, before charging. Full trace in `ROUND-01-OWNER-FEEDBACK.md`. — *M11*

#33M **[MTX-SWP]** ~~Explicit rollback costs strictly more than silently abandoning an open `defpact`, and
no pact has a TTL/expiry.~~ — **DESIGN, accepted (owner, 2026-08-19).** "It's how it was designed, leave
as is." Same non-live `MTX-SWP` module already confirmed for M11 (zero Talos wiring). Full trace in
`ROUND-01-OWNER-FEEDBACK.md`. — *M12*

#34M **[U|SWP / SWPT / SWPI / SWPU / Talos]** ~~BFS keeps only one chain per node and routing does zero
amount-out/liquidity comparison across candidate paths — "Smart Swap" is pure hop-count routing.~~ —
**Phase 1 FIXED ✅ AND PROVEN ✅ 2026-08-20** (`ROUND-02-FIXES.md` Fix #19). New
`SWPT::URC_ComputeAlternateRoutes` finds up to 3 edge-disjoint candidate routes (fixed cap — no dynamic
loops in Pact); `SWPI::URCX_Hopper` now picks the highest-payout candidate. Adversarially proven: a
diamond-topology swap delivers 4906 TSTZ fixed vs. 1990 TSTZ reverted (~2.5x worse) via the same swap.
**2026-08-21, owner consolidated ALL SmartSwap routing + execution-gas work under this single issue
(#34) as one 13-phase plan.** Phases 2-5 discovered a *separate, more severe* problem found while
building Phase 1's follow-up: real worst-case execution gas at realistic pool-count scale reached 6-7
million gas against the ~2,000,000 ceiling, dominated (56.9%) by a previously-unknown cost source
(`XE_UpdateStoaValue`'s post-swap per-pool re-pricing), not by Liquid Boost as first assumed. **All 13
phases FIXED ✅ AND PROVEN ✅, 2026-08-22 (`ROUND-02-FIXES.md` Fix #21):** Phases 6-10 built a
dirty-read path-injection redesign (new bundle-based `SWPU::C_SmartSwap`, cache self-warming,
adversarial malformed-bundle proof) — measured **7,145,298 → 397,043 gas on the identical worst-case
swap, an 18.5x reduction**, safely under the ceiling; the old self-searching path stays live, renamed
`CC_SmartSwap`, as the fallback. Phases 11-12 built the originally-requested genuine exhaustive
cheapest-path search (`SWPT::URC_ComputeAllRoutes`/`SWPI::URC_HopperExhaustive`), proved on a real
4-route topology that it finds a route best-of-3 structurally cannot (195.16 vs. 784.27), and measured
its own realistic-scale cost (sub-linear; dirty-read-only, so never competes against the paid ceiling).
Full phase list, design, and every measurement: `OuronetInformational/HANDOFF-swp-exhaustive-path-search.md`.
Finished-mechanism write-up + client orchestration guide: `OuronetInformational/HANDOFF-swp-smartswap-bundle-architecture.md`.
— *M2*

#34bM **[SWPI]** ~~Discovered during #34M follow-up discussion, not from the original Round I sweep.
`UEV_Issue`'s Stable-pool anchoring check (`16_SWPI.pact:1409-1421`) is supposed to require the first
token be *directly* pooled with a principal (owner's stated original design: "S may also have their
first token a principal, or if the first token is not a principal, it should exist in a pool where a
principal exists"). As coded it does neither correctly: it runs a full multi-hop `URC_Hopper` BFS search
(any hop count, not direct-only) targeting `DLK` specifically (not "any current principal" from
`UR_Principals()`). Two independent deviations from stated intent.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-20** (`ROUND-02-FIXES.md` Fix #20). Check rewritten to test the first token's *direct* neighbours
(`SWPT::URC_TokenNeighbours`, one hop) against the *full* current principal list, not a hardcoded DLK
target via multi-hop BFS. Adversarially proven: a token 2 hops from a principal (never directly pooled
with one) is now correctly rejected; the fix reproduced the old bug's false-accept on revert. Also fixed
a pre-existing test fixture (`[6.2+3]...repl`'s AG→AL→AU→BI→CO chain) that had been relying on the bug to
construct itself — given each link its own throwaway, never-activated direct-OURO anchor pool so the
#13C/#19H/#20H BFS-chain assertions it feeds stay byte-for-byte unchanged. — *owner-assigned, off-cycle*

#35M **[SWPI]** ~~Stable-pool swap math silently drops all but the first input position despite the schema
supporting multiple.~~ — **REFUTED 2026-08-22.** Owner: "stable swap pool can only do swap from one single
token to another" — the finding's premise (a multi-input stable swap) is not a real product scenario.
Traced every real call path: `URC_Swap` and `UC_BareboneSwap` both independently enforce
`length(input-amounts) == 1` for pool-type `"S"` before `UC_ComputeY` is ever reached; the Inverse
direction's schema is single-input by design (`input-position:integer`, not a list) across every pool
type, not a stable-specific gap. No live bug. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *M1*

#36M **[SWPI / MTX-SWP]** ~~`C_Issue` and `MTX|C_Issue` duplicate the entire write-side issuance sequence
(including a duplicated hardcoded genesis-mint constant) instead of sharing one chokepoint.~~ — **FIXED ✅
AND PROVEN ✅ 2026-08-22** (`ROUND-02-FIXES.md` Fix #22). Owner: use a singular shared core, called by
both. New `SWPI::XE_IssueWrite` holds the one write sequence; `SWPI::C_Issue` and
`MTX-SWP::MTX|C_Issue`'s Step 3 both call it instead of independently reimplementing it. Duplicated
`10000000.0` genesis-mint literal replaced by a single named `GENESIS_LP_SUPPLY`. Genuine pre-existing
gap found and fixed while wiring the new call: MTX-SWP's own `P|A_Define` had never registered MTX-SWP
as an approved IMC caller on SWPI (only on BRD/DPTF/DPOF/TFT/OUROBOROS/VST/SWPT/SWP/SWPL) — added
`(ref-P|SWPI::P|A_AddIMP mg)`. Adversarially proven: full regression failed hard at `UEV_IMC` before the
registration fix, passed clean (exit 0, 0 `FAILURE`) after. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *M5*

#37M **[U|SWP / U|BFS / SWPT]** ~~Several helpers crash on an empty-list input (`enumerate 0 -1`) instead
of returning `[]`.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-22** (`ROUND-02-FIXES.md` Fix #23). Owner initially
pushed back, suspecting a botched refactor rename on the 4 seemingly-unused named functions — grepped the
whole repo, confirmed zero callers anywhere under any name, not a rename. Traced real reachability: 4 of
7 named functions are genuinely dead code (no live callers at all); `UC_PoolTokensFromPairs`/
`UC_MakeGraphNodes`/`UC_BFS` share one root cause reachable from the live `CC_SmartSwap` entrypoint
whenever no pool has ever been issued yet (`SWP::URC_Swpairs()` genuinely `[]`); found a previously-
unflagged 5th site (`SWPT::URC_MakeGraph`) sharing the same pattern by tracing the chain further than the
original finding did — fixing only the named functions would have just relocated the crash one hop
deeper. `(if (= 0 (length X)) [] ...)` guard added at the 5 real root-cause sites; every other named
function is a thin pass-through that becomes safe automatically. Adversarially proven: new `SWP|TX 003b`
in the genuine pre-first-pool window, reverted the fix (`git stash`) and reproduced the exact predicted
`Array index out of bounds` crash. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *M3*

#38M **[SWPT]** ~~BFS graph-node lookup is a linear scan on every pop (O(V²) in practice) with no explicit
gas/size cap.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-22** (`ROUND-02-FIXES.md` Fix #24). Owner: prove in REPL
it produces the same results before calling it done. Confirmed #34's path cache skips this cost entirely
on a cache hit, but the still-live `CC_SmartSwap` self-searching fallback runs it every time.
`UCX_GraphNodeLinks` rewritten from rebuild-list+search+reindex (two O(V) passes + a reindex per call) to
a single `filter` pass; `UCX_GraphNodes` (now unused) removed as dead code. Adversarially proven: direct
before/after comparison on the real ~102-active-pool topology — byte-identical 7-hop route both times,
gas 423,762 → 256,867 (~39% cheaper), not a toy topology. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *M4*

#39M **[Talos / interfaces]** ~~`ClientThreeV2`/`ClientPactsV2` were overwritten in place instead of
archived, unlike the sibling `ClientFour` interfaces in the same file — an audit-trail gap, not a live
bug.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #25). Owner: fix it —
historical-purposes convention, keep old interfaces and just add the next V number. Reconstructed both
interfaces' full pre-overwrite text from git history (commit `df2d72e`). First placement attempt (central
registry, matching the finding literally) genuinely failed to load — the finding's premise was outdated
(live V3 had since moved to deploy-with-module files) and V2's Smart Swap functions need a module-owned
type not resolvable that early in the pipeline. Relocated to `04_TS01-C3.pact`/`05_TS01-P.pact` alongside
their live V3 siblings — confirmed the codebase already intended this exact pattern (`ClientFourV6`'s own
comment describes it, just never carried out until now). Purely additive, zero functional risk. Full
writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *M14*

## LOW (discipline / hygiene)

#40L **[U|SWP]** ~~`UC_LpID` calls a cross-module `UEV_*` directly from inside a nominally pure `UC_*`
function.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #26). Traced the only real
caller (`SWP::URC_LpComposer`): both lists passed in are structurally guaranteed identical length (built
from the same source via the same `enumerate` range), so the cross-module `UEV_UniformList` enforce could
never actually fail — dead defense, not load-bearing. Removed it, restoring `UC_*` purity. Full regression
clean before/after. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L40*

#41L **[U|SWP]** ~~The module's `UC_*` surface transitively inherits `enforce` from `U|LST` helpers —
purity contract not fully honored end-to-end.~~ — **DESIGN, accepted — documented exception (owner,
2026-08-23).** Unlike L40, these `enforce` calls (`UC_ReplaceAt`/`UC_RemoveItemAt`/`UC_LE`/`UC_FE`) are
load-bearing bounds-guards used pervasively inside live math (`UC_ComputeY`/`UC_ComputeInverseY` and
others) — not dead checks; removing them would strip real out-of-bounds crash protection. Owner: exclude
entirely from the StoicSyntax sweep, these stay `UC_*` — the `enforce` guards the computation's own
list/string shape, not a business decision. Formally codified as a new documented exception in
`OuronetInformational/StoicSyntax.md` § 6.1 (version bumped 1.8.0 → 1.9.0) and cross-referenced in
`StoicSyntax-Prefixes.md`. No code change. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L41*

#42L **[U|SWP]** ~~`UC_ComputeWP`/`InverseWP` divide by a token's weight with no zero-guard of their
own.~~ — **CLOSED — already covered by C4/#11C + C7/#8C, residual only, 2026-08-23.** Confirmed
`(/ 1.0 0.0)` is a real hard crash in Pact, but traced every real path that can ever set a pool's weight:
issuance (`UEV_Issue`, C4/#11C) and modification (`C_ModifyWeights`, C7/#8C) both already floor every
weight at `>=0.1`, closing this before the function is ever reached. C4's own adversarial revert test
already tripped this exact crash without naming it. No live path, no code change — closed as a byproduct
of already-landed fixes, same pattern as H5/#23H being closed as a byproduct of C4. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L42*

#43L **[U|SWP]** ~~`UC_ComputeD`'s docstring claims 5 iterations; the code runs 6.~~ — **CLOSED — already
fixed as a byproduct of H1/#24H, 2026-08-23.** H1 bumped the iteration count 6 → 12 for a real convergence
reason (measured 0.0078 short at 1000x reserve skew) and, doing so, rewrote the docstring to describe the
new count. Current source: docstring says 12, code runs 12 — the doc/code drift this finding describes no
longer exists. No code change here, closed as a byproduct like L42/H5. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L43*

#44L **[U|BFS]** `UCX_*`/`UDCX_*` is a locally-invented naming tier not codified in `StoicSyntax.md`. —
**TAGGED FOR SWEEP, 2026-08-23.** Premise no longer holds as originally written: `StoicSyntax-Prefixes.md`
now formally defines this tier (`UCx_`/`UDCx_`) and already lists `UCX_→UCx_`/`UDCX_→UDCx_` as a planned
mechanical rename. Owner: a broader StoicSyntax refactor runs as its own pass from `main` once every
audit's findings are merged — tagged for that, not hand-renamed now. No code change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L44*

#45L **[SWPT]** ~~`URC_AllGraphPaths` is misleadingly named — returns one shortest chain per node, not all
paths.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #27). Owner: rename it properly,
refactor the module to use the new name. Renamed to `URC_ShortestChainPerNode`; traced and updated the
one real caller (`URC_ComputeGraphPath`) and its own local binding/doc. Pure rename, zero behavior
change — every pre-existing exact-value route assertion (C6/H2/H4/M2) still passes byte-identical. Full
writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L45*

#46L **[SWPT]** ~~The REPL suite's "Smart Swap" coverage is a single transaction with no assertions on the
chosen route — none of #6C/#13C/#19H–21H are caught by existing tests.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-23** (`ROUND-02-FIXES.md` Fix #28). The real worry (those bugs regressing silently) is already
covered by each fix's own dedicated adversarial test, but `SWP|TX 016a` itself still asserted nothing.
Captured its return value and pinned the real measured output via `expect`, after probing for the actual
live value rather than guessing. Adversarially proven the assertion is real: corrupted the expected value
by one digit, got a genuine `FAILURE`, restored. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L46*

#47L **[SWPI]** ~~Unrecognized pool-type falls back to a silent `-1.0` sentinel instead of aborting.~~ —
**REFUTED — provably unreachable by construction, 2026-08-23.** Traced the full chain: `pool-type` is
always the first char of the swpair's own ID string; every swpair ID is built by exactly one exhaustive
function (`UC_PoolID`→`UC_Prefix`, only ever "S"/"W"/"P"), called from exactly one insertion point
(`SWP::XE_Issue`'s `insert`, confirmed the only one — every other table touch is `update`). Structurally
closed, not merely unreachable today. No code change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L47*

#48L **[SWPI]** Undocumented, unrelated-looking magic constants (`5040000.0`, `10000000.0`). —
**DESIGN, accepted — both owner-verified, 2026-08-23.** `10000000.0` (`URC_PoolValue`) is the same fixed
genesis LP mint amount as `GENESIS_LP_SUPPLY` — every issuance mints exactly 10M, by design, just used in
a different function than #36/M5 touched. `5040000.0` (`UC_PoolShares`/`UC_DeviationInValueShares`) has a
real reason tied to share computation, owner-verified correct at implementation time (exact derivation
not recalled on demand, but not an accidental/undocumented value). No code change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L48*

#49L **[SWPI]** ~~`URC_Hopper`'s doc says "cheapest available edge" — imprecise framing for what should
mean "maximizes output" (see #6C).~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #29).
Wording had migrated unchanged into `URCX_HopperForNodes` (#34M/M2's successor). Corrected to
"highest-output edge." Pure doc change, zero behavior change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L49*

#50L **[SWP]** ~~`UR_StoaValue` performs an ungated table write as a side effect of a nominal
"read".~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #30). Owner: deliberate
migration artifact (populate once, a real event writes the genuine value later), confirmed then
authorized removing it. First-instinct fix (`with-default-read`) tested via a scratch repro and found
wrong before proposing it — its default doesn't cover a field missing from an existing row, would have
crashed on the exact legacy-row case. Dropped the `update`; legacy rows now return `0.0` fresh every
read. Traced every reader of the field codebase-wide (including cross-module, AQP's `FVT`) — nothing
depends on it being persisted. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L50*

#51L **[SWP]** ~~`C_ModifyWeights` composes a bare `(SECURE)` cap directly instead of a named master
client cap.~~ — **REFUTED — correct shape, 2026-08-24.** `C_ModifyWeights` is the module's one `C_*`
whose write half is `XB_*` (both internal and external, genuinely called cross-module from `SWPL`)
instead of `XI_*` (internal-only, every sibling's shape). `XB_ModifyWeights` correctly carries its own
`UEV_IMC` + full named cap; `C_ModifyWeights`'s bare `SECURE` is enough to gate the hand-off. Not an
inconsistency. No code change. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L51*

#52L **[SWP]** ~~`XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no documenting `@doc`.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #31). Traced what each actually returns
first: `XE_Issue` returns the new `swpair` ID; `XI_ToggleFeeLock` returns `[0.0 0.0]` or the real ATS
unlock price, confirmed genuinely billed to the patron via `C_ToggleFeeLock`. Real `@doc` added to both
per R4. Pure doc change, zero behavior change. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L52*

#53L **[SWP]** ~~`UEV_PoolFee`'s upper bound (320.0) has units that aren't self-evidently sane — needs
cross-check against SWPU's fee formula.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md`
Fix #32). Cross-checked against the real swap-fee formula: fee is per-mille (1000.0 basis), so 320.0 =
32%, not arbitrary. Owner: mirrored across LP/special/boost fee components so their combined worst case
is 960 promille, always leaving 4% fees can never consume. Doc added capturing both units and rationale.
Pure doc change. Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L53*

#54L **[SWP]** ~~Admin migration utility `AHU`/`AUP_SwapPair(s)` falls outside the module's own prefix
vocabulary.~~ — **DESIGN, accepted — `AU_` formalized, 2026-08-24.** Confirmed deliberate schema-migration
tooling, gated by a separate obfuscated-account admin path. Confirmed the identical pattern already
repeats across 6 modules (DALOS, DPTF, DPOF, ATS, SWP, DPDC) — not a SWP-only slip, so renaming just one
copy would trade one inconsistency for another. Owner: formalize `AU_` (Admin Update) as a new StoicSyntax
category, placed immediately before `A_`; existing instances deliberately deferred to the full
cross-module sweep, not renamed piecemeal. Codified in `StoicSyntax.md` v1.10.0. No `.pact` code change.
Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L54*

#55L **[SWP]** ~~`XE_CanAddOrSwapToggle` redundantly re-derives a check `UEV_IMC` already performed.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #33). Since `UEV_IMC` aborts on failure,
reaching the second check already proves the same guard list passes — provably dead weight. Removed;
confirmed the referenced cap still composed elsewhere. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L55*

#56L **[SWPL]** ~~`URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*` (belongs in
`UEV_*`).~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #34). Traced all 11 real
callers: 8 of 11 pass raw unvalidated amounts — genuinely reachable, not tautological — and no single
non-`URC_*` choke point exists to relocate the check to. New StoicSyntax `v` (validating) specialization
formalized (v1.10.0 → v1.11.0) rather than forcing a false "leave incomplete vs. duplicate 8x" choice.
Renamed `URCv_AreAmountsBalanced`, added the missing per-element negative-amount check (the old sum-only
check let `[-5.0, 10.0]` through clean). Adversarially proven: reverting just the new check still fails,
but with a far worse opaque error deep in the transfer layer — a real upgrade, not a no-op. Full writeup
in `ROUND-01-OWNER-FEEDBACK.md`. — *L56*

#57L **[SWPL]** ~~`XI_AddLiqSendAndMint` performs two distinct writes (transfer + mint) in one
`XI_*`.~~ — **DESIGN, accepted — no split, 2026-08-24.** Checked reuse before agreeing: called from 3
separate sites in `17_SWPL.pact`, real reuse not cosmetic bundling. Combined name already honest, internal
ordering correct (transfer-in before mint-out). No code change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L57*

#58L **[SWPL]** `|KDA-PID`-qualified `defun` names deviate from the "prefix-only" naming convention. —
**TAGGED FOR SWEEP, 2026-08-24.** Not SWP-specific: 308 occurrences across 17 files, including the entire
Stage 2 DemiPad family. Owner: `KDA-PID` means Kadena's USD price (pre-migration); now hardcoded $0.1
pending the future Aletheia Oracle — rename `KDA-PID` → `STOA-PID` throughout, deferred to the full sweep
from `main` (protocol-wide economic-concept rename, not a SWP-scoped fix). No code change. Full writeup
in `ROUND-01-OWNER-FEEDBACK.md`. — *L58*

#59L **[SWPL]** ~~Reserve bump happens before the actual token transfer inside `XE|KDA-PID_AddLiqudity` —
safe only by same-tx atomicity; worth a defensive comment given MTX-SWP elsewhere *is* multi-step.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-24** (`ROUND-02-FIXES.md` Fix #35). Traced the real worry directly: does
`MTX-SWP`'s defpact split the bump and transfer across separate, non-atomic steps? No — confirmed the
whole function is always called entirely within Step 1's own `step-with-rollback`. Added `@doc` recording
the invariant and flagging it for any future caller. Pure doc change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L59*

#60L **[SWPLC]** LP-branding fee attribution resolves via DPTF/DPOF `Konto`, not `SWP::UR_OwnerKonto`
directly — a potential (not confirmed) billing-attribution mismatch. — **DESIGN, accepted — working as
intended, 2026-08-24.** Traced the mechanism: `entity-owner` never drives a debit (always billed to
`patron`), only a 25% smart-account interactor credit gated by `UR_AccountType`. `SWP|SC_NAME`
legitimately qualifies; the pool owner's normal account wouldn't qualify either, so "fixing" this would
just lose the incentive, not redirect it to the owner. No code change. Full writeup in
`ROUND-01-OWNER-FEEDBACK.md`. — *L60*

#61L **[SWPLC]** ~~`C_UpgradeBrandingLPs` is commented out in the REPL suite — untested.~~ — **FIXED ✅
AND PROVEN ✅ 2026-08-25** (`ROUND-02-FIXES.md` Fix #36). Original call was stale (wrong Talos module,
wouldn't have compiled). Traced the real `BRD` flag state machine, found and commented out 3 unrelated
pre-existing broken calls blocking the file from loading (never-issued ATS pair, never-created
frozen/sleeping-LP variants, a never-registered smart account). Added a new `SWP|TX 002` proving
propose→upgrade genuinely moves pending branding to live and flips Gray(3)→Blue(1). Adversarially
proven: corrupted the expected value, got a genuine `FAILURE`, restored. No `.pact` source touched. Full
writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L61*

#62L **[SWPLC]** ~~`C_Fuel` has zero REPL coverage of any kind despite moving real funds.~~ — **FIXED ✅
AND PROVEN ✅ 2026-08-25** (`ROUND-02-FIXES.md` Fix #37). Traced both modes: DIRECT (the only
externally-reachable path, via Talos `SWP|C_Fuel`) is safe by construction — caller only ever spends
their own funds, no LP minted; INDIRECT is internal-only, never exposed via Talos, already covered by the
established `UEV_IMC` mechanism. Added `SWP|TX 038c` proving the real DIRECT path bumps pool reserves by
exactly the fueled amounts via a delta assertion (post minus pre supplies). Adversarially proven:
corrupted the expected delta, got a genuine `FAILURE`, restored. No `.pact` source touched. Full writeup
in `ROUND-01-OWNER-FEEDBACK.md`. — *L62*

#63L **[SWPLC]** ~~The module defines no `XI_*` at all — every `C_*` orchestrates peer calls inline.~~ —
**DESIGN — accepted, working as intended, 2026-08-26.** Traced it: SWPLC owns no domain tables of its
own, only governance-only policy tables (`P|T`/`P|MT`, gated by `GOV`, outside the client flow). Every
`C_*` is pure orchestration — all real persisted writes happen in the modules it calls into
(`BRD::XE_UpdatePendingBranding`, `SWP::XE_UpdateSupplies`, `SWPL::XE|KDA-PID_AddLiqudity`,
`DPTF::C_Burn`, `TFT::C_Transfer`/`C_MultiTransfer`, `VST::C_Freeze`/`C_Sleep`), exactly the documented
`XE_*` forward-module-entrypoint pattern. With no local state to persist, there's nothing for an `XI_*`
to write — its absence is the natural shape of a 100%-orchestration module, not a gap. No code change.
Full writeup in `ROUND-01-OWNER-FEEDBACK.md`. — *L63*

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
