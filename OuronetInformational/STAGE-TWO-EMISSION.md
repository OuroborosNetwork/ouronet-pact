# The Stage Two daily emission — construction, cost, and the parallel fallback

> **Audience: the UI, and whoever runs the emission.** Subject: `DSP.AA_OuroMinterStageTwo`.
> Status of this document: **analysis + design COMPLETE, the parallel functions are NOT BUILT YET.**
> Everything under *What exists today* is in the tree and gate-green; everything under
> *What must be built* is a specification, not a description. Do not read the two as equals.

---

## 1. What the function is, and what you feed it

```pact
(defun AA_OuroMinterStageTwo:[decimal] (fvt-ids:[string]))
```

**One argument, and yes — you must feed it the vault ids.** Four of them, **by position**:

| # | id | what it is | created by |
|---|---|---|---|
| 0 | `CustodiansVault` | the DSA delegation vault | AQP-BOOT Step 13 |
| 1 | `CompanySharesTreasury` | shareholders | AQP-BOOT Step 8 |
| 2 | `OuroLpFarm` | Ouroboros liquidity farming | AQP-BOOT Step 8 |
| 3 | `SubsidiaryTreasury` | Demiourgos NFT staking | AQP-BOOT Step 8 |

Guarded: `(enforce (= (length fvt-ids) 4) …)`.

**Why they are passed and not hardcoded.** Every AQP entity id carries the block hash of the
transaction that minted it — `U|DALOS::UDC_Makeid` = `<name>-<first 12 of prev-block-hash>`. They
cannot be known when the module is written, and they cannot be recomputed afterwards. In the REPL
they *look* derivable because the fixture's previous-block-hash is fixed; **on chain they are
not.** The UI must read the four ids back from the AQP registry after the boot and hold them.

**Everything else is derived** and must not be passed: OURO id, Auryn id, the Auryndex, the
Demiourgos treasury, and the dispenser account all come from DALOS readers — exactly as Stage One
does.

**Authorisation:** `(with-capability (DSP|STAGE-ONE-MINTER) …)`. **Gas:** the whole emission is
gasless — `GASLESS-PATRON` pays, `dispenser` acts. That separation is what lets the emission sit on
the dispenser at all; before it existed, the tokens had to be minted *to* the gasless patron,
because `CC_Inject` debits its patron directly.

**Returns** `[daily custodians treasury shareholders farm autostake subsidiary-auryn]`.

---

## 2. The seven legs, and which of them scale

The split is **20 / 10 / 10 / 20 / 20 / 20** — custodians, treasury, shareholders, LP farm,
autostaking, subsidiary. Every share derives from one floored 10% unit and the **last share
absorbs the rounding remainder**, so the parts always sum to the minted amount with nothing
minted-but-unassigned.

| # | leg | call | scales? |
|---|---|---|:---:|
| 1 | mint the whole daily emission onto the dispenser | `DPTF\|C_Mint` | flat |
| 2 | 10% → Demiourgos treasury, as OURO | `DPTF\|C_BulkTransfer` | flat |
| 3 | 20% → Custodians vault | `AQP-FVT\|CC_Inject` | **SCALES** |
| 4 | 10% → shareholders | `AQP-FVT\|CC_Inject` | **SCALES** |
| 5 | 20% → LP farm | `AQP-FVT\|CC_Inject` | **SCALES** |
| 6 | 20% → fuels the Auryndex | `ATS\|C_Fuel` | flat |
| 7a | 20% coiled OURO→Auryn | `ATS\|C_Coil` | flat |
| 7b | …then injected as **AURYN** into the Subsidiary treasury | `AQP-FVT\|CC_Inject` | **SCALES** |

> **The subsidiary leg is COILED, not injected as OURO.** SubsidiaryTreasury's reward link is
> AURYN, so OURO cannot be injected into it at all. The coil conversion `URC_RBT` is read **before**
> the coil and the resulting Auryn amount is what gets injected — this matters enormously for the
> parallel version (§5).

**So exactly four legs scale, and they are the four `CC_Inject`s.** The doubled `CC_` prefix was
not chosen by hand — `_heavy.py` reported it: `DSP.A_OuroMinterStageTwo` reaches
`RPS.URH_FvtEnabledScoreEntityIdsForFvt`. Each `CC_Inject` scans the FVT's present users and fixes
every **deb-stale** one before injecting, so the divisor is live when the money moves.

