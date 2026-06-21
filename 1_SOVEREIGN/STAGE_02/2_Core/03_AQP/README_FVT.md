# AQP-FVT -- Farms, Vaults, and Treasuries

Module: `AQP-FVT` | Interface: `AcquisitionFarmsVaultsTreasuriesV1` | File: `04_FVT.pact`

**Status: Stub module — schemas and forward cap / `XE_*` sketched; `C_*` bodies still placeholders.**

## Purpose

FVTs register member scores and reward tokens, hold injected rewards, and distribute them with **Reward-Per-Share (RPS)** accounting.

**Farms (class 0)** use a **two-tier** model so injections split by **pool economic weight** (ghost TVL in STOA-equivalent units maintained in **SWP**), while **users** still accrue inside each LP score by **deb-score** (Tier‑1). **Vaults / Treasuries** may keep a simpler single-tier path until fully specified.

## Ghost TVL, SWP, and AQP — how linking is visualized

1. **SWP** owns pool reserves. After each **swap**, **add-liquidity**, or **remove-liquidity**, SWP recomputes and stores a **ghost TVL** for that `swpair` (e.g. pool value in STOA with a fixed peg policy so the number is stable for accounting — exact formula lives in SWP).

2. **`SWP::XE_RefreshGhostTvlForSwpair` (planned)**  
   Forward entry: **no `enforce` in `XE_*`** — the `defcap` on the SWP side validates caller / pair state. It **only** updates SWP tables (ghost TVL for that pair).

3. **AQP-POOL orchestrates**  
   The pool client flow already runs inside AQP after SWP mutates reserves. AQP:
   - Calls `SWP::XE_RefreshGhostTvlForSwpair` for the affected `swpair`, then  
   - For each **employed score** on that pool that participates in a farm (`fvt-link` + enabled `FVT|T|ScoreLink`), calls  
     **`FVT::XE_SyncFarmScoreGhostTvlFromSwp(fvt-id score-id)`**.

   So **FVT is not scanned by swpair inside SWP**; **AQP carries the bounded list** (scores attached to this pool, typically ≤ 7 per pool). No O(all farms) work on the hot path.

4. **`FVT::XE_SyncFarmScoreGhostTvlFromSwp`** (under `FVT|XE>SYNC-SCORE-GHOST-TVL`)  
   - Reads the new ghost TVL from SWP using **`FVT|T|ScoreLink.swpair`** (stored when the score link was admitted — denormalized from Pool → native LP id → `SWP::UR_GetLpSwpair`).  
   - **Settles Tier‑2** for that tranche at the old `ghost-tvl-weight`, updates **`FVT|T.total-ghost-tvl-weight` (`S`)** by `(new_W - old_W)`, writes new `ghost-tvl-weight`, advances `last-farm-rps-g` as per pseudocode in `04_FVT.pact`.

**Injection** does **not** loop over pools: it only does `G += R / S` on `FVT|T|RPS|Global` when `S = total-ghost-tvl-weight > 0`.

## Two-tier RPS (farms)

| Tier | Who | Index / weight | Role |
|------|-----|------------------|------|
| **Tier 2** | Farm + each **member score** (tranche) | `FVT|T|RPS|Global.current-rps` = **G** (one **G** per registered reward **DPTF**); denominator **S** = `FVT|T.total-ghost-tvl-weight` (sum of enabled links’ **W_i** — same role as a pool-wide “weight total”, analogous in spirit to how **deb** totals back Tier‑1); per tranche `ghost-tvl-weight` = **W_i**, `last-farm-rps-g` = **g_i** vs that row’s **G** | Splits each injection **for that reward token** across tranches by TVL weight |
| **Tier 1** | Each **user** inside a score | `FVT|T|ScoreLink.tranche-deb-rps` = **L_i**; `FVT|T|RPS|User.last-rps` checkpoints **L_i** (row keyed by user + fvt + score + **same DPTF**) | Splits each tranche’s accrued rewards for that token across users by **deb-score** |

**Token-agnostic vs token-scoped:** **S** and **W_i** depend only on SWP ghost TVL and membership — no reward DPTF in the key. **G**, user **pending-rewards**, and **last-rps** are **per reward DPTF** (`FVT|T|RPS|Global` / `FVT|T|RPS|User`). **`last-farm-rps-g`** on `FVT|T|ScoreLink` is a checkpoint against **G**; if a farm ever registers **multiple** reward DPTFs with **independently moving G**, the implementation must either (a) treat **one reward DPTF per farm** on v1 hot paths, or (b) extend storage (e.g. per `(fvt-id, score-id, dptf-id)` Tier‑2 checkpoint) so each **G** has its own **g_i**.

If a tranche has **no stakers** (`SCR` total deb for that score = 0), Tier‑2 accrual for that tranche is parked in **`pending-tranche-rewards`** until `L_i` can advance (see ACTION comments in `04_FVT.pact`).

## Where each number lives (implementation map)

