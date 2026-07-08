# Vacate pool — UI constructor handoff

Module: **`AQP-VCT`** (`05_VCT.pact`) | Interface: **`AcquisitionVacateV1`**

Pool **vacate** is a **forced unstake**: same FVT recipe phases as `C_*StakeFlow` with `direction=false`, but **pool owner** signs instead of the depositor.

**Transfer:** always **vault → owner** (depositor gets tokens back). Vacate has nothing to do with sending assets to the beneficiary.

**Beneficiary-id in args:** not a transfer destination. It is the **tracker row key** used in phases 1.2–5 to unwind **SCORE**, **ANK**, and **FVT RPS** — same as unstake.

---

## Architecture — two variants

Pick **one variant per pool × asset stream** (e.g. LP class-0 may need two streams: TF + OF).

| Variant | When to use | On-chain state | Talos client |
|---------|-------------|----------------|--------------|
| **Full** | Inventory fits one-tx gas | None (URD read inside `C_FullVacate*`) | **Yes** — `C_FullVacate*` |
| **Sliced session** | Multi-tx; UI needs crash recovery or gas tuning via `slice-count` / `C_ResliceVacate` | `VCT|T|Job` + hash-only `VCT|T|Slice` rows | **Yes** — `C_BeginVacate` + `C_VacateChunk*` |

```
Talos AQP-POOL|C_FullVacate* / C_BeginVacate / C_VacateChunk*
        → AQP-VCT::C_FullVacate* / C_BeginVacate / C_VacateChunk*
        → XI_Vacate* atomics (require P|VCT|RECIPE)
        → TFT / DPOF / DPDC-T bulk transfer
        → FVT::XE_Run*VacateLeg (phases 2–5)
```

Atomic execution is **`XI_Vacate*`** (not public). Full and chunk entry points compose **`VCT|C>*VACATE*`** caps for per-owner validation, then call `XI_*`.

**Session handle:** all chunk / reslice / abort txs use **`vacate-job-id`** (minted at Begin). One active job per pool at a time.

---

## Whole-row rules (vacate vs unstake)

| Asset | Stake / unstake | Vacate |
|-------|-----------------|--------|
| DPTF (TF) | partial amount OK | **full DPTFTracker row** per owner row (`amount = balance`) |
| DPOF (OF) | whole nonce only | **whole nonce only** |
| DPSF / DPNF | partial quantity per nonce OK | **full tracker row per nonce** |

---

## Variant 1 — Full vacate (one tx)

Recipe reads `AQP-POOL.URD_AQP|Vacate*Inventory` on-chain, bulk-transfers, unwinds all owners in one tx.

| Asset | Talos |
|-------|-------|
| DPTF | `AQP-POOL\|C_FullVacateTrueFungible patron pool-id dptf-id` |
| DPOF | `AQP-POOL\|C_FullVacateOrtoFungible patron pool-id dpof-id` |
| DPSF | `AQP-POOL\|C_FullVacateSemiFungible patron pool-id dpsf-id` |
| DPNF | `AQP-POOL\|C_FullVacateNonFungible patron pool-id dpnf-id` |

**UI:** if `(at "leg-count" (AQP-POOL.URD_AQP|Vacate*Inventory ...))` exceeds full gas envelope → use sliced session.

---

## Variant 2 — Sliced session (multi-tx)

On-chain: **`VCT|T|Job`** keyed by `vacate-job-id`; **`VCT|T|Slice`** keyed by `vacate-job-id|slice-idx` stores **`slice-hash`** + **`processed`** only — **no payload on-chain**.

Slice payloads live in **Begin/Reslice OC output** + off-chain storage. Chunk txs hash-verify submitted arrays against stored hashes.

UI chooses target **`slice-count`** (number of txs); chain computes **`owners-per-slice = ceil(owner_count / slice-count)`** (inventory field **`leg-count`** until AQP rename).

### Planning reads (AQP-POOL inventory — one URD per stream)

