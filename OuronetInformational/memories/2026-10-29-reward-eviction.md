# 2026-10-29 — Reward eviction (AQP-EVCT), the RPS split, and the ladder restructure

Session capture. What was decided, what was measured, and the two things that are still open.

## The ask, in the owner's words

> We have the ability to vacate a pool of all its assets, by sending them back to their owners. I
> want a similar function that Evicts the Rewards to their beneficiaries, effectively stripping all
> the reward tokens in the score aggregator, by sending them to their beneficiaries. This has to be
> a paralelizible function, that works similar to CC_Colect.

And the distinguishing property:

> While collect checks for the ownerhsip of the beneficiary who collects, EvictRewards only asks for
> the owner of the FVT.

## Rulings, each one load-bearing somewhere in the code

| question | ruling | where it shows up |
|---|---|---|
| the staleness (forced-fix) penalty | **"EvictRewards should zero it"** — a staker evicted *for* never had the chance to collect | `XE_EvictPay` → `RPS::XE_WU_FvtForcedFixCount\|Zero` |
| freeze | **not needed** — "it is simply a collet rewards triggered by the pool owner instaed of the beneficiary" | no freeze anywhere in AQP-EVCT |
| a zero-reward leg | **"0 reward simply means there is nothing to collect"** | the claimable enforce in `CCp_EvictMultiRewards` |
| scores | **"Eviction has nothing to do with score, its just sending the rewards"** — but stale scores are refreshed exactly as a collect refreshes them | `XE_EvictDrip`, which is the collect's own drip |
| coil dust | royalty sink if the pair has one, else the last beneficiary; **"EvictRewards musnt leave any dust"** | proved: a whole-FVT eviction lands the lane on `0.000000` |
| the ladder | **"Instead of coiling from the beneficiary, it should coil from the AQP\|SC_NAME. This way we would have a common core we could use."** | `ATSU::XB_Coil` + `URCi_CoilTo` |
| gasless | two variants, `AA_`/`AAp_` for the admin path and `CC_`/`CCp_` for the paid one, same name in Talos | four wrappers in `04_TS02-C3.pact` |

## What was built

- **`08b_EVCT.pact`** — module `AQP-EVCT`, interface `AcquisitionRewardEvictionV1`. Owns no table,
  holds no custody, writes nothing of its own: every write is a forward call into AQP-FVT's
  eviction surface. That is why it needs **no AQP-POOL policy entry and no governor rotation** —
  it never sends from `AQP|SC_NAME`. Loads at 44,655 gas.
- **`04b_RPSC.pact`** — module `AQP-RPSC`, the cost-preview surface RPS had to shed. Declares zero
  `deftable`s, which is why it needs no `new` entry in the deploy round.
- **`ATSU::XB_Coil`** — `C_Coil` with the funder and the recipient as separate accounts, plus
  `URCi_CoilTo` as its cost mirror (needed because `URCi_Coil` names `coiler` on both legs and the
  transfer class depends on the *receiver*).
- **AQP-FVT's collect core** — `URC_CollectPoolId`, `XI_CollectDrip`, `XI_CollectPay`,
  `XI_CollectForcedFixPenalty`, all under `(require-capability (SECURE))`. `CC_Collect` and the
  eviction surface are now two callers of one implementation rather than two implementations.
- **`REPL/Stage_02/[6.2.18]_AQP-EVICT.repl`** — the differential, described below.
- **`TS02-C3::P|ADMINISTRATIVE-SUMMONER`** — copied from TS01-A's capability of the same name.

## Why the gasless pair needed its own capability

This is the one design decision that was nearly wrong. Every other admin path in Talos reaches an
`A_` core that enforces its own `GOV` keyset, so `P|TS` is sufficient there. **Reward eviction does
not** — AQP-EVCT gates on FVT *ownership*. A gasless wrapper carrying only `P|TS` would therefore
have handed every FVT owner in the system an unmetered IGNIS path, which is exactly the door
narrowed to one account on 2026-09-15 after `RedTeam/[RT-I]_GasStation.repl`.

So `AAp_`/`AA_` gate on `P|ADMINISTRATIVE-SUMMONER` (`P|TS` + `GOV|TS02-C3_ADMIN`) **and** AQP-EVCT
still requires the executor to own the FVT. The admin keyset says the call may happen; the owner
konto says whose rewards may move.

## The differential, and how it had to be built

The requirement was explicit: *"it functions byte for byte identical to what would happen when the
user makes the reward claim himself."*

