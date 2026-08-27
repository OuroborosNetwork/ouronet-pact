# AQP Triplet Architecture — Score Bundles & Multi-Level Reward Payout

Module context: `AQP-SCORE` (`02_SCORE.pact`) · `AQP-FVT` (`04_FVT.pact`) · `AQP-POOL` (`03_AQP.pact`)  
Status: **Design spec (pre-implementation)** — canonical reference for protocol work and user-facing docs.

Related: [README_SCORE.md](README_SCORE.md) · [README_FVT.md](README_FVT.md) · [README_AQP.md](README_AQP.md)

---

## 1. Purpose

A **Triplet** is a bundle of **three SCORE rows** (bronze / silver / golden) that stake together and accrue farm rewards as **one membership unit**, while **collect** may pay **three payout lanes** via the autostake token ladder (OURO → Auryn → Elite-Auryn).

A **TripletFamily** is a **reward-layer** definition: three DPTF ids + ATS pair ids used at **collect** to coil/curl the base inject token into higher tiers.

**Critical separation:**

| Concept | Layer | Bound to reward family? |
|---------|--------|-------------------------|
| Triplet `T\|…` | SCORE (stake bundle) | **No** |
| TripletFamily `F\|…` | FVT (payout ladder) | N/A (it *is* the family) |
| TripletLink | FVT (farm/vault/treasury membership) | **No** |
| `RPS\|Global` | FVT (inject target) | Per **dptf-id**; optional family metadata |

One triplet can participate in **multiple** TripletFamily reward rails on the same FVT entity (e.g. OURO-base family F1 and D-base family F2), plus **plain** DPTF rewards (e.g. VESTA).

---

## 2. Product intent

1. User stakes LP (or vault/treasury asset) → three SCORE user rows update (existing stake path).
2. Rain bunnies (or future anchors) set **lane promile** on bronze / silver / golden BoostClasses.
3. Admin injects **base token** (typically OURO) into FVT vault.
4. User collects → **lane split** of claimable base:
   - **Bronze lane** → base token (OURO) direct
   - **Silver lane** → coiled (OURO → Auryn)
   - **Golden lane** → curled (OURO → Auryn → Elite-Auryn)

Bunnies do **not** change inject token; they change **lane weights** at collect.

---

## 3. Identity & key composition

### 3.1 TripletFamily (reward ladder)

```
Key: F|<token-0-id>|<token-1-id>|<token-2-id>
```

Example: `F|OURO-…|AURYN-…|ELITE-AURYN-…`

| Field | Role |
|-------|------|
| `token-0-id` | Position 1 — **only** token admin injects for this family |
| `token-1-id` | Position 2 — produced by **Coil** at collect (never injected) |
| `token-2-id` | Position 3 — produced by **Curl** at collect (never injected) |
| `ats-0-1-id` | ATS pair: token-0 → token-1 |
| `ats-1-2-id` | ATS pair: token-1 → token-2 |
| `active` | Governance toggle |

**Issued in FVT** (recommended): families are consumed only by reward registration and collect.

### 3.2 Triplet (score bundle)

```
Key: T|<bronze-score-id>|<silver-score-id>|<golden-score-id>
```

| Field | Role |
|-------|------|
| `bronze-score-id` | First id slot in composite key |
| `silver-score-id` | Second id slot in composite key |
| `golden-score-id` | Third id slot in composite key |
| `triplet-category` | `LP` \| `VAULT_TF` \| `TREASURY_SF_NF` (from shared **score-class** at issue) |
| `true-triplet` | `true` when one score has `boost-link = BAR` and the other two boost-link to it (boost-anchored / lane-ready); else standard bundle |

**No `triplet-family-id` on this row.**

Each constituent score row (`SCR|T|Score`) carries **`triplet:bool`** (false at issue, true once bundled — immutable) and **`triplet-id:string`** (`BAR` until issue, then `T|…`). Duplicate `(bronze, silver, golden)` combos are rejected by **`WI_Triplet` insert**; per-score reuse is blocked by the **`triplet`** flag.

