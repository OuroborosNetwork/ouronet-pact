# Vacate pool — UI constructor handoff

Module: **`AQP-VCT`** (`05_VCT.pact`) | Interface: **`AcquisitionVacateV1`** | Talos: **`TS02-C3` `AQP-POOL|*`**

Pool **vacate** is a **forced unstake**: same FVT recipe phases as unstake (`direction=false`), but **pool owner** signs. Tokens always return **vault → owner**. `beneficiary-id` in args is the **tracker / SCORE / ANK / RPS row key**, not a transfer destination.

---

## 1. UI Vacate Engine (canonical construction)

Build **one plan per asset stream**. Class-0 LP farms usually have **two streams** (native TF LP + Z\| OF LP). Other classes have one stream matching `aqp-class`.

```
for each stream with inventory:
  1. READ inventory + unit-count
  2. TRY Full (if soft+hard caps say yes; optional local 2M gas dry-run)
  3. ELSE build Legs batches at VACATE-GAS-MAX-*; verify each batch ≤ ~2M gas;
     shrink batch size and rebuild if a batch fails the gas check
  4. SHOW constructed tx list → user confirms → dump on chain
```

### 1.1 Exact reads (in order)

#### A. Pool identity (once)

| Call | Module | Why |
|------|--------|-----|
| `UR_AQP\|PoolAqpClass pool-id` | `AQP-POOL` | Decide which streams exist (0→TF+OF possible; 1→TF+Z\|/H\|; 2→OF; 3→DPSF; 4→DPNF) |
| `UR_AQP\|PoolAssetId pool-id` | `AQP-POOL` | Canonical asset for the pool |
| `UR_AQP\|PoolStakeEnabled pool-id` | `AQP-POOL` | Observability |
| `UR_VacateInProgress pool-id` | `AQP-VCT` | Mid-vacate resume / abort UI |

**Resolve asset-id(s) for streams:**

| Class | Stream | `asset-id` / `vacate-kind` |
|-------|--------|----------------------------|
| 0 (LP) | TF | `PoolAssetId` (native LP) · kind=`1` |
| 0 (LP) | OF | `DPTF.UR_Sleeping(PoolAssetId)` → Z\| id (skip if `BAR` / empty inventory) · kind=`2` |
| 1 (DPTF) | TF | `PoolAssetId` · kind=`1` |
| 1 (DPTF) | OF satellites | Linked Z\| / H\| DPOF ids (product already knows them; must pass `URC_StakeOrtoFungibleDpofMatchesPool`) · kind=`2` |
| 2 | OF | `PoolAssetId` · kind=`2` |
| 3 | DPSF | `PoolAssetId` · kind=`3` |
| 4 | DPNF | `PoolAssetId` · kind=`4` |

#### B. Inventory (per stream) — **required to construct Legs args**

| Stream | Call | Returns |
|--------|------|---------|
| TF | `AQP-VCT.URD_VacateTfInventory pool-id dptf-id` | `{ legs:[{owner-id, beneficiary-id, balance}], leg-count }` |
| OF | `AQP-VCT.URD_VacateOfInventory pool-id dpof-id` | `{ legs:[{owner-id, beneficiary-id, nonces:[int], amounts:[decimal]}], leg-count }` |
| DPSF | `AQP-VCT.URD_VacateCollectableInventory pool-id dpsf-id true` | same nonce-leg shape |
| DPNF | `AQP-VCT.URD_VacateCollectableInventory pool-id dpnf-id false` | same nonce-leg shape |

Skip a stream when `leg-count = 0`.

Optional raw nonce rows (same data, ungrouped): `URD_VacateOfNonceRows` / `URD_VacateCollectableNonceRows` — UI normally uses the **Inventory** URDs above.

#### C. Sizing helpers (per stream)

| Call | Use |
|------|-----|
| `AQP-VCT.URDC_VacateUnitCountForKind pool-id asset-id vacate-kind` | TF → owner-row count; OF/DPSF/DPNF → **total nonces** (gas unit) |
| `AQP-VCT.UC_ComputeMinSliceCount unit-count vacate-kind` | `ceil(units / VACATE-GAS-MAX-*)`, min 1 → starting **N** for Legs |
| `AQP-VCT.URDC_BuildVacateSlicePlan pool-id asset-id vacate-kind N` | Offline partition → `{ slices:[SlicePayload], slice-count, … }` **no chain writes** |

**Gas ceilings (profiled for ~2M / Legs tx — `[6.2.6]_AQP-VCT-GAS.repl`):**

