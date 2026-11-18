<!-- purpose: SPEC for the unclaimed-count repair round — the locked definition, every transition site, the schema change, the X-prefix canon sweep, the backfill, and the tests that would have caught the original drift. -->

# SPEC — `unclaimed-count`, and the round that repairs it

**Status: SPEC, not built.** Written 2026-11-08, after the defect was found while measuring a
bulked eviction. Read it before touching `04_RPS.pact` / `05_FVT.pact`.

---

## 1. What is wrong

`unclaimed-count` exists so the **last account still owed on a lane takes the remainder**, instead
of leaving rounding dust behind. The live `coin` contract states exactly that, in its own doc:

> *"Computes Claimable Reward of Account. When only one staker has unclaimed rewards
> (unclaimed-count=1), that staker receives the full vault supply **to avoid rounding dust**."*

**The reader was documented for that meaning. The writer implements a different one.** The writer
counts accounts that *can ever claim* — staked, or unstaked-with-pending. The reader wants accounts
that *have something to collect right now*.

They coincide everywhere except one case, and that case is the whole defect:

> **A staked account that has already collected to zero this round.**
> It *can ever claim* — it accrues again on the next injection. It *cannot be collected now*.

So after an injection to ten stakers, the count reads 10 for the first collector and **still 10 for
the tenth**. `= 1` is never reached while anyone is staked, the sweep branch is unreachable on a
live aggregator, and the dust it exists to prevent accumulates.

### 1.1 Measured, not argued

On `CompanySharesTreasury`, two staked claimants, injections chosen so the split cannot halve at the
token's 24 decimals:

| round | injected | paid out | left in the lane |
|---|---|---|---|
| 1 | `120.000000000000000000000001` | `120.000000000000000000000000` | `1e-24` |
| 2 | `80.0` (+ carried `1e-24`) | `80.000000000000000000000000` | `1e-24` |
| 3 | `33.000000000000000000000007` | — | **`2e-24`** |

Monotonic. Bounded per round by roughly (claimants − 1) sub-units, and never swept, because no
claimant is ever retired while staked.

### 1.2 This is a half-built implementation, not a regression

Nothing broke. The older `coin` contracts (`coin-live`, `coin-stoa`, `stoa-v1`, `stoa-v2`) DO reset
the count at inject — `;;3]Reset <unclaimed-count> (set it to <nzs-count>)`. The live contract
replaced that call with a comment:

> `;;3]Do not reset <unclaimed-count> on inject so accounts with 0 stake but pending rewards remain counted`

**That objection is correct and must be preserved.** `nzs` counts non-zero SCORES — staked accounts.
An account that unstaked while still owed is not in `nzs` but still has a live claim; resetting to
`nzs` erases it from the count, and the sweep then fires while that account is still owed, paying
its rewards to somebody else. That is the same failure the `deb-user > 0` guard was added for.

So the fix is **not** "re-enable the reset". It is "compute the right number", which `nzs` alone
cannot.

---

## 2. The locked definition

> **`unclaimed-count` for a (fvt-id, reward-dptf-id) lane is the number of LEGS whose claimable is
> currently greater than zero.**

A *leg* is one `(beneficiary, score-entity, reward-lane)` triple — the same unit
`URHC_BuildEvictPlans` emits and the same unit a collect settles.

Consequences, stated so they cannot be argued later:

- At an accrual event the count **maxes out** — every leg that gains a positive claimable is counted.
- As legs are collected it **falls**.
- When every leg has been collected it is **0**.
- At `= 1` the single remaining leg is the last one owed, and its collect **sweeps the remainder**.

The name then means what it says, and reader and writer agree. That agreement is the property the
tests in §8 exist to hold — the same reader-vs-writer discipline `GS-07` applied to `P|UR_IMP`.

---

## 3. State

`FVT|RPS|Global` (key `<FVT-ID> | <DPTF-ID>`) keeps `unclaimed-count` with the NEW meaning, and
gains one field:

