# Sleeping-LP duration multiplier — agreed design, not yet built

2026-10-09. Owner-agreed over two exchanges. Nothing below is deployed; this is the spec the
contract round implements.

## The defect

`mx-sleeping` is a **scalar fixed at score-issue time** (`SCR|Schema.mx-sleeping`, set by
`C_IssueLiquidityScore`) and applied flat at stake time. So a one-day sleep and a twenty-five
year sleep earn the identical multiplier. That is gameable: sleep briefly, stake at the top
rate, unsleep, repeat.

## What is NOT affected, and why that halves the work

**Frozen is not gameable and keeps a flat multiplier.** There is no unfreeze anywhere in the
tree — `C_RepurposeFrozen` is an admin migration (freeze the account, wipe, re-mint elsewhere),
not a path back to the native token. A freeze IS permanent, so a flat rate is the correct reward
for the maximum possible commitment. **Frozen changes by value only: 2.0 → 3.0.**

Only **sleeping** needs duration scaling.

## Why the weight must be fixed at stake time

AQP weights are MAINTAINED INCREMENTALLY — `total-base` accumulates at stake and unstake and is
never recomputed across holders. This is the same property the true-triplet lane defect turned
on (see `memories/2026-10-09-true-multiplet-three-defects.md`).

A multiplier that decayed with the remaining lock would therefore be impossible: every holder's
weight would move every block and the Tier-2 divisor would be permanently wrong. So the weight
is snapshotted at stake, and the lock is enforced by **CUSTODY** rather than by recomputation.
That is not a convenience — it is the only shape this architecture admits.

## The design

**Scale.** 25 years = `788,400,000 s` (`VST|C>SLEEP` → `UEV_MilestoneWithTime 0 duration 1
788400000`, under its own comment ";;Limit <Sleep> to 25 Years"). Split into **300 months** of
`2,628,000 s` each — derived from the bound, NOT from 30 days (300 × 30 days is 24.66 years).

With `mx-sleeping = 2.2`, month *k* gives `1.0 + 0.004k`, because `(2.2 − 1.0) / 300 = 0.004`
exactly. Score precision allows 3–24 decimals, so 0.004 needs no rounding slack.

**`mx-sleeping` STOPS BEING A SCALAR OF THE TOTAL. It becomes the CEILING** — the rate reached
only by a full 25-year lock. This must be said in the UI wherever the figure appears; a user
reading "sleeping ×2.2" and getting ×1.05 has been misled by the label, not by the chain.

**Remaining, not original.** The multiplier is computed from `release-date − now` AT STAKE TIME.
Using the original duration would let a holder sleep 25 years, wait 24.9, and stake into the top
rate for one month of commitment.

**Round to nearest month.** Floor would give 35 months to someone who slept 3 years and staked
an hour later. A day is 3.3% of a month, so rounding carries ±50% of a month of tolerance and
needs no epsilon. Worst-case gaming at a boundary is half a month = 0.002x.

**Per nonce, not per token.** A sleeping position is a set of DPOF batches with DIFFERENT
maturities, and a nonce is not splittable (segregation is off for sleeping). So the weight
contribution is computed per nonce and summed. The DPOF stake path already iterates nonces.

## The custody path

Direct staking of sleeping LP is **disabled**. The flow is a Talos orchestration:

1. Holder hands the sleeping DPOF to the AQP smart account.
2. AQP stakes it **for the holder** — `owner = AQP`, `beneficiary = holder`. This is the
   existing stake-for-another facility; without it this design would not be expressible.
   Remaining time is read here, per nonce, and the multiplier fixed.
3. The holder earns. The holder CANNOT withdraw, because custody is AQP's.
4. At maturity the position becomes **permissionlessly releasable**: anyone may trigger it and
   the proceeds go only to the rightful owner. AQP unstakes, unsleeps the matured nonce, and
   transfers the native LP to the holder. No privileged automaton is introduced — a keeper can
   run it without being trusted.
5. OPTIONAL, LATER: an automaton that force-vacates elapsed positions, so a holder cannot sit on
   a matured position still carrying its high weight. The owner's position is that this should
   be forced rather than left to choice.

## The sharp edge

**Unstake deliberately ignores every gate.** That is documented and intentional
(`05_FVT.pact` / the unstake tab's own note: a paused, vacating or score-less pool still returns
your asset). If AQP becomes the owner, the ORDINARY owner-unstake path must be **BLOCKED** for
these positions — otherwise the lock is bypassable through the front door and the custody
promise is broken. This is the single most likely thing to go wrong and wants a negative test
pinning it, not a comment.

## The ordering invariant (owner, 2026-10-09)

Frozen must out-rank sleeping by at least as much as sleeping out-ranks plain staking. In closed
form:

    mx-frozen >= (2 * mx-sleeping) - 1

so sleeping 2.2 forces frozen >= 3.4, and sleeping 1.999 forces frozen >= 2.998. Enforced at
issue and at any future setter. When sleeping is set and frozen no longer fits, frozen is RAISED
in the same transaction — and the Talos result string says so, because silently rewriting a
field the caller did not name is how an operator learns the wrong thing about their own config.

