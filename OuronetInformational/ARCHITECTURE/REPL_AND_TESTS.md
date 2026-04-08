# REPL harness and test scenarios

REPL files under **`REPL/`** load sovereign modules in order and run scripted transactions. **They are not** a substitute for on-chain deploy checks; they are a **local harness** for integration smoke tests.

## Top-level loaders

| File | Role |
|------|------|
| `Z.repl` | Full pipeline: Stage 00 sandboxes → Stage 00a Stoa tests → Stage 01 → Stage 02 → Stage ZZ (DPL-UR deploy only) |
| `Stage01_Tester.repl` | Stage 1 deployment + scenario blocks (6.1–6.8) |
| `Stage02_Tester.repl` | Stage 2 deployment + selected scenarios |
| `StageZZ_Tester.repl` | Deploy **`2_SLAVE/Stage_Z/01_DPL-UR.pact`** only (`load` path relative to `REPL/`) |

## Stage 0

| File | Role |
|------|------|
| `Stage00_Sanboxes.repl` | Kadena sandbox + Stoa sandbox bootstrap |
| `Stage00a_StoaTests.repl` | Stoa `coin` regression tests |

## Stage 1 — representative REPL files

| File | Role |
|------|------|
| `[0.0]_Starter.repl` | Starter keys / env |
| `[0.1]_Interfaces.repl` | Load Stage 1 interfaces |
| `[1]_Utilities.repl` | Load utilities |
| `[2.1]_Dalos.repl`, `[2.2]_Core.repl` | Core deploy |
| `[3]_Talos.repl` | Talos deploy |
| `[4.0]_Sovereign-Executor.repl` | Sovereign executor txs |
| `[5.1]_Aoz+.repl`, `[5.2]_Dispenser+.repl` | Slave modules |
| `[6.1]_Cumulator.repl` … `[6.8]_Dispenser.repl` | Long scenario suites (SWP, DPTF, ATS, VST, DPOF, dispenser, etc.) |

## Stage 2 — representative REPL files

| File | Role |
|------|------|
| `[0.1]_Interfaces.repl` | Stage 2 interfaces |
| `[2.1]_DpdcCore.repl` | DPDC family load order |
| `[2.2]_DemiPad.repl` | DemiPad + satellites |
| `[2.3]_EarningPools.repl` | AQP-related |
| `[3]_Talos.repl` | Stage 2 Talos |
| `[4.0]_Sovereign-Executor.repl` | Stage 2 executor |
| `[5.1]`–`[5.4]_Populate*.repl` | Population scenarios |
| `[5.3]_Launchpad.repl` | Launchpad |
| `[6.1]_DPDC.repl`, `[6.2]_AQP.repl`, `[6.3]_STOAICO.repl` | Feature scenarios |

## Notes for documentation

- DPL-UR-dependent reads may be **commented** in some REPLs when DPL-UR is not loaded in that chain.
- **`StageZZ_Tester.repl`** load path for DPL-UR must be **`../2_SLAVE/...`** when CWD is `REPL/` (not `../../`).
