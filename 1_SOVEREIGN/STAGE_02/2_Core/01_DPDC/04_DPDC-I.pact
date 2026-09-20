;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcIssueV2
    @doc "Exposes Collectables Issue Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

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
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator} (son:bool owner-account:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    ;; C_DeployAccountSFT/NFT removed — DPDC Audit #35M: standalone deployment, reachable via a public
    ;; Talos entrypoint with no ownership check, let any signer force any existing account to associate
    ;; with any collection. Real auto-association always calls DPDC::XBv_DeployAccountSFT/NFT directly,
    ;; module-to-module (see DPDC-C/DPDC-F/DPDC-R/DPDC-S and this module's own Issue flow below).
    (defun C_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
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
    @doc "DPDC-I is the Collectables Issue module of the DPDC family, implementing \
        \ DpdcIssueV2 and OuronetPolicyV2. Its flagship entrypoint C_IssueDigitalCollection \
        \ creates a new digital collection (SFT if son=true, else NFT): it charges IGNIS and \
        \ STOA usage fees, writes the collection record and its initial Verum role-chain via \
        \ DPDC, and auto-deploys owner and creator collection accounts with distinct default \
        \ role sets. URCi_ functions provide cost previews; it manages only its own policy \
        \ tables and gates issuance on owner-account ownership."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcIssueV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-I                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-I_ADMIN)))
    (defcap GOV|DPDC-I_ADMIN ()                         (enforce-guard GOV|MD_DPDC-I))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-I|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-I|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPDC-I|CALLER)))
            )
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;
    (defun URCi_IssueCollectionPrice:decimal
        (son:bool)
        @doc "IGNIS issue price for a digital collection, from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): son=true (SFT) = $20 = 2000 \
            \ ignis, son=false (NFT) = $25 = 2500 ignis (owner 2026-09-05). \
            \ Single source for the exec construct and the INFO preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_Issue" "issue-sft")
                    (ref-IGNIS::UC_IgnisPrice "DPNF|C_Issue" "issue-nft"))
        )
    )
    (defun URCi_IssueCollectionStoa:decimal
        (son:bool)
        @doc "STOA side-cost for a digital-collection issue (dpsf for SFT, dpnf for NFT). \
            \ Single source for XE_CollectStoa and the INFO preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if son (ref-IGNIS::UC_StoaPrice "issue-sft") (ref-IGNIS::UC_StoaPrice "issue-nft"))
        )
    )
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
        (son:bool owner-account:string)
        @doc "Cost preview for C_IssueDigitalCollection: IGNIS construct priced via \
            \ URCi_IssueCollectionPrice on the owner payer, empty output (the created \
            \ collection id is an exec-only write product). The STOA side-cost previews \
            \ separately via URCi_IssueCollectionStoa."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    ;;Protection: Class 3 — Custom: DPDC-I|C>ISSUE
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
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (id:string (ref-U|DALOS::UDC_Makeid collection-ticker))
                (specifications:object{DpdcUdcV2.DPDC|Properties}
                    (ref-DPDC-UDC::UDC_DPDC|Properties
                        id owner-account creator-account collection-name collection-ticker
                        can-upgrade can-change-owner can-change-creator can-add-special-role
                        can-transfer-nft-create-role can-freeze can-wipe can-pause
                        false 0 0
                    )
                )
                (zne:[object{DpdcUdcV2.DPDC|NonceElement}]
                    [(ref-DPDC-UDC::UDC_ZeroNonceElement)]
                )
                (ca:string creator-account)
                (oa:string owner-account)
                (verum-chain:object{DpdcUdcV2.DPDC|VerumRoles}
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
    (defun C_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-DPDC:module{DpdcV2} DPDC)
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
                            (ref-DPDC::XBv_DeployAccountSFT owner-account id
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
                            (ref-DPDC::XBv_DeployAccountSFT creator-account id
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
                        (ref-DPDC::XBv_DeployAccountSFT owner-account id
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
                            (ref-DPDC::XBv_DeployAccountNFT owner-account id
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
                            (ref-DPDC::XBv_DeployAccountNFT creator-account id
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
                        (ref-DPDC::XBv_DeployAccountNFT owner-account id
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
                (ref-IGNIS::XE_CollectStoa patron stoa-cost)
                (ref-IGNIS::UDC_ConstructOutputCumulator ignis-price owner-account trigger [id])
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)