# AQP / FVT / ANK — deferred integration tests

Tests **not yet run** (or only partially covered). Run when Stage 02 AQP modules are feature-complete and the full `[6.2]_AQP.repl` chain is green.

**Currently passing (smoke only):**

| Suite | Covers |
|-------|--------|
| `REPL/DPDC-stake-smoke.repl` | DPSF collectable stake/unstake (TX-FVT-DC-01/02/03); phase 1.3 `BenDpsf*` rollup bump; phase 3 incremental ANK + `XB_SetBenCollectableAnkSyncCount` on stake |
| `REPL/Stage_02/OF-stake-smoke.repl` | DPOF stake/unstake (no ANK leg) |
| `REPL/Stage_02/[6.2.4]_AQP-FVT.repl` (partial) | TF anchor issue, pool, **stake** (TX-FVT-01–03); reads `BenDptfLastAnkSyncCount` after stake — **not** unstake, **not** sync repair |

---

## 1. Anchor sync repair (`C_Sync*`)

Implemented in code; **no REPL asserts yet.**

### 1.1 True fungible — `C_SyncTrueFungibleAnchors` / Talos `AQP-POOL|C_SyncTrueFungibleAnchors`

- [ ] Stake DPTF → `BenDptfTotal` > 0, `last-ank-sync-count` stamped on stake
- [ ] Issue **second** TF anchor on same `dptf-id` after stake
- [ ] `URC_BenDptfAnchorsNeedSync(beneficiary, dptf-id)` → `true`
- [ ] Run sync → promile on **both** anchors matches `BenDptfTotalBalance`
- [ ] `last-ank-sync-count` := `UR_AA|AnchorsActive(dptf-id)`
- [ ] `URC_BenDptfAnchorsNeedSync` → `false` after sync
- [ ] Flat IGNIS `GAS|SYNC-TF-ANCHORS` (50) + per-anchor ANK IGNIS on patron cumulator
- [ ] Sync with zero stake → cap rejects
- [ ] **SCORE gap:** `boosted-score` unchanged after sync; only refreshes on next stake/unstake in that pool

### 1.2 Collectable — core `C_SyncCollectableAnchors` + Talos shells

- [ ] **DPSF:** `AQP-POOL|C_SyncSemiFungibleAnchors` → `C_SyncCollectableAnchors(..., son=true)`
- [ ] **DPNF:** `AQP-POOL|C_SyncNonFungibleAnchors` → `C_SyncCollectableAnchors(..., son=false)`
- [ ] Stake → issue **new** SF/NF anchor → `URC_BenDpsfAnchorsNeedSync` / `URC_BenDpnfAnchorsNeedSync` → `true`
- [ ] Sync reads `URD_BenDpsfActiveNonceSupplies` / `URD_BenDpnfActiveNonceSupplies` (not tracker scan)
- [ ] `ANK::XE_ResyncSemiFungible*` / `XE_ResyncNonFungible*` rewrite **absolute** promile (not incremental stake delta)
- [ ] `XB_SetBenCollectableAnkSyncCount` updates `BenDpsfAnkMeta` / `BenDpnfAnkMeta`
- [ ] Flat IGNIS `GAS|SYNC-COLLECTABLE-ANCHORS` (50) + per-anchor ANK IGNIS

### 1.3 Edge cases (sync)

- [ ] DPSF and DPNF **same id string** (minted one tx): sync SF does not touch `BenDpnf*` rows and vice versa
- [ ] Multi-nonce rollup: stake several nonces, partial unstake, sync still matches active rollup rows
- [ ] Sync when `anchors-active` unchanged (manual refresh) — idempotent promile rewrite
- [ ] Compare-before-write gas optimization in ANK TF update (if implemented later)

---

## 2. Collectable stake — gaps beyond DPSF smoke

- [ ] **DPNF** full flow: `CC_StakeNonFungibleCollectable` / unstake + `BenDpnfNonceTotal` rollup + trait/class anchors
- [ ] `BenDpsfAnkMeta` / `BenDpnfAnkMeta` reads after stake (sync-count vs `UR_AA|AnchorsActive`)
- [ ] Cross-pool: same beneficiary stakes same collection in **two pools** → one rollup row per nonce, two tracker rows
- [ ] Unstake rollup guard: `URC_CollectableUnstakeRollupSufficient` rejects when rollup < tracker
- [ ] Beneficiary ≠ owner stake; unstake reads beneficiary from tracker per nonce

---

## 3. True fungible stake — gaps beyond TX-FVT-03

- [ ] `CC_UnstakeTrueFungible` / full unstake clears tracker + `BenDptfTotal`
- [ ] Frozen leg `F|dptf-id` separate `BenDptfTotal` row from native
- [ ] LP class-0 pool stake (native + frozen + OF paths)
- [ ] Multi-score pool: all employed scores updated on stake

---

## 4. Orto fungible (DPOF)

- [ ] Full `[6.2.4]_AQP-FVT-OF.repl` in main `[6.2]_AQP.repl` chain (smoke only today)
- [ ] Confirm **no** `BenDpof*` rollup (by design) and **no** sync

---

## 5. Unimplemented or stub features (test when built)

| Feature | Module | Notes |
|---------|--------|--------|
| Vacate batch (`C_Vacate*`) | FVT + Talos | **Smoke:** TX-FVT-DC-04 DPSF single-leg; see `README_VACATE_UI.md` |
| `C_SyncScoreBoostFromAnchors` | TBD | Optional expensive SCORE boosted repair after ANK sync |
| `C_Issue` / `C_AddScoreLink` / reward links on FVT | FVT | `REPL_BootstrapVault` used instead in REPL |
| `SWP::XE_RefreshGhostTvlForSwpair` | FVT | LP ghost TVL lazy sync |
| Native + frozen combined TF anchor promile | ANK | Open sub-decision in README_AQP.md |

---

## 6. Module / interface hygiene (non-functional)

- [ ] XI depth alignment: `WriteCollectableTracker` → slot should be `XI_2` → leaf `XI_3` (rollup bump chain already fixed)
- [ ] Interface / README_AQP.md status lines updated (rollups + sync no longer “stub”)
- [ ] On-chain deploy handoff: interface bumps, `create-table` for `BenDpsf*` / `BenDpnf*` on live net

---

## Suggested REPL additions (when ready)

| ID | File | Scenario |
|----|------|----------|
| TX-FVT-04 | `[6.2.4]_AQP-FVT.repl` | TF unstake + optional second anchor + `C_SyncTrueFungibleAnchors` |
| TX-FVT-DC-04 | `[6.2.4]_AQP-FVT-DC.repl` | DPSF vacate single-leg (smoke); multi-leg + DPNF Bloodshed deferred |
| TX-FVT-VAC-LP | TBD | Class-0 LP: `C_VacateTrueFungible` + `C_VacateOrtoFungibleBatch` same pool |
| TX-FVT-VAC-NF | TBD | DPNF `C_VacateNonFungibleCollectable` repeated txs + gas limit tune |

Wire new txs into `[6.2]_AQP.repl` after local smoke passes.

---

*Last updated: collectable rollup + `C_Sync*` implementation pass (DPDC smoke green; sync repair untested).*
