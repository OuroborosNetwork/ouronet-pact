# How to build AQP staking products (Farm / Vault / Treasury)

**Goal:** Top-to-bottom recipes from live Talos `TS02-C3` + sovereign modules — what to create, in what order, with which options and limits.

**Related:** [README_GLOBAL.md](README_GLOBAL.md) · [README_TALOS_CATALOGUE.md](README_TALOS_CATALOGUE.md) · [README_FVT.md](README_FVT.md) · Boot: [README_AQP_BOOT.md](../../../2_SLAVE/Stage_02/README_AQP_BOOT.md)

All client calls below are **`TS02-C3.AQP-*|C_*`** unless noted.

---

## 0. Decide the product shape

| Product | FVT class | Typical pools | Score classes | Reward split |
|---------|----------:|---------------|---------------|--------------|
| **Farm (LP)** | 0 | One or many class-0 LP pools | Class-0 (often Silver/Bronze/Golden triplet per LP) | Two-tier: ghost TVL × deb |
| **Vault (TF)** | 1 | Class-1 DPTF pools | Class-1 | Vault RPS path |
| **Vault / earn SF-NF** | 1 or 2 | Class 3/4 pools | Class 3/4 + definitions | Per FVT design |
| **Treasury** | 2 | Mixed aggregators | Matching classes | General aggregator |

**Hard rules**

- Users stake in **pools**, never in the FVT.
- One score → one pool (`aqpool-link`) and one FVT (`fvt-link`).
- Multi-LP farm = **new scores per LP**, not shared scores.

---

## 1. Farm — single OURO LP (minimal)

### Once

1. `AQP-FVT|C_Issue` — `fvt-class=0`, `common-denominator=<OURO-… full id>`, owner = farm operator.
2. `AQP-FVT|C_AddRewardLink` — each reward DPTF (`segmentation=false`, multiplet-family `BAR` unless using multiplet).

### Per LP line

| Step | Call | Notes |
|-----:|------|-------|
| 1 | Issue 3× `AQP-SCR|C_IssueLiquidityScore` | Same `lp-denominator` = OURO full id; **new names** per LP |
| 2 | Optional ANK + `C_CreateScoreBoostClassLink` / `C_CreateScoreBoostLink` | Bronze/Golden → Silver foreign boost |
| 3 | Optional `C_EnableDebBoost` | Irreversible |
| 4 | `AQP-SCR|C_IssueTriplet` | bronze, silver, golden ids |
| 5 | `AQP-POOL|C_Issue` | `aqp-class=0`, `asset-id` = **native LP id** |
| 6 | `AQP-POOL|C_AddScore` ×3 | Employ triplet |
| 7 | `AQP-POOL|C_EnablePoolStake` | If not already enabled at issue policy |
| 8 | `AQP-FVT|C_AddScoreEntity` ×3 **or** entity type 3 with triplet id | Type **1** per score-id, or type **3** triplet — follow product wiring used in BOOT/golden |
| 9 | Users `C_StakeTrueFungible` / `C_StakeOrtoFungible` | Native LP and/or Z\| orto leg |
| 10 | Ops `C_Inject` / users `C_Collect` | Collect: type 1 or 3 matching how ScoreEntity was added |

### Adding a second OURO LP to the **same** farm

Repeat steps 1–9 with **new score names** and a **new pool**. Add ScoreEntity links on the **existing** farm. Do **not** reuse Step-6 score ids.

### Options / limits

| Option | Effect |
|--------|--------|
| Triplet vs single LP score | Triplet enables composite boost + multiplet-style collect paths; single score is simpler |
| Mosaic (`C_SetMosaic`) | Farm mosaic flag — only if product requires it |
| Multiplet rewards | `C_IssueMultipletFamily` then `C_AddRewardLink` with `segmentation=true` + family-id |
| Max scores / pool | 7 |
| Ghost TVL | Driven by SWP; stale until sync after liquidity txs |

---

## 2. Vault — TrueFungible stake (e.g. OURO)

