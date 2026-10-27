# Deploy/PureV16 — DEPLOY CARD

**Everything needed to send this round is in THIS folder. It is ONE transaction.** No init step,
no backfill, no configuration transaction, nothing from `Deploy/1_Pure`, `2_Init`, `3_Assets` or
`MANIFEST.md`. Ignore the `see Deploy/MANIFEST.md` and `Steps 1-0 must have run first` lines in
the transaction header — boilerplate the planner emits for the from-scratch pipeline, which does
not apply to an upgrade round. This round has **no** preceding steps.

## Send this one, and stop

| # | file | deploys | gas (REPL model) | bytes |
|---|---|---|---:|---:|
| 1 | `01_deploy.pact` | `AQP-FVT` | 285,724 | 286,849 |

286,849 against the planner's 320,000-byte cap — **33,151 bytes of headroom**. StoaChain's limit
is ~2M gas per transaction; this measured 285,724 in the REPL model plus its size charge, so it
fits with room.

## Why only one transaction

**Derived from the DEPLOYED artefact, not from git.** Re-emitting the V15 round and diffing it
transaction by transaction against `Deploy/PureV15/` shows:

```
01 (RPS)            IDENTICAL to deployed V15
02 (AQP-FVT)        CHANGED          <- this round
03 (VCT/MTX/DSA)    IDENTICAL to deployed V15
04 (AQP-INFO)       IDENTICAL to deployed V15
```

Git cannot answer this, because V15 was emitted from an uncommitted working tree — the deployed
transactions themselves are the only record of what is live. (`_livemodules.py --diff` answers the
same question against the chain and is the check to prefer when the chain is reachable.)

## What you do NOT need to do

- **No `create-table`.** Verified: **0 live forms** in the emitted file. Every one is commented out
  by upgrade mode, because the tables already exist and a live form would abort the transaction.
- **No backfill.** One new `defcap` and seven `emit-event` calls. No schema gained a field, so no
  pre-existing row is missing one.
- **No init / no reconfiguration.** No table created, no `P|A_Define` registration added — nothing
  an upgrade would fail to re-run.
- **No interface bump, no cascade.** `AcquisitionFarmsVaultsTreasuriesV4` declares **zero
  defcaps**, so a new capability obliges nothing of any consumer. No module outside this round
  needs redeploying.
- **No npm republish.** No entrypoint and no preview changed, so the client surface does not move.

## Afterwards

1. `python3 REPL/tools/_registrylive.py --record` — asks the CHAIN for each module's hash and
   records the sidecar. A Pact module hash changes on any redeploy, so this is a complete answer
   rather than a sample.
2. **Inject twice into the same lane and compare the event logs.** That is the whole point of this
   round: the first inject reports the stale set it fixed, the second reports `0`, and the gas
   difference between them is now explained ON CHAIN instead of having to be inferred.

## What is in this round

See `README.md`. In one line: **every un-staling path now says how many it un-staled.**
