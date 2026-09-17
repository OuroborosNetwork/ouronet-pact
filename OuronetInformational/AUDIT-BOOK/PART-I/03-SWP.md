# Chapter 3 — SWP, the swap and AMM family

> Source tree: `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/` (8,453 lines across 7 files, plus a 5,720-line
> `reference/` dump of Kaddex/KDX mainnet source used for comparison).
> Audit ran 2026-08-16 → 2026-08-29 on a dedicated `swp` branch, 103 commits. It is by a wide margin
> the largest of the three Stage-1 trees. This chapter was written 2026-09-17.

Evidence labels are the same as Chapters 1 and 2: **[V-cmd]**, **[V-read]**, **[INFERRED]**,
**[REPORTED]**. **No test was executed for this chapter.**

---

## 3.1 What the module does

SWP is Ouronet's automated market maker — the thing that lets one token become another without a
counterparty. It is eleven files, and unlike ATS or DALOS it is not one module with helpers; it is a
layered machine where each layer does one job:

- **`U|SWP`** is the maths. Three pool types share it: **Stable** pools (Curve-style, a Newton solve
  over an invariant `D` with an amplification coefficient), **Weighted** pools (Balancer-style,
  `∏ xᵢ^wᵢ`), and **Standard** pools (plain constant product). Six formulas in total — each of the
  three types, in both the forward direction ("I give X, how much Y do I get?") and the inverse
  ("I want Y, how much X must I give?").
- **`U|BFS` + `SWPT`** are the router's graph engine. There is rarely a direct pool between the two
  tokens a user wants to trade, so the system maintains an adjacency graph of every token that
  shares a pool with every other, and runs a breadth-first search to find a route. `SWPT` owns the
  graph and a path cache.
- **`SWP`** owns the state: pool properties, reserves, weights, amplifier, fees, the LP-token
  registry, ownership, the principal-token list, and the admin levers.
- **`SWPI`** issues pools and computes swap amounts (the "hopper" — a hop-by-hop route evaluation).
- **`SWPL`/`SWPLC`** add and remove liquidity, including *asymmetric* deposits (putting in an
  unbalanced ratio, which dilutes existing LPs and is therefore taxed).
- **`SWPU`** executes swaps, enforces slippage, and runs the smart router.
- **`MTX-SWP`** is the multi-transaction (`defpact`) variant of issuance and liquidity-adds, for
  operations too large for one transaction's gas budget.
- **`TS01-C3`** and **`TS01-P`** are the Talos wrappers — the only supported client doors.

**What breaks if SWP breaks.** Three distinct things, and the audit found instances of all three.

The first is **money moving wrongly in a single trade**: a rounding bias that always favours the
trader is a free, repeatable extraction from every liquidity provider; a solver that converges to the
wrong root can output more than the pool holds.

The second is **routing**: if the graph's node set is narrower than its edge set, long paths are
silently corrupted or lost — a user is told "no route" when one exists, or is routed through the
worst of several parallel pools. This is not a safety failure but it is a continuous, invisible
value leak.

The third is **pricing everything else**. SWP's `URC_OuroPrimordialPrice` publishes the canonical
dollar price of OURO, the gas token, to an on-chain oracle. DEMIPAD launchpad payments convert
with it. The Explorer displays it. A pricing error here is not contained to swaps at all — and §3.4(f)
is exactly that case.

---

## 3.2 How it was audited

**Round I — nine parallel deep-read passes over eleven files, read-only.** Same contract as its
siblings: load `StoicSyntax.md` first, work read-only, assume nothing is correct despite being live
on mainnet. Round I produced **71 findings — 13 CRITICAL, 12 HIGH, 14 MEDIUM, 32 LOW**. [V-cmd]

Two things make this round methodologically different from ATS and DALOS.

**There was no reference implementation to diff against.** AQP had the UrStoa RPS vault as ground
truth; SWP had nothing. So the AMM maths was verified against *first principles*: standard
Curve-style StableSwap and Balancer-style weighted invariants re-derived algebraically and checked
term-by-term against the source, then **numerically simulated** — replicating the exact Pact
`floor`/`fold` sequence — and tested against conservation, monotonicity and round-trip neutrality.
[REPORTED — `SWP/README.md` § Method]

**Several findings were found twice, independently.** `URC_BestEdge` was found by both the SWPT and
the SWPI auditor; the rounding-direction bias by both the `U|SWP` and the SWPI auditor; the
defpact Global-Admin-Pause gap by both the MTX-SWP and the Talos auditor. All thirteen CRITICALs were
then lead-re-verified directly against source, and the two mathematical ones independently re-derived
and simulated. Cross-corroboration, recorded as such rather than counted twice.

**Round I — owner feedback, and the rule that exists because it was broken.** Findings were presented
one at a time in `ISSUES-RANKED.md` order. The README carries a HARD RULE in capitals:

