<!-- purpose: THE unifying specification for the 2026-11-08 findings set — the two defect classes, the dependency order, the round plan, and every owner decision in one list. Each finding's detail lives in its own spec; this is the document that sequences them. -->

# UNIFIED SPEC — the 2026-11-08 findings set

> **This is the sequencing document, not a replacement for the five specs.** Each finding's evidence,
> transitions, tests and fix options live in its own file. What only exists here is the **order**, the
> **shared decisions**, and the **round plan** — the things that are wrong if you read any one spec
> alone.
>
> Ledger of evidence: [`FINDINGS-2026-11-08.md`](FINDINGS-2026-11-08.md).

---

## 1. The set

| | finding | spec | status |
|---|---|---|---|
| **B1** | Equity share count corrupts staked scores | — | **BUILT**, shipped PureV25 |
| **B2** | Reward eviction paid one transfer per leg | — | **BUILT**, uncommitted; pricing unfinished |
| **S1** | `unclaimed-count` means something other than its name | [`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md) | SPEC |
| **F1** | SF score-definition re-issue corrupts live bases | [`SPEC-score-definition-reissue.md`](SPEC-score-definition-reissue.md) | SPEC |
| **F2** | class-4 (DPNF) revaluation, and no repair path | [`SPEC-class4-score-revaluation.md`](SPEC-class4-score-revaluation.md) | SPEC |
| **F3** | a disabled link strands earned rewards | [`SPEC-disabled-link-strand.md`](SPEC-disabled-link-strand.md) | SPEC |
| **F4** | `coin`'s UrStoa vault carries S1 | [`SPEC-coin-urstoa-vault.md`](SPEC-coin-urstoa-vault.md) | SPEC |
| **F5** | 36 functions violate the X-prefix canon | folded into S1 §6.2 | SPEC |

None of it was the thing being built. All of it came from measuring something adjacent and not liking
the number.

---

## 2. Two classes, and why neither is visible to the gate

### 2.1 Class A — a live input feeding a stored accumulator

**B1, F1, F2.** A weight formula reads a live value; the result is written into an accumulator as a
signed delta; the reversal re-reads the live value. If it moved in between, the difference stays on
the accumulator forever.

```
stake:    base += floor(W(state₁) × amount, p)
unstake:  base -= floor(W(state₂) × amount, p)
residue =  floor(W(state₁)×a) − floor(W(state₂)×a)      ← permanent, either sign, unbounded
```

B1 established the pattern and its remedy shape: *a formula with a moving input and an accumulating
output needs a gate on the input, or a repair path for the output, or both.* F1 is the same route
through SF definitions, reachable today. F2 is the same route through class 4, which additionally has
**no repair path at all**.

### 2.2 Class B — a field whose documented meaning and maintenance rule disagree

**S1, F3, F4.** The code is self-consistent; the *intent* is recorded elsewhere — in a schema comment,
an `@doc`, or UI copy — and nothing can observe the disagreement.

- **S1**: counter documented "accounts with unclaimed rewards", maintained "accounts that can ever
  claim". The sweep is unreachable; dust accrues monotonically.
- **F3**: flag documented "stop accruing", implemented "stop accruing **and** block withdrawal".
- **F4**: S1 again, in StoaChain's root contract.

### 2.3 Why the gate cannot see either

In class A the arithmetic is correct at every individual site. In class B the code agrees with itself.
`_gate.py` checks conformance, arity, prefixes, pricing, generated-artefact staleness — all properties
of the code against itself. **Neither class is a disagreement between code and code. Both are
disagreements between code and a sentence.**

That is not an argument for a new tool. It is the reason §7's lessons are written as *review habits*
rather than checks: the only thing that found these was reading a counter and asking who reads it.

---

## 3. Five half-built mechanisms — the pattern that produced most of this

The single most repeated shape in the set: **state maintained faithfully, consumer never written,
prose describing the finished version.**

| mechanism | state kept | consumer | found in |
|---|---|---|---|
| `TotalNzsCount` | maintained | never written | prior work |
| `unclaimed-count` | maintained | reader/writer disagree | S1 |
| `SCR|T|SF|DefRevision.revision-nonce` | maintained, bumped per call | degraded to `(= rev 0)` | F1 §1.4 |
| `applied-def-revision-nonce` | — | **does not exist**; documented as live | F1 §1.4 |
| `coin`'s `nzs-count` | maintained per stake/unstake | only the dead reset | F4 §3 |

**Why it survives: a counter nobody reads cannot fail a test.** It is incremented correctly, it is
never asserted against, and it is indistinguishable from a working feature until someone greps for
its reader.

The worst instance is the fourth. `README_SCORE.md:232` states:

> "Per-user score attribution rows in AQP track an `applied-def-revision-nonce`. On the user's next
> stake/unstake interaction, the revision is compared and the score is recomputed if stale."

The string occurs **twice in the repository** — in that sentence and in one source comment. There is
no field, no writer, no comparison. **Documentation asserting that a defect is already handled is
what stopped anyone looking**, and correcting that line is the highest-priority documentation change
in the set (F1 §11.1).

---

## 4. Dependency order — the part that only exists here

```
                    ┌─ F1 §6.3  drift-locked guard on 4 definition writers ─┐
  ROUND A ──────────┤                                                       ├──► no schema, no bump
  (PureV26)         ├─ F2 inc 1  open the class-4 re-rate fence ────────────┤    independent of every
                    └─ B2 finish eviction bulking + pricing ────────────────┘    decision below

                    ┌─ S1   unclaimed-count  (AcquisitionSchemasV3 → V4)
  ROUND B ──────────┤  + F5 X-prefix canon sweep (rides the same cascade)
  (the S1 round)    │  + F3 two-line deletion        ← AFTER the counter work
                    └─ F1 inc 2/3 + F2 inc 2/3       ← BLOCKED on D1

  ROUND C ──────────── F4  coin UrStoa vault         ← AFTER Round B is observed on mainnet
```

### 4.1 The four ordering rulings, and the reason for each

1. **F3 lands after S1's counter work, in the same round.** F3 changes *who may claim*; S1 redefines
   *the counter that counts claimants* and **re-derives the sweep guard rather than carrying it over**
   (S1 §9). Two simultaneous changes to the claimant population, with the guard being rewritten
   between them, is how the first version got wrong.
2. **F4 lands after Round B is observed.** Owner ruling: *"fix AFTER S1, so the pattern is proven on
   modules we own before touching StoaChain's root contract."* F4 §6.2 copies S1's predicate rather
   than deriving it twice — so the predicate must exist and be proven first.
3. **F1/F2's family remedies cannot be designed before D1.** The code contains *both* candidate
   answers, each with a reasoned comment (§5.1). A bump map built before the ruling is the V13 failure
   repeated.
4. **Round A is unconditional.** Every item in it is correct under every answer to every decision in
   §5. That is the selection criterion, not cost.

### 4.2 The circular dependency, and how it resolves

F3's spec says *S1 first*. S1's amended §5.7 says *the cleanest resolution of the collect-ineligible
claimant is to fix F3 so it cannot exist*. Read naively that is a cycle.

**It resolves because they are different artefacts.** S1's **locked definition** is written as though
the ineligible case will not exist, with §5.7 recording why and naming the dependency. F3's
**deletion** then lands in the same round, after the counter transitions. If F3 were deferred out of
Round B, S1 would ship a definition whose precondition is false — so **they are coupled, and Round B
must carry both or neither.**

---

## 5. Every owner decision, in one list

Ordered by what they block. **D1 is the only one blocking build work already specified.**

| | decision | blocks | spec | recommendation |
|---|---|---|---|---|
| **D1** | **Historical or live base semantics?** Does a weight change apply to positions already staked? | F1 inc 2/3, F2 inc 2/3 — i.e. most of Round B's class-A work | F1 §12.1 | **none offered** — see §5.1 |
| **D2** | Has a definition re-issue already happened on live state? | the backfill value (adopt existing residue, or re-rate everyone) | F1 §12.2 | **answer by reading the chain** — `URHC_AQP|ScoreBackfillOutstanding`, no transaction |
| **D3** | Is `SCR|C>UPDATE-MULTIPLIERS` in scope? | may change D1's cost balance | F1 §12.4 | **trace before answering D1** — family A covers it natively, family B needs a second counter |
| **D4** | Make `UR_N|RawScore` immutable after first set? | F2 inc 3(i) | F2 §9.2 | product decision; DPDC already made this exact trade for the Set multiplier (Audit #15H) |
| **D5** | Confirm "disable never traps". | F3's whole framing | F3 §10.1 | **confirm** — the opposite reading leaves no holder-reachable recovery |
| **D6** | Any reason the collect gate exists that the trace missed? | deletion vs relocation | F3 §10.2 | searched, found nothing; the `enforce` carries **no comment**, which in this tree is itself evidence |
| **D7** | Does a collect-ineligible claimant count? | S1's locked definition and sweep guard | S1 §5.7 | **option (c)** — fix F3 so it cannot exist |
| **D8** | Who writes F4's backfilled count, and is the entrypoint kept? | F4 §6.5 | F4 §8.2 | a *kept* arbitrary setter is a standing risk of the under-count F4 §4 warns about |
| **D9** | Is `coin`'s `nzs-count` wanted at all? | F4 §6.3 | F4 §8.3 | mark vestigial; otherwise it is a fifth half-built mechanism and belongs on the ledger as one |

### 5.1 Why D1 gets no recommendation

Both answers are **already in the module**, each with a reasoned comment, and they are not reconcilable
by engineering judgement — they are different products.

**Historical — "no more no less."** `XI_1|UpdateScoreDataForOrtoFungibleLP`:

> THE UNSTAKE REVERSES THE LEDGER, NOT THE LIVE MULTIPLIER, and that asymmetry is the whole point. …
> `SCR|T|SleepStake` records what was awarded; this gives back exactly that. **Owner's instruction:
> "no more no less".**

That comment also describes F1's residue exactly — *"leave the difference on the base as weight for a
position nobody holds"* — while explaining why **that** path was built not to have it.

**Live — "the base follows current state."** The PureV25 class-3 route:
`URH_AQP|ScoreTargetBaseForBeneficiarySf` → `URHC_AQP|ScoreBackfillOutstanding` →
`CCp_BackfillScoreSlice`. Already shipped.

Observable difference — holder stakes 100 at weight 2, weight corrected to 3:

- **historical**: contribution stays 200; the corrected weight applies only on restake.
- **live**: contribution becomes 300 after the sweep; the correction is retroactive.

Family B is **materially cheaper** — no new table, and the engine already shipped. **That must not be
why it is chosen.** It is cheaper because PureV25 already paid for it, not because it is more correct.

---

## 6. What is NOT wrong — verified negatives

Recorded because each is something a reader of these specs will reasonably suspect, and tracing them
was most of the work.

1. **The drift latch is sound on its own terms.** `SCR|C>LOCK-SCORE-DRIFT`'s *"WHY THOSE TWO AND
   NOTHING ELSE"* is a true claim about inputs that move with **no transaction at all**. F1 is a
   different vector — the write and the un-write disagreeing. The `@doc` needs **scoping, not
   correcting** (F1 §1.2, §11.3).
2. **F3 is an access-control defect, not an accounting one.** Four candidate accounting failures were
   traced and all are correct: principal is never trapped (readiness is `(if direction … true)`, so
   unstake always works); accrual genuinely stops; the `TotalDebScore` mirror stays correct across
   disable → unstake → re-enable, because the sync set is `Enabled`-filtered; and the farm's `S`
   adjusts symmetrically on `changed` only (F3 §1.3).
3. **`coin`'s removed reset was removed CORRECTLY.** The live contract records the rationale twice
   (lines 1731, 1756): resetting `unclaimed-count := nzs-count` on inject drops zero-stake accounts
   holding pending rewards, which is the dangerous **under**-count direction. An earlier reading this
   session called it *"an unreasoned port artefact"* — the opposite is true. What was never done is
   replacing the capability it provided (F4 §4).
4. **The eviction bulking (B2) does not inherit the zero-amount hazard.** `XE_EvictPayNoMove` defers
   the transfer, so the abort that protects `coin` (§6.5) is absent there — but the path is safe for a
   *different* reason: `owed` is read per-leg immediately before that leg books, the bulk pays exactly
   that sum, and `XI_1|BookCollectUnclaimed` retires only on `deb == 0 AND pending > 0`, so a
   zero-owed leg books nothing, is paid nothing, and does not move the counter. **Checked
   deliberately, because the two protections are different and conflating them would hide a loss
   path.**
5. **`UR_SetMultiplier` is already immutable** (DPDC Audit #15H removed `C_UpdateSetMultiplier`), so
   only one of model 0's two inputs moves. It is also the §7.1 precedent for F2's cheapest remedy.
   **Currently true by the *absence* of a function, which nothing pins** — hence F2 `<<TX-F2-007>>`.

### 6.5 One guard in the root contract holds by accident

Flagged separately because it is the only latent *theft* vector in the set.

`C_URV|Collect` decrements `unclaimed-count` with no check that anything was collected, and
`URV|COLLECT` authorises on ownership alone. Repeated collects on a drained account would drive the
count below 1; the next claimant would then be paid `UR_URV|VaultSupply` — **the entire vault,
including every other staker's rewards.**

It does not execute because step 1 transmits `available-rewards` and `X_TRANSFER`'s `UEV_Amount` is
strict (`(> amount 0.0)`), aborting before the decrement. **A token-transfer precondition in another
module is the only thing holding it closed, and nothing records the dependency** — while the `>= 0.0`
variant (`UEV_MngAmount`) exists in the same contract.

F4 §6.1 therefore adds `(enforce (> available-rewards 0.0) "Nothing to collect")` **unconditionally,
regardless of what else that round changes.** It converts an invariant that depends on another
module into one stated where it is needed.

---

## 7. Lessons — written as review habits, because no check would have caught these

1. **For every maintained counter, grep for its reader.** Five instances in §3. A counter whose only
   consumers are its own increment and decrement is write-only state. This single grep found three of
   the five.
2. **An invariant that holds because of a precondition elsewhere is not stated.** §6.5. Write the
   guard where the invariant is needed, even when it is provably redundant today — *especially* when
   a laxer variant of the precondition exists nearby.
3. **A narrow reasoned claim generalises itself in prose.** Twice: the drift latch's *"and nothing
   else"*, and the toggle's *"Disabling is always allowed"* — both correct about the invariant their
   author had in mind, both read as claims about everything. Remedy: **scope the sentence**; do not
   delete it, because the reasoning is worth keeping.
4. **Documentation asserting a mechanism works prevents its discovery.** `README_SCORE.md:232`
   described a staleness detector that does not exist. Worse than no documentation, because it
   answers the question a reader was about to ask.
5. **A reader that returns the same value for "nothing is wrong" and "I am not allowed to look" is a
   false negative generator.** `URHC_AQP|ScoreBackfillOutstanding` returns `[]` for a class-4 score
   for both reasons, and its `@doc` calls empty *"fully rated"* (F2 §3). Honest in the `@doc`,
   indistinguishable at the call site. **Make the refusal a distinct value**, which is what F2's
   increment 1 does.
6. **Two correct rules in adjacent functions can disagree about what a field means.** `coin`'s unstake
   decrement (1787) is carefully right about zero-stake-with-pending; its collect decrement (1816) is
   wrong about the same question, by the same author. Consistency within a function is not consistency
   of a definition.

---

## 8. Round plan

### Round A — PureV26, unconditional

| item | change | schema | cascade |
|---|---|---|---|
| B2 finish | `URCi_EvictMultiRewards`/`URCi_FullEvictRewards` pricing (currently overcharges N transfer legs; `URCi_BulkTransferCumulator` prices on **amounts**, not shape); full gate | none | none |
| F1 §6.3 | `drift-locked` guard on the 4 definition writers | none | none — defcap-internal `enforce` |
| F2 inc 1 | `URH_AQP|ScoreTargetBaseForBeneficiaryNf`; dispatcher; fence `[0 1 3]` → `[0 1 3 4]` | none | `AcquisitionPoolsV*` + consumers (new interface member) |
| docs | F1 §11.1–11.4 corrections | — | — |

**Delete `XE_EvictSweepLaneDust` only when S1 lands**, not here — it is the stopgap for the sweep S1
makes reachable.

### Round B — the S1 round

`AcquisitionSchemasV3 → V4`, `AcquisitionRewardPerShareV5 → V6`,
`AcquisitionFarmsVaultsTreasuriesV6 → V7`, 11-module cascade, plus backfill transactions.

Order **within** the round matters: S1's counter transitions, **then** F3's deletion (§4.1.1), then
F1/F2's family remedies if D1 is answered. F5's rename rides the same cascade (owner ruling: *"we take
no corners when fixing a bug … no modification is too small"*).

**Do not build the bump map from `LIVE-INTERFACE-VERSIONS.md`** — it is unlinked from the load order
precisely because a wrong map was built from it. Use `_livemodules.py --diff`, and remember it
**understates** the cascade: an interface rename changes no function shapes, so consumers read as
identical and must still ship.

### Round C — `coin`

F4, after Round B is observed on mainnet. Sandbox parity first (F4 §7 `<<TX-F4-000>>`) — the
`00_StoaSandbox/` copies still call the removed reset, so the suite would otherwise test a contract
that is not deployed.

---

## 9. Immediate next actions

1. **Answer D2 by reading the chain** — `URHC_AQP|ScoreBackfillOutstanding` over live pools and
   scores. A read, no transaction. It tells us whether F1 is a repair or only a prevention, and it
   picks the backfill value. **Cheapest high-information action in the set.**
2. **Trace D3** (`UPDATE-MULTIPLIERS`) — needed *before* D1, since it changes which family is cheaper.
3. **Build Round A** — unconditional, and it closes the sharpest case (a score explicitly promised
   drift-proof) plus the class-4 false negative, without prejudging anything.
4. **Then D1**, with D2 and D3 in hand.
