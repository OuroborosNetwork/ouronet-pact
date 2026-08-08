# AQP Deploy Test Matrix (pre-DeployXY)

**Purpose:** Exhaustive scenario checklist for the five AQP sovereign modules + Talos + AQP-BOOT, before DeployXY.  
**Rule:** Code is source of truth. Docs that still say “stub” are stale — treat this matrix as the plan of record.  
**How to use:** Walk top → bottom. For each scenario: implement/extend REPL → run → mark status. Do not claim deploy-ready until **P0** is green and **P1** has no open fails.

**Status legend**

| Mark | Meaning |
|------|---------|
| `PASS` | Covered by named REPL and known green |
| `PARTIAL` | Some path covered; gaps remain |
| `MISSING` | No dedicated REPL assert yet |
| `REJECT` | Negative / enforce path (must fail correctly) |
| `DEFER` | Known out of scope for this DeployXY (document why) |

**Priority**

| Pri | Meaning |
|-----|---------|
| **P0** | Must pass before DeployXY (boot + hot paths + money paths) |
| **P1** | Should pass (guards, unstake, sync, multi-user fairness) |
| **P2** | Nice / gas / scale / edge (can ship with known limitation noted) |

**Existing loaders (reference)**

| Loader | Role |
|--------|------|
| `REPL/Z.repl` | AQP-FAST smoke (Stage02_Tester → `[6.2]_AQP.repl`) |
| `REPL/AQP-comprehensive.repl` | Long exhaustive (BOOT + `[6.4]` + `[6.3]`) — does **not** load TRIPLET-COLLECT / VCT gas |
| `REPL/triplet-diag.repl` | Boot + triplet LP score diag |
| `REPL/triplet-collect-golden.repl` | Boot + MULTIPLET_BASE farm collect |
| `REPL/Stage_02/[6.2.5]_AQP-VCT.repl` | Vacate lifecycle (outside Z / comprehensive) |
| Kursan gas sweeps | Vacate / stake gas ladders |

---

## 0. Cross-cutting / DeployXY gates

| ID | Scenario | Pri | Status | Evidence / notes |
|----|----------|-----|--------|------------------|
| X-01 | IMC wire + governors (BOOT Step 0) | P0 | PASS | BOOT-FULL / Z |
| X-02 | Full BOOT Steps 1–12 (anchors → scores → pools → FVT → multiplet → triplet farm → reward links) | P0 | PASS | `[6.2.9]_AQP-BOOT-FULL` + Steps 4–5 |
| X-03 | Talos client surface: every public AQP `C_*` reachable via `TS02-C3` | P0 | PARTIAL | Smoke uses Talos; no exhaustive “every Talos wrapper once” suite |
| X-04 | IGNIS / gas cumulators non-empty on admin + stake + inject/collect | P1 | PARTIAL | Gas ladders exist; not all C_* asserted |
| X-05 | No dispo / custody failures on golden money paths (inject ≤ vault; collect ≤ available-rewards) | P0 | PASS | triplet-collect-golden (post Tier-2 divisor fix) |
| X-06 | Module load order / interface embed / `P\|A_Define` IMP for ATSU on FVT+Talos | P0 | PASS | Collect Coil/Curl path |
| X-07 | Document known DEFER items for DeployXY release notes | P0 | PASS | See §10 DEFER release notes below |

---

## 1. AQP-ANK (`01_ANK.pact`)

### 1.1 Issue / revoke (admin)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| ANK-01 | Issue TF anchor, `acnoi=true` → new BoostClass + Anchor | P0 | PASS | `[6.2.1]` |
| ANK-02 | Issue TF/SF/NF into existing BoostClass, `acnoi=false` | P0 | PASS | `[6.2.1]` / BOOT |
| ANK-03 | Issue SF anchor (nonce-bound) | P0 | PASS | `[6.2.1]` |
| ANK-04 | Issue NF trait anchor (trait key/value) | P0 | PASS | BOOT / DPNF paths |
| ANK-05 | Issue NF set-class anchor (`dpnf-nonce-class`) | P1 | PARTIAL | BOOT bunny set; assert set-class path |
| ANK-06 | Revoke anchor → inactive; BC slot freed | P0 | PASS | `[6.2.1]` strip |
| ANK-07 | Revoke empty BoostClass → inactive | P1 | PARTIAL | Cap exists; dedicated expect? |
| ANK-08 | BOOT Steps 2–3 SnakePower + Booster classes | P0 | PASS | BOOT-FULL |

