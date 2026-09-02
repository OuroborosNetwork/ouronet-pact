;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; SOVEREIGN launchpad Talos. Holds ONLY the sovereign DEMIPAD orchestration
;; (asset registration/config + deposit/fuel/retrieve/withdraw). The per-sale
;; CITIZEN user wrappers (SPARK|/SNAKES|/CUSTODIANS|/KPAY|/STOAICO|) live in the
;; citizen Talos 2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact, deployed AFTER the
;; citizen sales. Deploy order: DEMIPAD core -> TS02-C1/C2/C3 -> THIS (sovereign)
;; -> citizen sales -> TS02-CPAD (citizen Talos).
;;
(interface TalosStageTwo_DemiPadV1
    @doc "Exposes Ouronet Stage Two Demipad SOVEREIGN Client Functions"
    ;;
    ;;  [A]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool]))
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool))
    (defun A_DefinePrice (asset-id:string price:object))
    (defun A_ToggleRetrieval (asset-id:string toggle:bool))
    ;;
    ;;  [C]
    ;;
    (defun C_DEMIPAD|Deposit (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal))
    ;;
    (defun C_DEMIPAD|Withdraw (patron:string asset-id:string type:integer destination:string))
    ;;
    (defun C_DEMIPAD|FuelTrueFungible (patron:string client:string asset-id:string amount:decimal))
    (defun C_DEMIPAD|FuelOrtoFungible (patron:string client:string asset-id:string nonces:[integer]))
    (defun C_DEMIPAD|FuelSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun C_DEMIPAD|FuelNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))

    (defun C_DEMIPAD|RetrieveTrueFungible (patron:string client:string asset-id:string amount:decimal))
    (defun C_DEMIPAD|RetrieveOrtoFungible (patron:string client:string asset-id:string nonces:[integer]))
    (defun C_DEMIPAD|RetrieveSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun C_DEMIPAD|RetrieveNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    ;;
)
;;
(module TS02-DPAD GOV
    @doc "TALOS Stage 2 Demiourgos Launchpad SOVEREIGN Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageTwo_DemiPadV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-DPAD          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                      (compose-capability (GOV|TS02-DPAD_ADMIN)))
    (defcap GOV|TS02-DPAD_ADMIN ()      (enforce-guard GOV|MD_TS02-DPAD))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()             (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|TS02-DPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        @doc "Registers THIS sovereign launchpad Talos' summoner guard as a trusted IMP peer of the \
            \ sovereign modules it drives (DEMIPAD core + DPDC for direct XB_DeployAccount). The \
            \ per-sale CITIZEN modules are registered by the citizen Talos (TS02-CPAD)."
        (let
            (
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                (ref-P|DPAD:module{OuronetPolicyV1} DEMIPAD)
                (ref-P|DPDC:module{OuronetPolicyV1} DPDC)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
            ;;DPDC Audit #35M: TS02-DPAD calls DPDC::XB_DeployAccountSFT/NFT directly (the removed
            ;;DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers previously carried TS02-C1/C2's
            ;;own registered guard through the call chain instead) -- register this module's own guard
            ;;as a trusted DPDC peer so P|UEV_IMC recognizes the direct call.
            (ref-P|DPDC::P|A_AddIMP mg)
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
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
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
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool])
        @doc "Registers an Asset to Launchpad; \
            \ An Asset can be a DPTF, DPMF, DPSF or DPNF \
            \   Asset-type can be designated via the double-boolean <fungibility> \
            \   \
            \   DPFT >> [true true] \
            \   DPMF >> [true false] \
            \   DPSF >> [false true] \
            \   DPNF >> [false false]"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-DPDC:module{DpdcV1} DPDC)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                    (tf:[bool] [true true])
                    (of:[bool] [true false])
                    (sf:[bool] [false true])
                    (nf:[bool] [false false])
                    (f:bool false)
                )
                (ref-DEMIPAD::A_RegisterAssetToLaunchpad patron asset-id fungibility)
                ;;Reconciles two audits' DeployAccount hardening (dptf-dpof #N2 + DPDC #35M):
                ;; #N2: lpad is DEMIPAD's own system smart account (not patron's) — tf/of use the ADMIN
                ;;   variant (TS01-A, no ownership check on <account>); the self-service C_ variant now
                ;;   requires the caller to own <account>, which they don't for lpad.
                ;; #35M: the public DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers were REMOVED
                ;;   (any signer could force any account onto any collection); sf/nf now call
                ;;   DPDC::XB_DeployAccountSFT/NFT directly, module-to-module — the pattern every
                ;;   legitimate internal caller (DPDC-C/DPDC-F/DPDC-R/DPDC-S) already uses.
                (cond
                    ((= fungibility tf) (ref-TS01-A::A_DPTF|DeployAccount patron asset-id lpad))
                    ((= fungibility of) (ref-TS01-A::A_DPOF|DeployAccount patron asset-id lpad))
                    ((= fungibility sf) (ref-DPDC::XB_DeployAccountSFT lpad asset-id f f f f f f f f f f f))
                    ((= fungibility nf) (ref-DPDC::XB_DeployAccountNFT lpad asset-id f f f f f f f f f f))
                    true
                )
            )
        )
    )
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool)
        @doc "Toggle Open For Bussines. Must be on to acquire Assets"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::A_ToggleOpenForBusiness asset-id toggle)
            )
        )
    )
    (defun A_DefinePrice (asset-id:string price:object)
        @doc "Updates Price Object for an Asset"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::A_DefinePrice asset-id price)
            )
        )
    )
    (defun A_ToggleRetrieval (asset-id:string toggle:bool)
        @doc "Retrieval ON allows Asset Owners to retrieve their Asssets that still exist on the Launchpad"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::A_ToggleRetrieval asset-id toggle)
            )
        )
    )
    (defun C_DEMIPAD|Deposit (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @doc "Sovereign launchpad DEPOSIT Talos op — the citizen sales call this to move a buyer's \
            \ STOA/OURS working-token into the Launchpad against <asset-id>. <type> 0 = Native STOA \
            \ (wrapped), 1 = OWS; <max-cost> is the buyer's dollar slippage ceiling (sentinel < 0 = \
            \ slippage off). IGNIS billed on patron here; the sale composes it Sigma-wise with its \
            \ asset-transfer Talos op."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount donor))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DEMIPAD::C_Deposit donor asset-id amount-in-dollars type direct-injection max-cost)
                )
                (format "Succesfuly deposited {} $ worth against {} into Demipad from {}." [amount-in-dollars asset-id sd])
            )
        )
    )
    ;;
    (defun C_DEMIPAD|Withdraw (patron:string asset-id:string type:integer destination:string)
        @doc "Withdraws all cumulated Tokens in the Launchpad, gathered through sale \
            \ Type 1 = WSTOA \
            \ Type 2 = SSTOA \
            \ Type 3 = OURO "
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (retrieval-amount:decimal (ref-DEMIPAD::UR_Funds asset-id type))
                    (working-id:string
                        (if (= type 1)
                            (ref-DALOS::UR_WrappedStoaID)
                            (if (= type 2)
                                (ref-DALOS::UR_SilverStoaID)
                                (ref-DALOS::UR_OuroborosID)
                            )
                        )
                    )
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
                )
                (ref-DEMIPAD::C_Withdraw patron asset-id type destination)
                (format "Succesfuly withdrawn {} {} from Demipad to {}." [retrieval-amount working-id sd])
            )
        )
    )
    ;;
    (defun C_DEMIPAD|FuelTrueFungible (patron:string client:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron client asset-id amount true)
            )
        )
    )
    (defun C_DEMIPAD|FuelOrtoFungible (patron:string client:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron client asset-id nonces true)
            )
        )
    )
    (defun C_DEMIPAD|FuelSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles client asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun C_DEMIPAD|FuelNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DEMIPAD::C_TransmitNonFungibles client asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    ;;
    (defun C_DEMIPAD|RetrieveTrueFungible (patron:string client:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron client asset-id amount false)
            )
        )
    )
    (defun C_DEMIPAD|RetrieveOrtoFungible (patron:string client:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron client asset-id nonces false)
            )
        )
    )
    (defun C_DEMIPAD|RetrieveSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles client asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun C_DEMIPAD|RetrieveNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DEMIPAD::C_TransmitNonFungibles client asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
