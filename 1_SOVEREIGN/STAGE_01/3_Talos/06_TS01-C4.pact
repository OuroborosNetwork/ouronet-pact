;; TS01-C4 — Talos Stage One Client Four (CODEX + PYTHIA dual-Apollo + Pyth ledger flush).
;; Deploy: load THIS file — TalosStageOne_ClientFourV7 + TS01-C4 module ship together.
;; Historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact (ClientFour V1–V5 + V6BlockTime).
;; Prior live ClientFourV6 lived only in this file (superseded by V7 — patronless A_RevokeLink).
;; Prerequisite: PYTHIA module deployed (22_PYTHIA.pact ships PythiaV4 + PythiaLedgerV2).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;;
(interface TalosStageOne_ClientFourV7
    @doc "Talos Stage One Client Four V7 — patronless Cronoton A_RevokeLink (no IGNIS); C_RevokeLink still 1 IGNIS."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun PYTHIA|C_UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun PYTHIA|C_Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string))
    (defun PYTHIA|C_RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun PYTHIA|A_RevokeLink:string (dual-link-key:string))
    (defun PYTHIA|A_Flush:string
        (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}]))
    ;;#17H fix: PYTHIA|A_UpdateDeployPrice/A_UpdateRenamePrice were never wired into any Talos
    ;;module - the core PYTHIA functions (GOV|PYTHIA_ADMIN-gated) existed but had no reachable
    ;;client path, permanently frozen at their hardcoded defaults for anyone, even the admin.
    (defun PYTHIA|A_UpdateDeployPrice:string (new-price:decimal))
    (defun PYTHIA|A_UpdateRenamePrice:string (new-price:decimal))
)
;;
(module TS01-C4 GOV
    @doc "TALOS Client Module for Stage 1 — CODEX + PYTHIA (Apollo keys + Pyth ledger flush)."
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageOne_ClientFourV7)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_TS01-C4        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()    (enforce-guard GOV|MD_TS01-C4))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
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
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|CODEX:module{OuronetPolicyV1} CODEX)
                (ref-P|PYTHIA:module{OuronetPolicyV1} PYTHIA)
                (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|CODEX::P|A_AddIMP mg)
            (ref-P|PYTHIA::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
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
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
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
    ;;
    ;;{F5}  [A]
    (defun CODEX|A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Mnemosyne operator registers a codex identity (CODEX|ADMIN on core module)."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV1} CODEX)
                )
                (ref-CODEX::A_RegisterCodexIdentity
                    codex-id public-standard public-smart codex-guard registered-by
                )
            )
        )
    )
    ;;{F6}  [C]
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard for <codex-id>."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV1} CODEX)
                )
                (ref-CODEX::C_RotateCodexGuard codex-id new-codex-guard)
            )
        )
    )
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append Arweave upload audit row for <codex-id>."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV1} CODEX)
                )
                (ref-CODEX::C_RecordArweaveUpload codex-id arweave-tx-id uploaded-bytes)
            )
        )
    )
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string)
        @doc "Register StoicTag; STOA from patron Stoa, Elite discount from account-address (STOA|C_CollectWTEx trigger false)."
        (with-capability (P|TS)
            (let
                (
                    (ref-CODEX:module{CodexV1} CODEX)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-IGNIS|V2:module{IgnisCollectorV2} IGNIS)
                    (stoa-fee:decimal (ref-CODEX::UC_StoicTagStoaFee tag-name))
                    (msg:string
                        (ref-CODEX::C_RegisterStoicTag tag-name account-address)
                    )
                )
                (ref-IGNIS|V2::STOA|C_CollectWTEx patron account-address stoa-fee false)
                msg
            )
        )
    )
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string)
        @doc "Release StoicTag; collects UC_StoicTagStoaFee(tag-name) as IGNIS (1 per glyph) from patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-CODEX:module{CodexV1} CODEX)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (tag-fee:decimal (ref-CODEX::UC_StoicTagStoaFee tag-name))
                    (msg:string (ref-CODEX::C_ReleaseStoicTag tag-name))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        tag-fee
                        patron
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                msg
            )
        )
    )
    (defun PYTHIA|C_DeployApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string )
        @doc "Deploy inert Apollo half (₱. or Π.); collects UC_DeployPrice native STOA (500 default)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV4} PYTHIA)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-IGNIS|V2:module{IgnisCollectorV2} IGNIS)
                    (deploy-fee:decimal (ref-PYTHIA::UC_DeployPrice))
                    (fee-anchor:string (ref-PYTHIA::UC_FeeDiscountAnchor))
                    (msg:string
                        (ref-PYTHIA::C_DeployApolloPythiaApiKey
                            owner-account apollo-account public
                        )
                    )
                )
                (ref-IGNIS|V2::STOA|C_CollectWTEx patron fee-anchor deploy-fee false)
                msg
            )
        )
    )
    (defun PYTHIA|C_UpdateDualConsumerLane:string
        ( patron:string
          dual-link-key:string
          new-name:string )
        @doc "Rename Pythia dual-link consumer-lane; collects UC_RenamePrice native STOA."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV4} PYTHIA)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-IGNIS|V2:module{IgnisCollectorV2} IGNIS)
                    (rename-fee:decimal (ref-PYTHIA::UC_RenamePrice))
                    (fee-anchor:string (ref-PYTHIA::UC_FeeDiscountAnchor))
                    (msg:string
                        (ref-PYTHIA::C_UpdateDualConsumerLane
                            dual-link-key new-name
                        )
                    )
                )
                (ref-IGNIS|V2::STOA|C_CollectWTEx patron fee-anchor rename-fee false)
                msg
            )
        )
    )
    (defun PYTHIA|C_Link:string
        ( standard-apollo:string
          smart-apollo:string
          consumer-lane:string )
        @doc "Both half-owners link deployed Standard+Smart halves into inactive dual row (no fee)."
        (with-capability (P|TS)
            (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
                (ref-PYTHIA::C_LinkDualApiKey standard-apollo smart-apollo consumer-lane)
            )
        )
    )
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string)
        @doc "Cronoton activates dual link after off-chain Apollo proof (no fee)."
        (with-capability (P|TS)
            (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
                (ref-PYTHIA::A_LinkDualApiKey standard-apollo smart-apollo)
            )
        )
    )
    (defun PYTHIA|C_RevokeLink:string
        ( patron:string
          dual-link-key:string )
        @doc "Both half-owners revoke active dual link; collects UC_RevokeIgnisFee IGNIS from patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV4} PYTHIA)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (revoke-fee:decimal (ref-PYTHIA::UC_RevokeIgnisFee))
                    (msg:string
                        (ref-PYTHIA::C_RevokeDualLink dual-link-key)
                    )
                )
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        revoke-fee
                        patron
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                msg
            )
        )
    )
    (defun PYTHIA|A_RevokeLink:string (dual-link-key:string)
        @doc "Cronoton revokes active dual link (no fee; patronless)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV4} PYTHIA)
                )
                (ref-PYTHIA::A_RevokeDualLink dual-link-key)
            )
        )
    )
    (defun PYTHIA|A_Flush:string
        (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
        @doc "Khronoton batch Pyth ledger flush (order-independent day entries; no fee)."
        (with-capability (P|TS)
            (let
                (
                    (ref-LEDGER:module{PythiaLedgerV2} PYTHIA)
                )
                (ref-LEDGER::A_Flush entries)
            )
        )
    )
    (defun PYTHIA|A_UpdateDeployPrice:string (new-price:decimal)
        @doc "Updates the PYTHIA Codex/Apollo deploy price (no fee)."
        (with-capability (P|TS)
            (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
                (ref-PYTHIA::A_UpdateDeployPrice new-price)
            )
        )
    )
    (defun PYTHIA|A_UpdateRenamePrice:string (new-price:decimal)
        @doc "Updates the PYTHIA Codex/Apollo rename price (no fee)."
        (with-capability (P|TS)
            (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
                (ref-PYTHIA::A_UpdateRenamePrice new-price)
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