**The obvious designs do not work.** You cannot run a collect and roll it back: `rollback-tx`
discards the DB writes *and* the figures, and the REPL has no channel for carrying a value across
one. You cannot use two accounts either — their scores differ, so their payouts differ, and "equal
after dividing by score" is not byte-for-byte.

What works is **three rounds in ONE transaction** on the same account: prime, inject+collect,
inject+evict. One transaction is load-bearing twice over — block time does not advance, so a live
stream drips identically between the rounds, and the total score cannot change because nothing
stakes. Under those conditions the reward formula makes the two payouts an *exact* equality, which
is why this suite asserts `=` on decimals where the surrounding suites assert a 5% band.

Measured: **28.800000000000000000000000 both ways.**

### Three things the first draft got wrong, and what they taught

1. **The priming round was a bare collect.** Since `093060fe`, "nothing to collect is a REFUSAL,
   not a no-op" — and `[6.2.4]` leaves the lane empty. It broke **eleven gate entrypoints at
   once**. The priming round now injects first.
2. **"Both rounds start from an equal available pool"** was false (67.2 vs 86.4) because the staker
   does not own the whole score — the fixture has two, and 19.2 of each 48.0 stays for the other.
   What makes the rounds comparable is an equal **index step**, not an equal pool. Replaced with the
   exact conservation identities (`post == pre − payout`; an inject adds exactly its amount).
3. **"RG available lands identically"** was false, and the reason is a *feature*: a whole-FVT
   eviction pays every leg, so the last claimant's dust sweep pays out the entire remaining pool
   and the lane lands on **exactly zero**. The assertion that replaced it is the owner's own
   requirement — "EvictRewards musnt leave any dust" — which was previously unproven.

A wrong assertion that passes is worse than no assertion, and two of these three would have passed
had the fixture been one staker instead of two.

### What [6.2.18] cannot prove, and where it is proved instead

`TX-EVICT-02` **skips** when no forced-fix count is outstanding, and says so in its output rather
than passing vacuously. Raising a count needs an inject that fixes a *stale* score, and the only
mechanism for that in the tree moves ANHD's EliteAuryn balance down a tier — a global side effect
that would poison every later suite in `[6.2]_AQP.repl`. That is exactly why `[6.2.8c]` lives in
the destructive tail and runs in its own pact process.

So the proof lives in the chain that already pays for the fixture:
**`REPL/Stage_02/[6.2.18b]_AQP-EVICT-PENALTY.repl`**, loaded from the tail of
`deb-staleness-inject-cc.repl` (a gate entrypoint). Measured: a real forced-fix count of **3 → 0**,
with **14.270825504728847105736745 AURYN** paid to the beneficiary in the same call and all 4
claimable legs consumed, so a re-read finds none. It `enforce`s its preconditions rather than
skipping them — a zero count there means `[6.2.8c]`'s fix path stopped raising one, and a suite that
quietly passes on a vanished fixture is how a test stops testing.

## Measurements

| | |
|---|---|
| ladder, before → after the `XB_Coil` restructure | 190,641 → 208,674 gas (**+9.5%**), amounts identical to 24 dp |
| ladder, after the collect core was extracted | 208,611 gas |
| `AQP-EVCT` module load | 44,655 gas |
| `TS02-C3` module load | 214,916 gas |
| `04_RPS.pact` before → after the split | 336,132 → 300,666 source bytes |
| `05_FVT.pact` now | **320,863 bytes — the module nearest the wall** |

**The last row is a warning.** `_deploybundle.py` caps an emitted transaction at a conservative
320,000 bytes, and AQP-FVT's *source* is already past it (the emitted file is smaller, because
upgrade mode strips `create-table`). The next feature on AQP-FVT needs the same split RPS just
got — and the seventh-power size charge means there is no arguing with it.

## The registry partition blocks cannot be pre-authored — an orphan check refuses them

Worth recording because the instinct is wrong in a useful way. `CCp_EvictMultiRewards` is a fed slice and
`Deploy/OURONET-REGISTRY.authored.json` is where "may this be split, along which parameter" is
written by hand — **absence means DO NOT SPLIT**. So the obvious move is to author the two blocks
now, ahead of the deploy, and avoid shipping an entrypoint that reads as unsliceable.

`_registry.py --check` refuses:

```
registry: 2 partition claim(s) do not hold
    TS02-C3.AQP-EVCT|AAp_EvictMultiRewards: ORPHAN -- no such entrypoint (drop the entry or fix the key)
    TS02-C3.AQP-EVCT|CCp_EvictMultiRewards: ORPHAN -- no such entrypoint (drop the entry or fix the key)
```

