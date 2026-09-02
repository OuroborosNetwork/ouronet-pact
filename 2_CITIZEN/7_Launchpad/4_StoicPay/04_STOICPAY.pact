(interface StoicPayV2


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
    ;;  [UR]
    ;;
    (defun UR_KpayID:string ())
    (defun UR_KpayLeft:decimal ())
    (defun UR_KpayPID:decimal (offset:decimal))
    (defun UR_GetPeriod:integer ())
    (defun UR_PeriodAllocation:decimal (period:integer))
    (defun UR_PAD_LEDGER_ACCOUNT:string ())
    ;;
    ;;  [URC]
    ;;
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV1.Costs} (amount:integer offset:decimal))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool))
    (defun INFO_BuyStoicPay:object{OuronetInfoV1.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-STOICPAY GOV
    @doc "StoicPay sale mechanics (DEMIPAD). UI read aggregate lives in DPL-UR as URC_0030_StoicPay."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements StoicPayV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_KPAY                       (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                              (compose-capability (GOV|KPAY_ADMIN)))
    (defcap GOV|KPAY_ADMIN ()                   (enforce-guard GOV|MD_KPAY))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                     (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|DEMIPAD|SC_NAME ()               (let ((ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)) (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)))
    ;;Team allocation recipients (LIVE deployed set — identical to on-chain ouronet-ns.DEMIPAD-STOICPAY).
    ;;60% team share = COMPANY (30%) + VENTURE1..4 (7.5% each) = 1.5x the buyer amount per sale (40/60 split;
    ;;250M end supply). The REPL fixture creates these five accounts so the buy-side MultiBulkTransfer resolves.
    (defun GOV|COMPANY ()                       (at 0 ["Ѻ.ъΦĞρλξäFφVПÉЫÍЬÙGěЭыц¥ĄïsKзŤ8£ΞδĚãlÍŃÝþáΩĘΞȘĎĄЛδůÖîĎĄΠДÈrЪqyςkѺδKłĄρțØänÀŚxчtÍςÃΩ₳9ť7ÇяŠΛδÓdťЗΞŻÛπΩ∇цжuлiØłÛáYπOкæáYoùχmŒуŞËЛΞьPĘáÛÝaBÑБžя₳țςhrĚë₱dÑLÞЛεñeîÓУłëΦ"]))
    (defun GOV|VENTURE1 ()                      (at 0 ["Ѻ.CЭΞŸNGúůρhãmИΘÛ¢₳šШдìAÚwŚGýηЗПAÊУÔȘřŽÍζЗηmΔφDmcдΛъ₳tĂýăŮsПÞ$öœGθeBŽvąαÃfçл¢ĎĆď$şbsЦэΘNÄëÍĂνуãöž¥àZjÆůšÁœôñχŽâЩåτâн4μфAOçĎΓuЗŮnøЙãĚè6Дżîþż$цÑûρψŻïZÉλûæřΨeèÎígςeL"]))
    (defun GOV|VENTURE2 ()                      (at 0 ["Ѻ.ĄÀтмωωàŹČлďÜhÍηЛνÙνûĘõțЫåÒÛHážNÍЧψξïžŹЬΛξП¥ЮςĄEйNĄЧ9óпиÃЗ2äÔвœ₿£ČóΩÞдréě7νшDÅЬXтBørŸĂBςąЙęìvÆлμЛáΩγĘЗôåУțτжéδÚνpÍżȘĘï4ąŹȘkφNθþÀωΞÀWžIи5ь€ÊOôΣëñэÔÿνÜw1юÔzźцξńѺfś"]))
    (defun GOV|VENTURE3 ()                      (at 0 ["Ѻ.ìѺďΘčμЮÚşŁì92lźřWмPòíFùЛgßCÊȚδğďŘTπΠrπмЮ6ŁYŘэHóęÀSăλьПO€ЮrØòш2ΓεîțůOÂŁŻДÍ¥ôWxí4ïçдå₿ЙÒεЗzÝăÚÆπБцìcÕyьΘæěЖù₱фщđÝKÚßzUÉÍЬŒΠYvVŻUЫýčWŘвůćCČΦú2ãбşèуÓçË€ïmôrýмúüÄЬáó"]))
    (defun GOV|VENTURE4 ()                      (at 0 ["Ѻ.BPΩÉ5eønDMRзΣÛł4áÃÄПNΩFзÌõãBЙĞńŒμЗŽτЯÈЙÓDд5țσÆďΔÂиĂqtVŒ3ЦтòȚиåâ8юđhýZNтě∇ŹÀĂkÖѺζEğOüбĆ6мθÈSoш∇ŠmHŒДiÖĎďнÈèTuĎSжğĎЫěIťčç$ÇíżùàĐZξÁτÞFxPÎÎπÿWÖàыДŤγEψàýÔу€эjĆ2ĎżÃς"]))

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
    (defcap P|KPAY|CALLER ()
        true
    )
    (defcap P|PAD-KPAY|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|KPAY|CALLER))
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
        (with-capability (GOV|KPAY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|KPAY_ADMIN)
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
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|DPAD:module{OuronetPolicyV1} DEMIPAD)
                (mg:guard (create-capability-guard (P|KPAY|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "KPAY|RemoteGov"
                (create-capability-guard (P|PAD-KPAY|REMOTE-GOV))
            )
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                   (GOV|DEMIPAD|SC_NAME))
    (defconst KPAY|INFO                     (CT_Info))
    (defconst BAR                           (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema KPAY|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable KPAY|T|Properties:{KPAY|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap KPAY|C>BUY (kpay-amount:integer)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (KpayID:string (UR_KpayID))
                (remaining-supply:decimal (UR_KpayLeft))
                (amount:decimal (dec kpay-amount))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (kpay-price:decimal
                    (if (= future-ten-minute-price -1.0)
                        (UR_KpayPID 0.0)
                        (UR_KpayPID 600.0)
                    )
                )
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            (enforce (> kpay-price 0.0) "Kpay Sale has Concluded!")
            (compose-capability (P|PAD-KPAY|REMOTE-GOV))
            (compose-capability (P|KPAY|CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                     (at 0 ["StoicPayV2"]))
    (defun CT_Bar ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_KpayID:string ()
        (at "asset-id" (read KPAY|T|Properties KPAY|INFO ["asset-id"]))
    )
    (defun UR_GetPeriod:integer ()
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (at "block-time" (chain-data)))
                (three-years:decimal 94608000.0)
                (period-length:decimal (/ three-years 25.0))  ; 3,784,320 seconds
                (elapsed:decimal (diff-time present-tm starting-tm))  ; Seconds between present and start
            )
            (if (< elapsed 0.0)
                -1 ;;Before Starting Time
                (if (>= elapsed three-years)
                    0 ;;After three years
                    (if (= elapsed 0.0)
                        1
                        (let
                            (
                                (p:integer (ceiling (/ elapsed period-length)))
                            )
                            (if (> p 25)
                                25
                                p
                            )
                        )
                    )
                )
            )
        )
    )
    (defun UR_PeriodAllocation:decimal (period:integer)
        (enforce (and (>= period -1) (<= period 25)) "Invalid Period")
        (if (or (= period -1) (= period 0))
            0.0
            (let
                (
                    (a1:decimal 4.4)
                    (ak:decimal (- 4.5 (* 0.1 (dec period))))
                    (sk:decimal (* (/ (dec period) 2.0)(+ a1 ak)))
                )
                (+ 20000000 (* sk 1000000.0))
            )
        )
    )
    (defun UR_KpayLeft:decimal ()
        @doc "Computes how much KPAY can still be bought this Period"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (KpayID:string (UR_KpayID))
                (resident-amount:decimal (ref-DPTF::UR_AccountSupply KpayID DEMIPAD|SC_NAME))
                (left-for-sale:decimal (* 0.4 resident-amount))
                (sold:decimal (- 100000000.0 left-for-sale))
                ;;
                (period:integer (UR_GetPeriod))
                (period-allocation:decimal (UR_PeriodAllocation period))
            )
            (if (or (= period -1)(= period 0))
                0.0
                (- period-allocation sold)
            )
        )
    )
    (defun UR_KpayPID:decimal (offset:decimal)
        @doc "Offset is used to compute the time with a future offset in seconds"
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (add-time (at "block-time" (chain-data)) offset))
                (elapsed-tm:decimal (diff-time present-tm starting-tm))
                (three-years:decimal 94608000.0)
            )
            (if (<= elapsed-tm 0.0)
                0.01
                (if (> elapsed-tm three-years)
                    1.0
                    (floor (+ 0.01 (* 0.99 (/ elapsed-tm three-years))) 24)
                )
            )
        )
    )
    (defun UR_PAD_LEDGER_ACCOUNT:string ()
        @doc "Launchpad ledger account (DPTF holder) for StoicPay inventory."
        DEMIPAD|SC_NAME
    )
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV1.Costs} (amount:integer offset:decimal)
        @doc "Computes Prices;"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (KpayID:string (UR_KpayID))
                (Kpay-price:decimal (UR_KpayPID offset))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) Kpay-price)
                (floor (* (/ Kpay-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — returns the coin.TRANSFER caps the UI signs, padded by \
            \ (1 + slippage/100). An offset of 15 minutes (900.0 s) computes the values."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::URC_Acquire buyer KpayID pid type slippage)
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds \
            \ A price of 10 minutes in the future is used to compute price.\
            \ If there are less than 10 minutes left, the present price is used."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)

                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (KpayID:string (UR_KpayID))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (present-price:decimal (UR_KpayPID 0.0))
                (kpay-price:decimal
                    (if (= present-price future-ten-minute-price)
                        present-price
                        future-ten-minute-price
                    )
                )
                (still-for-sale:integer (floor (UR_KpayLeft)))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:integer 
                    (if (= kpay-price -1.0)
                        0
                        (floor (/ client-stoa-value-in-dollarz kpay-price))
                    )
                )
                (period:integer (UR_GetPeriod))
            )
            (if (or (= period -1) (= period 0))
                0
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuyStoicPay = Sigma of the three SOVEREIGN Talos \
            \ ops' IGNIS (each self-collects): DEMIPAD deposit + DPTF StoicPay-out transfer + DPTF \
            \ multi-bulk venture-split transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (KpayID:string (UR_KpayID))
                (pid:decimal (at "pid" (URC_KpayAmountCosts kpay-amount 0.0)))
                (type:integer (if iz-native 0 1))
                (ten-p:decimal (* 0.25 (dec kpay-amount)))
                (twenty-p:decimal (* 0.5 (dec kpay-amount)))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer KpayID pid type false))
               (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount)))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_MultiBulkTransferCumulator [KpayID] DEMIPAD|SC_NAME
                          [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                          [[twenty-p ten-p ten-p ten-p ten-p]]))))
        )
    )
    (defun INFO_BuyStoicPay:object{OuronetInfoV1.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool)
        @doc "Cost preview for the C_KPAY|BuyStoicPay pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuyStoicPay (Sigma of the three Talos ops). \
            \ Launchpad ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) \
            \ is declared as the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (KpayID:string (UR_KpayID))
                (costs:object{DemiourgosLaunchpadV1.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} StoicPay for {} (pure-citizen, Sigma-billed)." [kpay-amount KpayID sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.C_KPAY|BuyStoicPay (the sole gas-funded path)." ]
                [ (format "Acquired {} {} StoicPay." [kpay-amount KpayID]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuyStoicPay buyer kpay-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price; the \
            \ UI does NOT sign them and warns the buyer the mined price may differ."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer KpayID pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> is the buyer's slippage ceiling in dollars (Variant 1); pass a sentinel below \
            \ zero for the slippage-off path (Variant 2)."
        (with-capability (KPAY|C>BUY kpay-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    ;;
                    (KpayID:string (UR_KpayID))
                    (costs:object{DemiourgosLaunchpadV1.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (ten-p:decimal (* 0.25 (dec kpay-amount)))
                    (twenty-p:decimal (* 0.5 (dec kpay-amount)))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                    (present-kpay-price:decimal (UR_KpayPID 0.0))
                    (paid:decimal (at "wstoa" costs))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::C_DEMIPAD|Deposit patron buyer KpayID pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — StoicPay from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::C_DPTF|Transfer patron KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount) true)
                ;;3] SOVEREIGN DPTF multi-bulk transfer Talos op — venture split (company 50% + 4 ventures); self-collects IGNIS
                (ref-TS01-C1::C_DPTF|MultiBulkTransfer patron [KpayID] DEMIPAD|SC_NAME
                    [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                    [[twenty-p ten-p ten-p ten-p ten-p]])
                (if iz-native
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} Native STOA"
                        [sb kpay-amount present-kpay-price paid]
                    )
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} OWS"
                        [sb kpay-amount present-kpay-price paid]
                    )
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
(create-table KPAY|T|Properties)