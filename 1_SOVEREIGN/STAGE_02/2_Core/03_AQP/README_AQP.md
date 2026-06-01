# AQP-POOL -- Acquisition Pools

Module: `AQP-POOL` | Interface: `AcquisitionPoolsV1` | File: `03_AQP.pact`

**Status: In progress — `C_Issue` and `C_AddScore` implemented; `C_RevokeScore`, `C_Stake`, and `C_Unstake` remain placeholders. Schemas, tables, UC key helpers, UDC defaults, and UR_* readers are in place.**

## Purpose

Pools are the **staking venues** where users lock assets to earn scores and, through FVTs, rewards. Each pool accepts one canonical asset-id (determined by `aqp-class`) and employs up to 7 Scores that measure the user's weighted contribution.

## Core Concepts

### Pool Classes (0-4)

Pool class determines which asset types can be staked:

| Class | Asset Type | Staking Variants |
|-------|-----------|-----------------|
| 0 | LP tokens | native, sleeping (OF), frozen (TF) -- same LP family |
| 1 | DPTF (non-LP) | native, frozen, sleeping, hibernating |
| 2 | DPOF (non-LP) | native only |
| 3 | DPSF (SFTs) | per-nonce |
| 4 | DPNF (NFTs) | per-nonce |

### Score Slots

Each pool has 7 score slots (`score-primary` through `score-septenary`). Scores assigned to these slots must have a matching `score-class`. When a user stakes, all active scores are updated.

### Staking Trackers

Per-user custody records track staked balances:

- `AQP|TrueFungibleTracker` -- DPTF balance per pool/owner/beneficiary
- `AQP|OrtoFungibleTracker` -- DPOF per nonce
- `AQP|SemiFungibleTracker` -- DPSF balance per nonce
- `AQP|NonFungibleTracker` -- DPNF balance per nonce

### Score Attribution (SF/NF only)

For DPSF and DPNF staking, per-position score attribution rows cache the last-computed base score and the applied definition revision. This enables lazy recomputation when score definitions change.

- `AQP|DPSFScoreAttribution` -- cached score + revision per (pool, dpsf-id, nonce, score-id)
- `AQP|DPNFScoreAttribution` -- cached score + revision per (pool, dpnf-id, nonce, score-id)

## Data Model

### Schemas

```
AQP|Schema                  Pool definition
  aqp-class:integer           Pool class 0-4
  asset-id:string             Canonical asset-id for staking
  score-primary:string        Score slot 1 (BAR if empty)
  score-secondary:string      Score slot 2
  score-tertiary:string       Score slot 3
  score-quaternary:string     Score slot 4
  score-quinary:string        Score slot 5
  score-senary:string         Score slot 6
  score-septenary:string      Score slot 7
  aqp-id:string               Self-referential ID
```

### Tables

| Table | Schema | Key |
|-------|--------|-----|
| `AQP\|T\|Pool` | `AQP\|Schema` | `<Pool-ID>` |
| `AQP\|T\|DPTFTracker` | `AQP\|TrueFungibleTracker` | `<Pool> \| <DPTF> \| <Owner> \| <Beneficiary>` |
| `AQP\|T\|DPOFTracker` | `AQP\|OrtoFungibleTracker` | `<Pool> \| <DPOF> \| <Owner> \| <Beneficiary> \| <Nonce>` |
| `AQP\|T\|DPSFTracker` | `AQP\|SemiFungibleTracker` | 5-part composite |
| `AQP\|T\|DPNFTracker` | `AQP\|NonFungibleTracker` | 5-part composite |
| `AQP\|T\|DPSFScoreAttribution` | `AQP\|DPSFScoreAttribution` | 6-part composite |
| `AQP\|T\|DPNFScoreAttribution` | `AQP\|DPNFScoreAttribution` | 6-part composite |

## Planned C_ Functions

