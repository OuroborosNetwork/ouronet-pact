(interface AcquisitionAnchors
    (defun GOV|AQP|SC_NAME ())
    ;;
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dptf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun C_RevokeAnchorClass:object{IgnisCollectorV1.OutputCumulator}
        (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator} (anchor-id:string))
)
(module AQP-ANK GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionAnchors)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP-ANK                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;
    (defconst AQP|SC_KEY                    (GOV|AqpKey))
    (defconst AQP|SC_NAME                   (GOV|AQP|SC_NAME))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|ANK_ADMIN)))
    (defcap GOV|ANK_ADMIN ()                (enforce-guard GOV|MD_AQP-ANK))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;; [Keys]
    (defun GOV|NS_Use ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|AqpKey ()                    (+ (GOV|NS_Use) ".dh_sc_aqp-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|AQP|SC_NAME ()               (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"]))
    ;;
    ;; [PBLs]
    (defun GOV|AQP|PBL ()                   (at 0 ["9G.632vHq208xaznBw9AfwrFGmLBqkr7tqEzf2Msq389xqEknmfAk8qI5MM1MaszdgMtEBpo6rbuC09Do7F6pjc91jzy3JxI6fjCkyuIbDpDD5i8CxeCBL0dKdDu3d2uAAwl6wE6npnm4Mjxx6JhiFq1sKddsGjLH9BjHF0ljtegHrn39qIADru76Ftr9Kgxh6Ds2aj4EufG07uK9sFG38ej5vooDMr0wp8alqGdnIiJxbhmwEKEg44l8pI5LDq2EotoM2jq86x1EJ5hM4wkfhtq4ye610tkAMIdLrDD87Euk14aJgMwnrLmytzcCc3Kakrnhs8Jxy5dFeowGxzlx1bGHqfwEen0pLcd6nl9udGE9hfFucLjM1seKzv542nwzz5jrpKmvzebI4BLK00Br1ocvxs4uor2nEv2Fng1l6qAiLcbv0hMnbLDEEcLpF1bD55gw55of7H2c3ieozahorkuCe5FEkAkEAhcGwJ35HCletrbcn2Ebo0fsD0tf2zxKsbzinpcJCtpv4EF4AyyhwD1LbtEd6qsEbgyJkA2DqdGBE5Fuqudzf8082Ei88d"]))
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
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|ANK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|ANK_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|ANK|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
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
        ank-class:string            ;;[.]   Stores the Asset Anchor Class [class-primary ... class-septenary]
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
        ;;
        ;;Select Keys
        anchor-id:string
    )
    ;;2]Asset Anchor Classes
    (defschema ANK|AnchorClass
        @doc "Stores Anchors existing for one specific class in one asset. \
            \ Each class may have up to 7 anchors."
        anchor-primary:string       ;;[M]   1st Asset Anchor
        anchor-secondary:string     ;;[M]   2nd Asset Anchor
        anchor-tertiary:string      ;;[M]   3rd Asset Anchor
        anchor-quaternary:string    ;;[M]   4th Asset Anchor
        anchor-quinary:string       ;;[M]   5th Asset Anchor
        anchor-senary:string        ;;[M]   6th Asset Anchor
        anchor-septenary:string     ;;[M]   7th Asset Anchor
        ;;
        class-name:string           ;;[.]   Class name used to derive class-id
        class-active:bool           ;;[M]   Stores if class is active
        ;;
        anchors:integer             ;;[M]   Stores number of active anchors in this class (0 to 7)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Stores the Asset ID
        class-id:string             ;;[.]   Stores the class-id
    )
    (defschema ANK|AssetAnchorClasses
        @doc "Stores classes used by one asset. \
            \ An asset may have up to 7 classes and each class up to 7 anchors."
        class-primary:string        ;;[M]   Key-ref to class-primary (BAR when absent)
        class-secondary:string      ;;[M]   Key-ref to class-secondary (BAR when absent)
        class-tertiary:string       ;;[M]   Key-ref to class-tertiary (BAR when absent)
        class-quaternary:string     ;;[M]   Key-ref to class-quaternary (BAR when absent)
        class-quinary:string        ;;[M]   Key-ref to class-quinary (BAR when absent)
        class-senary:string         ;;[M]   Key-ref to class-senary (BAR when absent)
        class-septenary:string      ;;[M]   Key-ref to class-septenary (BAR when absent)
        ;;
        classes:integer             ;;[M]   Number of active classes used (0 to 7)
        anchors:integer             ;;[M]   Total number of active anchors over all classes (0 to 49)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Stores the Asset ID
    )
    ;;3]User Anchor Values
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
    ;;
    ;;{2}
    (deftable ANK|T|Anchor:{ANK|Schema})                        ;;Key = <Anchor-ID>
    ;;
    (deftable ANK|T|TF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPTF-ID>
    (deftable ANK|T|SF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPSF-ID>
    (deftable ANK|T|NF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPNF-ID>
    ;;
    (deftable ANK|T|TF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPTF-ID> | <Class-ID>
    (deftable ANK|T|SF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPSF-ID> | <Class-ID>
    (deftable ANK|T|NF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPNF-ID> | <Class-ID>
    ;;
    (deftable ANK|T|Anchors:{ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
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
    (defcap ANK|C>ISSUE-DPTF
        (anchor-name:string dptf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Validates DPTF anchor issuance and class branch. \
            \ acnoi=true means class-name path (new class). \
            \ acnoi=false means class-id path (existing class)."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (fourth:string (drop 3 (take 4 dptf-id)))
                (first-two:string (take 2 dptf-id))
            )
            ;;1]<anchor-name> must conform to the same rules as ATS Index Names
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            ;;1b]If <acnoi> is true, <anchor-class-name-or-id> is a class-name and must conform ATS rules
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex anchor-class-name-or-id)
                true
            )
            ;;2]<dptf-id> must exist
            (ref-DPTF::UEV_id dptf-id)
            ;;3]Validation for <anchor-precision> and <anchor-promile>
            (UEV_Promile anchor-precision anchor-promile)
            ;;4]DPTF-amount must be conform with its precision
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
            ;;5]DPTF-ID may only be a Standard, Frozen or Reserved DPTF
            (enforce
                (fold (and) true 
                    [
                        (!= fourth BAR)         ;; Excludes Frozen LPs
                        (!= first-two "S|")     ;; Excludes LPs of Stable Pools
                        (!= first-two "W|")     ;; Excludes LPs of Weigthed Pools
                        (!= first-two "P|")     ;; Excludes LPs of Product Pools
                    ]
                )
                (format "Anchor cannot be issued for the DPTF {}." [dptf-id])
            )
            ;;6]Only the Owner of the DPTF-ID or the Owner of its Parent (in case of Frozen or Reserved DPTFs)
            ;;  may create an Anchor based on this <dptf-id>
            (CAP_TF|Owner dptf-id)
            ;;7]Validate class branch constraints:
            ;;   acnoi=true  -> there must be room for a new class on the asset
            ;;   acnoi=false -> class-id must exist, be active, and have room for anchor
            (UEV_IssueAnchor dptf-id [true true] acnoi anchor-class-name-or-id)
            ;;8]Compose the SECURE Capability
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPSF
        (anchor-name:string dpsf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Validates DPSF anchor issuance and class branch. \
            \ acnoi=true means class-name path (new class). \
            \ acnoi=false means class-id path (existing class)."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            ;;1]<anchor-name> must conform to the same rules as ATS Index Names
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            ;;1b]If <acnoi> is true, <anchor-class-name-or-id> is a class-name and must conform ATS rules
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex anchor-class-name-or-id)
                true
            )
            ;;2]<dpsf-id> must exist
            (ref-DPDC::UEV_id dpsf-id true)
            ;;3]Validation for <anchor-precision> and <anchor-promile>
            (UEV_Promile anchor-precision anchor-promile)
            ;;4]<dpsf-nonce> must be valid
            (ref-DPDC::UEV_Nonce dpsf-id true dpsf-nonce)
            ;;5]Only the Owner or the Creator of the <dpsf-id> may create an Anchor based of it
            (ref-DPDC::CAP_OwnerOrCreator dpsf-id true)
            ;;6]Validate class branch constraints:
            ;;   acnoi=true  -> there must be room for a new class on the asset
            ;;   acnoi=false -> class-id must exist, be active, and have room for anchor
            (UEV_IssueAnchor dpsf-id [false true] acnoi anchor-class-name-or-id)
            ;;7]Compose the SECURE Capability
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPNF
        (anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Validates DPNF anchor issuance and class branch. \
            \ acnoi=true means class-name path (new class). \
            \ acnoi=false means class-id path (existing class)."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            ;;1]<anchor-name> must conform to the same rules as ATS Index Names
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            ;;1b]If <acnoi> is true, <anchor-class-name-or-id> is a class-name and must conform ATS rules
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex anchor-class-name-or-id)
                true
            )
            ;;2]<dpnf-id> must exist
            (ref-DPDC::UEV_id dpnf-id false)
            ;;3]Validation for <anchor-precision> and <anchor-promile>
            (UEV_Promile anchor-precision anchor-promile)
            ;;4]<dpnf-trait-key> must be valid. Considering all Nonces of the dpnf-id have the same object construction
            ;;  the <dpnf-trait-key> must exist in the meta-data object. For this test, the first Nonce of the dpnf-id is used
            ;;  As such, the <dpnf-id> must have at least one element already defined.
            ;;  Only Positive DPNF-Nonces can be anchored. Negative DPNF-Nonces (Fragments) cannot be anchored.
            (enforce iz-key-present "Non-Fungible Key is invalid")
            ;;5]<dpnf-trait-value> must not be BAR, and its length must be min 2 and a maximum of 256 Glyphs
            (enforce
                (fold (and) true 
                    [
                        (>= l 2)                    ;;<l> must be minimum 2
                        (<= l 256)                  ;;<l> must be maximum 256
                        (!= dpnf-trait-value BAR)   ;;<dpnf-trait-value> cannot be BAR
                    ]
                )
                "Invalid Promile DPNF Trait-Value"
            )
            ;;6]Validate class branch constraints:
            ;;   acnoi=true  -> there must be room for a new class on the asset
            ;;   acnoi=false -> class-id must exist, be active, and have room for anchor
            (UEV_IssueAnchor dpnf-id [false false] acnoi anchor-class-name-or-id)
            ;;7]Compose the SECURE Capability
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (anchor-id:string)
        @event
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-CLASS (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
        @event
        (UEV_AnkFungibility ank-fungibility)
        (if (= ank-fungibility [true true])
            (CAP_TF|Owner asset-id)
            (if (= ank-fungibility [false true])
                (let ((ref-DPDC:module{DpdcV1} DPDC)) (ref-DPDC::CAP_OwnerOrCreator asset-id true))
                (let ((ref-DPDC:module{DpdcV1} DPDC)) (ref-DPDC::CAP_OwnerOrCreator asset-id false))
            )
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>UPDATE-DPTF (account:string anchor-id:string total-dptf-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ank-asset:string (UR_AnchoredAsset anchor-id))
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<anchor-id> must have an underlying Asset of True Fungible Type
            ;;  Verified with 3]
            ;;3]<total-dptf-amount> must be conform with the <ank-asset> precision
            (ref-DPTF::UEV_Amount ank-asset total-dptf-amount)
            ;;4]<anchor-id> must be live, and not revoked
            (UEV_LiveAnchor anchor-id)
        )
    )
    (defcap ANK|C>UPDATE-DPSF (account:string anchor-id:string nonces:[integer])
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account anchor-id nonces true))
    )
    (defcap ANK|C>UPDATE-DPNF (account:string anchor-id:string nonces:[integer])
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account anchor-id nonces false))
    )
    (defcap ANK|C>UPDATE-DPDC (account:string anchor-id:string nonces:[integer] son:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ank-asset:string (UR_AnchoredAsset anchor-id))
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<anchor-id> must have an underlying Asset of Semi Fungible Type
            ;;  Verified with 3]
            ;;3]<nonces> must exist for the <ank-asset>
            (ref-DPDC::UEV_NonceMapper ank-asset son nonces)
            ;;4]<anchor-id> must be live, and not revoked
            (UEV_LiveAnchor anchor-id)
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_UserAnchor:string 
        (account:string anchor-id:string)
        (concat [account BAR anchor-id])
    )
    (defun UC_AssetAnchorClassesTable (ank-fungibility:[bool])
        (if (= ank-fungibility [true true])
            ANK|T|TF|AnchorClasses
            (if (= ank-fungibility [false true])
                ANK|T|SF|AnchorClasses
                ANK|T|NF|AnchorClasses
            )
        )
    )
    (defun UC_AnchorClassTable (ank-fungibility:[bool])
        (if (= ank-fungibility [true true])
            ANK|T|TF|AnchorClass
            (if (= ank-fungibility [false true])
                ANK|T|SF|AnchorClass
                ANK|T|NF|AnchorClass
            )
        )
    )
    (defun UC_AssetClassKey:string (asset-id:string class-id:string)
        (concat [asset-id BAR class-id])
    )
    ;;{F0}  [UR]
    ;;[1] - <ANK|T|Anchor>
    (defun UR_Anchor:object{ANK|Schema} (anchor-id:string)
        (read ANK|T|Anchor anchor-id)
    )
    (defun UR_AnchoredAsset:string (anchor-id:string)
        (at "ank-asset" (read ANK|T|Anchor anchor-id ["ank-asset"]))
    )
    (defun UR_AnchorFungibility:[bool] (anchor-id:string)
        (at "ank-fungibility" (read ANK|T|Anchor anchor-id ["ank-fungibility"]))
    )
    (defun UR_AnchorPrecision:decimal (anchor-id:string)
        (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"]))
    )
    (defun UR_AnchorState:bool (anchor-id:string)
        (at "ank-active" (read ANK|T|Anchor anchor-id ["ank-active"]))
    )
    (defun UR_AnchorPromile:decimal (anchor-id:string)
        (at "ank-promile" (read ANK|T|Anchor anchor-id ["ank-promile"]))
    )
    ;;
    (defun UR_TF|AnchorAmount:decimal (anchor-id:string)
        (at "dptf-amount" (read ANK|T|Anchor anchor-id ["dptf-amount"]))
    )
    (defun UR_SF|AnchorNonce:integer (anchor-id:string)
        (at "dpsf-nonce" (read ANK|T|Anchor anchor-id ["dpsf-nonce"]))
    )
    (defun UR_NF|AnchorTraitKey:string (anchor-id:string)
        (at "dpnf-trait-key" (read ANK|T|Anchor anchor-id ["dpnf-trait-key"]))
    )
    (defun UR_NF|AnchorTraitValue:string (anchor-id:string)
        (at "dpnf-trait-value" (read ANK|T|Anchor anchor-id ["dpnf-trait-value"]))
    )
    (defun UR_AnchorID:string (anchor-id:string)
        (at "anchor-id" (UR_Anchor anchor-id))
    )
    ;;2] - <ANK|T|TF|AnchorClasses>|<ANK|T|SF|AnchorClasses>|<ANK|T|NF|AnchorClasses>
    (defun UR_AssetAnchorClassesData:object{ANK|AssetAnchorClasses} (ank-asset:string ank-fungibility:[bool])
        (UEV_AnkFungibility ank-fungibility)
        (if (= ank-fungibility [true true])
            (UR_TF|AnchorClasses ank-asset)
            (if (= ank-fungibility [false true])
                (UR_SF|AnchorClasses ank-asset)
                (UR_NF|AnchorClasses ank-asset)
            )
        )
    )
    (defun UR_TF|AnchorClasses:object{ANK|AssetAnchorClasses} (dptf-id:string)
        (with-default-read ANK|T|TF|AnchorClasses dptf-id
            (UDC_AssetAnchorClasses BAR BAR BAR BAR BAR BAR BAR 0 0 dptf-id)
            {"class-primary"        := c1
            ,"class-secondary"      := c2
            ,"class-tertiary"       := c3
            ,"class-quaternary"     := c4
            ,"class-quinary"        := c5
            ,"class-senary"         := c6
            ,"class-septenary"      := c7
            ,"classes"              := cs
            ,"anchors"              := a
            ,"asset-id"             := id}
            (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 c6 c7 cs a id)
        )
    )
    (defun UR_SF|AnchorClasses:object{ANK|AssetAnchorClasses} (dpsf-id:string)
        (with-default-read ANK|T|SF|AnchorClasses dpsf-id
            (UDC_AssetAnchorClasses BAR BAR BAR BAR BAR BAR BAR 0 0 dpsf-id)
            {"class-primary"        := c1
            ,"class-secondary"      := c2
            ,"class-tertiary"       := c3
            ,"class-quaternary"     := c4
            ,"class-quinary"        := c5
            ,"class-senary"         := c6
            ,"class-septenary"      := c7
            ,"classes"              := cs
            ,"anchors"              := a
            ,"asset-id"             := id}
            (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 c6 c7 cs a id)
        )
    )
    (defun UR_NF|AnchorClasses:object{ANK|AssetAnchorClasses} (dpnf-id:string)
        (with-default-read ANK|T|NF|AnchorClasses dpnf-id
            (UDC_AssetAnchorClasses BAR BAR BAR BAR BAR BAR BAR 0 0 dpnf-id)
            {"class-primary"        := c1
            ,"class-secondary"      := c2
            ,"class-tertiary"       := c3
            ,"class-quaternary"     := c4
            ,"class-quinary"        := c5
            ,"class-senary"         := c6
            ,"class-septenary"      := c7
            ,"classes"              := cs
            ,"anchors"              := a
            ,"asset-id"             := id}
            (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 c6 c7 cs a id)
        )
    )
    (defun UR_AssetAnchorClass:object{ANK|AnchorClass}
        (asset-id:string ank-fungibility:[bool] class-id:string)
        (let
            (
                (table-ref (UC_AnchorClassTable ank-fungibility))
                (class-key:string (UC_AssetClassKey asset-id class-id))
            )
            (with-default-read table-ref class-key
                (UDC_AnchorClass BAR BAR BAR BAR BAR BAR BAR BAR false 0 asset-id class-id)
                {"anchor-primary"       := a1
                ,"anchor-secondary"     := a2
                ,"anchor-tertiary"      := a3
                ,"anchor-quaternary"    := a4
                ,"anchor-quinary"       := a5
                ,"anchor-senary"        := a6
                ,"anchor-septenary"     := a7
                ,"class-name"           := cn
                ,"class-active"         := ca
                ,"anchors"              := a
                ,"asset-id"             := id
                ,"class-id"             := cid}
                (UDC_AnchorClass a1 a2 a3 a4 a5 a6 a7 cn ca a id cid)
            )
        )
    )
    (defun UR_ANK|First:string (input:object{ANK|AnchorClass})
        (at "anchor-primary" input)
    )
    (defun UR_ANK|Second:string (input:object{ANK|AnchorClass})
        (at "anchor-secondary" input)
    )
    (defun UR_ANK|Third:string (input:object{ANK|AnchorClass})
        (at "anchor-tertiary" input)
    )
    (defun UR_ANK|Fourth:string (input:object{ANK|AnchorClass})
        (at "anchor-quaternary" input)
    )
    (defun UR_ANK|Fifth:string (input:object{ANK|AnchorClass})
        (at "anchor-quinary" input)
    )
    (defun UR_ANK|Sixth:string (input:object{ANK|AnchorClass})
        (at "anchor-senary" input)
    )
    (defun UR_ANK|Seventh:string (input:object{ANK|AnchorClass})
        (at "anchor-septenary" input)
    )
    (defun UR_ANK|Quantity:integer (input:object{ANK|AnchorClass})
        (at "anchors" input)
    )
    (defun UR_AssetAnchorClassAssetID:string (input:object{ANK|AnchorClass})
        (at "asset-id" input)
    )
    ;;4] - <ANK|T|Anchors>
    (defun UR_UserAnchor:object{ANK|UserSchema} (account:string anchor-id:string)
        (with-default-read ANK|T|Anchors (UC_UserAnchor account anchor-id)
            (UDC_AccountAnchor 0.0 BAR BAR)
            {"promile"                  := p
            ,"ouronet-account"          := oa
            ,"anchor-id"                := aid}
            (UDC_AccountAnchor p oa aid)
        )
    )
    (defun UR_UserAnchorPromile:decimal (account:string anchor-id:string)
        (at "promile" (UR_UserAnchor account anchor-id))
    )
    (defun UR_UserAnchorAccount:string (account:string anchor-id:string)
        (at "ouronet-account" (UR_UserAnchor account anchor-id))
    )
    (defun UR_UserAnchorID:string (account:string anchor-id:string)
        (at "anchor-id" (UR_UserAnchor account anchor-id))
    )
    ;;
    ;;{F1}  [URC]
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (UR_AnchorPrecision anchor-id))
                (ank-promile:decimal (UR_AnchorPromile anchor-id))
                (dptf-amount:decimal (UR_TF|AnchorAmount anchor-id))
            )
            (if (<= dptf-amount 0.0)
                0.0
                (floor (* (/ total-dptf-amount dptf-amount) ank-promile) ank-precision)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (ank-promile:decimal (UR_AnchorPromile anchor-id))
                (dpfs-nonce:integer (UR_SF|AnchorNonce anchor-id))
                (current-promile:decimal (UR_UserAnchorPromile account anchor-id))
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
        (let
            (
                (ank-asset:string (UR_AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_AnchorPromile anchor-id))
                (dpnf-trait-key:string (UR_NF|AnchorTraitKey anchor-id))
                (dpnf-trait-value:string (UR_NF|AnchorTraitValue anchor-id))
                (current-promile:decimal (UR_UserAnchorPromile account anchor-id))
                ;;
                (conform-nonces:integer (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value))
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
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
                            (output:decimal
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
    ;;{F2}  [UEV]
    (defun UEV_AnkFungibility (ank-fungibility:[bool])
        (let
            (
                (l:integer (length ank-fungibility))
            )
            (enforce (and (= l 2) (!= ank-fungibility [true false])) "Invalid Fungibility")
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
    (defun UEV_AnchorClassSlot (anchor-class-slot:string)
        (enforce
            (fold (or) false
                [
                    (= anchor-class-slot "class-primary")
                    (= anchor-class-slot "class-secondary")
                    (= anchor-class-slot "class-tertiary")
                    (= anchor-class-slot "class-quaternary")
                    (= anchor-class-slot "class-quinary")
                    (= anchor-class-slot "class-senary")
                    (= anchor-class-slot "class-septenary")
                ]
            )
            "Invalid Anchor Class Slot"
        )
    )
    (defun UR_ANK|HasClass:bool (input:object{ANK|AssetAnchorClasses} class-id:string)
        (fold (or) false
            [
                (= (at "class-primary" input) class-id)
                (= (at "class-secondary" input) class-id)
                (= (at "class-tertiary" input) class-id)
                (= (at "class-quaternary" input) class-id)
                (= (at "class-quinary" input) class-id)
                (= (at "class-senary" input) class-id)
                (= (at "class-septenary" input) class-id)
            ]
        )
    )
    (defun UEV_IssueAnchor (ank-asset:string ank-fungibility:[bool] acnoi:bool anchor-class-name-or-id:string)
        @doc "Validates class constraints for anchor issuance only. \
            \ It does NOT issue class-id nor anchor-id."
        (let
            (
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_AssetAnchorClassesData ank-asset ank-fungibility))
                (classes:integer (at "classes" asset-classes))
                (has-class:bool (UR_ANK|HasClass asset-classes anchor-class-name-or-id))
                (class-anchors:object{ANK|AnchorClass} (UR_AssetAnchorClass ank-asset ank-fungibility anchor-class-name-or-id))
                (quantity:integer (UR_ANK|Quantity class-anchors))
                (class-active:bool (at "class-active" class-anchors))
            )
            ;;1]When acnoi=true, class-name validation is already enforced in ISSUE capability.
            ;;   Here we only validate free class slot availability.
            (if acnoi
                (enforce (<= classes 6) (format "Cannot add new Anchor Class for Asset {}" [ank-asset]))
                ;;2]When acnoi=false, class-id path: class must exist + active + have free anchor slot
                (enforce
                    (fold (and) true [has-class class-active (<= quantity 6)])
                    (format "Anchor Class {} invalid for Asset {}" [anchor-class-name-or-id ank-asset])
                )
            )
        )
    )
    (defun UEV_LiveAnchor (anchor-id:string)
        (let
            (
                (iz-anchor-active:bool (UR_AnchorState anchor-id))
            )
            (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_RevokedAnchorClass:object{ANK|AnchorClass}
        (anchors:object{ANK|AnchorClass} anchor-id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (p1:string (UR_ANK|First anchors))
                (p2:string (UR_ANK|Second anchors))
                (p3:string (UR_ANK|Third anchors))
                (p4:string (UR_ANK|Fourth anchors))
                (p5:string (UR_ANK|Fifth anchors))
                (p6:string (UR_ANK|Sixth anchors))
                (p7:string (UR_ANK|Seventh anchors))
                (ank-qt:integer (UR_ANK|Quantity anchors))
                (asset-id:string (UR_AssetAnchorClassAssetID anchors))
                (class-id:string (at "class-id" anchors))
                (lst:[string] [p1 p2 p3 p4 p5 p6 p7])
                (position-to-remove:integer
                    (cond
                        ((= anchor-id p1) 0)
                        ((= anchor-id p2) 1)
                        ((= anchor-id p3) 2)
                        ((= anchor-id p4) 3)
                        ((= anchor-id p5) 4)
                        ((= anchor-id p6) 5)
                        ((= anchor-id p7) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (UDC_AnchorClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (at "class-name" anchors) (at "class-active" anchors) (- ank-qt 1) asset-id class-id
            )
        )
    )
    (defun UDC_AnchorClass:object{ANK|AnchorClass}
        (a:string b:string c:string d:string e:string f:string g:string h:string ia:bool i:integer j:string k:string)
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"class-name"           : h
        ,"class-active"         : ia
        ,"anchors"              : i
        ,"asset-id"             : j
        ,"class-id"             : k}
    )
    (defun UDC_AssetAnchorClasses:object{ANK|AssetAnchorClasses}
        (c1:string c2:string c3:string c4:string c5:string c6:string c7:string c:integer a:integer id:string)
        {"class-primary"        : c1
        ,"class-secondary"      : c2
        ,"class-tertiary"       : c3
        ,"class-quaternary"     : c4
        ,"class-quinary"        : c5
        ,"class-senary"         : c6
        ,"class-septenary"      : c7
        ,"classes"              : c
        ,"anchors"              : a
        ,"asset-id"             : id}
    )
    (defun UDC_AddAssetClass:object{ANK|AssetAnchorClasses}
        (input:object{ANK|AssetAnchorClasses} class-id:string)
        (let
            (
                (c1:string (at "class-primary" input))
                (c2:string (at "class-secondary" input))
                (c3:string (at "class-tertiary" input))
                (c4:string (at "class-quaternary" input))
                (c5:string (at "class-quinary" input))
                (c6:string (at "class-senary" input))
                (c7:string (at "class-septenary" input))
            )
            (if (= c1 BAR)
                (UDC_AssetAnchorClasses class-id c2 c3 c4 c5 c6 c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                (if (= c2 BAR)
                    (UDC_AssetAnchorClasses c1 class-id c3 c4 c5 c6 c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                    (if (= c3 BAR)
                        (UDC_AssetAnchorClasses c1 c2 class-id c4 c5 c6 c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                        (if (= c4 BAR)
                            (UDC_AssetAnchorClasses c1 c2 c3 class-id c5 c6 c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                            (if (= c5 BAR)
                                (UDC_AssetAnchorClasses c1 c2 c3 c4 class-id c6 c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                                (if (= c6 BAR)
                                    (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 class-id c7 (at "classes" input) (at "anchors" input) (at "asset-id" input))
                                    (if (= c7 BAR)
                                        (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 c6 class-id (at "classes" input) (at "anchors" input) (at "asset-id" input))
                                        input
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    (defun UDC_RemoveAssetClass:object{ANK|AssetAnchorClasses}
        (input:object{ANK|AssetAnchorClasses} class-id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (lst:[string]
                    [
                        (at "class-primary" input)
                        (at "class-secondary" input)
                        (at "class-tertiary" input)
                        (at "class-quaternary" input)
                        (at "class-quinary" input)
                        (at "class-senary" input)
                        (at "class-septenary" input)
                    ]
                )
                (lst-v1 (ref-U|LST::UC_RemoveItem lst class-id))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (UDC_AssetAnchorClasses (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2) (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (at "classes" input) (at "anchors" input) (at "asset-id" input))
        )
    )
    (defun UDC_SetAssetClassAnchorsAndCounts:object{ANK|AssetAnchorClasses}
        (input:object{ANK|AssetAnchorClasses} class-id:string add-class:bool class-delta:integer anchor-delta:integer)
        (let
            (
                (out:object{ANK|AssetAnchorClasses}
                    (if add-class
                        (UDC_AddAssetClass input class-id)
                        input
                    )
                )
            )
            (UDC_AssetAnchorClasses
                (at "class-primary" out)
                (at "class-secondary" out)
                (at "class-tertiary" out)
                (at "class-quaternary" out)
                (at "class-quinary" out)
                (at "class-senary" out)
                (at "class-septenary" out)
                (+ (at "classes" out) class-delta)
                (+ (at "anchors" out) anchor-delta)
                (at "asset-id" out)
            )
        )
    )
    (defun UDC_ClassWithAddedAnchor:object{ANK|AnchorClass}
        (input:object{ANK|AnchorClass} anchor-id:string)
        (let
            (
                (quantity:integer (UR_ANK|Quantity input))
            )
            (cond
                ((= quantity 0) (UDC_AnchorClass anchor-id BAR BAR BAR BAR BAR BAR (at "class-name" input) (at "class-active" input) 1 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 1) (UDC_AnchorClass (UR_ANK|First input) anchor-id BAR BAR BAR BAR BAR (at "class-name" input) (at "class-active" input) 2 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 2) (UDC_AnchorClass (UR_ANK|First input) (UR_ANK|Second input) anchor-id BAR BAR BAR BAR (at "class-name" input) (at "class-active" input) 3 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 3) (UDC_AnchorClass (UR_ANK|First input) (UR_ANK|Second input) (UR_ANK|Third input) anchor-id BAR BAR BAR (at "class-name" input) (at "class-active" input) 4 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 4) (UDC_AnchorClass (UR_ANK|First input) (UR_ANK|Second input) (UR_ANK|Third input) (UR_ANK|Fourth input) anchor-id BAR BAR (at "class-name" input) (at "class-active" input) 5 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 5) (UDC_AnchorClass (UR_ANK|First input) (UR_ANK|Second input) (UR_ANK|Third input) (UR_ANK|Fourth input) (UR_ANK|Fifth input) anchor-id BAR (at "class-name" input) (at "class-active" input) 6 (at "asset-id" input) (at "class-id" input)))
                ((= quantity 6) (UDC_AnchorClass (UR_ANK|First input) (UR_ANK|Second input) (UR_ANK|Third input) (UR_ANK|Fourth input) (UR_ANK|Fifth input) (UR_ANK|Sixth input) anchor-id (at "class-name" input) (at "class-active" input) 7 (at "asset-id" input) (at "class-id" input)))
                input
            )
        )
    )
    (defun UDC_AccountAnchor:object{ANK|UserSchema}
        (a:decimal b:string c:string)
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
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
                (ank-asset:string (UR_AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_AnchorFungibility anchor-id))
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
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dptf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues an Anchor tied to an existing True Fungible Asset \
            \ Costs 1000 IGNIS and 1 STOA \
            \ acnoi=true creates and uses a new anchor-class-id from class-name. \
            \ acnoi=false uses existing anchor-class-id."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF anchor-name dptf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    ;;
                    (fungibility:[bool] [true true])
                    ;;1]Resolve class-id branch:
                    ;;   acnoi=true  -> issue new class-id from class-name
                    ;;   acnoi=false -> string is already class-id
                    (anchor-class-id:string
                        (if acnoi
                            (XI_IssueAnchorClass dptf-id fungibility anchor-class-name-or-id)
                            anchor-class-name-or-id
                        )
                    )
                    (class-row:object{ANK|AnchorClass} (UR_AssetAnchorClass dptf-id fungibility anchor-class-id))
                    (class-key:string (UC_AssetClassKey dptf-id anchor-class-id))
                    ;;
                    ;;2]Issue anchor-id and insert anchor definition row
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility anchor-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR
                        )
                    )
                    (table-ref (UC_AnchorClassTable fungibility))
                    (asset-table-ref (UC_AssetAnchorClassesTable fungibility))
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_TF|AnchorClasses dptf-id))
                )
                ;;3]Append anchor-id into class row
                (write table-ref class-key (UDC_ClassWithAddedAnchor class-row anchor-id))
                ;;4]Increment total anchors on asset class-summary row
                (write asset-table-ref dptf-id
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes anchor-class-id false 0 1)
                )
                ;;5]Collect KDA and output IDs (B-mode): two IDs only on acnoi=true
                (ref-IGNIS::KDA|C_Collect patron standard)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger (if acnoi [anchor-id anchor-class-id] [anchor-id]))   
            )
        )
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues an Anchor tied to an existing Semi Fungible Asset \
            \ Costs 1000 IGNIS and 1 STOA \
            \ acnoi=true creates and uses a new anchor-class-id from class-name. \
            \ acnoi=false uses existing anchor-class-id."
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF anchor-name dpsf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    ;;
                    (fungibility:[bool] [false true])
                    ;;1]Resolve class-id branch
                    (anchor-class-id:string
                        (if acnoi
                            (XI_IssueAnchorClass dpsf-id fungibility anchor-class-name-or-id)
                            anchor-class-name-or-id
                        )
                    )
                    (class-row:object{ANK|AnchorClass} (UR_AssetAnchorClass dpsf-id fungibility anchor-class-id))
                    (class-key:string (UC_AssetClassKey dpsf-id anchor-class-id))
                    ;;
                    ;;2]Issue anchor-id and insert anchor definition row
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility anchor-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR
                        )
                    )
                    (table-ref (UC_AnchorClassTable fungibility))
                    (asset-table-ref (UC_AssetAnchorClassesTable fungibility))
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_SF|AnchorClasses dpsf-id))
                )
                ;;3]Append anchor-id into class row
                (write table-ref class-key (UDC_ClassWithAddedAnchor class-row anchor-id))
                ;;4]Increment total anchors on asset class-summary row
                (write asset-table-ref dpsf-id
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes anchor-class-id false 0 1)
                )
                ;;5]Collect KDA and output IDs (B-mode)
                (ref-IGNIS::KDA|C_Collect patron standard)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger (if acnoi [anchor-id anchor-class-id] [anchor-id]))   
            )
        )
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues an Anchor tied to an existing Non Fungible Asset \
            \ Costs 1000 IGNIS and 1 STOA \
            \ acnoi=true creates and uses a new anchor-class-id from class-name. \
            \ acnoi=false uses existing anchor-class-id."
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    ;;
                    (fungibility:[bool] [false false])
                    ;;1]Resolve class-id branch
                    (anchor-class-id:string
                        (if acnoi
                            (XI_IssueAnchorClass dpnf-id fungibility anchor-class-name-or-id)
                            anchor-class-name-or-id
                        )
                    )
                    (class-row:object{ANK|AnchorClass} (UR_AssetAnchorClass dpnf-id fungibility anchor-class-id))
                    (class-key:string (UC_AssetClassKey dpnf-id anchor-class-id))
                    ;;
                    ;;2]Issue anchor-id and insert anchor definition row
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpnf-id fungibility anchor-class-id anchor-precision anchor-promile
                            0.0 0 dpnf-trait-key dpnf-trait-value
                        )
                    )
                    (table-ref (UC_AnchorClassTable fungibility))
                    (asset-table-ref (UC_AssetAnchorClassesTable fungibility))
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_NF|AnchorClasses dpnf-id))
                )
                ;;3]Append anchor-id into class row
                (write table-ref class-key (UDC_ClassWithAddedAnchor class-row anchor-id))
                ;;4]Increment total anchors on asset class-summary row
                (write asset-table-ref dpnf-id
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes anchor-class-id false 0 1)
                )
                ;;5]Collect KDA and output IDs (B-mode)
                (ref-IGNIS::KDA|C_Collect patron standard)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger (if acnoi [anchor-id anchor-class-id] [anchor-id]))   
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator}
        (anchor-id:string)
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>REVOKE anchor-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                ;;1]Updates <ANK|T|Anchor> Table
                (update ANK|T|Anchor anchor-id
                    {"ank-active"   : false}
                )
                ;;2]Updates anchor class tables for underlying asset
                (XI_RevokeAnchor anchor-id)
                ;;3]Outputs the Ignis Cumulator
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    (defun C_RevokeAnchorClass:object{IgnisCollectorV1.OutputCumulator}
        (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
        @doc "Revokes an Anchor Class from an asset; class must be empty."
        (UEV_IMC)
        (with-capability (ANK|C>REVOKE-CLASS asset-id ank-fungibility anchor-class-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (XI_RevokeAnchorClass asset-id ank-fungibility anchor-class-id)
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    ;;
    ;;
    ;;{F7}  [X]
    (defun XI_IssueAnchorClass:string
        (asset-id:string ank-fungibility:[bool] class-name:string)
        @doc "Issues Anchor Class row and links it to asset; outputs class-id."
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;1]Read current asset class summary
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_AssetAnchorClassesData asset-id ank-fungibility))
                ;;2]Create class-id from class-name
                (class-id:string (ref-U|DALOS::UDC_Makeid class-name))
                (class-key:string (UC_AssetClassKey asset-id class-id))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
            )
            ;;3]Insert empty active class row
            (insert class-table-ref class-key
                (UDC_AnchorClass BAR BAR BAR BAR BAR BAR BAR class-name true 0 asset-id class-id)
            )
            ;;4]Link class-id into first free class slot and increment classes count
            (write asset-table-ref asset-id
                (UDC_SetAssetClassAnchorsAndCounts asset-classes class-id true 1 0)
            )
            ;;5]Output new class-id
            class-id
        )
    )
    (defun XI_IssueAnchor:string
        (
            ank-name:string ank-asset:string ank-fungibility:[bool] ank-class:string ank-precision:integer ank-promile:decimal
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string
        )
        @doc "Core Anchor Issue Function; Populates the <ANK|T|Anchor> Table \
            \ Outputs the <anchor-id>"
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (anchor-id:string (ref-U|DALOS::UDC_Makeid ank-name))
            )
            ;;1]Insert anchor definition with immutable asset/fungibility/class linkage
            (insert ANK|T|Anchor anchor-id
                {"ank-asset"            : ank-asset
                ,"ank-fungibility"      : ank-fungibility
                ,"ank-class"            : ank-class
                ,"ank-precision"        : ank-precision
                ,"ank-active"           : true
                ,"ank-promile"          : ank-promile
                ,"dptf-amount"          : dptf-amount
                ,"dpsf-nonce"           : dpsf-nonce
                ,"dpnf-trait-key"       : dpnf-trait-key
                ,"dpnf-trait-value"     : dpnf-trait-value
                ,"anchor-id"            : anchor-id
                }
            )
            ;;2]Output created anchor-id
            anchor-id
        )
    )
    (defun XI_RevokeAnchor (anchor-id:string)
        @doc "Revokes an anchor from its underlying Asset"
        (require-capability (SECURE))
        (let
            (
                (ank-asset:string (UR_AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_AnchorFungibility anchor-id))
                (ank-class:string (at "ank-class" (UR_Anchor anchor-id)))
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_AssetAnchorClassesData ank-asset ank-fungibility))
                (class-row:object{ANK|AnchorClass} (UR_AssetAnchorClass ank-asset ank-fungibility ank-class))
                (class-key:string (UC_AssetClassKey ank-asset ank-class))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
                (revoked-class:object{ANK|AnchorClass} (UDC_RevokedAnchorClass class-row anchor-id))
                (class-now-empty:bool (= (UR_ANK|Quantity revoked-class) 0))
            )
            (write class-table-ref class-key revoked-class)
            (write asset-table-ref ank-asset
                (if class-now-empty
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes class-key false 0 -1)
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes class-key false 0 -1)
                )
            )
        )
    )
    (defun XI_RevokeAnchorClass (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
        @doc "Revokes anchor-class-id from asset. Class must be empty."
        (require-capability (SECURE))
        (let
            (
                ;;1]Read current asset summary and class row
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_AssetAnchorClassesData asset-id ank-fungibility))
                (class-row:object{ANK|AnchorClass} (UR_AssetAnchorClass asset-id ank-fungibility anchor-class-id))
                (class-key:string (UC_AssetClassKey asset-id anchor-class-id))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
            )
            ;;2]Only empty classes can be revoked
            (enforce (= (UR_ANK|Quantity class-row) 0) "Anchor Class must be empty for revoke")
            ;;3]Mark class row inactive
            (update class-table-ref class-key {"class-active" : false})
            ;;4]Unlink class-id from asset slots and decrement classes count
            (write asset-table-ref asset-id
                (UDC_SetAssetClassAnchorsAndCounts (UDC_RemoveAssetClass asset-classes anchor-class-id) anchor-class-id false -1 0)
            )
        )
    )
    ;;
    (defun XE_UpdateTrueFungibleAnchor
        (account:string anchor-id:string total-dptf-amount:decimal)
        @doc "Updates the Anchor Value <promile> for a given <account> and <anchor-id> \
            \ It uses the <total-dptf-amount>, which is the end amount after a stake or unstake operation"
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPTF account anchor-id total-dptf-amount)
            (write ANK|T|Anchors (UC_UserAnchor account anchor-id)
                (UDC_AccountAnchor
                    (URC_TrueFungibleAnchorPromile anchor-id total-dptf-amount)
                    account
                    anchor-id
                )
            )
        )
    )
    (defun XE_UpdateSemiFungibleAnchor
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates the Anchor Value <promile> for a given <account> and <anchor-id> \
            \ <direction> determines if its a stake [true] or unstake [false] event \
            \ <nonces> and <nonce-amounts> determine how many DPSFs are involved in the Update event"
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account anchor-id nonces)
            (write ANK|T|Anchors (UC_UserAnchor account anchor-id)
                (UDC_AccountAnchor
                    (URC_SemiFungibleAnchorPromile account anchor-id nonces nonce-amounts direction)
                    account
                    anchor-id
                )
            )
        )
    )
    (defun XE_UpdateNonFungibleAnchor
        (account:string anchor-id:string nonces:[integer] direction:bool)
        @doc "Updates the Anchor Value <promile> for a given <account> and <anchor-id> \
            \ <direction> determines if its a stake [true] or unstake [false] event \
            \ <nonces> determines which DPNF nonces are involved in the update event "
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account anchor-id nonces)
            (write ANK|T|Anchors (UC_UserAnchor account anchor-id)
                (UDC_AccountAnchor
                    (URC_NonFungibleAnchorPromile account anchor-id nonces direction)
                    account
                    anchor-id
                )
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table ANK|T|Anchor)
(create-table ANK|T|TF|AnchorClasses)
(create-table ANK|T|SF|AnchorClasses)
(create-table ANK|T|NF|AnchorClasses)
(create-table ANK|T|TF|AnchorClass)
(create-table ANK|T|SF|AnchorClass)
(create-table ANK|T|NF|AnchorClass)
(create-table ANK|T|Anchors)