**Issuance:** any three distinct scores with the **same owner**, **same score-class** (stricter than category band — no mixing DPTF/DPOF or SF/NF), and (for class 0) identical **`lp-denominator`**. Boost topology is **not** required at issue.

**FVT `mosaic` policy** (on `FVT|T`, default `true` at issue):

| `mosaic` | Admission |
|----------|-----------|
| `true` | Any mix of `ScoreLink` + `TripletLink` (standard or true) |
| `false` | Locked by **first** member added: `SCORE` → score links only; `TRUE-TRIPLET` / `STANDARD-TRIPLET` → matching triplet kind only |

Flip `mosaic` via `C_SetMosaic` only while the FVT has **zero** member links (toggle does not remove rows — disable with `C_ToggleScoreLink` / `C_ToggleTripletLink` instead).

### 3.3 TripletLink (FVT membership)

```
Key: <FVT-ID> | <Triplet-ID>
```

| Field | Farm (class 0) | Vault / Treasury |
|-------|----------------|------------------|
| `enabled` | bool | bool |
| `swpair` | SWP pair from native LP | `\|` (BAR sentinel) |
| `ghost-tvl-weight` `W_i` | From SWP ghost TVL at admission | `0.0` (see §7.2) |

### 3.4 Anchor id (RPS accrual key component)

| Membership | `anchor-id` in RPS Member/User |
|------------|--------------------------------|
| TripletLink | `triplet-id` (`T\|…`) |
| ScoreLink (classic) | `score-id` |

---

## 4. Triplet issuance flow (SCORE)

```
1. C_IssueTripletFamily (FVT)     — once per ladder on chain
2. C_IssueLiquidityScore × 3      — or vault/treasury score types (§5)
3. C_CreateScoreBoostClassLink × 3
4. C_CreateScoreBoostLink        — bronze→silver, golden→silver
5. C_IssueTriplet                 — T|bronze|silver|golden
6. C_AddScore × 3 (AQP-POOL)      — employ scores on pool / vault path
7. C_AddTriplet (FVT)             — admit bundle to FVT entity
8. C_AddRewardLink (FVT via Talos) — one row per reward DPTF; optional triplet-family-id for ladder metadata
```

Repeat steps 2–7 for each additional LP line (new score names + new triplet id).

---

## 5. Category rule (not LP-only)

All three scores in a triplet **must share the same score-class** (0–4) and therefore the same FVT membership category:

| Category | SCORE classes | FVT `fvt-class` | Typical use |
|----------|---------------|-----------------|-------------|
| **LP** | class **0** only | **0** Farm | OURO LP farms |
| **Vault TF** | class **1** DPTF (class **2** DPOF is a separate class — do not mix) | **1** Vault | TF vault bundles |
| **Treasury SF/NF** | class **3** DPSF / **4** DPNF (do not mix) | **2** Treasury | SF/NF treasury bundles |

Enforced at `C_IssueTriplet` (same score-class) and again at `C_AddTriplet` (FVT class must match category).

### True triplet vs standard triplet

| Kind | Boost topology | When `mosaic = false` on FVT |
|------|----------------|------------------------------|
| **Standard triplet** | Any boost-link layout | Locks FVT to `STANDARD-TRIPLET` if added first |
| **True triplet** (`true-triplet = true`) | Exactly one score with `boost-link = BAR`; the other two boost-link to that score | Locks FVT to `TRUE-TRIPLET` if added first |

Computed at issue by `URC_IsTrueTriplet` (three score ids; reads boost-links). LP bronze/silver/golden with satellites boosting silver is the canonical true triplet.

All three categories (LP farms, vault TF, treasury SF/NF) ship in **one implementation** — same tables, same RPS key shape; Tier-2 weight source differs by `fvt-class` (§7).

---

## 6. FVT table extensions

Existing tables **retained**:

```pact
FVT|T
FVT|T|ScoreLink          ;; vaults, treasuries, classic farm members, hybrid score tranche
FVT|T|RPS|Global
FVT|T|RPS|Member
FVT|T|RPS|User
```

**New:**

