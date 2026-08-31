;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; NOTE (Phase 1.1 URCi reposition, 2026-08-30): the shared OI|* cost/format vocabulary that
;; used to live here was relocated to the IGNIS module (the pre-Talos cost hub, so Talos + all
;; cost modules + the Z_Reads presentation layer can reach it). INFO-ZERO is now pure DALOS
;; presentation (DalosInfoV1) — its DALOS-INFO|URC_* functions call IGNIS's OI|* via
;; ref-I|OURONET. It relocates to Z_Reads (deployed last) in a follow-up step.
;;
(interface DalosInfoV1
    @doc "Exposes Information Function for the Dalos Client Functions"
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun DALOS-INFO|URC_ControlSmartAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_DeploySmartAccount:object{OuronetInfoV1.ClientInfo} (account:string))
    (defun DALOS-INFO|URC_DeployStandardAccount:object{OuronetInfoV1.ClientInfo} (account:string))
    (defun DALOS-INFO|URC_RotateGovernor:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_RotateGuard:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_RotateStoa:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_RotateSovereign:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_UpdateEliteAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun DALOS-INFO|URC_UpdateEliteAccountSquared:object{OuronetInfoV1.ClientInfo} (patron:string sender:string receiver:string))
)
;;
(module INFO-ZERO GOV
    ;;
    (implements OuronetPolicyV1)
    (implements DalosInfoV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO-ZERO              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|INFO-ZERO_ADMIN)))
    (defcap GOV|INFO-ZERO_ADMIN ()          (enforce-guard GOV|MD_INFO-ZERO))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|INFO-ZERO|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|INFO-ZERO|CALLER))
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
        (with-capability (GOV|INFO-ZERO_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|INFO-ZERO_ADMIN)
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
                (mg:guard (create-capability-guard (P|INFO-ZERO|CALLER)))
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
    ;;
    ;;<======================>
    ;;[DALOS-INFO] Functions — pure presentation; cost/format vocabulary (OI|*) lives in IGNIS
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    (defun DALOS-INFO|URC_ControlSmartAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_ControlSmartAccount account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Execute Smart Account Control."]
                [(format "Smart Ouronet Account {} controlled succesfully" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_DeploySmartAccount:object{OuronetInfoV1.ClientInfo} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                (kfp:decimal (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Deploy a Smart Ouronet Account."]
                [(format "Smart Ouronet Account {} deployed succesfully" [sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (if is-stoa-zero (ref-I|OURONET::OI|UDC_NoStoaCosts) (ref-I|OURONET::OI|UDC_FullStoaCosts kfp))
                []
            )
        )
    )
    (defun DALOS-INFO|URC_DeployStandardAccount:object{OuronetInfoV1.ClientInfo} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                (kfp:decimal (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Deploy a Standard Ouronet Account."]
                [(format "Standard Ouronet Account {} deployed succesfully" [sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (if is-stoa-zero (ref-I|OURONET::OI|UDC_NoStoaCosts) (ref-I|OURONET::OI|UDC_FullStoaCosts kfp))
                []
            )
        )
    )
    (defun DALOS-INFO|URC_RotateGovernor:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateGovernor account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Governor-Guard of an Ouronet Account."]
                [(format "Ouronet Account {} Governor-Guard rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_RotateGuard:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateGuard account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Primary-Guard of an Ouronet Account."]
                [(format "Ouronet Account {} Primary-Guard rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_RotateStoa:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateStoa account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Attached STOA-Address of an Ouronet Account."]
                [(format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_RotateSovereign:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateSovereign account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Sovereign of a Smart Ouronet Account."]
                [(format "Smart Ouronet Account {} Sovereign rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_UpdateEliteAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Update Elite Account Data for a single Ouronet Account"]
                [(format "Elite Account Data for {} updated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun DALOS-INFO|URC_UpdateEliteAccountSquared:object{OuronetInfoV1.ClientInfo} (patron:string sender:string receiver:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)))
                (sa1:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa2:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Update Elite Account Data for a two Ouronet Accounts"]
                [(format "Elite Account Data for {} and {} updated succesfully!" [sa1 sa2])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)

(create-table P|T)
(create-table P|MT)
