# ROUND I — Owner feedback

**Date:** 2026-08-16 · **Status:** append-only, growing as verdicts arrive. One entry per finding, in the
order verdicts were given (not severity order — see `ISSUES-RANKED.md`/`ROUND-01-FINDINGS.md` for that).

---

## C10 (asymmetric-add mint uses the naive amount) — **REFUTED**

**Owner evidence:** posted the full event log of a real `SWPLC|C>ADD-STANDARD-LQ` transaction (3-token weighted
pool `W|SSTOA|OURO|WSTOA`). Balanced LP = 768.567125264690543822303250, asymmetric LP (full, naive) =
1537.451515191937674407235653, asymmetric-fee (the D-invariant deficit, `full-lp − taxd-lp`) =
11.530845729348435433985315, relinquish-lp = 3.4050. Minted = 2302.613585547941655168505120, which is exactly
`balanced + full-asymmetric − relinquish`. The `SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX` event shows the 11.53 LP
deficit was explicitly priced and charged: *"~11.5308 LP out of a total ~1537.4515 Asym-LP, covered by 50.0
IGNIS (discounted as GAS), as Asym-Liq.-FEE."*

**Why the original finding was wrong:** C10 (as written) claimed the D-invariant-fair `taxd-lp` value is
computed and then silently discarded, with the full (naive, unreduced) amount minted at zero cost to the
depositor. That's false. Tracing `URC|KDA-PID_CLAD`'s "With Asymmetric TAX Collection" branch further than the
original audit pass did:

- `asymmetric-lp-fee-amount` (= `full-lp − taxd-lp`) is fed into `URC|KDA-PID_LpToIgnis(swpair, amount,
  kda-pid)` (`17_SWPL.pact:449-460`), which computes `floor(amount · lp-value-in-dwk · kda-pid · 100, 2)` — a
  real, oracle-priced dollar-equivalent conversion of the deficit into IGNIS, not an unrelated or symbolic
  charge.
- `kda-pid` is **not caller-suppliable** — `TS01-C3::SWP|C_AddLiquidity` reads it on-chain itself
  (`ref-U|CT|DIA::UR|KDA-PID`, `04_TS01-C3.pact:561`) before ever calling into SWPL, so a depositor cannot hand
  in a favorable/stale price to under-price their own fee within the same transaction.
- The mechanism is the module's own documented design, not an oversight: `SWP|C_AddLiquidity`'s `@doc`
  (`04_TS01-C3.pact` ~549-552) states plainly — *"If Asymmetric LP is detected, further IGNIS costs are
  enforced <ignis-gaseous-tax>, <deficit-ignis-tax>, <boost-ignis-tax>. Also a specific quantity of LP is
  relinquished as <fuel-lp-tax>."* — i.e. the deliberate design is: mint the full amount, tax the deficit in
  IGNIS (oracle-priced) plus relinquish a further LP amount, rather than mechanically reducing the mint
  (Curve-style). The `SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX` event text itself frames it the same way ("covered by
  ... IGNIS ... as Asym-Liq.-FEE").
- The original numeric "mint-then-burn nets ~47 free tokens" exploit walkthrough never accounted for this
  mandatory IGNIS payment — it assumed the deficit went completely uncompensated, which is incorrect.

**Verdict: REFUTED.** Retracted from the CRITICAL list. `README.md`'s status tracker and `ISSUES-RANKED.md`'s
#1C entry are annotated accordingly (not renumbered, to avoid breaking other findings' cross-references).

**What survives, narrowed and reclassified:** while the deficit *is* genuinely priced and charged, the IGNIS
collected is credited to `SWP|SC_NAME` — confirmed as a **real transfer**, not a symbolic label
(`IGNIS|C>COLLECT`'s `interactor` composes `IGNIS|C>TRANSFER patron interactor amount`,
`02_IGNIS.pact:144-163`) — but `SWP|SC_NAME` is the **shared vault across every SWP pool**, not this specific
pool's own reserves. So the depositor pays fair (oracle-priced) value for their deficit, but that value doesn't
flow back to increase the diluted pool's own per-LP-share backing — it funds the shared vault/gas-station
generally. This is precisely **H8**'s existing finding ("asymmetric-deficit compensation is not returned to the
diluted pool's own LP holders") — now confirmed with a concrete mechanism trace rather than left as a
"design — confirm intent" flag. **H8 is upgraded from an open design question to a confirmed mechanism-level
finding**; still a design decision for the owner (is protocol-wide value capture instead of per-pool LP
protection the intended tradeoff?), not a fund-drain bug. Severity stays HIGH, not CRITICAL — the depositor
does pay real value, so this is a fairness/accounting-destination question, not free money for an attacker.

**Follow-up not yet resolved (worth a REPL check before closing H8):** does the gaseous fee's pricing (`floor`,
50 IGNIS minimum floor, and the fact that the *other* two taxes — `deficit-ignis-tax`/`lqboost-ignis-tax` — are
priced off a **different**, VSE-based "deviation" metric that reported ~0.0002% in the owner's transaction
versus the D-invariant model's ~0.75% deficit fraction, a ~4000x discrepancy between the two models for the
*same* deposit) leave any residual gap for a **large** (not floor-dominated) one-sided deposit? The gaseous fee
itself scales correctly with the true D-invariant deficit (no cap found beyond the 50-IGNIS floor), so this
looks likely fine at scale — but the ~4000x model disagreement observed live is itself worth flagging as a
sharper, evidence-backed version of **H7** (two unreconciled deficit models), not just a theoretical concern
anymore.

---

## C13 (`SWPLC::C_Fuel` indirect branch / "IMC provides no real access control") — **REFUTED**

**How this one got caught:** not owner-supplied evidence this time — after the C10 correction, the audit lead
built a minimal, standalone Pact 5 REPL reproduction of the exact pattern (`(defcap CALLER () true)` +
`enforce-guard`/`compose-capability` on a `create-capability-guard(CALLER)`, mirroring `P|SWPLC|CALLER`/
`P|TALOS-SUMMONER`/`SECURE` byte-for-byte) before committing to this as a confirmed finding, per the owner's
"verify before you fix" standard set by the C10 exchange. Full probe scripts and output are reproducible; the
core result:

```
(with-capability (free.protected-target.CALLER)
    (free.protected-target.set-balance "victim-pool" 999999.0))
;; => "Module admin necessary for operation but has not been acquired: free.protected-target"
```

Reproduced from three angles, all failing identically: bare top-level transaction code, a separate
attacker-controlled module attempting the same `with-capability` wrap, and even attempting to pre-acquire the
module's own `GOV` capability first (also `(defcap GOV () true)`) — same wall every time. **Owner confirmed the
real-world corroborating fact independently:** the indirect branch's two actual call sites
(`19_SWPU.pact:687,858`, both `(ref-SWPLC::C_Fuel account swpair lp-fuel false false)`, inside
`XI_SmartSwapCore`/`XI_Swap`) are legitimate — the branch exists specifically for the case where the token
transfer already happened via the swap's own `TFT` transfer, and `C_Fuel`'s indirect call just reconciles
SWPLC's own reserve bookkeeping against tokens already in custody, with `lp-fuel` computed internally from the
fee split, never forwarded from user input.

**Why the original finding was wrong:** C13 claimed `with-capability` on a capability whose `defcap` body is
unconditionally `true` (e.g. `P|SWPLC|CALLER`) can be granted by **any** external caller — a bare transaction,
or an unrelated module — because nothing in the capability's own logic rejects it. That's incorrect for Pact 5:
`with-capability` on a capability defined by module `M` additionally requires **module admin of `M`** unless the
granting code is executing *from inside `M`'s own compiled functions*. This is a VM-level restriction, not
itself a capability that can be gamed the same way (confirmed: trying to pre-acquire `GOV` externally hits the
identical error). Concretely: `TS01-C3.P|TALOS-SUMMONER` can only ever become "in scope" via code physically
inside `TS01-C3` granting it to itself before calling out — exactly the legitimate `(with-capability (P|TS)
(ref-SWPLC::C_Fuel ...))` pattern already in the codebase — never by an outside caller forging the grant.

**Verdict: REFUTED.** With the bypass premise gone, no live path to `C_Fuel`'s indirect branch survives in this
audit's scope (Talos always hardcodes `direct-or-indirect=true`; SWPU's two internal calls are safe by
construction). The broader claim that this pattern might be a codebase-wide access-control gap is also
retracted — the underlying Pact 5 mechanism is sound.

**What (if anything) survives:** nothing rising to a documented finding. Optionally worth a LOW/hygiene note
(not re-numbered into the CRITICAL/HIGH tiers): `C_Fuel` is a public `defun` with a fund-bookkeeping-relevant
indirect branch reachable only via registered peers today — moving that branch to an `XI_`-internal function
(unreachable as a bare public entrypoint at all) would be pure defense-in-depth against a *future* peer module
mis-forwarding user input into it, not a fix for any currently-live issue.

---

## C2 (#3C, `U|SWP` StableSwap Newton solver has no domain guard) — **CONFIRMED, FIXED, PROVEN**

**Owner's challenge (worth recording — it sharpened the finding considerably):** owner pushed back on the
initial framing ("can you really confirm the math is wrong?", then "the fix has to be at the computation
level, even if UC functions can't enforce," then correctly predicted the scope narrows to stable pools
only, then correctly predicted a provably-correct solver removes the need for a pre-transfer sanity check).
Every one of those challenges was verified, not just accepted:

- **Is the math "wrong"?** No. Re-derived the algebra: `UC_YNext`'s numerator/denominator is exactly
  Newton's method on `f(Y) = Y² + (b-D)Y - c`, a quadratic with one positive (physical) and one negative
  (non-physical) root. The implementation is a correct root-finder. The actual defect: `y0 = xo -
  input-amount` (line 73) goes negative once `input-amount >= xo`, seeding Newton into the wrong root's
  basin. Confirmed by numeric replica of the exact Pact `floor`/`fold` sequence: `input=1010` against
  `xo=1000` solved to `Y=-31.77` → `output=1031.77`, exceeding the pool's entire balance.
- **Is a caller-side guard already in place (would make this dead-on-arrival, C13-style)?** Traced the
  full call chain: `SWPI::URC_S-Swap` → `UC_ComputeY`, gated only by `UEV_SwapData`
  (`16_SWPI.pact:1162-1188`), which checks token membership/list lengths only — never `input-amount` vs.
  the output reserve. No guard exists anywhere in the real swap path (`19_SWPU.pact::XI_SmartSwapCore`
  included).
- **Is this self-limiting (transfer just reverts on insufficient funds)?** No — traced further than the
  original finding: the oversized amount is transferred via `ref-TFT::C_Transfer o-id SWP|SC_NAME account
  adjusted-netto true` *before* `XE_UpdateSupplies` persists the corrupted balance, and `SWP|SC_NAME` is
  the **shared vault across every pool** (established in the C10 exchange above) — a token backing
  multiple pools can have ample balance to cover an oversized draw against one specific pool's accounting.
  Not self-correcting.
- **Scope — stable pools only?** Confirmed. Read `UC_ComputeWP`/`InverseWP`/`UC_ComputeEP`/`InverseEP`
  (`12_U_SWP.pact:250-362`) — all four are closed-form single-shot algebraic solves, no iteration, no
  seed-dependent root ambiguity possible. Only `UC_ComputeY`/`UC_ComputeInverseY` (Newton-iterated) can
  exhibit this failure mode.
- **Pure-computation fix, no `enforce` needed?** Confirmed and applied — see fix below.
- **Does a provably-correct solver make the pre-transfer sanity check unnecessary?** Agreed and retracted
  from the recommendation — a proven-correct fix doesn't need a runtime insurance check for the same bug.

