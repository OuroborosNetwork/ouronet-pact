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
