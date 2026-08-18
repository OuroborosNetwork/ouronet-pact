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
