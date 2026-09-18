# ROUND I — Findings (SWP modules)

**Date:** 2026-08-16 · **Status:** frozen (append-only). Owner verdicts recorded inline as they arrive.
**Scope:** `1_Utilities/12_U_SWP.pact` (`U|SWP`), `1_Utilities/13_U_BFS.pact` (`U|BFS`), `2_Core/14_SWPT.pact`
(`SWPT`), `2_Core/15_SWP.pact` (`SWP`), `2_Core/16_SWPI.pact` (`SWPI`), `2_Core/17_SWPL.pact` (`SWPL`),
`2_Core/18_SWPLC.pact` (`SWPLC`), `2_Core/19_SWPU.pact` (`SWPU`), `2_Core/20_MTX-SWP.pact` (`MTX-SWP`),
`3_Talos/04_TS01-C3.pact` (`TS01-C3`), `3_Talos/05_TS01-P.pact` (`TS01-CP`) — ~12,300 lines across the core+Talos
tier, plus their interfaces and the `[6.3]_SWP.repl`/`[6.2+3]_DPTF-SWP_Issuance-Only.repl` test suites.
**Baseline:** `cd REPL && pact Z.repl` — full pipeline green (confirmed by the SWP-core auditor). None of the
CRITICAL/HIGH findings below are covered by an existing assertion — no test constructs a zero-weight token, an
asymmetric-add-then-remove round trip, a multi-pool-per-pair routing scenario, an oversized swap, a
Global-Admin-Pause-during-defpact scenario, or a non-owner `C_ToggleSwapCapability` call.

Verification tags: **CONFIRMED** = re-read/re-derived directly against the code (numeric simulation for the two
math findings) · **PLAUSIBLE** = strong trace, would benefit from a REPL run to nail the exact magnitude/reach.

---

# CRITICAL

## C1 · SWPI — `URC_BestEdge` selects the WORST parallel-pool edge, not the best `[CONFIRMED, 2 auditors + lead re-read]`

**Location:** `16_SWPI.pact:881-922` (`URC_BestEdge`), selection fold at 903-918. Consumed by `URC_Hopper`
(820-880, `best-edge` binding at 856), whose output is executed verbatim by `19_SWPU.pact:592-761`
(`XI_SmartSwap`/`XI_SmartSwapCore`) — real transfers and pool-supply mutations, not a quote. Independently
surfaced by both the SWPT auditor (tracing consumers) and the SWPI auditor (owning the file); lead re-read
confirms the code exactly as reported:

```pact
(if (< (at idx svl) (at acc svl))
    idx
    acc
)
```

**What's wrong:** `svl` is the list of *output amounts* each candidate edge (parallel pool serving the same
token pair) would produce for a fixed input. The fold above keeps the index with the **smaller** value —
`argmin`, not `argmax`. For a swapper feeding a fixed input, "best" means most output. `URC_Hopper`'s own
`@doc` even says "the cheapest available edge" (correct intent — maximize output for a given input) while the
implementation is inverted.

**Failure scenario:** any token pair served by ≥2 live pools (e.g. a deep stable pool and a shallow weighted
pool for the same pair) — every multi-hop Smart Swap that touches that pair is systematically routed through
the **worse-priced** pool, silently, with no error. The same function backs `URC_WorthDWK`/`URC_PoolValue`
(price-oracle helpers consumed by `UEV_Issue`'s spawn-limit check and `SPWU|C>TOGGLE-SWAP`'s pool-worth gate),
so token "worth" is understated across the protocol wherever a multi-edge path is involved. Anyone can create a
second, shallow pool for any pair already served by a deep one to *guarantee* SmartSwap routes new flow into
the shallow pool — a standing value-extraction vector, zero cost to set up.

**Fix direction:** flip the comparator to `>` (track running max, not running min).

**Interface implication:** none — `URC_BestEdge` is an internal `URC_*` helper, not on `SwapperIssueV3`'s
public surface signature; a logic-only fix, no interface bump.

**Owner verdict:** _pending_

## C2 · U|SWP — Newton solver has no domain guard; large swaps converge to the wrong root and return output exceeding the pool's own balance `[CONFIRMED, numeric simulation]`

**Location:** `UC_ComputeY` (`12_U_SWP.pact:46-93`), `UC_YNext` (142-172); identical pattern in
`UC_ComputeInverseY`/`UC_ZNext` (94-141, 173-190).

