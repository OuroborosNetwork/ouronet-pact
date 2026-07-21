# Memory: Pythia ledger batch flush — gas optimization (2026-07-21)

## Context

`PYTHIA.A_Flush` accepts a batch of calendar-day entries (`PythFlushEntry[]`). Khronoton may shard large backlogs across multiple txs; entries must be order-independent.

**Deploy interfaces (not yet on chain):** `PythiaLedgerV2` in `23_PYTHIA.pact`, `TalosStageOne_ClientFourV6` in `06_TS01-C4.pact`.

## Gas probe results (`REPL/Stage_01/[6.10]_PYTHIA-flush-gas-probe.repl`)

| Path | Gas/day (approx) | Notes |
|------|------------------|-------|
| Insert (new rows) | ~103 | N=1000 → 103,167 gas |
| Update (replace open day) | ~185 | N=10000 → 1,846,022 gas |
| Seal (update + `iz-sealed`) | ~217 | N=9234 → 1,999,897 gas |

**Policy cap:** `PYTHIA|MAX-FLUSH-BATCH = 1000` (~103k–217k gas per tx; avoids long flush intervals during backlog).

**Theoretical 2M ceiling:** ~9,234 entries (sealing path).

## What caused ~80k/day (pre-optimization)

1. `(keys PYTHIA|T|PythDaily)` inside `UR_PythDailyExists` — table enumeration per entry; also disallowed in some cap/guard modes.
2. Per-entry `enforce` via `map UEV_FlushEntry` in the cap guard instead of one batch fold.
3. Double reads during validation before any write.

## Fixes applied

1. **`UR_PythDailyExists`:** `try` + single `read` instead of `(keys ...)`.
2. **Batch validation:** single `UEV_FlushEntries` (fold with inline per-entry checks) + one `(enforce (UEV_FlushEntries entries) …)` in `PYTHIA|A>FLUSH`.
3. **Sealed-day check:** inside `UEV_FlushEntries` fold via `UR_PythDailyExists` + `UR_PythDay` — **not** in `XI_*` (see convention below).

## Convention lesson: validation stays in caps, not X_

**Wrong:** `(enforce (= (at "iz-sealed" old-row) false) …)` inside `XI_1|ApplyOneFlushEntry`.

**Right:** sealed-ok check inside `UEV_FlushEntries`; cap calls `(enforce (UEV_FlushEntries entries) …)`. `XI_*` only orchestrates `W_*` writes.

See `ouronet/conventions/x-function-guards.md` and `modules/stage01/pythia-ledger-flush.md`.

## REPL

- Integration: `REPL/Stage_01/[6.10]_PYTHIA.repl` + `[6.10b]_PYTHIA-ledger-v2.repl`
- Gas probe: `REPL/Stage_01/[6.10]_PYTHIA-flush-gas-probe.repl`
- Smoke: `REPL/_smoke_pythia_ledger.repl`
