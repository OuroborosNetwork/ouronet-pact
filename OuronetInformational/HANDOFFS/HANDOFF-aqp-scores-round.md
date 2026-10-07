# HANDOFF — AQP scores: client reads, the two kinds of score family, and the manager

**Written 2026-10-05.** Deploys **32, 33 and 34 are LANDED** (owner confirmed, each verified by a
`/local` read before being frozen). The UI work below is **COMPLETE and merged into the working
tree** — this file exists so a session that resumes cold knows what was established by measurement
and what is still open.

---

## 0. THE THING MOST LIKELY TO BE RE-DISCOVERED THE HARD WAY

**`AQP-BOOT.C_Step6_CreateOuroLpTriplet` creates no triplet.** Its own `@doc` says *"Issue OURO LP
triplet **scores only**"*; the actual `C_IssueTriplet` lives in Step 11, which has not run.

```
(keys ouronet-ns.AQP-SCORE.SCR|T|Triplet)   ->  []        measured 2026-10-05
UR_SCR|ScoreBoostLink Bronze                ->  Silver
UR_SCR|ScoreBoostLink Golden                ->  Silver
UR_SCR|ScoreBoostLink Silver                ->  "|"       the hub
```

The function NAME is the trap. Three scores exist, no triplet row does, and every score correctly
reports `in-triplet: false`.

**Two kinds of score family exist and they are not interchangeable.** A registered TRIPLET is ONE
aggregator member, weighted by maintained lane weights, deb-independent, cannot go stale. A BOOST
CHAIN is several members that merely feed each other's boost — each earns and stales on its own.
Calling a chain a triplet tells a user something false about how they get paid.

A chain has **no id and none can be derived**: `SCR|Triplet` says *"Positions bronze/silver/golden
are id slots only (not boost roles)"*, so three members can be arranged six ways. A registered
triplet's id is `T|<bronze>|<silver>|<golden>` and **that composite IS the score-entity-id an
aggregator admits**.

The grouping lives in `src/lib/aqp/scoreGroups.ts`, tested as behaviour (12 assertions), and it
reports `wouldBeTrueTriplet` — `SCR|Triplet`'s own definition is *"true-triplet when one score has
BAR boost-link and the other two boost-link to it"*, which is exactly the shape it detects.

---

## 1. STATE OF THE CHAIN, as measured 2026-10-05

* **12 score entities**, all owned by ONE account (the AQP-BOOT admin).
* **Every one has `aqpool-link = "|"`** — no pool employs any score. Every weight is legitimately
  zero; that is a measurement, not a gap.
* `FVT|T|MultipletFamily` — **zero rows**.
* `SCR|T|Triplet` — **zero rows**.

The all-pool-less fact mattered: the score detail screen used to refuse to render anything without
a pool, so that refusal **was** the entire detail view. A POSITION needs the triple (account, pool,
score); a DEFINITION needs only the score.

---

## 2. WHAT IS WIRED

**Client** — `ScoresTab` + `ScoreDetail` on live reads via `O-UI-FOURTEEN` (9 declared functions).
Ids on rows and a labelled copyable `Score ID` on the detail. Chains grouped with the no-id
explanation. A pool-less score renders its definition with `hasPosition: false` scoping out the
account's own figures rather than showing zeros.

**Manager** — `ScoresMgmt` rewritten from a fixture mockup. **14 of the 17 `AQP-SCR|` entrypoints**,
split `Issue a score` (5) / `Scores I own` (9). Specs in `src/constants/scoreSpecs.tsx`.

**Reward ladders moved out of Scores entirely.** `multiplet-family-id` is a field on
`FVT|RPS|Global`, keyed `<FVT-ID> | <DPTF-ID>` — an attribute of ONE REWARD LANE OF ONE AGGREGATOR.
A score cannot have one, choose one, or be used to find one. It renders on the lane now.

---

## 3. THE BOUND THAT WILL BE GOT WRONG AGAIN IF THIS FILE IS NOT READ

Score multipliers (`mx-frozen`, `mx-sleeping`, `mx-hibernated`):

```
SCR|C>ISSUE-SCORE :  (> mx 0.0)
UEV_Fee           :  -1.0  |  0.0  |  [1.0, 999.0]
usable range      :  [1.0, 999.0]
```

