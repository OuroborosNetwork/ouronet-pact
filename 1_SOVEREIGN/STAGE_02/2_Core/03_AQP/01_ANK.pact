(interface AcquisitionAnchorsV1
    (defun GOV|AqpKey ())
    (defun GOV|AQP|SC_NAME ())
    (defun GOV|AQP|PBL ())
    ;;
    ;;  [UCK]
    (defun UCK_Anchors:string (account:string anchor-id:string))
    (defun UCK_UserBoost:string (account:string boost-class-id:string))
    ;;
    ;;  [UR] ANK|Schema
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string))
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string))
    (defun UR_ANK|BoostClassId:string (anchor-id:string))
    (defun UR_ANK|Precision:decimal (anchor-id:string))
    (defun UR_ANK|State:bool (anchor-id:string))
    (defun UR_ANK|Promile:decimal (anchor-id:string))
    (defun UR_ANK|TFAmount:decimal (anchor-id:string))
    (defun UR_ANK|SFNonce:integer (anchor-id:string))
    (defun UR_ANK|NFTraitKey:string (anchor-id:string))
    (defun UR_ANK|NFTraitValue:string (anchor-id:string))
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string))
    (defun UR_ANK|ID:string (anchor-id:string))
    (defun UR_ANK|AllAnchorIds:[string] ())
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string))
    ;;  [UR] BoostClass
    (defun UR_BC|Anchors:integer (boost-class-id:string))
    (defun UR_BC|Active:bool (boost-class-id:string))
    (defun UR_BC|ID:string (boost-class-id:string))
    (defun UR_BC|AllBoostClassIds:[string] ())
    ;;  [UR] AssetAnchors
    (defun UR_AA|GroupsActive:integer (asset-id:string))
    (defun UR_AA|AnchorsActive:integer (asset-id:string))
    ;;  [UR] UserSchema
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string))
    (defun UR_ANK-U|Account:string (account:string anchor-id:string))
    (defun UR_ANK-U|ID:string (account:string anchor-id:string))
    ;;  [UR] UserBoostSchema
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string))
    ;;
    ;;  [URC]
    (defun URC_TrueFungibleAnchorPromile:decimal
        (anchor-id:string total-dptf-amount:decimal)
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
    )
    (defun URC_TraitOrClass:bool (anchor-id:string))
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string))
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer))
    ;;
    ;;  [UEV]
    (defun UEV_IMC ())
    (defun UEV_AnkFungibility (asset-fungibility:[bool]))
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal))
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string))
    (defun UEV_AssetAnchorCap (ank-asset:string))
    (defun UEV_LiveAnchor (anchor-id:string))
    ;;
    ;;  [C]
    (defun C_RevokeBoostClass:object{IgnisCollectorV1.OutputCumulator}
        (boost-class-id:string)
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator} (anchor-id:string))
    ;;
    (defcap AQP|GOV ())
    ;;
    ;;  [XE]  cross-module backward (FVT::XI_RefreshTrueFungibleStakeAnchors, C_SyncTrueFungibleAnchors)
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
    )
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
    )
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
    )
)
(module AQP-ANK GOV
    ;; REPL observability: REPL/Stage_02/[6.2.1]_AQP-ANK.repl tags each intra-tx group as TXnnn · mm · <slug> in ;;==== … ==== and (print "--- [TXnnn · mm · …] ---"); mm is 01.. within each begin-tx.
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionAnchorsV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP-ANK                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|ANK_ADMIN)))
    (defcap GOV|ANK_ADMIN ()                (enforce-guard GOV|MD_AQP-ANK))
    (defcap AQP|GOV ()
        @doc "Interface/deploy surface for AQP|SC_NAME governor rotate. Runtime compose: AQP-POOL.AQP|GOV only — \
            \ do not compose this cap from other modules."
        true
    )
    ;;{G3}
    (defun GOV|Demiurgoi ()
        @doc "Resolves the governance keyset from DALOS."
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )
    (defun GOV|NS_Use ()
        @doc "Namespace prefix for AQP governance keyset name."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE))
    )
    (defun GOV|AqpKey ()
        @doc "Governance keyset name for the AQP smart account (canonical — sibling AQP modules ref AQP-ANK)."
        (+ (GOV|NS_Use) ".dh_sc_aqp-keyset")
    )
    (defconst AQP|SC_KEY                    (GOV|AqpKey))
    (defun GOV|AQP|SC_NAME ()
        @doc "Symbolic name of the AQP sovereign smart DALOS account (canonical)."
        (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"])
    )
    (defconst AQP|SC_NAME                   (GOV|AQP|SC_NAME))
    (defun GOV|AQP|PBL ()
        @doc "Public branding/license payload for AQP|SC_NAME smart account deploy (canonical)."
        (at 0 ["9G.632vHq208xaznBw9AfwrFGmLBqkr7tqEzf2Msq389xqEknmfAk8qI5MM1MaszdgMtEBpo6rbuC09Do7F6pjc91jzy3JxI6fjCkyuIbDpDD5i8CxeCBL0dKdDu3d2uAAwl6wE6npnm4Mjxx6JhiFq1sKddsGjLH9BjHF0ljtegHrn39qIADru76Ftr9Kgxh6Ds2aj4EufG07uK9sFG38ej5vooDMr0wp8alqGdnIiJxbhmwEKEg44l8pI5LDq2EotoM2jq86x1EJ5hM4wkfhtq4ye610tkAMIdLrDD87Euk14aJgMwnrLmytzcCc3Kakrnhs8Jxy5dFeowGxzlx1bGHqfwEen0pLcd6nl9udGE9hfFucLjM1seKzv542nwzz5jrpKmvzebI4BLK00Br1ocvxs4uor2nEv2Fng1l6qAiLcbv0hMnbLDEEcLpF1bD55gw55of7H2c3ieozahorkuCe5FEkAkEAhcGwJ35HCletrbcn2Ebo0fsD0tf2zxKsbzinpcJCtpv4EF4AyyhwD1LbtEd6qsEbgyJkA2DqdGBE5Fuqudzf8082Ei88d"])
    )
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|ANK|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ANK|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()
        @doc "Returns policy metadata key from DALOS policy module."
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info))
    )
    (defun P|UR:guard (policy-name:string)
        @doc "Reads one policy guard by policy name."
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        @doc "Reads imported policy guards list."
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        @doc "Writes or updates one local policy guard entry."
        (with-capability (GOV|ANK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Appends one imported policy guard entry."
        (with-capability (GOV|ANK_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        @doc "Post-deploy hook (AQP-BOOT Step 0). No cross-module IMP registration required — \
            \ ANK calls DALOS UR_*/CAP_*/UEV_* only (no DALOS UEV_IMC on those paths); client entry is Talos P|TALOS-SUMMONER."
        true
    )
    (defun UEV_IMC ()
        @doc "Enforces that caller matches an imported policy guard."
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;1]General Anchor Definition
    (defschema ANK|Schema
        @doc "General Anchor Definition \
            \ Each Anchor is defined via a so called Anchored-Asset \
            \ This may be a DPTF, DPSF or DPNF; It designation is stored here; \
            \ Along with the Anchor Precision and the Anchor ID itself \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <CAP_Owner>"
        ank-asset:string            ;;[.]   ID of the the Anchored Asset
        ank-fungibility:[bool]      ;;[.]   Stores the fungibility of the Asset the Anchor is based on.
        boost-class-id:string       ;;[.]   BoostClass this anchor belongs to
        ank-precision:integer       ;;[.]   Precision of the Anchor Variable [min 2 - max 8]
        ank-active:bool             ;;[M]   Stores if the Anchor is active or not. It can be inactivated by revoking it
        ank-promile:decimal         ;;[.]   Promile-value of Anchor
        ;;
        ;;DPTF Anchor ONLY
        dptf-amount:decimal         ;;[.]   DPTF Amount for the defined <promile> [0.0 when not DPTF Anchor]
        ;;
        ;;DPSF Anchor ONLY
        dpsf-nonce:integer          ;;[.]   DPSF Nonce for the defined <promile> [0 when not DPSF Anchor]
        ;;
        ;;DPNF Anchor ONLY
        dpnf-trait-key:string       ;;[.]   DPNF Trait-Key for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-trait-value:string     ;;[.]   DPNF Trait-Value for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-nonce-class:integer    ;;[.]   DPNF Nonce-Class for set anchors [-1 when trait mode, 0 all native NFTs, >0 specific set class]
        ;;
        ;;Select Keys
        anchor-id:string
    )
    ;;2]BoostClass Definition
    (defschema ANK|BoostClass
        @doc "Heterogeneous anchor grouping for score boosting. \
            \ Not tied to any asset-id. Up to 7 anchor slots from different asset types."
        anchor-primary:string       ;;[M]   1st anchor slot
        anchor-secondary:string     ;;[M]   2nd anchor slot
        anchor-tertiary:string      ;;[M]   3rd anchor slot
        anchor-quaternary:string    ;;[M]   4th anchor slot
        anchor-quinary:string       ;;[M]   5th anchor slot
        anchor-senary:string        ;;[M]   6th anchor slot
        anchor-septenary:string     ;;[M]   7th anchor slot
        ;;
        anchors:integer             ;;[M]   Count of active anchors (0-7)
        class-active:bool           ;;[M]   Active flag
        ;;
        ;;Select Keys
        boost-class-id:string       ;;[.]   Self-referential ID
    )
    ;;3]Per-Asset Bookkeeping
    (defschema ANK|AssetAnchors
        @doc "Tracks all anchors for one asset-id. 7 internal groups x 7 slots = 49 cap. \
            \ Single read gives all anchor-ids for an asset."
        group-primary:object{ANK|InternalGroup}
        group-secondary:object{ANK|InternalGroup}
        group-tertiary:object{ANK|InternalGroup}
        group-quaternary:object{ANK|InternalGroup}
        group-quinary:object{ANK|InternalGroup}
        group-senary:object{ANK|InternalGroup}
        group-septenary:object{ANK|InternalGroup}
        ;;
        groups-active:integer       ;;[M]   Groups in use (0-7)
        anchors-active:integer      ;;[M]   Total anchors across all groups (0-49)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Self-referential asset-id
    )
    (defschema ANK|InternalGroup
        @doc "Nested schema for ANK|AssetAnchors group slots (not a table). Up to 7 anchor slots per group."
        anchor-primary:string
        anchor-secondary:string
        anchor-tertiary:string
        anchor-quaternary:string
        anchor-quinary:string
        anchor-senary:string
        anchor-septenary:string
        anchors:integer             ;;Count within this group (0-7)
    )
    ;;4]User Anchor Values
    (defschema ANK|UserSchema
        @doc "Stores the cumulate promile of a given <ouronet-account> for a given <anchor-id> \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <ouronet-account> Ownership"
        promile:decimal             ;;[M]   Promile of User with Anchor
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   Stores the Ouronet Account for which the Anchor Value is saved
        anchor-id:string            ;;[.]   Stores the Anchor-ID
    )
    ;;5]Per-User Per-BoostClass Aggregate
    (defschema ANK|UserBoostSchema
        @doc "Aggregate promile for one user across all anchors in one BoostClass. \
            \ Eagerly updated whenever any member anchor promile changes for this user."
        aggregate-promile:decimal   ;;[M]   Sum of user promiles across member anchors
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   User account
        boost-class-id:string       ;;[.]   BoostClass reference
    )
    ;;
    ;;{2}
    (deftable ANK|T|Anchor:{ANK|Schema})                        ;;Key = <Anchor-ID>
    (deftable ANK|T|BoostClass:{ANK|BoostClass})                ;;Key = <Boost-Class-ID>
    (deftable ANK|T|AssetAnchors:{ANK|AssetAnchors})            ;;Key = <Asset-ID>
    ;;
    (deftable ANK|T|Anchors:{ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    (deftable ANK|T|UserBoost:{ANK|UserBoostSchema})            ;;Key = <Ouronet-Account> | <Boost-Class-ID>
    ;;{3}
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR))
    )
    (defconst BAR                   (CT_Bar))
    (defconst E-ANK
        {"promile"                  : 0.0
        ,"ouronet-account"          : BAR
        ,"anchor-id"                : BAR}
    )
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap ANK|C>REVOKE-BOOST-CLASS (boost-class-id:string)
        @doc "Authorizes revoking an empty BoostClass."
        @event
        (let
            (
                (bc:object{ANK|BoostClass} (UR_BC|Data boost-class-id))
            )
            (enforce (= (at "anchors" bc) 0) (format "{} BoostClass {} not empty" [E-ANK boost-class-id]))
            (enforce (at "class-active" bc) (format "{} BoostClass {} already inactive" [E-ANK boost-class-id]))
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>ISSUE-DPTF
        (anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Validates DPTF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (fourth:string (drop 3 (take 4 dptf-id)))
                (first-two:string (take 2 dptf-id))
            )
            (enforce
                (fold (and) true 
                    [
                        (!= fourth BAR)
                        (!= first-two "S|")
                        (!= first-two "W|")
                        (!= first-two "P|")
                    ]
                )
                (format "Anchor cannot be issued for the DPTF {}." [dptf-id])
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPTF::UEV_id dptf-id)
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (CAP_TF|Owner dptf-id)
            (if acnoi
                (UEV_AssetAnchorCap dptf-id)
                (UEV_IssueAnchor dptf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPSF
        (anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Validates DPSF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpsf-id true)
            (ref-DPDC::UEV_Nonce dpsf-id true dpsf-nonce)
            (ref-DPDC::CAP_OwnerOrCreator dpsf-id true)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpsf-id)
                (UEV_IssueAnchor dpsf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPNF
        (anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Validates DPNF trait-anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            (enforce
                (fold (and) true 
                    [
                        iz-key-present
                        (>= l 2)
                        (<= l 256)
                        (!= dpnf-trait-value BAR)
                    ]
                )
                "Invalid Non-Fungible Key or Invalid Promile DPNF Trait-Value"
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|C>ISSUE-DPNF-SET
        (anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Validates DPNF set-anchor issuance via nonce-class model. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            (enforce
                (and (>= dpnf-nonce-class 0) (<= dpnf-nonce-class classes-used))
                (format "Invalid DPNF nonce-class {} for collection {}." [dpnf-nonce-class dpnf-id])
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|XI>ISSUE-DPNF-COMMON
        (anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal)
        @doc "Common DPNF issuance checks shared by trait and set modes."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpnf-id false)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpnf-id)
                (UEV_IssueAnchor dpnf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (anchor-id:string)
        @doc "Authorizes anchor revocation for <anchor-id>; requires anchor ownership."
        @event
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-BOOST-CLASS-ENTRY (boost-class-id:string)
        @doc "Authorizes revoking a BoostClass entity."
        @event
        (compose-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id))
    )
    (defcap ANK|C>UPDATE-DPTF (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Authorizes updating user promile for all live DPTF-backed anchors on <dptf-id> after stake/unstake."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            ;;1]<total-dptf-amount> must be non-negative (0.0 allowed — vacate/unstake refresh)
            (enforce (>= total-dptf-amount 0.0) "total-dptf-amount must be non-negative")
            ;;2]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;3]<dptf-id> must exist
            (ref-DPTF::UEV_id dptf-id)
            ;;4] when positive, <total-dptf-amount> must conform to DPTF precision
            (if (> total-dptf-amount 0.0)
                (ref-DPTF::UEV_Amount dptf-id total-dptf-amount)
                true
            )
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>UPDATE-DPSF (account:string dpsf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPSF-backed anchors on one asset (delegates to UPDATE-DPDC, SF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpsf-id nonces true))
    )
    (defcap ANK|C>UPDATE-DPNF (account:string dpnf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPNF-backed anchors on one asset (delegates to UPDATE-DPDC, NF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpnf-id nonces false))
    )
    (defcap ANK|C>UPDATE-DPDC (account:string asset-id:string nonces:[integer] son:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<nonces> must exist for the target DPDC asset + fungibility mode
            (ref-DPDC::UEV_NonceMapper asset-id son nonces)
        )
        (compose-capability (SECURE))
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UCK_Anchors:string
        (account:string anchor-id:string)
        @doc "Composite key for ANK|T|Anchors (account BAR anchor-id)."
        (concat [account BAR anchor-id])
    )
    (defun UCK_UserBoost:string
        (account:string boost-class-id:string)
        @doc "Composite key for ANK|T|UserBoost (account BAR boost-class-id)."
        (concat [account BAR boost-class-id])
    )
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) ANK|Schema (2) ANK|BoostClass (3) ANK|AssetAnchors (4) ANK|UserSchema (5) ANK|UserBoostSchema
    ;; Policy P|T, P|MT — not ANK rows; use P|Info, P|UR, P|UR_IMP above.
    ;;
    ;; [1] ANK|T|Anchor  (ANK|Schema)  Key = <Anchor-ID>
    ;; Core row: UR_ANK|Data
    (defun UR_ANK|Data:object{ANK|Schema} (anchor-id:string)
        @doc "Reads full anchor definition row from ANK|T|Anchor."
        (read ANK|T|Anchor anchor-id)
    )
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string)
        @doc "Reads anchored asset id from anchor row."
        (at "ank-asset" (read ANK|T|Anchor anchor-id ["ank-asset"]))
    )
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string)
        @doc "Reads anchor fungibility marker."
        (at "ank-fungibility" (read ANK|T|Anchor anchor-id ["ank-fungibility"]))
    )
    (defun UR_ANK|BoostClassId:string (anchor-id:string)
        @doc "Reads the BoostClass-ID this anchor belongs to."
        (at "boost-class-id" (read ANK|T|Anchor anchor-id ["boost-class-id"]))
    )
    (defun UR_ANK|Precision:decimal (anchor-id:string)
        @doc "Reads anchor precision as decimal."
        (dec (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"])))
    )
    (defun UR_ANK|State:bool (anchor-id:string)
        @doc "Reads anchor active flag."
        (at "ank-active" (read ANK|T|Anchor anchor-id ["ank-active"]))
    )
    (defun UR_ANK|Promile:decimal (anchor-id:string)
        @doc "Reads anchor promile value."
        (at "ank-promile" (read ANK|T|Anchor anchor-id ["ank-promile"]))
    )
    ;;
    (defun UR_ANK|TFAmount:decimal (anchor-id:string)
        @doc "Reads DPTF amount for TF anchor."
        (at "dptf-amount" (read ANK|T|Anchor anchor-id ["dptf-amount"]))
    )
    (defun UR_ANK|SFNonce:integer (anchor-id:string)
        @doc "Reads DPSF nonce for SF anchor."
        (at "dpsf-nonce" (read ANK|T|Anchor anchor-id ["dpsf-nonce"]))
    )
    (defun UR_ANK|NFTraitKey:string (anchor-id:string)
        @doc "Reads DPNF trait key for NF anchor."
        (at "dpnf-trait-key" (read ANK|T|Anchor anchor-id ["dpnf-trait-key"]))
    )
    (defun UR_ANK|NFTraitValue:string (anchor-id:string)
        @doc "Reads DPNF trait value for NF anchor."
        (at "dpnf-trait-value" (read ANK|T|Anchor anchor-id ["dpnf-trait-value"]))
    )
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string)
        @doc "Reads DPNF nonce-class for NF set-anchor mode."
        (at "dpnf-nonce-class" (read ANK|T|Anchor anchor-id ["dpnf-nonce-class"]))
    )
    (defun UR_ANK|ID:string (anchor-id:string)
        @doc "Reads anchor-id field from anchor row."
        (at "anchor-id" (UR_ANK|Data anchor-id))
    )
    (defun UR_ANK|AllAnchorIds:[string] ()
        @doc "Returns all row keys from ANK|T|Anchor."
        (keys ANK|T|Anchor)
    )
    ;;
    ;; [2] ANK|T|BoostClass  (ANK|BoostClass)  Key = <Boost-Class-ID>
    (defun UR_BC|Data:object{ANK|BoostClass} (boost-class-id:string)
        @doc "Reads full BoostClass row."
        (read ANK|T|BoostClass boost-class-id)
    )
    (defun UR_BC|Anchors:integer (boost-class-id:string)
        @doc "Reads anchor count from BoostClass."
        (at "anchors" (read ANK|T|BoostClass boost-class-id ["anchors"]))
    )
    (defun UR_BC|Active:bool (boost-class-id:string)
        @doc "Reads active flag from BoostClass."
        (at "class-active" (read ANK|T|BoostClass boost-class-id ["class-active"]))
    )
    (defun UR_BC|ID:string (boost-class-id:string)
        @doc "Reads boost-class-id from BoostClass row."
        (at "boost-class-id" (read ANK|T|BoostClass boost-class-id ["boost-class-id"]))
    )
    (defun UR_BC|AllBoostClassIds:[string] ()
        @doc "Returns all row keys from ANK|T|BoostClass."
        (keys ANK|T|BoostClass)
    )
    ;;
    ;; [3] ANK|T|AssetAnchors  (ANK|AssetAnchors)  Key = <Asset-ID>
    (defun UR_AA|Data:object{ANK|AssetAnchors} (asset-id:string)
        @doc "Reads full per-asset bookkeeping row (with-default-read when absent)."
        (let
            (
                (eg:object{ANK|InternalGroup} (UDC_EmptyInternalGroup))
            )
            (with-default-read ANK|T|AssetAnchors asset-id
                {"group-primary"     : eg
                ,"group-secondary"   : eg
                ,"group-tertiary"    : eg
                ,"group-quaternary"  : eg
                ,"group-quinary"     : eg
                ,"group-senary"      : eg
                ,"group-septenary"   : eg
                ,"groups-active"     : 0
                ,"anchors-active"    : 0
                ,"asset-id"          : asset-id}
                {"group-primary"     := g1
                ,"group-secondary"   := g2
                ,"group-tertiary"    := g3
                ,"group-quaternary"  := g4
                ,"group-quinary"     := g5
                ,"group-senary"      := g6
                ,"group-septenary"   := g7
                ,"groups-active"     := ga
                ,"anchors-active"    := aa
                ,"asset-id"          := aid}
                {"group-primary"     : g1
                ,"group-secondary"   : g2
                ,"group-tertiary"    : g3
                ,"group-quaternary"  : g4
                ,"group-quinary"     : g5
                ,"group-senary"      : g6
                ,"group-septenary"   : g7
                ,"groups-active"     : ga
                ,"anchors-active"    : aa
                ,"asset-id"          : aid}
            )
        )
    )
    (defun UR_AA|GroupsActive:integer (asset-id:string)
        @doc "Reads groups-active from asset anchors row."
        (at "groups-active" (UR_AA|Data asset-id))
    )
    (defun UR_AA|AnchorsActive:integer (asset-id:string)
        @doc "Reads anchors-active from asset anchors row."
        (at "anchors-active" (UR_AA|Data asset-id))
    )
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string)
        @doc "Live anchor-ids for an asset. Reads the single AssetAnchors row, \
            \ iterates all groups and slots, collects non-BAR active anchors."
        (let
            (
                (aa:object{ANK|AssetAnchors} (UR_AA|Data asset-id))
                (ga:integer (at "groups-active" aa))
            )
            (if (<= ga 0)
                []
                (fold
                    (lambda (acc:[string] gi:integer)
                        (let
                            (
                                (grp:object{ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                (q:integer (at "anchors" grp))
                            )
                            (if (<= q 0)
                                acc
                                (fold
                                    (lambda (acc2:[string] ai:integer)
                                        (let
                                            (
                                                (aid:string (URC_IG|AnchorIdAtSlot grp ai))
                                            )
                                            (if (and (!= aid BAR) (UR_ANK|State aid))
                                                (+ acc2 [aid])
                                                acc2
                                            )
                                        )
                                    )
                                    acc
                                    (enumerate 0 (- q 1))
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 6)
                )
            )
        )
    )
    ;;
    ;; [4] ANK|T|Anchors  (ANK|UserSchema)  Key = <Ouronet-Account> | <Anchor-ID>
    ;; Core row: UR_ANK-U|Data
    (defun UR_ANK-U|Data:object{ANK|UserSchema} (account:string anchor-id:string)
        @doc "Core read: user cumulative promile row for account x anchor."
        (with-default-read ANK|T|Anchors (UCK_Anchors account anchor-id)
            (UDC_AccountAnchor 0.0 account anchor-id)
            {"promile"                  := p
            ,"ouronet-account"          := oa
            ,"anchor-id"                := aid}
            (UDC_AccountAnchor p oa aid)
        )
    )
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string)
        @doc "Reads promile from user-anchor row."
        (at "promile" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|Account:string (account:string anchor-id:string)
        @doc "Reads account id from user-anchor row."
        (at "ouronet-account" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|ID:string (account:string anchor-id:string)
        @doc "Reads anchor id from user-anchor row."
        (at "anchor-id" (UR_ANK-U|Data account anchor-id))
    )
    ;;
    ;; [5] ANK|T|UserBoost  (ANK|UserBoostSchema)  Key = <Ouronet-Account> | <Boost-Class-ID>
    (defun UR_UB|Data:object{ANK|UserBoostSchema} (account:string boost-class-id:string)
        @doc "Reads user-boost aggregate row (with-default-read when absent)."
        (with-default-read ANK|T|UserBoost (UCK_UserBoost account boost-class-id)
            (UDC_UserBoost 0.0 account boost-class-id)
            {"aggregate-promile"   := ap
            ,"ouronet-account"     := oa
            ,"boost-class-id"      := bcid}
            (UDC_UserBoost ap oa bcid)
        )
    )
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string)
        @doc "Reads aggregate promile for user in a BoostClass."
        (at "aggregate-promile" (UR_UB|Data account boost-class-id))
    )
    ;;
    ;;{F1}  [URC]
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dptf-amount:decimal (UR_ANK|TFAmount anchor-id))
            )
            (if (<= dptf-amount 0.0)
                0.0
                (floor (* (/ total-dptf-amount dptf-amount) ank-promile) ank-precision)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Computes SF anchor promile from nonce equality model."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-nonces:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
        @doc "Computes NF anchor promile using trait mode or nonce-class mode."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Absolute SF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-amount:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
            )
            (floor (* (dec conform-amount) ank-promile) ank-precision)
        )
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
        @doc "Absolute NF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
            )
            (floor (* (dec conform-nonces) ank-promile) ank-precision)
        )
    )
    (defun URC_TraitOrClass:bool (anchor-id:string)
        @doc "Returns true for trait-mode; false for nonce-class mode."
        (fold (and) true
            [
                (!= (UR_ANK|NFTraitKey anchor-id) BAR)
                (!= (UR_ANK|NFTraitValue anchor-id) BAR)
                (= (UR_ANK|NFNonceClass anchor-id) -1)
            ]
        )
    )
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string)
        @doc "Outputs how many nonces from <nonces> have the proper MetaData Trait"
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (nonce-meta-data:object 
                                (ref-DPDC::UR_N|RawMetaData 
                                    (ref-DPDC::UR_NativeNonceData dpnf-id false nonce)
                                )
                            )
                            (has-trait-key:bool (contains trait-key nonce-meta-data))
                            (output:integer
                                (if (or (< nonce 0) (not has-trait-key))
                                    0
                                    (if (= trait-value (at trait-key nonce-meta-data))
                                        1
                                        0
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer)
        @doc "Outputs how many nonces from <nonces> conform to nonce-class mode."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (output:integer
                                (if (< nonce 0)
                                    0
                                    (if (= nonce-class 0)
                                        1
                                        (if (= (ref-DPDC::UR_NonceClass dpnf-id false nonce) nonce-class)
                                            1
                                            0
                                        )
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_TrueFungibleStakeAnchorRefreshIgnis:decimal (n-live:integer)
        @doc "Internal: ignis|small per live TF anchor refreshed (n_live = length UR_ANK|AnchorsForAsset). Zero when n_live ≤ 0."
        (if (<= n-live 0)
            0.0
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    ;;
                    (unit:decimal (ref-DALOS::UR_UsagePrice "ignis|small"))
                )
                (* (dec n-live) unit)
            )
        )
    )
    ;; --- AssetAnchors / BoostClass slot helpers (in-memory; UDC_AA|* and XI_2|Recompute*) ---
    (defun URC_BC|AnchorIdAtSlot:string (bc:object{ANK|BoostClass} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from a BoostClass object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" bc))
            ((= idx 1) (at "anchor-secondary" bc))
            ((= idx 2) (at "anchor-tertiary" bc))
            ((= idx 3) (at "anchor-quaternary" bc))
            ((= idx 4) (at "anchor-quinary" bc))
            ((= idx 5) (at "anchor-senary" bc))
            ((= idx 6) (at "anchor-septenary" bc))
            BAR
        )
    )
    (defun URC_AA|GroupAtSlot:object{ANK|InternalGroup} (aa:object{ANK|AssetAnchors} idx:integer)
        @doc "URC: reads internal group at slot idx (0..6) from an AssetAnchors object (in-memory)."
        (cond
            ((= idx 0) (at "group-primary" aa))
            ((= idx 1) (at "group-secondary" aa))
            ((= idx 2) (at "group-tertiary" aa))
            ((= idx 3) (at "group-quaternary" aa))
            ((= idx 4) (at "group-quinary" aa))
            ((= idx 5) (at "group-senary" aa))
            ((= idx 6) (at "group-septenary" aa))
            (UDC_EmptyInternalGroup)
        )
    )
    (defun URC_IG|AnchorIdAtSlot:string (ig:object{ANK|InternalGroup} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from an InternalGroup object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" ig))
            ((= idx 1) (at "anchor-secondary" ig))
            ((= idx 2) (at "anchor-tertiary" ig))
            ((= idx 3) (at "anchor-quaternary" ig))
            ((= idx 4) (at "anchor-quinary" ig))
            ((= idx 5) (at "anchor-senary" ig))
            ((= idx 6) (at "anchor-septenary" ig))
            BAR
        )
    )
    (defun URC_IG|ContainsAnchor:bool (ig:object{ANK|InternalGroup} anchor-id:string)
        @doc "URC: true when InternalGroup contains anchor-id (in-memory scan of seven slots)."
        (or (= anchor-id (at "anchor-primary" ig))
        (or (= anchor-id (at "anchor-secondary" ig))
        (or (= anchor-id (at "anchor-tertiary" ig))
        (or (= anchor-id (at "anchor-quaternary" ig))
        (or (= anchor-id (at "anchor-quinary" ig))
        (or (= anchor-id (at "anchor-senary" ig))
            (= anchor-id (at "anchor-septenary" ig))))))))
    )
    (defun URC_AA|SetGroupAtSlot:object{ANK|AssetAnchors}
        (aa:object{ANK|AssetAnchors} grp:object{ANK|InternalGroup} slot:integer ta:integer ga:integer adjust-ga:bool)
        @doc "URC: returns updated AssetAnchors with group replaced at slot (in-memory; used by UDC_AA|PlaceAnchor / RemoveAnchor)."
        (let
            (
                (g1:object{ANK|InternalGroup} (if (= slot 0) grp (at "group-primary" aa)))
                (g2:object{ANK|InternalGroup} (if (= slot 1) grp (at "group-secondary" aa)))
                (g3:object{ANK|InternalGroup} (if (= slot 2) grp (at "group-tertiary" aa)))
                (g4:object{ANK|InternalGroup} (if (= slot 3) grp (at "group-quaternary" aa)))
                (g5:object{ANK|InternalGroup} (if (= slot 4) grp (at "group-quinary" aa)))
                (g6:object{ANK|InternalGroup} (if (= slot 5) grp (at "group-senary" aa)))
                (g7:object{ANK|InternalGroup} (if (= slot 6) grp (at "group-septenary" aa)))
                (new-ta:integer ta)
                (new-ga:integer
                    (if adjust-ga
                        (if (= (at "anchors" grp) 0)
                            (- ga 1)
                            (+ ga 1)
                        )
                        ga
                    )
                )
            )
            {"group-primary"    : g1
            ,"group-secondary"  : g2
            ,"group-tertiary"   : g3
            ,"group-quaternary" : g4
            ,"group-quinary"    : g5
            ,"group-senary"     : g6
            ,"group-septenary"  : g7
            ,"groups-active"    : new-ga
            ,"anchors-active"   : new-ta
            ,"asset-id"         : (at "asset-id" aa)}
        )
    )
    ;;{F2}  [UEV]
    (defun UEV_AnkFungibility (asset-fungibility:[bool])
        @doc "Validates asset-fungibility tuple (TF/SF/NF discriminator) for anchor-class / asset-summary tables."
        (let
            (
                (l:integer (length asset-fungibility))
            )
            (enforce (and (= l 2) (!= asset-fungibility [true false])) "Invalid Fungibility")
        )
    )
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal)
        @doc "Validates Promile Variables"
        (enforce
            (fold (and) true 
                [
                    (>= anchor-precision 2)                                     ;;<anchor-precision> must be minimum 2
                    (<= anchor-precision 8)                                     ;;<anchor-precision> must be maximum 8
                    (= (floor anchor-promile anchor-precision) anchor-promile)  ;;variables must be conform with each-other
                    (> anchor-promile 0.0)                                      ;;<anchor-promile> must be bigger than 0.0
                    (< anchor-promile 100000000000.0)                           ;;<anchor-promile> has a max ceiling of 100 billion promile
                    
                ]
            )
            "Invalid Promile Variables"
        )
    )
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string)
        @doc "Validates BoostClass exists, is active, and has a free slot; also validates asset 49-anchor cap. Used when acnoi=false."
        (let
            (
                (bc:object{ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (enforce (at "class-active" bc) (format "{} BoostClass {} must be active" [E-ANK boost-class-id]))
            (enforce (< (at "anchors" bc) 7) (format "{} BoostClass {} full (7 anchors)" [E-ANK boost-class-id]))
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_AssetAnchorCap (ank-asset:string)
        @doc "Validates asset 49-anchor cap. Used when acnoi=true (BoostClass is new)."
        (let
            (
                (aa:object{ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_LiveAnchor (anchor-id:string)
        @doc "Validates anchor exists and is active."
        (let
            (
                (iz-anchor-active:bool (UR_ANK|State anchor-id))
            )
            (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_ANK|Schema:object{ANK|Schema}
        (a:string b:[bool] c:string d:integer e:bool f:decimal g:decimal h:integer i:string j:string k:integer l:string)
        @doc "Constructs anchor definition row for ANK|T|Anchor."
        {"ank-asset"            : a
        ,"ank-fungibility"      : b
        ,"boost-class-id"       : c
        ,"ank-precision"        : d
        ,"ank-active"           : e
        ,"ank-promile"          : f
        ,"dptf-amount"          : g
        ,"dpsf-nonce"           : h
        ,"dpnf-trait-key"       : i
        ,"dpnf-trait-value"     : j
        ,"dpnf-nonce-class"     : k
        ,"anchor-id"            : l}
    )
    (defun UDC_BoostClass:object{ANK|BoostClass}
        (a:string b:string c:string d:string e:string f:string g:string h:integer i:bool j:string)
        @doc "Constructs BoostClass object."
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"anchors"              : h
        ,"class-active"         : i
        ,"boost-class-id"       : j}
    )
    (defun UDC_EmptyInternalGroup:object{ANK|InternalGroup} ()
        @doc "Constructs empty InternalGroup (all BAR, anchors=0)."
        {"anchor-primary"       : BAR
        ,"anchor-secondary"     : BAR
        ,"anchor-tertiary"      : BAR
        ,"anchor-quaternary"    : BAR
        ,"anchor-quinary"       : BAR
        ,"anchor-senary"        : BAR
        ,"anchor-septenary"     : BAR
        ,"anchors"              : 0}
    )
    (defun UDC_IG|WithAddedAnchor:object{ANK|InternalGroup}
        (ig:object{ANK|InternalGroup} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in an InternalGroup."
        (let
            (
                (a1:string (at "anchor-primary" ig))
                (a2:string (at "anchor-secondary" ig))
                (a3:string (at "anchor-tertiary" ig))
                (a4:string (at "anchor-quaternary" ig))
                (a5:string (at "anchor-quinary" ig))
                (a6:string (at "anchor-senary" ig))
                (a7:string (at "anchor-septenary" ig))
                (n:integer (at "anchors" ig))
            )
            (cond
                ((= a1 BAR) {"anchor-primary": new-anchor-id, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a2 BAR) {"anchor-primary": a1, "anchor-secondary": new-anchor-id, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a3 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": new-anchor-id, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a4 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": new-anchor-id, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a5 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": new-anchor-id, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a6 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": new-anchor-id, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a7 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": new-anchor-id, "anchors": (+ n 1)})
                ig
            )
        )
    )
    (defun UDC_IG|WithRemovedAnchor:object{ANK|InternalGroup}
        (ig:object{ANK|InternalGroup} revoked-anchor-id:string)
        @doc "Removes anchor-id from group, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" ig)
                     (at "anchor-secondary" ig)
                     (at "anchor-tertiary" ig)
                     (at "anchor-quaternary" ig)
                     (at "anchor-quinary" ig)
                     (at "anchor-senary" ig)
                     (at "anchor-septenary" ig)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" ig))
            )
            {"anchor-primary"   : (at 0 lst-v2)
            ,"anchor-secondary" : (at 1 lst-v2)
            ,"anchor-tertiary"  : (at 2 lst-v2)
            ,"anchor-quaternary": (at 3 lst-v2)
            ,"anchor-quinary"   : (at 4 lst-v2)
            ,"anchor-senary"    : (at 5 lst-v2)
            ,"anchor-septenary" : (at 6 lst-v2)
            ,"anchors"          : (- n 1)}
        )
    )
    (defun UDC_BC|WithAddedAnchor:object{ANK|BoostClass}
        (bc:object{ANK|BoostClass} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in a BoostClass."
        (let
            (
                (a1:string (at "anchor-primary" bc))
                (a2:string (at "anchor-secondary" bc))
                (a3:string (at "anchor-tertiary" bc))
                (a4:string (at "anchor-quaternary" bc))
                (a5:string (at "anchor-quinary" bc))
                (a6:string (at "anchor-senary" bc))
                (a7:string (at "anchor-septenary" bc))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (cond
                ((= a1 BAR) (UDC_BoostClass new-anchor-id a2 a3 a4 a5 a6 a7 (+ n 1) ca bcid))
                ((= a2 BAR) (UDC_BoostClass a1 new-anchor-id a3 a4 a5 a6 a7 (+ n 1) ca bcid))
                ((= a3 BAR) (UDC_BoostClass a1 a2 new-anchor-id a4 a5 a6 a7 (+ n 1) ca bcid))
                ((= a4 BAR) (UDC_BoostClass a1 a2 a3 new-anchor-id a5 a6 a7 (+ n 1) ca bcid))
                ((= a5 BAR) (UDC_BoostClass a1 a2 a3 a4 new-anchor-id a6 a7 (+ n 1) ca bcid))
                ((= a6 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 new-anchor-id a7 (+ n 1) ca bcid))
                ((= a7 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 a6 new-anchor-id (+ n 1) ca bcid))
                bc
            )
        )
    )
    (defun UDC_BC|WithRemovedAnchor:object{ANK|BoostClass}
        (bc:object{ANK|BoostClass} revoked-anchor-id:string)
        @doc "Removes anchor-id from BoostClass, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" bc)
                     (at "anchor-secondary" bc)
                     (at "anchor-tertiary" bc)
                     (at "anchor-quaternary" bc)
                     (at "anchor-quinary" bc)
                     (at "anchor-senary" bc)
                     (at "anchor-septenary" bc)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (UDC_BoostClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (- n 1) ca bcid
            )
        )
    )
    (defun UDC_AA|PlaceAnchor:object{ANK|AssetAnchors}
        (aa:object{ANK|AssetAnchors} new-anchor-id:string)
        @doc "Places anchor in first group with a free slot; creates new group if needed."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (enforce (< ta 49) (format "{} 49-anchor cap reached for asset {}" [E-ANK aid]))
            (let
                (
                    (result:list
                        (fold
                            (lambda (acc:list gi:integer)
                                (if (= (at 1 acc) 1)
                                    acc
                                    (let
                                        (
                                            (grp:object{ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                            (gn:integer (at "anchors" grp))
                                        )
                                        (if (< gn 7)
                                            [(UDC_IG|WithAddedAnchor grp new-anchor-id) 1 gi]
                                            acc
                                        )
                                    )
                                )
                            )
                            [(UDC_EmptyInternalGroup) 0 -1]
                            (enumerate 0 6)
                        )
                    )
                    (placed:integer (at 1 result))
                )
                (if (= placed 1)
                    (let
                        (
                            (updated-grp:object{ANK|InternalGroup} (at 0 result))
                            (slot:integer (at 2 result))
                            (prev-grp:object{ANK|InternalGroup} (URC_AA|GroupAtSlot aa slot))
                            (new-ga:integer
                                (if (and (= (at "anchors" prev-grp) 0) (> (at "anchors" updated-grp) 0))
                                    (if (> ga (+ slot 1)) ga (+ slot 1))
                                    ga
                                )
                            )
                        )
                        (URC_AA|SetGroupAtSlot aa updated-grp slot (+ ta 1) new-ga false)
                    )
                    (let
                        (
                            (new-grp:object{ANK|InternalGroup} (UDC_IG|WithAddedAnchor (UDC_EmptyInternalGroup) new-anchor-id))
                        )
                        (enforce (< ga 7) (format "{} 7-group cap reached for asset {}" [E-ANK aid]))
                        (URC_AA|SetGroupAtSlot aa new-grp ga (+ ta 1) ga true)
                    )
                )
            )
        )
    )
    (defun UDC_AA|RemoveAnchor:object{ANK|AssetAnchors}
        (aa:object{ANK|AssetAnchors} revoked-anchor-id:string)
        @doc "Removes anchor from its group in AssetAnchors."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (fold
                (lambda (acc:object{ANK|AssetAnchors} gi:integer)
                    (let
                        (
                            (grp:object{ANK|InternalGroup} (URC_AA|GroupAtSlot acc gi))
                        )
                        (if (URC_IG|ContainsAnchor grp revoked-anchor-id)
                            (let
                                (
                                    (updated-grp:object{ANK|InternalGroup} (UDC_IG|WithRemovedAnchor grp revoked-anchor-id))
                                    (was-ga:integer (at "groups-active" acc))
                                    (was-ta:integer (at "anchors-active" acc))
                                    (grp-now-empty:bool (= (at "anchors" updated-grp) 0))
                                )
                                (URC_AA|SetGroupAtSlot acc updated-grp gi (- was-ta 1) was-ga grp-now-empty)
                            )
                            acc
                        )
                    )
                )
                aa
                (enumerate 0 6)
            )
        )
    )
    (defun UDC_AccountAnchor:object{ANK|UserSchema}
        (a:decimal b:string c:string)
        @doc "Constructs user-anchor contribution object."
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
    (defun UDC_UserBoost:object{ANK|UserBoostSchema}
        (aggregate-promile:decimal ouronet-account:string boost-class-id:string)
        @doc "Constructs user-boost aggregate row for ANK|T|UserBoost."
        {"aggregate-promile"   : aggregate-promile
        ,"ouronet-account"     : ouronet-account
        ,"boost-class-id"      : boost-class-id}
    )
    ;;{FW}  [W]
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    ;; [1] ANK|T|Anchor  (ANK|Schema)  Key = <Anchor-ID>
    (defun WI_Anchor:string
        (anchor-id:string row:object{ANK|Schema})
        @doc "Insert ANK|T|Anchor full row (issue only)."
        (require-capability (SECURE))
        (insert ANK|T|Anchor anchor-id row)
    )
    ;; WW_Anchor — not used: issue path is WI_Anchor; revoke uses WU_Anchor|State.
    ;; WU_Anchor|AnchoredAsset — not mutable [.]
    ;; WU_Anchor|Fungibility — not mutable [.]
    ;; WU_Anchor|BoostClassId — not mutable [.]
    ;; WU_Anchor|Precision — not mutable [.]
    (defun WU_Anchor|State:string
        (anchor-id:string ank-active:bool)
        @doc "Update ank-active on ANK|T|Anchor."
        (require-capability (SECURE))
        (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
    )
    ;; WU_Anchor|Promile — not mutable [.]
    ;; WU_Anchor|TFAmount — not mutable [.]
    ;; WU_Anchor|SFNonce — not mutable [.]
    ;; WU_Anchor|NFTraitKey — not mutable [.]
    ;; WU_Anchor|NFTraitValue — not mutable [.]
    ;; WU_Anchor|NFNonceClass — not mutable [.]
    ;; WU_Anchor|ID — select key; WU not needed.
    ;;
    ;; [2] ANK|T|BoostClass  (ANK|BoostClass)  Key = <Boost-Class-ID>
    (defun WI_BoostClass:string
        (boost-class-id:string row:object{ANK|BoostClass})
        @doc "Insert ANK|T|BoostClass full row (inline issue when acnoi)."
        (require-capability (SECURE))
        (insert ANK|T|BoostClass boost-class-id row)
    )
    (defun WW_BoostClass:string
        (boost-class-id:string row:object{ANK|BoostClass})
        @doc "Upsert full ANK|T|BoostClass row (bookkeeping add/remove anchor slots)."
        (require-capability (SECURE))
        (write ANK|T|BoostClass boost-class-id row)
    )
    ;; WU_BoostClass|Primary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Secondary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Tertiary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quaternary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quinary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Senary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Septenary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Anchors — not used: mutates via WW_BoostClass (full row).
    (defun WU_BoostClass|Active:string
        (boost-class-id:string class-active:bool)
        @doc "Update class-active on ANK|T|BoostClass."
        (require-capability (SECURE))
        (update ANK|T|BoostClass boost-class-id {"class-active": class-active})
    )
    ;; WU_BoostClass|ID — select key; WU not needed.
    ;;
    ;; [3] ANK|T|AssetAnchors  (ANK|AssetAnchors)  Key = <Asset-ID>
    ;; WI_AssetAnchors — not used: first row touch is WW_AssetAnchors (upsert path).
    (defun WW_AssetAnchors:string
        (asset-id:string row:object{ANK|AssetAnchors})
        @doc "Upsert full ANK|T|AssetAnchors row (place/remove anchor in groups)."
        (require-capability (SECURE))
        (write ANK|T|AssetAnchors asset-id row)
    )
    ;; WU_AssetAnchors|GroupPrimary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSecondary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupTertiary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuaternary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuinary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSeptenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AnchorsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AssetId — select key; WU not needed.
    ;;
    ;; [4] ANK|T|Anchors  (ANK|UserSchema)  Key = <Ouronet-Account> | <Anchor-ID>
    ;; WI_Anchors — not used: first row touch is WW_Anchors (upsert path).
    (defun WW_Anchors:string
        (account:string anchor-id:string promile:decimal)
        @doc "Upsert user promile on ANK|T|Anchors for (account, anchor-id)."
        (require-capability (SECURE))
        (write ANK|T|Anchors (UCK_Anchors account anchor-id)
            (UDC_AccountAnchor promile account anchor-id)
        )
    )
    ;; WU_Anchors|Promile — not used: mutates via WW_Anchors (full row).
    ;; WU_Anchors|Account — select key; WU not needed.
    ;; WU_Anchors|ID — select key; WU not needed.
    ;;
    ;; [5] ANK|T|UserBoost  (ANK|UserBoostSchema)  Key = <Ouronet-Account> | <Boost-Class-ID>
    ;; WI_UserBoost — not used: first row touch is WW_UserBoost (upsert path).
    (defun WW_UserBoost:string
        (account:string boost-class-id:string aggregate-promile:decimal)
        @doc "Upsert aggregate-promile on ANK|T|UserBoost."
        (require-capability (SECURE))
        (write ANK|T|UserBoost (UCK_UserBoost account boost-class-id)
            (UDC_UserBoost aggregate-promile account boost-class-id)
        )
    )
    ;; WU_UserBoost|AggregatePromile — not used: mutates via WW_UserBoost (full row).
    ;; WU_UserBoost|Account — select key; WU not needed.
    ;; WU_UserBoost|BoostClassId — select key; WU not needed.
    ;;{F4}  [CAP]
    (defun CAP_Owner (anchor-id:string)
        @doc "Enforces Anchor Ownership; This is computed as: \
        \ 1] For DPTFs Computed via <CAP_TF|Owner> \
        \ 2] For DPSFs and DPNFs can be either its Owner or Creator"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_ANK|Fungibility anchor-id))
            )
            (if (= ank-fungibility [true true])
                (CAP_TF|Owner ank-asset)
                (if (= ank-fungibility [false true])
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset true)
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset false)
                )
            )
        )
    )
    (defun CAP_TF|Owner (dptf-id:string)
        @doc "Enforces dptf-id Ownership, as underlying Dptf-Based Anchor Ownership \
        \ 3 DPTF variants can exist as underlying anchored asset: \
        \ 1] Pure DPTF      = Its Owner \
        \ 2] Frozen DPTF    = DPTF Parent Ownership \
        \ 3] Reserved DPTF  = DPTF Parent Ownership \
        \ \
        \ \
        \ 4] LP DPTF        = Cannot exist as underlaying DPTF-Based Anchor \
        \ 5] Frozen LP DPTF = Cannot exist as underlaying DPTF-Based Anchor"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (first-two:string (take 2 dptf-id))
                (core-dptf-id:string
                    (cond
                        ((= first-two "F|") (ref-DPTF::UR_Frozen dptf-id))
                        ((= first-two "R|") (ref-DPTF::UR_Reservation dptf-id))
                        dptf-id
                    )
                )
                (owner:string (ref-DPTF::UR_Konto core-dptf-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner)
        )
    )
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    (defun C_RevokeBoostClass:object{IgnisCollectorV1.OutputCumulator}
        (boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (UEV_IMC)
        (with-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (WU_BoostClass|Active boost-class-id false)
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    (stoa-multiplier:decimal (if acnoi 2.0 1.0))
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id) boost-class-name-or-id))
                    (fungibility:[bool] [true true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility boost-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dptf-id boost-class-id)
                (ref-IGNIS::KDA|C_Collect patron (* standard stoa-multiplier))
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger
                    (if acnoi [anchor-id boost-class-id] [anchor-id])
                )
            )
        )
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    (stoa-multiplier:decimal (if acnoi 2.0 1.0))
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id) boost-class-name-or-id))
                    (fungibility:[bool] [false true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpsf-id boost-class-id)
                (ref-IGNIS::KDA|C_Collect patron (* standard stoa-multiplier))
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger
                    (if acnoi [anchor-id boost-class-id] [anchor-id])
                )
            )
        )
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    (stoa-multiplier:decimal (if acnoi 2.0 1.0))
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 dpnf-trait-key dpnf-trait-value -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::KDA|C_Collect patron (* standard stoa-multiplier))
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger
                    (if acnoi [anchor-id boost-class-id] [anchor-id])
                )
            )
        )
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    (stoa-multiplier:decimal (if acnoi 2.0 1.0))
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 BAR BAR dpnf-nonce-class
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::KDA|C_Collect patron (* standard stoa-multiplier))
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger
                    (if acnoi [anchor-id boost-class-id] [anchor-id])
                )
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator}
        (anchor-id:string)
        @doc "Revokes an anchor and updates BoostClass and AssetAnchors bookkeeping."
        (UEV_IMC)
        (with-capability (ANK|C>REVOKE anchor-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (WU_Anchor|State anchor-id false)
                (XI_RevokeAnchorBookkeeping anchor-id)
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    ;;
    ;;{F7}  [X]
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* … ; XE_* / XB_* → XI_1|* (depth 1) → XI_2|* …
    ;; Blocks: map first, then functions in map order (entry → children → shared leaves).
    ;;
    ;; --- Block A · C_Issue*Anchor ---
    ;;   C_Issue*Anchor
    ;;     ├ XI_IssueBoostClass (optional)
    ;;     └ XI_IssueAnchor
    ;;          └ XI_PlaceAnchorInBookkeeping
    ;; --- Block B · C_RevokeAnchor ---
    ;;   C_RevokeAnchor → XI_RevokeAnchorBookkeeping
    ;; --- Block C · TF user promile (FVT phase 2.2 backward) ---
    ;;   XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ XI_1|UpdateTrueFungibleUserAnchorValues
    ;; --- Block D · SF user promile ---
    ;;   XE_UpdateSemiFungibleUserAnchorValues
    ;;     └ XI_1|UpdateSemiFungibleUserAnchorValues
    ;; --- Block E · NF user promile ---
    ;;   XE_UpdateNonFungibleUserAnchorValues
    ;;     └ XI_1|UpdateNonFungibleUserAnchorValues
    ;; --- Block F · shared leaf ---
    ;;   XI_2|RecomputeAffectedBoostAggregates (TF / SF / NF / resync)
    ;;
    (defun XI_IssueBoostClass:string
        (boost-class-name:string)
        @doc "Internal (C_Issue*Anchor · depth 0]): create BoostClass inline when acnoi; returns boost-class-id."
        ;; SECURE: granted by WI_BoostClass (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;
                (boost-class-id:string (ref-U|DALOS::UDC_Makeid boost-class-name))
            )
            (WI_BoostClass boost-class-id
                (UDC_BoostClass BAR BAR BAR BAR BAR BAR BAR 0 true boost-class-id)
            )
            boost-class-id
        )
    )
    (defun XI_IssueAnchor:string
        (
            ank-name:string ank-asset:string ank-fungibility:[bool] boost-class-id:string ank-precision:integer ank-promile:decimal
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
        )
        @doc "Internal (C_Issue*Anchor · depth 0]): insert ANK|T|Anchor row; returns anchor-id."
        ;; SECURE: granted by WI_Anchor (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;
                (anchor-id:string (ref-U|DALOS::UDC_Makeid ank-name))
            )
            (WI_Anchor anchor-id
                (UDC_ANK|Schema
                    ank-asset ank-fungibility boost-class-id ank-precision true ank-promile
                    dptf-amount dpsf-nonce dpnf-trait-key dpnf-trait-value dpnf-nonce-class anchor-id
                )
            )
            anchor-id
        )
    )
    (defun XI_PlaceAnchorInBookkeeping (anchor-id:string asset-id:string boost-class-id:string)
        @doc "Internal (C_Issue*Anchor · depth 1]): place anchor in BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (bc:object{ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{ANK|AssetAnchors} (UR_AA|Data asset-id))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithAddedAnchor bc anchor-id))
            (WW_AssetAnchors asset-id (UDC_AA|PlaceAnchor aa anchor-id))
        )
    )
    ;;
    ;; --- Block B · C_RevokeAnchor ---
    (defun XI_RevokeAnchorBookkeeping (anchor-id:string)
        @doc "Internal (C_RevokeAnchor · depth 0]): remove anchor from BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (boost-class-id:string (UR_ANK|BoostClassId anchor-id))
                (bc:object{ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithRemovedAnchor bc anchor-id))
            (WW_AssetAnchors ank-asset (UDC_AA|RemoveAnchor aa anchor-id))
        )
    )
    ;;
    ;; --- Block C · TF user promile ---
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Backward (FVT::XI_RefreshTrueFungibleStakeAnchors / C_Sync*): UEV_IMC + XI_1|UpdateTrueFungibleUserAnchorValues \
            \ when n_live > 0; IGNIS = ignis|small × n_live (live anchors on dptf-id). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPTF account dptf-id total-dptf-amount)
                    (XI_1|UpdateTrueFungibleUserAnchorValues account dptf-id total-dptf-amount)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dptf-id]
            )
        )
    )
    (defun XI_1|UpdateTrueFungibleUserAnchorValues
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Internal (XE_Update*TF · depth 1]): rewrite user promile for each live TF anchor on dptf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPTF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_TrueFungibleAnchorPromile aid total-dptf-amount))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block D · SF user promile ---
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates user promile for each live SF anchor on dpsf-id, then recomputes affected BoostClass aggregates."
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
            (XI_1|UpdateSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts direction)
        )
    )
    (defun XI_1|UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Internal (XE_Update*SF · depth 1]): rewrite user promile for each live SF anchor on dpsf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPSF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_SemiFungibleAnchorPromile account aid nonces nonce-amounts direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block E · NF user promile ---
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Updates user promile for each live NF anchor on dpnf-id, then recomputes affected BoostClass aggregates."
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
            (XI_1|UpdateNonFungibleUserAnchorValues account dpnf-id nonces direction)
        )
    )
    (defun XI_1|UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Internal (XE_Update*NF · depth 1]): rewrite user promile for each live NF anchor on dpnf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPNF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_NonFungibleAnchorPromile account aid nonces direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block D′ · SF resync (C_SyncCollectableAnchors · son=true) ---
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite SF promile from full rollup inventory; IGNIS per live anchor."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
                    (XI_1|ResyncSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpsf-id]
            )
        )
    )
    (defun XI_1|ResyncSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Internal (XE_ResyncSemiFungible* · depth 1]): absolute promile per live SF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_SemiFungibleAnchorPromileAbsolute aid nonces nonce-amounts)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block E′ · NF resync (C_SyncCollectableAnchors · son=false) ---
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV1.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite NF promile from full rollup inventory; IGNIS per live anchor."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
                    (XI_1|ResyncNonFungibleUserAnchorValues account dpnf-id nonces)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpnf-id]
            )
        )
    )
    (defun XI_1|ResyncNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer])
        @doc "Internal (XE_ResyncNonFungible* · depth 1]): absolute promile per live NF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_NonFungibleAnchorPromileAbsolute aid nonces)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block F · shared leaf ---
    (defun XI_2|RecomputeAffectedBoostAggregates (account:string boost-class-ids:[string])
        @doc "Internal (user promile update · depth 2 · shared leaf]): recompute ANK|T|UserBoost aggregate-promile per boost-class-id."
        ;; SECURE: granted by WW_UserBoost (underlying W_).
        ;; map: distinct boost-class-ids touched by anchor promile refresh
        (map
            (lambda (bcid:string)
                (let
                    (
                        (bc:object{ANK|BoostClass} (UR_BC|Data bcid))
                        (n:integer (at "anchors" bc))
                    )
                    (if (<= n 0)
                        true
                        (let
                            (
                                (agg:decimal
                                    ;; fold: anchor slots 0..n-1 in this BoostClass (sum user promile)
                                    (fold
                                        (lambda (acc:decimal idx:integer)
                                            (let
                                                (
                                                    (aid:string (URC_BC|AnchorIdAtSlot bc idx))
                                                )
                                                (if (= aid BAR)
                                                    acc
                                                    (+ acc (UR_ANK-U|Promile account aid))
                                                )
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- n 1))
                                    )
                                )
                            )
                            (WW_UserBoost account bcid agg)
                        )
                    )
                )
            )
            boost-class-ids
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table ANK|T|Anchor)
(create-table ANK|T|BoostClass)
(create-table ANK|T|AssetAnchors)
(create-table ANK|T|Anchors)
(create-table ANK|T|UserBoost)