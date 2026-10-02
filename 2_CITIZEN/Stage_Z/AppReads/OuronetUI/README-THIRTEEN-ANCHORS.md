# O-UI-THIRTEEN · the Anchors slice — what has to be built, and what does not

Intelligence gathered 2026-10-03, against the **live chain**, after AQP-BOOT Steps 2 and 3 put
15 anchors and 6 boost classes on `SBN-SUVEHxb9UQ6_` (DemiBunnies).

## The headline: almost nothing needs adding to AQP-ANK

Every field the Anchors tab needs is already readable through the `AcquisitionAnchorsV1`
interface, i.e. **composable by modref**, with one exception noted below. Probed live:

```
(length (AQP-ANK.URH_ANK|AllAnchorIds))   -> 15
(AQP-ANK.URH_BC|AllBoostClassIds)         -> [BronzeSnakePower-… GoldenSnakePower-…
                                              SilverSnakePower-… StoaBooster-…
                                              UnityBooster-… VestaBooster-…]
```

and one anchor, every row field at once:

```
{"anchored-asset": "SBN-SUVEHxb9UQ6_", "asset-name": "DemiBunnies",
 "fungibility": [false,false], "boost-class": "BronzeSnakePower-k7qp4IxC984L",
 "promille": 50, "precision": 3, "active": true,
 "trait-key": "Background", "trait-value": "Ouroboros Rain"}
```

## NO CROSS-MODULE `keys` IS NEEDED — which removes three constraints at once

This is the most useful finding. `O-UI-EIGHT` has to run `(keys DPTF.DPTF|PropertiesTable)`, a
cross-module scan, and pays for it three times over: the node must be started with
`--allowReadsInLocal`; the scan cannot sit inside a `try`, because `try` forces read-only mode and
`keys` is disallowed there; and `_conformance.py` tolerates it only while the containing function
has **zero Pact callers**, so it must be quarantined in a `URH_` that nothing composes.

None of that applies here. AQP-ANK, DPTF and DPDC each expose their **own** `URH_` enumerators,
which are theirs to admin-gate and are therefore freely composable:

| need | reader | in interface |
|---|---|---|
| every anchor id | `AQP-ANK::URH_ANK\|AllAnchorIds` | yes |
| every boost-class id | `AQP-ANK::URH_BC\|AllBoostClassIds` | yes |
| assets I own (TF) | `DPTF::URH_OwnedTrueFungibles account` | yes |
| assets I own (SF/NF) | `DPDC::URH_OwnedCollectables account son` | yes |

So the whole slice composes normally, inside `try` if wanted, with no node flag.

## Field map — client

| UI field | reader |
|---|---|
| anchor id | `URH_ANK\|AllAnchorIds` |
| anchored asset / its name + ticker | `UR_ANK\|AnchoredAsset` → `DPTF::UR_Name`/`UR_Ticker` or `DPDC::UR_Name`/`UR_Ticker` |
| asset kind | `UR_ANK\|Fungibility` → `[bool]`: `[f,f]`=DPNF, and the DPSF/DPTF pair |
| boost class | `UR_ANK\|BoostClassId` |
| anchor's full promille | `UR_ANK\|Promile` · precision `UR_ANK\|Precision` |
| active / revoked | `UR_ANK\|State` |
| terms | `UR_ANK\|TFAmount` · `UR_ANK\|SFNonce` · `UR_ANK\|NFTraitKey` + `UR_ANK\|NFTraitValue` · `UR_ANK\|NFNonceClass` |
| **my** promille in an anchor | `UR_ANK-U\|Promile account anchor-id` |
| **my** aggregate in a class | `UR_UB\|AggregatePromile account boost-class-id` |
| class active / score-link lock | `UR_BC\|Active` · `UR_BC\|ScoreLinkCount` |
| staleness | `AQP::URC_BenDptfAnchorsNeedSync` · `URC_BenDpsfAnchorsNeedSync` · `URC_BenDpnfAnchorsNeedSync` |

