(interface InfoTwoV1
    @doc "Exposes Functions from Information One Module"
    true
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
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)