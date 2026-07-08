;; PYTHIA — Apollo Pythia API-Key registry (Stage 01 core #23, after CODEX).
;; Spec: OuronetInformational/HANDOFF-pact-apollo-pythia-key-module.md
;; Interface: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact (PythiaV1 frozen, PythiaV2 live).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;; Client entrypoints: Talos TS01-C4 (deploy/rename: native STOA via IGNIS; deactivate: IGNIS only).
;; Cronoton operator: ouronet-ns.pythia-cronoton-keyset (define before A_ActivateApiKey).
;;

(module PYTHIA GOV
    @doc "On-chain Apollo Pythia API-key registry. Standard keys: user deploy; Smart keys: admin only."
    ;;
    (implements PythiaV2)
    (implements OuronetPolicyV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_PYTHIA                     (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                              (compose-capability (GOV|PYTHIA_ADMIN)))
    (defcap GOV|PYTHIA_ADMIN ()                 (enforce-guard GOV|MD_PYTHIA))
    (defcap PYTHIA|CRONOTON ()                  (enforce-guard (keyset-ref-guard (GOV|CronotonKey))))
    ;;{G3}
    (defun GOV|Demiurgoi ()                     (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|NS_Use ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|CronotonKey ()                   (+ (GOV|NS_Use) ".pythia-cronoton-keyset"))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|PYTHIA|CALLER ()
        true
    )
    ;;{P4}
    (defconst P|I                               (P|Info))
    (defun P|Info ()                            (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|PYTHIA_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|PYTHIA_ADMIN)
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
                (mg:guard (create-capability-guard (P|PYTHIA|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let ((ref-U|G:module{OuronetGuardsV1} U|G))
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    (defschema PYTHIA|S|ApiKey
        @doc "One Apollo Pythia API-key lane. Table key = apollo-account (₱./Π. 162-char API key)."
        public:string                               ;;[.]   Canonical Apollo public-key material
        consumer-lane:string                        ;;[M]   Attribution / lane label
        activated:bool                              ;;[M]   On: Cronoton only; off: owner or Cronoton
        owner-account:string                        ;;[.]   Ouronet DALOS account that deployed + paid
        registered-at:time                          ;;[.]   Block time at deploy
        updated-at:time                             ;;[M]   Block time at last mutation
        ;;
        ;;Select Keys
        apollo-account:string                       ;;[.]   Apollo account string (= table key / API key)
    )
    (defschema PYTHIA|S|Config
        deploy-price:decimal
        rename-price:decimal
    )
    ;;{2}
    (deftable PYTHIA|T|ApiKeys:{PYTHIA|S|ApiKey})   ;;Key = <apollo-account>
    (deftable PYTHIA|T|Config:{PYTHIA|S|Config})      ;;Key = PYTHIA|INFO
    ;;{3}
    (defun CT_Bar ()                                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                                   (CT_Bar))
    (defconst PYTHIA|EPOCH:time                     (time "1970-01-01T00:00:00Z"))
    (defconst PYTHIA|APOLLO-LEN:integer             162)
    (defconst PYTHIA|INFO:string                    "config")
    (defconst PYTHIA|DEFAULT-DEPLOY-PRICE:decimal   1000.0)
    (defconst PYTHIA|DEFAULT-RENAME-PRICE:decimal   100.0)
    (defconst PYTHIA|DEACTIVATE-IGNIS-FEE:decimal   1.0)
    (defconst PYTHIA|APOLLO-STANDARD:string         "₱")
    (defconst PYTHIA|APOLLO-SMART:string            "Π")
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap PYTHIA|OWNER (owner-account:string)
        @doc "Caller controls the Ouronet (DALOS) account — Standard or Smart."
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS))
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
        )
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap PYTHIA|C>DEPLOY-STANDARD-API-KEY
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string )
        @doc "Owner deploys inert Standard (₱.) API-key row. Composes SECURE for WI_ApiKey."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
            )
            (enforce (!= public "") "Public key material must be non-empty")
            (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account false)
            (ref-U|DALOS::UEV_StoicTagName consumer-lane)
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>DEPLOY-SMART-API-KEY
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string )
        @doc "Demiurgoi deploys inert Smart (Π.) API-key row. Composes SECURE for WI_ApiKey."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (enforce (!= public "") "Public key material must be non-empty")
            (ref-DALOS::UEV_EnforceAccountExists owner-account)
            (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account true)
            (ref-U|DALOS::UEV_StoicTagName consumer-lane)
            (compose-capability (GOV|PYTHIA_ADMIN))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>ACTIVATE-API-KEY (apollo-account:string)
        @doc "Cronoton activates key after off-chain Apollo proof. Key must be inactive."
        @event
        (let
            (
                (iz-active:bool (UR_IsActivated apollo-account))
            )
            (enforce (not iz-active) "API key is already activated")
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>DEACTIVATE-API-KEY (owner-account:string apollo-account:string)
        @doc "Owner deactivates their key. Key must be active."
        @event
        (let
            (
                (iz-active:bool (UR_IsActivated apollo-account))
                (row-owner:string (UR_OwnerAccount apollo-account))
            )
            (enforce (= owner-account row-owner) "Only the deployer may deactivate this API key")
            (enforce iz-active "API key is already deactivated")
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>DEACTIVATE-API-KEY (apollo-account:string)
        @doc "Cronoton deactivates (revokes) key. Key must be active."
        @event
        (let
            (
                (iz-active:bool (UR_IsActivated apollo-account))
            )
            (enforce iz-active "API key is already deactivated")
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>UPDATE-NAME (owner-account:string apollo-account:string new-name:string)
        @doc "Owner renames consumer-lane on their deployed key. Composes SECURE for WU2."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
                (row-owner:string (UR_OwnerAccount apollo-account))
            )
            (enforce (= owner-account row-owner) "Only the deployer may rename this API key")
            (ref-U|DALOS::UEV_StoicTagName new-name)
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]
    (defun UC_DeployPrice:decimal ()
        @doc "Governance-tunable deploy toll (default 1000 STOA; collected in TS01-C4)."
        (with-default-read PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price" : PYTHIA|DEFAULT-DEPLOY-PRICE, "rename-price" : PYTHIA|DEFAULT-RENAME-PRICE}
            {"deploy-price" := p}
            p
        )
    )
    (defun UC_RenamePrice:decimal ()
        @doc "Governance-tunable consumer-lane rename toll (default 100 STOA; collected in TS01-C4)."
        (with-default-read PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price" : PYTHIA|DEFAULT-DEPLOY-PRICE, "rename-price" : PYTHIA|DEFAULT-RENAME-PRICE}
            {"rename-price" := p}
            p
        )
    )
    (defun UC_IsStandardApollo:bool (apollo-account:string)
        @doc "True when apollo-account begins with Standard ₱. (false = Smart Π.)."
        (= PYTHIA|APOLLO-STANDARD (take 1 apollo-account))
    )
    (defun UC_FeeDiscountAnchor:string ()
        @doc "STOA fee discount anchor — BAR (non-account) yields tier 0.0; Elite discounts never apply."
        BAR
    )
    (defun UC_DeactivateIgnisFee:decimal ()
        @doc "Fixed IGNIS toll for owner or Cronoton deactivate (1 IGNIS minimum unit; collected in TS01-C4)."
        PYTHIA|DEACTIVATE-IGNIS-FEE
    )
    ;;
    ;;{F1}  [UR]
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun UR_AKY|Data:object{PYTHIA|S|ApiKey} (apollo-account:string)
        @doc "Full API-key row."
        (read PYTHIA|T|ApiKeys apollo-account)
    )
    (defun UR_Public:string (apollo-account:string)
        (at "public" (read PYTHIA|T|ApiKeys apollo-account ["public"]))
    )
    (defun UR_IsActivated:bool (apollo-account:string)
        (at "activated" (read PYTHIA|T|ApiKeys apollo-account ["activated"]))
    )
    (defun UR_ConsumerLane:string (apollo-account:string)
        (at "consumer-lane" (read PYTHIA|T|ApiKeys apollo-account ["consumer-lane"]))
    )
    (defun UR_OwnerAccount:string (apollo-account:string)
        (at "owner-account" (read PYTHIA|T|ApiKeys apollo-account ["owner-account"]))
    )
    (defun UR_RegisteredAt:time (apollo-account:string)
        (at "registered-at" (read PYTHIA|T|ApiKeys apollo-account ["registered-at"]))
    )
    (defun UR_UpdatedAt:time (apollo-account:string)
        (at "updated-at" (read PYTHIA|T|ApiKeys apollo-account ["updated-at"]))
    )
    (defun UR_ApiKeyRow:object{PYTHIA|S|ApiKey} (apollo-account:string)
        @doc "Full row (module-only typed accessor; interface uses UR_ApiKeyRowOrNull)."
        (UR_AKY|Data apollo-account)
    )
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string)
        @doc "Like UR_AKY|Data but returns is-registered:false when absent."
        (if (= (try false (UR_AKY|Data apollo-account)) false)
            (UDC_AKY|Unregistered)
            (UDC_AKY|WithRegisteredFlag (UR_AKY|Data apollo-account))
        )
    )
    ;;
    ;;{F2}  [UDC]
    (defun UDC_AKY|ApiKey:object{PYTHIA|S|ApiKey}
        ( public:string
          consumer-lane:string
          activated:bool
          owner-account:string
          registered-at:time
          updated-at:time
          apollo-account:string )
        { "public"         : public
        , "consumer-lane"  : consumer-lane
        , "activated"      : activated
        , "owner-account"  : owner-account
        , "registered-at"  : registered-at
        , "updated-at"     : updated-at
        , "apollo-account" : apollo-account
        }
    )
    (defun UDC_AKY|Unregistered:object ()
        @doc "Sentinel for UR_ApiKeyRowOrNull when apollo-account is absent."
        { "apollo-account" : ""
        , "public"         : ""
        , "consumer-lane"  : ""
        , "activated"      : false
        , "owner-account"  : ""
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "is-registered"  : false
        }
    )
    (defun UDC_AKY|WithRegisteredFlag:object (row:object{PYTHIA|S|ApiKey})
        (+ row { "is-registered": true })
    )
    ;;
    ;;{FW}  [W]
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun WI_ApiKey:string
        (apollo-account:string row:object{PYTHIA|S|ApiKey})
        @doc "Insert PYTHIA|T|ApiKeys full row (deploy only)."
        (require-capability (SECURE))
        (insert PYTHIA|T|ApiKeys apollo-account row)
    )
    ;; WW_ApiKey — not used: issue path is WI_ApiKey only.
    ;; WU_ApiKey|Public — not mutable [.]
    ;; WU_ApiKey|OwnerAccount — not mutable [.]
    ;; WU_ApiKey|RegisteredAt — not mutable [.]
    ;; WU_ApiKey|ApolloAccount — select key; WU not needed.
    (defun WU_ApiKey|Activated:string
        (apollo-account:string activated:bool)
        @doc "Update activated on PYTHIA|T|ApiKeys."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account {"activated": activated})
    )
    (defun WU_ApiKey|ConsumerLane:string
        (apollo-account:string consumer-lane:string)
        @doc "Update consumer-lane on PYTHIA|T|ApiKeys."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account {"consumer-lane": consumer-lane})
    )
    (defun WU_ApiKey|UpdatedAt:string
        (apollo-account:string updated-at:time)
        @doc "Update updated-at on PYTHIA|T|ApiKeys."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account {"updated-at": updated-at})
    )
    (defun WU2_ApiKey|Activated&UpdatedAt:string
        (apollo-account:string activated:bool updated-at:time)
        @doc "Update activated + updated-at on PYTHIA|T|ApiKeys."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account
            {"activated": activated, "updated-at": updated-at}
        )
    )
    (defun WU2_ApiKey|ConsumerLane&UpdatedAt:string
        (apollo-account:string consumer-lane:string updated-at:time)
        @doc "Update consumer-lane + updated-at on PYTHIA|T|ApiKeys."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account
            {"consumer-lane": consumer-lane, "updated-at": updated-at}
        )
    )
    ;;
    ;; [2] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    ;; WI_Config — not used: first row touch is WW_Config (upsert path).
    (defun WW_Config:string
        (deploy-price:decimal rename-price:decimal)
        @doc "Upsert PYTHIA|T|Config price row."
        (require-capability (SECURE))
        (write PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price": deploy-price, "rename-price": rename-price}
        )
    )
    ;;
    ;;{F3}  [URD]
    (defun URD_ApiKeyCount:integer ()
        (length (keys PYTHIA|T|ApiKeys))
    )
    (defun URD_ApiKeyCountStr:string ()
        (format "Pythia API keys registered: {}" [(URD_ApiKeyCount)])
    )
    (defun URD_ListAllApiKeys:[object] ()
        @doc "All registered API keys (active + inactive) — Pythia website directory."
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "consumer-lane" "activated" "owner-account"
              "registered-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URD_ListActivatedApiKeys:[object] ()
        @doc "Activated API keys only — Pythia website directory."
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "consumer-lane" "activated" "owner-account"
              "registered-at" "updated-at" ]
            (where "activated" (= true))
        )
    )
    (defun URD_ListInactiveApiKeys:[object] ()
        @doc "Inactive API keys only — Pythia website directory."
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "consumer-lane" "activated" "owner-account"
              "registered-at" "updated-at" ]
            (where "activated" (= false))
        )
    )
    ;;
    ;;{F4}  [URC]
    (defun URC_IsStandardApollo:bool (apollo-account:string)
        (UC_IsStandardApollo apollo-account)
    )
    (defun URC_IsActivatedOrFalse:bool (apollo-account:string)
        @doc "Hot-path grant check: false when key is absent (no throw)."
        (with-default-read PYTHIA|T|ApiKeys apollo-account
            {"activated" : false}
            {"activated" := iz}
            iz
        )
    )
    (defun URC_ActivatedSet:[string] ()
        @doc "Activated apollo-account strings for Pythia cache mirror."
        (map
            (lambda (row:object) (at "apollo-account" row))
            (select PYTHIA|T|ApiKeys ["apollo-account"] (where "activated" (= true)))
        )
    )
    ;;
    ;;{F5}  [UEV]
    ;;{F6}  [CAP]
    ;;{F7}  [A]
    (defun A_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string )
        @doc "Demiurgoi deploys inert Smart (Π.) API-key row (activated false). STOA fee collected in TS01-C4."
        (UEV_IMC)
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (with-capability
                (PYTHIA|A>DEPLOY-SMART-API-KEY owner-account apollo-account public consumer-lane)
                (WI_ApiKey apollo-account
                    (UDC_AKY|ApiKey public consumer-lane false owner-account now now apollo-account)
                )
            )
        )
        (format "Pythia Smart API key {} registered (inactive) for lane {}" [apollo-account consumer-lane])
    )
    (defun A_ActivateApiKey:string (apollo-account:string)
        @doc "Cronoton activates API key after off-chain Apollo ownership proof."
        (UEV_IMC)
        (with-capability (PYTHIA|A>ACTIVATE-API-KEY apollo-account)
            (WU2_ApiKey|Activated&UpdatedAt apollo-account true (at "block-time" (chain-data)))
        )
        (format "Pythia API key {} activated" [apollo-account])
    )
    (defun A_DeactivateApiKey:string (apollo-account:string)
        @doc "Cronoton deactivates (revokes) API key."
        (UEV_IMC)
        (with-capability (PYTHIA|A>DEACTIVATE-API-KEY apollo-account)
            (WU2_ApiKey|Activated&UpdatedAt apollo-account false (at "block-time" (chain-data)))
        )
        (format "Pythia API key {} deactivated" [apollo-account])
    )
    (defun A_UpdateDeployPrice:string (new-price:decimal)
        @doc "Demiurgoi sets deploy toll (STOA collected in TS01-C4)."
        (UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config new-price (UC_RenamePrice))
            )
        )
        (format "Pythia deploy price set to {}" [new-price])
    )
    (defun A_UpdateRenamePrice:string (new-price:decimal)
        @doc "Demiurgoi sets consumer-lane rename toll (STOA collected in TS01-C4)."
        (UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config (UC_DeployPrice) new-price)
            )
        )
        (format "Pythia rename price set to {}" [new-price])
    )
    ;;
    ;;{F8}  [C]
    (defun C_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string )
        @doc "Owner inserts inert Standard (₱.) API-key row (activated false). Fee in TS01-C4."
        (UEV_IMC)
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (with-capability
                (PYTHIA|C>DEPLOY-STANDARD-API-KEY owner-account apollo-account public consumer-lane)
                (WI_ApiKey apollo-account
                    (UDC_AKY|ApiKey public consumer-lane false owner-account now now apollo-account)
                )
            )
        )
        (format "Pythia Standard API key {} registered (inactive) for lane {}" [apollo-account consumer-lane])
    )
    (defun C_DeactivateApiKey:string (owner-account:string apollo-account:string)
        @doc "Owner deactivates their API key."
        (UEV_IMC)
        (with-capability (PYTHIA|C>DEACTIVATE-API-KEY owner-account apollo-account)
            (WU2_ApiKey|Activated&UpdatedAt apollo-account false (at "block-time" (chain-data)))
        )
        (format "Pythia API key {} deactivated by owner" [apollo-account])
    )
    (defun C_UpdateApiConsumerName:string
        ( owner-account:string
          apollo-account:string
          new-name:string )
        @doc "Owner renames consumer-lane. Fee in TS01-C4."
        (UEV_IMC)
        (with-capability (PYTHIA|C>UPDATE-NAME owner-account apollo-account new-name)
            (WU2_ApiKey|ConsumerLane&UpdatedAt
                apollo-account new-name (at "block-time" (chain-data))
            )
        )
        (format "Pythia API key {} lane renamed to {}" [apollo-account new-name])
    )
    ;;
    (defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string )
        @doc "ClientInfo preview for TS01-C4 PYTHIA|C_DeployApiKey and PYTHIA|A_DeploySmartApiKey (STOA only)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (deploy-fee:decimal (UC_DeployPrice))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
                (kind:string
                    (if (UC_IsStandardApollo apollo-account) "Standard (₱.)" "Smart (Π.)")
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploy {} Pythia API key for lane {}." [kind consumer-lane])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "Native STOA deploy fee: {} (full price; Elite discounts do not apply)." [deploy-fee])
                ]
                [(format "Pythia {} API key registered (inactive) for lane {}." [kind consumer-lane])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_KadenaCosts (UC_FeeDiscountAnchor) deploy-fee)
                []
            )
        )
    )
    (defun PYTHIA|INFO_DeactivateApiKey:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          apollo-account:string )
        @doc "ClientInfo preview for TS01-C4 PYTHIA|C_DeactivateApiKey and PYTHIA|A_DeactivateApiKey."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (deact-fee:decimal (UC_DeactivateIgnisFee))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (owner-account:string (UR_OwnerAccount apollo-account))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deactivate Pythia API key {}." [apollo-account])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "IGNIS fee: {} (minimum unit)." [deact-fee])
                ]
                [(format "Pythia API key {} deactivated." [apollo-account])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron deact-fee)
                )
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun PYTHIA|INFO_UpdateApiConsumerName:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string )
        @doc "ClientInfo preview for TS01-C4 PYTHIA|C_UpdateApiConsumerName."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (rename-fee:decimal (UC_RenamePrice))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Rename Pythia API key consumer-lane to {}." [new-name])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "Native STOA rename fee: {} (full price; Elite discounts do not apply)." [rename-fee])
                ]
                [(format "Pythia API key lane renamed to {}." [new-name])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_KadenaCosts (UC_FeeDiscountAnchor) rename-fee)
                []
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table PYTHIA|T|ApiKeys)
(create-table PYTHIA|T|Config)