### 1.2 Caps / rejects

| ID | Scenario | Pri | Status | Type |
|----|----------|-----|--------|------|
| ANK-R01 | BoostClass full (7 anchors) reject | P1 | PARTIAL | REJECT |
| ANK-R02 | Asset 49-anchor cap reject | P2 | MISSING | REJECT |
| ANK-R03 | Bad promile / precision reject | P1 | MISSING | REJECT |
| ANK-R04 | Barred DPTF prefixes (S\|/W\|/P\| ATS/SWP) reject | P1 | MISSING | REJECT |
| ANK-R05 | Revoke BC with live anchors reject | P1 | MISSING | REJECT |
| ANK-R06 | Issue into inactive BoostClass reject | P1 | MISSING | REJECT |

### 1.3 Runtime promile (`XE_Update*` / `XE_Resync*`)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| ANK-10 | TF stake → `XE_UpdateTrueFungibleUserAnchorValues` updates promile + aggregate | P0 | PASS | FVT TF stake |
| ANK-11 | SF stake incremental promile | P0 | PASS | FVT-DC |
| ANK-12 | NF stake incremental promile | P0 | PARTIAL | Exhaustive DPNF / TRIPLET-DIAG |
| ANK-13 | Absolute resync TF after new anchor (`C_SyncTrueFungibleAnchors`) | P0 | PASS | `[6.2.4]` TX-FVT-06 |
| ANK-14 | Absolute resync SF (`C_SyncSemiFungibleAnchors`) | P0 | PASS | `[6.2.4]_AQP-FVT-DC` TX-FVT-DC-02b (**fixed** `active-nonce-count` on BenDpsfAnkMeta — select illegal in defcap) |
| ANK-15 | Absolute resync NF (`C_SyncNonFungibleAnchors`) | P0 | PASS | `[6.2.4]_AQP-FVT-NF` TX-FVT-NF-02 (mint 1 DHB + set-class anchor) |
| ANK-16 | Sync with zero stake → reject | P1 | MISSING | REJECT |
| ANK-17 | After sync, SCORE boosted stale until next stake (document + assert) | P1 | MISSING | Known design gap |
| ANK-18 | Multi-nonce SF/NF rollup + sync matches active supplies | P1 | MISSING | — |
| ANK-19 | Rain bunny anchors → Silver/Bronze/Golden aggregate promile | P0 | PASS | TRIPLET-DIAG / ANK-LP |

### 1.4 ANK out of scope this DeployXY

| ID | Item | Pri | Status |
|----|------|-----|--------|
| ANK-D01 | Neutral boost-staking custody | P2 | DEFER |
| ANK-D02 | Combined native+frozen TF promile single formula | P2 | DEFER (two rollup rows today) |

---

## 2. AQP-SCORE (`02_SCORE.pact`)

### 2.1 Issue scores (all classes)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| SCR-01 | Issue class-0 LP score (`lp-denominator` = OURO DPTF id) | P0 | PASS | BOOT Step 6 |
| SCR-02 | Issue class-1 TF score | P0 | PASS | BOOT Steps 4–5 / `[6.2.2]` |
| SCR-03 | Issue class-2 OF score | P0 | PASS | OF smoke / BOOT |
| SCR-04 | Issue class-3 SF score (`sft-equality` true/false) | P0 | PASS | `[6.2.2]` / DC |
| SCR-05 | Issue class-4 NF score (models −1 / 0 / 1) | P0 | PARTIAL | Model paths uneven |
| SCR-06 | Rotate ownership / Control flags | P1 | PARTIAL | `[6.2.2]` |
| SCR-07 | Enable deb-boost (one-way) | P1 | PARTIAL | Needs explicit expect + second-call REJECT |
| SCR-08 | Create boost-class-link (one-time) | P0 | PASS | BOOT / SCORE |
| SCR-09 | Create boost-link (foreign; no self) | P0 | PASS | Bronze/Golden → Silver |
| SCR-10 | Issue SF score definition (non-equal) | P1 | PARTIAL | — |
| SCR-11 | Issue NF trait definition | P1 | PARTIAL | — |
| SCR-12 | Issue NF set-class definition | P1 | PARTIAL | — |

