;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface StoaLiquidStakingV2
    @doc "Exposes the functions needed for Stoa Liquid Staking, Wrap and Unwrap STOA \
        \ as well as their URSTOA Counterparts"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|LIQUID|SC_STOA-NAME ())
    (defun GOV|LIQUID|GUARD ())

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
    ;;  [UR]
    ;;
    (defun UR_IzOuronetAccountRegisteredForUrstoaHoldings:bool (ouronet-account:string))
    (defun URCi_UnwrapStoa:object{IgnisCollectorV2.OutputCumulator} (unwrapper:string amount:decimal))
    (defun URCi_WrapStoa:object{IgnisCollectorV2.OutputCumulator} (wrapper:string amount:decimal))
    (defun URCi_UnwrapUrStoa:object{IgnisCollectorV2.OutputCumulator} (unwrapper:string amount:decimal))
    (defun URCi_WrapUrStoa:object{IgnisCollectorV2.OutputCumulator} (wrapper:string amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_IzLiquidStakingLive ())
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string))
    ;;
    ;;  [C]
    ;;
    (defun C_UnwrapStoa:object{IgnisCollectorV2.OutputCumulator} (unwrapper:string amount:decimal))
    (defun C_WrapStoa:object{IgnisCollectorV2.OutputCumulator} (wrapper:string amount:decimal))
    ;;
    ;;#13H fix: C_RegisterOuronetAccountForUrstoaHoldings removed (2026-08-27) - it took a
    ;;caller-supplied <guard> for an arbitrary <ouronet-account> with no ownership check
    ;;(account-hijacking risk). Account creation for wrapping/unwrapping UrStoa is instead
    ;;handled by UI-constructed Pact code using the real signer's own (read-keyset "ks"), the
    ;;same established pattern already used for native Stoa unwrap - see
    ;;OuronetInformational/memories/2026-08-27-urstoa-account-creation-is-ui-constructed.md.
    (defun C_UnwrapUrStoa:object{IgnisCollectorV2.OutputCumulator} (unwrapper:string amount:decimal))
    (defun C_WrapUrStoa:object{IgnisCollectorV2.OutputCumulator} (wrapper:string amount:decimal))

)
;;
(module LIQUID GOV
    @doc "LIQUID — the Stoa liquid-staking core, implementing StoaLiquidStakingV2. It wraps \
        \ and unwraps native STOA into liquid-staking tokens and their URSTOA counterparts \
        \ (C_WrapStoa/C_UnwrapStoa and C_WrapUrStoa/C_UnwrapUrStoa, with matching URCi cost \
        \ readers), gated by a liquid-staking-live check, plus an A_MigrateLiquidFunds admin \
        \ migration path."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements StoaLiquidStakingV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_LIQUID                             (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_LIQUID                             (keyset-ref-guard LIQUID|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|LIQUID_ADMIN)))
    (defcap GOV|LIQUID_ADMIN ()
        (enforce-one
            "LIQUID Admin not satisfed"
            [
                (enforce-guard GOV|MD_LIQUID)
                (enforce-guard GOV|SC_LIQUID)
            ]
        )
    )
    (defcap GOV|MIGRATE (migration-target-stoa-account:string)
        @event
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (target-balance:decimal (ref-coin::get-balance migration-target-stoa-account))
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce gap (format "Migration can only be executed when Global Administrative Pause is offline"))
            (enforce (= target-balance 0.0) "Migration can only be executed to an empty stoa account")
            (compose-capability (GOV|LIQUID_ADMIN))
            (compose-capability (LIQUID|NATIVE-AUTOMATIC))
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LiquidKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|LiquidKey)
        )
    )
    (defun GOV|LIQUID|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|LIQUID|SC_NAME)
        )
    )
    (defun GOV|LIQUID|SC_STOA-NAME () (create-principal (GOV|LIQUID|GUARD)))
    (defun GOV|LIQUID|GUARD ()                          (create-capability-guard (LIQUID|NATIVE-AUTOMATIC)))

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
    (defcap P|LQD|CALLER ()
        true
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
        (with-capability (GOV|LIQUID_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|LIQUID_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (mg:guard (create-capability-guard (P|LQD|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst LIQUID|SC_KEY                             (GOV|LiquidKey))
    (defconst LIQUID|SC_NAME                            (GOV|LIQUID|SC_NAME))
    (defconst LIQUID|SC_STOA-NAME                       (GOV|LIQUID|SC_STOA-NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst LIQUID|INFO                               (CT_Info))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap LIQUID|GOV ()
        @doc "Governor Capability for the Liquid Smart DALOS Account"
        true
    )
    (defcap LIQUID|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of LIQUID Smart Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap LIQUID|C>WRAP (account:string)
        @doc "Capability needed to wrap STOA to Ouronet Wrapped Stoa"
        @event
        (compose-capability (LIQUID|C>X_WRAPPER account))
    )
    (defcap LIQUID|C>UNWRAP (account:string)
        @doc "Capability needed to unwrap STOA to Ouronet Wrapped Stoa"
        @event
        (compose-capability (LIQUID|CONVERTER))
        (compose-capability (LIQUID|NATIVE-AUTOMATIC))
    )
    (defcap LIQUID|C>UR-WRAP (account:string)
        @doc "Capability needed to wrap URSTOA to Ouronet Wrapped UrStoa"
        @event
        (compose-capability (LIQUID|C>X_WRAPPER account))
    )
    (defcap LIQUID|C>UR-UNWRAP (account:string)
        @doc "Capability needed to unwrap URSTOA to Ouronet Wrapped UrStoa"
        @event
        (compose-capability (LIQUID|CONVERTER))
        (compose-capability (LIQUID|NATIVE-AUTOMATIC))
    )
    (defcap LIQUID|CONVERTER ()
        (UEV_IzLiquidStakingLive)
        (compose-capability (LIQUID|CALLER))
    )
    (defcap LIQUID|CALLER ()
        (compose-capability (LIQUID|GOV))
        (compose-capability (P|LQD|CALLER))
    )
    (defcap LIQUID|C>X_WRAPPER (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (LIQUID|CONVERTER))
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
    (defun CT_Info ()                                   (at 0 ["LiquidInformation"]))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_IzOuronetAccountRegisteredForUrstoaHoldings:bool (ouronet-account:string)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa ouronet-account))
                (trial (try false (ref-ur-coin::UR_UR|Details stoa-patron)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URCi_UnwrapStoa:object{IgnisCollectorV2.OutputCumulator}
        (unwrapper:string amount:decimal)
        @doc "Cost preview for C_UnwrapStoa: unwrapper->LIQUID wrapped-STOA transfer + burn, \
            \ re-derived purely (the STOA fuel payout is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer w-stoa-id unwrapper lq-sc amount)
                    (ref-DPTF::URCi_Burn w-stoa-id lq-sc)
                ]
                []
            )
        )
    )
    (defun URCi_WrapStoa:object{IgnisCollectorV2.OutputCumulator}
        (wrapper:string amount:decimal)
        @doc "Cost preview for C_WrapStoa: mint wrapped-STOA on LIQUID + LIQUID->wrapper \
            \ transfer, re-derived purely (the STOA fuel intake is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPTF::URCi_Mint w-stoa-id lq-sc false)
                    (ref-TFT::URCi_Transfer w-stoa-id lq-sc wrapper amount)
                ]
                []
            )
        )
    )
    (defun URCi_UnwrapUrStoa:object{IgnisCollectorV2.OutputCumulator}
        (unwrapper:string amount:decimal)
        @doc "Cost preview for C_UnwrapUrStoa: unwrapper->LIQUID Ur-STOA transfer + burn, \
            \ re-derived purely (the Ur-STOA transmit payout is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer w-ur-stoa-id unwrapper lq-sc amount)
                    (ref-DPTF::URCi_Burn w-ur-stoa-id lq-sc)
                ]
                []
            )
        )
    )
    (defun URCi_WrapUrStoa:object{IgnisCollectorV2.OutputCumulator}
        (wrapper:string amount:decimal)
        @doc "Cost preview for C_WrapUrStoa: mint Ur-STOA on LIQUID + LIQUID->wrapper transfer, \
            \ re-derived purely (the Ur-STOA intake is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPTF::URCi_Mint w-ur-stoa-id lq-sc false)
                    (ref-TFT::URCi_Transfer w-ur-stoa-id lq-sc wrapper amount)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_IzLiquidStakingLive ()
        @doc "Enforces Liquid Staking is live with an existing Autostake Pair"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
                (l-stoa:string (ref-DALOS::UR_SilverStoaID))
            )
            (enforce (!= w-stoa BAR) "Wrapped-Stoa is not set")
            (enforce (!= l-stoa BAR) "Liquid-Stoa is not set")
            (let
                (
                    (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                    (l-stoa-as-rbt:[string] (ref-DPTF::UR_RewardBearingToken l-stoa))
                )
                (enforce (= (length w-stoa-as-rt) 1) "Wrapped-Stoa cannot ever be part of another ATS-Pair")
                (enforce (= (length l-stoa-as-rbt) 1) "Liquid-Stoa cannot ever be part of another ATS-Pair")
                (enforce (= (at 0 w-stoa-as-rt) (at 0 l-stoa-as-rbt)) "Wrapped and Liquid Stoa are not part of the same ASTS Pair")
            )
        )
    )
    (defun UEV_Amount (amount:decimal)
        @doc "Enforces amount to coin (Stoa) Precision, which uses 12 decimal"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
            )
            (enforce
                (= (floor amount stoa-prec) amount)
                (format "{} is not conform with STOA prec." [amount])
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string)
        (P|UEV_IMC)
        (with-capability (GOV|MIGRATE migration-target-stoa-account)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)    
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (lq-stoa:string LIQUID|SC_STOA-NAME)
                    (present-stoa-balance:decimal (ref-coin::get-balance lq-stoa))
                )
                (install-capability (ref-coin::TRANSFER lq-stoa migration-target-stoa-account present-stoa-balance))
                (ref-DALOS::C_TransferDalosFuel lq-stoa migration-target-stoa-account present-stoa-balance)
                present-stoa-balance
            )
        )
    )
    (defun C_UnwrapStoa:object{IgnisCollectorV2.OutputCumulator}
        (unwrapper:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa unwrapper))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (with-capability (LIQUID|C>UNWRAP unwrapper)
                (let
                    (
                        (output:object{IgnisCollectorV2.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-TFT::C_Transfer w-stoa-id unwrapper lq-sc amount true)
                                    (ref-DPTF::C_Burn w-stoa-id lq-sc amount)
                                ]
                                []
                            )
                            
                        )
                    )
                    ;;(install-capability (ref-coin::TRANSFER lq-stoa stoa-patron amount))
                    ;;Capability is added instead in the JavaCode
                    (ref-IGNIS::C_TransferDalosFuel lq-stoa stoa-patron amount)
                    output
                )
            )
        )
    )
    (defun C_WrapStoa:object{IgnisCollectorV2.OutputCumulator}
        (wrapper:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa wrapper))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (with-capability (LIQUID|C>WRAP wrapper)
                (let
                    (
                        (output:object{IgnisCollectorV2.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-DPTF::C_Mint w-stoa-id lq-sc amount false)
                                    (ref-TFT::C_Transfer w-stoa-id lq-sc wrapper amount true)
                                ]
                                []
                            )
                        )
                    )
                    (ref-IGNIS::C_TransferDalosFuel stoa-patron lq-stoa amount)
                    output
                )
            )
        )
    )
    (defun C_UnwrapUrStoa:object{IgnisCollectorV2.OutputCumulator}
        (unwrapper:string amount:decimal)
        @doc "Unwrapper is the Ouronet Account doing the Unwrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md)."
        (P|UEV_IMC)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa unwrapper))
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (with-capability (LIQUID|C>UR-UNWRAP unwrapper)
                (let
                    (
                        (output:object{IgnisCollectorV2.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-TFT::C_Transfer w-ur-stoa-id unwrapper lq-sc amount true)
                                    (ref-DPTF::C_Burn w-ur-stoa-id lq-sc amount)
                                ]
                                []
                            )
                            
                        )
                    )
                    ;;(install-capability (ref-ur-coin::UR|TRANSFER lq-stoa stoa-patron amount))
                    ;;Capability is added instead in the JavaCode - NOT NEEDED because TRANSMIT is used.
                    (ref-ur-coin::C_UR|Transmit lq-stoa stoa-patron amount)
                    output
                )
            )
        )
    )
    (defun C_WrapUrStoa:object{IgnisCollectorV2.OutputCumulator}
        (wrapper:string amount:decimal)
        @doc "Wrapper is the Ouronet Account doing the Wrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md)."
        (P|UEV_IMC)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa wrapper))
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (with-capability (LIQUID|C>UR-WRAP wrapper)
                (let
                    (
                        (output:object{IgnisCollectorV2.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-DPTF::C_Mint w-ur-stoa-id lq-sc amount false)
                                    (ref-TFT::C_Transfer w-ur-stoa-id lq-sc wrapper amount true)
                                ]
                                []
                            )
                        )
                    )
                    (ref-ur-coin::C_UR|Transfer stoa-patron lq-stoa amount)
                    output
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)