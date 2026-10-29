# Deploy/PureV17 — collecting nothing is a refusal, and the cost mirrors now price the right account

**THREE transactions.** Two independent fixes, both in the AQP collect path, which is why they
ship together: `RPS` (01), `AQP-FVT` (02), `TS02-C3` (03). The deploy card is `DEPLOY.md`.

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

## The second fix — the cost mirrors priced the PATRON, the exec pays the COLLECTOR

Found while designing `EvictRewards`, which is the first operation where the two accounts are
**never** the same: patron is the FVT owner, collector is the staker. In a self-collect they are
one account, so all five sites were latent and every live figure was right.

| site | what it did |
|---|---|
| `URC_CollectTransferLegIgnis` | its `patron` fed `URC_ComputeTripletLanes`, whose parameter is `user-id`. A sponsored collect computed the **triplet lane split** — and so the whole per-token breakdown — from the SPONSOR's deb scores. An AMOUNT error, not a price error. |
| `URC_CollectXferIgnis` | priced `AQP\|SC_NAME → patron` while the exec credits the collector. Price-affecting: `URC_TransferClasses → URC_IzSimpleTransfer → (UR_AccountRoleFeeExemption id receiver)` selects class 1/2/5/6. |
| `URC_HeterogeneousLaneRouteIgnis` | passed `patron` into `ATSU::URCi_Coil`, whose parameter is `coiler`; the exec passes `collector`. |
| `URC_CollectForcedFixIgnis` | read `UR_FVT-FFC\|Count` for `patron`; the exec reads it for `executor`. |
| `AQP-FVT\|CC_Collect` (TS02-C3) | `bal-before`/`bal-after` on `patron` across a transfer crediting `executor` — a sponsored collect reported `0.0` for a payout that happened. Its `@doc` said "for patron" and the code believed the doc. |

Four were a **rename**: `patron` was used only in positions meaning the collector, so the
parameter was simply misnamed. `URC_CollectForcedFixIgnis` needed a second parameter, because the
COUNT is the collector's while the DISCOUNT dividing it is the patron's.

**No price moved** — `_pricesync.py --check` reports both artefacts `ok`. Expected: the class only
differs when fee-exemption differs between the two accounts, and in a self-collect there is one
account. The gate stayed at **29,220 assertions**, the same count as before, which is the evidence
the rename changed no behaviour.

**One conflation remains, deliberately, and now in one place.** `URCi_CollectFull` is declared on
`AcquisitionFarmsVaultsTreasuriesV4`, and V4 **is live** — confirmed with `_livemodules.py --diff`
against the chain, not from the cached snapshot. Adding a parameter means V5, cascading to the six
files that name it plus `INFO_AQP-FVT|Collect`'s arity, which moves the registry and every client
built from it. So it passes `patron` for both roles, annotated: a sponsored collect quotes the
sponsor's figures. Nothing sponsors a collect in the UI today. It is one token at the next FVT
bump, which the EVCT round forces anyway.

## RPS has run out of deploy headroom

Worth recording, because the next person to edit it will hit this. The first version of the
comment above pushed `17_deploy.pact` to **320,214 bytes — 214 OVER** `_deploybundle.py`'s cap,
and the tool's own suggestion (raise `HEADER_RESERVE` so the planner splits one more transaction)
**cannot help**: a single module cannot be split across two transactions. The comments were
trimmed instead of raising a gate-enforced safety cap unilaterally. The emitted file is now
**318,758 bytes, leaving 1,242**.

`04_RPS.pact` is at the ceiling. The next addition to it must be paid for by removing something,
and `EVCT` must not grow it.

## Scope derivation

Per `HOW-DEPLOY-ROUNDS-WORK.md`, not from `git diff`:

1. **Shape diff** — `_livemodules.py --diff` shows `AQP-FVT` and `TS02-C3` differing only by
   `REPL_BootstrapTreasury` / `REPL_BootstrapVault`, and `RPS` not differing at all. All three
   edits are BODY edits, which `--diff` structurally cannot see. **The shape diff UNDERSTATES
   this round and that is expected, not a reason to drop a module.**
2. **Cascade** — **none.** No interface touched. `URC_CollectForcedFixIgnis` gained a parameter
   but is module-local to `04_RPS.pact`; every one of its callers is in that same file, plus two
   REPL sites that `_callarity.py` caught.
3. **Batches** — `17` (RPS), `18` (AQP-FVT), and `TS02-C3` sliced out of `21`. See `DEPLOY.md`
   for why 21 is sliced rather than copied.
4. **Generator gaps** — none. No schema field added, so no backfill.

**CORRECTED 2026-10-29.** This section previously read *"RPS is NOT in this round… its only edit
is the comment on the unreachable branch."* That was true when the round carried only the
`CC_Collect` refusal. The cost-mirror fix gave RPS a real behaviour change, so it ships — and it
is now transaction **01**, the largest in the round. *The modification dictates the round.*

## The one decision still open

`02_deploy.pact` carries `REPL_BootstrapVault` and `REPL_BootstrapTreasury`, and `03_deploy.pact`
carries their two `AQP-FVT|REPL_*` Talos wrappers — 73 pre-existing lines, not added by either
fix. **No deployed module currently carries `REPL_` helpers**, and 14 REPL suites use these two.
Whether they ship to mainnet is a call about surface, not about either defect.

To exclude them, remove the functions from `05_FVT.pact` and the wrappers from `04_TS02-C3.pact`,
re-run `_deploybundle.py --write`, and re-copy/re-slice. The 14 suites that use them will then
fail, which is the cost of excluding them.