> *"This is not optional bookkeeping — it's what 'closed' means… This rule exists because C4 (#11C),
> C5 (#12C), and C6 (#13C) were skipped over silently mid-session on 2026-08-17/18 — not refuted,
> not deferred on purpose, just missed — and the gap wasn't caught until the owner asked to audit the
> audit."* [V-read — `SWP/README.md`]

Three CRITICALs were lost mid-session and recovered only because someone audited the audit. That is
in the tree's own front matter, in bold, and it is the most useful sentence in it.

**Round II — 49 numbered fixes.** The methodology is stated as non-negotiable in `HANDOFF.md` and is
stricter than either sibling's:

> *"(1) verify every claim against live source before accepting it, don't trust the finding doc or
> your own memory; (2) apply the fix; (3) build a REPL reproduction; (4) **adversarially prove it** —
> revert just the fix (surgically, by hand, never via git), confirm the bug reproduces, restore the
> fix, reconfirm; (5) run the full regression suite; (6) log in all four places."* [V-read]

Step 4 is the one that matters, and the handoff is explicit that the owner *"explicitly and
repeatedly demanded"* it: **do not trust a green test you have not watched fail first.** The
"never via git" clause is not stylistic — it cites a confirmed data-loss incident where a `git stash`
raced two concurrent sessions in a shared worktree and silently reverted files for both, twice.

**Three sub-programmes ran alongside the findings list**, and they are why this tree is twice the size
of its siblings:

1. **`#34M` / M2, promoted to a MASTER ISSUE.** What began as "BFS keeps only one chain per node and
   routing does no cross-route comparison" became a 13-phase programme, because fixing it surfaced a
   worst-case *execution-gas* crisis: 6–7 million gas against a ~2,000,000 ceiling at realistic
   scale, 56.9% of it from a previously-unknown source (`XE_UpdateStoaValue`), not from the routing
   itself. The outcome was a redesign — dirty-read path injection, a bundle-based `C_SmartSwap` — and
   a measured **7,145,298 → 397,043 gas** on the identical worst-case swap. [REPORTED]
2. **`#65bL`, a 9-phase gas-optimisation arc.** Cold-cache worst case **5,094,054 → 1,296,898**
   (74.5%); warm cache 1,143,255 (77.6%). [REPORTED] Phase 3 of it is worth naming because it
   *failed*: a binary search over a sorted raw-graph list looked like a win on a synthetic benchmark
   and **regressed by +27,527 gas** in the real integrated measurement. It was reverted and recorded
   as a genuine negative result rather than dropped. That is rare and it should be credited.
3. **A Kaddex/KDX comparison.** The audit pulled real Kadena-mainnet DEX source into
   `reference/` and diffed design decisions. Almost nothing survived scrutiny — the audit's
   conclusion on whether SWP needs Kaddex's `MUTEX` reentrancy lock was *no* — but three findings
   trace back to it (`#72C`, `#73C`, `#74`). And the comparison produced its own correction: the
   first supporting claim ("Pact detects recursion") was accepted from Kaddex's own source comment
   without proof, then went back and was independently established — finding along the way that the
   first proof attempt was confounded by `try` forcing read-only execution on anything it wraps.

**Round III was ruled out of scope on this branch** (owner, 2026-08-27): *"this branch's job was the
initial fix, scoped and now complete."* `ROUND-03-REVERIFY.md` was never created and does not exist.
[V-cmd] **But unlike ATS and DALOS, SWP did eventually get one** — as part of the Part III programme,
recorded in `ARCHITECTURE/DEFECT-LEDGER.md` §8.2: *"Every `FIXED` finding in the SWP audit tracker
was re-verified against current source — 75 rows, 42 fixes, 100% covered, not sampled. Result: 41
VERIFIED-PRESENT, 1 NOT-FOUND."* [V-read] This chapter re-checks a sample of that re-verify and
agrees with it, including on the one that was missing.

---

## 3.3 The findings

**Counting, with the denominator stated.** Round I produced **71** findings (`#1C`–`#71L`: 13C, 12H,
14M, 32L). Twelve more were added off-cycle afterwards — `#32bM`, `#34bM`, `#65bL`, `#65cL`, `#65dL`,
`#65eL`, `#65fL`, `#65gL`, `#65hL`, `#72C`, `#73C`, `#74` — for **83 distinct finding IDs**. The
tree presents them in **75 tracker rows** in `README.md` (several findings share a row) and **79
entries** in `ISSUES-RANKED.md` (the four `#65dL`/`#65eL`/`#65fL`/`#65hL` never got their own ranked
entry; they live in the tracker and in `ROUND-02-FIXES.md`). [V-cmd] All three numbers are correct
for their own denominator; none of them is "the number of findings" without saying which.

The table below follows the ranked order. Severity is as recorded.

### CRITICAL

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#1C` / C10 | Asymmetric liquidity-add mints the naive LP amount, not the invariant-fair `taxd-lp` | **REFUTED** | The deficit *is* priced and charged, via an oracle-based IGNIS tax the caller cannot supply; the original walkthrough omitted that mandatory payment. Substance folded into H8. [REPORTED] |
| `#2C` / C13 | `SWPLC::C_Fuel`'s indirect branch can credit unbacked reserves; sole gate is a trivially-true IMC cap | **REFUTED** | Self-caught via the audit's own REPL PoC: Pact 5 requires module-admin of the target module before `with-capability` grants its caps from outside. [REPORTED] |
| `#3C` / C2 | Stable-pool Newton solver has no domain guard — oversized swaps converge to the wrong root, output can exceed pool balance | **FIXED** | `1_Utilities/12_U_SWP.pact:326-355` — `UC_ComputeY` reseeds from `D` (Curve-style reference), comment names the C2 fix at `:355`. Scope was narrowed to stable pools only — W/P are closed-form with no seed-dependent root. [V-read] **Witnessed**: `SWP\|TX 015` in `[6.3]_SWP.repl` + `[6.2+3]_DPTF-SWP_Issuance-Only.repl`. [V-cmd] |
| `#72C` | `UC_ComputeInverseY` — C2's inverse-direction sibling, left explicitly open and never picked up: asking for ≥ the pool's own output reserve either crashed **uncatchably** (`div by zero, decimal`) at the ceiling or **silently returned a fabricated number** past it | **FIXED** | `12_U_SWP.pact:420-422` (now `UCv_ComputeInverseY`) — `(enforce (< output-amount xo) …)` placed *before* the invalid coefficients are computed, with 10 lines of `@doc` on why no seed choice can fix it. [V-read] **Witnessed**: `SWP\|TX 015b` in `[6.2+3]_DPTF-SWP_Issuance-Only.repl`. [V-cmd] |
| `#73C` | `URC_WorthWSTOA` — **two** bugs: the OURO shortcut ignored the primordial pool's own weights; the general fallback simulated a swap of the *entire* reserve instead of pricing one unit and scaling | **FIXED** | `16_SWPI.pact:1797` — `URC_SingleOuroWorthWSTOA` now performs a real 1-unit weighted swap via `UC_ComputeWP`; the general fallback prices 1 unit and scales across all three `WorthWSTOA` variants. [V-read] **Witnessed**: `SWP\|TX 032z8e`, `SWP\|TX 032z6f`. [V-cmd] |
| `#74` | `UEV_Issue` has no distinctness check on a caller's `pool-tokens` list | **VERIFIED SAFE, documented, no fix** | Rejected one layer down by `TFT::C_MultiTransfer`'s own `UEV_IzUnique`, reached because both issuance paths share `XE_IssueWrite`. `@doc` added recording where the protection lives. **Witnessed**: `[6.3]_SWP.repl:4405` `SWP\|TX 032o3`, which asserts the exact message `"Unique Items Required, duplicate item found: OURO-98c486052a51"`. [V-read] |
| `#4C` / C12 | `C_ToggleSwapCapability` has no ownership check anywhere — free DoS on any pool | **REFUTED** | The original trace stopped at the first `with-capability` block and missed the second, which gates the actual write behind `SWP\|C>ADD-OR-SWAP` → `CAP_Owner`, unconditionally, on both toggle directions. [REPORTED] |
| `#5C` / C11 | Slippage bound is checked against the fee-exclusive gross quote, never the net amount delivered | **DESIGN** | Feeless-vs-feeless comparison correctly protects against reserve/price movement; the residual fee-rate-change gap is answered by the `fee-lock` primitive. See §3.5. [REPORTED] |
| `#6C` / C1 | `URC_BestEdge` picks the pool with the **least** output — argmin instead of argmax | **FIXED** | `16_SWPI.pact:1655` — comment: *"C1 fix: keep the index with the LARGER output (argmax), not smaller (argmin)"*. [V-read] |
| `#7C` / C3 | All six swap formulas round toward the trader — repeatable, fee-free round-trip profit | **STABLE FIXED / WEIGHTED ACCEPTED** | Root cause was **not** floor/ceiling placement: Pact's native `^` silently uses float64 for decimal exponentiation. Fixed for the stable pool via exact-multiplication `UC_IntPow` (`12_U_SWP.pact:508`) and by flooring the *final* output rather than the intermediate (`:378`, `:450`, `:635`, `:702`). Weighted remains open by design — see §3.5. [V-read] |
| `#8C` / C7 | `C_ModifyWeights` has no length-parity check and a dead, never-enforced precision check | **FIXED** | `15_SWP.pact:503-532` — `UEV_UniformList` for parity, plus a real per-weight `enforce` (precision + `>= 0.1` floor) replacing the discarded map, plus `= 1.0` sum. [V-read] |
| `#9C` / C8 | `C_UpdateAmplifier` has **zero** bound check, including on the module's own `-1.0` "not a stable pool" sentinel | **FIXED** | `15_SWP.pact:606-607` — `(and (>= new-amplifier 1.0) (<= new-amplifier 2000.0))`. The ceiling is evidence-backed: `:598-602` records a REPL convergence-degradation sweep on a skewed pool, not a guess. [V-read] |
| `#10C` / C9 | Pools issued via the MTX-SWP defpact are never registered in `SWP\|LP` — every such pool's LP token hard-aborts AQP LP-stake admission | **FIXED** | `15_SWP.pact:1744-1787` — the `insert SWP\|LP` folded into `XE_Issue`, which both paths call; comment names the C9 fix. [V-read] |
| `#11C` / C4 | `UEV_Issue` never checks individual weights `> 0` — a `0.0`-weight token makes a W pool permanently untradeable | **FIXED** | `16_SWPI.pact:2564-2578` — the dead map now wraps a real `enforce` combining the precision check with a `>= 0.1` floor, matching `SWP\|S>WEIGHTS`'s bound so issuance and modification agree. [V-read] |
| `#12C` / C5 | `UEV_Issue` never checks individual genesis reserves `> 0` | **REFUTED** | Validated on every issuance path by the mandatory funding transfer itself (`C_MultiTransfer` → `XB_DebitTrueFungible` → `DPTF\|C>DEBIT` → `UEV_Amount`), just not inside `UEV_Issue`. The original trace stopped one defcap too shallow. [REPORTED] |
| `#13C` / C6 | The routing graph's node set is narrower than its live edge set — paths of 4+ hops corrupted or silently lost | **FIXED** | `12_U_SWP.pact:993 UC_MakeGraphNodes` now builds from the full caller-supplied swpairs universe. [V-read] Adversarial repro: reverting only this function broke *pool issuance itself* (a 3-hop connectivity check failed), which is a stronger demonstration of reach than the finding claimed. [REPORTED] |

### HIGH

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#14H` / H9 | Reentrancy ordering window in `XI_Swap` via a smart-account guard callback | **REFUTED** | Callback is reachable, but an isolated Pact 5 repro proved any write attempted from guard evaluation is blocked (`Operation disallowed in read-only or sys-only mode`) and is not even `try`-catchable. [REPORTED] |
| `#15H` / H10 | Global Admin Pause not honoured on `defpact` continuation steps | **DESIGN** | Step-0-only GAP gating is intentional and consistent across all 6 `defpact` flows in the codebase. Residual time-window exposure rides on `#68L` (no TTL). [REPORTED] |
| `#16H` / H12 | `SWP\|S>UPDATE-SUPPLIES` accepts non-positive reserve values unchecked | **FIXED** | `15_SWP.pact:536-552` — an unconditional non-negativity `enforce` inside the map lambda. [V-read] |
| `#17H` / H11 | `can-add` gates both deposits **and** withdrawals — one owner key can freeze every LP's exit | **FIXED** | `18_SWPLC.pact:962-963` — `UEV_RemoveLiquidity`'s `@doc` now states *"intentionally does NOT gate on `<can-add>`"* and the check is gone. Decided after industry research: Curve and Balancer both structurally exempt LP exit from their pause. [V-read] |
| `#18H` / H6 | `A_DefinePrimordialPool` reads `primality` but never enforces it | **FIXED** | `15_SWP.pact:800-804` — `primality` is now the sixth term of the fold; comment names the H6 fix. Live adversarial repro was found *structurally impossible* (`UEV_CheckAgainstMass` blocks any duplicate 3-token pool once the real one exists) and the audit said so rather than claiming a repro. [V-read] |
| `#19H` / H4 | Tracer graph is append-only; disabled/frozen/sleeping pools never filtered; no fallback route | **FIXED** | `16_SWPI.pact:1354-1360` — `URC_BestEdgeFiltered` restricts edge candidates to the call's own active universe; `URC_HopperActive` (`:111`) is the live-swap entry, `URC_Hopper` stays unfiltered for issuance-time pricing (`:1504-1505`). A **second layer** was needed after adversarial testing caught a disabled *parallel* pool still being selected. [V-read] |
| `#20H` / H2 | `URC_ComputeGraphPath` crashes (`at 0 []`) instead of returning a clean "no path" | **FIXED** | `14_SWPT.pact:604`, `:963`, `:1046` — `(if (> (length fp) 0) (at 0 fp) [BAR])` in all three variants. [V-read] The first repro attempt hit a pre-existing short-circuit instead of the real crash; the audit records the correction. [REPORTED] |
| `#21H` / H3 | Removing a principal token permanently orphans every Tracer entry filed under it, with no resync path | **FIXED (redesign)** | Not a patch: `SwapTracerV1 → V2` (now `V3`), the principal-keyed `SWPT\|Tracer` replaced by a plain token-adjacency `SWPT\|Graph` (`14_SWPT.pact:350`). **Nothing in SWPT is keyed by principal identity any more**, so orphaning is structurally impossible. Migration utility `SWPI::A_RebuildGraph` (`16_SWPI.pact:2711`), proven idempotent. [V-read] Three follow-ups: principals capped at 7, removal floored at 2 remaining, `A_RotatePrincipal` added (`15_SWP.pact:158`), and majors made permanently fixed (`URC_IsMajorPrincipal`, `:106`). [V-cmd] |
| `#22H` / H7 | Two unreconciled asymmetric-deficit pricing models stack in Standard mode | **DESIGN** | Both charges are meant to stack, and both were verified scoped exclusively to the asymmetric portion — two distinct levies on one base, not double-billing. [REPORTED] |
| `#23H` / H5 | Weight-precision validation in `UEV_Issue` computed then discarded — dead code | **FIXED** | Closed as a byproduct of `#11C`: H5's exact location *is* the map that C4's fix wrapped in a real enforce. Logged rather than silently dropped. [V-read] |
| `#24H` / H1 | `UC_ComputeD`/`UC_ComputeY` use a fixed iteration count with no convergence check | **FIXED** | `12_U_SWP.pact:370-374`, `:445-446`, `:548` — all three bumped to 12 iterations, `@doc` at `:521-530` records the measurement: at 1000× skew `UC_ComputeD` at 6 iterations was **0.0078 short** and fully converged (bit-identical to a 255-iteration reference) by iteration 10; 12 gives 2 iterations of margin. Pact is Turing-incomplete, so a dynamic convergence break is not expressible. Cost measured: **+64 gas flat** per stable swap. [V-read] |
| `#25H` / H8 | Asymmetric-deficit compensation never returned to the diluted pool's own LPs | **DESIGN** | Protocol-wide value capture (treasury / special targets / primordial-pool boost) is the intended model, not per-pool LP protection. [REPORTED] |

### MEDIUM

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#26M` / M9 | Slippage bound is symmetric (min *and* max), not a pure floor — a swap can revert because the price moved **in the user's favour** | **FIXED** | `19_SWPU.pact:1389` and `:1449` — upper bound commented out, not deleted, at both consumer sites, with a cross-reference between them. Researched against 5 protocols first: floor-only everywhere, zero counter-examples. [V-read] |
| `#27M` / M13 | `SmartSwapNoSlippage` recomputes the pools to refresh via a fresh post-swap BFS instead of the swap's own traversed edges | **FIXED** | `3_Talos/04_TS01-C3.pact:963`, `:1045` — `(if (= (length out) 4) (at 3 out) [])`, the swap's own recorded `distinct-edges`. The `(= (length out) 4)` guard is a *later* repair on top of the fix: indexing `(at 3 out)` unconditionally turned every refused swap into an index fault. [V-read] |
| `#28M` / M10 | `kda-pid` snapshotted at defpact Step 0, reused at Step 1, no re-validation or TTL | **DESIGN** | A fixed price across one logical multi-step event is intentional; re-pricing mid-flow would be internally inconsistent. Residual exposure rides on `#68L`. [REPORTED] |
| `#29M` / M8 | Draining LP supply to exactly zero re-triggers genesis-ratio pricing regardless of dust in tracked reserves | **REFUTED** | *"If dust is left, it hasn't been drained to zero."* Reserves and LP supply hit zero together by construction; the finding's premise is a state the code cannot produce. [REPORTED] |
| `#30M` / M6 | `C_ChangeOwnership` is one-phase — a fat-fingered destination permanently strips the true owner | **DESIGN** | Mechanics confirmed; the mitigation (addresses are pasted or Stoic-tagged, and the UI previews the destination pre-sign) is client-side and complete for the threat. Consistent with every other one-shot transfer here. [REPORTED] |
| `#31M` / M7 | `C_EnableFrozenLP`/`C_EnableSleepingLP` have **no** pool-owner authorisation at all | **FIXED** | `15_SWP.pact:762-778` — `CAP_Owner swpair` added to both defcaps, each with a comment naming the `#31M/M7` fix. [V-read] |
| `#32M` / M11 | Permissioned pool issuance charges IGNIS+STOA **before** the admin gate that can reject it | **DESIGN → REOPENED → FIXED** | See §3.4(e). The design verdict rested on a premise retracted in 2026-08 and never revisited until 2026-09-17. Fixed today: `20_MTX-SWP.pact:1007-1027` hoists the whole `(if p …)` form into step 1, ahead of `UEV_Issue` and therefore ahead of all money. **Witnessed**: `RedTeam/[RT-F]_Griefing.repl:184` `<<RT-F-002>>`, with an attribution control. [V-read] |
| `#33M` / M12 | Explicit rollback costs strictly more than silent abandonment; no TTL on open pacts | **DESIGN (split)** | Rollback-costs-more **verified and measured** in Part III: 53.00 IGNIS extra, nothing refunded. No-TTL correctly closed at `#68L`. [REPORTED — `DEFECT-LEDGER.md` §8.4] |
| `#32bM` | **Off-cycle correction:** M11/M12's "MTX-SWP has zero Talos wiring, unreachable" premise is factually wrong — `TS01-CP` has wired it since the repo's first commit | — | Verdicts were **left as-is** and deferred. `3_Talos/05_TS01-P.pact:221-330` wires all six defpact starters. [V-cmd] Reopened and resolved 2026-09-17. |
| `#34M` / M2 | BFS keeps only one chain per node; routing does zero cross-route value comparison — **and the worst-case gas crisis found while fixing it** | **FIXED (13 phases)** | Phase 1 (best-of-3 by actual payout) stays live as the self-searching fallback; Phases 6–10 built the bundle/dirty-read redesign. `16_SWPI.pact:868-980`, `14_SWPT.pact` `PathCache`. [V-cmd] |
| `#34bM` | `UEV_Issue`'s Stable-pool anchoring allows *transitive* connectivity to `DLK` instead of requiring direct adjacency to any current principal | **FIXED** | `16_SWPI.pact` — rewritten to test the first token's direct neighbours against the full principal list; comment tag `#34bM` present. [V-cmd] Also repaired a test fixture that had been *relying on the bug* to build a long BFS chain. |
| `#35M` / M1 | Stable-swap maths silently drops all but the first input position | **REFUTED** | `URC_Swap` and `UC_BareboneSwap` both independently enforce `length(input-amounts) == 1` for pool-type `"S"` before `UC_ComputeY` is reached. [REPORTED] |
| `#36M` / M5 | `C_Issue` and `MTX\|C_Issue` duplicate the entire write-side issuance sequence, including a duplicated hardcoded genesis-mint constant | **FIXED** | `16_SWPI.pact:2653 XE_IssueWrite` is the single chokepoint; `:401 GENESIS_LP_SUPPLY` replaces the duplicated `10000000.0` literal, used at `:2694`. [V-read] Wiring the new call surfaced a genuine pre-existing gap: MTX-SWP's own `P\|A_Define` had never registered MTX-SWP as an approved IMC caller on SWPI. |
| `#37M` / M3 | Several helpers crash on empty input (`enumerate 0 -1` evaluates to `[0 -1]`, not `[]`) | **FIXED** | Guards at the 5 real root-cause sites. The owner initially pushed back, suspecting a botched rename; a repo grep confirmed zero callers on 4 of 7 named functions, and tracing the chain further than the finding did surfaced a **5th, previously unflagged** site (`SWPT::URC_MakeGraph`). Reachable from the live `CC_SmartSwap` whenever no pool has ever been issued. **Witnessed**: `SWP\|TX 003b`. [V-cmd] |
| `#38M` / M4 | BFS graph-node lookup linear-scans on every pop (O(V²)), no size cap | **FIXED** | `13_U_BFS.pact:382 UCx_GraphNodeLinks` rewritten to a single `filter` pass. Measured on the real ~102-pool topology: byte-identical 7-hop route, **423,762 → 256,867 gas (~39%)**. [V-read/REPORTED] |
| `#39M` / M14 | `ClientThreeV2`/`ClientPactsV2` overwritten in place instead of archived | **FIXED → SINCE DELETED → CLOSED AS SUPERSEDED** | **The only fix in this tree that is not present today.** See §3.4(d). [V-cmd] |

### LOW

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#40L` | `UC_LpID` calls a cross-module `UEV_*` from inside a nominally pure `UC_*` | **FIXED** | Traced the only caller: both lists are structurally guaranteed equal length, so the enforce could never fire. Removed; `12_U_SWP.pact:773`. [V-cmd] |
| `#41L` | The `UC_*` surface transitively inherits `enforce` from `U\|LST` bounds-guards | **DESIGN — documented exception** | Unlike `#40L`, these are load-bearing guards inside live maths; deleting them strips real crash protection. Codified as `StoicSyntax.md §6.1` (v1.8.0 → v1.9.0). [REPORTED] |
| `#42L` | `UC_ComputeWP`/`InverseWP` divide by a weight with no zero-guard | **CLOSED — covered by `#11C` + `#8C`** | Both issuance and modification floor every weight at `>= 0.1`. [V-read] |
| `#43L` | `UC_ComputeD`'s docstring claims 5 iterations; the code runs 6 | **CLOSED — byproduct of `#24H`** | Doc and code both say 12 now (`12_U_SWP.pact:521`, `:548`). [V-read] |
| `#44L` | `UCX_*`/`UDCX_*` is an uncodified naming tier | **TAGGED → since done** | `StoicSyntax-Prefixes.md` defines the tier; the rename landed (`UCx_GraphNodeLinks`, `13_U_BFS.pact:382`). [V-cmd] |
| `#45L` | `URC_AllGraphPaths` misleadingly named — returns one shortest chain per node | **FIXED** | Renamed `URC_ShortestChainPerNode` (`14_SWPT.pact:116`, `:610`, plus `FromRaw`/`FromGraph` variants). [V-cmd] |
| `#46L` | Smart Swap REPL coverage is one transaction with no route assertions | **FIXED** | `SWP\|TX 016a` now captures its return value and pins the measured output; the assertion was adversarially proven by corrupting the expected value and observing a real `FAILURE`. [V-cmd] |
| `#47L` | Unrecognised pool-type falls back to a silent `-1.0` sentinel | **REFUTED — unreachable by construction** | Every swpair ID is built by one exhaustive function (`UC_PoolID` → `UC_Prefix`, only `"S"`/`"W"`/`"P"`) called from one insertion point. Structurally closed, not merely unreached. [REPORTED] |
| `#48L` | Undocumented magic constants `5040000.0`, `10000000.0` | **DESIGN** | `10000000.0` is the same fixed genesis LP mint as `GENESIS_LP_SUPPLY`; `5040000.0` is owner-verified share-computation. [REPORTED] |
| `#49L` | `URC_Hopper`'s doc says "cheapest available edge" | **FIXED** | `16_SWPI.pact:1326` — corrected to "highest-output edge", matching what `#6C`'s fix made it do. [V-read] |
| `#50L` | `UR_StoaValue` performs an ungated table write as a side effect of a read | **FIXED** | `15_SWP.pact:1020-1032` — the `update` is gone; `@doc` records that the first-instinct fix (`with-default-read`) was tested and found *wrong* before being proposed, because its default doesn't cover a field missing from an existing row. [V-read] |
| `#51L` | `C_ModifyWeights` composes bare `(SECURE)` instead of a named master cap | **REFUTED — correct shape** | It is the module's one `C_*` whose write half is `XB_*` (genuinely called cross-module from SWPL) rather than `XI_*`; `XB_ModifyWeights` carries its own `UEV_IMC` + full named cap. [REPORTED] |
| `#52L` | `XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no `@doc` | **FIXED** | [REPORTED] |
| `#53L` | `UEV_PoolFee`'s 320.0 upper bound has non-obvious units | **FIXED (doc)** | Fee is per-mille, so 320.0 = 32%; mirrored across LP/special/boost components so the combined worst case is 960‰, leaving 4% fees can never consume. `15_SWP.pact:1529`. [V-cmd] |
| `#54L` | `AHU`/`AUP_SwapPair(s)` falls outside the module's prefix vocabulary | **DESIGN — `AU_` formalised** | The identical pattern repeats across 6 modules; `AU_` added to `StoicSyntax.md` v1.10.0, existing instances deferred to a cross-module sweep. [REPORTED] |
| `#55L` | `XE_CanAddOrSwapToggle` redundantly re-derives a check `UEV_IMC` already made | **FIXED** | `15_SWP.pact:1766-1774` — removed, with `@doc` explaining that reaching the line already proves the guard list passed. [V-read] |
| `#56L` | `URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*` | **FIXED + new convention** | 8 of 11 callers pass raw unvalidated amounts, so it is genuinely reachable and not tautological, and no single non-`URC_` chokepoint exists. Rather than choose between "leave incomplete" and "duplicate 8×", the **`v` (validating) specialisation** was formalised (StoicSyntax v1.10.0 → v1.11.0). Renamed `URCv_AreAmountsBalanced` (`17_SWPL.pact:187`, `:1667`) and a missing per-element negative check added. [V-read] |
| `#57L` | `XI_AddLiqSendAndMint` performs two distinct writes in one `XI_*` | **DESIGN** | Called from 3 sites — real reuse, matching the owner's own criteria for a shared wrapper. [REPORTED] |
| `#58L` | `\|KDA-PID`-qualified `defun` names deviate from prefix-only naming | **TAGGED → since done** | 308 occurrences across 17 files at the time. The rename landed: `01_U_CT.pact:364 UR_STOA-PID\|Price`. [V-cmd] |
| `#59L` | Reserve bump precedes the token transfer in `XE\|KDA-PID_AddLiqudity` | **FIXED (doc)** | Traced the real worry — does MTX-SWP's defpact split bump and transfer across steps? It does not; the whole function runs inside Step 1's `step-with-rollback`. `@doc` records the invariant for future callers. [REPORTED] |
| `#60L` | LP-branding fee attribution resolves via DPTF/DPOF `Konto`, not `SWP::UR_OwnerKonto` | **DESIGN** | `entity-owner` never drives a debit, only a 25% smart-account interactor credit; the pool owner's normal account wouldn't qualify either, so "fixing" it would lose the incentive rather than redirect it. [REPORTED] |
| `#61L` | `C_UpgradeBrandingLPs` commented out of the REPL suite — untested | **FIXED** | New `SWP\|TX 002` proving propose→upgrade moves pending branding to live and flips Gray→Blue; the original call was stale (wrong Talos module). [V-cmd] |
| `#62L` | `C_Fuel` has zero REPL coverage despite moving real funds | **FIXED** | New `SWP\|TX 038c` asserting the real DIRECT path bumps reserves by exactly the fuelled amounts, no LP minted. [V-cmd] |
| `#63L` | SWPLC defines no `XI_*` at all | **DESIGN** | SWPLC owns no domain tables; every `C_*` is pure orchestration and all real writes happen in the modules it calls. The absence is the natural shape of a 100%-orchestration module. [REPORTED] |
| `#64L` | `URC_Swap`/`URC_InverseSwap`'s `validation:bool` conditionally enforces from inside a `URC_*` | **TAGGED → since done** | The `v` specialisation was applied: `19_SWPU.pact:1284` calls `ref-SWPI::URCv_Swap`. [V-cmd] |
| `#65L` | `URC_HopperActive` computed **twice** per self-searching Smart Swap — once in the defcap, once in execution | **FIXED** | `h-obj` computed once and threaded through the cap chain. Measured: **5,094,054 → 4,593,400 gas (~9.8%)** on the ~102-pool checkpoint. [REPORTED] |
| `#65bL` | Off-cycle: the graph-search engine rebuilds the whole graph on every routing attempt, and the true dominant cost (per-pool STOA repricing, 56.9%) shares it | **FIXED (7 phases, 6 shipped)** | `SWPT\|PathCache` wired (`14_SWPT.pact`, 25 references), plus a topology-versioning repair (the cache was insert-only, never refreshable). Phase 1 alone: **477,825 → 11,491 gas (~41.6×)** warm. Phase 3 was built, measured, found to **regress**, and reverted. [V-cmd / REPORTED] |
| `#65cL` | Naming: `URC_WorthDWK*` inconsistent with the "Stoa" vocabulary | **SUPERSEDED — actioned as `#65gL`** | [REPORTED] |
| `#65dL` | Re-verification of `#21H` after the owner independently re-raised it | **No code gap; one stale `@doc` corrected** | Re-grepped every `UR_Principals` consumer; exactly one real caller outside the setters. [REPORTED] |
| `#65eL` | Major vs. minor principal distinction | **FIXED** | `15_SWP.pact:106 URC_IsMajorPrincipal` — a "major" is a live member of the primordial pool; majors are permanently fixed, never removable or rotatable. [V-read] |
| `#65fL` | Zero-search OURO/DLK shortcuts, boost-path caching | **FIXED** | Phase 8a measured **276,994 → 26,783 gas (90.3%)** on a warm hit. [REPORTED] |
| `#65gL` | `DWK`/`DLK` → `WSTOA`/`SSTOA` rename | **FIXED** | Caught a real near-miss: a word-boundary `sed` first pass renamed a hardcoded REPL pool-lookup string, because the genesis-configured tickers are *literally* `"DWK"`/`"DLK"`. Caught by full regression (`Load failed`), reverted, redone surgically. [REPORTED] |
| `#65hL` | Targeted/early-exit BFS | **FIXED** | `13_U_BFS.pact:274 UC_BFSTargeted`. Verified first that BFS as an algorithm *class* is optimal here (unweighted shortest path, no edge weights or admissible heuristic for Dijkstra/A* to exploit) — the gap was in the implementation. [V-read] |
| `#66L` | Failure-branch `OutputCumulator` objects hand-built rather than via a `UDC_*` | **FIXED** | Confirmed byte-identical reproduction via a standalone REPL check before the change, not just a code trace. [REPORTED] |
| `#67L` | `MTX\|C_AddSleepingLiquidity` burns a Step-0-cached nonce amount | **CONFIRMED SAFE, no change** | `DPOF::C_Burn` enforces live supply at execution time; a stale cache can only cause a revert, never an over-burn. This investigation is what surfaced `#32bM`. [REPORTED] |
| `#68L` | No TTL/expiry on any of the 8 `defpact` flows | **DESIGN — structural limitation** | Pact has no scheduled execution; nothing can run against an abandoned pact without someone submitting a continuation. Not expressible as ordinary Pact logic. **Still open.** [REPORTED] |
| `#69L` | `MTX-SWP\|S>ADD-LQ`'s doc implies a bounded `kda-pid` lock window | **CLOSED — premise doesn't hold** | The current `@doc` makes no such claim. [REPORTED] |
| `#70L` | `SWP\|C_Fuel`/`SWP\|C_Firestarter` public on `TS01-C3` but undeclared on its interface | **FIXED** | `3_Talos/04_TS01-C3.pact:88-89` declares both; implementations at `:625`, `:827`. [V-read] |
| `#71L` | `SWPU`/`SWPLC` call `SWP::C_ToggleAddOrSwap` directly rather than via an `XE_*` | **DESIGN — documented** | Rerouting to the existing `XE_CanAddOrSwapToggle` would silently strip real IGNIS billing, LP-role bootstrap, and **the only ownership check in the chain**. `15_SWP.pact:2165-2167` records why. [V-read] |

---

## 3.4 Six findings worth the telling

### (a) `#7C` / C3 — the rounding bias that was not a rounding bug

Two independent auditors reported the same thing: all six swap formulas round toward the trader
rather than the pool, giving a repeatable fee-free round-trip profit. Numeric simulation confirmed
the bias empirically. The obvious diagnosis is floor/ceiling placement — the classic AMM mistake —
and the obvious fix is to move the roundings.

The diagnosis was wrong. The audit traced it to **Pact's native `^` silently dropping decimal
exponentiation into IEEE-754 double precision**, confirmed empirically: on one call the result
differed from exact repeated multiplication by ~0.013 *absolute*. Pact's `+`, `-`, `*` and `/` on
decimals genuinely are arbitrary-precision; `^` is not, and nothing in the language says so.

That reframes the problem completely. The stable pool's exponents are always whole numbers (token
count, and count+1), so exact multiplication *is* available: `UC_IntPow` (`12_U_SWP.pact:508`)
replaces `^` there, and both directions were then proven exact — zero bias — live. [REPORTED] A
second, genuinely separate correction went in alongside: **floor the final output, not the
intermediate solved balance** (`:378`, `:450`, `:635`, `:702` [V-read]), keeping intermediates at
internal precision 24.