| Function | Purpose |
|----------|---------|
| `C_Issue` | Create a new pool (aqp-class + asset-id) |
| `C_AddScore` | Assign a Score to an empty slot; calls `SCORE::XE_CreateAqpoolLink` |
| `C_RevokeScore` | Clear a score slot; revoke aqpool-link |
| `C_Stake` | Stake assets into a pool; update trackers, then call the appropriate `SCORE::XE_UpdateScoreDataFor*` forwarders (e.g. LP legs) and `ANK::XE_Update*UserAnchorValues` |
| `C_Unstake` | Reverse of stake; reconcile scores and anchors |

## Staking Flow (Planned)

```
User stakes asset X into Pool P
  1. Write/update tracker row for (pool, asset, user, nonce)
  2. For each active score slot in pool:
     a. Compute base-score from staked amount + score rules
     b. Read aggregate boost from ANK (UR_UB|AggregatePromile)
     c. Compute boosted-score and deb-score
     d. Call the matching SCORE::XE_UpdateScoreDataFor* forwarder for that score class / asset (e.g. LP: XE_UpdateScoreDataForTrueFungibleLP / XE_UpdateScoreDataForOrtoFungibleLP)
  3. Call ANK::XE_Update*UserAnchorValues for asset X
     (updates anchor promiles + aggregate boost for affected BoostClasses)
```

## Score rows and foreign `boost-link`

When a pool employs multiple scores, some scores may set `boost-link` to another score so ANK promile runs against that score's user **base** while this score's `SCR|T|UserScore` row stores **only boosted/deb surplus** over that foreign base (user `base-score` on the satellite stays this score's own LP weight). See **`README_SCORE.md` → Foreign boost-link** for the numeric model and implementation (`URC_SingularUserScoreDeltaFromSignedUserBase`, applied via `XI_ApplySingularUserScoreDelta` on LP stake and reusable for other singular-delta writers).

## LP pools and multi-LP farms

Class-0 pools stake **native LP token ids** (one canonical `asset-id` per pool). Each **distinct LP pair** that should earn farm rewards needs:

1. Its **own** class-0 pool (`C_Issue`).
2. Its **own** class-0 score set (production bootstrap uses an OURO **triplet** — three scores with the same `lp-denominator`; see `AQP-BOOT` Step 6 and [README_SCORE.md](README_SCORE.md#lp-scores-pools-and-fvt-matching)).
3. **`C_AddScore`** for each score into that pool’s slots (auto first-free slot; max **7** scores per pool).

Scores are **not** reusable across pools: `aqpool-link` is one-time. A second LP always means **new score issuances**, not re-wiring existing score ids.

**FVT** is separate: users stake here; rewards aggregate in a Farm via **`C_AddScoreLink`** (one row per score on the farm). Many pools and many scores can share **one** Farm FVT when their class-0 scores share the same **`lp-denominator`** (full OURO DPTF id). See [README_FVT.md](README_FVT.md#multi-lp-farms-one-fvt-many-pools).

On liquidity events, this pool orchestrates **`FVT::XE_SyncFarmScoreGhostTvlFromSwp`** only for scores **on this pool** (bounded ≤ 7), not for every member of a multi-LP farm.

## Relationship to Other Modules

- **SCORE**: AQP calls `XE_CreateAqpoolLink` on score assignment; stake/unstake uses dedicated `XE_UpdateScoreDataFor*` forwarders (class-0 LP: `XE_UpdateScoreDataForTrueFungibleLP` / `XE_UpdateScoreDataForOrtoFungibleLP`; further score classes get their own `XE_*` as added) — see `README_SCORE.md`
- **ANK**: AQP calls `XE_Update*UserAnchorValues` on stake/unstake to refresh anchor promiles
- **FVT**: No direct pool table coupling; FVT aggregates scores that AQP updates. Multi-LP farms admit many scores via `C_AddScoreLink` — see [README_FVT.md](README_FVT.md)