**What's wrong:** the Newton iteration's initial guess is `y0 = xo - input-amount`, with no clamp, no
`enforce`, no post-solve sanity check (`0 < Y < xo`) anywhere. When `input-amount` approaches/exceeds `xo`
(the *output* token's reserve), `y0` goes negative and Newton converges to the wrong (non-physical) root — a
real, stable, fully-converged fixed point that is simply not the answer the invariant requires. `UC_ComputeY`
then returns `xo - Y`, a number **larger than the pool's total balance of that token**, with no error signaled.

**Reproduced numerically** (pool `X=[1000,1000,1000]`, `A=85`, swap token0→token2):

| input | code output | pool holds |
|---|---|---|
| 1000.0 | 975.08 | 1000.0 (still plausible) |
| 1010.0 | **1031.77** | 1000.0 — output exceeds the entire pool balance |
| 5000.0 | **5001.36** | 1000.0 |

The break point sits inside a plausible trade size (just above 1.0× the output reserve), not an exotic corner.

**Invariant violated:** a swap can never legitimately return more of a token than the pool holds — the
constant-D invariant guarantees the solved balance stays in `(0, xo)`; this module enforces no such domain.

**Blast radius:** depends on whether SWPI/SWPU independently clamp `input-amount` before calling this and
re-validate `output ≤ reserve` after (in-scope trace found no such guard — see C4/C5's sibling gap in
`UEV_Issue`, and note SWPI's own swap path relies on this function's output being trustworthy). The math-core
function itself has no self-defense; any current or future caller that trusts its output for accounting before
a transfer-level balance check propagates the corruption.

**Fix direction:** bound the domain at the caller (`UC_*` can't `enforce`, so the guard belongs in the client
defcap: `input-amount < xo * SAFETY_MARGIN`), and/or harden the solver itself — clamp `Y` to `(0, xo)` between
iterations or fall back to bisection when a Newton step would leave that domain.

**Interface implication:** the fix is internal to `U|SWP`'s `UC_*` functions plus a defcap-level guard in
whichever client calls them — no signature change to `UtilitySwpV1`.

**Owner verdict:** _pending_

## C3 · U|SWP — rounding direction on every solved-balance term favors the swap taker across all three pool types `[CONFIRMED, numeric simulation, 2 independent auditors]`

**Location:** `UC_ComputeY` (91), `UC_ComputeInverseY` (139), `UC_ComputeWP` (277-279), `UC_ComputeInverseWP`
(309-311), `UC_ComputeEP` (334-336), `UC_ComputeInverseEP` (358-360) — all six S/W/P direct+inverse formulas.
Independently reconfirmed by the SWPI auditor (their H1) while checking fee sequencing.

**What's wrong:** every function floors the *solved new balance*, not the final answer:
- Direct swaps: `output = xo - floor(new-balance)` — flooring the subtracted term makes `output` **larger**.
- Inverse swaps: `input-needed = floor(new-balance) - xi` — flooring makes `input-needed` **smaller**.

Both bias the same way: the caller always receives at least as much, and pays at most as much, as the exact
invariant-preserving amount — the opposite of the standard AMM convention (Curve's own `get_dy` subtracts an
extra unit specifically to bias the *pool's* favor).

**Reproduced numerically** (zero fees, raw math, replicating the exact Pact `floor`/`fold` sequence):

- *Stable pool* `X=[1000,1000,1000]`, `A=85`: swap 100.0 tok0→tok2 → 99.99 tok2; swap 99.99 tok2→tok0 → 100.01
  tok0. **Net +0.01 profit on a pure round trip.**
- *Weighted pool* (80/20) `X=[8000,2000]`: swap 100.0 tok0→tok1 → 96.96; swap 96.96 tok1→tok0 → 100.01.
  **Net +0.01 profit.**

`UC_ComputeEP`/`UC_ComputeInverseEP` share the identical shape by construction (not separately simulated). A
smaller instance of the same bias exists in `UC_BalancedLiquidity`/`UC_LP` (LP-add path). Magnitude is bounded
per swap to roughly one unit of output/input precision — **not proportional to trade size, but directionally
guaranteed and free to repeat**, the exact "repeatable dust extraction" pattern the audit brief called out.
This is fee-free math-core bias; it either eats directly into whatever fee margin exists at the caller layer,
or is fully exposed on any fee-less/promotional route.

**Fix direction:** round the *final* user-facing amount in the protocol's favor, not an intermediate additive
term whose rounding direction flips sign after subtraction — floor the amount paid *out*, ceiling (or
floor-then-+1-ulp) the amount required *in*, mirroring Curve's `-1` convention. Apply symmetrically to
Y/Z, WP/InverseWP, EP/InverseEP, and `UC_BalancedLiquidity`/`UC_LP`.

**Interface implication:** internal to `U|SWP`'s `UC_*` math — no signature change.

**Owner verdict:** _pending_

## C4 · SWPI — `UEV_Issue` never validates individual pool weights are non-zero → permanent div-by-zero on a W pool `[CONFIRMED]`

**Location:** `UEV_Issue` (`16_SWPI.pact:1209-1322`), enforcement block 1263-1274. Divide sites:
`UC_ComputeWP` (`12_U_SWP.pact:275`, `1.0/ow`) and `UC_ComputeInverseWP` (307, `1.0/iw`).

**What's wrong:** `UEV_Issue` enforces only that weights **sum** to 1.0 — never that each `wᵢ > 0`. A weight
vector `[1.0, 0.0, 0.0]` passes. `UC_ComputeWP`/`UC_ComputeInverseWP` divide by the output/input token's own
weight to invert the exponent — a `0.0` weight is an immediate division by zero.

**Failure scenario:** any non-admin account issues a W pool with weights `[1.0, 0.0]`; issuance succeeds, but
every swap touching the zero-weight token aborts permanently — the token, and any genesis liquidity deposited
for it, is stranded (recoverable only via remove-liquidity's separate proportional-withdrawal math).

**Fix direction:** fold-and `(> wᵢ 0.0)` over every weight inside `UEV_Issue`, alongside the existing sum check.

**Interface implication:** none — internal validation strengthening inside `UEV_Issue`; `SwapperIssueV3`
signatures unaffected.

**Owner verdict:** _pending_

## C5 · SWPI/U|SWP — genesis issuance never validates every pool-token's initial reserve is non-zero → permanent div-by-zero on first swap `[CONFIRMED]`

**Location:** `UEV_Issue` (`16_SWPI.pact:1209-1322`) — the only reserve check is the spawn-limit block
(1297-1319), which prices **only the first pool token** and is skipped entirely on the admin (`p=true`) path.
Divide sites: `UC_DNext` (`12_U_SWP.pact:234`, `Dp = D^(n+1)/(nn*P)` where `P` = product of all reserves) and
the equivalent running-product terms in `UC_ComputeWP`/`UC_ComputeEP`.

**Failure scenario:** issue a "P" (equal-weight) pool `[A,B,C]` with amounts `[100,0,0]` — only `A`'s worth is
checked. First swap `A→B`: the running product includes the still-zero `C` → `0/0` → abort. The pool is
permanently unusable for any route touching a zero-reserve token; an all-zero stable-pool genesis hits the
same wall inside `UC_ComputeD` itself. The admin bootstrap path (`p=true`) skips the spawn-limit block
entirely, so even an admin has no on-chain guard against a mistyped zero amount.

**Fix direction:** fold-and `(> amountᵢ 0.0)` over every `pool-tokens[i]` supply in `UEV_Issue`, independent of
the `p` flag and the spawn-limit branch.

**Interface implication:** none — internal validation only.

**Owner verdict:** _pending_

## C6 · SWPT — graph node-envelope is narrower than the live edge-set; paths ≥4 hops are structurally corrupted or lost `[CONFIRMED]`

**Location:** `URC_MakeGraph` (`14_SWPT.pact:336-358`) builds `nodes` via `U|SWP::UC_MakeGraphNodes`
(`12_U_SWP.pact:609-630`), which only includes tokens **directly** pooled with `input` or `output` (≤1 hop from
either end). But `URC_TokenNeighbours`/`URC_TokenSwpairs` (359-402) read the **full, unrestricted** live
`SWPT|Tracer` table for each node in that restricted set — edges can name a neighbor token with no `GraphNode`
entry in `graph` at all.

**What's wrong:** when `U|BFS::UC_BFS` expands from an undeclared node, `UCX_GraphNodeLinks`
(`13_U_BFS.pact:144-164`) fails to find it and returns `[BAR]` — `UC_BFS`'s fold then **appends the literal
sentinel `BAR` into the chain** instead of terminating the branch, corrupting it.

**Failure scenario (reproduced topologically):** pools `W|A|B`, `W|B|C`, `W|C|D`, `W|D|E`; swap `A→E`.
`UC_MakeGraphNodes(A,E,...)` → `nodes = {A,B,D,E}` (`C` is missing — it's not directly pooled with either
end). When BFS expands `B` it discovers `C` via the live Tracer and enqueues it, but `C` has no `GraphNode`
entry — its own expansion corrupts the chain with a trailing `BAR` and the branch dies before reaching
`D`/`E`. **The only path between A and E (4 hops) is never found**, even though it demonstrably exists in the
live pool graph. As the pool graph grows deeper over time, an increasing fraction of legitimate token pairs
will hit this — the routing module's core promise ("multi-hop BFS finds the path") silently degrades to
"finds paths of ≤3 hops only, and corrupts state instead of degrading gracefully beyond that" (feeds directly
into H2's crash).

**Fix direction:** either build `nodes` from the full transitive closure reachable from `input`/`output`
(bounded by an explicit, documented, gas-budgeted max-hop constant), or make `URC_TokenNeighbours` filter its
Tracer-sourced neighbors down to the `nodes` set actually being built, so BFS never sees a link with no
`GraphNode`.

**Interface implication:** internal to `SWPT`'s `URC_*` helpers — no signature change to `SwapTracerV1`.

**Owner verdict:** _pending_

## C7 · SWP — `C_ModifyWeights` has no length check, a dead precision check, no per-weight bound, and no time-lock `[CONFIRMED]`

**Location:** cap `SWP|S>WEIGHTS` (`15_SWP.pact:366-385`), client `C_ModifyWeights` (1324-1336), writer
`XB_ModifyWeights` (1480-1487).

**What's wrong:** the entire validation is:
```pact
(map (lambda (w:decimal) (= (floor w (ref-U|CT::CT_FEE_PRECISION)) w)) new-weights)   ;; result discarded
(enforce (= pp "W") "Changing weights available only for weighted Pools")
(enforce (= ws 1.0) "All weights must add to exactly 1.0")
(CAP_Owner swpair)
```
1. The precision `map` computes a `[bool]` list and **throws it away** — never wrapped in `enforce`.
2. **No length-parity check** against `(length (UR_PoolTokens swpair))` (the sibling cap
   `SWP|S>UPDATE-SUPPLIES` does this correctly). A shorter/longer array is written straight through.
3. **No per-weight lower bound** — only `Σ = 1.0` is enforced; negative weights that cancel (`[2.0,-1.0]`)
   pass.
4. **No time-lock** — reweighting a live pool is instant, with reserves unchanged in the same call.

**Failure scenario:** (a) *Value extraction* — owner instantly reweights `[0.5,0.5] → [0.01,0.99]` with
reserves unchanged; the AMM's implied spot price jumps instantly, and the owner (or a front-runner) arbitrages
the pool against its own LPs before reserves rebalance — the classic Balancer-style weight-manipulation
LP-extraction vector, entirely unrestricted here. (b) *Data corruption* — `C_ModifyWeights swpair [0.6,0.4,0.0]`
on a 2-token pool: `Σ=1.0` still passes, `weights` becomes length-mismatched with `pool-tokens`; every
downstream consumer that zips `weights` against pool-tokens by position either hard-aborts (pool bricked) or
silently misattributes a weight to the wrong token.

**Fix direction:** wrap the precision check in `enforce` (or replace it); add a length-parity check against
`UR_PoolTokens swpair`; add a per-weight `> 0.0` floor; consider a time-locked/gradual weight-change mechanism.

**Interface implication:** none for the length/precision/bound checks — purely internal to the `SWP|S>WEIGHTS`
defcap, `SwapperV3.C_ModifyWeights` signature unchanged. If a time-lock mechanism is added, that would add new
`UR_*` state (e.g. "pending weights"/"unlock height") — **would** require bumping `SwapperV3` (→ `V4`) and
cascading to `TalosStageOne_ClientThreeV3` (→ `V4`).

**Owner verdict:** _pending_

## C8 · SWP — `C_UpdateAmplifier` has zero bound-check on the new amplifier value `[CONFIRMED]`

**Location:** cap `SWP|S>UPDATE-AMPLIFIER` (`15_SWP.pact:425-434`), client `C_UpdateAmplifier` (1440-1452),
writer `XI_UpdateAmplifier` (1679-1685). Corroborated independently by the SWPI auditor while tracing the C2
div-by-zero root.

**What's wrong:**
```pact
(defcap SWP|S>UPDATE-AMPLIFIER (swpair:string new-amplifier:decimal)
    @event
    (CAP_Owner swpair)
    (let ((current-amp:decimal (UR_Amplifier swpair)))
        (enforce (> current-amp 0.0) "Amplifier can only be updated for Stable Pools")
    )
)
```
this only checks that the pool **currently is** a stable pool. `new-amplifier` itself is never validated — no
lower bound, no upper bound, and critically no exclusion of the module's own sentinel `-1.0` (used throughout
the file to mean "not a stable pool"). `UEV_Issue` correctly floors `amp ≥ 1.0` **at creation**
(`16_SWPI.pact:1265`) — the exact same discipline was simply never re-applied here.

**Failure scenario:** (a) owner sets `new-amplifier = 0.0` or negative — `UC_YNext`'s
`c = D^(n+1)/(nn*P-Prime*A*nn)` is undefined at `A=0`, bricking every swap on a previously-healthy stable pool.
(b) owner sets `new-amplifier = -1.0` (the sentinel) — `C_ToggleAddOrSwap` (1355-1366) then misreads the pool
as non-stable and silently skips fee-exemption role wiring for the first token, on a pool that is still, in
every other respect, a stable pool.

**Fix direction:** enforce `new-amplifier` within a sane documented range (`≥ 1.0` matching issuance, plus a
practical ceiling) and explicitly reject `-1.0` (and any other pool-type sentinel) from this path.

**Interface implication:** none — internal to the `SWP|S>UPDATE-AMPLIFIER` defcap; `C_UpdateAmplifier`
signature unchanged.

**Owner verdict:** _pending_

## C9 · SWP/MTX-SWP — pools issued via the MTX-SWP defpact path are never registered in `SWP|LP`, breaking AQP LP-stake admission `[CONFIRMED]`

**Location:** writer `XE_AddLPTracker` (`15_SWP.pact:1607-1612`, table `SWP|LP`) — called correctly from the
single-tx path `16_SWPI.pact:1428` (`C_Issue`); **never called** from `20_MTX-SWP.pact` step 3 (866-897,
`MTX|C_Issue` — the shared defpact backing `C_IssueStablePool`/`WeightedPool`/`StandardPool`), which itself
calls `ref-SWP::XE_Issue` (887) and mints/transfers LP identically to `SWPI::C_Issue`, but omits the tracker
insert entirely.

**What's wrong:** `SWP|Pairs`, LP mint, and LP transfer all succeed identically through both issuance paths,
but only `16_SWPI.pact` populates `SWP|LP`. **MTX-SWP is the primary path for gas-heavy issuance** — proven by
the `[6.2+3]` REPL's own "Issue Stable 7xUSD via defpact 0|2/1|2/2|2" test (TX012a-c) — meaning precisely the
stable multi-token pools most likely to need the defpact path, plus any weighted/standard pool routed there for
gas reasons, end up with no `SWP|LP` row. Downstream, `UR_GetLpSwpair` (`15_SWP.pact:824-826`, a plain `read`,
no default) is relied on by `AQP-SCORE` (`02_SCORE.pact:2117,2534`), `AQP-POOL` (`03_AQP.pact:1603,2179,2266`),
and `AQP-FVT` (`04_FVT.pact:1845`) to resolve an LP token id back to its swpair for AQP LP-stake admission.

**Failure scenario:** any pool issued through `MTX-SWP` has an LP token that **can never be used as AQP LP-stake
collateral** — every AQP admission attempt for that LP id hard-aborts on the missing-row `read`, permanently
and silently (no error message pointing at the real cause — it looks like an AQP bug from the caller's side,
not an SWP issuance gap).

**Fix direction:** move the `SWP|LP` insert **into `XE_Issue` itself** (both `swpair` and `token-lp` are
already parameters there) so every issuance path gets it "for free"; remove the now-redundant standalone call
from `SWPI::C_Issue`. Secondary discipline note: `XE_AddLPTracker` is called cross-module via a
`module{SwapperV3}` ref from `16_SWPI.pact` yet is **not declared** on the `SwapperV3` interface at all — this
gap hid the C9 defect from static review; folding the insert into `XE_Issue` removes the need for the
undeclared interface member too.

**Interface implication:** if the fix folds the insert into `XE_Issue` (no new parameters), **no bump needed**
— `SwapperV3.XE_Issue`'s signature is unchanged, only its body grows. If instead `XE_AddLPTracker` is
formalized as a documented interface member (the "secondary discipline note" fix), that's an **additive**
change to `SwapperV3` → still fits under the current `V3` per Ouronet's interface-versioning convention
(additive members don't require a version bump unless a cascade rule forces one — confirm against
`INTERFACE_VERSIONING.md` before finalizing).

**Owner verdict:** _pending_

## C10 · SWPL — asymmetric-liquidity LP mint is never reduced to the invariant-fair amount on the default (liquid) path — immediately exploitable via mint-then-burn `[CONFIRMED, worked numeric exploit]`

**Location:** `URC_LD` (`17_SWPL.pact:844-917`) → `URCX_AsymmetricLP` (931-1047) → `URC|KDA-PID_CLAD`
(472-826, "With Asymmetric TAX Collection" branch, 556-719) → `XE|KDA-PID_AddLiqudity` (1743-1867) →
`XI_AddLiqSendAndMint` (1868-1887). Reached by the **default, flagship** entrypoint `SWP|C_AddLiquidity`
(`04_TS01-C3.pact:539`, `asymmetric-collection=true, gaseous-collection=true`).

**What's wrong:** `URCX_AsymmetricLP` computes **two** values for an asymmetric deposit — `full-asymmetric-lp`
(a naive, per-token-linear formula treating each token's contribution independently) and `taxd-lp` (the
mathematically fair, invariant-based amount, computed exactly like Curve's `add_liquidity` fee model: `D0`,
`D1`, fee-adjusted balances, `D_adj`, `taxd-lp = floor((D_adj-D0)*lp-supply/D0, prec)`). The **liquid, native
LP actually minted** to the depositor is `balanced-lp-amount + full-asymmetric-lp - relinquish-lp`, where
`relinquish-lp` is a small, **unrelated** deficit slice from a different model (the VSE "fuel" simulation) —
**`taxd-lp`, the correct number sitting right next to it, is never used for the mint.**

**Reproduced numerically** (2-token equal-weight pool, `X_A=1000, X_B=1000, lp-supply=1000`):
1. Attacker deposits `[100.0, 0.0]` (100% token A). `full-asymmetric-lp = 50.0`; `relinquish-lp` negligible
   (≈0.1–0.3). Attacker minted **≈49.8 liquid LP** for a deposit of 100 A only. Pool now
   `X_A=1100, X_B=1000, lp-supply≈1049.8`.
2. Attacker immediately calls `C_RemoveLiquidity` (linear pro-rata burn) for their ≈49.8 LP:
   `output ≈ (49.8/1049.8)*[1100,1000] ≈ [52.2, 47.4]`.
3. **Net: put in `[100,0]`, got back `≈[52.2,47.4]` — extracted ~47 units of a token never deposited**, at
   every other LP holder's expense, same-block. The one inter-step guard in the defpact path
   (`prev-pool-state == current-pool-state`) protects the depositor's own quote from third-party front-running
   — it does **not** stop the depositor from running this exact sequence against themselves.

Also affects Iced/Glacial (`asymmetric-collection=false`): `primary+secondary` still sums to
`balanced-lp-amount + full-asymmetric-lp` **unreduced**; the excess is wrapped as non-transferable "Frozen"
LP via `VST::C_Freeze`, which delays the depositor's own realization but does **not** prevent the immediate,
permanent dilution of every existing LP holder — native `lp-id` total supply already increased by the full
uncorrected amount at mint time, before any freeze-wrap happens. **Standard mode is strictly worse: no freeze
at all, the full excess mint is immediately liquid.**

**Fix direction:** mint `taxd-lp` (not `full-asymmetric-lp - relinquish-lp`) as the liquid asymmetric LP
component in the "With Asymmetric TAX Collection" branch; route the true deficit (`full-lp - taxd-lp`) through
one consistent compensation mechanism. Apply the same correction to the Iced/Glacial `secondary` bucket before
freezing it. Add a REPL regression: single-sided deposit immediately followed by full withdrawal must not let
the depositor extract more value in any token than break-even (modulo fees), for every liquidity mode.

**Interface implication:** internal math correction inside `SWPL`'s `URC*`/`XE*` chain — no signature change
to `SwapperLiquidityV1`.

**Owner verdict:** _pending_

## C11 · SWPU — slippage bound checks a fee-exclusive GROSS quote; the user's actual NET payout is never validated against any bound `[CONFIRMED]`

**Location:** direct swap — `UDC_SlippageObject` (`19_SWPU.pact:439-466`) sets
`expected-output-amount = URC_Swap swpair dsid false`; execution check in `XI|KDA-PID_Swap` (762-816):
`max-toa = URC_Swap swpair dsid true`, checked `(and (>= max-toa min) (<= max-toa max))`. Smart swap —
`UDC_SpawnSmartSwapSlippageBounds` (377-411) and `XI_SmartSwapRouter` (555-591) mirror the same shape via
`URC_Hopper`. **Lead re-read confirms this exactly** (`19_SWPU.pact:773-777`, `max-toa` bound to
`ref-SWPI::URC_Swap swpair dsid true`).

**What's wrong:** `URC_Swap`/`URC_Hopper` compute the swap-curve output on the **full, un-taxed input amount**
— zero LP/special/boost fee involvement (`validation:bool` only toggles whether `UEV_SwapData` enforcement
runs, not gross-vs-net). The amount the user **actually** receives is computed separately by
`UC_BareboneSwapWithFeez` (`16_SWPI.pact:393-463`), which shrinks input by the LP fee **before** the curve
runs, then carves out special/boost fees from the result — `o-id-netto` is what's transferred
(`XI_Swap`/`XI_SmartSwapCore`). **`o-id-netto` is never compared against `min`/`max` anywhere in this file.**
The only quantities checked are the fee-blind gross figures, which are systematically **larger** than what the
user gets by the full LP+special+boost fee percentage — on **both** `C_Swap` and `C_SmartSwap`.

**Failure scenario:** a pool with a 0.3% LP fee + 0.1% special fee. User quotes `expected=1000.0` (gross),
sets `0.5%` slippage → `min=995.0`. At execution the pool hasn't moved — `max-toa` recomputes to the same
`1000.0`, trivially inside bounds, swap proceeds. `o-id-netto` delivered ≈ `996.0` — the check can't
distinguish "pool didn't move (fine)" from "pool didn't move but fees just got hiked to 5%" (fees are
admin-mutable per pool via `XI_UpdateFee`, no visible time-lock) — because fees never enter the compared
quantity on **either** side of the comparison, at **either** quote time or execution time. **A user's declared
minimum-acceptable-output is not a floor on what they receive, structurally, for any swap.**

**Fix direction:** the checked quantity must be the fee-inclusive netto. Direct path: build `expected`/`max-toa`
via `UC_BareboneSwapWithFeez` (usable at both quote and execution time) and compare against `o-id-netto`, not
`URC_Swap`. Smart Swap: run `UC_BareboneSwapWithFeez` per-hop for both quote-time and execution-time
comparisons, or at minimum add an explicit floor on `final-netto` inside `XI_SmartSwap`/`XI_Swap` before any
transfer executes.

**Interface implication:** likely internal (swap the function used to compute the compared quantity) — no
signature change to `SwapperUsageV2.C_Swap`/`C_SmartSwap` required for the minimal fix. If the fix additionally
surfaces the fee-adjustment factor to callers (so off-chain quoting can pre-inflate tolerance), that would be
an **additive** interface change.

**Owner verdict:** _pending_

## C12 · SWPU — `C_ToggleSwapCapability` has no ownership/admin authorization anywhere in the call chain `[CONFIRMED, lead re-read]`

**Location:** `C_ToggleSwapCapability` (`19_SWPU.pact:471-482`), cap `SPWU|C>TOGGLE-SWAP` (193-210); Talos
`SWP|C_ToggleSwapCapability` (`04_TS01-C3.pact:425-444`), whose **own `@doc` claims** "Requires `<swpair>`
ownership." Lead re-read of `SPWU|C>TOGGLE-SWAP` confirms:
```pact
(defcap SPWU|C>TOGGLE-SWAP (swpair:string toggle:bool)
    (if toggle
        (enforce (> pool-worth inactive-limit) "...")   ;; a BUSINESS threshold, not an owner check
        true                                             ;; disable branch: NO CHECK AT ALL
    )
    (compose-capability (P|SWPU|CALLER))                 ;; (defcap P|SWPU|CALLER () true)
)
```

**What's wrong:** trace the full chain — Talos `SWP|C_ToggleSwapCapability` gates only on `P|TS` (global-pause
check, `patron` used only for IGNIS billing, never for authorization); `SWPU::C_ToggleSwapCapability`'s
interface signature has **no account parameter at all**; `SPWU|C>TOGGLE-SWAP` checks a pool-worth business
threshold on enable and **nothing** on disable; `SWP::C_ToggleAddOrSwap` (the function actually flipping the
flag) is gated by `P|GOVERNING-CALLER`, itself composing two `(defcap ... () true)` caps — no
`CAP_Owner`/`CAP_EnforceAccountOwnership` anywhere in this function (contrast `SWP::C_ChangeOwnership`, which
correctly gates on `SWP|S>RT_OWN` → real account-guard enforcement, proving the module has the primitive and
simply didn't apply it here).

**Failure scenario:** any account, with no relationship to the pool, calls Talos
`SWP|C_ToggleSwapCapability(any-account, any-swpair, false)` and instantly disables swap on that pool. Repeated
across the registry: a **zero-cost, unauthenticated denial-of-service against the entire AMM's trading
function**, pool by pool, until an admin notices and manually re-enables each one.

**Fix direction:** add an `account`/`patron` parameter to `SwapperUsageV2.C_ToggleSwapCapability` and gate
`SPWU|C>TOGGLE-SWAP` on `ref-DALOS::CAP_EnforceAccountOwnership (ref-SWP::UR_OwnerKonto swpair)` for **both**
`toggle=true` and `toggle=false`; have Talos pass `patron` through instead of dropping it.

**Interface implication:** **requires a bump.** Adding a parameter to `C_ToggleSwapCapability` changes
`SwapperUsageV2`'s signature → bump to `SwapperUsageV2` → `V3` (or fold into whatever next revision is
already planned). Per the cascade rule, every interface naming `SwapperUsageV2` must advance in lockstep —
concretely `TalosStageOne_ClientThreeV3` (`04_TS01-C3.pact`) references `SwapperUsageV2.Slippage` and must
bump alongside (→ `TalosStageOne_ClientThreeV4`), and `TS01-C3`'s own wrapper `SWP|C_ToggleSwapCapability`
must thread the new parameter through. Per repo policy ("stays on current version until first mainnet
deployment; bump only if post-deploy adjustment forces it") — this module **is** live on mainnet per the
audit's own premise, so this is exactly the class of forced post-deploy bump the policy anticipates.

**Owner verdict:** _pending_

## C13 · SWPLC — `C_Fuel`'s indirect branch can inflate a pool's recorded reserves with zero token backing; the sole gate is a trivially-true IMC capability chain `[CONFIRMED mechanism / PLAUSIBLE full exploit]`

**Location:** `C_Fuel` (`18_SWPLC.pact:483-527`), cap `SWPLC|C>INDIRECT-FUEL` (216-220). Lead re-read confirms
the cap body **exactly**:
```pact
(defcap SWPLC|C>INDIRECT-FUEL (account:string swpair:string id-lst:[string] transfer-amount-lst:[decimal])
    @event
    (compose-capability (P|SWPLC|CALLER))     ;; and P|SWPLC|CALLER is (defcap P|SWPLC|CALLER () true)
)
```
and the branch it gates does `(ref-SWP::XE_UpdateSupplies swpair new-balances) EOC` — **crediting the pool's
recorded reserves with no transfer call at all** in that branch. Also confirmed: `SWPLC::UEV_IMC` reduces to
`(ref-U|G::UEV_Any (P|UR_IMP))` — a check that *some* previously-registered capability-guard is currently
satisfied, where the registered guards (`create-capability-guard` over `P|<MODULE>|CALLER`/`SECURE`-style caps
across the codebase) are themselves bodied `(defcap ... () true)`.

**What's wrong (verified mechanism):** `create-capability-guard(CAP)` only re-checks that `CAP` is *currently
acquired* in the executing transaction's scope at the moment `enforce-guard` runs it — it does not verify
*who* originally acquired it or *which module's code* is on the call stack. Since `with-capability` on a public,
unconditionally-`true`-bodied `defcap` can be invoked by **any** code, including a bare top-level transaction
(nothing in Pact restricts *who* may request a capability grant — only the defcap's own body can, and here the
body is `true`), a raw transaction can self-grant e.g. `(with-capability (TS01-C3.P|TALOS-SUMMONER) ...)` and
walk straight through every `UEV_IMC` gate in the codebase that relies solely on this pattern. This is a
well-documented Pact footgun (capability-guards over trivially-true caps provide no real access control), and
it is the literal, sole mechanism `StoicSyntax.md` documents for "Protected entrypoints gate on IMC" — i.e. the
codebase's authors are relying on a pattern that, absent a further `enforce-guard`/`enforce-keyset` inside the
composed cap chain, does not actually restrict callers to Talos/registered peers.

**Why this matters specifically for `C_Fuel`:** most fund-affecting `C_*`/`A_*` functions in SWP layer a
*real* check on top of IMC (`CAP_Owner`, `CAP_EnforceAccountOwnership` — genuine `enforce-guard` against a
signing account's real keyset) inside the same defcap, so an IMC bypass alone doesn't defeat them. `C_Fuel`'s
indirect branch is the one place in this audit's scope where **IMC is the only gate**, `validation` can be
passed `false` (skipping `UEV_InputsForLP`'s non-negativity check), and the guarded action is a **direct,
unbacked credit to `SWP|Pairs.pool-tokens`** — the numerator every future `URC_LpBreakAmounts` withdrawal
reads. Since `SWP|SC_NAME` is a **single shared custody account for every pool** (not per-swpair), an inflated
credit on one pool's books, followed by `C_RemoveLiquidity`, pays out real tokens that in reality back
**other pools'** deposits — a cross-pool drain, not a self-contained accounting bug.

**Why the legitimate internal call is safe (and why this doesn't implicate every `C_Fuel` caller):**
`SWPU::XI_Swap` also calls `SWPLC::C_Fuel` with `direct-or-indirect=false` internally, to book already-custodied
swap-fee revenue (`lp-fuel`, computed internally from the fixed fee split, never user-supplied) back into a
pool's reserves — that specific call is safe by construction (bounded, internally-computed amount, tokens
already in custody from the same swap's input transfer). The vulnerability is that `C_Fuel` is a **public**
`defun`, reachable with **arbitrary** caller-chosen `account`/`input-amounts`/`validation=false` by anyone who
can satisfy `UEV_IMC` — which, per the mechanism above, may be anyone.

**Why PLAUSIBLE, not fully CONFIRMED, as an end-to-end exploit:** the capability-guard mechanism itself was
verified by direct code reading (`SECURE`/`P|*|CALLER` bodies are literally `true` in `15_SWP.pact:323`,
`18_SWPLC.pact:189-192`, `19_SWPU.pact:178`, and the Talos `P|TALOS-SUMMONER`/`P|DT` family) and is consistent
with documented Pact capability semantics, but was **not** exercised against a live Pact 5 REPL in this round —
an actual `(with-capability (TS01-C3.P|TALOS-SUMMONER) (SWPLC.C_Fuel ...))` from outside any of SWPLC's own
exposed functions should be run to settle it definitively.

**Scope note — this is not an SWP-only question.** The exact same `UEV_IMC`/trivially-true-cap pattern is used
uniformly across **every** Ouronet Stage-1/Stage-2 module (confirmed: `BRD`, `OUROBOROS`, `TS01-C1/C2/C3/C4`,
and by extension the AQP family per `StoicSyntax.md`'s own description of the pattern). If the mechanism is
confirmed broken, it is a codebase-wide architectural question, not a fix scoped to `C_Fuel` alone — flagging
here because `C_Fuel`'s indirect branch is the concrete instance found to have **no secondary real check**
layered on top, making it the actionable, in-scope repro target.

**Fix direction:** immediate/local: split `C_Fuel` into two named functions, keep the no-transfer (indirect)
path `XI_`-internal only (never a public `C_*`), reachable solely from `XI_Swap`'s own trusted call; and/or
make `SWPLC|C>INDIRECT-FUEL` independently validate a real custodied surplus (`account == SWP|SC_NAME`,
cross-checked against live custody vs. recorded reserves, á la Uniswap `sync`). Structural: if "only Talos can
drive this" must be a genuine security boundary (not just a convention), `P|TALOS-SUMMONER`-class caps need a
real `enforce-guard`/`enforce-keyset`, not a bare `true` body — this is a decision for whoever owns
`StoicSyntax.md`'s IMC chapter, beyond this audit's SWP scope.

**Interface implication:** if fixed by splitting `C_Fuel` into a public (direct-only) and an internal-only
function, `SwapperLiquidityClientV1`'s public surface **shrinks** (removes the `direct-or-indirect` parameter
from the public path) → requires a bump to `SwapperLiquidityClientV1` and cascades to
`TalosStageOne_ClientThreeV3` (which calls `SWP|C_Fuel`). If instead fixed by hardening the cap body only, no
signature change, no bump.

**Owner verdict:** _pending_

---

# HIGH

## H1 · U|SWP — `UC_ComputeD`/`UC_ComputeY` use a fixed iteration count with no convergence check `[CONFIRMED]`

`UC_ComputeD` (`12_U_SWP.pact:191-216`, `(enumerate 0 5)` = 6 steps; docstring claims 5 — doc/code mismatch),
`UC_ComputeY`/`UC_ComputeInverseY` (`(enumerate 0 10)` = 11 steps). No break-on-convergence (Curve's reference
iterates up to 255 times *and* exits early once `|Dₙ₊₁-Dₙ| ≤ 1`). Reproduced numerically: at 1000× reserve
skew (`X=[500000,500,500]`, `A=85`, a legally reachable pool state), 6 fixed iterations leave `D` off by
`0.0078` absolute / `3.6e-8` relative from the converged value — silently, feeding every downstream
`UC_ComputeY`/`UC_ComputeWP` call for that pool with a measurably wrong `D`, compounding C2's domain-safety
gap. **Fix direction:** add an explicit convergence break, or at minimum a post-loop sanity `enforce` (at the
caller) that `|D_last - D_prev| ≤ epsilon`. **Interface implication:** none. **Owner verdict:** _pending_

## H2 · SWPT — `URC_ComputeGraphPath` crashes instead of returning the clean "no path" sentinel `[CONFIRMED]`

`14_SWPT.pact:285-323`. Only the `all-paths == [[BAR]]` case (nothing discovered at all) returns cleanly.
Every other empty-result shape — including the C6 truncation, or a genuinely disconnected pair — filters
`all-paths` down to chains ending in `output` via `fold`+`UC_RemoveItem`; if **no** chain matches, the result is
`[]` and `(at 0 fp)` is an **out-of-bounds `at` on an empty list**, a raw Pact runtime abort, not the documented
`[string]` sentinel. `SWPU|X>SMART-SWAP`'s own designed-for guard (`19_SWPU.pact:314`,
`"No path found between {} and {}"`) is **unreachable** for this case — the crash happens one call earlier. Also
reachable from the fee-less quote helper `UDC_SpawnSmartSwapSlippageBounds`, i.e. can break a pre-flight
`/local` quote too. **Fix direction:** guard `(at 0 fp)` with a length check; return `[BAR]` when `fp` is empty.
**Interface implication:** none. **Owner verdict:** _pending_

## H3 · SWPT — principal removal permanently orphans previously-recorded Tracer entries, no resync path `[CONFIRMED]`

`URC_PathTracer`/`URC_TokenSwpairs` (`14_SWPT.pact:196-265,370-402`) key/iterate strictly against the
**current** `principals-lst` from `SWP::UR_Principals`. `SWP::A_UpdatePrincipal` supports removal. If a
principal is removed after swpairs were traced under it, those swpairs' Edges entries are filed under a
principal key no future call ever visits again — permanently invisible to routing, with **no** resync/rebuild
entrypoint anywhere in SWPT (only additive `XE_MultiPathTracer`). **Fix direction:** forbid principal removal
once any swpair has been traced under it, or add an `A_ResyncTracer` rebuild path against
`SWP::URC_Swpairs()`. **Interface implication:** an added resync function would be **additive** to
`SwapTracerV1` (no bump forced unless a cascade rule applies). **Owner verdict:** _pending_

## H4 · SWPT — Tracer graph is append-only forever; disabled/frozen/sleeping pools are never filtered from routing, no fallback `[CONFIRMED graph never removes; PLAUSIBLE liveness impact]`

Only writers (`XE_MultiPathTracer`/`XI_SinglePathTracer`) are strictly additive. `SWP`'s `can-swap`/
`frozen-lp`/`sleeping-lp` toggles never call into SWPT. `URC_Swpairs` (the seed list SWPT builds from) doesn't
filter on any of these flags either. The **only** place `can-swap` is actually checked is
`SWPU|X>SMART-SWAP`'s defcap, **after** BFS has already committed to a specific route — with zero retry/
fallback logic anywhere in the stack. **Failure scenario:** owner disables the only pool on the BFS-shortest
path for maintenance while a fully-active, only-slightly-longer route exists; the entire SmartSwap tx hard-
rejects instead of using the valid alternate. **Fix direction:** either filter `swpairs` by `can-swap` before
it reaches `URC_MakeGraphNodes`, or give SWPT a live per-pool "routable" flag maintained alongside
`SWP|Pairs.can-swap`. **Interface implication:** likely additive only. **Owner verdict:** _pending_

## H5 · SWPI — `UEV_Issue`'s weight-precision validation is computed and discarded `[CONFIRMED]`

`16_SWPI.pact:1255-1261` — a `map` producing `[bool]` ("is each weight within `fee-precision` decimals?") is
never bound, enforced, or folded. Same class of bug as AQP Round-I C1 ("validators defined but never wired") —
smaller blast radius here (weight precision, Pact decimals are arbitrary-precision, nothing downstream
currently assumes quantization) but still dead validation the author clearly intended to run. **Fix
direction:** wrap in `(enforce (fold (and) true (map ...)) "...")`, or drop the block if no longer wanted.
**Interface implication:** none. **Owner verdict:** _pending_

## H6 · SWP — `A_DefinePrimordialPool` reads the `primality` flag but never enforces it `[CONFIRMED]`

Cap `SWP|C>DEFINE-PRIMORDIAL-POOL` (`15_SWP.pact:536-557`): `primality` is bound from `UR_Primality
primordial-pool` but **never included** in the `fold (and)` enforce list — the five conditions actually
checked are weighted-type + contains-OURO + contains-WKDA + contains-LKDA + exactly-3-tokens, all fully
attacker-composable (anyone can issue a matching 3-token pool with `p=false`). **Failure scenario:** a
non-canonical, attacker-controlled-reserve pool with the right 3 assets qualifies to be set as **the**
primordial pool, undermining whatever downstream reference (asymmetric-liquidity gating, price reference)
relies on that designation. **Fix direction:** add `primality` to the `fold (and)` list. **Interface
implication:** none. **Owner verdict:** _pending_

## H7 · SWPL — two independent, unreconciled "asymmetric deficit" pricing models coexist in Standard mode `[PLAUSIBLE]`

`URC|KDA-PID_CLAD` (`17_SWPL.pact:472-826`): the D-invariant `gaseous-ignis-fee` (derived from
`full-lp - taxd-lp`) fires whenever `gaseous-collection=true`, **independent** of `asymmetric-collection`; the
VSE-based `deficit-ignis-tax`/`special-ignis-tax`/`lqboost-ignis-tax` fire whenever `asymmetric-collection=true`
— a **different** deficit computation using the pool's live swap-fee curve, no shared baseline with the first
model. `SWP|C_AddLiquidity` ("Standard") sets **both** flags true, so both fire together for the same
imbalance, with no reconciliation. The `gaseous` tax's own doc frames it as an *alternative* to LP
restriction, reading as designed to be the *only* mechanism when active — not stacked with a second. Whether
this double-counts (over-charging honest depositors) or is genuinely additive needs numeric REPL verification.
**Fix direction:** pick one canonical deficit model per mode, document with a worked example. **Interface
implication:** internal pricing logic only. **Owner verdict:** _pending_

## H8 · SWPL — asymmetric-deficit compensation is not returned to the diluted pool's own LP holders `[DESIGN — confirm intent]`

`XE|KDA-PID_AddLiqudity` (`17_SWPL.pact:1743-1867`): all deficit-tax IGNIS is collected to `SWP|SC_NAME` or
routed to unrelated ecosystem sinks (special targets, LKDA index) — **none** credited back to the specific
swpair's own LP holders as pool value. Combined with C10/H7, existing LPs are diluted in native-share terms
regardless of whether the depositor "pays their fair share" in Ignis; that payment compensates the
protocol/ecosystem generally, not the LPs who bore the dilution. **Fix direction:** if intentional, document
it explicitly (C10's mint-side fix is then the LPs' *only* protection); if not, route the deficit tax back
into the swpair's own reserves. **Interface implication:** none for documentation; a reserve-credit fix would
be internal. **Owner verdict:** _pending_

## H9 · SWPU — reentrancy ordering window in `XI_Swap`: input debit runs before pool-reserve commit, after swap output is already fixed `[PLAUSIBLE]`

`XI_Swap` (`19_SWPU.pact:817-913`): output (`o-id-netto` etc.) is computed from pre-call reserves (836-852);
then `ico1 = TFT::C_MultiTransfer` **debits `account`** (854-856) — routing through
`DPTF::XB_DebitTrueFungible` → `CAP_EnforceAccountOwnership` → `enforce-guard account-guard`, which for a
**smart account** (`A_DeploySmartAccount`, arbitrary caller-supplied guard predicate, a real, exercised
Ouronet feature) can execute arbitrary callback code synchronously; only **after** this — and after crediting
the output to `account` (865-893) — does the body call `ref-SWP::XE_UpdateSupplies` (899) to actually commit
the reserve delta. A malicious smart-account guard authorizing its own debit could reenter and execute a
second swap against the same pool while the first swap's reserve commit is still pending, with the first
swap's already-fixed, now-stale-priced output still being delivered on top. Note: the Smart Swap path debits
**first**, before any per-hop reads, so this ordering issue is specific to the **direct** `XI_Swap` path.
**Fix direction:** commit `XE_UpdateSupplies` (and ideally the output credit) before any external call that
can trigger arbitrary guard code, or add an explicit reentrancy-guard capability around the swap body.
**Interface implication:** none — internal statement reordering. **Owner verdict:** _pending_

## H10 · MTX-SWP/Talos — Global Administrative Pause is not honored on any `defpact` continuation step `[CONFIRMED, 2 independent auditors]`

`20_MTX-SWP.pact` has zero `GAP`/pause references anywhere; `05_TS01-P.pact`'s `P|TS` (58-67, the sole GAP
check, `(enforce (not gap) "...")`) only wraps **Step 0** of each of the 4 `defpact`s (`MTX|C_Issue`,
`MTX|C_AddLiquidity`, `…AddFrozenLiquidity`, `…AddSleepingLiquidity`). Steps 1/2 are driven by a bare
chain-level `(continue-pact step rollback pact-id)` — structurally incapable of re-entering any Talos wrapper
(confirmed against the REPL suite's own usage, e.g. `[6.3]_SWP.repl:1745,1776,2844,2874,...`). If an admin
trips GAP mid-flight (e.g. responding to a live exploit), any already-started multi-step liquidity-add or
pool-issue completes anyway — "no client Functions can be executed" does not actually hold for in-flight SWP
operations. **Not** an IGNIS-billing bypass (each step self-bills correctly) and per-pool circuit breakers
(`can-add`, frozen/sleeping-enable) **are** correctly re-checked fresh at every step — only the system-wide
pause is the gap. **Fix direction:** add a local `gap` read inside every fund-moving step body of the 4
`defpact`s (Pact's continuation model makes a literal Talos-wrapper-per-step impossible, so the check has to
live in MTX-SWP itself), and confirm the gas-station's `cont`-transaction allowlist explicitly covers these 4
pact families (a `cont` carries no module/function reference, so a Talos-only sponsorship rule can't naturally
recognize Steps 1/2 either — a separate UX/gas-station concern alongside the pause gap). **Interface
implication:** none. **Owner verdict:** _pending_

## H11 · SWPLC — `can-add` gates BOTH liquidity adds and removals; a single owner-controlled toggle can strand every LP's principal `[CONFIRMED]`

`UEV_RemoveLiquidity` (`18_SWPLC.pact:408-422`) reads the **same** `can-add` flag `UEV_AddLiquidity` does
(`SWP::UR_CanAdd`, one schema field, no sibling `can-remove`); `C_ToggleAddLiquidity`'s only gate is
`CAP_Owner swpair`. Flipping `can-add=false` blocks new deposits **and** simultaneously hard-fails
`C_RemoveLiquidity` for every existing LP on the pool — permanently, until the same single key re-enables it,
with no time bound and no LP-side escape hatch. The REPL suite only ever drives the toggle to `true`, so this
interaction has never been exercised. **Fix direction:** split into two independent flags (`can-add`/
`can-remove`), or explicitly document/rename as a full circuit-breaker if that's the intended semantics.
**(Owner: is a single add+remove kill-switch intentional?)** **Interface implication:** splitting the flag
adds a new schema field + `UR_*`/`C_*` surface → **additive** to `SwapperV3`/`SwapperLiquidityClientV1`, likely
fits under current version numbers unless a cascade rule applies — confirm against `INTERFACE_VERSIONING.md`.
**Owner verdict:** _pending_

## H12 · SWP — `SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values with zero enforcement `[CONFIRMED code / PLAUSIBLE reachability]`

`15_SWP.pact:386-409`: `(if (> new-supplies[idx] 0.0) (ref-DPTF::UEV_Amount ...) true)` — when the resulting
value is `≤ 0.0`, the write proceeds with **no** check at all (no precision validation, no floor-at-zero),
persisting a negative pool-token-supply directly into `SWP|Pairs.pool-tokens`. Reachable today only if a
caller drives `new-supplies[idx] ≤ 0` — `SWPLC::C_Fuel`'s `validation=false` path (see C13) is the one found
route where negative `input-amounts` could reach this unchecked, and the only wired Talos entrypoint hardcodes
`validation=true`, so this specific hole is not reachable via the blessed path today, but nothing independently
re-validates non-negativity regardless of any upstream flag. **Fix direction:** `SWP|S>UPDATE-SUPPLIES` should
floor/enforce `new-supplies[idx] ≥ 0.0` unconditionally, not gated behind `> 0.0`. **Interface implication:**
none. **Owner verdict:** _pending_

---

# MEDIUM

## M1 · SWPI — `UC_ComputeY`/`UC_ComputeInverseY` silently drop all but the first input position on stable swaps `[PLAUSIBLE]`
`16_SWPI.pact:54-55` reads only `(at 0 ...)` of `input-amounts`/`input-positions`, unlike `UC_ComputeWP`/
`UC_ComputeEP` which correctly fold over the full list. If any caller ever invokes the stable path with &gt;1
simultaneous input, the extra amount(s) are silently unaccounted for by the invariant math. **Fix:**
either restrict-and-document (enforce `length==1` at the caller) or generalize to fold like the WP/EP paths.

## M2 · U|SWP/SWPT — BFS records only one chain per node; routing is pure hop-count with no value/liquidity comparison `[CONFIRMED — architectural, not a bug]`
`U|BFS::UC_BFS`'s global once-only `visited` marking (correct for termination — see VERIFIED CORRECT) means
only the *first-discovered* chain to any node survives, even when an equally valid alternate route exists —
confirmed with a diamond-graph reproduction (`A→{B,C}→D` loses the `A→C→D` chain). `URC_ComputeGraphPath`
then takes the one chain BFS kept, with no amount-out/liquidity-depth comparison across candidates (compounds
with C1's inverted per-hop edge selection). Not a correctness bug in the traversal itself — an architectural
choice (hop-count routing) that, combined with C1/C6, currently optimizes for none of {shortest economic
path, best edge, completeness}. **Owner to confirm:** is hop-count-only routing the intended product
behavior?

## M3 · U|SWP — unguarded `(enumerate 0 (- (length X) 1))` crashes (rather than returning `[]`) on empty-list inputs `[PLAUSIBLE]`
Pattern repeats across `UC_AreOnPools`, `UC_FilterOne`/`Two`, `UC_IzOnPools`, `UC_PoolTokensFromPairs`,
`UC_MakeGraphNodes`, and `U|BFS::UC_BFS` on an empty graph — `enumerate 0 -1` is an invalid range, raising an
opaque low-level Pact error instead of a clean empty-list result. Fails safe (aborts, no corruption) but is a
DoS/UX gap for any caller that doesn't pre-filter. **Fix:** short-circuit each with an explicit
`(if (= 0 (length X)) [] ...)`.

## M4 · SWPT — `UCX_GraphNodeLinks` linear-scans the whole node list on every BFS pop; no explicit gas/size cap `[PLAUSIBLE, needs gas measurement]`
O(V²) in practice (not O(V+E)) for high-degree "hub" tokens (e.g. a primary stable/KDA-pegged token connected
to many pools). C6's 2-hop envelope accidentally caps `V` for most pairs today, but nothing explicitly bounds
`length(graph)` or rejects an oversized query. **Fix:** index by node name instead of linear scan, and/or add
a documented max-node/max-degree cap.

## M5 · SWPI/MTX-SWP — `C_Issue` and `MTX|C_Issue` duplicate the write-side issuance logic instead of one calling the other `[CONFIRMED]`
`16_SWPI.pact:1383-1435` and `20_MTX-SWP.pact:866-897` independently reimplement the same mint/transfer/
tracker sequence, including a duplicated hardcoded `10000000.0` genesis-mint constant. Validation is correctly
shared (`MTX|C_Issue` step 1 reuses `SWPI::UEV_Issue`) but the writes are not — a future change to genesis
mechanics applied to one path and not the other silently diverges behavior. **Fix:** factor the shared write
sequence into one `XE_*` both callers invoke.

## M6 · SWP — `C_ChangeOwnership` is one-phase/unilateral `[PLAUSIBLE, by-design pattern — confirm]`
`15_SWP.pact:1246-1258` writes `new-owner` immediately on the current owner's signature alone — no acceptance
step. `ref-DALOS::UEV_EnforceAccountExists new-owner` only checks the account exists, not that it's the
intended recipient. A fat-fingered destination permanently strips the true owner of every pool-admin lever.
**Fix (or accept):** consider a two-phase propose→accept transfer.

## M7 · SWP — `C_EnableFrozenLP`/`C_EnableSleepingLP` have no pool-owner authorization at all `[CONFIRMED]`
Both caps (`15_SWP.pact:526-535`) compose only `P|GOVERNING-CALLER` (two `true`-bodied caps) — every other
admin lever in the module correctly calls `CAP_Owner swpair`; these two don't. Anyone routing through the
blessed aggregator can permanently flip either flag for any pool without owner consent — a potential griefing
vector if the frozen/sleeping-LP link imposes any downstream restriction. **Fix:** add `CAP_Owner swpair` to
both, or explicitly document why this is intentionally permissionless.

## M8 · SWPL — full-drain-to-zero re-triggers genesis-ratio pricing regardless of dust left in tracked reserves `[PLAUSIBLE]`
`URC_LD` (`17_SWPL.pact:864-876`) treats `current-lp-supply == 0.0` (a real, re-triggerable state, not a
one-time flag) as "first-ever depositor," pricing against the fixed genesis ratio/`10000000.0` baseline
regardless of what `UR_PoolTokenSupplies` actually holds at that moment. If flooring left non-zero dust when
supply hit exactly zero, re-genesis pricing anchors to the wrong ratio for that dust. **Fix:** derive the
"genesis" branch from actual zero reserves, not LP-supply alone, or sweep reserves to exactly zero whenever
supply reaches zero.

## M9 · SWPU — slippage bound is symmetric (min **and** max), not a pure floor `[CONFIRMED]`
`UC_SlippageMinMax` (`19_SWPU.pact:335-348`) rejects a swap that would deliver **more** than quoted by more
than the tolerance — for exact-input swaps, only a minimum-output floor is standard AMM protection; a max
bound causes unnecessary reverts on favorable price movement and opens a low-cost griefing angle (push price
favorably right before a queued victim swap to force its revert). **Fix:** drop the max bound for exact-input
swaps, or document why a ceiling is deliberately wanted.

## M10 · MTX-SWP — `kda-pid` price snapshotted at Step 0, reused unchanged at Step 1 with no re-validation or time bound `[CONFIRMED]`
`MTX|C_AddLiquidity`/`…Frozen…`/`…Sleeping…` (`20_MTX-SWP.pact`) `yield` a `clad` object priced against
`kda-pid` at Step 0; Step 1's re-check (`prev-pool-state == current-pool-state`) covers AMM reserves/weights/
fees but the `PoolState` schema has **no** price field, so `kda-pid` drift between steps is invisible to that
guard — `deficit-ignis-tax`/`special-ignis-tax`/`lqboost-ignis-tax`/`gaseous-ignis-fee` are all billed at the
stale Step-0 price. The single-tx path (`TS01-C3::SWP|C_AddLiquidity`) has zero exposure (reads and consumes
`kda-pid` in the same tx) — the staleness is introduced specifically by the multi-step decomposition. Not a
reserve-draining bug (core custody amounts aren't price-dependent) — one-sided, repeatable fee/tax mispricing.
**Fix:** re-derive price-dependent portions fresh in Step 1, add `kda-pid`/a staleness bound to the equality
check, or bound the allowable Step-0→Step-1 gap.

## M11 · MTX-SWP — permissioned pool issuance charges IGNIS+KDA before the admin gate that can reject it `[CONFIRMED]`
`MTX|C_Issue` (`20_MTX-SWP.pact:782-898`) Step 2 unconditionally collects IGNIS+KDA; Step 3 is the **only**
place the `p=true` admin cosignature requirement is checked. If the admin never signs Step 3, the pact sits
open forever with the Step-2 fee already spent, non-refundable, and no cancel/refund path. **Fix:** move the
admin gate earlier, or add an explicit reject/refund path, or document as an accepted cost.

## M12 · MTX-SWP — explicit rollback costs strictly more than silent abandonment, with no TTL on open pacts `[CONFIRMED]`
Every `step-with-rollback` charges a flat 100.0 IGNIS on rollback, on top of the prior step's own 100.0 (or
live IGNIS+KDA for Issue) — a patron who wants to cleanly cancel pays double; one who simply never continues
pays only the first step's cost and leaves the pact dangling forever (no expiry mechanism anywhere).
**Fix:** remove/reduce the rollback penalty, and/or add a max-age check on continuations (also bounds M10's
exposure window).

## M13 · Talos — SmartSwap `NoSlippage` recomputes the touched-pool set via a fresh post-swap BFS instead of using the swap's own returned edges `[CONFIRMED]`
`SWP|C_SmartSwapNoSlippage` (`04_TS01-C3.pact:818-859`) independently re-runs `URC_Hopper` **after** the swap
has mutated reserves and uses that fresh result to decide which pools get `XE_UpdateStoaValue` calls, instead
of using `(at 3 out)` — the swap's own actually-traversed edge list — as `SWP|C_SmartSwapWithSlippage`
correctly does. If the post-swap reserve shift changes which route BFS would now pick, some genuinely-touched
pools never get their StoaValue refreshed (stale until a later unrelated op) and/or untouched pools get a
spurious update. Self-healing, not a fund-loss bug. Companion dead-code note: `WithSlippage` computes the same
`path-edges` binding and never uses it (wasted gas). **Fix:** make `NoSlippage` mirror `WithSlippage` — use
`(at 3 out)`; delete the unused binding in `WithSlippage`.

## M14 · `0_Interfaces/03_Talos.pact` — `ClientThreeV2`/`ClientPactsV2` were overwritten in place rather than archived `[CONFIRMED, git history]`
Unlike the sibling `ClientFour` block in the same file (V1 through V6BlockTime all preserved with doc notes),
commit `df2d72e` rewrote `TalosStageOne_ClientThreeV2`'s text directly into `…V3` (and the same for
`ClientPactsV2→V3`) rather than archiving the old block — neither `V2` interface exists in the tree anymore,
only recoverable via `git show dde2bf4:...`. Not a live bug (nothing references the old names), but an
audit-trail gap given the same file demonstrates the correct archival pattern right next to it, and per
`CLAUDE.md`'s own policy a post-mainnet `V2→V3` bump is exactly the case whose frozen prior version is most
valuable to keep. **Fix:** reconstruct and re-add `ClientThreeV2`/`ClientPactsV2` from git history as frozen
historical blocks, matching the `ClientFour` convention.

---

# LOW (discipline / hygiene)

**U|SWP** — `UC_LpID` calls a bare cross-module `UEV_UniformList` directly inside a nominally pure `UC_*`
function (StoicSyntax purity violation, check itself is legitimate) · module's `UC_*` surface transitively
inherits `enforce` from `U|LST` helpers (`UC_ReplaceAt`, `UC_RemoveItemAt`, `UC_LE`/`UC_FE`) — prefix contract
not fully honored end-to-end · `UC_ComputeWP`/`InverseWP` divide by weight with no zero-guard (presumably
prevented upstream by C4's fix once applied, but the math core itself has no self-defense) · `UC_ComputeD`
docstring says "5 iterations", code runs 6.

**U|BFS** — `UCX_*`/`UDCX_*` is a locally-invented aux-depth naming tier not codified in `StoicSyntax.md`
(only `URCX_`/`URDCX_` are documented) — reasonable extension, worth codifying if intentional.

**SWPT** — `URC_AllGraphPaths` is misleadingly named (returns one shortest chain per discovered node, not all
simple paths — good for gas, bad for API clarity; risks future misuse assuming true all-paths semantics) ·
`REPL/Stage_01/[6.3]_SWP.repl`'s "Smart Swap Tests" section contains exactly one SmartSwap transaction with no
assertions on chosen nodes/edges and no ≥2-parallel-pool, disconnected-pair, or ≥4-hop coverage — none of C1/
C6/H2/H3/H4 are caught by the existing suite.

**SWPI** — `UC_BareboneSwap`/`InverseSwap`'s unrecognized-`pool-type` fallback returns a silent `-1.0` sentinel
instead of an abort (currently unreachable, weaker failure mode if the pool-type invariant is ever broken) ·
magic constants `5040000.0`/`10000000.0` undocumented and unrelated-looking · `URC_Hopper`'s `@doc` says
"cheapest available edge" — imprecise framing for what should be "maximizes output" (see C1).

**SWP** — `UR_StoaValue` performs an ungated `update` write as a side effect of a nominal "read" (idempotent
today, violates the module's own reads-don't-write contract, externally triggerable at the caller's gas
expense) · `C_ModifyWeights` composes bare `(SECURE)` directly rather than a named master client cap, unusual
layering vs. the rest of the module · `XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no `@doc`
per R4 · `UEV_PoolFee`'s upper bound (320.0) has units not self-evidently sane, worth confirming against
SWPU's fee-application formula · `AHU`/`AUP_SwapPair(s)` migration utility falls outside the module's own
prefix vocabulary (should likely be `A_*`) · `XE_CanAddOrSwapToggle` redundantly re-derives an equivalent
check `UEV_IMC` already performed.

**SWPL** — `URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*` (StoicSyntax: validation belongs
in `UEV_*`/defcap; harmless — still correctly rejects, matches AQP's L1 pattern) · `XI_AddLiqSendAndMint`
performs two distinct writes (transfer-in + mint) in one `XI_` (documented honestly by the combined name;
order within it is correct, custody-first) · `|KDA-PID`-qualified `defun` names deviate from the "prefix-only,
no embedded qualifiers" convention (consistent local pattern across SWPL/MTX-SWP/TS01-C3, likely deliberate —
worth a documented exception) · `XE|KDA-PID_AddLiqudity` bumps reserves before `XI_AddLiqSendAndMint`'s actual
transfer — safe only because the whole call is one atomic tx; worth a defensive comment given MTX-SWP elsewhere
*is* multi-step.

**SWPLC** — LP-branding fee attribution (`C_UpdatePendingBrandingLPs`) resolves `entity-owner` via the
token's own DPTF/DPOF `Konto` field rather than `SWP::UR_OwnerKonto` directly — authorization is still
correctly pinned to the real owner via `CAP_Owner`, but IGNIS-cumulator billing attribution could diverge if
`Konto` is ever set to the shared vault at issuance (needs a check of `SWP::XE_Issue`'s DPTF-issuance call) ·
`C_UpgradeBrandingLPs` is commented out in the REPL suite, untested · `C_Fuel` has zero REPL coverage of any
kind (direct, indirect, validated, unvalidated) despite moving real funds · the module defines no `XI_*` at
all — every `C_*` orchestrates peer `ref-X::C_*`/`XE_*` calls inline (internally consistent across the file,
but a deviation from the "C_* calls XI_*/W_*" default).

**SWPU** — `URC_Swap`'s `validation:bool` parameter name is misleading (toggles enforcement, not gross-vs-net
— exactly what made C11 easy to miss) · `URC_Hopper` computed twice for the same Smart Swap tx (defcap +
execution) — wasted gas, not a correctness bug (no writes occur between the two calls) · failure-branch
`OutputCumulator` object literals hand-built instead of via a `UDC_*` constructor.

**MTX-SWP** — `MTX|C_AddSleepingLiquidity` step 0 caches a nonce's supply and step 1 burns the cached value
rather than re-reading current supply (ownership *is* re-checked fresh; believed safe only because `DPOF::C_Burn`
is assumed to enforce sufficiency — not independently verified in this scope) · no TTL/expiry mechanism on any
of the 8 `defpact` flows (state-bloat + enables M10/M12) · `MTX-SWP|S>ADD-LQ`'s own `@doc` implies a short,
bounded `kda-pid` lock window that the implementation doesn't actually enforce (see M10).

**Talos** — `SWP|C_Fuel`/`SWP|C_Firestarter` are public on `TS01-C3` but not declared on
`TalosStageOne_ClientThreeV3` (interface-completeness gap, not a security issue — still reachable via the
concrete module ref) · `SWPU::C_ToggleSwapCapability` and `SWPLC::C_ToggleAddLiquidity` both call
`SWP::C_ToggleAddOrSwap` directly (a client-tier `C_` on a peer core module) rather than through a dedicated
`XE_`/`XB_` forward entrypoint that already exists (`XE_CanAddOrSwapToggle`) but is only ever self-invoked —
verified not currently exploitable (`CAP_Owner`'s `enforce-guard` holds regardless of which module is on the
call stack) but fragile: a future change to `C_ToggleAddOrSwap`'s cap composition assuming Talos-only entry
could silently break both callers.

---

# What is VERIFIED CORRECT (invariants that hold — the sign-off backbone)

**U|SWP** — `UC_ComputeD`/`UC_DNext` matches the Curve reference StableSwap invariant term-by-term (re-derived
algebraically), converges to ~1e-29 relative error for balanced pools and up to 100× skew. `UC_YNext`/`UC_ZNext`
are the correct derivative-based Newton update for both swap directions (symmetric substitution confirmed) and
converge to the exact continuous solution within ~1e-25 *for in-domain inputs* (see C2 for out-of-domain).
`UC_ComputeWP`/`InverseWP` correctly implement the Balancer-style weighted invariant (`∏xᵢ^wᵢ`) as an exact
closed-form solve, not an approximation. `UC_ComputeEP`/`InverseEP` correctly implement the equal-weight
constant-product special case. `UC_SpecialFeeOutputs` apportions a total across weighted shares with the last
share absorbing all rounding remainder — exact conservation (`Σparts == input`), a genuinely well-designed
pattern worth using as the template for fixing C3 elsewhere. Pool-type dispatch is unspoofable — a swpair's
first character (`S`/`W`/`P`) is baked in at issuance by `UC_Prefix` and every dispatch site reads the same
derived value; no path calls weighted math on a stable pool or vice versa.

**U|BFS** — `UC_BFS` termination is proved and numerically confirmed: total enqueues bounded by `N-1` given a
graph of `N` nodes (visited marked at enqueue, not dequeue — the correct discipline), exactly matching the
`length(graph)`-bounded outer fold. No infinite loop or duplicate re-expansion on a graph containing a cycle
(tested: linear chain, cycle+tail, branching tree — all fully explored). This holds **regardless** of C6's
node-envelope mismatch — the BFS primitive itself is sound; the bug is in what graph it's handed.

**SWPT** — genuinely read-only/pure-compute across every `URC_*`/`UR_*`/`UC_*` — no `enforce`, no table writes
on the pathing functions. `XE_MultiPathTracer`/`XI_SinglePathTracer` correctly follow the XE/XI split
(`UEV_IMC` first, no enforce in the XI body, write-only). `URC_PathTracer`'s `BAR`-sentinel bookkeeping
correctly strips a stray leading sentinel before persisting a principal's first entry. No forbidden
`select`/`keys` on the execution path. The degenerate "input has zero links at all" case is handled cleanly
(only the *other* empty-result shape crashes — H2).

**SWP** — Fee-lock semantics work as intended (`UEV_FeeLockState` genuinely blocks `C_UpdateFee` while locked).
`FeeSplit` proportional distribution is safe by construction — `UC_SpecialFeeOutputs` normalizes by the live
submitted sum, not a fixed basis, so targets can never collectively exceed the collected fee regardless of
individual `value` choices. `CAP_Owner` is correctly and consistently applied to `C_ChangeOwnership`,
`C_ModifyCanChangeOwner`, `C_ModifyWeights`, `C_UpdateFee`, `C_UpdateAmplifier`, `C_UpdateSpecialFeeTargets`,
`C_ToggleFeeLock`, `C_ToggleAddOrSwap` (the only exceptions found are M7's two). Table-key construction
(`UC_PoolID`) is consistent at both existence-check and issuance time — no collision risk observed. `UEV_IMC`
is present as the first statement of every `A_*`/`C_*`/`XE_*`/`XB_*` in the module. No `select`/`keys`/`URD_*`
on any execution path (the one scan-capable reader, `URD_OwnedSwapPairs`, is never called from a mutating
path). All persistence gates on `require-capability` of a named governing cap or `SECURE` — no raw unguarded
writes found outside the X-tier (aside from the L-item `UR_StoaValue` discipline note). `cd REPL && pact
Z.repl` runs green end-to-end, confirming baseline behavioral correctness for every scenario the suite covers.

**SWPI** — `UC_BareboneSwapWithFeez`/`InverseBareboneSwapWithFeez` fee sequencing is internally consistent and
not double-applied: LP fee deducted from input before the invariant math (fee-on-input, retained portion
fueled back), special/boost fees carved from the AMM-computed gross output after (fee-on-output) — no
component applied twice or skipped. Not vulnerable to the classic donation/first-depositor attack — reserves
are a maintained ledger table, never a live read of custody balance, so a direct transfer into `SWP|SC_NAME`
outside the tracked write path cannot move pricing or dilute LP value. Multi-hop execution reads live,
non-stale state — each hop re-reads reserves fresh and commits via `XE_UpdateSupplies` before the next hop
begins (only the *edge selection* within a hop is wrong — C1; sequencing itself is sound). `amp` is correctly
floored at issuance (`UEV_Issue`, `≥1.0`) — the update-time gap is a separate finding (C8). `C_Issue`'s cap
wiring follows the StoicSyntax C_ contract exactly.

**SWPL** — Balanced-add mint is genuinely proportional (`minted = totalSupply·depositValue/poolValue`) for any
pool size, traced end-to-end through `UC_LP`. First-depositor/empty-pool edge case has no donation-attack
surface (reserves are a separately-maintained ledger, not a live custody-balance read — same protection as
SWPI's). Multi-step defpact TOCTOU/front-running protection is real: `pool-state` is snapshotted at Step 0 and
re-checked before Step 1 executes, with a clean rollback branch on mismatch (this correctly defends the
depositor's own quote from third parties — it does **not**, and structurally cannot, defend against C10's
self-directed exploit, which is a pricing-formula defect, not a TOCTOU one). `XE_AutonomousSwapManagement` is
correctly scoped (IMC-gated, no per-user pricing effect). All five liquidity-add variants (Standard/Iced/
Glacial/Frozen/Sleeping) funnel through one shared math chokepoint — good for maintainability, though it also
means C10 affects every variant with an asymmetric component uniformly.

**SWPLC** — `C_RemoveLiquidity`'s withdrawal math is proportional-and-conservative: `ratio` and per-token
amounts are `floor`-only at every stage (rounding always favors the pool/remaining LPs, never the withdrawer).
Full-withdrawal (100% burn) is special-cased to return exact reserves with no residual dust, and the next
depositor correctly detects `lp-supply==0` to re-read genesis supplies rather than inheriting a corrupted
ratio — full-drain-then-refill is handled correctly end-to-end (see M8 for the *partial*-dust variant of this
case). `totalSupply==0` division is structurally unreachable (the `lp-amount>0 ∧ lp-amount≤pool-lp-amount`
enforce pair rules it out before the divide). Burn/transfer ordering has no double-withdraw window (Pact's
single-threaded atomic execution). The `C_Fuel` **direct** branch is fully backed 1:1 by a real,
TFT-authorized transfer with no LP minted in return — no wash-profit or first-depositor manipulation surface
on that branch specifically (contrast C13's indirect branch). LP-branding authorization can't be redirected to
a different pool via `entity-pos` manipulation — the position resolves strictly from the caller-given
`swpair`'s own token fields.

**SWPU** — the `-1.0` no-slippage sentinel is genuinely a skip-the-check value everywhere it's used, never
compared as a real bound. Boundary inclusivity (`>=`/`<=`) is consistent between direct-swap and smart-swap
paths. Multi-hop execution has no `try`/error-swallowing around any hop — a failing hop reverts the whole tx
(Pact default atomicity), and `can-swap` is checked for **every** edge in the route up front, not just the
first/last. Liquid-boost/special-fee exclusion from the transferred amount is directionally correct (`o-id-
netto = tsoa - special - boost` — the wiring of "what the user gets" is right; only the slippage *check* is
anchored to the wrong quantity, C11). `kda-pid`/OURO-price-update gating is correctly scoped to primordial-
pool-touching routes only.

**MTX-SWP** — every fund-moving continuation step re-checks a full-object `PoolState` equality before touching
custody (native Pact `enforce`, no auto-rollback-on-mismatch — a failed check just safely reverts, re-
attemptable later). Per-pool circuit breakers (`can-add`, asymmetric-allowed, frozen/sleeping-enable) are
re-evaluated fresh at every step — an admin toggling any of these mid-flight **is** correctly caught (the
contrast case that makes H10's GAP gap notable). No custody happens in any pure-compute step — abandoning a
pact there costs only the flat entry fee, no principal ever at risk from partial completion. Final-delivery
steps are reachable by anyone for the already-fixed `account` (never a caller-choice), so LP minted mid-flight
is never permanently strandable. No custom replay surface — every flow uses native `step`/`step-with-rollback`
keyed by Pact's own `pact-id`. Chokepoint reuse against the single-tx path is real, not a parallel
reimplementation — `MTX|C_Issue` and `SWPI::C_Issue` both terminate in `ref-SWP::XE_Issue`, and Step 1 reuses
`SWPI::UEV_Issue` for validation.

**Talos (TS01-C3/TS01-CP)** — the two issuance/liquidity rails (atomic single-tx via `TS01-C3`, multi-step via
`TS01-CP`→`MTX-SWP`) are genuinely parallel front doors sharing validation and core mutation, not one wrapping
the other, and confirmed to use identical `asymmetric-collection`/`gaseous-collection` boolean encodings — no
semantic divergence between the two rails. The full slippage-wrapper family was traced end-to-end:
`WithSlippage` passes the caller's bound through unmodified, `NoSlippage` uses a genuine skip sentinel (never
even reads the bound object's content on that branch), and every swap wrapper's argument order matches its
target interface signature positionally, including `SingleSwap*`'s single-element-list wrapping. IGNIS billing
is complete across all ~30 client wrappers — spot-checked individually, including the two apparent exceptions
(`C_UpgradeBranding`/`C_UpgradeBrandingLPs`, which self-bill in KDA at the core layer, not a skip) and the
documented, bounded, fee-charging `C_Firestarter` faucet. `UEV_IMC` placement and `format`-string honesty
(branch-accurate result messages) were spot-checked across every swap/liquidity/issue wrapper with no
mismatch found. No Talos-originated core-to-core `C_`→`C_` shortcut was found (the one instance in this scope
is core-to-core, not Talos itself — see LOW).

---

# Talos wiring completeness matrix (per user request — every SWP-family public entrypoint, wired or not)

Legend: ✅ wired into `TS01-C3`/`TS01-CP` · 🅰 wired into `TS01-A` (Stage-1 admin Talos, confirmed present, out
of this audit's core scope) · ⭕ internal-only by design (correctly unwired) · ⚠ flagged.

**`15_SWP.pact`** — `A_UpdatePrincipal`/`A_UpdateLimit`/`A_UpdateLiquidBoost`/`A_DefinePrimordialPool`/
`A_ToggleAsymetricLiquidityAddition` 🅰 (`01_TS01-A.pact`) · `C_ChangeOwnership`/`C_EnableFrozenLP`/
`C_EnableSleepingLP`/`C_ModifyCanChangeOwner`/`C_ModifyWeights`/`C_ToggleFeeLock`/`C_UpdateAmplifier`/
`C_UpdateFee`/`C_UpdateSpecialFeeTargets`/branding functions ✅ · `C_ToggleAddOrSwap` ⚠✅ (reached only
indirectly, cross-module, from `SWPLC`/`SWPU` — see LOW) · `XB_ModifyWeights`/`XE_UpdateSupplies`/
`XE_UpdateSupply`/`XE_Issue`/`XE_CanAddOrSwapToggle` ⭕ · `XE_UpdateStoaValue` ✅ (called directly by Talos
after every liquidity/swap op).

**`16_SWPI.pact`** — `C_Issue` ✅ (atomic fast-path issuance). All else `UC_`/`URC_`/`UEV_`/`UDC_`, correctly
unwired.

**`17_SWPL.pact`** — no `C_`/`A_` surface at all; `XI_AddLiqSendAndMint`/`XE_AutonomousSwapManagement` ⭕,
correct by construction (pure internal compute/write core for `SWPLC`).

**`18_SWPLC.pact`** — `C_UpdatePendingBrandingLPs`/`C_UpgradeBrandingLPs`/`C_ToggleAddLiquidity`/`C_Fuel`/
all 5 `C|KDA-PID_Add*Liquidity`/`C_RemoveLiquidity` ✅ — complete. `C_Fuel`'s wired call hardcodes
`direct-or-indirect=true, validation=true`; the `false`-branch reachability concern is C13, not a
completeness gap.

**`19_SWPU.pact`** — `C_ToggleSwapCapability`/`C_SmartSwap`/`C_Swap` ✅ (8 wrapper variants across With/
NoSlippage × Single/Multi/Smart). All `XI_*` internal orchestration tiers ⭕ — complete.

**`20_MTX-SWP.pact`** — `C_IssueStablePool`/`WeightedPool`/`StandardPool`/`C_AddStandardLiquidity`/
`IcedLiquidity`/`GlacialLiquidity`/`FrozenLiquidity`/`SleepingLiquidity` ✅ **Step 0 only** — Steps 1-2 of
every one of these 8 flows are **not reachable through any Talos wrapper** (structural consequence of Pact's
`continue-pact` mechanism, not a missed wiring task — see H10 for the resulting security gap this creates).

No public `A_`/`C_`/protected-`X*` entrypoint across the 6 core+util modules was found completely unwired with
no Talos or admin-Talos path at all — the wiring gap that exists (MTX-SWP Steps 1-2) is a Pact-mechanics
limitation, documented at H10, not an oversight in the Talos files themselves.

---

# Cross-cutting themes

1. **"Computed but never enforced" is the single most repeated pattern in this audit** — C7's dead precision
   `map` in `SWP|S>WEIGHTS`, H5's dead precision `map` in `SWPI::UEV_Issue`, and H6's unused `primality`
   binding in `SWP|C>DEFINE-PRIMORDIAL-POOL` are three independent instances of exactly the same author habit:
   write the check, forget the `enforce`. Matches AQP Round-I's own cross-cutting theme 3 — worth a dedicated
   StoicSyntax lint/review step ("every `map`/`fold` producing a `[bool]` or `bool` in a defcap must terminate
   in an `enforce`") rather than continuing to catch these one at a time.
2. **Rounding/precision bias systematically favors the counterparty across the entire math core** — C3's
   six-formula rounding bias and C10's unreduced asymmetric-mint are the same root failure mode (a
   mathematically correct, protocol-favorable number exists or is computable, and a less-favorable one is used
   instead) recurring at two different layers: raw swap math (U|SWP) and liquidity-add math (SWPL).
3. **Bound-checking discipline is inconsistent across a parameter's own lifecycle** — `UEV_Issue` correctly
   bounds `amp≥1.0`, weight-sum, and (per this round's fixes) will bound individual weights/reserves at
   **creation**; the exact same parameters (`C_UpdateAmplifier`, `C_ModifyWeights`) have **no** equivalent
   bound when changed **later**. The module clearly knows how to write these guards (see `UEV_PoolFee`) — it
   simply didn't apply the pattern uniformly across create vs. update paths.
4. **The routing layer optimizes for none of its own stated goals** — "Smart Swap" is neither shortest-value
   (M2: pure hop-count, no amount comparison) nor even correctly edge-optimal within a hop (C1: inverted
   comparator) nor exhaustive in graph coverage (C6: node/edge-set mismatch). Each defect is individually
   fixable and none compound into a fund-safety issue on its own, but together they mean the routing layer's
   name currently overstates what it does.
5. **Pact's `defpact` continuation model silently drops exactly the one control that lives only at the Talos
   layer** (H10) while faithfully preserving every control MTX-SWP itself owns (per-pool circuit breakers) —
   a structural, not incidental, gap: anything checked *only* in a Talos wrapper is invisible to
   `continue-pact`, by construction of how Pact's multi-step transactions work.
6. **The codebase's sole cross-module trust primitive (`UEV_IMC` over trivially-true capability chains) may
   not provide the access control `StoicSyntax.md` describes it as providing** (C13) — a question this audit
   surfaces via one concrete, unprotected instance (`C_Fuel`'s indirect branch) but which, if confirmed, has
   implications for every Stage-1/Stage-2 module using the identical pattern, not just SWP.

---

# Needs a REPL to confirm (Round III fodder — one assertion per item below)

- **C1:** two parallel pools for the same pair, different depth; run a multi-hop SmartSwap and assert the
  chosen edge is the *deeper* pool (currently: the shallower one).
- **C2:** a swap with `input-amount` just above the observed `~1.0×xo` breakpoint; assert the output does not
  exceed the pool's actual token balance (currently: it can).
- **C3:** a fee-free (or fee-known) two-leg round trip (A→B→A); assert the trader nets **no** profit
  (currently: nets +1 precision-unit per formula family tested).
- **C4/C5:** issue a W-pool with a `0.0` weight, and separately a pool with a `0.0` genesis reserve; assert
  issuance is **rejected** (currently: succeeds, then hard-aborts on the first swap touching that token).
- **C6:** build the 4-hop `A-B-C-D-E` topology; call `URC_ComputeGraphPath("A","E",...)` directly and assert
  it returns a valid path rather than crashing/dropping it.
- **C7:** `C_ModifyWeights` with a length-mismatched `new-weights` array; assert rejection (currently:
  succeeds, bricking the pool on the next swap).
- **C8:** `C_UpdateAmplifier` to `0.0`/negative/`-1.0` on a live stable pool; assert rejection (currently:
  succeeds, then the next swap hard-aborts or the pool silently misroutes as non-stable).
- **C9:** issue a pool via `MTX-SWP::C_IssueStablePool`/etc., then attempt any AQP LP-stake admission on the
  resulting LP token; assert it succeeds (currently: hard tx abort on the missing `SWP|LP` row).
- **C10:** single-sided deposit via `SWP|C_AddLiquidity` immediately followed by full `C_RemoveLiquidity`;
  assert the depositor doesn't net more than break-even in any token (currently: nets a real profit at other
  LPs' expense — worked example nets ~47 units of an undeposited token on a 100-unit deposit).
- **C11:** a swap on a pool with known nonzero fees; assert `o-id-netto` delivered is never below the
  slippage-derived `min` (currently: `min` is compared against a number that never includes fees, so this can
  be violated silently).
- **C12:** from a non-owner account, call `SWP|C_ToggleSwapCapability(...,false)` on someone else's pool via
  Talos; assert rejection (currently: succeeds).
- **C13:** attempt `(with-capability (TS01-C3.P|TALOS-SUMMONER) (SWPLC.C_Fuel account swpair amounts false
  false))` from a bare top-level transaction (not through any of SWPLC's own exposed functions); determine
  whether it succeeds — this is the single most consequential open question in the whole audit and should be
  run before anything else in Round III.
- **H10:** start any of the 4 MTX-SWP `defpact`s via `TS01-CP`, trip Global Administrative Pause, then
  `continue-pact` the remaining steps directly; assert rejection (currently: completes anyway).
- **H11:** toggle `can-add=false` on a pool with an existing LP position; attempt `C_RemoveLiquidity`; confirm
  current behavior (reverts) matches intended product design.
- **M9:** construct a swap where price moves favorably beyond the slippage tolerance between quote and
  execution; confirm the tx currently reverts despite the user receiving a *better* price than quoted.

---

# Summary index

**Modules audited (11/11 in scope, 100% coverage):** `U|SWP`, `U|BFS`, `SWPT`, `SWP`, `SWPI`, `SWPL`, `SWPLC`,
`SWPU`, `MTX-SWP`, `TS01-C3`, `TS01-CP`.

**Findings by severity:** 13 CRITICAL · 12 HIGH · 14 MEDIUM · ~30 LOW/hygiene items (grouped by module above).
Two findings (C1, H10) were independently reproduced by two separate auditors approaching from different
modules; two more (C3's core defect, C8's root cause) were cross-confirmed by a second auditor tracing a
different consumer — treated as corroboration, not double-counted in the totals above.

**Live-vs-local divergence:** not yet run — blocked on the owner-supplied Pythia `x-pythia-key` and chain-id
confirmation (see README.md). No findings in this document currently depend on live/local drift; once the key
is available, results will be appended to README.md and cross-referenced here if any divergence affects a
finding's applicability.

**Interface-version implications:** the large majority of findings (all math/validation-only fixes) require
**no** interface bump — they tighten internal checks or fix internal formulas without touching any public
signature. Three findings do carry version implications if fixed as recommended:
- **C12** (`C_ToggleSwapCapability` ownership) — **requires** bumping `SwapperUsageV2` (adds a parameter) and
  cascading to `TalosStageOne_ClientThreeV3`.
- **C13** (`C_Fuel` IMC/indirect-branch hardening) — **if** fixed by splitting the function (removing
  `direct-or-indirect` from the public surface) rather than hardening the cap body alone, requires bumping
  `SwapperLiquidityClientV1` and cascading to `TalosStageOne_ClientThreeV3`.
- **H11** (`can-add`/`can-remove` split) — **additive** change to `SwapperV3`/`SwapperLiquidityClientV1`;
  confirm against `INTERFACE_VERSIONING.md` whether additive-only members force a version bump under this
  repo's cascade rule or can land under the current `V3`.
All three are Stage-1 SWP interfaces already implied to be live on mainnet per this audit's own premise — per
`CLAUDE.md` policy, a forced post-deploy version bump is exactly the scenario these interfaces' `V1→V2→V3`
history already anticipates (and see M14 for a request to preserve, not overwrite, whatever the next archived
version becomes).
