(module CADUCEUS GOV
    @doc "Barebones Stage 2 Citizen module scaffold for Caduceus bridge."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CADUCEUS                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|CADUCEUS_ADMIN)))
    (defcap GOV|CADUCEUS_ADMIN ()
        (enforce-guard GOV|MD_CADUCEUS)
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CADUCEUS|SC_NAME ()                      (at 0 ["CADUCEUS_SMART_ACCOUNT_PLACEHOLDER"]))
    (defun GOV|CADUCEUS|PBL ()                          (at 0 ["CADUCEUS_PUBLIC_KEY_PLACEHOLDER"]))

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
    ;;
    ;; Placeholders to be set by you.
    (defconst CADUCEUS|SC_NAME                          (GOV|CADUCEUS|SC_NAME))
    (defconst CADUCEUS|PBL                              (GOV|CADUCEUS|PBL))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
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
    ;;
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
(module CADUCEUS GOV
    @doc "Caduceus bridge controller for DPTF mint/burn flows."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CADUCEUS                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CADUCEUS_ADMIN)))
    (defcap GOV|CADUCEUS_ADMIN ()
        (enforce-guard GOV|MD_CADUCEUS)
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

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
    (defconst CFG_KEY                                   "bridge")
    ;;{3.2}  schemas
    ;;
    ;;
    (defschema CADUCEUS|ConfigSchema
        bridge-account:string
        bridge-stoa:string
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
    ;;{3.3}  tables
    (deftable CADUCEUS|ConfigTable:{CADUCEUS|ConfigSchema}) ;; Key = "bridge"
    (deftable CADUCEUS|SignalTable:{CADUCEUS|SignalSchema}) ;; Key = signal-id

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;; Oracle capability for bridge relayer keyset.
    (defcap BRIDGE|RELAYER ()
        (enforce-guard (keyset-ref-guard (CT_BridgeKey)))
    )
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_BridgeKey ()                              (+ (CT_Namespace) ".dh_bridge_caduceus-keyset"))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
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
    ;;{5.4}  Validate [UEV/CAP]
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
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    (defun A_SetBridgeConfig
        (
            bridge-account:string
            bridge-stoa:string
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
                    ,"bridge-stoa"   : bridge-stoa
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                )
                (UEV_Ready)
                (ref-TS01-C1::C_DALOS|DeploySmartAccount
                    (UR_BridgeAccount)
                    guard
                    (at "bridge-stoa" (read CADUCEUS|ConfigTable CFG_KEY ["bridge-stoa"]))
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                [
                    ;;#N2 fix: bridge-account is CADUCEUS's own system smart account (not
                    ;;patron's) - admin variant (TS01-A, no ownership check on <account>),
                    ;;replaces the self-service C_DPTF|DeployAccount (TS01-C1), which now
                    ;;requires the caller to own <account>. Running this still requires
                    ;;holding both GOV|CADUCEUS_ADMIN and TS01-A's own admin keyset.
                    (ref-TS01-A::A_DPTF|DeployAccount patron dptf-id bridge-account)
                    (ref-TS01-C1::C_DPTF|ToggleMintRole patron dptf-id bridge-account true)
                    (ref-TS01-C1::C_DPTF|ToggleBurnRole patron dptf-id bridge-account true)
                    (ref-TS01-C1::C_DPTF|ToggleTransferRole patron dptf-id bridge-account true)
                ]
            )
        )
    )
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                (UEV_Active)
                (UEV_FreshSignal signal-id)
                (ref-TS01-C1::C_DPTF|Mint patron dptf-id bridge-account amount false)
                (ref-TS01-C1::C_DPTF|Transfer patron dptf-id bridge-account receiver amount true)
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (patron:string (UR_Patron))
                    (dptf-id:string (UR_DptfId))
                    (bridge-account:string (UR_BridgeAccount))
                )
                (UEV_Ready)
                (UEV_Active)
                (UEV_FreshSignal signal-id)
                (ref-TS01-C1::C_DPTF|Burn patron dptf-id bridge-account amount)
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

)
