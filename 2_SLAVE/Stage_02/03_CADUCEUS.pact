(module CADUCEUS GOV
    @doc "Barebones Stage 2 Slave module scaffold for Caduceus bridge."
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_CADUCEUS                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;
    ;;{G2}
    (defcap GOV ()                           (compose-capability (GOV|CADUCEUS_ADMIN)))
    (defcap GOV|CADUCEUS_ADMIN ()
        (enforce-guard GOV|MD_CADUCEUS)
    )
    ;;
    ;;{G3}
    (defun GOV|NS_Use ()                     (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|Demiurgoi ()                  (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;; Placeholders to be set by you.
    (defconst CADUCEUS|SC_NAME               (GOV|CADUCEUS|SC_NAME))
    (defconst CADUCEUS|PBL                   (GOV|CADUCEUS|PBL))
    (defun GOV|CADUCEUS|SC_NAME ()           (at 0 ["CADUCEUS_SMART_ACCOUNT_PLACEHOLDER"]))
    (defun GOV|CADUCEUS|PBL ()               (at 0 ["CADUCEUS_PUBLIC_KEY_PLACEHOLDER"]))
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)
(module CADUCEUS GOV
    @doc "Caduceus bridge controller for DPTF mint/burn flows."
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_CADUCEUS               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|CADUCEUS_ADMIN)))
    (defcap GOV|CADUCEUS_ADMIN ()
        (enforce-guard GOV|MD_CADUCEUS)
    )
    ;; Oracle capability for bridge relayer keyset.
    (defcap BRIDGE|RELAYER ()
        (enforce-guard (keyset-ref-guard (GOV|BridgeKey)))
    )
    ;;{G3}
    (defun GOV|NS_Use ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|BridgeKey ()                 (+ (GOV|NS_Use) ".dh_bridge_caduceus-keyset"))
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
    (defschema CADUCEUS|ConfigSchema
        bridge-account:string
        bridge-kadena:string
        bridge-sovereign:string
        bridge-public:string
        dptf-id:string
        patron:string
        active:bool
    )
    (defschema CADUCEUS|SignalSchema
        signal-id:string
        external-chain:string
        external-tx:string
        action:string
        receiver:string
        amount:decimal
        processed-at:time
    )
    ;;{2}
    (deftable CADUCEUS|ConfigTable:{CADUCEUS|ConfigSchema}) ;; Key = "bridge"
    (deftable CADUCEUS|SignalTable:{CADUCEUS|SignalSchema}) ;; Key = signal-id
    ;;{3}
    (defconst CFG_KEY                        "bridge")
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
    (defun UR_BridgeConfigured:bool ()
        (contains CFG_KEY (keys CADUCEUS|ConfigTable))
    )
    (defun UR_BridgeAccount:string ()
        (at "bridge-account" (read CADUCEUS|ConfigTable CFG_KEY ["bridge-account"]))
    )
    (defun UR_DptfId:string ()
        (at "dptf-id" (read CADUCEUS|ConfigTable CFG_KEY ["dptf-id"]))
    )
    (defun UR_Patron:string ()
        (at "patron" (read CADUCEUS|ConfigTable CFG_KEY ["patron"]))
    )
    (defun UR_BridgeActive:bool ()
        (at "active" (read CADUCEUS|ConfigTable CFG_KEY ["active"]))
    )
    (defun UR_SignalProcessed:bool (signal-id:string)
        (contains signal-id (keys CADUCEUS|SignalTable))
    )
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    (defun UEV_Ready:bool ()
        (let
            (
                (configured:bool (UR_BridgeConfigured))
            )
            (enforce configured "CADUCEUS bridge is not configured")
            configured
        )
    )
    (defun UEV_Active:bool ()
        (let
            (
                (active:bool (UR_BridgeActive))
            )
            (enforce active "CADUCEUS bridge is disabled")
            active
        )
    )
    (defun UEV_FreshSignal:bool (signal-id:string)
        (let
            (
                (processed:bool (UR_SignalProcessed signal-id))
            )
            (enforce (not processed) "Bridge signal already processed")
            true
        )
    )
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;{F5}  [A]
    (defun A_SetBridgeConfig
        (
            bridge-account:string
            bridge-kadena:string
            bridge-sovereign:string
            bridge-public:string
            dptf-id:string
            patron:string
            active:bool
        )
        @doc "Initial/updated CADUCEUS config. Use your bridge smart account and relayer patron."
        (with-capability (GOV|CADUCEUS_ADMIN)
            (write CADUCEUS|ConfigTable CFG_KEY
                {
                    "bridge-account"   : bridge-account
                    ,"bridge-kadena"   : bridge-kadena
                    ,"bridge-sovereign": bridge-sovereign
                    ,"bridge-public"   : bridge-public
                    ,"dptf-id"         : dptf-id
                    ,"patron"          : patron
                    ,"active"          : active
                }
            )
        )
    )
    (defun A_SetBridgeActive (active:bool)
        @doc "Pauses/unpauses bridge processing."
        (with-capability (GOV|CADUCEUS_ADMIN)
            (update CADUCEUS|ConfigTable CFG_KEY
                {"active" : active}
            )
        )
    )
    (defun A_DeployBridgeSmartAccount (guard:guard)
        @doc "Deploys the CADUCEUS bridge smart account through TS01-C1."
        (with-capability (GOV|CADUCEUS_ADMIN)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                )
                (UEV_Ready)
                (ref-TS01-C1::DALOS|C_DeploySmartAccount
                    (UR_BridgeAccount)
                    guard
                    (at "bridge-kadena" (read CADUCEUS|ConfigTable CFG_KEY ["bridge-kadena"]))
                    (at "bridge-sovereign" (read CADUCEUS|ConfigTable CFG_KEY ["bridge-sovereign"]))
                    (at "bridge-public" (read CADUCEUS|ConfigTable CFG_KEY ["bridge-public"]))
                )
            )
        )
    )
    (defun A_ProvisionBridgeDptfRoles ()
        @doc "Ensures bridge account exists on the DPTF and grants mint/burn/transfer roles."
        (with-capability (GOV|CADUCEUS_ADMIN)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                [
                    ;;#N2 fix: bridge-account is CADUCEUS's own system smart account (not
                    ;;patron's) - admin variant (TS01-A, no ownership check on <account>),
                    ;;replaces the self-service DPTF|C_DeployAccount (TS01-C1), which now
                    ;;requires the caller to own <account>. Running this still requires
                    ;;holding both GOV|CADUCEUS_ADMIN and TS01-A's own admin keyset.
                    (ref-TS01-A::DPTF|A_DeployAccount patron dptf-id bridge-account)
                    (ref-TS01-C1::DPTF|C_ToggleMintRole patron dptf-id bridge-account true)
                    (ref-TS01-C1::DPTF|C_ToggleBurnRole patron dptf-id bridge-account true)
                    (ref-TS01-C1::DPTF|C_ToggleTransferRole patron dptf-id bridge-account true)
                ]
            )
        )
    )
    ;;{F6}  [C]
    (defun C_MintToUserFromBridgeSignal
        (
            signal-id:string
            external-chain:string
            external-tx:string
            receiver:string
            amount:decimal
        )
        @doc "Bridge inbound flow: mint on bridge account, transfer to user, and mark signal as consumed."
        (with-capability (BRIDGE|RELAYER)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                (UEV_Active)
                (UEV_FreshSignal signal-id)
                (ref-TS01-C1::DPTF|C_Mint patron dptf-id bridge-account amount false)
                (ref-TS01-C1::DPTF|C_Transfer patron dptf-id bridge-account receiver amount true)
                (write CADUCEUS|SignalTable signal-id
                    {
                        "signal-id"      : signal-id
                        ,"external-chain": external-chain
                        ,"external-tx"   : external-tx
                        ,"action"        : "mint"
                        ,"receiver"      : receiver
                        ,"amount"        : amount
                        ,"processed-at"  : (at "block-time" (chain-data))
                    }
                )
                (format "Bridge mint signal {} processed" [signal-id])
            )
        )
    )
    (defun C_BurnFromBridgeSignal
        (
            signal-id:string
            external-chain:string
            external-tx:string
            amount:decimal
        )
        @doc "Bridge outbound flow: burn from bridge account and mark signal as consumed."
        (with-capability (BRIDGE|RELAYER)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                (UEV_Active)
                (UEV_FreshSignal signal-id)
                (ref-TS01-C1::DPTF|C_Burn patron dptf-id bridge-account amount)
                (write CADUCEUS|SignalTable signal-id
                    {
                        "signal-id"      : signal-id
                        ,"external-chain": external-chain
                        ,"external-tx"   : external-tx
                        ,"action"        : "burn"
                        ,"receiver"      : bridge-account
                        ,"amount"        : amount
                        ,"processed-at"  : (at "block-time" (chain-data))
                    }
                )
                (format "Bridge burn signal {} processed" [signal-id])
            )
        )
    )
    ;;{F7}  [X]
    ;;
)