```pact
FVT|T|TripletFamily:{FVT|TripletFamily}
FVT|T|TripletLink:{FVT|TripletLink}
```

**Extended `FVT|RPS|Global`** (same key `fvt-id | dptf-id`) — **one atomic registration per reward token**:

| Field | Values |
|-------|--------|
| `triplet-family-id` | `BAR` — plain collect on all anchors; `F\|…` — ladder metadata when `dptf-id` = family token-0 (triplet anchors may Coil/Curl at collect; score anchors stay plain) |
| `reward-kind` | Derived at add from family-id (internal bookkeeping; **collect branches on anchor type**, not a second registration) |

**Extended RPS Member / User keys** — generalize `score-id` → **`anchor-id`**:

```
Member:  fvt-id | anchor-id | dptf-id
User:    user-id | fvt-id | anchor-id | dptf-id
```

`anchor-id` = `triplet-id` or `score-id`. `dptf-id` = inject/accrual token (OURO, D, VESTA, …).

---

## 7. RPS tiers — farms & vaults

There is **no separate “hybrid” product or mode**. An FVT entity simply admits **zero or more** `TripletLink` rows and **zero or more** `ScoreLink` rows. Tier-2 always sums **all enabled members** into one inject divisor `S` — for farms (ghost `W_i`), vaults, and treasuries (deb sum per §7.2).

### 7.1 Farms (class 0) — ghost TVL Tier-2

**Unchanged core:** one `G` per `(fvt, dptf-id)` on inject.

**Membership set `S`** (inject divisor for Tier-2):

```
S = Σ W_i   over all enabled TripletLinks
  + Σ W_j   over all enabled ScoreLinks
```

Inject `R` of base token:

```
ΔG = R / S
Each member tranche earns ΔG × (W_member / S)  →  advances that anchor’s L_i (Tier-1 index)
```

**Example (triplet + score on same farm):** `W_triplet = 80`, `W_score = 20` → 80% of index growth goes to the triplet tranche, 20% to the score tranche. No flag, no alternate code path — just two link rows in `S`.

**Tier-1 per user:**

| Anchor type | User weight | Accrual |
|-------------|-------------|---------|
| Triplet | `W_user = lane_b + lane_s + lane_g` (§8) | `pending + W_user × ΔL_triplet` |
| Score | `deb-score` on that score | `pending + deb × ΔL_score` |

**deb-score semantics (SCORE):** `deb-score` is the **final user weight** for that score row. When deb machinery is off, the deb multiplier is **1** — so `deb-score` equals the effective stake weight (same role as “non-deb” score in product terms). FVT reads `deb-score` for classic `ScoreLink` accrual; it does **not** invent a parallel weight field. Each score in a triplet keeps its own SCORE definition (deb on/off, boost links, creation path); the triplet only **unifies** them at the FVT membership layer.

### 7.2 Vaults & treasuries (class 1 / 2) — deb-weight Tier-2

Vault/treasury RPS is **not fully specified** today ([README_FVT.md](README_FVT.md) § class table). When a vault/treasury admits **both** `TripletLink` and `ScoreLink` rows against the same inject token, the **same multi-member `S` pattern** applies — but weights come from **SCR aggregate deb**, not SWP ghost TVL:

```
S = Σ D_triplet_k   (one deb weight per triplet anchor k)
  + Σ D_score_m     (total deb per score anchor m)
```

Each tranche receives inject share `R × (D_member / S)` before Tier-1 user accrual.

| Link type | Tier-2 weight | `swpair` |
|-----------|---------------|----------|
| TripletLink | Sum of `total-deb-score` across the triplet’s three score ids (each score’s existing SCR mirror) | `\|` |
| ScoreLink | That score’s `total-deb-score` (existing vault mirror) | `\|` |

**Yes — vault/treasury with triplet + score needs Tier-2 tranche rewards** when both anchors share one inject token. Without the split, inject would mis-allocate across anchors.

No special “composite deb” formula beyond **unifying three independently-defined scores**: each score already maintains its own `total-deb-score`; the triplet tranche weight is their sum.

