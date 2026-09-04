# REPL/modules/ — standalone per-module testers (P3)

Each file boots a **fresh blockchain-like environment in one REPL flow** and runs *only* that
module's suite(s), so you can iterate on one module in seconds-to-a-minute instead of booting the
whole world. This is the fast-iteration half of the two-variant design; the exhaustive counterpart
is `REPL/ZALL.repl`. See `OuronetInformational/ARCHITECTURE/REPL_TEST_ARCHITECTURE.md`.

Run any tester from the REPL dir:

```bash
cd REPL && LC_ALL=C.UTF-8 pact modules/<MODULE>.repl
```

Each tester is a thin wrapper composing the **shared** pieces (no duplication): the deploy cores
(`../deploy-stageNN.repl`) + the module's suite file(s) (`../Stage_0N/[6.x]_*.repl`) — the exact
same files `ZALL.repl` loads. Some suites depend on another suite's *fixtures* (issued tokens,
collections); those prerequisite suites are loaded first (noted in each file's header).

## Roster (all green)

**Stage 1** (deploy 00→01): CUMULATOR, DPTF, SWP¹, ADMIN¹, DPOF, ATS, VST, DISPENSER, CODEX,
PYTHIA, INFO-ONE, DALOS-ADMIN.
**Stage 2** (deploy 00→01→02): DPDC, EQUITY, DPDC-FRAGMENTS, DPDC-S, DPNF, DEMIPAD², DPOF-S2²,
DPSF-UPDATES², AQP, STOAICO, LAUNCHPAD.

¹ SWP/ADMIN preload `[6.2]_DPTF` (+ `[6.3]_SWP` for ADMIN) for their token/pair fixtures.
² DEMIPAD/DPOF-S2/DPSF-UPDATES preload the `[6.1.3]`/`[6.1.4]`/`[6.1.5]` DPDC chain for TSFS/CNF/COF.

## Self-booting harnesses in `REPL/` root (also standalone module testers)

Some paths are covered by pre-existing self-booting drivers in `REPL/` root (they deploy their own
Stage 0/1/2 env + AQP-BOOT, so they are standalone testers already — not folded into ZALL because
they set up their own SubsidiaryTreasury/staker fixtures that aren't boot-composable after
`[6.2]_AQP`):

- **`deb-staleness-proof.repl`** (261) — deb-staleness fix incl. `MTX-AQP -> RPS::XE_FvtFixUserChunk`.
- **`deb-staleness-inject-cc.repl`** (204) — enforced-fresh inject CC-batch.
- **`deb-staleness-sweep-cc.repl`** (222) — anchor re-score sweep CC-batch.
- **`deb-staleness-unstale-all-cc.repl`** — owner mass-unstale CC-batch (slow).
- **`aqp-info-groundtruth.repl`** (411), **`triplet-collect-golden.repl`** (144),
  **`launchpad-groundtruth.repl`** (139) — behavioral/cost ground-truth gates.

These are the module testers for the AQP deb-fix / CC-batch / ground-truth paths that ZALL's
`[6.2]_AQP` umbrella does not carry.

- **`POPULATE-NOSFERATU.repl`** / **`POPULATE-BLOODSHED.repl`** / **`POPULATE-BUNNIES.repl`** — the mass-mint scale fixtures (slow). Each passes green in a fresh boot; they are NOT chained into ZALL because they cross-suite contaminate (DPDC-S nonce/sclass state), which is a test-ordering artifact, not a code bug.

## Adding a new module tester
1. Copy an existing one of the same stage.
2. Point the final `(load "../Stage_0N/[6.x]_<suite>.repl")` at the module's suite.
3. If it fails on a missing token/collection, preload the suite that issues that fixture (its header
   usually says "reuses X from [6.1.n]").
