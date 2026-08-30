(interface StoicPayV2
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
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool))
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    ;;
    ;;  [C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool))

)
(module DEMIPAD-STOICPAY GOV
    @doc "StoicPay sale mechanics (DEMIPAD). UI read aggregate lives in DPL-UR as URC_0030_StoicPay."
    ;;
    (implements OuronetPolicyV1)
    (implements StoicPayV2)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_KPAY                       (keyset-ref-guard (GOV|Demiurgoi)))
    ;;
    (defconst DEMIPAD|SC_NAME                   (GOV|DEMIPAD|SC_NAME))
    ;;{G2}
    (defcap GOV ()                              (compose-capability (GOV|KPAY_ADMIN)))
    (defcap GOV|KPAY_ADMIN ()                   (enforce-guard GOV|MD_KPAY))
    ;;{G3}
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
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
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
    (defschema KPAY|PropertiesSchema
        asset-id:string
    )
    ;;{2}
    (deftable KPAY|T|Properties:{KPAY|PropertiesSchema})
    ;;{3}
    (defun KPAY|Info ()                     (at 0 ["StoicPayV2"]))
    (defconst KPAY|INFO                     (KPAY|Info))
    (defun CT_Bar ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                           (CT_Bar))
    
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
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
    ;;{F1}  [URC]
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV1.Costs} (amount:integer offset:decimal)
        @doc "Computes Prices;"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaKdaPidV1} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (kda-prec:integer (ref-U|CT::CT_KDA_PRECISION))
                (kda-pid:decimal (ref-U|CT|DIA::UR|KDA-PID))
                ;;
                (KpayID:string (UR_KpayID))
                (Kpay-price:decimal (UR_KpayPID offset))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) Kpay-price)
                (floor (* (/ Kpay-price kda-pid) (dec amount)) kda-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool)
        @doc "An offset of 15 minutes (900.0 seconds) is used to compute values for the Coin.Transfer Capabilities"
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::URC_Acquire buyer KpayID pid type)
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
                (ref-U|CT|DIA:module{DiaKdaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                ;;
                (kda-prec:integer (ref-U|CT::CT_KDA_PRECISION))
                (kda-pid:decimal (ref-U|CT|DIA::UR|KDA-PID))
                ;;
                (k-account:string (ref-DALOS::UR_AccountKadena account))
                (wkda:string (ref-DALOS::UR_WrappedStoaID))
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
                (client-kadena-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wkda account)
                    )
                )
                (client-kadena-value-in-dollarz:decimal (floor (* client-kadena-supply kda-pid) 2))
                (can-buy-with-client-supply:integer 
                    (if (= kpay-price -1.0)
                        0
                        (floor (/ client-kadena-value-in-dollarz kpay-price))
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
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool)
        (UEV_IMC)
        (with-capability (KPAY|C>BUY kpay-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    ;;
                    (KpayID:string (UR_KpayID))
                    (costs:object{DemiourgosLaunchpadV1.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (ico1:object{IgnisCollectorV1.OutputCumulator}
                        (ref-DEMIPAD::C_Deposit buyer KpayID pid type false)
                    )
                    (ico2:object{IgnisCollectorV1.OutputCumulator}
                        (ref-TFT::C_Transfer KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount) true)
                    )
                    (ten-p:decimal (* 0.25 (dec kpay-amount)))
                    (twenty-p:decimal (* 0.5 (dec kpay-amount)))
                    (ico3:object{IgnisCollectorV1.OutputCumulator}
                        (ref-TFT::C_MultiBulkTransfer [KpayID] DEMIPAD|SC_NAME
                            [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                            [[twenty-p ten-p ten-p ten-p ten-p]]
                        )
                    )
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                    (present-kpay-price:decimal (UR_KpayPID 0.0))
                    (paid:decimal (at "wkda" costs))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
                )
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
    ;;{F7}  [X]
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table KPAY|T|Properties)