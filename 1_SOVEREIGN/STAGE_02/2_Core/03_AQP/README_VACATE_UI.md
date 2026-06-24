# Vacate pool — UI multi-tx constructor handoff

Pool **vacate** is a **forced unstake**: same FVT recipe phases as `C_*StakeFlow` with `direction=false`, but **pool owner** signs (`CAP_PoolOwner`) instead of the depositor (`CAP_StakeOwner`).

**Transfer:** always **vault → owner** (depositor gets tokens back). Vacate has nothing to do with sending assets to the beneficiary.

**Beneficiary-id in args:** not a transfer destination. It is the **tracker row key** used in phases 1.2–5 to unwind **SCORE** (deb/base/nzs), **ANK** promile rollups, and **FVT RPS** — same as unstake, except the pool owner signs instead of the owner.

## Collectable vacate (Talos surface)

**FVT** implements one sovereign recipe: `C_VacateCollectableBatch` (`son` dispatches DPSF vs DPNF). Talos does **not** expose a multi-leg batch shell.

| Talos entry | Use for |
|-------------|---------|
| `C_VacateSemiFungibleCollectable` | **All** class-3 DPSF vacate txs |
| `C_VacateNonFungibleCollectable` | **All** class-4 DPNF vacate txs (incl. Bloodshed) |

Each Talos call → FVT batch with one owner group. For many owners, the UI submits **many txs** (order irrelevant). For one owner with many nonces, chunk `nonces` / `nonce-amounts` to `≤ VACATE-MAX-NONCES` per tx.

## LP pools (aqp-class 0) — two independent vacate streams

Class **0** LP pools accept **both** DPTF legs (native / frozen LP) **and** DPOF legs (sleeping `Z|` orto). Trackers are separate tables:

| Asset | Tracker table | Talos entry (single leg) | Talos entry (batch) |
|-------|---------------|--------------------------|---------------------|
| DPTF | `AQP\|T\|DPTFTracker` | `AQP-POOL\|C_VacateTrueFungible` | one tx per `(owner, beneficiary, dptf-id, amount)` |
| DPOF | `AQP\|T\|DPOFTracker` | — | `AQP-POOL\|C_VacateOrtoFungibleBatch` |

**The UI constructor must plan vacate txs for both streams** when an LP pool has staked TF **and** OF inventory. Order of txs does not matter. Do **not** use a single “vacate whole pool” call — there is no on-chain enumerator.

Class **1** (DPTF-only): TF vacate only.  
Class **2** (DPOF-only): OF batch vacate only.  
Class **3** (DPSF): collectable vacate (`son=true`).  
Class **4** (DPNF): collectable vacate (`son=false`) — Bloodshed-scale batching.

## Capability layering (matches stake)

| Layer | Module | Cap | `@event`? |
|-------|--------|-----|-----------|
| Client shell | Talos `TS02-C3` | `AQP\|C>VACATE-*` | **Yes** — composes `P\|TS` only |
| Recipe | `AQP-FVT` | `FVT\|C>*VACATE*` | No — `UEV_IMC` + validation + `SECURE` |
| Phase 1 custody | `AQP-POOL` | `AQP\|XE>*POOL-VACATE-CUSTODY` | No — `CAP_PoolOwner` + vault IMC |
| Phases 1.2–5 | `AQP-POOL` / `AQP-SCORE` / `AQP-FVT` | existing `XE_*` / `XI_*` | No — `P\|SECURE-CALLER` or `SECURE` |

The **sovereign recipe cap** lives in **FVT** (not Talos). Talos only bills IGNIS via `C_Collect patron`.

## On-chain batch limits (`AQP-POOL`)

```pact
VACATE-MAX-NONCES = 64    ;; max nonces per owner group per tx (FVT enforces on batch arrays)
```

`VACATE-MAX-LEGS` remains in AQP for the FVT batch shape but Talos always passes one leg. Tune `VACATE-MAX-NONCES` on mainnet using Bloodshed gas profiling (~700–800 nonces per ~2M gas was the working estimate).

## UI constructor algorithm

### 1. Inventory (off-chain reads)

Per pool, scan tracker rows (on-chain `URD_*` helpers for pool-scoped keys are **deferred** — until then, index events or maintain a mirror):

| Class | Source rows | Group key |
|-------|-------------|-----------|
| TF | `DPTFTracker` | `(owner-id, beneficiary-id, dptf-id)` → `amount` |
| OF | `DPOFTracker` | `(owner-id, beneficiary-id, dpof-id, nonce)` → whole nonce |
| DPSF/DPNF | `DPSFTracker` / `DPNFTracker` | `(owner-id, beneficiary-id, nonce)` → `amount` |

### 2. Group legs

- **Collectables / DPOF:** group nonces by `(owner-id, beneficiary-id)` — one transfer leg per group (DPDC/DPOF: one `receiver` per `C_Transfer`).
- **DPTF:** one leg per `(owner, beneficiary, dptf-id)` with total amount (TFT bulk multi-receiver exists but vacate uses per-leg unstake recipe).

### 3. Chunk into txs

For each asset stream, **one Talos tx per owner group** (and chunk nonces if a single owner exceeds `VACATE-MAX-NONCES`):

```
for each (owner, beneficiary) group with staked nonces:
  while nonces remain for this group:
    take next slice with length ≤ VACATE-MAX-NONCES
    submit C_VacateSemiFungibleCollectable or C_VacateNonFungibleCollectable
```

**Explicit nonce lists** in each tx — no pool-id-only vacate.

### 4. Talos function pick

| Situation | Call |
|-----------|------|
| One DPTF leg | `AQP-POOL\|C_VacateTrueFungible patron pool-id owner beneficiary dptf-id amount` |
| Multiple OF legs (same dpof-id) | `AQP-POOL\|C_VacateOrtoFungibleBatch` — or one tx per owner via repeated batch with N=1 |
| DPSF owner group (any size) | `AQP-POOL\|C_VacateSemiFungibleCollectable` — repeat per owner / nonce chunk |
| DPNF owner group (any size) | `AQP-POOL\|C_VacateNonFungibleCollectable` — repeat per owner / nonce chunk |

Signer: **pool owner** konto (`URC_AqpOwnerKonto pool-id`), not each depositor.

### 5. Patron / IGNIS

Each vacate tx passes `patron` (pays `IGNIS::C_Collect` on the recipe `OutputCumulator`) — same as stake/unstake shells.

## Multi-receiver note

- **DPTF:** TFT supports multi-receiver bulk; vacate recipe still uses one owner receiver per leg (unstake semantics).
- **DPOF / DPDC:** one receiver per `C_Transfer` — batch by owner group, not by “all receivers in one transfer”.

## Deferred / full tests

See `TEST_DEFERRED.md`:

- Pool-scoped `URD_*` tracker scans for UI inventory
- Bloodshed full-collection vacate gas limit assessment
- LP dual-stream vacate (TF + OF same pool)
- Third-party beneficiary rows (v1 unstake uses self-stake keys; vacate passes explicit `beneficiary-id` validated against tracker)

## Smoke coverage

`REPL/Stage_02/[6.2.4]_AQP-FVT-DC.repl` **TX-FVT-DC-04** — stake then `C_VacateSemiFungibleCollectable` (pool owner, single leg).