**The weighted pool cannot be fixed the same way, and the audit says so at the site.** `x^weight` is
a genuine fractional power; no exact-multiplication trick exists in pure Pact. `12_U_SWP.pact:590-603`
carries the reasoning verbatim [V-read]: writing a from-scratch high-precision power routine
(Newton's method or a power series) was *"assessed and explicitly declined as disproportionate to the
residual risk"* — the bias scales with float64's ~1e-16 *relative* precision, is orders of magnitude
below anything resembling insolvency, stays internally consistent (the same computed value backs both
the transfer and the reserve update), and for realistic non-24-decimal token precisions is routinely
swallowed entirely by final settlement rounding. It closes: *"Accepted as a bounded, documented
limitation of the underlying language, not tracked as an open bug."*

That is the right way to leave something open. The alternative — quietly fixing the stable half and
marking C3 "FIXED" — would have made the tracker look cleaner and the system less understood.

### (b) `#21H` / H3 — the finding that was answered by deleting the concept, not the bug

`SWPT` maintained a routing graph keyed by *principal token*. Remove a principal and every Tracer
entry filed under it was orphaned, with no resync path. The natural fix is a resync function.

The audit built one — and then did not stop there. It replaced the principal-keyed `SWPT|Tracer`
with a plain **token-adjacency** `SWPT|Graph` (`14_SWPT.pact:350` [V-read]). After the redesign,
**nothing in SWPT is keyed by principal identity at all**, so orphaning is not fixed, it is
*unrepresentable* — regardless of what any future remove or replace does. `SwapTracerV1` became `V2`
(and is now `V3`), and a migration utility `SWPI::A_RebuildGraph` (`16_SWPI.pact:2711` [V-read]) was
added and adversarially proven idempotent. Every prior `#13C`/`#19H`/`#20H`/`#11C` route assertion
was re-run and confirmed byte-identical post-redesign.

Then three follow-ups, each of which is its own small lesson:

- **Fix #13** capped principals at 7 and added `A_RotatePrincipal` as the retirement path.
- **Fix #14** re-allowed removal (safe now) but floored it at 2 remaining, and split "rotate into
  self" into its own distinct `enforce` so the error message tells you which rule you broke.
- **Fix #44 (`#65eL`)** — the owner, months later and unprompted by any code reference, re-raised
  the original concern as a possible "major vs. minor principal" gap. The audit **re-verified against
  current code rather than trusting its memory of the earlier fix**: grepped every consumer of
  `UR_Principals`, found exactly one real caller outside the setters, confirmed no regression — and
  then implemented the owner's actual new idea anyway. `URC_IsMajorPrincipal` (`15_SWP.pact:106`
  [V-read]) defines a "major" as a live member of the primordial pool and makes majors permanently
  fixed. Not because rotation was unsafe — `#65dL` had just proven it safe — but because there is no
  legitimate reason to retire OURO/WSTOA/SSTOA from the principals list, so the operation should not
  exist.