### 2.2 Triplet

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| SCR-20 | `C_IssueTriplet` three same-class scores | P0 | PASS | BOOT Step 11 |
| SCR-21 | True-triplet (one hub + two satellites boost-linked) detection | P0 | PASS | Ouro LP pattern |
| SCR-22 | Standard triplet (no true-triplet geometry) | P1 | MISSING | Explicit issue + assert |
| SCR-23 | Triplet category LP / VAULT_TF / TREASURY_SF_NF | P1 | PARTIAL | LP covered; vault/treasury category asserts thin |
| SCR-24 | Class-0 triplet requires matching `lp-denominator` | P0 | PARTIAL | Cap exists; REJECT test? |
| SCR-R20 | Duplicate score in two triplets REJECT | P1 | MISSING | REJECT |
| SCR-R21 | Mixed owners / mixed classes REJECT | P1 | MISSING | REJECT |
| SCR-R22 | Self boost-link REJECT | P1 | MISSING | REJECT |

### 2.3 Links (`XE_*`)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| SCR-30 | `XE_CreateAqpoolLink` one-time | P0 | PASS | `C_AddScore` |
| SCR-31 | `XE_RevokeAqpoolLink` via `C_RevokeScore` (zero stake) | P0 | PASS | `[6.2.3]` |
| SCR-32 | `XE_CreateFvtLink` one-time via FVT `C_AddScoreEntity` | P0 | PASS | BOOT / FVT |
| SCR-R30 | Second aqpool / fvt link REJECT | P1 | PARTIAL | REJECT |
| SCR-R31 | Revoke score with non-zero totals REJECT | P0 | PASS | `[6.2.3]` |
| SCR-R32 | Revoke score while boost-link dependents exist REJECT | P0 | PASS | `[6.2.3]` triplet guard |

### 2.4 Stake weight deltas (`XE_Apply*`)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| SCR-40 | TF native stake → base/boosted/deb on employed scores | P0 | PASS | FVT TF |
| SCR-41 | TF frozen `F\|` leg separate weight | P1 | MISSING | TEST_DEFERRED §3 |
| SCR-42 | OF native stake/unstake (no ANK) | P0 | PASS | FVT-OF |
| SCR-43 | OF special `Z\|` / `H\|` multipliers | P1 | MISSING | — |
| SCR-44 | SF equal-weight stake | P0 | PASS | FVT-DC |
| SCR-45 | SF defined-nonce stake | P1 | MISSING | — |
| SCR-46 | NF model −1 / 0 / 1 stake | P1 | PARTIAL | Exhaustive DPNF |
| SCR-47 | LP class-0: DPTF LP amount → denominator-equivalent base | P0 | PASS | TRIPLET-DIAG |
| SCR-48 | LP orto `Z\|` LP path | P1 | MISSING | — |
| SCR-49 | Multi employed-ids updated in one stake | P0 | PARTIAL | Triplet pool ×3; assert all three rows |
| SCR-50 | Foreign boost-link surplus (Bronze/Golden boosted, base=0) | P0 | PASS | TRIPLET-DIAG |
| SCR-51 | Unstake clears user score to zero when full exit | P0 | PASS | TF `[6.2.4]` TX-FVT-07; OF/DC smoke |
| SCR-52 | `URD_UserScoreStakerAccounts` returns stakers with deb>0 (triplet Tier-2) | P0 | PASS | Used by FVT farm triplet settle |

### 2.5 SCORE rejects (issue / control)

| ID | Scenario | Pri | Status |
|----|----------|-----|--------|
| SCR-R40 | Precision / class / mx bounds REJECT | P2 | MISSING |
| SCR-R41 | Rotate when `can-change-owner=false` REJECT | P1 | MISSING |
| SCR-R42 | Control when `can-upgrade=false` REJECT | P1 | MISSING |
| SCR-R43 | Re-enable deb-boost REJECT | P1 | MISSING |
| SCR-R44 | SF definition when `sft-equality=true` REJECT | P1 | MISSING |

