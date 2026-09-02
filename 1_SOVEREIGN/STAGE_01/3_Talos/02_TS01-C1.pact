;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
(interface TalosStageOne_ClientOneV1
    @doc "Exposes Ouronets Stage One First Batch of Client Functions \
        \ Modules: DALOS, DPTF and DPOF are included in the First Batch"
    ;;
    ;;DALOS Functions
    (defun C_DALOS|ControlSmartAccount (patron:string account:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool))
    (defun C_DALOS|DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string))
    (defun C_DALOS|DeployStandardAccount (account:string guard:guard stoa:string public:string))
    (defun C_DALOS|RotateGovernor (patron:string account:string governor:guard))
    (defun C_DALOS|RotateGuard (patron:string account:string new-guard:guard safe:bool))
    (defun C_DALOS|RotateStoa (patron:string account:string stoa:string))
    (defun C_DALOS|RotateSovereign (patron:string account:string new-sovereign:string))
    (defun C_DALOS|UpdateEliteAccount (patron:string account:string))
    (defun C_DALOS|UpdateEliteAccountSquared (patron:string sender:string receiver:string))
    ;;
    ;;
    ;;DPTF (Demiourgos Pact True Fungible) Functions
    (defun C_DPTF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_DPTF|UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    (defun C_DPTF|Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun C_DPTF|RotateOwnership (patron:string id:string new-owner:string))
    (defun C_DPTF|Control (patron:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun C_DPTF|TogglePause (patron:string id:string toggle:bool))
    (defun C_DPTF|ToggleReservation (patron:string id:string toggle:bool))
        ;;
    (defun C_DPTF|ToggleFee (patron:string id:string toggle:bool))
    (defun C_DPTF|SetMinMove (patron:string id:string min-move-value:decimal))
    (defun C_DPTF|SetFee (patron:string id:string fee:decimal))
    (defun C_DPTF|SetFeeTarget (patron:string id:string target:string))
    (defun C_DPTF|DonateFees (patron:string id:string))
    (defun C_DPTF|ResetFeeTarget (patron:string id:string))
    (defun C_DPTF|ToggleFeeLock (patron:string id:string toggle:bool))
        ;;
    (defun C_DPTF|DeployAccount (patron:string id:string account:string))
    (defun C_DPTF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun C_DPTF|ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun C_DPTF|ToggleMintRole (patron:string id:string account:string toggle:bool))
    (defun C_DPTF|ToggleFeeExemptionRole (patron:string id:string account:string toggle:bool))
    (defun C_DPTF|ToggleTransferRole (patron:string id:string account:string toggle:bool))
        ;;
    (defun C_DPTF|ClearDispo (patron:string account:string))
    (defun C_DPTF|Burn (patron:string id:string account:string amount:decimal))
    (defun C_DPTF|Mint (patron:string id:string account:string amount:decimal origin:bool))
    (defun C_DPTF|WipeSlim (patron:string id:string atbw:string amtbw:decimal))
    (defun C_DPTF|Wipe (patron:string id:string atbw:string))
        ;;
    (defun C_DPTF|Transmute (patron:string id:string transmuter:string transmute-amount:decimal))
    (defun C_DPTF|Transfer (patron:string id:string sender:string receiver:string transfer-amount:decimal method:bool))
    (defun C_DPTF|MultiTransfer (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool))
    (defun C_DPTF|BulkTransfer (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun C_DPTF|MultiBulkTransfer (patron:string id:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    ;;
    ;;
    ;;DPOF (Demiourgos Pact Orto Fungible) Functions
    (defun C_DPOF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_DPOF|UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    (defun C_DPOF|Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun C_DPOF|RotateOwnership (patron:string id:string new-owner:string))
    (defun C_DPOF|Control (patron:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun C_DPOF|TogglePause (patron:string id:string toggle:bool))
        ;;
    (defun C_DPOF|DeployAccount (patron:string id:string account:string))
    (defun C_DPOF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun C_DPOF|ToggleAddQuantityRole (patron:string id:string account:string toggle:bool))
    (defun C_DPOF|ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun C_DPOF|MoveCreateRole (patron:string id:string receiver:string))
    (defun C_DPOF|ToggleTransferRole (patron:string id:string account:string toggle:bool))
        ;;
    (defun C_DPOF|AddQuantity (patron:string id:string account:string nonce:integer amount:decimal))
    (defun C_DPOF|Burn (patron:string id:string account:string nonce:integer amount:decimal))
    (defun C_DPOF|Mint (patron:string id:string account:string amount:decimal meta-data-chain:[object]))
    (defun C_DPOF|WipeSlim (patron:string id:string account:string nonce:integer amount:decimal))
    (defun C_DPOF|WipeHeavy (patron:string id:string account:string))
    (defun C_DPOF|WipePure (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV1.RemovableNonces}))
    (defun C_DPOF|WipeClean (patron:string id:string account:string nonces:[integer]))
        ;;
    (defun C_DPOF|Transmit (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool))
    (defun C_DPOF|Transfer (patron:string id:string nonces:[integer] sender:string receiver:string method:bool))    
    ;;
)
;;
(interface TalosStageOne_ClientOneV2
    @doc "Additive Talos Stage One Client One surface — opt-in per consumer; does not replace TalosStageOne_ClientOneV1."
    (defun C_DPOF|BulkTransfer
        (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
    )
)
;;
(module TS01-C1 GOV
    @doc "TALOS Stage 1 Client Functiones Part 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageOne_ClientOneV1)
    (implements TalosStageOne_ClientOneV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C1        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                  (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()    (enforce-guard GOV|MD_TS01-C1))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
        true
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-C1_ADMIN)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|ELITE:module{OuronetPolicyV1} ELITE)
                (ref-P|ATS:module{OuronetPolicyV1} ATS)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|DALOS::A_P|AddIMP mg)
            (ref-P|IGNIS::A_P|AddIMP mg)
            (ref-P|DPTF::A_P|AddIMP mg)
            (ref-P|DPOF::A_P|AddIMP mg)
            (ref-P|ELITE::A_P|AddIMP mg)
            (ref-P|ATS::A_P|AddIMP mg)
            (ref-P|TFT::A_P|AddIMP mg)
            (ref-P|TS01-A::A_P|AddIMP mg)
        )
    )
    ;;
    ;;
    ;;  [DALOS_Client]
    (defun C_DALOS|ControlSmartAccount (patron:string account:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        @doc "Controls Smart Ouronet Account properties via boolean triggers"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::C_ControlSmartAccount account payable-as-smart-contract payable-by-smart-contract payable-by-method)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_ControlSmartAccount account))
                (format "Smart Ouronet Account {} controlled succesfully" [account])
            )
        )
    )
    (defun C_DALOS|DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-DALOS::C_DeploySmartAccount account guard stoa sovereign public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::C_STOA|Collect account (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Smart Ouronet Account {} deployed succesfully" [account])
            )
        )
    )
    (defun C_DALOS|DeployStandardAccount (account:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-DALOS::C_DeployStandardAccount account guard stoa public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::C_STOA|Collect account (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Standard Ouronet Account {} deployed succesfully" [account])
            )
        )
    )
    (defun C_DALOS|RotateGovernor (patron:string account:string governor:guard)
        @doc "Rotates the governor of a Smart Ouronet Account \
        \ The Governor acts as a governing entity for the Smart Ouronet Account allowing fine control of its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::C_RotateGovernor account governor)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateGovernor account))
                (format "Ouronet Account {} Governor-Guard rotated succesfully!" [account])
            )
        )
    )
    (defun C_DALOS|RotateGuard (patron:string account:string new-guard:guard safe:bool)
        @doc "Rotates the guard of an Ouronet Safe. Boolean <safe> also enforces the <new-guard>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::C_RotateGuard account new-guard safe)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateGuard account))
                (format "Ouronet Account {} Primary-Guard rotated succesfully!" [account])
            )
        )
    )
    (defun C_DALOS|RotateStoa (patron:string account:string stoa:string)
        @doc "Rotates the STOA Account attached to an Ouronet Account. \
        \ The attached STOA Account is the account that makes STOA Payments for specific Ouronet Actions"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::C_RotateStoa account stoa)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateStoa account))
                (format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [account])
            )
        )
    )
    (defun C_DALOS|RotateSovereign (patron:string account:string new-sovereign:string)
        @doc "Rotates the Sovereign of a Smart Ouronet Account \
        \ The Sovereign of a Smart Ouronet Account acts as its owner, allowing dominion over its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::C_RotateSovereign account new-sovereign)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateSovereign account))
                (format "Smart Ouronet Account {} Sovereign rotated succesfully!" [account])
            )
        )
    )
    (defun C_DALOS|UpdateEliteAccount (patron:string account:string)
        @doc "Manualy Updates the Demiourgos Elite Account for one Ouronet Account in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-ELITE:module{EliteV1} ELITE)
                    (ea-id:string (ref-DALOS::EliteAurynID))
                )
                (ref-ELITE::XE_UpdateEliteSingle ea-id account)
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)
                )
                (format "Elite Account Data for {} updated succesfully!" [account])
            )
        )
    )
    (defun C_DALOS|UpdateEliteAccountSquared (patron:string sender:string receiver:string)
        @doc "Manualy Updates the Demiourgos Elite Account for two Ouronet Accounts in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-ELITE:module{EliteV1} ELITE)
                    (ea-id:string (ref-DALOS::EliteAurynID))
                )
                (ref-ELITE::XE_UpdateElite ea-id sender receiver)
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)
                )
                (format "Elite Account Data for {} and {} updated succesfully!" [sender receiver])
            )
        )
    )
    ;;  [DPTF_Client]
    (defun C_DPTF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}])
        @doc "Updates <pending-branding> for DPTF Token <entity-id> costing 100 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-B|DPTF:module{BrandingUsagePrimaryV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|DPTF::C_UpdatePendingBranding entity-id logo description website social)
                )
                (format "Pending Branding for DPTF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun C_DPTF|UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPTF Token, making it a premium BrandingV1. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPTF:module{BrandingUsagePrimaryV1} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-B|DPTF::C_UpgradeBranding patron entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun C_DPTF|Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Issues a new DPTF Token in Bulk, can also be used to issue a single DPTF \
        \ Outputs a string list with the issed DPTF IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-DPTF::C_Issue patron account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun C_DPTF|RotateOwnership (patron:string id:string new-owner:string)
        @doc "Rotates DPTF ID Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_RotateOwnership id new-owner)
                )
                (format "ID {} Ownership succesfully set to {}" [id sa])
            )
        )
    )
    (defun C_DPTF|Control (patron:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        @doc "Controls the properties of a DPTF Token \
            \ <can-change-owner> <can-upgrade> <can-add-special-role> <can-freeze> <can-wipe> <can-pause>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Control id cu cco casr cf cw cp)
                )
                (format "Succesfully controlled Properties of {}" [id])
            )
        )
    )
    (defun C_DPTF|TogglePause (patron:string id:string toggle:bool)
        @doc "Toggles Pause for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_TogglePause id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    (defun C_DPTF|ToggleReservation (patron:string id:string toggle:bool)
        @doc "Toggles Reservations for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleReservation id toggle)
                )
                (if toggle
                    (format "Reservations succesfully opened for {}" [id])
                    (format "Reservations succesfully closed for {}" [id])
                )
            )
        )
    )
    ;;
    (defun C_DPTF|ToggleFee (patron:string id:string toggle:bool)
        @doc "Toggles Fee collection for a DPTF Token. When a DPTF Token is setup with a transfer fee, \
            \ it will come in effect only when the toggle is on(true)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFee id toggle)
                )
                (if toggle
                    (format "Fee Collection activated succesfully for {}" [id])
                    (format "Fee Collection deactivated succesfully for {}" [id])
                )
            )
        )
    )
    (defun C_DPTF|SetMinMove (patron:string id:string min-move-value:decimal)
        @doc "Sets the minimum amount needed to transfer a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetMinMove id min-move-value)
                )
                (format "MinMove Value succesfully set for {} to {}" [id min-move-value])
            )
        )
    )
    (defun C_DPTF|SetFee (patron:string id:string fee:decimal)
        @doc "Sets a transfer fee for the DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFee id fee)
                )
                (format "Fee Promille succesfully set to {} Promille for {}" [fee id])
            )
        )
    )
    (defun C_DPTF|SetFeeTarget (patron:string id:string target:string)
        @doc "Sets the Fee Collection Target for a DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id target)
                )
                (format "Fee Target succesfully set for {} to {}" [id sa])
            )
        )
    )
    (defun C_DPTF|DonateFees (patron:string id:string)
        @doc "Sets the Fee Collection target to the DALOS|SC_NAME \
        \ When DPTF Fees collect here, the will be earned by Ouronet Custodians"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id (ref-DALOS::GOV|DALOS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun C_DPTF|ResetFeeTarget (patron:string id:string)
        @doc "Sets the Fee Collection target to the OUROBOROS|SC_NAME \
        \ Fees can then be collected by <DPTF|C_WithdrawFees>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun C_DPTF|ToggleFeeLock (patron:string id:string toggle:bool)
        @doc "Toggles DPTF Fee Settings Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-DPTF::C_ToggleFeeLock patron id toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (if toggle
                    (format "Fee Settings succesfully locked for {}" [id])
                    (format "Fee Settings succesfully unlocked  for {}" [id])
                )
            )
        )
    )
    ;;
    (defun C_DPTF|DeployAccount (patron:string id:string account:string)
        @doc "Deploys a DPTF Account. Self-service activation only - the caller must own \
            \ <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure account \
            \ setup (a smart account governed by another module) must use the admin variant \
            \ A_DPTF|DeployAccount in TS01-A instead."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPTF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::URCi_DeployAccount account)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])
            )
        )
    )
    (defun C_DPTF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        @doc "Toggles Freezing of a DPTF Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFreezeAccount id account toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun C_DPTF|ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <burn-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleBurnRole id account toggle)
                )
            )
        )
    )
    (defun C_DPTF|ToggleMintRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <mint-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleMintRole id account toggle)
                )
            )
        )
    )
    (defun C_DPTF|ToggleFeeExemptionRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <fee-exemption-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFeeExemptionRole id account toggle)
                )
            )
        )
    )
    (defun C_DPTF|ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <transfer-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleTransferRole id account toggle)
                )
                (if toggle
                    (format "Transfer Role succesfuly added for {} to {}" [id sa])
                    (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                )
            )
        )
    )
    ;;
    (defun C_DPTF|ClearDispo (patron:string account:string)
        @doc "Clears OURO Dispo by levereging existing Elite-Auryn"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_ClearDispo account)
                )
            )
        )
    )
    (defun C_DPTF|Burn (patron:string id:string account:string amount:decimal)
        @doc "Burns a DPTF Token from an account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Burn id account amount)
                )
                (format "Succesfully burned {} {} on Account {}" [amount id sa])
            )
        )
    )
    (defun C_DPTF|Mint (patron:string id:string account:string amount:decimal origin:bool)
        @doc "Mints a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Mint id account amount origin)
                )
                (if origin
                    (format "Succesfully premined {} {} on Account {}" [amount id sa])
                    (format "Succesfully minted {} {} on Account {}" [amount id sa])
                )
            )
        )
    )
    (defun C_DPTF|WipeSlim (patron:string id:string atbw:string amtbw:decimal)
        @doc "Similar to <C_DPTF|Wipe>, but doesnt wipe the whole existing amount"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-ELITE:module{EliteV1} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_WipeSlim id atbw amtbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id atbw)
                (format "Succesfully wiped {} {} from account {}" [amtbw id sa])
            )
        )
    )
    (defun C_DPTF|Wipe (patron:string id:string atbw:string)
        @doc "Wipes a DPTF Token from a given account in its entirety \
        \ Only works for positive existing amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-ELITE:module{EliteV1} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Wipe id atbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id atbw)
                (format "Succesfully wiped all {} from account {}" [id sa])
            )
        )
    )
    ;;
    (defun C_DPTF|Transmute (patron:string id:string transmuter:string transmute-amount:decimal)
        @doc "Transmutes a DPTF Token. Transmuting Uses the whole amount as it if were Primary Fee \
        \ without adding to the Primary Fee Counter. \
        \ Thus it can either be collected to the Fee Target Collector \
        \ or to increase Autostake Indices, if the Id is part of any Autostake Pools \
        \ (and these have the neccesary setting set up in the  required manner) \
        \ Only works for DPTFs that have been setup up with transfer fees. \
        \ One of 3 Variants is automatically chosen for transmutation \
        \   Simple  >> For DPTFs that are not Elite Auryn Class \
        \   Elite   >> For Elite Auryn Class DPTFs that require Elite Account Update"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_Transmute id transmuter transmute-amount)
                )
            )
        )
    )
    (defun C_DPTF|Transfer (patron:string id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @doc "Transfers a DPTF Token from <sender> to <receiver>, using the <transfer-amount> and <method> \
        \ It autonomously choose between the 6 Transfer Variants spread over 3 Classes. \
        \ \
        \   Class 1 >> 1 IGNIS Cost \
        \           [CX_Class1Transfer]             Transfers a DPTF with no transfer Fees (also for VTT amounts < 10.0) \
        \           [CX_Class1TransferUnity]        Transfers UNITY with no transfer Fees (amount < 10.0) \
        \   Class 2 >> 2 IGNIS Cost \
        \           [CX_Class2Transfer]             Transfer a DPTF with a transfer Fee \
        \           [CX_Class2TransferUnity]        Transfers Unity with transfer Fee \
        \           [CX_Class2TransferElite]        Transfers EA Class DPTFs with no Fees \
        \   Class 3 >> 3 IGNIS Cost \
        \           [CX_Class3TransferElite]        Transfers EA Class DPTFs with transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id sender receiver transfer-amount))
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_Transfer id sender receiver transfer-amount method)
                )
                (if (= receiver-amount transfer-amount)
                    (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                    (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                )
            )
        )
    )
    (defun C_DPTF|MultiTransfer (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        @doc "Transfers Multiple DPTF Tokens from one sender to another, each token having its own amount specified \
        \ Receiver, as it is only one, can also be a Smart Ouronet Account \
        \ 150k Gas can support between 10 and 20 Transfers, depending on DPTF Token (Simple, Complex, Elite, Unity)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiTransfer id-lst sender receiver transfer-amount-lst method)
                )
                (format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])
            )
        )
    )
    (defun C_DPTF|BulkTransfer (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @doc "Transfers a DPTF in Bulk, from 1 sender to multiple receivers, each with its own amount \
        \ Because <receivers> cannot be Smart Ouronet Accounts, no <method> parameter is needed \
        \ When the Token <id> is set up with a Transfer Fee, and its receiver is on the receiver list, \
        \ it is not exempted from the transfer fee, as is normally the case \
        \ \
        \ It autonomously choose between the 6 Transfer Variants spread over 4 Classes. \
        \ \
        \   Class 0 >> VTT (Volumetric Transfer Tax) Class: (1xL IGNIS or Variable IGNIS Cost for UNITY)\
        \           [CX_Class0BulkTransfer]         Bulk Transfers DPTFs with VTT \
        \           [CX_Class0BulkTransferUnity]    Bulk Transfers UNITY, which also has VTT \
        \   Class 1 >> 1xL IGNIS Cost \
        \           [CX_Class1BulkTransfer]         Bulk Transfers DPTFs with no transfer Fees \
        \   Class 2 >> 2xL IGNIS Cost \
        \           [CX_Class2BulkTransfer]         Bulk Transfers DPTFs with transfer Fees \
        \           [CX_Class2BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with no Transfer Fees \
        \   Class 3 >> 3xL IGNIS Cost \
        \           [CX_Class3BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with Transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiBulkTransfer [id] sender [receiver-lst] [transfer-amount-lst])
                )
                (format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length receiver-lst)])
            )
        )
    )
    (defun C_DPTF|MultiBulkTransfer (patron:string id:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        @doc "Executes Multiple Bulk Transfers in a single Function"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiBulkTransfer id sender receiver-array transfer-amount-array)
                )
                (format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id) sa-s (length receiver-array)])
            )
        )
    )
    ;;  [DPOF_Client]
    (defun C_DPOF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}])
        @doc "Updates <pending-branding> for DPOF Token <entity-id> costing 150 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-B|DPOF:module{BrandingUsagePrimaryV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|DPOF::C_UpdatePendingBranding entity-id logo description website social)
                )
                (format "Pending Branding for DPOF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun C_DPOF|UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPOF:module{BrandingUsagePrimaryV1} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-B|DPOF::C_UpgradeBranding patron entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun C_DPOF|Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-DPOF::C_Issue patron account name ticker decimals can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun C_DPOF|RotateOwnership (patron:string id:string new-owner:string)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_RotateOwnership id new-owner)
                )
            )
        )
    )
    (defun C_DPOF|Control (patron:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        @doc "Similar to its DPTF Variant, has an extra boolean trigger for <can-transfer-nft-create-role>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Control id cu cco casr ctocr cf cw cp sg)
                )
                (format "Succesfully controlled DPOF {} Boolean Properties" [id])
            )
        )
    )
    (defun C_DPOF|TogglePause (patron:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_TogglePause id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    ;;
    (defun C_DPOF|DeployAccount (patron:string id:string account:string)
        @doc "Similar to its DPTF Variant. Self-service activation only - the caller must \
            \ own <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure \
            \ account setup (a smart account governed by another module) must use the \
            \ admin variant A_DPOF|DeployAccount in TS01-A instead."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPOF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::URCi_DeployAccount account)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])
            )
        )
    )
    (defun C_DPOF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleFreezeAccount id account toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun C_DPOF|ToggleAddQuantityRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <add-quantity-role> for a DPMF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleAddQuantityRole id account toggle)
                )
            )
        )
    )
    (defun C_DPOF|ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <burn-role> for a DPMF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleBurnRole id account toggle)
                )
            )
        )
    )
    (defun C_DPOF|MoveCreateRole (patron:string id:string receiver:string)
        @doc "Moves <create-role> for a DPMF Token <id> to <receiver> \
        \ Only a single account may have this role"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_MoveCreateRole id receiver)
                )
            )
        )
    )
    (defun C_DPOF|ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleTransferRole id account toggle)
                )
            )
        )
    )
    ;;
    (defun C_DPOF|AddQuantity (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_AddQuantity id account nonce amount)
                )
                (format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])
            )
        )
    )
    (defun C_DPOF|Burn (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Burn id account nonce amount)
                )
                (format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])
            )
        )
    )
    (defun C_DPOF|Mint (patron:string id:string account:string amount:decimal meta-data-chain:[object])
        @doc "Mints a DPOF Token, creating it and adding quantity to it \
        \ Outputs the nonce of the created DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (with-capability (P|TS)
                            (ref-DPOF::C_Mint id account amount meta-data-chain)
                        )
                    )
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format "Succesfully minted {} {} on Account {}, on the new Nonce {}" [amount id sa (at 0 (at "output" ico))])
            )
        )
    )
    (defun C_DPOF|WipeSlim (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <account> by <amount> \
            \ Amount may be lower or equal to the nonce amount. \
            \ Requires <id> has <segmentation> set to true"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipeSlim id account nonce amount)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun C_DPOF|WipeHeavy (patron:string id:string account:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <account> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipeHeavy id account)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun C_DPOF|WipePure (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV1.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <account>, presented via an <removable-nonces-obj> object \
        \ \
        \ The object must be pre-read (dirty read) \
        \ \
        \ Example to retrieve the <removable-nonces-obj> \
        \ <(URHC_WipePure account id)> ; to get the whole object \
        \ <(UC_TakePureWipe (URHC_WipePure account id) 165)> ; to get only the first 165 units \
        \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipePure id account removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun C_DPOF|WipeClean (patron:string id:string account:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipeClean id account nonces)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    ;;
    (defun C_DPOF|Transmit (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by a specific <amount> \
            \ This debits the <sender> nonces by <amount> and creates new nonces on receiver of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Transmit id nonces amounts sender receiver method)
                )
                (ref-ELITE::XE_UpdateElite id sender receiver)
                (format "Succesfuly Transmited DPOF {} Nonces {} with Amounts {} from Sender {} to Receiver {}"
                    [id nonces amounts ss sr]
                )
            )
        )
    )
    (defun C_DPOF|Transfer (patron:string id:string nonces:[integer] sender:string receiver:string method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by changing their Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Transfer id nonces sender receiver method)
                )
                (ref-ELITE::XE_UpdateElite id sender receiver)
                (format "Succesfuly Transmited DPOF {} Nonces {} from Sender {} to Receiver {}"
                    [id nonces ss sr]
                )
            )
        )
    )
    (defun C_DPOF|BulkTransfer
        (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk whole-nonce DPOF transfer — one sender, many standard-account receivers (TalosStageOne_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV1} ELITE)
                    ;;
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (l:integer (length receiver-lst))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_BulkTransfer id nonces-array sender receiver-lst method)
                )
                (map
                    (lambda (idx:integer)
                        (ref-ELITE::XE_UpdateElite id sender (at idx receiver-lst))
                    )
                    (enumerate 0 (- l 1))
                )
                (format "Succesfully bulk-transferred DPOF {} from {} to {} receivers"
                    [id sa-s l]
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)