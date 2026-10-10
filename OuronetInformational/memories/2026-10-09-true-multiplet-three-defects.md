# The true-triplet weight defects — three of them, one owner ruling

2026-10-09. Supersedes `2026-10-08-true-triplet-lane-base-defect.md`, which found the second of
these and mis-scoped the fix as a one-function change.

## The ruling

Owner, 2026-10-08, in full because every fix below is measured against it:

> if within a triplet, a score uses as base one of the other scores in that triplet, then that
> score is an additive satellite when it comes to boosting. it means it earns when staking
> nothing, but boosts from boosters apply to the other base and thats what the score is. example.
> i stake 100 LP with 2x deb i got 200 silver score. bronze is 0 golden is 0. i stake a bunny with
> 10% boost for the bronze. since the bronze is tied not to its own base, but to the silver base,
> this means the boost is applied to the silver base, and used for the bronze score only as the
> boost part. so 10% out of 100 is 10 bronze score times 2x deb means 20 bronse score. otherwise
> staking LP would have meant 100 silver and 100 bronse and 100 golden score. … one base score,
> the others are additive satelites which are there for boosting purposes.

So: hub carries the whole base; satellites have base 0 and convert THEIR OWN boosters into THEIR
OWN reward quality against the HUB's base. Weight = 200 + 20 + 0 = 220.

## What was actually wrong

**D1 — `02_SCORE.pact`, the satellite's stored value clamped to zero.** The foreign-boost-link
branch stored `max(0, nominal − foreign_base)`. Its own README example explains why that was once
right: *"promile 1100 ‰ ⇒ ×1.10"*. Under that convention a promile was `1000 + bonus`, so
`base × prom/1000` was the boosted TOTAL and subtracting the base left the increment.

**ANK promiles are the bonus ALONE** — a 5% booster stores 50, not 1050. Under the real convention
`base × prom/1000` is already the increment, so the subtraction was a SECOND one and `max(0, …)`
clamped every satellite to 0 for any promile below 1000‰. Change M3 redefined `boosted-score` as
the increment, moved the normal branch over, and recorded that it deliberately *"keeps the nominal-*
surplus math unchanged"*. Two self-consistent specifications, one function, and the defect was the
join between them.

**D2 — `04_RPS.pact`, the lanes dropped the base.** `URC_ComputeTripletLanes` computed
`silver base-score × that slot's own promile`. Three faults, and only the third is obvious: the
HUB's lane became its base times a FRACTION of itself rather than the base (no boosters ⇒ w-user
0); DEB never entered; and it assumed the hub is the SILVER slot when the rules only say
`boost-link = BAR`. `[6.2.9]` proves the last one — ANHD's hub is the GOLDEN slot, so the silver
basis read 0 there regardless.

**D3 — `02_SCORE.pact`, the satellite's boost base was order-dependent.** `base-for-boost` was
`floor(foreign-base-ref + signed-user-base-delta, p)`, anticipating a hub row not yet written. But
the apply order is `URC_PoolActiveScoreIds` = *"primary through septenary order"*: the pool's SLOT
order, chosen at configuration time and unrelated to which leg is the hub. Hub early ⇒ the delta
was counted twice; hub late ⇒ it added the SATELLITE's delta, a different scale from the hub's
whenever the two multipliers differ. Measured in `[6.4]`: hub base 400 with a 50‰ booster paid
**25** instead of 20, and 600‰ paid **300** instead of 240.

**D4 — `02_SCORE.pact`, staleness could not see a booster change.** `URC_U-SCR|UserScoreDebStale`
compared the stored deb-score against `(base + STORED boosted) × live-Elite-DEB` — recomputing only
the tier while READING the boost. So it detected a DEB change and was blind to a booster change,
and its short-circuit `(not ScoreDebBoost)` excused any score with no tier even when it carried a
booster class. This was OLDER than D1–D3 and MASKED for true triplets, because their lanes read the
promile live; making lanes read stored deb-scores removed the mask and `[6.2.7] TX-SWEEP01` failed
at once — `total-lane-weight` 220 → 220 after a sweep that zeroed the promile, with silver holding
`boosted 20, base 200, deb-boost false, stale? false`.

## The fixes

| | change |
|---|---|
| D1 | satellite stores `boost-part` / `normal-deb`; no subtraction. `apply-foreign-boost-surplus` renamed `additive-satellite-row` — the word *surplus* is what let M3 stop halfway |
| D2 | each lane = that leg's STORED deb-score at its own aqpool-link. Slot-agnostic. Σ lanes ≡ `URC_TripletUserDebSum` |
| D2 | `URC_ScoreEntityUserWeight` and `URC_ScoreEntityMemberTier2Divisor` both collapse onto the SCORE deb basis, read live. The contrib-weight / total-lane-weight snapshots are still maintained but no longer paid from |
| D3 | `base-for-boost` = `foreign-base-ref`, plus new `URC_HubsFirstScoreIds` applied at all three stake entrypoints so the hub is always written first |
| D4 | the predicate now asks `URC_SingularUserScoreDeltaFromSignedUserBase … 0.0` what the row SHOULD hold — no second copy of the formula — and the short-circuit requires no tier AND no booster class |

## Why no corrective transaction was needed

The hub rows on mainnet were correct throughout (base 12.5, DEB 4.5, deb-score 56.25). Only the
derivation above them was wrong. Because both tiers now read the SCORE deb basis live, and SCORE
maintains it, weights became correct the moment the fix landed — the zeroed snapshots are no longer
read to pay anyone. The owner's offer to "simply stake once more for the 3 present stakes" was not
required.

## The part worth keeping

**Every one of these was observed and written down as something else.**

- `[6.4]` saw D1 and printed `NOTE: Bronze boosted=0 — foreign surplus needs aggregate promile
  >500‰`, reasoning backwards from the clamp to a threshold and turning the symptom into
  documentation. `DEPLOY_TEST_MATRIX.md` recorded SCR-50 as **PASS** because the only thing it
  asserted was `base = 0` — the half that worked.
- `README_TRIPLET.md` carried D2 as **open decision #2**: *"lane formula uses base × promile/1000 on
  silver base-score; satellite deb-score surplus fields are not used for FVT lanes."* Both halves
  true, both wrong, filed as a design question.
- D2 cannot fail loudly at all: a zero divisor short-circuits to "nothing to pay".
- D3 passed `> 0`. A presence check cannot see a magnitude error, which is why `TX-AQP-TD-D1h/i`
  now assert the exact value computed from the live hub base and promile.
- The UI had traced D2 correctly into a warning (*"BYPASSES Elite-DEB … inert while they are
  admitted as this triplet"*) and a test pinned that warning. **A test written against a defect
  defends it once the defect is fixed** — three UI tests and one REPL note had to be retired WITH
  the defects, not around them.

A conditional assertion is indistinguishable from an absent one. `[6.4]` now asserts its FIXTURE
PRECONDITION first — that the boot granted those classes a promile at all — so a fixture that stops
producing one fails instead of excusing a zero.

## Deploy

`Deploy/PureV5/` 02 → 06, in order. AQP-SCORE, RPS, then the dot-pin closure
(MTX-AQP + AQP-DSA + AQP-VCT, AQP-FVT, AQP-INFO + AQP-BOOT + O-UI-FOURTEEN). Six of the eight
modules ship byte-identical to what is live; they are in the round because a stale dot-caller of a
table-owning callee ABORTS with *"hash not blessed"*. Same closure round V4 shipped and measured.
