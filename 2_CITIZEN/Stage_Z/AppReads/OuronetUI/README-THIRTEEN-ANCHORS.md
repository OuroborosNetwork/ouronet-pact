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

## THE ONE GAP — `class-owner`, and where the dot call belongs

`ANK|BoostClass` carries `class-owner`, and the only reader exposing it is `UR_BC|Data`, which
returns an object and is therefore **module-only** — the interface object-return rule keeps it out
of `AcquisitionAnchorsV1`. Same for the seven `anchor-*` slots; `UR_BC|Anchors` returns only the
**count**.

It matters because `acnoi=false` — attaching an anchor to an **existing** class — is enforced
against `class-owner`. Without it the manager cannot say which classes you may attach to.

### The resolution, after measuring what a dot call actually does

Owner, 2026-10-03: *"there is no problem calling read functions with dot — it's only when they are
called from within a module that they call the version that existed when the module was deployed.
Calling it by dot for a read always uses the latest module."*

Correct, and the measurement adds the part that decides the design. Both cases, in a scratch REPL:

```
TOP-LEVEL dot call, after the callee upgrades    ->  20   (the NEW logic)
IN-MODULE dot call, after the callee upgrades    ->  ABORTS:
      "Execution aborted, hash not blessed for module B: _elYB7H8y…"
```

So an in-module dot call into a callee that reads **its own tables** does not go stale — it
**dies**. Pact refuses table access from code carrying a superseded module hash unless that hash
is `bless`ed, and **the tree contains zero `bless` calls.**

(KBN survived its own pin only because it owns no tables: `A_BunnyRGBSet` computes and calls
outward, so the pinned copy ran and wrote the previous artwork. Had KBN owned a table, Step 1
would have aborted instead — louder, and much easier to diagnose.)

**Therefore: O-UI-THIRTEEN must NOT dot-call `AQP-ANK.UR_BC|Data`.** AQP-ANK reads its own tables,
so every AQP-ANK upgrade would hard-break the read module until it was redeployed in the same
round. The earlier recommendation to register the edge in `_dotpin.py` and accept it was wrong.

**The call goes in the UI instead, at `/local` top level, where it always resolves to the latest
module.** Verified against the live chain in ONE call:

```pact
(map (lambda (c:string)
       { "id": c
       , "owner":  (at "class-owner"  (ouronet-ns.AQP-ANK.UR_BC|Data c))
       , "slots":  (at "anchors"      (ouronet-ns.AQP-ANK.UR_BC|Data c))
       , "active": (at "class-active" (ouronet-ns.AQP-ANK.UR_BC|Data c)) })
     (ouronet-ns.AQP-ANK.URH_BC|AllBoostClassIds))
```

```
BronzeSnakePower-k7qp4IxC984L  slots=1  active=True  owner=Ѻ.éXødVțrřĄθ7ΛдUŒj…
GoldenSnakePower-k7qp4IxC984L  slots=2   SilverSnakePower-k7qp4IxC984L  slots=1
StoaBooster-yd67psaR1LFA       slots=2   UnityBooster-yd67psaR1LFA      slots=4
VestaBooster-yd67psaR1LFA      slots=5                      (1+2+1+2+4+5 = 15 anchors)
```

Zero coupling, always latest, and the UI already composes read strings this way elsewhere. The
member slots need no decision either: filter `URH_ANK|AllAnchorIds` by `UR_ANK|BoostClassId`.

## Proposed surface — `O-UI-THIRTEEN`, anchors slice only

```
URC_13|AnchorCatalogue   ()                 B · every anchor, alphabetical, with its class + terms
URC_13|MyAnchors         (account)          A · the same rows + my promille + staleness, non-zero only
URC_13|AnchorDetail      (anchor-id account) one anchor: terms, my promille vs its max, class, asset
URC_13|BoostClasses      (account)          C · slots used, score-link lock, my aggregate
                                            (NOT owner -- the UI reads that top-level, see above)
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
