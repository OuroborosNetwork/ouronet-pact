# Deploy/PureV15 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** No init step, no backfill, no
configuration transaction, nothing from `Deploy/1_Pure`, `2_Init`, `3_Assets` or `MANIFEST.md`.
Ignore the `see Deploy/MANIFEST.md` and `Steps 1-0 must have run first` lines in the transaction
headers — they are boilerplate the planner emits for the from-scratch pipeline and do not apply
to an upgrade round. This round has **no** preceding steps.

## Send these four, in this order, and stop

| # | file | deploys | gas (REPL model) | bytes |
|---|---|---|---:|---:|
| 1 | `01_deploy.pact` | `RPS` | 372,386 | 316,406 |
| 2 | `02_deploy.pact` | `AQP-FVT` | 285,724 | 278,059 |
| 3 | `03_deploy.pact` | `AQP-VCT`, `MTX-AQP`, `AQP-DSA` | 418,402 | 268,080 |
| 4 | `04_deploy.pact` | `AQP-INFO` | 0 | 116,165 |

**Order is load order, not preference.** Each module may only be sent once the modules it
references are live. Do not reorder and do not merge: the size charge is the SEVENTH power of
transaction size, so merging two of these would cost far more than sending both.

Gas figures are the **REPL model**, which is not the chain's. StoaChain's limit is ~2M per
transaction and the largest here measured 418,402 plus its size charge, so all four fit with
room. `01` is the tight one on BYTES: **316,406 against the planner's 320,000 cap, 3,594 bytes of
headroom**, and a Pact module cannot be split across transactions. RPS is close to full; the next
thing added to it may not be emittable. (The header line inside the file reads 331,529 bytes --
that is the PLANNED source size before upgrade mode strips the `create-table` forms. The emitted
file is what ships and what the cap is checked against.)

## What you do NOT need to do

- **No `create-table`.** Every `create-table` form in these files is commented out — verified, 0
  live forms across all four. The tables already exist on chain and a live form would abort the
  whole transaction.
- **No backfill.** No schema gained a field this round, so no pre-existing row is missing one.
  (Contrast `PureV14`, which needed `04_backfill.pact` and `08_backfill.pact`.)
- **No init / no reconfiguration.** No table is created, no `P|A_Define` registration is added,
  nothing an upgrade would fail to re-run.
- **No npm republish of `@ouronet/talos-registry`.** The client surface did not move: 442
  entrypoints, 447 previews, surface hash `56f3f7f008117146`, confirmed against chain+repo. No
  interface was bumped, so no module outside this round needs redeploying either.

## Afterwards

1. `python3 REPL/tools/_registrylive.py --record` — asks the CHAIN for each module's hash and
   records the sidecar. A Pact module hash changes on any redeploy, so this is a complete answer
   rather than a sample. Without it, `Deploy/OURONET-REGISTRY.json` keeps agreeing with itself
   about the old surface.
2. Collect from a **ladder** lane to exercise the new collect path — `OuroLpFarm`
   (`MULTIPLET_BASE`, no quality split, so HOMOGENEOUS) is the one to use.
   **`SubsidiaryTreasury` will not exercise it**: its reward links are registered with `BAR` as
   the family id, making it a plain single-token lane whose collect never reaches a coil. A
   collect-all there validates the lane-writer fixes in this round and none of the collect
   optimisation.

## What is in this round

Two independent changes, in the same module, so they ship together:

1. **The lane-added-after-stake collect abort** — plus the silent accrual-wipe on the same root
   cause. See `README.md` §"Three defects, one root cause".
2. **The Coil/Coil collect ladder** — 223,956 to 189,287 gas on a triplet collect (−15.5%), plus
   `RPS.URC_CollectLadderPreview` so a client can show the three amounts a ladder lane actually
   pays instead of one figure in one ticker. Also fixes a latent `patron`/`collector` misbilling
   in the heterogeneous route. See `README.md` §"FOLDED IN 2026-10-26".
