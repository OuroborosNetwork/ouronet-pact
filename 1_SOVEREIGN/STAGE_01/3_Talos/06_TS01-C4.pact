(module TS01-C4 GOV
    @doc "TALOS Client Module for Stage 1 — CODEX (Mnemosyne Codex Identity, Arweave tracker, StoicTags)."
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageOne_ClientFourV1)
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
                (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|CODEX::P|A_AddIMP mg)
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
        @doc "Register StoicTag; STOA from patron Kadena, Elite discount from account-address (KDA|C_CollectWTEx trigger false)."
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
                (ref-IGNIS|V2::KDA|C_CollectWTEx patron account-address stoa-fee false)
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
    ;;
)

(create-table P|T)
(create-table P|MT)
