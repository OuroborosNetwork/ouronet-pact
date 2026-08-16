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
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Living — C10, C13 refuted; C2 fixed; rest still pending. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Living — Fix #1 (C2) landed. |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. *(not yet created)* |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in place.
Module `.pact` source changes **only** during a Fixes round, one fix at a time. **This round is
audit-and-document only — no code was changed.**

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean).

## Status tracker (living)

| ID | Sev | Module | Short | Verify | Verdict / status |
|----|-----|--------|-------|--------|------------------|
| C1 | CRIT | SWPI | `URC_BestEdge` picks the worst parallel-pool edge (argmin not argmax) | CONFIRMED (2 independent auditors + lead re-read) | _pending_ |
| C2 | CRIT | U\|SWP | Newton solver (`UC_ComputeY`/`InverseY`) no domain guard — output can exceed pool balance | CONFIRMED (numeric simulation) | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — scope narrowed to stable pools only (W/P are closed-form, no seed-dependent root); `UC_ComputeY` reseeded `y0 = D` (Curve-style reference), pure computation, no `enforce`; new permanent REPL regression (`[6.2+3]…repl` `SWP\|TX 015`) proven to fail pre-fix and pass post-fix. `UC_ComputeInverseY`'s sibling issue (different failure mode — corrupted coefficients, not wrong-root) is explicitly **not** covered — still open. |
| C3 | CRIT | U\|SWP | All 6 solved-balance formulas round toward the trader — repeatable round-trip profit | CONFIRMED (numeric simulation, 2 independent auditors) | _pending_ |
| C4 | CRIT | SWPI | `UEV_Issue` never checks individual weights `&gt;0` — permanent div-by-zero on a W pool | CONFIRMED | _pending_ |
| C5 | CRIT | SWPI | `UEV_Issue` never checks individual genesis reserves `&gt;0` — permanent div-by-zero | CONFIRMED | _pending_ |
| C6 | CRIT | SWPT | Graph node-envelope narrower than edge-set — paths ≥4 hops corrupted/lost | CONFIRMED | _pending_ |
| C7 | CRIT | SWP | `C_ModifyWeights` — no length-parity check, dead precision `enforce` | CONFIRMED | _pending_ |
| C8 | CRIT | SWP | `C_UpdateAmplifier` — zero bound-check on new value (incl. the `-1.0` type sentinel) | CONFIRMED | _pending_ |
| C9 | CRIT | SWP / MTX-SWP | Pools issued via MTX-SWP defpact never registered in `SWP\|LP` — breaks AQP LP-stake admission | CONFIRMED | _pending_ |
| C10 | ~~CRIT~~ | SWPL | ~~Asymmetric-liquidity LP mint uses the naive amount, not fair invariant `taxd-lp`~~ | **REFUTED** | **REFUTED (owner, 2026-08-16)** — deficit IS priced + charged via oracle-based IGNIS tax (`URC\|KDA-PID_LpToIgnis`, `kda-pid` not caller-suppliable); original exploit walkthrough omitted this mandatory payment. Substance folded into H8 (upgraded). See `ROUND-01-OWNER-FEEDBACK.md`. |
| C11 | ~~CRIT~~ | SWPU | ~~Slippage bound checks the fee-exclusive gross quote, never the actual net amount delivered~~ | **DESIGN** | **DESIGN, confirmed intentional (owner, 2026-08-17)** — feeless-vs-feeless comparison correctly protects against reserve/price movement; the residual fee-rate-change gap is fully answered by the real, `enforce`d, publicly-queryable `fee-lock` primitive (`UEV_FeeLockState`/`UR_FeeLock`) — unlocked-by-default is a deliberate trust-boundary choice consistent with every other owner-mutable pool lever, not an oversight. See `ROUND-01-OWNER-FEEDBACK.md` (optional doc-gap note on `C_ToggleFeeLock` also recorded there). |
| C12 | ~~CRIT~~ | SWPU | ~~`C_ToggleSwapCapability` — no ownership check anywhere; free DoS on any pool~~ | **REFUTED** | **REFUTED (owner, 2026-08-17)** — original trace stopped at `C_ToggleAddOrSwap`'s first `with-capability` block (`P\|GOVERNING-CALLER`, trivially-true), missing the second block (line 1408) gating the actual `SWP\|Pairs` write via `SWP\|C>ADD-OR-SWAP`, which composes real `CAP_Owner` → `CAP_EnforceAccountOwnership` unconditionally on both toggle directions. No live DoS. See `ROUND-01-OWNER-FEEDBACK.md`. |
| C13 | ~~CRIT~~ | SWPLC | ~~`C_Fuel` indirect branch unbacked-credit / IMC bypass~~ | **REFUTED** | **REFUTED (self-caught via REPL PoC, 2026-08-16)** — Pact 5 requires module-admin of the target module for `with-capability` to grant its capabilities from outside; the "self-grant a trivially-true cap" bypass is not possible. Owner independently confirmed the branch's only real callers (`19_SWPU.pact:687,858`) are safe (transfer already handled, amount internally computed). See `ROUND-01-OWNER-FEEDBACK.md`. |
| H1 | HIGH | U\|SWP | `UC_ComputeD`/`UC_ComputeY` fixed iteration count, no convergence check | CONFIRMED | _pending_ |
| H2 | HIGH | SWPT | `URC_ComputeGraphPath` crashes (`at 0 []`) instead of a clean "no path" result | CONFIRMED | _pending_ |
| H3 | HIGH | SWPT | Principal removal permanently orphans Tracer entries, no resync path | CONFIRMED | _pending_ |
| H4 | HIGH | SWPT | Tracer graph append-only; disabled/frozen/sleeping pools not filtered, no fallback route | CONFIRMED | _pending_ |
| H5 | HIGH | SWPI | Dead validation: weight-precision check computed, never `enforce`d | CONFIRMED | _pending_ |
| H6 | HIGH | SWP | `A_DefinePrimordialPool` reads `primality` but never enforces it | CONFIRMED | _pending_ |
| H7 | HIGH | SWPL | Two unreconciled asymmetric-deficit pricing models stack in Standard mode | PLAUSIBLE | _pending_ |
| H8 | HIGH | SWPL | Asymmetric-deficit compensation not returned to the diluted pool's own LPs | **CONFIRMED** (mechanism traced, was DESIGN-flag) | _pending_ — owner: is protocol-wide value capture (vs. per-pool LP protection) intentional? See `ROUND-01-OWNER-FEEDBACK.md` C10 entry. |
| H9 | HIGH | SWPU | Reentrancy ordering window in `XI_Swap` via smart-account guard callback | PLAUSIBLE | _pending_ |
| H10 | HIGH | MTX-SWP / Talos | Global Admin Pause not honored on `defpact` continuation steps | CONFIRMED (2 independent auditors) | _pending_ |
| H11 | HIGH | SWPLC | `can-add` toggle silently blocks both deposits **and** withdrawals | CONFIRMED | _pending_ |
| H12 | HIGH | SWPLC / SWP | `SWP\|S&gt;UPDATE-SUPPLIES` accepts non-positive new reserve values unchecked | CONFIRMED (code) / PLAUSIBLE (reachability) | _pending_ |
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