## NO DIVISIBILITY RULE IS NEEDED — multiply before dividing

The earlier instinct was to constrain `(mx - 1.0)` so 300 equal steps land on clean decimals.
That constraint disappears with the right formula:

    mx_k = 1.0 + ((k * (mx - 1.0)) / 300)

At k = 300 this is exactly `mx` for ANY `mx`, because the 300 cancels. Pre-computing a per-month
step and multiplying by k is what would have accumulated error and forced the rule. So 1.999 is
as exact as 2.2 and the owner may pick either.

`UEV_Fee` bounds these: 4 decimals, value in [1.0, 999.0] (or -1/0). Checked live 2026-10-09 —
2.2, 3.4, 1.999 and 2.998 all pass.

## Values

| | now | after |
|---|---|---|
| `mx-frozen` | 2.0 | **3.0** flat — but must satisfy the invariant above |
| `mx-sleeping` | 2.0 | **a CEILING**, reached at 300 months |

Two candidate defaults, both valid: `1 / 2.2 / 3.4`, or `1 / 1.999 / 2.998` (keeps the sleeping
ceiling strictly under 2, so nobody can say "sleeping doubles your stake").

## CHANGING A MULTIPLIER — the danger is conservation, not staleness

**Today they cannot be changed at all.** `mx-frozen` / `mx-sleeping` appear ONLY in the issue
path (`SCR|XI>ISSUE-SCORE`) and in readers; there is no setter anywhere in the tree, which is
what the score page already tells users ("cannot be changed once positions exist").

**If a setter is added, stale weights are not the problem.** The base is an accumulated SIGNED
delta — `URC_SignedBaseDeltaFor*Stake` computes `lp-amount x mx` and flips the sign on unstake,
under its own stated invariant: *"a full unstake reverses exactly and nets to 0 (no negative
base, no clamp)"*. Change `mx` between a stake and its unstake and the reversal stops
cancelling: stake 100 at x2 adds 200, unstake 100 at x3 subtracts 300, the holder's base goes
to -100 and `total-base` is corrupted.

**Nothing would report it.** Deb-staleness compares the stored deb-score against
`(base + boost) x live-Elite-DEB`; `mx` is not in that comparison, so no row would read stale
and no sweep would fix it. Same silent shape as the true-triplet lane defect.

## OWNER RULING 2026-10-09 (final): MUTABLE + RE-RATE SWEEP

The multipliers ARE mutable. Changing one triggers a re-rate of every affected stake, across as
many transactions as it takes, and the sweep must be:

  * **PARALLELISABLE — a FED-SLICE recipe, not a cursor pager.** These are two different shapes
    and only one of them is parallel-safe. `Cp_WipeSlice` takes an explicit slice object and is
    order-independent; `CCp_SweepRecomputeChunk` computes its own window from stored progress
    and is strictly SEQUENTIAL. The existing AQP re-score sweep
    (`XI_FvtSweepRecomputeWindow`) is the second kind — it must NOT be copied here. See
    `StoicSyntax-Prefixes.md` § "Recipe axes".
  * **CHECKED BEFORE IT RUNS.** Two separate checks: whether a re-rate is NEEDED at all (no
    affected legs ⇒ no transactions), and whether one is IN PROGRESS (the score is mid-rerate
    and therefore internally inconsistent). The pool sweep's `sweep-in-progress` latch plus its
    "cannot unfreeze until offset reaches total" completeness rule is the precedent.

WHY THIS AND NOT THE ALTERNATIVES. Three options were weighed and each costs somebody:
immutable protects everyone but makes a badly-chosen rate permanent; snapshotting the rate on
the position protects existing holders and permanently disadvantages every later staker, with a
standing incentive never to unstake; re-rating changes the deal for existing holders. The owner
chose re-rating: one rate for everyone, always, and the base is REBUILT FROM SOURCE
(`Σ leg_amount × current_mx`, from the tracker rows) rather than patched — so conservation
cannot drift, because nothing is being adjusted incrementally.

The counter-argument, recorded because it will come back: a 25-year sleeping lock is a
commitment made on the strength of a stated ceiling, and re-rating it afterwards changes that
deal. If the owner later wants locked positions exempt, the exemption belongs in the SWEEP
(skip legs whose lock predates the change), not in the storage model.

### Superseded reasoning

**THE SNAPSHOT FIX WAS REJECTED FIRST, then the whole immutability position was too.** Recording the rate on the
position makes the arithmetic safe and the POLICY unsound: a holder who staked at 2.2 keeps 2.2
forever against a live ceiling of 1.999, is permanently advantaged over every later staker, and
acquires a standing incentive never to unstake. That is a worse outcome than refusing the
change. Conservation was the wrong thing to optimise for.

**DECISION: the multipliers stay effectively immutable.** They are set at issue, the caller is
warned at issue what the legal values are and that they are final, and nothing re-rates a live
position.

### The one safe setter, and why it is not an admin override

