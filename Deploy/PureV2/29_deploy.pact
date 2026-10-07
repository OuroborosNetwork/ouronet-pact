;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 29
;; O-UI-THIRTEEN -- the manager picker learns AUTHORITY, not just ownership
;; =========================================================================================
;; MODULE-ONLY. `OUiThirteenV1` went live with PureV2/25 and a deployed interface cannot be
;; re-sent or changed, so the new reader is declared in the MODULE and not in the interface --
;; a module may expose MORE than its interface declares, never less. A read module owns no
;; tables, so this is a plain redeploy with nothing to migrate.
;;
;; -----------------------------------------------------------------------------------------
;; WHAT IS NEW: URH_13|MyAuthorityTrueFungibles (account)
;; -----------------------------------------------------------------------------------------
;; True fungibles the account may ANCHOR BUT DOES NOT OWN, concatenated onto the owned list by
;; `URH_13|MyAnchorableAssets`. Two sources, and both were invisible until now:
;;
;;   SPECIALS. An `F|` frozen or `R|` reserved token is owned by the VESTING contract --
;;     `XI_CreateSpecialTrueFungibleLink` issues it to `VST|SC_NAME` with can-change-owner
;;     false -- while `CAP_TF|Owner` resolves it to its PARENT and enforces the PARENT's
;;     ownership. So the parent's owner is the authority and never saw the asset.
;;
;;   LP TOKENS. Owned by `SWP|SC_NAME`, equally permanently. Since PureV2/27,
;;     `URCv_AnchorableDptfAuthority` resolves one to the POOL OWNER of its swpair.
;;
;; MEASURED ON MAINNET BEFORE WRITING ANY OF IT (`DPTF::URH_OwnedTrueFungibles`):
;;     VST owns  F|ELITEAURYN-8ZLws7IkbT7x  F|SPARK-6B42e2_oW8j0
;;               F|VST-8Nh-JO8JO4F5         R|OURO-8Nh-JO8JO4F5
;;     SWP owns  W|SSTOA-OURO-WSTOA|LP-6D_MJJXmhuz3
;;     ATS owns  (none)
;; which is exactly what the manager was showing when those two SMART accounts were selected,
;; and exactly what it showed nobody else.
;;
;; -----------------------------------------------------------------------------------------
;; THE RULING THIS IMPLEMENTS
;; -----------------------------------------------------------------------------------------
;; VST, ATS and SWP own tokens as a PROTOCOL FUNCTION -- custody -- and that must never become a
;; route to managing them. Whoever controls those accounts should not be able to anchor what
;; they merely hold; the authority resolves through to the real party instead. The contract has
;; enforced this all along (`CAP_TF|Owner` for specials since 2026-09-20, LP since PureV2/27).
;; This is the READ side of the same rule: without it the only way to see such an asset was to
;; select the custodial account, which is precisely the route the ruling closes.
;;
;; DEDUPED AGAINST WHAT IS OWNED, inside the reader rather than at the call site: the caller
;; concatenates the two lists, and a token appearing in both would render as two assets.
;;
;; PINNED BY `[6.2.9]_AQP-BOOT-FULL.repl` <<OUI13-A7>> (gate entrypoint `AQP-FULL.repl`), which
;; asserts the list is NON-EMPTY before folding over it -- a `fold (and) true` over an empty
;; list is trivially true, so a reader that silently returned nothing would otherwise pass.
;;
;; -----------------------------------------------------------------------------------------
;; SIGNING / VERIFY
;; -----------------------------------------------------------------------------------------
;; `GOV|O_UI_THIRTEEN_ADMIN`. Afterwards, as a /local read with the POOL OWNER's account:
;;   (ouronet-ns.O-UI-THIRTEEN.URH_13|MyAuthorityTrueFungibles "<pool owner>")
;;     -> must include W|SSTOA-OURO-WSTOA|LP-6D_MJJXmhuz3
;; and with the owner of a token that has a frozen counterpart, that counterpart.
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact (module only -- its interface is already live)
(module O-UI-THIRTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiThirteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-THIRTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;The two SPECIAL true-fungible prefixes, mirroring `URCv_CoreDptf`'s own `cond`. Named here
    ;;because the special link is SYMMETRIC -- `UR_Frozen` answers the parent when handed a
    ;;special -- so "is this already a special" is the test that stops a link walk going
    ;;backwards. It is not a copy of `CT_ANK_LP_PREFIXES`; those are a different set for a
    ;;different question.
    (defconst CT_13_SPECIAL_PREFIXES:[string]   ["F|" "R|"])
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

    (defun URH_13|MyAuthorityTrueFungibles:[string] (account:string)
        @doc "True fungibles this account may ANCHOR BUT DOES NOT OWN. \
            \ \
            \ `URH_OwnedTrueFungibles` selects on `owner-konto`, so it answers ownership and \
            \ nothing else. Anchoring authority is wider than ownership in exactly two ways, \
            \ both of them deliberate, and a manager who sees only what they own cannot reach \
            \ either: \
            \ \
            \   SPECIALS. An `F|` frozen or `R|` reserved token is owned by the VESTING \
            \     contract -- `XI_CreateSpecialTrueFungibleLink` issues it to VST|SC_NAME with \
            \     can-change-owner false -- but `CAP_TF|Owner` resolves it to its PARENT and \
            \     enforces the parent's ownership. So the parent's owner is the authority. \
            \     Measured on mainnet: VST owns F|ELITEAURYN, F|SPARK, F|VST and R|OURO, and \
            \     they appeared in the manager ONLY when the VST smart account was selected. \
            \ \
            \   LP TOKENS. A liquidity-pool token is owned by SWP|SC_NAME, also permanently. \
            \     Since 2026-10-03 `URCv_AnchorableDptfAuthority` resolves it to the POOL \
            \     OWNER of its swpair, so the pool's owner is the authority. \
            \ \
            \ BOTH ARE CUSTODY, NOT MANAGEMENT. The owner's ruling is that VST, ATS and SWP own \
            \ tokens as a protocol function and must never be a route to managing them; the \
            \ authority resolves through to the real party instead. This reader is the read-side \
            \ of that ruling -- the contract already enforced it, and nothing showed it. \
            \ \
            \ RETURNS IDS ONLY, and never one the account already owns: the caller concatenates \
            \ this onto `URH_OwnedTrueFungibles`, so a token owned outright must not appear \
            \ twice. Deduped against that list here rather than at the call site, because a \
            \ duplicate asset in the picker is indistinguishable from two real assets."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (owned:[string] (ref-DPTF::URH_OwnedTrueFungibles account))
                (bar:string (ref-U|CT::CT_BAR))
            )
            (let
                (
                    ;;THE SPECIAL LINK IS SYMMETRIC, AND THAT IS WHAT MADE THE FIRST VERSION OF
                    ;;THIS WRONG. `XE_UpdateSpecialTrueFungible` calls `XI_UpdateFrozen` TWICE --
                    ;;core -> special AND special -> core -- so `UR_Frozen` answers the PARENT
                    ;;when handed a special. Measured on mainnet:
                    ;;
                    ;;    UR_Frozen "F|ELITEAURYN-8ZLws7IkbT7x" -> "ELITEAURYN-8Nh-JO8JO4F5"
                    ;;    UR_Frozen "ELITEAURYN-8Nh-JO8JO4F5"   -> "F|ELITEAURYN-8ZLws7IkbT7x"
                    ;;
                    ;;So walking the links from VST|SC_NAME -- which OWNS the four specials --
                    ;;returned their four PARENTS, tokens VST neither owns nor may anchor. The
                    ;;manager showed EliteAuryn, Spark, Vesta and Ouroboros as VST's to manage.
                    ;;
                    ;;Hence the `core-only` filter: follow the link only FROM a core token. An
                    ;;id that is already `F|`/`R|` has no counterpart to find -- it IS one.
                    (core-only:[string]
                        (filter (lambda (i:string)
                                    (not (contains (take 2 i) CT_13_SPECIAL_PREFIXES)))
                                owned))
                    ;;The LP token of every swpair this account owns. One pool, one LP token.
                    (lps:[string]
                        (map (lambda (p:string) (ref-SWP::UR_TokenLP p))
                             (ref-SWP::URH_OwnedSwapPairs account)))
                )
                (let
                    (
                        ;;`UR_Frozen`/`UR_Reservation` answer BAR when no counterpart was ever
                        ;;created, so this filter separates "has one" from "has none".
                        (specials:[string]
                            (filter
                                (lambda (i:string) (!= i bar))
                                (+ (map (lambda (i:string) (ref-DPTF::UR_Frozen i)) core-only)
                                   (map (lambda (i:string) (ref-DPTF::UR_Reservation i))
                                        core-only))))
                    )
                    ;;FILTERED BY THE AUTHORITY RULE ITSELF, not by the derivation that produced
                    ;;the candidate. This is the invariant the page needs -- "ids this account
                    ;;may anchor" -- and asking `URCv_AnchorableDptfAuthority` directly makes the
                    ;;reader correct even if a link direction or a prefix set changes under it.
                    ;;The derivation above only has to be a superset; this decides.
                    (filter (lambda (i:string)
                                (and (not (contains i owned))
                                     (= (ref-ANK::URCv_AnchorableDptfAuthority i) account)))
                            (distinct (+ specials lps)))
                )
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
                (+
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [true true]))
                        (ref-DPTF::URH_OwnedTrueFungibles account))
                    ;;AUTHORITY, NOT OWNERSHIP -- the two extra true-fungible sources.
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [true true]))
                        (URH_13|MyAuthorityTrueFungibles account)))
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

