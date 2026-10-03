;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 26
;; O-UI-THIRTEEN (module upgrade) -- the full anchor detail read
;; =========================================================================================
;; MODULE-ONLY, and that is forced rather than chosen. `OUiThirteenV1` went live with
;; PureV2/25 and a deployed interface cannot be re-sent or changed. The new reader is therefore
;; declared in the MODULE and not in the interface: a module may expose MORE than its interface
;; declares, and may not expose less.
;;
;; A read module owns no tables, so this is a plain redeploy with nothing to migrate -- which is
;; the property that makes iterating on the read surface cheap, and the reason the AppReads split
;; exists at all.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IS NEW: URC_13|AnchorFull (anchor-id account)
;; ------------------------------------------------------------------------------------------
;; Everything about one anchor, for the detail view behind a row click. It needed NO new
;; sovereign reader -- all twelve `ANK|Schema` fields are already reachable through
;; `AcquisitionAnchorsV1`, so this is composition, not capability. What it adds over
;; `URC_13|AnchorDetail` is the context a row cannot carry:
;;
;;   mode              "amount" | "nonce" | "trait" | "set-class", NAMED on the server
;;   the four terms    tf-amount, sf-nonce, trait-key/value, nonce-class -- ALL of them, raw
;;   fungibility       the [bool] tuple itself
;;   asset-owner       via URC_AnchorableAssetOwner
;;   anchors-on-asset  against the structural cap of 49 (UEV_AssetAnchorCap: 7 groups x 7)
;;   groups-on-asset   the other half of that structure
;;   siblings          the OTHER anchors on the same asset
;;   class-*           active, slots, score-link count (non-zero LOCKS revocation)
;;   my-*              promille, class aggregate, needs-sync
;;
;; WHY `mode` IS NAMED ON THE SERVER. Only ONE of the four terms fields is live on any anchor;
;; the rest hold sentinels (0.0, 0, BAR, -1). A client deciding for itself which to believe is a
;; client that will eventually believe the wrong one. The sentinels ship ALONGSIDE the mode so a
;; reader can CONFIRM it rather than trust it -- `nonce-class: -1` is what makes a trait anchor
;; a trait anchor.
;;
;; WHY `siblings` IS WORTH A FIELD. The repair is per ASSET, not per anchor
;; (`C_SyncTrueFungibleAnchors ... dptf-id`), so this list is literally "what else this one
;; button will refresh".
;;
;; ------------------------------------------------------------------------------------------
;; A DERIVATION REPLACED BY THE REAL READER
;; ------------------------------------------------------------------------------------------
;; `URC_13|AnchorTerms` decided trait-vs-set with `(= nonce-class -1)`. AQP-ANK has a
;; purpose-built discriminator, `URC_TraitOrClass`, which checks all THREE conditions -- both
;; trait fields non-BAR *and* nonce-class = -1. The two agree on every anchor the four issuance
;; entrypoints produce and would diverge on a row written any other way, so the module now asks
;; the owner of the question instead of re-deriving its answer.
;;
;; ------------------------------------------------------------------------------------------
;; VERIFICATION
;; ------------------------------------------------------------------------------------------
;; Four assertions in `[6.2.9]_AQP-BOOT-FULL` <<OUI13-A6>>: a trait anchor reports mode=trait;
;; it ships nonce-class -1 beside it; `siblings` excludes the anchor itself; and the sibling
;; count is `anchors-on-asset` minus one -- which is the assertion that fails if the filter is
;; wrong rather than the list.
;;
;; `_scratch_loadpurev2.repl` loads 25 then 26 over a deployed tree and asserts the upgraded
;; module STILL satisfies the live OUiThirteenV1 while carrying the undeclared reader.
;; Gate green.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact (module only -- its interface is already live)
(module O-UI-THIRTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiThirteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-THIRTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_THIRTEEN_ADMIN)))
    (defcap GOV|O_UI_THIRTEEN_ADMIN ()      (enforce-guard GOV|MD_O-UI-THIRTEEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH]

    (defun URC_13|AnchorKind:string (asset-fungibility:[bool])
        @doc "The anchored asset's kind, as one word, from the [bool] discriminator AQP-ANK \
            \ stores. Slot 0 is `is a true fungible`; slot 1 is the collectable `son`. \
            \ \
            \ Returned as a STRING rather than the raw tuple because every consumer -- the \
            \ row \
            \ renderer, the name lookup, the staleness reader, the repair button -- \
            \ dispatches \
            \ on it, and a two-element [bool] is the kind of value each of them would \
            \ decode \
            \ slightly differently."
        (if (at 0 asset-fungibility)
            "dptf"
            (if (at 1 asset-fungibility) "dpsf" "dpnf")
        )
    )

    (defun URC_13|AssetName:object (asset-id:string asset-fungibility:[bool])
        @doc "Name and ticker of an anchored asset, from whichever module owns it: DPTF \
            \ true fungible, DPDC for a collectable. \
            \ \
            \ An anchor row is useless without this: `SBN-SUVEHxb9UQ6_` tells a user \
            \ nothing \
            \ and `DemiBunnies` tells them everything."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (kind:string (URC_13|AnchorKind asset-fungibility))
            )
            (if (= kind "dptf")
                {"name"   : (ref-DPTF::UR_Name asset-id)
                ,"ticker" : (ref-DPTF::UR_Ticker asset-id)}
                (let
                    (
                        (son:bool (= kind "dpsf"))
                    )
                    {"name"   : (ref-DPDC::UR_Name asset-id son)
                    ,"ticker" : (ref-DPDC::UR_Ticker asset-id son)}
                )
            )
        )
    )

    (defun URC_13|AnchorTerms:string (anchor-id:string)
        @doc "The anchor's terms, rendered: what you must have staked to earn its \
            \ \
            \ Four shapes, one per issuance entrypoint, and only ONE of the four stored \
            \ fields \
            \ is meaningful for any given anchor; the rest hold their unset sentinels \
            \ (0.0, 0, \
            \ BAR, -1). Rendering it here rather than in the client is what stops four UIs \
            \ deciding independently which field to believe."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (kind:string (URC_13|AnchorKind (ref-ANK::UR_ANK|Fungibility anchor-id)))
            )
            (if (= kind "dptf")
                (format "{} staked per unit" [(ref-ANK::UR_ANK|TFAmount anchor-id)])
                (if (= kind "dpsf")
                    (format "nonce {} - 1 per unit" [(ref-ANK::UR_ANK|SFNonce anchor-id)])
                    ;;DPNF splits again: a SET anchor carries a nonce-class and no trait, a
                    ;;TRAIT anchor the reverse. AQP-ANK has a purpose-built discriminator --
                    ;;URC_TraitOrClass -- which checks all THREE conditions (both trait fields
                    ;;non-BAR *and* nonce-class = -1). An earlier version derived it from the
                    ;;nonce class alone: it agrees on every anchor the four entrypoints issue,
                    ;;and would diverge on a row written any other way.
                    (if (ref-ANK::URC_TraitOrClass anchor-id)
                        (format "trait {} = {}"
                            [(ref-ANK::UR_ANK|NFTraitKey anchor-id)
                             (ref-ANK::UR_ANK|NFTraitValue anchor-id)])
                        (format "set class {}" [(ref-ANK::UR_ANK|NFNonceClass anchor-id)])
                    )
                )
            )
        )
    )

    (defun URC_13|AnchorRow:object (anchor-id:string)
        @doc "One anchor, every field a list row needs, with the asset named and the terms \
            \ rendered. The unit both the catalogue and the account view are built from -- \
            \ so \
            \ the two cannot drift in what a row means."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (asset:string (ref-ANK::UR_ANK|AnchoredAsset anchor-id))
                (fung:[bool] (ref-ANK::UR_ANK|Fungibility anchor-id))
            )
            (let
                (
                    (named:object (URC_13|AssetName asset fung))
                )
                {"anchor-id"        : anchor-id
                ,"asset-id"         : asset
                ,"asset-name"       : (at "name" named)
                ,"asset-ticker"     : (at "ticker" named)
                ,"asset-kind"       : (URC_13|AnchorKind fung)
                ,"boost-class-id"   : (ref-ANK::UR_ANK|BoostClassId anchor-id)
                ,"promille"         : (ref-ANK::UR_ANK|Promile anchor-id)
                ,"precision"        : (ref-ANK::UR_ANK|Precision anchor-id)
                ,"active"           : (ref-ANK::UR_ANK|State anchor-id)
                ,"terms"            : (URC_13|AnchorTerms anchor-id)}
            )
        )
    )

    (defun URC_13|NeedsSync:bool (account:string asset-id:string asset-kind:string)
        @doc "Is this account's anchor value on <asset-id> out of date? \
            \ \
            \ Three readers, one per asset kind, because AQP keeps a separate sync counter \
            \ per kind. Extracted from URC_13|AnchorDetail rather than nested inline: a \
            \ three-way ternary at that depth put the arms at column 46, where the only way \
            \ to see which reader an arm called was to count parentheses."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (= asset-kind "dptf")
                (ref-AQP::URC_BenDptfAnchorsNeedSync account asset-id)
                (if (= asset-kind "dpsf")
                    (ref-AQP::URC_BenDpsfAnchorsNeedSync account asset-id)
                    (ref-AQP::URC_BenDpnfAnchorsNeedSync account asset-id)
                )
            )
        )
    )

    (defun URC_13|AnchorDetail:object (anchor-id:string account:string)
        @doc "One anchor as the detail panel shows it: the row, this account's promille in it, \
            \ and whether that figure is STALE. \
            \ \
            \ Staleness is per ANCHORED ASSET, not per anchor, because the repair is: \
            \ `AQP|C_SyncTrueFungibleAnchors patron executee dptf-id` refreshes EVERY \
            \ anchor \
            \ standing on that asset in one call. A per-anchor flag would invite a per- \
            \ anchor \
            \ button and bill the user once per anchor for one piece of work."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (row:object (URC_13|AnchorRow anchor-id))
            )
            (let
                (
                    (asset:string (at "asset-id" row))
                    (kind:string (at "asset-kind" row))
                )
                {"row"              : row
                ,"my-promille"      : (ref-ANK::UR_ANK-U|Promile account anchor-id)
                ,"my-class-total"   : (ref-ANK::UR_UB|AggregatePromile
                                          account (at "boost-class-id" row))
                ;;The repair unit, named so the client does not have to re-derive it.
                ,"repair-asset-id"  : asset
                ,"needs-sync"       : (URC_13|NeedsSync account asset kind)}
            )
        )
    )

    (defun URC_13|AnchorFull:object (anchor-id:string account:string)
        @doc "EVERYTHING about one anchor, for the detail view behind a row click. \
            \ \
            \ Every one of ANK|Schema's twelve fields is reachable through the interface, so \
            \ this needed no new sovereign reader -- it is composition, not capability. What \
            \ it adds over URC_13|AnchorDetail is the CONTEXT a row cannot carry: what else is \
            \ anchored on the same asset, how full that asset's 49-slot cap is, and what the \
            \ boost class looks like from the inside. \
            \ \
            \ MODE is NAMED rather than left to the caller to infer. Only ONE of the four \
            \ terms fields is live on any anchor; the rest hold sentinels (0.0, 0, \
            \ BAR, -1), so a client deciding for itself which to believe is a client that will \
            \ eventually believe the wrong one."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (row:object (URC_13|AnchorRow anchor-id))
                (fung:[bool] (ref-ANK::UR_ANK|Fungibility anchor-id))
            )
            (let
                (
                    (kind:string (URC_13|AnchorKind fung))
                    (asset:string (at "asset-id" row))
                    (bc:string (at "boost-class-id" row))
                )
                {"row"              : row
                ,"mode"             : (if (= kind "dptf") "amount"
                                      (if (= kind "dpsf") "nonce"
                                      (if (ref-ANK::URC_TraitOrClass anchor-id)
                                          "trait" "set-class")))
                ;;THE RAW TERMS FIELDS, all four, unfiltered. The detail shows which one is live
                ;;AND what the others hold, because "nonce-class: -1" is how a reader CONFIRMS
                ;;this is a trait anchor rather than taking the mode above on trust.
                ,"tf-amount"        : (ref-ANK::UR_ANK|TFAmount anchor-id)
                ,"sf-nonce"         : (ref-ANK::UR_ANK|SFNonce anchor-id)
                ,"trait-key"        : (ref-ANK::UR_ANK|NFTraitKey anchor-id)
                ,"trait-value"      : (ref-ANK::UR_ANK|NFTraitValue anchor-id)
                ,"nonce-class"      : (ref-ANK::UR_ANK|NFNonceClass anchor-id)
                ,"fungibility"      : fung
                ;;THE ASSET and its anchor bookkeeping. `anchors-on-asset` against the cap of 49
                ;;(UEV_AssetAnchorCap: 7 groups x 7 slots) is what a manager needs before
                ;;issuing another; `groups-on-asset` is the other half of that structure.
                ,"asset-owner"      : (ref-ANK::URC_AnchorableAssetOwner asset fung)
                ,"anchors-on-asset" : (ref-ANK::UR_AA|AnchorsActive asset)
                ,"groups-on-asset"  : (ref-ANK::UR_AA|GroupsActive asset)
                ;;SIBLINGS -- the other anchors on the same asset. They matter for one concrete
                ;;reason: the repair is per ASSET, so syncing this one refreshes all of them,
                ;;and the detail view should say which.
                ,"siblings"         : (filter (lambda (a:string) (!= a anchor-id))
                                          (ref-ANK::UR_ANK|AnchorsForAsset asset))
                ;;THE CLASS, from the inside. A non-zero score-link count LOCKS the class's
                ;;anchors against revocation, which is why an owner's revoke is refused.
                ,"class-active"     : (ref-ANK::UR_BC|Active bc)
                ,"class-slots"      : (ref-ANK::UR_BC|Anchors bc)
                ,"class-score-links": (ref-ANK::UR_BC|ScoreLinkCount bc)
                ;;MINE.
                ,"my-promille"      : (ref-ANK::UR_ANK-U|Promile account anchor-id)
                ,"my-class-total"   : (ref-ANK::UR_UB|AggregatePromile account bc)
                ,"needs-sync"       : (URC_13|NeedsSync account asset kind)}
            )
        )
    )

    (defun URH_13|AnchorCatalogue:[object] ()
        @doc "B view -- EVERY anchor on chain, whether or not it concerns the caller. \
            \ \
            \ HEAVY: reaches AQP-ANK's own `URH_ANK|AllAnchorIds` and then reads ~10 \
            \ fields per \
            \ anchor. The scan is the callee's, so this composes normally -- but the \
            \ prefix is \
            \ `URH_` because the COST is heavy, and a caller reading `URC_` would budget \
            \ for a \
            \ point read. Not `try`-composable: RULES.md rule 5."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (map (lambda (a:string) (URC_13|AnchorRow a)) (ref-ANK::URH_ANK|AllAnchorIds))
        )
    )

    (defun URH_13|MyAnchors:[object] (account:string)
        @doc "A view -- the anchors this account holds a NON-ZERO promille in, with staleness. \
            \ \
            \ Filtered on the server side deliberately. The client could fetch the \
            \ catalogue and \
            \ filter, but then every wallet downloads every anchor on the chain to find \
            \ its own \
            \ three, and the filter predicate lives in two places."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (map
                (lambda (a:string) (URC_13|AnchorDetail a account))
                (filter
                    (lambda (a:string) (< 0.0 (ref-ANK::UR_ANK-U|Promile account a)))
                    (ref-ANK::URH_ANK|AllAnchorIds)
                )
            )
        )
    )

    (defun URH_13|BoostClasses:[object] (account:string)
        @doc "C view -- every boost class, with its members, its lock state and this account's \
            \ aggregate in it. \
            \ \
            \ MEMBERS ARE DERIVED, NOT READ. `UR_BC|Anchors` returns only a COUNT, and the \
            \ seven \
            \ `anchor-*` slot fields live in the module-only `UR_BC|Data`. Filtering the \
            \ anchor \
            \ list by `UR_ANK|BoostClassId` gets the same answer from a list already \
            \ fetched, \
            \ and avoids the in-module dot call that would hard-break this module on an \
            \ AQP-ANK \
            \ upgrade (see the header). \
            \ \
            \ NO `class-owner`. It is reachable only through that same module-only reader; \
            \ the \
            \ UI reads it at /local top level in the same request. The header gives the \
            \ form."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (all-anchors:[string] (ref-ANK::URH_ANK|AllAnchorIds))
            )
            (map
                (lambda (c:string)
                    (let
                        (
                            (members:[string]
                                (filter
                                    (lambda (a:string)
                                        (= c (ref-ANK::UR_ANK|BoostClassId a)))
                                    all-anchors))
                        )
                        {"boost-class-id"   : c
                        ,"slots-used"       : (ref-ANK::UR_BC|Anchors c)
                        ,"active"           : (ref-ANK::UR_BC|Active c)
                        ;;Non-zero LOCKS the class's anchors against revocation. A client-side
                        ;;fact because it is why a manager's revoke button is refused.
                        ,"score-links"      : (ref-ANK::UR_BC|ScoreLinkCount c)
                        ,"my-aggregate"     : (ref-ANK::UR_UB|AggregatePromile account c)
                        ,"members"          : (map (lambda (a:string) (URC_13|AnchorRow a))
                                                   members)
                        ,"max-promille"     : (fold (+) 0.0
                                                  (map (lambda (a:string)
                                                           (ref-ANK::UR_ANK|Promile a))
                                                       members))}
                    )
                )
                (ref-ANK::URH_BC|AllBoostClassIds)
            )
        )
    )

    (defun URH_13|MyAnchorableAssets:[object] (account:string)
        @doc "MANAGER: what this account owns that an anchor can be issued against, over \
            \ three asset kinds, each with its name and its current anchor count. \
            \ \
            \ `anchors-used` is the thing a manager needs before issuing: an asset caps at \
            \ 49 \
            \ anchors (`UEV_AssetAnchorCap`), and nothing else on the page would say how \
            \ close \
            \ it is. \
            \ \
            \ VERY HEAVY -- THREE scans, two of them owner scans over whole-collection \
            \ tables. \
            \ `DPDC::URH_OwnedCollectables` measured FAILING at a 150,000 gas limit and \
            \ passing \
            \ at 1,500,000, so this is `/local` only and needs a generous limit."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (+
                (map
                    (lambda (i:string) (URC_13|AnchorableAsset i [true true]))
                    (ref-DPTF::URH_OwnedTrueFungibles account))
                (+
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [false true]))
                        (ref-DPDC::URH_OwnedCollectables account true))
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [false false]))
                        (ref-DPDC::URH_OwnedCollectables account false))
                )
            )
        )
    )

    (defun URC_13|AnchorableAsset:object (asset-id:string asset-fungibility:[bool])
        @doc "One owned asset as the manager's picker shows it. Split out of \
            \ URH_13|MyAnchorableAssets so the three kinds share one shape rather than \
            \ three \
            \ near-identical inline objects."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (named:object (URC_13|AssetName asset-id asset-fungibility))
            )
            {"asset-id"         : asset-id
            ,"asset-name"       : (at "name" named)
            ,"asset-ticker"     : (at "ticker" named)
            ,"asset-kind"       : (URC_13|AnchorKind asset-fungibility)
            ;;Against the 49-slot cap in UEV_AssetAnchorCap.
            ,"anchors-used"     : (ref-ANK::UR_AA|AnchorsActive asset-id)}
        )
    )
)