A narrow setter is still wanted, because the live scores carry the old 2.0/2.0 and must reach
the new defaults. It is gated on **no frozen and no sleeping position existing for the score**
— at which point the change is provably harmless rather than merely believed to be:

    URC_SignedBaseDeltaForDptfLpStake:  (if native-or-frozen 1.0 (UR_SCR|ScoreMxFrozen score-id))

The flag is "is NATIVE". **A native stake multiplies by 1.0 and never touches `mx`.** So while
no frozen or sleeping leg exists, no accumulated delta anywhere used the value being changed,
nothing can fail to reverse, and no holder is grandfathered into anything. The gate self-closes
the moment somebody sleeps or freezes, after which the value is final for the life of the score.

This mirrors the house pattern rather than inventing one — `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`
is re-pointable "only while the score is EMPTY (nzs-count = 0)".

**The gate is NOT `nzs-count = 0`.** SilverSnakePower has three native stakers today and would
be refused, while being exactly the score that needs the change. The precise condition is the
absence of frozen/sleeping LEGS, checkable from the pool's tracker rows for the frozen asset and
the sleeping DPOF.

**Consequence for the live chain: there is nothing to repair.** Every current position is
native, so every base was computed with 1.0. Setting the new values today changes no existing
weight.

## Scope

SCORE (per-nonce multiplier derivation), AQP (custody stake path + blocked ordinary release),
a new Talos orchestration, and the UI vocabulary change from "multiplier" to "up to". REPL
coverage before any deploy — in particular a negative test that the ordinary unstake refuses a
custody position before maturity.

---

# BUILD LOG — 2026-10-09, the re-rate engine and four things found while building it

What follows is what the implementation actually turned up. Each item is here because it was
**measured**, and in three cases the measurement contradicted something written above.

## 1. A deployed interface cannot be extended — and Pact 5 means it never needs to be

**The blocker.** `AcquisitionScoresV2`, `AcquisitionPoolsV1` and `TalosStageTwo_ClientThreeV2`
are all on chain (`Deploy/1_Pure/15`, `/16`, `/21`). A Pact interface cannot be upgraded. The
pre-compaction work had added **five** declarations across the three of them —
`XE_SetScoreMultipliers`, `UC_MxOrderingOk`, `URC_AQP|ScoreMxChangeSafe`,
`URCi_UpdateScoreMultipliers`, `AQP-POOL|C_UpdateScoreMultipliers`. The gate cannot see this,
because the REPL deploys interfaces fresh on every run, and `_deploybundle.py` STRIPS interface
forms from upgrade transactions (`interfaces=0` in all six PureV5 files). So the suite was green
and the deploy would not have been.

**The resolution, and it is not the obvious one.** Measured directly:

```
(interface ITest (defun declared:string (x:string)))
(module MImpl G (implements ITest) (defun declared …) (defun undeclared …))
(let ((r:module{ITest} MImpl)) (r::undeclared "ok"))   -> "undeclared:ok"
```

**Pact 5 resolves modref members against the CONCRETE module at runtime; the `module{Iface}`
annotation constrains only what may be ASSIGNED.** Interface membership is not required for
dispatch. The tree already relied on this without saying so: Talos calls
`ref-AQP::C_UpdateScoreMultipliers` through `module{AcquisitionPoolsV1}`, which does not declare
it, and the end-to-end test passed.

A V2→V3 bump was built and then **reverted**, which is the useful part of the story. The cascade
itself was free — all ten modules naming `AcquisitionScoresV2` were already in the round for
dot-pin reasons — but changing `implements` on a *deployed* module is not free:

> A module that stops implementing V2 breaks every **not-yet-upgraded** module whose
> `module{AcquisitionScoresV2}` annotation it must still satisfy. Across a multi-transaction
> round that is a live window in which the whole AQP family aborts.

Staying on V2 has no such window. All three interface regions are now **byte-identical to HEAD**,
verified by hashing the pre-`(module …)` span against `git show HEAD:`.

**Rule going forward: never edit an interface that appears in `Deploy/1_Pure/`.** Put the
function in the module and call it; the interface is documentation, not a dispatch table.

## 2. The signed floor — a one-ulp negative leak on every stake/unstake cycle

`URC_SignedBaseDeltaForDptfLpStake`'s `@doc` claims *"a full unstake reverses exactly and nets to
0 (no negative base, no clamp)"*. That claim was **false**, and the new test caught it on first
run — `expected: 0.0, received: -0.000001`.

All seven `URC_SignedBaseDeltaFor*Stake` functions ended on

```pact
(floor (* raw-weight (if direction 1.0 -1.0)) p)      ;; sign INSIDE the floor
```

`floor` rounds toward negative infinity, so it rounds a credit DOWN and a debit AWAY FROM ZERO:

```
floor(+300.3333333, 6) = +300.333333
floor(-300.3333333, 6) = -300.333334      the pair sums to -0.000001
```

The residue is always negative and it accumulates, walking a holder's base — and the score's
`total-base` — below zero. Nothing reports it: deb-staleness never compares a base against its
own history.

**It was unreachable until this change.** Every multiplier used to be a flat `1.0` or `2.0`, so
products were exact at score precision and the floor never bit. A per-month multiplier is
`1 + m(c−1)/300`, non-terminating for almost every `m` — so the defect and its fix had to land
in the same commit as the division that exposes it.

