# SWP Audit — cycle log & status tracker

Home for all audit data on the SWP (swap/AMM) infrastructure — sibling in rigor, structure, and cycle
discipline to `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/`. Goal: a **comprehensive, evidence-backed sign-off
that the code we ship is correct** — for every path, "if X and Y and Z happen, the outcome is P, and P is
correct."

## Scope — the entire SWP surface (11 modules, enumerated from `MODULE-INDEX.md` + direct interface reads,
not guessed)

| Module | File | Interface | Role |
|---|---|---|---|
| `U\|SWP` | `1_Utilities/12_U_SWP.pact` | `UtilitySwpV1` | StableSwap/weighted/standard AMM math core, LP math, graph-prep helpers |
| `U\|BFS` | `1_Utilities/13_U_BFS.pact` | `BreadthFirstSearchV1` | Raw breadth-first-search primitive |
| `SWPT` | `2_Core/14_SWPT.pact` | `SwapTracerV1` | Multi-hop route/path tracing (built on `U\|BFS`) |
| `SWP` | `2_Core/15_SWP.pact` | `SwapperV3` | Pool/pair core state: properties, pairs, pools, asymmetry, LP, admin |
| `SWPI` | `2_Core/16_SWPI.pact` | `SwapperIssueV3` | Pool issuance + swap-amount computation ("hopper") |
| `SWPL` | `2_Core/17_SWPL.pact` | `SwapperLiquidityV1` | Liquidity-add mechanics (balanced/asymmetric) |
| `SWPLC` | `2_Core/18_SWPLC.pact` | `SwapperLiquidityClientV1` | LP branding + remove-liquidity |
| `SWPU` | `2_Core/19_SWPU.pact` | `SwapperUsageV2` | Swap execution, slippage enforcement, smart router |
| `MTX-SWP` | `2_Core/20_MTX-SWP.pact` | `SwapperMtxV3` | Multistep (`defpact`) issue/add-liquidity flows |
| `TS01-C3` | `3_Talos/04_TS01-C3.pact` | `TalosStageOne_ClientThreeV3` | Talos client wrapper — single-tx SWP surface |
| `TS01-CP` | `3_Talos/05_TS01-P.pact` | `TalosStageOne_ClientPactsV3` | Talos client wrapper — MTX-SWP defpact surface |

Historical-only, referenced for cascade context, not separately audited: `SwapperV2` (`0_Interfaces/02_Core.pact:527`),
`TalosStageOne_ClientThreeV2`/`ClientPactsV2` (overwritten in place — see M14).

Baseline REPL coverage: `REPL/Stage_01/[6.3]_SWP.repl` (4365 lines, full suite), `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`
(1605 lines). `cd REPL && pact Z.repl` confirmed green during this round (SWP-core auditor ran it directly).

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Living — C10, C13, C12, H9 refuted; C11, H10 design; C2, C1, C7, C8, C9, H12, H11, H6, C6, H4, H2, C4, H5, C3(stable) fixed, C3(weighted) accepted limitation; rest still pending. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Living — Fix #1 (C2), Fix #2 (C1), Fix #3 (C3), Fix #4 (C7), Fix #5 (C8), Fix #6 (C9), Fix #7 (H12), Fix #8 (H11), Fix #9 (H6), Fix #10 (C6+H4+H2 combined), Fix #11 (C4, closes H5 too) landed. |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. *(not yet created)* |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in place.
Module `.pact` source changes **only** during a Fixes round, one fix at a time. **This round is
audit-and-document only — no code was changed.**

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean).

## HARD RULE — no finding is "settled" until it's written down here

