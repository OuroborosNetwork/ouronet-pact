# AQP-ANK -- Acquisition Anchors

Module: `AQP-ANK` | Interface: `AcquisitionAnchorsV1` | File: `01_ANK.pact`

## Purpose

Anchors define **promile thresholds** that measure how much of a specific asset a user holds (or has staked). BoostClasses group heterogeneous anchors together so that a single Score entity can be boosted by multiple anchors across different asset types.

## Core Concepts

### Anchor

An individual promile rule tied to **one** asset-id and one fungibility type. For example:

- A DPTF anchor: "holding 1000 OURO = 500 promile"
- A DPNF anchor: "owning an NFT with trait `power=legendary` = 200 promile"
- A DPSF anchor: "owning nonce 3 of SFT collection X = 100 promile"

Each anchor has a fixed promile value and a threshold (amount, nonce, or trait) that determines when a user qualifies.

### BoostClass

A **heterogeneous grouping** of up to 7 anchors. The anchors in a BoostClass may reference different asset types and fungibility kinds. A BoostClass is the entity that Scores link to via `boost-class-link`.

BoostClasses are **not** tied to any asset-id. They are created inline when issuing the first anchor (`acnoi=true`), adding a 2x STOA cost to that issuance. Subsequent anchors link to an existing BoostClass (`acnoi=false`) at 1x STOA. Revocation requires all member anchors to be revoked first.

### Per-Asset Bookkeeping (AssetAnchors)

Each asset-id that has at least one anchor gets a single bookkeeping row. This row contains 7 internal groups, each with 7 anchor slots, enforcing a structural cap of **49 anchors per asset**. This is purely organizational -- it tracks which anchors exist for an asset and enables single-read enumeration.

### User Promile

Per-anchor promile: `ANK|T|Anchors` stores each user's current promile for each individual anchor. Updated when the user stakes/unstakes the anchored asset (either in a pool or via neutral boost-staking).

Per-BoostClass aggregate: `ANK|T|UserBoost` stores the **aggregate promile** for a user across all anchors in a BoostClass. This is eagerly recomputed whenever any member anchor's user promile changes. Scores read this single value to compute boosted-score.

## Data Model

### Schemas

```
ANK|Schema                  Individual anchor definition
  ank-asset:string            [.]  Asset-id the anchor is based on
  ank-fungibility:[bool]      [.]  Fungibility type ([true true]=TF, [true false]=SF, [false false]=NF)
  boost-class-id:string       [.]  BoostClass this anchor belongs to
  ank-precision:integer        [.]  Decimal places for promile (2-8)
  ank-active:bool              [M]  Active flag (false = revoked)
  ank-promile:decimal          [.]  Promile value of this anchor
  dptf-amount:decimal          [.]  TF: amount threshold for promile (0.0 when not TF)
  dpsf-nonce:integer           [.]  SF: nonce for promile (0 when not SF)
  dpnf-trait-key:string        [.]  NF: trait key (BAR when not NF trait mode)
  dpnf-trait-value:string      [.]  NF: trait value (BAR when not NF trait mode)
  dpnf-nonce-class:integer     [.]  NF: nonce-class (-1=trait, 0=all, >0=specific class)
  anchor-id:string             [.]  Self-referential ID

ANK|BoostClass              Heterogeneous anchor grouping (entity)
  anchor-primary:string        [M]  1st anchor slot
  anchor-secondary:string      [M]  2nd anchor slot
  anchor-tertiary:string       [M]  3rd anchor slot
  anchor-quaternary:string     [M]  4th anchor slot
  anchor-quinary:string        [M]  5th anchor slot
  anchor-senary:string         [M]  6th anchor slot
  anchor-septenary:string      [M]  7th anchor slot
  anchors:integer              [M]  Count of active anchors (0-7)
  class-active:bool            [M]  Active flag
  boost-class-id:string        [.]  Self-referential ID

ANK|InternalGroup           Inline group within AssetAnchors (not a table entity)
  anchor-primary:string        7 anchor-id slots
  anchor-secondary:string
  anchor-tertiary:string
  anchor-quaternary:string
  anchor-quinary:string
  anchor-senary:string
  anchor-septenary:string
  anchors:integer              Count within this group (0-7)

ANK|AssetAnchors            Per-asset bookkeeping row
  group-primary:object{ANK|InternalGroup}     7 internal groups
  group-secondary:object{ANK|InternalGroup}
  group-tertiary:object{ANK|InternalGroup}
  group-quaternary:object{ANK|InternalGroup}
  group-quinary:object{ANK|InternalGroup}
  group-senary:object{ANK|InternalGroup}
  group-septenary:object{ANK|InternalGroup}
  groups-active:integer        [M]  Groups in use (0-7)
  anchors-active:integer       [M]  Total anchors across all groups (0-49)
  asset-id:string              [.]  Self-referential asset-id

ANK|UserSchema              Per-user per-anchor promile
  promile:decimal              [M]  Current user promile for this anchor
  ouronet-account:string       [.]  User account
  anchor-id:string             [.]  Anchor reference

ANK|UserBoostSchema         Per-user per-BoostClass aggregate
  aggregate-promile:decimal    [M]  Sum of user promiles across all member anchors
  ouronet-account:string       [.]  User account
  boost-class-id:string        [.]  BoostClass reference
```