---

## 3. AQP-POOL (`03_AQP.pact`)

### 3.1 Pool admin

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| POOL-01 | Issue class-0 LP pool (asset = SWP LP id) | P0 | PASS | BOOT Step 7 DHOuroLp |
| POOL-02 | Issue class-1 TF pool | P0 | PASS | BOOT / FVT smoke |
| POOL-03 | Issue class-2 OF pool | P0 | PASS | OF smoke |
| POOL-04 | Issue class-3 SF / class-4 NF pools | P0 | PASS | BOOT / DC / DPNF |
| POOL-05 | `C_AddScore` contiguous slots, class match | P0 | PASS | `[6.2.3]` / BOOT |
| POOL-06 | `C_RevokeScore` + slot compact | P0 | PASS | `[6.2.3]` |
| POOL-07 | Disable / Enable pool stake | P0 | PARTIAL | Vacate disables; explicit toggle suite? |
| POOL-R01 | Wrong class/asset at issue REJECT | P1 | MISSING | REJECT |
| POOL-R02 | Add score class mismatch / dup / non-BAR aqpool REJECT | P1 | PARTIAL | REJECT |
| POOL-R03 | Add score when pool stake disabled? | P2 | MISSING | Document expected behavior |

### 3.2 Custody / rollups (via FVT stake phase 1)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| POOL-10 | TF transfer + tracker + `BenDptfTotal` rollup | P0 | PASS | FVT TF stake |
| POOL-11 | TF unstake clears tracker + rollup | P0 | PASS | `[6.2.4]` TX-FVT-07 |
| POOL-12 | OF transfer + tracker (no rollup by design) | P0 | PASS | FVT-OF |
| POOL-13 | SF transfer + tracker + `BenDpsf*` rollup | P0 | PASS | FVT-DC |
| POOL-14 | NF transfer + tracker + `BenDpnf*` rollup | P0 | PARTIAL | Exhaustive DPNF |
| POOL-15 | Cross-pool same beneficiary same asset → one rollup, two trackers | P1 | MISSING | TEST_DEFERRED §2 |
| POOL-16 | Beneficiary ≠ owner stake; unstake uses tracker beneficiary | P1 | MISSING | — |
| POOL-17 | Unstake rollup sufficiency guard | P1 | MISSING | REJECT |
| POOL-18 | Frozen TF separate BenDptf row | P1 | MISSING | — |

### 3.3 Sync repair

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| POOL-20 | `C_SyncTrueFungibleAnchors` happy path | P0 | PASS | `[6.2.4]` TX-FVT-06 |
| POOL-21 | `C_SyncSemiFungibleAnchors` happy path | P0 | PASS | `[6.2.4]_AQP-FVT-DC` TX-FVT-DC-02b |
| POOL-22 | `C_SyncNonFungibleAnchors` happy path | P0 | PASS | `[6.2.4]_AQP-FVT-NF` TX-FVT-NF-02 |
| POOL-R20 | Sync with no stake REJECT | P1 | MISSING | REJECT |

### 3.4 Vacate hooks (POOL XE used by VCT)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| POOL-30 | Vacate disables stake via `XB_SetPoolStakeEnabled` | P0 | PASS | VCT / OF / DC |
| POOL-31 | Finalize re-enables; Abort leaves disabled | P0 | PARTIAL | `[6.2.5]` |

---

## 4. AQP-FVT (`04_FVT.pact`)