Fixed at all seven sites to `(* (floor raw-weight p) (if direction 1.0 -1.0))`. The reasoning is
recorded once, in `CT_SIGNED_FLOOR_NOTE`, and the seven sites point at it.

**What the fix does NOT buy**, stated plainly because it would otherwise be assumed: same-shape
round trips now cancel exactly, but **different shapes still do not**, because
`floor(am) + floor(bm) ≠ floor((a+b)m)` is simply true. Four stakes of 100 followed by one full
unstake of 400 leaves **−1 ulp**. The drift is bounded by `(rows − 1)` ulp, it is now
*measured* (`TX-RERATE-04`), and `URHC_AQP|ScoreBackfillOutstanding` sees it as a non-zero delta —
so the sweep is what repairs it. A genuine fix would mean storing the base unfloored and
flooring on read, which is a storage-semantics change and not this round's work.

## 3. The class-2 leg — CORRECTED 2026-10-10: the same gamble was NOT open, because the path is dead

**This section originally read "The same gamble was still open on class-2 — flat ceiling, 100-year
term", and said the leg was "live on `OfStakePool`/`MVST`". It is not live. It is unreachable from
any client, and the claim was wrong.** Three measured rules compose to that, and no single one of
them says it:

- `UEV_AddScorePoolAndScore` (`03_AQP.pact:2965`) enforces `score-class == aqp-class`, so a
  score-class-2 score can ONLY be employed by an aqp-class-2 pool.
- `URC_StakeOrtoFungibleDpofMatchesPool` lets an aqp-class-2 pool admit **native DPOF only** —
  `(not (contains p2 ["Z|" "H|"]))`.
- So a score-class-2 score never sees a special leg, and
  `XI_1|UpdateScoreDataForSpecialOrtoFungible` — the only caller of
  `URC_SignedBaseDeltaForSpecialDpofStake` — is dead from the client surface.

`mx-sleeping` / `mx-hibernated` on a class-2 score therefore cannot be reached by any live path,
and **there was never a second gamble to close.** The only live duration multiplier in the system
is class-0 `mx-sleeping`, the sleeping-LP leg.

The fix described below is still correct and still in the tree — a flat ceiling on a time-locked
leg is wrong arithmetic wherever it sits, and if class-2 is ever wired up it will be right. What
was wrong was the REPORT: a function being correct was mistaken for a path being reachable, and
nothing in the gate distinguishes those. See DEFECT-LEDGER §8.39, and `[6.2.17]`
`<<TX-RERATE-SKIP>>`, which pins the reachability fact as an assertion so the mistake cannot
repeat silently.

What the original text said, kept because the arithmetic claims are accurate: it left
`URC_SignedBaseDeltaForSpecialDpofStake` computing `sum(nonce-amounts) × mx` with the FULL ceiling
regardless of remaining time.

Now per-nonce on both branches. Two facts made it clean:

- Both metadata schemas carry `release-date` (sleeping writes `{release-amount, release-date}`,
  hibernating writes `{mint-time, release-date}`), so **one primitive serves both** —
  `URC_DecayedMxForNonce (mx-ceiling, cap-months, dpof, nonce)`.
- The scales are exact. `VST|C>SLEEP` caps duration at 788,400,000 s and `VST|C>HIBERNATE` caps
  `dayz` at 36,500. Divided by `CT_SLEEP_MONTH_SECONDS` those are **exactly 300 and exactly
  1200** — hence `CT_HIBERNATE_MONTHS 1200`, and no epsilon at full term.

Scaling hibernation on the 300-month sleep curve would have made a 25-year hibernation worth the
same as a 100-year one: a milder version of the flattening the mechanism exists to remove.

## 4. Nothing in the system could see an orphaned score row

Every sweep enumerates holders from the **AQP pool tracker**. There was no `select` over
`SCR|T|UserScore` anywhere in SCORE. So a user-score row whose position went to zero while its
base did not is invisible to all of them — *nothing lists it, so nothing can repair it*. That
state is reachable and was measured below zero on the deployed chain, via `C_AddScore`'s
unguarded signed delta.

`URH_SCR|ScoreHolderAccounts (pool-id, score-id)` closes it, and
`URHC_AQP|ScoreBackfillCandidates` takes the **union** of the two lists. The union is the point:
the tracker answers *"who holds a position"*, the score table answers *"who carries a base"*, and
each direction of disagreement is a real repair.

It filters through `UR_U-SCR|UserScoreBaseScore`, which honours `vacate-generation`, so a row a
fast-vacate already retired reads 0.0 and is **not** returned.

## 5. Two traps the engine had to be shaped around

**An additive satellite would never converge.** When a score has both a boost-link and a
boost-class-link, `URC_SingularUserScoreDeltaFromSignedUserBase` pins its stored base at exactly
`0.0` — the hub owns the canonical base. A naive back-fill computes a non-zero target, applies
the delta, reads `0.0` back, and reports the holder outstanding **forever**: a sweep that never
terminates and bills every pass. `URC_AQP|ScoreBackfillSupported` refuses satellites. When a hub
is re-rated its satellites go deb-stale, and the EXISTING staleness sweep is what repairs them.