### Tables

| Table | Schema | Key |
|-------|--------|-----|
| `ANK\|T\|Anchor` | `ANK\|Schema` | `<Anchor-ID>` |
| `ANK\|T\|BoostClass` | `ANK\|BoostClass` | `<Boost-Class-ID>` |
| `ANK\|T\|AssetAnchors` | `ANK\|AssetAnchors` | `<Asset-ID>` |
| `ANK\|T\|Anchors` | `ANK\|UserSchema` | `<Account> \| <Anchor-ID>` |
| `ANK\|T\|UserBoost` | `ANK\|UserBoostSchema` | `<Account> \| <Boost-Class-ID>` |

## Entity Lifecycle

### BoostClass + Anchor (Unified Issuance via `acnoi`)

BoostClasses are **not** issued separately. They are created inline during anchor issuance using the `acnoi` (Anchor-Class New Or Id) boolean parameter present on every `C_Issue*Anchor` function:

- **`acnoi=true`** + `boost-class-name`: Creates a **new** BoostClass entity and places the anchor into it. Costs **2x STOA** (one for the BoostClass, one for the anchor).
- **`acnoi=false`** + `boost-class-id`: Places the anchor into an **existing** BoostClass (must be active, must have a free slot). Costs **1x STOA**.

Issuance functions: `C_IssueTrueFungibleAnchor` / `C_IssueSemiFungibleAnchor` / `C_IssueNonFungibleAnchor` / `C_IssueNonFungibleSetAnchor`.

### Revocation

1. **Anchor**: `C_RevokeAnchor` -- deactivates the anchor, removes it from both the BoostClass and AssetAnchors bookkeeping.
2. **BoostClass**: `C_RevokeBoostClass` -- deactivates an empty BoostClass (all member anchors must be revoked first).

## Promile Computation

### TF Anchors
`promile = floor((user-balance / dptf-amount) * ank-promile, ank-precision)` — **pro-rated** (continuous),
**not** a whole-threshold step: staked balance scales the boost proportionally. E.g. `ank-promile = 500`,
`dptf-amount = 1000`, user stakes `2500` → `floor(2.5 * 500) = 1250`. Guard: `dptf-amount <= 0.0` yields `0.0`.
The computed **result is not capped**; instead the per-anchor *definition* is bounded at anchor issue
(**audit fix #15**, enforced in `UEV_Promile` + `ANK|C>ISSUE-DPTF`): `anchor-precision = 3` exactly,
`ank-promile ∈ [1.0, 10000.0]` (conform to precision 3), and TF `dptf-amount ∈ [1000.0, 1,000,000.0]`. So a
single anchor's per-unit leverage (`ank-promile / dptf-amount`) is bounded, but a user's *accumulated* promile
still pro-rates past 1000 by staking more. Matches `URC_TrueFungibleAnchorPromile` in `01_ANK.pact`.
(Contrast SF/NF below: **whole-unit** — nonce-count × promile — because they are collectable-nonce based.)

### SF Anchors
Based on nonce ownership -- user holding the specified nonce earns the promile.

### NF Anchors
Two modes based on `dpnf-nonce-class`:
- **Trait mode** (`dpnf-nonce-class = -1`): count user NFTs matching `(trait-key, trait-value)`, multiply by promile
- **Set/class mode** (`dpnf-nonce-class >= 0`): count user NFTs in the specified nonce-class, multiply by promile

## Aggregate Boost

The aggregate promile for a user in a BoostClass is the **sum** of the user's individual promiles across all member anchors:

```
aggregate_promile(user, boost-class) = SUM(user_promile(user, anchor_i))
    for each anchor_i in boost-class where anchor_i is active
```

This aggregate is stored in `ANK|T|UserBoost` and eagerly updated.

## Anchor Update Triggers

Anchor promile updates are triggered by **any** event that changes a user's relevant asset balance:

1. **Pool staking/unstaking** (via AQP): AQP calls `XE_Update*UserAnchorValues` which reads the asset's anchors from `ANK|T|AssetAnchors`, recomputes per-anchor promile, and updates the aggregate in `ANK|T|UserBoost`.

2. **Neutral boost-staking** (future): ANK's own custody path calls the same `XE_Update*` logic. The user stakes purely for anchor credit, no pool involvement.

Both paths converge on the same update functions. The lookup chain is:

```
asset-id --> ANK|T|AssetAnchors (single read, all anchor-ids)
  --> for each anchor: ANK|T|Anchor (read boost-class-id)
    --> ANK|T|UserBoost (recompute aggregate for affected boost-class)
```

All direct key lookups, no scans.

## Relationship to Other Modules

- **SCORE**: A Score links to a BoostClass via `boost-class-link`. When computing `boosted-score`, SCORE reads `UR_UB|AggregatePromile` from ANK.
- **AQP-POOL**: On stake/unstake events, AQP calls ANK's `XE_Update*` forward entries to refresh anchor promiles.
- **FVT**: No direct interaction. FVT aggregates scores which already incorporate boost.
