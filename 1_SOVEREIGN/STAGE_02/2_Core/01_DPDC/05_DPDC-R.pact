;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcRolesV2
    @doc "Exposes Collectables Role Functions"

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
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;

    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))
    (defun C_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))
    (defun C_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))

)
;;
(module DPDC-R GOV
    @doc "DPDC-R is the Collectables Roles module of the DPDC family, implementing \
        \ DpdcRolesV2 and OuronetPolicyV2, managing the special roles on a collection's \
        \ accounts. Its C_ entrypoints toggle per-account roles (add-quantity, freeze, \
        \ exemption, burn, update, modify-creator, modify-royalties, transfer) and move \
        \ singleton roles (create, recreate, set-URI) between accounts. Each op is \
        \ owner-gated via DPDC::CAP_Owner plus role/state validators, ensures the target \
        \ account is deployed, then writes state and updates the Verum role-chain through \
        \ DPDC; URCi_ give IGNIS cost previews."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcRolesV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-R                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-R_ADMIN)))
    (defcap GOV|DPDC-R_ADMIN ()                         (enforce-guard GOV|MD_DPDC-R))
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
    (defcap P|DPDC-R|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-R|CALLER))
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
        (with-capability (GOV|DPDC-R_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-R_ADMIN)
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
        (with-capability (GOV|DPDC-R_ADMIN)
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
        (with-capability (GOV|DPDC-R_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (mg:guard (create-capability-guard (P|DPDC-R|CALLER)))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
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
    (defcap DPDC|C>TG_ADD-QTY-R (id:string account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id true toggle)
            (ref-DPDC::UEV_AccountAddQuantityState id account (not toggle))
            (ref-DPDC::CAP_Owner id true)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>FRZ-ACC (id:string son:bool account:string frozen:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;; DPDC Audit #13H: <can-freeze> gates new freezes only — unfreeze is a release valve and
            ;; must stay available even after <can-freeze> has been renounced, or an already-frozen
            ;; account (combined with <can-upgrade=false>) would be bricked with no recovery path.
            (if frozen
                (ref-DPDC::UEV_CanFreezeON id son)
                true
            )
            (ref-DPDC::UEV_AccountFreezeState id son account (not frozen))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_EXEMPTION-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (type:bool (ref-DALOS::UR_AccountType account))
            )
            (enforce type "Only Smart Ouronet Accounts can get this role")
            (ref-DPDC::UEV_AccountExemptionState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_BURN-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountBurnState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_UPDATE-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountUpdateState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_MODIFY-CREATOR-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountModifyCreatorState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_MODIFY-ROYALTIES-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountModifyRoyaltiesState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_TRANSFER-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountTransferState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    ;;
    (defcap DPDC|C>MV_CREATE-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountCreateState id son old-account true)
            (ref-DPDC::UEV_AccountCreateState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>MV_RECREATE-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountRecreateState id son old-account true)
            (ref-DPDC::UEV_AccountRecreateState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        ) 
    )
    (defcap DPDC|C>MV_SET-URI-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountSetUriState id son old-account true)
            (ref-DPDC::UEV_AccountSetUriState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
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
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_ToggleAddQuantityRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleAddQuantityRole" "auth")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleFreezeAccount (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleFreezeAccount" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleFreezeAccount" "setup"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleExemptionRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleExemptionRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleExemptionRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleBurnRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleBurnRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleBurnRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleUpdateRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleUpdateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleUpdateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleModifyCreatorRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleModifyCreatorRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleModifyCreatorRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleModifyRoyaltiesRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleModifyRoyaltiesRole" "fee")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleModifyRoyaltiesRole" "fee"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleTransferRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleTransferRole" "usage")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleTransferRole" "usage"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveCreateRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveCreateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveCreateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveRecreateRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveRecreateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveRecreateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveSetUriRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveSetUriRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveSetUriRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPDC|C>TG_ADD-QTY-R
    (defun XI_ToggleAddQuantityRole (id:string account:string toggle:bool)
        (require-capability (DPDC|C>TG_ADD-QTY-R id account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Rnaq id account toggle)
            (ref-DPDC::XE_U|VerumRoles id true 3 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>FRZ-ACC
    (defun XI_ToggleFreezeAccount (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>FRZ-ACC id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
            )
            (ref-DPDC::XE_U|Frozen id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 1 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_EXEMPTION-R
    (defun XI_ToggleExemptionRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_EXEMPTION-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
            )
            (ref-DPDC::XE_U|Exemption id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 2 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_BURN-R
    (defun XI_ToggleBurnRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_BURN-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Burn id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 4 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_UPDATE-R
    (defun XI_ToggleUpdateRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_UPDATE-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Update id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 7 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_MODIFY-CREATOR-R
    (defun XI_ToggleModifyCreatorRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_MODIFY-CREATOR-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|ModifyCreator id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 8 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_MODIFY-ROYALTIES-R
    (defun XI_ToggleModifyRoyaltiesRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_MODIFY-ROYALTIES-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|ModifyRoyalties id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 9 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_TRANSFER-R
    (defun XI_ToggleTransferRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_TRANSFER-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Transfer id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 11 toggle account)
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPDC|C>MV_CREATE-R
    (defun XI_MoveCreateRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_CREATE-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Create id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 5 false old-account)
            (ref-DPDC::XE_U|Create id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 5 true new-account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>MV_RECREATE-R
    (defun XI_MoveRecreateRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_RECREATE-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Recreate id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 6 false old-account)
            (ref-DPDC::XE_U|Recreate id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 6 true new-account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>MV_SET-URI-R
    (defun XI_MoveSetUriRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_SET-URI-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|SetNewUri id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 10 false old-account)
            (ref-DPDC::XE_U|SetNewUri id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 10 true new-account)
        )
    )
    ;;{5.7}  User [A/C]
    ;;Role Toggling
    (defun UEV_ExecutorIsCollectionOwner (executor:string id:string son:bool)
        @doc "Thin local wrapper over DPDC::UEV_ExecutorIsOwnerKonto. \
            \ \
            \ RENAMED 2026-09-22 from UEV_ExecutorIsOwnerKontoLocal. 06_DPDC-MNG and 08_DPDC-S \
            \ define the identical helper under the name used here, and three names for one \
            \ check in one module family is three greps. \
            \ \
            \ Exists so the DPDC modref is bound in ONE place rather than at eleven call sites. \
            \ Every entrypoint in this module is gated by DPDC::CAP_Owner, which enforces on the \
            \ DERIVED (UR_OwnerKonto id son) -- HANDOFF 4g, across the whole module -- so all \
            \ eleven need the same binder against the same pair. \
            \ \
            \ <son> travels with <id> because DPSF and DPNF are separate tables and the same id \
            \ can live in both; an owner lookup without it is a lookup of a different token. \
            \ C_ToggleAddQuantityRole passes the literal TRUE, matching its own capability, \
            \ which already hardcodes (CAP_Owner id true) because add-quantity is semi-fungible \
            \ only. (patron/executor canon 2.2, indirect route named.)"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
        )
    )
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id true)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_ADD-QTY-R id executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id true)
                (XI_ToggleAddQuantityRole id executee toggle)
                (URCi_ToggleAddQuantityRole id)
            )
        )
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>FRZ-ACC id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleFreezeAccount id son executee toggle)
                (URCi_ToggleFreezeAccount id son)
            )
        )
    )
    (defun C_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_EXEMPTION-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleExemptionRole id son executee toggle)
                (URCi_ToggleExemptionRole id son)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_BURN-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleBurnRole id son executee toggle)
                (URCi_ToggleBurnRole id son)
            )
        )
    )
    (defun C_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_UPDATE-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleUpdateRole id son executee toggle)
                (URCi_ToggleUpdateRole id son)
            )
        )
    )
    (defun C_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_MODIFY-CREATOR-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleModifyCreatorRole id son executee toggle)
                (URCi_ToggleModifyCreatorRole id son)
            )
        )
    )
    (defun C_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_MODIFY-ROYALTIES-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleModifyRoyaltiesRole id son executee toggle)
                (URCi_ToggleModifyRoyaltiesRole id son)
            )
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_TRANSFER-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleTransferRole id son executee toggle)
                (URCi_ToggleTransferRole id son)
            )
        )
    )
    ;;
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum5 id son))
            )
            (with-capability (DPDC|C>MV_CREATE-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveCreateRole id son old-account executee)
                (URCi_MoveCreateRole id son)
            )
        )
    )
    (defun C_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum6 id son))
            )
            (with-capability (DPDC|C>MV_RECREATE-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveRecreateRole id son old-account executee)
                (URCi_MoveRecreateRole id son)
            )
        )
    )
    (defun C_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum10 id son))
            )
            (with-capability (DPDC|C>MV_SET-URI-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveSetUriRole id son old-account executee)
                (URCi_MoveSetUriRole id son)
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)