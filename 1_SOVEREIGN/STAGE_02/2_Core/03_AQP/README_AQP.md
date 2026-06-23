# AQP-POOL -- Acquisition Pools

Module: `AQP-POOL` | Interface: `AcquisitionPoolsV1` | File: `03_AQP.pact`

**Status: In progress — `C_Issue`, `C_AddScore`, `C_RevokeScore` implemented; stake/unstake/sync are designed stubs; `AQP|T|BeneficiaryDptfTotal` schema + table + UR helpers added (rollup writers pending with stake impl).**

## Purpose

Pools are the **staking venues** where users lock assets to earn scores and, through FVTs, rewards. Each pool accepts one canonical asset-id (determined by `aqp-class`) and employs up to 7 Scores that measure the user's weighted contribution.

---

## Staking entry points (settled API)

Three public paths by **asset mechanics** (not by pool class alone). LP uses TF or OF — no separate LP function.

| Function | Asset | Stake args (high level) | Unstake beneficiary |
|----------|-------|-------------------------|---------------------|
| Talos `C_StakeTrueFungible` / `C_UnstakeTrueFungible` → **`FVT::C_TrueFungibleStakeFlow`** | DPTF + native\|F\| LP | `patron pool owner beneficiary dptf-id amount` (+ `direction` in FVT) | **Required** on unstake (balance buckets per owner+beneficiary) |
| `C_StakeOrtoFungible` / `C_UnstakeOrtoFungible` | DPOF (native, Z\|, H\|, Z\| LP) | `patron pool owner beneficiary dpof-id nonces` | **Unstake:** beneficiary read from tracker row per nonce |
| `C_StakeCollectable` / `C_UnstakeCollectable` | DPSF / DPNF | `patron pool owner beneficiary collectable-id son nonces amounts` | **Omitted** — read from tracker row per nonce |

**Also:** `C_VacatePool` (pool owner force-unwind), `C_SyncTrueFungibleAnchors` (pool-agnostic ANK repair — see below).

### True fungible rules (settled, not all implemented)

- **Beneficiary** must be an existing **activated standard Ouronet account** (`DALOS::UEV_EnforceAccountExists` + `UEV_EnforceAccountType false`).
- **Owner** signs; **beneficiary** earns score + anchor promile (`ouronet-account` in SCORE/ANK). Same id = self-stake.
- **Staking allowed only if** pool has ≥ 1 employed score (`URC_PoolActiveScoreIds` non-empty).
- **DPTF legs:** native and **frozen** (`F|`) allowed; **reserved** (`R|`) **rejected**.
- **No `native-or-frozen` on the public API** — derive from `dptf-id`: `F|` → frozen multiplier path; else native. Passed internally to SCORE `XE_*`.
- **Custody:** `TFT::C_Transfer` owner → `AQP|SC_NAME` on stake; reverse on unstake.
- **Structural blueprint:** UrStoa `C_URV|Stake` / `Unstake` in `00_StoaSandbox/coin.pact` (transfer → tracker/supply → score-side updates). AQP adds multi-score loop + ANK. FVT Inject/Collect (RPS) is **not** part of stake.

### Orto fungible rules (settled, partial impl)

- **Whole-nonce only:** stake/unstake always uses `DPOF::C_Transfer` with full nonce supply (`UR_NoncesSupplies`). No `C_Transmit` / partial segmentation on the stake path (collection may still segment elsewhere).
- Talos **`C_StakeOrtoFungible`** / **`C_UnstakeOrtoFungible`** omit `nonce-amounts` — amounts resolved from `DPOF::UR_NoncesSupplies` before the `@event` cap.
- **No ANK phase** on OF stake — anchors are **DPTF / DPSF / DPNF only**; staking DPOF does not change anchor promile balances.
- **No `BeneficiaryDpofTotal` rollup** — per-pool `AQP|T|DPOFTracker` (per nonce) is sufficient; unlike DPTF there is no cross-pool O(1) read for anchor sync.

### Stake body order (true fungible — settled)

1. Cap + `UEV_*` (pool, scores, owner, beneficiary, amount, dptf-id, not `R|`, asset matches pool class)
2. Transfer tokens to `AQP|SC_NAME`
3. Update **per-pool** `AQP|T|DPTFTracker` row
4. Bump **cross-pool** `AQP|T|BeneficiaryDptfTotal` (+amount / −amount) — O(1)
5. **ANK first:** `AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues(beneficiary, dptf-id, total-balance)` using rollup (skip if zero anchors; LP has no TF anchors)
6. **SCORE second:** loop `URC_PoolActiveScoreIds` → `XE_UpdateScoreDataForTrueFungible` (class 1) or `XE_UpdateScoreDataForTrueFungibleLP` (class 0)
7. IGNIS cumulator

