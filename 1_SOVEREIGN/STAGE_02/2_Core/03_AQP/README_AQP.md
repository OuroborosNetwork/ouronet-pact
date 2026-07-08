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

**Also:** `C_Vacate*` batch vacate (pool-owner forced unstake — UI multi-tx; see [`README_VACATE_UI.md`](README_VACATE_UI.md)), `C_SyncTrueFungibleAnchors` (pool-agnostic ANK repair — see below), **`C_DisablePoolStake` / `C_EnablePoolStake`** (owner stake pause/resume).

### Pool stake toggle and score revoke lifecycle

| Field / tx | Behavior |
|------------|----------|
| `AQP\|Schema.stake-enabled` | Default **`true`** at `C_Issue` |
| `C_DisablePoolStake` | Owner sets `stake-enabled` → **false** (pause new stakes). Idempotent. |
| `C_EnablePoolStake` | Owner sets `stake-enabled` → **true**. Stake still requires employed scores + FVT ready. |
| First `C_Vacate*` on a pool | Idempotently **`AQP-POOL::XB_SetPoolStakeEnabled false`** (VCT → AQP via IMC; no extra cap) |

**Wind-down order:** optional `C_DisablePoolStake` → unstake/vacate (vacate also disables via **`XB_`**) → FVT off → `C_RevokeScore`. Re-open stakes with **`C_EnablePoolStake`**.

**Score revoke:** user weights live at **`SCR\|T\|UserScore`** key `(account \| pool-id \| score-id)`. Before `C_RevokeScore`: disable stake (optional) → all unstake/vacate → FVT off (`fvt-link` BAR) → revoke. Historical user rows at the old pool **stay on chain** (do not migrate). Re-employ same score-id on another pool starts fresh `(user, new-pool, score-id)` weights; new LP lines should use **new score issuances**.

### True fungible rules (settled, not all implemented)

- **Beneficiary** must be an existing **activated standard Ouronet account** (`DALOS::UEV_EnforceAccountExists` + `UEV_EnforceAccountType false`).
- **Owner** signs; **beneficiary** earns score + anchor promile (`ouronet-account` in SCORE/ANK). Same id = self-stake.
- **`stake-enabled`** (default **true** at `C_Issue`): pool owner may **`C_DisablePoolStake`** to pause new stakes; **`C_EnablePoolStake`** turns admission back on. **Unstake and vacate ignore this flag.**
- **Stake admission** (`direction=true` only): `stake-enabled` **and** ≥ 1 employed score **and** (when rewards apply) FVT pipeline ready (`URC_PoolEmployedScoresFvtStakeReady`). Unstake/vacate skip score and FVT pipeline gates.
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
| `C_VacateTrueFungible` / `C_VacateOrtoFungibleBatch` / collectable via Semi+NonFungible Talos shells | **AQP-VCT** recipes; see [`README_VACATE_UI.md`](README_VACATE_UI.md) |
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
- **AQP-POOL:** phase 1 only (`XE_TrueFungible*` legs; TFT/DPOF inlined in `XE_*`); no monolithic TF **`C_*`**.

Result text uses **`UC_ShortAccount`** and branches self-stake vs beneficiary stake.

**Canonical phase model:** [`README_STAKE_PHASES.md`](README_STAKE_PHASES.md) — phases **1** (1.1–1.3) → **2** → **3** → **4** → **5**.

```
PHASE 1  1.1–1.3  AQP-POOL::XE_TrueFungible*
PHASE 2           FVT::XI_RpsPreScore
PHASE 3  3.1      FVT::XI_RefreshTrueFungibleStakeAnchors (3.2/3.3 comment-only)
PHASE 4           SCR::XE_ApplyTrueFungibleStakeDelta
PHASE 5  5.1–5.2  FVT::XI_BookStakeUnclaimedCounts / XI_CheckpointStakeRps
```

| Step | Module | Function | UrStoa ≡ | Status |
|------|--------|----------|----------|--------|
| 1.1–1.3 | POOL | `XE_TrueFungible*` | `X_UR\|Transfer` (+ N/A trackers) | **READY** |
| 2 | FVT | `XI_RpsPreScore` | 2.2 insert + 2.3 `UpdatePendingRewards` | **READY** |
| 3.1 | FVT/ANK | `XI_RefreshTrueFungibleStakeAnchors` | N/A | **READY** |
| 4 | SCR | `XE_ApplyTrueFungibleStakeDelta` | vault/user/nzs | **READY** |
| 5.1–5.2 | FVT | `XI_BookStakeUnclaimedCounts` / `XI_CheckpointStakeRps` | unclaimed + `UpdateUserRPS` | **READY** |

