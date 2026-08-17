# Vacate pool — UI constructor handoff

Module: **`AQP-VCT`** (`05_VCT.pact`) | Interface: **`AcquisitionVacateV1`** | Talos: **`TS02-C3` `AQP-POOL|*`**

Pool **vacate** is a **forced unstake**: same FVT recipe phases as unstake (`direction=false`), but **pool owner** signs. Tokens always return **vault → owner**. `beneficiary-id` in args is the **tracker / SCORE / ANK / RPS row key**, not a transfer destination.

> **Rehaul note.** There is **no `finalize` flag** and there are **no UI-supplied Legs for a full vacate**. The two variants are:
> - **Full** (`CC_FullVacate` / `XB_Vacate*`): input is **just the pool-id** (+ asset-id for the per-stream `XB_` forms). VCT scans the pool inventory **on-chain**, drains it, and auto begin+finalize.
> - **Batch** (`CC_BatchVacate*`): the UI splits inventory into disjoint gas-safe slices and fires N txs. The **first** batch auto-begins (freezes); the batch that **empties the pool** auto-finalizes. No UI "finalize" claim — the chain decides via `URC_PoolFullyVacated`.

---

## 1. UI Vacate Engine (canonical construction)

Class-0 LP farms usually have **two streams** (native TF LP + Z\| OF LP); other classes have one stream matching `aqp-class`. For a **Full** vacate the streams are handled for you on-chain (`CC_FullVacate` walks every stream); you only build **per-stream** slices when the pool is too large to empty in one tx and you fall back to **Batch**.

```
1. READ pool class + per-stream inventory + unit-count
2. TRY Full: if the whole pool empties in one ~2M-gas tx → CC_FullVacate(pool-id)   (or XB_Vacate* per stream)
3. ELSE Batch: per stream, slice inventory at VACATE-GAS-MAX-*; build N disjoint
   CC_BatchVacate* txs (each ≤ ~2M gas); shrink slice size and rebuild on gas fail
4. SHOW constructed tx list → user confirms → dump ALL txs on chain (parallel is fine)
```

### 1.1 Exact reads (in order)

#### A. Pool identity (once)

| Call | Module | Why |
|------|--------|-----|
| `UR_AQP\|PoolAqpClass pool-id` | `AQP-POOL` | Decide which streams exist (0→TF+OF possible; 1→TF+Z\|/H\|; 2→OF; 3→DPSF; 4→DPNF) |
| `UR_AQP\|PoolAssetId pool-id` | `AQP-POOL` | Canonical asset for the pool |
| `UR_AQP\|PoolStakeEnabled pool-id` | `AQP-POOL` | Observability |
| `UR_VacateInProgress pool-id` | `AQP-VCT` | Mid-vacate resume / abort UI |

**Resolve asset-id(s) for streams** (only needed for the per-stream `XB_`/`CC_BatchVacate*` forms; `CC_FullVacate` derives them on-chain):

| Class | Stream | `asset-id` / `vacate-kind` |
|-------|--------|----------------------------|
| 0 (LP) | TF | `PoolAssetId` (native LP) · kind=`1` |
| 0 (LP) | OF | `DPTF.UR_Sleeping(PoolAssetId)` → Z\| id (skip if `BAR` / empty inventory) · kind=`2` |
| 1 (DPTF) | TF | `PoolAssetId` · kind=`1` |
| 1 (DPTF) | OF satellites | Linked Z\| / H\| DPOF ids (product already knows them; must pass `URC_StakeOrtoFungibleDpofMatchesPool`) · kind=`2` |
| 2 | OF | `PoolAssetId` · kind=`2` |
| 3 | DPSF | `PoolAssetId` · kind=`3` |
| 4 | DPNF | `PoolAssetId` · kind=`4` |

#### B. Inventory (per stream) — **required to construct Batch args**

| Stream | Call | Returns |
|--------|------|---------|
| TF | `AQP-VCT.URD_VacateTfInventory pool-id dptf-id` | `{ legs:[{owner-id, beneficiary-id, balance}], leg-count }` |
| OF | `AQP-VCT.URD_VacateOfInventory pool-id dpof-id` | `{ legs:[{owner-id, beneficiary-id, nonces:[int], amounts:[decimal]}], leg-count }` |
| DPSF | `AQP-VCT.URD_VacateCollectableInventory pool-id dpsf-id true` | same nonce-leg shape |
| DPNF | `AQP-VCT.URD_VacateCollectableInventory pool-id dpnf-id false` | same nonce-leg shape |

Skip a stream when `leg-count = 0`. (`CC_FullVacate` no-ops empty streams on-chain — an already-empty pool is a clean no-op.)

Optional raw nonce rows (same data, ungrouped): `URD_VacateOfNonceRows` / `URD_VacateCollectableNonceRows` — UI normally uses the **Inventory** URDs above.

#### C. Sizing helpers (per stream — Batch only)