---

## 3. What it costs, and when it stops fitting

**Measured, whole transaction:** **911,546** gas in the boot suite, **966,256** standalone — about
**48% of a 2M block**, against Stage One's ~135k. Seven times the cost for one transaction. The two
figures were taken minutes apart and differ by 6% purely from chain state.

**Measured, per inject leg** (`REPL/Kursan/AQP-scale-inject.repl`, on a single-score/single-stream
FVT):

```
gas(n) = 199,096 + 5,189·n        n = deb-STALE present users on that FVT
```

That reconciles with the whole-transaction figure: 4 × 199,096 ≈ 796k of fixed inject cost, plus
~120–170k for mint / bulk-transfer / fuel / coil, ≈ 920–965k. **The fixture had a handful of
stakers.** So the 911k is a **floor, not a ceiling.**

### The number you actually need

| | stale stakers | note |
|---|---:|---|
| headroom in a 2M block after the ~940k fixed cost | ~1,060,000 gas | |
| at the **measured** slope, 5,189/user | **≈ 204 total** | across ALL FOUR vaults combined |
| at the **conservative backstop**, 6,500/user | **≈ 163 total** | the constant the code ships with |
| a **single** leg on its own | **307** | `INJECT-FIX-CHUNK-MAX = 2,000,000 / 6,500` |

> **Read the first row carefully: it is a COMBINED budget, not a per-vault one.** The four legs
> share one block. Three quiet vaults and one busy one is the same ceiling as four medium ones.

**What "stale" means, and why this is less alarming than it sounds.** A member is deb-stale when
their SCORE deb is behind the live Elite-DEB — i.e. when their Elite-DEB *moved* since their last
refresh. It is **not** "everyone who staked" and it is **not** reset by the emission itself. On a
quiet day the stale set is small and the emission costs near its 940k floor. The spike case is a
day of heavy Elite-DEB movement across the big vaults — and that is precisely the day the emission
must not fail.

---

## 4. Is it proven? — the honest answer

**It is proven to RUN and to FIT. It is NOT proven CORRECT.**

`AA_OuroMinterStageTwo` is exercised in **exactly one place** in the whole suite:
`<<TX-BOOT-S2GAS>>` in `REPL/Stage_02/[6.2.9]_AQP-BOOT-FULL.repl`, inside a `rollback-tx`. That
test asserts **two gas bounds and nothing else**:

```pact
(expect "<<TX-BOOT-S2GAS>> the Stage Two emission fits inside one 2M block"  true (< g 2000000))
(expect "<<TX-BOOT-S2GAS>> ...and it is NOT suspiciously cheap (all six legs ran)" true (> g 500000))
```

The band is deliberately a band — an exact pin would be noise at 6% variance, and a *cheaper*
emission is a broken one rather than an improvement, which is why there is a lower bound at all.
But note what is **not** asserted: not the six split amounts, not the balances that should have
moved, not the treasury credit, not the coil conversion, not the returned list. **A regression that
moved the right total to the wrong place would pass this test.**

**The parts, individually, are well covered** — which is why the risk is contained rather than
open:

| machinery | proof |
|---|---|
| deb-staleness scan + fix | `REPL/Kursan/deb-staleness-proof.repl`, `-inject-cc`, `-sweep-cc`, `-unstale-all-cc` — all gate-green |
| inject gas model | `REPL/Kursan/AQP-scale-inject.repl` — the `199,096 + 5,189n` measurement |
| the MTX defpact fallback takes a sponsor | `<<TX-MTX-SPONSOR>>` |
| mint / transfer / fuel / coil | the Stage One minter and the DPTF/ATS module suites |

**Action: close the correctness gap before deploy.** A `commit-tx` sibling to `<<TX-BOOT-S2GAS>>`
that captures the seven destination balances before and after and asserts each delta against the
returned split. This is cheap and it is the difference between "it fits" and "it works".

---

## 5. The parallel fallback — and the one fact that decides its design

### Why you cannot just call the function in pieces

```pact
(defun URC_DailyOURO ()
    (floor (/ (- 10000000.0 current-ouro-supply) 10000.0) op))
```

