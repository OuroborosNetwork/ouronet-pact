# Deploy/PureV17 — collecting nothing is a refusal, not a billable no-op

**1 transaction. One `enforce` added to `CC_Collect`. No interface change, no cascade, no backfill.**

## The incident

Two consecutive `AQP-FVT|CC_Collect` calls on the same vault, lane and holder:

| tx | result |
|---|---|
| `Caq1B4S2UdrFIgoCF-DkFoXBkhMMbD-HzwEYdZ7ruMg` | *"Successfully collected **2.375302789248** WSTOA…"* — with a DPTF transfer event |
| `_n8jEM6Pu5lZn7kVVnaqsPieo6IJwcEakC_TF5CiiTw` | *"Successfully collected **0.000000000000** WSTOA…"* — **no DPTF transfer event at all** |

The second one's events tell the whole story: `FVT|C>COLLECT` fired, `IGNIS|C>COLLECT` billed
**57**, and nothing moved. The holder paid 57 IGNIS for a transaction that transferred nothing.

## The arithmetic was not wrong

Queried against mainnet at the time of the report:

| probe | value |
|---|---|
| global `CurrentRps` | `0.004346837826404259873894329519365466714391819557` |
| holder `LastRps` | `0.004346837826404259873894329519365466714391819557` |
| holder `PendingRewards` | `0` |
| `StreamCount` / `StreamUnreleased` | `0` / `0` |
| live claimable | **`0`** |

The holder's checkpoint sat EXACTLY at the global index. Their own earlier collect put it there,
no stream was dripping on the lane, and nothing had accrued since. **A correct zero.**

## The defect was that a correct zero was allowed to BILL

`RPS.XI_TransferRewardDptfFromVault` opened with

```pact
(if (<= payout 0.0)
    (UC_EmptyOc)
    …)
```

so a non-positive payout short-circuited to an empty cumulator and the call succeeded having done
nothing. **This was a deliberate design choice, not an oversight** — `[6.2.4]_AQP-FVT.repl`
carried a block titled *"second collect idempotent"* asserting exactly `second collect payout=0`.
On its own terms it was right: collecting twice cannot double-pay. What it missed is that the
second call is not free.

Owner ruling, 2026-10-28: *"collection should only be possible for greater than 0 values."*

## The change

`AQP-FVT.CC_Collect` now enforces a positive claimable before billing:

```pact
(enforce
    (> (ref-RPS::URC_CollectClaimableRewards
            executor pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
        0.0)
    "Nothing to collect: no rewards have accrued on this reward token for this score-entity")
```

**Placed AFTER the stream drip, and that position is load-bearing.** `UEV_CollectContext` runs
before `XE_XI_ReleaseStream`, and a lane carrying a live stream has a claimable that is ZERO
before the drip and positive after it. Checking in the defcap would refuse exactly the streamed
collects that are legitimate — a stricter gate that is *wrong*, which is worse than the one it
replaces.

**Not placed in the `XI_` that already has the value**, where it would have cost nothing: an
`XI_` must not enforce, and exactly one in the sovereign tree breaks that today. Nine `C_`/`CC_`
carry an `enforce`, two of them in this module. The cost is one extra `URC` read over rows the
transaction has already touched.

The now-unreachable `(if (<= payout 0.0) …)` branch in RPS is **annotated, not deleted** — it is
the line that allowed the defect, and it remains a floor for any future caller.

## What this does NOT break

`CC_Collect` has a side effect beyond paying: PHASE 6 refreshes a stale deb score and resyncs the
FVT mirror. That side effect is now unreachable when the payout is zero.

**Nobody is stranded.** `CC_UnstaleMyScores` is the dedicated self-service unstale path, is
Talos-wired, and its own doc states it is *"deliberately the cheaper path so users proactively
unstale"*. A holder with nothing to collect has always had a better route than paying for a
collect that moves nothing.

## Four suites were using the old behaviour

Found by the gate, each updated rather than disabled:

| suite | what it used a zero collect for | now |
|---|---|---|
| `[6.2.4]_AQP-FVT` | an **idempotence guarantee** | asserts the refusal, **and** that the refusal moves nothing |
| `[6.4]_AQP-TRIPLET-COLLECT` | an **attack vehicle** — a zero-weight account walking the claimant counter | asserts **both** defences: the new refusal *and* the original counter invariant |
| `Kursan/AQP-stream-tests` | a **gas baseline** | both sides now pay, so the 1,109-gas delta isolates the drip instead of comparing payout against a no-op |
| `[6.2.7]_AQP-DEB-MTX` | a **deb-staleness self-fix trigger** | the lane is funded *before* staleness is created, so PHASE 6 is still exercised |

A new regression pins the incident itself: `<<TX-AQP-CL01Z>>` in
`[6.4]_AQP-EXHAUSTIVE-COLLECT.repl`, with a **non-vacuity check first** (claimable really is 0),
because otherwise an `expect-failure` could pass for the wrong reason.

**Gate green: 29,220 assertions.**

## Scope derivation

Per `HOW-DEPLOY-ROUNDS-WORK.md`, not from `git diff`:

1. **Shape diff** — `_livemodules.py --diff` shows neither `AQP-FVT` nor `RPS` differing, because
   the change adds no function, capability or constant. It is a BODY edit, which `--diff`
   structurally cannot see. *(The cache was 2 days stale and 7 modules had moved on chain; it was
   refreshed with `--probe` before this was read.)*
2. **Cascade** — **none.** No interface touched, confirmed over `0_Interfaces/`.
3. **Batch** — `Deploy/1_Pure/18_deploy.pact` carries `05_FVT.pact` alone.
4. **Generator gaps** — none. The two backfills MANIFEST ties to these modules
   (`min-inject-amount`, `stream-eligible`) are for schema fields **already live on chain**; this
   change adds no schema field.

**RPS is NOT in this round.** Its only edit is the comment on the unreachable branch; compared
module-to-module against live source its remaining difference is `create-table` forms, which an
upgrade deploy strips anyway. No behaviour change, so it does not belong. *The modification
dictates the round.*