| Asset class | Pre-flight URD | Returns |
|-------------|----------------|---------|
| DPTF | `AQP-POOL.URD_AQP\|VacateTfInventory pool-id dptf-id` | `object{AQP\|VacateTfInventory}` — `legs` + `leg-count` |
| DPOF | `AQP-POOL.URD_AQP\|VacateOfInventory pool-id dpof-id` | `object{AQP\|VacateNonceLegInventory}` — `legs` + `leg-count` |
| DPSF | `AQP-POOL.URD_AQP\|VacateCollectableInventory pool-id dpsf-id true` | `object{AQP\|VacateNonceLegInventory}` |
| DPNF | `AQP-POOL.URD_AQP\|VacateCollectableInventory pool-id dpnf-id false` | `object{AQP\|VacateNonceLegInventory}` |

**Minimum slices:** `AQP-VCT.UC_ComputeMinSliceCount unit-count vacate-kind` — `ceil(units / VACATE-GAS-MAX-*)`, min 1. Use `AQP-VCT.URDC_VacateUnitCountForKind` for `unit-count` (TF = owner count; OF/DPSF/DPNF = total nonces).

**Gas ceilings per chunk tx (2M gas — profiled REPL `[6.2.6]_AQP-VCT-GAS.repl`):**

| Kind | `VACATE-GAS-MAX-*` measures | Profiled ~gas/unit |
|------|----------------------------|-------------------|
| **DPTF (TF)** | Unique **owners** (custody recipients; parallel beneficiary per row) | ~72k / owner |
| **DPOF (OF)** | **Total nonces** across all owner rows | ~53k / nonce |
| **DPSF** | **Total nonces** across all owner rows | ~57k / nonce |
| **DPNF** | **Total nonces** across all owner rows | ~58k / nonce |

Seven owners with 800 nonces can exceed the limit in one chunk even though owner count is low — gas scales with **nonce count**, not owner count. Inventory rows group nonces by `(owner-id, beneficiary-id)`; `URDC_BuildVacateSlicePlan` splits any row exceeding the per-chunk nonce cap before slicing.

```pact
VACATE-GAS-MAX-TF   = 24    ; max owners per chunk
VACATE-GAS-MAX-OF   = 33    ; max total nonces per chunk
VACATE-GAS-MAX-DPSF = 29
VACATE-GAS-MAX-DPNF = 30
```

Separate from gas: `AQP-POOL.VACATE-MAX-NONCES` (64) is a structural batch cap on `URC_VacateBatchNonceTotalOk`.

Run `cd REPL && pact VCT-gas-sweep.repl` and grep `<<VCT-GAS-*>>` for fresh numbers (probes use 1 nonce/owner; values are max **nonces** for collectables).

**Preflight plan (off-chain mirror):** `AQP-VCT.URDC_BuildVacateSlicePlan pool-id asset-id vacate-kind slice-count` → `object{VCT|VacateSlicePlan}` with `slices:[object]`.

### Session flow

| Step | Function | Role |
|------|----------|------|
| 1 | `AQP-VCT.C_BeginVacate` | Mint `vacate-job-id`; write hash-only slice rows; disable stake; return slice-plan OC |
| 2+ | `AQP-VCT.C_VacateChunk*` | Payload must match `slice-hash`; runs `AQP-VCT.XI_Vacate*`; marks slice processed |
| optional | `AQP-VCT.C_ResliceVacate` | Old job `resliced=true`; mint **new** `vacate-job-id`; rebuild from live inventory |
| auto | `AQP-VCT.XI_FinalizeVacateIfComplete` | Last chunk: finalize job, clear pool vacate state, **re-enable stake** |
| escape | `AQP-VCT.C_AbortVacate` | Job `aborted=true`; clear vacate state; **stake stays disabled** |

**Job terminal states (mutually exclusive):** `finalized`, `aborted`, `resliced` — active = none set.

**`vacate-kind`:** `1=TF`, `2=OF`, `3=DPSF`, `4=DPNF` — collectable `son` is implied by kind (DPSF→true, DPNF→false).

### Building chunk payloads