A finding is presented **one at a time**, in `ISSUES-RANKED.md` order (#1C → #71L). The moment a
verdict is reached on it — REFUTED, DESIGN, DOC-FIX, CONVENTION, or FIXED — **before moving on to
the next finding**, the same turn must:

1. Append the verdict + reasoning to `ROUND-01-OWNER-FEEDBACK.md` (append-only, never edit past
   entries).
2. Update this file's tracker row (status column) and the cycle-log summary line.
3. Annotate `ISSUES-RANKED.md` for that finding (strike-through / status note).
4. If code changed: add a numbered entry to `ROUND-02-FIXES.md` with the diff and the REPL proof
   (pre-fix repro + post-fix pass, adversarially reverted and reconfirmed where feasible).

This is not optional bookkeeping — it's what "closed" means. A finding that was only discussed in
chat and never landed in these files **is not closed**, no matter how thoroughly it was reasoned
through, and must be treated as still-open until it is written down. This rule exists because C4
(#11C), C5 (#12C), and C6 (#13C) were skipped over silently mid-session on 2026-08-17/18 — not
refuted, not deferred on purpose, just missed — and the gap wasn't caught until the owner asked to
audit the audit. Verify against the actual committed files before trusting any "we already settled
this" claim, including claims made by the agent itself.

## Status tracker (living)

| ID | Sev | Module | Short | Verify | Verdict / status |
|----|-----|--------|-------|--------|------------------|
| C1 | CRIT | SWPI | `URC_BestEdge` picks the worst parallel-pool edge (argmin not argmax) | CONFIRMED (2 independent auditors + lead re-read) | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #2)** — owner required REPL reproduction before accepting; live-reproduced against real pools (18.70 vs 10.00 output, worse one picked, `FAILURE` observed), one-char comparator flip (`<`→`>`), same REPL block now proves the fix (`Expect: success`), full pipeline green. |
| C2 | CRIT | U\|SWP | Newton solver (`UC_ComputeY`/`InverseY`) no domain guard — output can exceed pool balance | CONFIRMED (numeric simulation) | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — scope narrowed to stable pools only (W/P are closed-form, no seed-dependent root); `UC_ComputeY` reseeded `y0 = D` (Curve-style reference), pure computation, no `enforce`; new permanent REPL regression (`[6.2+3]…repl` `SWP\|TX 015`) proven to fail pre-fix and pass post-fix. `UC_ComputeInverseY`'s sibling issue (different failure mode — corrupted coefficients, not wrong-root) is explicitly **not** covered — still open. |
| C3 | CRIT | U\|SWP | All 6 solved-balance formulas round toward the trader — repeatable round-trip profit | CONFIRMED (numeric simulation, 2 independent auditors) | **STABLE: FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #3)** — root cause was Pact's native `^` silently using float64 for decimal exponentiation (confirmed empirically, ~0.013 absolute error on one call), not floor/ceiling placement; fixed via exact-multiplication `UC_IntPow` for the stable pool's whole-number exponents, both directions proven exact (0 bias) live. **WEIGHTED: ACCEPTED KNOWN LIMITATION** — `x^weight` is a genuine fraction, no exact-multiplication fix exists; confirmed bounded (~1e-16 relative, float64 epsilon), confirmed non-solvency-threatening (unlike C2), documented in-source and converted to a regression-bound test rather than a permanently-failing assertion. |
| C4 | CRIT | SWPI | `UEV_Issue` never checks individual weights `&gt;0` — permanent div-by-zero on a W pool | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #11)** — dead precision-check map now wraps a real `enforce` + `>=0.1` floor (matches C7/#8C's bound). Adversarially proven: reverted, a literal 0.0 weight still crashed elsewhere but a sub-floor 0.05 weight sailed through and issued a real, live, badly-conditioned pool — the sharper half of the bug. Also closes H5's duplicate in this function. |
| C5 | CRIT | SWPI | `UEV_Issue` never checks individual genesis reserves `&gt;0` — permanent div-by-zero | CONFIRMED | _pending_ |
| C6 | CRIT | SWPT | Graph node-envelope narrower than edge-set — paths ≥4 hops corrupted/lost | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #10, combined with H4/H2)** — `UC_MakeGraphNodes` now builds nodes from the full caller-supplied swpairs universe instead of a ≤1-hop filter. Adversarially reproduced live (reverting only this function broke pool issuance itself — "No connection to DLK detected" 3 hops deep); restored, full 4-hop chain discovers intact. |
| C7 | CRIT | SWP | `C_ModifyWeights` — no length-parity check, dead precision `enforce` | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #4)** — length-parity via `UEV_UniformList` (mirrors sibling cap), real per-weight `enforce` (precision + `>=0.1` floor, rules out negatives) replacing the discarded map. Adversarially proven: all 4 attack cases succeeded pre-fix, rejected post-fix; legitimate reweight still works. Same discarded-map bug found duplicated in `UEV_Issue` (H5) — not fixed here, flagged for its own turn. |
| C8 | CRIT | SWP | `C_UpdateAmplifier` — zero bound-check on new value (incl. the `-1.0` type sentinel) | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #5)** — floor `>=1.0` (matches issuance) + ceiling `<=2000.0` (REPL-verified via convergence-degradation sweep on a skewed pool, ties to H1). Live-demonstrated pre-fix (`0.0` succeeded, bricked the pool permanently — even further than the pool bricked). Post-fix: all 4 bad values rejected, legitimate update works. |
| C9 | CRIT | SWP / MTX-SWP | Pools issued via MTX-SWP defpact never registered in `SWP\|LP` — breaks AQP LP-stake admission | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #6)** — insert folded into `XE_Issue` (both paths call it), redundant standalone call removed from `SWPI::C_Issue`. Reproduced against a real, live-issued pool (pool7, actually issued via the buggy MTX-SWP defpact in this same suite) — hard-aborted pre-fix, resolves correctly post-fix. Historical gas-limit context (150k → ~2M) documented in-source + memory per owner. |
| C10 | ~~CRIT~~ | SWPL | ~~Asymmetric-liquidity LP mint uses the naive amount, not fair invariant `taxd-lp`~~ | **REFUTED** | **REFUTED (owner, 2026-08-16)** — deficit IS priced + charged via oracle-based IGNIS tax (`URC\|KDA-PID_LpToIgnis`, `kda-pid` not caller-suppliable); original exploit walkthrough omitted this mandatory payment. Substance folded into H8 (upgraded). See `ROUND-01-OWNER-FEEDBACK.md`. |
| C11 | ~~CRIT~~ | SWPU | ~~Slippage bound checks the fee-exclusive gross quote, never the actual net amount delivered~~ | **DESIGN** | **DESIGN, confirmed intentional (owner, 2026-08-17)** — feeless-vs-feeless comparison correctly protects against reserve/price movement; the residual fee-rate-change gap is fully answered by the real, `enforce`d, publicly-queryable `fee-lock` primitive (`UEV_FeeLockState`/`UR_FeeLock`) — unlocked-by-default is a deliberate trust-boundary choice consistent with every other owner-mutable pool lever, not an oversight. See `ROUND-01-OWNER-FEEDBACK.md` (optional doc-gap note on `C_ToggleFeeLock` also recorded there). |
| C12 | ~~CRIT~~ | SWPU | ~~`C_ToggleSwapCapability` — no ownership check anywhere; free DoS on any pool~~ | **REFUTED** | **REFUTED (owner, 2026-08-17)** — original trace stopped at `C_ToggleAddOrSwap`'s first `with-capability` block (`P\|GOVERNING-CALLER`, trivially-true), missing the second block (line 1408) gating the actual `SWP\|Pairs` write via `SWP\|C>ADD-OR-SWAP`, which composes real `CAP_Owner` → `CAP_EnforceAccountOwnership` unconditionally on both toggle directions. No live DoS. See `ROUND-01-OWNER-FEEDBACK.md`. |
| C13 | ~~CRIT~~ | SWPLC | ~~`C_Fuel` indirect branch unbacked-credit / IMC bypass~~ | **REFUTED** | **REFUTED (self-caught via REPL PoC, 2026-08-16)** — Pact 5 requires module-admin of the target module for `with-capability` to grant its capabilities from outside; the "self-grant a trivially-true cap" bypass is not possible. Owner independently confirmed the branch's only real callers (`19_SWPU.pact:687,858`) are safe (transfer already handled, amount internally computed). See `ROUND-01-OWNER-FEEDBACK.md`. |
| H1 | HIGH | U\|SWP | `UC_ComputeD`/`UC_ComputeY` fixed iteration count, no convergence check | CONFIRMED | _pending_ |
| H2 | HIGH | SWPT | `URC_ComputeGraphPath` crashes (`at 0 []`) instead of a clean "no path" result | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #10, combined with C6/H4)** — pulled forward and fixed alongside C6/H4 (flagged explicitly, not silently bundled) since their fix makes "no active path" a normal outcome for the first time. `(at 0 fp)` guarded. First repro attempt was wrong (hit the pre-existing `[[BAR]]` short-circuit instead) — corrected and reproduced the real `Array index out of bounds` crash live; restored, clean `[]` result. |
| H3 | HIGH | SWPT | Principal removal permanently orphans Tracer entries, no resync path | CONFIRMED | _pending_ |
| H4 | HIGH | SWPT | Tracer graph append-only; disabled/frozen/sleeping pools not filtered, no fallback route | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #10, combined with C6/H2)** — new `SWP::URC_ActiveSwpairs`/`SWPI::URC_HopperActive` route only over `can-swap=true` pools; `URC_Hopper` kept unfiltered for internal issuance-time pricing. Needed a 2nd layer (`URC_EdgesActive`/`URC_BestEdgeFiltered`) after adversarial testing caught a disabled *parallel* pool still being selected. Live-reproduced (disabled shortcut still picked pre-fix); restored, correct fallback to the active route. |
| H5 | HIGH | SWPI | Dead validation: weight-precision check computed, never `enforce`d | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #11)** — closed as a byproduct of C4/#11C's fix; H5's exact finding location (`16_SWPI.pact:1255-1261`'s discarded map) *is* the map C4's fix wraps in a real `enforce`. Not deferred — same code, one change, logged here so it isn't silently left "pending" once no longer true. |
| H6 | HIGH | SWP | `A_DefinePrimordialPool` reads `primality` but never enforces it | CONFIRMED | **FIXED ✅ (`ROUND-02-FIXES.md` Fix #9)** — `primality` added to the fold. Live adversarial repro attempted and found structurally impossible: `UEV_CheckAgainstMass` blocks any duplicate 3-token pool sharing the same token set, in any order, once the real one exists — only theoretical exposure was a one-time bootstrap race, already closed on mainnet. Regression-verified (real pool still designatable). |
| H7 | HIGH | SWPL | Two unreconciled asymmetric-deficit pricing models stack in Standard mode | PLAUSIBLE | _pending_ |
| H8 | HIGH | SWPL | Asymmetric-deficit compensation not returned to the diluted pool's own LPs | **CONFIRMED** (mechanism traced, was DESIGN-flag) | _pending_ — owner: is protocol-wide value capture (vs. per-pool LP protection) intentional? See `ROUND-01-OWNER-FEEDBACK.md` C10 entry. |
| H9 | ~~HIGH~~ | SWPU | ~~Reentrancy ordering window in `XI_Swap` via smart-account guard callback~~ | **REFUTED** | **REFUTED (owner, 2026-08-17)** — callback reachable (governor can be rotated to a user-guard, invoked during the debit), but proven via isolated Pact 5 REPL repro that any write attempted from a guard-evaluation callback is blocked (`Operation disallowed in read-only or sys-only mode`), not even `try`-catchable. See `ROUND-01-OWNER-FEEDBACK.md`. |
| H10 | HIGH | MTX-SWP / Talos | Global Admin Pause not honored on `defpact` continuation steps | CONFIRMED (2 independent auditors) | **DESIGN — closed (owner, 2026-08-17)** — step-0-only GAP gating confirmed intentional and consistent across all 6 codebase `defpact` flows (not SWP-specific); owner's "same transaction" framing was logical, not literal. Residual time-window exposure rides on **L68** (no TTL) being fixed separately, not independently closed here. See `ROUND-01-OWNER-FEEDBACK.md`. |
| H11 | HIGH | SWPLC | `can-add` toggle silently blocks both deposits **and** withdrawals | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #8)** — owner decided after industry research (Curve/Balancer both structurally exempt LP exit from their pause; security-audit consensus treats blockable withdrawals as a trust anti-pattern): `can-add` legitimately pauses deposits, must never block removal. `UEV_RemoveLiquidity`'s `can-add` check removed entirely. Proven live pre/post against the real production call chain and a real patron LP balance. |
| H12 | HIGH | SWPLC / SWP | `SWP\|S&gt;UPDATE-SUPPLIES` accepts non-positive new reserve values unchecked | CONFIRMED (code) / PLAUSIBLE (reachability) | **FIXED ✅ (defensive hardening, owner: "just in case")** — real `enforce (>= val 0.0)` added inside the map lambda. Live external repro attempted and confirmed blocked by Pact's own foreign-module-admin rule (same as C13/H9) — stronger evidence of non-reachability than originally assumed. C2 (now fixed) was the main practical route in; this closes a secondary layer. Full-suite regression clean, both issuance-only and full swap-execution paths. |
| M1–M14 | MED | various | See `ROUND-01-FINDINGS.md` § MEDIUM | mixed | _pending_ |
| L-items | LOW | various | See `ROUND-01-FINDINGS.md` § LOW | mixed | _pending_ |

## Live-vs-local (Pythia) status

**Blocked — awaiting owner input.** Per `OuronetInformational/pythia-dirty-read-access.md`, `/read` requires an
owner-supplied `x-pythia-key` (not in the repo) and confirmation of which StoaChain chain id (0–9) `ouronet-ns`
lives on. Reachability confirmed (`/healthz` → `{"service":"ok"}` 2026-08-16). Once supplied, `describe-module`
will be run for all 11 modules above; hash/code/interface divergences will be appended here and cross-referenced
into the findings below (a fix may need to target a **different** interface version than what's in the local
tree if mainnet has already diverged).

## Method (Round I)
One deep-read auditor per module (9 parallel passes covering all 11 files), matching the AQP audit's method —
each auditor loaded `StoicSyntax.md` first, worked read-only, and was told to assume nothing is correct despite
being live on mainnet. All 13 CRITICALs were then lead-re-verified directly against the source (exact cap
bodies / formulas read and, for the two math CRITICALs, independently re-derived and numerically simulated).
Several findings were independently reproduced by two auditors approaching from different modules (`URC_BestEdge`
found by both the SWPT and SWPI auditors; the rounding-direction bias found by both the U|SWP and SWPI auditors;
the Global-Admin-Pause gap found by both the MTX-SWP and Talos auditors) — cross-corroboration, not
double-counting, in the findings doc.

Ground truth for the AMM math: standard Curve-style StableSwap (`D`/`Y` Newton solve) and Balancer-style weighted
invariant (`∏xᵢ^wᵢ`), re-derived algebraically and checked against the source term-by-term; no in-repo reference
implementation existed to diff against (unlike AQP's UrStoa RPS vault ground truth), so verification here relied
on first-principles AMM invariants (conservation, monotonicity, round-trip neutrality) plus numeric simulation
replicating the exact Pact `floor`/`fold` sequence.
