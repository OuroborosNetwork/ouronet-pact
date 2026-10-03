;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 25
;; O-UI-THIRTEEN (FIRST DEPLOY) -- the EarningPools reads, slice 1: anchors
;; =========================================================================================
;; A NEW MODULE, so this ships the INTERFACE AND THE MODULE. Every other file in this round is
;; a module-only upgrade because its interface is already live; `OUiThirteenV1` is not, and a
;; module cannot implement an interface that has never been deployed.
;;
;; NO TABLES, so no `create-table` and nothing to migrate -- AppReads rule 1. That is what makes
;; a read module freely redeployable: there is no state to move, so a later slice (scores, pools,
;; aggregators) is a plain redeploy of this same module.
;;
;; INDEPENDENT OF 24. This neither needs nor is needed by `24_deploy.pact`. Deploy order between
;; the two does not matter.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IT ANSWERS -- the Anchors tab, client and manager
;; ------------------------------------------------------------------------------------------
;;   URH_13|AnchorCatalogue    ()                   B view: every anchor on chain
;;   URH_13|MyAnchors          (account)            A view: anchors the account holds a
;;                                                  NON-ZERO promille in, with staleness
;;   URC_13|AnchorDetail       (anchor-id account)  one anchor + my promille + the repair unit
;;   URH_13|BoostClasses       (account)            C view: classes, members, lock, my aggregate
;;   URH_13|MyAnchorableAssets (account)            manager: what the account owns that can be
;;                                                  anchored, with its count against the 49 cap
;; plus four helpers the rows are built from (AnchorKind, AssetName, AnchorTerms, AnchorRow,
;; NeedsSync), all declared so a client can call any of them directly.
;;
;; ------------------------------------------------------------------------------------------
;; NO CROSS-MODULE `keys`, WHICH IS WHY IT COMPOSES
;; ------------------------------------------------------------------------------------------
;; O-UI-EIGHT, -NINE and -TEN each quarantine a `(keys OTHER.Table)` in a `URH_` nothing calls,
;; and pay three times: the node needs `--allowReadsInLocal`, the scan cannot sit inside a `try`
;; (read-only mode forbids `keys`), and `_conformance.py` tolerates it only in a function with
;; ZERO Pact callers. None of that applies here -- AQP-ANK, DPTF and DPDC each expose their OWN
;; enumerators, so every scan is somebody else's, reached by modref.
;;
;; ------------------------------------------------------------------------------------------
;; ONE FIELD THIS MODULE DELIBERATELY DOES NOT ANSWER
;; ------------------------------------------------------------------------------------------
;; A boost class's `class-owner` lives only in the module-only `UR_BC|Data`. An IN-MODULE dot
;; call would reach it and must not be used: it pins AQP-ANK's hash, and because AQP-ANK reads
;; its own tables, a pinned caller does not go stale -- it ABORTS with "hash not blessed" on
;; AQP-ANK's next upgrade. Measured 2026-10-03; the tree blesses nothing.
;;
;; The UI reads it at `/local` TOP LEVEL instead, where a dot call always resolves to the latest
;; module, in the same request:
;;
;;     (map (lambda (c:string) (at "class-owner" (ouronet-ns.AQP-ANK.UR_BC|Data c)))
;;          (ouronet-ns.AQP-ANK.URH_BC|AllBoostClassIds))
;;
;; ------------------------------------------------------------------------------------------
;; GAS -- MEASURED, AND THE DEFAULT LIMIT IS NOT ENOUGH
;; ------------------------------------------------------------------------------------------
;; The full fixture block costs 442,937 gas over 30 anchors and 15 classes. On its own,
;; `DPDC::URH_OwnedCollectables` FAILS at a 150,000 limit ("Evaluation did not reduce to a
;; value") and succeeds at 1,500,000. These are `/local` dirty reads so nobody is charged, but a
;; caller that leaves the limit at its default gets an error that looks like a bug in the read.
;;
;; ------------------------------------------------------------------------------------------
;; VERIFICATION
;; ------------------------------------------------------------------------------------------
;; 21 assertions in `[6.2.9]_AQP-BOOT-FULL` <<OUI13-A1..A5>>, placed there and NOT in
;; APPREADS-OuronetUI -- that chain has no anchors, so every read would return `[]` and pass
;; while proving nothing. Here they run against the anchors Steps 2 and 3 have just issued.
;;
;; The fixture corrected three things while being written:
;;   · `slots-used` counts LIVE slots; a revoked anchor still points at its class. 16 live slots
;;     against 30 members in the fixture. The invariant asserted is that the ACTIVE members
;;     reproduce the stored count.
;;   · caller and owner can differ -- the boot steps run as ANHD while KBN is owned by LUMY, so
;;     the manager picker must be queried for the OWNER konto. (On mainnet the two coincide,
;;     which is why asserting it in a fixture is worth more than observing it in production.)
;;   · hardcoded counts are wrong in a shared chain -- [6.2.1] issues and revokes anchors first,
;;     so the catalogue is asserted against the chain's OWN enumerator, not a literal.
;;
;; NEGATIVE-TESTED: breaking the boost-class member filter turns 2 assertions red.
;; Gate green at 26,393 assertions.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact
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