**`URC_DailyOURO` reads the OURO supply — and leg 1 mints into that supply.** Call it again in a
second transaction and it returns a *different, smaller* number. Any multi-transaction variant that
recomputes the daily emission per part will compute shares that do not sum to what was minted:
tokens minted-but-unassigned, or an over-assignment that aborts on the last leg.

> **This is the whole design constraint. The emission must be computed ONCE.**

### The codebase already solved this, and the answer is elegant

`A_KosonMinterStageOne_2of3` does **not** recompute the daily. It reads:

```pact
(daily-primordial-left:decimal (ref-DPTF::UR_AccountSupply PrimordialKosonID dispenser))
```

**What is actually left on the dispenser.** The dispenser balance *is* the carried state — no new
table, no run ledger, no cross-transaction bookkeeping, and self-correcting: if a later part fails,
the funds sit on the dispenser and you retry. Stage Two must follow this precedent.

### The shape to build

**Phase 1 — flat, one transaction, ~150k gas.** Mint the daily emission onto the dispenser, pay the
treasury, fuel the Auryndex, and coil the subsidiary share to Auryn. After it, the dispenser holds
exactly **50% of the daily emission in OURO** (custodians 20 + shareholders 10 + farm 20) **and**
the coiled Auryn.

**Phase 2 — four independent inject legs, parallel-safe.** Each takes its FVT id and its amount:

| leg | token | amount |
|---|---|---|
| custodians | OURO | 40% of the dispenser's OURO residual |
| shareholders | OURO | 20% of the residual |
| LP farm | OURO | 40% of the residual |
| subsidiary | AURYN | the dispenser's **entire** Auryn balance |

Those four ratios are exact — 20/10/20 of the daily is 40/20/40 of the 50% residual — and because
each leg is fed its amount rather than deriving it from what the previous leg left, **the four are
order-independent and can be submitted in parallel.** The intrinsic safety is that the dispenser
cannot spend what it does not hold: a wrong amount aborts rather than mis-pays.

**Phase 3 — only when a single leg alone exceeds a block.** Per vault, in ascending order of cost:

1. `AQP-FVT|CCp_InjectFixChunk (patron fvt-id reward-dptf-id chunk)` — page the fix phase, repeat
   until the report says zero remain, then
   `AQP-FVT|CC_InjectFinalize (patron executor fvt-id reward-dptf-id amount)` — **same outcome as
   the single-tx inject.**
2. `AQP-FVT|CCp_UnstaleAll (patron fvt-id reward-dptf-id chunk)` — owner mass-unstale *without*
   injecting; repeat until "injection-ready", then run a now-light `AQP-FVT|CC_Inject`.
3. `MTX-AQP|2|CC_Inject (patron executor fvt-id reward-dptf-id amount)` — the 2-step defpact;
   step 0 runs on call, advance with `(continue-pact 1)`. Each step bills its own IGNIS.

`chunk` is the UI's simulated slice, seeded at `INJECT-FIX-CHUNK-MAX = 307` and **refined by
`/local` simulation** — the node gas meter is the real ceiling. An oversized chunk aborts
atomically: submitter's gas, offset unchanged, retry smaller.

### What was built in DSP

**BUILT 2026-09-23.** Five additions, all in `2_CITIZEN/Stage_Z/03_DSP+.pact`:

```pact
(defun URHC_StageTwoPlan:object (fvt-ids:[string]))
    ;; PREFLIGHT, read-only, call via /local. Returns daily, split, subsidiary-auryn
    ;; (indicative), per-vault stale counts, stale-total, est-gas and a one-tx
    ;; recommendation. URHC_ because it runs the same heavy scan CC_Inject runs, once
    ;; per vault -- so the count it reports is the exact set each inject would fix.

(defun A_OuroMinterStageTwo_Flat:[decimal] ())
    ;; Phase 1. Mint + treasury + Auryndex fuel + subsidiary coil. NO ARGUMENTS: not one
    ;; of these legs touches a vault. A_ and not AA_ -- no heavy read is reachable, which
    ;; is the whole point of the split.
    ;; RETURNS [daily custodians shareholders farm subsidiary-auryn].

(defun URC_StageTwoResidual:[decimal] ())
    ;; RECOVERY. The four inject amounts derived from what the dispenser is HOLDING --
    ;; 40/20/40 of the OURO residual plus the whole AURYN balance -- for when the flat
    ;; leg's return value was lost, or to verify before injecting.

(defun AA_OuroMinterStageTwo_InjectLeg:string (fvt-id reward-dptf-id amount))
    ;; Phase 2, called four times, ORDER-INDEPENDENT and parallel-submittable.

(defun AA_OuroMinterStageTwo_InjectLegFinalize:string (fvt-id reward-dptf-id amount))
    ;; Phase 3 tail, after CCp_InjectFixChunk has been paged to zero stale.
```