| Layer | Table | Farm fields / role |
|-------|-------|---------------------|
| Farm aggregate | `FVT|T` | **`total-ghost-tvl-weight` (`S`)** — Tier‑2 denominator; maintain as sum of **enabled** `FVT|T|ScoreLink.ghost-tvl-weight`. **`total-deb-score`** (and other totals) remain SCORE mirrors for reporting; Tier‑1 splitting uses **per-score** deb from SCORE, not necessarily this row alone. |
| Per tranche (score) | `FVT|T|ScoreLink` | **`swpair`**, **`ghost-tvl-weight` (`W_i`)**, **`last-farm-rps-g` (`g_i`)**, **`tranche-deb-rps` (`L_i`)**, **`pending-tranche-rewards`** |
| Per reward token (farm-wide index) | `FVT|T|RPS|Global` | **`current-rps` (`G`)**, **`available-rewards`**, inject/collect gates, etc. — key `(fvt-id, dptf-id)` |
| Per user × tranche × reward | `FVT|T|RPS|User` | **`last-rps`**, **`pending-rewards`** — key adds **dptf-id** |

## Execution order (same transaction, when Pact is wired)

Liquidity-changing paths are expected to follow this **dependency-safe** order (SWP never calls FVT):

1. **SWP** mutates reserves (swap / add / remove liq) and, at end of that path, updates its **ghost TVL** row for the `swpair` (source of truth).
2. **`SWP::XE_RefreshGhostTvlForSwpair`** — forward entry in SWP; refreshes only SWP tables.
3. **AQP-POOL** (or equivalent composer **after** SWP in the tx) calls **`FVT::XE_SyncFarmScoreGhostTvlFromSwp`** for each **(fvt-id, score-id)** tied to that pool (bounded list), which: reads ghost TVL from SWP via the link’s **`swpair`**, runs **Tier‑2 settle** at old **W_i**, writes new **W_i**, adjusts **`FVT|T.total-ghost-tvl-weight`** by **ΔW**.
4. **`C_Inject`** for a given **dptf-id**: farm path **`G += R / S`** on that token’s **`FVT|T|RPS|Global`** row when **`S > 0`** (no pool scan).
5. **Stake / unstake / collect** (see ACTION block in `04_FVT.pact`): settle **Tier‑2** (tranche earns vs **G** and **W_i** / **g_i**), push into **L_i** or **`pending-tranche-rewards`**, then **Tier‑1** vs user **deb** and **`FVT|T|RPS|User`**.

If a transaction **only** touches SWP and skips steps 2–3, **FVT** rows can remain stale until a later tx runs the sync — document that at the pool / client policy level.

## FVT Classes

| Class | Type | Description |
|-------|------|-------------|
| 0 | Farm | Member LP scores; `common-denominator`; two-tier RPS + ghost TVL from SWP |
| 1 | Vault | Non-LP scores; farm-only ScoreLink columns use sentinel `|` / zeros until vault RPS is specified |
| 2 | Treasury | General-purpose aggregator |

## Common denominator (farms only)

For class-0 FVTs, `common-denominator` is the **full native DPTF token-id** of the shared pool leg (e.g. `OURO-98c486052a51`), not a ticker alone. It must match every admitted member score’s `lp-denominator`. On `C_AddScoreLink`, FVT validates against `SCORE` and sets `fvt-link` on the score via `XE_CreateFvtLink`.

## Multi-LP farms (one FVT, many pools)