| Kind | Const | Unit | Max per Legs tx |
|------|-------|------|-----------------|
| TF | `VACATE-GAS-MAX-TF` | owners | **24** |
| OF | `VACATE-GAS-MAX-OF` | nonces | **33** |
| DPSF | `VACATE-GAS-MAX-DPSF` | nonces | **29** |
| DPNF | `VACATE-GAS-MAX-DPNF` | nonces | **30** |

**Full hard caps (on-chain reject if exceeded — still may OOG under 2M before these):**

| Cap | Value | Measures |
|-----|-------|----------|
| `VACATE-FULL-MAX-LEGS` | 128 | owner rows (TF) / owner×ben legs (nonce Full) |
| `VACATE-FULL-MAX-NONCES` | 512 | total nonces across Full OF/collectable |

---

### 1.2 Algorithm — Full first, then Legs with verify/shrink

Pseudo-engine for **one stream**:

```text
inv        = URD_Vacate*Inventory(...)
units      = URDC_VacateUnitCountForKind(...)
if units == 0: done (this stream)

# --- Step 1: try Full ---
fullHardOk = (TF && units <= VACATE-FULL-MAX-LEGS)
          || (nonce-kind && units <= VACATE-FULL-MAX-NONCES
              && leg-count <= VACATE-FULL-MAX-LEGS)

if fullHardOk:
  plan = URDC_BuildVacateSlicePlan(pool-id, asset-id, vacate-kind, 1)
  estimate gas of Talos AQP-POOL|C_FullVacate*(patron, pool-id, asset-id, Legs from plan.slices[0])
  if estimatedGas <= 2_000_000:
    queue single Full tx for this stream
    goto next stream

# --- Step 2: Legs construction loop ---
N = UC_ComputeMinSliceCount(units, vacate-kind)   # starts at ceil(units/GAS-MAX)
repeat:
  plan = URDC_BuildVacateSlicePlan(pool-id, asset-id, vacate-kind, N)
  batches = []
  allFit = true
  for i in 0 .. N-1:
    slice = plan.slices[i]
    tx    = mapSliceToTalosLegs(slice, finalize=(i == N-1))
    gas   = estimateGas(tx)                       # local / dry-run
    show UI: "Leg i+1/N — units=… — gas=… — OK|TOO BIG"
    if gas > 2_000_000:
      allFit = false
      break
    batches.append(tx)
  if allFit:
    queue batches for this stream
    break
  N = N + 1                                       # smaller batches
  # safety: if N > units, fail loudly (unit=1 still OOG → ops/Abort path)
```

**UI should surface** each iteration (N, per-leg unit count, estimated gas, pass/fail) so the operator sees the construction engine working.

**LP / two streams:** run the algorithm independently for TF and for OF. Do **not** merge into one tx. Order is UI choice (usually TF then OF, or largest first). Each stream’s last Legs tx uses `finalize=true` only when **that stream’s** remaining units will be 0 after the batch. Vacate-in-progress is **pool-wide**: first successful Legs/Full on either stream auto-begins; stake re-enables only when a finalize succeeds (asset empty) — if the other stream still has inventory, start/continue that stream before relying on stake being on.

---

### 1.3 How inventory / plan → transaction args

#### Full — Legs payload from `URDC_BuildVacateSlicePlan` with `N=1`

| Stream | Talos |
|--------|-------|
| TF | `AQP-POOL\|C_FullVacateTrueFungible patron pool-id dptf-id owner-ids beneficiary-ids amounts` |
| OF | `AQP-POOL\|C_FullVacateOrtoFungible patron pool-id dpof-id owner-ids beneficiary-ids nonces-array amounts-array` |
| DPSF | `AQP-POOL\|C_FullVacateSemiFungible patron pool-id dpsf-id owner-ids beneficiary-ids nonces-array amounts-array` |
| DPNF | `AQP-POOL\|C_FullVacateNonFungible patron pool-id dpnf-id owner-ids beneficiary-ids nonces-array amounts-array` |

Build with `URDC_BuildVacateSlicePlan pool-id asset-id kind 1`, then pass `slices[0]` fields (OF amounts via `UC_ZeroIntAmountsMatrix`; DPSF/DPNF use `amounts-array` from the slice).

#### Legs — from `URDC_BuildVacateSlicePlan` slice

Each slice is a `VCT|SlicePayload`:

| Field | TF | OF / DPSF / DPNF |
|-------|----|------------------|
| `owner-ids` | yes | yes |
| `beneficiary-ids` | yes | yes |
| `amounts` | yes (decimals = full row balances) | empty |
| `nonces-array` | empty | `[[nonce…], …]` per owner row |
| `amounts-array` | empty | OF: **zero-sentinel ints** via `UC_ZeroIntAmountsMatrix nonces-array`; collectables: floor(balances) ints |

