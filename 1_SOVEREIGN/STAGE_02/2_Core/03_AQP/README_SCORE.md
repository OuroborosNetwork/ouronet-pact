# AQP-SCORE -- Acquisition Scores

Module: `AQP-SCORE` | Interface: `AcquisitionScoresV1` | File: `02_SCORE.pact`

## Purpose

Scores define **how staked assets are weighted** for reward distribution. Each Score entity specifies the rules (multipliers, models, definitions) for computing a user's weight in a pool. Scores link to BoostClasses (from ANK) to incorporate anchor-based boosting.

## Core Concepts

### Score Classes (0-4)

Each Score belongs to exactly one class, which determines the type of asset it measures:

| Class | Type | Multipliers Used | Special Fields |
|-------|------|-----------------|----------------|
| 0 | LP (Liquidity Pool) | mx-frozen, mx-sleeping | lp-denominator (common token in LP) |
| 1 | DPTF (True Fungible, non-LP) | mx-frozen | -- |
| 2 | DPOF (Orto Fungible, non-LP) | mx-sleeping, mx-hibernated | -- |
| 3 | DPSF (Semi Fungible) | -- | sft-equality |
| 4 | DPNF (Non Fungible) | -- | nft-score-model (-1, 0, 1) |

### Score Lifecycle

1. **Issue**: `C_IssueLiquidityScore` / `C_IssueTrueFungibleScore` / etc. -- creates the Score entity with its class, multipliers, and model parameters.
2. **Link to BoostClass**: `C_CreateBoostClassLink` -- one-time assignment of a BoostClass for boosting (optional, BAR if unused).
3. **Link to Pool**: `XE_CreateAqpoolLink` -- forward entry from AQP when a Score is assigned to a pool slot.
4. **Link to FVT**: `XE_CreateFvtLink` -- forward entry from FVT when a Score joins a Farm/Vault/Treasury.
5. **Issue Definitions** (class 3-4 only): `C_IssueSemiFungibleScoreDefinition` / `C_IssueNonFungibleScoreDefinition` / `C_IssueNonFungibleSetScoreDefinition` -- define per-nonce or per-trait weights.
6. **Ownership/Control**: `C_RotateOwnership`, `C_Control` -- management operations.

### Links

All links are **one-time** (BAR -> value, never changed after set):

- `boost-class-link` -> BoostClass-ID from ANK (for boosting)
- `boost-link` -> another Score-ID whose **user** `base-score` (same account, same pool) feeds the ANK promile when computing **nominal** boosted/deb for **this** score; see **Foreign boost-link** below
- `aqpool-link` -> Pool-ID from AQP (which pool employs this score)
- `fvt-link` -> FVT-ID (which Farm/Vault/Treasury aggregates this score)

**Revoke policy:** only **`aqpool-link`** is planned to clear (`XE_RevokeAqpoolLink` via POOL `C_RevokeScore`). **`boost-class-link`** and **`boost-link`** stay immutable — deactivate BoostClasses / anchors in ANK instead; reissue scores to fix wiring. Full matrix: **`README.md` § Mutability & lifecycle**.

### Immutability Policy

Fields marked `[.]` are fixed at issuance and must not change after user positions exist. Changing score-class, multipliers, or models after staking would leave existing `SCR|UserSchema` rows incorrect. The correct migration path is: issue a new Score, remove the old one from the pool, and wire the new one.

## Data Model

### Schemas

```
SCR|Schema                  Core score definition
  owner-konto:string          [Mu] Score owner
  can-upgrade:bool            [Mu] Settings can be upgraded
  can-change-owner:bool       [Mu] Owner can be changed
  boost-class-link:string     [..] BoostClass-ID for boosting (BAR if unused)
  boost-link:string           [..] Score-ID for cascaded boost (BAR if unused)
  aqpool-link:string          [..] Pool-ID employing this score (BAR if unlinked)
  fvt-link:string             [..] FVT-ID aggregating this score (BAR if unlinked)
  deb-boost:bool              [.t] DEB boosting enabled (one-time toggle)
  precision:integer           [.]  Decimal places for per-user weights and total-* aggregates (3-24)
  total-base-score:decimal    [M]  Sum of user base-scores at precision
  total-boosted-score:decimal [M]  Sum of user boosted-scores at precision
  total-deb-score:decimal     [M]  Sum of user deb-scores at precision
  nzs-count:integer           [M]  Non-zero-score user count
  score-class:integer         [.]  Class 0-4
  lp-denominator:string       [.]  Class-0 only: common DPTF in all scored LPs; BAR for 1-4
  mx-frozen:decimal           [.]  Frozen multiplier
  mx-sleeping:decimal         [.]  Sleeping multiplier
  mx-hibernated:decimal       [.]  Hibernated multiplier
  sft-equality:bool           [.]  Class-3: all SFTs equal weight
  nft-score-model:integer     [.]  Class-4: -1=equal, 0=native, 1=trait-defined
  score-id:string             [.]  Self-referential ID

SCR|UserSchema              Per-user per-pool per-score weights
  base-score:decimal           This score's own LP (or class) weight; never copies a foreign score's base
  boosted-score:decimal        Boost tier (see Boosted Score); with a **foreign** boost-link, stores **surplus** only
  deb-score:decimal            DEB tier; with a **foreign** boost-link, stores **surplus** only
  ouronet-account:string       User account
  pool-id:string               Pool reference
  score-id:string              Score reference

SCR|SF|Schema               SFT nonce score definition
  nonce-score-value:decimal    Weight for this nonce
  score-id:string              Parent score
  dpsf-id:string               SFT collection
  nonce:integer                Nonce value

SCR|NF|Schema               NFT trait/set score definition
  trait-score-value:decimal    Weight for this trait/class
  score-id:string              Parent score
  dpnf-id:string               NFT collection
  trait-key:string              Trait key (trait mode)
  trait-value:string            Trait value (trait mode)
  dpnf-nonce-class:integer     Nonce class (set mode; -1 for trait mode)

SCR|SF|DefRevision          SF definition revision tracker
  revision-nonce:integer       Bumped on definition change
  score-id:string
  dpsf-id:string

SCR|NF|DefRevision          NF definition revision tracker
  revision-nonce:integer       Bumped on definition change
  score-id:string
  dpnf-id:string
```

