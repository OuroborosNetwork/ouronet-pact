(interface InfoTwoV1
    @doc "Exposes the Stage-2 INFO (ClientInfo preview) surface — DPDC collectables, \
        \ DEMIPAD launchpad, EQUITY, AQP. Each function wraps a core URCi cost reader."
    ;;  [DPDC collectables]
    (defun DPSF|INFO_Make:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun DPNF|INFO_Make:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer))
    ;;  [DEMIPAD] — sovereign launchpad
    (defun URC_DEMIPAD|Deposit:object{OuronetInfoV1.ClientInfo} (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal))
    (defun URC_DEMIPAD|Withdraw:object{OuronetInfoV1.ClientInfo} (patron:string asset-id:string type:integer destination:string))
    (defun URC_DEMIPAD|FuelTrueFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string amount:decimal))
    (defun URC_DEMIPAD|RetrieveTrueFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string amount:decimal))
    (defun URC_DEMIPAD|FuelOrtoFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer]))
    (defun URC_DEMIPAD|RetrieveOrtoFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer]))
    (defun URC_DEMIPAD|FuelSemiFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun URC_DEMIPAD|RetrieveSemiFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun URC_DEMIPAD|FuelNonFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun URC_DEMIPAD|RetrieveNonFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
)
;;LIQUID|INFO_UnwrapStoa
;;LIQUID|INFO_WrapStoa
;;LIQUID|INFO_UnwrapUrStoa
(module INFO-TWO GOV
    ;;
    ;;(implements InfoTwoV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO|DPTF      (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|INFO|DPTF_ADMIN)))
    (defcap GOV|INFO|DPTF_ADMIN ()  (enforce-guard GOV|MD_INFO|DPTF))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    ;;{P3}
    ;;{P4}
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;
    ;;  [SIP|URC] - Simple Ignis Price >> dependent on a single trigger
    ;;
    ;;
    ;;  [SKP|URC] - Simple Stoa Price 
    ;;
    ;;
    ;;  [INFO] - Informational URC Functions
    ;;
    ;;  [DPSF]
    (defun DPSF|INFO_Make:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                ;;
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                (nonce:integer (ref-DPDC-S::UR_NonceOfSet id set-class))
                (set-name:string (ref-DPDC-S::UR_SetName id son set-class))
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [son] account dpdc [nonces] [(make-list (length nonces) how-many-sets)])
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates {} {} Sets on Account {}" [how-many-sets set-name])]
                [(format "Successfully generated {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}" [how-many-sets set-class nonce id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;  [DPNF]
    ;;
    (defun DPNF|INFO_Make:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string id:string nonces:[integer] set-class:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                ;;
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                (set-name:string (ref-DPDC-S::UR_SetName id son set-class))
                (nonce:integer (+ 1 (ref-DPDC::UR_NoncesUsed id false)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [son] account dpdc [nonces] [(make-list (length nonces) 1)])
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ft:string (take 2 id))
                (sh:string "E|")
                (nu:integer (ref-DPDC::UR_NoncesUsed id son))
                (smallest:decimal (ref-DALOS::UR_UsagePrice "ignis|smallest"))
                (price:decimal
                    (if (fold (and) true [(= ft sh) son (= nu 0)])
                        (/ smallest 1000.0)
                        smallest
                    )
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price owner trigger [])
                )
                (ifp2:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico2))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [son] dpdc account [[nonce]] [[1]])
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates a {} Set on Account {}" [set-name sa])]
                [(format "Successfully generated Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;  [DEMIPAD] — sovereign launchpad ops (deposit + fuel/retrieve TF/OF/SF/NF + withdraw)
    (defun URC_DEMIPAD|Deposit:object{OuronetInfoV1.ClientInfo} (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (sd:string (ref-I|OURONET::OI|UC_ShortAccount donor)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Deposits {} $ worth against {} into the Launchpad from {}" [amount-in-dollars asset-id sd])]
                [(format "Succesfully deposited {} $ worth against {} into Demipad from {}" [amount-in-dollars asset-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_Deposit donor asset-id amount-in-dollars type direct-injection)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DEMIPAD|Withdraw:object{OuronetInfoV1.ClientInfo} (patron:string asset-id:string type:integer destination:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (amount:decimal (ref-DEMIPAD::UR_Funds asset-id type))
                (working-id:string (if (= type 1) (ref-DALOS::UR_WrappedStoaID) (if (= type 2) (ref-DALOS::UR_SilverStoaID) (ref-DALOS::UR_OuroborosID))))
                (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Withdraws {} {} accumulated in the Launchpad to {}" [amount working-id sd])]
                [(format "Succesfully withdrawn {} {} from Demipad to {}" [amount working-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer working-id lpad destination amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DEMIPAD|FuelTrueFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (ref-TFT:module{TrueFungibleTransferV1} TFT) (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} {} (TrueFungible) to the Launchpad from {}" [amount asset-id sa])]
                [(format "Succesfully fueled {} {} to the Launchpad from {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id client lpad amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DEMIPAD|RetrieveTrueFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (ref-TFT:module{TrueFungibleTransferV1} TFT) (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} {} (TrueFungible) from the Launchpad to {}" [amount asset-id sa])]
                [(format "Succesfully retrieved {} {} from the Launchpad to {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id lpad client amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DEMIPAD|FuelOrtoFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (OrtoFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])))
    (defun URC_DEMIPAD|RetrieveOrtoFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (OrtoFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])))
    (defun URC_DEMIPAD|FuelSemiFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} Amounts {} (SemiFungible) to the Launchpad from {}" [asset-id nonces amounts sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])))
    (defun URC_DEMIPAD|RetrieveSemiFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} Amounts {} (SemiFungible) from the Launchpad to {}" [asset-id nonces amounts sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])))
    (defun URC_DEMIPAD|FuelNonFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (NonFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])))
    (defun URC_DEMIPAD|RetrieveNonFungible:object{OuronetInfoV1.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD) (sa:string (ref-I|OURONET::OI|UC_ShortAccount client)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (NonFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])))
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)