**Fast-vacate is safe, for a reason worth not re-deriving.** `XI_2|ApplySingularUserScoreDelta`
stamps the row with the score's current `vacate-generation`, so a zero-delta write would
*resurrect* a lazily-invalidated row. It cannot happen: `WU_Score|Nuke` is gated pool-side on
emptiness, so by the time the generation bumps the trackers are empty, every target is 0.0, and
the outstanding list is `[]`.

## 6. What is built, and what is not

**Built, gate-green, 57 assertions in `[6.2.17]_AQP-RERATE.repl`** (loaded from
`modules/AQP-LP.repl`, the only chain with a class-0 score and pool):

- `SCR::XE_ApplyRawBaseDelta` — IMC-gated, `SCR|XE>APPLY-RAW-BASE-DELTA` enforces
  `current + delta >= 0` and that the score is employed by the pool. The ordinary stake path
  deliberately keeps no such clamp (its invariant is symmetry, and a clamp there would MASK the
  add-score defect); here the caller supplies a figure, so the floor must be checked.
- `URH_AQP|ScoreTargetBaseForBeneficiary` — `Σ` of three legs, **one floor per leg**, calling the
  stake path's own delta functions rather than reimplementing them.
- `URHC_AQP|ScoreBackfillOutstanding` / `…Needed` — the work list and the "is it needed" answer.
- `CCp_BackfillScoreSlice` + Talos wrapper — permissionless fed slice, priced per holder.
  Idempotent because the target is recomputed **immediately before each write, inside the map**;
  that single ordering choice is what makes replay, overlap and repeated accounts all harmless.

**Not built:** the custody stake path (VST `XE_Unsleep`, the `P|A_AddIMP` registration, the
owner/sender decoupling), the pool-stale side table, and relaxing
`AQP|C>UPDATE-SCORE-MULTIPLIERS`'s emptiness gate — which should only be relaxed together with
pool-stale, since that is what blocks stake/unstake while a sweep is outstanding.

**Also not built: an end-to-end convergence test.** The arithmetic and the refusals are proven;
the *plumbing* (stake → add score → outstanding non-empty → sweep → `[]` → Σ bases = total-base →
full unstake nets to 0) is not, because no fixture in the tree stakes into a class-0 pool. That
fixture is the next piece of work and it is the one that would make the engine trustworthy
end-to-end.

# BUILD LOG — 2026-10-10, closing the three gaps and two defects found closing them

Scope of this pass: the custody path made MANDATORY, the vacate leak it exposed, the nine INFO
previews, and the evidence that settled gap 3. Everything below is gate-green.

## 7. THE CUSTODY PATH WAS OPTIONAL, WHICH MEANT THE GAMBLE WAS STILL OPEN

`CCp_StakeSleepingCustodial` existed and worked, but `CC_StakeOrtoFungible` still accepted a `Z|`
batch and recorded the STAKER in the tracker's owner column. Both paths earn the same
duration-scaled multiplier, so the ordinary one paid a 25-year rate to a position its holder could
withdraw in the next block. **Closing the gamble in the multiplier while leaving that path open
moved the hole rather than filling it** — the curve priced a commitment nobody had to make.

The guard is in `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW`, not in the Talos mirror, because every mirror in
`TS02-C3` carries no validation by design (acquiring it only puts a registered IMC guard in scope).
Two facts shaped it:

- **The custodial client reuses the SAME defcap** as the ordinary flow. So a guard on the cap alone
  would have blocked the very path it exists to require. The cap therefore gained one parameter,
  `tracker-owner`, placed deliberately BESIDE `owner-id` — their difference *is* the custody
  mechanism, and separating them by five parameters would hide what the guard checks.
- **The rule is an equality, not a flag**: `special-leg == (tracker-owner == AQP|SC_NAME)`. That
  ties the guard to the invariant that matters rather than to a boolean a caller could pass wrongly.

**Two enforces, not one combined**, and the reason is the 2026-09-14 shadowed-gate lesson: a test
can only tell two refusals apart by their MESSAGE. A single "paths must match" would make the two
failures indistinguishable from outside.

**STAKE DIRECTION ONLY.** Gating the unstake too would trap any user-owned sleeping position that
already exists — the custodial release requires the pool in the owner column and would refuse it —
turning a pricing rule into an asset lock. Refusing the ENTRY is sufficient.

**AND IT FOLLOWS THE MULTIPLIER, NOT THE PREFIX** — which took two corrections. A prefix-keyed
rule (`Z|` or `H|`) would have re-created §8 one prefix over, because custody's only exit is
`VST::XE_Unsleep` and a hibernating batch has nothing on `UR_Sleeping`. Scoping to `Z|` fixed that
and was still wrong: a `Z|` satellite on an aqp-class-1 pool **scores zero** (`of-skip`), so
requiring custody there would have locked it for up to twenty-five years for nothing. The gamble
costs the protocol a mispriced multiplier; the over-broad rule would have cost a holder their
asset.