### Tables

| Table | Schema | Key |
|-------|--------|-----|
| `SCR\|T\|Score` | `SCR\|Schema` | `<Score-ID>` |
| `SCR\|T\|UserScore` | `SCR\|UserSchema` | `<Account> \| <Pool-ID> \| <Score-ID>` |
| `SCR\|T\|SF\|Score` | `SCR\|SF\|Schema` | `<Score-ID> \| <DPSF-ID> \| <Nonce>` |
| `SCR\|T\|NF\|Score` | `SCR\|NF\|Schema` | `<Score-ID> \| <DPNF-ID> \| <Trait-Key> \| <Trait-Value> \| <Nonce-Class>` |
| `SCR\|T\|SF\|DefRevision` | `SCR\|SF\|DefRevision` | `<Score-ID> \| <DPSF-ID>` |
| `SCR\|T\|NF\|DefRevision` | `SCR\|NF\|DefRevision` | `<Score-ID> \| <DPNF-ID>` |

## Score Computation

### Base Score

Computed by AQP on stake/unstake. Depends on the score class:

- **Class 0 (LP)**: `URC_LpAmountToLpDenominatorEquivalent` — pro-rata `SWPL::URC_LpBreakAmounts` on the stake's `swpair`, **lp-denominator leg** (e.g. OURO token units at current reserves); then frozen/sleeping multipliers per LP variant
- **Class 1 (DPTF)**: Token amount * mx-frozen (for frozen tokens; 1.0 for standard)
- **Class 2 (DPOF)**: Sleeping/hibernated multipliers for special tokens
- **Class 3 (DPSF)**: Per-nonce weight from `SCR|SF|Schema` (or 1.0 if sft-equality)
- **Class 4 (DPNF)**: Per-trait/class weight from `SCR|NF|Schema`, or 1.0 (model -1), or native score (model 0)

### Boosted Score (own base)

When `boost-link = BAR`, **nominal** boosted uses this score's own user `base-score` (after the stake delta) as `base_for_boost`. A non-`BAR` `boost-link` is always **another** score-id: `SCR|C>CREATE-BOOST-LINK-SCORE` requires `boost-score-id ≠ score-id` (no self-link). **Nominal** boosted is then:

```
nominal_boosted = base_for_boost * (aggregate_promile(user, boost-class-link) / 1000)
```

(`aggregate_promile` / 1000 is the per-mille factor from ANK; see `UR_UB|AggregatePromile`.) If `boost-class-link = BAR`, **nominal** boosted equals this score's user `base-score` after the stake delta.

The value written to `SCR|T|UserScore.boosted-score` is that **nominal** boosted (floored to score `precision`), except in the **foreign boost-link** case below.

### DEB Score (nominal)

If `deb-boost = true`, **nominal** deb applies the account's Elite DEB multiplier from DALOS (`UR_Elite-DEB`) to **nominal** boosted. If `deb-boost = false`, **nominal** deb equals **nominal** boosted.

The value written to `SCR|T|UserScore.deb-score` follows the same **foreign surplus** rule as boosted when a foreign `boost-link` is active.

### Foreign boost-link (composite / split scores)