```pact
dormant-claim-count:integer  ;;[M] legs OWED but NOT EARNING — see below for what qualifies
```

**Why a second counter rather than a scan.** The number to write at an accrual event is
`stakers + dormant`:

- **stakers** — every leg whose account still has weight. All of them gain a positive claimable at
  an accrual event, so this is derivable from the existing non-zero-score bookkeeping.
- **dormant legs** — legs that are OWED but receive NOTHING at an accrual event. Two distinct
  causes, one consequence, and BOTH must be counted (owner, 2026-11-08):
  - an **orphan**: the account's score across the aggregator has gone to 0 — it withdrew — but it
    never collected what it had already earned;
  - a **disabled member**: administratively switched off, which *"earns nothing from new
    injections; its already-accrued rewards are untouched"* — it may still hold a score.

  Neither is derivable from stake state, which is exactly why the `nzs` reset could not work. And
  missing EITHER is the dangerous direction: the count then reads LOW, `= 1` fires while they are
  still owed, and the sweeper takes their rewards.

  THEY COLLECT AND EVICT NORMALLY. Owner: *"a disabled member can still collect if he has rewards
  that can be collected, and an evict would also correctly send his rewards even if he doesn't have
  a stake. For collection and evict purposes it functions like a normal leg."* The ONLY thing that
  treats them differently is the accrual event, which is the one place this counter is set.

The orphan transitions **already exist in the code**, folded invisibly into the single counter:
today, unstaking *with* pending deliberately does not decrement (that is an orphan being created),
and the orphan's later collect does decrement (that is it being retired). Splitting them out makes
the accrual-time value computable with **one read and one write**, and no walk over the legs.

`AcquisitionSchemasV3` therefore bumps to `V4`. See §6.

---

## 4. Transitions — every site

| # | event | condition | `unclaimed-count` | `dormant-claim-count` |
|---|---|---|---|---|
| T1 | **accrual** — inject | always | **set** to `stakers + dormant` | unchanged |
| T2 | **accrual** — stream release | only when the drip actually releases | **set** to `stakers + dormant` | unchanged |
| T3 | **collect** | the leg's claimable goes positive → 0 | **−1** | unchanged |
| T4 | **collect of a dormant leg** | the leg was owed but not earning (orphan or disabled) | **−1** | **−1** |
| T5 | **unstake / vacate** | weight → 0 AND pending > 0 | unchanged | **+1** |
| T6 | **unstake / vacate** | weight → 0 AND pending == 0 | **−1** if it was counted | unchanged |
| T7 | **stake** | account becomes a staker | unchanged *(see note)* | unchanged |
| T8 | **member disabled** | the member holds legs with claimable > 0 | unchanged | **+N** (its owed legs) |
| T9 | **member re-enabled** | those legs are still owed | unchanged | **−N** |

**T2 IS NOT OPTIONAL, AND IT IS THE EASIEST ONE TO MISS.** `XE_ReleaseStream` exists: a streamed
lane's claimables become positive **without an injection**, as the clock moves. If the count is
restored only at inject, a streamed lane reads LOW, `= 1` fires while other legs are owed, and the
sweeper takes their rewards. That is the §1 failure arriving through the new counter. Any
implementation that restores only at T1 is wrong.

**T7 deliberately does nothing.** Staking grants future accrual, not a present claim: the new
staker's claimable is 0 until T1 or T2. Counting them at stake time would hold the count above the
real number of owed legs and make `= 1` unreachable again — the very defect being repaired. They are
picked up by the next accrual event, which is where their claim actually begins.

**T6 keeps today's rule.** A clean exit — nothing pending — leaves nothing to collect.

