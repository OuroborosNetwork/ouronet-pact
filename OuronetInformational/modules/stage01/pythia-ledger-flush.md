# PYTHIA ledger batch flush (Stage 01)

**Module:** `ouronet-ns.PYTHIA` (`23_PYTHIA.pact`)  
**Interface:** `PythiaLedgerV2` (ships in deploy file; not yet on chain)  
**Talos:** `TS01-C4.PYTHIA|A_Flush` via `TalosStageOne_ClientFourV7` (`06_TS01-C4.pact`)

Khronoton handoff: [`HANDOFF-pythia-khronoton-flush.md`](../../HANDOFF-pythia-khronoton-flush.md)  
Table/read spec: [`HANDOFF-pact-pyth-ledger.md`](../../HANDOFF-pact-pyth-ledger.md)

---

## Batch API

```pact
(defun A_Flush:string (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
```

Each `PythFlushEntry`:

```pact
{ day: integer              ; UTC ordinal since PYTHIA|LEDGER-EPOCH-START
, iz-complete: bool        ; false = open day; true = seal after this flush
, petitions: integer
, pondus: decimal          ; ≤3 dp
, transactions: integer
, gas-reserved: integer
, failed-transactions: integer
, wasted-gas-reserved: integer
}
```

Metrics are **cumulative for that UTC day**, not deltas.

---

## Layering (follow x-function-guards)

| Layer | Function | Role |
|-------|----------|------|
| Cap | `PYTHIA\|A>FLUSH` | empty check, batch length, `(enforce (UEV_FlushEntries entries) …)`, compose CRONOTON + SECURE |
| UEV | `UEV_FlushEntries` | Single fold: per-entry field bounds, pondus dp, sealed-ok; pure bool |
| A | `A_Flush` | `(with-capability (PYTHIA\|A>FLUSH entries) (XI_FlushPythLedger entries))` |
| XI | `XI_FlushPythLedger` | tier 0 — fold `XI_1|ApplyOneFlushEntry`; commit `WW_PythTotal` once |
| XI | `XI_1|ApplyOneFlushEntry` | tier 1 — insert or update via `WI_`/`WU_`; **no enforce** |
| UR | `UR_PythDailyExists` | `try false (UR_PythDay day)` then `true` — never `(keys …)` in validation |

**Never** put `enforce` or `UEV_*` calls inside `XI_*`. Sealed-day rejection belongs in `UEV_FlushEntries`, evaluated from the cap.

---

## Existence checks without `keys`

```pact
(defun UR_PythDailyExists:bool (day:integer)
  (try
    false
    (let ((row:object{…} (UR_PythDay day)))
      true)))
```

`(keys …)` is for `URD_*` scans only. Using it inside cap-time validation is expensive and may fail in read-only/guard modes.

---

## Order independence

- Each tx processes a disjoint set of `day` ordinals.
- Update path: `total := total − oldDayMetrics + newDayMetrics`.
- `last-day := max(last-day, day)` per entry.
- Sharded txs may land in any order when day sets do not overlap.

---

## Gas constants

```pact
(defconst PYTHIA|MAX-FLUSH-BATCH:integer 1000)    ; policy cap
(defconst PYTHIA|FLUSH-GAS-TARGET:integer 2000000)
```

Export: `UR_PythMaxFlushBatch`, `UR_PythLedgerEpochStart`, `UR_PythCurrentDay`.

Probe: `REPL/Stage_01/[6.10]_PYTHIA-flush-gas-probe.repl`.  
Memory: [`memories/2026-07-21-pythia-flush-batch-gas.md`](../../memories/2026-07-21-pythia-flush-batch-gas.md).

---

## Interface versioning

| Name | Location | Status |
|------|----------|--------|
| `PythiaLedgerV1` | `02_Core.pact` | Frozen — insert-only, caller passes day + flushed-at |
| `PythiaLedgerV2BlockTime` | `02_Core.pact` | Frozen — never deployed; single six-metric block-time flush |
| **`PythiaLedgerV2`** | **`23_PYTHIA.pact`** | **Deploy target — batch entries** |
| `TalosStageOne_ClientFourV6BlockTime` | `03_Talos.pact` | Frozen — never deployed; single-metric A_Flush |
| `TalosStageOne_ClientFourV6` | `06_TS01-C4.pact` (prior) | Superseded — patron A_RevokeLink (IGNIS) |
| **`TalosStageOne_ClientFourV7`** | **`06_TS01-C4.pact`** | **Deploy target — patronless A_RevokeLink** |
