(interface AcquisitionAnchorsV1
    ;;  [UC]
    (defun UC_UserAnchor:string (account:string anchor-id:string))
    (defun UC_AnchorClassTable (asset-fungibility:[bool]))
    (defun UC_AssetAnchorClassesTable (asset-fungibility:[bool]))
    (defun UC_AssetClassKey:string (asset-id:string class-id:string))
    ;;
    ;;  [UR]
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string))
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string))
    (defun UR_ANK|Class:string (anchor-id:string))
    (defun UR_ANK|Precision:decimal (anchor-id:string))
    (defun UR_ANK|State:bool (anchor-id:string))
    (defun UR_ANK|Promile:decimal (anchor-id:string))
    (defun UR_ANK|TFAmount:decimal (anchor-id:string))
    (defun UR_ANK|SFNonce:integer (anchor-id:string))
    (defun UR_ANK|NFTraitKey:string (anchor-id:string))
    (defun UR_ANK|NFTraitValue:string (anchor-id:string))
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string))
    (defun UR_ANK|ID:string (anchor-id:string))
    (defun UR_ANK-CLASS|First:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Second:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Third:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Fourth:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Fifth:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Sixth:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Seventh:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|ClassActive:bool (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|Quantity:integer (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|AssetID:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASS|ClassID:string (asset-id:string asset-fungibility:[bool] class-id:string))
    (defun UR_ANK-CLASSES|ClassPrimary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassSecondary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassTertiary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassQuaternary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassQuinary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassSenary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|ClassSeptenary:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|Count:integer (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|Anchors:integer (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-CLASSES|AssetID:string (asset-id:string asset-fungibility:[bool]))
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string))
    (defun UR_ANK-U|Account:string (account:string anchor-id:string))
    (defun UR_ANK-U|ID:string (account:string anchor-id:string))
    (defun URC_TrueFungibleAnchorPromile:decimal
        (anchor-id:string total-dptf-amount:decimal)
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
    )
    (defun URC_TraitOrClass:bool (anchor-id:string))
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string))
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer))
    ;;
    ;;  [UEV]
    (defun UEV_IMC ())
    (defun UEV_AnkFungibility (asset-fungibility:[bool]))
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal))
    (defun UEV_AnchorClassSlot (anchor-class-slot:string))
    (defun UEV_IssueAnchor (ank-asset:string ank-fungibility:[bool] acnoi:bool anchor-class-name-or-id:string))
    (defun UEV_LiveAnchor (anchor-id:string))
    ;;
    ;;  [C]
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dptf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator} (anchor-id:string))
    (defun C_RevokeAnchorClass:object{IgnisCollectorV1.OutputCumulator}
        (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
    )
    ;;
    ;;  [XE]
    (defun XE_UpdateTrueFungibleAnchor
        (account:string anchor-id:string total-dptf-amount:decimal)
    )
    (defun XE_UpdateSemiFungibleAnchor
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun XE_UpdateNonFungibleAnchor
        (account:string dpnf-id:string nonces:[integer] direction:bool)
    )
)
(module AQP-ANK GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionAnchorsV1)
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
    (defun GOV|Demiurgoi ()
        @doc "Resolves the governance keyset from DALOS."
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )
    ;;
    ;; [Keys]
    (defun GOV|NS_Use ()
        @doc "Returns namespace prefix constant used by ANK."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE))
    )
    (defun GOV|AqpKey ()
        @doc "Builds the governance keyset name for AQP."
        (+ (GOV|NS_Use) ".dh_sc_aqp-keyset")
    )
    ;;
    ;; [SC-Names]
    (defun GOV|AQP|SC_NAME ()
        @doc "Returns ANK module symbolic name."
        (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"])
    )
    ;;
    ;; [PBLs]
    (defun GOV|AQP|PBL ()
        @doc "Returns immutable public branding/license payload constant."
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
        @doc "Registers ANK secure caller guard in DALOS policies."
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|ANK|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
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
        dpnf-nonce-class:integer    ;;[.]   DPNF Nonce-Class for set anchors [-1 when trait mode, 0 all native NFTs, >0 specific set class]
        ;;
        ;;Select Keys
        anchor-id:string
    )
    ;;2]Anchor Class Definition
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
        class-active:bool           ;;[M]   Stores if class is active
        ;;
        anchors:integer             ;;[M]   Stores number of active anchors in this class (0 to 7)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Stores the Asset ID
        class-id:string             ;;[.]   Stores the class-id
    )
    ;;3]Anchor Classes Definition
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
    (deftable ANK|T|TF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPTF-ID> | <Anchor-Class-ID>
    (deftable ANK|T|SF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPSF-ID> | <Anchor-Class-ID>
    (deftable ANK|T|NF|AnchorClass:{ANK|AnchorClass})           ;;Key = <DPNF-ID> | <Anchor-Class-ID>
    ;;
    (deftable ANK|T|TF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPTF-ID>
    (deftable ANK|T|SF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPSF-ID>
    (deftable ANK|T|NF|AnchorClasses:{ANK|AssetAnchorClasses})  ;;Key = <DPNF-ID>
    ;;
    (deftable ANK|T|Anchors:{ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
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
                (ref-DPDC:module{DpdcV1} DPDC)
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            ;;1a]<dpnf-trait-key> must be valid. Considering all Nonces of the dpnf-id have the same object construction
            ;;  the <dpnf-trait-key> must exist in the meta-data object. For this test, the first Nonce of the dpnf-id is used
            ;;  As such, the <dpnf-id> must have at least one element already defined.
            ;;  Only Positive DPNF-Nonces can be anchored. Negative DPNF-Nonces (Fragments) cannot be anchored.
            ;;1b]<dpnf-trait-value> must not be BAR, and its length must be min 2 and a maximum of 256 Glyphs
            (enforce
                (fold (and) true 
                    [
                        iz-key-present
                        (>= l 2)                    ;;<l> must be minimum 2
                        (<= l 256)                  ;;<l> must be maximum 256
                        (!= dpnf-trait-value BAR)   ;;<dpnf-trait-value> cannot be BAR
                    ]
                )
                "Invalid Non-Fungible Key orInvalid Promile DPNF Trait-Value"
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|C>ISSUE-DPNF-SET
        (anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Validates DPNF set-anchor issuance via nonce-class model. \
            \ nonce-class 0 targets all native NFTs; nonce-class > 0 targets a specific set class."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            ;;1]<dpnf-nonce-class> must be valid
            (enforce
                (and (>= dpnf-nonce-class 0) (<= dpnf-nonce-class classes-used))
                (format "Invalid DPNF nonce-class {} for collection {}." [dpnf-nonce-class dpnf-id])
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|XI>ISSUE-DPNF-COMMON
        (anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal)
        @doc "Common DPNF issuance checks shared by trait and set modes. \
            \ 1) anchor-name ATS-conform \
            \ 1b) class-name ATS-conform when acnoi=true \
            \ 2) dpnf-id exists \
            \ 3) promile variables valid \
            \ 4) class branch valid \
            \ 5) compose SECURE."
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
            ;;2]<dpnf-id> must exist
            (ref-DPDC::UEV_id dpnf-id false)
            ;;3]Validation for <anchor-precision> and <anchor-promile>
            (UEV_Promile anchor-precision anchor-promile)
            ;;4]Validate class branch constraints
            (UEV_IssueAnchor dpnf-id [false false] acnoi anchor-class-name-or-id)
            ;;5]Compose secure writer
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (anchor-id:string)
        @doc "Authorizes anchor revocation for <anchor-id>; requires anchor ownership."
        @event
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-CLASS (asset-id:string ank-fungibility:[bool] anchor-class-id:string)
        @doc "Authorizes revoking an empty anchor class on <asset-id> for the given class id."
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
        @doc "Authorizes updating user promile for a DPTF-backed anchor after stake/unstake."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
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
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_UserAnchor:string 
        (account:string anchor-id:string)
        @doc "Builds user-anchor composite key."
        (concat [account BAR anchor-id])
    )
    (defun UC_AnchorClassTable (asset-fungibility:[bool])
        @doc "Resolves per-class table by asset fungibility (TF / SF / NF)."
        (if (= asset-fungibility [true true])
            ANK|T|TF|AnchorClass
            (if (= asset-fungibility [false true])
                ANK|T|SF|AnchorClass
                ANK|T|NF|AnchorClass
            )
        )
    )
    (defun UC_AssetAnchorClassesTable (asset-fungibility:[bool])
        @doc "Resolves asset-class summary table by asset fungibility (TF / SF / NF)."
        (if (= asset-fungibility [true true])
            ANK|T|TF|AnchorClasses
            (if (= asset-fungibility [false true])
                ANK|T|SF|AnchorClasses
                ANK|T|NF|AnchorClasses
            )
        )
    )
    (defun UC_AssetClassKey:string (asset-id:string class-id:string)
        @doc "Builds asset-class composite key."
        (concat [asset-id BAR class-id])
    )
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) ANK|Schema (2) ANK|AnchorClass (3) ANK|AssetAnchorClasses (4) ANK|UserSchema
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
    (defun UR_ANK|Class:string (anchor-id:string)
        @doc "Reads bound anchor-class-id (ank-class) from the anchor row."
        (at "ank-class" (read ANK|T|Anchor anchor-id ["ank-class"]))
    )
    (defun UR_ANK|Precision:decimal (anchor-id:string)
        @doc "Reads anchor precision as decimal."
        (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"]))
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
    ;;
    ;; [2] ANK|T|TF|AnchorClass | ANK|T|SF|AnchorClass | ANK|T|NF|AnchorClass
    ;;     (ANK|AnchorClass)  Key = <Asset-ID> | <Class-ID>
    ;; Core row: UR_ANK-CLASS|Data (key = asset-id + asset-fungibility picks table + class-id)
    (defun UR_ANK-CLASS|Data:object{ANK|AnchorClass}
        (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Core read: one anchor-class row (up to seven anchor slots per class)."
        (with-default-read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id)
            (UDC_AnchorClass BAR BAR BAR BAR BAR BAR BAR false 0 asset-id class-id)
            {"anchor-primary"       := a1
            ,"anchor-secondary"     := a2
            ,"anchor-tertiary"      := a3
            ,"anchor-quaternary"    := a4
            ,"anchor-quinary"       := a5
            ,"anchor-senary"        := a6
            ,"anchor-septenary"     := a7
            ,"class-active"         := ca
            ,"anchors"              := a
            ,"asset-id"             := id
            ,"class-id"             := cid}
            (UDC_AnchorClass a1 a2 a3 a4 a5 a6 a7 ca a id cid)
        )
    )
    (defun UR_ANK-CLASS|First:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-primary for class row at key (asset-id, asset-fungibility, class-id)."
        (at "anchor-primary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-primary"]))
    )
    (defun UR_ANK-CLASS|Second:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-secondary for class row at key."
        (at "anchor-secondary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-secondary"]))
    )
    (defun UR_ANK-CLASS|Third:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-tertiary for class row at key."
        (at "anchor-tertiary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-tertiary"]))
    )
    (defun UR_ANK-CLASS|Fourth:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-quaternary for class row at key."
        (at "anchor-quaternary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-quaternary"]))
    )
    (defun UR_ANK-CLASS|Fifth:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-quinary for class row at key."
        (at "anchor-quinary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-quinary"]))
    )
    (defun UR_ANK-CLASS|Sixth:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-senary for class row at key."
        (at "anchor-senary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-senary"]))
    )
    (defun UR_ANK-CLASS|Seventh:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchor-septenary for class row at key."
        (at "anchor-septenary" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchor-septenary"]))
    )
    (defun UR_ANK-CLASS|ClassActive:bool (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads class-active for class row at key."
        (at "class-active" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["class-active"]))
    )
    (defun UR_ANK-CLASS|Quantity:integer (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads anchors count for class row at key."
        (at "anchors" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["anchors"]))
    )
    (defun UR_ANK-CLASS|AssetID:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads asset-id field for class row at key."
        (at "asset-id" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["asset-id"]))
    )
    (defun UR_ANK-CLASS|ClassID:string (asset-id:string asset-fungibility:[bool] class-id:string)
        @doc "Reads class-id field for class row at key."
        (at "class-id" (read (UC_AnchorClassTable asset-fungibility) (UC_AssetClassKey asset-id class-id) ["class-id"]))
    )
    ;;
    ;; [3] ANK|T|TF|AnchorClasses | ANK|T|SF|AnchorClasses | ANK|T|NF|AnchorClasses
    ;;     (ANK|AssetAnchorClasses)  Key = <DPTF-ID>|<DPSF-ID>|<DPNF-ID>
    ;; Single read: UC_AssetAnchorClassesTable as table arg to with-default-read (no separate tbl binding).
    (defun UR_ANK-CLASSES|Data:object{ANK|AssetAnchorClasses} (asset-id:string asset-fungibility:[bool])
        @doc "Reads asset class-summary row by asset-id and asset-fungibility (with-default-read when row absent). \
            \ Pure read; caller must pass a valid asset-fungibility discriminator (validated on issue paths via UEV / caps)."
        (with-default-read (UC_AssetAnchorClassesTable asset-fungibility) asset-id
            (UDC_AssetAnchorClasses BAR BAR BAR BAR BAR BAR BAR 0 0 asset-id)
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
    (defun UR_ANK-CLASSES|ClassPrimary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-primary slot for asset summary row at key."
        (at "class-primary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassSecondary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-secondary slot for asset summary row at key."
        (at "class-secondary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassTertiary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-tertiary slot for asset summary row at key."
        (at "class-tertiary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassQuaternary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-quaternary slot for asset summary row at key."
        (at "class-quaternary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassQuinary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-quinary slot for asset summary row at key."
        (at "class-quinary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassSenary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-senary slot for asset summary row at key."
        (at "class-senary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|ClassSeptenary:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads class-septenary slot for asset summary row at key."
        (at "class-septenary" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|Count:integer (asset-id:string asset-fungibility:[bool])
        @doc "Reads classes count for asset summary row at key (asset-id, asset-fungibility)."
        (at "classes" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|Anchors:integer (asset-id:string asset-fungibility:[bool])
        @doc "Reads total anchors count for asset summary row at key."
        (at "anchors" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    (defun UR_ANK-CLASSES|AssetID:string (asset-id:string asset-fungibility:[bool])
        @doc "Reads asset-id field for asset summary row at key."
        (at "asset-id" (UR_ANK-CLASSES|Data asset-id asset-fungibility))
    )
    ;;
    ;; [4] ANK|T|Anchors  (ANK|UserSchema)  Key = <Ouronet-Account> | <Anchor-ID>
    ;; Core row: UR_ANK-U|Data
    (defun UR_ANK-U|Data:object{ANK|UserSchema} (account:string anchor-id:string)
        @doc "Core read: user cumulative promile row for account x anchor."
        (with-default-read ANK|T|Anchors (UC_UserAnchor account anchor-id)
            (UDC_AccountAnchor 0.0 BAR BAR)
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
    ;;{F1}  [URC]
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (UR_ANK|Precision anchor-id))
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
    (defun UEV_AnchorClassSlot (anchor-class-slot:string)
        @doc "Validates class slot name belongs to supported slots."
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
    (defun UEV_IssueAnchor (ank-asset:string ank-fungibility:[bool] acnoi:bool anchor-class-name-or-id:string)
        @doc "Validates class constraints for anchor issuance only. \
            \ It does NOT issue class-id nor anchor-id."
        (if acnoi
            ;;1]When acnoi=true, class-name validation is already enforced in ISSUE capability.
            ;;   Here we only validate free class slot availability.
            (let
                (
                    (classes:integer (UR_ANK-CLASSES|Count ank-asset ank-fungibility))
                )
                (enforce (<= classes 6) (format "Cannot add new Anchor Class for Asset {}" [ank-asset]))
            )
            ;;2]When acnoi=false, class-id path: AnchorClass row at (ank-asset, class-id) must exist (read fails otherwise),
            ;;   stored asset-id on that row must match ank-asset, class must be active, and have a free anchor slot.
            ;;   No summary-slot scan: UC_AssetClassKey already scopes the class row to ank-asset.
            (let
                (
                    (class-asset-id:string (UR_ANK-CLASS|AssetID ank-asset ank-fungibility anchor-class-name-or-id))
                    (class-active:bool (UR_ANK-CLASS|ClassActive ank-asset ank-fungibility anchor-class-name-or-id))
                    (quantity:integer (UR_ANK-CLASS|Quantity ank-asset ank-fungibility anchor-class-name-or-id))
                )
                (enforce
                    (fold (and) true [(= class-asset-id ank-asset) class-active (<= quantity 6)])
                    (format "Anchor Class {} invalid for Asset {}" [anchor-class-name-or-id ank-asset])
                )
            )
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
        ,"ank-class"            : c
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
    (defun UDC_RevokedAnchorClass:object{ANK|AnchorClass}
        (asset-id:string asset-fungibility:[bool] class-id:string revoked-anchor-id:string)
        @doc "Builds class row after removing one anchor id."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (p1:string (UR_ANK-CLASS|First asset-id asset-fungibility class-id))
                (p2:string (UR_ANK-CLASS|Second asset-id asset-fungibility class-id))
                (p3:string (UR_ANK-CLASS|Third asset-id asset-fungibility class-id))
                (p4:string (UR_ANK-CLASS|Fourth asset-id asset-fungibility class-id))
                (p5:string (UR_ANK-CLASS|Fifth asset-id asset-fungibility class-id))
                (p6:string (UR_ANK-CLASS|Sixth asset-id asset-fungibility class-id))
                (p7:string (UR_ANK-CLASS|Seventh asset-id asset-fungibility class-id))
                (ank-qt:integer (UR_ANK-CLASS|Quantity asset-id asset-fungibility class-id))
                (ca:bool (UR_ANK-CLASS|ClassActive asset-id asset-fungibility class-id))
                (lst:[string] [p1 p2 p3 p4 p5 p6 p7])
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id p1) 0)
                        ((= revoked-anchor-id p2) 1)
                        ((= revoked-anchor-id p3) 2)
                        ((= revoked-anchor-id p4) 3)
                        ((= revoked-anchor-id p5) 4)
                        ((= revoked-anchor-id p6) 5)
                        ((= revoked-anchor-id p7) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (UDC_AnchorClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) ca (- ank-qt 1) asset-id class-id
            )
        )
    )
    (defun UDC_AnchorClass:object{ANK|AnchorClass}
        (a:string b:string c:string d:string e:string f:string g:string h:bool i:integer j:string k:string)
        @doc "Constructs AnchorClass object (identity is class-id only; no stored display name)."
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"class-active"         : h
        ,"anchors"              : i
        ,"asset-id"             : j
        ,"class-id"             : k}
    )
    (defun UDC_AssetAnchorClasses:object{ANK|AssetAnchorClasses}
        (a:string b:string c:string d:string e:string f:string g:string h:integer i:integer j:string)
        @doc "Constructs AssetAnchorClasses object."
        {"class-primary"        : a
        ,"class-secondary"      : b
        ,"class-tertiary"       : c
        ,"class-quaternary"     : d
        ,"class-quinary"        : e
        ,"class-senary"         : f
        ,"class-septenary"      : g
        ,"classes"              : h
        ,"anchors"              : i
        ,"asset-id"             : j}
    )
    (defun UDC_AddAssetClass:object{ANK|AssetAnchorClasses}
        (asset-anchor-classes:object{ANK|AssetAnchorClasses} new-class-id:string)
        @doc "Adds class-id to first free class slot."
        (let
            (
                (c1:string (at "class-primary" asset-anchor-classes))
                (c2:string (at "class-secondary" asset-anchor-classes))
                (c3:string (at "class-tertiary" asset-anchor-classes))
                (c4:string (at "class-quaternary" asset-anchor-classes))
                (c5:string (at "class-quinary" asset-anchor-classes))
                (c6:string (at "class-senary" asset-anchor-classes))
                (c7:string (at "class-septenary" asset-anchor-classes))
            )
            (if (= c1 BAR)
                (UDC_AssetAnchorClasses new-class-id c2 c3 c4 c5 c6 c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                (if (= c2 BAR)
                    (UDC_AssetAnchorClasses c1 new-class-id c3 c4 c5 c6 c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                    (if (= c3 BAR)
                        (UDC_AssetAnchorClasses c1 c2 new-class-id c4 c5 c6 c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                        (if (= c4 BAR)
                            (UDC_AssetAnchorClasses c1 c2 c3 new-class-id c5 c6 c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                            (if (= c5 BAR)
                                (UDC_AssetAnchorClasses c1 c2 c3 c4 new-class-id c6 c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                                (if (= c6 BAR)
                                    (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 new-class-id c7 (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                                    (if (= c7 BAR)
                                        (UDC_AssetAnchorClasses c1 c2 c3 c4 c5 c6 new-class-id (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
                                        asset-anchor-classes
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
        (asset-anchor-classes:object{ANK|AssetAnchorClasses} class-id:string)
        @doc "Removes class-id from slots and appends BAR."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (lst:[string]
                    [
                        (at "class-primary" asset-anchor-classes)
                        (at "class-secondary" asset-anchor-classes)
                        (at "class-tertiary" asset-anchor-classes)
                        (at "class-quaternary" asset-anchor-classes)
                        (at "class-quinary" asset-anchor-classes)
                        (at "class-senary" asset-anchor-classes)
                        (at "class-septenary" asset-anchor-classes)
                    ]
                )
                (lst-v1 (ref-U|LST::UC_RemoveItem lst class-id))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (UDC_AssetAnchorClasses (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2) (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (at "classes" asset-anchor-classes) (at "anchors" asset-anchor-classes) (at "asset-id" asset-anchor-classes))
        )
    )
    (defun UDC_SetAssetClassAnchorsAndCounts:object{ANK|AssetAnchorClasses}
        (asset-anchor-classes:object{ANK|AssetAnchorClasses} class-id:string add-class:bool class-delta:integer anchor-delta:integer)
        @doc "Applies class-slot updates and adjusts class/anchor counters."
        (let
            (
                (out:object{ANK|AssetAnchorClasses}
                    (if add-class
                        (UDC_AddAssetClass asset-anchor-classes class-id)
                        asset-anchor-classes
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
        (asset-id:string asset-fungibility:[bool] class-id:string new-anchor-id:string)
        @doc "Builds class row with one appended anchor id."
        (let
            (
                (quantity:integer (UR_ANK-CLASS|Quantity asset-id asset-fungibility class-id))
                (ca:bool (UR_ANK-CLASS|ClassActive asset-id asset-fungibility class-id))
            )
            (cond
                ((= quantity 0) (UDC_AnchorClass new-anchor-id BAR BAR BAR BAR BAR BAR ca 1 asset-id class-id))
                ((= quantity 1) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) new-anchor-id BAR BAR BAR BAR BAR ca 2 asset-id class-id))
                ((= quantity 2) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) (UR_ANK-CLASS|Second asset-id asset-fungibility class-id) new-anchor-id BAR BAR BAR BAR ca 3 asset-id class-id))
                ((= quantity 3) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) (UR_ANK-CLASS|Second asset-id asset-fungibility class-id) (UR_ANK-CLASS|Third asset-id asset-fungibility class-id) new-anchor-id BAR BAR BAR ca 4 asset-id class-id))
                ((= quantity 4) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) (UR_ANK-CLASS|Second asset-id asset-fungibility class-id) (UR_ANK-CLASS|Third asset-id asset-fungibility class-id) (UR_ANK-CLASS|Fourth asset-id asset-fungibility class-id) new-anchor-id BAR BAR ca 5 asset-id class-id))
                ((= quantity 5) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) (UR_ANK-CLASS|Second asset-id asset-fungibility class-id) (UR_ANK-CLASS|Third asset-id asset-fungibility class-id) (UR_ANK-CLASS|Fourth asset-id asset-fungibility class-id) (UR_ANK-CLASS|Fifth asset-id asset-fungibility class-id) new-anchor-id BAR ca 6 asset-id class-id))
                ((= quantity 6) (UDC_AnchorClass (UR_ANK-CLASS|First asset-id asset-fungibility class-id) (UR_ANK-CLASS|Second asset-id asset-fungibility class-id) (UR_ANK-CLASS|Third asset-id asset-fungibility class-id) (UR_ANK-CLASS|Fourth asset-id asset-fungibility class-id) (UR_ANK-CLASS|Fifth asset-id asset-fungibility class-id) (UR_ANK-CLASS|Sixth asset-id asset-fungibility class-id) new-anchor-id ca 7 asset-id class-id))
                (UR_ANK-CLASS|Data asset-id asset-fungibility class-id)
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
                    (fungibility:[bool] [true true])
                    (anchor-class-id:string
                        ;;1]Resolve class-id branch:
                        ;;   acnoi=true  -> issue new class-id from class-name
                        ;;   acnoi=false -> string is already class-id
                        (if acnoi
                            (XI_IssueAnchorClass dptf-id fungibility anchor-class-name-or-id)
                            anchor-class-name-or-id
                        )
                    )
                    (class-key:string (UC_AssetClassKey dptf-id anchor-class-id))
                    (anchor-id:string
                        ;;2]Issue anchor-id and insert anchor definition row
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility anchor-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR -1
                        )
                    )
                    (table-ref (UC_AnchorClassTable fungibility))
                    (asset-table-ref (UC_AssetAnchorClassesTable fungibility))
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data dptf-id fungibility))
                )
                ;;3]Append anchor-id into class row
                (write table-ref class-key (UDC_ClassWithAddedAnchor dptf-id fungibility anchor-class-id anchor-id))
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
                    (fungibility:[bool] [false true])
                    (anchor-class-id:string
                        ;;1]Resolve class-id branch
                        ;;   acnoi=true  -> issue new class-id from class-name
                        ;;   acnoi=false -> string is already class-id
                        (if acnoi
                            (XI_IssueAnchorClass dpsf-id fungibility anchor-class-name-or-id)
                            anchor-class-name-or-id
                        )
                    )
                    (class-key:string (UC_AssetClassKey dpsf-id anchor-class-id))
                    (anchor-id:string
                        ;;2]Issue anchor-id and insert anchor definition row
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility anchor-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR -1
                        )
                    )
                    (table-ref (UC_AnchorClassTable fungibility))
                    (asset-table-ref (UC_AssetAnchorClassesTable fungibility))
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data dpsf-id fungibility))
                )
                ;;3]Append anchor-id into class row
                (write table-ref class-key (UDC_ClassWithAddedAnchor dpsf-id fungibility anchor-class-id anchor-id))
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
                    (out:[string]
                        (XI_IssueNonFungibleAnchor
                            anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile
                            dpnf-trait-key dpnf-trait-value -1
                        )
                    )
                )
                (ref-IGNIS::KDA|C_Collect patron standard)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger out)
            )
        )
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV1.OutputCumulator}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool anchor-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues an Anchor tied to a DPNF set class via nonce-class model (0 = all native NFTs, >0 specific set class)."
        (UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (gas-costs:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (standard:decimal (ref-DALOS::UR_UsagePrice "standard"))
                    (out:[string]
                        (XI_IssueNonFungibleAnchor
                            anchor-name dpnf-id acnoi anchor-class-name-or-id anchor-precision anchor-promile
                            BAR BAR dpnf-nonce-class
                        )
                    )
                )
                (ref-IGNIS::KDA|C_Collect patron standard)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs AQP|SC_NAME trigger out)
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV1.OutputCumulator}
        (anchor-id:string)
        @doc "Revokes an anchor and updates its class linkage tables."
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
    (defun XI_IssueNonFungibleAnchor:[string]
        (
            ank-name:string ank-asset:string acnoi:bool ank-class-name-or-id:string ank-precision:integer ank-promile:decimal
            dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
        )
        @doc "Core NF anchor issue path: resolves class branch, issues anchor row, updates class and asset summary."
        (require-capability (SECURE))
        (let
            (
                (ank-fungibility:[bool] [false false])
                (ank-class:string
                    (if acnoi
                        (XI_IssueAnchorClass ank-asset ank-fungibility ank-class-name-or-id)
                        ank-class-name-or-id
                    )
                )
                (class-key:string (UC_AssetClassKey ank-asset ank-class))
                (anchor-id:string
                    (XI_IssueAnchor
                        ank-name ank-asset ank-fungibility ank-class ank-precision ank-promile
                        0.0 0 dpnf-trait-key dpnf-trait-value dpnf-nonce-class
                    )
                )
                (table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data ank-asset ank-fungibility))
            )
            (write table-ref class-key (UDC_ClassWithAddedAnchor ank-asset ank-fungibility ank-class anchor-id))
            (write asset-table-ref ank-asset
                (UDC_SetAssetClassAnchorsAndCounts asset-classes ank-class false 0 1)
            )
            (if acnoi
                [anchor-id ank-class]
                [anchor-id]
            )
        )
    )
    (defun XI_IssueAnchorClass:string
        (asset-id:string ank-fungibility:[bool] class-name:string)
        @doc "Issues Anchor Class row and links it to asset; outputs class-id."
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (asset-classes:object{ANK|AssetAnchorClasses} 
                    ;;1]Read current asset class summary
                    (UR_ANK-CLASSES|Data asset-id ank-fungibility)
                )
                (class-id:string 
                    ;;2]Create class-id from class-name
                    (ref-U|DALOS::UDC_Makeid class-name)
                )
                (class-key:string (UC_AssetClassKey asset-id class-id))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
            )
            ;;3]Insert empty active class row (identity is class-id only)
            (insert class-table-ref class-key
                (UDC_AnchorClass BAR BAR BAR BAR BAR BAR BAR true 0 asset-id class-id)
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
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
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
                (UDC_ANK|Schema
                    ank-asset
                    ank-fungibility
                    ank-class
                    ank-precision
                    true
                    ank-promile
                    dptf-amount
                    dpsf-nonce
                    dpnf-trait-key
                    dpnf-trait-value
                    dpnf-nonce-class
                    anchor-id
                )
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
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_ANK|Fungibility anchor-id))
                (ank-class:string (at "ank-class" (UR_ANK|Data anchor-id)))
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data ank-asset ank-fungibility))
                (class-key:string (UC_AssetClassKey ank-asset ank-class))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
                (revoked-class:object{ANK|AnchorClass} (UDC_RevokedAnchorClass ank-asset ank-fungibility ank-class anchor-id))
                (class-now-empty:bool (= (at "anchors" revoked-class) 0))
            )
            (write class-table-ref class-key revoked-class)
            (write asset-table-ref ank-asset
                (if class-now-empty
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes ank-class false 0 -1)
                    (UDC_SetAssetClassAnchorsAndCounts asset-classes ank-class false 0 -1)
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
                (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data asset-id ank-fungibility))
                (class-key:string (UC_AssetClassKey asset-id anchor-class-id))
                (class-table-ref (UC_AnchorClassTable ank-fungibility))
                (asset-table-ref (UC_AssetAnchorClassesTable ank-fungibility))
            )
            ;;2]Only empty classes can be revoked
            (enforce (= (UR_ANK-CLASS|Quantity asset-id ank-fungibility anchor-class-id) 0) "Anchor Class must be empty for revoke")
            ;;3]Mark class row inactive
            (update class-table-ref class-key {"class-active" : false})
            ;;4]Unlink class-id from asset slots and decrement classes count
            (write asset-table-ref asset-id
                (UDC_SetAssetClassAnchorsAndCounts (UDC_RemoveAssetClass asset-classes anchor-class-id) anchor-class-id false -1 0)
            )
        )
    )
    ;;
    (defun XU_UpdateSemiFungibleClassAnchors
        (account:string dpsf-id:string class-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates all live SF anchors in one class for account."
        (let
            (
                (a1:string (UR_ANK-CLASS|First dpsf-id [false true] class-id))
                (a2:string (UR_ANK-CLASS|Second dpsf-id [false true] class-id))
                (a3:string (UR_ANK-CLASS|Third dpsf-id [false true] class-id))
                (a4:string (UR_ANK-CLASS|Fourth dpsf-id [false true] class-id))
                (a5:string (UR_ANK-CLASS|Fifth dpsf-id [false true] class-id))
                (a6:string (UR_ANK-CLASS|Sixth dpsf-id [false true] class-id))
                (a7:string (UR_ANK-CLASS|Seventh dpsf-id [false true] class-id))
            )
            (if (and (!= a1 BAR) (UR_ANK|State a1)) (write ANK|T|Anchors (UC_UserAnchor account a1) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a1 nonces nonce-amounts direction) account a1)) true)
            (if (and (!= a2 BAR) (UR_ANK|State a2)) (write ANK|T|Anchors (UC_UserAnchor account a2) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a2 nonces nonce-amounts direction) account a2)) true)
            (if (and (!= a3 BAR) (UR_ANK|State a3)) (write ANK|T|Anchors (UC_UserAnchor account a3) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a3 nonces nonce-amounts direction) account a3)) true)
            (if (and (!= a4 BAR) (UR_ANK|State a4)) (write ANK|T|Anchors (UC_UserAnchor account a4) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a4 nonces nonce-amounts direction) account a4)) true)
            (if (and (!= a5 BAR) (UR_ANK|State a5)) (write ANK|T|Anchors (UC_UserAnchor account a5) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a5 nonces nonce-amounts direction) account a5)) true)
            (if (and (!= a6 BAR) (UR_ANK|State a6)) (write ANK|T|Anchors (UC_UserAnchor account a6) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a6 nonces nonce-amounts direction) account a6)) true)
            (if (and (!= a7 BAR) (UR_ANK|State a7)) (write ANK|T|Anchors (UC_UserAnchor account a7) (UDC_AccountAnchor (URC_SemiFungibleAnchorPromile account a7 nonces nonce-amounts direction) account a7)) true)
        )
    )
    (defun XU_UpdateNonFungibleClassAnchors
        (account:string dpnf-id:string class-id:string nonces:[integer] direction:bool)
        @doc "Updates all live NF anchors in one class for account."
        (let
            (
                (a1:string (UR_ANK-CLASS|First dpnf-id [false false] class-id))
                (a2:string (UR_ANK-CLASS|Second dpnf-id [false false] class-id))
                (a3:string (UR_ANK-CLASS|Third dpnf-id [false false] class-id))
                (a4:string (UR_ANK-CLASS|Fourth dpnf-id [false false] class-id))
                (a5:string (UR_ANK-CLASS|Fifth dpnf-id [false false] class-id))
                (a6:string (UR_ANK-CLASS|Sixth dpnf-id [false false] class-id))
                (a7:string (UR_ANK-CLASS|Seventh dpnf-id [false false] class-id))
            )
            (if (and (!= a1 BAR) (UR_ANK|State a1)) (write ANK|T|Anchors (UC_UserAnchor account a1) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a1 nonces direction) account a1)) true)
            (if (and (!= a2 BAR) (UR_ANK|State a2)) (write ANK|T|Anchors (UC_UserAnchor account a2) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a2 nonces direction) account a2)) true)
            (if (and (!= a3 BAR) (UR_ANK|State a3)) (write ANK|T|Anchors (UC_UserAnchor account a3) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a3 nonces direction) account a3)) true)
            (if (and (!= a4 BAR) (UR_ANK|State a4)) (write ANK|T|Anchors (UC_UserAnchor account a4) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a4 nonces direction) account a4)) true)
            (if (and (!= a5 BAR) (UR_ANK|State a5)) (write ANK|T|Anchors (UC_UserAnchor account a5) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a5 nonces direction) account a5)) true)
            (if (and (!= a6 BAR) (UR_ANK|State a6)) (write ANK|T|Anchors (UC_UserAnchor account a6) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a6 nonces direction) account a6)) true)
            (if (and (!= a7 BAR) (UR_ANK|State a7)) (write ANK|T|Anchors (UC_UserAnchor account a7) (UDC_AccountAnchor (URC_NonFungibleAnchorPromile account a7 nonces direction) account a7)) true)
        )
    )
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
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates all active SF anchor-user rows for account on dpsf-id."
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
            (let
                (
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data dpsf-id [false true]))
                    (c1:string (at "class-primary" asset-classes))
                    (c2:string (at "class-secondary" asset-classes))
                    (c3:string (at "class-tertiary" asset-classes))
                    (c4:string (at "class-quaternary" asset-classes))
                    (c5:string (at "class-quinary" asset-classes))
                    (c6:string (at "class-senary" asset-classes))
                    (c7:string (at "class-septenary" asset-classes))
                )
                (if (and (!= c1 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c1)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c1 nonces nonce-amounts direction) true)
                (if (and (!= c2 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c2)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c2 nonces nonce-amounts direction) true)
                (if (and (!= c3 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c3)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c3 nonces nonce-amounts direction) true)
                (if (and (!= c4 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c4)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c4 nonces nonce-amounts direction) true)
                (if (and (!= c5 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c5)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c5 nonces nonce-amounts direction) true)
                (if (and (!= c6 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c6)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c6 nonces nonce-amounts direction) true)
                (if (and (!= c7 BAR) (UR_ANK-CLASS|ClassActive dpsf-id [false true] c7)) (XU_UpdateSemiFungibleClassAnchors account dpsf-id c7 nonces nonce-amounts direction) true)
            )
        )
    )
    (defun XE_UpdateNonFungibleAnchor
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Updates all active NF anchor-user rows for account on dpnf-id."
        ;;
        (UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
            (let
                (
                    (asset-classes:object{ANK|AssetAnchorClasses} (UR_ANK-CLASSES|Data dpnf-id [false false]))
                    (c1:string (at "class-primary" asset-classes))
                    (c2:string (at "class-secondary" asset-classes))
                    (c3:string (at "class-tertiary" asset-classes))
                    (c4:string (at "class-quaternary" asset-classes))
                    (c5:string (at "class-quinary" asset-classes))
                    (c6:string (at "class-senary" asset-classes))
                    (c7:string (at "class-septenary" asset-classes))
                )
                (if (and (!= c1 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c1)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c1 nonces direction) true)
                (if (and (!= c2 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c2)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c2 nonces direction) true)
                (if (and (!= c3 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c3)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c3 nonces direction) true)
                (if (and (!= c4 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c4)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c4 nonces direction) true)
                (if (and (!= c5 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c5)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c5 nonces direction) true)
                (if (and (!= c6 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c6)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c6 nonces direction) true)
                (if (and (!= c7 BAR) (UR_ANK-CLASS|ClassActive dpnf-id [false false] c7)) (XU_UpdateNonFungibleClassAnchors account dpnf-id c7 nonces direction) true)
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