**When** `boost-link` is set to **another** score-id (not `BAR`; never this score's id — enforced at link creation) **and** `boost-class-link` is not `BAR`:

1. This score's user **`base-score` is stored as `0.0`** (canonical base lives on the linked score; this row is surplus-only for base).
2. Read **foreign base** = that linked score's user `base-score` for the same `(ouronet-account, pool-id)`.
3. **Promile input** = `floor(foreign_base + signed_lp_delta, precision)` where `signed_lp_delta` is this stake leg's contribution in the same weight units (LP path: from `URC_SignedBaseDeltaFor*LpStake`).
4. Compute **nominal boosted** = `floor(promile_input * (promile / 1000), precision)` using the user's aggregate promile on **this** score's `boost-class-link`.
5. Compute **nominal deb** from **nominal boosted** (DEB multiplier when `deb-boost`).
6. **Store only the surplus** over the foreign reference base (subtract **foreign base** only, not the LP delta term):
   - `boosted-score = max(0, floor(nominal_boosted - foreign_base, precision))`
   - `deb-score = max(0, floor(nominal_deb - foreign_base, precision))`

**Example (Score B uses Score A's base 100, promile 1100 ‰ ⇒ ×1.10, DEB ×1.30 on nominal boosted):**

| Step | Would be if everything were "full" values | Stored on B's `SCR|T|UserScore` |
|------|--------------------------------------------|----------------------------------|
| Base | 100.0 (from A) | **0.0** (foreign base is not duplicated here) |
| Boosted | 110.0 | **10.0** (= 110 − 100, only the extra over the foreign base) |
| Deb | 143.0 (= 110 × 1.30) | **43.0** (= 143 − 100) |

**Intent:** several scores can each hold **only their incremental** boosted/deb portions while sharing one **logical** base that lives on a primary score (Score A). Summing **base + boosted + deb** across entities is **not** intended to reconstruct a single "full" triple without knowing which row owns the foreign base; the **foreign** score holds the canonical base, satellites hold **surpluses**.

**Singular user-base delta:** `URC_SingularUserScoreDeltaFromSignedUserBase` in `02_SCORE.pact` implements this netting for any path that applies one signed base delta at score precision; LP stake uses `XI_ApplySingularUserScoreDelta` behind `SCR|XE>UPDATE-LP-STAKE-*`.

**Caveat:** Nominal values use the linked score's user **base** as read at transaction time; if that base moves in the same transaction, ordering follows Pact evaluation order.

### Definition Revisions (Lazy Refresh)

When an admin changes an SF/NF score definition (nonce weights or trait weights), the revision counter in `SCR|T|SF|DefRevision` or `SCR|T|NF|DefRevision` is bumped. Per-user score attribution rows in AQP track an `applied-def-revision-nonce`. On the user's next stake/unstake interaction, the revision is compared and the score is recomputed if stale.

## LP scores, pools, and FVT matching

Class-0 scores store `lp-denominator` — the **full native DPTF token-id** of the common pool leg (e.g. `OURO-98c486052a51`), not a ticker alone. It must appear in every scored LP pair’s `pool-tokens`. Class-0 issue validates the id via `DPTF::UEV_id`.

### One score, one pool

`aqpool-link` is **one-time**: each score id is employed by **at most one** AQP pool. You cannot assign the same score to a second LP pool; add a **new** class-0 score issuance per LP line.

### OURO LP triplet (bootstrap pattern)

`AQP-BOOT` Step 6 issues **Silver / Bronze / Golden** class-0 scores that share one `lp-denominator` but do **not** embed an LP id in the score row. Bronze and Golden use **foreign `boost-link`** to Silver for composite boosting. The triplet is then attached to **one** class-0 pool via **`C_AddScore` × 3**. A second OURO LP later repeats Step 6–style issuance (new score names/ids) + new pool + new add-score calls.

### Many scores, one farm

`fvt-link` is also **one-time**, but **many** scores may share the **same** Farm FVT id when their `lp-denominator` matches the farm’s `common-denominator`. FVT admits each score with **`C_AddScoreLink`** (one `FVT|T|ScoreLink` row per score). With the triplet pattern, **N LPs ⇒ 3N ScoreLink rows** on one farm — see [README_FVT.md](README_FVT.md#multi-lp-farms-one-fvt-many-pools).

When a Score joins a Farm, FVT reads `UR_SCR|ScoreLpDenominator` and enforces `lp-denominator == common-denominator`. That validation lives in **FVT**, not SCORE.

## Relationship to Other Modules

- **ANK**: SCORE reads `UR_UB|AggregatePromile` to compute boosted-score. The `boost-class-link` field references an ANK BoostClass.
- **AQP-POOL**: AQP calls score-specific forward writers on stake/unstake (e.g. class-0 LP: `XE_UpdateScoreDataForTrueFungibleLP` / `XE_UpdateScoreDataForOrtoFungibleLP`). AQP also calls `XE_CreateAqpoolLink` when assigning a Score to a pool.
- **FVT**: FVT calls `XE_CreateFvtLink` when admitting a Score. FVT keeps aggregated `total-*` mirrors and (for farms) **Tier‑2** reward splitting by **ghost TVL** from SWP — see **`README_FVT.md`**.
