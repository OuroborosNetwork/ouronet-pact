;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 9 of 24
;; This is STEP 9 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-8 must have run first, including the init steps between deploys.
;; 4 source file(s), 321,475 gas measured in the REPL gas model, 282,635 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
;;
;; TOTAL: 5 interface(s), 4 module(s), 14 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
;;      interface  PythiaV5
;;      interface  PythiaLedgerV3
;;      module     PYTHIA
;;      table      P|T
;;      table      P|MT
;;      table      PYTHIA|T|ApiKeys
;;      table      PYTHIA|T|Config
;;      table      PYTHIA|T|DualLinks
;;      table      PYTHIA|T|Revocation
;;      table      PYTHIA|T|PythDaily
;;      table      PYTHIA|T|PythTotal
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;      interface  TalosStageOne_AdminV2
;;      module     TS01-A
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
;;      interface  TalosStageOne_ClientOneV2
;;      module     TS01-C1
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
;;      interface  TalosStageOne_ClientTwoV2
;;      module     TS01-C2
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact ==================
;; PYTHIA — Apollo Pythia dual-Apollo API-key registry (Stage 01 core #23).
;; Spec: OuronetInformational/HANDOFFS/HANDOFF-pact-apollo-pythia-key-module.md
;; Deploy: load THIS file — PythiaV5 + PythiaLedgerV3 interfaces + PYTHIA module ship together.
;; Shared/historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact (PythiaV1–V3, PythiaLedger V1/V2BlockTime).
;; Talos client: 1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact (TalosStageOne_ClientFourV8 embedded).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;; Cronoton: ouronet-ns.pythia-cronoton-keyset (A_Link / A_RevokeLink / A_Flush).
;;
;; TABLES (deftable) — vs PYTHIA V1/V2 single-key model:
;;   PYTHIA|T|ApiKeys     — carryover table name; V3 schema (counterpart; no per-half consumer-lane)
;;   PYTHIA|T|Config      — carryover (deploy/rename prices)
;;   PYTHIA|T|DualLinks   — NEW V3 (pair row: lane + iz-active)
;;   PYTHIA|T|Revocation  — NEW V3 (revoked-at-height fast-lane anchor)
;;   PYTHIA|T|PythDaily   — Pyth ledger calendar-day snapshots (key = day ordinal string; iz-sealed)
;;   PYTHIA|T|PythTotal   — Pyth ledger running totals (key = "stoachain")
;;   P|T / P|MT           — standard Ouronet policy tables
;;
;; Spec (ledger): OuronetInformational/HANDOFFS/HANDOFF-pact-pyth-ledger.md
;; (create-table ...) at module bottom runs on **first module install** (greenfield).
;; You do not submit separate create-table txs. All eight fire in the PYTHIA deploy tx.
;; If PYTHIA were already on-chain at V3, only PythDaily + PythTotal are additive create-tables.
;;
;; net: v4   ·   dev: v5   ;; bumped by the StoicSyntax refactor — deploy v5 then set net: v5
(interface PythiaV5
    @doc "PYTHIA V4 — V3 dual-Apollo + Config UR prices; select-based inventory is URH_."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|CronotonKey ())

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
    ;;
    (defun UC_DeployPrice:decimal ())
    (defun UC_RenamePrice:decimal ())
    (defun UC_RevokeIgnisFee:decimal ())
    (defun UC_IsStandardApollo:bool (apollo-account:string))
    (defun UC_FeeDiscountAnchor:string ())
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string))
    (defun UC_DualLinkStandard:string (dual-link-key:string))
    (defun UC_DualLinkSmart:string (dual-link-key:string))
    (defun UC_ChainEpoch:integer (block-height:integer))
    (defun UC_CurrentChainEpoch:integer ())
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_DeployApiKey:decimal ())
    (defun URCi_UpdateDualConsumerLane:decimal ())
    (defun URCi_RevokeLink:decimal ())
    ;;
    ;; [UR] PYTHIA|S|ApiKey + DualLink + Config + Revocation
    (defun UR_Public:string (apollo-account:string))
    (defun UR_Counterpart:string (apollo-account:string))
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string))
    (defun UR_OwnerAccount:string (apollo-account:string))
    (defun UR_RegisteredAt:time (apollo-account:string))
    (defun UR_UpdatedAt:time (apollo-account:string))
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string))
    (defun UR_DualLinkIzActive:bool (dual-link-key:string))
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string))
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string))
    (defun UR_Config ())
    (defun UR_DeployPrice:decimal ())
    (defun UR_RenamePrice:decimal ())
    (defun UR_RevocationAtHeight:integer ())
    (defun UR_RevocationEpoch:integer ())
    (defun UR_ApiKeyBySlot:object (standard-apollo:string))
    ;;
    ;; [URD] — select / keys inventory
    (defun URH_ApiKeyCount:integer ())
    (defun URH_ApiKeyCountStr:string ())
    (defun URH_DualLinkCount:integer ())
    (defun URH_ListAllApiKeys:[object] ())
    (defun URH_ListAllDualLinks:[object] ())
    (defun URH_ListActiveDualLinks:[object] ())
    (defun URH_ListInactiveDualLinks:[object] ())
    (defun URH_ActiveDualLinkSet:[string] ())
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;; NOTE: INFO_PYTHIA|* previews are UI-only → NOT declared here (canon: INFO not in
    ;; interfaces); they live in the PYTHIA module's {5.3} Read block.
    ;;
    (defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string))
        ;; Cronoton: create+activate (auto PYTHIA-<hash12> lane) or flip inactive→true
    (defun A_RevokeDualLink:string (dual-link-key:string))
    (defun A_UpdateDeployPrice:string (new-price:decimal))
    (defun A_UpdateRenamePrice:string (new-price:decimal))
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun C_LinkDualApiKey:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun C_RevokeDualLink:string (dual-link-key:string))
    (defun C_UpdateDualConsumerLane:string
        (
            dual-link-key:string
            new-name:string
        ))

)
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface PythiaLedgerV3
    @doc "Pyth ledger V2 — batch flush entries (explicit day, iz-complete); order-independent txs."

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
    ;;
    (defschema PYTHIA|S|PythMetrics
        @doc "Six Pyth work counters — nested on daily and total rows."
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythFlushAcc
        @doc "Internal fold state for batch XI_FlushPythLedger."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
    (defschema PYTHIA|S|PythFlushEntry
        @doc "One calendar day in a batch A_Flush (metrics cumulative for that UTC day)."
        day:integer
        iz-complete:bool
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythDaily
        @doc "One calendar-day snapshot. Table key = day ordinal string."
        day:integer
        flushed-at:time
        iz-sealed:bool
        metrics:object{PYTHIA|S|PythMetrics}
    )
    (defschema PYTHIA|S|PythTotal
        @doc "Running totals. Key = stoachain. last-day = highest day ordinal written."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
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
    (defun UR_PythMaxFlushBatch:integer ())
    (defun UR_PythLedgerEpochStart:time ())
    (defun UR_PythCurrentDay:integer ())
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URH_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Flush:string (entries:[object{PYTHIA|S|PythFlushEntry}]))

)
;;
(module PYTHIA GOV
    @doc "Dual-Apollo Pythia registry + on-chain Pyth work ledger (daily flush / running total)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements PythiaV5)
    (implements PythiaLedgerV3)
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_PYTHIA                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|PYTHIA_ADMIN)))
    (defcap GOV|PYTHIA_ADMIN ()                         (enforce-guard GOV|MD_PYTHIA))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CronotonKey ()                           (+ (CT_Namespace) ".pythia-cronoton-keyset"))

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
    (defcap P|PYTHIA|CALLER ()
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
        (with-capability (GOV|PYTHIA_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|PYTHIA_ADMIN)
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
        (with-capability (GOV|PYTHIA_ADMIN)
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
        (with-capability (GOV|PYTHIA_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (mg:guard (create-capability-guard (P|PYTHIA|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR:string                                (CT_Bar))
    (defconst PYTHIA|EPOCH:time                         (time "1970-01-01T00:00:00Z"))
    (defconst PYTHIA|LEDGER-EPOCH-START:time            (time "2026-08-01T00:00:00Z"))
    (defconst PYTHIA|SECONDS-PER-DAY:decimal            86400.0)
    (defconst PYTHIA|APOLLO-LEN:integer                 162)
    (defconst PYTHIA|DUAL-LINK-LEN:integer              325)
    (defconst PYTHIA|INFO:string                        "config")
    (defconst PYTHIA|REVOCATION:string                  "revocation")
    (defconst PYTHIA|STOACHAIN:string                   "stoachain")
    (defconst PYTHIA|REVOKE-IGNIS-FEE:decimal           1.0)
    (defconst PYTHIA|EPOCH-BLOCKS:integer               120)
    (defconst PYTHIA|APOLLO-STANDARD:string             "₱")
    (defconst PYTHIA|APOLLO-SMART:string                "Π")
    (defconst PYTHIA|MAX-DAILY-RANGE:integer            365)
    (defconst PYTHIA|MAX-FLUSH-BATCH:integer            1000)
    ;;{3.2}  schemas
    ;;
    (defschema PYTHIA|S|ApiKey
        @doc "One Apollo half (₱. slot or Π. consumer). Table key = apollo-account."
        public:string                                   ;;[.]   Canonical Apollo public-key material
        counterpart:string                              ;;[.]   Other half; BAR until linked (immutable once set)
        owner-account:string                            ;;[.]   Ouronet DALOS account that deployed + paid
        registered-at:time                              ;;[.]   Block time at deploy
        updated-at:time                                 ;;[M]   Block time at last mutation
        ;;
        ;;Select Keys
        apollo-account:string                           ;;[.]   Apollo account string (= table key)
    )
    (defschema PYTHIA|S|DualLink
        @doc "Dual-Apollo pair. Table key = standard + BAR + smart composite (325 chars)."
        standard-apollo:string                          ;;[.]   Standard ₱. slot half
        smart-apollo:string                             ;;[.]   Smart Π. consumer half
        consumer-lane:string                            ;;[M]   Stoic lane (C_Link) or auto PYTHIA-<hash12> (A_Link create); rename via C_UpdateDualConsumerLane
        iz-active:bool                                  ;;[M]   Live auth only when true (Cronoton or pre-linked false row)
        linked-at:time                                  ;;[.]   Block time at first link insert
        updated-at:time                                 ;;[M]   Block time at last iz-active mutation
        ;;
        ;;Select Keys
        dual-link-key:string                            ;;[.]   Composite key (= table key)
    )
    (defschema PYTHIA|S|Config
        deploy-price:decimal
        rename-price:decimal
    )
    (defschema PYTHIA|S|Revocation
        @doc "Last dual-link revoke anchor: block height at revoke (epoch = floor(height / 120))."
        revoked-at-height:integer
    )
    ;;{3.3}  tables
    (deftable PYTHIA|T|ApiKeys:{PYTHIA|S|ApiKey})                       ;;Key = <apollo-account>
    (deftable PYTHIA|T|DualLinks:{PYTHIA|S|DualLink})                   ;;Key = <dual-link-key>
    (deftable PYTHIA|T|Config:{PYTHIA|S|Config})                        ;;Key = PYTHIA|INFO
    (deftable PYTHIA|T|Revocation:{PYTHIA|S|Revocation})                ;;Key = PYTHIA|REVOCATION
    (deftable PYTHIA|T|PythDaily:{PythiaLedgerV3.PYTHIA|S|PythDaily})   ;;Key = <day ordinal string>
    (deftable PYTHIA|T|PythTotal:{PythiaLedgerV3.PYTHIA|S|PythTotal})   ;;Key = PYTHIA|STOACHAIN

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;#68L fix: removed PYTHIA|FLUSH-GAS-TARGET - dead constant, confirmed zero references
    ;;anywhere; likely a leftover from an earlier gas-based batching design later replaced by
    ;;the count-based PYTHIA|MAX-FLUSH-BATCH cap. No functional change.
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap PYTHIA|CRONOTON ()                          (enforce-guard (keyset-ref-guard (GOV|CronotonKey))))
    ;;{C3}  Composed
    (defcap PYTHIA|C>DEPLOY-API-KEY
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Composes SECURE for WI_ApiKey."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (is-smart:bool (not (UC_IsStandardApollo apollo-account)))
            )
            (enforce (!= public "") "Public key material must be non-empty")
            (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account is-smart)
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>LINK-DUAL
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both Apollo half-owners link deployed halves into inactive dual row with lane label."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
            )
            (ref-U|DALOS::UEV_StoicTagName consumer-lane)
            (UEV_DualPairForLink standard-apollo smart-apollo)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard-apollo)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart-apollo)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>LINK-DUAL (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate: insert active dual row (auto lane) or flip inactive→true."
        @event
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (if row-missing
                (UEV_DualPairForLink standard-apollo smart-apollo)
                (enforce
                    (fold (and) true
                        [
                            (not (UR_DualLinkIzActive dlk))
                            (= (UR_Counterpart standard-apollo) smart-apollo)
                            (= (UR_Counterpart smart-apollo) standard-apollo)
                        ]
                    )
                    "Dual link not ready for Cronoton activate (must exist inactive with counterparts)"
                )
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>REVOKE-DUAL (dual-link-key:string)
        @doc "Both Apollo half-owners revoke active dual link (iz-active false)."
        @event
        (let
            (
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (iz-active:bool (at "iz-active" row))
            )
            (enforce iz-active "Dual link is already inactive")
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>REVOKE-DUAL (dual-link-key:string)
        @doc "Cronoton revokes active dual link (Pythia authority)."
        @event
        (let
            (
                (iz-active:bool (UR_DualLinkIzActive dual-link-key))
            )
            (enforce iz-active "Dual link is already inactive")
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>UPDATE-DUAL-LANE (dual-link-key:string new-name:string)
        @doc "Both half-owners rename consumer-lane on the dual link row."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
            )
            (ref-U|DALOS::UEV_StoicTagName new-name)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>FLUSH
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch Pyth ledger flush; each entry is one calendar day (order-independent across txs)."
        @event
        (let
            (
                (entry-count:integer (length entries))
            )
            (enforce
                (fold (and) true
                    [
                        (> entry-count 0)
                        (<= entry-count PYTHIA|MAX-FLUSH-BATCH)
                        (UEV_FlushEntries entries)
                    ]
                )
                (format "Pyth flush batch invalid or exceeds max {} entries per tx" [PYTHIA|MAX-FLUSH-BATCH])
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]
    (defcap PYTHIA|OWNER (owner-account:string)
        @doc "Caller controls the Ouronet (DALOS) account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
        )
    )

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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    ;;
    (defun UDC_AKY|ApiKey:object{PYTHIA|S|ApiKey}
        (
            public:string
            counterpart:string
            owner-account:string
            apollo-account:string
        )
        @doc "Constructor for object{PYTHIA|S|ApiKey}; WI_ApiKey stamps registered-at/updated-at."
        { "public"         : public
        , "counterpart"    : counterpart
        , "owner-account"  : owner-account
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "apollo-account" : apollo-account
        }
    )
    (defun UDC_AKY|Unregistered:object ()
        @doc "Sentinel for UR_ApiKeyRowOrNull when apollo-account is absent."
        { "apollo-account" : ""
        , "public"         : ""
        , "counterpart"    : BAR
        , "owner-account"  : ""
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "is-registered"  : false
        }
    )
    (defun UDC_AKY|WithRegisteredFlag:object (row:object{PYTHIA|S|ApiKey})
        (+ row { "is-registered": true })
    )
    (defun UDC_DLK|DualLink:object{PYTHIA|S|DualLink}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
            iz-active:bool
            dual-link-key:string
        )
        @doc "Constructor for object{PYTHIA|S|DualLink}; WI_DualLink stamps linked-at/updated-at."
        { "standard-apollo" : standard-apollo
        , "smart-apollo"    : smart-apollo
        , "consumer-lane"   : consumer-lane
        , "iz-active"       : iz-active
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "dual-link-key"   : dual-link-key
        }
    )
    (defun UDC_DLK|Unregistered:object ()
        @doc "Sentinel for UR_DualLinkRowOrNull when dual-link-key is absent."
        { "dual-link-key"   : ""
        , "standard-apollo" : ""
        , "smart-apollo"    : ""
        , "consumer-lane"   : BAR
        , "iz-active"       : false
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "is-registered"   : false
        }
    )
    (defun UDC_DLK|WithRegisteredFlag:object (row:object{PYTHIA|S|DualLink})
        (+ row { "is-registered": true })
    )
    (defun UDC_DualLinkView:object
        (
            dual-link-key:string
            standard-apollo:string
            smart-apollo:string
            iz-active:bool
            standard-owner:string
            smart-owner:string
            consumer-lane:string
        )
        @doc "Composite dual-link view (owners from ApiKeys halves)."
        { "dual-link-key"    : dual-link-key
        , "standard-apollo"  : standard-apollo
        , "smart-apollo"     : smart-apollo
        , "consumer-apollo"  : smart-apollo
        , "iz-active"        : iz-active
        , "standard-owner"   : standard-owner
        , "smart-owner"      : smart-owner
        , "consumer-lane"    : consumer-lane
        }
    )
    (defun UDC_PythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythMetrics}."
        { "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    (defun UDC_PythMetrics|Zero:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Zeroed six-metric blob."
        (UDC_PythMetrics 0 0.0 0 0 0 0)
    )
    (defun UDC_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal}
        (
            total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            last-day:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythTotal}."
        { "total-metrics": total-metrics
        , "last-day": last-day
        }
    )
    (defun UDC_PythTotal|Zero:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Zeroed Pyth running total (default before first flush)."
        (UDC_PythTotal (UDC_PythMetrics|Zero) 0)
    )
    (defun UDC_PythDaily:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        (
            day:integer
            flushed-at:time
            iz-sealed:bool
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythDaily}."
        { "day": day
        , "flushed-at": flushed-at
        , "iz-sealed": iz-sealed
        , "metrics": metrics
        }
    )
    (defun UDC_PythFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
        (
            day:integer
            iz-complete:bool
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}."
        { "day": day
        , "iz-complete": iz-complete
        , "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    ;;{5.2}  Compute [UC]
    (defun UC_DeployPrice:decimal ()
        @doc "Alias → UR_DeployPrice (kept for Talos/INFO call sites)."
        (UR_DeployPrice)
    )
    (defun UC_RenamePrice:decimal ()
        @doc "Alias → UR_RenamePrice (kept for Talos/INFO call sites)."
        (UR_RenamePrice)
    )
    (defun UC_IsStandardApollo:bool (apollo-account:string)
        @doc "True when apollo-account begins with Standard ₱. (false = Smart Π.)."
        (= PYTHIA|APOLLO-STANDARD (take 1 apollo-account))
    )
    (defun UC_FeeDiscountAnchor:string ()
        @doc "STOA fee discount anchor — BAR yields tier 0.0; Elite discounts never apply."
        BAR
    )
    (defun UC_RevokeIgnisFee:decimal ()
        @doc "Fixed IGNIS toll for owner or Cronoton dual-link revoke (1 IGNIS; collected in TS01-C4)."
        PYTHIA|REVOKE-IGNIS-FEE
    )
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string)
        @doc "Composite dual-link key: Standard ₱. + BAR + Smart Π."
        (+ standard-apollo (+ BAR smart-apollo))
    )
    (defun UC_DualLinkStandard:string (dual-link-key:string)
        @doc "Standard ₱. half of composite dual-link key."
        (take PYTHIA|APOLLO-LEN dual-link-key)
    )
    (defun UC_DualLinkSmart:string (dual-link-key:string)
        @doc "Smart Π. half of composite dual-link key."
        (drop (+ PYTHIA|APOLLO-LEN (length BAR)) dual-link-key)
    )
    (defun UC_ChainEpoch:integer (block-height:integer)
        @doc "Stoa chain epoch: block-height / 120 (int div) — matches explorer (e.g. 378734 → 3156)."
        (/ block-height PYTHIA|EPOCH-BLOCKS)
    )
    (defun UC_CurrentChainEpoch:integer ()
        @doc "Chain epoch for the executing block."
        (UC_ChainEpoch (at "block-height" (chain-data)))
    )
    (defun UC_AutonomousConsumerLane:string ()
        @doc "Token-style auto lane PYTHIA-<first 12 of prev-block-hash> via U|DALOS.UDC_Makeid; rename later via C_UpdateDualConsumerLane."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UDC_Makeid "PYTHIA")
        )
    )
    ;;
    (defun UCk_PythDaily:string (day:integer)
        @doc "PYTHIA|T|PythDaily key = decimal string of day ordinal."
        (int-to-str 10 day)
    )
    (defun UC_PythDayOrdinal:integer (stamp:time)
        @doc "Calendar operating day: 1 = PYTHIA|LEDGER-EPOCH-START (UTC midnight boundary)."
        (+ 1 (floor (/ (diff-time stamp PYTHIA|LEDGER-EPOCH-START) PYTHIA|SECONDS-PER-DAY)))
    )
    (defun UC_AddPythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            a:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            b:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Element-wise sum — A_Flush ADDs each entry (gateway drain delta) onto day row and grand total."
        { "petitions": (+ (at "petitions" a) (at "petitions" b))
        , "pondus": (+ (at "pondus" a) (at "pondus" b))
        , "transactions": (+ (at "transactions" a) (at "transactions" b))
        , "gas-reserved": (+ (at "gas-reserved" a) (at "gas-reserved" b))
        , "failed-transactions": (+ (at "failed-transactions" a) (at "failed-transactions" b))
        , "wasted-gas-reserved": (+ (at "wasted-gas-reserved" a) (at "wasted-gas-reserved" b))
        }
    )
    (defun UC_FlushAccFromTotal:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Seed batch fold from current PYTHIA|T|PythTotal row."
        { "total-metrics": (at "total-metrics" tot)
        , "last-day": (at "last-day" tot) }
    )
    (defun UC_FlushEntryMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
        @doc "Extract six-metric blob from a flush entry."
        (UDC_PythMetrics
            (at "petitions" entry)
            (at "pondus" entry)
            (at "transactions" entry)
            (at "gas-reserved" entry)
            (at "failed-transactions" entry)
            (at "wasted-gas-reserved" entry)
        )
    )
    (defun UC_MaxDay:integer (a:integer b:integer)
        @doc "Greater of two day ordinals."
        (if (> a b) a b)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_DeployApiKey:decimal ()
        @doc "Cost single-source for PYTHIA|C_DeployApiKey — RAW native STOA toll \
            \ (UC_DeployPrice, default 500). Discount anchor is BAR (no Elite discount). \
            \ Consumed by TS01-C4 exec collect + INFO preview."
        (UC_DeployPrice)
    )
    (defun URCi_UpdateDualConsumerLane:decimal ()
        @doc "Cost single-source for PYTHIA|C_UpdateDualConsumerLane — RAW native STOA \
            \ rename toll (UC_RenamePrice). Consumed by exec collect + INFO preview."
        (UC_RenamePrice)
    )
    (defun URCi_RevokeLink:decimal ()
        @doc "Cost single-source for PYTHIA|C_RevokeLink — flat IGNIS toll \
            \ (UC_RevokeIgnisFee), collected via IGNIS::XE_CollectIgnis in TS01-C4. \
            \ Consumed by exec + INFO."
        (UC_RevokeIgnisFee)
    )
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun UR_AKY|Data:object{PYTHIA|S|ApiKey} (apollo-account:string)
        @doc "Full Apollo half row."
        (read PYTHIA|T|ApiKeys apollo-account)
    )
    (defun UR_Public:string (apollo-account:string)
        (at "public" (read PYTHIA|T|ApiKeys apollo-account ["public"]))
    )
    (defun UR_Counterpart:string (apollo-account:string)
        (at "counterpart" (read PYTHIA|T|ApiKeys apollo-account ["counterpart"]))
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
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string)
        @doc "ApiKey row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_AKY|Data apollo-account)) false)
            (UDC_AKY|Unregistered)
            (UDC_AKY|WithRegisteredFlag (UR_AKY|Data apollo-account))
        )
    )
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun UR_DLK|Data:object{PYTHIA|S|DualLink} (dual-link-key:string)
        @doc "Full dual-link row."
        (read PYTHIA|T|DualLinks dual-link-key)
    )
    (defun UR_DualLinkIzActive:bool (dual-link-key:string)
        (at "iz-active" (read PYTHIA|T|DualLinks dual-link-key ["iz-active"]))
    )
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string)
        @doc "DualLink row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_DLK|Data dual-link-key)) false)
            (UDC_DLK|Unregistered)
            (UDC_DLK|WithRegisteredFlag (UR_DLK|Data dual-link-key))
        )
    )
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string)
        @doc "iz-active when dual row exists; false when absent (default-read)."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"iz-active" : false}
            {"iz-active" := iz}
            iz
        )
    )
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string)
        @doc "Stoic lane on dual link row; BAR when row absent."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"consumer-lane" : BAR}
            {"consumer-lane" := lane}
            lane
        )
    )
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    (defun UR_Config ()
        @doc "Full Config row (deploy-price + rename-price); defaults when unset. The defaults \
            \ are DERIVED, not hardcoded: every Ouronet price is denominated in DOLLARS and \
            \ converted to STOA at the oracle, so these read $50 deploy / $10 rename out of \
            \ IG|DETER through UC_StoaPrice (= 500 / 100 STOA at the $0.10 peg, unchanged from \
            \ the raw constants they replace). Governance may still override either in-table."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-default-read PYTHIA|T|Config PYTHIA|INFO
                {"deploy-price" : (ref-IGNIS::UC_StoaPrice "pythia-deploy")
                ,"rename-price" : (ref-IGNIS::UC_StoaPrice "pythia-rename")}
                {"deploy-price" := d, "rename-price" := r}
                {"deploy-price" : d, "rename-price" : r}
            )
        )
    )
    (defun UR_DeployPrice:decimal ()
        @doc "Governance-tunable deploy toll (default $50 = 500 STOA per Apollo half; collected in TS01-C4)."
        (at "deploy-price" (UR_Config))
    )
    (defun UR_RenamePrice:decimal ()
        @doc "Governance-tunable consumer-lane rename toll (default $10 = 100 STOA; collected in TS01-C4)."
        (at "rename-price" (UR_Config))
    )
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    (defun UR_RevocationAtHeight:integer ()
        @doc "Block height recorded at last dual-link revoke; 0 when never revoked."
        (with-default-read PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height" : 0}
            {"revoked-at-height" := h}
            h
        )
    )
    (defun UR_RevocationEpoch:integer ()
        @doc "Chain epoch at last revoke: floor(revoked-at-height / 120); 0 when never revoked."
        (let
            (
                (h:integer (UR_RevocationAtHeight))
            )
            (if (= h 0)
                0
                (UC_ChainEpoch h)
            )
        )
    )
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun UR_PythDay:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (day:integer)
        @doc "Full Pyth daily delta row for day ordinal; zeroed row for un-flushed / gap \
            \ days (never aborts, so range reads survive holes in the ledger)."
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day":         day
            , "flushed-at":  PYTHIA|LEDGER-EPOCH-START
            , "iz-sealed":   false
            , "metrics":     (UDC_PythMetrics|Zero) }
            { "day"        := d
            , "flushed-at" := fa
            , "iz-sealed"  := iz
            , "metrics"    := m }
            (UDC_PythDaily d fa iz m)
        )
    )
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    (defun UR_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Running Pyth ledger totals; zeros when never flushed."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            { "total-metrics":
                { "petitions": 0
                , "pondus": 0.0
                , "transactions": 0
                , "gas-reserved": 0
                , "failed-transactions": 0
                , "wasted-gas-reserved": 0 }
            , "last-day": 0 }
            { "total-metrics" := total-metrics
            , "last-day" := last-day }
            (UDC_PythTotal total-metrics last-day)
        )
    )
    (defun UR_PythTotal|TotalMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Six-metric running totals blob; zeros when never flushed."
        (at "total-metrics" (UR_PythTotal))
    )
    (defun UR_PythTotal|LastDay:integer ()
        @doc "Highest calendar day ordinal with a daily row; 0 before first flush."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            {"last-day": 0}
            {"last-day" := last-day}
            last-day
        )
    )
    (defun UR_PythCurrentDay:integer ()
        @doc "Calendar day ordinal for the executing block-time (UTC; helper for Khronoton)."
        (UC_PythDayOrdinal (at "block-time" (chain-data)))
    )
    (defun UR_PythLedgerEpochStart:time ()
        @doc "UTC midnight anchor for calendar day 1; keyless read for off-chain day math."
        PYTHIA|LEDGER-EPOCH-START
    )
    (defun UR_PythMaxFlushBatch:integer ()
        @doc "Max calendar-day entries per A_Flush tx (tuned for ~2M gas; see HANDOFF)."
        PYTHIA|MAX-FLUSH-BATCH
    )
    (defun UR_PythDailyExists:bool (day:integer)
        @doc "True when PYTHIA|T|PythDaily has a row for day ordinal."
        ;; Avoid (keys ...) enumeration (disallowed in some capability/guard modes) AND
        ;; do not rely on UR_PythDay throwing (it now defaults). Probe a sentinel `day`
        ;; of -1: a real row always carries day >= 1, so present <=> read day != -1.
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day": -1 }
            { "day" := d }
            (!= d -1)
        )
    )
    ;;
    ;; [7] Composite reads (dual-link views)
    (defun UR_ApiKeyBySlot:object (standard-apollo:string)
        @doc "Dual-link view keyed by Standard ₱. slot (owner/status reads)."
        (let
            (
                (counterpart:string (UR_Counterpart standard-apollo))
                (dlk:string
                    (if (= counterpart BAR)
                        BAR
                        (UC_DualLinkKey standard-apollo counterpart)
                    )
                )
            )
            (if (= dlk BAR)
                (UDC_DualLinkView BAR standard-apollo BAR false BAR BAR BAR)
                (let
                    (
                        (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dlk))
                        (standard:string (at "standard-apollo" row))
                        (smart:string (at "smart-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart)
                        lane
                    )
                )
            )
        )
    )
    ;; WU_PythTotal|TotalMetrics — not used: mutates via WW_PythTotal (full row).
    ;; WU_PythTotal|LastDay — not used: mutates via WW_PythTotal (full row).
    ;;
    (defun URH_ApiKeyCount:integer ()
        (length (keys PYTHIA|T|ApiKeys))
    )
    (defun URH_ApiKeyCountStr:string ()
        (format "Pythia Apollo halves registered: {}" [(URH_ApiKeyCount)])
    )
    (defun URH_DualLinkCount:integer ()
        (length (keys PYTHIA|T|DualLinks))
    )
    (defun URH_ListAllApiKeys:[object] ()
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "counterpart" "owner-account"
              "registered-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListAllDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListActiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= true))
        )
    )
    (defun URH_ListInactiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= false))
        )
    )
    (defun URH_ActiveDualLinkSet:[string] ()
        @doc "Active dual-link-key strings for Pythia cache mirror."
        (map
            (lambda (row:object) (at "dual-link-key" row))
            (select PYTHIA|T|DualLinks ["dual-link-key"] (where "iz-active" (= true)))
        )
    )
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string)
        @doc "Auth-path lookup by Smart Π. consumer half (select on DualLinks)."
        (let
            (
                (rows:[object] (select PYTHIA|T|DualLinks
                    [ "dual-link-key" "standard-apollo" "smart-apollo" "iz-active" "consumer-lane" ]
                    (where "smart-apollo" (= smart-apollo))
                ))
            )
            (if (= (length rows) 0)
                (UDC_DualLinkView BAR BAR smart-apollo false BAR BAR BAR)
                (let
                    (
                        (row:object (at 0 rows))
                        (dlk:string (at "dual-link-key" row))
                        (standard:string (at "standard-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart-apollo
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart-apollo)
                        lane
                    )
                )
            )
        )
    )
    (defun URH_ListPythDaily:[object{PythiaLedgerV3.PYTHIA|S|PythDaily}] (from:integer to:integer)
        @doc "Bounded daily delta rows for charting (inclusive range; empty when invalid)."
        (if
            (fold (or) false
                [
                    (< from 1)
                    (< to from)
                    (> (- to from) PYTHIA|MAX-DAILY-RANGE)
                ]
            )
            []
            (map
                (lambda (d:integer) (UR_PythDay d))
                (enumerate from to)
            )
        )
    )
    ;;
    (defun INFO_PYTHIA|DeployApiKey:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_DeployApiKey (500 STOA per half)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (deploy-fee:decimal (UR_DeployPrice))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
                (kind:string
                    (if (UC_IsStandardApollo apollo-account) "Standard (₱.)" "Smart (Π.)")
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploy {} Pythia Apollo half (unlinked)." [kind])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "Native STOA deploy fee: {} per half (full price; Elite discounts do not apply)." [deploy-fee])
                    "Consumer lane is set at C_Link when both halves are paired."
                ]
                [(format "Pythia {} Apollo half registered (unlinked)." [kind])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) deploy-fee)
                []
            )
        )
    )
    (defun INFO_PYTHIA|Link:object{OuronetInfoV2.ClientInfo}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_Link (inactive dual row; no fee)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (std-owner:string (UR_OwnerAccount standard-apollo))
                (smt-owner:string (UR_OwnerAccount smart-apollo))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount std-owner))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount smt-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Link Standard {} to Smart {} for lane {} (inactive dual row)." [standard-apollo smart-apollo consumer-lane])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Dual link key: {}." [dlk])
                    "No STOA or IGNIS fee. Cronoton activates after off-chain proof."
                ]
                [(format "Pythia dual link {} created for lane {} (inactive)." [dlk consumer-lane])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|RevokeLink:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_RevokeLink / A_RevokeLink (1 IGNIS)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (revoke-fee:decimal (UC_RevokeIgnisFee))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Revoke (deactivate) dual link {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "IGNIS fee: {} (minimum unit)." [revoke-fee])
                    "Counterpart fields remain immutable; deploy fresh halves to re-pair."
                ]
                [(format "Pythia dual link {} deactivated." [dual-link-key])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron revoke-fee)
                )
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|UpdateDualConsumerLane:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
            new-name:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_UpdateDualConsumerLane."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (rename-fee:decimal (UR_RenamePrice))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Rename Pythia dual link consumer-lane to {}." [new-name])
                    (format "Dual link key: {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Native STOA rename fee: {} (full price; Elite discounts do not apply)." [rename-fee])
                ]
                [(format "Pythia dual link lane renamed to {}." [new-name])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) rename-fee)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_FlushEntries:bool (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Validate flush batch: fold over entries; pure bool (no enforce)."
        (fold
            (lambda (acc:bool entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
                (let
                    (
                        (day:integer (at "day" entry))
                        (pondus:decimal (at "pondus" entry))
                        (sealed-ok:bool
                            (if (UR_PythDailyExists day)
                                (= (at "iz-sealed" (UR_PythDay day)) false)
                                true
                            )
                        )
                        (entry-ok:bool
                            (fold (and) true
                                [
                                    (> day 0)
                                    (>= (at "petitions" entry) 0)
                                    (>= pondus 0.0)
                                    (= pondus (floor pondus 3))
                                    (>= (at "transactions" entry) 0)
                                    (>= (at "gas-reserved" entry) 0)
                                    (>= (at "failed-transactions" entry) 0)
                                    (>= (at "wasted-gas-reserved" entry) 0)
                                    sealed-ok
                                ]
                            )
                        )
                    )
                    (and acc entry-ok)
                )
            )
            true
            entries
        )
    )
    (defun UEV_ValidateCompositeDualLinkKey:bool (dual-link-key:string)
        @doc "Dual-link-key is 325 chars: valid ₱. standard + BAR + valid Π. smart."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (standard:string (UC_DualLinkStandard dual-link-key))
                (smart:string (UC_DualLinkSmart dual-link-key))
                (sep:string (take (length BAR) (drop PYTHIA|APOLLO-LEN dual-link-key)))
            )
            (enforce (= (length dual-link-key) PYTHIA|DUAL-LINK-LEN) "Dual link key length must be 325")
            (enforce (= sep BAR) "Dual link key separator must be BAR")
            (and
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck standard false)
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck smart true)
            )
        )
    )
    (defun UEV_DualPairForLink
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves deployed, unlinked, valid glyphs, dual row absent."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (UEV_ValidateCompositeDualLinkKey dlk)
            (enforce (= (UR_Counterpart standard-apollo) BAR) "Standard half is already linked")
            (enforce (= (UR_Counterpart smart-apollo) BAR) "Smart half is already linked")
            ;;UNREACHABLE: the DLK row exists only if the pair was linked, and both link paths
            ;;(A_LinkDualApiKey / C_LinkDualApiKey) call XI_ApplyDualCounterparts -- which sets
            ;;BOTH counterparts -- immediately before WI_DualLink, in one transaction. So the
            ;;row's existence implies the counterpart enforces above already fired. Counterparts
            ;;are never cleared (C_RevokeDualLink deactivates only). Fail-closed backstop that
            ;;would start earning its keep if a non-atomic write path were ever introduced.
            ;;Demonstrated in REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce
                (= (try false (UR_DLK|Data dlk)) false)
                "Dual link row already exists for this pair"
            )
        )
    )
    (defun UEV_DualPairReadyForActivate
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves exist and counterparts match (linked metadata present)."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (enforce (= (UR_Counterpart standard-apollo) smart-apollo) "Standard half not linked to Smart")
            ;;UNREACHABLE for the same reason as the backstop in UEV_DualPairForLink above: the
            ;;two counterparts are written as one atomic pair by XI_ApplyDualCounterparts, so
            ;;they cannot disagree, and any genuine mismatch trips the STANDARD-side enforce on
            ;;the line above. Pinned as unreachable, not as coverage, in
            ;;REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce (= (UR_Counterpart smart-apollo) standard-apollo) "Smart half not linked to Standard")
            dlk
        )
    )
    ;;{5.5}  Write [W]
    ;;
    ;; Six blocks — one per deftable (table order). Within each block: WI → WW → WU (all fields).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_* / sibling WU_*.
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun WI_ApiKey:string
        (
            apollo-account:string
            row:object{PYTHIA|S|ApiKey}
        )
        @doc "Insert PYTHIA|T|ApiKeys full row (deploy only); stamps registered-at/updated-at from block time."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|ApiKeys apollo-account
                (+ {"registered-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_ApiKey — not used: deploy path is WI_ApiKey.
    ;; WU_ApiKey|Public — not mutable [.]
    (defun WU_ApiKey|Counterpart:string (apollo-account:string counterpart:string)
        @doc "Set counterpart on PYTHIA|T|ApiKeys (link only; immutability enforced in event caps)."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account
            { "counterpart": counterpart
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_ApiKey|OwnerAccount — not mutable [.]
    ;; WU_ApiKey|RegisteredAt — not mutable [.]
    ;; WU_ApiKey|UpdatedAt — not used: mutates via WU_ApiKey|Counterpart.
    ;; WU_ApiKey|ApolloAccount — select key; WU not needed.
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun WI_DualLink:string
        (
            dual-link-key:string
            row:object{PYTHIA|S|DualLink}
        )
        @doc "Insert PYTHIA|T|DualLinks full row (C_Link inactive or A_Link create+active); stamps linked-at/updated-at."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|DualLinks dual-link-key
                (+ {"linked-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_DualLink — not used: link path is WI_DualLink; revoke uses WU_DualLink|IzActive.
    ;; WU_DualLink|StandardApollo — not mutable [.]
    ;; WU_DualLink|SmartApollo — not mutable [.]
    (defun WU_DualLink|ConsumerLane:string (dual-link-key:string consumer-lane:string)
        @doc "Update consumer-lane on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "consumer-lane": consumer-lane
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    (defun WU_DualLink|IzActive:string (dual-link-key:string iz-active:bool)
        @doc "Update iz-active on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "iz-active": iz-active
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_DualLink|LinkedAt — not mutable [.]
    ;; WU_DualLink|UpdatedAt — not used: mutates via WU_DualLink|ConsumerLane / WU_DualLink|IzActive.
    ;; WU_DualLink|DualLinkKey — select key; WU not needed.
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    ;; WI_Config — not used: first row touch is WW_Config (upsert path).
    (defun WW_Config:string (deploy-price:decimal rename-price:decimal)
        @doc "Upsert PYTHIA|T|Config full row (governance price updates)."
        (require-capability (SECURE))
        (write PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price": deploy-price, "rename-price": rename-price}
        )
    )
    ;; WU_Config|DeployPrice — not used: mutates via WW_Config (full row).
    ;; WU_Config|RenamePrice — not used: mutates via WW_Config (full row).
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    ;; WI_Revocation — not used: first row touch is WW_Revocation (upsert path).
    (defun WW_Revocation:string (revoked-at-height:integer)
        @doc "Upsert PYTHIA|T|Revocation block height anchor (set on each revoke)."
        (require-capability (SECURE))
        (write PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height": revoked-at-height}
        )
    )
    ;; WU_Revocation|RevokedAtHeight — not used: mutates via WW_Revocation (full row).
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun WI_PythDaily:string
        (
            day:integer
            row:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        )
        @doc "Insert PYTHIA|T|PythDaily full row (first flush of calendar day only)."
        (require-capability (SECURE))
        (insert PYTHIA|T|PythDaily (UCk_PythDaily day) row)
    )
    (defun WU_PythDaily|Metrics:string
        (
            day:integer
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Replace same-day metrics snapshot (open day re-flush)."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"metrics": metrics})
    )
    (defun WU_PythDaily|FlushedAt:string (day:integer flushed-at:time)
        @doc "Stamp latest flush time on the open calendar day row."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"flushed-at": flushed-at})
    )
    (defun WU_PythDaily|IzSealed:string (day:integer iz-sealed:bool)
        @doc "Seal a calendar day when advancing to the next day."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"iz-sealed": iz-sealed})
    )
    ;; WU_PythDaily|Day — not mutable [.]
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    ;; WI_PythTotal — not used: first row touch is WW_PythTotal (upsert path).
    (defun WW_PythTotal:string (row:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Upsert PYTHIA|T|PythTotal full row (A_Flush total-metrics + last-day)."
        (require-capability (SECURE))
        (write PYTHIA|T|PythTotal PYTHIA|STOACHAIN row)
    )
    ;;{5.6}  Aux/X
    ;;
    ;;Protection: Class 1 — Innate protection offered by WW_Revocation
    (defun XI_RecordRevocationAtHeight:integer ()
        @doc "Record executing block height at revoke (fast-lane poll via UR_RevocationAtHeight)."
        ;; SECURE: granted by WW_Revocation (underlying W_).
        (let
            (
                (bh:integer (at "block-height" (chain-data)))
            )
            (WW_Revocation bh)
            bh
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_ApiKey|Counterpart
    (defun XI_ApplyDualCounterparts:string
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Fill immutable counterpart fields on both Apollo halves."
        ;; SECURE: granted by WU_ApiKey|Counterpart; BAR validated in PYTHIA|C>LINK-DUAL cap.
        (WU_ApiKey|Counterpart standard-apollo smart-apollo)
        (WU_ApiKey|Counterpart smart-apollo standard-apollo)
        (format "Counterparts linked: {} <-> {}" [standard-apollo smart-apollo])
    )
    ;;Protection: Class 1 — Innate protection offered by WW_PythTotal
    (defun XI_FlushPythLedger:string
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Process batch entries; commit running total once (entries may land in any tx order)."
        ;; SECURE: granted by WW_PythTotal (underlying W_).
        (let
            (
                (now:time (at "block-time" (chain-data)))
                (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal} (UR_PythTotal))
                (init:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc} (UC_FlushAccFromTotal tot))
                (final:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                    (fold
                        (lambda
                            (
                                acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                                entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
                            )
                            (XI_1|ApplyOneFlushEntry acc entry now)
                        )
                        init
                        entries
                    )
                )
            )
            (WW_PythTotal
                (UDC_PythTotal
                    (at "total-metrics" final)
                    (at "last-day" final)
                )
            )
            (format "batch {} entries" [(length entries)])
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_PythDaily|Metrics,
    ;;Protection:          WU_PythDaily|FlushedAt, WU_PythDaily|IzSealed, WI_PythDaily
    (defun XI_1|ApplyOneFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (
            acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
            entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
            now:time
        )
        @doc "Fold step: ADD entry metrics (gateway drain delta) onto day row + grand total; seal flag only."
        ;; SECURE: granted by WI_/WU_PythDaily (underlying W_).
        (let
            (
                (day:integer (at "day" entry))
                (iz-complete:bool (at "iz-complete" entry))
                (delta:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_FlushEntryMetrics entry)
                )
                (total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (at "total-metrics" acc)
                )
                (last-day:integer (at "last-day" acc))
                (next-last:integer (UC_MaxDay last-day day))
                (next-total:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_AddPythMetrics total-metrics delta)
                )
            )
            (if (UR_PythDailyExists day)
                (let
                    (
                        (old-row:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (UR_PythDay day))
                        (day-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                            (UC_AddPythMetrics (at "metrics" old-row) delta)
                        )
                    )
                    (WU_PythDaily|Metrics day day-metrics)
                    (WU_PythDaily|FlushedAt day now)
                    (if iz-complete (WU_PythDaily|IzSealed day true) true)
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
                (let
                    (
                        (_:string (WI_PythDaily day (UDC_PythDaily day now iz-complete delta)))
                    )
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate (no fee): create active dual with auto PYTHIA-<hash12> lane, or flip inactive C_Link row to true."
        (P|UEV_IMC)
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (with-capability (PYTHIA|A>LINK-DUAL standard-apollo smart-apollo)
                (if row-missing
                    (let
                        (
                            (lane:string (UC_AutonomousConsumerLane))
                        )
                        (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                        (WI_DualLink dlk
                            (UDC_DLK|DualLink
                                standard-apollo smart-apollo lane true dlk
                            )
                        )
                        (format "Pythia dual link {} created+activated with lane {}" [dlk lane])
                    )
                    (let
                        (
                            (msg:string
                                (format "Pythia dual link {} activated" [dlk])
                            )
                        )
                        (WU_DualLink|IzActive dlk true)
                        msg
                    )
                )
            )
        )
    )
    (defun A_RevokeDualLink:string (dual-link-key:string)
        @doc "Cronoton revokes active dual link."
        (P|UEV_IMC)
        (with-capability (PYTHIA|A>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by Cronoton" [dual-link-key])
    )
    (defun A_UpdateDeployPrice:string (new-price:decimal)
        (P|UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config new-price (UR_RenamePrice))
            )
        )
        (format "Pythia deploy price set to {}" [new-price])
    )
    (defun A_UpdateRenamePrice:string (new-price:decimal)
        (P|UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config (UR_DeployPrice) new-price)
            )
        )
        (format "Pythia rename price set to {}" [new-price])
    )
    (defun A_Flush:string (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch flush: each entry is a drain DELTA — ADD onto day row + grand total; iz-complete seals only."
        (P|UEV_IMC)
        (with-capability (PYTHIA|A>FLUSH entries)
            (XI_FlushPythLedger entries)
        )
        (format "Pythia ledger flushed {} day entries" [(length entries)])
    )
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Fee in TS01-C4."
        (P|UEV_IMC)
        (let
            (
                (kind:string (if (UC_IsStandardApollo apollo-account) "Standard" "Smart"))
            )
            (with-capability (PYTHIA|C>DEPLOY-API-KEY owner-account apollo-account public)
                (WI_ApiKey apollo-account
                    (UDC_AKY|ApiKey public BAR owner-account apollo-account)
                )
            )
            (format "Pythia {} Apollo half {} registered (unlinked)" [kind apollo-account])
        )
    )
    (defun C_LinkDualApiKey:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both half-owners link deployed halves into inactive dual row with lane (no fee)."
        (P|UEV_IMC)
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (with-capability (PYTHIA|C>LINK-DUAL standard-apollo smart-apollo consumer-lane)
                (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                (WI_DualLink dlk
                    (UDC_DLK|DualLink
                        standard-apollo smart-apollo consumer-lane false dlk
                    )
                )
            )
            (format "Pythia dual link {} created for lane {} (inactive)" [dlk consumer-lane])
        )
    )
    (defun C_RevokeDualLink:string (dual-link-key:string)
        @doc "Both half-owners revoke active dual link. Fee in TS01-C4 (IGNIS)."
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by owner" [dual-link-key])
    )
    (defun C_UpdateDualConsumerLane:string
        (
            dual-link-key:string
            new-name:string
        )
        @doc "Both half-owners rename consumer-lane on dual link row. Fee in TS01-C4."
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>UPDATE-DUAL-LANE dual-link-key new-name)
            (WU_DualLink|ConsumerLane dual-link-key new-name)
        )
        (format "Pythia dual link {} lane renamed to {}" [dual-link-key new-name])
    )

)

;; Module install — (create-table ...) runs in the same tx as (module PYTHIA …) on greenfield deploy.
                    ;; policy
                   ;; policy meta
       ;; V1 name; V3 schema
        ;; carryover
     ;; V3 NEW
    ;; V3 NEW
     ;; Ledger NEW
     ;; Ledger NEW

;; --- tables for 22_PYTHIA.pact (8 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table PYTHIA|T|ApiKeys)
;; (create-table PYTHIA|T|Config)
;; (create-table PYTHIA|T|DualLinks)
;; (create-table PYTHIA|T|Revocation)
;; (create-table PYTHIA|T|PythDaily)
;; (create-table PYTHIA|T|PythTotal)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_AdminV2
    @doc "Exposes Ouronet Administrative Functions"

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
    ;;
    ;;
    ;;Fueling Functions
    (defun XB_DynamicFuelSTOA ())
    (defun XE_ConditionalFuelSTOA (condition:bool))
    ;;{5.7}  User [A/C]
    ;;
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string))
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool))
    (defun DALOS|A_ToggleGAP (executor:string gap:bool))
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool))
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool))
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal))
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool))
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string))
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal))
    ;;
    ;;
    (defun BRD|A_Live (executor:string entity-id:string))
    (defun BRD|A_SetFlag (executor:string entity-id:string flag:integer))
    ;;
    ;;
    (defun DPTF|A_UpdateTreasuryDispoParameters (executor:string type:integer tdp:decimal tds:decimal))
    (defun DPTF|A_WipeTreasuryDebt (executor:string))
    (defun DPTF|A_WipeTreasuryDebtPartial (executor:string debt-to-be-wiped:decimal))
    (defun DPTF|A_DeployAccount (patron:string id:string account:string))
    ;;
    (defun DPOF|A_DeployAccount (patron:string id:string account:string))
    ;;
    (defun ATS|AA_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string]))
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    ;;
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string))
    ;;
    ;;
    (defun ORBR|A_Fuel ())
    ;;
    ;;
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun SWP|A_RotatePrincipal (old:string new:string))
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool))
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string))
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool))

)
;;
(module TS01-A GOV
    @doc "TALOS Stage 1 Administrator Functions \
        \ Contains All Administrator functions [DALOS BRD ORBR SWP]\
        \ Also contains Fueling Functions needed in all subsequent TALOS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_AdminV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-A                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-A_ADMIN)))
    (defcap GOV|TS01-A_ADMIN ()                         (enforce-guard GOV|MD_TS01-A))
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
        @doc "Talos Summoner Capability"
        true
    )
    (defcap P|TRG ()
        @doc "Talos Remote Governor Capability"
        true
    )
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (GOV|TS01-A_ADMIN))
    )
    (defcap P|GOVERNING-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (P|TRG))
    )
    (defcap P|SECURE-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (SECURE))
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
        (with-capability (GOV|TS01-A_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-A_ADMIN)
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
        (with-capability (GOV|TS01-A_ADMIN)
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
        (with-capability (GOV|TS01-A_ADMIN)
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
        @doc "Fix (audit finding #22L test-coverage sweep): ATS and ATSU were never \
            \ registered as permitted callers here (ATS was even bound - ref-P|ATS - \
            \ but never used), so any TS01-A admin function routing into either module \
            \ (e.g. ATS|AA_RemoveSecondary, ATS|A_KickStart) always failed P|UEV_IMC's \
            \ whitelist check - unconditionally, regardless of caller/key. Never caught \
            \ because those functions had zero test coverage. Every other Talos module's \
            \ own P|A_Define already registers into both ATS and ATSU; this just matches \
            \ that existing pattern."
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|TS)))
            )
            (ref-P|DALOS::P|A_Add
                "TS01-A|RemoteDalosGov"
                (create-capability-guard (P|TRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst GASLESS-PATRON                            (URC_Gassless))
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_Gassless ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [Fueling Functions]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DynamicFuelSTOA ()
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (ref-DALOS::UR_AutoFuel)
                (with-capability (SECURE)
                    (XI_DirectFuelSTOA)
                )
                true
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ConditionalFuelSTOA (condition:bool)
        (P|UEV_IMC)
        (if condition
            (with-capability (SECURE)
                (XB_DynamicFuelSTOA)
            )
            true
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_DirectFuelSTOA ()
        (require-capability (SECURE))
        (let
            (
                (ref-ORBR:module{OuroborosV2} OUROBOROS)
            )
            (with-capability (P|TS)
                (ref-ORBR::C_Fuel GASLESS-PATRON)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;  [DALOS_Administrator]
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string)
        @doc "Migrates Ouronet Gas Station Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_MigrateLiquidFunds GASLESS-PATRON executor migration-target-stoa-account)
            )
        )
    )
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool)
        @doc "Toggles the Ouroboros Autonomous Price Update to <oapu>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleOAPU GASLESS-PATRON executor oapu)
                (if oapu
                    "Ouroboros Autonomous Price Update successfully turned ON"
                    "Ouroboros Autonomous Price Update successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_ToggleGAP (executor:string gap:bool)
        @doc "Toggles the Global administrative Pause, the GAP, to <toggle>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGAP GASLESS-PATRON executor gap)
                (if gap
                    "Global Administrative Pause successfully turned ON"
                    "Global Administrative Pause successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Smart Ouronet Account in Administrator Mode, without collection STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeploySmartAccount executor guard stoa sovereign public)
                (format "Succesfuly deployed Smart Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account in Administrator Mode, without collection STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeployStandardAccount executor guard stoa public)
                (format "Succesfuly deployed Standard Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool)
        @doc "ADMIN: switch STOA collection on Ouronet ACCOUNT CREATION on/off, INDEPENDENTLY \
            \ of the global STOA switch (DALOS|A_IgnisToggle native=true). OFF — the default — \
            \ keeps onboarding free while global STOA collection is ON. Admin op, so this \
            \ entrypoint is itself IGNIS+STOA exempt."
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleAccountCreationStoa GASLESS-PATRON executor toggle)
                (if toggle
                    "Account-Creation STOA Collection succesfully turned ON"
                    "Account-Creation STOA Collection succesfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool)
        @doc "Toggles Ouronet Gas Collection \
        \ <native> true is STOA Collection for Specific Usage Actions \
        \ <native> false is IGNIS Collection for Client Functions"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGasCollection GASLESS-PATRON executor native toggle)
                (if native
                    (if toggle
                        "STOA Collection succesfully turned ON"
                        "STOA Collection succesfully turned OFF"
                    )
                    (if toggle
                        "IGNIS Collection succesfully turned ON"
                        "IGNIS Collection succesfully turned OFF"
                    )
                )
            )
        )
    )
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal)
        @doc "Sets OUROBOROS Price in $. Used in Compresion and Sublimation"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetIgnisSourcePrice GASLESS-PATRON executor price)
                (format "Succesfuly set IGNIS price to {}" [price])
            )
        )
    )
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool)
        @doc "Sets Automatic fueling of Collected STOA for the Increase of the <StoaLiquindex>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetAutoFueling GASLESS-PATRON executor toggle)
                (if toggle
                    "LiquidStaking Autofueling successfully turned ON"
                    "LiquidStaking Autofueling successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string)
        @doc "Updates Public Key; To be used only as failsafe by the Admin"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_UpdatePublicKey GASLESS-PATRON executor new-public)
                (format "Public Key for Account {} successfully updated!" [sa])
            )
        )
    )
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal)
        @doc "Updates specific Usage Price in STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_UpdateUsagePrice GASLESS-PATRON executor action new-price)
                (format "Price for Action {} successfully updated with {}" [action new-price])
            )
        )
    )
    ;;  [BRD_Administrator]
    (defun BRD|A_Live (executor:string entity-id:string)
        @doc "Sets <pending-branding> for an <entity-id> to <live-branding>, reseting <pending-branding> data \
            \ Resetting <pending-branding> data does not reset its last 3 keys \
            \ Can only be done by Branding Administrator"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_Live GASLESS-PATRON executor entity-id)
            )
        )
    )
    (defun BRD|A_SetFlag (executor:string entity-id:string flag:integer)
        @doc "Forcibly (in administrator mode) sets a Branding Flag for <entity-id> \
            \ <0> Flag = Golden Flag        Premium Flag reserved for Demiourgos Entity IDs \
            \ <1> Flag = Blue Flag          Premium Flag for Entity IDs (non-Demiourgos); \
            \                               Premium Flags are paid live branded Entity-IDs that are not labeled as problematic \
            \                               Paid live branded Entity IDs can still be flaged Red by the Branding Administrator \
            \ <2> Flag = Green Flag         Standard Flag for Entity IDs (non-Demiourgos) that have their Branding set to Live \
            \ <3> Flag = Gray Flag          Default Flag for newly-issued Entity-IDs (non-Demiourgos) that dont have their Branding Live yet \
            \ <4> Flag = Red Flag           Problem Flag for Entity IDs, marking potential dangerous or scam Entity IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_SetFlag GASLESS-PATRON executor entity-id flag)
            )
        )
    )
    ;;  [DPTF_Administrator]
    (defun DPTF|A_UpdateTreasuryDispoParameters (executor:string type:integer tdp:decimal tds:decimal)
        @doc "Updates Treasury Dispo Parameters, that dictate how much OURO Debt the Treasury can incurr \
            \ Type can only be 0 1 2 3 \
            \ Type 0 = No Treasury Dispo \
            \ Type 1 = Maximum Dispo equal to Total Supply \
            \ Type 2 = Promile Based Dispo; A <tdp> value of 320.0 means up to 32% of Total Supply can be overspent\
            \ Type 3 = Absolute Value Dispo in Thousands; A <tds> value of 250.0 means up to 250 Thousands can be overspent"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_UpdateTreasury GASLESS-PATRON executor type tdp tds)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebt (executor:string)
        @doc "Wipes all Treasury Debt, increasing OURO supply by the Debt Amount, \
            \ and setting Treasury Dispo Parameters to neutral (no overspend capability)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebt GASLESS-PATRON executor)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebtPartial (executor:string debt-to-be-wiped:decimal)
        @doc "Wipes all partialy the Treasury Debt, increasing OURO supply by the <debt-to-be-wiped> amount \
        \ Treasury Dispo Parameters are left as they are, this function simply wipe a part of the Treasury Debt through mint."
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebtPartial GASLESS-PATRON executor debt-to-be-wiped)
            )
        )
    )
    (defun DPTF|A_DeployAccount (patron:string id:string account:string)
        @doc "Administrative variant of DPTF|C_DeployAccount (TS01-C1) - deploys a DPTF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPTF|C_DeployAccount instead. \
            \ ONLY THE ADMIN may deploy for someone else (owner, 2026-09-21); the absence of an \
            \ ownership check on <account> is the entire reason this door exists, and \
            \ P|ADMINISTRATIVE-SUMMONER is what confines it. \
            \ Wraps XB_DeployAccount -- the core was reclassified out of the C_ band, since it \
            \ builds no cumulator and was called from inside its own module."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DPTF::XBv_DeployAccount id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPTF|C_DeployAccount's price
                    (ref-DPTF::URCi_DeployAccount account)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully! (admin)" [id sa])
            )
        )
    )
    ;;
    ;;  [DPOF_Administrator]
    (defun DPOF|A_DeployAccount (patron:string id:string account:string)
        @doc "Administrative variant of DPOF|C_DeployAccount (TS01-C1) - deploys a DPOF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPOF|C_DeployAccount instead."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DPOF::XBv_DeployAccount id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPOF|C_DeployAccount's price
                    (ref-DPOF::URCi_DeployAccount account)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {} (admin)" [id sa])
            )
        )
    )
    ;;  [ATS_Administrator]
    (defun ATS|AA_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant, queries <accounts-with-ats-data> via <DPTF-DPOF-ATS|UR_FilterKeysForInfo>"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::AA_RemoveSecondary remover ats reward-token accounts-with-ats-data)
                )
            )
        )
    )
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative Variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance, with no upper bound on the resulting KickStart \
            \ index (still subject to the shared 0.1 floor) - for legitimate ratios \
            \ above the owner-facing ATS|C_KickStart's 100.0 ceiling."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                ;;A_ on the blessed path: the collection runs EXACTLY as any C_'s does -- it is
                ;;simply served by GASLESS-PATRON, the one account IGNIS::XE_CollectIgnis exempts. The
                ;;path is preserved, not skipped; that is what makes an A_ gasless.
                (ref-IGNIS::XE_CollectIgnis GASLESS-PATRON
                    (ref-ATSU::A_KickStart GASLESS-PATRON executor ats rt-amounts rbt-request-amount)
                )
            )
        )
    )
    ;;  [LIQUID_Administrator]
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string)
        @doc "Migrates Stoa Liquid Staking STOA Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                )
                (ref-LIQUID::A_MigrateLiquidFunds migration-target-stoa-account)
            )
        )
    )
    ;;  [OUROBOROS_Administrator]
    (defun ORBR|A_Fuel ()
        @doc "Uses up all collected Native STOA on the Ouroboros Account, wraps it, and fuels the Stoa Liquid Index \
            \ Transaction fee must be paid for by the Ouronet Gas Station, so that all available balance may be used. \
            \ Is Part of all the Functions that collect native STOA as fee, \
            \ boosting the STOA Liquid Index, from 40% of the collected STOA \
            \ As Stand-Alone Function, can only be used by the Admin. \
            \ In normal condition, there is no need for using it on itself, as all collected STOA is automatically used up \
            \ by implementing this function at the end of those funtions that collect the STOA. \
            \ Dalos-Patron is the only gass"
        ;;GATE FIX (P3.3 sweep): this was (with-capability (SECURE)), and SECURE in this module
        ;;is (defcap SECURE () true) -- a C1 trivial cap. So the function's own @doc above ("As
        ;;Stand-Alone Function, can only be used by the Admin") was not enforced by anything:
        ;;ANY signer could call it and force the STOA fuelling at a moment of their choosing.
        ;;Every other |A_ entrypoint in this module already gates on P|ADMINISTRATIVE-SUMMONER
        ;;(P|TS + GOV|TS01-A_ADMIN); this one was the single outlier. The only live caller,
        ;;REPL/Stage_01/[6.3]_SWP.repl:2443, already signs with a Demiurgoi key, so no legitimate
        ;;caller loses access.
        ;;
        ;;SECURE is still ACQUIRED rather than replaced: XI_DirectFuelSTOA require-capability's it,
        ;;so swapping the two caps outright breaks the call (it did -- the suite caught it). The
        ;;admin cap gates, SECURE grants. Same shape as XB_DynamicFuelSTOA, the automatic path,
        ;;which gates on P|UEV_IMC and then grants SECURE inside it.
        ;;
        ;;Pinned by REPL/modules/CONFORMANCE.repl <<CONF-05>>; the class is linted by
        ;;_conformance.py [admin-gate-terminal], which was written FROM this defect and verified
        ;;against it by reverting the fix and watching the rule fire.
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (with-capability (SECURE)
                (XI_DirectFuelSTOA)
            )
        )
    )
    ;;  [SWP_Administrator]
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
        \ least 2 would remain defined, and <principal> isn't a 'major' principal \
        \ — #65eL). A principal is a token that must exist once in every W or P \
        \ Swpiar, on the first position. Also, the S Pools, must have at least \
        \ one Token dtied directly to a principal Token. SWPT's storage is \
        \ principal-agnostic (#21H), so removal of a minor principal is safe — it \
        \ only affects future pool-issuance principal-anchoring validation, never \
        \ existing routing. A major principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice) can never be removed \
        \ this way; retiring one requires redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool). SWP|A_RotatePrincipal remains available as \
        \ an atomic, count-preserving alternative for minor principals — it never \
        \ touches the floor or cap, but is equally blocked from rotating a major \
        \ principal away."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdatePrincipal principal add-or-remove)
            )
        )
    )
    (defun SWP|A_RotatePrincipal (old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one step, without \
        \ touching the 2-minimum floor or 7-maximum cap. Safe with respect to \
        \ SWPT's routing graph (#21H fix): SWPT's storage is principal-agnostic, \
        \ so this never orphans anything there — the only effect is on future \
        \ pool-issuance principal-anchoring validation. Rejects rotating a \
        \ principal into itself, rejects <new> already being a principal, and \
        \ rejects <old> being a 'major' principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice, #65eL) — majors are \
        \ fixed, retirable only by redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool)."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_RotatePrincipal old new)
            )
        )
    )
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool)
        @doc "Updates either the <spawn-limit> or <inactive-limit> for the SWP Module \
        \ The <spawn-limit> is the minimum number in STOA that a pool must be created with, in order to be opened for swap \
        \ The <inactive-limit> is the minimum number in STOA as total pool liquidity value, that trigger autonomic disable of the swap mechanism"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLimit limit spawn)
            )
        )
    )
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool)
        @doc "Updates Liquid Boost switch. When set to true, every swap is set to pump the Index for Stoa Liquid Staking"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLiquidBoost new-boost-variable)
            )
        )
    )
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_DefinePrimordialPool primordial-pool)
            )
        )
    )
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_ToggleAsymetricLiquidityAddition GASLESS-PATRON toggle)
            )
        )
    )

)

