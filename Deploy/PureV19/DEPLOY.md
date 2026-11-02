# Deploy/PureV19 — DEPLOY CARD

**Everything needed to send this round is in THIS folder. It is ONE transaction, and there is no
init step.** Nothing from `Deploy/1_Pure`, `2_Init`, `3_Assets` or `MANIFEST.md`. Ignore the
`see Deploy/MANIFEST.md` and `Steps 1-0 must have run first` lines inside the transaction header —
boilerplate the planner emits for the from-scratch pipeline, which does not apply to an upgrade
round. This round has **no** preceding steps.

| | |
|---|---|
| transactions | **1** — `01_deploy.pact` |
| modules | **1** — `AQP-VCT` |
| interfaces | **0** |
| init steps | **0** |
| measured | **261,126 gas**, 192,452 bytes, 3,570 lines |
| post-deploy | `python3 REPL/tools/_registrylive.py --record` |

## What it is

**The flat nonce ceiling comes off the vacate batch.**

Owner, 2026-11-02: *"there should be no limit on nonce cap, we use whatever fits. This is decided
by the UI constructor when it creates the transaction that fits, and mustn't be hindered by the
pact code."*

### What was wrong

`VACATE-MAX-NONCES` capped a batch at **64 total nonces**, and sat directly beside a
beneficiary-aware gas model that admits far more:

```
bens × VACATE-GAS-PER-BEN (75,000) + nonces × VACATE-GAS-PER-POS (4,000) ≤ VACATE-GAS-BUDGET (2,000,000)
```

For a single beneficiary that is **481 nonces**. So the flat 64 bound **first, every time**, and
made the model it was paired with unreachable. `URC_BatchOwnerArraysGasOk`'s own `@doc` already
advertised a capacity no caller could ever use:

> *"Concentrated batches fit ~159 nonces vs the old flat ~30"*

Measured consequence: a pool holding ~1,138 staked nonces needed **18** transactions where gas
alone allows about **5**.

### What changed

| | before | after |
|---|---|---|
| `VACATE-MAX-NONCES` | `64` | **deleted** |
| `URC_VacateBatchNonceTotalOk` | reader enforcing it | **deleted** |
| `VCT\|C>ORTO-FUNGIBLE-VACATE-BATCH` | 4 conjuncts incl. `nonce-ok` | 3 conjuncts |
| `VCT\|C>COLLECTABLE-VACATE-BATCH` | 5 conjuncts incl. `nonce-ok` | 4 conjuncts |

Both capability `@doc`s claimed to validate *"the total nonce count"* and were corrected — a doc
asserting a check that no longer runs is worse than no doc. The collectable one now also records
that its `gas-max` argument is **vestigial**: `URC_BatchOwnerArraysGasOk` ignores it and applies
the beneficiary-aware model instead.

**True fungible was never affected.** `VCT|C>TRUE-FUNGIBLE-VACATE-BATCH` carries `amounts`, not
nonces, and never called the deleted reader.

## Why one transaction, and no cascade

`URC_VacateBatchNonceTotalOk` was **never declared in `AcquisitionVacateV4`**. The interface
occupies lines 2–157 of `06_VCT.pact`; every edit in this round lands at line **358 or later**,
inside the module. So no interface bumps and no consumer rebinds — checked by line number rather
than asserted.

`python3 REPL/tools/_livemodules.py --diff` reports exactly one divergent pair for this work:

```
AQP-VCT.functions   DEPLOYED only: URC_VacateBatchNonceTotalOk
AQP-VCT.constants   DEPLOYED only: VACATE-MAX-NONCES
```

AQP-VCT is in the round's `also` key, not its cascade, for the same reason it was in V18's: its
body changed and its signatures did not, so an interface grep cannot see it.

## Pre-existing divergence this round does NOT address

`_livemodules.py --diff` reports **nine other** module/shape pairs that already differed before
this work. They are listed so that "not in this round" is a decision rather than an oversight:

| module | divergence |
|---|---|
| `AQP-FVT`, `TS02-C3` | repo-only `REPL_BootstrapTreasury` / `REPL_BootstrapVault` (and the Talos wrappers) |
| `BLOODSHED-C/E/L/R/SETS`, `NOSFERATU` | citizen modules refactored in the repo (`UC_`/`UDC_` renames) and never deployed |

The two sovereign ones are REPL bootstrap helpers; the rest are citizen modules, which the parity
invariant in `CLAUDE.md` does not cover. **None is touched by this round.**

## Send it

```
Deploy/PureV19/01_deploy.pact        # AQP-VCT, 261,126 gas
```

Then, because the registry snapshot is generated from the chain:

```
python3 REPL/tools/_registrylive.py --record
```

A Pact module hash changes on any redeploy, so that call is what makes the snapshot's
"last confirmed against mainnet" date mean something again.
