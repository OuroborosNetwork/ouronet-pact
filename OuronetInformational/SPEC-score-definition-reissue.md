<!-- F1 · opened 2026-11-08 · OPEN -->

# SPEC — SF/NF score-definition re-issue, and the staleness detector that was never built

> **Companion to** [`FINDINGS-2026-11-08.md`](FINDINGS-2026-11-08.md) §F1 (and §F2, which is the
> same defect one class over). To be folded into the unified spec once F2–F4 are written.
>
> **Status: SPECIFICATION, NOT A BUILD PLAN.** §6 presents two coherent fix families and §12 names
> the decision that picks between them. That decision is the owner's and is not made here, because
> the two families give *different and both-defensible* answers to "what does a weight change mean
> for a position already staked?" Building either one before that is answered is building a guess.

---

## 1. What is wrong

A class-3 (DPSF) or class-4 (DPNF) score base is an **accumulated signed delta**, not a recomputed
quantity. Stake adds a delta; unstake subtracts one. Both deltas are produced by the *same* function
with a `direction` flag, and both read the nonce weighting **live** from `SCR|T|SF|Score`:

```pact
(defun URC_SignedBaseDeltaForDpsfStake:decimal
    (score-id:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    …
    ;;SIGN OUTSIDE THE FLOOR, AND THIS IS NOT COSMETIC -- see CT_SIGNED_FLOOR_NOTE.
    (* (floor raw-weight p) (if direction 1.0 -1.0)))
```

`AQP-SCR|C_IssueSemiFungibleScoreDefinition` may rewrite those weights at any time, under any
amount of live stake. Nothing stops it.

### 1.1 The mechanism, exactly

For one holder, one nonce, amount `a`, score precision `p`, definition weight `W`:

| event | definition in force | written to base |
|---|---|---|
| stake | `D₁` | `+ floor(W(D₁) · a, p)` |
| *(re-issue)* | `D₁ → D₂` | — nothing; no row moves |
| unstake | `D₂` | `− floor(W(D₂) · a, p)` |

**Residue on the base after the position is fully closed:**

```
floor(W(D₁)·a, p) − floor(W(D₂)·a, p)
```

Properties that make this a correctness defect rather than a rounding nuisance:

- **It is unbounded in magnitude.** It scales with `a` and with the size of the weight change.
- **It is unbounded in sign.** `W(D₂) > W(D₁)` leaves a *negative* residue.
- **It is permanent.** No later event subtracts it; nothing recomputes the base from live stake on
  the normal path. The holder has no position and a non-zero base.
- **It survives the holder.** The residue sits on the per-beneficiary row, so the score's aggregate
  carries weight for stake nobody holds — which is the denominator of every reward split on that
  score.
- **A re-issue to the *same* values is still unsafe** when `p` differs from the value's own
  precision, because the two `floor`s are taken at different times against possibly-changed
  `ScorePrecision`. (Secondary; `SCR|C>ISSUE-SF-SCORE-DEFINITION` does enforce precision conformance
  at write time, so this needs a precision change to bite.)

### 1.2 What is NOT wrong — the drift latch is sound on its own terms

`SCR|C>LOCK-SCORE-DRIFT` exists (shipped V14, 2026-10-25: field, reader, writer, client entrypoint,
`URCi_` cost reader, and `AA_MigrateDriftLocked` backfill). Its `@doc` enumerates the vectors:

> **WHY THOSE TWO AND NOTHING ELSE.** They are the only inputs to a stored weight that can move
> without the holder restaking: deb comes from the holder's Elite tier, and the boost promile comes
> from the linked BOOST CLASS. With deb-boost off and no class link, the promile short-circuits to
> 0.0 and ANK is never consulted, so **the weight is arithmetically frozen between stakes.**

**That claim is TRUE, and this defect does not contradict it.** State it carefully, because the
distinction is the whole reason the latch did not catch F1:

| | drift (what the latch covers) | asymmetry (F1) |
|---|---|---|
| when the base goes wrong | continuously, with no holder action | at the holder's **next unstake** |
| does the stored base move between stakes? | no — the *reward computation* reads a moved input | no |
| detected by | deb-boost / boost-class-link being provably inert | nothing |

The latch protects against a stored weight whose *inputs* move under it. F1 is a stored weight whose
*write* and *un-write* disagree. Different vector, same consequence: `base ≠ Σ(amount × weight)`.