ANK **before** SCORE so `UR_UB|AggregatePromile` is fresh when boosted/deb are computed.

---

## Two table layers: per-pool trackers vs beneficiary rollups

| Layer | Table | Granularity | Purpose |
|-------|--------|-------------|---------|
| **Per-pool custody** | `AQP\|T\|DPTFTracker` | `(pool, dptf-id, owner, beneficiary)` | Revoke guards, pool-local balance, vacate |
| **Cross-pool rollup** | `AQP\|T\|BeneficiaryDptfTotal` | `(beneficiary, dptf-id)` | Single O(1) total for ANK; sync without scanning N pools |

Same DPTF staked in 700 pools → **700 tracker rows**, **one** rollup row per `(beneficiary, dptf-id)`. Native `X` and frozen `F|X` are **separate** rollup rows (match ANK `ank-asset` id used at anchor issue).

**Open sub-decision:** whether native-anchor promile should combine native + frozen leg totals (two-row read, still O(1)).

---

## Anchor sync (`C_SyncTrueFungibleAnchors`)

### Problem

- Anchors can be **issued after** users already staked → promile rows stay 0 until refreshed.
- `C_IssueTrueFungibleAnchor` does **not** backfill existing stakers.
- Inline stake/unstake refreshes ANK when anchors exist; **repair path** needed otherwise.

### Solution (settled)

**`C_SyncTrueFungibleAnchors(patron, beneficiary-id, dptf-id)`** — pool-agnostic:

1. Read `UR_AQP|BeneficiaryDptfTotalBalance` (one row)
2. `ANK::XE_UpdateTrueFungibleUserAnchorValues(beneficiary, dptf-id, total-balance)`
3. Set `last-ank-sync-count := ANK::UR_AA|AnchorsActive(dptf-id)`
4. IGNIS (`GAS|SYNC-TF-ANCHORS`)

Cost: **O(live anchors on asset)** — independent of pool count.

### UI “needs sync” signal

```text
URC_BeneficiaryAnchorsNeedSync(beneficiary, dptf-id) =
  (total-balance > 0) AND (UR_AA|AnchorsActive(dptf-id) > last-ank-sync-count)
```

When a new anchor is issued, `anchors-active` increments → UI prompts user to run sync (no on-chain push required).

### SCORE boosted staleness (documented gap)

Sync updates **ANK only**. Existing `SCR|T|UserScore.boosted-score` in each pool is **not** rewritten. Boosted/deb refresh **lazily** on next stake/unstake in that pool unless we add a separate expensive `C_SyncScoreBoostFromAnchors` later.

---

## ANK update graph (reference)

```
Asset dptf-id
  └── ANK|T|AssetAnchors (≤49 anchors, 7×7 groups)
        └── each anchor → ANK|T|Anchor → boost-class-id
              └── stake/sync writes ANK|T|Anchors (user promile per anchor)
                    └── XH_RecomputeAffectedBoostAggregates → ANK|T|UserBoost

Score.boost-class-link → BoostClass
  └── SCORE reads UR_UB|AggregatePromile(beneficiary, boost-class-link) on stake
```

Up to **49 anchors per asset** × write on sync/stake; up to **7 BoostClass** aggregate recomputes. Gas-heavy at the cap — measure in REPL after impl.

---

## TODO — rollup tables for other asset types

| Asset | Cross-pool rollup | ANK on stake | Sync repair |
|-------|-------------------|--------------|-------------|
| DPTF | `AQP\|T\|BeneficiaryDptfTotal` **live** | `XE_UpdateTrueFungibleUserAnchorValues` | `C_SyncTrueFungibleAnchors` |
| DPOF | **None** (per-nonce `DPOFTracker` only) | **None** — no DPOF anchors | N/A |
| DPSF | TBD | `XE_UpdateSemiFungibleUserAnchorValues` (incremental nonces) | TBD |
| DPNF | TBD | `XE_UpdateNonFungibleUserAnchorValues` (incremental nonces) | TBD |

ANK issue paths: `C_IssueTrueFungibleAnchor`, `C_IssueSemiFungibleAnchor`, `C_IssueNonFungibleAnchor` / `Set` only.