| Call | Use |
|------|-----|
| `AQP-VCT.URDC_VacateUnitCountForKind pool-id asset-id vacate-kind` | TF → owner-row count; OF/DPSF/DPNF → **total nonces** (gas unit) |
| `AQP-VCT.UC_ComputeMinSliceCount unit-count vacate-kind` | `ceil(units / VACATE-GAS-MAX-*)`, min 1 → starting **N** for Batch |
| `AQP-VCT.URDC_BuildVacateSlicePlan pool-id asset-id vacate-kind N` | Offline partition → `{ slices:[SlicePayload], slice-count, … }` **no chain writes** |

**Gas ceilings (profiled for ~2M per batch tx — `[6.2.6]_AQP-VCT-GAS.repl`):**

| Kind | Const | Unit | Max per batch tx |
|------|-------|------|------------------|
| TF | `VACATE-GAS-MAX-TF` | owners | **24** |
| OF | `VACATE-GAS-MAX-OF` | nonces | **33** |
| DPSF | `VACATE-GAS-MAX-DPSF` | nonces | **29** |
| DPNF | `VACATE-GAS-MAX-DPNF` | nonces | **30** |

---

### 1.2 Algorithm — Full first, then Batch with verify/shrink

```text
# --- Step 1: try Full (whole pool, one tx) ---
# CC_FullVacate walks EVERY stream on-chain. Prefer it when the pool is small enough
# that all streams together empty inside one ~2M-gas tx (estimate from total unit counts).
if wholePoolFitsOneTx:
  queue  AQP-POOL|CC_FullVacate(patron, pool-id)         # pool-id ONLY; no arrays
  done
# (Per-stream Full alternative: XB_VacateTrueFungible(pool-id) /
#  XB_VacateOrtoFungible(pool-id,dpof-id) / XB_VacateSemiFungible / XB_VacateNonFungible.)

# --- Step 2: Batch construction loop, per stream ---
for each stream with inventory:
  units = URDC_VacateUnitCountForKind(...)
  if units == 0: continue
  N = UC_ComputeMinSliceCount(units, vacate-kind)        # ceil(units / GAS-MAX)
  repeat:
    plan = URDC_BuildVacateSlicePlan(pool-id, asset-id, vacate-kind, N)
    txs, allFit = [], true
    for i in 0 .. N-1:
      slice = plan.slices[i]
      tx    = mapSliceToBatchCall(slice)                 # NO finalize arg
      gas   = estimateGas(tx)
      show UI: "Batch i+1/N — units=… — gas=… — OK|TOO BIG"
      if gas > 2_000_000: allFit = false; break
      txs.append(tx)
    if allFit: queue txs; break
    N = N + 1                                            # smaller slices
    # safety: if N > units, fail loudly (unit=1 still OOG → ops/Abort path)
```

**Serial execution (Chainweb).** Txs integrate into blocks **one at a time**; "parallel" only means the UI can submit all batch txs to the mempool at once. Because execution is serial there are **no write conflicts** between batches, so slices may be split by beneficiary and drained incrementally, and first/last detection is safe. The **emptying** batch (the one after which every employed score has `nzs==0`) auto-finalizes and re-enables stake — regardless of submission order.

**LP / two streams:** build a batch plan **independently** for TF and for OF. Vacate-in-progress is **pool-wide**: the first successful batch on either stream auto-begins (freezes); stake re-enables only when the **whole pool** is empty (`URC_PoolFullyVacated` counts both streams via the shared score `nzs`). Prefer `CC_FullVacate` when it fits — it handles both streams in one tx.

---

### 1.3 How inventory / plan → transaction args

#### Full — **no arrays** (on-chain scan)

| Scope | Talos |
|-------|-------|
| Whole pool (any class) | `AQP-POOL\|CC_FullVacate patron pool-id` |
| TF stream only | `AQP-POOL\|XB_VacateTrueFungible patron pool-id` |
| One OF asset | `AQP-POOL\|XB_VacateOrtoFungible patron pool-id dpof-id` |
| DPSF collection | `AQP-POOL\|XB_VacateSemiFungible patron pool-id dpsf-id` |
| DPNF collection | `AQP-POOL\|XB_VacateNonFungible patron pool-id dpnf-id` |

#### Batch — one `URDC_BuildVacateSlicePlan` slice per tx (**no `finalize`**)

Each slice is a `VCT|SlicePayload`:

| Field | TF | OF | DPSF / DPNF |
|-------|----|----|-------------|
| `owner-ids` | yes | yes | yes |
| `beneficiary-ids` | yes | yes | yes |
| `amounts` | yes (decimals = full row balances) | — (unused) | — (unused) |
| `nonces-array` | — | `[[nonce…], …]` per owner row | `[[nonce…], …]` |
| `amounts-array` | — | — (resolved on-chain) | `floor(balances)` ints |