I had read the UNMERGED check (which skips keys the artefact lacks) and concluded pre-authoring was
tolerated. It is not: there is a separate ORPHAN check, and it is right — the `_patronslots.py`
lesson is that an authored entry which outlives, or precedes, its site is an unverified claim
sitting in an authoritative file. **Reading one check and inferring the tool's behaviour from it is
the error**; running the tool is what settles it.

So the blocks live in `Deploy/PureV18/DEPLOY.md` as a post-send step, in full, with the reasoning —
prose that nothing validates, which is the correct home for a claim nothing can yet verify. The
whole-FVT variants get no block at all, and that is the answer rather than a gap: no list argument
exists to cut, they scan and spend in one transaction so they are not a cursor, and they have no
ordered phases so nothing is architectural.

## THREE SHAPES, not two — owner ruling, 2026-10-30

The surface shipped as a fed slice plus a whole-FVT convenience. The owner's reading of how a
client would actually use it changed the shape of the module:

| | legs per transaction | role |
|---|---|---|
| `CC_/AA_FullEvictRewards` | all of them | tried FIRST — "if it fits it is what would be executed" |
| `CC_/AA_EvictSingleReward` | exactly one | the FALLBACK, and the owner's preferred client shape |
| `CCp_/AAp_EvictMultiRewards` | as many as fit ~2M gas | "only for demonstration purposes", behind a toggle |

**The argument for Single is legibility and structural safety, and both are worth recording.**
Verbatim: *"the single leg TX chain is interesting because you can see instantly if there are 120
tx constructed there are 120 legs."* `URHC_BuildEvictPlans` emits one object per leg, so the
transaction count IS the leg count — no packing loop, no probe-and-resize, no arithmetic between
what was read and what was sent. And one leg is one drip plus one payment, so **no transaction in
the campaign can approach the ceiling**: the run is safe by construction where Multi is safe only
by measurement, and has to be re-measured whenever the data moves.

**What I had built and called `CC_FullEvictRewards` was never the Single shape.** It is all legs in
one transaction — the gas-risky one. The naming now says which is which: Full / Single / Multi.

### What a fan-out changes, and it is exactly two things

1. **The dust becomes order-dependent in *who*, not in *whether*.** The last claimant on a lane
   sweeps the remainder, so whichever of the N transactions lands last on that lane receives it.
   The lane still ends on exactly zero. This is the 2026-10-29 ruling rather than a side effect:
   royalty sink if the pair has one, *"if not, to the last beneficiary"*.
2. **A refused leg is not a lost leg.** Every shape re-checks the claimable, so a leg collected
   between the read and the send refuses and moves nothing; a re-read returns only what is left.
   Firing 120 at once must EXPECT a few to bounce — the safety property, not a failure.

### Proved by execution, not by inspection

`TX-EVICT-01b` in `[6.2.18]` runs the Single path on the same fixture the others ran on, in one
transaction so block time cannot move:

* the Single evict paid **28.800000000000000000000000** — the same exact figure the self-collect
  and the whole-FVT evict paid for that leg. Three entrypoints, one payout rule.
* the **Single cost quote equals the Multi quote for the same one leg** (58.0 both ways), so the
  client's choice between the two paths is not a choice between two prices.
* `URHC_EvictLegCount` equals the plan length — the legibility property, asserted rather than
  asserted-to.

### One thing deliberately NOT refactored

`URCi_EvictMultiRewards` still folds `AQP-RPSC::URCi_CollectFull` directly rather than folding
`URCi_EvictSingleReward`, which would read as the tidier version. The price-sheet generator walks
`ref-MOD::` edges and loses a leg behind an intra-module hop — measured, not feared: `C_Coil`
delegating to `XB_Coil` took the sheet from 93 claimed-exact prices to 87 and was reverted. One
duplicated call, pinned by the quote equality above, is the cheaper trade.

## Open

- ~~The forced-fix zeroing is unproven by execution.~~ **CLOSED** the same day — see
  `[6.2.18b]_AQP-EVICT-PENALTY` above.
- **`IG|COMPONENTS["AQP-FVT|CC_Collect"] = 57`** has not been recalibrated against the new 208,611
  measurement. The price sheet did not move because the component is a declared constant, not a
  derived leg sum — so this is a pricing decision, not a drift.
- **`Deploy/PureV17` is superseded**; the round that carries this work is
  `2026-10-v18-eviction` in `_deploybundle.py` — 17 modules, 8 transactions.
- **Cross-repo**: `INFO_AQP-FVT|Collect` gained a sixth parameter (`collector`), so
  `OURONET-REGISTRY.json` → `@ouronet/talos-registry` → OuronetUI's collect preview spec all need
  it. The registry is chain-derived, so this unblocks only after the deploy.
