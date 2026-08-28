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

**Status (original scope):** FIXED ✅ AND PROVEN ✅ — narrowed to stable pools only (per owner's correct
prediction), computation-level fix (per owner's correct requirement), no pre-transfer sanity check needed
(per owner's correct prediction, now that the solver is provably correct at the source). `UC_ComputeInverseY`'s
sibling issue was explicitly **not** covered by this fix and was left open. Full diff summary:
`ROUND-02-FIXES.md` Fix #1. Awaiting Round III re-verify.

**Sibling gap closed — #72C, `UC_ComputeInverseY` (2026-08-28):** this sat open exactly as recorded above
("should be split out before Round III re-verify closes C2") — never picked back up, because Round III
re-verify was itself explicitly ruled out of scope for this branch (2026-08-27, deferred to `main`). That
deferral was meant for routine double-checking of already-closed findings; C2 was never actually fully
closed, only the direct-swap half was, and the distinction got lost in the general deferral. Surfaced again
when the owner asked, unrelated to any audit-cycle work, whether the direct/inverse swap math was verified
correct — went back into the audit trail instead of assuming it was fine, found this note.

**Reproduced live before touching anything**, same discipline as the original C2 fix — no REPL proof
existed for the inverse direction, so one was built first, on the same live `pool7` fixture `SWP|TX 015`
already uses:
- `output-amount = 0.5 × xo` (in-domain): correct, sane output.
- `output-amount = xo` exactly: **uncatchable native crash** — `Arithmetic exception: div by zero, decimal`,
  inside `UC_YNext`'s `c` term, not even caught by wrapping the call in `try`. `xo-minus = xo -
  output-amount` is a plain *factor* of `P-Prime` (not just an addend), so it hits `P-Prime == 0.0` and the
  solver's `c = D^(n+1) / (nn * P-Prime * A * nn)` divides by zero.
- `output-amount = 1.01× / 1.5× / 5× xo` (over the pool's real reserve — impossible requests, no finite
  input can ever buy more than 100% of a pool's own token reserve): **no crash** — the solver silently
  returned `~1.01×`, `~1.5×`, `~5×` xo back as the "input needed," a plausible-looking, monotonically
  scaling, entirely fabricated number. This is the more dangerous of the two failure modes: nothing about
  the returned value looks wrong at a glance.

**Why the C2 fix (reseeding `y0`) doesn't transfer:** `UC_ComputeY`'s bug was a bad *starting guess* —
reseeding to `D` worked because the physical root exists for *any* positive input (the curve asymptotes
toward but never reaches the reserve ceiling). `UC_ComputeInverseY`'s bug is upstream of Newton entirely —
the *coefficients themselves* (`S-Prime`/`P-Prime`) are invalid before iteration ever starts, for a request
that has no valid answer by construction (you cannot compute "the input required to withdraw more than the
pool has," any more than you can floor-divide by a number that doesn't exist). No seed choice fixes invalid
coefficients. The correct fix is rejecting the request outright, before those coefficients are computed.

**Blast-radius check before fixing (traced every real caller, not assumed):** `UC_ComputeInverseY` is
reachable two ways that share **no** common validating choke point — confirmed this matters, since it rules
out fixing this in a caller-side `UEV_*` instead: (1) `URC_InverseSwap`'s `validation:bool` param
(`16_SWPI.pact:848-849`) can skip its own `UEV_InverseSwapData` gate entirely, and that gate only checks
token membership + amount well-formedness, never `output-amount` against the live reserve; (2)
`UC_InverseBareboneSwapWithFeez` (`16_SWPI.pact:562`) is a `UC_*` function with zero validation anywhere in
its chain, called directly by both `SWPL` (sovereign) *and* `2_SLAVE/Stage_Z/01_DPL-UR.pact` (a slave
module) — no shared gate exists on this path at all. The fix has to live inside `UC_ComputeInverseY` itself.

**Fix — `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`, `UC_ComputeInverseY`:** added
`(enforce (< output-amount xo) "UC_ComputeInverseY: output-amount must be strictly less than the pool's
current output-token reserve")`, sequenced between `xo`/`xi` and `xo-minus` so it runs *before*
`xo-minus`/`P-Prime` are ever computed (Pact evaluates `let` bindings in declared order, and a failed
`enforce` aborts immediately — confirmed empirically, not assumed). This is a direct, load-bearing `enforce`
inside a nominally `UC_*` function — StoicSyntax §6.1 already documents this exact function as carrying
this kind of computation-intrinsic bounds guard (via the `U|LST` helpers it already calls), so this stays
consistent with existing, already-accepted precedent rather than introducing a new exception. `UC_ComputeY`
untouched.

**Adversarially proven, live:** built the reproduction as a permanent REPL proof first (`SWP|TX 015b`,
below), confirmed it failed correctly pre-fix (crashed the whole load exactly like the raw reproduction
did), applied the fix, confirmed all 6 assertions pass, then `git stash`'d `12_U_SWP.pact` back to the
pre-fix code and reran — the suite crashed again with the identical `div by zero` at the identical location,
proving the test and the fix are both doing real work. Restored the fix (`git stash pop`), diffed against a
pre-stash backup copy to confirm byte-identical restoration, reran clean.

**New permanent REPL proof — `REPL/Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `SWP|TX 015b - #72C
Regression: Stable-Swap Inverse Newton Domain Guard`** (immediately after `SWP|TX 015`, same `pool7`
fixture, no hardcoded reserve figures): asserts the in-domain case still returns a sane positive value, and
that the at-boundary and all three over-boundary cases are now cleanly, catchably rejected (`try`-wrapped —
catchable is itself part of what changed, the pre-fix at-boundary crash was NOT `try`-catchable).

**Full suite (`[6.2]`+`[6.3]`) and default issuance-only (`[6.2+3]`) pipelines both verified clean** (exit
0, 0 `FAILURE`), `Stage01_Tester.repl` reverted to default afterward (zero drift).

**Status (sibling, #72C):** FIXED ✅ AND PROVEN ✅. C2 is now fully closed, both directions. See
`ROUND-02-FIXES.md` Fix #48.

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

**Addendum (`#65dL`, 2026-08-28):** owner independently re-raised this exact concern — if principals
can be rotated/removed, doesn't that break the routing infrastructure existing pools depend on? —
while discussing `#65bL`/`#65cL`. Re-verified against the current code rather than assuming this
finding still covers it: grepped every consumer of `SWP::UR_Principals` across the whole codebase,
confirmed it has exactly one real caller outside `A_UpdatePrincipal`/`A_RotatePrincipal` themselves —
`SWPI::UEV_Issue`'s issuance-time-only anchoring gate. Nothing in `SWPT`'s graph, `SWPI`'s value
computation, or live trading reads current principal status — the H3/#21H fix still holds exactly as
designed; rotating or removing a principal cannot affect any already-issued pool's routing, pricing,
or tradability. Also corrected the owner's "major vs. minor principal" framing: no such tier exists
in the code — `principals` is a flat, undifferentiated list, and `primordial-pool` is a mechanically
separate single-swpair property, not a principal subtype. Full explainer written up as
`OuronetInformational/memories/2026-08-28-principal-and-primordial-pool-architecture.md`. Found one
small, genuinely missed leftover while re-verifying: `A_RotatePrincipal`'s own `@doc` in
`15_SWP.pact` still said "standalone removal via `A_UpdatePrincipal` is disabled" — accurate as of
Fix #13, but Fix #14 re-enabled removal (floor-gated) and updated the *Talos wrapper's* docstring
(`01_TS01-A.pact`) to match, but missed the core module's own defun doc. Corrected — pure doc change,
no behavior touched, full regression re-run clean. See `ROUND-02-FIXES.md` Fix #43.

## H3/#21H third follow-up (`#65eL`) — major vs. minor principal distinction, enforced — **BUILT AND PROVEN**

**Owner's follow-up direction (2026-08-28):** after the `#65dL` re-verification confirmed no code gap
exists, owner proposed an actual new rule rather than just leaving the concern resolved-by-absence:
define a "major" principal as one currently a member of the primordial pool (always OURO/DWK/DLK in
practice — a "major principal" isn't a new registered category, it's a *property* of certain existing
principals), and make majors permanently fixed — never removable or rotatable via
`A_UpdatePrincipal`/`A_RotatePrincipal` — while any other ("minor") principal keeps working exactly as
before. Rationale, restated plainly: even though `#65dL` proved rotating/removing *any* principal
can't break existing routing, an admin accidentally or maliciously rotating OURO/DWK/DLK away is still
worth blocking outright — there's no legitimate reason to ever do it, and locking it out removes an
entire class of "why would you even allow this" admin mistakes for free.

**Design, checked against the actual enforced invariants before building, not assumed:**
`SWP|C>DEFINE-PRIMORDIAL-POOL` (the capability gating `A_DefinePrimordialPool`) already enforces that
whatever pool gets designated primordial must be a `W`-type, 3-token pool containing exactly OURO,
`DALOS::UR_WrappedStoaID` (DWK), and `DALOS::UR_SilverStoaID` (DLK) — confirmed via the actual capability
code, not the doc comment. `H6`/`#18H`'s own fix additionally confirmed a second pool sharing that exact
3-token set is structurally impossible to issue (`UEV_CheckAgainstMass`). So "member of the primordial
pool" is, in practice, always exactly `{OURO, DWK, DLK}` — but the check is defined as *live membership
in whatever pool is currently `primordial-pool`*, not a hardcoded OURO/DWK/DLK list, so it stays correct
even if the primordial pool is ever redefined to a different physical pool instance (still forced to
contain those same 3 tokens either way). Also confirmed `SWP|Properties`'s `primordial-pool` field is
always populated (genesis inserts the `BAR` sentinel), so the new check never crashes pre-bootstrap —
it just correctly reports "nothing is major yet."

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:**
- New `URC_IsMajorPrincipal(token):bool` — `false` if no primordial pool is defined yet, otherwise
  `token`'s membership in `UR_PoolTokens(UR_PrimordialPool())`. Doesn't require `token` to already be a
  registered principal — callers check that separately.
- `SWP|C>PRINCIPAL`'s removal branch: added a third, distinct enforce
  (`(not (URC_IsMajorPrincipal principal))`) alongside the existing "must currently be a principal" and
  "floor" checks — a major principal is rejected outright, even with headroom above the 2-minimum floor.
- `SWP|C>ROTATE-PRINCIPAL`: added the same check against `old` — a major principal can never be the
  source of a rotation, regardless of the other 3 existing rejection reasons.
- `@doc`s updated on both defcaps, both `defun`s (`A_UpdatePrincipal`/`A_RotatePrincipal`), and both
  Talos wrappers (`01_TS01-A.pact`) to describe the new distinction.

**Adversarially proven, live — `SWP|TX 035a` (new, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`):**
`URC_IsMajorPrincipal` correctly identifies OURO and DLK as major, and — importantly — DWK as major
too even though genesis never actually registers DWK as a principal (proving the check is about
primordial-pool membership, not principal status); a genuine minor test principal correctly reports
`false`. At 7 principals defined (well above the floor, so this genuinely isolates the NEW guard from
the pre-existing floor guard), removing OURO and rotating OURO away are both rejected outright. A minor
principal is removed and restored in the same test, proving the new guard doesn't over-block anything.
Reverted each guard in isolation (`(enforce (not (URC_IsMajorPrincipal ...)) ...)` → `(enforce true ...)`)
and re-ran: caught a real test-design flaw along the way — the first revert-and-rerun pass used a
nonexistent token (`"ZZ-..."`) as the rotate target, which fails `A_RotatePrincipal`'s own `UEV_id`
validation regardless of the major-principal guard, making that specific assertion vacuous; also
discovered the removal test's real side effect (OURO genuinely gets removed once its guard is
neutralized) contaminates a rotate test running immediately after on the same token. Fixed by using a
real, already-issued non-principal token (`TE`, from `SWP|TX 034`'s own pool) as the rotate target, and
re-ran each guard's revert in isolation (one neutralized at a time) — both now show a genuine
"expected failure, got result" when their own guard is removed, confirmed independently, then both
restored and the full suite reconfirmed clean. Full suite (`[6.2]`+`[6.3]`) and default issuance-only
(`[6.2+3]`) pipelines both exit 0, 0 `FAILURE`, `Stage01_Tester.repl` reverted to default afterward
(zero drift).

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #44.

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

## L42 (#42L, U|SWP — `UC_ComputeWP`/`UC_ComputeInverseWP` divide by weight with no zero-guard of their own) — **CLOSED — already covered by C4 (#11C) + C7 (#8C), residual only, no code change**

**Confirmed the mechanism, then checked reachability before proposing anything:** `UC_ComputeWP`
(`12_U_SWP.pact`) computes `(inverse-ow (floor (/ 1.0 ow) 24))` where `ow` is the output-position token's
weight — confirmed directly against the real Pact binary that `(/ 1.0 0.0)` throws a hard "Arithmetic
exception: div by zero," not a clean message. `UC_ComputeInverseWP` has the identical shape on its own
input-side weight.

**Traced every real path that can ever set a pool's weight — both already closed this exact gap:**
`SWPI::UEV_Issue` (C4/#11C's own fix, this same session) enforces `>= 0.1` on every weight at issuance;
`SWP::C_ModifyWeights` (C7/#8C's fix) enforces the identical `>= 0.1` floor on every post-issuance
reweight. No other path exists to set a pool's weight. In fact, C4's own adversarial revert-and-reproduce
test already tripped over this exact crash without naming it: reverting the C4 fix and testing a literal
`0.0` weight "still failed even reverted — something else downstream (a real division-by-zero...) already
aborts on exact zero" — that undiagnosed "something else downstream" is precisely this function's
unguarded `(/ 1.0 ow)`.

**Owner direction:** finalize as closed, document it.

**Status:** CLOSED — no live weight of `0.0` can reach a real pool today; both entry points (issuance,
modification) floor every weight at `0.1` before this function is ever reached. Residual only, same class
as M1/L40/L41's own accepted residual risk: a hypothetical future caller of these `UC_*` functions that
bypasses both validated entry points would still hit a raw crash instead of a clean message, but no such
caller exists. No code change — the real fix already landed as C4/#11C (`ROUND-02-FIXES.md` Fix #11) and
C7/#8C (`ROUND-02-FIXES.md` Fix #4); this finding is closed as their byproduct, not by any new work. — *L42*

---

## L43 (#43L, U|SWP — `UC_ComputeD`'s docstring claims 5 iterations, code runs 6) — **CLOSED — already fixed as a byproduct of H1 (#24H), no code change**

**Checked the current source before writing anything:** `UC_ComputeD`'s docstring (`12_U_SWP.pact:221`)
now reads "Uses `UC_DNext` for aproximation over 12 fixed iterations," and the code runs
`(enumerate 0 11)` — 12 iterations, matching exactly. The doc/code mismatch this finding describes
(5-in-docstring vs. 6-in-code) doesn't exist anymore: H1 (#24H, this same session) bumped the iteration
count 6 → 12 for a real convergence reason (measured 0.0078 short at 1000x reserve skew) and, doing so,
necessarily rewrote the docstring to describe the new count — closing this exact doc/code drift as an
unavoidable side effect, not a separate documentation pass.

**Owner direction:** finalize as closed, document it.

**Status:** CLOSED — no code change here; the fix already landed as H1/#24H (`ROUND-02-FIXES.md` Fix
#15). Closed as a byproduct, same pattern as H5/#23H (closed by C4) and L42 (closed by C4+C7). — *L43*

---

## L44 (#44L, U|BFS — `UCX_*`/`UDCX_*` is a locally-invented aux-depth naming tier not codified in `StoicSyntax.md`) — **TAGGED FOR SWEEP — not resolved individually**

**Checked whether the finding's premise still holds before tagging it either way:** `13_U_BFS.pact` has 9
`UCX_*` functions (`UCX_GraphNodeLinks`, `UCX_PrimalQE`, `UCX_GetChains`, …) and 5 `UDCX_*` functions
(`UDCX_AddVisited`, `UDCX_AddChains`, …) — all internal, none declared on the public `BreadthFirstSearchV1`
interface (confirmed while working #38M/M4 in this same file). The finding's premise ("not codified") is
no longer true: `OuronetInformational/StoicSyntax-Prefixes.md` now formally defines this exact tier —
`UCx_`/`UDCx_` (lowercase `x` = "auxiliary of the function directly above it") are real registry entries
with real semantics, and its own migration-mapping table already lists `UCX_ → UCx_` / `UDCX_ → UDCx_` as
a planned mechanical rename (uppercase → lowercase, pure find-replace, zero behavior change).

**Owner direction:** a broader StoicSyntax refactor (naming, function arrangement within modules,
interface cleanup) is planned as its own pass, run **from `main`, after every audit's findings are merged
there** — not piecemeal inside this branch. Tag this finding for that sweep rather than hand-renaming 14
functions now.

**Status:** TAGGED FOR SWEEP — no code change here. The concept is already codified (`StoicSyntax-Prefixes.md`,
migration-mapping table); only the mechanical rename of the 14 `UCX_*`/`UDCX_*` functions in
`13_U_BFS.pact` remains, deferred to the planned post-merge sweep from `main`. — *L44*

---

## L45 (#45L, SWPT — `URC_AllGraphPaths` misleadingly named, returns one shortest chain per node, not all paths) — **CONFIRMED, FIXED, PROVEN**

**Re-verified the finding still held, not assumed stale like some prior LOW items:** `URC_AllGraphPaths`
is unchanged since the original finding — still a thin wrapper over `UC_BFS`, still returns
`(at "chains" bfs-obj)` (one shortest chain per reached node), still named as if it returns every path.
Actually worse now than when flagged: the module also has `URC_ComputeAllRoutes` (#34 Phase 11's genuine
exhaustive multi-route search) with a near-identical name sitting right next to it — real risk of a future
reader grabbing the wrong one.

**Owner direction:** rename it properly and refactor the module to use the new name — this isn't a
StoicSyntax prefix-tier gap like L44 (the `URC_` prefix itself is correct), it's a plain misleading
descriptive name, worth fixing directly rather than deferring to the sweep.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`:** renamed `URC_AllGraphPaths` →
`URC_ShortestChainPerNode` (interface declaration + implementation + doc). Traced every real reference
first (interface, the one real caller `URC_ComputeGraphPath`, zero REPL references by name) — updated the
caller's own local binding name (`all-paths` → `shortest-chains`) and doc for the same clarity. New doc
comment explains the actual semantics precisely, including a verified note that `output` plays no role in
the BFS itself (confirmed against `UC_MakeGraphNodes`'s own pre-existing doc: "stay in the signature
(unused)") — accepted only for signature symmetry with its caller. No version bump needed on
`SwapTracerV2` — still pre-mainnet, matching every other interface edit this whole audit.

**Adversarially proven, live:** full `[6.2]`/`[6.3]` suite (every pre-existing exact-value route assertion
from C6/H2/H4/M2's own fixes — would have failed on any behavior drift from the rename): exit 0, 0
`FAILURE`. Issuance-only regression: exit 0, 0 `FAILURE`. Full `Z.repl` (Stage 1 + Stage 2): exit 0, 0
`FAILURE`, `Load successful`. Pure rename — zero behavior change by construction, confirmed by the
untouched exact-value assertions still passing byte-identical.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #27. Awaiting Round III re-verify. — *L45*

---

## L46 (#46L, SWPT — Smart Swap REPL coverage is one TX with no route assertions, none of #6C/#13C/#19H-21H caught) — **CONFIRMED, FIXED, PROVEN**

**Checked the literal claim, and the actual underlying worry, separately:** `SWP|TX 016a` is still exactly
what the finding describes — one `SWP|CC_SmartSwapWithSlippage` call, zero assertion. But the real worry
(C1/C6/H4/H2/H3/M2 regressing silently) is no longer accurate: every one of those fixes landed with its
own dedicated adversarial regression test (the diamond-topology route comparisons at `SWP|TX 032c`-`032g`,
disabled-pool fallback tests, etc.) — the real risk is already covered elsewhere, just not by this
specific smoke test.

**Owner direction:** fix it anyway, make sure not to break anything.

**Fix — `REPL/Stage_01/[6.3]_SWP.repl`, `SWP|TX 016a`:** captured the swap's own return value instead of
discarding it, and added a real `expect` pinning the exact result. Didn't guess the expected value — first
ran with a probe `print` to capture the real, live output at this exact point in the suite's topology
(`"Succesfully smart-swapped 5.0 AKOSON-98c486052a51 to 4.187143624737786198597098 TUSD-98c486052a51 via
3 Swaps over 3 Pools"`), then wrote the assertion against that measured value.

**Adversarially proven the assertion actually catches something, not just that it passes:** deliberately
corrupted the expected value by one decimal digit and reran — genuine `FAILURE`, exact expected-vs-received
diff shown. Restored the correct value, reran clean. Full `[6.2]`/`[6.3]` suite: exit 0, 0 `FAILURE`.
Issuance-only regression (unaffected — `TX 016a` isn't in that path): exit 0, 0 `FAILURE`. Full `Z.repl`
(Stage 1 + Stage 2): exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #28. Awaiting Round III re-verify. — *L46*

---

## L47 (#47L, SWPI — unrecognized pool-type falls back to a silent `-1.0` sentinel instead of aborting) — **REFUTED — provably unreachable by construction, no code change**

**First proposed a fix, then the owner correctly pushed back on whether it was needed at all** — asked
whether the `pool-type` data fed in could ever really be anything else, given how it's produced. Traced
the full chain instead of assuming either way:
- `pool-type` at every real call site is `(ref-U|SWP::UC_PoolType swpair)` — literally
  `(take 1 swpair)`, the first character of the swpair's own ID string.
- Every swpair ID that will ever exist is built by exactly one function, `UC_PoolID`, called from exactly
  one place: `SWP::XE_Issue`'s `insert` into `SWP|Pairs`. Confirmed no second insertion path exists —
  every other touch to that table anywhere in the module is `update`, which requires the row to already
  exist.
- `UC_PoolID` derives its own prefix character from `UC_Prefix`, which is exhaustive by construction —
  `(if (= amp -1.0) (if (= ws 1.0) "W" "P") "S")` — there is no fourth branch, nothing else it can ever
  produce.

**Also worked through why the "fix" itself wasn't syntactically simple, before concluding it wasn't
needed at all:** a bare `(enforce false ...)` can't sit in a `cond`'s trailing default slot — Pact
requires every branch (default included) to type-check to the function's declared return type
(`decimal`), and `enforce` returns `bool`; that would be a compile-time type error, not a runtime
improvement. The syntactically-valid fix would have been an `enforce` placed *before* the `cond`
(mirroring the existing stable-pool single-input check already sitting there), leaving `-1.0` as a
provably-unreachable trailing default only Pact's type checker still requires.

**Owner's read confirmed:** `pool-type` can never be anything but `"S"`/`"W"`/`"P"` for any real swpair,
ever — not "unreachable today, could regress," but structurally closed given the single exhaustive
construction path. Adding the enforce would be pure defensive bloat guarding against a state that
literally cannot occur.

**Status:** REFUTED — no enforce needed, no code change. Closed as provably unreachable by construction,
not merely unreachable in practice. — *L47*

---

## L48 (#48L, SWPI — undocumented, unrelated-looking magic constants `5040000.0`/`10000000.0`) — **DESIGN, accepted — both intentional and owner-verified, no code change**

**Traced both before presenting, not taken on faith either way:**
- `10000000.0` at `16_SWPI.pact:1357` (inside `URC_PoolValue`) is the same genesis LP mint value already
  named `GENESIS_LP_SUPPLY` for `C_Issue`/`XE_IssueWrite` during the #36/M5 fix — a real duplicate, in a
  different function #36 wasn't scoped to touch.
- `5040000.0` (3 uses, `UC_PoolShares`/`UC_DeviationInValueShares`, also consumed from `SWPL`'s
  asymmetric-liquidity add/remove logic) — checked for any documented rationale anywhere in the codebase
  or `OuronetInformational/`; found none.

**Owner, on `10000000.0`:** leave as-is — every new SWP issuance mints exactly 10,000,000 LP tokens,
fixed, by design; that's why the number is used here too, not an accidental duplicate needing
unification.

**Owner, on `5040000.0`:** leave as-is — there's a real reason for this specific number tied to how
shares are computed; owner verified it was correct at implementation time, doesn't recall the exact
derivation on demand right now, but it's not an arbitrary/undocumented-by-accident value.

**Status:** DESIGN, accepted — both constants intentional and owner-verified, not oversights. No code
change, no renaming, no centralizing. — *L48*

---

## L49 (#49L, SWPI — `URC_Hopper`'s doc says "cheapest available edge," imprecise for what should be "maximizes output") — **CONFIRMED, FIXED, PROVEN**

**Checked whether the finding's location still existed before fixing it:** `URC_Hopper` itself was
already rewritten with an accurate doc during the #19H fix — the "cheapest" wording had migrated,
unchanged, into its successor `URCX_HopperForNodes` (split out during #34M/M2). Confirmed via grep it's
the only remaining "cheapest" instance in the file.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`:** doc corrected to "highest-output edge," with a note
explaining the wording was backwards (C1/#6C's own fix made this function maximize output among parallel
pools, not minimize cost). Pure doc wording, zero behavior change.

**Adversarially proven:** full `Z.repl` regression: exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #29. Awaiting Round III re-verify. — *L49*

---

## L50 (#50L, SWP — `UR_StoaValue` performs an ungated table write as a side effect of a nominal "read") — **CONFIRMED, FIXED, PROVEN**

**Confirmed the violation, then tested the obvious fix before proposing it — and it would have been
wrong.** `UR_StoaValue` (a `UR_*`) did a real `update SWP|Pairs swpair {"stoa-value": 0.0}` write when it
encountered a legacy V2 row predating the V3 `stoa-value` field. First instinct was to swap this for
`with-default-read`. Built a scratch repro simulating exactly this scenario (an old-schema row read
against a newer module schema with an added field) before proposing it as the fix — confirmed
`with-default-read`'s default only covers a key **entirely absent** from the table, not a field missing
from an otherwise-existing row; it throws "Key not found in object" on precisely the legacy-row case it
would need to handle. Would have been a real regression if shipped without testing.

**Owner confirmed the write's original purpose:** a deliberate migration artifact — populate the field
once so a real event (`XE_UpdateStoaValue`) can later write the genuine value; not an oversight.

**Traced every reader of `stoa-value` before removing the write, to confirm nothing depends on it being
physically persisted:** grepped the entire codebase (Stage 1 and Stage 2, including cross-module —
AQP's `FVT` module reads this via `SWP::UR_StoaValue`) — `UR_StoaValue` is the only function anywhere
that ever reads the field directly. No caller inspects the underlying row's write history, only the
returned decimal. Genesis pools already seed the field to `0.0` from day one, so this only ever mattered
for pre-V3 legacy rows.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** dropped the `update` entirely; a legacy row now
returns `0.0` computed fresh on every read, never persisted here. `XE_UpdateStoaValue` still writes the
real value whenever an actual price update occurs. Restores `UR_*` purity — no write, no side effect.

**Adversarially proven:** full `[6.2]`/`[6.3]` suite, issuance-only regression, and full `Z.repl` (Stage 1
+ Stage 2, exercising the cross-module `FVT` caller too) all exit 0, 0 `FAILURE`, `Load successful` —
confirming zero observable behavior change to any real caller.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #30. Awaiting Round III re-verify. — *L50*

---

## L51 (#51L, SWP — `C_ModifyWeights` composes bare `(SECURE)` instead of a named master client cap, unusual layering vs. the rest of the module) — **REFUTED — correct shape, no code change**

**Traced why before treating it as a bug:** every sibling `C_*` in the module (`C_UpdateAmplifier`,
`C_UpdateFee`, `C_ModifyCanChangeOwner`, …) composes its own named cap directly and calls a matching
`XI_*` (internal-only) for the write. `C_ModifyWeights` is the one exception — it composes bare
`(SECURE)` and calls `XB_ModifyWeights` instead, which is the one that composes the real named cap
(`SWP|S>WEIGHTS`). Confirmed why the prefix differs: `XB_ModifyWeights` genuinely is called externally
too — `17_SWPL.pact` calls `ref-SWP::XB_ModifyWeights` directly, cross-module, twice — unlike every
sibling's `XI_*`, which is unreachable any way but through its own `C_*`.

**Owner reasoned through the correct shape from memory, without looking at the code, and it matched
exactly:** an `XB_*` (both internal and external) needs its own `UEV_IMC` + complete `with-capability`
inside the defun, since it can't rely on an internal caller's context; the `C_*` wrapping it only needs
bare `SECURE` to gate the hand-off, since `XB_ModifyWeights` fully re-validates on every call regardless
of caller. Confirmed against the actual source: `XB_ModifyWeights` opens with `(UEV_IMC)` then its own
`(with-capability (SWP|S>WEIGHTS …) …)`; `C_ModifyWeights` opens with `(UEV_IMC)` then bare
`(with-capability (SECURE) (XB_ModifyWeights …) …)` — exactly the predicted shape, matching this
codebase's own documented `XB_*`/`XE_*` contract.

**Status:** REFUTED — not an inconsistency. `C_ModifyWeights`'s layering correctly follows from
`XB_ModifyWeights`'s genuine dual internal/external role, which no sibling `XI_*`-based `C_*` shares.
Composing the named cap a second time at the `C_*` level would be redundant, not more correct. No code
change. — *L51*

---

## L52 (#52L, SWP — `XE_Issue`/`XI_ToggleFeeLock` return meaningful values with no documenting `@doc` per R4) — **CONFIRMED, FIXED, PROVEN**

**Confirmed both violate R4 (§19.4), then traced what they actually return before writing docs — not
guessed:** `XE_Issue:string` returns `swpair`, the newly-constructed pool ID, used by its own callers
(`SWPI::C_Issue`, `MTX-SWP::MTX|C_Issue`) to continue their own flow. `XI_ToggleFeeLock:[decimal]`
returns `[0.0 0.0]` when locking, or the real ATS unlock price (`U|ATS::UC_UnlockPrice`, itself
`[virtual-gas-cost(IGNIS) native-gas-cost(KDA)]`) when unlocking — traced its caller (`C_ToggleFeeLock`)
to confirm this is genuinely billed back to the patron via `KDA|C_Collect`, not decorative.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** added real `@doc` to both, per R4 — what each
function does and precisely what it returns and why. Pure documentation, zero behavior change.

**Adversarially proven:** full `[6.2]`/`[6.3]` suite and full `Z.repl` (Stage 1 + Stage 2) both exit 0, 0
`FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #31. Awaiting Round III re-verify. — *L52*

---

## L53 (#53L, SWP — `UEV_PoolFee`'s upper bound (320.0) has units not self-evidently sane) — **CONFIRMED, FIXED, PROVEN**

**Did exactly what the finding asked before concluding anything:** cross-checked `320.0` against the real
swap-fee formula (`16_SWPI.pact`'s `fselp`/`ofs`), which treats `1000.0` as the full-fee basis — confirming
fee is expressed in per-mille, so `320.0` means a 32% ceiling, not a nonsensical raw number. Traced
`UEV_PoolFee`'s real callers: it gates both `fee-lp` at issuance and the LP-or-special slot via
`C_UpdateFee`.

**Owner explained the design rationale for the specific number:** the same bound is deliberately mirrored
across all three fee components a pool can carry — LP fee, special-target fee, liquid-boost fee — so
their combined worst case is `320.0 × 3 = 960` promille, always leaving at least 40 promille (4%) of
every swap that fees can never fully consume. `320.0` wasn't picked arbitrarily; it's `≈1000/3`, sized
specifically to prevent the three independently-capped components from ever summing to the full 1000.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** added `@doc` to `UEV_PoolFee` capturing both the
per-mille units and the three-way-mirrored design rationale, so a future reader doesn't have to
reverse-engineer it from the swap formula the way this trace did. Pure documentation, zero behavior
change.

**Adversarially proven:** full `[6.2]`/`[6.3]` suite and full `Z.repl` (Stage 1 + Stage 2) both exit 0, 0
`FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #32. Awaiting Round III re-verify. — *L53*

---

## L54 (#54L, SWP — admin migration utility `AHU`/`AUP_SwapPair(s)` falls outside the module's own prefix vocabulary) — **DESIGN, accepted — `AU_` formalized, existing instances deferred to the full sweep**

**Traced before presenting, found something worth flagging beyond the naming question:** `AHU`
(`15_SWP.pact:1871`) is a separate admin capability, distinct from the module's normal `GOV`/keyset-ref
path — gated by `CAP_EnforceAccountOwnership` against a single hardcoded account string, deliberately
obfuscated (a mix of Latin/Cyrillic/Greek-lookalike Unicode). `AUP_SwapPair` does
`(update SWP|Pairs id {"id": id})` — rewrites a row's own `id` field back to itself.

**Owner confirmed the purpose:** genuine, deliberate schema-migration tooling — used historically when new
fields were added to `SWP|Pairs`, to force existing rows to pick up the new schema shape. Not vestigial.
Direction: keep these functions (historical/observational value — they document how past migrations were
done and may be needed again), and formalize a new StoicSyntax prefix category, **`AU_`** (Admin Update)
— admin-mode-only functions whose sole purpose is applying schema/data updates during migrations,
distinct from `A_*`'s live-business-mutation role.

**Checked whether renaming just SWP's copy made sense before asking again, and it changed the answer:**
`AHU`/`AUP_*` is not a SWP-specific naming slip — the identical pattern (a local `AHU` cap + `AUP_*`
migration functions) already repeats across six modules: `01_DALOS`, `05_DPTF`, `06_DPOF`, `08_ATS`,
`15_SWP`, and Stage 2's `02_DPDC` (`AUP_OuronetAccount`, `AUP_TrueFungibleAccount`, `AUP_TrueFungible`,
`AUP_UnstakeAccount`, `AUP_AutostakePair`, `AUP_OrtoFungibleAccount`, `AUP_OrtoFungible`,
`AUP_SwapPair(s)`). Renaming SWP's copy alone would trade one inconsistency for another (five other
modules would still say `AHU`); renaming all six now would balloon a single LOW-severity SWP finding into
an unscoped cross-module refactor.

**Owner's direction on placement, then final call:** `AU_` placed immediately before `A_` in the
FUNCTIONS block order (§7) and the protected-entrypoints table (§6.2) — matching the "admin-mode-only,
migration-only" role sitting adjacent to but distinct from live admin mutations. Close the finding: `AU_`
formalized now (`OuronetInformational/StoicSyntax.md` § 6.2/§7, bumped **1.9.0 → 1.10.0**, changelog row
added; mirrored in `StoicSyntax-Prefixes.md`); the six existing `AHU`/`AUP_*` instances are a known,
deliberate, shared pattern intentionally left unrenamed for now — explicitly deferred to the full
post-merge StoicSyntax sweep as one coordinated cross-module rename, not touched piecemeal.

**Status:** DESIGN, accepted — `AU_` is now a real, versioned StoicSyntax rule, not just a note here. No
`.pact` code changed; the rename itself is deliberately scoped to the later sweep. Fully resolved, not
left open. — *L54*

---

## L55 (#55L, SWP — `XE_CanAddOrSwapToggle` redundantly re-derives a check `UEV_IMC` already performed) — **CONFIRMED, FIXED, PROVEN**

**Traced whether the second check could ever actually matter, not assumed dead on sight:**
`XE_CanAddOrSwapToggle` called `(UEV_IMC)` — exactly `UEV_Any (P|UR_IMP)` — then immediately re-ran
`UEV_Any` again against `[local-guard] + (P|UR_IMP)`, the identical list with one extra local guard
prepended. Since `(UEV_IMC)` is a bare statement (not wrapped in `try`) and aborts the whole transaction
on failure, reaching the second check already proves `(P|UR_IMP)` alone contains a passing guard —
`UEV_Any` only needs one guard to pass, so adding `local-guard` to an already-guaranteed-passing OR-set
can never change the outcome. Confirmed `SWP|C>ADD-OR-SWAP` (referenced by the local guard) is still
genuinely composed elsewhere (`C_ToggleAddOrSwap`'s own `with-capability`, the real validation gate) —
not orphaned by removing the redundant copy.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`:** removed the entire redundant second guard-check
block; `(UEV_IMC)` remains the sole gate before the write. Pure dead-code removal, zero behavior change.

**Adversarially proven:** full `[6.2]`/`[6.3]` suite (exercising `C_ToggleAddOrSwap`'s existing tests) and
full `Z.repl` (Stage 1 + Stage 2) both exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #33. Awaiting Round III re-verify. — *L55*

---

## L56 (#56L, SWPL — `URC_AreAmountsBalanced` contains a raw `enforce` inside a `URC_*`) — **CONFIRMED, FIXED, PROVEN**

**Re-verified the finding's own "matches AQP's L1 pattern" framing before trusting it, and it didn't
match.** AQP's L1 was a genuine tautology (deleted outright — a value checked against its own derivation
source, unfailable in every real path). Applied the same rigor here via a full agent-driven trace of
every real caller: `URC_AreAmountsBalanced` ← `URC_SortLiquidity` ← `URC_LD` ← **11 real call sites**
across `SWPL`/`SWPLC`/`MTX-SWP`/`INFO-ONE+`. 8 of 11 pass raw, caller-controlled amounts with **zero**
upstream validation — the check is genuinely reachable, not dead. Owner's own instinct (before the trace
completed) correctly flagged that the check was weaker than it looked: `sum > 0.0` alone lets a
mixed-sign list like `[-5.0, 10.0]` sail through.

**Owner's architectural question, answered by tracing rather than assuming:** is there a single place to
put proper validation outside the `URC_*` chain, or would it require duplicating at every call site?
Traced it: no — the three raw-input call groups live in three separate modules, each calling
`SWPL::URC_LD` directly; the only place all 11 real callers converge is the `URC_LD` →
`URC_SortLiquidity` → `URC_AreAmountsBalanced` chain itself. Per StoicSyntax's own rule, `URC_*`'s
allowed callees are `UR_`/`UC_`/other `URC_` only — not `UEV_*` — so even calling a `UEV_*` from inside
`URC_AreAmountsBalanced` would reproduce the exact transitive-violation shape just fixed for L40, one
hop later. Genuinely one place, or eight — no clean single-`UEV_*` option exists.

**Owner's resolution — formalize a new StoicSyntax specialization instead of forcing a false choice:**
neither "leave a known-incomplete check in place" nor "duplicate it 8 times for a naming technicality."
Introduced **`v`** (validating) as a new stackable lowercase specialization role (same mechanism as the
existing `x`/`k`), marking a `UC_`/`URC_`/`URDC_` function whose `enforce` is intrinsic to its own
computation — legitimate only when (1) the check is genuinely reachable, not tautological, and (2) no
single non-tier choke point exists upstream shared by every real caller. This also retroactively gives
L41's `U|LST` exception (v1.9.0) a real, named category instead of an ad-hoc carve-out.

**Fix:**
- `OuronetInformational/StoicSyntax.md` § 6.1 + `StoicSyntax-Prefixes.md` § 1/§ 2: formalized `v`
  (bumped **1.10.0 → 1.11.0**, changelog row added), documenting both instances — `U|LST` (L41, deferred,
  not renamed) and this one (renamed in source, the first fresh application).
- `1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact`: renamed `URC_AreAmountsBalanced` → `URCv_AreAmountsBalanced`
  (interface + implementation + its one real caller `URC_SortLiquidity`). Added the missing per-element
  `>= 0.0` check (matching the equivalent check already correct in `SWPLC::UEV_InputsForLP`, which only
  covers the separate `C_Fuel` flow) — the old sum-only check never actually protected against negative
  individual amounts.

**Adversarially proven, live — new `SWP|TX 038b` in `[6.3]_SWP.repl`:** `[-100.0, 600.0]` (sums to
`500.0 > 0.0`) against a real pool via `SWP|C_AddIcedLiquidity` — cleanly rejected with the new message.
Reverted just the new per-element check (rename and sum-check left in place): the identical call **still
failed**, but with a far worse, opaque error — `'-100.0 is not a Valid Transaction amount'`, thrown deep
in the DPTF transfer layer — confirming the fix isn't a redundant safety net, it genuinely upgrades an
opaque late abort into a clean, precise, early rejection at the point of the actual violation. Restored,
reconfirmed clean. Full `[6.2]`/`[6.3]` suite, issuance-only regression, and full `Z.repl` (Stage 1 +
Stage 2) all exit 0, 0 `FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #34. Awaiting Round III re-verify. — *L56*

---

## L57 (#57L, SWPL — `XI_AddLiqSendAndMint` performs two distinct writes, transfer + mint, in one `XI_*`) — **DESIGN, accepted — no code change**

**Owner:** no point splitting into two `XI_*` here. Raised a sharper framing: is there any reason the two
`C_*` calls (`TFT::C_MultiTransfer`, `DPTF::C_Mint`) need to be wrapped in a shared function at all,
rather than called directly at each site — unless the wrapper is genuinely reused multiple times or does
more than just the two calls?

**Checked the actual reuse before agreeing:** `XI_AddLiqSendAndMint` is called from **3 separate sites**
in `17_SWPL.pact` (the standard, iced, and glacial add-liquidity paths), each already wrapping it in its
own `(with-capability (SECURE) ...)`. Real reuse, not cosmetic bundling — matches the owner's own stated
exception criteria exactly.

**Status:** DESIGN, accepted — the combined name is already honest about what it does, the internal
ordering (transfer-in before mint-out, custody-first) is correct, and the shared-function structure is
justified by genuine 3-site reuse, not arbitrary bundling. No code change. — *L57*

---

## L58 (#58L, SWPL — `|KDA-PID`-qualified `defun` names deviate from the "prefix-only" naming convention) — **TAGGED FOR SWEEP — not resolved individually**

**Checked how widespread the pattern actually is before treating it as a naming nit:** not SWP-specific
— `|KDA-PID` appears **308 times across 17 files**, spanning the SWP family (`17_SWPL`, `18_SWPLC`,
`19_SWPU`, `20_MTX-SWP`, `16_SWPI`, `03_INFO-ZERO`, `21_INFO-ONE+`), Talos (`04_TS01-C3`, `05_TS01-P`),
the root price reader (`01_U_CT::UR|KDA-PID`, `0_Interfaces/01_Utilities.pact`), the entire Stage 2
DemiPad family (`00_Demipad`, `01_Spark`, `02_Snakes`, `03_Custodians`, `04_STOICPAY` — unrelated to
SWP), a Slave module (`2_SLAVE/Stage_Z/01_DPL-UR.pact`), and REPL test references.

**Owner explained what `KDA-PID` actually means:** Kadena price in dollars — on Kadena's chain, an Oracle
supplied a live USD price for KDA. Post-migration to StoaChain, there's no oracle yet and no live STOA
price, so it's hardcoded at $0.1; a future Oracle ("Aletheia") will supply real STOA pricing once built.
The concept has already shifted from "Kadena price" to "Stoa price" — owner's direction: rename
`KDA-PID` → `STOA-PID` throughout, once it can be done as one coordinated pass.

**Owner's call on scope and timing:** this is a protocol-wide rename of an economic concept (the price
basis for IGNIS/KDA gas pricing), not a SWP-scoped naming fix — it touches multiple unrelated Stage 2
modules. Confirmed with the owner before executing anything this size: defer to the full StoicSyntax
sweep, run from `main` once all audits are merged, same treatment as L44/L54's own deferred cross-cutting
renames — not resolved piecemeal inside this branch.

**Status:** TAGGED FOR SWEEP — no code change here. Direction recorded precisely (`KDA-PID` → `STOA-PID`,
all 308 occurrences across 17 files) so the eventual sweep doesn't have to rediscover scope or intent. — *L58*

---

## L59 (#59L, SWPL — reserve bump happens before the actual transfer inside `XE|KDA-PID_AddLiqudity`, safe only by same-tx atomicity) — **CONFIRMED, FIXED, PROVEN**

**Checked the exact worry the finding raised, not just its conclusion:** every branch of
`XE|KDA-PID_AddLiqudity` calls `XE_UpdateSupplies` (reserve bump) before `XI_AddLiqSendAndMint` (the
actual transfer-in + LP mint). The finding already concluded this is safe for a single transaction, but
flagged the real risk: if `MTX-SWP`'s multi-step defpact ever split the bump and the transfer across two
*separate* steps (which really are separate transactions over time, not atomic with each other), reserves
could reflect tokens that haven't actually arrived — a real, exploitable window.

**Traced `MTX-SWP::MTX|C_AddLiquidity` directly to check whether that split actually happens:** it
doesn't. `XE|KDA-PID_AddLiqudity` is called entirely within Step 1's own `step-with-rollback` block —
never spanning Step 1 and a later step. Since each individual pact step is itself a single atomic
transaction, the same same-tx guarantee holds there too, confirmed rather than assumed.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact`:** added a `@doc` to `XE|KDA-PID_AddLiqudity`
explaining the ordering invariant precisely, confirming it holds for both real call shapes (single-tx
SWPLC client paths, and MTX-SWP's defpact Step 1), and flagging explicitly that a future caller splitting
the bump and transfer across two steps would need to re-derive this safety, not assume it. Pure
documentation, zero behavior change.

**Adversarially proven:** full `[6.2]`/`[6.3]` suite and full `Z.repl` (Stage 1 + Stage 2) both exit 0, 0
`FAILURE`, `Load successful`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #35. Awaiting Round III re-verify. — *L59*

---

## L60 (#60L, SWPLC — LP-branding fee attribution resolves via DPTF/DPOF `Konto`, not `SWP::UR_OwnerKonto` directly) — **DESIGN, accepted — no code change**

**Traced the full billing/credit mechanism before concluding anything, not taken on faith either way:**
`C_UpdatePendingBrandingLPs`'s `entity-owner` never drives a debit — real IGNIS payment is always billed
to the calling `patron`. `entity-owner` only controls a 25% referral-style **credit** back to whoever's
named — and for LP-token branding (`entity-pos` 1/2), that resolves to `SWP|SC_NAME` (the module's own
smart account, confirmed set as the LP token's own `owner-konto` at issuance via `DPTF::XE_IssueLP`), not
the real pool owner. Confirmed `entity-pos 3` (sleeping-LP) diverts the same way, to `VST|SC_NAME`.

**Owner's correction, once the mechanism was laid out precisely:** the 25% credit only exists as a
**smart-account interactor incentive** in the first place — `IGNIS::UR_AccountType` gates whether the
named `interactor` qualifies at all; a normal (non-smart) account fails that check and the credit falls
through to the general IGNIS pot instead. `SWP|SC_NAME` legitimately earns the 25% because it genuinely
*is* a registered smart account. Swapping `entity-owner` for `SWP::UR_OwnerKonto` (typically a normal
user account) wouldn't redirect the credit to the pool owner at all — it would just fail the smart-account
check and lose the incentive entirely, benefiting no one.

**Status:** DESIGN, accepted — working as intended, not a bug. No code change. — *L60*

---

## L61 (#61L, SWPLC — `C_UpgradeBrandingLPs` is commented out in the REPL suite, untested) — **CONFIRMED, FIXED, PROVEN**

**Investigated why before just uncommenting it:** `BRD::XE_UpgradeBranding` is a real state machine keyed
off a `flag` (Golden/Blue/Green/Gray/Red hierarchy), with different rules per starting flag. Traced a
fresh LP token's real starting state: `BRD|DEFAULT` sets `flag: 3` (Gray) for every entity, and every LP
token gets its own `BRD|BrandingTable` row at issuance (`DPTF::XB_IssueFree` → `XE_Issue`, confirmed via
`05_DPTF.pact:2136`, inside the exact same flow `DPTF::XE_IssueLP` uses) — so `entity-pos 1` (the plain
LP token) needs no extra setup and is safe to test directly, unlike `entity-pos 2`/`3` (frozen/sleeping
LP), which only exist if a user separately created that variant.

**Found the original commented-out call was already stale, not just disabled:** it referenced
`ref-TS01-C2::SWP|C_UpgradeBrandingLPs`, but both `SWP|C_UpdatePendingBrandingLPs`/`C_UpgradeBrandingLPs`
actually live on `TalosStageOne_ClientThreeV3` (`04_TS01-C3.pact`) — would not have compiled as written
even if simply uncommented.

**Found the whole file was more broken than "just commented out for cost reasons," while trying to get a
clean run:** `[6.4]_Admin.repl` (already excluded from the default `Z.repl` pipeline) hard-fails at load
on a pre-existing, unrelated reference to an ATS pair (`"Magnindium-98c486052a51"`) that's never actually
issued anywhere in the test suite — confirmed via a repo-wide grep, the only reference to that name is
this one broken call. Also found the pool used in this file's existing (pre-existing, already-uncommented)
`entity-pos` 2/3 `C_UpdatePendingBrandingLPs` calls never had a frozen/sleeping LP variant created, so
those also hard-fail. And a separate, later transaction in the same file references a never-registered
smart account. None of these are related to `C_UpgradeBrandingLPs` or to this fix.

**Fix — `REPL/Stage_01/[6.4]_Admin.repl`:** commented out the three unrelated pre-existing broken calls
(with notes explaining each), added a new, real `SWP|TX 002` proving `C_UpgradeBrandingLPs`: proposes real
branding data via `C_UpdatePendingBrandingLPs` on pool6's own LP token (`entity-pos 1`), then upgrades via
`C_UpgradeBrandingLPs`, then asserts the *live* branding (not just pending) actually reflects the proposed
data and the flag moved Gray(3) → Blue(1). Placed right after this file's first transaction rather than
at the original commented-out location, since several unrelated broken transactions later in the file
would otherwise block it from ever being reached — out of scope for this fix, left alone.

**Adversarially proven, live:** all 3 new assertions pass. Deliberately corrupted the expected flag value
(`1` → `999`) — genuine `FAILURE` with the exact expected-vs-received diff. Restored, reconfirmed clean.
Default `Z.repl` pipeline (`[6.4]` excluded, as normal): exit 0, 0 `FAILURE`. No `.pact` source touched —
purely REPL coverage.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #36. Awaiting Round III re-verify. — *L61*

## L62 (#62L, SWPLC — `C_Fuel` has zero REPL coverage of any kind despite moving real funds) — **CONFIRMED, FIXED, PROVEN**

**Investigated the actual risk before adding a test:** `SWPLC::C_Fuel` has two modes gated by a
`direct-or-indirect:bool` argument. DIRECT (`true`) does a real `TFT::C_MultiTransfer` from the calling
account into the pool's own `SWP|SC_NAME` custody, under `SWPLC|C>DIRECT-FUEL` (composes `P|DT` +
`P|SWPLC|CALLER`, both trivially-true — the real authorization is that the caller can only ever move their
own funds). INDIRECT (`false`) skips the transfer entirely and just bumps `XE_UpdateSupplies` reserves,
returning the `EOC` sentinel, under `SWPLC|C>INDIRECT-FUEL` (also trivially-true).

**Confirmed INDIRECT is not externally reachable:** grepped every caller of `C_Fuel` across the codebase.
The only real, permissionless, externally-wired path is Talos `SWP|C_Fuel` (`04_TS01-C3.pact:583-600`,
doc: "Fueling increases Liquidity without issuing LP, therefore increasing LP Value"), which always calls
`direct-or-indirect=true`. The `false` (INDIRECT) mode is only ever called internally, from `19_SWPU.pact`
(lines 1256, 1515) — never exposed via Talos — and is protected the same way every other internal-only
core call is: the established `UEV_IMC` module-registration check, not an account-level cap. So DIRECT is
safe by construction (caller spends only their own funds, no LP minted, straight donation-to-reserves), and
INDIRECT's only real protection is already covered by the existing, already-audited `UEV_IMC` mechanism.
No security fix needed — this was purely a coverage gap, not a vulnerability.

**Fix — `REPL/Stage_01/[6.3]_SWP.repl`:** added a new `SWP|TX 038c` proving the real, permissionless
DIRECT path (`Talos SWP|C_Fuel`) does exactly what its own doc claims: bumps pool6's reserves by exactly
the fueled amounts (`[10.0 20.0]`), with no LP minted. Used a delta assertion (`post-supplies` minus
`pre-supplies` via `(zip (-) post pre)`) rather than an absolute value, since pool6's reserves have moved
through hundreds of prior transactions by this point in the suite — only the delta actually proves the
claim. Did not attempt to assert the caller's own balance decrease (no DPTF balance-reader function exists
in the current API surface; that side is implicitly covered by TFT's own, already-audited transfer tests).

**Adversarially proven, live:** deliberately corrupted the expected delta (`fuel-amounts` → `[999.0
999.0]`) — genuine `FAILURE` with the exact expected-vs-received diff (`expected: [999.0 999.0], received:
[10.0 20.0]`). Restored, reconfirmed clean. Full suite (`[6.2]`+`[6.3]`): exit 0, 0 `FAILURE`. Default
`Z.repl` pipeline (`[6.2+3]` issuance-only): exit 0, 0 `FAILURE`, `Stage01_Tester.repl` shows zero drift
after reverting. No `.pact` source touched — purely REPL coverage.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #37. Awaiting Round III re-verify. — *L62*

---

## L63 (#63L, SWPLC — the module defines no `XI_*` at all, every `C_*` orchestrates peer calls inline) — **DESIGN, accepted — no code change**

**Investigated before accepting:** checked whether SWPLC owns any domain tables of its own that a missing
`XI_*` should be writing to. It doesn't — the only `deftable`s in the module are the governance-only
policy tables (`P|T`, `P|MT`), written exclusively by `GOV`-gated admin functions (`P|A_Add`,
`P|A_AddIMP`), entirely outside the client (`C_*`) flow.

**Traced every real write reachable from a `C_*` in this module:** every one lands in a *different*
module's `XE_*`/`C_*` — `BRD::XE_UpdatePendingBranding`, `BRD::XE_UpgradeBranding`,
`SWP::XE_UpdateSupplies`, `SWPL::XE|KDA-PID_AddLiqudity`, `SWPL::XE_AutonomousSwapManagement`,
`DPTF::C_Burn`, `TFT::C_Transfer`/`C_MultiTransfer`, `VST::C_Freeze`/`C_Sleep`. This is exactly the
documented `XE_*` "forward-module entrypoint" pattern from `CLAUDE.md` — SWPLC is the client/orchestration
layer, the persistence itself belongs to (and stays in) the owning module.

**Status:** DESIGN, accepted — SWPLC is 100% orchestration with zero domain state of its own; an `XI_*`
would have nothing local left to write. Its absence is the natural shape of the module, not a missing
piece. No code change. — *L63*

---

## L64 (#64L, SWPI — `URC_Swap`'s `validation:bool` parameter name is misleading, contributed to #5C being easy to miss) — **TAGGED FOR SWEEP — not resolved individually**

**Investigated what `validation` actually gates, before proposing anything:** confirmed it has nothing to
do with gross-vs-net/fee amounts — it only toggles whether `UEV_SwapData` (pure input-shape/membership
enforcement: uniform list lengths, every input-id is on the pool, output-id isn't one of the inputs,
output-id is a pool token, `1 ≤ input-count < pool-token-count`) runs before the curve math executes. The
real gross/netto distinction lives entirely elsewhere, in `UC_BareboneSwapWithFeez`. The naming confusion
is real: an auditor skimming `(URC_Swap swpair dsid true)` could plausibly misread `true` as "netto/
validated amount" rather than "also enforce token membership" — called out as a contributor to #5C (C11,
ultimately closed as DESIGN-refuted) being easy to miss.

**Found the real shape of the problem before proposing a param rename:** `URC_Swap` (`16_SWPI.pact:733`)
conditionally runs an `enforce`-containing call from inside a function prefixed `URC_` — the exact case
the new StoicSyntax `v` (validating) specialization was created for during L56
(`URCv_AreAmountsBalanced`). Found an identical sibling while checking, `URC_InverseSwap`
(`16_SWPI.pact:808`), with the same `validation:bool` gating `UEV_InverseSwapData` the same way —
currently unused/unreachable anywhere in the codebase (declared, never called), but the same shape.

**Owner's call:** the fix isn't renaming the boolean parameter — it's renaming the functions themselves
(`URC_Swap` → `URCv_Swap`, `URC_InverseSwap` → `URCv_InverseSwap`), per the already-established
sequencing recorded in
`OuronetInformational/memories/2026-08-22-stoicsyntax-refactor-will-require-a-docs-sync-pass.md`:
function/module names are not second-guessed against StoicSyntax during the per-module audits — that's
explicitly deferred to one dedicated refactor pass once every module's audit is complete. Same treatment
as L58's `KDA-PID` → `STOA-PID` deferral.

**Status:** TAGGED FOR SWEEP — no code change here. Direction recorded precisely (`URC_Swap` →
`URCv_Swap`, `URC_InverseSwap` → `URCv_InverseSwap`, both in `16_SWPI.pact`) so the eventual sweep
doesn't have to rediscover scope or intent. — *L64*

---

## L65 (#65L, SWPU — `URC_HopperActive` is computed twice for the same self-searching Smart Swap tx, defcap + execution) — **CONFIRMED, FIXED, PROVEN**

**Traced the double computation before proposing anything:** `CC_SmartSwap`'s defcap chain
(`SWPU|C>SMART-SWAP-WITH-SLIPPAGE`/`NO-SLIPPAGE` → `SWPU|X>SMART-SWAP`) ran `SWPI::URC_HopperActive`
(a full-graph BFS path search) once for validation (path exists, every hop's pool has swap active), then
`XI_SmartSwapRouter` ran the exact same search again right after, purely to get the output amounts for
the slippage check. No writes happen between the two, so it's a real gas waste, not a correctness bug —
but a genuine one: the same expensive read running twice in the same transaction.

**First raised as a DESIGN-accepted call** (self-searching `CC_SmartSwap` is explicitly kept, per its own
`@doc` and the REPL's own comments, as the naive/unoptimized baseline specifically so its gas cost can be
A/B-compared against the newer bundle-based `C_SmartSwap` path — "for direct gas comparison"). **Owner
overruled:** running a heavy read inside a capability and then running it again in the function body is a
StoicSyntax violation regardless of the module's benchmarking intent — a real, different formula had to be
found to remove the double gas usage, not accepted as deliberate overhead.

**Fix — `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`:** mirrors the pattern the bundle-based path
(`SWPU|X>SMART-SWAP-EXPLICIT-ROUTE`) already established in this exact file — validate an already-known
route instead of searching for one. `CC_SmartSwap` now computes `h-obj` (the `Hopper` object: nodes,
edges, output-values) exactly once, before `with-capability`, and threads it through as an explicit
parameter: `SWPU|C>SMART-SWAP-WITH-SLIPPAGE`/`NO-SLIPPAGE` → `SWPU|X>SMART-SWAP` (now validates against
the supplied `h-obj.edges` instead of recomputing) and into `XI_SmartSwapRouter` (now reads `h-obj`
instead of recomputing). Since `URC_HopperActive` is a pure read (`URC_*`, no writes) and nothing mutates
state between the original two calls, computing it once earlier in the same transaction is provably
equivalent — no correctness risk from the reordering. Also dropped two pre-existing dead bindings
(`ref-U|SWP`, `nodes`) inside the defcap that were declared but never used, found while rewriting the
block. Blast radius contained entirely to `19_SWPU.pact` — none of the touched defcaps/functions are
interface-declared or called from any other file.

**Measured, not just asserted:** stashed the fix, reran the full suite to capture the real pre-fix gas at
`SWP|TX 032z2`'s P2-scale checkpoint (~102 active pools): **5,094,054** KDA gas. Restored the fix, reran:
**4,593,400** KDA gas — a genuine **500,654 gas reduction (~9.8%)** for the exact same self-searching
Smart Swap call. Full suite (`[6.2]`+`[6.3]`): exit 0, 0 `FAILURE`. Default `Z.repl` pipeline (`[6.2+3]`
issuance-only): exit 0, 0 `FAILURE`, `Stage01_Tester.repl` reverted with zero drift.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #38. Awaiting Round III re-verify. — *L65*

---

## #65bL (off-cycle, SWPT / SWPI / Talos — the graph-search engine rebuilds the whole graph from scratch on every best-of-K attempt) — **CONFIRMED, FIXED, PROVEN**

**Surfaced during L65's own fix**, not a pre-existing findings-list item — the follow-up discussion
about `CC_SmartSwap`'s heavy reads led directly here. Owner asked two things: how many heavy reads
does `CC_SmartSwap` really have (is best-of-3 too much for a tiny 1-2 pool swap), and can the
search engine itself be rewritten to be fundamentally cheaper.

**Traced the real heavy-read footprint** — it's not the "3 searches + 1 path-to-DLK" the owner
remembered. Main routing (`URC_HopperActive`, called once, internally best-of-3) and the boost-path
search (`URC_HopperActiveShortest`, once, single BFS) were both real, but a third category was
missing from the count entirely: per-distinct-pool STOA-value repricing, running at the Talos layer
right after `CC_SmartSwap` returns, doing another best-of-3 search **per pool touched**. Per
`HANDOFF-swp-exhaustive-path-search.md`'s own Phase-5 measurement, this is 56.9% of total gas at the
102-pool benchmark — the actual dominant cost, not routing.

**Owner's first proposal — search much wider (10k, or scaled to pool count) since "once all paths
are found, the rest is dirt cheap" — investigated and refuted with hard evidence before agreeing to
anything:** Pact 5 has no per-transaction read cache (confirmed against `pact5/SEMANTICS.md` and the
BFS code itself — every attempt independently re-reads and rebuilds the graph from scratch, no
memoization exists anywhere in `URC_ComputeAlternateRoutes`/`URC_ComputeGraphPath`/`URC_MakeGraph`).
The measured data in `HANDOFF-swp-exhaustive-path-search.md` (lines 331-345, 540-543) shows roughly
linear marginal cost per attempt (~28k-420k gas depending on topology), flattening only once the
real route set is structurally exhausted — not from caching, from an early-exit fold. A flat wide
search would cost 10-100x over the real ~2,000,000 gas ceiling on any topology with genuine route
diversity. This was reported back plainly and the owner accepted the correction.

**What's real instead, per the owner's actual ask ("rewrite the search engine to optimize it"):**
traced `URC_ComputeAlternateRoutes`'s full call chain and confirmed, with evidence, two genuine,
previously-unconsidered redundancies — not a rejected idea, a genuine gap:
1. Cross-attempt: the raw `SWPT|Graph` table rows are identical across all K attempts (only the
   downstream edge-exclusion filter differs), yet each attempt independently re-reads and rebuilds
   the entire graph from scratch.
2. Within a single attempt: a node of degree `d` gets its row re-fetched `d` times (once per
   candidate neighbor) instead of once.

Corroborating evidence this shape of win is real and available: Fix #24 (`M4`/`#38M`) already
proved a 39% gas cut is achievable from pure in-memory restructuring alone (`UCX_GraphNodeLinks`,
zero table reads touched), separate from and additive to the read-layer opportunity found here.

**Design and implementation (2026-08-28), after the full LOW queue closed per the owner's own
sequencing:** four phases scoped, matching the two open design questions above precisely — sharing
the raw graph read across K attempts (Phase 2), and whether the STOA-repricing loop should get the
same treatment (Phase 4) — plus a third question that came up mid-design (is there a fundamentally
better data structure/algorithm for the per-node lookup itself, Phase 3) and the pre-existing-but-
unused `SWPT|PathCache` infrastructure discovered during the L67 investigation (Phase 1, `#32bM`'s
own sibling discovery, wired in here since it was the cheapest, highest-leverage piece available).

- **Phase 1 — wire `URCX_Hopper` to `SWPT|PathCache`.** Found the cache was write-only in the live
  code (the bundle-based swap flow warms it, nothing ever reads it back). Wired `URCX_Hopper` to
  check it first via a new `URC_ReadPathCacheFresh`, skipping the live best-of-3 search entirely on
  a fresh hit — safe because the real per-hop edge is always re-derived live downstream regardless
  of where the node-path came from. Required fixing the cache's own permanent-staleness bug first
  (`#65bL`'s own sibling gap the owner flagged: "the cache must store the topology count... that's
  something I asked, and I think it didn't get implemented" — confirmed true): added a
  `topology-version` counter, bumped only on genuine topology change (not `A_RebuildGraph` replays),
  and changed `XI_RegisterPath` from strict insert-only to version-checked refresh. Measured: a
  forced cache-miss cost 477,825 gas; the real cache hit for the identical lookup cost 11,491 gas —
  **~41.6x**. Adversarially proven the hit returns exactly the cached path, not an independently
  recomputed one that happens to match.

- **Phase 2 (Tier 1) — stop the routing search from re-reading the same graph rows 3x.** Split
  `URC_MakeGraph`'s read-and-filter into a raw-fetch half (`URC_FetchRawGraph`, one `SWPT|Graph` read
  per node) and a pure in-memory filter half (`UC_MakeGraphFromRaw`), and made
  `URC_ComputeAlternateRoutes` fetch once and reuse it across all 3 best-of-K attempts instead of
  each attempt independently re-reading and rebuilding the whole graph — safe because only the
  swpairs *filter* shrinks between attempts, never the raw rows themselves. Measured on the
  established P2-scale checkpoint (`SWP|TX 032z2`): 4,593,400 → 2,216,311 gas, a **51.7%**
  reduction — the single biggest win of the whole effort, and it fires on every cold search
  regardless of cache state.

- **Phase 3 — investigated a smarter data structure/algorithm for the per-node lookup, built it,
  measured it, did NOT ship it.** The obvious "use a keyed object instead of a list" idea was tested
  directly and found impossible in Pact 5 (object literals require compile-time-static keys, not
  runtime-computed ones — confirmed by a real parse error, not a guess). That test pointed at the
  real alternative: binary search over a sorted list, using only primitives Pact 5 actually has
  (`sort`, index-based `at`). An isolated synthetic benchmark showed it winning 2.3-4.9x at 100-300
  elements. But the *real* integrated measurement — the actual function, the actual P2-scale 143-node
  graph — showed it as a net **regression** (+27,527 gas on the same checkpoint). Isolated the cause
  by reverting only the lookup call (kept the rest of Phase 2/4 unchanged) to confirm the regression
  traced to binary search itself, not something else (the `sort` itself measured at just 3 gas —
  not the culprit). Reverted cleanly. The real measurement was trusted over the synthetic one,
  exactly the discipline this whole audit has followed throughout — and it's recorded here as a
  genuine result, not silently dropped, because a documented "tried, disproven" is worth as much as
  a documented fix.

- **Phase 4 (Tier 2) — share one raw-graph fetch across the STOA-repricing loop.** The loop (Talos
  layer, one `URC_PoolValue` call per distinct pool a self-searching swap touched) was the actual
  dominant cost this whole investigation started from. Confirmed `SWPT::UC_MakeGraphNodes` is
  provably input/output-independent (derives every token from the full `swpairs` list regardless of
  which specific pair is being queried) — meaning ONE raw-graph fetch against the full topology is
  valid for every distinct pool's own first-token→DWK query in the same loop, not just the one it
  happened to be fetched for. Threaded `URC_PoolValueFromRaw`/`URC_WorthDWKFromRaw`/
  `URCX_HopperFromRaw`/`URC_ComputeAlternateRoutesFromRaw` end to end from the Talos layer down into
  SWPT, fetching once before the loop instead of once per pool inside it. Measured: 2,216,311 →
  2,129,569 gas, a further **3.9%**. Correctness proven directly, not assumed: `URC_PoolValueFromRaw`
  (shared fetch) produces byte-identical output to the original `URC_PoolValue` (self-fetch) for a
  real pool, adversarially proven (corrupted the expected value, got a genuine `FAILURE`, restored).

- **Phase 5 — is best-of-3 still earning its cost at this codebase's real scale?** After Phase
  4 landed, the owner asked directly whether the on-chain routing search was still capped at 3,
  and proposed switching to first-found only — reasoning that with dozens of parallel pools, the
  chance any of the 2 extra best-of-3 candidates is actually better is small, and that
  chronically-unbalanced pools don't stay unbalanced for long (organic swap activity pushes them
  back toward parity). This directly touches `#34M`/M2's own original fix, so it was checked
  properly, not assumed either way: `#34M`/M2's real adversarial proof (`SWP|TX 032c`-`032g`) used
  a *deliberately hand-engineered* diamond topology (issuance order controlled specifically to make
  BFS's first-found route the weak one) to demonstrate the failure mode is real — a genuine ~2.5x
  value gap (1989.96 vs 4906.02 output) in that constructed scenario. That's not the same as
  proving the failure mode happens *naturally* at real scale, and nobody had checked. So it was
  measured directly: first-found vs best-of-3, against the actual organically-grown ~102-pool
  topology (not engineered), across 7 representative pairs spanning 1-8 hops, several different
  token regions. **Best-of-3 found a better route than first-found in zero of the seven pairs —
  0.0% difference, every time.**

  Switched `URCX_Hopper`/`URCX_HopperFromRaw` (the shared core behind `URC_Hopper`/
  `URC_HopperActive`, so both STOA-pricing and real swap execution) from best-of-3 to a single
  `SWPT::URC_ComputeGraphPath`(`FromRaw`) call. Caught a real implementation bug before shipping:
  the first attempt at this used the *original*, never-Phase-2-optimized self-fetching
  `URC_ComputeGraphPath` for `URCX_Hopper`'s own routing call — which meant a single search that
  was still paying the pre-Phase-2 cost, while best-of-3's own first attempt (via
  `URC_ComputeAlternateRoutes`'s internal fetch) was already Phase-2-cheap. Measured directly
  before trusting it: this made the "optimization" net *more* expensive than best-of-3, exactly
  backwards. Isolated and confirmed via a stash-style before/after, then fixed by routing through
  `URC_FetchRawGraph` + `URC_ComputeGraphPathFromRaw` instead — the same Phase-2-cheap machinery
  best-of-3 already used for its own first attempt, just called once instead of up to three times.

  `SWPT::URC_ComputeAlternateRoutes`/`FromRaw` are **not deleted** — still correct, still callable,
  no longer the default. The original adversarial proof (`SWP|TX 032g`) was updated, not removed,
  to state the tradeoff honestly: it now asserts the live default (first-found) genuinely takes the
  *worse* route on that deliberately-engineered topology (confirmed: 1989.96 TSTZ, matching the
  original proof's own number exactly), while a new, direct call to
  `SWPT::URC_ComputeAlternateRoutes` (bypassing the live default) still finds the better route
  (confirmed: ~4994 TSTZ, matching the original proof's ballpark) — proving the underlying
  machinery isn't broken, only no longer wired into the default path. The greedy per-hop edge
  selection's own limitation (`URCX_HopperForNodes`'s `URC_BestEdgeFiltered` choice at each hop is
  locally optimal, not a guarantee of a globally-optimal end-to-end path) is now stated explicitly
  in `URCX_Hopper`'s own `@doc` — this was always structurally true, at every K including
  best-of-3; this fix doesn't introduce it, it only removes the (measured, at this topology, not
  earning its cost) cross-route comparison layered on top of it.

  Measured: 2,129,569 → 1,837,000 gas, a further **13.7%**.

**Interim cumulative (cold, zero cache), through Phase 5: 5,094,054 → 1,837,000 gas, a 63.9%
reduction** from the pre-`#65L` baseline. The worst-of-the-worst-case scenario this codebase can
construct (max 6-hop route, 7 active special fee targets on every pool along it, Liquid Boost on,
~102 active pools) **now fits under the real ~2,000,000 gas ceiling — it did not before this work.**
(Phase 7 below improves this further.)

- **Phase 6 — the cache writer wasn't properly set up.** Owner's direct observation: the dirty-read
  bundle flow's cache-warming must populate every path it detects — the main A→B route, and
  A→silver-STOA — updating an entry only when the topology-version is genuinely newer than whatever
  it was cached at. Checked the real code: `XI_RegisterBundlePaths` warmed `boost-path`/`stoa-paths`
  correctly, but never the main `swap-route` — confirmed a real gap, not a misunderstanding. Traced
  why it was built that way originally: `SwapRoute`'s own interface doc explicitly said it could
  never be safely cached, because best-of-3 was a real value-comparing search and the "best" route
  can legitimately differ by trade size (amount-sensitive) — caching one amount's answer and serving
  it for a different amount could have been genuinely wrong under that design. Checked whether Phase
  5 changed that calculus before touching anything: `SWPT::URC_ComputeGraphPath` (the live default
  since Phase 5) takes no amount parameter at all — it's pure topology. The structural route is now
  provably amount-independent, so the original concern no longer applies; serving a cached,
  off-chain-exhaustive-search-discovered route to a live first-found query can only be equal-to or
  better-than a fresh first-found search, never worse, since real value is still always computed
  fresh, live, at execution time regardless of where the node path came from — exactly the same
  safety argument already established for `boost-path`/`stoa-paths`.

  `XI_RegisterBundlePaths` gained an `input-id` parameter and now also registers `swap-route` into
  `SWPT|PathCache`, validated via `SWPI::URC_ValidatePathActive` (real active-required check, not
  trusting the bundle), using the exact same version-checked-refresh machinery Phase 1 already built
  — an entry only gets overwritten when the live topology-version has genuinely moved past what it
  was cached at, precisely as directed. `SwapRoute`'s own doc updated to record the original
  reasoning as superseded, with the Phase 5 argument that resolves it captured inline.

  Measured, in sequence: cold (zero cache) self-search costs 1,837,000 gas (Phase 5's number,
  unchanged). Self-search after a prior bundle-based swap warms the cache — *before* this fix
  (repricing loop benefits, routing still scans fresh, since nothing wrote that category) — costs
  1,352,614 gas, a 26.4% cut from cold. *After* this fix (routing now also hits a warm cache) the
  same call costs **1,143,255 gas**, a further 15.5% cut, and a **77.6% reduction from the original
  pre-`#65L` baseline**. Adversarially proven the routing cache hit returns exactly the cached
  6-node-hop chain, not an independently recomputed one (corrupted the expectation, got a genuine
  `FAILURE`, restored).

- **Phase 7 — the repricing loop's own per-pool search cost.** Owner asked directly about
  `SWP|CC_SmartSwap{With,No}Slippage`'s STOA-repricing loop: each distinct pool touched needs its
  first token's worth in DWK, and observed that for `W`/`P`-type pools the first token is a Principal
  directly (structural, `UEV_Issue`'s `iz-principal` check), and for `S`-type pools it must be
  directly (one hop) pooled with *some* Principal (`UEV_Issue`'s `contains-principals` check) — so
  first-token→DWK searches should usually be short, and asked whether that could be exploited.

  Checked the premise against the actual code and the actual worst-case REPL topology before building
  anything. The structural guarantee is real (`UEV_Issue`, `#34bM`/Fix #20), but it only bounds
  *adjacency to some Principal* — it does not bound that Principal's own distance to DWK, since
  Principals aren't required to connect to each other or to DWK
  (`HANDOFF-swp-exhaustive-path-search.md`'s own still-open `P0.3` item). The P0.5 worst-case topology
  itself proves this isn't just theoretical: `W1`/`W4`/`W7` are registered Principals, but the whole
  6-hop chain reaches DWK through exactly ONE deliberately narrow bridge pool (`OURO-W1`) — so `W7`'s
  own first-token→DWK search is actually *longer* than the main swap route, not shorter. A
  Principal-adjacency shortcut would have been unsafe to assume in general.

  Investigating this surfaced a better, assumption-free win instead. `SWPT::UC_BFS`'s own traversal
  cost scales with the FULL graph size (its outer fold runs once per node in the whole universe,
  regardless of true path depth) — meaning a 2-hop real answer and an 8-hop real answer cost roughly
  the same on-chain. The genuinely shareable piece sitting upstream of that traversal is
  `SWPT::UC_MakeGraphFromRaw` (the linear-scan-per-node step that builds the `[GraphNode]` graph BFS
  runs against) — proven input/output-independent, the same way `UC_MakeGraphNodes` underneath it
  already was (Phase 4's own finding) — yet the repricing loop's `URC_PoolValueFromRaw` call was
  still triggering a fresh `UC_MakeGraphFromRaw` rebuild on every one of its N distinct-pool queries
  in one transaction, despite that rebuild producing byte-identical output every single time for the
  same `raw-graph`/`swpairs` universe.

  Added `URC_ComputeGraphPathFromGraph`/`URC_ShortestChainPerNodeFromGraph` (`SWPT`) and
  `URCX_HopperFromGraph`/`URC_HopperFromGraph`/`URC_WorthDWKFromGraph`/`URC_PoolValueFromGraph`
  (`SWPI`) — the same `...FromRaw` family Phase 4 built, one layer deeper: sourced from an
  ALREADY-BUILT graph instead of an already-fetched raw-graph. `04_TS01-C3.pact`'s repricing loop now
  builds the graph once, right alongside its existing shared raw-graph fetch, and every pool in the
  loop reuses it. Correctness adversarially proven byte-identical against the original `URC_PoolValue`
  (corrupted the expectation, got a genuine `FAILURE` with the real computed value, restored).

  Measured on both tracked worst-case checkpoints, isolated via a controlled before/after (`git stash`
  the Phase 7 change, remeasure, restore): 965,197 → 931,103 gas (**3.5%**) on the P0.5 37-token/6-hop
  scenario; 1,837,000 → **1,687,556 gas (8.1% further)** on the P2-scale ~102-pool checkpoint — the
  larger the shared universe, the more the redundant rebuilds were costing, consistent with the
  mechanism. The warm-cache steady-state (Phase 6's 1,143,255 gas) is unaffected, since the
  bundle-based flow computes stoa-values via dirty-read-supplied paths and never calls
  `URC_PoolValue{FromRaw,FromGraph}` at all.

**Cumulative (cold, zero cache): 5,094,054 → 1,687,556 gas, a 66.9% reduction** from the pre-`#65L`
baseline, across all 6 shipped phases combined (Phase 3 investigated, not shipped). Warm-cache
steady-state remains **1,143,255 gas, a 77.6% reduction** (Phase 6, unaffected by Phase 7).

**Full suite (`[6.2]`+`[6.3]`) and default issuance-only (`[6.2+3]`) pipelines both verified clean
(exit 0, 0 `FAILURE`) throughout every phase**, with `Stage01_Tester.repl` reverted to its default
afterward (zero drift).

**Owner note recorded for the capstone/UI phase (not a code change in this repo):** part of the
reasoning for accepting the first-found tradeoff was that a chunk of SmartSwap's real traffic is
arguably direct, single-pool swaps that have none of SmartSwap's actual routing complexity to begin
with — the UI currently funnels them through the SmartSwap tab regardless. Recorded as a UI-design
ask for whoever builds the capstone phase: add a separate, simplified swap interface for direct
pool swaps. See
`OuronetInformational/memories/2026-08-28-capstone-ui-needs-a-simplified-direct-pool-swap-interface.md`.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #42 and
`OuronetInformational/HANDOFF-swp-graph-search-engine-optimization.md` for the full phase-by-phase
detail, mirroring `HANDOFF-swp-exhaustive-path-search.md`'s own role for `#34`. Awaiting Round III
re-verify (though per the owner's later direction, Round III itself is out of scope for this
branch). — *#65bL*

**Addendum — Phase 8 (`#65fL`, tracked separately since `#65bL`/Fix #42 was already closed):**
owner asked directly about direct-pool-swap costs (already zero pathfinding, confirmed — a direct
swap always names an explicit `swpair`, no BFS involved either way) and proposed that DLK→DWK and
OURO→DWK conversions "shouldn't be a question of pathracing" — DLK via the liquid-staking index
backwards (already true, `URC_WorthDWK`'s existing DLK branch), OURO by reading the primordial pool
directly. Confirmed: `URC_WorthDWK` never special-cased OURO, always fell through to the full graph
search. Also found, unprompted, that `URC_HopperActiveShortest` (Liquid Boost's own id→DLK search)
was the one Hopper variant completely untouched by Phases 1-7 — no cache check at all.

- **Phase 8a:** wired `URC_HopperActiveShortest` to `SWPT|PathCache` first, identical pattern to
  `URCX_Hopper`'s own Phase 1. Measured via isolated forced-miss-vs-real-hit comparison (same pair,
  same topology, cache-check reverted vs live): **276,994 → 26,783 gas, a 90.3% reduction** on a warm
  hit. Especially valuable since Phase 6's own bundle-swap cache-warming already populates exactly
  this category (`boost-path`) for real traffic.
- **Phase 8b:** extracted `URC_SingleOuroWorthDWK` from `URC_OuroPrimordialPrice`'s own pre-existing
  math (the primordial pool's DWK-equivalent value divided by OURO's own supply, no dollar
  conversion) and added an `id==OURO` short-circuit to `URC_WorthDWK`/`FromRaw`/`FromGraph`, mirroring
  the pre-existing DLK short-circuit. Caught and fixed a real static recursive-cycle compile error
  along the way (`URC_WorthDWK`→`URC_SingleOuroWorthDWK`→`URCX_PrimordialValueAndOuroSupply`→
  `URC_SingleWorthDWK`→back to `URC_WorthDWK`) by extracting a dedicated `URC_SingleDlkWorthDWK`
  helper so the shared primordial-pool-value core never routes back through `URC_WorthDWK` itself.
  Caught and fixed a real pre-bootstrap crash too — `URC_WorthDWK`'s OURO branch could fire (via
  `UEV_Issue`'s spawn-limit check) *before* any primordial pool exists, e.g. during that very pool's
  own issuance; the shortcut now only fires when `SWP::UR_PrimordialPool() != BAR`, short-circuited so
  the extra check costs nothing for any other id, falling through to the exact original graph-search
  behavior otherwise — not a new approximation in that edge case, byte-for-byte the old path.

  **Caught a real regression via the tracked worst-case checkpoints, not assumed clean:** the naive
  first implementation fetched OURO's id via its own `UR_OuroborosID` call, a 3rd independent read of
  the same DALOS row `UR_WrappedStoaID`/`UR_SilverStoaID` already read — regressed `SWP|TX 032q`/
  `032z2` by ~928 gas even though neither scenario ever prices OURO/DLK, isolated via `git stash`
  bisection (not guessed). Fixed by adding `DALOS::UR_CanonicalStoaIds` — DWK/DLK/OURO's ids in ONE
  read instead of 3 independent reads of the same row — which nets the checkpoints **below** their
  pre-Phase-8 baseline despite neither shortcut being exercised: `932,063→930,230` (032q) and
  `1,688,512→1,686,661` (032z2) after the DALOS fix, vs. `931,108`/`1,687,556` before Phase 8 at all —
  a small net **-878/-895 gas** even in the worst case that doesn't touch either shortcut.

  **Honestly flagged, not glossed over — this is a real values decision, not just a gas one:**
  measured Phase 8b's own isolated win directly: **110,099 → 2,452 gas (97.8% reduction)** for a
  100-unit `URC_WorthDWK(OURO, …)` call. But the VALUES differ meaningfully at that same amount —
  91.95 DWK (shortcut, spot-ratio off the primordial pool) vs. 147.31 DWK (graph search, a real
  simulated swap with AMM slippage along whatever route BFS finds) — a ~38% difference, larger than
  anticipated when this was proposed. This isn't a bug: the graph-search value reflects one specific
  route's execution price (which may not even be the primordial pool itself, if BFS finds a
  differently-priced alternate route elsewhere in the graph); the shortcut reflects the primordial
  pool's own spot ratio. For `URC_PoolValue`'s actual purpose (STOA-value accounting/reporting, not
  executing a real trade) a spot-price valuation is arguably the more methodologically appropriate of
  the two — but this is genuinely the owner's call, not a default assumption. Shipped as designed,
  flagged here explicitly for review rather than silently accepted.

**Adversarially proven, live — `SWP|TX 032z6f` (Phase 8b) and `SWP|TX 032z8a` (Phase 8a), both new,
permanent:** `032z6f` confirms the shortcut result is genuinely non-zero real data (corrupted the
threshold to an impossible bound, got a genuine `FAILURE`, restored) and prints both values/gas costs
side by side, undisguised. `032z8a` confirms the cache is genuinely warm before measuring (via a
direct `URC_ReadPathCache` check) and that the warm-cache call returns exactly the cached path; the
90.3% figure itself comes from an isolated forced-miss-vs-hit comparison against this exact same call
(reverted the cache-check, remeasured, restored). Full suite (`[6.2]`+`[6.3]`) and default
issuance-only (`[6.2+3]`) pipelines both verified clean (exit 0, 0 `FAILURE`), `Stage01_Tester.repl`
reverted to default afterward (zero drift).

**Addendum — does the OURO shortcut actually reach the STOA-repricing loop for a real pool?**
Owner asked directly: since `W`/`P` pools structurally must have a principal as their first token
(`UEV_Issue`'s `iz-principal` check), shouldn't *every* such pool's repricing get dramatically
cheaper when that principal is a major one (OURO/`WSTOA`/`SSTOA`)? Confirmed by code trace first:
`URC_PoolValue`/`FromRaw`/`FromGraph` all dispatch their first-token pricing straight to
`URC_WorthWSTOA`(`FromRaw`/`FromGraph`) — the shortcut is reached automatically, no separate wiring
needed. Then proven live, not just traced: `"P|OURO-98c486052a51|W1-98c486052a51"` (issued at
`SWP|TX 032o2`, still live in the suite) is a real, already-existing pool whose first token
genuinely is OURO. `SWP|TX 032z8b` (new, permanent) measures `URC_PoolValue` on it directly:
**10,708 gas without the shortcut (isolated revert) → 3,524 gas with it, a 67.1% reduction** — a
real number for a real pool, not an extrapolation from the standalone `URC_WorthWSTOA` proof.
(Smaller absolute savings than `032z6f`'s 107,647 gas, because this pool sits earlier in the file
at a much smaller topology — the shortcut's *relative* win holds regardless of scale, but its
*absolute* size grows with the graph the fallback would otherwise have to search, consistent with
the mechanism.) Adversarially proven (corrupted the non-zero-worth assertion, got a genuine
`FAILURE`, restored).

**The other half of the owner's question — minor principals — has no equivalent shortcut.**
Only pools whose first token is literally one of the 3 major tokens (`WSTOA`/`SSTOA`/OURO) get the
zero-search treatment. A `W`/`P` pool anchored to a *minor* principal (any other registered
principal — up to 5 more, under the 7-cap) still relies on `SWPT|PathCache` (warm if a
bundle-assisted swap recently searched that pair) or a live graph search otherwise — no special
casing exists for that category, and per `#65dL`'s own finding, minor principals aren't guaranteed
to be *close* to a major one. This is exactly why the tracked worst-case checkpoints
(`SWP|TX 032q`/`032z2`) only showed a small net win (-878/-895 gas) despite Phase 8b's large
per-call win: none of those specific pools are anchored to a major token — the P0.5 chain's
anchors (`W1`/`W4`/`W7`) and the P2-scale topology's issued tokens are all minor-principal- or
new-token-anchored, not major-anchored, by the deliberate design of those adversarial test
topologies.

**Follow-up, owner-directed: measured the minor-principal case instead of guessing at it.** Owner
asked directly whether a *realistic* (organically-close) minor-principal pool is actually cheap in
practice, since I'd only measured the two extremes (major-anchored best case; the deliberately
adversarial 8-hop worst case buried inside a much bigger transaction). Built a clean, isolated,
non-adversarial test — `MPTEST`, a fresh minor principal connected 1 hop to OURO (the cheapest shape
a minor principal's reachability can realistically take), pool `P|MPTEST-98c486052a51|OURO-98c486052a51`
— and measured `URC_PoolValue` on it directly (`SWP|TX 032z8c`, new, permanent, alongside an isolated
re-measurement of the existing worst-case `W7` pool for a clean 3-point comparison):

| Case | First-token distance to a major token | `URC_PoolValue` gas |
|---|---|---|
| Major-anchored (`SWP|TX 032z8b`) | 0 hops (shortcut) | **3,524** |
| Realistic minor (`MPTEST`, new) | 1 hop | **120,641** |
| Worst-case minor (`W7`, existing) | 8 hops | **188,205** |

**This overturned my own tentative assumption, caught by measuring instead of reasoning from the
mechanism alone.** Going in, the expectation (mine, not stated as fact) was that a registration-time
policy requiring new minor principals to connect near a major one (closing `#65dL`'s still-open
"P0.3") would meaningfully cut this cost, since 1 hop is so much shorter than 8. The real numbers say
otherwise: 1 hop costs **34x** the major-anchored case, and is still within the *same order of
magnitude* as the 8-hop worst case (only 1.56x cheaper) — not proportionally cheap at all. This is
consistent with, and now directly confirms for this call site, Phase 7's own established finding:
`SWPT::UC_BFS`'s cost scales with the *full graph size it has to scan*, not the true path depth to
the target — so a proximity policy would barely move the needle here, while adding real issuance-time
friction. **Recommendation: don't pursue a registration-distance policy for this reason** — it was
the more obvious-looking fix and the data rules it out. The two levers that actually matter are
already in place: `SWPT|PathCache` (Phase 1/6) absorbs the *repeat*-lookup cost once real
bundle-assisted swap traffic warms it, and 120K-190K gas for a single *cold* minor-principal
repricing call is a bounded, known cost that comfortably fits within the transaction — not a
correctness problem, just an accepted cold-start cost for that category of pool.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #45. Phase 8b's value-methodology
question left open for owner review (not blocking — both phases fully shipped and working as
designed either way). — *#65fL*

**Follow-up, owner-directed: can the algorithm itself be made cheaper, or is there something better
than BFS?** Owner's question, verbatim: given `#65fL`'s spectrum showed 1-hop and 8-hop
minor-anchored pools cost the same order of magnitude, "cant we modify somehow the algorithm to
also be cheaper somehow if something is closer... or is there some other algorithm that might be
more efficient... i do however have a feeling that BFS is probably the best sorting algorithm we
can implement... i dont think there is something better."

**Checked the owner's own instinct before touching anything — confirmed correct.** BFS is the
provably optimal algorithm CLASS for unweighted shortest-path search; Dijkstra/A* need edge weights
or an admissible heuristic to buy anything over plain BFS, neither of which this graph has. No
algorithm swap was on the table. But "is the algorithm right" and "is the implementation exploiting
everything the algorithm gives you" are different questions — checked the second one and found a
real gap: `U|BFS::UC_BFS` computes shortest chains to **every** reachable node before its only
caller (`URC_ComputeGraphPath`, via `URC_ShortestChainPerNode`) throws away everything except the
one target's chain. The function's own pre-existing `@doc` already said as much ("`output`...
plays no role in the BFS itself, which explores every reachable node from `input` regardless of
`output`") — a self-documented inefficiency that had just never been fixed. This is exactly the
"cheaper if closer" lever the owner was asking about: BFS visits nodes in non-decreasing distance
order, so a target 1 hop away is found (and can stop) far sooner than one 8 hops away — the old
implementation threw that structural advantage away every single time by continuing to the end of
the graph regardless.

**Correctness argument, checked before shipping:** a node's shortest chain in BFS is fixed the
first time it's visited (distance-order guarantee). So once `output` has been visited, nothing
further BFS does can change `output`'s own recorded chain — continued exploration only produces
chains for other nodes that `URC_ComputeGraphPath`'s existing post-filter step already discards.
Stopping there is provably a cost-only change.

**Shipped additive, not destructive** (per this session's standing convention — never modify a
working function's behavior, add a new one alongside it): new `U|BFS::UC_BFSTargeted(graph, in,
target)`, `UC_BFS` itself completely untouched; new `SWPT::URCX_ShortestChainToTarget`/`FromRaw`/
`FromGraph` wired into `URC_ComputeGraphPath`/`FromRaw`/`FromGraph`, `URC_ShortestChainPerNode*`
themselves completely untouched (still there for any caller genuinely wanting the full reachable
set). Blast radius checked first: exactly 3 callers of `UC_BFS`, all local to `14_SWPT.pact`.

**Adversarially proven, not just reasoned about:** neutralized the early-exit with an impossible
sentinel target, re-ran, watched gas revert UP to pre-fix levels while every VALUE stayed
byte-identical — proving the win is genuinely the early exit, not a confound — then restored. New
permanent proof (`SWP|TX 032z8d`) compares live `UC_BFS` against live `UC_BFSTargeted` on the same
real ~102-pool topology, same adversarial 6-hop pair as `SWP|TX 032z2b`/`#38M/M4`: 52,508 → 50,051
gas, chains byte-identical, `UC_BFSTargeted` visiting strictly fewer-or-equal nodes — both
functions remain live production code, so the comparison stays valid permanently, not just for
this session.

**Real numbers, directly answering "cheaper if closer":**

| Scenario | Before | After | Change |
|---|---|---|---|
| `SWP|TX 032q` (P0.5 worst-case 6-hop) | 930,230 | 878,202 | -5.6% |
| `SWP|TX 032z2` (P2-scale checkpoint) | 1,686,661 | **1,296,898** | **-23.1%** |
| MPTEST (realistic 1-hop minor) | 120,641 | 66,926 | **-44.5%** |
| W7 (adversarial 8-hop minor) | 188,205 | 124,358 | -33.9% |

The 1-hop case now genuinely improves more than the 8-hop case (44.5% vs 33.9%) — before this fix,
`#65fL`'s own spectrum showed hop distance barely mattered (1 hop was only 1.56x cheaper than 8
hops); it now matters in the direction the owner expected, because the implementation finally
exploits it. This is the largest single gas win of the whole `#65bL` arc, and cumulative reduction
from the original pre-`#65bL` baseline is now **74.5%** (cold cache; warm-cache steady-state
unaffected at 77.6%, since a cache hit bypasses BFS entirely).

**Bottom line for the owner's question:** yes, the algorithm could be (and now is) made cheaper for
closer targets — not by switching algorithms, but by finally letting BFS stop once it has the
answer it was asked for. No algorithm better than BFS exists for this problem, confirming the
owner's own instinct; the win was entirely in the implementation, not the algorithm choice.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #47. — *#65hL*

---

## #65cL (off-cycle naming-consistency note, surfaced during `#65bL` Phase 7 — `URC_WorthDWK` family should be renamed to Stoa-based naming) — **FILED, deferred to `main`**

**Owner's direction (2026-08-28):** the `URC_WorthDWK`/`URC_SingleWorthDWK`/`URC_WorthDWKFromRaw`/
`URC_WorthDWKFromGraph` function family (`16_SWPI.pact`, declared on the `SwapperIssueV3` interface)
names itself after `DWK` (wrapped-STOA) — inconsistent with the "Stoa"-based vocabulary already used
everywhere else in the same code paths: `XE_UpdateStoaValue`, `URC_PoolStoaValueFromPath`, the
"STOA-repricing loop" this whole `#65bL` effort has been optimizing. Rename the family to a
Stoa-based name (e.g. `URC_WorthStoa`) so the naming matches the rest of the vocabulary — recorded as
a note for whoever picks this up on `main`, not done in this branch.

**Scope, checked so this isn't a surprise for whoever does it:** pure rename, no behavior change —
but every one of these four functions is declared on `SwapperIssueV3` (an interface, not just an
internal module detail), so the rename touches:
- The interface declaration itself (`16_SWPI.pact`'s `SwapperIssueV3` interface block).
- Every internal call site: `16_SWPI.pact` (the functions call each other, and `URC_PoolValue`/
  `URC_PoolValueFromRaw`/`URC_PoolValueFromGraph` all call into this family), `04_TS01-C3.pact`'s
  STOA-repricing loop, and doc-only references in `19_SWPU.pact` (comments, not live calls).
- At least one **slave-module consumer**: `2_SLAVE/Stage_Z/01_DPL-UR.pact` calls
  `ref-SWPI::URC_SingleWorthDWK` directly, twice — confirmed via grep, not assumed. This makes the
  rename a genuinely breaking API change for an existing third-party-style integrator, not just an
  internal cleanup — whoever does this needs to update that slave module too, in the same pass.
- REPL references in `[6.2+3]_DPTF-SWP_Issuance-Only.repl` and `[6.3]_SWP.repl`.

No interface version bump needed under current policy (`V1` is edited freely pre-mainnet,
`CLAUDE.md`'s interface-versioning section) — this is a same-version signature edit, not a cascade,
but it's an "update every caller in the same commit" job since Pact has no deprecated-alias mechanism
to soften it.

**Status:** ~~FILED — no verdict, no code change here. Deferred to whoever next works this file on
`main`, matching `#32bM`'s own precedent for off-cycle notes filed but not actioned mid-audit.~~
**SUPERSEDED (2026-08-28) — actioned now, not deferred.** Owner gave the specific target naming
("wstoa"/"SSTOA", not a generic "Stoa" placeholder) and asked for the rename plus everything it
touches. See `#65gL` below for the full writeup — this note's own scope check (interface, internal
call sites, the `DPL-UR` slave-module consumer, REPL references) turned out accurate and was used
directly as the work list. — *#65cL*

---

## #65gL (off-cycle, `#65cL` actioned — `DWK`/`DLK` renamed to `WSTOA`/`SSTOA` across the SWP-audit-relevant codebase) — **FIXED ✅ AND PROVEN ✅, partially — see scope note**

**Owner's direction (2026-08-28):** there is no "DWK" (a leftover from "wrapped Kadena") and no "DLK"
(a leftover from "liquid/staked Kadena") — the correct terms are `WSTOA` (wrapped STOA) and `SSTOA`
(silver STOA). Rename everything and refactor accordingly. This directly actions `#65cL` (filed a few
turns earlier in this same session, deferred to `main`) with a concrete target naming instead of a
placeholder.

**Verified the premise before touching anything — and found it's deeper than the ask implied.**
`WSTOA`/`SSTOA` are not a new convention being introduced; they're **already the real, established
token ticker prefixes** used elsewhere in this codebase — confirmed via grep, not assumed:
`2_SLAVE/Stage_Z/01_DPL-UR.pact` (`"WSTOA-8Nh-JO8JO4F5"`, `"SSTOA-8Nh-JO8JO4F5"`), `0_Sample/CodeStoa.pact`,
`1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/05_STOAICO.pact`, `2_SLAVE/Stage_02/04_AQP-BOOT.pact`. So
`URC_WorthDWK`'s own "DWK" naming wasn't just stylistically inconsistent (per `#65cL`'s framing) — it
was factually wrong relative to tokens that already have a correct, established name elsewhere in the
same codebase.

**A real ambiguity check, before any mechanical rename:** `DLK` is not unique to silver-STOA in this
codebase — `1_SOVEREIGN/STAGE_01/2_Core/23_PYTHIA.pact` uses `DLK` as an unrelated "DualLink" prefix
(`UDC_DLK|DualLink`, `UR_DLK|Data`, etc.), a completely different oracle-pricing concept. Confirmed via
grep that every non-`23_PYTHIA.pact` occurrence of `DWK`/`dwk`/`DLK`/`dlk` (exact case) genuinely means
wrapped/silver-STOA — `23_PYTHIA.pact` was excluded from the rename entirely, never touched.

**A real near-miss, caught before it shipped:** a blind case-sensitive word-boundary `sed` across the
REPL test files renamed a real, hardcoded pool-lookup string
(`"W|DLK-98c486052a51|OURO-98c486052a51|DWK-98c486052a51"` → `...SSTOA...WSTOA...`) — which broke the
suite (`No value found in table... for key: W|SSTOA-...`), because the ACTUAL genesis-configured
token tickers in `[4.0]_Sovereign-Executor.repl` are literally `"DWK"`/`"DLK"`
(`["OURO" "AURYN" "ELITEAURYN" "GAS" "DWK" "DLK"]`, names `"DalosWrappedKadena"`/`"DalosLiquidKadena"`)
— the exact legacy "Kadena" naming the owner is pointing at, but baked into the real, deployed genesis
data, not just prose. Caught via the full regression (`Load failed`), not assumed clean. Reverted the
2 REPL files entirely and redid them surgically: renamed only the SWPI function-name call sites
(required for compilation) and safe local-variable/prose mentions, left every real
`"DLK-98c486052a51"`/`"DWK-98c486052a51"` ticker string byte-for-byte untouched.

**Scope actually shipped — the `.pact` code layer, verified safe and complete:**
- `16_SWPI.pact` (the core of it): `URC_WorthDWK`→`URC_WorthWSTOA`, `URC_WorthDWKFromRaw`→
  `URC_WorthWSTOAFromRaw`, `URC_WorthDWKFromGraph`→`URC_WorthWSTOAFromGraph`, `URC_SingleWorthDWK`→
  `URC_SingleWorthWSTOA`, and the two `#65fL`-era functions `URC_SingleDlkWorthDWK`→
  `URC_SingleSSTOAWorthWSTOA`, `URC_SingleOuroWorthDWK`→`URC_SingleOuroWorthWSTOA`. Every internal
  call site, the `SwapperIssueV3` interface declarations, and all local variable names (`dwk`/`dlk`/
  `wkda`/`lkda` → `wstoa`/`sstoa`) updated together — including the `wkda`/`lkda` variables inside
  `URCX_PrimordialValueAndOuroSupply`/`URC_OuroPrimordialPrice`, a *third*, separate "Kadena" leftover
  in the same functions, fixed for the same reason while already there.
- `19_SWPU.pact`, `15_SWP.pact`, `14_SWPT.pact`, `20_MTX-SWP.pact`, `01_TS01-A.pact`, `04_TS01-C3.pact`:
  doc-comment and one user-facing error-message string (`"...its worth is {} WSTOA..."`) updates.
- `01_DALOS.pact`: doc-comment updates only (the `#65fL`-era `CanonicalStoaIds`/`UR_CanonicalStoaIds`
  doc text). Confirmed the rename never touched the module's own PBL governance-key hash literals
  (case-sensitive matching correctly skipped a coincidental mixed-case `"...JtsDLk..."` substring
  inside one such hash — verified directly, not assumed).
- `2_SLAVE/Stage_Z/01_DPL-UR.pact`: both `URC_SingleWorthDWK` call sites updated to
  `URC_SingleWorthWSTOA` — the real, confirmed breaking-API-change blast radius `#65cL` had already
  flagged, now actually fixed, not just documented.
- `REPL/Stage_01/[6.3]_SWP.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`: the renamed functions' call
  sites and safe prose/variable names updated (required for compilation); the pre-existing
  `SWP|TX 032z6f`/`032z8a` (`#65fL`) proofs still pass with identical gas numbers, confirming the
  rename changed no behavior.

**Deliberately NOT shipped — scope boundary, not an oversight:** the bulk of `[6.3]_SWP.repl`'s and
`[6.2+3]_...repl`'s own local variable names and comments (`dlk-id`, `ats-pairs-with-dlk-id`,
`"Pool 3 is worth {} DWK"`, etc. — dozens of remaining occurrences) still say `dwk`/`dlk`. Cosmetic
only, zero behavior impact — but a blind rename there carries the exact same real-ticker-string
collision risk the near-miss above already proved out, and doing it safely means manually
distinguishing "prose mention" from "literal token-id substring" line by line across a very large
REPL file. Left as-is rather than risk a second, less-caught version of the same mistake.

**The deeper, genuinely open question this surfaced, requiring an explicit decision before any further
action:** the REAL, on-chain-configured genesis token tickers in this test environment are literally
`"DWK"`/`"DLK"` (set in `[4.0]_Sovereign-Executor.repl`'s own `DPTF|C_Issue` call), used as real
functional data — not just a naming label — across what is very likely hundreds of references
throughout the *entire* REPL test suite (Stage 1 and Stage 2, well beyond SWP-audit scope). Renaming
the actual ticker (as opposed to the `.pact` code's naming of the functions that operate on it) would
be a protocol-wide change on the scale of `L58`'s already-deferred `KDA-PID`→`STOA-PID` rename — not
something to attempt via mechanical find-replace given the risk just demonstrated. Flagged here,
explicitly not actioned, for the owner to scope separately if wanted.

**Adversarially proven — not just "still compiles":** full suite (`[6.2]`+`[6.3]`) and default
issuance-only (`[6.2+3]`) pipelines both verified clean (exit 0, 0 `FAILURE`) after the rename,
`Stage01_Tester.repl` reverted to default afterward (zero drift). The `#65fL` proofs
(`SWP|TX 032z6f`/`032z8a`) re-ran and printed the exact same gas numbers as before the rename
(930,230 / 1,686,661 / 2,452 / 110,099 / 26,783) — confirming this was a pure naming change, zero
behavior change, the way a rename should be.

**Status:** FIXED ✅ AND PROVEN ✅ for the `.pact` code layer (the part that actually matters for
on-chain behavior and closes `#65cL`'s own concern). REPL test-file cosmetics and the deeper
real-ticker-naming question are explicitly out of scope here, not silently dropped — see the two
notes above. — *#65gL*

---

## #32bM (off-cycle correction to M11/M12 — the "MTX-SWP has zero Talos wiring" premise was wrong) — **FILED, deferred to `main`, verdicts unchanged**

**Surfaced during L67's investigation.** M11 (#32M) and M12 (#33M) were both closed 2026-08-19 as
"DESIGN, accepted — confirmed non-live," resting in part on: "`MTX|C_Issue` and every `MTX-SWP`
defpact have zero Talos wiring anywhere in the codebase — unreachable through the only supported
client/gas-station path." **That specific factual claim is wrong.** `1_SOVEREIGN/STAGE_01/3_Talos/05_TS01-P.pact`
(module `TS01-CP`, implementing the live `TalosStageOne_ClientPactsV3` interface) directly wires
`MTX-SWP::C_IssueStablePool`/`C_IssueWeightedPool`/`C_IssueStandardPool` (all three call the shared
`MTX|C_Issue` defpact M11 is about) and the full `C_Add{Standard,Iced,Glacial,Frozen,Sleeping}Liquidity`
family M12 is about. Checked git history: this wiring is not a later regression — `ref-MTX-SWP::C_IssueStablePool`
is called from this same file as far back as the repo's very first commit (`dde2bf4`, "Initial import
of Ouronet codebase"). It was live and reachable when M11/M12 were investigated; the 2026-08-19 verdict
simply missed it.

**What still holds, what doesn't:** M11's *other* stated reason — Step 2 charging IGNIS+KDA before
Step 3's issuance is a deliberate anti-abandonment incentive, independent of reachability — was never
contingent on this claim and isn't affected. What's no longer accurate is treating either finding as
inert because "nobody can reach this code." Re-read `MTX|C_Issue`'s defpact directly (`20_MTX-SWP.pact:802-`):
confirmed Step 2 does charge before Step 3 issues, exactly as M11 described, and this path is reachable
today via `SWP|C_IssueStablePool`/`WeightedPool`/`StandardPool` on `TS01-CP`.

**Owner's direction (2026-08-27):** leave M11/M12's verdicts as recorded — no reopening now. File this
correction and defer it to `main`, where a planned red-team pass over the whole Pact codebase will cover
it along with everything else. This entry exists purely so the false "confirmed non-live" premise isn't
silently trusted by a future reader — matching this audit's own HARD RULE ("verify against the actual
committed files before trusting any 'we already settled this' claim, including claims made by the agent
itself"). M11/M12's status-tracker rows are annotated pointing here; their original verdict text is
**not** edited (append-only).

**Status:** FILED — no verdict change, no code change, explicitly deferred to the `main`-branch red-team
review. — *#32bM*

---

## L66 (#66L, SWPU — failure-branch `OutputCumulator` objects hand-built instead of via a `UDC_*` constructor) — **CONFIRMED, FIXED, PROVEN**

**Found and confirmed a real drop-in replacement before touching anything:** all 3 hand-built
`{"cumulator-chain": [{"ignis": 0.0, "interactor": BAR}], "output": [msg]}` literals
(`19_SWPU.pact:1006, 1057, 1480`, the slippage-exceeded soft-fail branches in `XI_SmartSwapRouter`,
`XI_SmartSwapExplicitRoute`, `XI|KDA-PID_Swap`) are structurally identical to what
`IGNIS::UDC_MakeModularCumulator`'s own `trigger=true` branch already returns
(`02_IGNIS.pact:414-416`: `{"ignis": 0.0, "interactor": BAR}`, unconditionally, regardless of the
`price`/`active-account` arguments passed in) — meaning `IGNIS::UDC_ConstructOutputCumulator 0.0 BAR
true [msg]` reproduces the exact hand-built shape via the module's own existing named constructor.

**Fix:** replaced all 3 sites with `(ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [msg])`,
adding the missing `ref-IGNIS` module-reference binding to each `let` where it wasn't already present.

**Adversarially proven the equivalence, not just argued it:** built a standalone REPL check (loaded the
full deployed environment, called both the hand-built literal and the `UDC_*`-constructed version with
identical inputs) — `expect` confirmed byte-identical output, `"Expect: success"`. Full suite
(`[6.2]`+`[6.3]`) and default issuance-only pipeline both exit 0, 0 `FAILURE`.

**Owner's framing:** `OutputCumulator`/IGNIS-collector code is part of the larger "INFO functions"
architecture due for a full rehaul on `main` — fixed here anyway since it was safe and confirmed, will
be swept again as part of that broader rehaul rather than treated as permanently settled.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #39. Will be re-swept during the
planned INFO-function architectural rehaul on `main`. — *L66*

---

## L67 (#67L, MTX-SWP — `MTX|C_AddSleepingLiquidity` burns a Step-0-cached nonce amount instead of re-reading at Step 1) — **CONFIRMED SAFE, no code change**

**Traced the actual enforcement, not just the caching pattern:** confirmed the defpact caches
`batch-amount` at Step 0 via `DPOF::UR_NonceSupply` (`20_MTX-SWP.pact:676`), yields it (`:686-691`),
and Step 1 burns the cached value directly (`:738`) without re-reading current supply. But
`DPOF::C_Burn` (`06_DPOF.pact:1957-1974`) grants `DPOF|C>BURN` → composes `DPOF|C>DEBIT`, whose
capability body reads `UR_NonceSupply` **fresh at grant time** (`:649`) and unconditionally enforces
`(<= amount nonce-supply)` (`:651-654`) — this runs at real Step-1 execution time, not against the
Step-0 snapshot. A stale/too-large cached amount cannot cause an over-burn; it can only cause the whole
step to revert.

**Staleness window is real but harmless:** Step 0/Step 1 are separate transactions, so an intervening
tx could lower the same nonce's supply in between. Since an existing nonce's supply can only ever
decrease, the only failure mode from staleness is a Step-1 revert — never a silent over-burn.

**Correction found along the way, filed separately:** this investigation is what surfaced the M11/M12
reachability error — see `#32bM` above. Doesn't change this finding's own safety verdict (`DPOF::C_Burn`'s
enforcement is unconditional and real regardless of whether MTX-SWP is reachable).

**Status:** CONFIRMED SAFE — `DPOF::C_Burn`'s live-supply enforcement makes the cached amount provably
non-exploitable. No code change. — *L67*

---

## L68 (#68L, MTX-SWP — no TTL/expiry mechanism on any of the 8 `defpact` flows) — **DESIGN, accepted structural limitation**

**Owner's own assessment, checked and confirmed correct:** Pact has no native mechanism to force-expire
an open, uncontinued `defpact` — there is no scheduled/cron execution, and the only way an open pact's
state can ever change is via someone submitting a continuation transaction for that exact pact. An
abandoned pact that nobody ever continues simply has no code path that can ever run against it again —
there is nothing to attach a TTL check *to*. A TTL/expiry mechanism here isn't a missing `enforce`, it
would require entirely different on-chain or off-chain infrastructure (e.g. a separate sweep
transaction someone is incentivized to submit, or a redesign of the flow away from open-ended
multi-step `defpact`s) — not a fix expressible as ordinary Pact logic inside the existing flows.

**Status:** DESIGN, accepted as a structural limitation of the `defpact` primitive itself, not a
fixable gap in this code. No code change. Residual linkage to H10/M10/M12's own "time-window exposure"
notes stays as previously recorded — this finding is the reason none of those got a TTL-based fix
either. — *L68*

---

## L69 (#69L, MTX-SWP — `MTX-SWP|S>ADD-LQ`'s own `@doc` implies a bounded `kda-pid` lock window not enforced) — **CLOSED, already covered / premise doesn't hold against current text**

**Checked the actual current doc text before treating this as still open:** `MTX-SWP|S>ADD-LQ`'s real
`@doc` (`20_MTX-SWP.pact:276`) reads only `"Records the KDA-PID the MTX was initiated with"` — it does
not claim or imply a short, bounded lock window. The substantive concern this finding is pointing at
(a fixed `kda-pid` persisting unchanged across a multi-step flow, no re-validation) was already
investigated and closed as DESIGN by the owner at **M10** (2026-08-19): a fixed price across one
logical multi-step event is intentional, not an oversight; residual time-window exposure explicitly
rides on **L68** (no TTL), same linkage as H10/M12.

**Status:** CLOSED — the doc doesn't make the claim described, and the underlying substance is already
recorded at M10 with its residual explicitly tied to L68. No code change. — *L69*

---

## L70 (#70L, Talos — `SWP|C_Fuel`/`SWP|C_Firestarter` public on `TS01-C3` but missing from its own interface) — **CONFIRMED, FIXED, PROVEN**

**Confirmed the gap directly against the live interface:** read `TalosStageOne_ClientThreeV3`
(`04_TS01-C3.pact:56-113`) in full — `SWP|C_Fuel` and `SWP|C_Firestarter` are real, public functions on
the `TS01-C3` module (`:583`, `:785`) but neither is declared on the interface it implements
(everything else the module exposes is). Confirmed this is genuinely interface-incompleteness, not a
security issue — both remain fully callable via the concrete module reference either way; the gap only
matters for code that needs an interface-typed (`module{TalosStageOne_ClientThreeV3}`) reference rather
than the concrete module.

**Fix:** added matching stubs to the interface, signatures copied exactly from the live module
(`(defun SWP|C_Fuel (patron:string account:string swpair:string input-amounts:[decimal]))` and
`(defun SWP|C_Firestarter (fire-starter:string))`), placed after `SWP|C_RemoveLiquidity` alongside the
rest of the liquidity/misc section.

**Status:** FIXED ✅ AND PROVEN ✅ — see `ROUND-02-FIXES.md` Fix #40. Full suite + default issuance-only
pipeline both exit 0, 0 `FAILURE` (interface addition, no behavior change, verified by successful
`Z.repl` load). — *L70*

---

## L71 (#71L, Talos — `SWPU::C_ToggleSwapCapability`/`SWPLC::C_ToggleAddLiquidity` call `SWP::C_ToggleAddOrSwap` directly instead of an `XE_*` forward entrypoint) — **DESIGN, accepted, documented**

**Investigated whether rerouting through the existing `XE_*` would be a safe mechanical fix — it would
not be.** `SWP::C_ToggleAddOrSwap` (`15_SWP.pact:1472-1548`) does far more than a toggle write: it bills
real IGNIS (`ico0`), bootstraps LP burn/mint/fee-exemption roles the first time add-liquidity is enabled
(`ico1`-`ico4`), and — critically — is the **only** place in this call chain that enforces pool
ownership, via `SWP|C>ADD-OR-SWAP`'s composed `CAP_Owner`. The module's own `XE_CanAddOrSwapToggle`
(`:1734-1751`) does none of that (only `UEV_IMC` + a raw `update`, no ownership check at all). Neither
caller's own capability re-derives ownership independently (`SWPU`'s `SPWU|C>TOGGLE-SWAP` only checks a
pool-worth threshold when toggling swap ON; `SWPLC`'s `P|SWPLC|CALLER` is literally `true`) — rerouting
either caller to the bare `XE_*` today would silently strip authorization from both.

**Owner's call:** leave it as-is — it works, and a properly-capped `XE_*` replacement is real design
work (build ownership + billing + role-bootstrap into a genuine forward entrypoint), not a mechanical
rename, and not worth doing piecemeal now. Documented instead: added a real `@doc` to
`C_ToggleAddOrSwap` (`15_SWP.pact`) recording exactly why the direct cross-module `C_`→`C_` call is
intentional, what would break if naively rerouted, and that a real `XE_*` replacement is deferred, not
forgotten.

**Status:** DESIGN, accepted — unusual layering, intentional, documented. No functional code change,
`@doc` only. See `ROUND-02-FIXES.md` Fix #41. — *L71*

---