**The practical trap is the word "drift-proof".** A score may be drift-**locked** — the strongest
promise the module offers about its weights — and still accumulate residue from a definition
re-issue, because neither `SCR|C>ISSUE-SF-SCORE-DEFINITION` (line 1023) nor
`SCR|C>ISSUE-NF-SCORE-DEFINITION` (1078) nor `SCR|C>ISSUE-NF-SET-SCORE-DEFINITION` (1086) nor
`SCR|XI>X_ISSUE-NF-SCORE-DEFINITION` (1094) consults `UR_SCR|ScoreDriftLocked`. Measured: the only
four `drift-locked` guards in the module are at lines 969, 1013, 1161, 1204 — the lock itself and the
three boost caps. **Zero definition writers check it.**

So §11 asks for the latch's `@doc` to be *scoped*, not corrected: "the only inputs that can move
without the holder restaking" should read "…without any transaction touching this score", which is
what it actually proves.

### 1.3 Measured, not argued — the guard inconsistency

Three sibling reconfiguration capabilities demand the score be empty before its weighting may change:

| line | capability | guard |
|---|---|---|
| 968 | `SCR|C>ENABLE-DEB-BOOST-SCORE` | `(= (UR_SCR|ScoreNzsCount score-id) 0)` |
| 1160 | `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE` | `(= (UR_SCR|ScoreNzsCount score-id) 0)` |
| 1196 | `SCR|C>CREATE-BOOST-LINK-SCORE` | `(= (UR_SCR|ScoreNzsCount score-id) 0)` |

refused with *"the score must have no stakers (nzs-count = 0) — vacate to reconfigure"*.

Those are the **only three** `ScoreNzsCount` guards in `02_SCORE.pact`. The four definition writers
above do not carry it, and neither does `SCR|C>UPDATE-MULTIPLIERS` (line 890) — see §1.5.

The per-nonce weights are the *most direct* input to a class-3 base of anything in that table. The
indirect inputs are gated; the direct one is not.

### 1.4 A half-built detector, not a regression — `DefRevision`

The staleness detector for exactly this defect **was designed, is documented as working, and does not
exist.**

What exists:

- `SCR|T|SF|DefRevision` with `revision-nonce`, and `SCR|T|NF|DefRevision` with **three**
  (`global-revision-nonce`, `trait-revision-nonce`, `class-revision-nonce`).
- A live writer: `XI_IssueSemiFungibleScoreDefinition` bumps once per call —
  `(WW_SFDefRevision score-id dpsf-id (UDC_SCR|SF|DefRevision (+ revision-nonce 1) …))`.

What consumes it — **the complete census, all four nonces**:

```pact
;; URCx_SfStakeDefinitionWeightedRawWeight  (02_SCORE.pact:2622)
(if (= rev 0) 0.0 …)
;; URCx_DpnfModelOneScrDefinitionRawWeight  (02_SCORE.pact:2693)
(if (= g 0) 0.0 (… (if (= trait-rev 0) [] …) … (if (= class-rev 0) 0 …)))
```

**Every read is an `= 0` existence test.** The value above zero is never compared to anything. A
counter that only ever answers "has this been defined at all?" is a boolean wearing an integer's
clothes — and it is incremented faithfully on every call, which is what makes it look alive.

The intended consumer is named in the source and in the docs:

```
;; 02_SCORE.pact:576
;;trackers compare applied-def-revision-nonce to SCR|T|SF|DefRevision.revision-nonce /
```

> `README_SCORE.md:232` — "Per-user score attribution rows in AQP track an
> `applied-def-revision-nonce`. On the user's next stake/unstake interaction, the revision is
> compared and the score is recomputed if stale."

**`applied-def-revision-nonce` occurs exactly twice in the entire repository: in that comment and in
that sentence.** No schema field. No writer. No comparison. Verified across `1_SOVEREIGN/`,
`2_CITIZEN/` and `REPL/`.

The documentation asserts the defect is already handled. It is the kind of sentence that stops
anyone from looking.

**This is the fourth instance of one pattern** — a mechanism built to the point of maintaining state,
with the consumer never written, and prose describing the finished version:

| mechanism | state kept | consumer |
|---|---|---|
| `TotalNzsCount` | maintained | never written |
| `unclaimed-count` | maintained, writer/reader disagree | partial — see [`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md) |
| `SCR|T|*|DefRevision` | maintained | degraded to `= 0` |
| *(F2)* NF trait/class revisions | maintained | degraded to `= 0` |

It is worth naming the shape, because the next one will look the same: **a counter nobody reads
cannot fail a test, so it is indistinguishable from a working feature until someone greps for its
reader.**

### 1.5 Already exploited, deliberately, by our own tests

`REPL/modules/EVICT-BULK.repl` uses this route **on purpose** to manufacture a stale class-3 base,
because after the PureV25 equity gate (B1) the equity route can no longer produce one.

That is the sharpest available evidence that the route is open: we reached for it when we needed a
corrupt base and it worked first time. It also means **whatever §6 chooses, that fixture breaks** —
see §9.4.

### 1.6 `SCR|C>UPDATE-MULTIPLIERS` — the same shape, and probably the same defect

`mx-frozen` / `mx-sleeping` / `mx-hibernated` multiply the raw weight, are reconfigurable with no
`nzs-count` guard, and are read live on both legs. By the §1.1 argument this leaves the identical
residue.

**Not asserted as a finding here** — it needs its own trace, because the sleeping path has a ledger
(§2.3) that may already neutralise it and the frozen/hibernated paths may not. Flagged so the
unified spec either confirms it as F6 or records why it is safe. **Do not fix F1 in a way that
cannot extend to it.**

---

## 2. The locked definitions

### 2.1 `revision-nonce`

> The number of times a definition-writing entrypoint has committed rows for this
> `(score-id, asset-id)` pair. Monotonic, never reset, bumped **once per call** regardless of how
> many nonce rows that call wrote.

Consequences that must survive any change: it is **not** a count of rows, **not** a content hash, and
two different calls that write identical values still bump it. So `revision-nonce` can only ever
answer *"might the definition have changed since nonce N?"* — never *"did the weight this holder
depends on change?"* A false positive is a wasted recompute, not a wrong number. That asymmetry is
why it is usable as a trigger and useless as a diff.

### 2.2 `applied-def-revision-nonce` (does not exist; defined here)

> On a per-(beneficiary, pool, score, asset) tracker row: the `revision-nonce` that was in force when
> that row's contribution to the base was last written.

`applied == live` ⟺ every delta on this row was computed under the current definition ⟺ the row's
contribution is reversible exactly.

### 2.3 Two meanings of "correct base" — and the module already contains both

This is the fork, and both arms have a precedent **in this module**, which is why §12.1 is a real
question and not a formality.

**(A) Historical — "no more no less".** The base records what was *awarded*. A weight change applies
to future stakes only. Precedent, verbatim, `XI_1|UpdateScoreDataForOrtoFungibleLP`:

> THE UNSTAKE REVERSES THE LEDGER, NOT THE LIVE MULTIPLIER, and that asymmetry is the whole point. A
> sleeping multiplier is a function of the time the lock has LEFT, so by the time a position comes
> out it is smaller than it was going in — recomputing the reversal would give back LESS than was
> taken and leave the difference on the base as weight for a position nobody holds.
> `SCR|T|SleepStake` records what was awarded; this gives back exactly that. **Owner's instruction:
> "no more no less".**

Note the phrase *"leave the difference on the base as weight for a position nobody holds"* — that is
F1's residue, described exactly, in a comment explaining why a **different** path was built not to
have it.

**(B) Live — "the base is a function of current state".** The base equals `Σ(amount × live weight)`;
a definition change makes every holder stale and a sweep re-rates them. Precedent: the PureV25
class-3 route, which already computes the target and the work list —
`URH_AQP|ScoreTargetBaseForBeneficiarySf`, `URHC_AQP|ScoreBackfillOutstanding`,
`CCp_BackfillScoreSlice`.

They differ in observable outcome. Holder stakes 100 units at weight 2, weight is corrected to 3:

- **(A)** base contribution stays 200; rewards reflect weight 2 until they restake.
- **(B)** base contribution becomes 300 after the sweep; rewards reflect the corrected weight
  retroactively.

Neither is obviously right. (A) is what the module's own ledger precedent chose. (B) is what an
operator *fixing a mistake* almost certainly intends, and is what the machinery already shipped in
PureV25 supports.

---

## 3. State

### 3.1 Already present — no change needed

| table | field | status |
|---|---|---|
| `SCR|T|SF|DefRevision` | `revision-nonce` | maintained; consumed as `= 0` only |
| `SCR|T|NF|DefRevision` | `global-` / `trait-` / `class-revision-nonce` | same |
| `SCR|T|Score` | `drift-locked` | fully built; not consulted by definition writers |
| `SCR|T|Score` | `nzs-count` | maintained; guards 3 of 8 reconfiguration caps |
| `SCR|T|SleepStake` | awarded sleeping weight | the family-(A) precedent, DPOF LP only |

### 3.2 Required by family (A) only

A per-(beneficiary, pool, score, asset, nonce) **awarded-weight stamp**, so the unstake reverses the
stamp rather than recomputing. This is `SCR|T|SleepStake` generalised to class 3 and class 4.

Cost: one row per staked nonce per position, written on stake, deleted on unstake. It is a **new
domain table** and a schema bump. It is *not* a scan: both legs already enumerate the holder's
nonces, so the stamp is point-read/point-write along a path that is already `O(staked nonces)`.

### 3.3 Required by family (B) only

`applied-def-revision-nonce:integer` on the AQP per-beneficiary tracker row, per §2.2.

Cost: one integer per tracker row and a field backfill (§8). **No new table.** The recompute engine
already exists.

**This is the materially cheaper arm, and that must not be the reason it is chosen.** It is cheaper
because PureV25 already paid for it, not because it is more correct.

---

## 4. Transitions — every site

Sites are listed for both families; `(A)`/`(B)` marks which arm needs the row.

| # | site | today | must become |
|---|---|---|---|
| T1 | `XI_IssueSemiFungibleScoreDefinition` | writes rows, bumps `revision-nonce` | unchanged *(the bump is already right)* |
| T2 | `SCR|C>ISSUE-SF-SCORE-DEFINITION` | shape validation only | **+ `drift-locked` guard** (both arms); **+ `nzs-count = 0`** iff §12.1 picks the hard gate |
| T3 | `SCR|C>ISSUE-NF-SCORE-DEFINITION`, `…-NF-SET-…`, `SCR|XI>X_ISSUE-NF-…` | same | same — F2 |
| T4 | `XI_1|UpdateScoreDataForSemiFungible` (stake leg) | `URC_SignedBaseDeltaForDpsfStake … true` | **(A)** stamp awarded weight · **(B)** write `applied = live revision` |
| T5 | same (unstake leg, `direction false`) | recomputes from live definition | **(A)** reverse the stamp · **(B)** if `applied != live`, re-rate this row first, then reverse |
| T6 | `XI_2|ApplySingularUserScoreDelta` | applies a signed delta | unchanged — the delta's *provenance* changes, not its application |
| T7 | `URCx_SfStakeDefinitionWeightedRawWeight` | `(if (= rev 0) 0.0 …)` | unchanged in (B); in (A) it stops being on the unstake path |
| T8 | `URHC_AQP|ScoreBackfillOutstanding` | work list vs live target | **(B)** must additionally report rows stale by revision, not only by delta ≠ 0 |
| T9 | `CCp_BackfillScoreSlice` | re-rates a fed slice | **(B)** must also stamp `applied = live` per row, or it will re-report them forever |

**T9 is the one that bites.** A re-rate that fixes the base without advancing `applied` leaves the row
permanently stale-by-revision, so the sweep never terminates and `URHC_…Outstanding` never empties —
which is the signal §1.4's intended design uses to mean "fully rated". The write and the stamp must
be in the same transaction.

**T5 ordering hazard, family (B).** The re-rate must complete **before** the reversal delta is
computed, and the reversal must then be computed against the *re-rated* basis. Doing them in the
other order reverses a stale figure from a fresh base. This is the same ordering trap recorded in
[`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md) §7 for backfill vs. accrual, and it is the
reason that spec's backfill is ordered rather than idempotent.