That last move is worth naming: *"we proved it can't break, and we removed the ability anyway"* is
a defensible position, and the tree records both halves rather than presenting the second as though
it repaired the first.

### (c) `#26M` / M9 — the guard that punished the user for good luck

`SWPU`'s slippage protection bound the output on **both** sides: a minimum *and* a maximum. A
maximum means a swap reverts because the price moved **in the user's favour** between quote and
execution. The user pays gas for a refusal that cost them nothing and would have profited them.

The audit did not argue from first principles; it checked what everyone else does. Five protocols
surveyed, **zero counter-examples** — floor-only, universally. Only then was the upper bound
disabled, and the choice of *how* is deliberate: **commented out, not deleted**, at both
`UC_SlippageMinMax` consumer sites, with a cross-reference between them
(`19_SWPU.pact:1389`, `:1449` [V-read]). The intent is recoverable if someone ever wants it back.

The detour is the instructive part. Testing the change required a *full swap execution*, not just a
module load — and that turned up **a real Pact 5 runtime bug**: a single-argument `and` parses fine
and fails at execution. A load-only check would have gone green with a broken swap path.

`#26M` also leaves a trace that Part III later picked up. The only tests naming *"out of Slippage
bounds"* are this finding's pair, and **both assert the message must NOT appear** — positive slippage
is deliberately allowed. So `19_SWPU.pact`'s `(>= feeless-final min)`, which the source itself calls
*"the real protection this whole check exists for"*, was asserted nowhere. Part III's `RT-A-004`
closed that. [REPORTED — `DEFECT-LEDGER.md` §8.3]