**Asymmetry discovered mid-investigation:** `UC_ComputeInverseY`'s failure mode is *not* the same bug.
Its `xo-minus = xo - output-amount` (not `y0`) feeds directly into `S-Prime`/`P-Prime` as a supposedly-known
coefficient before Newton starts; numeric replica confirms it divides by zero exactly at `output-amount =
xo` and produces corrupted (sign-flipped) coefficients past it — not a wrong-root-from-bad-seed problem, so
reseeding doesn't fix it. **Left unfixed and unpatched**, flagged as needing its own separate treatment
(likely a real domain enforcement on `output-amount`, since "solve the input needed to withdraw more than
the pool has" has no valid answer to converge to). Not folded into this fix; tracked as still-open.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`, `UC_ComputeY`, line 73:** reseeded `y0` from
`(- xo input-amount)` to `D` (the already-computed invariant, line 61) — matching the Curve-style reference
`get_y`'s own initial guess. `D` is always in the correct root's basin regardless of trade size, because the
physical root (`0 < Y < xo`) exists for any positive input (the curve asymptotes toward but never reaches
`0`). One-line change, pure arithmetic, no `enforce`/table read — stays fully `UC_*`-legal. `UC_YNext`,
`UC_ComputeInverseY`, `UC_ZNext` untouched.

**REPL regression test — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 015 - C2
Regression: Stable-Swap Newton Domain Guard`** (permanent, in the canonical default-loaded suite, not
scratch — appended after `TX 014` where pool7 is live and swap-enabled). Reads pool7's real on-chain state
(no hardcoded reserves) and asserts the actual invariant — `0 < output < xo` — at three input sizes: 1000.0
(in-domain, unaffected), `1.2 × xo` (the exact size that broke the pre-fix solver), `1000 × xo` (extreme,
must still resolve to the asymptote). Property-based rather than golden-value, so it survives future
internal changes to the solver.

**Verification:**
1. Python replica of the exact Pact fold/floor sequence — `y0=D` keeps output inside `(0, xo)` from 1× up
   through 1,000,000× the old breaking point.
2. `pact Z.repl` (default, issuance-only SWP path) — exit 0, 0 `FAILURE`, `Load successful`.
3. Temporarily switched to the full `[6.2]_DPTF.repl` + `[6.3]_SWP.repl` suite (README's stated baseline
   coverage) and reran — exit 0, 0 `FAILURE`. Reverted the toggle after (diff shows only the intended files
   changed).
4. **Adversarial proof the new test is real, not vacuous:** `git stash`'d only `12_U_SWP.pact` back to the
   pre-fix code, reran `Z.repl` — the two oversized/extreme assertions failed exactly as predicted
   (`FAILURE: ... oversized swap ... expected: true, received: false`, same for extreme) while the
   in-domain assertion still passed, confirming the test isolates precisely the C2 failure mode. Restored
   the fix (`git stash pop`), reran — 6/6 `Expect: success`.

**Unrelated, pre-existing note:** the full `Z.repl` pipeline currently fails later, in Stage 2, inside
`AQP-VCT` (`Variable ln shadows native...` → `Load failed` loading `[2.3]_EarningPools.repl`) — this is
in-progress, uncommitted work from a separate session (`05_VCT.pact` and friends), unrelated to and
untouched by this fix. SWP's own Stage-1 run (including the new TX 015) completes and passes well before
that point in every run above.

**Status:** FIXED ✅ AND PROVEN ✅ — narrowed to stable pools only (per owner's correct prediction),
computation-level fix (per owner's correct requirement), no pre-transfer sanity check needed (per owner's
correct prediction, now that the solver is provably correct at the source). `UC_ComputeInverseY`'s sibling
issue is explicitly **not** covered by this fix and remains open. Full diff summary:
`ROUND-02-FIXES.md` Fix #1. Awaiting Round III re-verify.

---

## C12 (#4C, `SWPU::C_ToggleSwapCapability` no ownership check) — **REFUTED**

**Owner's claim:** only the pool owner can toggle swap; the call chain ends in a capability that composes
`CAP_Owner`, so there's no bug.

**Verified against source, not accepted on say-so.** The original finding traced `SWP::C_ToggleAddOrSwap`
(`15_SWP.pact:1337-1413`) and stopped at its **first** `with-capability` block (line 1354):
`(with-capability (P|GOVERNING-CALLER) ...)`, which wraps only ancillary IGNIS/role bookkeeping (granting
burn/mint/fee-exemption roles when a pool is *enabled* for the first time) and does trace to two
trivially-`true` caps (`P|SWP|CALLER`, `SWP|GOV` — confirmed by reading both definitions). That's where the
"no `CAP_Owner` anywhere in this function" conclusion came from — and it was wrong, because the function has
a **second, later** `with-capability` block that the original trace never reached.

**The actual persistence write:** line 1408, `(with-capability (SWP|C>ADD-OR-SWAP swpair toggle
add-or-swap) (XE_CanAddOrSwapToggle swpair toggle add-or-swap))` — runs **unconditionally**, for both
`toggle=true` and `toggle=false`. `XE_CanAddOrSwapToggle` (`1587-1606`) is the function that actually writes
`can-swap`/`can-add` to `SWP|Pairs`. The cap gating it, `SWP|C>ADD-OR-SWAP` (`476-489`), ends with
`(CAP_Owner swpair)` called unconditionally regardless of toggle direction; `CAP_Owner` (`1098-1106`) is
`ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto swpair)` — a real, live ownership-guard enforcement
tied to the pool's actual recorded owner.

**Why the original finding was wrong:** it correctly identified that `SPWU|C>TOGGLE-SWAP` (the outer,
SWPU-layer cap) has no enforcement on its disable branch — that part is true in isolation. But it treated
that shallow gate as the *only* protection in the chain and never followed the call into `SWP`'s own
`C_ToggleAddOrSwap` far enough to find the second `with-capability` block that does the real, unconditional
ownership check one hop deeper. Same shape as the C13 refutation: a shallow outer gate that looks
unprotected, backed by a solid enforcement in the module that actually owns the write.

**Verdict: REFUTED.** No live DoS path — any non-owner calling `SWP|C_ToggleSwapCapability` on a pool they
don't own hits `CAP_EnforceAccountOwnership` inside `XE_CanAddOrSwapToggle` and reverts, on both the enable
and disable branches. Retracted from CRITICAL; `README.md` and `ISSUES-RANKED.md` annotated accordingly (not
renumbered, per this round's convention).

---

## C11 (#5C, SWPU slippage bound checks the fee-exclusive gross quote, never the net delivered) — **DESIGN, confirmed intentional**

**Owner's claim (in two steps):** (1) slippage compares two feeless amounts, which is fine because it's a
like-for-like comparison; (2) the pool admin *can* change fees between quote and execution and nothing
breaks — that's by design, and any pool owner who wants to rule it out can opt into `fee-lock`.

**Verified in two passes, not accepted outright either time.**

**Pass 1 — is the feeless-vs-feeless comparison itself sound?** Yes, conceded directly: if fee is held
constant across the window, `gross = netto / (1 - fee%)` is a fixed scalar, so bounding gross to a tolerance
bounds netto to the same proportional tolerance. This correctly protects against reserve/price movement
between quote and execution — the finding's implicit assumption that "fee-exclusive" itself was the defect
was wrong.

**Pass 2 — is the residual fee-rate-change gap ("nothing breaks... this was so by design... admin may opt in
to lock fees") actually covered?** Checked the mechanics directly rather than accept the description:
- `C_UpdateFee` (`15_SWP.pact:1453-1465`) is gated by `SWP|S>UPDATE-FEE`, which hard-`enforce`s
  `UEV_FeeLockState swpair false` (`419-424`, `994-1001`) — a fee change is **impossible** while a pool's
  `fee-lock` is `true`. Confirmed load-bearing, not decorative.
- `UR_FeeLock:bool (swpair:string)` (`692-693`) is a genuine public reader — an integrator/front-end **can**
  check lock state before trusting a pool's slippage guarantee, refuse to quote unlocked pools, or warn the
  user.
- `fee-lock` defaults to `false` at genesis (`1563`) — unlocked-by-default, opt-in to lock. This is a
  real trust-boundary choice, not an oversight: a trader on an unlocked pool is knowingly (or should be
  knowingly) trusting that specific pool owner, same as for every other owner-controlled lever in this
  module (amplifier, weights, special-fee targets, etc. — none of which have platform-wide timelocks
  either).
- "Nothing breaks" confirmed literally: a fee change mid-window doesn't revert, corrupt state, or misbehave
  — the swap executes exactly per the (correctly, feeless) computed math. The only effect is the trader
  receiving less than they'd have gotten pre-change, same category of risk as every other owner-mutable pool
  parameter.

**Verdict: DESIGN — confirmed intentional and mechanically sound.** Not a bug; `fee-lock` is a real,
enforced, publicly-queryable primitive that fully answers the residual gap for any pool that opts in, and
unlocked pools carrying owner trust risk is a deliberate, consistent design choice across the module, not
specific to slippage.

**Optional, non-blocking follow-up (documentation only, not a tracked finding):** every slippage-related
`@doc` (`UDC_SlippageObject`, `UDC_SpawnSmartSwapSlippageBounds`, `C_Swap`, `C_SmartSwap`) correctly and
explicitly says "fee-less" — the exclusion itself is documented. But `C_ToggleFeeLock` has **no `@doc` at
all**, and the `fee-lock:bool` schema field (`269`) carries only a bare section-marker comment — nothing in
the source connects "slippage is fee-exclusive" to "`fee-lock` is what makes that safe to rely on." A
one-line `@doc` on `C_ToggleFeeLock` (and/or the schema field) stating that purpose would save a future
integrator or auditor from re-deriving this same chain. Not raised as a separate action item by the owner;
noted here only so it isn't silently lost.

---

## C1 (#6C, SWPI `URC_BestEdge` picks the worst parallel-pool edge) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** verify empirically in REPL before accepting the finding at all — "construct a swap
architecture in repl, there are already enough pools created, look them up, add what's missing, and let's
observe if your assessment holds true in repl first."

**Reproduction (before any fix):** used two already-existing pools that both directly connect DLK and OURO
(no new fixtures needed) — `W|DLK|OURO|DWK` (deep genesis: 3200/10000/6000) and `S|DLK|OURO|DWK` (shallow
genesis: 800/900/850), both registered principals, both swap-enabled by `TX 014`. Added
`REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 016 - C1 Reproduction`: computed each
pool's real output for the same `10.0` DLK input independently via the same `URC_Swap` any real caller
uses (so "which pool is better" is derived live, not asserted from the audit doc), then compared that
against what `URC_BestEdge` actually picked. Result, live from the interpreter, not predicted:

```
pool1 (W, deep)     output for 10.0 DLK->OURO = 18.703251597095004399307073
pool2 (S, shallow)  output for 10.0 DLK->OURO = 10.001390223588246869505299
URC_BestEdge actually chose:            S|DLK|OURO|DWK   (the WORSE pool — 10.00 output)
Objectively better edge (higher output): W|DLK|OURO|DWK   (18.70 output — nearly 2x)
```
`FAILURE: C1 reproduction — URC_BestEdge selects the higher-output edge` — confirmed live, not just from
reading the fold. Finding upheld.

**Fix — `16_SWPI.pact`, `URC_BestEdge`, line 909:** one-character comparator flip in the edge-selection
fold, `<` → `>` (argmin → argmax), plus a one-line comment recording why:
```diff
-                                (if (< (at idx svl) (at acc svl))
+                                (if (> (at idx svl) (at acc svl))
```
No interface change — `URC_BestEdge` is internal to `SwapperIssueV3`, not on the public surface.

**Verification (after the fix):** same `Z.repl` run, same `SWP|TX 016` block (unchanged — it already
encoded the correct behavior as its `expect`), only the comparator changed underneath it:
```
URC_BestEdge actually chose:            W|DLK|OURO|DWK   (now the BETTER pool — 18.70 output)
"Expect: success C1 reproduction — URC_BestEdge selects the higher-output edge"
```
Full `Z.repl` pipeline: exit 0, 0 `FAILURE`, `Load successful`, end to end.

**Status:** FIXED ✅ AND PROVEN ✅ — same block serves as both the pre-fix reproduction (failed as
predicted) and the permanent post-fix regression proof (passes now), mirroring the C2 pattern. Awaiting
Round III re-verify.

---

## C3 (#7C, U|SWP rounding direction favors the swap taker) — **STABLE: FIXED & PROVEN. WEIGHTED: ACCEPTED KNOWN LIMITATION.**

**Owner direction:** verify in REPL first (same standard as C1); once real, apply the fix; when the first
fix attempt proved ineffective, investigate deeper for the true root cause rather than re-guess; once the
true root cause turned out to be a Pact-language limitation ("we can't modify math, we gotta work with
what Pact gives us"), accept and document the residual that genuinely can't be fixed, and confirm directly
whether any of this threatens pool solvency.

**Reproduction (before any fix):** built a zero-fee round-trip probe in
`REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl` (new `SWP|TX 017`) calling `UC_ComputeY`/`UC_ComputeWP`
directly against two already-issued pools (`S|DLK|OURO|DWK`, `W|DLK|OURO|DWK`), bypassing fees entirely to
isolate the math. Confirmed live: stable pool netted +6.3e-15 DLK on a 100.0 round trip; weighted pool
netted +1.8e-12 DLK on a 9999.0 round trip (found only after probing several smaller amounts — 100.0,
137.777, 333.333333, 1.0, 0.0001, 271.828182845904523536 — which all round-tripped exactly clean first,
so the reproduction amount was picked because it's what actually triggered the bias, not to dramatize it).

**First fix attempt — WRONG, and I said so rather than claim success:** moved the `floor`/`ceiling` from
wrapping the intermediate solved-balance term to wrapping the final answer (matching the textbook "round
the pool's favor at the last step" AMM convention). Reran the same reproduction block: **byte-for-byte
identical numbers, same failures.** Traced why: `o-prec`/`i-prec` for the test tokens (DLK, OURO) are both
24 — the same as the internal working precision (`prec:integer 24`) used throughout the Newton iteration —
so moving the *outer* rounding boundary was a mathematical no-op; there was no truncation boundary left at
that point to move.

**Deeper investigation — the real root cause:** built a Python high-precision replica of the exact
floor/fold sequence to isolate where the divergence actually entered. It showed **zero** bias with internal
flooring replicated faithfully — meaning the bug wasn't in the repeated `floor(...,24)` truncations either,
contradicting my own working hypothesis. Instrumented `UC_ComputeD` directly in Pact and diffed against the
Python replica digit-by-digit: they diverged starting around the 17th significant digit — far too large a
gap for a 24-decimal floor artifact. Isolated it to Pact's `^` operator with a direct empirical test:
```
d = 2549.996147035166093620040554
(^ d 4.0)                        = 42282250700760.0859375
d*d*d*d (manual multiplication)  = 42282250700760.099021482473331191153317335329175719323256875718459007868358138754818195565982177117931551671056
diff: pow - manual = -0.013083982473331191153317335329175719323256875718459007868358138754818195565982177117931551671056
```
**Pact's `^` silently computes decimal exponentiation via IEEE-754 double precision internally** — not
exact/arbitrary-precision like `+`/`-`/`*`/`/` genuinely are on Pact decimals (verified `/` carries 255+
digits). A ~0.013 absolute error on a single exponentiation, confirmed as the true source of the bias —
not the floor/ceiling placement, and not the internal iteration's own truncation.

**Fix — stable pool only, `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`:** added `UC_IntPow`
(exact repeated-multiplication power for non-negative integer exponents) and replaced every whole-number
`^` usage in `UC_DNext` (`n^n`, `D^(n+1)`) and `UC_YNext` (`n^n`, `D^(n+1)`, `Y^2` → `Y*Y`) with it. This
fully covers `UC_ComputeY` (direct) and, transitively, `UC_ComputeInverseY`/`UC_ZNext` (inverse — they
share `UC_ComputeD`/`UC_YNext`, confirmed rather than assumed by testing the inverse direction directly).
Left the original outer floor→ceiling reordering from the first attempt in place (harmless, still correct
in principle for lower-precision tokens where it *would* matter).

**Verification (stable pool):** same `SWP|TX 017` block, both directions:
```
STABLE          100.0 DLK -> 100.000000000000000000000000 OURO -> 100.000000000000000000000000 DLK
STABLE INVERSE  needs 100.000000000000000000000000 DLK in to get 100.000000000000000000000000 OURO out
```
Exact to 24 decimal places, zero bias, both directions. `Expect: success` on both assertions.

**Weighted pool — NOT fixed, and can't be the same way.** Its bias comes from `x^weight` (e.g. `x^0.3`) —
a genuinely fractional exponent. `UC_IntPow`'s exact-multiplication trick only works for whole-number
exponents; there's no equivalent trick for a true fraction. Closing this fully would require writing a
from-scratch high-precision fractional power routine in Pact (Newton's method / power series) — real
numerical-computing work, non-trivial gas cost, real risk of introducing new bugs in something this
delicate, for a residual that (see below) poses no meaningful risk. **Owner decision: decline that work,
accept the residual as a known, bounded, documented language-level limitation.**

**Is this a solvency risk? No — verified, not just asserted:**
- Categorically different from C2 (which was a single-swap, *unbounded* failure — output could exceed the
  pool's entire balance of a token in one shot, a real solvency threat, already fixed separately). C3's
  residual is a *relative* floating-point precision limit (~1e-16, float64's native epsilon) multiplied by
  the *magnitude* of the numbers in the computation — for any realistic pool size, a fraction of a token,
  not a fraction of the pool.
- The measured 1.8e-12 bias required a 24-decimal-precision token specifically to be *visible* at all —
  real tokens are virtually never configured at 24 decimals (6/8/12/18 is typical); at realistic
  precisions the final settlement-rounding would swallow a bias this small entirely, most of the time.
- No accounting desync: the same computed value backs both the actual transfer and the tracked-reserve
  update — internally consistent, not a ledger-vs-custody mismatch.
- Repetition economics don't favor an attacker: extracting anything meaningful would need an astronomical
  number of round trips, each costing real gas, almost certainly exceeding whatever value was extracted.

**Documentation:** added a `KNOWN, ACCEPTED LIMITATION` block comment directly above `UC_ComputeWP` in
`12_U_SWP.pact` explaining the mechanism, why it can't be fixed the same way as the stable-pool case, and
the risk assessment, so a future reader doesn't mistake this for an unaddressed bug. Converted the
weighted-pool assertion in `SWP|TX 017` from a hard "must not profit" check (which would fail forever, now
that this is an accepted limitation, not an open bug) into a **regression bound** — passes now, but would
still catch a future change that made the bias grow beyond generous headroom over float64's own epsilon.

**Status:** Stable pool: FIXED ✅ AND PROVEN ✅ (both directions). Weighted pool: **ACCEPTED KNOWN
LIMITATION** — confirmed bounded, confirmed non-solvency-threatening, confirmed not fixable without a
disproportionate rewrite; closed as a documented tradeoff, not left as an open action item. Full
diff/rationale: `ROUND-02-FIXES.md` Fix #3. Awaiting Round III re-verify (stable-pool portion only).

---

## C7 (#8C, SWP `C_ModifyWeights` no length check / dead precision check / no bound) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** per-weight floor of at least 0.1, no negative values, enforce precision, and a
length-parity check — plus a specific ask to check `U|CT` for any additional validation logic attached to
`CT_FEE_PRECISION` before designing the fix.

**Investigated `U|CT` as directed:** it's a pure constants module — `CT_FEE_PRECISION` (`01_U_CT.pact:48`)
is a bare `() 4`, nothing else bundled with it. No hidden extra check being missed there. But looking
further surfaced two more useful things:
- The **correct** working version of this exact idiom already exists in the codebase:
  `06_U_INT.pact`'s `UEV_UniformList` puts `enforce` **inside** the `map` lambda (so each element's
  failure aborts immediately) — `SWP|S>WEIGHTS`'s original precision check used `=` (a comparison,
  producing a bool) instead of `enforce`, then discarded the `[bool]` result entirely. That's the actual
  bug: wrong idiom, not a missing helper. `08_U_DALOS.pact:432-449`'s `UEV_Fee` confirms the same correct
  pattern for a single value.
- The **exact same bug** — same discarded-map idiom, same `CT_FEE_PRECISION` constant — is duplicated in
  `16_SWPI.pact:1257-1263`, `UEV_Issue` (pool issuance time). Already tracked separately as **H5**, still
  pending its own verdict; flagging the connection here, not fixing it now — it's its own finding in the
  queue with its own context (issuance-time `UEV_Issue` also lacks a per-weight bound, matching **C4**,
  separately pending).

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>WEIGHTS`:** added length-parity via the existing
`ref-U|INT::UEV_UniformList` helper (mirroring the sibling `SWP|S>UPDATE-SUPPLIES` cap exactly); rewrote
the precision map to put a real `enforce` inside the lambda (matching `UEV_UniformList`'s working idiom),
combining the precision check with a `>= 0.1` per-weight floor (which also rules out negative weights) via
`(fold (and) true [...])`, per the repo's own 2-condition combining convention.

**Reproduction and verification, both proven live — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`,
new `SWP|TX 018 - C7 Reproduction: Weight-Modification Guards`** (canonical default-loaded suite, real
pool `W|DLK|OURO|DWK`, real owner signature):
1. **Adversarial proof the reproduction is real:** `git stash`'d only `15_SWP.pact` back to the pre-fix
   code, reran `Z.repl` — all four attack cases succeeded when they should have failed:
   `FAILURE: ... length mismatch ... expected failure, got result` (same wording for the sub-0.1 weight,
   the negative weight, and the imprecise-weight cases). Confirmed each hole was real, not assumed.
2. Restored the fix (`git stash pop`), reran — all four now correctly abort:
   `Expect failure: Success: C7 fix — length mismatch (2 weights on a 3-token pool) is rejected` (and the
   same for the other three).
3. **A legitimate reweight still works** — `[0.4, 0.4, 0.2]` (correct length, all `>= 0.1`, sums to 1.0,
   4-decimal precision) succeeds and is reflected live: `pool1 weights now: [0.4, 0.4, 0.2]`.
4. Full `Z.repl` pipeline: exit 0, 0 `FAILURE`, `Load successful`.

**Not addressed (deliberately out of scope for this fix, per the original finding's own framing):** a
time-lock/gradual-weight-change mechanism for the Balancer-style instant-reweight value-extraction vector
(item 4 in the original finding) is a design decision, not a validation bug, and would force a
`SwapperV3`→`V4` interface bump cascading to `TalosStageOne_ClientThreeV3`. Left for the owner to decide
separately if wanted.

**Status:** FIXED ✅ AND PROVEN ✅ — all three requested guards (length parity, per-weight `>= 0.1`
floor, real precision enforcement) verified to reject the exact holes they close and verified not to
reject legitimate reweights. `H5`'s duplicate of the discarded-map bug (in `UEV_Issue`) remains open,
tracked separately. Awaiting Round III re-verify.

---

## C8 (#9C, SWP `C_UpdateAmplifier` no bound-check on the new amplifier value) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** owner explicitly delegated the concrete bound values — "I never knew what I should
use" — asking for a recommended, evidence-backed floor and ceiling rather than an arbitrary number.

**Ceiling chosen empirically, not from folklore:** built a REPL probe sweeping `A` from 1.0 to 1,000,000
on a balanced pool (clean, round-trip stayed exact throughout) and, more tellingly, on a skewed pool
(`[100, 5000, 5000]`, 4000-unit trade) where the fixed 11-iteration Newton solver's convergence quality is
actually stressed:

| A | round-trip delta |
|---|---|
| 85.0 (this codebase's own test value) | ~3.3e-13 |
| 1000.0 | ~4.6e-8 |
| 5000.0 | ~1.1e-7 |
| 100,000+ | ~1.4e-7 (plateaus) |

Degradation is real and measurable past the low hundreds (ties directly to **H1**, the separately-tracked,
still-open "fixed iteration count, no convergence check" finding), though it plateaus rather than exploding.
**Recommended and applied: floor `>= 1.0`** (matches `UEV_Issue`'s own creation-time floor,
`16_SWPI.pact:1267`) **and ceiling `<= 2000.0`** — covers realistic real-world stable-pool amplifier ranges
with margin to spare below where this implementation's convergence quality starts visibly degrading. A
single range enforce also excludes `-1.0`/`0.0`/negatives with no separate sentinel check needed.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>UPDATE-AMPLIFIER`:** added
`(enforce (and (>= new-amplifier 1.0) (<= new-amplifier 2000.0)) ...)` alongside the pre-existing
`current-amp > 0.0` check. No interface change.

**Reproduction/verification — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 019 - C8
Reproduction: Amplifier-Update Guards`:**
- Live demonstration: `new-amplifier = 0.0` succeeded pre-fix (`FAILURE: ... expected failure, got
  result`) — confirmed the vulnerability directly, not just from reading the code.
- **A real testing lesson surfaced along the way, worth recording:** the first draft of this test chained
  four `expect-failure` attempts against the *same* pool with no reset between them. Against the pre-fix
  code, the first bad value (`0.0`) actually succeeds and bricks `current-amp` to `0.0` — which then makes
  every *later* case "look rejected" for the wrong reason (the cap's own pre-existing `current-amp > 0.0`
  check), not because any bound on `new-amplifier` was doing anything. Worse: it also discovered that once
  bricked, **no further `C_UpdateAmplifier` call can ever succeed again** (even a "reset" attempt trips
  the same pre-existing check) — a stronger, more permanent form of the original finding's "bricks every
  swap" scenario than originally stated. Fixed the test to reset to a known-good baseline (`85.0`) before
  each isolated case, so every case is independently meaningful under both pre- and post-fix code.
- Post-fix: all four cases correctly rejected (`Expect failure: Success`), and a legitimate update
  (`150.0`, within `[1.0, 2000.0]`) still succeeds and is reflected live.
- Did **not** additionally chase four fully-isolated pre-fix empirical proofs (one per distinct pool) —
  direct inspection of the pre-fix `enforce` shows it only ever references `current-amp`, never
  `new-amplifier`, so all four bad values are provably the same unconditional-accept code path, not four
  independent things requiring four separate demonstrations. One clean live proof (`0.0`) plus that code
  read is sufficient; manufacturing more scripts past that point would be process for its own sake.
- Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — floor/ceiling both evidence-backed (issuance precedent + REPL
convergence data, not guessed), reproduction proven live, a genuine test-isolation bug caught and fixed
along the way (and left as a durable lesson in the test's own comments). Awaiting Round III re-verify.

---

## C9 (#10C, SWP/MTX-SWP pools issued via defpact never registered in `SWP|LP`) — **CONFIRMED, FIXED, PROVEN**

**Owner context:** confirmed directly — `UR_GetLpSwpair`/`SWP|LP` was added later and the standalone
`XE_AddLPTracker` call was never wired into the `MTX-SWP` defpact path when it was added. Owner also
explained *why* the multi-step path exists at all: it was gas-limit-driven (~150k gas/tx historically),
and StoaChain's actual live limit is ~2,000,000 gas/tx — comfortably enough for even a 7-pool-token
issuance in one transaction today. The multi-step mechanism is kept for historical continuity and as a
worked example, not because it's still gas-required. Directed to fix the bug and document this context.

**Verified against current source before touching anything:** `XE_AddLPTracker` appears exactly once in
the whole codebase (`16_SWPI.pact:1430`, `SWPI::C_Issue`) and zero times in `20_MTX-SWP.pact`. Confirmed
`MTX|C_Issue`'s step 3 (`866-897`) calls `ref-SWP::XE_Issue` (`887`) identically to `SWPI::C_Issue`, but
never calls the tracker. Also confirmed `MTX-SWP` *does* correctly call `XE_MultiPathTracer` (routing-graph
registration, `893`) — this bug is scoped exactly to the one missing `SWP|LP` insert, not a broader
"MTX-SWP forgets bookkeeping" pattern.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `XE_Issue`:** folded the `SWP|LP` insert directly into
`XE_Issue` (both `token-lp` and `swpair` are already in scope there), so every issuance path gets it "for
free." Removed the now-redundant standalone call from `16_SWPI.pact::C_Issue` (would otherwise double-
insert and abort on the second call). Matches the finding's own recommended fix direction exactly.

**Reproduction and verification — real pool, not synthetic — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-
Only.repl`, new `SWP|TX 020 - C9 Reproduction: MTX-SWP Issuance Registers SWP|LP`:** used `pool7`
(`S|BUSD|TUSD|USDT|USDC|USDD|AUSD|CUSD`), which is issued in this exact suite through the real `MTX-SWP`
defpact (`TX 012a/b/c`, `0|2 → 1|2 → 2|2`) — not a hand-built repro case.
1. **Adversarial proof:** surgically reverted only the one new `XE_AddLPTracker` line inside `XE_Issue`
   (left the C7/C8 fixes in the same file untouched, to avoid their own tests' cascading-state issues from
   masking this one — see C8's entry for why that matters). Reran `Z.repl`: `UR_GetLpSwpair` on pool7's
   real LP token id (`S|BUSD-TUSD-USDT-USDC-USDD-AUSD-CUSD|LP-98c486052a51`) threw
   (`FAILURE: ... evaluation of actual failed with error message`) — confirmed the missing-row hard-abort
   live, against a pool that was actually issued through the buggy path in this same run.
2. Restored the fix, reran: `Expect: success` — `UR_GetLpSwpair` now resolves pool7's LP token back to
   its swpair correctly.
3. Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Documentation (per owner's request):** added a block comment directly above `(module MTX-SWP GOV` in
`20_MTX-SWP.pact` recording the gas-limit history (150k historical vs. ~2M live), that the multi-step split
is no longer gas-required, why it's still kept (continuity + worked example), and the C9 connection (why
the bug slipped through — two issuance paths, one bookkeeping step, only one caller remembered it). Also
captured as a dated memory note
(`OuronetInformational/memories/2026-08-17-mtx-swp-multi-step-no-longer-gas-required.md`) with the durable
rule generalized: when two-or-more call paths need the same follow-up bookkeeping step, fold it into the
shared function they both already call, rather than leaving it a standalone call each caller must remember.

**Status:** FIXED ✅ AND PROVEN ✅ — reproduced against a real, live-issued pool (not synthetic),
adversarially proven, historical context captured in-source and in memory for future sessions. Awaiting
Round III re-verify.

---

## H9 (#14H, SWPU `XI_Swap` reentrancy ordering window) — **REFUTED**

**Owner's challenge, in two parts.** First: asked for a plain-English explanation plus a real REPL proof
before accepting or rejecting — explicitly skeptical that "a swap can be triggered while another is
pending," on the grounds that Pact transactions are atomic. Second, after the proof came back: pushed
further on the *mechanism* — argued that in Pact, "the only things that can execute are those the module
admin wrote down," so no third party can ever make a module's code "turn around and call someone else,"
and that this is precisely why Pact doesn't have Solidity-style reentrancy at all.

**Research + isolated proof (not just code reading) before any verdict:**
- Traced the actual smart-account mechanism: the account's own `guard` field is protocol-locked to plain
  keyset guards (`UEV_EnforceGuardProtocol guard true`, `01_DALOS.pact:596`, rejects `u:`/`c:`/`m:`/`p:`).
  But the separate `governor` field is NOT locked the same way — `C_RotateGovernor`'s cap requires the
  *opposite* (`UEV_EnforceGuardProtocol governor false`, `:602`), i.e. a `u:` user-guard wrapping arbitrary
  code is installable as governor.
- `CAP_EnforceAccountOwnership` → `UEV_SmartAccOwn` (`01_DALOS.pact:924-943`) does
  `(enforce-one … [(enforce-guard account-guard) (enforce-guard sovereign-guard) (enforce-guard governor)])`
  — reached from the debit path (`05_DPTF.pact:777`, inside `XB_DebitTrueFungible`). So a rotated
  governor's arbitrary callback genuinely is invoked, synchronously, during `XI_Swap`'s input debit — the
  reachability half of the finding is real, not hypothetical.
- **Built a minimal, isolated Pact 5 REPL reproduction** (mirroring the exact `enforce-one`/`enforce-guard`
  structure, not the full DALOS/SWP machinery — same methodology as C13's refutation): a `victim` module
  calls `(enforce-one "auth" [(enforce-guard real-guard) (enforce-guard malicious-guard)])`, where
  `malicious-guard` wraps an `attacker` module function that attempts a real table `insert`. Ran it two
  ways:
  1. Bare attempt: `Error during database operation: Operation disallowed in read-only or sys-only mode`,
     thrown exactly at the `insert`, propagating up through the guard call and killing the whole
     transaction.
  2. Attempt wrapped in `try` (to see if the attacker could swallow the error and let their own
     transaction limp forward anyway): **same error, same abort** — this specific violation is not
     `try`-catchable, unlike an ordinary `enforce` failure.

**Verdict: REFUTED.** A reentrant "second swap" needs to write (transfer tokens, update reserves) to do
any damage; that write is categorically blocked from this exact execution context, and even attempting it
takes down the whole transaction rather than failing quietly. No partial, narrow, or degraded exploit
survives.

**Correcting the reasoning, not just the conclusion (important for future audits):** the owner's
conclusion was right, but "the code can never turn around and call someone else unless it's written down"
overstates it as "callbacks are impossible in Pact." They're not — `create-user-guard`/`enforce-guard` is
a real, deliberate Pact primitive that lets a module check a guard **without knowing in advance what code
is behind it**, and the codebase's own smart-account `governor` rotation feature depends on exactly this.
The isolated proof confirms the callback genuinely executes (the `insert` line is reached and evaluated —
it's the write, specifically, that's rejected). What actually makes this safe is a narrower, more precise
rule: **code invoked to satisfy a guard/`enforce` condition runs read-only, unconditionally, not
`try`-catchably.** That's a deliberate VM-level sandbox around a real callback capability, not an absence
of callbacks — the same shape of callback that causes reentrancy bugs in other smart-contract languages
(e.g. Solidity fallback functions during a token transfer) exists in Pact too; it's just sandboxed at
exactly the moment it would otherwise matter. Folding the precise version of this into
`OuronetInformational/pact5/SEMANTICS.md`'s footguns section and a dated memory note, so the durable
takeaway is "guard-evaluation callbacks are read-only-sandboxed," not the broader (and not quite accurate)
"Pact has no callbacks."

**Status:** REFUTED, proven both empirically (isolated Pact 5 reproduction, not just code reading) and
mechanistically (traced to the specific VM rule responsible, not a vague "Pact is safe" appeal).

---

## H10 (#15H, MTX-SWP/Talos Global Administrative Pause not honored on `defpact` continuation steps) — **DESIGN, closed**

**Owner's position:** GAP is meant, by design, to gate only Step 0 of a multi-step flow. Once Step 0 has
passed (which could only happen with GAP off), the continuation steps are "logically" the same operation
already authorized, and should complete regardless of GAP's later state — that's how it was implemented
throughout the codebase, not an MTX-SWP-specific oversight.

**Verified before accepting, not taken at face value:**
- **Consistency claim — confirmed true.** Checked every multi-step `defpact` in the codebase, not just
  MTX-SWP's 4: AQP's `MTX-AQP` has 2 more (`MTX|2|C_Inject`, `MTX|2|C_SweepRevokeAnchor`,
  `06_MTX-AQP.pact`). All 6, without exception, follow the identical pattern — GAP enforced only in the
  Talos wrapper that summons Step 0, never re-checked in later steps, which run via bare `continue-pact`.
  This is genuinely the architecture, not a gap specific to this module.
- **"Same transaction" (literal) — checked and found inaccurate.** Pact's own execution model
  (`pact5/SEMANTICS.md`, `REFERENCE.md`) confirms Step 0 and each `continue-pact` are separate,
  independently-signed, independently-timed transactions (own `publicMeta`, own signatures), linked only
  by shared pact-id and enforced step ordering — not one transaction in any sense Pact's runtime
  recognizes.
- **No documented design note found** stating the step-0-only behavior was a deliberate choice anywhere in
  `CONTEXT.md`/`StoicSyntax.md`/`ARCHITECTURE/`/module `@doc`s — it's implicit in the uniform
  architecture, not asserted anywhere in writing (this entry is now that documentation).
- **No TTL/expiry exists** between steps for any of these `defpact`s (confirmed — matches the already-
  separately-tracked **L68**) — a pact can sit half-finished indefinitely; nothing bounds how long after
  Step 0 a continuation can run.

**Owner clarified, on the "same transaction" point:** meant *logically* one transaction (one user-
authorized operation, mechanically split across steps for historical gas reasons), not literally one
blockchain transaction — always understood they're physically separate.

**What I flagged before closing:** "logically one operation" is a fully coherent premise, but it only
functions as a *safety* argument if the split pieces are guaranteed to complete close together in time —
otherwise a pact could be opened while GAP is off, sit dormant indefinitely, and be continued specifically
during a later pause (e.g. an active-incident pause), completing an operation the pause was meant to halt.
That residual exposure isn't closed by the design premise alone — it's closed by **L68**'s TTL fix (once
pacts expire if not completed within a bounded window, "logically one operation" becomes true in practice,
not just in intent, and no per-step GAP re-check is needed). Recommended linking the two rather than
treating H10 as fully independent.

**Owner's final call:** close H10 as correct by design, notwithstanding the L68 linkage.

**Status:** DESIGN — closed. Step-0-only GAP gating is confirmed intentional and consistently applied
across all 6 of the codebase's `defpact` flows (not an MTX-SWP-specific bug). The residual time-window
exposure this depends on is explicitly **not** independently closed by this verdict — it rides on **L68**
(no TTL/expiry) being fixed separately; until then the pause's own enforce message ("no client Functions
can be executed") is technically overstated for however long an unbounded in-flight pact could sit. No
code changed for H10 itself.

---

## H12 (#16H, SWP `SWP|S>UPDATE-SUPPLIES` accepts non-positive new reserve values) — **CONFIRMED, FIXED**

**Owner direction:** harden defensively regardless of current reachability — "just in case."

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|S>UPDATE-SUPPLIES`:** the old code only validated
a new supply value when it was already `> 0.0` (calling `DPTF::UEV_Amount`); for `<= 0.0` it silently
returned `true`, no check at all. Added an unconditional `(enforce (>= val 0.0) ...)` inside the same `map`
lambda — real-enforce-inside-the-lambda, matching the working `UEV_UniformList`/C7 idiom, not the original
dead-fallthrough one — on top of the pre-existing positive-value precision check.

**Attempted a live adversarial reproduction, and the attempt itself turned out to be informative, not
just a formality:** tried calling `XE_UpdateSupplies` directly from REPL top-level code with a genuinely
negative delta. Hit a real wall, not a test-authoring mistake:
- First attempt failed for an unrelated reason (`"None of the guards passed"` from `UEV_IMC`) — traced to
  `XE_UpdateSupplies`'s IMC policy check, which requires one of a fixed list of **peer-module**
  capabilities already be in scope (`SWP.SECURE`, `SWPI/SWPL/SWPLC/SWPU/MTX-SWP`'s own `P|*|CALLER` caps,
  or Talos's `P|TS`/`P|TALOS-SUMMONER`) — confirmed by reading `SWP::P|UR_IMP`'s live contents directly.
- Tried acquiring `SWP.SECURE` (and even `SWP.GOV`) directly from bare top-level code with the admin
  keyset used throughout this REPL suite: both attempts hit
  `"Module admin necessary for operation but has not been acquired: ouronet-ns.SWP"` — the same Pact 5
  foreign-module-admin rule already confirmed for C13/H9. `SECURE` is itself `(defcap SECURE () true)` —
  identical shape to C13's `P|SWPLC|CALLER` — and is equally unforgeable from outside the module.
- **Conclusion: there is genuinely no way to reach `XE_UpdateSupplies` from outside the trusted
  peer-module graph.** Every real caller in the codebase (`SWPU`, `SWPL`, `SWPLC`) reaches it from
  *inside* one of those already-granted peer capabilities. This is stronger evidence for "not reachable
  today" than the original finding's own framing (`PLAUSIBLE reachability`) — I actively tried to break
  in from outside and hit a real, confirmed wall, not just failed to find a path.
- **Worth recording as a connection to C2:** the most plausible *legitimate* route that could have driven
  a negative `new-supplies[idx]` was an oversized swap whose output exceeded the pool's reserve — exactly
  **C2**'s bug (now fixed earlier this round). Before the C2 fix, `UC_ComputeY` could return an output
  larger than the pool's balance, which would have flowed straight into `XE_UpdateSupplies` via the
  legitimate `SWPU::XI_Swap` → `XE_UpdateSupplies` path with a genuinely negative resulting balance for
  the output token. Fixing C2 already incidentally closed off the main practical route into H12 too — this
  fix is now closing what was already a secondary layer, not the primary exposure.

**Verification performed (regression, not adversarial — the adversarial angle isn't constructible as
established above):**
1. Default suite (`Z.repl`, issuance-only path): exit 0, 0 `FAILURE`, `Load successful`.
2. Temporarily switched to the full `[6.2]_DPTF.repl` + `[6.3]_SWP.repl` suite — real swap execution,
   real `XE_UpdateSupplies` calls through the legitimate `SWPU` path with real (always-positive, since C2
   is fixed) values: exit 0, 0 `FAILURE`, `Load successful`. Toggle reverted afterward (diff confirmed
   clean).

**Status:** FIXED — code-level correctness verified by direct review (matches the already-proven C7
idiom exactly) and by full-suite regression (no legitimate call path broke). No permanent new REPL test
added, since a genuine adversarial reproduction against this specific defcap isn't constructible from
outside the trusted peer-module graph — attempted and confirmed blocked, not simply not attempted.

---

## H11 (#17H, SWPLC `can-add` gates both deposits and removals) — **CONFIRMED, FIXED, PROVEN**

**Owner's position:** the combined switch was intentional — designed as a single "pause liquidity
provisioning" lever. The open question was whether that was still the right call, deferred pending
research on industry practice.

**Research before deciding, not guessed:** sent a research pass on how production AMMs handle this exact
question. Findings, all primary-sourced:
- **Uniswap** (V2/V3): core pools have no pause mechanism at all — not directly comparable, but the
  baseline "gold standard" has zero admin power over liquidity ops.
- **Curve**: `kill_me` blocks `add_liquidity` and priced exits (`remove_liquidity_imbalance`,
  `remove_liquidity_one_coin`), but the plain, pro-rata `remove_liquidity` has **no kill check at all** —
  structurally exempt, not just policy.
- **Balancer**: pause blocks everything, but a separate Recovery Mode exit **becomes permissionless
  specifically while paused** — Balancer's own stated rationale: "so that funds can never be locked by
  governance action."
- **Security-audit consensus**: Trail of Bits' maturity criteria require privileged actors not be able to
  "trap funds in the protocol"; ConsenSys Diligence's circuit-breaker guidance frames emergency pause as
  "the only action now active is a withdrawal." Real incidents (Multichain froze withdrawals before
  losing $126M+; Solend's community reversed an emergency-powers vote within a day) show this is a
  reputational/trust red line, not just a theoretical concern.
- **Verdict, converged on independently by both production AMMs that actually solved this:** pause new
  deposits freely; existing LPs' proportional exit must never be blockable by the same switch.

**Owner's decision, after reviewing the research:** agreed — `can-add` may legitimately pause new
deposits, but must never be able to strand existing LPs' own principal; that would not be fair to users
who already own LP. Directed: ungate removal from the switch entirely.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact`, `UEV_RemoveLiquidity`:** removed the `can-add`
read/enforce entirely. Removal now depends only on genuine validity checks (LP amount format, not
exceeding actual outstanding supply) — never on the pool owner's add-liquidity switch. Matches the Curve
model (structural exemption, not a conditional policy check).

**Reproduction and verification, against the real production call chain — `REPL/Stage_01/[6.2+3]_DPTF-
SWP_Issuance-Only.repl`, new `SWP|TX 022 - H11 Reproduction: can-add Never Blocks Removal`:** real pool
(pool1, `W|DLK|OURO|DWK`), real Talos entrypoints (`TS01-C3::SWP|C_ToggleAddLiquidity`/
`C_AddLiquidity`/`C_RemoveLiquidity`), real patron LP balance (10,000,000.0 from genesis issuance).
1. **Adversarial proof:** surgically reverted only the `can-add` check inside `UEV_RemoveLiquidity`
   (matches the by-now-established isolate-the-single-change pattern), reran `Z.repl` — the real
   `TS01-C3::SWP|C_RemoveLiquidity` call for patron's own legitimately-owned 100,000 LP threw
   `"Liquidity Adding and Removal isn't enabled on pool W|DLK-98c486052a51|OURO-98c486052a51|DWK-
   98c486052a51"` — the exact old error message, from the real call chain (`TS01-C3` →
   `SWPLC::C_RemoveLiquidity` → `SWPLC|C>REMOVE_LQ` → `UEV_RemoveLiquidity`), not a synthetic repro.
2. Restored the fix, reran: `can-add=false` still correctly blocks a *new* deposit (`Expect failure:
   Success`), and the *same* removal that failed above now succeeds — patron's LP goes from
   `10000000.0` to `9900000.0` (the 1% removed), live, through the real call chain. Toggle restored to
   `true` afterward so nothing downstream is perturbed.
3. Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — verified against the real production entrypoints and a real LP
balance, not a synthetic construction; both the "still blocks new deposits" and "no longer blocks
removal" halves confirmed live, pre- and post-fix. Interface unchanged — `UEV_RemoveLiquidity`'s
signature is the same, only its body shrank; no `SwapperLiquidityClientV1` version bump needed (the
originally-considered `can-add`/`can-remove` split wasn't necessary once the decision was "always allow
removal" rather than "add an independently-toggleable removal gate"). Awaiting Round III re-verify.

---

## H6 (#18H, SWP `A_DefinePrimordialPool` reads `primality` but never enforces it) — **CONFIRMED, FIXED**

**Owner clarified what `primality` actually is** (I'd only inferred "eligibility flag" from code, not the
full intent): set once, permanently, at pool issuance (the `p:bool` param); means a pool is exempt from
low-liquidity gates and can never be autonomously disabled. Also clarified two structural facts I hadn't
verified: no one can issue a duplicate pool sharing the same token set, and non-OURO/non-LKDA issuance
requires genuine token ownership — meaning the practical risk is low, "already done correctly on
mainnet," but still worth fixing. Directed: just add the boolean to the enforce fold.

**Verified the structural claims directly, not accepted on description alone:**
- Searched the whole codebase for `primality`/`UR_Primality`: **zero other read sites** anywhere besides
  this one cap and the issuance-time write — the low-liquidity-gate-exemption/never-autonomously-disabled
  semantics the owner described are the *intended* meaning, not something currently wired up elsewhere to
  cross-check against.
- Confirmed the REPL fixture's own primordial pool (`pool1`) really was issued with `p=true`, so the fix
  wouldn't break existing designation.
- **Confirmed the uniqueness claim empirically, and it's stronger than either of us assumed:** tried
  constructing a live adversarial "lookalike" pool (same OURO/WKDA/LKDA tokens, different order, p=false)
  to prove the pre-fix hole live. Hit `"Pool already exists for given Tokens!"` from
  `SWP::UEV_New`/`UEV_CheckAgainstMass` (`15_SWP.pact:1058-1122`) — traced the check: it compares token
  **sets** via pure `contains`-based membership (`UEV_CheckAgainst`), not positional/string equality, so
  it's completely order-independent. Once the real 3-token pool exists, **no second pool sharing that
  token set can ever be issued, in any order, with any weights.** The only theoretical exposure was a
  one-time bootstrap-race window (front-running the very first OURO|WKDA|LKDA issuance) — already closed
  on mainnet since the real pool was issued first, matching the owner's own risk assessment exactly, now
  with a concrete mechanism behind it rather than just an assertion.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, `SWP|C>DEFINE-PRIMORDIAL-POOL`:** added `primality` to
the existing `fold (and)` list: `[iz-weigthed has-ouro has-wkda has-lkda iz-three primality]`. One
boolean, matching the pattern already used correctly elsewhere in this cap. No interface change.

**Verification — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, new `SWP|TX 023 - H6 Reproduction:
Primality Gate on Primordial-Pool Designation`:** since a live adversarial reproduction against the
current, populated pool set is structurally impossible (established above), verification is regression-
only: confirmed the real, `primality=true` pool can still be (re-)designated with the new check in place.
Full `Z.repl`: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED — one-line fix, code-level correctness plus regression confirmed. Full adversarial
reproduction against a live pool isn't constructible (mass-uniqueness prevents the prerequisite state from
ever existing), same honest-about-the-limit pattern as H12; the attempt itself surfaced and documented a
real, useful structural guarantee (`UEV_CheckAgainstMass`) that wasn't explicitly verified before. Awaiting
Round III re-verify.

---

## C6 (#13C, SWPT graph node-envelope narrower than live edge-set) — **CONFIRMED, FIXED, PROVEN** — combined with H4 (#19H)

Presented alongside H4 (#19H) because both live in the exact same call chain (`SWPI::URC_Hopper` →
`SWPT::URC_ComputeGraphPath`/`URC_MakeGraph` → `URC_TokenNeighbours`/`URC_Edges`) and a correct fix for
one is structurally entangled with the other. Owner directed the design after three corrections during
discussion: (1) SWPT/SWP deploy order only matters for fresh REPL loading, not for upgrading already-live
mainnet modules — no need to treat it as a hard blocker; (2) no artificial gas-budgeted max-hop constant —
the pool architecture's principal-anchoring already provides a real, natural hop bound; (3) no bounded
retry loop in `URC_Hopper` — Pact is Turing-incomplete, "how many retries are enough" is unknowable in
general. Owner's own proposed direction: filter to active (`can-swap=true`) pools up front, once, and
route over that filtered set in a single BFS pass.

**What the fix actually required — deeper than the first attempt.** Filtering the top-level `swpairs`
argument fed into `URC_ComputeGraphPath`/`UC_MakeGraphNodes` closes the *node*-envelope side. But
`URC_TokenNeighbours`/`URC_TokenSwpairs` (and, downstream, `URC_Edges`/`SWPI::URC_BestEdge`) don't take
that argument at all — they read the live `SWPT|Tracer` table directly, entirely bypassing whatever
universe the caller asked for. This was caught by testing, not by static review: the first pass compiled
and passed the existing suite, but crashed for real (`Array index out of bounds`) the moment an actual
adversarial scenario (disabled parallel pool) was constructed — see H4's entry below for that half, and
the full mechanism trace.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`, `UC_MakeGraphNodes`:** dropped the old ≤1-hop
filter (`UC_FilterOne swpairs input-id` / `output-id`); nodes are now built from every token appearing
across the *entire* passed-down `swpairs` list. `input-id`/`output-id` stay in the signature, unused —
zero interface change. This makes the node envelope equal to "every token reachable in whatever universe
the caller specified," which is exactly what BFS's edge-derivation needs to match.

**Reproduced live, adversarially, isolated from every other change in the same files:** built a genuine
4-hop chain with previously-unpooled tokens (`S|OURO|AG`, `S|AG|AL`, `S|AL|AU`, `S|AU|BI`, `S|BI|CO` —
`[6.2+3]…repl` `SWP|TX 024a-e`/`025`), then temporarily reverted *only* this one function back to the old
≤1-hop filter (nothing else touched). Result: the bug surfaces even earlier and more severely than the
original finding predicted — pool issuance itself breaks, because `UEV_Issue`'s DLK-connectivity check
(which also routes through the graph) can no longer see `AU` (3 hops deep):
```
No connection to DLK detected for AU-98c486052a51. Create a W or P Pool first with it!
```
Restored the fix, re-ran: issuance succeeds, and `SWP|TX 026` confirms the full 5-node chain
`[AG, AL, AU, BI, CO]` is discovered intact via `URC_HopperActive`, 4 real edges, no `BAR` sentinel
anywhere in the result.

**Status:** FIXED ✅ AND PROVEN ✅ — see combined write-up and full diff in `ROUND-02-FIXES.md` Fix #10
(covers this, H4, and H2 together — one connected fix, adversarially proven for each). Awaiting Round III
re-verify.

---

## H4 (#19H, SWPT routing never filters disabled pools, no fallback) — **CONFIRMED, FIXED, PROVEN** — combined with C6 (#13C)

**What actually closes this turned out to need two layers, not one — found by testing, not assumed.**
Layer 1 (filter which pools are even candidates): new `SWP::URC_ActiveSwpairs` (filters `URC_Swpairs()` to
`can-swap=true`), and a new `SWPI::URC_HopperActive` entrypoint that routes only over that filtered set.
`SWPI::URC_Hopper` itself is **left unfiltered** and kept for internal issuance-time pricing
(`URC_WorthDWK`, `UEV_Issue`'s DLK-connectivity check) — those calls happen *before* a pool (or its
neighbors) may even be swap-enabled yet, and reverting them to active-only during Layer-1 development
immediately broke real issuance transactions with an empty-swpairs crash inside
`UC_PoolTokensFromPairs`. `SWPU`'s four real execution/quote call sites (`SWPU|X>SMART-SWAP`,
`UDC_SpawnSmartSwapSlippageBounds`, `XI_SmartSwapRouter`, `XI_Pumpdate`) were switched to
`URC_HopperActive`.

**Layer 1 alone was not enough — adversarial testing caught it.** Built a shortcut pool `S|AG|CO` (1 hop)
parallel to the 4-hop chain from C6/#13C's fix, enabled it, then disabled it and asked
`URC_HopperActive(AG, CO, …)` to route. With only Layer 1 in place, `URC_BestEdgeFiltered` correctly
found zero active edges directly between `AG`/`CO` — but BFS had *already* treated them as adjacent nodes
in the discovered path, because `URC_MakeGraph`'s node/link check only verified "is this token a valid
node somewhere" (true — `CO` has other active pools), not "does an active edge exist *between this
specific pair*." Crashed with `Array index out of bounds` inside `URCX_BestEdgeOf`. **Layer 2:**
`URC_MakeGraph`'s link computation now requires a genuine `URC_EdgesActive` match between each node and
candidate neighbor, not just neighbor-token membership in the node set — this subsumes the membership
check (a real edge implies both endpoints are valid nodes) and closes both problems with one condition.
New `SwapTracerV1`-additive `URC_EdgesActive`, and `SwapperIssueV3`-additive `URC_BestEdgeFiltered`
(shares its selection core with the existing `URC_BestEdge` via new internal `URCX_BestEdgeOf`).

**Reproduced live, adversarially:** with the shortcut active, temporarily reverted `URC_HopperActive`
to route over the *unfiltered* full swpair set (simulating "no fix at all"). Disabled the shortcut,
queried `AG->CO`: routing **still picked the disabled shortcut** —
`edges: ["S|AG-98c486052a51|CO-98c486052a51"]`, `nodes: [AG, CO]` — the exact H4 failure scenario,
reproduced against real pool state, not asserted. Restored the fix, re-ran: routing correctly falls back
to the active 4-hop chain, the disabled shortcut never appears in the result (`SWP|TX 028`).

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #10 for the full diff and all three
adversarial proofs (this, C6/#13C, and H2/#20H — closed as a byproduct, see its own entry below).
Awaiting Round III re-verify.

---

## H2 (#20H, `URC_ComputeGraphPath` crashes instead of returning a clean no-path result) — **CONFIRMED, FIXED, PROVEN** — closed as a byproduct of C6/H4

Not originally scheduled for this turn (findings are presented in ranked order, and #20H comes after
#19H) — folded in explicitly rather than deferred, because the C6/H4 fix makes "no active path exists"
a normal, expected outcome for the first time (previously #13C's corruption bug masked how often this
line would actually be hit). Leaving `(at 0 fp)` bare while rewriting everything around it would have
just traded one crash for another under a newly-legitimate trigger. Flagged this explicitly before fixing
rather than silently bundling it in.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`, `URC_ComputeGraphPath`:**
```diff
-                    (at 0 fp)
+                    (if (> (length fp) 0) (at 0 fp) [BAR])
```

**Reproduced live, adversarially — and the first attempt at a repro scenario was wrong, caught by
testing.** First scenario (disable every pool touching `AG`/`CO` including `S|OURO|AG`) made `AG` a fully
isolated node — `URC_AllGraphPaths` returns `[[BAR]]` (the "nothing at all" sentinel) which short-circuits
*before* reaching the `(at 0 fp)` line at all, so reverting the guard didn't crash. Real reproduction needs
BFS to find *some* chains that never reach `output` specifically: left `S|OURO|AG` active (so `AG` stays
richly connected to the wider live graph through OURO's many other pools) and disabled only the pools that
could ever reach `CO`. With the guard reverted, this crashes exactly as predicted:
```
Array index out of bounds. Length (0), Index (0)
  at (at 0 fp)  — 14_SWPT.pact:324
```
Restored the guard, re-ran: `URC_HopperActive(AG, CO, …)` returns the clean empty-Hopper sentinel
(`nodes: []`), no crash (`SWP|TX 029`).

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #10. Awaiting Round III re-verify.

---

## C4 (#11C, `UEV_Issue` never validates individual pool weights are non-zero) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** fix it, floor at 0.1 — matching the bound already decided for post-issuance reweights
(`SWP|S>WEIGHTS`, C7/#8C's fix).

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`, `UEV_Issue`:** the existing weight-precision `map`
computed `(= (floor w fee-precision) w)` per weight and **discarded the result** — dead validation, the
same pattern independently flagged as H5/#23H, living in exactly this map. Wrapped it in a real `enforce`
and added the `>=0.1` floor to the same condition, one change closing both C4 and H5's duplicate in this
function:
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

**Reproduced live, adversarially — and the revert surfaced a sharper, more useful result than the
finding's own description.** New `SWP|TX 030` in `[6.2+3]…repl`: attempted issuing `W|OURO|CU|RU` (previously
unpooled tokens) with `[0.9, 0.1, 0.0]` and separately with `[0.85, 0.1, 0.05]`. Reverted only this one map
back to the dead-validation original, reran:
- The literal `0.0`-weight attempt **still failed** even reverted — something else downstream (a real
  division-by-zero, matching the finding's own "permanent div-by-zero" framing) already aborts on exact
  zero, just with no clean validation message pointing at the real cause.
- The `0.05` attempt — below the intended floor but not literally zero — **succeeded outright** and issued
  a real, live, badly-conditioned pool. This is the sharper half of the bug: not "creates a pool that then
  crashes on first touch" but "creates a pool that never crashes and is simply badly conditioned/exploitable
  the whole time it exists," pre-fix, with zero on-chain signal anything is wrong.

Restored the fix, reran: both attempts correctly rejected, and a legitimate `[0.5, 0.3, 0.2]` issuance still
succeeds end-to-end (real pool + LP token minted). Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #11. Also closes H5/#23H's duplicate
instance in this same function (not its own turn, but the identical dead-map pattern, same fix). No
interface change. Awaiting Round III re-verify.

---

## H5 (#23H, `UEV_Issue` weight-precision validation computed and discarded) — **CONFIRMED, FIXED, PROVEN** — closed as a byproduct of C4 (#11C)

Not its own turn (ranked well after where the pass currently is) — but H5's finding location
(`16_SWPI.pact:1255-1261`, the discarded `map (lambda (w) (= (floor w fee-precision) w)) weights`) turned
out to be **exactly** the map C4/#11C's fix touches — there was no way to fix #11C without also fixing
this. Logged explicitly here, same turn, rather than left showing `_pending_` once it no longer is —
that's the entire reason the HARD RULE at the top of `README.md` exists.

**Fix + proof:** identical to C4/#11C's entry above — same diff, same `SWP|TX 030` reproduction. No
separate work performed or needed.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #11. Awaiting Round III re-verify.

---

## C5 (#12C, genesis issuance never validates every pool-token's initial reserve is non-zero) — **REFUTED**

**Owner pushback:** a 0-amount transfer can't happen — issuance requires moving a non-zero amount of
every pool token, and that's already gated the same way an ordinary transfer is.

**First response was wrong — traced one layer too shallow, corrected on the second pass.** Initially
traced `SWPI::C_Issue` → `TFT::C_MultiTransfer` → its own guarding defcap, `DPTF|C>MULTI-TRANSFER`
(`09_TFT.pact:319-369`): that defcap only checks list-uniqueness, length-parity, dispo-locker,
receiver-ownership, transferability, and per-token pause/freeze/move-role state — no amount check
anywhere in it, and `UEV_MoveRoleCheck` (called inside it) doesn't even take `amount` as a parameter.
Concluded from that alone that no amount validation existed on this path. Wrong — stopped before the
actual debit.

**Second pass, deeper:** `C_MultiTransfer`'s fold calls `XB_DebitTrueFungible` once per token
(`05_DPTF.pact:2566`), and *that* function composes its **own**, separate capability:
`DPTF|C>DEBIT` (`05_DPTF.pact:742`) — whose very first line is `(UEV_Amount id amount)`. `UEV_Amount`
(`05_DPTF.pact:1380`) enforces both decimal-precision conformance and `(> amount 0.0)` — the exact same
gate an ordinary single transfer goes through, just reached one defcap deeper than the first trace went.
Confirmed this call is unconditional (not gated by `wipe-mode` or anything else), confirmed
`SWPI::C_Issue` calls `C_MultiTransfer` for genesis liquidity **unconditionally** — `p` only skips the
separate spawn-limit *worth* check, never the actual fund transfer — and confirmed the MTX-SWP defpact
issuance path (`20_MTX-SWP.pact:904`) calls the identical `TFT::C_MultiTransfer` for the same purpose.
Since the whole issuance transaction is atomic, a `0.0` (or negative, or precision-violating) reserve on
*any* pool token aborts the entire issuance before any pool ever reaches a committed state with it — on
both issuance paths, regardless of `p`.

**Status:** REFUTED — the finding's core claim (no path validates individual token reserves are
non-zero) is false; every pool-token's genesis reserve is validated on every issuance path, via the
mandatory funding transfer's own capability chain, not via `UEV_Issue` itself. No fix needed. — *C5*

---

## H3 (#21H, principal removal permanently orphans Tracer entries) — **CONFIRMED, FIXED, PROVEN** — full architecture redesign, not a patch

**Owner design decision, arrived at through discussion, not the finding's own suggested fix
direction:** principals should only ever be *replaced*, never bare-removed, and capped at a maximum of
7 (mirroring the existing 2–7 pool-token bound `UEV_Issue` already enforces). Working through what
"replace" actually requires surfaced that a bare swap-in-place doesn't fix the underlying problem by
itself — the retiring principal's already-traced entries orphan exactly the same way under replace as
under removal, unless paired with either a real resync of every existing swpair, or forbidding replacing
a principal that already has live swpairs traced under it.

**That led to a deeper question: does SWPT need to be keyed by principal identity at all anymore?**
Walking through the actual mechanism (`SWPT.SWPT|Tracer[token].links`, one `{principal, swpairs}` entry
per principal, `SWPT.URC_TokenSwpairs` only ever looking up entries for principals in the *current*
list) showed principal-based partitioning served no remaining purpose once routing already operates over
the full swpair universe (post-#13C/#19H) — it didn't reduce storage (a multi-principal pool gets
recorded once per principal it touches — duplicated, not compressed) or reduce read cost (every read
concatenates every bucket anyway). It only introduced the fragility being discussed, plus real scaling
cost (concatenate-then-dedup across every principal bucket, on every BFS node visit, growing with total
connected-pool count for hub tokens).

**Fix — full replacement of SWPT's storage model, not a patch on top of it (#21H's actual resolution):**
- **`SwapTracerV1` → `SwapTracerV2`** (`14_SWPT.pact`). Old `Edges{principal, swpairs}` schema and the
  principal-keyed `SWPT|Tracer` table removed entirely. New `NeighbourEdge{token, swpairs}` schema and
  `SWPT|Graph` table — plain token-to-token adjacency, principal identity plays no role anywhere in
  this module's storage, keys, or reads. `URC_TokenNeighbours`, `URC_Edges`, `URC_EdgesActive`,
  `URC_ComputeGraphPath`, `URC_AllGraphPaths`, `URC_MakeGraph` all lose their `principal-lst` parameter
  entirely — a genuine interface simplification, not just an internal change.
- **`URC_MakeGraph`'s active-edge-filter logic (#13C/#19H's fix) carries over completely unchanged in
  structure** — still requires a genuine `URC_EdgesActive` match between each node and candidate
  neighbor, not just node-set membership; only *how* `URC_TokenNeighbours`/`URC_Edges` compute their
  answer changed underneath it. Same for `URC_ComputeGraphPath`'s #20H empty-result guard.
- **`XE_UpdateGraph(swpair)`** replaces `XE_MultiPathTracer` — for every pair of tokens in the swpair
  (all ordered pairs, both directions), idempotently appends the swpair to each token's neighbour entry
  for the other (creates the entry if this is their first connection; skips the append if the swpair is
  already recorded there). Called from the identical two sites as before (`SWPI::C_Issue`,
  `MTX-SWP`'s Step 3) — neither `SwapperIssueV3` nor `SwapperMtxV3` needed any interface change, since
  `principal-lst` was always fetched *internally* by both call sites, never part of their own declared
  signatures. Blast radius confirmed via full grep before starting: exactly these two call sites, plus
  three internal `SWPI` functions (`URCX_Hopper`, `URC_BestEdge`, `URC_BestEdgeFiltered`) — all
  module-body-only changes.
- **Migration utility (`SWPI::A_RebuildGraph`), for backfilling pools issued under the old
  architecture.** Deliberately placed in `SWPI`, not `SWPT` — `SWPT` deploys *before* `SWP` in this
  codebase's deploy order and can't hold a compile-time reference to `SwapperV3` in its own initial
  module body (caught by a real load failure, not anticipated in advance); `SWPI` already deploys after
  both and is already a legitimate `XE_UpdateGraph` caller. Walks `SWP::URC_Swpairs()` and calls the
  exact same `XE_UpdateGraph` normal issuance already uses, once per existing pool. A second real issue
  surfaced building this: calling `XE_UpdateGraph` from `A_RebuildGraph`'s own capability context failed
  `UEV_IMC` — the IMC check verifies a *specific* capability (`P|SWPI|CALLER`, registered with `SWPT` via
  `SWPI::P|A_Define`) is actively composed, not merely "the call originates from SWPI's module code";
  `C_Issue` satisfies it via its own cap chain (`SWPI|C>ISSUE` → `P|DT`), `A_RebuildGraph` didn't compose
  anything that did. Fixed by wrapping the migration loop in `(with-capability (P|SECURE-CALLER))`,
  matching what `C_Issue` effectively provides.

**Adversarially proven, live — `SWP|TX 031`:** ran `SWPI::A_RebuildGraph` against already-current state
and confirmed a genuinely non-empty, real route (`OURO→AG`, deliberately left active by an earlier test)
is byte-identical before and after — proving the migration is safe to re-run without duplicating or
corrupting anything, the core safety property required for a function meant to run exactly once, blind,
immediately after a mainnet upgrade.

**Every existing #13C/#19H/#20H/#11C adversarial proof (`SWP|TX 026/028/029/030`) was re-run against the
full redesign and produced byte-identical results** to before the storage change — confirming the new
architecture preserves every prior guarantee while eliminating the principal-keying fragility structurally,
not by patching around it.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #12 for the full diff. Note: this closes
#21H's actual bug (orphaning is now structurally impossible, since nothing is keyed by principal identity
at all) independent of whether the retiring principal is removed or replaced. The owner's separate
"replace-only, capped at 7" *policy* layer on `SWP::A_UpdatePrincipal` itself — no longer required to fix
this finding, since the underlying fragility is gone, but still wanted for operational discipline — is
**not yet built**; that's the natural next turn if still desired. Awaiting Round III re-verify.

---

## H3/#21H follow-up — "replace-only, capped at 7" policy layer — **BUILT AND PROVEN**

The policy layer flagged as "not yet built" above, now landed. Owner direction: cap principals at 7
(mirrors `UEV_Issue`'s existing 2–7 pool-token bound); standalone removal stays permanently disabled
(`SWP|C>PRINCIPAL` already unconditionally rejects `add-or-remove=false`, from #21H's own fix); the only
way to retire a principal is a new atomic rotate.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:**
- `SWP|C>PRINCIPAL` defcap: added `(enforce (< current-count 7) ...)` on the add path, plus a
  not-already-present guard (`A_UpdatePrincipal` had no such check before — calling it twice for the
  same token would have silently duplicated it in the list; closed as in-scope hardening while already
  touching this exact validation).
- `A_UpdatePrincipal`'s body simplified — the remove branch is unreachable now that the defcap
  unconditionally rejects `add-or-remove=false`; removed rather than left as misleading dead code.
- New `SWP|C>ROTATE-PRINCIPAL` defcap + `A_RotatePrincipal(old, new)`: atomic, count-preserving
  replacement — `old` must currently be a principal, `new` must not already be one, they must differ.
  Both additive to `SwapperV3`'s interface, no version bump needed.
- `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`: new `SWP|A_RotatePrincipal` wrapper, mirroring the
  existing `SWP|A_UpdatePrincipal` pattern, additive to `TalosStageOne_AdminV1`.

**Adversarially proven, live — `SWP|TX 032-035` in `[6.2+3]…repl`:**
- Added 5 principals to reach the cap of 7 (2 → 7); an 8th (`RE`) correctly rejected; standalone removal
  (`add-or-remove=false`) correctly rejected — both reverted (removed the whole guard block) and
  reconfirmed both unexpectedly succeed pre-fix, restored, reconfirmed both rejected post-fix.
- Rotate-specific rejections proven: rotating a non-principal, rotating into an already-existing
  principal, rotating a principal into itself.
- **The real end-to-end proof:** issued a genuine pool (`P|HG|TE`) anchored to a freshly-added principal
  (`HG`), confirmed the route between them is real and non-empty (not a trivial `[]`), rotated `HG → TI`,
  and confirmed the *exact same route* is byte-identical after rotation — proving #21H's principal-agnostic
  `SWPT` storage genuinely makes rotation harmless to existing routing, not just in theory. Also confirmed
  a *new* pool can no longer anchor to the retired `HG` (fails the existing `iz-principal` issuance check)
  but *can* anchor to the new principal `TI`. Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #13. Awaiting Round III re-verify.

---

## H3/#21H second follow-up — removal re-allowed with a 2-minimum floor; rotate-into-self split out — **BUILT AND PROVEN**

**Owner refinement to Fix #13's policy:** rotating a principal into itself must be its own explicit,
distinct rejection (not bundled with the "already exists" check) and gated by the same module-admin
capability as `A_UpdatePrincipal` — verified this was already true (`SWP|C>ROTATE-PRINCIPAL` already
composed `GOV|SWP_ADMIN`, identical to `SWP|C>PRINCIPAL`), but the two conditions were combined into one
`fold (and) [...]` enforce, which also violated this codebase's own 2-condition convention
(`(enforce (and p q) msg)`, not `fold`, for exactly 2 booleans) — split into two separate, clearly-
messaged enforces. Separately: standalone removal should be **re-allowed** — since #21H's storage
redesign already makes removal harmless (`SWPT` is principal-agnostic, nothing orphans), the earlier
"replace-only" restriction was pure caution that's no longer warranted — but must never drop the count
below 2, so `SWPI::UEV_Issue`'s principal-anchoring validation always has somewhere real to anchor a new
pool.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:**
- `SWP|C>ROTATE-PRINCIPAL`: split the combined `fold` into two distinct enforces —
  `(enforce (!= old new) "Cannot rotate a principal into itself")` and a separate "already a principal"
  check.
- `SWP|C>PRINCIPAL`: removal path re-enabled, gated by `(enforce (> current-count 2) ...)` — current
  count must exceed 2 for a removal to be allowed (leaving at least 2). Pact's parser rejected
  `(let () ...)` for sequencing two enforces per `if` branch (empty binding lists aren't valid here) —
  used `(and (enforce ...) (enforce ...))` instead, which sequences correctly since `enforce` returns
  `true` on success and aborts the whole transaction on failure either way.
- `A_UpdatePrincipal`: removal logic restored (was deleted as "dead code" in Fix #12 when removal was
  still permanently blocked) — the old empty-list special case (`pp = [BAR]`) is no longer reachable
  since the 2-minimum floor guarantees the list can never empty out via this path.
- `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`: both `SWP|A_UpdatePrincipal`/`SWP|A_RotatePrincipal`
  docstrings corrected (no longer claim removal is disabled).

**Adversarially proven, live — `SWP|TX 033` rewritten:** drained all 5 disposable test principals from
Fix #13's setup (7 → 2, touching only test-only tokens — the 2 genesis principals other tests depend on,
`OURO`/`SilverStoa`, are never removed), proving removal genuinely works now; attempted removing `OURO`
at count=2 — correctly rejected by the floor; restored all 5 back to 7 so the later rotation test's setup
(`HG` needs to still be a principal) is unaffected. Floor guard reverted (loosened to `> 0`) and
reconfirmed the same `OURO`-at-count-2 removal unexpectedly succeeds pre-fix; restored, reconfirmed
rejected. Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #14. Awaiting Round III re-verify.

---

## H7 (#22H, two unreconciled asymmetric-deficit pricing models stack in Standard mode) — **DESIGN, confirmed intentional**

**Owner:** by design — both charges are intended to stack, and they only ever apply to the asymmetric
portion of a deposit, not the whole thing.

**Verified before accepting, not taken on description alone.** Confirmed `SWP|C_AddLiquidity` (Standard
mode) does call `URC|KDA-PID_CLAD` with both `asymmetric-collection=true` and `gaseous-collection=true`
(`18_SWPLC.pact:556`), and that both `gaseous-ignis-fee` and `deficit-ignis-tax`/`special-ignis-tax`/
`lqboost-ignis-tax` do get charged together in the same transaction (`17_SWPL.pact`, `s-ico1` at
663-668 concatenates `ico-gaseous` alongside `ico1`, which carries the VSE-based tax sum) — the
finding's core mechanical claim holds. What determines whether that's a bug is intent, which only the
owner can confirm: closing as DESIGN.

**Confirmed the specific scoping claim, not just the general one:** both mechanisms live entirely inside
the `iz-asymmetric` branch (`17_SWPL.pact:524`) and are computed exclusively from asymmetric-specific
quantities — `gaseous-ignis-fee` from `asymmetric-lp-fee-amount`/`asymmetric-deviation`, the VSE taxes
from `URC_AsymmetricTax`'s output. Neither mechanism ever reads or taxes the balanced portion of a mixed
deposit. So the two charges are two distinct levies stacked on the same asymmetric base, not the same
deficit billed twice under two names.

**Status:** DESIGN, confirmed intentional — no fix needed, no code changed.

---

## H1 (#24H, `UC_ComputeD`/`UC_ComputeY` fixed iteration count, no convergence check) — **CONFIRMED, FIXED, PROVEN**

**Owner pushback, correctly:** "math is either correct or it isn't" — and separately, direct experience
that more iterations past the chosen count showed negligible improvement. Both needed a real answer, not
a restatement of the audit doc's own unverified claim.

**Measured directly against the real functions, not the finding's own number taken on faith.** Built a
scratch REPL calling `U|SWP::UC_ComputeD`/`UC_DNext` at the exact skew the finding cites
(`X=[500000,500,500]`, `A=85`) and compared the coded 6-iteration result against manually-folded
references at 10, 20, 50, 100, and 255 iterations. Result: **the finding's number is exactly right** —
6 iterations leaves `D` off by `0.0078` absolute from the converged value — **and** the computation is
already fully converged, bit-identical to the 255-iteration reference, by iteration 10. Ran the same
check for `UC_ComputeY`/`UC_ComputeInverseY` (11 coded iterations): already fully converged at 11,
byte-identical to 255 — confirms the owner's own testing was correct for these two.

**So the precise answer to "is the math correct":** the Newton formula itself (`UC_DNext`/`UC_YNext`/
`UC_ZNext`) is correct in all three cases — it converges to the right root. What was wrong was
specifically `UC_ComputeD`'s fixed step count, measured 4 iterations short of where its own math
actually settles at a legally-reachable skew. Not "the math is broken" — one specific hardcoded number
was measured wrong, with the exact gap shown.

**First proposed a "convergence-break" (early-exit once `|Dₙ₊₁-Dₙ| ≤ epsilon`) — owner correctly rejected
it as the same category error already made once this session for `URC_Hopper`'s retry-loop proposal:**
Pact is Turing-incomplete — there is no dynamic-length loop or early-exit-from-`fold` on a runtime
condition. Every loop's length must be a fixed number decided in advance. Withdrew it; the only real
option is a plain, static iteration-count bump.

**Owner direction:** bump to 12 uniformly — `UC_ComputeD` (6→12, closes the measured gap with 2
iterations of margin) **and** `UC_ComputeY`/`UC_ComputeInverseY` (11→12, pure margin, no measured
shortfall) — before deciding, wanted the exact gas cost. Measured directly (`env-gas`, isolated per
function): `UC_ComputeD` 58→116 gas (+58), `UC_ComputeY`'s fold 73→79 gas (+6), `UC_ComputeInverseY`'s
fold ≈79(est)→82 gas (+6). A stable swap calls `UC_ComputeD` once plus one of `UC_ComputeY`/
`UC_ComputeInverseY` once, so total added cost per swap is a flat **+64 gas**, fixed, every call,
independent of pool state — nowhere near what an unbounded/255-iteration approach would have cost.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`:** `UC_ComputeD` `(enumerate 0 5)` →
`(enumerate 0 11)` (6→12 iterations); `UC_ComputeY`/`UC_ComputeInverseY` `(enumerate 0 10)` →
`(enumerate 0 11)` each (11→12 iterations). `UC_ComputeD`'s docstring corrected (was already wrong,
claiming "5 fixed iterations" when the code ran 6 — now accurately documents 12, the measured
convergence point, and why no dynamic loop is possible).

**Adversarially proven, live — new `SWP|TX 036` in `[6.2+3]…repl`:** asserts `UC_ComputeD` at the exact
skew that exposed the gap now matches a 100-iteration reference exactly. Reverted `UC_ComputeD` alone
back to 6 iterations and reconfirmed the identical `0.0078` gap reproduces precisely
(`0.007789943067608829898242`, matching the original measurement to the last digit); restored,
reconfirmed exact convergence. Full suite: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #15. Awaiting Round III re-verify.

---

## H8 (#25H, asymmetric-deficit compensation not returned to the diluted pool's own LP holders) — **DESIGN, confirmed intentional**

**Owner:** by design — closing as a non-issue.

**Verified before presenting.** Traced `XE|KDA-PID_AddLiqudity` (`17_SWPL.pact:1743-1867`) end to end:
all collected deficit/special/lqboost IGNIS goes to `SWP|SC_NAME` (general treasury), special-fee-target
accounts, or the *primordial* pool's own reserves (Liquid Boost) — never back into the specific swpair
being diluted. This is the surviving, narrowed half of #1C (refuted earlier this round): the deficit is
genuinely priced and charged (refuting #1C's "unpriced extraction" framing), it's just that the payment
compensates the protocol/ecosystem generally, not the specific pool's own LP holders who bore the
dilution in native-share terms.

**Status:** DESIGN, confirmed intentional — no fix needed, no code changed.

---

## M9 (#26M, slippage bound is symmetric — min and max — not a pure floor) — **CONFIRMED, FIXED, PROVEN**

**Owner pushback:** "I thought slippage was supposed to protect both ways — what is the industry
standard?" Genuine, substantive question — needed real research, not a restatement of the finding's own
claim.

**Researched properly before answering — 5 parallel, independently-sourced threads, zero
counter-examples:**
- Uniswap V2 (`swapExactTokensForTokens`): `amountOut >= amountOutMin` — floor only, confirmed directly
  from `UniswapV2Router02.sol`/`UniswapV2Pair.sol` source, no ceiling anywhere in the swap path.
- Uniswap V3 (`exactInputSingle`/`exactInput`): `amountOut >= amountOutMinimum` — floor only, confirmed
  from `SwapRouter.sol`. `sqrtPriceLimitX96` is a price-impact limiter (can cause a *partial fill*), not
  an output ceiling — explicitly distinguished via Uniswap's own docs.
- Exact-output swaps (V2/V3): the mirror case — `amountIn <= amountInMax`/`amountInMaximum` — ceiling
  only, confirmed from source. No minimum-input bound exists anywhere; overpaying is capped, underpaying
  is impossible to check (the router computes the minimal input itself).
- Curve, Balancer V2, SushiSwap, PancakeSwap: same floor-only pattern confirmed directly from source in
  every case (`min_dy`, `limit`, `amountOutMin`) — zero counter-examples across five independently-checked
  protocols.
- Precedent search for "is a ceiling ever deliberate": none found. Stronger — the industry has a name for
  this exact scenario, "positive slippage," and treats it as value to capture or pass through: 1inch/
  KyberSwap retain it as disclosed revenue (trade still executes), ParaSwap Delta only fees the excess
  (trade still executes), CoW Protocol and UniswapX are explicitly architected to *maximize* trader
  surplus. No audit (Trail of Bits, OpenZeppelin, Consensys Diligence, Cyfrin, Sherlock, Code4rena) flags
  a missing ceiling as a vulnerability — the recurring finding in all of them is a missing *floor*.

**Verdict:** symmetric bounds around expected output, for an exact-input swap, has no legitimate
precedent anywhere checked — it's specifically the reverse of how every major AMM works, not an
alternate valid convention.

**Owner direction:** don't drop the upper-bound code, comment it out with a clear local explanation, and
be careful not to disturb the floor check while doing it.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`, two call sites** (`XI_SmartSwapRouter` and
`XI|KDA-PID_Swap` — confirmed via full-codebase grep these are the *only* two consumers of
`UC_SlippageMinMax`'s output; `UC_SlippageMinMax` itself untouched, both `min` and `max` are still
computed and returned since `max` is still used in the error-message text): the `(<= ... max)` half of
each `(and ...)` check commented out, not deleted, with a full explanation of the industry research and
exact instructions for reverting if ever needed.

**A real Pact 5 bug caught by testing with actual swap execution, not just load:** first attempt left the
`and` wrapper in place with only one live argument — `(and (>= feeless-final min))`. This parses and
loads fine but fails at *runtime* ("Expected Pact Value, got closure or table reference") the moment a
real swap executes through it — confirmed via the full `Z.repl` pipeline (Stage 1 + Stage 2), not the
issuance-only suite, since this code path only runs during actual swap execution. Pact 5's `and` doesn't
accept a single argument at runtime despite parsing correctly. Fixed by dropping the now-redundant `and`
wrapper entirely — with only one live condition, a plain `if` is both correct and matches this codebase's
own "1 condition → plain check" convention.

**Adversarially proven, live — new `SWP|TX 037` in `[6.2+3]…repl`, executed against the full `Z.repl`
pipeline for real swap execution (issuance-only suite doesn't exercise this code path):** constructed a
slippage object with a deliberately-understated `expected-output-amount` (80% of the real swap output)
and a tight 1% tolerance — guaranteeing the real output exceeds the old `max` bound while trivially
clearing the floor. Post-fix: swap succeeds (`38.89` output, well above the `~32.19` old ceiling).
Reverted the fix at the `XI|KDA-PID_Swap` site and reconfirmed the exact pre-fix behavior — the swap gets
soft-rejected (not a hard abort; the response embeds `"...out of Slippage bounds min of 31.55 - max of
32.19..."`, precisely matching real output `39.84` exceeding that `max`). Restored, reconfirmed success.
Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #16. Awaiting Round III re-verify.

---

## M13 (#27M, `SmartSwapNoSlippage` recomputes touched pools via a fresh post-swap BFS) — **CONFIRMED, FIXED, PROVEN**

**Original finding:** `SWP|C_SmartSwapNoSlippage` (`04_TS01-C3.pact`) independently re-ran `URC_Hopper`
*after* the swap had already mutated reserves, and used that fresh result to decide which pools get
`XE_UpdateStoaValue` calls — instead of using `(at 3 out)`, the swap's own actually-traversed edge list,
which `SWP|C_SmartSwapWithSlippage` already used correctly. If the post-swap reserve shift changed which
route BFS would now pick, genuinely-touched pools could miss their StoaValue refresh (stale until an
unrelated later op) and/or untouched pools could get a spurious update. Flagged as self-healing, not a
fund-loss bug — no accounting corruption, no funds at risk.

**Re-verified against live source before any fix:** confirmed `WithSlippage` (`04_TS01-C3.pact:777-816`)
computed a `path-edges` binding via `URC_Hopper` that was never actually used — its refresh loop already
correctly used `(at 3 out)` — pure dead code/wasted gas. `NoSlippage` (`:818-859`) computed the same
binding and *did* feed it into the refresh loop via `(distinct path-edges)` — the live bug. Also found,
new since this session's #21H/#19H redesign: both call sites were the *only two places left in the
entire codebase* still calling the unfiltered `URC_Hopper` — every live execution/quote call site in
`19_SWPU.pact` already correctly uses `URC_HopperActive`.

**Owner question:** "it needs to use hopperactive" — correct instinct that these were the last unfiltered
stragglers, but confirmed with the owner that swapping to `URC_HopperActive` would not actually close the
finding: the bug isn't (only) wrong-universe filtering, it's *timing* — a second, independent BFS query
run against reserves the swap itself just mutated. A correctly-filtered active-only BFS could still pick
a different route than what was actually swapped. Agreed fix: eliminate the second query entirely and use
the swap's own recorded execution data instead of any `Hopper` variant.

**Fix — `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact`, both Smart Swap functions:** deleted the
`path-edges`/`URC_Hopper` binding from both `SmartSwapWithSlippage` (dead-code cleanup, zero behavior
change) and `SmartSwapNoSlippage` (the live fix — its refresh loop now uses `(at 3 out)`, matching
`WithSlippage`'s already-correct pattern). `(at 3 out)` is `distinct-edges`, built in `XI_SmartSwap`
(`19_SWPU.pact:625-628`) from the exact `edges` list `XI_SmartSwapCore` iterates hop-by-hop to execute
the real swaps — cannot diverge from what was actually swapped, by construction.

**Owner direction on proof rigor:** asked for Option B specifically — force the old code to demonstrably
pick the wrong pool, then prove the new code picks correctly in the identical scenario, via purpose-built
new pools with engineered reserves rather than relying on the correctness-by-construction argument alone.

**Adversarially proven, live — new `SWP|TX 016b`-`016g` in `[6.3]_SWP.repl`:** issued two brand-new,
fully isolated pools sharing the same token pair (`OURO` — already a principal, satisfies the
first-token-must-be-a-principal anchoring rule — and a fresh test token `TSTY`, touched nowhere else in
the suite): `P|OURO|TSTY` (constant-product, reserves 1000/2000 — better rate) and `W|OURO|TSTY`
(equal-weighted `[0.5 0.5]` — mathematically identical constant-product math, different prefix so both
register as genuine parallel BFS edges) with reserves 1000/1500 — worse rate. Sized a 1500-OURO swap so
BFS picks `P|OURO|TSTY` pre-swap (feeless quote 1200 vs 900) but the swap's own price impact collapses
`P`'s rate below `W`'s for the identical amount post-swap (300 vs 900) — a guaranteed, deterministic
flip, not a hoped-for one.

Ran with the fix reverted (temporarily, surgically, in-place — not via `git stash`) first: real swap
executed 1500 OURO → 1193.59 TSTY through `P|OURO|TSTY` (confirmed via the swap's own "via 1 Swaps over 1
Pools" result text). Old code's post-swap recompute picked `W|OURO|TSTY` instead — exact bug reproduced:
`P|OURO|TSTY`'s cached StoaValue stayed at `0.0` (stale — the pool that was *actually* swapped never got
refreshed) while `W|OURO|TSTY`'s cached value was spuriously bumped to `2544.17...` (its true value)
despite never being touched by the swap.

Restored the fix, reran: `P|OURO|TSTY`'s cached value correctly became `5130.80...`, exactly matching a
fresh recompute; `W|OURO|TSTY`'s cached value correctly stayed at `0.0`, untouched. Five `expect`
assertions lock this in (swap actually executed; actually-swapped pool's cache matches fresh recompute;
that cache genuinely moved off its default, not a vacuous pass; untouched pool's cache stays at its
default; that pool's true value is genuinely nonzero, so "stayed at default" is a meaningful assertion,
not a coincidence) — all 5 pass. Full dedicated-suite load (`[6.2]`/`[6.3]`, full execution path): exit
0, 0 `FAILURE`. Default issuance-only regression: exit 0, 0 `FAILURE` (new transactions live only in the
full-suite file, zero interference). Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`,
`Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #17. Awaiting Round III re-verify.

---

## M10 (#28M, `kda-pid` snapshotted at defpact Step 0, reused unchanged at Step 1) — **DESIGN, closed**

**Owner's position:** the same price must be used throughout, because the whole multi-step flow is one
single logical event even though it's split into multiple `defpact` steps — using a different price
partway through would make the fee/tax math internally inconsistent. Intentional.

**Verified before accepting:** confirmed `PoolState` (`17_SWPL.pact:84-93`, `{A, F, X, W, LP, FT, FTP}`)
has no price field by design — the drift-detection check (`(enforce (= prev-pool-state
current-pool-state) ...)`) genuinely cannot and is not meant to cover `kda-pid`; it exists specifically
to catch AMM-side drift (reserves/weights/fees), a different and separately-protected class of staleness.
Confirmed `kda-pid` is real, price-load-bearing input (not cosmetic): `URC|KDA-PID_CLAD` feeds it into
`URC|KDA-PID_TokenToIgnis` to derive `deficit-ignis-tax`/`special-ignis-tax`/`lqboost-ignis-tax`
(`17_SWPL.pact:576-605`), computed once at Step 0 and never revisited at Step 1.

**Owner added:** the defpact already has a pool-drift detection mechanism — if pool state changes between
steps, Step 1 cannot finalize (rolls back). Correct and confirmed (the `step-with-rollback` `enforce`
above) — but this protects the AMM-reserve/weight/fee axis specifically because `PoolState` was scoped to
cover exactly that; it doesn't extend to `kda-pid` because `kda-pid` isn't part of `PoolState` at all, by
the same design choice being confirmed here.

**Same caveat flagged as H10 (#15H) — identical shape, same underlying gap:** "one logical event, fixed
price throughout" is a coherent premise, but it only holds in *practice* — not just intent — if Step 0 and
Step 1 execute close together in time. There is no TTL/expiry on these `defpact`s (confirmed — same gap
already tracked as **L68**), and the patron alone controls *when* Step 1 executes. An unbounded gap turns
"locked initiation price" into a free option: open Step 0, wait until `kda-pid` drifts to a point that
makes the tax cheaper, then finalize. That is a different exposure than "should price be allowed to
change mid-operation," and isn't closed by the one-event design premise alone — it rides on **L68**'s TTL
fix the same way H10's residual exposure does.

**Owner's final call:** close M10 as correct by design, notwithstanding the L68 linkage (identical
resolution to H10).

**Status:** DESIGN — closed. Fixed-price-across-steps is confirmed intentional; the AMM-side
drift-detection mechanism (`PoolState` equality check) is confirmed to be a deliberately different,
already-adequate guard for a different axis (reserves/weights/fees), not an oversight that happens to
miss price. The residual time-window exposure this depends on is explicitly **not** independently closed
by this verdict — it rides on **L68** (no TTL/expiry) being fixed separately, same as H10. No code
changed for M10 itself.

---

## M8 (#29M, full-drain-to-zero re-triggers genesis-ratio pricing regardless of dust left in tracked reserves) — **REFUTED**

**Owner pushback:** "if dust is left in tracked reserves, it means it hasn't been drained to zero, now
does it?" — pointing out the finding describes a self-contradictory state.

**Traced and confirmed the owner's point exactly:** the genesis-branch trigger itself is real —
`URC_LD` (`17_SWPL.pact:864-876`) does treat `current-lp-supply == 0.0` as "first depositor," pricing
against `UR_PoolGenesisSupplies`/the fixed `10000000.0` baseline instead of `UR_PoolTokenSupplies`. But
the "dust could remain when that happens" half is false. `URC_CustomLpBreakAmounts`
(`17_SWPL.pact:1494-1524`, the function computing a removal's payout) has an explicit special case:
`(if (= input-lp-amount swpair-lp-supply) swpair-pool-token-supplies ...)` — when the amount being
removed equals the *entire current LP supply*, it returns the literal current reserves, not a floored
ratio. Since LP is fungible, any removal that brings supply to exactly `0.0` is necessarily a removal of
the entire outstanding supply at that moment (nothing partial can zero out the last unit) — so that
removal always hits the exact-return branch, never the floored one. Confirmed this flows straight to the
write: `C_RemoveLiquidity` (`18_SWPLC.pact:833-876`) computes `pt-new-amounts = pt-current-amounts -
pt-output-amounts`; on a full drain these are equal, so `pt-new-amounts` is exactly `[0.0, 0.0, ...]` —
no flooring involved. Also checked every other `XE_UpdateSupplies` caller in the codebase (swap
execution, asymmetric/frozen/sleeping liquidity additions) — none decrease supply toward zero; the only
LP-burning removal path is the one just shown to be dust-free on a full drain.

**Status:** REFUTED — the finding's premise (LP supply exactly zero *and* reserves holding dust) is a
state the code structurally cannot produce: the two quantities are proven to hit zero together, by
construction, in the same write. No fix needed. — *M8*

---

## M6 (#30M, `C_ChangeOwnership` is one-phase/unilateral — no propose→accept step) — **DESIGN, non-issue**

**Owner:** not the intended attack surface this reads as — account addresses in practice are copy-pasted
or referenced via Stoic tags in the UI, not hand-typed, so the realistic typo risk this finding worries
about is far lower than the on-chain code alone suggests. The UI also previews the transaction (including
the destination) before the user signs, giving a real confirmation step — just implemented client-side
rather than as a second on-chain transaction.

**Assessed, not just accepted at face value:** the on-chain mechanics traced in the original presentation
are accurate — `C_ChangeOwnership` (`15_SWP.pact:1360-1372`) writes the new owner immediately on the
current owner's signature alone, `UEV_EnforceAccountExists` only checks the account exists, and there's
no on-chain propose/accept split. But the owner's mitigation is a genuine, complete answer to the
specific threat modeled (fat-fingered destination), not a partial one: copy-paste plus a pre-sign preview
addresses exactly the failure mode the finding describes, the same way it does for every other irreversible
single-step transfer already in this codebase (e.g. an ordinary `TFT::C_Transfer` to a wrong address is
equally unrecoverable and isn't held to a different standard) — singling out `C_ChangeOwnership` for
two-phase hardening while every other transfer stays one-shot would be an inconsistent bar, not a
principled one. No comparable residual/linked gap (unlike H10/M10's L68 dependency) — the UI-level
mitigation isn't waiting on a separate fix to be complete.

**Status:** DESIGN, confirmed non-issue — no fix needed, no code changed. — *M6*

---

## M7 (#31M, `C_EnableFrozenLP`/`C_EnableSleepingLP` have no pool-owner authorization) — **CONFIRMED, FIXED, PROVEN**

**Owner:** Sleeping LP and Frozen LP must only be triggerable by the pool owner, and once triggered it can
never be undone — that's the intended design. If it isn't so, it has to get fixed.

**Verified before fixing:** confirmed the irreversibility half was already correctly implemented — the
only writes to `frozen-lp`/`sleeping-lp` in `15_SWP.pact` set them to `true` (inside `XI_EnableFrozenLP`/
`XI_EnableSleepingLP`); the only `false` anywhere is the genesis default at issuance. No code path ever
flips either back off. Confirmed the owner-authorization half was genuinely missing, exactly as the
original finding described: `SWP|C>ENABLE-FROZEN`/`SWP|C>ENABLE-SLEEPING` (`15_SWP.pact:603-612`)
composed only `P|GOVERNING-CALLER` (a protocol-routing check — any legitimate Talos caller, not
owner-specific) — unlike the module's other ownership-gated levers (`SWP|S>RT_OWN`, `SWP|S>RT_CAN-CHANGE`),
neither called `CAP_Owner swpair`. Also confirmed real downstream consequence: `SWPLC.pact`'s
`UEV_AddDormantLiquidity`/`UEV_AddChilledLiquidity` gate the sleeping/frozen liquidity-addition paths
directly on these flags, so an unauthorized flip is a real, actionable griefing vector, not cosmetic.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`, both defcaps:** added `(CAP_Owner swpair)` to
`SWP|C>ENABLE-FROZEN` and `SWP|C>ENABLE-SLEEPING`, matching the module's own established pattern for
every other per-pool admin lever.

**Adversarially proven, live — new `SWP|TX 032a`/`032b` in `[6.3]_SWP.repl`:** used `pool5`
(`P|OURO|BUSD`, owned by `KST.ANHD`, untouched by the existing `SWP|TX 032`). With only a non-owner
(`KST.EMMA`) signing, attempted both `SWP|C_EnableFrozenLP`/`SWP|C_EnableSleepingLP` — both correctly
rejected, and (the decisive check) `UR_IzFrozenLP`/`UR_IzSleepingLP` both still read `false` — no state
mutation slipped through. With the true owner (`KST.ANHD`) signing, the identical calls succeed and both
flags read `true`.

Reverted the fix (temporarily, in-place): re-ran with the non-owner signer — the state-mutation checks
failed exactly as expected (`expected: false, received: true`) — `XI_EnableFrozenLP`/`XI_EnableSleepingLP`
write unconditionally before anything else in the call, so removing `CAP_Owner` lets the flag flip happen
regardless of who's calling; exact reproduction of the described vulnerability. Restored the fix, reran:
all assertions pass again. Full `[6.2]`/`[6.3]` suite (real execution path): exit 0, 0 `FAILURE`. Default
issuance-only regression: exit 0, 0 `FAILURE` (zero interference — new transactions live only in the
full-suite file). Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #18. Awaiting Round III re-verify.

---

## M11 (#32M, permissioned pool issuance charges IGNIS+KDA before the admin gate that can reject it) — **DESIGN, accepted — and confirmed non-live**

**Owner:** by design — Step 2 charges first, deliberately, so that once fees are collected there's an
incentive to see the pact through; if collection were the *last* step instead, a patron could walk
through every earlier step for free and simply decline to pay at the end. Also: pool issuance now fits in
a single transaction — the multi-step `MTX|C_Issue` defpact is kept only for historical, observational,
and learning purposes, not as a live path.

**Verified both halves, not accepted at face value:**
- **The incentive-ordering rationale** is a real, coherent pattern already documented in this exact file
  for the sibling `20_MTX-SWP.pact` defpacts — a `HISTORICAL NOTE` (owner, 2026-08-17, during #C9) already
  in the module's own source states the whole module exists only because of an obsolete ~150k-gas ceiling
  (StoaChain's actual live limit is ~2,000,000 gas — comfortably enough for even a 7-token issuance in one
  transaction today), and is "kept live for historical continuity ... and as a worked defpact/multi-step
  example," not as the intended production path.
- **"Should now fit in a single tx" — confirmed true and already the live path.** `SWPI::C_Issue`
  (`16_SWPI.pact:1488-1492`) is the real single-transaction issuance path, and it correctly orders its own
  `p`-gate: `SWPI|C>ISSUE`'s defcap (`:236-244`) checks `GOV|SWPI_ADMIN` *inside the defcap*, which Pact
  evaluates before the `with-capability` body (fee collection) ever runs — admin approval is required
  before any fee is charged, exactly the ordering M11 asks for. So the correctly-ordered path already
  exists and is what's actually used.
- **"Historical/observational purposes, not live" — independently confirmed, not just asserted.**
  Grepped the entire codebase: `MTX|C_Issue` (and every other `MTX-SWP` defpact — `AddLiquidity`,
  `AddFrozenLiquidity`, `AddSleepingLiquidity`) has **zero** references anywhere in `3_Talos/` or
  `0_Interfaces/`, and zero references in any REPL test outside `20_MTX-SWP.pact` itself. Per this
  codebase's own architecture ("Talos is the only supported client path... the Ouronet gas station pays
  execution only for paths defined in Talos"), this defpact is not reachable through any gas-sponsored
  client flow at all — reaching it would require a raw, unsponsored direct module call bypassing Talos
  entirely, not a realistic exposure for a normal user.

**Status:** DESIGN, accepted — the fee-before-gate ordering is a deliberate anti-abandonment incentive
pattern for defpact-style flows, and (independently, stronger than a residual-risk caveat) the specific
defpact this finding is about has no live client path at all — confirmed unreachable through the
supported architecture, not merely mitigated. No fix needed, no code changed. — *M11*

---

## M12 (#33M, explicit rollback costs strictly more than silent abandonment, no TTL on open pacts) — **DESIGN, accepted**

**Owner:** it's how it was designed. Leave as is.

**Presented with the direct connection to M11 already established:** this finding is entirely scoped to
the same four `20_MTX-SWP.pact` `step-with-rollback` blocks (`C_Issue`, `C_AddLiquidity`,
`C_AddFrozenLiquidity`, `C_AddSleepingLiquidity`) already confirmed, while closing M11, to have zero
Talos wiring anywhere in the codebase — unreachable through the only supported client/gas-station path,
consistent with the module's own `HISTORICAL NOTE` (kept for historical/observational/learning purposes
only). Confirmed the flat `100.0` IGNIS rollback-penalty pattern is accurate as described (all 4
`step-with-rollback` blocks charge it), and no TTL exists anywhere (same gap as **L68**).

**Status:** DESIGN, accepted — owner confirmed intentional. Same non-live basis as M11 applies (no live
client path exists for this module), but the owner's call here is on the design itself, not contingent on
reachability. No fix needed, no code changed. — *M12*

---

## M2 (#34M, BFS keeps only one chain per node; routing does zero cross-route value comparison) — **CONFIRMED, FIXED, PROVEN**

**Owner's first reaction:** it was supposed to find the cheapest route, and there must be a value-computation
mechanism somewhere — asked for a re-check before accepting the finding.

**Re-checked, not just re-asserted:** traced every function touching route selection. Confirmed a real
value-comparison mechanism genuinely exists — `URCX_BestEdgeOf` (already fixed earlier this session as
#C1) picks the higher-output pool among *parallel* edges connecting the same two adjacent tokens. But
that's the only value comparison in the whole path. `SWPT::URC_ComputeGraphPath` → `URC_AllGraphPaths` →
`U|BFS::UC_BFS` marks every node globally `visited` the first time it's reached, so only the
first-discovered *route* (which sequence of intermediate tokens) survives — `URC_AllGraphPaths` doesn't
return all paths despite its name, and `URC_ComputeGraphPath` (its only caller) just takes the one chain
BFS kept. Confirmed via grep this is the *only* caller — no other function ever sees the fuller candidate
set to compare.

**Explained the distinction plainly:** step 2 (which pool, given two adjacent tokens) is chosen by value.
Step 1 (which tokens to route through at all) is chosen by BFS discovery order, never by value — so
"always pick the best" was true for step 2 but not actually happening for step 1. Owner accepted this once
walked through concretely (a diamond topology where a route with a great first hop but a thin, easily-
overwhelmed second hop can lose to a route with a mediocre first hop but a deep second hop — greedy
per-hop maximization doesn't guarantee the best whole-route outcome).

**Owner's direction once convinced:** fix it, and prove the fix in the REPL.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` + `16_SWPI.pact`:** added
`SWPT::URC_ComputeAlternateRoutes` (additive to the `SwapTracerV2` interface) — finds up to 3 edge-disjoint
candidate routes by re-running `URC_ComputeGraphPath` with each previously-found route's edges excluded
from the universe, forcing genuinely different routes rather than re-discovering the same route with a
different (already-optimal) parallel pool. Fixed cap of 3 — Pact has no dynamic-length/convergence loops,
so the count has to be a number decided in advance, same constraint hit earlier this session for the
Newton-iteration count and the connectivity retry logic. `SWPI::URCX_Hopper` was split into
`URCX_HopperForNodes` (the existing per-hop best-edge computation, now taking an already-known node path)
and a new outer `URCX_Hopper` that computes the Hopper object for every candidate route and returns the
one with the highest final output via a new `UC_BestHopper`. `URC_Hopper`/`URC_HopperActive`'s public
signatures are unchanged.

**A real bug the fix's own testing surfaced, fixed defensively rather than taken on as new scope:** the
first load attempt crashed — `URC_MakeGraphNodes`/`UC_PoolTokensFromPairs` throws an out-of-bounds error
on an empty `swpairs` list instead of cleanly returning no-route (this is the separately-tracked M3
finding, not yet reviewed in this pass). The single-route old code never triggered it because it only ever
called the pathfinder once, with the full non-empty universe; this fix's exclusion-based retries are the
first caller able to legitimately exhaust the universe down to empty (a single-pool universe, after that
pool's route is excluded). Rather than take on M3's broader fix as scope creep here, guarded
`URC_ComputeAlternateRoutes`'s three calls locally — an empty `swpairsN` short-circuits to `[BAR]` instead
of ever reaching the crashing path.

**Adversarially proven, live — new `SWP|TX 032c`-`032g` in `[6.3]_SWP.repl`:** built a genuine diamond
topology, `OURO -> {TSTC, TSTD} -> TSTZ`, issuing the TSTC-side pools first (so BFS's first-discovered
route is the worse one): `OURO/TSTC` (5000/10000) into a thin `TSTC/TSTZ` (2000/2000, Stable — TSTC isn't
a principal, so this leg needed Stable's DLK-connectivity escape hatch instead of a W/P pool) versus
`OURO/TSTD` (5000/7500) into a deep `TSTD/TSTZ` (200000/200000, Stable). A 10,000-OURO smart swap:

Reverted the fix (temporarily, in-place — single-first-found-route behavior restored): the exact same
swap delivered only **1989.96 TSTZ**, confirming it took the worse (thin-second-hop) route. Restored the
fix: the same swap delivered **4906.02 TSTZ** — a genuine ~2.5x improvement, confirming it now takes the
better (deep-second-hop) route despite the worse one being discovered first. Three `expect` assertions
pin this down (swap actually executed; genuinely routed through 2 pools; delivered materially more than
half the fixed-code amount, ruling out the worse route) — all pass with the fix in place, and the
threshold-crossing assertion specifically fails when reverted. Full `[6.2]`/`[6.3]` suite (real execution
path): exit 0, 0 `FAILURE`. Default issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 +
Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #19. Awaiting Round III re-verify.

**Phase 2-13 follow-up — FIXED ✅ AND PROVEN ✅, 2026-08-22 (`ROUND-02-FIXES.md` Fix #21):** post-fix
discussion (same session) established that best-of-3 is a bounded heuristic, not a guarantee of the
*actual* cheapest route — owner's real intent is genuine exhaustive on-chain path search. That
discussion also surfaced a separate, more severe worst-case execution-gas crisis (real worst case at
realistic scale reached 6-7 million gas against the ~2,000,000 ceiling) which got consolidated into
this same issue as one 13-phase plan. All 13 phases are now complete: a dirty-read path-injection
redesign (new bundle-based `SWPU::C_SmartSwap`, measured 7,145,298 → 397,043 gas on the identical
worst-case swap, an 18.5x reduction) closes the gas crisis, and a genuine exhaustive route search
(`SWPT::URC_ComputeAllRoutes`/`SWPI::URC_HopperExhaustive`) delivers the originally-requested
cheapest-path search, proven to find routes best-of-3 structurally cannot. Full phased plan, every
design decision, the depth-vs-path-count distinction, the same-pool-detour pruning rule, the concrete
counter-example proving "shortest ≠ cheapest," and every real measurement:
`OuronetInformational/HANDOFF-swp-exhaustive-path-search.md`. Finished-mechanism write-up + client
orchestration guide: `OuronetInformational/HANDOFF-swp-smartswap-bundle-architecture.md`. Fix #19
(`CC_SmartSwap`, the renamed self-searching variant) stays live as the production fallback alongside
the new bundle-based path — whether it's ever fully retired is an explicit open decision, not made
here.

---

## #34bM (`UEV_Issue`'s Stable-pool anchoring check — direct vs. transitive connectivity) — **CONFIRMED, FIXED, PROVEN**

**Origin:** not from the original Round I sweep — surfaced organically while discussing #34M/M2's fix.
While explaining why on-chain exhaustive path search is unsafe (unbounded worst-case route count), traced
whether the pool-issuance anchoring rules structurally bound path count/length. They don't (a concrete
fan-out counter-example was walked through and accepted) — but during that discussion the owner stated
the *actual* intended design for Stable-pool anchoring precisely: "S may also have their first token a
principal, or if the first token is not a principal, it should exist in a pool where a principal exists,"
with the added constraint that "the token that is the one tied directly to a principal must be on the
first position." Checked this against the live `UEV_Issue` code and found it didn't match.

**Verified precisely, not assumed:** `UEV_Issue`'s Stable-pool branch (`16_SWPI.pact:1408-1421` at the
time) called `URC_Hopper(first-pool-token, dlk, 1.0)` — the same full multi-hop BFS pathfinder rebuilt for
#34M — targeting `DLK` specifically. Two independent deviations from the owner's stated design: (1) it
allowed *any* hop count via BFS, not direct (one-hop) adjacency only; (2) it checked connectivity to one
hardcoded token (DLK) rather than the *current* full principal list (`UR_Principals()`, up to 7 since the
cap/rotate work). Owner: "if this is not true, then this is another bug we need to fix" — assigned a
number (#34bM) and asked for the fix now, matching the stated design exactly.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`:** replaced the DLK-targeted `URC_Hopper` BFS call with
a direct-neighbour check: `SWPT::URC_TokenNeighbours(first-pool-token)` (one hop, every existing pool
regardless of active status, by design — matches how the issuance-time check has always needed to work
before pools go live) filtered against the full `principals` list. Confirmed this also correctly enforces
the "must be on the first position" requirement, since only `first-pool-token`'s neighbours are ever
checked — a principal-adjacent token elsewhere in the pool's token list does not satisfy the rule, exactly
as specified.

**A significant discovery while proving it:** the fix broke a pre-existing test fixture —
`[6.2+3]_DPTF-SWP_Issuance-Only.repl`'s `AG→AL→AU→BI→CO` chain (`SWP|TX 024b`-`024e`), built specifically
to test #13C/#19H/#20H's multi-hop BFS pathfinding (deep chain discovery, shortcut preference, disabled-
pool fallback, clean no-path failure). That chain had been relying on exactly the bug being fixed here —
each link was only ever transitively reachable to DLK, never directly principal-adjacent. Scoped this
precisely (one background investigation) before touching anything: confirmed it's the *only* fixture in
either test file affected (every other Stable pool in the suite, including #34M's own diamond-topology
pools, already anchors directly). Fixed by giving `AL`/`AU`/`BI` each a throwaway direct-`OURO` pool
(new `SWP|TX 024a2`) — deliberately never toggled swap-enabled, so `URC_HopperActive`-based BFS assertions
in `TX 026`-`029` never see them and the AG→AL→AU→BI→CO topology those tests exercise is unchanged. This
satisfies the anchoring rule *genuinely* (each link really is now directly principal-adjacent), not as a
workaround.

**Adversarially proven, live — new `SWP|TX 032h`-`032k` in `[6.3]_SWP.repl`:** built `TSTN` (directly
pooled with `OURO`), `TSTM` (pooled only with `TSTN` — 2 hops from any principal, never direct). Attempted
`S|TSTM|TSTQ` (Stable, `TSTM` first): correctly rejected with the fix in place. Reverted the fix
in-place: the identical call *succeeds* — `"expected failure, got result"` — exact reproduction of the
old bug's false-accept. Restored, reconfirmed rejection. Full `[6.2]`/`[6.3]` suite (real execution path):
exit 0, 0 `FAILURE`. Default issuance-only regression (including the repaired `AG→AL→AU→BI→CO` chain and
all of #13C/#19H/#20H's assertions passing unchanged): exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 +
Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #20. Awaiting Round III re-verify.

---

## M1 (#35M, `UC_ComputeY`/`UC_ComputeInverseY` silently drop all but the first input position on stable
      swaps) — **REFUTED**

**Owner:** "stable swap pool can only do swap from one single token to another." — the finding's premise
(a stable-pool swap with more than one simultaneous input token) is not a real, intended use case at
all; single-input is the contract, not an accidental gap.

**Traced every real call path before presenting, confirmed the owner's point exactly:** `UC_ComputeY`
(`1_Utilities/12_U_SWP.pact:46`) does read only `(at 0 (at "input-amounts" drsi))` — unlike
`UC_ComputeWP`/`UC_ComputeEP`, which correctly fold the whole `input-amounts` list via `UC_AddSupply`.
But every actual caller independently enforces `length(input-amounts) == 1` for pool-type `"S"` *before*
`UC_ComputeY` is ever reached:
- `URC_Swap` (`16_SWPI.pact:704`, the general dispatcher behind every `C_Swap`/`XI_Swap` client
  entrypoint): `(enforce (= l1 1) "Only a single Input can be used in Stable Swap")`.
- `UC_BareboneSwap` (`16_SWPI.pact:554`, the SmartSwap per-hop math): the **identical** enforce,
  independently.
Both gates predate `UC_ComputeY`'s own call — a multi-input stable swap is rejected at the door on both
paths, every time. The Inverse direction (`UC_ComputeInverseY`) doesn't even have a list to drop from:
its schema field is `input-position:integer` (singular), same as `UC_ComputeInverseWP` — the Inverse
direction is single-input **by design** across every pool type (solving for one unknown input given one
target output is well-posed; multiple simultaneous unknown inputs summing to one output isn't, without
more constraints). Confirmed with the owner: single-input is the actual product contract for stable
pools, not a limitation the forward-direction enforce works around.

**Residual, noted but not fixed here:** `UC_ComputeY`/`UC_ComputeInverseY` are `UC_*` (pure compute, no
capability gate) and have no self-defense of their own — both existing enforces live in their *callers*,
not inside the functions. Today's call graph is fully guarded; a hypothetical future caller constructing
a `DirectRawSwapInput` and calling `UC_ComputeY` directly, bypassing both `URC_Swap` and
`UC_BareboneSwap`, would silently reproduce the exact behavior the finding describes. Flagged, not
pursued as a fix — the finding is refuted on its own terms (no live, reachable bug exists), and adding a
third redundant enforce inside a `UC_*` pure-compute function would itself be a StoicSyntax violation
(`UC_*` may not `enforce`) requiring it to become `URC_*`/`UEV_*`, a bigger change than this residual
risk justifies without a live path found.

**Status:** REFUTED — the finding's premise (a stable swap with more than one input) is not a real
product scenario; the code's actual contract (single-input only, doubly enforced on every real call
path) matches owner-confirmed intended design. No fix needed. — *M1*

---

## M5 (#36M, SWPI/MTX-SWP — `C_Issue` and `MTX|C_Issue` duplicate the write-side issuance logic) — **CONFIRMED, FIXED, PROVEN**

**Owner:** use a singular core for this, called from both functions. Multi-step issuance (`MTX|C_Issue`)
is now more historical/observational — single-tx issuance is always under the real gas ceiling — but the
historical path stays live and should call the same shared core, not keep its own copy. Asked whether
that's feasible given the `defpact`'s multi-step nature, and to go ahead if so.

**Feasibility confirmed before building, not assumed:** a `defpact` `step` is ordinary Pact code — it can
freely call cross-module functions, including other `UEV_IMC`-gated `XE_*` entrypoints. Proven directly:
`MTX|C_Issue`'s own Step 3 already called several cross-module `XE_*`/`C_*` functions
(`ref-DPTF::XE_IssueLP`, `ref-SWP::XE_Issue`, `ref-BRD::XE_Issue`, `ref-SWPT::XE_UpdateGraph`) before any
of this fix's changes — so a defpact step calling one more shared cross-module function is the same
mechanism already working, not new territory.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact` + `20_MTX-SWP.pact`:** new `XE_IssueWrite` in SWPI
(forward-module entrypoint on the `SwapperIssueV3` interface) holds the one shared write sequence
(mint LP token, register pool, transfer pool tokens in, mint genesis LP supply, transfer LP out,
register the swap-tracer graph edge) — previously independently reimplemented in both `SWPI::C_Issue`
and `MTX-SWP::MTX|C_Issue`'s Step 3, including a duplicated hardcoded `10000000.0` genesis-mint
constant (now a single named `GENESIS_LP_SUPPLY`). Returns a wider list
(`[swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]`), not an `OutputCumulator` —
matching this codebase's `XE_*` convention that the calling module's own `C_` composes IGNIS — so
`C_Issue` aggregates every sub-cumulator into its own single billed response exactly as before, while
`MTX|C_Issue`'s Step 3 (already billed separately in its own Step 2) just reads `swpair`/`token-lp`.
`C_Issue` itself now delegates to `XE_IssueWrite` instead of inlining the sequence; Step 3 does the same.

**Real gap found and fixed while wiring the new call, not anticipated up front:** the first regression
run failed hard at load — `UEV_IMC`'s "None of the guards passed" — because MTX-SWP's own `P|A_Define`
had never registered MTX-SWP as an approved "Implementing Module Policy" caller on SWPI specifically
(it already registers on BRD/DPTF/DPOF/TFT/OUROBOROS/VST/SWPT/SWP/SWPL, which is exactly why the
pre-existing `ref-SWPT::XE_UpdateGraph` call from the same step already worked). MTX-SWP had simply never
before needed to call a `UEV_IMC`-gated function on SWPI directly. Added
`(ref-P|SWPI::P|A_AddIMP mg)` to `P|A_Define`, matching the module's own existing pattern exactly.

**Adversarially proven, live:** full `[6.2]`+`[6.3]` suite (real execution path, exercises
`MTX|C_Issue`'s defpact issuance via the pre-existing `SWP|TX 012b`/`012c` "Issue Stable 7xUSD via
defpact" test): before the `P|A_Define` fix, hard load failure at exactly the new call site
(`16_SWPI.pact:1820` inside `UEV_IMC`, reached from `20_MTX-SWP.pact:890`'s new `XE_IssueWrite` call) —
a genuine cross-module authorization gap, not a REPL assertion failure. After the fix: exit 0, 0
`FAILURE`. Default issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2):
exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #22. Awaiting Round III re-verify.

---

## M3 (#37M, U|SWP — unguarded `enumerate 0 -1` crashes instead of returning `[]` on empty-list inputs) — **CONFIRMED, FIXED, PROVEN**

**Owner's first reaction:** pushed back on the finding's premise rather than accepting it — "why the hell
were they constructed like this? ... i dont remember on writing broken code. i remember those functions
being valid the way they are written," and specifically questioned whether the four named functions with
no callers anywhere (`UC_AreOnPools`/`UC_FilterOne`/`UC_FilterTwo`/`UC_IzOnPools`) were really unused, or
whether a refactor had botched a rename and they're actually called under a different name.

**Checked the "botched rename" theory directly, not just re-asserted the earlier claim:** grepped the
entire repo (`.pact`/`.repl`, every directory) for the exact function names and for any bare fragment
(`FilterOne`/`FilterTwo`/`AreOnPools`/`IzOnPools`) that could catch a differently-prefixed alias. Zero
hits anywhere outside `12_U_SWP.pact` itself and its own interface declaration
(`0_Interfaces/01_Utilities.pact`). Not a naming collision — these four are genuinely declared on the
module's public interface (so a future slave module *could* call them) but nothing live in Core, Talos,
or any Slave module ever does today. Read their bodies: they're coherent, correctly-written "filter a
swpairs list to those touching a given token" utilities — not malformed, not a sign of a botched edit,
just never wired into a caller.

**Also corrected an imprecision in the original finding's own wording while re-verifying the mechanism:**
`enumerate 0 -1` does not itself error — checked directly against the real Pact binary, it returns
`[0, -1]`. The actual crash is one step later, when the enclosing `fold`/`map` does `(at 0 someList)` on
that first index against an empty list, throwing "Array index out of bounds." Same practical effect, but
the root cause is the `at`-indexing, not `enumerate`.

**Traced every real caller of all seven originally-named functions before proposing a fix, and found the
finding's own function list was incomplete:** three of the seven (`UC_PoolTokensFromPairs`,
`UC_MakeGraphNodes`, `U|BFS::UC_BFS`) share one root cause and ARE genuinely reachable — from
`SWPU|X>SMART-SWAP`'s defcap (the live, gas-sponsored `CC_SmartSwap`/Talos `SWP|CC_SmartSwap*` entrypoint)
via `SWP::URC_AllPoolTokens`, whenever `URC_Swpairs()` is `[]` — a real, achievable state: the window
before the very first pool is ever issued. No REPL test exercised that window (every existing test
creates pools first), so it had never been caught — until this same session's own #34 work incidentally
hit it for real and patched two call sites locally (`SWPT::URC_ComputeAlternateRoutes`/
`URC_ComputeAllRoutes`) while explicitly flagging the general fix as "M3, a separate tracked finding,"
deferred as scope creep at the time. Tracing the chain further (not stopping at the named functions)
found a fifth, previously-unflagged site sharing the identical pattern directly downstream:
`SWPT::URC_MakeGraph` (`14_SWPT.pact:512`) indexes its own `nodes` list the same unguarded way — fixing
only the named functions would have just relocated the crash one hop deeper instead of eliminating it.

**Owner's direction once shown the real reachable path:** fix it without breaking functionality.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact` + `13_U_BFS.pact` + `2_Core/14_SWPT.pact`:**
added a minimal `(if (= 0 (length X)) [] (fold ...))` guard at the 5 actual root-cause sites —
`UC_AreOnPools`, `UC_IzOnPools`, `UC_PoolTokensFromPairs` (all `12_U_SWP.pact`), `UCX_GraphNodes`
(`13_U_BFS.pact` — the true root of `UC_BFS`'s own empty-graph crash, since `UC_BFS` never indexes
`graph` directly itself), and `URC_MakeGraph` (`14_SWPT.pact`, the newly-found fifth site). Every other
function named in the finding (`UC_FilterOne`/`Two`, `UC_MakeGraphNodes`, `UC_BFS`, `UC_UniqueTokens`) is
a thin pass-through over one of these five and becomes safe automatically once its dependency returns
`[]` cleanly — confirmed by tracing the full chain end-to-end (an empty `swpairs` now flows all the way
through to `URC_ComputeGraphPath`'s existing `[BAR]` "no path" sentinel, the same clean-failure
convention already established by the #20H fix, instead of crashing). Zero behavior change for any
non-empty input — the guard only intercepts the length-zero case.

**Adversarially proven, live — new `SWP|TX 003b` in `[6.3]_SWP.repl`,** placed in the genuine
pre-first-pool-issuance window (after TX 001-003 wrap/coil/move tokens, before TX 004 issues the first
pool): `SWP::URC_Swpairs()` confirmed genuinely `[]` at that point (not simulated), then
`SWP::URC_AllPoolTokens()` and `SWPT::URC_ComputeGraphPath "OURO" "DLK" []` both now return clean results
(`[]` and `[BAR]`) instead of crashing. Reverted the fix (temporarily, via `git stash` on just the 3
source files, REPL test left in place): full suite failed hard at load — `Array index out of bounds` in
`UC_PoolTokensFromPairs`, called from `UC_UniqueTokens`, called from `URC_AllPoolTokens`, called from the
new test — an exact reproduction, not a soft assertion failure. Restored, reconfirmed clean. Full
`[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression (unaffected — the new TX only lives
in the full-suite file): exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`,
`Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #23. Awaiting Round III re-verify. — *M3*

---

## M4 (#38M, SWPT — `UCX_GraphNodeLinks` linear-scans the whole node list on every BFS pop) — **CONFIRMED, FIXED, PROVEN**

**Owner's questions before authorizing:** could this actually be made more efficient, would that risk
breaking existing functionality, and does the path-cache mechanism built during #34 (`SWPT|PathCache`,
`URC_ReadPathCache`) already make this moot? Directed: if you think you can optimize it, prove in the
REPL it produces the same results as the current implementation before calling it done.

**Answered all three before touching code:**
- **Path-cache relevance, checked not assumed:** traced the bundle-based `SWPU::C_SmartSwap` path built
  in #34 — its defcap does one cheap `SWPI::URC_ValidatePathActive` structural check instead of a full
  graph search ("no full-graph BFS at the defcap layer," per its own doc comment); on a cache hit, M4's
  cost genuinely doesn't fire at all anymore. But the self-searching `CC_SmartSwap` fallback — kept
  deliberately live as the production fallback — still runs the full unguarded BFS every time, and #34's
  own gas breakdown already showed graph-search calls (`XE_UpdateStoaValue`'s six per-pool searches
  alone) were 56.9% of the old worst-case total. Not obsolete, still a real live cost on a real path.
- **Root cause, re-confirmed:** `UCX_GraphNodeLinks` rebuilds the *entire* node-name list from `graph` on
  every call (`UCX_GraphNodes`, a full O(V) pass) just to linear-search it, then re-indexes back into
  `graph` by position — two full passes plus a reindex, per lookup, per BFS pop.
- **Can it be made faster without changing behavior:** yes — Pact has no O(1) hash-index over a plain
  list argument, so the asymptotic cost per lookup can't drop below O(V) without restructuring the graph
  representation entirely (out of scope here), but a single-pass `filter` directly over `graph` (matching
  the `"node"` field, same first-match tie-break as the old `UC_Search`-based lookup) removes the wasted
  rebuild pass — same correctness contract, meaningfully cheaper in practice.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact`:** `UCX_GraphNodeLinks` rewritten to a single
`filter` over `graph`, taking the first match's `"links"` field (or `[BAR]` on no match — same sentinel
as before). `UCX_GraphNodes` (its only caller) removed as dead code, not left behind as clutter.

**Adversarially proven, live — direct before/after comparison, not just "existing tests still pass,"
per the owner's own instruction:** new permanent `SWP|TX 032z2b` in `[6.3]_SWP.repl`, calling
`SWPT::URC_ComputeGraphPath` directly on the real ~102-active-pool P2-scale topology (the same worst-case
`W1`→`W7` 6-hop pair #34 already measured), isolating just the graph-search cost from swap-execution
overhead. Reverted the fix (`git stash` on just `13_U_BFS.pact`, proof TX left in place) and re-ran: same
call returned the byte-identical 7-node path (`[W1, W2, W3, W4, W5, W6, W7]`) at **423,762 gas**. Restored
the fix, re-ran: identical path, **256,867 gas — a real ~39% reduction** on this isolated call, at real
scale, not a toy topology. Full `[6.2]`/`[6.3]` suite (every pre-existing exact-value route assertion
from C6/H2/H4/M2's own fixes, which would have failed on any BFS behavior drift): exit 0, 0 `FAILURE`.
Issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`,
`Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #24. Awaiting Round III re-verify. — *M4*

---

## M14 (#39M, `0_Interfaces/03_Talos.pact` — `ClientThreeV2`/`ClientPactsV2` overwritten in place instead of archived) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** yes, fix this — the codebase's convention is to keep old interfaces around for
historical purposes and simply add the next V number for what's actually referenced live, since the
whole codebase deploys anew across all modules/interfaces regardless.

**Reconstructed from git history, not guessed:** identified the exact overwriting commit (`df2d72e`) and
pulled the full pre-overwrite text of both interfaces from its parent commit — a clean, complete,
byte-accurate reconstruction, not a re-derivation from memory or partial diff.

**Found the placement had to differ from a naive copy-paste, and verified why before writing anything:**
the finding's original premise (both interfaces living in `0_Interfaces/03_Talos.pact`, the central
registry) is itself now outdated — the architecture was restructured since the finding was written. The
central registry now holds only historical `ClientFour` versions; the *live* `ClientThreeV3`/
`ClientPactsV3` moved out to their own deploy-with-module files (`3_Talos/04_TS01-C3.pact` /
`05_TS01-P.pact`) at some point after M14 was originally filed. First attempt (archiving `ClientThreeV2`
into the central registry, matching the literal old finding text) failed to load: `ClientThreeV2`'s Smart
Swap functions type against `SwapperUsageV2.Slippage`, a module-owned interface (declared inside
`19_SWPU.pact`, not `0_Interfaces/`) that isn't deployed yet at the central registry's early
Interfaces-load point in the pipeline. Checked whether this codebase already had a working precedent for
this exact class of problem: `06_TS01-C4.pact`'s own header comment says "Prior live ClientFourV6 lived
only in this file (superseded by V7 — patronless A_RevokeLink)" for the identical reason (module-owned
`PythiaLedgerV2` dependency) — but checking the actual file found `ClientFourV6` was never actually
archived there either, just documented as should-be. Not a working example to copy, but confirmation the
intended pattern (frozen-in-the-deploy-with-module-file, not the central registry, when a module-owned
type dependency exists) was already the codebase's own stated intent — this fix is the first to actually
carry it out.

**Fix:**
- `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact` — `TalosStageOne_ClientThreeV2` (frozen, full original
  text) added ahead of the live `ClientThreeV3`, with a comment explaining why it lives here instead of
  the central registry.
- `1_SOVEREIGN/STAGE_01/3_Talos/05_TS01-P.pact` — `TalosStageOne_ClientPactsV2` (frozen, full original
  text) added ahead of the live `ClientPactsV3`, alongside its always-paired sibling rather than split
  across files even though it alone (no `SwapperUsageV2` dependency) could have lived in the central
  registry — consistency over a subtle technicality.
- `1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact` — header comment updated to point to the new
  locations and explain why, matching the existing `ClientFourV6` cross-reference style.

**Adversarially proven, live:** first placement attempt genuinely failed to load (`Module SwapperUsageV2
has no such member: Slippage`) — a real compile error, not assumed — confirming the relocation was
necessary, not cosmetic preference. After the fix: full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`.
Issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`,
`Load successful`. Purely additive/documentation — no live code path touched, nothing references the
restored names, zero functional risk by construction.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #25. Awaiting Round III re-verify. — *M14*

---

## L40 (#40L, U|SWP — `UC_LpID` calls a cross-module `UEV_*` from inside a nominally pure `UC_*`) — **CONFIRMED, FIXED, PROVEN**

**Owner direction:** go through the LOW bundle one by one; a later StoicSyntax rename sweep will close
some of these on its own — tag those, and resolve the rest individually now. Starting with L40.

**Confirmed the violation, then checked whether it was load-bearing before touching anything:** `UC_LpID`
(`12_U_SWP.pact:477`) called `U|INT::UEV_UniformList` — a real, enforce-carrying validation, confirmed by
reading its body — directly from inside a `UC_*`, breaking the "no `enforce`, even transitively" purity
contract. Traced the only real caller in the entire codebase: `SWP::URC_LpComposer` builds both
`token-names` and `token-tickers` from the exact same source list (`pool-token-ids`) via the exact same
`enumerate 0 (- l 1)` range — the two lists are structurally guaranteed identical length, every time. The
check could never actually fail on any live call path; not a naming-only issue, a genuine dead-defense
case like several already-refuted findings this session.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`:** removed the `UEV_UniformList` call and its
now-unused bindings (`ref-U|INT`, `l2`, `lengths`) from `UC_LpID`, restoring `UC_*` purity. Residual, not
pursued: `UC_LpID` is declared on the public `UtilitySwpV1` interface, so a hypothetical future caller
passing mismatched-length lists would hit a plain out-of-bounds crash inside the folds instead of a clean
enforce message — same class of residual risk already accepted in M1's own write-up, not a live path
today.

**Adversarially proven, live:** full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`. Issuance-only regression:
exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful` — matching
the prediction that this check was never reachable, since removing it changed nothing observable.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #26. Awaiting Round III re-verify. — *L40*

---

## L41 (#41L, U|SWP — `UC_*` surface transitively inherits `enforce` from `U|LST` helpers) — **DESIGN, accepted — documented exception, excluded from the sweep**

**Presented, not assumed fixable like L40:** unlike L40's single dead check, `U|LST::UC_ReplaceAt`/
`UC_RemoveItemAt`/`UC_LE`/`UC_FE` are called pervasively and load-bearingly across `U|SWP`'s own `UC_*`
surface — including inside `UC_ComputeY`/`UC_ComputeInverseY`, the actual stable-swap Newton-solver math.
These aren't dead checks like L40's; they're real bounds-guards (index-in-bounds, list-not-empty)
preventing a bare out-of-bounds crash mid-computation. Deleting them the way L40's dead check was deleted
would strip real protection from live, critical math.

**Owner direction:** exclude this from the sweep entirely. Leave `U|LST` as-is, note it as a documented
exception, and these stay `UC_*` — because they're fundamentally computing over string/list values, and
their `enforce` calls exist only to keep that computation from getting corrupted (an out-of-bounds crash
mid-fold), not to gate a business/application decision the way a real `UEV_*` domain check would.

**Formalized as a versioned StoicSyntax rule, not just noted here** — per this codebase's own convention
("when a durable rule changes, bump the version and update the file first"): added as a documented
exception in `OuronetInformational/StoicSyntax.md` § 6.1 (bumped **1.8.0 → 1.9.0**, changelog row added)
and cross-referenced in `OuronetInformational/StoicSyntax-Prefixes.md`'s own `UC_` row. Scoped narrowly
and explicitly — only `U|LST`'s named list/string-shape bounds-guard helpers (and any `UC_*` that calls
them) are covered; a `UC_*` calling into real business validation elsewhere is still a genuine violation,
not swept under this exception.

**Status:** DESIGN, accepted — documented exception, formally codified in StoicSyntax v1.9.0. No code
change, tagged **excluded from the StoicSyntax rename sweep**. — *L41*

---