---

## Core Concepts

### Pool Classes (0-4)

| Class | Asset Type | Staking path |
|-------|-----------|--------------|
| 0 | LP tokens | TF (native\|F\|) + OF (sleeping\|Z\|) |
| 1 | DPTF (non-LP) | TF (native, frozen); OF for sleep/hib satellites |
| 2 | DPOF (non-LP) | OF (native) |
| 3 | DPSF (SFTs) | Collectable (`son=true`) |
| 4 | DPNF (NFTs) | Collectable (`son=false`) |

### Score Slots

Seven slots per pool. Stake updates **every** employed score (skip `BAR`).

### Staking Trackers (per-pool)

- `AQP|TrueFungibleTracker` — DPTF balance per pool/owner/beneficiary
- `AQP|OrtoFungibleTracker` — DPOF per nonce
- `AQP|SemiFungibleTracker` — DPSF per nonce
- `AQP|NonFungibleTracker` — DPNF per nonce

### Score Attribution (SF/NF only)

- `AQP|DPSFScoreAttribution` / `AQP|DPNFScoreAttribution` — cached score + def revision per (pool, asset, position, score-id)

---

## Data Model

### Tables

| Table | Schema | Key |
|-------|--------|-----|
| `AQP\|T\|Pool` | `AQP\|Schema` | `<Pool-ID>` |
| `AQP\|T\|DPTFTracker` | `AQP\|TrueFungibleTracker` | `<Pool> \| <DPTF> \| <Owner> \| <Beneficiary>` |
| `AQP\|T\|BeneficiaryDptfTotal` | `AQP\|BeneficiaryDptfTotal` | `<Beneficiary> \| <DPTF-ID>` |
| `AQP\|T\|DPOFTracker` | `AQP\|OrtoFungibleTracker` | 5-part composite |
| `AQP\|T\|DPSFTracker` | `AQP\|SemiFungibleTracker` | 5-part composite |
| `AQP\|T\|DPNFTracker` | `AQP\|NonFungibleTracker` | 5-part composite |
| `AQP\|T\|DPSFScoreAttribution` | `AQP\|DPSFScoreAttribution` | 6-part composite |
| `AQP\|T\|DPNFScoreAttribution` | `AQP\|DPNFScoreAttribution` | 6-part composite |

### C_ Functions

| Function | Status |
|----------|--------|
| `C_Issue` | Implemented |
| `C_AddScore` | Implemented |
| `C_RevokeScore` | Implemented |
| `C_VacatePool` | Stub (loops FVT::C_TrueFungibleStakeFlow per tracker — TBD) |
| TF stake/unstake | **FVT::C_TrueFungibleStakeFlow** (direction); Talos client shell only |
| OF stake/unstake | **FVT::C_OrtoFungibleStakeFlow** (direction); Talos ×4 Transfer/Transmit shells |
| `C_StakeCollectable` / `C_UnstakeCollectable` | Stub |
| `C_SyncTrueFungibleAnchors` | Stub (table + UR ready) |

---

## C_StakeTrueFungible — FVT recipe + Talos client shell

**Sovereign recipe:** **`FVT::C_TrueFungibleStakeFlow`** (`direction=true` stake, `false` unstake) — orchestrates five **`XE_*`** phases, returns concatenated **`OutputCumulator`**.

**Talos:** **`AQP-POOL|C_StakeTrueFungible`** / **`C_UnstakeTrueFungible`** — **`@event`** cap + **`IGNIS::C_Collect patron`** + result text only.

**Capability model (see `.cursor/skills/ouronet-talos-orchestrator-events/SKILL.md`):**

- **Talos client `@event`:** `AQP|C>STAKE-TRUE-FUNGIBLE` / `C>UNSTAKE-TRUE-FUNGIBLE` (incl. `patron`) — **`compose-capability (P|TS)` only**.
- **FVT `C_TrueFungibleStakeFlow`:** `UEV_IMC` + `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW` + phase **`XE_*`** calls.
- **AQP-POOL:** phase 1 only (`XE_TrueFungiblePoolCustody`); no monolithic TF **`C_*`**.

Result text uses **`UC_ShortAccount`** and branches self-stake vs beneficiary stake.

