# Master inventory

_Generated from repository layout scan. Update when files are added or removed._

## Counts (approximate)

| Area | `.pact` files | Notes |
|------|----------------|--------|
| `1_SOVEREIGN/` | 71 | Stage 1 + Stage 2 sovereign |
| `2_SLAVE/` | 10 | AOZ, Dispenser, Bloodshed, Nosferatu, KBunnies, DPL-UR |
| `0_Sample/` | 5 | ModuleSample, snippets |
| `REPL/` | 36 | Staged harness (`Z.repl`, Stage01/02, scenarios) |

## Sovereign layout

```
1_SOVEREIGN/STAGE_01/
  0_Interfaces/     01_Utilities.pact, 02_Core.pact, 03_Talos.pact
  1_Utilities/      U|CT, U|G, U|LST, U|RS, U|ST, U|INT, U|DEC, U|DALOS, U|DPTF, U|VST, U|SWP, U|ATS, U|BFS
  2_Core/           DALOS, DPMF, INFO-ZERO, BRD, DPTF, DPOF, ELITE, TFT, ATS, ATSU, VST, LIQUID, OUROBOROS,
                    IGNIS, SWPT, SWP, SWPI, SWPL, SWPLC, SWPU, MTX-SWP, INFO-ONE
  3_Talos/          TS01-A, TS01-C1, TS01-C2, TS01-C3, TS01-CP (P)

1_SOVEREIGN/STAGE_02/
  0_Interfaces/     02_Core.pact (DPDC family), 03_Talos.pact
  2_Core/
    01_DPDC/        DPDC-UDC, DPDC, DPDC-C, DPDC-I, DPDC-R, DPDC-MNG, DPDC-T, DPDC-S, DPDC-F, DPDC-N, EQUITY+
    02_DEMIPAD/     DEMIPAD, Spark, Snakes, Custodians, StoicPay, STOAICO
    03_AQP/         AQP, AQP-ANK, AQP-SCORE, FVT
    INFO-TWO.pact
  3_Talos/          TS02-C1, TS02-C2, TS02-DPAD, TS02-C3
```

## Slave layout

```
2_SLAVE/
  Stage_01/         01_AOZ+.pact, 02_DSP+.pact
  Stage_02/         01_NOSFERATU, 02_KBunnies, 1_Bloodshed/* (BSD-L, E, R, C, SETS)
  Stage_Z/          01_DPL-UR.pact (unified deployer reads)
```

## Quick links to deep docs

- Module-by-module: [`STAGE_01_MODULES.md`](STAGE_01_MODULES.md), [`STAGE_02_MODULES.md`](STAGE_02_MODULES.md)
- Interface catalogs: [`STAGE_01_INTERFACES.md`](STAGE_01_INTERFACES.md), [`STAGE_02_INTERFACES.md`](STAGE_02_INTERFACES.md)
- Harness: [`REPL_AND_TESTS.md`](REPL_AND_TESTS.md)