**T8/T9 ARE NEW AND HAVE NO EQUIVALENT TODAY**, because today nothing distinguishes earning legs
from owed ones. Disabling a member moves its owed legs from the earning set to the dormant set
WITHOUT changing what is collectable — the legs still collect and still evict normally (SS12.2).
Miss T8 and the next accrual counts those legs in `stakers` while they receive nothing: the count
reads HIGH, never reaches 1, and the sweep stops firing. Miss T9 and it reads LOW, `= 1` fires while
they are owed, and the sweeper takes their rewards. The second is the one that costs somebody money.

A member disabled while holding NO pending moves nothing: it has no owed leg to reclassify.

---

## 5. What it must account for

1. **Orphans** (§3). The reason the `nzs` reset was removed, and the reason this round adds a field
   rather than re-enabling it.
2. **Streams** (T2). The only accrual that is not an inject.
3. **Legs that floor to zero.** A share can floor to 0 at the token's precision when an account's
   weight is a vanishing fraction of the lane. Such a leg must **not** be counted at T1/T2, or the
   count stalls above 1 forever and the sweep silently stops firing. The accrual-time value is
   "legs that now have a POSITIVE claimable", not "legs that exist".
   *Degradation if got wrong: back to today's behaviour — dust accrues, nothing is paid wrongly. The
   safe direction, and it must still be asserted.*
4. **`zombie-rewards`.** Injected while nothing was staked; held out of `available-rewards` by
   design. A zombie balance must not make the lane look owed, and the sweep must not pay it out.