### 4.1 Admin lifecycle

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| FVT-01 | Issue Farm (class 0) + common-denominator | P0 | PASS | BOOT Step 8 |
| FVT-02 | Issue Vault (1) / Treasury (2) with CD=`\|` | P0 | PASS | BOOT |
| FVT-03 | Rotate ownership / Control | P1 | PARTIAL | Exhaustive FVT-ADMIN |
| FVT-04 | SetCommonDenominator before any links | P1 | PARTIAL | FA03 |
| FVT-05 | SetMosaic (only with zero links) | P0 | PASS | `[6.2.4]` TX-FVT-08 |
| FVT-06 | `C_AddScoreEntity` type=1 (score) | P0 | PASS | BOOT Step 9 / smoke |
| FVT-07 | `C_AddScoreEntity` type=3 (triplet) | P0 | PASS | BOOT Step 11 |
| FVT-08 | Toggle ScoreEntityLink enable/disable | P0 | PASS | FVT smoke / FA |
| FVT-09 | Membership-mode lock (SCORE / TRUE-TRIPLET / STANDARD-TRIPLET) when mosaic=false | P0 | PASS | `[6.2.4]` TX-FVT-08 SCORE lock |
| FVT-10 | Mosaic mix score + triplet on one FVT | P1 | MISSING | Product-critical if used on mainnet |
| FVT-11 | `C_IssueMultipletFamily` OURO→Auryn→Elite | P0 | PASS | BOOT Step 10 |
| FVT-12 | `C_AddRewardLink` PLAIN (`multiplet-family-id=BAR`) | P0 | PASS | BOOT Step 12 / treasuries |
| FVT-13 | `C_AddRewardLink` MULTIPLET_BASE (family + token-0) | P0 | PASS | BOOT Step 11 OURO |
| FVT-14 | Toggle RewardLink | P1 | PARTIAL | — |
| FVT-R01 | Add entity wrong type / mode / zero ghost W REJECT | P1 | PARTIAL | REJECT |
| FVT-R02 | Add reward MULTIPLET without active family REJECT | P1 | MISSING | REJECT |
| FVT-R03 | Inject with S=0 / denom=0 REJECT | P0 | PARTIAL | Cap; explicit expect |

### 4.2 Stake flows (phases 1–5)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| FVT-20 | TF stake flow end-to-end | P0 | PASS | `[6.2.4]` |
| FVT-21 | TF **unstake** flow end-to-end | P0 | PASS | `[6.2.4]` TX-FVT-07 partial+full |
| FVT-22 | OF stake + unstake | P0 | PASS | FVT-OF |
| FVT-23 | SF stake + unstake | P0 | PASS | FVT-DC |
| FVT-24 | NF stake + unstake | P0 | PARTIAL | Exhaustive DPNF |
| FVT-25 | LP pool stake (class-0) updates triplet score weights | P0 | PASS | TRIPLET-DIAG |
| FVT-26 | Stake when FVT not ready (no reward / disabled link) REJECT | P0 | PARTIAL | Cap `URC_ScoreFvtStakeReady` |
| FVT-27 | Stake when pool disabled REJECT | P0 | PARTIAL | — |
| FVT-28 | Phase order: custody → RPS bank → ANK → SCORE → checkpoint | P1 | PARTIAL | Assert via reads after each phase in one tx hard; post-state checks OK |
| FVT-29 | Ghost TVL sync on farm stake/inject/collect | P0 | PASS | Farm S mirrors StoaValue in golden |

### 4.3 Inject / Collect / RPS

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| FVT-30 | Farm inject: `G += R/S`, available-rewards += R | P0 | PASS | triplet-collect-golden / `[6.3]` |
| FVT-31 | Vault/treasury inject: denom = sum member deb | P0 | PASS | Exhaustive RPS / `[6.3]` |
| FVT-32 | Classic score-entity collect (PLAIN) — claimable ≤ available | P0 | PASS | Exhaustive COLLECT + `[6.2.4]` TX-FVT-05 vault |
| FVT-32b | Second collect without inject → 0 payout | P0 | PASS | `[6.2.4]` TX-FVT-05 |
| FVT-33 | Triplet MULTIPLET_BASE collect — Coil/Curl lane split | P0 | PASS | TRIPLET-COLLECT golden |
| FVT-34 | Farm triplet Tier-2 divisor = Σ W_user (not Σ SCR total-deb) | P0 | PASS | Fixed; golden proves payout ≤ vault |
| FVT-35 | Multi-staker farm: inject split fair by W_i / W_user | P1 | PASS | `[6.4]_AQP-TRIPLET-COLLECT` TX-AQP-CL04 (ANHD+EMMA; payout∝W_user) |
| FVT-36 | Collect with pending banked at stake (no inject between) | P1 | PARTIAL | — |
| FVT-37 | Collect after inject with zero user weight → 0 payout | P1 | MISSING | — |
| FVT-38 | Disabled ScoreEntityLink cannot collect | P1 | MISSING | REJECT |
| FVT-39 | Disabled RewardLink cannot inject/collect | P1 | MISSING | REJECT |
| FVT-40 | Available-rewards decreases by exact payout | P0 | PARTIAL | Assert in golden |
| FVT-41 | last-rps checkpoints to L_i (farm) / G (vault) after collect | P0 | PASS | CL03 expects |
| FVT-42 | Second collect without new inject → 0 | P1 | MISSING | Idempotence |
| FVT-43 | Multi reward DPTF on one FVT (independent G) | P1 | PARTIAL | Treasuries have one each; multi on farm? |
| FVT-44 | Segmentation flag behavior (if product-relevant) | P2 | MISSING | Confirm product intent |

