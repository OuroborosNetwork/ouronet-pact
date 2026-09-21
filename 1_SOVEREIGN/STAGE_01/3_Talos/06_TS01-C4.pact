;; TS01-C4 — Talos Stage One Client Four (CODEX + PYTHIA dual-Apollo + Pyth ledger flush).
;; Deploy: load THIS file — TalosStageOne_ClientFourV8 + TS01-C4 module ship together.
;; Historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact — EMPTY; the frozen-copy
;; convention was retired 2026-09-02 (StoicSyntax §7.10). ClientFour V1–V6 live in git only.
;; Prior live ClientFourV6 lived only in this file (superseded by V7 — patronless A_RevokeLink).
;; Prerequisite: PYTHIA module deployed (22_PYTHIA.pact ships PythiaV5 + PythiaLedgerV3).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;;
;; net: v7   ·   dev: v8   ;; bumped by the StoicSyntax refactor — deploy v8 then set net: v8
(interface TalosStageOne_ClientFourV8
    @doc "Talos Stage One Client Four V7 — patronless Cronoton A_RevokeLink (no IGNIS); C_RevokeLink still 1 IGNIS."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        (
            executor:string
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun CODEX|C_RotateCodexGuard:string (patron:string executor:string codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (patron:string executor:string codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string executor:string tag-name:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string executor:string tag-name:string))
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
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}]))
    ;;#17H fix: PYTHIA|A_UpdateDeployPrice/A_UpdateRenamePrice were never wired into any Talos
    ;;module - the core PYTHIA functions (GOV|PYTHIA_ADMIN-gated) existed but had no reachable
    ;;client path, permanently frozen at their hardcoded defaults for anyone, even the admin.
    (defun PYTHIA|A_UpdateDeployPrice:string (new-price:decimal))
    (defun PYTHIA|A_UpdateRenamePrice:string (new-price:decimal))

)
;;
(module TS01-C4 GOV
    @doc "TALOS Client Module for Stage 1 — CODEX + PYTHIA (Apollo keys + Pyth ledger flush)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientFourV8)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C4                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C4))
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
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-C1_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|TS01-C1_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|TS01-C1_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|CODEX:module{OuronetPolicyV2} CODEX)
                (ref-P|PYTHIA:module{OuronetPolicyV2} PYTHIA)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|CODEX::P|A_AddIMP mg)
            (ref-P|PYTHIA::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        ( executor:string
          codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Mnemosyne operator registers a codex identity (CODEX|ADMIN on core module)."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV2} CODEX)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                ;;THE GASLESS PATRON, RESOLVED LOCALLY. `GASLESS-PATRON` is a defconst in
                ;;01_TS01-A, not something every Talos module has -- writing the bare name here
                ;;made Pact read it as a MODULE reference and the whole file stopped loading
                ;;("Cannot find module: ouronet-ns.GASLESS-PATRON"). It is exactly what TS01-A's
                ;;URC_Gassless returns, so it is read from the same source rather than
                ;;re-declared: one definition, no chance of the two drifting.
                (ref-CODEX::A_RegisterCodexIdentity
                    (ref-DALOS::GOV|DALOS|SC_NAME) executor
                    codex-id public-standard public-smart codex-guard registered-by
                )
            )
        )
    )
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string)
        @doc "Cronoton activates dual link after off-chain Apollo proof (no fee)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                )
                (ref-PYTHIA::A_LinkDualApiKey standard-apollo smart-apollo)
            )
        )
    )
    (defun PYTHIA|A_RevokeLink:string (dual-link-key:string)
        @doc "Cronoton revokes active dual link (no fee; patronless)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                )
                (ref-PYTHIA::A_RevokeDualLink dual-link-key)
            )
        )
    )
    (defun PYTHIA|A_Flush:string
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Khronoton batch Pyth ledger flush (order-independent day entries; no fee)."
        (with-capability (P|TS)
            (let
                (
                    (ref-LEDGER:module{PythiaLedgerV3} PYTHIA)
                )
                (ref-LEDGER::A_Flush entries)
            )
        )
    )
    (defun PYTHIA|A_UpdateDeployPrice:string (new-price:decimal)
        @doc "Updates the PYTHIA Codex/Apollo deploy price (no fee)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                )
                (ref-PYTHIA::A_UpdateDeployPrice new-price)
            )
        )
    )
    (defun PYTHIA|A_UpdateRenamePrice:string (new-price:decimal)
        @doc "Updates the PYTHIA Codex/Apollo rename price (no fee)."
        (with-capability (P|TS)
            (let
                (
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                )
                (ref-PYTHIA::A_UpdateRenamePrice new-price)
            )
        )
    )
    (defun CODEX|C_RotateCodexGuard:string (patron:string executor:string codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard for <codex-id>."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV2} CODEX)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (let ((msg:string (ref-CODEX::C_RotateCodexGuard patron executor codex-id new-codex-guard)))
                    (ref-IGNIS::XE_CollectIgnis patron (ref-CODEX::URCi_RotateCodexGuard patron))
                    msg
                )
            )
        )
    )
    (defun CODEX|C_RecordArweaveUpload:string (patron:string executor:string codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append Arweave upload audit row for <codex-id>."
        (with-capability (P|TS)
            (let 
                (
                    (ref-CODEX:module{CodexV2} CODEX)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (let ((msg:string (ref-CODEX::C_RecordArweaveUpload patron executor codex-id arweave-tx-id uploaded-bytes)))
                    (ref-IGNIS::XE_CollectIgnis patron (ref-CODEX::URCi_RecordArweaveUpload patron))
                    msg
                )
            )
        )
    )
    (defun CODEX|C_RegisterStoicTag:string (patron:string executor:string tag-name:string)
        @doc "Register StoicTag; STOA from patron Stoa, Elite discount from account-address (XB_CollectStoaDiscountedFrom trigger false)."
        (with-capability (P|TS)
            (let
                (
                    (ref-CODEX:module{CodexV2} CODEX)
                    (ref-IGNIS|V2:module{IgnisCollectorV3} IGNIS)
                    (stoa-fee:decimal (ref-CODEX::URCi_RegisterStoicTag tag-name))
                    (msg:string
                        (ref-CODEX::C_RegisterStoicTag patron executor tag-name)
                    )
                )
                (ref-IGNIS|V2::XB_CollectStoaDiscountedFrom patron executor stoa-fee false)
                msg
            )
        )
    )
    (defun CODEX|C_ReleaseStoicTag:string (patron:string executor:string tag-name:string)
        @doc "Release StoicTag; collects UC_StoicTagStoaFee(tag-name) as IGNIS (1 per glyph) from patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-CODEX:module{CodexV2} CODEX)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (tag-fee:decimal (ref-CODEX::URCi_ReleaseStoicTag tag-name))
                    (msg:string (ref-CODEX::C_ReleaseStoicTag patron executor tag-name))
                )
                (ref-IGNIS::XE_CollectIgnis patron
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
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                    (ref-IGNIS|V2:module{IgnisCollectorV3} IGNIS)
                    (deploy-fee:decimal (ref-PYTHIA::URCi_DeployApiKey))
                    (fee-anchor:string (ref-PYTHIA::UC_FeeDiscountAnchor))
                    (msg:string
                        (ref-PYTHIA::C_DeployApolloPythiaApiKey
                            owner-account apollo-account public
                        )
                    )
                )
                (ref-IGNIS|V2::XB_CollectStoaFull patron deploy-fee false)   ;;PYTHIA fees are NON-discountable (spec)
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
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                    (ref-IGNIS|V2:module{IgnisCollectorV3} IGNIS)
                    (rename-fee:decimal (ref-PYTHIA::URCi_UpdateDualConsumerLane))
                    (fee-anchor:string (ref-PYTHIA::UC_FeeDiscountAnchor))
                    (msg:string
                        (ref-PYTHIA::C_UpdateDualConsumerLane
                            dual-link-key new-name
                        )
                    )
                )
                (ref-IGNIS|V2::XB_CollectStoaFull patron rename-fee false)   ;;PYTHIA fees are NON-discountable (spec)
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
            (let
                (
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                )
                (ref-PYTHIA::C_LinkDualApiKey standard-apollo smart-apollo consumer-lane)
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
                    (ref-PYTHIA:module{PythiaV5} PYTHIA)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (revoke-fee:decimal (ref-PYTHIA::URCi_RevokeLink))
                    (msg:string
                        (ref-PYTHIA::C_RevokeDualLink dual-link-key)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron
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

)

(create-table P|T)
(create-table P|MT)
