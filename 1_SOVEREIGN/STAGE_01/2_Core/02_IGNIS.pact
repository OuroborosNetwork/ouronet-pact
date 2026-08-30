
(module IGNIS GOV
    ;;
    (implements OuronetPolicyV1)
    (implements IgnisCollectorV1)
    (implements IgnisCollectorV2)
    (implements OuronetInfoV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_IGNIS                  (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|IGNIS_ADMIN)))
    (defcap GOV|IGNIS_ADMIN ()              (enforce-guard GOV|MD_IGNIS))
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
    (defcap P|IGNIS|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|IGNIS|CALLER))
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
        (with-capability (GOV|IGNIS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|IGNIS_ADMIN)
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
                (mg:guard (create-capability-guard (P|IGNIS|CALLER)))
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
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                           (CT_Bar))
    (defun CT_KdaPrec ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_KDA_PRECISION)))
    (defconst KDAPREC                       (CT_KdaPrec))
    ;;
    (defconst DALOS|SC_NAME                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|DALOS|SC_NAME)))
    (defconst OUROBOROS|SC_NAME             (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
    (defconst GAS_QUARTER 0.25)
    (defconst GAS_EXCEPTION
        [
            DALOS|SC_NAME
            OUROBOROS|SC_NAME
        ]
    )
    (defun DALOS|EmptyOutputCumulatorV2:object{IgnisCollectorV1.OutputCumulator} ()
        {"cumulator-chain"      :
            [
                {"ignis"        : 0.0
                ,"interactor"   : BAR}
            ]
        ,"output"               : []}
    )
    (defconst EMPTY_CC
        [
            {
                "ignis-prices" : [],
                "interactors" : []
            }
        ]
    )
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap IGNIS|S>DISCOUNT (patron:string idp:string)
        @event
        true
    )
    (defcap IGNIS|S>FREE ()
        @event
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap IGNIS|C>DC (patron:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (compose-capability (IGNIS|S>DISCOUNT patron (UDC_MakeIDP (ref-DALOS::URC_IgnisGasDiscount patron))))
            (compose-capability (P|IGNIS|CALLER))
        )
    )
    (defcap IGNIS|C>COLLECT (patron:string interactor:string amount:decimal)
        @event
        (UEV_Patron patron)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (first:string (take 1 interactor))
                (sigma:string "Σ")
                (tanker:string (ref-DALOS::UR_Tanker))
            )
            (enforce-one
                "Invalid Interactor"
                [
                    (enforce (= interactor BAR) "Interactor is invalid")
                    (enforce (= first sigma) "Invalid Smart Account as interactor")
                ]
            )
            (if (= interactor BAR)
                (compose-capability (IGNIS|C>TRANSFER patron tanker amount))
                (compose-capability (IGNIS|C>TRANSFER patron interactor amount))
            )
            (compose-capability (P|IGNIS|CALLER))
        )
    )
    (defcap IGNIS|C>TRANSFER (sender:string receiver:string ta:decimal)
        (enforce (!= sender receiver) "Sender and Receiver must be different")
        (UEV_TwentyFourPrecision ta)
        (enforce (> ta 0.0) "Cannot debit|credit 0.0 or negative GAS amounts")
        (compose-capability (IGNIS|C>DEBIT sender ta))
        (compose-capability (IGNIS|C>CREDIT receiver))
    )
    (defcap IGNIS|C>DEBIT (sender:string ta:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (read-gas:decimal (ref-DALOS::UR_TF_AccountSupply sender false))
            )
            (enforce (<= ta read-gas) "Insufficient GAS for GAS-Debiting")
            (ref-DALOS::UEV_EnforceAccountExists sender)
            (ref-DALOS::UEV_EnforceAccountType sender false)
            (compose-capability (SECURE))
        )
    )
    (defcap IGNIS|C>CREDIT (receiver:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists receiver)
            (compose-capability (SECURE))
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_FindKeyIndex:integer (key-lst:[string] key:string)
        @doc "First index of key in key-lst, or -1 if absent. Single linear scan, local to the \
            \ compress/prime pipeline below (UDC_CompressOutputCumulator/UDC_PrimeIgnisCumulator) \
            \ only — NOT a general-purpose replacement for U|LST::UC_Search, whose documented \
            \ contract (return every matching index) is different and untouched by this helper."
        (if (= (length key-lst) 0)
            -1
            (fold
                (lambda
                    (found:integer idx:integer)
                    (if (and (= found -1) (= (at idx key-lst) key)) idx found)
                )
                -1
                (enumerate 0 (- (length key-lst) 1))
            )
        )
    )
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    (defun URC_Exception (account:string)
        (contains account GAS_EXCEPTION)
    )
    (defun URC_ZeroEliteGAZ (sender:string receiver:string)
        (let
            (
                (t1:bool (URC_Exception sender))
                (t2:bool (URC_Exception receiver))
            )
            (or t1 t2)
        )
    )
    (defun URC_ZeroGAZ:bool (id:string sender:string receiver:string)
        (let
            (
                (t1:bool (URC_ZeroGAS id sender))
                (t2:bool (URC_Exception receiver))
            )
            (or t1 t2)
        )
    )
    (defun URC_ZeroGAS:bool (id:string sender:string)
        (let
            (
                (t1:bool (URC_IsVirtualGasZeroAbsolutely id))
                (t2:bool (URC_Exception sender))
            )
            (or t1 t2)
        )
    )
    (defun URC_IsVirtualGasZeroAbsolutely:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (t1:bool (URC_IsVirtualGasZero))
                (gas-id:string (ref-DALOS::UR_IgnisID))
                (t2:bool (if (or (= gas-id BAR)(= id gas-id)) true false))
            )
            (or t1 t2)
        )
    )
    (defun URC_IsVirtualGasZero:bool ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if (ref-DALOS::UR_VirtualToggle)
                false
                true
            )
        ) 
    )
    (defun URC_IsNativeGasZero:bool ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if (ref-DALOS::UR_NativeToggle)
                false
                true
            )
        )
    )
    ;;{F2}  [UEV]
    (defun UEV_TwentyFourPrecision (amount:decimal)
        @doc "Enforces a 24 Precision, for use with IGNIS Token."
        (enforce
            (= (floor amount 24) amount)
            (format "The GAS Amount of {} is not a valid GAS Amount decimal wise" [amount])
        )
    )
    (defun UEV_Patron (patron:string)
        @doc "Capability that ensures a DALOS account can act as gas payer, enforcing all necesarry restrictions"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if (ref-DALOS::UR_AccountType patron)
                (do
                    (enforce (= patron DALOS|SC_NAME) "Only the DALOS Account can be a Smart Patron")
                    (ref-DALOS::CAP_EnforceAccountOwnership DALOS|SC_NAME)
                )
                (ref-DALOS::CAP_EnforceAccountOwnership patron)
            )
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_MakeIDP:string (ignis-discount:decimal)
        (format "{}{}" [(* (- 1.0 ignis-discount) 100.0) "%"])
    )
    (defun UDC_ConstructOutputCumulator:object{IgnisCollectorV1.OutputCumulator}
        (price:decimal active-account:string trigger:bool output-lst:list)
        (UDC_MakeOutputCumulator
            [
                (UDC_MakeModularCumulator
                    price
                    active-account
                    trigger
                )
            ]
            output-lst
        )
    )
    (defun UDC_BrandingCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string multiplier:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (* multiplier (ref-DALOS::UR_UsagePrice "ignis|branding"))
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_SmallestCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|smallest")
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_SmallCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|small")
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_MediumCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|medium")
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_BigCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|big")
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_BiggestCumulator:object{IgnisCollectorV1.OutputCumulator}
        (active-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|biggest")
                active-account
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    (defun UDC_CustomCodeCumulator:object{IgnisCollectorV1.OutputCumulator} ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (* 5.0 (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (at 1 (ref-DALOS::UR_DemiurgoiID))
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;
    ;;<======================>
    ;;[DALOS-URCi] cost readers — the single source for each DALOS client op's tier choice.
    ;;  DALOS deploys below IGNIS (cannot host these); Talos bills through them and the Z_Reads
    ;;  presentation derives its preview from the same call, so billing and preview never drift.
    ;;<======================>
    (defun DALOS|URCi_ControlSmartAccount:object{IgnisCollectorV1.OutputCumulator} (account:string)
        (UDC_SmallCumulator account)
    )
    (defun DALOS|URCi_RotateGovernor:object{IgnisCollectorV1.OutputCumulator} (account:string)
        (UDC_SmallCumulator account)
    )
    (defun DALOS|URCi_RotateGuard:object{IgnisCollectorV1.OutputCumulator} (account:string)
        (UDC_SmallCumulator account)
    )
    (defun DALOS|URCi_RotateKadena:object{IgnisCollectorV1.OutputCumulator} (account:string)
        (UDC_SmallCumulator account)
    )
    (defun DALOS|URCi_RotateSovereign:object{IgnisCollectorV1.OutputCumulator} (account:string)
        (UDC_SmallCumulator account)
    )
    (defun DALOS|URCi_UpdateEliteAccount:object{IgnisCollectorV1.OutputCumulator} (patron:string)
        (UDC_SmallCumulator patron)
    )
    (defun DALOS|URCi_UpdateEliteAccountSquared:object{IgnisCollectorV1.OutputCumulator} (patron:string)
        (UDC_MediumCumulator patron)
    )
    ;;  KDA-billed DALOS ops: the URCi returns the native fair price (the tier "key" single-sourced)
    (defun DALOS|URCi_DeploySmartAccount:decimal ()
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::UR_UsagePrice "smart"))
    )
    (defun DALOS|URCi_DeployStandardAccount:decimal ()
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::UR_UsagePrice "standard"))
    )
    ;;
    (defun UDC_MakeModularCumulator:object{IgnisCollectorV1.ModularCumulator}
        (price:decimal active-account:string trigger:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (interactor:string
                    (if (ref-DALOS::UR_AccountType active-account)
                        active-account
                        BAR
                    )
                )
            )
            (if trigger
                {"ignis"        : 0.0
                ,"interactor"   : BAR}
                {"ignis"        : price
                ,"interactor"   : interactor}
            )
        )
    )
    (defun UDC_MakeOutputCumulator:object{IgnisCollectorV1.OutputCumulator}
        (input-modular-cumulator-chain:[object{IgnisCollectorV1.ModularCumulator}] output-lst:list)
        {"cumulator-chain"  : input-modular-cumulator-chain
        ,"output"           : output-lst}
    )
    (defun UDC_ConcatenateOutputCumulators:object{IgnisCollectorV1.OutputCumulator}
        (input-output-cumulator-chain:[object{IgnisCollectorV1.OutputCumulator}] new-output-lst:list)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (folded-obj:[[object{IgnisCollectorV1.ModularCumulator}]]
                    (fold
                        (lambda
                            (acc:[[object{IgnisCollectorV1.ModularCumulator}]] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (at "cumulator-chain" (at idx input-output-cumulator-chain))
                            )
                        )
                        []
                        (enumerate 0 (- (length input-output-cumulator-chain) 1))
                    )
                )
            )
            {"cumulator-chain"  : (fold (+) [] folded-obj)
            ,"output"           : new-output-lst}
        )
    )
    (defun UDC_CompressOutputCumulator:object{IgnisCollectorV1.CompressedCumulator}
        (input-output-cumulator:object{IgnisCollectorV1.OutputCumulator})
        @doc "Merges same-interactor legs of a cumulator-chain into one (interactor, summed-ignis) \
            \ entry each. Optimized (DALOS audit, post-#8H): uses the local single-pass \
            \ UC_FindKeyIndex instead of U|LST::UC_Search (which does ~4x the traversals for a \
            \ question this caller only ever needs one index for), and folds the accumulator as a \
            \ bare object instead of a throwaway 1-element list, dropping a UC_ReplaceAt/UC_Chain \
            \ call every iteration. Output is provably identical to the prior implementation — see \
            \ REPL/_scratch_ignis_compress_prime_optimization.repl."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (cumulator-chain-input:[object{IgnisCollectorV1.ModularCumulator}]
                    (at "cumulator-chain" input-output-cumulator)
                )
                (folded-obj:object{IgnisCollectorV1.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV1.CompressedCumulator} idx:integer)
                            (let
                                (
                                    (read-ignis-price:decimal (at "ignis" (at idx cumulator-chain-input)))
                                    (read-interactor:string (at "interactor" (at idx cumulator-chain-input)))
                                    (interactor-position:integer (UC_FindKeyIndex (at "interactors" acc) read-interactor))
                                )
                                (if (= interactor-position -1)
                                    {
                                        "ignis-prices"  : (ref-U|LST::UC_AppL (at "ignis-prices" acc) read-ignis-price),
                                        "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) read-interactor)
                                    }
                                    (let
                                        (
                                            (ignis-amount-in-acc:decimal (at interactor-position (at "ignis-prices" acc)))
                                            (updated-ignis-amount:decimal (+ read-ignis-price ignis-amount-in-acc))
                                        )
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) interactor-position updated-ignis-amount),
                                            "interactors"   : (at "interactors" acc)
                                        }
                                    )
                                )
                            )
                        )
                        (at 0 EMPTY_CC)
                        (enumerate 0 (- (length cumulator-chain-input) 1))
                    )
                )
            )
            folded-obj
        )
    )
    (defun UDC_PrimeIgnisCumulator:object{IgnisCollectorV1.PrimedCumulator}
        (patron:string input:object{IgnisCollectorV1.CompressedCumulator})
        @doc "Splits each compressed leg into a smart-account cut and a principal/BAR cut per the \
            \ GAS_QUARTER fee-share. Optimized (DALOS audit, post-#8H) the same way as \
            \ UDC_CompressOutputCumulator above — see that function's @doc."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (fll:integer (length (at "ignis-prices" input)))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (folded-obj:object{IgnisCollectorV1.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV1.CompressedCumulator} idx:integer)
                            (let
                                (
                                    (input-ignis-price:decimal (at idx (at "ignis-prices" input)))
                                    (input-ignis-price-discounted:decimal (* input-ignis-price ignis-discount))
                                    (input-interactor:string (at idx (at "interactors" input)))
                                    (iz-interactor-principal:bool
                                        (if (= input-interactor BAR)
                                            true
                                            false
                                        )
                                    )
                                    (smart-ignis-amount:decimal
                                        (if iz-interactor-principal
                                            0.0
                                            (* GAS_QUARTER input-ignis-price-discounted)
                                        )
                                    )
                                    (prime-ignis-amount:decimal (- input-ignis-price-discounted smart-ignis-amount))
                                    ;;
                                    (principal-interactor-position:integer (UC_FindKeyIndex (at "interactors" acc) BAR))
                                    (principal-interactor-exists:bool (!= principal-interactor-position -1))
                                )
                                (if principal-interactor-exists
                                    ;;Wen principal interactor already exists
                                    (let
                                        (
                                            (principal-interactor-current-ignis-amount:decimal (at principal-interactor-position (at "ignis-prices" acc)))
                                            (updated-interactor-ignis-amount:decimal (+ principal-interactor-current-ignis-amount prime-ignis-amount))
                                        )
                                        (if iz-interactor-principal
                                            ;;Wen interactor is principal
                                            {
                                                "ignis-prices"  : (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) principal-interactor-position updated-interactor-ignis-amount),
                                                "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                            }
                                            ;;Wen interactor is not principal
                                            {
                                                "ignis-prices"  : (ref-U|LST::UC_AppL (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) principal-interactor-position updated-interactor-ignis-amount) smart-ignis-amount),
                                                "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                            }
                                        )
                                    )
                                    ;;Wen principal interactor doesnt exit yet
                                    (if iz-interactor-principal
                                        ;;Wen interactor is principal
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_AppL (at "ignis-prices" acc) prime-ignis-amount),
                                            "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                        }
                                        ;;Wen interactor is not principal
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_AppL (ref-U|LST::UC_AppL (at "ignis-prices" acc) prime-ignis-amount) smart-ignis-amount),
                                            "interactors"   : (ref-U|LST::UC_AppL (ref-U|LST::UC_AppL (at "interactors" acc) BAR) input-interactor)
                                        }
                                    )
                                )
                            )
                        )
                        (at 0 EMPTY_CC)
                        (enumerate 0 (- fll 1))
                    )
                )
            )
            {"primed-cumulator" : folded-obj}
        )
    )
    ;;
    ;;<======================>
    ;;[OURONET-INFO] Functions — shared cost/format vocabulary (relocated from INFO-ZERO;
    ;;  must live pre-Talos so Talos + all cost modules + Z_Reads presentation can reach it)
    ;;<======================>
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV1.OutputCumulator})
        (let
            (
                (cc:[object{IgnisCollectorV1.ModularCumulator}] (at "cumulator-chain" input))
            )
            (fold
                (lambda
                    (acc:decimal idx:integer)
                    (+ acc (at "ignis" (at idx cc)))
                )
                0.0
                (enumerate 0 (- (length cc) 1))
            )
        )
    )
    (defun OI|UC_ShortAccount:string (account:string)
        (concat
            [
                (take 5 account)
                "..."
                (take -3 account)
            ]
        )
    )
    (defun OI|UC_ConvertPrice:string (input-price:decimal)
        (let
            (
                (number-of-decimals:integer (if (<= input-price 1.00) 3 2))
                (converted:decimal
                    (if (< input-price 1.00)
                        (floor (* input-price 100.0) 3)
                        (floor input-price 2)
                    )
                )
                (s:string
                    (if (< input-price 1.00)
                        "¢"
                        "$"
                    )
                )
                (ss:string "<0.001¢")
            )
            (if (< input-price 0.00001)
                (format "{}" [ss])
                (format "{}{}" [converted s])
            )
        )
    )
    (defun OI|UC_FormatIndex:string (index:decimal)
        (let
            (
                (fi:decimal (floor index 12))
                (fis:string (format "{}" [fi]))
                (l1:string (take -3 fis))
                (l2:string (take -3 (drop -3 fis)))
                (l3:string (take -3 (drop -6 fis)))
                (l4:string (take -3 (drop -9 fis)))
                (whole:string (drop -13 fis))
            )
            (concat
                [whole ",[" l4 "." l3 "." l2 "." l1 "]"]
            )
        )
    )
    (defun OI|UC_FormatTokenAmount:string (amount:decimal)
        (format "{}" [(floor amount 4)])
    )
    (defun OI|UR_KadenaTargets:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            [
                (at 2 (ref-DALOS::UR_DemiurgoiID))
                DALOS|SC_NAME
                (at 1 (ref-DALOS::UR_DemiurgoiID))
                OUROBOROS|SC_NAME
            ]
        )
    )
    (defun OI|UDC_ClientInfo:object{OuronetInfoV1.ClientInfo}
        (a:[string] b:[string] c:object{OuronetInfoV1.ClientIgnisCosts} d:object{OuronetInfoV1.ClientKadenaCosts} e:list)
        {"pre-text"         : a
        ,"post-text"        : b
        ,"ignis"            : c
        ,"kadena"           : d
        ,"output"           : e}
    )
    (defun OI|UDC_ClientIgnisCosts:object{OuronetInfoV1.ClientIgnisCosts}
        (a:decimal b:decimal c:decimal d:string)
        {"ignis-discount"   : a
        ,"ignis-full"       : b
        ,"ignis-need"       : c
        ,"ignis-text"       : d}
    )
    (defun OI|UDC_ClientKadenaCosts:object{OuronetInfoV1.ClientKadenaCosts}
        (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string)
        {"kadena-discount"  : a
        ,"kadena-full"      : b
        ,"kadena-need"      : c
        ,"kadena-split"     : d
        ,"kadena-targets"   : e
        ,"kadena-text"      : f}
    )
    (defun OI|UDC_FullKadenaCosts:object{OuronetInfoV1.ClientKadenaCosts} (kfp:decimal)
        (let
            (
                (ref-U|CT|DIA:module{DiaKdaPidV1} U|CT)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;
                (kda-pid:decimal (ref-U|CT|DIA::UR|KDA-PID))
                (kadena-split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit kfp KDAPREC))
                (kadena-targets:[string] (OI|UR_KadenaTargets))
                (kadena-price:string (OI|UC_ConvertPrice (* kfp kda-pid)))
                (kadena-text:string
                    (format "Operation costs {} KDA valued at {} with no further discounts applied." [kfp kadena-price])
                )
            )
            (OI|UDC_ClientKadenaCosts
                1.0
                kfp
                kfp
                kadena-split
                kadena-targets
                kadena-text
            )
        )
    )
    (defun OI|UDC_KadenaCosts:object{OuronetInfoV1.ClientKadenaCosts} (patron:string kfp:decimal)
        (let
            (
                (ref-U|CT|DIA:module{DiaKdaPidV1} U|CT)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (kda-pid:decimal (ref-U|CT|DIA::UR|KDA-PID))
                (kadena-discount:decimal (ref-DALOS::URC_KadenaGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 kadena-discount))]))
                (kadena-need:decimal (floor (* kadena-discount kfp) KDAPREC))
                (kadena-split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit kadena-need KDAPREC))
                (kadena-targets:[string] (OI|UR_KadenaTargets))
                (kadena-need-price:string (OI|UC_ConvertPrice (* kadena-need kda-pid)))
                (kadena-text:string
                    (if (= kadena-discount 1.0)
                        (format "Operation costs {} KDA valued at {} with no further discounts applied." [kadena-need kadena-need-price])
                        (format "Operation costs {} KDA discounted by {} to {} KDA valued at {}"
                            [kfp discount-percent kadena-need kadena-need-price]
                        )
                    )
                )
            )
            (OI|UDC_ClientKadenaCosts
                kadena-discount
                kfp
                kadena-need
                kadena-split
                kadena-targets
                kadena-text
            )
        )
    )
    (defun OI|UDC_NoKadenaCosts:object{OuronetInfoV1.ClientKadenaCosts} ()
        (OI|UDC_ClientKadenaCosts
            1.0
            0.0
            0.0
            [0.0]
            [BAR]
            "Operation is free of native Kadena (KDA)"
        )
    )
    (defun OI|UDC_DynamicKadenaCost:object{OuronetInfoV1.ClientKadenaCosts} (patron:string kfp:decimal)
        (if (= kfp 0.0)
            (OI|UDC_NoKadenaCosts)
            (OI|UDC_KadenaCosts patron kfp)
        )
    )
    ;;
    (defun OI|UDC_IgnisCosts:object{OuronetInfoV1.ClientIgnisCosts} (patron:string ifp:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 ignis-discount))]))
                (ignis-need:decimal (* ignis-discount ifp))
                (ignis-need-price (OI|UC_ConvertPrice (/ ignis-need 100.0)))
                (ignis-text:string
                    (if (= ignis-discount 1.0)
                        (format "Operation costs {} IGNIS valued at {} with no further discounts applied." [ignis-need ignis-need-price])
                        (format "Operation costs {} IGNIS discounted by {} to {} IGNIS valued at {}"
                            [(floor ifp) discount-percent ignis-need ignis-need-price]
                        )
                    )
                )
            )
            (OI|UDC_ClientIgnisCosts
                ignis-discount
                ifp
                ignis-need
                ignis-text
            )
        )
    )
    (defun OI|UDC_NoIgnisCosts:object{OuronetInfoV1.ClientIgnisCosts} ()
        (OI|UDC_ClientIgnisCosts
            1.0
            0.0
            0.0
            "Operation is free of Ouronet GAS (IGNIS)"
        )
    )
    (defun OI|UDC_DynamicIgnisCost:object{OuronetInfoV1.ClientIgnisCosts} (patron:string ifp:decimal)
        (if (= ifp 0.0)
            (OI|UDC_NoIgnisCosts)
            (OI|UDC_IgnisCosts patron ifp)
        )
    )
    ;;
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    (defun C_TransferDalosFuel (sender:string receiver:string amount:decimal)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
            )
            (ref-coin::transfer sender receiver amount)
        )
    )
    (defun C_Collect
        (patron:string input-output-cumulator:object{IgnisCollectorV1.OutputCumulator})
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (compressed-cumulator:object{IgnisCollectorV1.CompressedCumulator}
                    (UDC_CompressOutputCumulator input-output-cumulator)
                )
                (primed-cumulator:object{IgnisCollectorV1.PrimedCumulator}
                    (UDC_PrimeIgnisCumulator patron compressed-cumulator)
                )
                (ignis-prices:[decimal] (at "ignis-prices" (at "primed-cumulator" primed-cumulator)))
                (ignis-sum:decimal (fold (+) 0.0 ignis-prices))
                (iz-gassles-patron:bool (ref-DALOS::UR_AccountType patron))
                (virtual-gas-toggle:bool (ref-DALOS::UR_VirtualToggle))
            )
            (if (and (!= ignis-sum 0.0) (not iz-gassles-patron))
                (if virtual-gas-toggle
                    (with-capability (IGNIS|C>DC patron)
                        (let
                            (
                                (icl:integer (length ignis-prices))
                                (primed-collector:object{IgnisCollectorV1.CompressedCumulator} 
                                    (at "primed-cumulator" primed-cumulator)
                                )
                            )
                            (map
                                (lambda
                                    (idx:integer)
                                    (let
                                        (
                                            (interactor:string (at idx (at "interactors" primed-collector)))
                                            (amount:decimal (at idx (at "ignis-prices" primed-collector)))
                                        )
                                        ;;A leg priced at 0.0 (or, if ever misconfigured, negative) is a
                                        ;;legitimately free leg for THIS interactor within an otherwise-
                                        ;;billable bundle — skip collecting it instead of hitting
                                        ;;IGNIS|C>TRANSFER's unconditional (> ta 0.0) enforce, which would
                                        ;;otherwise abort the whole batch over one free leg (DALOS audit
                                        ;;#8H). Ties into the same IGNIS|S>FREE event already used for the
                                        ;;all-free case, so a free leg is still observable on-chain.
                                        (if (> amount 0.0)
                                            (with-capability (IGNIS|C>COLLECT patron interactor amount)
                                                (XI_IgnisCollector patron interactor amount)
                                            )
                                            (with-capability (IGNIS|S>FREE) true)
                                        )
                                    )
                                )
                                (enumerate 0 (- icl 1))
                            )
                            (ref-DALOS::XE_IncrementOuronetAccountNonce patron)
                        )
                    )
                    (with-capability (IGNIS|S>FREE)
                        true
                    )
                )
                (with-capability (IGNIS|S>FREE)
                    true
                )
            )
        )
    )
    (defun KDA|C_Collect (sender:string amount:decimal)
        (KDA|C_CollectWT sender amount (URC_IsNativeGasZero))
    )
    (defun KDA|C_CollectWT (sender:string amount:decimal trigger:bool)
        (KDA|C_CollectWTEx sender sender amount trigger)
    )
    (defun KDA|C_CollectWTEx (payer:string discount-account:string amount:decimal trigger:bool)
        @doc "Collect native STOA from payer Kadena account; Elite split from discount-account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (split-discounted-kda:[decimal] (ref-DALOS::URC_SplitKDAPrices discount-account amount))
                (am0:decimal (at 0 split-discounted-kda))
                (am1:decimal (at 1 split-discounted-kda))
                (am2:decimal (at 2 split-discounted-kda))
                (am3:decimal (at 3 split-discounted-kda))
                (kda-sender:string (ref-DALOS::UR_AccountKadena payer))
                (demiurgoi:[string] (ref-DALOS::UR_DemiurgoiID))
                (kda-cto:string (ref-DALOS::UR_AccountKadena (at 1 demiurgoi)))
                (kda-hov:string (ref-DALOS::UR_AccountKadena (at 2 demiurgoi)))
                (kda-ouroboros:string (ref-DALOS::UR_AccountKadena OUROBOROS|SC_NAME))
                (kda-dalos:string (ref-DALOS::UR_AccountKadena DALOS|SC_NAME))
            )
            (if (not trigger)
                (do
                    (C_TransferDalosFuel kda-sender kda-hov am0)          ;;10% to Demiourgos.Holdings
                    (C_TransferDalosFuel kda-sender kda-cto am2)          ;;30% to Ouronet Maintenance
                    (C_TransferDalosFuel kda-sender kda-ouroboros am3)    ;;40% to KDA-Ouroboros (as Pitstop for LiquidKadenaIndex fueling)
                    (C_TransferDalosFuel kda-sender kda-dalos am1)        ;;20% to KDA-Dalos (Ouronet Gas Station)
                )
                (format "While Kadena Collection is {}, the {} KDA could not be collected" [trigger amount])
            )
        )
    )
    ;;{F7}  [X]
    (defun XI_IgnisCollector (patron:string interactor:string amount:decimal)
        (require-capability (IGNIS|C>COLLECT patron interactor amount))
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (collector:string
                    (if (= interactor BAR)
                        (ref-DALOS::UR_Tanker)
                        interactor
                    )
                )
            )
            (ref-DALOS::XE_IgnisIncrement false amount)
            (XI_IgnisTransfer patron collector amount)
        )
    )
    (defun XI_IgnisTransfer (sender:string receiver:string ta:decimal)
        (require-capability (IGNIS|C>TRANSFER sender receiver ta))
        (XI_IgnisDebit sender ta)
        (XI_IgnisCredit receiver ta)
    )
    (defun XI_IgnisDebit (sender:string ta:decimal)
        (require-capability (IGNIS|C>DEBIT sender ta))
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance sender false 
                (- (ref-DALOS::UR_TF_AccountSupply sender false) ta)
            )
        )
    )
    (defun XI_IgnisCredit (receiver:string ta:decimal)
        (require-capability (IGNIS|C>CREDIT receiver))
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance receiver false 
                (+ (ref-DALOS::UR_TF_AccountSupply receiver false) ta)
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)