### 4.4 FVT mirrors / known incomplete writers

| ID | Scenario | Pri | Status | Notes |
|----|----------|-----|--------|-------|
| FVT-50 | `total-deb-score` mirror refresh vault/treasury | P1 | PARTIAL | `WU_Fvt\|TotalDebScore` used |
| FVT-51 | `total-base/boosted/nzs` FVT mirrors | P2 | DEFER | Explicitly “not yet written” in code — release note |
| FVT-52 | Mosaic + multiplet + standard score coexistence economics | P1 | MISSING | If mosaic used live |

---

## 5. AQP-VCT (`05_VCT.pact`)

### 5.1 Full vacate

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| VCT-01 | Full vacate TF (UI Legs payload) | P0 | PASS | `[6.2.5]` TX-VCT-TF01 via `aqp-deploy-gate.repl` |
| VCT-02 | Full vacate OF (UI Legs payload) | P0 | PASS | FVT-OF |
| VCT-03 | Full vacate SF (UI Legs payload) | P0 | PASS | FVT-DC |
| VCT-04 | Full vacate NF (UI Legs payload) | P0 | PASS | `[6.2.5]` TX-VCT-DPNF01 (mint probe DHB; Bloodshed-scale DEFER) |
| VCT-05 | Full vacate clears SCORE + ANK + FVT RPS state | P0 | PARTIAL | Asserts in DC/OF; TF/NF deepen |
| VCT-06 | Pool stake disabled during vacate; re-enabled on success | P0 | PASS | Vacate flow |

### 5.2 Stateless Legs vacate

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| VCT-10 | Legs auto-begin → batch(es) → finalize | P0 | PASS | `[6.2.5]` TF02 / DPNF02–03 / L01–L02 |
| VCT-11 | Continue after partial (re-split remaining) | P1 | PASS | `[6.2.5]` TX-VCT-L02 + **L05 TF multi-batch** + **L06 OF multi-batch (2 owners)** |
| VCT-12 | Abort clears vacate-in-progress; stake stays disabled | P0 | PASS | `[6.2.5]` TX-VCT-L03 |
| VCT-13 | Legs reject (bad payload / bad finalize) | P1 | PASS | `[6.2.5]` TX-VCT-N01 (empty arrays) / N02 (amount mismatch) |
| VCT-13b | `finalize=true` with leftover inventory (UI-trust) | P1 | PASS | `[6.2.5]` **TX-VCT-N03** — succeeds; stake re-enabled; leftover remains (UI must not do this) |
| VCT-14 | Gas ceilings TF/OF/SF/NF respected | P1 | PASS | `REPL/Kursan/VCT-gas-sweep.repl` → `[6.2.6]` (run in DeployXY checklist) |
| VCT-15 | LP class-0 dual-stream vacate (TF LP + OF LP) | P0 | PASS | `[6.4]` TX-AQP-CL05 / `triplet-collect-golden.repl` |
| VCT-16 | Multi-owner / multi-beneficiary Legs | P1 | PASS | FVT-DC-05 / `[6.2.5]` L02 / **L05** |
| VCT-17 | Offline plan helpers (URD + URDC_Build + UC_ComputeMinSliceCount) | P1 | PASS | `[6.2.5]` **TX-VCT-P01** |

### 5.3 VCT loader gap

| ID | Scenario | Pri | Status |
|----|----------|-----|--------|
| VCT-20 | Wire `[6.2.5]_AQP-VCT.repl` into DeployXY gate suite (or dedicated `aqp-deploy-gate.repl`) | P0 | PASS | `REPL/aqp-deploy-gate.repl` = Z + VCT |

