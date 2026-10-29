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
| a zero-reward leg | **"0 reward simply means there is nothing to collect"** | the claimable enforce in `CCp_EvictRewards` |
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

### What the suite does NOT prove

`TX-EVICT-02` **skips** when no forced-fix count is outstanding, and says so in its output rather
than passing vacuously. Raising a count needs an inject that forces a deb fix on a *stale* score,
and the only mechanism for that in the tree moves ANHD's EliteAuryn balance — a global side effect
that would poison every later suite in `[6.2]_AQP.repl`. That is exactly why `[6.2.8c]` lives in
the destructive tail. **The right home for the zeroing proof is `deb-staleness-inject-cc.repl`**,
which is a gate entrypoint and already builds the staleness; it is not there yet.

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

## Open

- **The forced-fix zeroing is unproven by execution.** See above.
- **`IG|COMPONENTS["AQP-FVT|CC_Collect"] = 57`** has not been recalibrated against the new 208,611
  measurement. The price sheet did not move because the component is a declared constant, not a
  derived leg sum — so this is a pricing decision, not a drift.
- **`Deploy/PureV17` is superseded**; the round that carries this work is
  `2026-10-v18-eviction` in `_deploybundle.py` — 17 modules, 8 transactions.
- **Cross-repo**: `INFO_AQP-FVT|Collect` gained a sixth parameter (`collector`), so
  `OURONET-REGISTRY.json` → `@ouronet/talos-registry` → OuronetUI's collect preview spec all need
  it. The registry is chain-derived, so this unblocks only after the deploy.
