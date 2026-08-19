# 2026-08-19 — NF-stake anchor cost is O(anchors defined on the collectable), flat per stake

Measured while adding the multi-anchor fan-out test (`A05`, #FP5). A useful design constraint for anyone
sizing a trait-anchored collectable.

## The behaviour

When an NFT is staked, `AQP-POOL` → `ANK::XE_ResyncNonFungibleUserAnchorValues` **scans every live anchor on
the asset** and updates each conforming one:

```lisp
(aids (UR_ANK|AnchorsForAsset dpnf-id))          ; ALL anchors on the collectable
(map (lambda (aid)
       (WW_Anchors account aid (URC_NonFungibleAnchorPromile account aid nonces direction))
       (UR_ANK|BoostClassId aid))                 ; boost-class of EVERY anchor
     aids)
(XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))   ; ALL distinct boost-classes
```

So the sync iterates all `AnchorsForAsset` and recomputes all `distinct` boost-classes **regardless of how many
anchors the specific NFT actually matches**. Matching more just adds a few non-zero promile writes.

## The measurement (KBN = 15 anchors, ~4 boost-classes)

- Single-anchor stake (Common + Elk0nite Eyes → 1 anchor): **92,486 gas**
- Multi-anchor stake (Legendary Elite-Auryn Rain → 5 anchors / 4 boost-classes): **92,552 gas**
- **Δ = 66 gas (0.07%)**

## The takeaway

- **The gas lever is how many anchors a collectable DEFINES, not how many a given NFT hits.** A heavily-anchored
  collectable makes *every* stake of it proportionally pricier; a Legendary NFT hitting 5 anchors is not
  meaningfully more expensive than a plain one hitting 1.
- The fan-out itself is correct + now tested: one NFT with N matching traits → N per-user promiles + refold of
  each touched boost-class, deduped by `distinct`. `A05` proves the same-class sum
  (`GoldenSnakePower == EliteAurynRain(200) + LegendarySnakeTokenRain(400) = 600`).
- A **single `Rarity="Legendary"` bunny conforms to all four Legendary anchors** (LegendarySnakeTokenRain→Golden,
  LegendaryUnityBooster→Unity, LegendaryStoaBooster→Stoa, LegendaryVestaBooster→Vesta) — the natural multi-anchor
  fixture; a `Legendary + Elite-Auryn Rain` bunny adds the Background anchor too (5 total).
- Ref: `01_ANK.pact` `XE_ResyncNonFungibleUserAnchorValues`; `[6.4]_AQP-EXHAUSTIVE-ANK-LP.repl` A05a/A05b.