**Every value in `(0.0, 1.0)` looks like a sensible multiplier and is refused after the fee.** It is
a conjunction across two files. `score-op-specs.test.ts` parses all of these out of the Pact sources
rather than copying them — `anchorSpecs` had all four of its bounds wrong on first write and the
test meant to catch it compared the spec to itself.

Other bounds: precision 3..24, `nft-score-model` ∈ {-1, 0, 1}, name 2..256 alphanumeric, fee
precision 4 decimals.

---

## 4. OPEN — needs a decision, do not start on spec

**Three of the seventeen cannot be wired.** `C_IssueSingleScoreModel`,
`C_CombineTripletScoreModel`, `C_IssueScoreFromModel` turn on `SCR|T|ScoreEntityModel`, which has
**zero readers on `AcquisitionScoresV1`** — no enumerator, no field reader;
`URC_ScoreEntityModelExists` is module-only. Models can be written and never listed, and issuing
from one needs a `model-id` nothing can supply.

This is **not a side feature**: `SCR|ScoreEntityModel` is documented as *"A reusable score-entity
TEMPLATE so many entities issue IDENTICALLY (DSA: every agency scores the same)"* — it is the
delegated-vault mechanism, and the owner independently anticipated needing it ("multiple triplet
scores with different ID following the same pattern").

Reaching it needs a sovereign addition to `02_SCORE.pact` and therefore an
**`AcquisitionScoresV1` → `V2` cascade**, which touches every implementing module. The owner was
asked and has not decided. **Do not begin this without that decision.**

---

## 5. OTHER THINGS NOT DONE

* **No score operation has ever been executed.** Specs match deployed signatures param-for-param
  and bounds are parsed from Pact, but that is static agreement, not a signed transaction. The
  cheapest real check is opening an Issue form and seeing whether the cost preview renders a
  number — that proves the whole path resolved against the live contract without signing.
* ~~`AQP-POOL`'s three `C_Sync*Anchors` remain unwired.~~ **FALSE — CORRECTED 2026-10-05, hours
  after this file was written.** All three are wired and reachable from TWO places:
  `AnchorsTab`'s batch bar and `AnchorDetail`, both via `syncSpecFor(kind)` in `anchorSpecs.tsx`.

  I had said this three times — twice in conversation and once here — without once checking, and
  it took one grep to disprove. The error came from conflating "the three syncs live on the
  `AQP-POOL` module" with "the AQP-POOL *slice* is unwired", then carrying the conclusion
  forward. **A handoff repeating an unverified claim is worse than one that omits it**, because
  the next session inherits it as established fact and plans around it.

  This is why the AQP client-surface coverage is now MEASURED from the registry
  (`aqp-surface-coverage.test.ts`) rather than remembered — the same reason `_executorplan.py`
  is ground truth for the Pact sweep instead of a number in a document.
* The aggregator and pool MANAGER surfaces are fixture-backed. Stated as measured numbers rather
  than as "the slice is unwired", because that phrasing was imprecise in the same way the sync
  claim was — a module is not a screen, and the CLIENT halves of both are wired:

  ```
  AQP-ANK  6/6     AQP-SCR 14/17     AQP-POOL 11/29     AQP-FVT 2/23     AQP-DSA 0/9
  ```

  `AQP-POOL`'s 11 are stake/unstake/sync; the 18 remaining are vacate, batch-drain and pool
  administration. `AQP-FVT`'s 2 are `CC_Collect` and `CC_UnstaleMyScores` — both holder actions;
  the 21 remaining are owner operations. `AQP-DSA` (Delegated Aggregators) is untouched.

  **Do not hand-count this** — run `aqp-surface-coverage.test.ts`. It reads the spec OBJECTS,
  because two regex attempts at the same question were wrong in opposite directions (26/77 and
  74/77), and it DERIVES the AQP module set from the registry, because the hardcoded version
  named a module that does not exist and missed two that do.

---

## 6. PROCESS NOTE WORTH KEEPING

`PureV2` deploy files must be moved to `FROZEN` in `REPL/tools/_purev2.py` **the moment a deploy is
reported**, not when it is noticed. 24, 25 and 26 were each silently regenerated from a source that
had moved after they shipped — rewriting the record of what was actually sent. 32 was two edits away
from being the fourth; it was frozen in the same session it landed, and the source gained two fields
minutes later.