### (d) `#39M` / M14 — the fix a later sweep deleted, and why the deletion was right

M14 was small: the historical interfaces `TalosStageOne_ClientThreeV2` and `ClientPactsV2` had been
*overwritten in place* rather than archived, unlike the sibling `ClientFour` block in the same file.
Fix #25 reconstructed both from git history (commit `df2d72e`) and archived them.

Even the fix had a lesson in it. The first placement attempt — into the central interface registry,
which is what the finding literally described — **genuinely failed to load**. The finding's premise
was already out of date: live V3 had moved to deploy-with-module files, and V2's Smart Swap functions
need a module-owned type not resolvable that early. Relocated alongside their live V3 siblings
instead.

**On 2026-09-02, commit `6833a21` deleted them both.** [V-cmd] Its message reads:

> *"deleted dead old versions (ClientFourV1-V6BlockTime, ClientPactsV2, ClientThreeV2 — all 0/0)"*

Zero implementers, zero consumers — which is **the defining property of a deliberately-frozen
archive**. The tool's own heuristic guaranteed it would delete exactly the artefact the fix created,
and a usage counter cannot distinguish "unused because obsolete" from "unused on purpose". The sweep
also deleted `ClientFourV1-V6BlockTime`, the very precedent Fix #25 had cited as justification.