---

## 5. What it must account for

1. **`revision-nonce` cannot diff.** §2.1. Any design that tries to compute "how much did the weight
   change" from the nonce is wrong. Detection only; repair is recompute-or-stamp.
2. **Undefined nonces weigh 0, legitimately.** `URCx_SfStakeDefinitionWeightedRawWeight` point-reads
   with a default of `0.0`. A nonce may be staked and undefined. A re-issue that *defines* a
   previously-undefined nonce therefore changes a weight from 0 to non-zero — same defect, and the
   case most likely to be hit in practice, because "I forgot a nonce" is the commonest reason to
   re-issue at all.
3. **`revision-nonce 0` means "no definition".** Holders may be staked on a score whose definition
   has never been written; their whole base contribution is 0. The first definition write is the
   `0 → 1` transition and must be treated as a weight change, not as initialisation.
4. **Precision is a second vector.** §1.1 last bullet. `ScorePrecision` participates in both `floor`s.
5. **Must extend to multipliers (§1.6) and to class 4 (F2).** A fix that only covers SF nonce weights
   leaves two live routes to the same residue.
6. **Must not add a scan to the stake path.** Both arms are `O(holder's staked nonces)`, which that
   path already is. Family (B)'s re-rate on T5 is bounded by the holder's own position, not by the
   score's population — that bound must be asserted, not assumed.