5. **Vacate.** Reaches the counter through the same stake-unwind path (`XE_BookStakeUnclaimedCounts`
   — VCT's own comment calls it *"unclaimed-count hygiene"*). T5/T6 cover it; no separate rule.
6. **The two-tier farm case.** `FVT|RPS|Member` carries its own `unclaimed-count` (`mc`) and the
   sweep has a second branch on it. Everything in this spec applies to the member counter too, or
   the member mini-vault keeps the defect the global one loses.
7. **A COLLECT-INELIGIBLE claimant — added 2026-11-08 from F3.** A member whose
   `ScoreEntityLink.enabled` is false, or whose reward token's `reward-enabled` is false, holds `deb`
   and **cannot collect**: `UEV_CollectContext` (`05_FVT.pact:2363`/`2365`) refuses both its collect
   and its eviction. Under *either* candidate reading of the counter it is counted — it has unclaimed
   rewards, and it can claim after a re-enable — but it can never be retired while the flag is off.
   **So it is a permanent floor on the count and a second, independent reason the sweep never
   fires**, unrelated to the staked-collector rule in §1.

   The locked definition in §2 must therefore say explicitly whether a claimant that *cannot presently
   claim* is counted. **If it is, `(= gc 1)` is not a sufficient sweep guard** — the lane can sit at
   `gc = 2` with one real claimant and one frozen one, forever, and no amount of correctness in §4's
   transitions will fire it.

   Three options, and §12 needs the ruling:
   - **(a)** Exclude collect-ineligible claimants from the count — the counter becomes "accounts that
     can claim NOW". Makes the sweep reachable, but the count then moves when an admission flag is
     toggled, which adds `enabled` to the list of writers in §4.
   - **(b)** Keep them counted and make the sweep guard "no OTHER claimant can presently claim".
     Leaves the count stable but the guard is no longer a simple equality.
   - **(c)** Fix F3 so the ineligibility cannot exist — see
     [`SPEC-disabled-link-strand.md`](SPEC-disabled-link-strand.md) §8, where the remedy is the
     deletion of those two `enforce`s. **This option makes the problem disappear rather than
     accommodating it**, and is the recommended one.

   **Note the dependency direction.** F3's spec rules that S1 lands first, because F3 changes who may
   claim and S1 redefines the counter that counts them. If (c) is chosen, S1's definition should be
   written as though the ineligible case will not exist, with this clause recording why — and F3 must
   then actually land, or S1 ships a definition whose precondition is false.

---

## 6. Interfaces, cascade, prefixes

### 6.1 Schema

`AcquisitionSchemasV3` → **`V4`** (one field on `FVT|RPS|Global`). Cascades to **11 modules**:
`00_AQP-SCHEMAS`, `01_ANK`, `02_SCORE`, `03_AQP`, `04_RPS`, `04b_RPSC`, `05_FVT`, `06_VCT`,
`08_DSA`, `08b_EVCT`, `09_AQP-INFO`.

### 6.2 The X-prefix canon sweep — done in the same round

`StoicSyntax.md` §12.1 defines exactly three X prefixes (`XI_` / `XE_` / `XB_`), with depth written
as `XI_1|`, `XI_2|` — *"Pipe `|` after the tier digit"*. There is **no compound form**. The tree
carries 36 functions that encode a wrapper relationship into the NAME instead of the call graph:

| shape | references |
|---|---:|
| `XE_XI_` | 119 |
| `XE_WU_` | 18 |
| `XE_WI_` | 17 |

All 36 are interface-declared, so `AcquisitionRewardPerShareV5` → **`V6`** and
`AcquisitionFarmsVaultsTreasuriesV6` → **`V7`**.

`XE_XI_TransferRewardDptfFromVault` becomes `XE_TransferRewardDptfFromVault`, calling
`XI_1|TransferRewardDptfFromVault` — the relationship stated by the call graph, as the canon
intends. **The tree already agrees in prose**: `06_VCT.pact:2602` documents the function as
`XE_BookStakeUnclaimedCounts`, without the compound, while `05_FVT` calls it with one.

Owner ruling, 2026-11-08: *"we take no corners when fixing a bug … no modification is too small. We
do 200 transactions if we need to."* These interfaces are inside the schema cascade already, so the
sweep costs one cascade rather than a second round.

---

## 7. Backfill

Changing the MEANING of a stored value makes every live row wrong on arrival. Each live
`(fvt, lane)` needs, once:

```
dormant-claim-count := count of legs with pending > 0 whose account has no remaining stake
unclaimed-count    := count of legs with claimable > 0
```

Both are computable from current state by a heavy read; neither is derivable from the old value, so
this is a **migration transaction per lane**, not an in-place upgrade. The same applies to
`FVT|RPS|Member` rows (§5.6).

`Deploy/` generators cannot emit this — see `HOW-DEPLOY-ROUNDS-WORK.md` §4, *"Table/schema
repairs … needs a real migration transaction, hand-authored, positioned."*

**Ordering:** backfill AFTER the modules deploy (the new field must exist) and BEFORE any inject or
collect on that lane (both read the counter). A lane injected between deploy and backfill reads a
default of 0 and the sweep fires on the first collect — paying one account the whole lane. The
migration must therefore be part of the round, not a follow-up.

---

## 8. Tests

The drift survived because nothing compared the reader's intent to the writer's rule. The tests must
close that, not merely exercise the paths.

1. **The defining property.** Inject to N staked legs; collect them one at a time; assert the count
   reads `N, N-1, … 1`, and that the **last** collect leaves `available-rewards` at **exactly 0.0**.
   *Fails today at the first assertion.*
2. **Negative — the orphan.** One account unstakes with pending, others keep staking. Inject.
   Assert the count includes the orphan, and that collecting every STAKED leg does **not** drop it
   to 0 or trigger a sweep while the orphan is owed. *This is the regression the removed `nzs` reset
   caused; it must fail if anyone re-enables that reset.*
3. **Negative — the stream.** A streamed lane, no inject. Drip, then collect all but one; assert the
   count was restored at the drip and the last collect sweeps. *Fails if T2 is skipped.*
4. **Floored-to-zero leg.** A leg whose share floors to 0 must not be counted; assert the count
   still reaches 1 and the sweep fires.
5. **Conservation, every round.** `lane before = paid + lane after`, exactly, across three
   consecutive injections — the harness that measured §1.1.
6. **Member tier.** Repeat 1 and 5 against a class-0 farm so `mc` is covered as well as `gc`.
7. **No sweep for an account with nothing owed.** The EMMA case: an exited, fully-collected account
   calling collect must receive 0 and must not sweep. *Guards the re-derivation in §9.*

---

## 9. The sweep guard must be re-derived, not carried over

The current guard is `(and (= gc 1) (> deb-user 0.0))`. The `deb-user > 0` half exists because an
exited account once swept a vault it had no claim on:

> *"EMMA (exited, deb=0) collected the sweep and the vault went to 0 / ANHD (the rightful sole
> claimant) gained 0.0"* … *"`gc == 1` is a NORMAL END-OF-LIFE STATE, not an attack precondition."*

