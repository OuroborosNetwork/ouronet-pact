# 2026-10-08 — SUSPECTED DEFECT: a true triplet's hub lane drops the staked base

**Found by the owner, from a number that looked wrong on screen.** Not by a test, and no test in
the tree can currently fail on it.

## The claim

`URC_ComputeTripletLanes` (`04_RPS.pact`) computes ALL THREE lanes as

```pact
(base:decimal (UR_U-SCR|UserScoreBaseScore user-id pool-id silver-id))   ;; the HUB's base
(lane-b (floor (* base (/ prom-b 1000.0)) p))
(lane-s (floor (* base (/ prom-s 1000.0)) p))
(lane-g (floor (* base (/ prom-g 1000.0)) p))
;; w-user = lane-b + lane-s + lane-g
```

and `URC_TripletUserLaneWeightLive`'s own @doc states it: *"Σ lanes = silver base × Σ promiles"*.

So the HUB's lane is the hub's base multiplied by the HUB's OWN BOOSTER RATE. With no boosters,
`prom-s = 0`, the staked base disappears, and `w-user = 0`.

## Why that is wrong, from the contract itself

The chain STORES the opposite model, and a sibling reader says so:

> `URC_MemberStakedStoaValue`: *"Triplet: SUM the three scores' total-base — **the hub
> (boost-link BAR) carries the LP base, the two satellites are surplus-only (base 0)**, so the
> sum equals the single underlying LP position"*

Measured on mainnet for the owner's position in `DHOuroLp`:

```
SilverSnakePower (hub)  base 12.5   deb 56.25     <- carries the staked LP
BronzeSnakePower        base 0                    <- surplus only
GoldenSnakePower        base 0                    <- surplus only

prom-b = prom-s = prom-g = 0        (no boosters held)
URC_ComputeTripletLanes -> lane-b 0, lane-s 0, lane-g 0, w-user 0
URC_ScoreEntityUserWeight(farm) -> 0
URC_FvtUserStillPresent(farm)   -> false
```

So the hub carries the base everywhere EXCEPT in the one function that turns it into reward
weight.

## Consequence, which is worse than one user earning nothing

`w-user` is both the Tier-1 NUMERATOR and, summed, the `total-lane-weight` DIVISOR. If no holder
has a booster, **every** holder's `w-user` is 0, so `total-lane-weight` is 0 and the member's
entire Level-2 tranche of the farm is undistributable — staked LP earns nothing and nothing can
unstick it except someone acquiring a booster. The 0/0 is guarded (`if (> w-total 0.0)`), so it
fails silently as "you earned nothing" rather than aborting.

## Expected behaviour (owner, 2026-10-08)

The hub lane carries the base; the satellites carry only surplus. In the owner's words, staking
12.5 with a 4.5 tier should give `0 + 56.25 + 0`, and a 5% bronze booster should add its surplus
to the bronze lane — tier-multiplied like everything else.

## Status

**NOT FIXED. Sovereign code, owner's call, and a deploy round.** The UI was changed only to stop
presenting it as the design: the tier-2 infomatic now reports the zero-weight outcome as a
SUSPECTED DEFECT, names the expected behaviour, and says it reports what the chain will actually
pay today.

## Why nothing caught it

`[6.2.9]` and the AQP suites stake and collect, but no assertion covers *a true triplet whose
holders have no boosters* — the one shape where the multiply-by-promile erases the base. The
fixture triplets all carry boost promiles. A regression test should assert that a true-triplet
holder with ZERO boosters still has non-zero `w-user` equal to the hub's base.