```text
plan  = URDC_BuildVacateSlicePlan pool-id asset-id kind N
slice = (at i (at "slices" plan))

# TF — per-leg amount MUST equal the live tracker balance (URC_VacateTfLegBalancesOk)
AQP-POOL|CC_BatchVacateTrueFungible
  patron pool-id dptf-id
  (at "owner-ids" slice) (at "beneficiary-ids" slice) (at "amounts" slice)

# OF — whole-nonce; amounts resolved on-chain from the tracker (UI passes NO amounts)
AQP-POOL|CC_BatchVacateOrtoFungible
  patron pool-id dpof-id
  (at "owner-ids" slice) (at "beneficiary-ids" slice) (at "nonces-array" slice)

# DPSF (son=true) / DPNF (son=false)
AQP-POOL|CC_BatchVacateCollectables
  patron pool-id collectable-id son
  (at "owner-ids" slice) (at "beneficiary-ids" slice)
  (at "nonces-array" slice) (at "amounts-array" slice)
```

**Manual map without the plan helper (same math):** take `inv.legs`, pack consecutive owner-rows so TF owners ≤24 / total nonces ≤ GAS-MAX-*, emit parallel arrays:

- TF: `owner-ids` / `beneficiary-ids` / `amounts` = map of `owner-id` / `beneficiary-id` / `balance`
- OF: `owner-ids` / `beneficiary-ids` / `nonces-array` = map of `nonces` (no amounts — resolved on-chain)
- Collectable: add `amounts-array` = `floor` of `amounts`

#### Escape / status

| Call | When |
|------|------|
| `AQP-POOL\|C_AbortVacate patron pool-id` | Abandon mid-campaign; clears `vacate-in-progress`; **stake stays disabled** |
| `AQP-POOL\|C_EnablePoolStake patron pool-id` | Ops re-enable after Abort (or when intentional) |
| Re-read `URD_Vacate*Inventory` + rebuild | After any batch gas failure / partial dump |

---

### 1.4 On-chain behaviour the UI must assume

1. First successful Full/Batch tx **auto-begins**: stake **and unstake** disabled + `vacate-in-progress=true`, and **collect + inject are frozen** on the pool's ≤7 employed-score FVTs (`vacate-frozen`).
2. There is **no finalize flag**. A batch that leaves inventory keeps the campaign open (VIP stays `true`, stake stays disabled). The batch that empties the **whole pool** (`URC_PoolFullyVacated` — every employed score `nzs==0`) auto-finalizes: clears `vacate-in-progress`, unfreezes the FVTs, re-enables stake.
3. Empty/oversized batches are **rejected** by the batch cap (`gas-ok` requires a positive, ≤GAS-MAX leg/nonce count).
4. TF per-leg `amounts` must equal the tracker balance (`URC_VacateTfLegBalancesOk`); OF is whole-nonce (amounts resolved on-chain); collectables use full nonce quantity.
5. Failed batches leave remaining inventory; UI re-reads and re-splits (e.g. N=8 instead of 7) — **no Job/Slice session**.

---

## 2. Architecture summary

| Variant | When | Talos |
|---------|------|-------|
| **Full (agnostic)** | Whole pool empties in one ~2M tx | `CC_FullVacate(pool-id)` |
| **Full (per stream)** | One stream, one tx | `XB_Vacate{TrueFungible,OrtoFungible,SemiFungible,NonFungible}` |
| **Batch** | Pool too large for one tx | `CC_BatchVacate{TrueFungible,OrtoFungible,Collectables}` |

```
UI reads (URD / URDC / UC)
  → Full: CC_FullVacate(pool-id) / XB_Vacate*(pool-id[,asset])   (VCT scans on-chain)
  → Batch: construct N× CC_BatchVacate* slices
  → Talos AQP-POOL|*
  → AQP-VCT XI_EnsureVacateBegun (freeze) → XI_Vacate* → XI_MaybeFinalizeVacate (auto on drain)
```

**No Job / Slice tables.** Offline plan only.

---

## 3. Capability layering

| Layer | Cap |
|-------|-----|
| Talos | `CC_FullVacate` / `XB_Vacate*` / `CC_BatchVacate*` compose `P\|TS`; `AQP\|C>ABORT-VACATE` for abort |
| VCT recipe | `VCT\|C>VACATE` (agnostic master) · `VCT\|C>LEGS-*-VACATE` (batch) · `VCT\|C>ABORT-VACATE-POOL` |
| Begin/finalize | `XI_EnsureVacateBegun` (freeze) / `XI_MaybeFinalizeVacate` (auto-unfreeze on drain) |
| Unwind | `AQP-FVT` `XE_Run*VacateLeg` (IMC); FVT freeze via `FVT::XE_SetFvtVacateFrozen` |

---

## 4. Smoke coverage

| Test | Variant |
|------|---------|
| `[6.2.4]_AQP-FVT-OF.repl` TX-FVT-07 / 08 | `CC_BatchVacateOrtoFungible` / `CC_FullVacate` |
| `[6.2.4]_AQP-FVT-DC.repl` TX-FVT-DC-04 / 05 | `CC_FullVacate` / `CC_BatchVacateCollectables` |
| `[6.2.5]_AQP-VCT.repl` | `CC_FullVacate` + `XB_Vacate*` + `CC_BatchVacate*` (multi-batch, partial, split-beneficiary) + Abort + rejects |
| `[6.2.6]_AQP-VCT-GAS.repl` | `CC_BatchVacate*` chunk-gas ceilings |
| `REPL/aqp-deploy-gate.repl` | Z + VCT gate |