;; --- tables for 01_TS01-A.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_ClientOneV2
    @doc "Exposes Ouronets Stage One First Batch of Client Functions \
        \ Modules: DALOS, DPTF and DPOF are included in the First Batch"

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
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool))
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard))
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool))
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string))
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string))
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string))
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string))
    ;;
    ;;
    (defun DPTF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPTF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    (defun DPTF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPTF|C_RotateOwnership (patron:string executor:string executee:string id:string))
    (defun DPTF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun DPTF|C_TogglePause (patron:string executor:string id:string toggle:bool))
    (defun DPTF|C_ToggleReservation (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPTF|C_ToggleFee (patron:string executor:string id:string toggle:bool))
    (defun DPTF|C_SetMinMove (patron:string executor:string id:string min-move-value:decimal))
    (defun DPTF|C_SetFee (patron:string executor:string id:string fee:decimal))
    (defun DPTF|C_SetFeeTarget (patron:string executor:string id:string target:string))
    (defun DPTF|C_DonateFees (patron:string executor:string id:string))
    (defun DPTF|C_ResetFeeTarget (patron:string executor:string id:string))
    (defun DPTF|C_ToggleFeeLock (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPTF|C_DeployAccount (patron:string id:string account:string))
    (defun DPTF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleMintRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun DPTF|C_ClearDispo (patron:string executor:string))
    (defun DPTF|C_ClearDispoForeign (patron:string executor:string executee:string))
    (defun DPTF|C_Burn (patron:string executor:string id:string amount:decimal))
    (defun DPTF|C_Mint (patron:string executor:string id:string amount:decimal origin:bool))
    (defun DPTF|C_WipeSlim (patron:string executor:string executee:string id:string amtbw:decimal))
    (defun DPTF|C_Wipe (patron:string executor:string executee:string id:string))
        ;;
    (defun DPTF|C_Transmute (patron:string executor:string id:string transmute-amount:decimal))
    (defun DPTF|C_Transfer (patron:string executor:string executee:string id:string transfer-amount:decimal method:bool))
    (defun DPTF|C_MultiTransfer (patron:string executor:string executee:string id-lst:[string] transfer-amount-lst:[decimal] method:bool))
    (defun DPTF|C_BulkTransfer (patron:string executor:string executee-lst:[string] id:string transfer-amount-lst:[decimal]))
    (defun DPTF|C_MultiBulkTransfer (patron:string executor:string executee-array:[[string]] id-lst:[string] transfer-amount-array:[[decimal]]))
    ;;
    ;;
    (defun DPOF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPOF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    (defun DPOF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPOF|C_RotateOwnership (patron:string executor:string executee:string id:string))
    (defun DPOF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun DPOF|C_TogglePause (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPOF|C_DeployAccount (patron:string id:string account:string))
    (defun DPOF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_MoveCreateRole (patron:string executor:string executee:string id:string))
    (defun DPOF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun DPOF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun DPOF|C_Burn (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun DPOF|C_Mint (patron:string executor:string id:string amount:decimal meta-data-chain:[object]))
    (defun DPOF|C_WipeSlim (patron:string executor:string executee:string id:string nonce:integer amount:decimal))
    (defun DPOF|CC_WipeHeavy (patron:string executor:string executee:string id:string))
    (defun DPOF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun DPOF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun DPOF|C_Transmit (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool))
    (defun DPOF|C_Transfer (patron:string executor:string executee:string id:string nonces:[integer] method:bool))    
    (defun DPOF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
    )

)
;;
(module TS01-C1 GOV
    @doc "TALOS Stage 1 Client Functiones Part 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientOneV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C1                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C1))
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ELITE:module{OuronetPolicyV2} ELITE)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ELITE::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [DALOS_Client]
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        @doc "Controls Smart Ouronet Account properties via boolean triggers"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_ControlSmartAccount patron executor payable-as-smart-contract payable-by-smart-contract payable-by-method)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_ControlSmartAccount executor))
                (format "Smart Ouronet Account {} controlled succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeploySmartAccount executor guard stoa sovereign public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::XE_CollectStoa executor (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Smart Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeployStandardAccount executor guard stoa public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::XE_CollectStoa executor (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Standard Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard)
        @doc "Rotates the governor of a Smart Ouronet Account \
        \ The Governor acts as a governing entity for the Smart Ouronet Account allowing fine control of its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGovernor patron executor governor)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateGovernor executor))
                (format "Ouronet Account {} Governor-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool)
        @doc "Rotates the guard of an Ouronet Safe. Boolean <safe> also enforces the <new-guard>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGuard patron executor new-guard safe)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateGuard executor))
                (format "Ouronet Account {} Primary-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string)
        @doc "Rotates the STOA Account attached to an Ouronet Account. \
        \ The attached STOA Account is the account that makes STOA Payments for specific Ouronet Actions"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateStoa patron executor stoa)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateStoa executor))
                (format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string)
        @doc "Rotates the Sovereign of a Smart Ouronet Account \
        \ The Sovereign of a Smart Ouronet Account acts as its owner, allowing dominion over its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateSovereign patron executor new-sovereign)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateSovereign executor))
                (format "Smart Ouronet Account {} Sovereign rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string)
        @doc "Manualy Updates the Demiourgos Elite Account for one Ouronet Account in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateEliteSingle ea-id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)
                )
                (format "Elite Account Data for {} updated succesfully!" [account])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string)
        @doc "Manualy Updates the Demiourgos Elite Account for two Ouronet Accounts in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateElite ea-id sender receiver)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)
                )
                (format "Elite Account Data for {} and {} updated succesfully!" [sender receiver])
            )
        )
    )
    ;;  [DPTF_Client]
    (defun DPTF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPTF Token <entity-id> costing 100 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|DPTF::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
                (format "Pending Branding for DPTF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPTF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPTF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPTF::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPTF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Issues a new DPTF Token in Bulk, can also be used to issue a single DPTF \
        \ Outputs a string list with the issed DPTF IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Issue patron account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPTF|C_RotateOwnership (patron:string executor:string executee:string id:string)
        @doc "Rotates DPTF ID Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_RotateOwnership patron executor executee id)
                )
                (format "ID {} Ownership succesfully set to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        @doc "Controls the properties of a DPTF Token \
            \ <can-change-owner> <can-upgrade> <can-add-special-role> <can-freeze> <can-wipe> <can-pause>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Control patron executor id cu cco casr cf cw cp)
                )
                (format "Succesfully controlled Properties of {}" [id])
            )
        )
    )
    (defun DPTF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Pause for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_TogglePause patron executor id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleReservation (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Reservations for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleReservation patron executor id toggle)
                )
                (if toggle
                    (format "Reservations succesfully opened for {}" [id])
                    (format "Reservations succesfully closed for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ToggleFee (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Fee collection for a DPTF Token. When a DPTF Token is setup with a transfer fee, \
            \ it will come in effect only when the toggle is on(true)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFee patron executor id toggle)
                )
                (if toggle
                    (format "Fee Collection activated succesfully for {}" [id])
                    (format "Fee Collection deactivated succesfully for {}" [id])
                )
            )
        )
    )
    (defun DPTF|C_SetMinMove (patron:string executor:string id:string min-move-value:decimal)
        @doc "Sets the minimum amount needed to transfer a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetMinMove patron executor id min-move-value)
                )
                (format "MinMove Value succesfully set for {} to {}" [id min-move-value])
            )
        )
    )
    (defun DPTF|C_SetFee (patron:string executor:string id:string fee:decimal)
        @doc "Sets a transfer fee for the DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFee patron executor id fee)
                )
                (format "Fee Promille succesfully set to {} Promille for {}" [fee id])
            )
        )
    )
    (defun DPTF|C_SetFeeTarget (patron:string executor:string id:string target:string)
        @doc "Sets the Fee Collection Target for a DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id target)
                )
                (format "Fee Target succesfully set for {} to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_DonateFees (patron:string executor:string id:string)
        @doc "Sets the Fee Collection target to the DALOS|SC_NAME \
        \ When DPTF Fees collect here, the will be earned by Ouronet Custodians"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id (ref-DALOS::GOV|DALOS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ResetFeeTarget (patron:string executor:string id:string)
        @doc "Sets the Fee Collection target to the OUROBOROS|SC_NAME \
        \ Fees can then be collected by <DPTF|C_WithdrawFees>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ToggleFeeLock (patron:string executor:string id:string toggle:bool)
        @doc "Toggles DPTF Fee Settings Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_ToggleFeeLock patron executor id toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (if toggle
                    (format "Fee Settings succesfully locked for {}" [id])
                    (format "Fee Settings succesfully unlocked  for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_DeployAccount (patron:string id:string account:string)
        @doc "Deploys a DPTF Account. Self-service activation only - the caller must own \
            \ <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure account \
            \ setup (a smart account governed by another module) must use the admin variant \
            \ DPTF|A_DeployAccount in TS01-A instead. \
            \ The core it wraps is now XB_DeployAccount, not C_DeployAccount: that function \
            \ builds no cumulator and was being called from inside its own module, which is \
            \ what a C_ may never be. The BILLING is unchanged and stays here -- a user who \
            \ activates their own token account PAYS, even though the account is normally \
            \ created automatically and they need not do this at all."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPTF::XBv_DeployAccount id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::URCi_DeployAccount account)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])
            )
        )
    )
    (defun DPTF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Freezing of a DPTF Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFreezeAccount patron executor executee id toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <burn-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleBurnRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleMintRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <mint-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleMintRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <fee-exemption-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFeeExemptionRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <transfer-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleTransferRole patron executor executee id toggle)
                )
                (if toggle
                    (format "Transfer Role succesfuly added for {} to {}" [id sa])
                    (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ClearDispo (patron:string executor:string)
        @doc "SELF clear: <executor> settles their OWN OURO dispo by leveraging their existing \
        \ Elite-Auryn. This is the variant every real user wants, and the reason it exists as \
        \ its own name is that the core takes three roles while the self case has only two -- \
        \ making the caller write the same account twice would be an invitation to write two \
        \ different ones by accident. Ownership of <executor> is enforced in TFT's \
        \ DPTF|C>CLEAR-DISPO. See DPTF|C_ClearDispoForeign for the delegated variant."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_ClearDispo patron executor executor)
                )
            )
        )
    )
    (defun DPTF|C_ClearDispoForeign (patron:string executor:string executee:string)
        @doc "FOREIGN clear: <executor> settles <executee>'s OURO dispo. BOTH ownerships are \
        \ enforced in TFT's DPTF|C>CLEAR-DISPO, because clearing a dispo force-spends the \
        \ executee's Elite-Auryn at 2.5x the debt -- so this is not a favour the executor can \
        \ do unilaterally, it is one the executee must sign for. \
        \ \
        \ The use case is narrow and the owner named it: the executee is stranded without \
        \ connectivity and has handed their key to someone who can execute for them. Anyone \
        \ able to run this could equally run DPTF|C_ClearDispo as the executee, so it adds no \
        \ authority -- what it adds is an AUDIT TRAIL naming who actually executed."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_ClearDispo patron executor executee)
                )
            )
        )
    )
    (defun DPTF|C_Burn (patron:string executor:string id:string amount:decimal)
        @doc "Burns a DPTF Token from an executor"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Burn patron executor id amount)
                )
                (format "Succesfully burned {} {} on Account {}" [amount id sa])
            )
        )
    )
    (defun DPTF|C_Mint (patron:string executor:string id:string amount:decimal origin:bool)
        @doc "Mints a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Mint patron executor id amount origin)
                )
                (if origin
                    (format "Succesfully premined {} {} on Account {}" [amount id sa])
                    (format "Succesfully minted {} {} on Account {}" [amount id sa])
                )
            )
        )
    )
    (defun DPTF|C_WipeSlim (patron:string executor:string executee:string id:string amtbw:decimal)
        @doc "Similar to <DPTF|C_Wipe>, but doesnt wipe the whole existing amount"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_WipeSlim patron executor executee id amtbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
                (format "Succesfully wiped {} {} from account {}" [amtbw id sa])
            )
        )
    )
    (defun DPTF|C_Wipe (patron:string executor:string executee:string id:string)
        @doc "Wipes a DPTF Token from a given account in its entirety \
        \ Only works for positive existing amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Wipe patron executor executee id)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
                (format "Succesfully wiped all {} from account {}" [id sa])
            )
        )
    )
    ;;
    (defun DPTF|C_Transmute (patron:string executor:string id:string transmute-amount:decimal)
        @doc "Transmutes a DPTF Token. Transmuting Uses the whole amount as it if were Primary Fee \
        \ without adding to the Primary Fee Counter. \
        \ Thus it can either be collected to the Fee Target Collector \
        \ or to increase Autostake Indices, if the Id is part of any Autostake Pools \
        \ (and these have the neccesary setting set up in the  required manner) \
        \ Only works for DPTFs that have been setup up with transfer fees. \
        \ One of 3 Variants is automatically chosen for transmutation \
        \   Simple  >> For DPTFs that are not Elite Auryn Class \
        \   Elite   >> For Elite Auryn Class DPTFs that require Elite Account Update"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_Transmute patron executor id transmute-amount)
                )
            )
        )
    )
    (defun DPTF|C_Transfer (patron:string executor:string executee:string id:string transfer-amount:decimal method:bool)
        @doc "Transfers a DPTF Token from <executor> to <executee>, using the <transfer-amount> and <method> \
        \ It autonomously choose between the 6 Transfer Variants spread over 3 Classes. \
        \ \
        \   Class 1 >> 1 IGNIS Cost \
        \           [CX_Class1Transfer]             Transfers a DPTF with no transfer Fees (also for VTT amounts < 10.0) \
        \           [CX_Class1TransferUnity]        Transfers UNITY with no transfer Fees (amount < 10.0) \
        \   Class 2 >> 2 IGNIS Cost \
        \           [CX_Class2Transfer]             Transfer a DPTF with a transfer Fee \
        \           [CX_Class2TransferUnity]        Transfers Unity with transfer Fee \
        \           [CX_Class2TransferElite]        Transfers EA Class DPTFs with no Fees \
        \   Class 3 >> 3 IGNIS Cost \
        \           [CX_Class3TransferElite]        Transfers EA Class DPTFs with transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id executor executee transfer-amount))
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_Transfer patron executor executee id transfer-amount method)
                )
                (if (= receiver-amount transfer-amount)
                    (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                    (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                )
            )
        )
    )
    (defun DPTF|C_MultiTransfer (patron:string executor:string executee:string id-lst:[string] transfer-amount-lst:[decimal] method:bool)
        @doc "Transfers Multiple DPTF Tokens from <executor> to <executee>, each token having its own amount specified \
        \ Receiver, as it is only one, can also be a Smart Ouronet Account \
        \ 150k Gas can support between 10 and 20 Transfers, depending on DPTF Token (Simple, Complex, Elite, Unity)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiTransfer patron executor executee id-lst transfer-amount-lst method)
                )
                (format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])
            )
        )
    )
    (defun DPTF|C_BulkTransfer (patron:string executor:string executee-lst:[string] id:string transfer-amount-lst:[decimal])
        @doc "Transfers a DPTF in Bulk, from <executor> to the multiple receivers in <executee-lst>, each with its own amount \
        \ Because <receivers> cannot be Smart Ouronet Accounts, no <method> parameter is needed \
        \ When the Token <id> is set up with a Transfer Fee, and its receiver is on the receiver list, \
        \ it is not exempted from the transfer fee, as is normally the case \
        \ \
        \ It autonomously choose between the 6 Transfer Variants spread over 4 Classes. \
        \ \
        \   Class 0 >> VTT (Volumetric Transfer Tax) Class: (1xL IGNIS or Variable IGNIS Cost for UNITY)\
        \           [CX_Class0BulkTransfer]         Bulk Transfers DPTFs with VTT \
        \           [CX_Class0BulkTransferUnity]    Bulk Transfers UNITY, which also has VTT \
        \   Class 1 >> 1xL IGNIS Cost \
        \           [CX_Class1BulkTransfer]         Bulk Transfers DPTFs with no transfer Fees \
        \   Class 2 >> 2xL IGNIS Cost \
        \           [CX_Class2BulkTransfer]         Bulk Transfers DPTFs with transfer Fees \
        \           [CX_Class2BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with no Transfer Fees \
        \   Class 3 >> 3xL IGNIS Cost \
        \           [CX_Class3BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with Transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiBulkTransfer patron executor [executee-lst] [id] [transfer-amount-lst])
                )
                (format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length executee-lst)])
            )
        )
    )
    (defun DPTF|C_MultiBulkTransfer (patron:string executor:string executee-array:[[string]] id-lst:[string] transfer-amount-array:[[decimal]])
        @doc "Executes Multiple Bulk Transfers in a single Function"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiBulkTransfer patron executor executee-array id-lst transfer-amount-array)
                )
                (format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id-lst) sa-s (length executee-array)])
            )
        )
    )
    ;;  [DPOF_Client]
    (defun DPOF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPOF Token <entity-id> costing 150 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|DPOF::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
                (format "Pending Branding for DPOF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPOF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPOF::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPOF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPOF::C_Issue patron account name ticker decimals can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPOF|C_RotateOwnership (patron:string executor:string executee:string id:string)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_RotateOwnership patron executor executee id)
                )
            )
        )
    )
    (defun DPOF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        @doc "Similar to its DPTF Variant, has an extra boolean trigger for <can-transfer-nft-create-role>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Control patron executor id cu cco casr ctocr cf cw cp sg)
                )
                (format "Succesfully controlled DPOF {} Boolean Properties" [id])
            )
        )
    )
    (defun DPOF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_TogglePause patron executor id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    ;;
    (defun DPOF|C_DeployAccount (patron:string id:string account:string)
        @doc "Similar to its DPTF Variant. Self-service activation only - the caller must \
            \ own <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure \
            \ account setup (a smart account governed by another module) must use the \
            \ admin variant DPOF|A_DeployAccount in TS01-A instead."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPOF::XBv_DeployAccount id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::URCi_DeployAccount account)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])
            )
        )
    )
    (defun DPOF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleFreezeAccount patron executor executee id toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPOF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <add-quantity-role> for a DPOF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleAddQuantityRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPOF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <burn-role> for a DPOF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleBurnRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPOF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves <create-role> for a DPOF Token <id> to <executee> \
        \ Only a single account may have this role"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_MoveCreateRole patron executor executee id)
                )
            )
        )
    )
    (defun DPOF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleTransferRole patron executor executee id toggle)
                )
            )
        )
    )
    ;;
    (defun DPOF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_AddQuantity patron executor id nonce amount)
                )
                (format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])
            )
        )
    )
    (defun DPOF|C_Burn (patron:string executor:string id:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Burn patron executor id nonce amount)
                )
                (format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])
            )
        )
    )
    (defun DPOF|C_Mint (patron:string executor:string id:string amount:decimal meta-data-chain:[object])
        @doc "Mints a DPOF Token, creating it and adding quantity to it \
        \ Outputs the nonce of the created DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (with-capability (P|TS)
                            (ref-DPOF::C_Mint patron executor id amount meta-data-chain)
                        )
                    )
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully minted {} {} on Account {}, on the new Nonce {}" [amount id sa (at 0 (at "output" ico))])
            )
        )
    )
    (defun DPOF|C_WipeSlim (patron:string executor:string executee:string id:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <executee> by <amount> \
            \ Amount may be lower or equal to the nonce amount. \
            \ Requires <id> has <segmentation> set to true"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipeSlim patron executor executee id nonce amount)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <executee> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::CC_WipeHeavy patron executor executee id)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <executee>, presented via an <removable-nonces-obj> object \
        \ \
        \ The object must be pre-read (dirty read) \
        \ \
        \ Example to retrieve the <removable-nonces-obj> \
        \ <(URHC_WipePure executee id)> ; to get the whole object \
        \ <(UCv_TakePureWipe (URHC_WipePure executee id) 165)> ; to get only the first 165 units \
        \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipePure patron executor executee id removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipeClean patron executor executee id nonces)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of <account>'s \
            \ <id> nonces. The UI dirty-reads the plan and fires one such tx per slice, all in \
            \ parallel; slices are disjoint, order-independent and retryable (replay REVERTS). \
            \ Elite re-rank runs per slice — it recomputes from live state, so whichever slice \
            \ lands last leaves the correct final rank under any arrival order."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::Cp_WipeSlice id account removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    ;;
    (defun DPOF|C_Transmit (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by a specific <amount> \
            \ This debits the <executor> nonces by <amount> and creates new nonces on executee of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Transmit patron executor executee id nonces amounts method)
                )
                (ref-ELITE::XE_UpdateElite id executor executee)
                (format "Succesfuly Transmited DPOF {} Nonces {} with Amounts {} from Sender {} to Receiver {}"
                    [id nonces amounts ss sr]
                )
            )
        )
    )
    (defun DPOF|C_Transfer (patron:string executor:string executee:string id:string nonces:[integer] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by changing their Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Transfer patron executor executee id nonces method)
                )
                (ref-ELITE::XE_UpdateElite id executor executee)
                (format "Succesfuly Transmited DPOF {} Nonces {} from Sender {} to Receiver {}"
                    [id nonces ss sr]
                )
            )
        )
    )
    (defun DPOF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
        @doc "Bulk whole-nonce DPOF transfer — one executor, many standard-account receivers (TalosStageOne_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (l:integer (length executee-lst))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_BulkTransfer patron executor executee-lst id nonces-array method)
                )
                (map
                    (lambda (idx:integer)
                        (ref-ELITE::XE_UpdateElite id executor (at idx executee-lst))
                    )
                    (enumerate 0 (- l 1))
                )
                (format "Succesfully bulk-transferred DPOF {} from {} to {} receivers"
                    [id sa-s l]
                )
            )
        )
    )

)

