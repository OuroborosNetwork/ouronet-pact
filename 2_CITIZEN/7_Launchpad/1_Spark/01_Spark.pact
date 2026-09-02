(interface SparksV1
    ;;
    ;;  [UR]
    ;;
    (defun UR_SparkID:string ())
    (defun UR_IzOpenForBusiness:bool ())
    (defun UR_FrozenSparkID:string ())
    (defun UR_Sparks (account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    (defun URC_SparkCost:decimal ())
    (defun URC_SparkRedemptionCost:decimal ())
    (defun URC_AccountRedemptionAmount:decimal (account:string))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;
    ;;  [C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal))
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string))
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal))
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool))
    (defun INFO_BuySparks:object{OuronetInfoV1.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool))
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun INFO_RedeemSparks:object{OuronetInfoV1.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    ;;
)
(module DEMIPAD-SPARK GOV
    ;;
    (implements OuronetPolicyV1)
    (implements SparksV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_SPARK                     (keyset-ref-guard (GOV|Demiurgoi)))
    ;;
    (defconst DEMIPAD|SC_NAME                  (GOV|DEMIPAD|SC_NAME))
    ;;{G2}
    (defcap GOV ()                             (compose-capability (GOV|SPARK_ADMIN)))
    (defcap GOV|SPARK_ADMIN ()                 (enforce-guard GOV|MD_SPARK))
    ;;{G3}
    (defun GOV|Demiurgoi ()                    (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|DEMIPAD|SC_NAME ()              (let ((ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)) (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|SPARK|CALLER ()
        true
    )
    (defcap P|PAD-SPARK|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SPARK|CALLER))
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
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SPARK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|SPARK_ADMIN)
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
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|VST:module{OuronetPolicyV1} VST)
                (ref-P|DPAD:module{OuronetPolicyV1} DEMIPAD)
                (mg:guard (create-capability-guard (P|SPARK|CALLER)))
            )
            (ref-P|DPAD::A_P|Add
                "SPARK|RemoteGov"
                (create-capability-guard (P|PAD-SPARK|REMOTE-GOV))
            )
            (ref-P|DPTF::A_P|AddIMP mg)
            (ref-P|TFT::A_P|AddIMP mg)
            (ref-P|VST::A_P|AddIMP mg)
            (ref-P|DPAD::A_P|AddIMP mg)
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
    (defschema SPARK|PropertiesSchema
        spark-id:string
    )
    ;;{2}
    (deftable SPARK|T|Properties:{SPARK|PropertiesSchema})
    ;;{3}
    (defun CT_Info ()                        (at 0 ["spark-data-key"]))
    (defconst SPARK|INFO                        (CT_Info))
    (defun CT_Bar ()                            (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                               (CT_Bar))
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
    (defcap SPARK|C>BUY (sparks-amount:integer)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (spark-id:string (UR_SparkID))
                (remaining-supply:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                (amount:decimal (dec sparks-amount))
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap SPARK|C>REEDEM-ALL (account-to-redeem:string)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (compose-capability (SPARK|C>X_REEDEM account-to-redeem supply))
        )
    )
    (defcap SPARK|C>REEDEM-FEW (account-to-redeem:string redemption-quantity:decimal)
        @event
        (compose-capability (SPARK|C>X_REEDEM account-to-redeem redemption-quantity))
    )
    (defcap SPARK|C>X_REEDEM (account-to-redeem:string redemption-quantity:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (ref-DPTF::CAP_Owner spark-id)
            (enforce 
                (and
                    (> redemption-quantity 0.0)
                    (<= redemption-quantity supply)
                )
                "Invalid Redemmption Amount"
            )
            (compose-capability (P|SECURE-CALLER))
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
            (compose-capability (GOV|SPARK_ADMIN))
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    ;;{F2}  Compute [UC]
    ;;{F3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_SparkID:string ()
        (at "spark-id" (read SPARK|T|Properties SPARK|INFO ["spark-id"]))
    )
    (defun UR_BoostPromille:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
            )
            (at "boost" (ref-DEMIPAD::UR_Price (UR_SparkID)))
        )
    )
    (defun UR_IzOpenForBusiness:bool ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
            )
            (ref-DEMIPAD::UR_OpenForBusiness (UR_SparkID))
        )
    )
    (defun UR_FrozenSparkID:string ()
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-DPTF::UR_Frozen (UR_SparkID))
        )
    )
    (defun UR_Sparks (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (spark-id:string (UR_SparkID))
                (f-spark-id:string (UR_FrozenSparkID))
            )
            {"spark-id"         : spark-id
            ,"f-spark-id"       : f-spark-id
            ,"spark-supply"     : (ref-DPTF::UR_AccountSupply spark-id account)
            ,"f-spark-supply"   : (ref-DPTF::UR_AccountSupply f-spark-id account)
            ;;
            ,"iz-sale"          : (UR_IzOpenForBusiness)
            ,"boost-promile"    : (UR_BoostPromille)
            ;;
            ,"left-for-sale"    : (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME)
            ,"sparks-supply"    : (ref-DPTF::UR_Supply spark-id)
            ,"f-sparks-supply"  : (ref-DPTF::UR_Supply f-spark-id)
            ;;
            ,"stoa-spark-cost"   : (URC_SparkCost)
            ,"redemption-value" : (URC_SparkRedemptionCost)
            ;;
            ,"native-max"       : (URC_GetMaxBuy account true)
            ,"wstoa-max"         : (URC_GetMaxBuy account false)
            ;;
            ,"account-ignis"    : (ref-DPTF::UR_AccountSupply (ref-DALOS::UR_IgnisID) account)
            ,"ignis-collection" : (ref-DALOS::UR_VirtualToggle)}
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds"
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
                (still-for-sale:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:decimal (floor (/ client-stoa-value-in-dollarz spark-price)))
            )
            (floor
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URC_SparkCost:decimal ()
        @doc "Returns the amount of STOA that is needed to pay for one Token"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (floor (/ spark-price stoa-pid) stoa-prec)
        )
    )
    (defun URC_SparkRedemptionCost:decimal ()
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) stoa-pid) stoa-prec)
        )
    )
    (defun URC_CustomSparkRedemptionCost:decimal (custom-stoa-pid:decimal)
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) custom-stoa-pid) stoa-prec)
        )
    )
    (defun URC_AccountRedemptionAmount:decimal (account:string)
        @doc "Returns Account Redemption Amount"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account))
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (rc:decimal (URC_SparkRedemptionCost))
            )
            (floor (* supply rc) stoa-prec)
        )
    )
    (defun URC_SparkAmountCosts:object{DemiourgosLaunchpadV1.Costs} (amount:integer)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) spark-price)
                (floor (* (/ spark-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuySparks = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPTF Sparks-out transfer. The deposit is \
            \ amount-independent; the transfer cost depends only on the DPTF fee class of Sparks."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (spark-id:string (UR_SparkID))
                (pid:decimal (at "pid" (URC_SparkAmountCosts sparks-amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer spark-id pid type false))
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_Transfer spark-id DEMIPAD|SC_NAME buyer (dec sparks-amount))))
        )
    )
    (defun INFO_BuySparks:object{OuronetInfoV1.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool)
        @doc "Cost preview for the C_SPARK|BuySparks pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuySparks (Sigma of the two Talos ops). Launchpad \
            \ ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared \
            \ in the description as the good being bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (spark-id:string (UR_SparkID))
                (costs:object{DemiourgosLaunchpadV1.Costs} (URC_SparkAmountCosts sparks-amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} Sparks for {} (pure-citizen, Sigma-billed)." [sparks-amount spark-id sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.C_SPARK|BuySparks (the sole gas-funded path)." ]
                [ (format "Acquired {} {} Sparks." [sparks-amount spark-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuySparks buyer sparks-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Pure-citizen IGNIS cost preview for C_Redem*Sparks = Sigma of the six SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): wSTOA transfer + freeze + wipe + unfreeze + remint + VST re-freeze. \
            \ Per-op costs are fee-class based; fed the same redemption-quantity the exec receives."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-VST:module{VestingV1} VST)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer wstoa-id redemption-payer account-to-redeem redemption-value))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_WipeSlim spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint spark-id DEMIPAD|SC_NAME false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-VST::URCi_Freeze DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)) ])
        )
    )
    (defun INFO_RedeemSparks:object{OuronetInfoV1.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Cost preview for the SPARK|C_RedemAll/FewSparks pure-citizen redeem (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_RedeemSparks (Sigma of the six Talos ops). No \
            \ protocol STOA fee; the redeem RETURNS wSTOA to the account (a refund, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Redeem {} {} from {} (pure-citizen, Sigma-billed)." [redemption-quantity spark-id sa])
                  (format "Returns {} {} to the account (a refund, not a cost)." [redemption-value wstoa-id]) ]
                [ (format "Redeemed {} {} for {} {}." [redemption-quantity spark-id redemption-value wstoa-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_RedeemSparks redemption-payer account-to-redeem redemption-quantity))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{F4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    (defun XI_RedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV1} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_SparkRedemptionCost))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::C_DPTF|Transfer patron wstoa-id redemption-payer account-to-redeem redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::C_DPTF|ToggleFreezeAccount patron spark-id account-to-redeem true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::C_DPTF|WipeSlim patron spark-id account-to-redeem redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::C_DPTF|ToggleFreezeAccount patron spark-id account-to-redeem false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::C_DPTF|Mint patron spark-id DEMIPAD|SC_NAME redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::C_VST|Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    (defun XI_CustomRedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV1} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_CustomSparkRedemptionCost custom-stoa-pid))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::C_DPTF|Transfer patron wstoa-id redemption-payer account-to-redeem redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::C_DPTF|ToggleFreezeAccount patron spark-id account-to-redeem true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::C_DPTF|WipeSlim patron spark-id account-to-redeem redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::C_DPTF|ToggleFreezeAccount patron spark-id account-to-redeem false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::C_DPTF|Mint patron spark-id DEMIPAD|SC_NAME redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::C_VST|Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    ;;{F7}  User [A]
    ;;{F8}  User [C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal)
        @doc "PURE CITIZEN buy. Composes two SOVEREIGN Talos ops — C_DEMIPAD|Deposit (buyer STOA -> \
            \ Launchpad) then C_DPTF|Transfer (Sparks Launchpad -> buyer) — each self-collecting IGNIS \
            \ on <patron>. A citizen cannot fold cumulators (no permission for the bare uncollected \
            \ core funcs), so IGNIS is billed Sigma-wise (once per op). <max-cost> is the buyer's dollar \
            \ slippage ceiling (sentinel < 0 = slippage off). Preview: URCi_BuySparks / INFO_BuySparks."
        (with-capability (SPARK|C>BUY sparks-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    ;;
                    (spark-id:string (UR_SparkID))
                    (costs:object{DemiourgosLaunchpadV1.Costs} (URC_SparkAmountCosts sparks-amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::C_DEMIPAD|Deposit patron buyer spark-id pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — Sparks from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::C_DPTF|Transfer patron spark-id DEMIPAD|SC_NAME buyer (dec sparks-amount) true)
                (format "User {} succesfuly acquired {} {} Tokens" [sb sparks-amount spark-id])
            )
        )
    )
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_RedeemSparks patron redemption-payer account-to-redeem supply)
            )
        )
    )
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_CustomRedeemSparks patron redemption-payer account-to-redeem supply custom-stoa-pid)
            )
        )
    )
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_RedeemSparks patron redemption-payer account-to-redeem redemption-quantity)
        )
    )
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_CustomRedeemSparks patron redemption-payer account-to-redeem redemption-quantity custom-stoa-pid)
        )
    )
    ;;{F9}  REPL (test-only, stripped at mainnet) [REPL]
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table SPARK|T|Properties)