1. Optional ANK for that DPTF.
2. `AQP-SCR|C_IssueTrueFungibleScore` (+ optional boost-class-link, EnableDebBoost).
3. `AQP-POOL|C_Issue` — `aqp-class=1`, `asset-id` = DPTF id.
4. `AQP-POOL|C_AddScore`.
5. `AQP-FVT|C_Issue` — `fvt-class=1` (Vault).
6. `C_AddRewardLink` + `C_AddScoreEntity` (type 1).
7. Users `C_StakeTrueFungible` / `C_UnstakeTrueFungible`.
8. `C_Inject` / `C_Collect`.

**Sleeping / hibernating DPOF satellites** on class-1 pools: use `C_StakeOrtoFungible` / unstake for Z\|/H\| legs when product supports them — pool class must allow that OF id.

---

## 3. Collectable pool — SemiFungible (DPSF)

1. `AQP-SCR|C_IssueSemiFungibleScore`.
2. `AQP-SCR|C_IssueSemiFungibleScoreDefinition` — nonce → weight map.
3. `AQP-POOL|C_Issue` — `aqp-class=3`, asset = DPSF id.
4. `C_AddScore` → FVT Vault/Treasury (`fvt-class` 1 or 2) → reward link → ScoreEntity.
5. Stake: `C_StakeSemiFungibleCollectable` (nonces).
6. Unstake: `C_UnstakeSemiFungibleCollectable` (nonces + amounts).

---

## 4. Collectable pool — NonFungible (DPNF)

Same pattern as SF with:

- `C_IssueNonFungibleScore` + trait **or** set definition.
- Pool `aqp-class=4`.
- `C_StakeNonFungibleCollectable` / `C_UnstakeNonFungibleCollectable`.

---

## 5. Standalone OrtoFungible pool

1. `C_IssueOrtoFungibleScore`.
2. Pool `aqp-class=2`, asset = circulating DPOF id (not Z\|/H\|).
3. Wire FVT + stake via `C_StakeOrtoFungible` (whole nonces).

---

## 6. Operator day-2

| Need | Action |
|------|--------|
| Pause deposits | `C_DisablePoolStake` |
| Resume | `C_EnablePoolStake` |
| Pause a score tranche | `C_ToggleScoreEntityLink` enabled=false |
| Pause a reward | `C_ToggleRewardLink` |
| Force-return all stakes | Vacate Full or Legs — [README_VACATE_UI.md](README_VACATE_UI.md) |
| Mid-vacate abandon | `C_AbortVacate` then later `C_EnablePoolStake` |
| Anchor drift | `C_Sync*Anchors` |

---

## 7. Vacate construction (UI)

**Canonical engine (exact URD/URDC reads + Full-first → Legs verify/shrink + arg mapping):**  
[README_VACATE_UI.md §1](README_VACATE_UI.md#1-ui-vacate-engine-canonical-construction)

Short version per asset stream:

1. Resolve asset-id(s) from `UR_AQP|PoolAqpClass` / `PoolAssetId` (+ `DPTF.UR_Sleeping` for class-0 Z\|).
2. Dirty-read `AQP-VCT.URD_Vacate*Inventory` (+ `URDC_VacateUnitCountForKind`).
3. If units fit Full (~2M + hard caps) → one `C_FullVacate*` (Legs payload from plan `N=1`).
4. Else `UC_ComputeMinSliceCount` → `URDC_BuildVacateSlicePlan` → N `C_Vacate*Legs`; gas-check each leg; grow N until all fit; last batch `finalize=true`.
5. Class-0 with TF+OF inventory → run for **both** streams independently.

Show construction iterations + tx list; confirm; dump. On gas failures, re-read and re-split.

---

## 8. Production bootstrap shortcut

Live chain / REPL can use **AQP-BOOT** steps (anchors → scores → DH pools + first OURO LP pool). Farm ScoreEntity wiring may be a later boot step — see BOOT README. Custom products still follow sections 1–5 above.

---

## 9. Common mistakes

| Mistake | Fix |
|---------|-----|
| Stake into FVT | Stake into **pool** |
| Reuse scores on LP #2 | New score issuance |
| `common-denominator` / `lp-denominator` = `"OURO"` | Full `OURO-…` id |
| Pool before scores | Scores → pool → AddScore → FVT link |
| Finalize Legs while inventory remains | Only finalize when that asset URD count is 0 |
| Expect Abort to re-enable stake | Abort clears flag only; call EnablePoolStake |