7. **Must not make a definition write scan.** The write stays `O(nonces written)`; it bumps a counter
   and refuses or does not. The same O(1)-at-write constraint the owner set for `Inject` —
   *"Inject must scale with number of legs, it must be agnostic to them"* — applies here for the same
   reason: a definition write cannot be allowed to cost the score's population.
8. **Negative/fragment nonces scale by 0.001.** Present on both legs today, so it cancels; a stamp
   design must stamp the *scaled* figure or reintroduce asymmetry.
9. **The EQUITY branch is out of scope.** `URC_SignedBaseDeltaForDpsfStake`'s first branch is keyed on
   the asset and reads live supply by design; B1/PureV25 gated it. Do not re-gate it here, and do not
   let a `nzs-count` guard on T2 accidentally cover it — EQUITY has no definition rows.

---

## 6. The fix — two families

### 6.1 Family A — stamp and reverse ("no more no less")

Add §3.2's stamp. Stake writes the awarded weight; unstake reverses the stamp. A definition re-issue
then affects **only future stakes** and needs **no gate at all** — the asymmetry is structurally
impossible, not forbidden.

- **Pro:** eliminates the defect rather than guarding it. Covers §1.6 and F2 with one mechanism.
  Follows the owner's existing ruling on the identical question.
- **Con:** a new domain table and per-nonce writes on the stake path. Does **not** let an operator fix
  a mis-set weight for existing holders — they must vacate and restake.
- **Interacts with PureV25:** makes `URH_AQP|ScoreTargetBaseForBeneficiarySf`'s notion of "target"
  wrong, because under (A) the correct base is historical and not recomputable from live state. The
  class-3 arm of the backfill engine would have to be **withdrawn**, not extended.

### 6.2 Family B — detect and re-rate

Add §3.3's `applied-def-revision-nonce`. Finish the mechanism §1.4 documents: compare on the holder's
next interaction, re-rate from live stake when stale, stamp `applied`. Extend
`URHC_AQP|ScoreBackfillOutstanding` to report revision-staleness, and have `CCp_BackfillScoreSlice`
stamp as it rates (T9).

- **Pro:** no new table; the recompute engine, the work list and the paged repair route all shipped in
  PureV25. Matches the documented design and `README_SCORE.md`. Lets an operator correct a weight for
  existing holders, which is the actual operational need.
- **Con:** it is **lazy** — a stale row stays wrong until its holder interacts or an admin sweeps, so
  the score's aggregate is wrong in the interval. Requires either auto-freeze on re-issue
  (`URC_AQP|ScoreAutoFreezeOnAdd` exists and is the right shape) or acceptance of a wrong denominator
  while the sweep runs.
- **Does not cover §1.6** without a parallel revision counter for multipliers.

### 6.3 Both families need, unconditionally

`drift-locked` must gate every definition writer (T2, T3). Under (A) it is belt-and-braces; under (B)
it is load-bearing, because a drift-locked score is exactly the one whose holders are entitled to
assume their base is stable. **This is the one change that is correct regardless of §12.1 and could
ship on its own.**

---

## 7. Interfaces, cascade, prefixes

Not enumerated — the cascade depends on which family §12.1 picks, and a bump map built before that is
the V13 failure mode ([`CLAUDE.md`](../CLAUDE.md): a wrong bump map built from a cached snapshot).
What is known:

- **(A)** new table + schema ⇒ `AcquisitionSchemasV3 → V4` and the full 11-module cascade already
  scoped for S1 in [`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md) §6. **Land it in that round.**
- **(B)** a field on the AQP tracker ⇒ the same `AcquisitionSchemasV3 → V4` bump. **Also lands in the
  S1 round.** Either way this is **not** a standalone deploy, and both arms want the same schema bump
  S1 already forces.
- **(6.3 alone)** no schema change, no interface bump — a defcap guard inside `02_SCORE.pact`.
  Deployable in any round.

Prefix discipline: a new per-row reader is `UR_`; the staleness predicate is `URC_` (read + derive, no
`enforce`); the guard is an `enforce` inside the existing defcap, or a `UEV_` if reused across the
four definition caps — which it should be. The repair entrypoint already exists and is correctly
`CCp_` (fed-slice, parallel-safe). **No `XE_XI_`-style compound prefixes** — the valid set is
`UC_/UCv_/UR_/URC_/URCv_/UEV_/UDC_/CAP_/A_/AA_/C_/CC_/{A,C}{,A}p_/XI_/XE_/XB_`, with depth written
`XI_1|` / `XI_2|`.

---

## 8. Backfill

**Family (B) requires it and it is not optional.** Adding `applied-def-revision-nonce` to a schema
leaves every pre-existing row **without the field** — and `with-default-read` does not cover that: it
defaults an absent **row**, not an absent **field** ([`CLAUDE.md`](../CLAUDE.md), the deploy-round
trap). An `AA_Migrate…` one-shot in the shape of `AA_MigrateDriftLocked` is required.

**The backfill value is a decision, not a default.**

- `applied := live revision` — asserts every existing row is correctly rated. **False** wherever a
  re-issue has already happened, and silently adopts the existing residue as truth.
- `applied := 0` — marks every row stale, so the first sweep re-rates the entire population to the
  live definition. Correct under (B)'s semantics and **expensive**, and it will move bases for
  holders who were never affected.

Which one is right depends on §12.2: whether any live score has actually had a definition re-issued
under stake. `URHC_AQP|ScoreBackfillOutstanding` can answer it per (pool, score) **before** the
round — it already reports every holder whose stored base disagrees with the live target, and under
(B)'s semantics a non-empty result on a score with no other known cause **is** the F1 residue. Run it
against live state first; the measurement picks the value.

---

## 9. Tests

### 9.1 The defect, pinned before the fix

`<<TX-F1-001>>` — stake `a` at `W₁`; re-issue to `W₂`; unstake fully; **assert base ≠ 0** and assert
the residue equals `floor(W₁·a,p) − floor(W₂·a,p)` exactly. This must pass *on today's tree*, as the
proof the spec is about something real, and invert when the fix lands.

`<<TX-F1-002>>` — same with `W₂ > W₁`; assert the residue is **negative**.

`<<TX-F1-003>>` — nonce undefined at stake (`W₁ = 0` by default), defined at re-issue (§5.2).

`<<TX-F1-004>>` — `revision-nonce 0 → 1` as the weight change (§5.3).

### 9.2 Drift-lock coverage (ships with §6.3)

`<<TX-F1-005>>` — drift-lock a score, then attempt each of the four definition writers; assert all
four refuse, **each by its own message**, so a shadowed gate is distinguishable from an absent one
(the 2026-09-14 ordering ruling's rationale).

`<<TX-F1-006>>` — negative test: a *non*-locked score's definition write still succeeds. Without this,
6.3 could be implemented as a blanket refusal and pass 005.

### 9.3 Whichever family lands

- **(A)** stake at `W₁`, re-issue, unstake ⇒ **base exactly 0**. Plus: a *new* stake after the
  re-issue is weighted at `W₂`.
- **(B)** stake at `W₁`, re-issue, interact ⇒ base `= floor(W₂·a,p)`; `applied == live`;
  `URHC_AQP|ScoreBackfillOutstanding` reports the row **before** and is **empty after** (T9 — this is
  the assertion that catches a re-rate that forgets to stamp).
- **Both:** a conservation assertion over the score aggregate — `Σ` per-beneficiary bases equals the
  score total — asserted after a full stake/re-issue/unstake cycle. This is the invariant the residue
  breaks, and the one an eviction sweep divides by.

### 9.4 `REPL/modules/EVICT-BULK.repl` must be re-fixtured

It manufactures its stale class-3 base through this exact route (§1.5), so **any** fix to §6 breaks it.
It needs a replacement route to a corrupt base. The honest options are an `AA_`-level direct row write
for test purposes, or — better — re-pointing those assertions at whatever stale-base vector remains
*after* the fix, which is the thing actually worth regression-testing. **Do not keep the fixture
alive by exempting the test path from the guard**; an exemption in a guard is a guard with a known
hole and a comment explaining it.

---

## 10. F2 — class 4 (DPNF) is the same defect

`URCx_DpnfModelOneScrDefinitionRawWeight` has the identical shape with three revision nonces instead of one, all read
as `= 0`, and three definition writers with neither `nzs-count` nor `drift-locked`. Everything above
transfers. The additional complication is the **trait aggregate**: `URC_NFTraitKeysList` is read once
per call and the per-(key,value) defs are point-read, so a re-issue can change the *key set* as well
as the weights — meaning a stamp (family A) must stamp the resolved total, not the inputs.

**Only NFT model 1 is reachable from a *definition* writer.**
`URCx_DpnfModelZeroDpdcNativeRawWeight` (model 0) reads no definition rows at all — it takes
`DPDC-S::URC_N|Score` live. So a `nzs-count` or `drift-locked` guard on the NF definition writers
constrains model-1 scores only, which is correct and should be stated in the refusal message rather
than left for an operator to discover.

**That does NOT make model 0 safe**, and this spec must not be read as saying so. Model 0 has its own
live-input vector with a *different writer in a different module under a different authority*, and it
is strictly harder to fix than anything in this document — see
[`SPEC-class4-score-revaluation.md`](SPEC-class4-score-revaluation.md). **Corrected 2026-11-08**: the
first draft of this section claimed model 0 "has no re-issue vector", conflating "reads no definition
rows" with "has no moving input". It reads a moving input owned by DPDC.

F2 gets its own spec section rather than its own spec, since the remedy is one mechanism. **Do not fix
F1 alone.**

---

## 11. Documentation that must be corrected in the same round

1. **`README_SCORE.md:232`** — states the staleness mechanism works. Must say it is specified and not
   built, pointing here. This is the highest-priority line in the spec: it is the sentence that
   prevented the defect from being found.
2. **`02_SCORE.pact:576`** — the `applied-def-revision-nonce` comment describes a comparison no code
   performs. Mark it as a forward reference to this spec.
3. **`SCR|C>LOCK-SCORE-DRIFT` `@doc`** — scope "WHY THOSE TWO AND NOTHING ELSE" per §1.2. The claim is
   true as written about *drift*; it reads as a claim about base correctness, which it is not. This
   doc has already been corrected once (2026-10-25, for offering a remedy that did not exist) and the
   correction is recorded in it — follow that precedent and record this one the same way.
4. **`URCx_SfStakeDefinitionWeightedRawWeight` / `URCx_DpnfModelOneScrDefinitionRawWeight` `@doc`s** — note that the revision read is
   an existence test only, so the next reader does not infer a comparison that is not there.

---

## 12. Decisions needed from the owner

### 12.1 Historical or live? — picks the family, blocks the build

§2.3. Does a weight change apply to positions already staked?

- **"No more no less"** (the sleeping-LP ruling, extended) ⇒ family A; a definition re-issue is
  future-only and needs no gate; the PureV25 class-3 backfill arm is withdrawn.
- **"The base follows the current definition"** ⇒ family B; finish the documented detector; keep and
  extend PureV25.

**Everything in §4, §7 and §8 is conditional on this.** It cannot be inferred from the code, because
the code contains both answers, each with a reasoned comment.

### 12.2 Has it already happened on live state?

Picks §8's backfill value and tells us whether this is a repair or only a prevention. Answerable
before the round by running `URHC_AQP|ScoreBackfillOutstanding` against live pools and scores — a
read, no transaction.

### 12.3 Does §6.3 ship early?

The `drift-locked` guard on the four definition writers is correct under both families, needs no
schema change and no interface bump. It can ride any round. Recommendation: **yes** — it closes the
sharpest case (a score that was explicitly promised to be drift-proof) without prejudging 12.1.

### 12.4 Is §1.6 in scope?

`SCR|C>UPDATE-MULTIPLIERS` appears to carry the same defect. Confirming it is a trace, not a build.
Recommendation: trace it **before** choosing a family, since family A covers it natively and family B
needs a second revision counter for it — which could change the answer to 12.1.