```
UrStoa C_URV|Stake                    →  FVT::C_TrueFungibleStakeFlow (Talos client shell)
────────────────────────────────────────────────────────────────────────────
1]   Move URSTOA user↔vault           →  1]   AQP-POOL::XE_TrueFungiblePoolCustody
2.1] UpdatePendingRewards             →  2.1] FVT::XI_SettleStakePendingRewards (via C_TrueFungibleStakeFlow)
2.2] (none)                           →  2.2] ANK::XE_RefreshTrueFungibleStakeAnchors
2.3] UpdateVaultScore + UserScore     →  2.3] SCR::XE_ApplyTrueFungibleStakeDelta
2.4] UpdateUserRPS                    →  2.4] FVT::XI_CheckpointStakeRps (via C_TrueFungibleStakeFlow)
3]   Return text + gas                →  3]   Talos: IGNIS::C_Collect (+ format)
```

| Phase | Module | `XE_*` | Status |
|-------|--------|--------|--------|
| 1] Custody + trackers | POOL | `XE_TrueFungiblePoolCustody` | **Phase 1 wired** — returns OC from XI sub-steps |
| 2.1] RPS settle (OLD deb) | FVT | `XI_SettleStakePendingRewards` (internal) | STUB |
| 2.2] ANK refresh | ANK | `XE_RefreshTrueFungibleStakeAnchors` | STUB |
| 2.3] SCORE weight | SCR | `XE_ApplyTrueFungibleStakeDelta` | STUB |
| 2.4] RPS checkpoint (NEW L_i) | FVT | `XI_CheckpointStakeRps` (internal) | STUB |

**Standalone `C_*` on AQP-POOL:** lifecycle (`C_Issue`, `C_AddScore`, …), `C_SyncTrueFungibleAnchors`, OF/DPDC stake stubs. TF stake/unstake recipe is **`FVT::C_TrueFungibleStakeFlow`**; POOL exposes **`XE_TrueFungiblePoolCustody`** (phase 1) only.

**POOL `XI_*` (internal):** `XI_TransferDptfPoolCustody`, `XI_WriteDptfTracker`, `XI_BumpBeneficiaryDptfTotal` — called from `XE_TrueFungiblePoolCustody` when implemented.

**SCR `XE_UpdateScoreDataFor*`:** per-score forward writers; batch loop lives in `XE_ApplyTrueFungibleStakeDelta`.

**Implement order:** POOL custody UEV + transfer → trackers → FVT settle → ANK refresh → SCR loop → FVT checkpoint

### IGNIS billing (Talos stake/unstake)

Talos is **orchestrator only**: each phase **`XE_*` returns `OutputCumulator`** with pricing composed inside the sovereign module (sub-`XI_*` steps return cumulators that parent functions concatenate). Talos **`UDC_ConcatenateOutputCumulators [ico1 ico2 … ico5] []`** then **`IGNIS::C_Collect`**. **No Talos URC pricing.** **No `XB_DynamicFuelKDA`.**

| Phase | Module `XE_*` | Cumulator composition (inside module) |
|-------|---------------|--------------------------------------|
| 1] POOL custody | `XE_TrueFungiblePoolCustody` | `XI_Transfer` (TFT OC) + `XI_WriteDptfTracker` (ignis\|medium) + `XI_BumpBeneficiaryDptfTotal` (ignis\|biggest) |
| 2.1] FVT settle | `XI_SettleStakePendingRewards` | single OC: `URC_SettleStakePendingIgnis settle-scores distinct-fvts` (lists resolved once in parent XI) |
| 2.2] ANK refresh | `XE_RefreshTrueFungibleStakeAnchors` | ignis\|small × live anchor count |
| 2.3] SCORE delta | `XE_ApplyTrueFungibleStakeDelta` | fold concat of per-class `XI_Apply*ScoreStakeDelta` (internal; each uses `URC_StakeScoreDeltaIgnisUnit`) |
| 2.4] FVT checkpoint | `XI_CheckpointStakeRps` | flat 2 × ignis\|biggest |

**Implement order:** phase 1] POOL **(wired)** → 2.1 FVT → 2.2 ANK → 2.3 SCORE bodies → 2.4 FVT checkpoint

---

## C_OrtoFungibleStakeFlow — FVT recipe + Talos client shell

**Sovereign recipe:** **`FVT::C_OrtoFungibleStakeFlow`** (`direction=true` stake, `false` unstake) — **four** phases (no ANK leg).

**Talos:** **`AQP-POOL|C_StakeOrtoFungible`** / **`C_UnstakeOrtoFungible`** — resolve whole-nonce legs via `UR_NoncesSupplies` before `@event` cap → **`IGNIS::C_Collect`** → recipe.