Part III's re-verify caught it — the single `NOT-FOUND` out of 42 re-checked fixes — and recorded it
as a silent deletion. **And then corrected itself, which is the part worth reading.**
`DEFECT-LEDGER.md` §8.6 [V-read]:

> *"The mechanism is right. **The intent was wrong, and the correction matters more than the
> finding.** `6833a21` was not a rogue tool. It was step 5b-2.4 of a sequenced phase executing a
> dated canon amendment — `StoicSyntax-Prefixes.md` §7.10, 'Retire the pool: delete the
> `0_Interfaces/` files; git history preserves old versions', written the same day. The frozen-copy
> convention was **deliberately abandoned**."*

And then the argument that settles it, which is about this repository's own cascade rule: a restored
archive **cannot be both loadable and historical**. The deleted V2 text carries 12 type references
to interface versions that no longer exist (`SwapperV3`, `SwapperUsageV2`, `BrandingV1`), so a
verbatim restore *fails to load* — proven at the time, since Fix #25's own first attempt died on
`Module SwapperUsageV2 has no such member: Slippage`. Rewriting those refs to today's versions
fabricates a "V2" typed against types V2 never saw. Meanwhile the archive that **did** live in-tree
was rewritten by three separate canon sweeps in ten days (+92% in size) until its `@doc` described a
surface that never existed.

> *"An in-tree archive is a strictly worse provenance store than git: mutable, swept, deployed, and
> silently falsifiable."*

**M14 is closed as SUPERSEDED. Nothing was restored, and nothing should be.** [V-cmd — the
interfaces are absent tree-wide] This chapter records it as the tree's one deleted fix not because
the deletion was wrong, but because a reader checking this audit's claims will find a `FIXED` verdict
whose artefact is gone, and deserves to know which of the two possible reasons applies.

### (e) `#32M` / M11 — the verdict whose premise was retracted, and sat for three weeks

This is the case the book's own front matter is describing when it says a reachability claim needs
re-checking.

**2026-08-19.** M11 reported that permissioned pool issuance through the `MTX-SWP` defpact charges
IGNIS and STOA *before* the admin gate that can reject it. Verdict: **DESIGN — accepted, confirmed
non-live.** Fee-before-gate ordering is a deliberate anti-abandonment incentive for defpact flows;
and, independently, *"`MTX|C_Issue` and every `MTX-SWP` defpact have zero Talos wiring anywhere in the
codebase — unreachable through the only supported client/gas-station path."*