### 7.3 Tier-2 on triplet-internal bronze/silver/golden?

**No.** Bronze, silver, golden are **not** separate FVT tranches. They are **lane weights inside one triplet anchor** used only at **collect** (§8). FVT Tier-2 tranches are **TripletLink vs ScoreLink** (and multiple TripletLinks for multiple LP lines).

---

## 8. Lane weights & collect split

Derived at stake settle / collect from SCORE + ANK (no SCORE table keyed to pool-id):

```
pool-id  = UR_SCR|ScoreAqpoolLink(silver-score-id)
base     = UR_U-SCR|UserScoreBaseScore(user, pool, silver)

prom_b   = UR_UB|AggregatePromile(user, bronze boost-class)
prom_s   = UR_UB|AggregatePromile(user, silver boost-class)
prom_g   = UR_UB|AggregatePromile(user, golden boost-class)

lane_b   = floor(base × prom_b / 1000, p)
lane_s   = floor(base × prom_s / 1000, p)
lane_g   = floor(base × prom_g / 1000, p)
W_user   = lane_b + lane_s + lane_g
```

Only lanes with weight `> 0` participate in split (re-normalize over active lanes).

**Collect** `CC_Collect(patron, fvt-id, anchor-id, reward-dptf-id)`:

```
global = RPS|Global(fvt, reward-dptf-id)

if global.reward-kind = PLAIN:
  ;; Classic path — anchor must be score-id (or triplet disallowed)
  claimable = deb × ΔL + pending
  TFT transfer reward-dptf-id to patron

if global.reward-kind = TRIPLET_BASE:
  ;; anchor-id must resolve to TripletLink
  enforce global.triplet-family-id matches family registry
  claimable = W_user × ΔL + pending   ;; on (user, fvt, triplet-id, reward-dptf-id)

  split claimable by lane_b : lane_s : lane_g (active lanes only)

  bronze portion → TFT token-0 (direct)
  silver portion → ATSU C_Coil  (token-0 → token-1)
  golden portion → ATSU C_Curl  (token-0 → token-1 → token-2)
```

Positions 2 and 3 of a family are **never injected**; they appear only via ATS at collect.

---

## 9. Multiple TripletFamilies on one FVT

Same triplet bundle, parallel reward lines:

```
Global(fvt, OURO)  → TRIPLET_BASE + F|OURO|AURYN|ELITE
Global(fvt, D)     → TRIPLET_BASE + F|D|D2|D3
Global(fvt, VESTA) → PLAIN
```

Parallel RPS rows per staker:

```
(user, fvt, triplet-id, OURO)
(user, fvt, triplet-id, D)
```

Stake/unstake settles pending on **each** enabled Global where the user has weight on that anchor.

**Do not** duplicate `T|…` rows for a second family — that would duplicate `W_i` and break `S`.

---

## 10. What one farm may contain

| Configuration | Allowed |
|---------------|---------|
| Multiple TripletLinks (multiple LP lines) | Yes — same lp-denominator policy |
| TripletLink(s) + ScoreLink(s) | Yes — normal multi-member farm (§7.1) |
| ScoreLink only | Yes — classic farm |
| One `C_AddRewardLink` per reward DPTF | Yes — OURO with `F\|…` covers score + triplet anchors on same inject |
| PLAIN token (VESTA) + OURO with family on same FVT | Yes — separate globals per dptf-id |

**Farm admission lock (triplet links):** all TripletLinks on one farm share the same **score category / lp-denominator** policy — **not** the same TripletFamily.

---

## 11. Multi-member collect walkthrough

**Setup:** Farm with `TripletLink` (`W=80`) + `ScoreLink` score-X (`W=20`). One `Global(OURO, TRIPLET_BASE, F1)`.

**Inject 100 OURO:** Tier-2 assigns ~80 index units to triplet tranche, ~20 to score-X tranche.

**User A** (triplet LP only): collects via `CC_Collect(patron, farm, T|…, OURO)` → lane split → OURO + Auryn + Elite.