**POOL phase 1:** `XE_TrueFungibleTransfer`, `XE_TrueFungiblePoolTracker`, `XE_TrueFungibleBeneficiaryRollup` (TFT transfer inlined in `XE_TrueFungibleTransfer`).

### IGNIS billing (Talos stake/unstake)

Talos is **orchestrator only**: each phase **`XE_*` returns `OutputCumulator`** with pricing composed inside the sovereign module (sub-`XI_*` steps return cumulators that parent functions concatenate). Talos **`UDC_ConcatenateOutputCumulators [ico1 ico2 … ico5] []`** then **`IGNIS::C_Collect`**. **No Talos URC pricing.** **No `XB_DynamicFuelKDA`.**

| Step | Module `XE_*` | Cumulator composition |
|------|---------------|----------------------|
| 1.1–1.3 | `XE_TrueFungible*` | transfer + tracker + rollup |
| 2 | `XI_RpsPreScore` | `URC_SettleStakePendingIgnis` |
| 3.1 | `XI_RefreshTrueFungibleStakeAnchors` | ANK + AQP sync concat |
| 3.2–3.3 | *(comment-only)* | — |
| 4 | `XE_ApplyTrueFungibleStakeDelta` | per-score fold |
| 5.1 | `XI_BookStakeUnclaimedCounts` | `URC_BookStakeUnclaimedIgnis` |
| 5.2 | `XI_CheckpointStakeRps` | 2 × ignis\|biggest |

---

## C_OrtoFungibleStakeFlow — FVT recipe + Talos client shell

**Sovereign recipe:** **`FVT::C_OrtoFungibleStakeFlow`** — same phase skeleton as TF; **1.3** and **3.x** are comment-only in the ICO list. See [`README_STAKE_PHASES.md`](README_STAKE_PHASES.md).

| Step | Module | Function | UrStoa ≡ | Status |
|------|--------|----------|----------|--------|
| 1.1–1.2 | POOL | `XE_OrtoFungibleTransfer` / `XE_OrtoFungiblePoolTracker` | `X_UR\|Transfer` | **READY** |
| 1.3 | — | *(comment-only)* | N/A | **READY** |
| 2 | FVT | `XI_RpsPreScore` | insert + `UpdatePendingRewards` | **READY** |
| 3.1–3.3 | — | *(comment-only)* | N/A | **READY** |
| 4 | SCR | `XE_ApplyOrtoFungibleStakeDelta` | vault/user/nzs | **READY** |
| 5.1–5.2 | FVT | `XI_BookStakeUnclaimedCounts` / `XI_CheckpointStakeRps` | unclaimed + checkpoint | **READY** |

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
| **`XE_*`** | Cross-module forward (on interface) | `AQP::XE_TrueFungible*` legs, `AQP::XE_SetVacateJobState` / `AQP::XE_ZeroDptfTrackerSlot` (VCT-only), `SCR::XE_Apply*`, `ANK::XE_UpdateTrueFungibleUserAnchorValues` (C_Sync) |
| **`XB_*`** | Home `C_*` + cross-module shared write | `AQP::XB_SetPoolStakeEnabled`, `AQP::XB_SetBenDptfAnkSyncCount`, `AQP::XB_SetBenCollectableAnkSyncCount` |
| **`XI_*`** | Same-module internal only (tiered `XI_*` → `XI_1\|*` → `XI_2\|*`) | `FVT::XI_RpsPreScore`, `POOL::XI_1\|WriteDptfTrackerSlot`, `SCR::XI_2\|ApplySingularUserScoreDelta`, `ANK::XI_1\|UpdateTrueFungibleUserAnchorValues` |

---

## Score rows and foreign `boost-link`

See **`README_SCORE.md` → Foreign boost-link** for satellite scores and `URC_SingularUserScoreDeltaFromSignedUserBase`.

## LP pools and multi-LP farms

Class-0 pools, triplets, FVT — unchanged; see prior sections in this file and **`README_FVT.md`**.

## Relationship to Other Modules

- **SCORE:** `XE_CreateAqpoolLink`, `XE_UpdateScoreDataFor*` on stake; reads `UR_UB|AggregatePromile` from ANK
- **ANK:** `XE_UpdateTrueFungibleUserAnchorValues` on stake/unstake/sync; up to 49 anchors per asset
- **FVT:** Rewards/RPS separate from stake (UrStoa Inject/Collect analogue)