**2026-08-27.** While investigating an unrelated LOW (`#67L`), the audit discovered the premise was
**factually wrong**. `TS01-CP` (`05_TS01-P.pact`) had wired `MTX-SWP::C_IssueStablePool`/
`WeightedPool`/`StandardPool` **since the repository's first commit**. This was logged honestly as
`#32bM`, marked as *"the one open item"* in `MERGE-HANDOFF.md` — and, per owner direction, the
verdict was **left as-is** and deferred to a main-branch red-team pass rather than reopened.

**2026-09-17.** The red-team pass reached it. `05_TS01-P.pact:221-330` wires **all six** defpact
starters; the wrapper takes `p:bool` straight from the client and gates nothing but `P|TS`. [V-cmd]
And M11 was proven **by execution**, each step in its own committed transaction [REPORTED —
`DEFECT-LEDGER.md` §8.4]:

| step | what happens |
|---|---|
| 0 | `SWPI::UEV_Issue … p` — **no authorisation check of any kind**. `p=true` *skips* the spawn-limit branch, so the permissioned path is the **laxer** one. |
| 1 | **commits 5,506.0 raw IGNIS + 600.0 raw STOA** (2,919.77 / 459.0 net) |
| 2 | `GOV\|MTX-SWP_ADMIN` refuses: `"MTX-SWP Ownership not verified"` |

No refund, no cancel. Rollback costs a **further 53.00 IGNIS**; abandoning leaves the pact open
forever (`#68L`). Three controls were run, because an unattributable refusal proves nothing:
*attribution* (the same drive at `p=false` fails with a **different** message, so the `p=true`
refusal is the admin gate and nothing else), *non-vacuity* (it completes when the master key signs),
and the contrast that makes it a defect — **the single-transaction twin refuses the identical
operation and charges zero**, because `SWPI|C>ISSUE` (`16_SWPI.pact:424`) hoists its conditional
admin gate above `UEV_Issue`, exactly as the 2026-09-14 authorise-first ruling requires.

> Same logical operation, two live Talos doors, and only one charges you for a refusal — selected by
> `p`, an undocumented raw bool on the Talos signature whose `@doc` never mentions it.

**And it falsified a claim in the ledger written by the same programme.** `DEFECT-LEDGER.md` §7.3 had
recorded `MTX|C_Issue` as *"the counter-example, and it is the specification — validation before
money"*. That is true for `p=false` and false for `p=true`: *shape* validation precedes the money;
*authorisation* follows it. The op cited as the specification was carrying the unrepaired case, and
the owner had ruled with that framing in front of them. §8.4 says so in the first person.

**Fixed 2026-09-17.** `20_MTX-SWP.pact:1007-1027` [V-read] hoists **the whole `(if p …)` form** into
step 1, ahead of `UEV_Issue` and therefore ahead of all money. Not the bare acquire — the in-source
comment is explicit about why:

> *"THE WHOLE CONDITIONAL FORM IS HOISTED, not the bare acquire: only a PERMISSIONED issuance needs
> the admin key, so unwrapping the branch would convert a conditional gate into an unconditional one
> and lock out every ordinary pool issuance. That is the exact mistake CLAUDE.md records a scripted
> reorder making during the sweep."*

Pinned by `RedTeam/[RT-F]_Griefing.repl:184` `<<RT-F-002>>` [V-read], with an attribution control the
block needs more than most: `PK_AncientHodler` is *both* an ordinary account key and a
`DemiurgoiSithMasters` member in this fixture, so an ANHD-signed drive would pass the gate and prove
nothing. The same call with the same signer and only `p` flipped must fail for a **different** reason
— and does (`:231`).

**M12 splits the same way.** "Rollback costs more than abandonment" is now **verified and measured**
(53.00 IGNIS extra, nothing refunded); "no TTL" remains correctly closed at `#68L`.

One inference is named rather than hidden: the fixture conflates identities, so what was *measured*
is that step 1 charges and that step 2's first and only obstacle at `p=true` is the master keyset.
That a caller who cannot satisfy it therefore pays and is refused is **one inference step**, not a
measurement. Closing it needs a non-Demiurgoi account that owns a DPTF.

### (f) `#73C`'s twin — the follow-up that was filed, not chased, and was worth 38%

`MERGE-HANDOFF.md` closed the SWP branch with a section headed *"The one item genuinely worth a look,
not just deferred by design"*:

> **`URC_OuroPrimordialPrice`'s dollar-denominated math** — flagged in `#73C`'s own writeup as
> *likely* carrying the identical weight-omission bug just fixed on the WSTOA-denominated side. Both
> build off the same shared core… This is **not confirmed** — nobody has traced or reproduced it —
> but given the WSTOA sibling's bug was real and the two functions share the exact same math shape,
> it's the most likely next real finding in this file. **Recommend a 15-minute trace.**

The lead was also written into the source, verbatim, in `URCx_PrimordialValueAndOuroSupply`'s own
`@doc`. It sat unopened for nineteen days, because it was filed as a *lead* rather than a *defect*.

The 15 minutes were eventually spent, and it was real. `URC_OuroPrimordialPrice` computed
`((R_wstoa + R_sstoa·k) × pid) / R_ouro` — a flat reserve ratio that **reads no weight at all**.
It was proven not by reading but by controlled experiment: reserves held constant, weights varied
through the live `SWP|C_ModifyWeights` path [REPORTED — `DEFECT-LEDGER.md` §8.1]:

| pool weights `[SSTOA, OURO, WSTOA]` | `URC_OuroPrimordialPrice` | weight-aware sibling | error |
|---|---|---|---|
| `[0.4, 0.4, 0.2]` | `0.09200067782692156…` | `0.11998182062980…` | −23.3% |
| `[0.2, 0.6, 0.2]` | `0.09200067782692156…` *(bit-identical)* | `0.17996364248400…` | −48.9% |
| **`[0.3, 0.5, 0.2]` (genesis)** | `0.09200067782692156…` *(bit-identical)* | `0.14997348886490…` | **−38.65%** |

**The output does not move by a single digit across three weightings of the pool it prices.** And it
is not latent: `SWP|C>DEFINE-PRIMORDIAL-POOL` (`15_SWP.pact:781`) enforces a *weighted* pool of
exactly three tokens — three equal decimal weights cannot sum to 1.0 — so the pool it serves
**cannot** be equal-weighted. Genesis ships `[0.3 0.5 0.2]`.

Blast radius: the oracle write publishes it as the canonical OURO price on every swap touching the
primordial pool; DEMIPAD launchpad payments convert with it; the Explorer derives display values from
it. `OUROBOROS`'s compress/sublimate clamp below $1.00 and so are masked *today* — a masking that
ends the moment OURO's true price crosses $1 while the understated feed is below it.

**Fixed 2026-09-17** by **delegation, not re-derivation**: `16_SWPI.pact:1768-1796` [V-read] now calls
`URC_TokenDollarPrice` → `URC_SingleWorthWSTOA` → `URC_WorthWSTOA`'s OURO short-circuit →
`URC_SingleOuroWorthWSTOA`, a real 1-unit weighted swap through `UC_ComputeWP` — the only maths in
the family that consumes the weights. That path is `#73C`'s own repair, already live and proven, so
the fix introduces no new arithmetic. *The defect was that a second implementation existed at all.*

And the commit says the thing that makes this the most useful story in the chapter:

> *"THE FIX CHANGED NO ASSERTION, WHICH IS THE POINT. The gate came back at 22,941 both before and
> after, because nothing in the suite pinned an OURO price. A 38% repricing of the token behind the
> oracle write, DEMIPAD launchpad payments and the Explorer moved not one test. **That is how the bug
> shipped and how its repair could have regressed unnoticed.**"* [V-cmd — `git log 15dd7b7`]

The witness added, `<<SWP-G27>>` (`REPL/modules/SWP.repl:5321` [V-read]), pins the **invariant**
rather than a figure — OURO's price must equal what the generic weight-aware pricer returns for OURO
— because a literal would pin today's reserves and go red on any ordinary trade, while the invariant
only breaks if someone re-derives the price by hand again. And it carries its own counter-example:
the *removed* formula is recomputed inline from the same shared core and asserted to **disagree**
(`:5367`), so every run re-proves both that the guard discriminates rather than comparing something
to itself, and that the original defect was real on live reserves.