```text
;; After Begin — read handle from OC or chain:
active  = AQP-VCT.URDC_ActiveJobForPool pool-id
job-id  = (at "vacate-job-id" active)

;; Slice payload (same shape Begin hashed):
plan    = AQP-VCT.URDC_BuildVacateSlicePlan pool-id asset-id vacate-kind slice-count
slice0  = (at 0 (at "slices" plan))

;; TF chunk:
submit Talos AQP-POOL|C_VacateChunkTrueFungible patron job-id slice-idx owner-ids beneficiary-ids amounts

;; OF / DPSF / DPNF chunk (unified sovereign C_VacateChunkNonce):
submit Talos AQP-POOL|C_VacateChunkNonce patron job-id slice-idx owner-ids beneficiary-ids nonces-array amounts-array
;; OF: amounts-array = zero sentinel parallel to nonces (Talos C_VacateChunkOrtoFungible builds this)
```

**Slice verification:** `VCT|T|Slice.slice-hash` is **Blake2b** via Pact `(hash object{…})` — canonical `VCT|TfSlicePayload` or `VCT|NonceSlicePayload`. Chunk tx recomputes hash from submitted arrays and enforces equality.

### Recovery reads

- `AQP-VCT.UR_Job vacate-job-id`
- `AQP-VCT.URD_SlicesForJob vacate-job-id` — hash + processed per slice
- `AQP-VCT.URDC_ActiveJobForPool pool-id` — active job while session open

**Pool observability:** `AQP-POOL.UR_AQP|VacateInProgress`, `AQP-POOL.UR_AQP|InitialVacateHash`, `AQP-POOL.UR_AQP|PhaseVacateHash`, `AQP-POOL.UR_AQP|LastVacateHash`.

### Talos session surface

| Talos entry | Sovereign target |
|-------------|------------------|
| `C_BeginVacate` | `AQP-VCT::C_BeginVacate` |
| `C_ResliceVacate patron vacate-job-id slice-count` | `AQP-VCT::C_ResliceVacate` |
| `C_VacateChunkTrueFungible patron vacate-job-id …` | `AQP-VCT::C_VacateChunkTrueFungible` |
| `C_VacateChunkNonce patron vacate-job-id …` | `AQP-VCT::C_VacateChunkNonce` |
| `C_VacateChunkOrtoFungible patron vacate-job-id …` | → `C_VacateChunkNonce` (zero-sentinel amounts) |
| `C_VacateChunkCollectable patron vacate-job-id …` | → `C_VacateChunkNonce` |
| `C_AbortVacate patron vacate-job-id` | `AQP-VCT::C_AbortVacate` |

---

## LP pools (aqp-class 0)

Two **independent** streams when both TF and OF inventory exist — plan and complete both separately.

---

## Capability layering

| Layer | Module | Cap |
|-------|--------|-----|
| Client shell | Talos `TS02-C3` | `AQP\|C>FULL-VACATE-*` / `AQP\|C>BEGIN-VACATE` / `AQP\|C>VACATE-CHUNK-*` (`@event`, `P\|TS` only) |
| Master recipe | `AQP-VCT` | `VCT\|C>*` — one `@event` cap per `C_*`; all validation + `SECURE` (+ nested atomic caps for custody) |
| Atomic vacate | `AQP-VCT` | `VCT\|C>TRUE-FUNGIBLE-VACATE` / `…-BATCH` → composes **`P\|VCT\|RECIPE`** |
| Table writers | `AQP-VCT` | `XI_*` → `XI_1|*` → `XI_2|*` — each tier **`require-capability (SECURE)`** from master `VCT\|C>*` |
| Leg unwind | `AQP-FVT` | `XE_Run*VacateLeg` (IMC from VCT) |

---

## Smoke coverage

| Test | Variant | Asset |
|------|---------|-------|
| `REPL/Stage_02/OF-stake-smoke.repl` TX-FVT-07 | Session (slice-count 1) | OF |
| `REPL/Stage_02/OF-stake-smoke.repl` TX-FVT-08 | Full | OF |
| `REPL/Stage_02/[6.2.4]_AQP-FVT-DC.repl` TX-FVT-DC-05 | Session (slice-count 1) | DPSF |