**User B** (score-X only): collects via `CC_Collect(patron, farm, score-X, OURO)` → plain OURO only (even though Global is TRIPLET_BASE, **anchor** is a score → PLAIN branch for that anchor).

**User C** (both): two user rows, two collects (or one Talos composite tx).

Total OURO received = OURO leg from triplet collect + full amount from score collect (if both positions exist).

---

## 12. SCORE vs FVT responsibilities

| Responsibility | Module |
|----------------|--------|
| Issue scores, boost links, triplet registry | SCORE |
| Issue triplet family, triplet link, reward globals | FVT |
| LP / vault stake, employ scores | AQP-POOL |
| Lane promile | ANK (read by FVT `URC_*`) |
| Coil / Curl at collect | ATSU (called from FVT via cap composition) |
| Client entry | Talos `AQP-FVT|C_AddRewardLink` (triplet-family-id BAR or F\|…) · `CC_Collect` |

---

## 13. Migration from current boot

Current boot (Step 9): `C_AddScoreLink × 3` per LP triplet on farm.

Target boot:

```
Step 6:  issue scores (unchanged)
NEW:     C_IssueTriplet per LP line
Step 9:  C_AddTriplet × N  (replaces 3× ScoreLink per LP)
Step 10: C_AddRewardLink(farm, VESTA, …, BAR)           — plain side token
         C_AddRewardLink(farm, OURO, …, F|OURO|AURYN|ELITE) — one OURO row; score + triplet anchors share inject
         optional plain links alongside triplet-base
```

Existing `CC_Collect` vault/treasury paths and ScoreLink-only farms remain valid.

---

## 14. Implementation scope (single phase)

One delivery — no deferred “v2”. Suggested **build order** within that phase:

| # | Work |
|---|------|
| 1 | SCORE: `Triplet` schema + `C_IssueTriplet` + category enforce |
| 2 | FVT: `TripletFamily` + `C_IssueTripletFamily` |
| 3 | FVT: `TripletLink` + `C_AddTriplet`; extended `RPS\|Global` (`reward-kind`, `triplet-family-id`) |
| 4 | FVT: RPS `anchor-id` keys (Member/User); Tier-2 `S` over all TripletLinks + ScoreLinks |
| 5 | FVT: Tier-2 by class — farm `W_i`; vault/treasury `D_triplet` = sum of three `total-deb-score` |
| 6 | FVT: lane `URC_*`; settle/checkpoint paths for triplet anchors |
| 7 | FVT: `CC_Collect` TRIPLET_BASE branch + ATSU Coil/Curl; PLAIN path unchanged for score anchors |
| 8 | Multi-family `Global` rows (PLAIN + TRIPLET_BASE on same FVT) |
| 9 | Boot migration (`C_AddTriplet`, OURO `TRIPLET_BASE`) + REPL golden paths (farm, vault, treasury) |
| 10 | Talos wrappers (per-anchor collect; optional composite tx if desired) |

Interface updates (`02_Core`, `03_Talos`) and module load order land with the above — not a follow-on release.

---

## 15. Open decisions (track before coding)

1. **Talos composite collect:** single tx collecting all anchors for one user vs explicit per-anchor calls.
2. **Foreign surplus vs lane weights:** lane formula uses `base × promile/1000` on silver base-score; satellite `deb-score` surplus fields are not used for FVT lanes.

---

## 16. Glossary

| Term | Meaning |
|------|---------|
| **Triplet** | SCORE bundle `T\|bronze\|silver\|golden` |
| **TripletFamily** | Reward ladder `F\|t0\|t1\|t2` + ATS ids |
| **TripletLink** | FVT admits one triplet as one membership tranche |
| **Anchor** | `triplet-id` or `score-id` — RPS accrual key |
| **Lane** | Bronze / silver / golden split of one triplet claim |
| **Multi-member FVT** | Any mix of TripletLink + ScoreLink rows sharing the same inject globals |
| **TRIPLET_BASE** | Global row: inject token-0 only; collect may coil/curl |

---

*Document version: 2026-07-10 — design discussion consolidation.*
