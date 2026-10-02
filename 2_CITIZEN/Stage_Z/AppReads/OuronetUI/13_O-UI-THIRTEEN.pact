;; ===========================================================================================
;; O-UI-THIRTEEN -- the EarningPools page. SLICE 1: ANCHORS, client and manager.
;; ===========================================================================================
;; OuronetUI entity 13. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;; Intelligence and the design decisions: ./README-THIRTEEN-ANCHORS.md.
;;
;; REPLACES NOTHING. Slot 13 had no DPL-UR reads behind it -- this is the first read module for
;; the acquisition system, written against 15 anchors and 6 boost classes live on chain.
;;
;; ------------------------------------------------------------------------------------------
;; NO CROSS-MODULE `keys` ANYWHERE IN THIS MODULE, and that is the whole reason it composes
;; ------------------------------------------------------------------------------------------
;; O-UI-EIGHT, -NINE and -TEN each quarantine a `(keys OTHER.Table)` in a `URH_` that nothing
;; calls, and pay for it three times: the node needs `--allowReadsInLocal`; the scan cannot sit
;; inside a `try`, because `try` runs its body in read-only mode where `keys` is disallowed
;; (RULES.md rule 5); and `_conformance.py` tolerates a cross-module scan only while the
;; containing function has ZERO Pact callers.
;;
;; None of that applies here. AQP-ANK, DPTF and DPDC each expose their OWN enumerators --
;; `URH_ANK|AllAnchorIds`, `URH_BC|AllBoostClassIds`, `URH_OwnedTrueFungibles`,
;; `URH_OwnedCollectables` -- which are those modules' to admin-gate and are therefore freely
;; composable through a modref. Every scan below is somebody else's, reached by `::`.
;;
;; The functions are still named `URH_` wherever they REACH one. The prefix is a cost class, not
;; a syntax check: a caller reading `URC_` would expect a point read and budget accordingly.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT THIS MODULE DELIBERATELY DOES NOT ANSWER: a boost class's OWNER
;; ------------------------------------------------------------------------------------------
;; `ANK|BoostClass` carries `class-owner`, and the only reader exposing it is `UR_BC|Data`,
;; which returns an object and is therefore module-only -- the interface object-return rule
;; keeps it out of `AcquisitionAnchorsV1`, so no modref can reach it.
;;
;; A dot call WOULD reach it, and must not be used here. Measured 2026-10-03:
;;
;;     TOP-LEVEL dot call, after the callee upgrades  ->  the NEW logic
;;     IN-MODULE dot call, after the callee upgrades  ->  "Execution aborted, hash not blessed
;;                                                         for module B"
;;
;; An in-module dot call pins the callee's hash, and Pact refuses TABLE ACCESS from a superseded
;; hash unless it is blessed. The tree blesses nothing. AQP-ANK reads its own tables, so dot-
;; calling it from here would HARD-BREAK this module on every AQP-ANK upgrade -- not go stale,
;; break. `_dotpin.py --upgrade AQP-ANK` reports exactly that.
;;
;; So the owner is read by the UI at `/local` top level, where a dot call always resolves to the
;; latest module, in the same request as the call to `URH_13|BoostClasses`:
;;
;;     (map (lambda (c:string) (at "class-owner" (ouronet-ns.AQP-ANK.UR_BC|Data c)))
;;          (ouronet-ns.AQP-ANK.URH_BC|AllBoostClassIds))
;;
;; Zero coupling, always current. The alternative -- bumping AcquisitionAnchorsV1 to V2 for two
;; accessors -- drags a cascade across the whole AQP family.
;;
;; ------------------------------------------------------------------------------------------
;; THE FUNGIBILITY TUPLE, decoded once here so no caller has to
;; ------------------------------------------------------------------------------------------
;;     [true  true ]  DPTF   true fungible      C_IssueTrueFungibleAnchor
;;     [false true ]  DPSF   semi fungible      C_IssueSemiFungibleAnchor      (son = true)
;;     [false false]  DPNF   non fungible       C_IssueNonFungible[Set]Anchor  (son = false)
;; So slot 0 is "is a true fungible" and slot 1 is the collectable `son` discriminator. The
;; name, the ticker, the staleness reader and the repair entrypoint all dispatch on it.
;;
;; ------------------------------------------------------------------------------------------
;; GAS -- a dirty read is free to the user, not free to the node
;; ------------------------------------------------------------------------------------------
;; `DPDC::URH_OwnedCollectables` FAILS at a 150,000 limit ("Evaluation did not reduce to a
;; value") and succeeds at 1,500,000. Measured, not assumed. Callers must issue these at a
;; generous `/local` gas limit; `URH_13|MyAnchorableAssets` reaches TWO such scans plus a name
;; read per asset.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiThirteenV1
    @doc "EarningPools reads, slice 1: anchors. The catalogue, an account's own anchor values, \
        \ one anchor in detail, the boost classes, and the manager's anchorable assets."

    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_13|AnchorKind:string (asset-fungibility:[bool]))
    (defun URC_13|AssetName:object (asset-id:string asset-fungibility:[bool]))
    (defun URC_13|AnchorTerms:string (anchor-id:string))
    (defun URC_13|AnchorRow:object (anchor-id:string))
    (defun URC_13|NeedsSync:bool (account:string asset-id:string asset-kind:string))
    (defun URC_13|AnchorDetail:object (anchor-id:string account:string))
    (defun URH_13|AnchorCatalogue:[object] ())
    (defun URH_13|MyAnchors:[object] (account:string))
    (defun URH_13|BoostClasses:[object] (account:string))
    (defun URH_13|MyAnchorableAssets:[object] (account:string))
)

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
                    ;;TRAIT anchor the reverse. The discriminator is the class, which is -1
                    ;;in trait mode -- documented in ANK|Schema, and the only way to tell.
                    (if (= (ref-ANK::UR_ANK|NFNonceClass anchor-id) -1)
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
