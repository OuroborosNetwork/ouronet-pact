# ROUND II — Fixes (SWP modules)

One entry per fix, applied sequentially, owner green-lit before landing. Diff summary + why.

## Fix #1 — C2 (#3C): `U|SWP` StableSwap Newton solver has no domain guard

**Owner direction:** owner challenged the initial framing at each step rather than accepting it outright —
"can you really confirm the math is wrong?", then required the fix live at the computation level (no
`enforce`/`UEV` allowed inside `UC_*`), then independently predicted the bug is stable-pool-only and that a
provably-correct solver removes the need for a separate pre-transfer sanity check. All three were verified
against the source and numerics before anything was touched — see the full exchange in
`ROUND-01-OWNER-FEEDBACK.md` (C2 entry) for the complete trace.

**Root cause (verified, not assumed):** `UC_YNext`'s Newton iteration is algebraically a correct
root-finder for `f(Y) = Y² + (b-D)Y - c`, a quadratic with one positive (physical) and one negative
(non-physical) root. `UC_ComputeY` seeded `y0 = xo - input-amount` (`12_U_SWP.pact:73`), which goes negative
once `input-amount >= xo` (the output token's own reserve), walking Newton into the wrong root's basin.
Numeric replica of the exact Pact `floor`/`fold` sequence: pool `X=[1000,1000,1000]`, `A=85`, `input=1010`
(just over 1.0× the output reserve) solved to `Y=-31.77` → `output=1031.77`, exceeding the pool's entire
balance of that token.

**Reachability confirmed, not assumed:** traced the full call chain (`SWPI::URC_S-Swap` →
`UC_ComputeY`, gated only by `UEV_SwapData`, `16_SWPI.pact:1162-1188`) — the only validation gate checks
token membership/list lengths, never `input-amount` vs. the output reserve. No guard exists anywhere in the
real swap path (`19_SWPU.pact::XI_SmartSwapCore` included). Also confirmed this is **not self-limiting**:
the oversized amount is transferred via `TFT::C_Transfer` to the trader *before* `XE_UpdateSupplies`
persists the corrupted balance, and the source account (`SWP|SC_NAME`) is a shared vault across every pool
— a token backing multiple pools can have ample balance to cover an oversized draw against one specific
pool's accounting, so the transfer doesn't reliably revert on insufficient funds.

**Scope confirmed stable-pools-only:** read `UC_ComputeWP`/`InverseWP`/`UC_ComputeEP`/`InverseEP`
(`12_U_SWP.pact:250-362`) — all four are closed-form single-shot algebraic solves (no fold, no iteration,
no initial guess), structurally incapable of this seed-dependent wrong-root failure mode.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`, `UC_ComputeY`, line 73:**

```diff
-                ;;For best results <input-amount> < 0.9975 * xo
-                (y0:decimal (- xo input-amount))
+                ;;Seeded at <D> (matching the Curve-style reference `get_y`), not <xo - input-amount>
+                ;;<xo - input-amount> goes negative once <input-amount> >= <xo>, walking Newton into the
+                ;;non-physical negative root of the same quadratic; <D> is always in the correct root's
+                ;;basin regardless of trade size (C2 fix)
+                (y0:decimal D)
```

`D` (the invariant, already computed at line 61 in the same `let`) is always in the correct root's basin
regardless of trade size, because the physical root (`0 < Y < xo`) exists for *any* positive input — the
curve asymptotes toward but never reaches `0`. One-line change, pure arithmetic, no `enforce`/table read —
`UC_ComputeY` stays fully `UC_*`-legal. `UC_YNext`, `UC_ComputeInverseY`, `UC_ZNext` untouched. No interface
change (`UtilitySwpV1` signature unaffected).

**Explicitly NOT fixed — `UC_ComputeInverseY` (different failure mode):** investigated whether the same
reseed applies; it doesn't. Its `xo-minus = xo - output-amount` (not `y0`) feeds directly into
`S-Prime`/`P-Prime` as a supposedly-known coefficient *before* Newton starts. Numeric replica confirms this
divides by zero exactly at `output-amount = xo` and produces corrupted (sign-flipped) coefficients past it
— not a wrong-root-from-bad-seed problem, so reseeding is a no-op there (confirmed: identical output for
both seed choices up to the crash point in the replica). This needs its own, separate treatment (likely a
real domain enforcement on `output-amount`, since "solve the input needed to withdraw more than the pool
has" has no valid answer to converge to). Left untouched; tracked as still-open.

**REPL test — new `SWP|TX 015 - C2 Regression: Stable-Swap Newton Domain Guard` in
`REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`** (the canonical, default-loaded suite — not scratch),
appended after `TX 014 - Enable Pools Functionality` where pool7 (the live stable pool) is issued and
swap-enabled. Reads pool7's real on-chain state via `SWP::UR_Amplifier`/`UR_PoolTokenSupplies`/
`UR_PoolTokenPosition`/`UR_PoolTokenPrecisions`/`UR_Weigths` — no hardcoded reserve figures — and calls
`U|SWP::UC_ComputeY` directly at three input sizes relative to the live output reserve `xo`:
- **in-domain** (`1000.0`) — must be unaffected by the fix.
- **oversized** (`1.2 × xo`) — the exact size that broke the pre-fix solver.
- **extreme** (`1000 × xo`) — must still resolve to the physical asymptote, not misfire.

Each asserts the actual invariant that must hold regardless of trade size — `output > 0.0` and `output <
xo` — rather than a golden decimal value, so the test survives future internal changes to the solver as
long as the invariant itself is preserved.

**Verification:**
1. Python replica of the exact Pact fold/floor sequence — `y0=D` keeps output inside `(0, xo)` from 1× up
   through 1,000,000× the old breaking point, unchanged from the old (correct) answer wherever the old code
   already worked in-domain.
2. `pact Z.repl` (default, issuance-only SWP path) — exit 0, 0 `FAILURE`, `Load successful`, all 6 new
   `expect`s → `Expect: success`.
3. Temporarily switched `Stage01_Tester.repl` to the full `[6.2]_DPTF.repl` + `[6.3]_SWP.repl` suite
   (README's stated baseline coverage) and reran — exit 0, 0 `FAILURE`. Toggle reverted afterward (final
   diff touches only the two intended files).
4. **Adversarial proof the new test is real, not vacuous:** `git stash`'d only `12_U_SWP.pact` back to the
   pre-fix code, reran `Z.repl` — the two oversized/extreme assertions failed exactly as predicted
   (`FAILURE: ... oversized swap ... expected: true, received: false`, likewise for extreme) while the
   in-domain assertion still passed — confirms the test isolates precisely the C2 failure mode, nothing
   broader. Restored the fix (`git stash pop`), reran — 6/6 `Expect: success` again.

**Unrelated, pre-existing note (not a regression from this fix):** the full `Z.repl` pipeline currently
fails later, in Stage 2, inside `AQP-VCT` (`Variable ln shadows native...` → `Load failed` loading
`[2.3]_EarningPools.repl`) — in-progress, uncommitted work from a separate session (`05_VCT.pact` and
neighboring files), untouched by this fix. SWP's own Stage-1 run, including the new `TX 015`, completes and
passes well before that point in every run above.

**Status:** FIXED ✅ AND PROVEN ✅ — scope, fix layer, and the drop of the pre-transfer sanity-check
recommendation were all owner-predicted and then independently verified rather than assumed.
`UC_ComputeInverseY`'s sibling issue remains explicitly open (not part of this fix; not yet its own tracked
finding — should be split out before Round III re-verify closes C2). Awaiting Round III re-verify.

## Fix #2 — C1 (#6C): `SWPI::URC_BestEdge` picks the worst parallel-pool edge, not the best

**Owner direction:** don't accept the finding on the strength of a code read alone — construct a real
swap scenario in REPL against actually-issued pools and observe whether the described behavior holds
before touching any code.

**Reproduction (before any fix):** used two pools already present in the fixture that both directly
connect the same token pair (DLK, OURO) — no new fixtures needed:
- `W|DLK-98c486052a51|OURO-98c486052a51|DWK-98c486052a51` — deep, genesis reserves 3200/10000/6000.
- `S|DLK-98c486052a51|OURO-98c486052a51|DWK-98c486052a51` — shallow, genesis reserves 800/900/850.

Both are registered principals (`TX-18 [4.1.19]` in `[4.0]_Sovereign-Executor.repl`) and swap-enabled by
`SWP|TX 014`. Added `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 016 - C1
Reproduction`: computed each pool's real output for the same `10.0` DLK input independently, via the same
`URC_Swap` any real caller uses (so "which pool is objectively better" is derived live from current pool
state, not asserted from the audit doc), then compared that against what `URC_BestEdge` itself picked.
Live interpreter output, not predicted:

```
pool1 (W, deep)     output for 10.0 DLK->OURO = 18.703251597095004399307073
pool2 (S, shallow)  output for 10.0 DLK->OURO = 10.001390223588246869505299
URC_BestEdge actually chose:            S|DLK|OURO|DWK   (the WORSE pool — 10.00 output)
Objectively better edge (higher output): W|DLK|OURO|DWK   (18.70 output — nearly 2x)

FAILURE: C1 reproduction — URC_BestEdge selects the higher-output edge
  expected: "W|DLK-98c486052a51|OURO-98c486052a51|DWK-98c486052a51"
  received: "S|DLK-98c486052a51|OURO-98c486052a51|DWK-98c486052a51"
```

Finding upheld empirically, not just from reading the fold.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`, `URC_BestEdge`, line 909:** one-character comparator
flip in the edge-selection fold (argmin → argmax), plus a comment recording why:

```diff
+                ;;C1 fix: keep the index with the LARGER output (argmax), not smaller (argmin) — "best"
+                ;;edge for a fixed input means most output, matching URC_Hopper's own documented intent.
                 (sp:integer
                     (fold
                         (lambda
                             (acc:integer idx:integer)
                             (if (= idx 0)
                                 acc
-                                (if (< (at idx svl) (at acc svl))
+                                (if (> (at idx svl) (at acc svl))
                                     idx
                                     acc
                                 )
                             )
                         )
                         0
                         (enumerate 0 (- (length svl) 1))
                     )
                 )
```

No interface change — `URC_BestEdge` is internal to `SwapperIssueV3`, not on its public surface.

**Verification (after the fix):** same `Z.repl` run, same `SWP|TX 016` block — unchanged, since it already
encoded the *correct* expected behavior as its `expect`. Only the comparator changed underneath it:

```
URC_BestEdge actually chose:            W|DLK|OURO|DWK   (now the BETTER pool — 18.70 output)
"Expect: success C1 reproduction — URC_BestEdge selects the higher-output edge"
```

Full `Z.repl` pipeline: exit 0, 0 `FAILURE`, `Load successful`, end to end.

**Status:** FIXED ✅ AND PROVEN ✅ — the same REPL block served first as the pre-fix reproduction
(failed exactly as predicted) and then, unmodified, as the permanent post-fix regression proof (passes
now) — same adversarial pattern as Fix #1. Awaiting Round III re-verify.

## Fix #3 — C3 (#7C): `U|SWP` round-trip rounding bias — stable pool fixed, weighted pool accepted as a known limitation

**Owner direction:** verify in REPL first; when the first fix attempt didn't work, investigate deeper
rather than re-guess; once the true root cause turned out to be a Pact-language limitation, accept and
document what genuinely can't be fixed ("we can't modify math, we gotta work with what Pact gives us"),
and confirm directly whether any of this threatens pool solvency.

**Reproduction:** `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 017`, zero-fee round
trip via `UC_ComputeY`/`UC_ComputeWP` directly against real pools (`S|DLK|OURO|DWK`, `W|DLK|OURO|DWK`).
Confirmed live: stable +6.3e-15 on a 100.0 round trip, weighted +1.8e-12 on a 9999.0 round trip (found
after several smaller amounts round-tripped exactly clean first — the reproduction size was picked because
it's what actually triggered the bias).

**First fix attempt (wrong — reported as such, not claimed a success):** moved `floor`/`ceiling` to wrap
the final answer instead of the intermediate solved-balance term (textbook AMM rounding convention). Rerun
of the identical reproduction produced **byte-for-byte identical numbers** — a no-op, because the test
tokens' precision (24) equals the internal working precision, leaving no truncation boundary at that point
to move.

**Deeper investigation — actual root cause:** a Python high-precision replica of the exact computation
showed *zero* bias, contradicting the working hypothesis (internal per-iteration `floor(...,24)`
truncation). Direct Pact instrumentation of `UC_ComputeD` diverged from the replica starting ~17
significant digits in — too large for a 24-decimal floor artifact. Isolated to Pact's `^` operator:

```
d = 2549.996147035166093620040554
(^ d 4.0)                        = 42282250700760.0859375
d*d*d*d (manual multiplication)  = 42282250700760.099021482473331191153317335329175719323256875718459007868358138754818195565982177117931551671056
```

Pact's `^` computes decimal exponentiation through IEEE-754 double precision internally — unlike `+ - * /`
on Pact decimals, which genuinely are exact. A ~0.013 absolute error on one call. This, not the floor/
ceiling placement, is the real source of the bias.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`:** added `UC_IntPow` (exact power via repeated
multiplication for non-negative integer exponents) and replaced every whole-number `^` call in `UC_DNext`
(`n^n`, `D^(n+1)`) and `UC_YNext` (`n^n`, `D^(n+1)`, `Y^2`→`Y*Y`) with it. Covers `UC_ComputeY` directly and
`UC_ComputeInverseY`/`UC_ZNext` transitively (they share `UC_ComputeD`/`UC_YNext` — confirmed by testing
the inverse direction explicitly, not assumed).

**Verification (stable pool, both directions), same `SWP|TX 017` block:**
```
STABLE          100.0 DLK -> 100.000000000000000000000000 OURO -> 100.000000000000000000000000 DLK
STABLE INVERSE  needs 100.000000000000000000000000 DLK in to get 100.000000000000000000000000 OURO out
```
Exact to 24 decimal places, zero bias, both `Expect: success`.

**Weighted pool — NOT fixed the same way, and can't be.** Its bias comes from `x^weight`, a genuine
fraction (e.g. `x^0.3`) — `UC_IntPow`'s exact-multiplication trick only applies to whole-number exponents.
Closing this fully would need a from-scratch high-precision fractional power routine in Pact (Newton's
method / power series): real numerical work, real gas cost, real risk of new bugs, for a residual assessed
as posing no meaningful risk (below). **Owner decision: decline that rewrite, accept the residual.**

**Solvency assessment (verified, not asserted):** categorically different from C2, which was a
single-swap, *unbounded* failure (output could exceed the pool's entire balance in one shot — a real
solvency threat, fixed separately in Fix #1). This residual is a *relative* float64 precision limit
(~1e-16) times the magnitude of the numbers involved — for any realistic pool, a fraction of a token, not
a fraction of the pool. The measured 1.8e-12 needed a 24-decimal-precision token to even be visible; real
tokens (6/8/12/18 decimals typical) would usually round it away entirely at settlement. No accounting
desync (the same computed value backs both the transfer and the tracked-reserve update). Repetition
economics don't favor an attacker — gas cost to harvest it would almost certainly exceed the value
harvested.

**Documentation:** added a `KNOWN, ACCEPTED LIMITATION` block comment directly above `UC_ComputeWP` in
`12_U_SWP.pact` explaining the mechanism, why the stable-pool fix doesn't transfer, and the risk
assessment. Converted the weighted-pool assertion in `SWP|TX 017` from a hard "must not profit" check
(which would now fail forever, being an accepted limitation rather than an open bug) into a **regression
bound** — passes today, but still catches a future change that grows the bias beyond generous headroom
over float64's own epsilon.

**Verification (full suite):** `pact Z.repl` — exit 0, 0 `FAILURE`, `Load successful`.

**Status:** Stable pool: FIXED ✅ AND PROVEN ✅ (both directions). Weighted pool: **ACCEPTED KNOWN
LIMITATION** — bounded, non-solvency-threatening, not fixable without disproportionate rewrite; closed as
a documented tradeoff. Awaiting Round III re-verify (stable-pool portion).

## Fix #4 — C7 (#8C): SWP `C_ModifyWeights` no length check, dead precision check, no per-weight bound

**Owner direction:** enforce a per-weight floor of at least 0.1 (no negatives), enforce precision for
real, add the length-parity check — and check `U|CT` for any additional validation logic attached to
`CT_FEE_PRECISION` before designing the fix.

**Investigated as directed:** `U|CT` (`01_U_CT.pact:48`) is a pure constants module; `CT_FEE_PRECISION`
is a bare `() 4`, nothing else bundled with it. Found the actual useful things elsewhere instead — the
**correct** version of this exact idiom already lives in the codebase (`06_U_INT.pact`'s
`UEV_UniformList` puts `enforce` *inside* the `map` lambda; `08_U_DALOS.pact`'s `UEV_Fee` does the same
for a single value) — the original bug was using `=` instead of `enforce` and discarding the result, not
a missing helper. Also found the identical discarded-map bug duplicated in `16_SWPI.pact`'s `UEV_Issue`
(pool issuance) — tracked separately as **H5**, not touched here.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>WEIGHTS`:**

```diff
                 (ref-U|CT:module{OuronetConstantsV1} U|CT)
+                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                 (pp:string (take 1 swpair))
                 (ws:decimal (fold (+) 0.0 new-weights))
-            )
+                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
+                (l0:integer (length (UR_PoolTokens swpair)))
+                (l1:integer (length new-weights))
+            )
+            (ref-U|INT::UEV_UniformList [l0 l1])
             (map
                 (lambda
                     (w:decimal)
-                    (= (floor w (ref-U|CT::CT_FEE_PRECISION)) w)
+                    (enforce
+                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
+                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
+                    )
                 )
                 new-weights
             )
```

Length-parity mirrors the sibling `SWP|S>UPDATE-SUPPLIES` cap exactly (same `UEV_UniformList` helper,
same shape). No interface change.

**Reproduction and verification — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 018 -
C7 Reproduction: Weight-Modification Guards`** (canonical suite, real pool, real owner signature):
1. **Adversarial proof of the reproduction:** `git stash`'d only `15_SWP.pact` back to pre-fix, reran
   `Z.repl` — all four attacks succeeded: length mismatch (`[0.5, 0.5]` on a 3-token pool), a below-floor
   weight (`[0.05, 0.45, 0.5]`), a negative weight (`[1.2, 0.3, -0.5]`, sums to 1.0), and an imprecise
   weight (`[0.30001, 0.5, 0.19999]`, 5 decimals) — each `FAILURE: ... expected failure, got result`.
2. Restored the fix, reran — all four now correctly abort (`Expect failure: Success: ...` for each).
3. A legitimate reweight (`[0.4, 0.4, 0.2]` — correct length, all `>= 0.1`, sums to 1.0, in-precision)
   still succeeds: `pool1 weights now: [0.4, 0.4, 0.2]`.
4. Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Not addressed:** the time-lock/gradual-weight-change mechanism for the Balancer-style instant-reweight
value-extraction angle (item 4 of the original finding) — a design decision, not a validation bug; would
force a `SwapperV3`→`V4` bump. Left for a separate decision.

**Status:** FIXED ✅ AND PROVEN ✅ — all three requested guards verified both to reject exactly what
they should and to leave legitimate operations working. `H5` (the same discarded-map bug in `UEV_Issue`)
remains open, tracked separately, not bundled into this fix. Awaiting Round III re-verify.

## Fix #5 — C8 (#9C): SWP `C_UpdateAmplifier` has zero bound-check on the new amplifier value

**Owner direction:** owner delegated the concrete floor/ceiling values — "I never knew what I should
use" — asking for an evidence-backed recommendation to implement directly, not a menu of options.

**Ceiling derived empirically:** REPL probe sweeping `A` from 1.0 to 1,000,000, on both a balanced pool
(clean throughout) and a skewed pool (`[100, 5000, 5000]`, 4000-unit trade — the harder convergence case
for the fixed 11-iteration Newton solver, ties to the separately-tracked **H1** finding):

```
A=85.0 (this codebase's own test value)  -> round-trip delta ~3.3e-13
A=1000.0                                  -> ~4.6e-8
A=5000.0                                  -> ~1.1e-7
A=100,000+                                -> ~1.4e-7 (plateaus, doesn't explode)
```

Degradation is real past the low hundreds, though bounded rather than catastrophic. **Recommendation:
floor `>= 1.0`** (matches `UEV_Issue`'s own creation-time floor, `16_SWPI.pact:1267`), **ceiling `<=
2000.0`** (covers realistic real-world stable-pool ranges with margin below the observed degradation
zone).

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>UPDATE-AMPLIFIER`:**

```diff
             (enforce (> current-amp 0.0) "Amplifier can only be updated for Stable Pools")
+            (enforce
+                (and (>= new-amplifier 1.0) (<= new-amplifier 2000.0))
+                (format "Amplifier {} must be between 1.0 and 2000.0" [new-amplifier])
+            )
```

Single range check also excludes `-1.0`/`0.0`/negatives — no separate sentinel-exclusion check needed.
No interface change.

**Reproduction and verification — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 019 -
C8 Reproduction: Amplifier-Update Guards`:**
- `new-amplifier = 0.0` confirmed succeeding pre-fix live (`FAILURE: ... expected failure, got result`).
- **Testing bug caught and fixed along the way:** chaining four `expect-failure` attempts against the
  same pool with no reset between them meant the first success (pre-fix) bricked `current-amp` to `0.0`,
  making every later case "look rejected" for the wrong reason. Further discovered this brick is
  *permanent even under pre-fix code* — no further `C_UpdateAmplifier` call can succeed once `current-amp`
  drops to `<= 0`, since that's the cap's own pre-existing check. A stronger, more permanent bricking
  scenario than the original finding described. Fixed by resetting to a known-good baseline (`85.0`)
  before each isolated case.
- Post-fix: all four bad values (`0.0`, `-1.0`, `-5.0`, `5000.0`) correctly rejected; a legitimate update
  (`150.0`) still succeeds.
- Did not chase four fully-isolated pre-fix demonstrations across separate pools — direct inspection of
  the pre-fix `enforce` shows it only ever checks `current-amp`, never `new-amplifier`, so all four bad
  values are provably the identical unconditional-accept path. One live proof plus that code read is
  sufficient evidence; further scripts would be process for its own sake.
- Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — both bound values evidence-backed (issuance precedent + REPL
convergence data), reproduction proven live, a real test-isolation bug caught and fixed along the way.
Awaiting Round III re-verify.

## Fix #6 — C9 (#10C): SWP/MTX-SWP pools issued via defpact never registered in `SWP|LP`

**Owner direction:** confirmed the root cause directly — `UR_GetLpSwpair`/`SWP|LP` was added after
`MTX-SWP`'s defpact issuance path already existed, and the follow-up wiring was never added there. Also
explained the historical reason the multi-step path exists at all (gas-limit-driven — see below) and
asked for the fix plus that context documented.

**Verified before touching anything:** `XE_AddLPTracker` appears exactly once in the codebase
(`16_SWPI.pact:1430`) and zero times in `20_MTX-SWP.pact`; confirmed `MTX|C_Issue` step 3 calls
`ref-SWP::XE_Issue` (`887`) identically to `SWPI::C_Issue` but never the tracker. Confirmed `MTX-SWP`
*does* correctly call `XE_MultiPathTracer` (routing registration) — this bug is scoped exactly to the one
missing `SWP|LP` insert.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `XE_Issue`:**

```diff
             (insert SWP|Pairs swpair
                 { ... }
             )
+            (XE_AddLPTracker token-lp swpair)
             (with-capability (P|SECURE-CALLER)
```

**`1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`, `C_Issue`:** removed the now-redundant standalone call
(would otherwise double-insert and abort on the second call):

```diff
-                    (ref-SWP::XE_AddLPTracker token-lp swpair)
                     (ref-SWPT::XE_MultiPathTracer swpair (ref-SWP::UR_Principals))
```

No interface change — `XE_Issue`'s signature is unchanged, `XE_AddLPTracker` was never on the interface
either way.

**Reproduction and verification, against a REAL pool — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-
Only.repl`, new `SWP|TX 020 - C9 Reproduction: MTX-SWP Issuance Registers SWP|LP`:** used `pool7`
(`S|BUSD|TUSD|USDT|USDC|USDD|AUSD|CUSD`), issued in this exact suite through the real `MTX-SWP` defpact
(`TX 012a/b/c`) — not a synthetic repro.
1. Surgically reverted only the one new line inside `XE_Issue` (left C7/C8's fixes in the same file
   intact, to avoid their own tests' known cascading-state behavior masking this one). Reran `Z.repl`:
   `UR_GetLpSwpair` on pool7's real LP token id threw (`evaluation of actual failed with error message`)
   — confirmed the hard-abort live, on a pool that was actually issued through the buggy path.
2. Restored the fix, reran: `Expect: success` — resolves correctly.
3. Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Documentation — the historical gas-limit context, per owner's request:** `MTX-SWP`'s whole reason to
split issuance across `defpact` steps was a historical ~150k gas-per-transaction ceiling. StoaChain's
actual live limit is ~2,000,000 gas/tx — comfortably enough for even a 7-pool-token issuance in one
transaction today. The multi-step split is no longer gas-required; it's kept for continuity (real pools
already went through it) and as a worked `defpact` example. This context is also *why* C9 happened: two
issuance paths needed the same follow-up bookkeeping step, and only one caller remembered it — exactly
the shape the fix (folding into the shared `XE_Issue`) now structurally prevents from recurring. Recorded:
- Block comment directly above `(module MTX-SWP GOV` in `20_MTX-SWP.pact`.
- Dated memory note:
  `OuronetInformational/memories/2026-08-17-mtx-swp-multi-step-no-longer-gas-required.md`, with the
  generalized durable rule (fold shared follow-up steps into the shared function, don't leave them as
  separately-remembered standalone calls).

**Status:** FIXED ✅ AND PROVEN ✅ — reproduced against a real, live-issued pool rather than a synthetic
case, adversarially proven, historical context captured for future sessions. Awaiting Round III re-verify.

## Fix #7 — H12: SWP `SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values with zero enforcement

**Owner direction:** harden defensively regardless of current reachability — "just in case."

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>UPDATE-SUPPLIES`:**

```diff
             (map
                 (lambda
                     (idx:integer)
-                    (if (> (at idx new-supplies) 0.0)
-                        (ref-DPTF::UEV_Amount (at idx pool-tokens) (at idx new-supplies))
-                        true
-                    )
+                    (let
+                        (
+                            (val:decimal (at idx new-supplies))
+                        )
+                        (enforce
+                            (>= val 0.0)
+                            (format "New supply {} for pool token {} cannot be negative" [val (at idx pool-tokens)])
+                        )
+                        (if (> val 0.0)
+                            (ref-DPTF::UEV_Amount (at idx pool-tokens) val)
+                            true
+                        )
+                    )
                 )
                 (enumerate 0 (- l0 1))
             )
```

The old code only validated a new supply when it was already `> 0.0`; for `<= 0.0` it silently returned
`true`, no check at all. Real `enforce` now runs unconditionally inside the lambda, matching the working
`UEV_UniformList`/C7 idiom. No interface change.

**Attempted a live adversarial reproduction — hit a real wall, which is itself useful evidence:** tried
calling `XE_UpdateSupplies` directly from REPL top-level code with a genuinely negative delta.
- First failed for an unrelated reason: `"None of the guards passed"` from `UEV_IMC`. Traced to
  `XE_UpdateSupplies`'s IMC policy check, which requires one of a fixed list of peer-module capabilities
  (`SWP.SECURE`, `SWPI/SWPL/SWPLC/SWPU/MTX-SWP`'s own `P|*|CALLER` caps, Talos's `P|TS`/`P|TALOS-SUMMONER`)
  already be in scope — confirmed by reading `SWP::P|UR_IMP`'s live contents directly.
- Tried acquiring `SWP.SECURE` and `SWP.GOV` directly with the admin keyset used throughout this REPL
  suite: both hit `"Module admin necessary for operation but has not been acquired: ouronet-ns.SWP"` —
  same Pact 5 foreign-module-admin rule already confirmed for C13/H9. `SECURE` is `(defcap SECURE ()
  true)` — identical shape to C13's `P|SWPLC|CALLER`, equally unforgeable from outside the module.
- **Conclusion:** there is genuinely no way to reach `XE_UpdateSupplies` from outside the trusted
  peer-module graph — every real caller (`SWPU`, `SWPL`, `SWPLC`) reaches it from *inside* an already-
  granted peer capability. Stronger evidence for "not reachable today" than the original finding's own
  `PLAUSIBLE reachability` framing — actively tried to break in from outside and hit a confirmed wall.
- **Connection to C2:** the one plausible legitimate route that could have driven a negative
  `new-supplies[idx]` was an oversized swap whose output exceeded the pool's reserve — exactly C2's bug
  (Fix #1, already landed). Fixing C2 already incidentally closed off the main practical route into H12;
  this fix closes what was already a secondary layer.

**Verification (regression, not adversarial — adversarial isn't constructible here, as established
above):**
1. Default suite (`Z.repl`, issuance-only): exit 0, 0 `FAILURE`, `Load successful`.
2. Full `[6.2]_DPTF.repl` + `[6.3]_SWP.repl` suite (real swap execution, real `XE_UpdateSupplies` calls
   through the legitimate `SWPU` path, always-positive values since C2 is fixed): exit 0, 0 `FAILURE`,
   `Load successful`. Suite toggle reverted afterward (diff confirmed clean).

**Status:** FIXED — code-level correctness verified by direct review (matches the proven C7 idiom) and
full-suite regression (no legitimate call path broke). No permanent adversarial REPL test added, since
external reproduction against this defcap isn't constructible from outside the trusted peer-module
graph — attempted and confirmed blocked, not simply not attempted.

## Fix #8 — H11: SWPLC `can-add` gates both deposits and removals

**Owner direction:** the combined switch was originally intentional; owner asked for industry-practice
research before deciding whether to keep it that way.

**Research (see full findings in `ROUND-01-OWNER-FEEDBACK.md`):** Curve's `kill_me` structurally exempts
plain `remove_liquidity` from its kill switch; Balancer's Recovery Mode exit becomes permissionless
specifically while paused, "so that funds can never be locked by governance action"; security-audit firms
(Trail of Bits, ConsenSys Diligence) treat blockable user exits as a trust anti-pattern, with real
incidents (Multichain, Solend) showing reputational cost. **Owner's decision:** `can-add` may pause new
deposits, but must never block existing LPs from getting their own principal back.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact`, `UEV_RemoveLiquidity`:**

```diff
         (let
             (
                 (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                 (ref-SWP:module{SwapperV3} SWP)
                 ;;
-                (can-add:bool (ref-SWP::UR_CanAdd swpair))
                 (lp-id:string (ref-SWP::UR_TokenLP swpair))
                 (pool-lp-amount:decimal (ref-DPTF::UR_Supply lp-id))
             )
             (ref-DPTF::UEV_Amount lp-id lp-amount)
             (enforce (<= lp-amount pool-lp-amount) (format "{} is an invalid LP Amount for removing Liquidity" [lp-amount]))
-            (enforce can-add (format "Liquidity Adding and Removal isn't enabled on pool {}" [swpair]))
         )
```

Removal now depends only on genuine validity checks (amount format, not exceeding actual outstanding
supply) — matches Curve's structural-exemption model, not a conditional policy check. No interface
change — `UEV_RemoveLiquidity`'s signature is unchanged.

**Reproduction and verification, against the real production call chain — `REPL/Stage_01/[6.2+3]_DPTF-
SWP_Issuance-Only.repl`, new `SWP|TX 022 - H11 Reproduction: can-add Never Blocks Removal`:** real pool
(`W|DLK|OURO|DWK`), real Talos entrypoints, real 10,000,000.0 LP genesis balance.
1. **Adversarial proof:** reverted only the `can-add` check, reran `Z.repl` — the real
   `TS01-C3::SWP|C_RemoveLiquidity` call for patron's own legitimately-owned 100,000 LP threw the exact
   old error (`"Liquidity Adding and Removal isn't enabled on pool ..."`), from the real call chain, not
   a synthetic repro.
2. Restored the fix, reran: new deposits still correctly blocked by `can-add=false`; the *same* removal
   that failed above now succeeds — patron's LP goes `10000000.0` → `9900000.0` live, through the real
   call chain. Toggle restored to `true` afterward.
3. Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — verified against real production entrypoints and a real LP balance;
both halves (still-blocks-deposits, no-longer-blocks-removal) confirmed live, pre- and post-fix. Awaiting
Round III re-verify.

## Fix #9 — H6: SWP `A_DefinePrimordialPool` reads `primality` but never enforces it

**Owner direction:** clarified what `primality` actually means (issuance-time-permanent exemption from
low-liquidity gates / never-autonomously-disabled) and two structural facts (no duplicate-token-set pool
issuance; non-OURO/non-LKDA issuance requires genuine token ownership) that lower the practical risk —
still worth fixing. Directed: add the boolean to the enforce fold.

**Verified before fixing:** `primality` has zero other read sites anywhere in the codebase besides this
cap and the issuance-time write — the owner's described semantics are the intended meaning, not something
else currently cross-checks. Confirmed the REPL fixture's own primordial pool was genuinely issued with
`p=true`, so the fix wouldn't break existing designation.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|C>DEFINE-PRIMORDIAL-POOL`:**

```diff
-            (enforce (fold (and) true [iz-weigthed has-ouro has-wkda has-lkda iz-three]) "Pool is not the primordial pool")
+            (enforce (fold (and) true [iz-weigthed has-ouro has-wkda has-lkda iz-three primality]) "Pool is not the primordial pool")
```

One boolean added to an already-existing fold, matching the pattern already used correctly in the same
cap. No interface change.

**Attempted a live adversarial reproduction — found structurally impossible, which is itself useful
evidence:** tried issuing a "lookalike" pool (same OURO/WKDA/LKDA tokens, different order, `p=false`) to
prove the pre-fix hole live. Hit `"Pool already exists for given Tokens!"` from `SWP::UEV_New`/
`UEV_CheckAgainstMass` (`15_SWP.pact:1058-1122`) — traced it: token-**set** comparison via `contains`-
based membership (`UEV_CheckAgainst`), completely order-independent. Once the real 3-token pool exists,
no second pool sharing that token set can ever be issued, in any order, with any weights. Confirms the
owner's risk assessment with a concrete mechanism: the only theoretical exposure was a one-time
bootstrap-race window (front-running the very first OURO|WKDA|LKDA issuance), already closed on mainnet
since the real pool was issued first.

**Verification — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 023 - H6 Reproduction:
Primality Gate on Primordial-Pool Designation`:** regression-only, since adversarial reproduction against
the current populated state is structurally impossible (established above) — confirmed the real,
`primality=true` pool can still be (re-)designated with the check in place. Full `Z.repl`: exit 0, 0
`FAILURE`, `Load successful`.

**Status:** FIXED — one-line fix, code-level correctness plus regression confirmed. Full adversarial
reproduction isn't constructible (mass-uniqueness prevents the prerequisite state from ever existing) —
same honest-about-the-limit pattern as H12/Fix #7; the attempt itself surfaced and documented a real
structural guarantee (`UEV_CheckAgainstMass`) worth having on record. Awaiting Round III re-verify.

---

## Fix #10 — C6 (#13C) + H4 (#19H) + H2 (#20H): SWPT routing-graph node/edge-envelope mismatch, disabled pools never filtered, and the resulting "no path" crash

**Owner direction:** filter routing to `can-swap=true` pools only, up front, in a single BFS pass — no
artificial max-hop constant (principal-anchoring already provides a real, natural bound) and no bounded
retry loop (Pact is Turing-incomplete; "how many retries is enough" isn't a knowable number). Presented
and fixed together because C6 and H4 live in the same call chain and neither fix is complete without the
other; H2 was pulled forward and fixed alongside them (flagged explicitly, not silently bundled) because
the C6/H4 fix makes "no active path exists" a normal outcome for the first time, and leaving `(at 0 fp)`
bare would have just traded one crash for another.

**Root cause, precisely:** `SWPI::URC_Hopper` fed `SWPT::URC_ComputeGraphPath` the *entire, unfiltered*
swpair list (H4). `U|SWP::UC_MakeGraphNodes` then narrowed that to only swpairs directly touching
input/output (≤1 hop from either end) to build BFS `nodes` — but `SWPT::URC_TokenNeighbours`/
`URC_TokenSwpairs` (which build each node's *links*) read the **live, unrestricted `SWPT|Tracer` table
directly**, with no notion of any caller-supplied swpair universe at all (C6). Node envelope narrower
than the live edge-set → BFS could expand into a token with no matching `GraphNode` entry → the fold
spliced the literal `"BAR"` sentinel into the chain instead of terminating. Separately, nothing anywhere
in the routing path ever excluded a `can-swap=false` pool from being chosen (H4) — the only place
`can-swap` was checked was deep in `SWPU|X>SMART-SWAP`'s defcap, *after* BFS had already committed, with
no fallback. And `URC_ComputeGraphPath`'s `(at 0 fp)` bare-crashed on genuinely-empty results instead of
returning the documented `[BAR]` sentinel (H2).

**Fix required two build-and-test iterations to get right — both caught by testing, not predicted in
advance:**

**Iteration 1 (incomplete, caught by full-suite regression):** filtered `swpairs` at the top of the call
chain only. Compiled clean, passed the existing test suite — then crashed a *real* issuance transaction
(`Array index out of bounds` in `UC_PoolTokensFromPairs`) the moment the full pipeline ran, because
`SWPI::URC_WorthDWK`/`UEV_Issue`'s internal DLK-connectivity pricing calls share `URC_Hopper` with real
swap execution, and those internal calls legitimately need the *full* pool universe (pools may not be
swap-enabled yet at issuance time) — filtering them starved issuance-time pricing of any route at all.

**Iteration 2 (incomplete, caught by a purpose-built adversarial scenario):** split `URC_Hopper` (kept
unfiltered, used internally) from a new `URC_HopperActive` (active-only, used by real execution) via a
shared internal core `URCX_Hopper`. This alone fixed C6's *node*-envelope mismatch and closed H4 for the
"only-a-disabled-pool-exists" case — but a disabled pool running *parallel* to an active route (a second
pool between the same token pair) still got selected, because `URC_MakeGraph`'s link filter only checked
"is this neighbor token a valid node somewhere" (true — it has other active pools), not "does an active
edge exist between *this specific pair*." Crashed `URCX_BestEdgeOf` with an empty edge list.

**Final fix — five files:**

1. **`1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`, `UC_MakeGraphNodes`:** dropped the ≤1-hop filter;
   nodes now built from every token across the *entire* passed-down `swpairs` list (whatever universe the
   caller specifies). `input-id`/`output-id` stay in the signature, unused — zero interface impact.
2. **`1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`:**
   - New `URC_EdgesActive(t1, t2, principal-lst, whitelist)` — `URC_Edges` filtered to swpairs also
     present in `whitelist`. Additive to `SwapTracerV1`.
   - `URC_MakeGraph`'s link computation now requires `URC_EdgesActive(node, neighbor, …) != []` — a
     genuine active edge — instead of just `contains neighbor nodes`. Subsumes the membership check (a
     real edge implies both endpoints are valid nodes) and closes C6 and H4 with one condition.
   - `URC_ComputeGraphPath`: `(at 0 fp)` → `(if (> (length fp) 0) (at 0 fp) [BAR])` (H2).
3. **`1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** new `URC_ActiveSwpairs()` — `URC_Swpairs()` filtered to
   `can-swap=true`. Additive to `SwapperV3`.
4. **`1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`:**
   - `URC_Hopper`'s body extracted into internal `URCX_Hopper(…, swpairs)`, taking the swpair universe as
     a parameter instead of fetching it internally.
   - `URC_Hopper` (unchanged signature) now a thin wrapper: `URCX_Hopper(…, SWP::URC_Swpairs())` — full
     universe, used internally for issuance-time pricing.
   - New `URC_HopperActive` — `URCX_Hopper(…, SWP::URC_ActiveSwpairs())` — active-only, additive to
     `SwapperIssueV3`.
   - `URC_BestEdge`'s selection core extracted into internal `URCX_BestEdgeOf(ia, i, o, edges)`.
     `URC_BestEdge` (unchanged) wraps it with `SWPT::URC_Edges`; new `URC_BestEdgeFiltered(ia, i, o,
     swpairs)` (additive) wraps it with `SWPT::URC_EdgesActive`.
   - `URCX_Hopper`'s fold now calls `URC_BestEdgeFiltered(…, swpairs)` — same `swpairs` the whole call is
     scoped to, so `URC_Hopper`'s full-universe callers get a no-op filter and `URC_HopperActive`'s callers
     get real exclusion.
5. **`1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`:** all four real routing call sites
   (`SWPU|X>SMART-SWAP`, `UDC_SpawnSmartSwapSlippageBounds`, `XI_SmartSwapRouter`, `XI_Pumpdate`) switched
   from `ref-SWPI::URC_Hopper` to `ref-SWPI::URC_HopperActive`.

**Interface implication:** three additive members (`SwapperV3.URC_ActiveSwpairs`, `SwapTracerV1.URC_EdgesActive`,
`SwapperIssueV3.URC_HopperActive`/`URC_BestEdgeFiltered`) — no existing signature changed, no bump forced.

**Adversarially proven, live, one finding at a time — new fixture in `[6.2+3]_DPTF-SWP_Issuance-Only.repl`
(`SWP|TX 024a-029`):** built a genuine 4-hop chain (`S|OURO|AG|AL|AU|BI|CO`, previously-unpooled tokens,
touches no existing test state) plus a parallel 1-hop shortcut (`S|AG|CO`).

- **C6/#13C** (`SWP|TX 026`): temporarily reverted only `UC_MakeGraphNodes` to the old ≤1-hop filter.
  Even pool *issuance* broke (`No connection to DLK detected for AU-98c486052a51` — 3 hops deep).
  Restored: `URC_HopperActive(AG, CO, …)` finds the full 5-node chain intact, 4 real edges, no `BAR`.
- **H4/#19H** (`SWP|TX 028`): with the shortcut active then disabled, temporarily reverted
  `URC_HopperActive` to route over the unfiltered full swpair set. Routing **still picked the disabled
  shortcut** (`edges: ["S|AG-98c486052a51|CO-98c486052a51"]`) — reproduced against real pool state.
  Restored: routing correctly falls back to the active 4-hop chain; the disabled pool never appears.
- **H2/#20H** (`SWP|TX 029`): first repro attempt (isolate `AG` entirely) was wrong — hits the pre-existing
  `all-paths == [[BAR]]` short-circuit before ever reaching `(at 0 fp)`, so reverting the guard didn't
  crash; caught this by testing, not by reasoning it out. Corrected: kept `AG` connected to the wider
  live graph via `OURO` (so BFS finds real chains) while disabling every route to `CO` specifically.
  Reverted the guard: `Array index out of bounds. Length (0), Index (0)` at `(at 0 fp)`, exactly as
  predicted. Restored: clean `nodes: []`, no crash.

Each revert was isolated to exactly the one function under test; everything else stayed at its fixed
state throughout. Full `Z.repl`-equivalent regression (`REPL/_swp_fix_check.repl`, a scratch harness built
to route around unrelated, pre-existing breakage from concurrent ATS/AQP work in this shared working
tree — confirmed via `git stash` on a clean checkout before touching anything): exit 0, 0 `FAILURE`,
`Load successful`, re-run clean after every restore.

**Status:** FIXED ✅ AND PROVEN ✅ (all three findings, each independently adversarially reproduced
pre-fix and reconfirmed post-fix). Awaiting Round III re-verify.

---

## Fix #11 — C4 (#11C): `UEV_Issue` never validates individual pool weights are non-zero

**Owner direction:** floor at 0.1, matching the bound already decided for `SWP|S>WEIGHTS` (C7/#8C).

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`, `UEV_Issue`:**
```diff
-            (map
-                (lambda
-                    (w:decimal)
-                    (= (floor w fee-precision) w)
-                )
-                weights
-            )
+            (map
+                (lambda
+                    (w:decimal)
+                    (enforce
+                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
+                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
+                    )
+                )
+                weights
+            )
```
The precision check already existed but was computed and discarded (dead validation, same pattern as
H5/#23H — fixing this map in place closes both, it's the one place the check lives). No interface change.

**Adversarially proven, live — new `SWP|TX 030` in `[6.2+3]_DPTF-SWP_Issuance-Only.repl`.** Attempted
issuing `W|OURO|CU|RU` (previously unpooled tokens) with `[0.9, 0.1, 0.0]` and `[0.85, 0.1, 0.05]`.
Temporarily reverted only this map to the original dead-validation form, reran:
- `0.0` weight still failed even reverted (a real division-by-zero elsewhere already catches the literal-
  zero case, just with no clean error).
- `0.05` weight — below the floor, not literally zero — **succeeded and issued a real, live,
  badly-conditioned pool.** This is the sharper part of the bug: it never crashes, it just silently exists
  in an exploitable state, with the original finding's "div-by-zero" framing only covering the exact-zero
  half of it.

Restored the fix: both bad-weight attempts correctly rejected; a legitimate `[0.5, 0.3, 0.2]` issuance
still succeeds end-to-end (real pool + LP token minted). Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — also closes H5/#23H's duplicate instance in this same function.
Awaiting Round III re-verify.

---

## Fix #12 — H3 (#21H): SWPT redesigned as a principal-agnostic adjacency graph (SwapTracerV1 → V2)

**Owner direction:** principals should be replace-only (never bare-removed), capped at 7. Working
through what "replace" actually requires led to the real fix: principal-based partitioning of the
Tracer served no remaining purpose once routing already operates over the full swpair universe
(post-#13C/#19H) — it only added fragility (retiring principal's entries orphan on removal *or*
replace) and real scaling cost (every read concatenates+dedupes every principal bucket). Full redesign,
not a patch.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`, complete rewrite of the schema/table/functions
section (governance/policy blocks unchanged):**
- `SwapTracerV1` → `SwapTracerV2`. `Edges{principal, swpairs}` / `SWPT|Tracer` removed entirely.
  New `NeighbourEdge{token, swpairs}` / `SWPT|Graph` — plain token adjacency, no principal anywhere.
- `URC_TokenNeighbours`, `URC_Edges`, `URC_EdgesActive`, `URC_ComputeGraphPath`, `URC_AllGraphPaths`,
  `URC_MakeGraph` all drop their `principal-lst` parameter — real interface simplification.
- `URC_MakeGraph`'s #13C/#19H active-edge-filter logic and `URC_ComputeGraphPath`'s #20H empty-result
  guard carry over structurally unchanged — only the underlying neighbour/edge lookup changed.
- New `XE_UpdateGraph(swpair)` (replaces `XE_MultiPathTracer`): for every ordered pair of tokens in
  the swpair, idempotently appends the swpair to each token's neighbour entry for the other.
- New internal `XI_UpdateGraphForSwpair`/`XI_UpdatePair`, `UC_FindNeighbourIndex` helper.

**`1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`:** `URCX_Hopper`, `URC_BestEdge`, `URC_BestEdgeFiltered`,
`C_Issue` updated to the simplified `SwapTracerV2` calls (drop principal fetching/threading). New
`A_RebuildGraph()` — one-time migration/backfill utility, walks `SWP::URC_Swpairs()` and calls
`XE_UpdateGraph` for every existing pool, exactly mirroring what normal issuance already does. Deliberately
placed here rather than in `SWPT` — `SWPT` deploys before `SWP` and can't hold a compile-time reference to
`SwapperV3` (a real load failure caught this, not anticipated); `SWPI` already deploys after both. Wrapped
in `(with-capability (P|SECURE-CALLER))` — a second real issue caught by testing: `XE_UpdateGraph`'s
`UEV_IMC` check verifies the specific `P|SWPI|CALLER` capability is actively composed, not merely that the
call originates from SWPI's module code; `C_Issue` satisfies it via its own cap chain, a bare
`GOV|SWPI_ADMIN`-gated function does not.

**`1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact`:** Step 3 updated to the simplified `XE_UpdateGraph` call.

**Interface implication:** `SwapTracerV1` → `SwapTracerV2`, a real breaking signature change — but
verified via full grep before starting that no other module's *interface* references `SwapTracerV1`
(only internal `16_SWPI.pact`/`20_MTX-SWP.pact` function bodies do) — so `SwapperIssueV3` and
`SwapperMtxV3` needed **zero** interface changes, only module-body updates.

**Adversarially proven, live:**
- Every prior #13C/#19H/#20H/#11C adversarial proof (`SWP|TX 026/028/029/030`) re-run against the full
  redesign — byte-identical results to before the storage change.
- New `SWP|TX 031`: ran `SWPI::A_RebuildGraph` against already-current state; confirmed a genuinely
  non-empty real route (`OURO→AG`) is byte-identical before and after — proving the migration is safe
  to re-run without duplicating or corrupting anything.
- Full suite: exit 0, 0 `FAILURE`, `Load successful`, re-run clean after both fixes discovered mid-build
  (the deploy-order failure, and the `UEV_IMC` capability-scope failure).

**Status:** FIXED ✅ AND PROVEN ✅. The owner's separate "replace-only, capped at 7" policy layer on
`SWP::A_UpdatePrincipal` is not yet built — no longer required to close #21H (orphaning is now
structurally impossible regardless of remove vs. replace), but still wanted for operational discipline.
Awaiting Round III re-verify.

---

## Fix #13 — H3/#21H follow-up: cap principals at 7, add `A_RotatePrincipal`

**Owner direction:** cap at 7 (mirrors `UEV_Issue`'s existing 2–7 pool-token bound); standalone removal
stays permanently disabled; add an atomic rotate as the only way to retire a principal.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:**
- `SWP|C>PRINCIPAL`: added the 7-cap enforce on the add path, plus a not-already-present guard
  (`A_UpdatePrincipal` previously had no duplicate-add protection at all — closed as in-scope hardening).
- `A_UpdatePrincipal`: dead remove-branch code removed (unreachable since the defcap already
  unconditionally rejects `add-or-remove=false`).
- New `SWP|C>ROTATE-PRINCIPAL` + `A_RotatePrincipal(old, new)`: atomic, count-preserving replacement.
  Both additive to `SwapperV3` — no version bump.
- `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`: new `SWP|A_RotatePrincipal` Talos wrapper, additive to
  `TalosStageOne_AdminV1`.

**Adversarially proven, live — `SWP|TX 032-035`:** cap and standalone-removal guards reverted (whole
guard block removed) and reconfirmed both unexpectedly succeed pre-fix — an 8th principal added, a
standalone removal completed — restored, reconfirmed both correctly rejected. Rotate's three rejection
cases proven (non-principal, already-existing target, self-rotation). End-to-end proof: issued a real
pool (`P|HG|TE`) anchored to a freshly-added principal, confirmed a genuinely non-empty route, rotated
`HG → TI`, confirmed the identical route survives byte-for-byte — proving #21H's principal-agnostic
storage makes rotation harmless in practice, not just on paper. Confirmed a new pool can no longer anchor
to the retired principal but can anchor to the new one. Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #14 — H3/#21H second follow-up: re-allow removal with a 2-minimum floor, split rotate-into-self

**Owner refinement:** rotate-into-self needs its own distinct enforce (not bundled), gated by the same
admin capability as `A_UpdatePrincipal` (already true — verified, not assumed). Standalone removal
should be re-allowed (safe now, post-#21H storage redesign) but never below 2 principals defined.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:**
- `SWP|C>ROTATE-PRINCIPAL`: split the combined `fold (and) [...]` into two separate enforces — this
  also fixes a convention violation (2 conditions should be `(enforce (and p q) msg)`, not `fold`).
- `SWP|C>PRINCIPAL`: removal re-enabled, `(enforce (> current-count 2) ...)` on the remove path.
  `(let () ...)` (empty bindings, for sequencing two enforces per `if` branch) isn't valid in this
  parser — used `(and (enforce ...) (enforce ...))` instead.
- `A_UpdatePrincipal`: removal write-logic restored (deleted as dead code in Fix #12, live again now
  that the defcap conditionally allows it).
- `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`: docstrings corrected.

**Adversarially proven, live — `SWP|TX 033` rewritten:** drained 5 disposable test principals (7 → 2,
never touching the 2 genesis principals other tests need), proving removal works; removing `OURO` at
count=2 correctly rejected; restored to 7. Floor guard reverted (`> 0`) and reconfirmed the same removal
unexpectedly succeeds pre-fix; restored, reconfirmed rejected. Full suite: exit 0, 0 `FAILURE`,
`Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #15 — H1 (#24H): `UC_ComputeD`/`UC_ComputeY`/`UC_ComputeInverseY` iteration count bumped to 12

**Owner direction:** measure first, don't trust the audit doc's number or memory of prior testing.
Measured `UC_ComputeD` (6 iter, as coded) against manual references at 10/20/50/100/255 iterations, at
the finding's own skew (`X=[500000,500,500]`, `A=85`): confirmed exactly — `0.0078` absolute error at 6
iterations, fully converged (bit-identical) by iteration 10. Same check on `UC_ComputeY`/
`UC_ComputeInverseY` (11 iter): already fully converged at 11 — no shortfall found there.

A "convergence-break" (early-exit once `|Dₙ₊₁-Dₙ| ≤ epsilon`) was proposed and correctly rejected —
Pact has no dynamic-length loop; every iteration count must be fixed in advance. Owner direction instead:
bump all three to 12 uniformly (2 iterations of margin past `UC_ComputeD`'s measured convergence point;
pure margin for the other two), after confirming gas cost.

**Gas measured directly (`env-gas`, isolated per function), not estimated:**
- `UC_ComputeD`: 58 → 116 gas (+58, iterations roughly doubled 6→12).
- `UC_ComputeY`'s fold: 73 → 79 gas (+6, one extra iteration).
- `UC_ComputeInverseY`'s fold: → 82 gas (+6, same shape).
- Total added cost per stable swap: **flat +64 gas** (one `UC_ComputeD` call + one `UC_ComputeY`/
  `UC_ComputeInverseY` call), fixed regardless of pool state.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`:**
```diff
 UC_ComputeD:       (enumerate 0 5)  -> (enumerate 0 11)  ;; 6 -> 12 iterations
 UC_ComputeY:        (enumerate 0 10) -> (enumerate 0 11)  ;; 11 -> 12 iterations
 UC_ComputeInverseY: (enumerate 0 10) -> (enumerate 0 11)  ;; 11 -> 12 iterations
```
`UC_ComputeD`'s docstring corrected — previously claimed "5 fixed iterations" while the code ran 6 (a
pre-existing doc/code mismatch); now documents 12, the measured convergence point, and explains why no
adaptive/dynamic loop is possible in Pact.

**Adversarially proven, live — new `SWP|TX 036` in `[6.2+3]_DPTF-SWP_Issuance-Only.repl`:** asserts
`UC_ComputeD` at the exact skew that exposed the gap matches a 100-iteration reference exactly (`abs
difference = 0.0`). Reverted `UC_ComputeD` alone back to 6 iterations and reconfirmed the identical
`0.0078` gap reproduces to the last digit (`0.007789943067608829898242`); restored, reconfirmed exact
convergence. Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #16 — M9 (#26M): slippage upper bound commented out (not deleted), floor-only for exact-input swaps

**Owner direction:** wanted to confirm industry standard before deciding. Researched 5 protocols in
parallel (Uniswap V2/V3, Curve, Balancer, SushiSwap, PancakeSwap) plus a precedent search — zero
counter-examples anywhere for a symmetric bound on exact-input swaps; every one is floor-only, and
"positive slippage" (beating the quote) is industry-treated as value to capture, never grounds to revert.
Direction: comment out the max check, don't delete it, be careful not to disturb the floor.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`, both consumers of `UC_SlippageMinMax`** (confirmed
via full-codebase grep these are the only two — `UC_SlippageMinMax` itself untouched):
- `XI_SmartSwapRouter`: `(and (>= feeless-final min) (<= feeless-final max))` → `(<= feeless-final max)`
  commented out with the industry-research rationale and exact restore instructions.
- `XI|KDA-PID_Swap`: same shape, `max-toa` in place of `feeless-final`.

**Real Pact 5 bug caught by testing with actual swap execution, not just load:** first attempt kept the
`and` wrapper around the single remaining condition — `(and (>= feeless-final min))` parses and loads
fine, but fails at runtime ("Expected Pact Value, got closure or table reference") the instant a real swap
executes through it. Only surfaced by running the full `Z.repl` pipeline (Stage 1 + Stage 2) for real swap
execution — the issuance-only suite never exercises this code path at all. Fixed by dropping the
now-redundant `and` entirely; a single condition is a plain `if`, matching this codebase's own convention.

**Adversarially proven, live — new `SWP|TX 037`, run against the full `Z.repl` pipeline:** constructed a
slippage object with `expected-output-amount` deliberately understated to 80% of the real swap output and
a tight 1% tolerance, guaranteeing the real output clears the floor but blows through the old ceiling.
Post-fix: swap succeeds (`38.89` output vs. the old `~32.19` ceiling). Reverted the `XI|KDA-PID_Swap` site
and reconfirmed the exact pre-fix rejection (`"...out of Slippage bounds min of 31.55 - max of
32.19..."`, matching the real `39.84` output exceeding that max); restored, reconfirmed success. Full
`Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #17 — M13 (#27M): SmartSwap post-swap pool-refresh set now uses the swap's own traversed edges

**Owner direction:** demonstrate Option B specifically — force the old code to visibly pick the wrong
pool, then prove the new code picks correctly in the identical scenario, rather than relying on the
correctness-by-construction argument alone. Suggested issuing new pools with engineered amounts to make
the scenario deterministic.

**Fix — `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact`, both Smart Swap functions:**
- `SWP|C_SmartSwapNoSlippage`: deleted the post-swap `path-edges`/`URC_Hopper` recompute; its refresh
  loop now iterates `(at 3 out)` — the swap's own recorded `distinct-edges` — matching
  `SmartSwapWithSlippage`'s already-correct pattern.
- `SWP|C_SmartSwapWithSlippage`: deleted the same `path-edges`/`URC_Hopper` binding, confirmed dead
  (its loop already used `(at 3 out)`) — pure gas cleanup, zero behavior change.

**Adversarially proven, live — new `SWP|TX 016b`-`016g` in `[6.3]_SWP.repl`:** issued two brand-new,
fully isolated parallel pools — `P|OURO|TSTY` (constant-product, 1000/2000 reserves) and `W|OURO|TSTY`
(equal-weighted `[0.5 0.5]`, mathematically identical math, 1000/1500 reserves) — sized so a 1500-OURO
swap deterministically flips BFS's best-edge pick: `P` wins pre-swap (feeless 1200 vs 900), but the
swap's own price impact drops `P` below `Q` for the identical amount post-swap (300 vs 900).

Reverted the fix (temporarily, in-place): real swap executed through `P|OURO|TSTY` (1500 OURO → 1193.59
TSTY), but the old code's post-swap recompute picked `W|OURO|TSTY` instead — reproduced exactly:
`P|OURO|TSTY`'s cached StoaValue stayed stale at `0.0` (the actually-swapped pool never refreshed) while
`W|OURO|TSTY`'s cache was spuriously bumped to `2544.17...` despite never being touched.

Restored the fix: `P|OURO|TSTY`'s cache correctly became `5130.80...` (exact match to a fresh recompute);
`W|OURO|TSTY`'s cache correctly stayed at `0.0`. Five `expect` assertions pin this down (swap actually
executed; actually-swapped pool's cache matches fresh; that cache genuinely moved, not a vacuous pass;
untouched pool's cache stays put; that pool's true value is genuinely nonzero) — all 5 pass. Full
`[6.2]`/`[6.3]` suite (real execution path): exit 0, 0 `FAILURE`. Default issuance-only regression: exit
0, 0 `FAILURE` (zero interference — new transactions live only in the full-suite file). Full `Z.repl`
(Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #18 — M7 (#31M): `C_EnableFrozenLP`/`C_EnableSleepingLP` now require pool-owner authorization

**Owner direction:** Sleeping/Frozen LP must only be triggerable by the pool owner, and it's irreversible
by design — if the code didn't enforce owner-only, it needs to be fixed.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** added `(CAP_Owner swpair)` to both
`SWP|C>ENABLE-FROZEN` and `SWP|C>ENABLE-SLEEPING`, matching the module's own established pattern for
every other per-pool admin lever (`SWP|S>RT_OWN`, `SWP|S>RT_CAN-CHANGE`). Confirmed the irreversibility
half was already correct (no code path ever writes either flag back to `false`) — only the
authorization gate was missing.

**Adversarially proven, live — new `SWP|TX 032a`/`032b` in `[6.3]_SWP.repl`:** a non-owner signer
(`KST.EMMA`) attempting `SWP|C_EnableFrozenLP`/`SWP|C_EnableSleepingLP` on a pool owned by `KST.ANHD` is
rejected, and — the decisive check — the flags genuinely stay `false` (no partial mutation). The true
owner's identical calls succeed. Reverted the fix in-place: the flags flip to `true` even under the
non-owner signer, reproducing the exact vulnerability (`XI_Enable*` writes unconditionally before any
other check). Restored, reconfirmed clean. Full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only
regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #19 — M2 (#34M): Smart Swap now compares up to 3 candidate routes by actual payout, not just discovery order

**Owner direction:** was sure a cheapest-route mechanism existed; once shown precisely that it only
covers picking the best pool *within* a hop, not comparing whole routes, asked for a fix proven in REPL.

**Fix:**
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` — new `URC_ComputeAlternateRoutes` (additive to
  `SwapTracerV2`): finds up to 3 edge-disjoint candidate routes by re-running `URC_ComputeGraphPath` with
  each previously-found route's edges excluded, forcing genuinely different routes. Fixed cap of 3 (Pact
  has no dynamic-length/convergence loops). New helpers `URC_RouteEdges`/`UC_ExcludeEdges` support it.
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` — `URCX_Hopper` split into `URCX_HopperForNodes` (the
  existing per-hop best-edge computation, now taking an already-known node path) and a new outer
  `URCX_Hopper` that computes every candidate route's Hopper object and picks the highest-output one via
  new `UC_BestHopper`. `URC_Hopper`/`URC_HopperActive`'s public signatures unchanged.
- Defensive guard added in `URC_ComputeAlternateRoutes`: an exhausted (empty) candidate universe
  short-circuits to `[BAR]` instead of calling `URC_ComputeGraphPath`, whose downstream graph-building
  crashes on an empty list (M3, a separate tracked finding) rather than returning cleanly — this fix's own
  exclusion-based retries are the first caller able to legitimately produce that empty-universe case.

**Adversarially proven, live — new `SWP|TX 032c`-`032g` in `[6.3]_SWP.repl`:** diamond topology
`OURO -> {TSTC, TSTD} -> TSTZ`, TSTC-side issued first (worse route, discovered first by BFS): thin
second hop `TSTC/TSTZ` (2000/2000) vs. deep second hop `TSTD/TSTZ` (200000/200000). A 10,000-OURO swap
delivers **4906.02 TSTZ** with the fix in place. Reverted the fix (single-first-found-route restored):
the identical swap delivers only **1989.96 TSTZ** — a genuine ~2.5x worse outcome, confirming the old code
takes the bad route. Restored, reconfirmed 4906.02. Three `expect` assertions pin this down. Full
`[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl`
(Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #20 — #34bM: `UEV_Issue`'s Stable-pool anchoring check now requires direct principal adjacency

**Owner direction:** discovered off-cycle, during #34M follow-up discussion. Stated design precisely: a
Stable pool's first token must either be a principal itself, or be directly pooled (one hop, in an
existing pool) with one — not transitively reachable through a chain of non-principal tokens — and that
directly-anchored token must be in the pool's first position specifically.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`:** replaced a full multi-hop `URC_Hopper` BFS search
targeting `DLK` specifically with a direct-neighbour check — `SWPT::URC_TokenNeighbours(first-pool-token)`
(one hop, unfiltered by active status) against the *full* current `UR_Principals()` list. Fixes both
deviations from stated design at once: hop-count (direct-only, not transitive) and target (any current
principal, not one hardcoded token).

**A pre-existing test fixture broke and was repaired, not worked around:**
`[6.2+3]_DPTF-SWP_Issuance-Only.repl`'s `AG→AL→AU→BI→CO` chain (built for #13C/#19H/#20H's multi-hop BFS
tests) had been relying on the exact bug being fixed here to construct itself. Scoped precisely (via a
background investigation) before touching it: the *only* fixture in either test file affected. Fixed by
giving `AL`/`AU`/`BI` each a throwaway, never-swap-enabled direct-`OURO` pool (`SWP|TX 024a2`) — genuinely
satisfies the corrected rule (each link really is now directly principal-adjacent) without the BFS tests
(which query `URC_HopperActive`, active-only) ever seeing the throwaway pools, so the chain topology those
tests exercise is byte-for-byte unchanged.

**Adversarially proven, live — new `SWP|TX 032h`-`032k` in `[6.3]_SWP.repl`:** `TSTN` directly pooled with
`OURO`; `TSTM` pooled only with `TSTN` (2 hops from any principal, never direct). `S|TSTM|TSTQ` (`TSTM`
first) is correctly rejected with the fix active. Reverted in-place: the identical call succeeds
(`"expected failure, got result"`) — exact reproduction of the old false-accept. Restored, reconfirmed
rejection. Full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression (including the
repaired chain and all #13C/#19H/#20H assertions passing unchanged): exit 0, 0 `FAILURE`. Full `Z.repl`
(Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #21 — M2 / #34 (master issue, Phases 6-13): dirty-read path-injection redesign — closes the
      real gas-ceiling crisis Fix #19 uncovered, and delivers the originally-requested exhaustive search

**Owner direction:** Fix #19's own worst-case measurement (Phase 2-5, P0.5/P0.6 in the HANDOFF doc)
found that real worst-case `CC_SmartSwap` execution — with Liquid Boost, a supposedly-always-on
production feature — costs **6-7 million gas at realistic scale (~100 active pools) against the real
~2,000,000 Stoa ceiling**, growing worse as the protocol's pool count grows (new pools must anchor to
principal tokens, which become search hubs). Owner directed the whole thing — best-of-3's own
limitations, the gas-ceiling crisis, and the fix — be consolidated into this one issue, executed
phase-by-phase with explicit go-ahead at each step, full REPL verification (not load-testing — real
pass/fail assertions) at every stage, adversarial revert-and-reproduce proof for every fix. Full
13-phase plan, every design decision, every dead end: `OuronetInformational/HANDOFF-swp-exhaustive-path-search.md`.
Finished-mechanism write-up + client orchestration guide: `OuronetInformational/HANDOFF-swp-smartswap-bundle-architecture.md`.

**The redesign (Phases 6-10, the dirty-read bundle mechanism) — push all path discovery off-chain:**
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` — `SWPT|PathCache` table (+ `PathCacheRow` on the
  `SwapTracerV2` interface) — a shared, amount-agnostic X→target path cache. `URC_ReadPathCache`
  (reversed-lookup read, checks both key directions before concluding a miss), `URC_EdgeConnects` /
  `URC_ValidatePathStructure` (exists-only structural + depth-cap validation, re-run on every read —
  even cache hits — never trusted blindly), `XI_RegisterPath` (first-write-wins, self-verifying,
  checks both directions before writing regardless of caller claims) + its proper cross-module
  forward-writer `XE_RegisterPath` (mirrors the established `XE_UpdateGraph` pattern — a caller-side
  grant of `SWPT.SECURE` directly was investigated and rejected: this codebase's own
  `Audit/ATS/ROUND-01-FINDINGS.md` proves that pattern is unsafe for a `true`-bodied capability).
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` — `URC_ValidatePathActive` (wraps SWPT's structural
  check with the active-required `can-swap` pass); `URC_HopperForKnownRoute` (feeless quote over a
  caller-supplied route's *exact* edges, not a re-derived "best" edge — keeps the slippage floor
  check consistent with what real execution will actually walk).
- `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact` — `SmartSwapPathBundle`/`SwapRoute`/`CachedPathOrMiss`/
  `TokenPathPair` schemas; existing self-searching entrypoints renamed `CC_SmartSwap` /
  `SWP|CC_SmartSwap{With,No}Slippage` (zero behavior change, kept as the fallback/comparison
  baseline); new bundle-based `SWPU::C_SmartSwap` + `XI_SmartSwapExplicitRoute` +
  `SWPU|X>SMART-SWAP-EXPLICIT-ROUTE` defcap (validates the whole bundle's route via **one** cheap
  `URC_ValidatePathActive` call — no full-graph search at the defcap layer at all, the actual
  mechanism behind the gas reduction); `boost-path` threaded through `XI_SmartSwapCore` /
  `XI_LiquidIndexPump` / `XI_RawLiquidPump` via a `NO_PATH` sentinel so the self-searching chain is
  behaviorally untouched; `URC_PoolStoaValueFromPath` / `URC_ComputeStoaValueResults` (the "dumb
  writer" pricing computation, reproducing `URC_PoolValue`'s exact formula from bundle data instead
  of a fresh search); `XI_RegisterBundlePaths` (cache self-warming, re-validates every path from
  scratch, never trusts the bundle's `is-new` claim).
- `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact` — `SWP|C_SmartSwapWithSlippage` /
  `SWP|C_SmartSwapNoSlippage` (the bundle-based Talos entrypoints) with the real dumb-writer (`map`
  straight into `XE_UpdateStoaValue`, **zero** `URC_PoolValue` calls at the Talos layer for this
  path — the mechanism that removes what Phase 2-5 found was 56.9% of the old total cost).
- **Two real bugs fixed as a natural byproduct, both with adversarial revert-reproduce proof:**
  `XI_RawLiquidPump`'s long-standing crash (unguarded index into a possibly-empty search result —
  actually *two* bugs, the second in its caller `XI_LiquidIndexPump`, only surfacing once the first
  was fixed and execution could reach it); a doc-comment inconsistency in the bundle schemas caught
  *before* code was built against it (`stoa-paths` targets DWK, not DLK like `boost-path` — traced
  `URC_PoolValue`'s real implementation rather than assuming).

**The exhaustive search itself (Phases 11-12, the originally-requested "genuine cheapest path"):**
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` — `URC_ComputeAllRoutes(input, output, swpairs,
  max-attempts)`: a real `fold` over up to `max-attempts` (not this issue's own Fix #19's fixed
  cap-of-3), same edge-exclusion-per-found-route mechanism, `MAX_ATTEMPTS_HARD_CAP` (50,000)
  clamping regardless of caller request, depth cap (`MAX_ROUTE_NODES = 7`) enforced as a documented
  post-discovery filter (not baked into the shared `U|BFS` utility — a deliberate scope decision,
  since this function is dirty-read-only and the efficiency concern that preference exists for
  doesn't apply here).
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` — `URC_HopperExhaustive`, mirroring `URCX_Hopper`'s
  shape, reusing `URCX_HopperForNodes`/`UC_BestHopper` (this same Fix #19's own machinery)
  completely unchanged.

**Adversarially proven, live — permanent regression across `[6.3]_SWP.repl`:**
- **Gas, the headline number:** same worst-case swap, same ~102-active-pool topology —
  `CC_SmartSwap` (self-searching): **7,145,298 gas**. `C_SmartSwap` (bundle-based): **385,749 gas,
  397,043 including cache-warming writes — an 18.5x reduction**, safely under the real ceiling.
  Both confirmed executing the identical real 6-hop/6-pool route, not a shortcut (`SWP|TX 032z2` /
  `032z6`).
- **Malformed-bundle adversarial proof (`SWP|TX 032z8`):** wrong-endpoint route, depth-cap
  violation, fabricated non-existent pool, and a real-but-`can-swap=false` pool — all four correctly
  abort the whole transaction (`expect-failure`) before any state changes. A fabricated boost-path
  and a fabricated stoa-path entry — both correctly degrade gracefully instead (swap still
  completes, checked against the actual returned string, not a placebo assertion).
- **Cache self-warming (`SWP|TX 032z6`/`032z7`):** a genuinely-new path gets registered and reads
  back correctly (reversed-lookup); a natural depth-cap rejection (the P2-scale topology's real
  `W7→DLK` route is genuinely 8 hops) correctly skips registration — caught as a real finding, not
  assumed, and confirmed to be the depth-cap safety mechanism working as designed, not a bug.
- **Exhaustive search, closing P4.1 (open since the original Round I sweep) — `SWP|TX 049`-`052`:**
  extended the Fix #19 diamond topology with 2 more routes (issued last, so best-of-3 structurally
  cannot see the 4th). Measured empirically (a first sizing attempt was wrong, caught by isolating
  each candidate route's own value before asserting anything): for a 100 OURO test, best-of-3 picks
  195.16, the exhaustive search finds and picks 784.27 — a real case where the true-best route is
  provably outside best-of-3's own reach. Also proves the single-pool-universe edge case (exactly 1
  route when connected, exactly 0 when not, no crash).
- **Realistic-scale measurement (`SWP|TX 053`):** `URC_ComputeAllRoutes`'s own cost/candidate-count
  at full ~104-pool scale — sub-linear growth with background pool count; the early-exit
  short-circuit confirmed working (extra `max-attempts` beyond natural exhaustion cost almost
  nothing more). Go/no-go: tractable — this function is dirty-read-only, so none of these numbers
  ever compete against the real paid-gas ceiling.
- Full `[6.2]`+`[6.3]` suite, default issuance-only regression, and full `Z.repl` (Stage 1 + Stage
  2) all exit 0, 0 `FAILURE` — reconfirmed after every phase, not just at the end.

**Not yet built, explicitly scoped out and tracked, not silently dropped:** exhaustive-search route
discovery still needs to actually feed `swap-route` for a real client (currently `CC_SmartSwap`'s
`URC_HopperActive` best-of-3 remains the *production default* discovery mechanism; `C_SmartSwap`'s
bundle can be filled by either). Cache self-warming and the new bundle-based path coexist with the
`CC_`-renamed originals deliberately — whether `CC_` is ever fully retired is an explicit open
decision, not made here.

**Status:** FIXED ✅ AND PROVEN ✅ — all 13 phases of the consolidated plan complete, 2026-08-22.
Awaiting Round III re-verify.

---

## Fix #22 — M5 (#36M): `SWPI::C_Issue` and `MTX-SWP::MTX|C_Issue` now share one write-sequence chokepoint

**Owner direction:** use a single shared core for the write sequence, called from both `C_Issue` and
`MTX|C_Issue`. Multi-step issuance (`MTX|C_Issue`) is now considered historical/observational —
single-tx issuance is always safely under the real ~2,000,000 gas ceiling (per this same session's #34
gas work) — but the historical path stays live and must call the same shared core, not its own copy.

**Feasibility confirmed before building:** a `defpact` `step` is ordinary Pact code — it can freely call
cross-module functions, including other `UEV_IMC`-gated `XE_*` entrypoints, exactly like non-defpact
code. Proven by pre-existing code already in `MTX|C_Issue`'s own Step 3 (`ref-DPTF::XE_IssueLP`,
`ref-SWP::XE_Issue`, `ref-BRD::XE_Issue`, `ref-SWPT::XE_UpdateGraph` — all cross-module, all already
working, all unmodified by this fix) before any new call was added.

**Fix:**
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` — new `XE_IssueWrite` (forward-module entrypoint, added
  to the `SwapperIssueV3` interface): the ONE write sequence (mint LP token, register the pool,
  transfer pool tokens in, mint genesis LP supply, transfer LP out, register the swap-tracer graph
  edge). Returns `[swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]` — a wider list,
  not an `OutputCumulator` (this codebase's `XE_*` convention: the forward module's own `C_` composes
  IGNIS, not this function) — so `C_Issue` can still aggregate every sub-call's own cumulator into its
  single billed response exactly as before, while `MTX|C_Issue`'s Step 3 (already billed separately, in
  its own Step 2) takes just `swpair`/`token-lp` and ignores the rest. New `SWPI|XE>ISSUE-WRITE` local
  cap (no checks beyond `UEV_IMC` — real validation already ran in whichever caller's own defcap/Step 1
  got here first). New named constant `GENESIS_LP_SUPPLY` (`10000000.0`) replaces the bare literal that
  was independently duplicated in both callers' own write sequences. `C_Issue` itself rewritten to
  delegate to `XE_IssueWrite` instead of inlining the sequence.
- `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact` — `MTX|C_Issue`'s Step 3 rewritten to call
  `ref-SWPI::XE_IssueWrite` instead of independently reimplementing the sequence.
- `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact`, `P|A_Define` — genuine pre-existing gap found and
  fixed while wiring the new cross-module call: `UEV_IMC` (the gate `XE_IssueWrite` opens with) checks
  a per-module "Implementing Module Policy" allow-list that each *caller* must register itself onto —
  MTX-SWP's own `P|A_Define` already registered itself on BRD/DPTF/DPOF/TFT/OUROBOROS/VST/SWPT/SWP/SWPL
  (which is why the pre-existing `ref-SWPT::XE_UpdateGraph` call from the same Step 3 already worked)
  but had never registered itself on SWPI, because MTX-SWP had never before needed to call a
  `UEV_IMC`-gated function on SWPI directly. Added `(ref-P|SWPI::P|A_AddIMP mg)`, matching the existing
  pattern for every other module MTX-SWP already registers with.

**Adversarially proven, live:** full `[6.2]`+`[6.3]` suite (real execution path, exercises
`MTX|C_Issue`'s defpact issuance via the pre-existing `SWP|TX 012b`/`012c` "Issue Stable 7xUSD via
defpact" test): before the `P|A_Define` fix, failed hard at load with `UEV_IMC`'s "None of the guards
passed" (`02_U_G.pact:57`) — a genuine cross-module authorization gap, not a REPL assertion failure.
After adding the missing registration: exit 0, 0 `FAILURE`. Default issuance-only regression: exit 0,
0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #23 — M3 (#37M): unguarded `enumerate 0 -1` crash fixed at its 5 real root-cause sites

**Owner direction:** pushed back on the finding first — didn't believe unused/broken functions were
really in the codebase, suspected a botched refactor rename. Once shown the grep proving no rename (zero
callers anywhere, under any name) and the real live-reachable path, directed: fix it without breaking
functionality.

**Mechanism correction found while re-verifying:** `enumerate 0 -1` doesn't itself error (returns
`[0, -1]`, confirmed against the real binary) — the crash is the subsequent `(at 0 emptyList)` inside the
enclosing `fold`. Same practical effect, different exact cause than the finding stated.

**Reachability confirmed, not assumed:** 4 of the 7 originally-named functions
(`UC_AreOnPools`/`UC_FilterOne`/`UC_FilterTwo`/`UC_IzOnPools`) have zero callers anywhere in the repo —
dead code, no current risk. The other 3 (`UC_PoolTokensFromPairs`, `UC_MakeGraphNodes`, `U|BFS::UC_BFS`)
share one root cause and ARE reachable — from the live, gas-sponsored `CC_SmartSwap` entrypoint, whenever
`SWP::URC_Swpairs()` is `[]` (the real window before the first pool is ever issued). This same session's
own #34 work already hit this crash once for real and patched two call sites locally, explicitly
deferring the general fix as this exact finding. Tracing the full chain (not stopping at the named
functions) found a 5th, previously-unflagged site sharing the identical pattern:
`SWPT::URC_MakeGraph` (`14_SWPT.pact:512`) — fixing only the named functions would have just relocated
the crash one hop deeper.

**Fix:**
- `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact` — `(if (= 0 (length swpairs)) [] (fold ...))` guard
  added to `UC_AreOnPools`, `UC_IzOnPools`, `UC_PoolTokensFromPairs` (the 3 actual root-cause sites in
  this file).
- `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact` — same guard added to `UCX_GraphNodes` (the true root
  of `UC_BFS`'s own empty-graph crash — `UC_BFS` never indexes `graph` directly itself, only through this
  function).
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` — same guard added to `URC_MakeGraph` (the newly-found 5th
  site, on its own `nodes` list).
- Every other function named in the finding (`UC_FilterOne`/`Two`, `UC_MakeGraphNodes`, `UC_BFS`,
  `UC_UniqueTokens`) is a thin pass-through over one of these five and becomes safe automatically —
  confirmed by tracing the full chain to `URC_ComputeGraphPath`'s existing `[BAR]` "no path" sentinel
  (the same clean-failure convention already established by the #20H fix), reached cleanly instead of
  crashing. Zero behavior change for any non-empty input.

**Adversarially proven, live — new `SWP|TX 003b` in `[6.3]_SWP.repl`**, placed in the genuine
pre-first-pool-issuance window (after TX 001-003, before TX 004's first pool issuance):
`SWP::URC_Swpairs()` confirmed genuinely `[]` at that point; `URC_AllPoolTokens()` and
`SWPT::URC_ComputeGraphPath "OURO" "DLK" []` both now return clean results instead of crashing. Reverted
the fix (`git stash` on just the 3 source files, proof TX left in place): full suite failed hard at load
with the exact predicted `Array index out of bounds` in `UC_PoolTokensFromPairs`. Restored, reconfirmed
clean. Full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression: exit 0, 0 `FAILURE`.
Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #24 — M4 (#38M): `UCX_GraphNodeLinks` single-pass rewrite, ~39% cheaper, same output

**Owner direction:** asked whether this could genuinely be made more efficient without breaking
functionality, and whether #34's path cache already made it moot — then, once both were answered
concretely: "you gotta check in repl that it produce the same results as the current implementation. to
make sure you didnt break it."

**Path-cache relevance checked, not assumed:** the bundle-based `SWPU::C_SmartSwap` path (built in #34)
skips the graph-BFS chain entirely on a cache hit — confirmed via its own defcap doc comment ("no
full-graph BFS at the defcap layer"). Not obsolete, though: the self-searching `CC_SmartSwap` fallback is
still a live, gas-sponsored production entrypoint that runs the full unguarded BFS every time, and #34's
own gas breakdown already showed graph-search calls were 56.9% of the old worst-case total.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact`:** `UCX_GraphNodeLinks` rewritten from
rebuild-the-whole-name-list (`UCX_GraphNodes`) + linear search (`UC_Search`) + re-index-by-position (two
full O(V) passes plus a reindex per call) to a single `filter` directly over `graph`, matching by the
`"node"` field, same first-match tie-break as before. `UCX_GraphNodes` (its only caller) removed as dead
code rather than left behind.

**Adversarially proven, live — direct before/after comparison (not just "existing tests still pass"),
matching the owner's explicit instruction:** new permanent `SWP|TX 032z2b` in `[6.3]_SWP.repl`, calling
`SWPT::URC_ComputeGraphPath` directly on the real ~102-active-pool P2-scale topology (the same worst-case
`W1`→`W7` 6-hop pair #34 already measured), isolating the graph-search cost from swap-execution overhead.
Reverted the fix (`git stash` on just `13_U_BFS.pact`): same call, **423,762 gas**, byte-identical 7-node
path. Restored: identical path, **256,867 gas — a real ~39% reduction**, measured at real scale. Full
`[6.2]`/`[6.3]` suite (every pre-existing exact-value route assertion from C6/H2/H4/M2 — would have
failed on any BFS behavior drift): exit 0, 0 `FAILURE`. Issuance-only regression: exit 0, 0 `FAILURE`.
Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

---

## Fix #25 — M14 (#39M): `ClientThreeV2`/`ClientPactsV2` reconstructed and archived from git history

**Owner direction:** fix it — historical-purposes convention is to keep old interfaces around and add
the next V number for what's live, since the codebase deploys anew across all modules/interfaces anyway.

**Reconstruction:** identified the overwriting commit (`df2d72e`) and pulled both interfaces' full
pre-overwrite text from its parent commit — exact, not re-derived.

**Placement required investigation, not a literal copy-paste of the old finding:** the finding's original
premise (both interfaces belonging in the central `0_Interfaces/03_Talos.pact` registry) is now outdated
— the live `ClientThreeV3`/`ClientPactsV3` moved to their own deploy-with-module files since the finding
was filed. First attempt (central registry, matching the old finding literally) failed to load for real:
`ClientThreeV2`'s Smart Swap functions type against `SwapperUsageV2.Slippage`, a module-owned interface
not yet deployed at the registry's early load point. Checked for a working precedent first —
`06_TS01-C4.pact`'s own comment describes the identical situation for `ClientFourV6` (module-owned
`PythiaLedgerV2` dependency) but the actual archived interface was never written, just the comment. Not a
copy-able example, but confirmation the intended pattern (frozen alongside the deploy-with-module file,
not the central registry, when a module-owned dependency exists) was already this codebase's own stated
intent.

**Fix:**
- `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact` — `TalosStageOne_ClientThreeV2` (frozen, full original
  text) added ahead of the live `ClientThreeV3`.
- `1_SOVEREIGN/STAGE_01/3_Talos/05_TS01-P.pact` — `TalosStageOne_ClientPactsV2` (frozen, full original
  text) added ahead of the live `ClientPactsV3`, kept with its always-paired sibling rather than split
  across files.
- `1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact` — header comment updated to point to the new
  locations and explain why, matching the existing `ClientFourV6` cross-reference style.

**Adversarially proven, live:** the first placement attempt genuinely failed to load (`Module
SwapperUsageV2 has no such member: Slippage`) — confirming the relocation was necessary, not a style
choice. After the fix: full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression: exit 0,
0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`. Purely
additive/documentation — no live code path touched, zero functional risk by construction.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.