---

## 6. AQP-BOOT (`2_SLAVE/Stage_02/04_AQP-BOOT.pact`)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| BOOT-00 | Step 0 IMC | P0 | PASS | — |
| BOOT-01 | Step 1 BunnySet | P0 | PASS | — |
| BOOT-02 | Steps 2–3 anchor classes | P0 | PASS | — |
| BOOT-04 | Steps 4–5 core + subsidiary scores | P0 | PASS | — |
| BOOT-06 | Step 6 OURO LP triplet scores + boost links | P0 | PASS | — |
| BOOT-07 | Step 7 pools (DH + OuroLp) + AddScore | P0 | PASS | — |
| BOOT-08 | Step 8 Issue FVT entities | P0 | PASS | — |
| BOOT-09 | Step 9 AddScoreEntity vault/treasury | P0 | PASS | — |
| BOOT-10 | Step 10 IssueMultipletFamily | P0 | PASS | — |
| BOOT-11 | Step 11 IssueTriplet + farm ScoreEntity + MULTIPLET reward | P0 | PASS | — |
| BOOT-12 | Step 12 AddRewardLink vault/treasury | P0 | PASS | — |
| BOOT-13 | Idempotent re-run / wrong order fails safely | P1 | MISSING | Ops safety |
| BOOT-14 | Handoff NEXT= strings match README_AQP_BOOT | P2 | PARTIAL | Doc drift check |

---

## 7. Integration scenarios (multi-module)

| ID | Scenario | Pri | Status | Evidence |
|----|----------|-----|--------|----------|
| INT-01 | End-to-end: boot → LP stake → inject OURO → MULTIPLET collect | P0 | PASS | triplet-collect-golden |
| INT-02 | End-to-end: treasury inject → score collect (G path) | P0 | PASS | `[6.3]` / RPS |
| INT-03 | End-to-end: SF stake → inject → collect → vacate | P0 | PARTIAL | Pieces exist; one continuous REPL? |
| INT-04 | End-to-end: TF stake → unstake → zero state | P0 | PASS | `[6.2.4]` TX-FVT-03→07 |
| INT-05 | End-to-end: issue new ANK after stake → sync | P0 | PASS | TF TX-FVT-06; SF TX-FVT-DC-02b; NF TX-FVT-NF-02 |
| INT-06 | Multi-user farm fairness (2 stakers, inject, both collect) | P0 | PASS | Vault TX-FVT-09; farm TX-AQP-CL04 |
| INT-07 | Disable entity link mid-accrual → collect blocked; re-enable | P1 | MISSING | — |
| INT-08 | Pool disable during stake season | P1 | MISSING | — |
| INT-09 | Comprehensive loader includes TRIPLET-COLLECT + VCT | P0 | PARTIAL | Gate = Z+VCT; farm = `triplet-collect-golden` (not one process) |
| INT-10 | Deploy gate loader: single entry that fails CI if any P0 fails | P0 | PARTIAL | Run triad: `Z.repl` / `aqp-deploy-gate.repl` / `triplet-collect-golden.repl` — no single CI wrapper yet |

---

## 8. DeployXY execution plan (ordered)

Walk in this order when implementing REPL coverage:

### Wave A — Close P0 holes (blockers)

1. **TF unstake** (FVT-21 / POOL-11 / SCR-51 / INT-04)
2. **Anchor sync repair** TF + SF + NF (ANK-13..15 / POOL-20..22 / INT-05)
3. **LP dual-stream vacate** (VCT-15) — if OuroLpFarm is in DeployXY scope
4. **Wire VCT + TRIPLET-COLLECT into deploy gate** (VCT-20 / INT-09 / INT-10)
5. **Assert available-rewards / second-collect / payout ≤ vault** on golden paths (FVT-40 / FVT-42)

### Wave B — P1 fairness & guards

6. Multi-staker farm RPS (FVT-35 / INT-06)
7. Cross-pool rollup + beneficiary≠owner (POOL-15..17)
8. Explicit REJECT suites (ANK-R*, SCR-R*, FVT-R*, VCT-13)
9. Mosaic / membership-mode (FVT-09 / FVT-10) if product uses them
10. Frozen TF / OF special prefixes (SCR-41 / SCR-43)