```text
plan  = URDC_BuildVacateSlicePlan pool-id asset-id kind N
slice = (at i (at "slices" plan))
last? = (i == N-1) && (no further Legs for this asset in this dump)

# TF
AQP-POOL|C_VacateTrueFungibleLegs
  patron pool-id dptf-id
  (at "owner-ids" slice)
  (at "beneficiary-ids" slice)
  (at "amounts" slice)
  last?

# OF  (amounts-array = UC_ZeroIntAmountsMatrix (at "nonces-array" slice))
AQP-POOL|C_VacateOrtoFungibleLegs
  patron pool-id dpof-id
  (at "owner-ids" slice)
  (at "beneficiary-ids" slice)
  (at "nonces-array" slice)
  zero-sentinel-amounts-array
  last?

# DPSF / DPNF
AQP-POOL|C_VacateSemiFungibleLegs | C_VacateNonFungibleLegs
  patron pool-id asset-id
  owner-ids beneficiary-ids nonces-array amounts-array
  last?
```

**Manual map without plan helper (same math):** take `inv.legs`, pack consecutive owner-rows so TF owners ≤24 / total nonces ≤ GAS-MAX-*, emit parallel arrays:

- TF: `owner-ids` / `beneficiary-ids` / `amounts` = map of `owner-id` / `beneficiary-id` / `balance`
- Nonce: `owner-ids` / `beneficiary-ids` / `nonces-array` = map of `nonces`; OF amounts → zeros; collectable amounts → `floor` of `amounts`

#### Escape / status

| Call | When |
|------|------|
| `AQP-POOL\|C_AbortVacate patron pool-id` | Abandon mid-vacate; clears `vacate-in-progress`; **stake stays disabled** |
| `AQP-POOL\|C_EnablePoolStake patron pool-id` | Ops re-enable after Abort (or when intentional) |
| Re-read `URD_Vacate*Inventory` + rebuild | After any Legs gas failure / partial dump |

---

### 1.4 On-chain behaviour the UI must assume

1. First successful Full/Legs tx **auto-begins**: stake disabled + `vacate-in-progress=true`.
2. Legs `finalize=false` never re-enables stake.
3. Legs `finalize=true` is a **UI claim** that this batch emptied that asset; XI clears `vacate-in-progress` and re-enables stake (**write-only** — no inventory scan in `C_*` / `XI_*`).
4. Failed Legs leave remaining inventory; UI re-reads and re-splits (e.g. N=8 instead of 7) — **no Job/Slice session**.
5. Vacate is whole-row: TF amount must equal tracker balance; OF whole nonce; collectables full nonce quantity.

---

## 2. Architecture summary

| Variant | When | Talos |
|---------|------|-------|
| **Full** | Stream fits one ~2M tx (+ hard Full caps) | `C_FullVacate*` |
| **Stateless Legs** | Needs N txs | `C_Vacate*Legs(..., finalize)` |

```
UI reads (URD / URDC / UC)
  → construct Full or N× Legs payloads
  → Talos AQP-POOL|C_*
  → AQP-VCT XI_EnsureVacateBegun → XI_Vacate* → XI_MaybeFinalizeVacate
```

**No Job / Slice tables.** Offline plan only.

---

## 3. Capability layering

| Layer | Cap |
|-------|-----|
| Talos | `AQP\|C>FULL-VACATE-*` / `AQP\|C>VACATE-*-LEGS` / `AQP\|C>ABORT-VACATE` |
| VCT recipe | `VCT\|C>FULL-*` / `VCT\|C>LEGS-*` / `VCT\|C>ABORT-VACATE-POOL` |
| Begin/finalize | `XI_EnsureVacateBegun` / `XI_MaybeFinalizeVacate` |
| Unwind | `AQP-FVT` `XE_Run*VacateLeg` (IMC) |

---

## 4. Smoke coverage

| Test | Variant |
|------|---------|
| `[6.2.4]_AQP-FVT-OF.repl` TX-FVT-07 / 08 | Legs / Full OF |
| `[6.2.4]_AQP-FVT-DC.repl` TX-FVT-DC-05 | Legs DPSF |
| `[6.2.5]_AQP-VCT.repl` | Full + Legs + Abort + rejects |
| `[6.2.6]_AQP-VCT-GAS.repl` | Legs gas ceilings |
| `REPL/aqp-deploy-gate.repl` | Z + VCT gate |