Sizing constants live in DSP beside them, and every one is measured rather than chosen:
`S2-FIXED = 950,000` (top of the observed band, because a preflight that under-estimates sends the
operator into a transaction that aborts), `S2-GAS-PER-STALE = 6,500` (deliberately the same number
as AQP-FVT's `INJECT-FIX-GAS-PER-USER`, so the two cannot quietly disagree about the cost of the
same fix), `S2-ONE-TX-CEILING = 1,600,000` (not 2M — chain state moved the measurement 6% between
two runs minutes apart).

---

## 5b. The behaviour that will surprise you first: ESCROW

Found by the correctness test the moment it was written, and it is **designed behaviour, not a
defect** — but nobody would guess it from the minter's own source.

When an inject reaches a vault with **no eligible stakers**, the share is **not** credited to that
lane's available rewards. `RPS::XI_DistributeInjectAmount` parks it:

```pact
;; ESCROW -- no stakers (divisor 0): park `amount` in limbo, available-rewards untouched.
(WU_RpsGlobal|ZombieRewards fvt-id reward-dptf-id (+ zombie amount))
```

The money leaves the dispenser, enters AQP custody, and waits. The **next** inject into that lane
that *does* have a denominator flushes `amount + zombie` together. Nothing is lost and nothing is
double-paid.

**Two consequences for whoever runs the emission:**

1. **A vault with no stakers still costs you the full leg** — the tokens move, the transaction
   runs, and the accounting lands in escrow. It is not a no-op you can skip.
2. **`UR_FVT-RG|AvailableRewards` alone is the wrong thing to watch.** On an empty vault it reads
   zero after a perfectly successful inject. The quantity that is conserved across both branches is
   **`AvailableRewards + ZombieRewards`**, and that is what `<<TX-BOOT-S2MOVE>>` asserts.

> The first version of that test asserted `AvailableRewards` and watched all four vaults report a
> delta of zero while the dispenser emptied correctly. That looked exactly like four lost injects.
> It was four escrows.

**And the Auryndex takes two deposits, not one.** Leg 6 fuels it with the 20% autostake share and
leg 7a coils the 20% subsidiary share *through* it — both are OURO entering the same pool, so its
RUR grows by the **sum**. The same first draft expected the fuel alone and read exactly double.

The existing one-shot `AA_OuroMinterStageTwo` **stays exactly as it is** — it is the fast path and
it will be the right call on most days. The parallel form is the fallback, and the point of
building it now is that you cannot build it on the day you need it.

---

## 6. The UI's decision procedure

```
1.  read the four FVT ids from the AQP registry           (once, cached)
2.  URC_StageTwoPlan(fvt-ids)  ->  stale counts + gas estimate
3.  estimate < ~1.6M ?
        YES -> AA_OuroMinterStageTwo(fvt-ids)             one transaction, done
        NO  -> AA_OuroMinterStageTwo_Flat()               phase 1
               then submit the four InjectLeg calls, in parallel, with the
               amounts the plan returned
4.  any single leg still over budget ?
        -> page CCp_InjectFixChunk(chunk) until zero stale, then InjectLegFinalize
        -> or MTX-AQP|2|CC_Inject + (continue-pact 1)
5.  verify: dispenser OURO balance and Auryn balance are both ZERO
```

**Step 5 is the invariant worth wiring into the UI as an alarm.** A non-zero dispenser balance
after a completed emission means a leg did not run, and the dispenser balance is the only place
that fact is visible.

**One operational rule, from §5:** *complete a run before starting the next.* The residual-ratio
arithmetic is self-correcting across a retry of the same run, but interleaving two runs — phase 1
of day two before the inject legs of day one — puts two days' emissions in the residual and the
40/20/40 split would mis-allocate between them. Daily cadence makes this easy to honour; the alarm
in step 5 makes a violation visible.