That guard was written against the OLD meaning — *"still in the set is deb > 0"*. Under the new
meaning it is **wrong in both directions**: it would block a legitimate orphan who is genuinely the
last leg owed, and it is no longer the right question for anyone else.

The correct guard under the locked definition is **"this caller's own claim is positive"**, which is
stricter, directly checkable, and does not depend on stake state at all. Test 7 pins it.

---

## 10. What this round REMOVES

`AQP-FVT::XE_EvictSweepLaneDust`, added in the eviction-bulking round, zeroes a lane at the end of a
whole-aggregator evict. It exists **only** because the real sweep was unreachable. Once this round
lands, the real sweep fires for eviction too — the last leg of a full evict is the last leg owed —
and keeping both would leave two mechanisms zeroing the same row by different routes. That is the
pair that drifts. Delete it, and let the eviction path inherit the fixed sweep.

---

## 11. `coin` — the same defect, a later round

The live `coin` UrStoa vault has the identical reader/writer disagreement: the doc in §1 is ITS doc,
`XI_URV|ResetUnclaimedCount` is defined and never called, and the stake-site comment names the same
orphan objection. It is one global vault with one lane and five stakers, so the fix is smaller.

Do it **after** this round, so the pattern is proven on modules we own before touching StoaChain's
root contract.

---

## 12. Decisions — settled by the owner, 2026-11-08

### 12.1 The staker count is PER-FVT, not per-lane

> *"If there are 2 reward lanes, the user earns on both … say we have 2 reward lanes, and add the
> third, even then he is eligible to earn on the third as soon as rewards are injected into that
> lane."*

So the earning set is a property of the AGGREGATOR, not of a lane, and one roll-up serves every
lane — including a lane added later. `UR_FVT|TotalNzsCount` is therefore the right granularity and
is finished in this round (declared, unwritten at `05_FVT.pact:2451`, no consumer today).

`dormant-claim-count` stays **per lane**, because pending is per lane: an account can be owed on
lane A and have nothing on lane B.

### 12.2 No special case for a disabled member — the definition already covers it

A leg counts iff its claimable is positive. Owner: *"its not that 'only 8 can ever be collected',
all can be collected."* An orphan or a disabled member holding accrued rewards is an ordinary
collectable leg; only the ACCRUAL skips it. Both sit in `dormant-claim-count` and are included in
the value written at T1/T2.

A consequence accepted deliberately: a dormant leg that is never collected holds the count above
zero, so that lane never reaches `= 1` and its final dust is not swept. That is CORRECT — the dust
is not unassigned while somebody is still owed.

### 12.3 Accrual is O(1) — no per-leg walk, ever

> *"Per leg walk would make injections impossibly expensive. Imagine we have 1 mil legs. We wouldn't
> be able to inject. Inject must scale with number of legs, it must be agnostic to them."*

T1/T2 write `stakers + dormant` from two counters: one read each, one write, independent of leg
count. `CC_Inject` already carries heavy reads for the forced-fix refresh; this adds nothing of that
order.

**The approximation, stated so it is not discovered later.** `stakers` counts accounts that WILL
receive a share, not accounts whose share is positive AFTER flooring. A share floors to zero only
when an account's weight is a vanishing fraction of the lane — under roughly 1e-26 of it at 24
decimals. Such a leg is counted but never collected, so the count stalls above 1 and the final dust
is retained rather than swept.