Final rule: mandatory iff the leg is `Z|` **and** the pool is aqp-class 0 — the only place a
duration multiplier is earned. Forbidden everywhere else. Pinned three ways, including
**positively** by `[6.2.17]` `<<TX-RERATE-SKIP>>`, which asserts the ordinary path ACCEPTS a
non-earning satellite — so a prefix-keyed regression goes red. See DEFECT-LEDGER §8.39.

**No hibernation custody, and no residual.** `H|` earns no multiplier anywhere (§3), so there is
no gamble to close and nothing to build. A `VST::XE_Awake` was written and then removed rather
than shipped: it would have been unreachable from any client, and unreachable code in a deployed
sovereign module is worse than absent code. What was kept from that work is
`URC_HibernationFeePromile` — the 800-promile decay extracted from the two places that had
inlined it, so `C_Awake` and `URCi_Awake` can no longer disagree about how much of a holder's
principal gets burned.

Pinned by message at both ends: `[6.4]` `<<TX-AQP-CL06>>` (ordinary path refuses a sleeping leg)
and `[6.2.5]` `<<TX-VCT-L01b>>` (custodial path refuses a native leg, using `MVST-98c486052a51`,
the tree's real native DPOF, whose ordinary stake sits two lines above — the same rule admitting
the right leg and refusing the wrong one).

## 8. THE VACATE PATHS STRANDED EVERY CUSTODIAL POSITION — asset loss, in shipped code

`XI_VacateOrtoFungibleBatch` and `XI_DrainOrtoFungibleBatch` both did:

```pact
(ref-DPOF::C_BulkTransfer patron AQP|SC_NAME owner-ids dpof-id nonces-array true)
```

Sender `AQP|SC_NAME`, recipients `owner-ids` — the tracker's owner column. **For a custodial row
that column IS `AQP|SC_NAME`.** The pool was both sender and recipient: the batch never left, while
the tracker row and the score were unwound around it. The position gone, the asset still inside,
and **no row left to find it by**.

This was introduced by the custody feature itself and no test could see it, because the only
fixture that vacated a `Z|` satellite staked it NON-custodially. Fixed by
`UC_VacateOrtoDestinations`, which substitutes the beneficiary wherever the owner is the pool. That
is the right destination and not merely an available one: a custodial row can only be created by
`CCp_StakeSleepingCustodial`, which moves the batch FROM the staker and records that same staker as
beneficiary — so the substitution returns the asset to the account it came from.

**It returns the still-sleeping batch, not the native counterpart.** A vacate may run long before
maturity, when unsleeping is impossible; the holder keeps both the asset and the remaining lock.

Proven by migrating `[6.4]` `<<TX-AQP-CL05>>` to the custodial client: its pre-existing
`Z| LP returned got=5.0` assertion now runs against a custodial row through the real agnostic
`CC_FullVacate`, and **fails without the helper**. One fixture change, two subjects.

The collectable siblings (`DPDC-T`) are unaffected — custody is DPOF-only.

## 9. THE LEDGER'S SOUNDNESS DEPENDS ON THE MULTIPLIER GATE, and that was unstated

`URC_SCR|SleepingLegHeldWeight` derives the leg from the STORED term and the score's **current**
ceiling. So if a ceiling moved between stake and unstake, the reversal would not equal the credit.
It cannot move, because `SCR|C>UPDATE-MULTIPLIERS` refuses a change while any sleeping position
exists — **the two are one mechanism**, not two independent rules:

> the ledger stores a ceiling-INDEPENDENT term, so ONE row per nonce serves every score on the
> pool; and the gate is what stops the ceiling moving underneath it.

Written into `03_AQP.pact` at the leg itself, because the obvious future change — relaxing that
gate so a multiplier can be re-set during a sweep — would silently make the unstake reverse at a
rate the stake never credited. Anyone doing that must also re-rate the stored legs.

**Also corrected: five comments named `SCR|T|StakeWeight`, a table that does not exist** (it is
`SCR|T|SleepStake`), and one pointed at `URC_SCR|AwardedWeightTotal`, a function that does not
exist. Residue from the pivot away from storing the weight. They misdescribed the DESIGN, not just
the name: the table stores the remaining TERM, and each score re-derives its own weight from it.

## 10. GAP 3 — THE DETECTION AND THE SAFETY WERE ALREADY THERE; ONLY PARALLELISM WAS MISSING

Measured rather than assumed, and it changes the shape of the work:

- **`URC_U-SCR|UserScoreDebStale` is DERIVED**, not a stored flag — *"true when the stored
  deb-score is not what the LIVE rates would produce right now."* So adding a score entity to an
  FVT makes every affected member self-report as stale. **There is no flag to set and no freeze to
  add**, which is why no `C_AddScoreEntity` hook was needed.
- **`URH_FvtStalePresentUsers` already existed** as the work-list reader.
- **`CC_InjectFinalize` already refuses** while any member is stale, so a newly added lane cannot
  be FUNDED while its `total-lane-weight` is partially populated. That is what makes the partial
  state safe: without it, the first holder fixed would have had `w_A / w_A` = the whole pot.
