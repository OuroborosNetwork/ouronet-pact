;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EliteV2
    @doc "Exposes Elite Account Related Functions"

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
    ;;  [URC]
    ;;
    (defun URC_EliteAurynzSupply (account:string))
    (defun URC_IzIdEA:bool (id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_UpdateEliteSingle (id:string account:string))
    (defun XE_UpdateElite (id:string sender:string receiver:string))
    ;;{5.7}  User [A/C]

)
;;
(module ELITE GOV




    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements EliteV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ELITE                  (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|ELITE_ADMIN)))
    (defcap GOV|ELITE_ADMIN ()              (enforce-guard GOV|MD_ELITE))
    ;;{G5}  functions
    ;;#56L fix: removed GOV|ELITE_ADMIN-CALLER (defcap) and GOV|CollectiblesKey (defun,
    ;;referencing an unrelated "dpdc-keyset") - two vestigial boilerplate items copied from the
    ;;module sample template, confirmed zero references anywhere in the repo (including from
    ;;other modules via ref-ELITE::). No functional change.
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|ELITE|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ELITE|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
        (with-capability (GOV|ELITE_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|ELITE_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (mg:guard (create-capability-guard (P|ELITE|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()                    (let ((ref-U|CT:module{OuronetConstantsV2} U|CT)) (ref-U|CT::CT_NS_USE)))
    ;;
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV2} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_EliteAurynzSupply (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (fea:string (ref-DPTF::UR_Frozen ea-id))
                        (rea:string (ref-DPTF::UR_Reservation ea-id))
                        (vea:string (ref-DPTF::UR_Vesting ea-id))
                        (sea:string (ref-DPTF::UR_Sleeping ea-id))
                        (hea:string (ref-DPTF::UR_Hibernation ea-id))
                        (fea-supply:decimal
                            (if (!= fea BAR)
                                (ref-DPTF::UR_AccountSupply fea account)
                                0.0
                            )
                        )
                        (rea-supply:decimal
                            (if (!= rea BAR)
                                (ref-DPTF::UR_AccountSupply rea account)
                                0.0
                            )
                        )
                        (vea-supply:decimal
                            (if (!= vea BAR)
                                (ref-DPOF::UR_AccountSupply vea account)
                                0.0
                            )
                        )
                        (sea-supply:decimal
                            (if (!= sea BAR)
                                (ref-DPOF::UR_AccountSupply sea account)
                                0.0
                            )
                        )
                        (hea-supply:decimal
                            (if (!= hea BAR)
                                (ref-DPOF::UR_AccountSupply hea account)
                                0.0
                            )
                        )
                    )
                    (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply hea-supply])
                )
                0.0
            )
        )
    )
    (defun URC_IzIdEA:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
                (vea:string (ref-DPTF::UR_Vesting ea-id))
                (sea:string (ref-DPTF::UR_Sleeping ea-id))
                (hea:string (ref-DPTF::UR_Hibernation ea-id))
            )
            (contains id [ea-id fea rea vea sea hea])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    (defun XE_UpdateEliteSingle (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (a-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not a-type)
                        (ref-DALOS::XE_UpdateElite account (URC_EliteAurynzSupply account))
                        true
                    )
                )
                true
            )
        )
    )
    (defun XE_UpdateElite (id:string sender:string receiver:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (s-type:bool (ref-DALOS::UR_AccountType sender))
                (r-type:bool (ref-DALOS::UR_AccountType receiver))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not s-type)
                        (ref-DALOS::XE_UpdateElite sender (URC_EliteAurynzSupply sender))
                        true
                    )
                    (if (not r-type)
                        (ref-DALOS::XE_UpdateElite receiver (URC_EliteAurynzSupply receiver))
                        true
                    )
                )
                true
            )
        )
    )
    ;;{5.7}  User [A/C]

)

(create-table P|T)
(create-table P|MT)