```
UrStoa (conceptual)                   →  FVT::C_OrtoFungibleStakeFlow
──────────────────────────────────────────────────────────────────────
1]   Move nonces user↔vault          →  1]   AQP-POOL::XE_OrtoFungiblePoolCustody
2.1] UpdatePendingRewards              →  2.1] FVT::XI_SettleStakePendingRewards
     (no ANK — DPOF has no anchors)    →      (skipped)
2.3] Update user score                 →  2.3] SCR::XE_ApplyOrtoFungibleStakeDelta
2.4] UpdateUserRPS                     →  2.4] FVT::XI_CheckpointStakeRps
```

| Phase | Module | Entry | Status |
|-------|--------|--------|--------|
| 1] Custody + tracker | POOL | `XE_OrtoFungiblePoolCustody` → `XI_1\|TransferDpofPoolCustody` + `XI_1\|WriteDpofTracker` | **Wired** (whole-nonce; native / Z\| / H\| / Z\| LP) |
| 2.1] RPS settle | FVT | `XI_SettleStakePendingRewards` | **READY** |
| 2.3] SCORE delta | SCR | `XE_ApplyOrtoFungibleStakeDelta` → class 0 LP / class 2 native or Z\|/H\| special | **Wired** |
| 2.4] RPS checkpoint | FVT | `XI_CheckpointStakeRps` | **READY** |

**POOL `XI_*` (internal):** `XI_1|TransferDpofPoolCustody`, `XI_1|WriteDpofTracker`, `XI_1|WriteDpofTrackerSlot` — no `BumpBeneficiaryDpofTotal`.

**URC (POOL):** `URC_StakeOrtoFungiblePoolClassOk`, `URC_StakeOrtoFungibleDpofMatchesPool`, `URC_OrtoUnstakeNoncesSufficient`.

**First impl target:** class-2 pool, native circulating `dpof-id`, class-2 scores, whole-nonce Transfer, self-stake.

**SCORE class dispatch:** `XE_ApplyOrtoFungibleStakeDelta` loops employed scores: class **0** → `XI_1|UpdateScoreDataForOrtoFungibleLP` (Z| LP); class **2** → native or `Z|/H|` special via `URC_OrtoDpofIsSpecialLeg` (multiplier from dpof-id prefix); classes **1/3/4** skipped on OF leg.

---

**SCORE class dispatch:** `XE_ApplyTrueFungibleStakeDelta` (FVT forward) loops pool scores and dispatches to module-internal **`XI_Apply*ScoreStakeDelta`** (0–4). Per-class bodies call **`XE_UpdateScoreDataFor*`** when wired (same-module forward writers on interface for future AQP OF/SF/NF stake paths).

**X* naming (AQP TF stake):**

| Prefix | Scope | Examples |
|--------|--------|----------|
| **`C_*`** | Sovereign client/recipe entry | `FVT::C_TrueFungibleStakeFlow` |
| **`XE_*`** | Cross-module forward (on interface) | `AQP::XE_TrueFungiblePoolCustody`, `ANK::XE_Refresh*`, `SCR::XE_Apply*`, `ANK::XE_UpdateTrueFungibleUserAnchorValues` (C_Sync) |
| **`XI_*`** | Same-module internal only | `FVT::XI_Settle*`, `FVT::XI_Checkpoint*`, `POOL::XI_Transfer*`, `SCR::XI_Apply*ScoreStakeDelta`, `ANK::XI_UpdateTrueFungibleUserAnchorValues` |
| **`XH_*`** | ANK helper (no cap) | `XH_RecomputeAffectedBoostAggregates` |

---

## Score rows and foreign `boost-link`

See **`README_SCORE.md` → Foreign boost-link** for satellite scores and `URC_SingularUserScoreDeltaFromSignedUserBase`.

## LP pools and multi-LP farms

Class-0 pools, triplets, FVT — unchanged; see prior sections in this file and **`README_FVT.md`**.

## Relationship to Other Modules

- **SCORE:** `XE_CreateAqpoolLink`, `XE_UpdateScoreDataFor*` on stake; reads `UR_UB|AggregatePromile` from ANK
- **ANK:** `XE_UpdateTrueFungibleUserAnchorValues` on stake/unstake/sync; up to 49 anchors per asset
- **FVT:** Rewards/RPS separate from stake (UrStoa Inject/Collect analogue)