## THE ONE GAP — `class-owner`, and the two member-slot fields

`ANK|BoostClass` carries `class-owner`, and the only reader that exposes it is `UR_BC|Data`,
which returns `object{...}` and is therefore **module-only** — the interface object-return rule
keeps it out of `AcquisitionAnchorsV1`. Same for the seven `anchor-*` slot fields;
`UR_BC|Anchors` returns only the **count** (`1` for BronzeSnakePower today).

It matters because `acnoi=false` — attaching an anchor to an **existing** class — is enforced
against `class-owner`. Without it the manager cannot say which classes you may attach to; it can
only offer all of them and let the chain refuse.

Three ways out, and the cheapest is right:

1. **Dot-call `AQP-ANK.UR_BC|Data` from O-UI-THIRTEEN.** Works today (probed). Precedent exists:
   `O-UI-FOUR` already dot-calls `STOAICO` in six places. The cost is the pin — a dot call
   freezes AQP-ANK's code into the read module — but `UR_BC|Data` is a plain table read whose
   logic is stable, and only CODE pins, never TABLES. Register the edge in `_dotpin.py` so
   "redeploy O-UI-THIRTEEN after any AQP-ANK change" is mechanical rather than remembered. Read
   modules own no tables and are redeployed freely, which is exactly the case where a pin is
   cheap.
2. Bump `AcquisitionAnchorsV1` → `V2` to add `UR_BC|Owner` and `UR_BC|Slots`. Correct, and it
   drags a cascade across the AQP family plus an AQP-ANK redeploy for two accessors.
3. Live without the owner. The manager lists every class and lets failures teach.

**Taking (1).** The member slots need no decision at all: filter `URH_ANK|AllAnchorIds` by
`UR_ANK|BoostClassId`, which is one pass over a list we already fetch.

## Proposed surface — `O-UI-THIRTEEN`, anchors slice only

```
URC_13|AnchorCatalogue   ()                 B · every anchor, alphabetical, with its class + terms
URC_13|MyAnchors         (account)          A · the same rows + my promille + staleness, non-zero only
URC_13|AnchorDetail      (anchor-id account) one anchor: terms, my promille vs its max, class, asset
URC_13|BoostClasses      (account)          C · every class + slots used + score-link lock + my aggregate
URH_13|MyAnchorableAssets(account)          manager · TF + SF + NF I own, each with name/ticker/kind
URC_13|MyBoostClasses    (account)          manager · the classes I own, i.e. may attach to
```

`URH_` on the last one because it reaches two heavy owner scans.

## Gas, measured — this is a real UI constraint

`DPDC::URH_OwnedCollectables` **fails at a 150,000 gas limit** and succeeds at 1,500,000:

```
gas   150,000 : "Evaluation did not reduce to a value"
gas 1,500,000 : ["DHB-SUVEHxb9UQ6_", "DHN-SUVEHxb9UQ6_", "SBN-SUVEHxb9UQ6_"]
```

`DPTF::URH_OwnedTrueFungibles` returned six. So the manager reads must be issued at a generous
`/local` gas limit, and the client reads — which fold over 15 anchors and 6 classes — should be
measured before shipping rather than assumed cheap.

## Write path — already done, nothing to build

The five anchor entrypoints are in the registry and already have `OpSpec`s in the UI
(`src/constants/aqpConsumerSpecs.tsx` for the consumer side). What the client can do here is
**unstale only**; issue/revoke/attach are management functions.

    AQP-ANK|C_IssueTrueFungibleAnchor      AQP-ANK|C_IssueSemiFungibleAnchor
    AQP-ANK|C_IssueNonFungibleAnchor       AQP-ANK|C_IssueNonFungibleSetAnchor
    AQP-ANK|C_RevokeAnchor                 AQP-ANK|C_RevokeBoostClass

and the repair path, which is per ANCHORED ASSET and not per anchor:

    AQP|C_SyncTrueFungibleAnchors  (patron executee dptf-id)
    AQP|C_SyncCollectableAnchors   (patron executee collectable-id son)
