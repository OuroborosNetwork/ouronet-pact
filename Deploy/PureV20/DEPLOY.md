# Deploy/PureV20 — DEPLOY CARD

**Everything needed to send this round is in THIS folder.** Nothing from `Deploy/1_Pure`,
`2_Init`, `3_Assets` or `MANIFEST.md`. Ignore the `see Deploy/MANIFEST.md` and `Steps 1-0 must
have run first` lines inside each transaction header — boilerplate the planner emits for the
from-scratch pipeline, which does not apply to an upgrade round. No preceding steps, no init step.

| | |
|---|---|
| transactions | **8**, in the order below |
| modules | **20** |
| interfaces shipped | **3** — `CodexV4`, `PythiaV7`, `AcquisitionFarmsVaultsTreasuriesV6`. Nine already-live ones are SKIPPED; see below |
| init steps | **0** |
| total size | **1,752,230 bytes** |
| verified | gate green, **29,536 assertions**, identical to the pre-change baseline |
| post-deploy | `python3 REPL/tools/_registrylive.py --record` |

## Send them in this order

| # | bytes | lines | carries |
|---|---|---|---|
| `01_deploy.pact` | 291,311 | 6,200 | `CodexV4`, `CODEX`, `PythiaV7`, `PYTHIA`, `TS01-C1`, `TS01-C4`, `P-UI-ONE`, `O-UI-SEVEN`, `O-UI-THREE` |
| `02_deploy.pact` | 223,861 | 4,040 | `INFO-ONE` |
| `03_deploy.pact` | 81,427 | 1,652 | `DEMIPAD` |
| `04_deploy.pact` | 317,572 | 5,328 | `AcquisitionFarmsVaultsTreasuriesV6`, `AQP-FVT` |
| `05_deploy.pact` | 271,278 | 5,151 | `AQP-VCT`, `MTX-AQP`, `AQP-DSA` |
| `06_deploy.pact` | 218,327 | 4,082 | `AQP-EVCT`, `TS02-C3` |
| `07_deploy.pact` | 284,899 | 5,030 | `AQP-INFO`, `TS02-DPAD`, `STOAICO`, `INFO-TWO` |
| `08_deploy.pact` | 63,555 | 1,106 | `DSP` |

Largest is 317,572 bytes against a ~395 KiB per-transaction gas ceiling. The
size charge grows as the **seventh power** of transaction size, so these must NOT be merged to
reduce the count — halving a transaction divides its size charge by 128. See
`HOW-DEPLOY-ROUNDS-WORK.md`.

## What it is — two canons, one round

**§7.22 — no client-facing string carries a full Ouronet account.** An account is ~60 characters
and runs off the edge of every panel. `IGNIS::OI|UC_ShortAccount` had existed as long as the
trees have; 18 files used it, 59 sites across 11 files did not.

**§7.23 — a core `C_` does not compose the result string; Talos does.** Owner: *"the core
functions just supply the execution. Historically the talos module supplied the end result
string."* The precedent was already live (`DALOS::C_ControlSmartAccount` + `TS01-C1`), and 598 of
622 sovereign core entrypoints already followed it. Twelve did not.

**The second is why the first could not be finished in the core alone.** The account sweep had to
edit CODEX — a *core* module — because the sentence a user reads for a StoicTag registration was
built there and the Talos passed it through verbatim. Now it is composed in `TS01-C4`, and CODEX
knows nothing about presentation.

## Eight of the twenty contain no edit of their own

`MTX-AQP`, `AQP-DSA`, `AQP-EVCT`, `DSP`, `O-UI-THREE`, `O-UI-SEVEN`, `P-UI-ONE` and `AQP-VCT`'s
siblings ride the **interface cascade**: a return type is part of a signature, so dropping
`:string` from ten core entrypoints bumped three interfaces, and a modref naming `V5` cannot bind
to a module implementing `V6`. 236 occurrences were rebound across 46 files.

**`_livemodules.py --diff` CANNOT SCOPE THIS ROUND.** It compares module *shapes*, and most of
these changed only a version string. Every file is listed by hand in the generator's `also`.

## Four modules are in NO deploy chain

`09_AQP-INFO.pact` and the three AppReads (`03_O-UI-THREE`, `07_O-UI-SEVEN`, `01_P-UI-ONE`) are
loaded by REPL harnesses, so no generated batch carries them. Listing them in `also` marks them
as needing redeploy and then nothing emits them — the generator says so rather than dropping them
silently, which is the only reason an earlier cut of this round was not shipped **without
`AQP-INFO`**, the file carrying 16 of the 59 account sites including the unstake result string
that started all of this. They are placed with the round's `extra` anchors.

## Nine already-live interfaces are deliberately NOT shipped

**Pact refuses to re-deploy an interface — identical bytes included.** `Interface cannot be
upgraded`. The first cut of this round shipped twelve interfaces, nine of which were already on
chain, and a live sequential simulation stopped at transaction 01 on `PythiaLedgerV4`.

**The repo's own gate could never have caught this.** It builds a chain from scratch, where
declaring any of them for the first time is perfectly legal; only a replay against live state can
see "this is already there". The gate was green at 29,536 the whole time.

They are co-hosted in the files the three bumps dragged in. Each is now registered in
`_deploybundle.py`'s `LIVE_INTERFACES` and replaced by a skip marker in the emitted source:

`PythiaLedgerV4`, `TalosStageOne_ClientOneV3`, `TalosStageOne_ClientFourV9`,
`DemiourgosLaunchpadV3`, `AcquisitionRewardEvictionV1`, `TalosStageTwo_ClientThreeV7`,
`TalosStageTwo_DemiPadV4`, `InfoTwoV3`, `OUiThreeV2`.

Every one was confirmed **against the chain** — `(at "code" (describe-module "ouronet-ns.<name>"))`
compared to the block in the tree — and all nine matched. That check is what makes a skip safe: a
*changed* unversioned interface must be version-bumped, not skipped, and `strip_live_interfaces`
is fatal on a hash mismatch for exactly that reason.

## The three bumps are each exactly one past LIVE

Verified against the chain rather than the repo, because an undeployed round in the tree would
make repo state a lie: `CodexV3`, `PythiaV6` and `AcquisitionFarmsVaultsTreasuriesV5` are all
live, and `V4`/`V7`/`V6` are absent. No version is skipped and nothing collides.

## It also carries V19, which never shipped

`_livemodules.py --diff` on 2026-11-04 still reported `VACATE-MAX-NONCES` and
`URC_VacateBatchNonceTotalOk` as DEPLOYED-only, so the vacate nonce-cap removal was still on the
repo side of the line. Sending this round without `06_VCT.pact` would strand it behind a newer
round. **Do not send `Deploy/PureV19/`** — it is kept only as the record of a round prepared and
superseded before it went out.

## Generated by

```
python3 REPL/tools/_deploybundle.py --round 2026-11-v20-short-accounts --write
```

which emits into `Deploy/1_Pure/`; those eight files were copied here verbatim and `Deploy/1_Pure`
was then restored to the from-scratch pipeline with a plain `--write`, because the gate diffs it
against that.