- **The REMOVE direction needs nothing at all.** Weight state is per-member
  (`FVT|T|ScoreEntityLink.total-lane-weight`, keyed `fvt-id | score-entity-id`), so removing an
  entity drops a whole independent lane. There is no cross-member aggregate to go stale.

What WAS missing is what the owner asked for: the fixer was a **cursor pager** (`take chunk` of a
shared list), so two concurrent sends pick the same members and **charge the 2e forced-fix penalty
twice**. `CCp_FvtFixSlice` is the fed-slice twin — explicit accounts, staleness re-checked
in-transaction, so an overlapping or replayed slice skips rather than re-penalising.

## 11. NINE INFO PREVIEWS, and one dot-pin avoided

All nine new Talos entrypoints now have `INFO_*` cost previews in `09_AQP-INFO.pact` (88 → 97).

**`URCi_ReleaseSleepingCustodial` lives in AQP-FVT, not in AQP-INFO**, and that placement is the
interesting part. The release prices two legs: the orto phase chain in the unstake direction, plus
`VST::XE_Unsleep`. Writing the second as a dot-call `VST.URCi_Unsleep` from AQP-INFO would have
**pinned VST's body into the reader** (`_dotpin.py`) — putting AQP-INFO into VST's redeploy cascade
forever and quoting a stale price after any VST upgrade. AQP-INFO had **zero** cross-stage
dot-calls before this; threading it through the module that already holds the `ref-VST` modref
costs nothing.

Assertions (`[6.5]`, all green): the four flat ops quote non-zero; the two fed slices are asserted
as a **scaling law** (`3 accounts == 3 x 1 account`) rather than as non-zero, because the UI sizes
slices by the quote and a flat figure would invite one oversized transaction; `CCp_FvtFixSlice`
quotes zero both currencies; and the custodial stake is asserted **EQUAL to the ordinary orto
stake**, which is the claim its own `@doc` makes.

**One honest gap:** the release preview's numeric value is not measured against a live charge. No
chain in the tree holds both AQP-INFO and a live custodial sleeping position — `[6.4]` is a
destructive tail excluded from `AQP-FULL`. It is pinned structurally instead (it aborts on a native
DPOF, which is the evidence the VST leg is really in the sum), and both legs are reconstructed from
the same readers the execution path calls. That is sound, but it is not a balance delta.

## 12. NOT BUILT, deliberately

- **Re-rating an existing ledger to a changed `mx` ceiling** — owner's call: new stakes only.
- **No pool freeze on score-entity add** — §10: a stale member mis-states reward SHARES, never the
  base, so stake and unstake stay correct and holders are never trapped. The inject gate is the
  right place for that refusal and it already exists.

# BUILD LOG — 2026-10-10 (second pass): the three gaps the first pass left, and what measuring found

Owner ordered three items and they are all in. Gate green. What follows is why each turned out
different from how it was specified.

## 13. SPECIAL SATELLITES SCORED ZERO — the gap under the gap

Owner ruling: *"special token satelites must behave like the native token plus their designated
multiplier"*, and the zero should survive *"only if the score is a satelite score in a true
triplet, and adds only the bonus from boosters."*

Measured, the first half was not implemented at all. Three rules composed into a silent dead end
and **none of them stated it**:

- `UEV_AddScorePoolAndScore` enforces `score-class == aqp-class` → a pool's scores share its class
- the orto score-delta dispatch handled score-class **0 and 2 only** → `"of-skip"`, 0.0, otherwise
- `URC_StakeOrtoFungibleDpofMatchesPool` admits `Z|`/`H|` on aqp-class **1**, native-only on **2**

So a satellite **moved, was tracked, and earned nothing**, and the score-class-2 path that did the
weighting was unreachable from any client. `mx-sleeping`/`mx-hibernated` were dead outside the
class-0 sleeping-LP leg.

**The second half needed no work, which is why the fix is a routing change and not a special
case.** The triplet-satellite zero is enforced *downstream*, in
`URC_SingularUserScoreDeltaFromSignedUserBase` (boost-link and boost-class-link both non-BAR ⇒
user base 0). Routing special legs through the normal machinery preserves it exactly; reproducing
it in the dispatch would have created a second copy free to disagree.

Dispatch now keys on the **leg**, with `UEV_DpofSpecialStakeScoreContext` (class 1 **or** 2)
replacing the class-2-only validator on that path. The native path keeps the exact check, because
a native DPOF can only ever be a class-2 pool's own asset.

## 14. HIBERNATION IS FLAT, AND THE 1.0 FLOOR IS REAL

Owner ruling: hibernation uses a **single** multiplier because the decaying burn fee already
prices impatience — *"he paid somewhere else"* — and it defaults to **1.0**, raisable by the pool
owner. Sleeping stays duration-scaled because it is held to term under custody.

Both now come from ONE expression, `UC_MxForRemaining`, keyed on `cap-months` so the argument
naming the instrument is the argument deciding the rule.

**`mx-hibernated` had no setter at all** — issuance hard-coded 1.0 for every class but 2 and
`UPDATE-MULTIPLIERS` took only frozen + sleeping. Added as a third parameter, free because that
entrypoint is new in this round.