A **single Farm FVT** can aggregate **many OURO-denominated LPs** that share the same `common-denominator`. **Step-by-step onboarding:** [README.md § OURO LP onboarding flow](README.md#ouro-lp-onboarding-flow-per-lp-line).

Users **stake in AQP pools**, not in the FVT; the farm only registers member scores and splits injected rewards.

### Entity pattern (per distinct LP)

Each native LP line gets its **own** provisioning chain:

1. **Issue** a class-0 pool (`C_Issue`) with that LP’s native `asset-id`.
2. **Issue** a score set for that LP (bootstrap uses a **triplet**: Silver / Bronze / Golden class-0 scores with shared `lp-denominator` — see `AQP-BOOT` Step 6).
3. **`C_AddScore`** on the pool for each score (≤ 7 slots per pool; triplet uses 3).
4. **`C_AddScoreLink`** on the farm **once per score** — one permanent `FVT|T|ScoreLink` row per `(fvt-id, score-id)`.

```
Farm FVT (common-denominator = OURO-…)
  ├── ScoreLink ← Silver₁   (pool LP₁, swpair₁, W₁)
  ├── ScoreLink ← Bronze₁
  ├── ScoreLink ← Golden₁
  ├── ScoreLink ← Silver₂   (pool LP₂, swpair₂, W₂)
  …
  └── (typically 3 ScoreLink rows per LP when using the OURO triplet)
```

**Injection** updates farm-wide **G** using **S = Σ W_i** over **enabled** links. Each link keeps its own **`swpair`** and **`ghost-tvl-weight`**, so different LPs with the same OURO leg still split by economic weight.

### One-time links (cannot share scores across pools)

| Field | Rule |
|-------|------|
| `aqpool-link` | One score → **one** employing pool. A second LP needs **new** score issuances. |
| `fvt-link` | One score → **one** FVT. Many scores may point at the **same** farm id. |

Adding a second LP is **not** “attach the same triplet to another pool”; it is **new pool + new triplet + new `C_AddScoreLink` calls**.

### Scale (ScoreLink row count)

| LPs on farm | Triplet (3 scores/LP) | `FVT|T|ScoreLink` rows |
|-------------|----------------------|-------------------------|
| 1 | yes | 3 |
| 2 | yes | 6 |
| 10 | yes | 30 |
| 20 | yes | 60 |

There is **no protocol cap** on how many ScoreLink rows one farm may hold. Row count is a **product choice** (scores per LP), not a table limit.

**Hot-path cost stays bounded per pool:** when SWP liquidity changes on one pair, AQP syncs ghost TVL only for scores **employed on that pool** (≤ 7), not for every link on the farm. Avoid single transactions that settle or sync **all** farm members at once — use per-pool orchestration and `C_ToggleScoreLink` to disable a tranche without deleting its row.

If 3 links per LP is heavy for ops or gas planning, issue **one** class-0 score per LP instead of a triplet; the farm model is unchanged.

## Schema field tags (same legend as `SCR|Schema` in AQP-SCORE)

| Tag | Meaning |
|-----|---------|
| `[.]` | Fixed at issue (or at row creation for link tables) |
| `[..]` | Fixed after the admission write |
| `[M]` | Mutable under normal operations |
| `[Mu]` | Mutable only under owner + `can-upgrade` rules |

## Score links (`FVT|T|ScoreLink`)

Permanent row per `(fvt-id, score-id)`; **`enabled`** `[M]` toggles participation in **`S`** and user accrual.

**Farm (parent `fvt-class` 0) only — Tier‑2 / Tier‑1 columns**

| Column | Role |
|--------|------|
| `swpair` | SWP pair id at admission `[..]` |
| `ghost-tvl-weight` | **W_i**, from SWP ghost TVL `[M]` |
| `last-farm-rps-g` | Checkpoint vs farm **G** `[M]` |
| `tranche-deb-rps` | Tier‑1 **L_i** `[M]` |
| `pending-tranche-rewards` | Buffer when tranche has no deb stakers `[M]` |

**Vault / Treasury:** same columns exist; for now store `swpair` = `"|"`, numerics `0.0`, until a vault/treasury RPS layout is defined.

## Reward + RPS tables (no separate RewardLink)

Reward registration uses **one row per `(fvt-id, dptf-id)`** in **`FVT|T|RPS|Global`**. There is **no** `FVT|T|RewardLink` table: **`reward-enabled`** on that row replaces the old `FVT|RewardLink.enabled` flag and gates **`C_Inject`** / **`C_Collect`**.

- **`FVT|T|RPS|Global`** — `reward-enabled`, farm **G** (`current-rps`), `available-rewards`, `unclaimed-count`, `segmentation` (see `04_FVT.pact` for `[.]` / `[M]` per field).
- **`FVT|T|RPS|User`** — per `(user-id, fvt-id, score-id, dptf-id)`: Tier‑1 checkpoint against **L_i** for that score tranche.

**Composite key (user row):** `Ouronet-Account | FVT-ID | Score-ID | DPTF-ID`

## Planned `C_` / `XE_` surface

| Symbol | Purpose |
|--------|---------|
| `C_Issue` | Create FVT |
| `C_AddScoreLink` | Admit score; set `swpair`, initial ghost weights / checkpoints; call `SCORE::XE_CreateFvtLink` |
| `C_ToggleScoreLink` | Enable/disable member |
| `C_AddRewardLink` / `C_ToggleRewardLink` | Insert / toggle `FVT|T|RPS|Global` (same key as reward row; `reward-enabled`) |
| `C_Inject` | Deposit reward; farm: `G += R / S` |
| `C_Collect` | User claim through Tier‑2 settle + Tier‑1 line |
| `SWP::XE_RefreshGhostTvlForSwpair` | *(SWP module)* refresh ghost TVL row for one pair |
| `FVT::XE_SyncFarmScoreGhostTvlFromSwp` | *(this module)* AQP calls after SWP refresh; Tier‑2 settle + `W_i` / `S` update |

## Relationship to other modules

- **SCORE**: Per-user deb / score totals for Tier‑1; `fvt-link` on scores.
- **SWP**: Source of truth for reserves and **ghost TVL** per `swpair`; `XE_RefreshGhostTvlForSwpair` runs after liquidity events.
- **AQP-POOL**: Orchestrates `SWP::XE_*` then `FVT::XE_SyncFarmScoreGhostTvlFromSwp` for affected pool scores (bounded fan-out).
- **ANK**: Boosting remains inside SCORE rows read at stake/collect.

## FVT-Link validation (score admission)

1. `aqpool-link ≠ BAR` on the score  
2. Compatible `score-class` vs `fvt-class`  
3. Farm: `lp-denominator == common-denominator`  
4. Persist **`swpair`** on `FVT|T|ScoreLink` from pool → LP → `SWP::UR_GetLpSwpair`  
5. `SCORE::XE_CreateFvtLink`
