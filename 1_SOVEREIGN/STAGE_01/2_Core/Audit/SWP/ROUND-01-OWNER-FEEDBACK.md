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