**The 1.0 floor was missing at issuance** (`> 0.0`), which admitted a *penalising* 0.5 while the
setter had always required `>= 1.0` — a value issuable and then never updatable. Fixed, and the
test matters more than the fix: `UEV_Fee` independently refuses 0.5 but **accepts 0.0 and -1.0**,
so a test written with 0.5 passes while proving nothing — delete the floor and it stays green.
`[6.2.2]` `<<TX-SCORE-17>>` uses **0.0**, which clears the fee validator so the floor is the only
thing left that can refuse it.

## 15. BENEFICIARY REASSIGNMENT — and the policy rule that could not survive contact

Owner's case: a custodial staker cannot withdraw before maturity, so they must be able to SELL —
*"i no longer want you to stake it for me, but i want bob to earn from it."*

Built as `XI_OrtoStakePhases` run TWICE with `move-asset` false: an unstake run for the seller and
a stake run for the buyer. `move-asset` gates phase 1.1 and nothing else, so the tracker row, the
score weight on every employed score, FVT presence, lane weights and both parties' RPS checkpoints
all migrate while no token leaves `AQP|SC_NAME`. The seller is settled first, so she keeps what she
earned.

**The buyer is re-rated to the term remaining now**, not given the seller's ceiling. Inheriting
would make reassignment strictly better than buying the nonce and staking it fresh — the same
position by another route — and that arbitrage is what the duration curve exists to remove.

### The stated gate was unimplementable, and the fixture said so

Owner's rule: allow it *"only when the sleeping token is freely movable."* Implemented literally,
the first fixture refused a sale nobody had restricted. Cause, in
`VST::XI_CreateSpecialOrtoFungibleLink`:

```pact
(ref-DPOF::C_ToggleTransferRole patron (UR_Konto special-dpof) VST|SC_NAME special-dpof true)
```

**VST grants itself the transfer role on every special token at creation** — dissolution moves the
batch to VST and the role check would otherwise refuse it. So roles are active on every sleeping,
vested and hibernating token that has ever existed, and "is it freely movable" is a question with
one answer and no information in it.

Resolved with `VST::URC_SpecialLegIssuerRestricted`: are there role-holders *besides* VST's own
account? Every other name got there through `C_ToggleTransferRole*`, which only the token owner can
call — so presence is intent, absence is its absence. It lives in VST because VST creates the
exception.

Where intent exists the check applies in full, which is `DPOF::UEV_MoveRoleCheck` — an
`enforce-one` over [sender-role, receiver-role], so a **whitelisted** recipient qualifies. The
owner confirmed that reading: *"bob may have a trasnfer role, so he is allowed to move towards.
therefore alice can reasign to bob, becuase she could have transfered to bob in the first place."*

Full truth table pinned, and the middle row is the one that distinguishes the correct gate from an
over-broad one:

| token state | recipient | result | test |
|---|---|---|---|
| infrastructure grant only | anyone | allowed | `[6.2.17]` `TX-RERATE-SELL` |
| owner whitelisted Bob | Bob | **allowed** | `[6.2.17]` `TX-RERATE-WL` |
| owner whitelisted Bob | stranger | refused | `[6.2.17]` `TX-RERATE-WL` |
| owner granted a role | non-whitelisted | refused | `[6.4]` `TX-AQP-CL06` |

**Why gate at all**, since the position is locked anyway: the release pays the **native**
counterpart to whoever is beneficiary at maturity, so a reassignment is a DEFERRED DELIVERY of the
asset — and nothing downstream re-checks it, because the release moves the native token, whose
role list is a different object from the sleeping variant's.

## 16. A DEFECT I INTRODUCED, AND THREE TESTS THAT WERE PASSING FOR THE WRONG REASON

Single-sourcing the weighting, I collapsed stake and unstake into one call. The **rule** was
correctly shared; the **clock** was not supposed to be. A stake prices the live remaining term; an
unstake must reverse the *stamp*, because by the time a position comes out its lock has run down.

`[6.4]` `<<TX-AQP-CL06>>` failed immediately and named the number: a 5.0 batch credited at the 2.0
ceiling reversed at 1.0 and left **exactly 5.0** behind — the phantom weight `SCR|T|SleepStake`
exists to prevent, re-created by the refactor meant to make it harder to get wrong. Fixed with
`(not direction)` as the clock selector. **Share the rule, not the inputs** (DEFECT-LEDGER §8.41).

The same change turned three `[6.2.17]` probe assertions red, and they were the more interesting
casualty: they added the stake direction to the unstake direction and expected 0.0, which held only
while both recomputed from the live clock. They were probes on nonces **never staked**, so with the
reversal reading the stamp there is nothing to cancel against. Rewritten to assert what is
load-bearing — the reversal equals minus the ledger weight, and is shape-free — with the netting
property pointed at where it is genuinely proven: end to end on a staked position, in
`TX-RERATE-SAT` and `[6.4]` `CL06`, both asserting the base returns to its exact pre-stake value.

A test proving a property the system no longer relies on is worth replacing, not keeping green.
