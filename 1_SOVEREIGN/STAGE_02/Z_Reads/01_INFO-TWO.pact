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
    ;;  [EQUITY]
    (defun URC_EQUITY|IssueCompany:object{OuronetInfoV1.ClientInfo} (patron:string creator-account:string collection-name:string))
    (defun URC_EQUITY|MorphEquity:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
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
    ;;  [DPDC roles/toggles] — DPDC-R (son = false for DPNF, true for DPSF)
    (defun URC_DPDC-R|Toggle:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string son:bool label:string ico:object{IgnisCollectorV1.OutputCumulator} toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]) (format "Operation: Removes {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]))]
                [(if toggle (format "{} Role added for {} to {}" [label id sa]) (format "{} Role removed for {} to {}" [label id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_DPNF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Burn" (r::URCi_ToggleBurnRole id false) toggle)))
    (defun URC_DPSF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Burn" (r::URCi_ToggleBurnRole id true) toggle)))
    (defun URC_DPNF|ToggleExemptionRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Fee-Exemption" (r::URCi_ToggleExemptionRole id false) toggle)))
    (defun URC_DPSF|ToggleExemptionRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Fee-Exemption" (r::URCi_ToggleExemptionRole id true) toggle)))
    (defun URC_DPNF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Freeze" (r::URCi_ToggleFreezeAccount id false) toggle)))
    (defun URC_DPSF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Freeze" (r::URCi_ToggleFreezeAccount id true) toggle)))
    (defun URC_DPNF|ToggleModifyCreatorRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id false) toggle)))
    (defun URC_DPSF|ToggleModifyCreatorRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id true) toggle)))
    (defun URC_DPNF|ToggleModifyRoyaltiesRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id false) toggle)))
    (defun URC_DPSF|ToggleModifyRoyaltiesRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id true) toggle)))
    (defun URC_DPNF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Transfer" (r::URCi_ToggleTransferRole id false) toggle)))
    (defun URC_DPSF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Transfer" (r::URCi_ToggleTransferRole id true) toggle)))
    (defun URC_DPNF|ToggleUpdateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account false "Update" (r::URCi_ToggleUpdateRole id false) toggle)))
    (defun URC_DPSF|ToggleUpdateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Update" (r::URCi_ToggleUpdateRole id true) toggle)))
    (defun URC_DPSF|ToggleAddQuantityRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Toggle patron id account true "Add-Quantity" (r::URCi_ToggleAddQuantityRole id) toggle)))
    ;;  [DPDC role moves] — DPDC-R Move* (patron id new-account)
    (defun URC_DPDC-R|Move:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string son:bool label:string ico:object{IgnisCollectorV1.OutputCumulator})
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Moves the {} Role of {} {} to {}" [label (if son "SFT" "NFT") id sa])]
                [(format "{} Role of {} succesfully moved to {}" [label id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DPNF|MoveCreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account false "Create" (r::URCi_MoveCreateRole id false))))
    (defun URC_DPSF|MoveCreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account true "Create" (r::URCi_MoveCreateRole id true))))
    (defun URC_DPNF|MoveRecreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account false "Recreate" (r::URCi_MoveRecreateRole id false))))
    (defun URC_DPSF|MoveRecreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account true "Recreate" (r::URCi_MoveRecreateRole id true))))
    (defun URC_DPNF|MoveSetUriRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account false "Set-URI" (r::URCi_MoveSetUriRole id false))))
    (defun URC_DPSF|MoveSetUriRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-account:string) (let ((r:module{DpdcRolesV1} DPDC-R)) (URC_DPDC-R|Move patron id new-account true "Set-URI" (r::URCi_MoveSetUriRole id true))))
    ;;  [DPDC management] — DPDC-MNG Control / Pause / Respawn / AddQuantity
    (defun URC_DPDC-MNG|Simple:object{OuronetInfoV1.ClientInfo} (patron:string desc:string result:string ico:object{IgnisCollectorV1.OutputCumulator})
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo [desc] [result]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DPNF|Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of NFT {}" [id]) (format "Succesfully controlled Properties of NFT {}" [id]) (r::URCi_Control id false))))
    (defun URC_DPSF|Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of SFT {}" [id]) (format "Succesfully controlled Properties of SFT {}" [id]) (r::URCi_Control id true))))
    (defun URC_DPNF|TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses NFT {}" [id]) (format "Operation: Unpauses NFT {}" [id])) (format "NFT {} pause toggled" [id]) (r::URCi_TogglePause id false))))
    (defun URC_DPSF|TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses SFT {}" [id]) (format "Operation: Unpauses SFT {}" [id])) (format "SFT {} pause toggled" [id]) (r::URCi_TogglePause id true))))
    (defun URC_DPNF|Respawn:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Respawns NFT {} Nonce {}" [id nonce]) (format "Succesfully respawned NFT {} Nonce {}" [id nonce]) (r::URCi_RespawnNFT id))))
    (defun URC_DPSF|AddQuantity:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Adds {} quantity to SFT {} Nonce {}" [amount id nonce]) (format "Succesfully added {} quantity to SFT {} Nonce {}" [amount id nonce]) (r::URCi_AddQuantity id))))
    ;;  [DPDC updates] — DPDC-N single-field (URCi_UpdateNonceField) + bulk (URCi_UpdateNonces)
    (defun URC_DPDC-N|Field:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string son:bool label:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (r:module{DpdcNonceV1} DPDC-N))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates the {} of {} {}" [label (if son "SFT" "NFT") id])]
                [(format "{} of {} {} succesfully updated" [label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonceField account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DPDC-N|Bulk:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string son:bool label:string count:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (r:module{DpdcNonceV1} DPDC-N))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates {} {} of {} {}" [count label (if son "SFT" "NFT") id])]
                [(format "{} {} of {} {} succesfully updated" [count label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonces account count)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    ;;   NF single-field
    (defun URC_DPNF|UpdateNonceName:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (URC_DPDC-N|Field patron id account false (format "Name (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceDescription:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (URC_DPDC-N|Field patron id account false (format "Description (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account false (format "Royalty (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceIgnisRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account false (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceURI:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}) (URC_DPDC-N|Field patron id account false (format "URI (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceMetaData:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (URC_DPDC-N|Field patron id account false (format "Meta-Data (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (URC_DPDC-N|Field patron id account false (format "Score (Nonce {})" [nonce])))
    (defun URC_DPNF|RemoveNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (URC_DPDC-N|Field patron id account false (format "Score-Removal (Nonce {})" [nonce])))
    (defun URC_DPNF|UpdateSetNonceName:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (URC_DPDC-N|Field patron id account false (format "Name (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceDescription:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (URC_DPDC-N|Field patron id account false (format "Description (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account false (format "Royalty (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account false (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceURI:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}) (URC_DPDC-N|Field patron id account false (format "URI (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceMetaData:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (URC_DPDC-N|Field patron id account false (format "Meta-Data (Set-Class {})" [set-class])))
    (defun URC_DPNF|UpdateSetNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (URC_DPDC-N|Field patron id account false (format "Score (Set-Class {})" [set-class])))
    (defun URC_DPNF|RemoveSetNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (URC_DPDC-N|Field patron id account false (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   NF bulk
    (defun URC_DPNF|UpdateNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}) (URC_DPDC-N|Bulk patron id account false "Nonce" 1))
    (defun URC_DPNF|UpdateNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}]) (URC_DPDC-N|Bulk patron id account false "Nonces" (length nonces)))
    (defun URC_DPNF|UpdateSetNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}) (URC_DPDC-N|Bulk patron id account false "Set-Nonce" 1))
    (defun URC_DPNF|UpdateSetNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}]) (URC_DPDC-N|Bulk patron id account false "Set-Nonces" (length set-classes)))
    ;;   SF single-field
    (defun URC_DPSF|UpdateNonceName:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (URC_DPDC-N|Field patron id account true (format "Name (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceDescription:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (URC_DPDC-N|Field patron id account true (format "Description (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account true (format "Royalty (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceIgnisRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account true (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceURI:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}) (URC_DPDC-N|Field patron id account true (format "URI (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceMetaData:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (URC_DPDC-N|Field patron id account true (format "Meta-Data (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (URC_DPDC-N|Field patron id account true (format "Score (Nonce {})" [nonce])))
    (defun URC_DPSF|RemoveNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (URC_DPDC-N|Field patron id account true (format "Score-Removal (Nonce {})" [nonce])))
    (defun URC_DPSF|UpdateSetNonceName:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (URC_DPDC-N|Field patron id account true (format "Name (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceDescription:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (URC_DPDC-N|Field patron id account true (format "Description (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account true (format "Royalty (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (URC_DPDC-N|Field patron id account true (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceURI:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}) (URC_DPDC-N|Field patron id account true (format "URI (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceMetaData:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (URC_DPDC-N|Field patron id account true (format "Meta-Data (Set-Class {})" [set-class])))
    (defun URC_DPSF|UpdateSetNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (URC_DPDC-N|Field patron id account true (format "Score (Set-Class {})" [set-class])))
    (defun URC_DPSF|RemoveSetNonceScore:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (URC_DPDC-N|Field patron id account true (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   SF bulk
    (defun URC_DPSF|UpdateNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}) (URC_DPDC-N|Bulk patron id account true "Nonce" 1))
    (defun URC_DPSF|UpdateNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}]) (URC_DPDC-N|Bulk patron id account true "Nonces" (length nonces)))
    (defun URC_DPSF|UpdateSetNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}) (URC_DPDC-N|Bulk patron id account true "Set-Nonce" 1))
    (defun URC_DPSF|UpdateSetNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}]) (URC_DPDC-N|Bulk patron id account true "Set-Nonces" (length set-classes)))
    ;;  [DPDC wipes] — DPDC-MNG single (URCi_WipeNonce/WipeSlim) + multi (URCi_WipeCumulator)
    (defun URC_DPDC-MNG|WipeMulti:object{OuronetInfoV1.ClientInfo} (patron:string id:string son:bool obj:object{DpdcManagementV1.RemovableNonces} label:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (r:module{DpdcManagementV1} DPDC-MNG) (n:integer (length (at "r-nonces" obj))))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: {} wipe of {} {} Nonces of {}" [label (if son "SFT" "NFT") n id])]
                [(format "{} wipe of {} {} Nonces of {} succesful" [label (if son "SFT" "NFT") n id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_WipeCumulator id son obj)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_DPNF|WipeNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Wipes NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id false))))
    (defun URC_DPSF|WipeNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Wipes SFT {} Nonce {}" [id nonce]) (format "SFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id true))))
    (defun URC_DPSF|WipeNoncePartialy:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Partially wipes {} of SFT {} Nonce {}" [amount id nonce]) (format "Partially wiped {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_WipeSlim id))))
    (defun URC_DPNF|WipeHeavy:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|WipeMulti patron id false (r::URDC_WipePure account id false) "Heavy")))
    (defun URC_DPSF|WipeHeavy:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|WipeMulti patron id true (r::URDC_WipePure account id true) "Heavy")))
    (defun URC_DPNF|WipePure:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV1.RemovableNonces}) (URC_DPDC-MNG|WipeMulti patron id false removable-nonces-obj "Pure"))
    (defun URC_DPSF|WipePure:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV1.RemovableNonces}) (URC_DPDC-MNG|WipeMulti patron id true removable-nonces-obj "Pure"))
    (defun URC_DPNF|WipeClean:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer]) (let ((r:module{DpdcManagementV1} DPDC-MNG) (d:module{DpdcV1} DPDC)) (URC_DPDC-MNG|WipeMulti patron id false (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id false nonces)) "Clean")))
    (defun URC_DPSF|WipeClean:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer]) (let ((r:module{DpdcManagementV1} DPDC-MNG) (d:module{DpdcV1} DPDC)) (URC_DPDC-MNG|WipeMulti patron id true (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id true nonces)) "Clean")))
    (defun URC_DPNF|WipeDirty:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer]) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|WipeMulti patron id false (r::URC_FilterAccountViableNonces account id false nonces) "Dirty")))
    (defun URC_DPSF|WipeDirty:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer]) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|WipeMulti patron id true (r::URC_FilterAccountViableNonces account id true nonces) "Dirty")))
    ;;  [DPDC burn] — DPDC-MNG single-nonce burn
    (defun URC_DPNF|Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Burns NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} burned" [id nonce]) (r::URCi_BurnNFT id))))
    (defun URC_DPSF|Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer) (let ((r:module{DpdcManagementV1} DPDC-MNG)) (URC_DPDC-MNG|Simple patron (format "Operation: Burns {} of SFT {} Nonce {}" [amount id nonce]) (format "Burned {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_BurnSFT id))))
    ;;  [DPDC transfers] — DPDC-T Multi/Bulk transfer + Repurpose (DPDC-T / DPDC-F)
    (defun URC_DPNF|TransferNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Transfers {} of NFT {} Nonce {} to {}" [amount id nonce receiver]) (format "Transferred {} of NFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [[nonce]] [[amount]]))))
    (defun URC_DPSF|TransferNonce:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Transfers {} of SFT {} Nonce {} to {}" [amount id nonce receiver]) (format "Transferred {} of SFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [[nonce]] [[amount]]))))
    (defun URC_DPNF|TransferNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of NFT {} to {}" [(length nonces) id receiver]) (format "Transferred {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [nonces] [amounts]))))
    (defun URC_DPSF|TransferNonces:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of SFT {} to {}" [(length nonces) id receiver]) (format "Transferred {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [nonces] [amounts]))))
    (defun URC_DPNF|BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers NFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred NFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id false sender receiver-lst nonces-array amounts-array))))
    (defun URC_DPSF|BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers SFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred SFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id true sender receiver-lst nonces-array amounts-array))))
    (defun URC_DPNF|Repurpose:object{OuronetInfoV1.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id false amounts))))
    (defun URC_DPSF|Repurpose:object{OuronetInfoV1.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]) (let ((t:module{DpdcTransferV1} DPDC-T)) (URC_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id true amounts))))
    (defun URC_DPNF|RepurposeFragments:object{OuronetInfoV1.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of NFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id false amounts))))
    (defun URC_DPSF|RepurposeFragments:object{OuronetInfoV1.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of SFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id true amounts))))
    ;;  [DPDC sets] — DpdcSetsV1 Make/Break/Define/Rename/Toggle
    (defun URC_DPNF|Make:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Makes an NFT {} Set (class {}) from {} Nonces" [id set-class (length nonces)]) (format "NFT {} Set (class {}) made" [id set-class]) (s::URCi_MakeNonFungibleSet account id nonces))))
    (defun URC_DPSF|Make:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Makes {} SFT {} Sets (class {}) from {} Nonces" [how-many-sets id set-class (length nonces)]) (format "{} SFT {} Sets (class {}) made" [how-many-sets id set-class]) (s::URCi_MakeSemiFungibleSet account id nonces how-many-sets))))
    (defun URC_DPNF|Break:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Breaks NFT {} Set-Nonce {}" [id nonce]) (format "NFT {} Set-Nonce {} broken" [id nonce]) (s::URCi_BreakNonFungibleSet account id nonce))))
    (defun URC_DPSF|Break:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer how-many-sets:integer) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Breaks {} SFT {} Set-Nonce {}" [how-many-sets id nonce]) (format "{} SFT {} Set-Nonce {} broken" [how-many-sets id nonce]) (s::URCi_BreakSemiFungibleSet account id nonce how-many-sets))))
    (defun URC_DPNF|DefinePrimordialSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for NFT {}" [set-name id]) (format "Primordial Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id false))))
    (defun URC_DPSF|DefinePrimordialSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for SFT {}" [set-name id]) (format "Primordial Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id true))))
    (defun URC_DPNF|DefineCompositeSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for NFT {}" [set-name id]) (format "Composite Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineCompositeSet id false))))
    (defun URC_DPSF|DefineCompositeSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for SFT {}" [set-name id]) (format "Composite Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineCompositeSet id true))))
    (defun URC_DPNF|DefineHybridSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for NFT {}" [set-name id]) (format "Hybrid Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineHybridSet id false))))
    (defun URC_DPSF|DefineHybridSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for SFT {}" [set-name id]) (format "Hybrid Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineHybridSet id true))))
    (defun URC_DPNF|RenameSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer new-name:string) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Renames NFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "NFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id false))))
    (defun URC_DPSF|RenameSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer new-name:string) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Renames SFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "SFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id true))))
    (defun URC_DPNF|ToggleSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer toggle:bool) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Toggles NFT {} Set-Class {}" [id set-class]) (format "NFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id false))))
    (defun URC_DPSF|ToggleSet:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer toggle:bool) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Toggles SFT {} Set-Class {}" [id set-class]) (format "SFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id true))))
    ;;  [DPDC fragments] — DpdcFragmentsV1 (+ EnableSetClassFragmentation on DpdcSetsV1)
    (defun URC_DPNF|EnableNonceFragmentation:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for NFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id false))))
    (defun URC_DPSF|EnableNonceFragmentation:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for SFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id true))))
    (defun URC_DPNF|EnableSetClassFragmentation:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for NFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id false))))
    (defun URC_DPSF|EnableSetClassFragmentation:object{OuronetInfoV1.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}) (let ((s:module{DpdcSetsV1} DPDC-S)) (URC_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for SFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id true))))
    (defun URC_DPNF|MakeFragments:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id false))))
    (defun URC_DPSF|MakeFragments:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id true))))
    (defun URC_DPNF|MergeFragments:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id false))))
    (defun URC_DPSF|MergeFragments:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer) (let ((fr:module{DpdcFragmentsV1} DPDC-F)) (URC_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id true))))
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
    ;;
    ;;  [EQUITY] — shareholder/company SFT collection (exposed via DPSF Talos)
    (defun URC_EQUITY|IssueCompany:object{OuronetInfoV1.ClientInfo} (patron:string creator-account:string collection-name:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-EQUITY:module{EquityV1} EQUITY) (sa:string (ref-I|OURONET::OI|UC_ShortAccount creator-account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues the 8-element Shareholder (Equity) SFT Collection '{}' on Account {}" [collection-name sa])]
                [(format "Shareholder Collection '{}' issued succesfully on Account {}" [collection-name sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_IssueShareholderCollection)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_EQUITY|MorphEquity:object{OuronetInfoV1.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-EQUITY:module{EquityV1} EQUITY) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Morphs {} shares of {} Nonce {} into Nonce {} on Account {}" [input-amount id input-nonce output-nonce sa])]
                [(format "Succesfully morphed {} {} Nonce {} shares into Nonce {} on {}" [input-amount id input-nonce output-nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_MorphPackageShares account id input-nonce input-amount output-nonce)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)