**The degradation is bounded and safe**: dust stays in the lane rather than being paid to the wrong
account — the same state as before this round, not a worse one. Asserted by test 4 in SS8 rather
than left to be noticed.

---

## 13. CORRECTION 2026-11-09 — `TotalNzsCount` is the WRONG figure for T1/T2

§12.1 settled Q1 as *"staker count is per-FVT — finish `TotalNzsCount` as the roll-up."* **That is
wrong, and it would have reproduced the very defect this spec repairs.**

**A reward leg is `(user, score-entity, lane)`.** The counter is maintained per leg — measured:
`SubsidiaryTreasury` reads 29 on its WSTOA lane against **26** present users and 5 member entities,
and a per-account counter cannot exceed 26.

**But `nzs-count` is per SCORE, and one member can employ several scores.** Measured on chain:

| pool | active scores |
|---|---:|
| DHOuroLp | **3** |
| DHBloodshed / DHCodingDivision / DHCompany / DHNosferatu / DHWonderCoach | 2 |
| DHBunnies / StoicismPool | 1 |

And the overlap is real, not hypothetical: reading the holders of `SilverSnakePower`,
`BronzeSnakePower` and `GoldenSnakePower` returns **the same six accounts**. So Σ`nzs` over a
member's employed scores counts one of those users **three times** for **one** leg.

A restore of `unclaimed-count := Σnzs + dormant` therefore sets the count ABOVE the number of legs
that can be collected. The count never reaches 1, the sweep never fires, and the dust accrues —
which is exactly §1's defect, reintroduced by the repair, and **invisible**, because the counter
would look plausible and no assertion compares it to a leg count.

### 13.1 The figure that IS correct, and it is already computed

`XI_1|BookUnclaimedForFvtRewardLine` loops over settle plans (one per member) and derives, per
member, `m-was` / `m-is`: *did this user hold non-zero weight on this member before / after*. That
is precisely the `(user, member)` leg transition, and it already drives the member mini-vault
counter. So an **earning-leg count is maintainable O(1) at a site that already exists** — `+1` on
`(not m-was) AND m-is`, `−1` on `m-was AND (not m-is)` — with no walk and nothing new at inject.

### 13.2 Revised field list — FOUR fields, not one

| schema | field | meaning |
|---|---|---|
| `FVT\|RewardAggregate` | `earning-leg-count:integer` | `(user, member)` pairs with non-zero weight on this FVT |
| `FVT\|RPS\|Global` | `dormant-claim-count:integer` | legs owed on this lane that earn nothing at accrual |
| `FVT\|ScoreEntityLink` | `earning-user-count:integer` | users with non-zero weight on THIS member (tier-2) |
| `FVT\|MemberVault` | `dormant-claim-count:integer` | tier-2 dormant, per lane |

**`TotalNzsCount` should be DELETED, not finished.** It has a field, a reader, and no writer and no
consumer; §1.4 already records it as one of the half-built mechanisms. Keeping it while adding the
correct counter beside it leaves two plausible figures for one question — which is how this family
of defects starts.

### 13.3 The member tier is live and cannot be scoped out

`URC_CollectClaimableRewards` has a SECOND sweep branch on the member mini-vault (`mc == 1`),
farm-only (class 0). Measured: of the 9 live aggregators, **one is a farm — `OuroLpFarm`** — and it
is the lane holding 27 sub-units of stranded dust with zero collectable legs. So tier 2 carries the
same defect on the one aggregator where it is most visible, and the fix is the same mechanism twice.

### 13.4 Consequence for sequencing

This spec cannot be built from §4 as written. The transition table is still right about *when* the
counter moves; what changes is *what value T1/T2 restore*, and that now requires two maintained
counters rather than one existing reader. **Four new fields across three schemas means the backfill
is four columns across 11 lanes and 2 tiers**, and a mis-set `unclaimed-count` pays one account a
whole lane (§7). That is the risk this correction protects.
