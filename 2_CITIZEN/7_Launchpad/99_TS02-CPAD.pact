;; Deploy: load THIS file — interface(s) + module ship together. LAST module of the
;; launchpad: the CITIZEN Talos. Deployed AFTER the citizen sales (Spark..StoicIco)
;; and after the sovereign launchpad Talos (1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact).
;;
;; Holds ALL citizen user wrappers in one place so they can be granted free gas-station
;; access. The kicker: the citizen C_ funcs stay callable directly from their own module,
;; but ONLY these Talos wrappers are the gas-funded path — a direct citizen-module call
;; would not have its gas paid.
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface CitizenLaunchpadTalosV2
    @doc "Exposes the Ouronet Stage Two CITIZEN launchpad user Client Functions (sole gas-funded path)."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_SPARK|BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal))
    (defun C_SPARK|RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string))
    (defun C_SPARK|RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun C_SNAKES|Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))
    (defun C_CUSTODIANS|Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))
    (defun C_KPAY|BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal))
    (defun C_STOAICO|Collect (patron:string account:string))

)
;;
(module TS02-CPAD GOV
    @doc "TALOS Stage 2 CITIZEN Launchpad User Functions (Spark/Snakes/Custodians/StoicPay/StoicIco)"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements CitizenLaunchpadTalosV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-CPAD                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-CPAD_ADMIN)))
    (defcap GOV|TS02-CPAD_ADMIN ()                      (enforce-guard GOV|MD_TS02-CPAD))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                             (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun P|Info ()                                    (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::P|Info)))
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
        (with-capability (GOV|TS02-CPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS02-CPAD_ADMIN)
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
        @doc "Registers THIS citizen Talos' summoner guard as a trusted IMP peer of the per-sale \
            \ citizen modules it wraps (Spark/Snakes/Custodians/StoicPay/StoicIco), so their P|UEV_IMC \
            \ recognizes calls from this Talos."
        (let
            (
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|SPARK:module{OuronetPolicyV2} DEMIPAD-SPARK)
                (ref-P|SNAKES:module{OuronetPolicyV2} DEMIPAD-SNAKES)
                (ref-P|CUSTODIANS:module{OuronetPolicyV2} DEMIPAD-CUSTODIANS)
                (ref-P|KPAY:module{OuronetPolicyV2} DEMIPAD-STOICPAY)
                (ref-P|STOAICO:module{OuronetPolicyV2} STOAICO)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            ;;register into the sale modules (their P|UEV_IMC recognizes this Talos)
            (ref-P|SPARK::P|A_AddIMP mg)
            (ref-P|SNAKES::P|A_AddIMP mg)
            (ref-P|CUSTODIANS::P|A_AddIMP mg)
            (ref-P|KPAY::P|A_AddIMP mg)
            (ref-P|STOAICO::P|A_AddIMP mg)
            ;;register into TS01-A so the wrappers' XB_DynamicFuelSTOA gas-station refuel passes P|UEV_IMC
            (ref-P|TS01-A::P|A_AddIMP mg)
        )
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
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_SPARK|BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Pass a sentinel < 0 for slippage \
            \ off (Variant 2, live price via install-capability, UI-warned)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_BuySparks patron buyer sparks-amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun C_SPARK|RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_RedemAllSparks patron redemption-payer account-to-redeem)
            )
        )
    )
    (defun C_SPARK|RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_RedemFewSparks patron redemption-payer account-to-redeem redemption-quantity)
            )
        )
    )
    ;;
    (defun C_SNAKES|Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-SNAKES:module{SaleSnakesV2} DEMIPAD-SNAKES)
                )
                (ref-SNAKES::C_Acquire patron buyer nonce amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun C_CUSTODIANS|Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-CUSTODIANS:module{SaleCustodiansV2} DEMIPAD-CUSTODIANS)
                )
                (ref-CUSTODIANS::C_Acquire patron buyer nonce amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun C_KPAY|BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-KPAY:module{StoicPayV3} DEMIPAD-STOICPAY)
                    (acquisition-text:string (ref-KPAY::C_BuyStoicPay patron buyer kpay-amount iz-native max-cost))
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                acquisition-text
            )
        )
    )
    (defun C_STOAICO|Collect (patron:string account:string)
        @doc "Gas-funded entry for the StoicIco reward self-collect. No STOA inflow (it is a payout), so \
            \ no XB_DynamicFuelSTOA refuel. Cost preview: STOAICO.URCi_Collect / STOAICO.INFO_Collect."
        (with-capability (P|TS)
            (STOAICO.C_Collect patron account)
        )
    )

)

(create-table P|T)
(create-table P|MT)