**One adjacent defect found in the same trace is still latent.**
`URCx_PrimordialValueAndOuroSupply` hard-codes reserve positions `0=SSTOA, 1=OURO, 2=WSTOA`, while
`C>DEFINE-PRIMORDIAL-POOL` checks only membership and length — no order check, no sort on the
issuance path. A primordial pool issued with the same three tokens in a different order silently
transposes the reserves. Unreachable today only because genesis and the fixture happen to use the
matching order. [REPORTED — §8.1]

---

## 3.5 What remains open

### Open by design, and material

| item | state | why |
|---|---|---|
| **`#7C` / C3, weighted half** — round-trip bias in weighted pools | **Accepted known limitation.** Documented in place at `12_U_SWP.pact:590-603`. [V-read] | `x^weight` is a genuine fractional power; Pact's native `^` drops to float64 and there is no exact-multiplication trick. A from-scratch high-precision power routine was assessed and declined as disproportionate: the bias is ~1e-16 *relative*, internally consistent, and usually swallowed by settlement rounding. **It is a real, permanent, bounded arbitrage against weighted-pool LPs.** |
| **`#5C` / C11** — slippage compares fee-exclusive quotes | **Design.** | The feeless-vs-feeless comparison correctly catches reserve/price movement. The residual — a pool owner changing the *fee rate* between quote and execution — is answered by the `fee-lock` primitive, which is real, `enforce`d and publicly queryable. But **it is unlocked by default**, so the protection is opt-in by pool owner. An integrator quoting against an unlocked pool has no fee-rate guarantee. |
| **`#25H` / H8** — asymmetric-deficit compensation is not returned to the diluted pool's LPs | **Design.** | It is captured protocol-wide (treasury, special targets, primordial-pool boost). LPs in a pool that receives a large asymmetric deposit are diluted and compensated *indirectly*, not directly. This is a legitimate design choice and it should be visible to anyone providing liquidity. |
| **`#68L`** — no TTL on any of the 8 `defpact` flows | **Structural.** | Pact has no scheduled execution; nothing can force-expire an abandoned pact. Open pacts persist forever. `#15H` and `#28M`'s residual time-window exposure both ride on this, explicitly. |
| **`#33M` / M12** — explicit rollback costs more than silent abandonment | **Design, now measured.** | 53.00 IGNIS extra, nothing refunded. For the AddLiquidity family this is a ruled anti-spam design; the `MTX\|C_Issue` instance has no such ruling but is small next to what M11 was charging. [REPORTED] |
| **`#4C` / C4-equivalent trust levers** | — | `#30M` (one-phase ownership transfer), `#60L` (fee attribution), `#48L` (magic constants) are all closed as design with client-side or owner-side mitigations. None is a defect; all are trust assumptions a reader should be able to see. |

### Latent, found but not chased

- **`URCx_PrimordialValueAndOuroSupply` hard-codes reserve order.** `0=SSTOA, 1=OURO, 2=WSTOA`,
  while the defining capability checks only membership and length. A primordial pool issued with the
  same tokens in a different order transposes the reserves silently. Unreachable today only because
  genesis and the fixture use the matching order. [REPORTED — `DEFECT-LEDGER.md` §8.1] **No finding
  ID, no fix, no pin.**
- **A measured aside from the M11 work, not chased:** `MTX|C_Issue` step 0 is the only
  Talos-reachable SWP client op found that collects **zero IGNIS while doing real work** — 4,124 gas
  at `p=true`, **76,934 at `p=false`** — while its three sibling defpacts all take
  `LQ|INITIATION-FEE` in step 0 as anti-spam. `GAS_PAYER` Case 1 whitelists the `ouronet-ns.TS…`
  prefix, so the station pays it. [REPORTED — §8.4]

### Tagged-for-sweep items that have since been done

Four LOW findings were deferred to a protocol-wide StoicSyntax pass rather than fixed piecemeal. That
pass ran, and all four are closed, though the SWP tracker was never updated to say so:

| finding | then | now |
|---|---|---|
| `#44L` | `UCX_*`/`UDCX_*` uncodified tier | `UCx_GraphNodeLinks`, `13_U_BFS.pact:382` [V-cmd] |
| `#58L` | `KDA-PID` → `STOA-PID` across 308 sites in 17 files | `01_U_CT.pact:364 UR_STOA-PID\|Price` [V-cmd] |
| `#64L` | `URC_Swap` → `URCv_Swap` | `19_SWPU.pact:1284` calls `ref-SWPI::URCv_Swap` [V-cmd] |
| `#54L` | `AU_` category formalised, instances deferred | `StoicSyntax.md` v1.10.0 [REPORTED] |

For completeness, the interface cascade also completed: every SWP-family interface is now one to two
versions ahead of where the audit left it — `UtilitySwpV2`, `BreadthFirstSearchV2`, `SwapTracerV3`,
`SwapperV4`, `SwapperIssueV4`, `SwapperLiquidityV2`, `SwapperLiquidityClientV2`, `SwapperUsageV3`,
`SwapperMtxV4`, `TalosStageOne_ClientThreeV4`, `TalosStageOne_ClientPactsV4`. [V-cmd]

### Fix presence, re-checked

Part III re-verified all 42 SWP fixes against current source and found **41 present, 1 not found**
(M14). [REPORTED — `DEFECT-LEDGER.md` §8.2] This chapter independently spot-checked **22** of them by
locating the fixed construct in current source, and agrees on every one, including M14:

> Present and read: `#3C`, `#72C`, `#73C`, `#74`, `#6C`, `#7C`, `#8C`, `#9C`, `#10C`, `#11C`,
> `#13C`, `#16H`, `#17H`, `#18H`, `#19H`, `#20H`, `#21H`, `#24H`, `#26M`, `#27M`, `#31M`, `#36M`,
> `#38M`, `#45L`, `#49L`, `#50L`, `#55L`, `#56L`, `#65eL`, `#65hL`, `#70L`, `#71L`. [V-read / V-cmd]
> Absent: `#39M` / M14, by deliberate later decision. [V-cmd]

**Proof tags survive.** All nine `SWP|TX` proof identifiers named in the fix write-ups still exist in
the suite files — `015`, `015b`, `002`, `003b`, `016a`, `038c`, `032o3`, `032z6f`, `032z8e`.
[V-cmd] They live in `[6.3]_SWP.repl` and `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, which are
alternatives to each other in `Stage01_Tester.repl` (issuance-only is the committed default) but
**both** run under `ZALL.repl` and `REPL/modules/SWP.repl`. So unlike ATS, SWP's proofs did not rot:
they were written into the canonical suite from the start rather than into scratch harnesses, and
that single decision is why this tree's evidence is still alive and ATS's largely is not.

### Three ordering observations from the re-verify, still open

Part III's SWP re-verify independently found `CAP_Owner` sitting **after** the business check in
`SWP|C>ENABLE-FROZEN`, `C>ENABLE-SLEEPING`, `C>ADD-OR-SWAP`, `S>WEIGHTS`, `S>RT_CAN-CHANGE` and
`SPW|S>UPDATE_SPECIAL-FEE-TARGETS`. [REPORTED — §8.2] The 2026-09-14 authorise-first sweep matched
`compose-capability (GOV|…)` forms and never saw the `CAP_*` ownership ones.

Per CLAUDE.md's standing engineering position these should **not** be resolved by reordering —
ordering is only a proxy for testability, and swapping it hides the other guard instead. The remedy
is a fixture that satisfies the first guard so both are exercised. As of this chapter, that work is
recorded but not done for the SWP sites.

And one shape flagged as worth watching, not yet actioned: `C_ToggleAddOrSwap`'s `ico1` binding
performs real `DPTF::C_Toggle*Role` **writes inside an eager `let`, above the `with-capability`** —
the same eager-binding pathology this book's Rule 1 exists for, in a function whose only ownership
check lives in the capability it has not acquired yet. [REPORTED — §8.2]
