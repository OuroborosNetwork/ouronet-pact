;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
(interface DpdcIssueV1
    @doc "Exposes Collectables Issue Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_IssueCollectionPrice:decimal (son:bool))
    (defun URCi_IssueCollectionStoa:decimal (son:bool))
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV1.OutputCumulator} (son:bool owner-account:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    ;; C_DeployAccountSFT/NFT removed — DPDC Audit #35M: standalone deployment, reachable via a public
    ;; Talos entrypoint with no ownership check, let any signer force any existing account to associate
    ;; with any collection. Real auto-association always calls DPDC::XB_DeployAccountSFT/NFT directly,
    ;; module-to-module (see DPDC-C/DPDC-F/DPDC-R/DPDC-S and this module's own Issue flow below).
    (defun C_IssueDigitalCollection:object{IgnisCollectorV1.OutputCumulator}
        (
            patron:string son:bool
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
    )

)
;;
(module DPDC-I GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements DpdcIssueV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-I                 (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|DPDC-I_ADMIN)))
    (defcap GOV|DPDC-I_ADMIN ()             (enforce-guard GOV|MD_DPDC-I))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-I|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-I|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-I_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-I_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPDC:module{OuronetPolicyV1} DPDC)
                (mg:guard (create-capability-guard (P|DPDC-I|CALLER)))
            )
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                   (CT_Bar))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DPDC-I|C>ISSUE (owner-account:string creator-account:string collection-name:string collection-ticker:string iz-special:bool)
        @doc "DPDC Audit #53L: <creator-account> is intentionally NOT ownership-checked, unlike \
            \ <owner-account> (real CAP_EnforceAccountOwnership below). The collection owner is meant \
            \ to be able to freely designate any account -- e.g. a trusted associate -- as the \
            \ collection's creator without that account's separate consent/signature, the same way an \
            \ owner has complete dominion over their own collection's admin structure elsewhere in this \
            \ module family (#4C/#17H/#20H/#25M). Only the type/prefix is validated \
            \ (UEV_EnforceAccountType) so <creator-account> is at least a real, well-formed account."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-U|DALOS::UEV_NameOrTicker collection-name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker collection-ticker false iz-special)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
            (ref-DALOS::UEV_EnforceAccountType creator-account false)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;
    (defun URCi_IssueCollectionPrice:decimal
        (son:bool)
        @doc "IGNIS issue price for a digital collection: token-issue * (son?5:10). \
            \ Single source for the exec construct and the INFO preview."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (* (ref-DALOS::UR_UsagePrice "ignis|token-issue") (if son 5.0 10.0))
        )
    )
    (defun URCi_IssueCollectionStoa:decimal
        (son:bool)
        @doc "STOA side-cost for a digital-collection issue (dpsf for SFT, dpnf for NFT). \
            \ Single source for C_STOA|Collect and the INFO preview."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpnf"))
        )
    )
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV1.OutputCumulator}
        (son:bool owner-account:string)
        @doc "Cost preview for C_IssueDigitalCollection: IGNIS construct priced via \
            \ URCi_IssueCollectionPrice on the owner payer, empty output (the created \
            \ collection id is an exec-only write product). The STOA side-cost previews \
            \ separately via URCi_IssueCollectionStoa."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URCi_IssueCollectionPrice son)
                owner-account
                (ref-IGNIS::URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XI_IssueDigitalCollection:string
        (
            son:bool
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
        (require-capability (DPDC-I|C>ISSUE owner-account creator-account collection-name collection-ticker iz-special))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-DPDC:module{DpdcV1} DPDC)
                (id:string (ref-U|DALOS::UDC_Makeid collection-ticker))
                (specifications:object{DpdcUdcV1.DPDC|Properties}
                    (ref-DPDC-UDC::UDC_DPDC|Properties
                        id owner-account creator-account collection-name collection-ticker
                        can-upgrade can-change-owner can-change-creator can-add-special-role
                        can-transfer-nft-create-role can-freeze can-wipe can-pause
                        false 0 0
                    )
                )
                (zne:[object{DpdcUdcV1.DPDC|NonceElement}]
                    [(ref-DPDC-UDC::UDC_ZeroNonceElement)]
                )
                (ca:string creator-account)
                (oa:string owner-account)
                (verum-chain:object{DpdcUdcV1.DPDC|VerumRoles}
                    (if son
                        (if (!= owner-account creator-account)
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [ca]    ;;r-exemption
                                [oa]    ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                ca      ;;r-nft-create
                                ca      ;;r-nft-recreate
                                [ca oa] ;;r-nft-update
                                [ca]    ;;r-modify-creator
                                [ca]    ;;r-modify-royalties
                                ca      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [oa]    ;;r-exemption
                                [oa]    ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                oa      ;;r-nft-create
                                oa      ;;r-nft-recreate
                                [oa] ;;r-nft-update
                                [oa]    ;;r-modify-creator
                                [oa]    ;;r-modify-royalties
                                oa      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                        )
                        (if (!= owner-account creator-account)
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [ca]    ;;r-exemption
                                [BAR]   ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                ca      ;;r-nft-create
                                ca      ;;r-nft-recreate
                                [ca oa] ;;r-nft-update
                                [ca]    ;;r-modify-creator
                                [ca]    ;;r-modify-royalties
                                ca      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [oa]    ;;r-exemption
                                [BAR]   ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                oa      ;;r-nft-create
                                oa      ;;r-nft-recreate
                                [oa]    ;;r-nft-update
                                [oa]    ;;r-modify-creator
                                [oa]    ;;r-modify-royalties
                                oa      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                        )
                        
                    )
                )
            )
            (ref-DPDC::XE_I|Collection id son specifications)
            (ref-DPDC::XE_I|VerumRoles id son verum-chain)
            id
        )
    )
    ;;{5.7}  User [A/C]
    ;; C_DeployAccountSFT/NFT removed — DPDC Audit #35M: see interface-side removal note above.
    (defun C_IssueDigitalCollection:object{IgnisCollectorV1.OutputCumulator}
        (
            patron:string son:bool
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
        (P|UEV_IMC)
        (with-capability (DPDC-I|C>ISSUE owner-account creator-account collection-name collection-ticker iz-special)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-BRD:module{BrandingV1} BRD)
                    (ref-DPDC:module{DpdcV1} DPDC)
                    ;;
                    (ignis-price:decimal (URCi_IssueCollectionPrice son))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (stoa-cost:decimal (URCi_IssueCollectionStoa son))
                    (id:string
                        (XI_IssueDigitalCollection
                            son
                            owner-account creator-account collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role 
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            iz-special
                        )
                    )
                    (t:bool true)
                    (f:bool false)
                )
                (ref-BRD::XE_Issue id)
                ;;Deploy Collection Accounts for Owner and Creator
                (if son
                    ;;SFT New Account Roles
                    (if (!= owner-account creator-account)
                        (do
                            (ref-DPDC::XB_DeployAccountSFT owner-account id
                                true    ;;role-nft-add-quantity
                                false   ;;frozen
                                false   ;;role-exemption
                                true    ;;role-nft-burn
                                false   ;;role-nft-create
                                false   ;;role-nft-recreate
                                true    ;;role-nft-update
                                false   ;;role-modify-creator
                                false   ;;role-modify-royalties
                                false   ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                            (ref-DPDC::XB_DeployAccountSFT creator-account id
                                false   ;;role-nft-add-quantity
                                false   ;;frozen
                                true    ;;role-exemption
                                false   ;;role-nft-burn
                                true    ;;role-nft-create
                                true    ;;role-nft-recreate
                                true    ;;role-nft-update
                                true    ;;role-modify-creator
                                true    ;;role-modify-royalties
                                true    ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                        )
                        (ref-DPDC::XB_DeployAccountSFT owner-account id
                            true    ;;role-nft-add-quantity
                            false   ;;frozen
                            true    ;;role-exemption
                            true    ;;role-nft-burn
                            true    ;;role-nft-create
                            true    ;;role-nft-recreate
                            true    ;;role-nft-update
                            true    ;;role-modify-creator
                            true    ;;role-modify-royalties
                            true    ;;role-set-new-uri
                            false   ;;role-transfer
                        )
                    )
                    (if (!= owner-account creator-account)
                        (do
                            (ref-DPDC::XB_DeployAccountNFT owner-account id
                                false   ;;frozen
                                false   ;;role-exemption
                                true    ;;role-nft-burn
                                false   ;;role-nft-create
                                false   ;;role-nft-recreate
                                true    ;;role-nft-update
                                false   ;;role-modify-creator
                                false   ;;role-modify-royalties
                                false   ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                            (ref-DPDC::XB_DeployAccountNFT creator-account id
                                false   ;;frozen
                                true    ;;role-exemption
                                false   ;;role-nft-burn
                                true    ;;role-nft-create
                                true    ;;role-nft-recreate
                                true    ;;role-nft-update
                                true    ;;role-modify-creator
                                true    ;;role-modify-royalties
                                true    ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                        )
                        (ref-DPDC::XB_DeployAccountNFT owner-account id
                            false   ;;frozen
                            true    ;;role-exemption
                            true    ;;role-nft-burn
                            true    ;;role-nft-create
                            true    ;;role-nft-recreate
                            true    ;;role-nft-update
                            true    ;;role-modify-creator
                            true    ;;role-modify-royalties
                            true    ;;role-set-new-uri
                            false   ;;role-transfer
                        )
                    )
                )
                (ref-IGNIS::C_STOA|Collect patron stoa-cost)
                (ref-IGNIS::UDC_ConstructOutputCumulator ignis-price owner-account trigger [id])
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)