### Wave C — P2 / release notes

11. Gas ladders confirmed for production gas limits
12. Document DEFER: FVT mirror writers (FVT-51), combined frozen promile, neutral boost-stake
13. Doc rename pass: README_TRIPLET TripletFamily → MultipletFamily / ScoreEntity (non-blocking)

---

## 9. Suggested new REPL files (after this list is approved)

| Proposed file | Covers |
|---------------|--------|
| `REPL/Stage_02/[6.5]_AQP-TF-UNSTAKE.repl` | Wave A.1 |
| `REPL/Stage_02/[6.5]_AQP-SYNC-REPAIR.repl` | Wave A.2 |
| `REPL/Stage_02/[6.5]_AQP-LP-VACATE.repl` | Wave A.3 |
| `REPL/Stage_02/[6.5]_AQP-FARM-MULTI-STAKER.repl` | Wave B.6 |
| `REPL/Stage_02/[6.5]_AQP-REJECTS.repl` | Wave B.8 (batched REJECT expects) |
| `REPL/aqp-deploy-gate.repl` | Loads Z + VCT (TF/OF/SF/NF vacate + rejects + multi-batch + offline plan + finalize-trust; DPNF mint probe); run `triplet-collect-golden.repl` + `Kursan/VCT-gas-sweep.repl` separately |

---

## 10. DeployXY DEFER release notes (X-07)

Document these as known out-of-scope / deferred for this DeployXY:

| Item | Why DEFER |
|------|-----------|
| Bloodshed / Nosferatu / Bunnies **scale** vacate | Probe mint covers logic on AQP-FAST; Populate* scale is FULL Stage02 only |
| ANK-D01 Neutral boost-staking custody | Product path deferred |
| ANK-D02 Combined native+frozen TF promile | Two rollup rows today |
| FVT mirror writers (FVT-51) | Ops surface not required for smoke |
| Single CI process for all P0 (INT-10) | Triad of loaders is the gate; unify later if desired |

---

## 11. Current verdict (Wave B)

| Area | Deploy-ready? |
|------|----------------|
| BOOT 0–12 | Yes |
| ANK issue + promile on stake + **TF + SF + NF sync repair** | Yes (TF TX-FVT-06; SF TX-FVT-DC-02b; NF TX-FVT-NF-02; **`active-nonce-count`** on Ben*AnkMeta) |
| SCORE stake/unstake weights (TF vault) | Yes |
| POOL TF custody stake/unstake + sync stamp | Yes (**fixed** `WU_BenDptfTotal\|LastAnkSyncCount`) |
| FVT farm triplet MULTIPLET collect | Yes (`triplet-collect-golden`) |
| FVT vault PLAIN inject/collect/2nd-collect | Yes (`[6.2.4]` TX-FVT-05) |
| FVT TF partial+full unstake | Yes |
| FVT mosaic / non-mosaic SCORE lock | Yes (`member-link-count` gate) |
| FVT multi-staker vault inject fairness | Yes (`[6.2.4]` TX-FVT-09 60/40) |
| FVT multi-staker farm LP fairness | Yes (`TX-AQP-CL04` payout∝W_user; needs Rain bunny promile) |
| VCT TF/OF full+sliced + abort/reject | Yes in `aqp-deploy-gate.repl` |
| VCT DPNF vacate (mint probe DHB/DHN/KBN) | Yes on AQP-FAST (`TX-VCT-DPNF01..03`) |
| VCT LP dual-stream vacate (TF + Z\| OF) | Yes (`TX-AQP-CL05` in `triplet-collect-golden`) |

**Bottom line:** DeployXY smoke triad is green — `Z.repl`, `aqp-deploy-gate.repl` (incl. DPNF mint-probe), `triplet-collect-golden.repl` (incl. multi-staker farm CL04 + **LP dual-stream vacate CL05**). Remaining open items are mostly P1 REJECT suites / PARTIAL deepeners, not P0 blockers.

---

*Generated as the plan of record for DeployXY AQP testing. Update status marks in-place as REPL scenarios land.*