;; --- tables for 02_TS01-C1.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_ClientTwoV2
    @doc "Exposes Ouronet Stage One Second Batch of Client Functions \
        \ Modules: ATS, VST, LQD and ORBR are included in the Second Batch"

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
    (defun ATS|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun ATS|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    ;;Hot Rbt Management
    (defun ATS|HOT-RBT|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun ATS|HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    (defun ATS|HOT-RBT|C_Repurpose (patron:string executor:string executee:string hot-rbt:string nonce:integer))
        ;;
    (defun ATS|C_Issue:list (patron:string account:string ats:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string] rbt-nfr:[bool]))
    (defun ATS|C_RotateOwnership (patron:string executor:string executee:string ats:string))
    (defun ATS|C_Control (patron:string executor:string ats:string can-change-owner:bool syphoning:bool hibernate:bool))
    (defun ATS|C_UpdateRoyalty (patron:string executor:string ats:string royalty:decimal))
    (defun ATS|C_UpdateSyphon (patron:string executor:string ats:string syphon:decimal))
    (defun ATS|C_SetHibernationFees (patron:string executor:string ats:string peak:decimal decay:decimal))
        ;;
    (defun ATS|C_ToggleParameterLock (patron:string executor:string ats:string toggle:bool))
    (defun ATS|C_AddSecondary (patron:string executor:string ats:string reward-token:string rt-nfr:bool))
        ;;
    (defun ATS|C_ControlColdRecoveryFees (patron:string executor:string ats:string c-nfr:bool c-fr:bool))
    (defun ATS|C_SetColdRecoveryFees (patron:string executor:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun ATS|C_SetColdRecoveryDuration (patron:string executor:string ats:string soft-or-hard:bool base:integer growth:integer))
    (defun ATS|C_ToggleElite (patron:string executor:string ats:string toggle:bool))
    (defun ATS|C_ToggleUpgrade (patron:string executor:string ats:string toggle:bool))
    (defun ATS|C_SwitchColdRecovery (patron:string executor:string ats:string toggle:bool))
        ;;
    (defun ATS|C_AddHotRBT (patron:string executor:string ats:string hot-rbt:string))
    (defun ATS|C_ControlHotRecoveryFee (patron:string executor:string ats:string h-fr:bool))
    (defun ATS|C_SetHotRecoveryFee (patron:string executor:string ats:string promile:decimal decay:integer))
    (defun ATS|C_SwitchHotRecovery (patron:string executor:string ats:string toggle:bool))
        ;;
    (defun ATS|C_SetDirectRecoveryFee (patron:string executor:string ats:string promile:decimal))
    (defun ATS|C_SwitchDirectRecovery (patron:string executor:string ats:string toggle:bool))
        ;;
    (defun ATS|CC_RemoveSecondary (patron:string remover:string ats:string reward-token:string))
    (defun ATS|C_WithdrawRoyalties (patron:string ats:string target:string))
    (defun ATS|C_KickStart (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun ATS|C_Fuel (patron:string fueler:string ats:string reward-token:string amount:decimal))
    (defun ATS|C_Coil (patron:string coiler:string ats:string rt:string amount:decimal))
    (defun ATS|C_Curl (patron:string curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun ATS|C_VestedCoil (patron:string coiler-vester:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer))
    (defun ATS|C_VestedCurl (patron:string curler-vester:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer))
    (defun ATS|C_Constrict (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer))
    (defun ATS|C_Brumate (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer))
    (defun ATS|C_Syphon (patron:string syphon-target:string ats:string syphon-amounts:[decimal]))
        ;;
    (defun ATS|C_ColdRecovery (patron:string recoverer:string ats:string ra:decimal))
    (defun ATS|C_Cull (patron:string culler:string ats:string))
        ;;
    (defun ATS|C_HotRecovery (patron:string recoverer:string ats:string ra:decimal))
    (defun ATS|C_Reverse (patron:string recoverer:string id:string nonce:integer))
    (defun ATS|C_Redeem (patron:string redeemer:string id:string nonce:integer))
        ;;
    (defun ATS|C_DirectRecovery (patron:string recoverer:string ats:string ra:decimal))
    ;;
    ;;
    (defun VST|C_CreateFrozenLink:[string] (patron:string dptf:string))
    (defun VST|C_CreateReservationLink:[string] (patron:string dptf:string))
    (defun VST|C_CreateVestingLink:[string] (patron:string dptf:string))
    (defun VST|C_CreateSleepingLink:[string] (patron:string dptf:string))
    (defun VST|C_CreateHibernatingLink:[string] (patron:string dptf:string))
        ;;Frozen
    (defun VST|C_Freeze (patron:string freezer:string freeze-output:string dptf:string amount:decimal))
    (defun VST|C_RepurposeFrozen (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun VST|C_ToggleTransferRoleFrozenDPTF (patron:string s-dptf:string target:string toggle:bool))
        ;;Reservation
    (defun VST|C_Reserve (patron:string reserver:string dptf:string amount:decimal))
    (defun VST|C_Unreserve (patron:string unreserver:string r-dptf:string amount:decimal))
    (defun VST|C_RepurposeReserved (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun VST|C_ToggleTransferRoleReservedDPTF (patron:string s-dptf:string target:string toggle:bool))
        ;;Vesting
    (defun VST|C_Vest (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer))
    (defun VST|C_Unvest (patron:string unvester:string dpof:string nonce:integer))
    (defun VST|C_RepurposeVested (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
        ;;Sleeping
    (defun VST|C_Sleep (patron:string sleeper:string target-account:string dptf:string amount:decimal seconds:integer))
    (defun VST|C_Unsleep (patron:string unsleeper:string dpof:string nonce:integer))
    (defun VST|C_Merge(patron:string merger:string dpof:string nonces:[integer]))
    (defun VST|C_RepurposeMerge (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun VST|C_RepurposeSleeping (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun VST|C_ToggleTransferRoleSleepingDPOF (patron:string s-dpof:string target:string toggle:bool))
        ;;Hibernating
    (defun VST|C_Hibernate (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer))
    (defun VST|C_Awake (patron:string awaker:string dpof:string nonce:integer))
    (defun VST|C_Slumber (patron:string merger:string dpof:string nonces:[integer]))
    (defun VST|C_RepurposeSlumber (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun VST|C_RepurposeHibernating (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun VST|C_ToggleTransferRoleHibernatingDPOF (patron:string s-dpof:string target:string toggle:bool))
    ;;
    ;;
    (defun LQD|C_UnwrapStoa (patron:string unwrapper:string amount:decimal))
    (defun LQD|C_WrapStoa (patron:string wrapper:string amount:decimal))
    ;;#13H fix: LQD|C_RegisterOuronetAccountForUrstoaHoldings removed (2026-08-27) - see
    ;;12_LIQUID.pact's matching note; account creation is UI-constructed, not a Pact function.
    (defun LQD|C_UnwrapUrStoa (patron:string unwrapper:string amount:decimal))
    (defun LQD|C_WrapUrStoa (patron:string wrapper:string amount:decimal))
    ;;
    ;;
    (defun ORBR|C_Compress (client:string ignis-amount:decimal))
    (defun ORBR|C_Sublimate (client:string target:string ouro-amount:decimal))
    (defun ORBR|C_SublimateV2 (client:string target:string ouro-amount:decimal))
    (defun ORBR|C_WithdrawFees (patron:string id:string target:string))

)
;;
(module TS01-C2 GOV
    @doc "TALOS Client Module for Stage 1, namely ATS VST LIQUID and OUROBOROS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientTwoV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C2                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C2))
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|SWPU:module{OuronetPolicyV2} SWPU)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            ;;
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPLC::P|A_AddIMP mg)
            (ref-P|SWPU::P|A_AddIMP mg)
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
    ;;  [ATS_Client]
    (defun ATS|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for ATSPair <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|ATS:module{BrandingUsagePrimaryV2} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|ATS::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|ATS:module{BrandingUsagePrimaryV2} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|ATS::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    (defun ATS|HOT-RBT|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for a HOT-RBT <entity-id> costing 150 IGNIS (Standard DPOF Costs)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-ATS::HOT-RBT|C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun ATS|HOT-RBT|C_Repurpose (patron:string executor:string executee:string hot-rbt:string nonce:integer)
        @doc "Repurposes a Hot-Rbt to a another Account, Can only be done by atspair owner"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_Repurpose patron executor executee hot-rbt nonce)
                )
                (format "Succesfully repurposed HOT-RBT {} Nonce {} to Account {}" [hot-rbt nonce srt])
            )
        )
    )
    ;;
    (defun ATS|C_Issue:list (patron:string account:string ats:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string] rbt-nfr:[bool])
        @doc "Issues and Autostake Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATS::C_Issue patron account ats index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun ATS|C_RotateOwnership (patron:string executor:string executee:string ats:string)
        @doc "Rotates ATSPair Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_RotateOwnership patron executor executee ats)
                )
                (format "Succesfully changed ownership for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_Control (patron:string executor:string ats:string can-change-owner:bool syphoning:bool hibernate:bool)
        @doc "Controls the Properties of an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_Control patron executor ats can-change-owner syphoning hibernate)
                )
                (format "Succesfully controlled ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_UpdateRoyalty (patron:string executor:string ats:string royalty:decimal)
        @doc "Updates the Royalty value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateRoyalty patron executor ats royalty)
                )
                (format "Royalty for ATS-Pair {} updated Succesfully to {} Promile" [ats royalty])
            )
        )
    )
    (defun ATS|C_UpdateSyphon (patron:string executor:string ats:string syphon:decimal)
        @doc "Updates the Syphoning Index value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateSyphon patron executor ats syphon)
                )
                (format "Syphon Index for ATS-Pair {} updated Succesfully to {}" [ats syphon])
            )
        )
    )
    (defun ATS|C_SetHibernationFees (patron:string executor:string ats:string peak:decimal decay:decimal)
        @doc "Updates the Hibernation Fees an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHibernationFees patron executor ats peak decay)
                )
                (format "Hibernation Fees for ATS-Pair {} set to {} Promile-Peak and {} Promile-Decay per Day" [ats peak decay])
            )
        )
    )
    ;;
    (defun ATS|C_ToggleParameterLock (patron:string executor:string ats:string toggle:bool)
        @doc "Toggle ATSPair Parameter Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATS::C_ToggleParameterLock patron executor ats toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
            )
        )
    )
    (defun ATS|C_AddSecondary (patron:string executor:string ats:string reward-token:string rt-nfr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddSecondary patron executor ats reward-token rt-nfr)
                )
                (if rt-nfr
                    (format "Succesfully Added {} as a secondndary Reward Token for the ATS-Pair {} with Native-Fee-Recovery" [ats reward-token])
                    (format "Succesfully Added {} as a secondndary Reward Token for the ATS-Pair {} without Native-Fee-Recovery" [ats reward-token])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_ControlColdRecoveryFees (patron:string executor:string ats:string c-nfr:bool c-fr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlColdRecoveryFees patron executor ats c-nfr c-fr)
                )
                (format "Succesfully controlled Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryFees (patron:string executor:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryFees patron executor ats fee-positions fee-thresholds fee-array)
                )
                (format "Succesfully set Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryDuration (patron:string executor:string ats:string soft-or-hard:bool base:integer growth:integer)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryDuration patron executor ats soft-or-hard base growth)
                )
                (format "Succesfully set Cold Recovery Duration for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_ToggleElite (patron:string executor:string ats:string toggle:bool)
        @doc "Toggles ATSPair Elite Functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleElite patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Elite Mode for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Elite Mode for ATS-Pair {}" [ats])
                )
            )
        )
    )
    (defun ATS|C_ToggleUpgrade (patron:string executor:string ats:string toggle:bool)
        @doc "Sets can-upgrade for an ATS-Pair (audit finding #21L / L3). Gates C_Control \
            \ (can-change-owner/syphoning/hibernate) - false blocks C_Control entirely \
            \ until set back to true."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleUpgrade patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully allowed further Property Upgrades (can-upgrade) for ATS-Pair {}" [ats])
                    (format "Succesfully blocked further Property Upgrades (can-upgrade) for ATS-Pair {} - C_Control is now disabled until this is turned back on" [ats])
                )
            )
        )
    )
    (defun ATS|C_SwitchColdRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Cold Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchColdRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Cold Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Cold Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_AddHotRBT (patron:string executor:string ats:string hot-rbt:string)
        @doc "Adds a Hot-RBT to an ATS-Pair immutably \
            \ Must be a non special DPOF Token with zero Supply \
            \ Ownership of this Token is transfered to the ATS|SC_NAME"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddHotRBT patron executor ats hot-rbt)
                )
                (format "Succesfully added DPOF {} as Hot-RBT for ATS-Pair {}" [hot-rbt ats])
            )
        )
    )
    (defun ATS|C_ControlHotRecoveryFee (patron:string executor:string ats:string h-fr:bool)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlHotRecoveryFee patron executor ats h-fr)
                )
                (format "Succesfully controlled Hot-Recovery Fee for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_SetHotRecoveryFee (patron:string executor:string ats:string promile:decimal decay:integer)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHotRecoveryFees patron executor ats promile decay)
                )
                (format "Succesfully set Hot-Recovery Fees for ATS-Pair {} to {} Promile and {} Days-Decay" [ats promile decay])
            )
        )
    )
    (defun ATS|C_SwitchHotRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchHotRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Hot Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Hot Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_SetDirectRecoveryFee (patron:string executor:string ats:string promile:decimal)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetDirectRecoveryFee patron executor ats promile)
                )
                (format "Succesfully set Direct-Recovery Fees for ATS-Pair {} to {} Promile" [ats promile])
            )
        )
    )
    (defun ATS|C_SwitchDirectRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchDirectRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Direct Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Direct Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    ;;
    (defun ATS|CC_RemoveSecondary (patron:string remover:string ats:string reward-token:string)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::CC_RemoveSecondary remover ats reward-token)
                )
                (format "Succesfully removed RT {} from ATS-Pair" [reward-token ats])
            )
        )
    )
    (defun ATS|C_WithdrawRoyalties (patron:string ats:string target:string)
        @doc "Withdraws ATS-Pair Royalties, if non-zero"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_WithdrawRoyalties ats target)
                )
                (format "Succesfully withdrawn Royalties from ATS-Pair {} to Account {}" [ats st])
            )
        )
    )
    (defun ATS|C_KickStart (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Kickstarst an ATSPair, so that it starts at a given Index \
            \ Can only be done on a freshly created ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_KickStart patron kickstarter ats rt-amounts rbt-request-amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully Kickstarted ATS-Pair {} to an Index of {}" [ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Fuel (patron:string fueler:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an ATSPair with RT Tokens, increasing its Index"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (prev-index:decimal (ref-ATS::URC_Index ats))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Fuel fueler ats reward-token amount)
                )
                (format "Succesfully fueld ATS-Pair {} increasing its index by {}"
                    [ats (- (ref-ATS::URC_Index ats) prev-index)]
                )
            )
        )
    )
    (defun ATS|C_Coil (patron:string coiler:string ats:string rt:string amount:decimal)
        @doc "Coils an RT Token from a specific ATS-Pair, generating a RBT Token \
        \ Only works if <ats> has hibernation off."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Coil patron coiler ats rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} RBT Tokens" [amount rt ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Curl (patron:string curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Curl double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Both ATS-Pairs must have hibernation off for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Curl patron curler ats1 ats2 rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully curled {} {} on ATS-Pairs {} and {} generating {} RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_VestedCoil (patron:string coiler-vester:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Coils a DPTF Token and Vests its output to <target-account> \
            \ Requires that: \
            \ *]Input DPTF is part of an ATSPair, the <ats> \
            \ *]That the RBT of <ats> has a vested counterpart \
            \ \
            \ Outputs the resulted Vested Cold-RBT Amount \
            \ Only the Owner of <coil-token> can execute thi function, \
            \ as this is prerequisite for Vesting"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ref-VST:module{VestingV2} VST)
                    ;;
                    (coil-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats coil-token amount)
                    )
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Coil patron coiler-vester ats coil-token amount)
                            (ref-VST::C_Vest patron coiler-vester target-account c-rbt c-rbt-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} Vested RBT Tokens" [amount coil-token ats c-rbt-amount])
            )
        )
    )
    (defun ATS|C_VestedCurl (patron:string curler-vester:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Same as <ATS|C_VestedCoil> but instead Curls the input Token. \
            \ Requires that : \
            \ *]Input DPTF is part of an ATSPair, the <ats1> \
            \ *]That the Cold-RBT Token of the <ats1> is RT in <ats2> \
            \ *]That Cold-RBT of <ats2> has a vested counterpat \
            \ \
            \ Outputs the resulted Vested Cold-RBT of <ats2>"
        (with-capability (P|TS)
            (let*
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ref-VST:module{VestingV2} VST)
                    ;;
                    (coil1-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 curl-token amount)
                    )
                    (coil2-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 (at "rbt-id" coil1-data) (at "rbt-amount" coil1-data))
                    )
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Curl patron curler-vester ats1 ats2 curl-token amount)
                            (ref-VST::C_Vest patron curler-vester target-account (at "rbt-id" coil2-data) c-rbt2-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully curled {} {} on ATS-Pair {} and {} generating {} Vested RBT Tokens of the second ATS-Pair" 
                    [amount curl-token ats1 ats2 c-rbt2-amount]
                )
            )
        )
    )
    (defun ATS|C_Constrict (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer)
        @doc "Constricts an RT Token from a specific ATS-Pair, generating a RBT Token in HIbernated Form \
        \ Only works if <ats> has hibernation on."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Constrict patron constricter ats rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully constricted {} {} on ATS-Pair {} generating {} Hibernated RBT Tokens" 
                    [amount rt ats (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Brumate (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Brumate double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Second ATS-Pair must have hibernation on for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Brumate patron brumator ats1 ats2 rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully brumated {} {} on ATS-Pairs {} and {} generating {} Hibernated RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Syphon (patron:string syphon-target:string ats:string syphon-amounts:[decimal])
        @doc "Syphons from an ATS Pair, extracting RTs and decreasing ATSPair Index. \
            \ Syphoning can be executed until the set up Syphon limit is achieved"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount syphon-target))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Syphon syphon-target ats syphon-amounts)
                )
                (format "Succesfully syphoned {} RT Amount(s) from ATS-Pair {} to Target {}" [syphon-amounts ats st])
            )
        )
    )
    ;;
    (defun ATS|C_ColdRecovery (patron:string recoverer:string ats:string ra:decimal)
        @doc "Recovers Cold-RBT, disolving it, generating RTs cullable in the future. \
        \ Amount of RTs is determined by the ATS-Pair Index at the Cold Recovery Moment"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_ColdRecovery patron recoverer ats ra)
                )
                (format "Succesfully placed {} {} ATS-Pair RBT into Cold Recovery" [ra ats])
            )
        )
    )
    (defun ATS|C_Cull (patron:string culler:string ats:string)
        @doc "Culls an ATSPair, extracting RTs that are cullable. Fix (audit finding \
            \ #32N / N1): reports a distinct 'nothing to cull yet' message when nothing \
            \ was actually culled, instead of always claiming success - the underlying \
            \ crash-vs-graceful-empty-result fix lives in ATSU.URC_MultiCull."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Cull culler ats)
                    )
                    (cw:[decimal] (at "output" ico))
                    (how-many-tokens:integer (length cw))
                    (total-culled:decimal (fold (+) 0.0 cw))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= total-culled 0.0)
                    (format "Nothing to Cull just yet for ATS-Pair {} - no positions have reached their cull-time" [ats])
                    (format "Succesfully Culled {} RT(s) Tokens with amounts of {} from ATS-Pair {}" [how-many-tokens cw ats])
                )
            )
        )
    )
    ;;
    (defun ATS|C_HotRecovery (patron:string recoverer:string ats:string ra:decimal)
        @doc "Converts a Cold-RBT to a Hot-RBT, preparing it for Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_HotRecovery patron recoverer ats ra)
                )
                (format "Succesfully converted {} RBT to Hot-RBT on ATS-Pair {}" [ra ats])
            )
        )
    )
    (defun ATS|C_Reverse (patron:string recoverer:string id:string nonce:integer)
        @doc "Reverses a Hot-RBT Nonce, converting it to Cold-RBT in its entirety \
            \ as the Hot-RBT doesnt have segmentation turned on"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Recover patron recoverer id nonce)
                )
                (format "Succesfully Converted Hot-RBT {} Nonce {} back into the Native RBT of ATS-Pair {}" [id nonce ats])
            )
        )
    )
    (defun ATS|C_Redeem (patron:string redeemer:string id:string nonce:integer)
        @doc "Redeems a Hot-RBT, recovering RTs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Redeem patron redeemer id nonce)
                )
                (format "Succesfully Redeemed Hot-RBT {} Nonce {} back in RTs for ATS-Pair {}" [id nonce ats])
            )
        )
    )
    ;;
    (defun ATS|C_DirectRecovery (patron:string recoverer:string ats:string ra:decimal)
        @doc "Directly Recovers RBT to RTs using Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_DirectRecovery patron recoverer ats ra)
                )
                (format "Succesfully recovered directly {} RBT Token on ATS-Pair" [ra ats])
            )
        )
    )
    ;;  [VST_Client]
    (defun VST|C_CreateFrozenLink:[string] (patron:string dptf:string)
        @doc "Creates a Frozen Link, issuing a Special-DPTF as a frozen counterpart for another DPTF \
            \ A Frozen Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Frozen variety, is used for implementing the FROZEN Functionality for a DPTF Token \
            \ So called FROZEN Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Frozen Token. \
            \ Frozen Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ Only the <dptf> owner can create Frozen Tokens to Target Accounts, \
            \ or designate other Smart Ouronet Accounts to create them \
            \ \
            \ Frozen Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Frozen Token for adding Liquidity \
            \ generates a Frozen LP Token, which behaves similarly to the Frozen Token \
            \ that is, it can never be converted back to the SWPairs native LP, locking liquidity in place \
            \ Existing LPs can also be frozen, permanently locking liquidity \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateFrozenLink patron dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Frozen Link for the DPTF {}, issuing the Frozen DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateReservationLink:[string] (patron:string dptf:string)
        @doc "Creates a Reservation Link, issuing a Special-DPTF as a reserved counterpart for another DPTF \
            \ A Reservation Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Reserved variety, is used for implementing the RESERVED Functionality for a DPTF Token \
            \ So called RESERVED Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Reserved Token. \
            \ Reserved Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ As opposed to frozen tokens, where only the <dptf> owner can generate them or designated Ouronet Accounts, \
            \ Reserved Tokens can be generated by clients, using as input the <dptf> Token, only when reservations are open by the <dptf> owner \
            \ That is, the <dptf> owner dictates when clients can generate reserved tokens from the input <dptf>, \
            \ and as such, reserved tokens can be used for special discounts when sales are planned with the main <dptf> Token, \
            \ as if they were the main <dptf> token. \
            \ \
            \ Reserved Tokens cannot be used to add liquidty on any Swpair. \
            \ \
            \ OURO will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateReservationLink patron dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Reservation Link for the DPTF {}, issuing the Reserved DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateVestingLink:[string] (patron:string dptf:string)
        @doc "Creates a Vesting Link, issuing a Special-DPOF as a vested counterpart for another DPTF \
            \ A Vesting Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Vested variety, is used for implementing the Vesting Functionality for a DPTF Token \
            \ The <dptf> owner has the ability to vest its <dptf> token into a vested counterpart \
            \ specifying a target account, an offset, a duration and a number of milestones as vesting parameters \
            \ \
            \ The Target account receives the vested token, and according to its input vested parameters, \
            \ can revert it back to the <dptf> counterpart, as vesting intervals expire \
            \ \
            \ Vested Tokens cannot be used to add liquidity on any Swpair \
            \ \
            \ If a Vested Counterpart is created for a Token that is a Cold-RBT in an ATS Pair, \
            \ the RT owner of that ATS Pair can <coil>|<curl> the RT Token, and subsequently <vest> the output Hot-RBT token, \
            \ thus creating an additional layer of locking, for the input <RT> token, by converting it in a Vested Hot-RBT \
            \ OURO, AURYN and ELITE-AURYN will be the first Tokens that will make use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateVestingLink patron dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Vesting Link for the DPTF {}, issuing the Vested DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateSleepingLink:[string] (patron:string dptf:string)
        @doc "Creates a Sleeping Link, issuing a Special-DPOF as a sleeping counterpart for another DPTF \
            \ A Sleeping Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Sleeping variety, is used for implementing the Sleeping Functionality for a DPTF Token \
            \ A Sleeping DPOF is similar to a vested Token, however it has a single period after which it can be converted \
            \ in its entirety, at once, into the initial <dptf> \
            \ As opposed to Vested DPOF Tokens, multiple Sleeping DPOF Tokens, can be unified into a single Sleeping Token \
            \ using a weigthed mean to determine the final time when it can be converted back to the initial <dptf> \
            \ \
            \ As oposed to Vested Tokens, Sleeping Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Sleeping Token for adding Liquidity \
            \ generates a Sleeping LP Token, which behaves similarly to the Sleeping Token, inheriting its sleeping date, \
            \ that is, it can be converted back to the SWPairs native LP, when its sleeping interval expires \
            \ Existing LPs can also be put to sleep, locking liquidity for a given period \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateSleepingLink patron dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Sleeping Link for the DPTF {}, issuing the Sleeping DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateHibernatingLink:[string] (patron:string dptf:string)
        @doc "Creates a Hibernating Link, issuing a Special-DPOF as a hibernating counterpart for another DPTF \
            \ A Hibernating Link is immutable, and noted in the Token Properties of both DPTF and the Special DPOF \
            \ A Special DPOF of the Hibernating variety, is used for implementing the Hibernating Functionality for a DPTF Token \
            \ A Hibernating DPOF is similar to a sleeping Token, with a few particularities. \
            \ It has a day granularity, and up to 100 years can be used for hibernating. \
            \ \
            \ In direct contrast to a Sleeping DPOF, which has to be waited up for it to be converted back to its original DPTF \
            \ the Hibernated DPOF can be converted on Demand back into its original DPTF, however there is a fee to do so, \
            \ if the hibernation period hasnt elaspsed. This fee decreases from 800 promile down to zero at its awakening time \
            \ The fee is automaticaly burned, and cannot be recovered by any means. \
            \ \
            \ Similarly to Sleeping DPOFs, multiple batches can be merged, using the same algoritm implemented for mergind of Sleeping DPOFs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateHibernatingLink patron dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Hibernation Link for the DPTF {}, issuing the Hibernated DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
            )
        )
    )
    ;;  [VST Freezing]
    (defun VST|C_Freeze (patron:string freezer:string freeze-output:string dptf:string amount:decimal)
        @doc "Freezes a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sfa:string (ref-I|OURONET::OI|UC_ShortAccount freeze-output))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Freeze patron freezer freeze-output dptf amount)
                )
                (format "Succesfully freeze {} DPTF {} to Account {}" [amount dptf sfa])
            )
        )
    )
    (defun VST|C_RepurposeFrozen (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @doc "Repurposes a Frozen DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeFrozen patron dptf-to-repurpose repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed Frozen DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleFrozenDPTF (patron:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Frozen DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleFrozenDPTF patron s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Frozen DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Reserving]
    (defun VST|C_Reserve (patron:string reserver:string dptf:string amount:decimal)
        @doc "Reserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount reserver))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Reserve patron reserver dptf amount)
                )
                (format "Account {} succesfully reserved {} {} Tokens" [sr amount dptf])
            )
        )
    )
    (defun VST|C_Unreserve (patron:string unreserver:string r-dptf:string amount:decimal)
        @doc "Unreserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount unreserver))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unreserve patron unreserver r-dptf amount)
                )
                (format "Account {} succesfully unreserved {} {} Tokens" [su amount r-dptf])
            )
        )
    )
    (defun VST|C_RepurposeReserved (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @doc "Repurposes a Reserved DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeReserved patron dptf-to-repurpose repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed Reserved DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleReservedDPTF (patron:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Reserved DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleReservedDPTF patron s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Reserved DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Vesting]
    (defun VST|C_Vest (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer)
        @doc "Vests a DPTF Token, generating ist Vested DPOF Counterspart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sv:string (ref-I|OURONET::OI|UC_ShortAccount vester))
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Vest patron vester target-account dptf amount offset seconds milestones)
                )
                (format "Succesfully vested DPTF {} From Account {} to Account {}" [dptf sv sta])
            )
        )
    )
    (defun VST|C_Unvest (patron:string unvester:string dpof:string nonce:integer)
        @doc "Culls the Vested DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount unvester))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unvest patron unvester dpof nonce)
                )
                (format "Succesfully unvested DPOF {} Nonce {} to Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_RepurposeVested (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @doc "Repurposes a Vested DPOF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeVested patron dpof-to-repurpose nonce repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed Vested DPTF {} Nonce {}from {} to {}" [dpof-to-repurpose nonce srf srt])
            )
        )
    )
    ;;  [VST Sleeping]
    (defun VST|C_Sleep (patron:string sleeper:string target-account:string dptf:string amount:decimal seconds:integer)
        @doc "Sleeps a DPTF Token, generating its Sleeping DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Sleep patron sleeper target-account dptf amount seconds)
                )
                (format "Sucesfully put to Sleep {} DPTF {} on Account {} for a Duration of {} seconds." [amount dptf sta seconds])
            )
        )
    )
    (defun VST|C_Unsleep (patron:string unsleeper:string dpof:string nonce:integer)
        @doc "Culls the Sleeping DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount unsleeper))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unsleep patron unsleeper dpof nonce)
                )
                (format "Succesfully unsleeped DPOF {} Nonce {} on Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_Merge(patron:string merger:string dpof:string nonces:[integer])
        @doc "Merges selected sleeping Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount merger))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Merge patron merger dpof nonces)
                )
                (format "Succesfully merged Sleeping DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeMerge (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @doc "Repurposes multiple Sleeping DPOFs from <repurpose-from> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeMerge patron dpof-to-repurpose nonces repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed and merged Sleeping DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeSleeping (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @doc "Repurposes a single Sleeping DPOF from <repurpose-from> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSleeping patron dpof-to-repurpose nonce repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed Sleeping DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleSleepingDPOF (patron:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Sleeping DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleSleepingDPOF patron s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Sleeping DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [VST Hibernating]
    (defun VST|C_Hibernate (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        @doc "Hibernates a DPTF Token, generating its Hibernated DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Hibernate patron hibernator target-account dptf amount dayz)
                )
                (format "Sucesfully hibernated {} {} on Account {} for a Duration of {} days." [amount dptf sta dayz])
            )
        )
    )
    (defun VST|C_Awake (patron:string awaker:string dpof:string nonce:integer)
        @doc "Culls the Hibernated DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount awaker))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Awake patron awaker dpof nonce)
                    )
                    (output:list (at "output" ico))
                    (v1:decimal (at 0 output))
                    (v2:decimal (at 1 output))
                    (v3:decimal (at 2 output))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= v1 0.0)
                    (format "Awakend DPOF {} Nonce {} with no Hibernation Fee, getting the Full Amount of {} back" [dpof nonce v2])
                    (format "Awakend DPOF {} Nonce {} with a Hibernation Fee of {} Promile, relinquishing {} Tokens and getting only {} Tokens back" [dpof nonce v1 v3 v2])
                )
            )
        )
    )
    (defun VST|C_Slumber (patron:string merger:string dpof:string nonces:[integer])
        @doc "Merges selected hibernated Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount merger))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Slumber patron merger dpof nonces)
                )
                (format "Succesfully merged Hibernated DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeSlumber (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @doc "Repurposes multiple Hibernated DPOFs from <repurpose-from> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSlumber patron dpof-to-repurpose nonces repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed and merged Hibernated DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeHibernating (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @doc "Repurposes a single Hibernating DPOF from <repurpose-from> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeHibernating patron dpof-to-repurpose nonce repurpose-from repurpose-to)
                )
                (format "Succesfully repurposed Hibernated DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleHibernatingDPOF (patron:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Hibernating DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleHibernatingDPOF patron s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Hibernating DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [LIQUID_Client]
    (defun LQD|C_UnwrapStoa (patron:string unwrapper:string amount:decimal)
        @doc "Unwraps DPTF Stoa to Native Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapStoa patron unwrapper amount)
                )
                (format "Succesfully Unwrapped {} STOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapStoa (patron:string wrapper:string amount:decimal)
        @doc "Wraps Native Stoa to DPTF Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapStoa patron wrapper amount)
                )
                (format "Succesfully Wrapped {} STOA on Account {}" [amount sw])
            )
        )
    )
    (defun LQD|C_UnwrapUrStoa (patron:string unwrapper:string amount:decimal)
        @doc "Unwrapper is the Ouronet Account doing the Unwrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapUrStoa patron unwrapper amount)
                )
                (format "Succesfully Unwrapped {} URSTOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapUrStoa (patron:string wrapper:string amount:decimal)
        @doc "Wrapper is the Ouronet Account doing the Wrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapUrStoa patron wrapper amount)
                )
                (format "Succesfully Wrapped {} URSTOA on Account {}" [amount sw])
            )
        )
    )
    ;;  [OUROBOROS_Client]
    (defun ORBR|C_Compress (client:string ignis-amount:decimal)
        @doc "Compresses IGNIS - Ouronet Gas Token, generating OUROBOROS \
            \ Only whole IGNIS Amounts greater than or equal to 1.0 can be used for compression \
            \ Similar to Sublimation, the output amount is dependent on OUROBOROS price, set at a minimum of 1$ \
            \ Compression has 98.5% efficiency, 1.5% is lost as fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_Compress client ignis-amount)
                    )
                )
                (format "Succesfully compressed {} IGNIS to {} OUROBOROS" [ignis-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_Sublimate (client:string target:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Needed for Sublimating negative Amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_Sublimate client target ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_SublimateV2 (client:string target:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Can be used for Sublimation when OURO Supply is Positive, also being used in Firestarter."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_SublimateV2 client target ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
                (at 0 (at "output" ico))
            )
        )
    )
    (defun ORBR|C_WithdrawFees (patron:string id:string target:string)
        @doc "Withdraws collected DPTF Fees collected in standard mode \
        \ DPTF Fees collected in standard mode cumullate on the OUROBOROS Smart Account \
        \ Only the Token Owner can withdraw these fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ORBR::C_WithdrawFees id target)
                )
                (format "Succesfully withdrawn DPTF Fees for DPTF {} to Account {}" [id st])
            )
        )
    )

)

;; --- tables for 03_TS01-C2.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

