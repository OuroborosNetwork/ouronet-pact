;; PYTHIA — Apollo Pythia dual-Apollo API-key registry (Stage 01 core #23).
;; Spec: OuronetInformational/HANDOFF-pact-apollo-pythia-key-module.md
;; Deploy: load THIS file — PythiaV4 + PythiaLedgerV2 interfaces + PYTHIA module ship together.
;; Shared/historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact (PythiaV1–V3, PythiaLedger V1/V2BlockTime).
;; Talos client: 1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact (TalosStageOne_ClientFourV7 embedded).
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
;; Spec (ledger): OuronetInformational/HANDOFF-pact-pyth-ledger.md
;; (create-table ...) at module bottom runs on **first module install** (greenfield).
;; You do not submit separate create-table txs. All eight fire in the PYTHIA deploy tx.
;; If PYTHIA were already on-chain at V3, only PythDaily + PythTotal are additive create-tables.
;;
(interface PythiaV4
    @doc "PYTHIA V4 — V3 dual-Apollo + Config UR prices; select-based inventory is URD_."
    (defun GOV|CronotonKey ())
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
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_DeployApiKey:decimal ())
    (defun URCi_UpdateDualConsumerLane:decimal ())
    (defun URCi_RevokeLink:decimal ())
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
    (defun URD_ApiKeyCount:integer ())
    (defun URD_ApiKeyCountStr:string ())
    (defun URD_DualLinkCount:integer ())
    (defun URD_ListAllApiKeys:[object] ())
    (defun URD_ListAllDualLinks:[object] ())
    (defun URD_ListActiveDualLinks:[object] ())
    (defun URD_ListInactiveDualLinks:[object] ())
    (defun URD_ActiveDualLinkSet:[string] ())
    (defun URD_ApiKeyByConsumer:object (smart-apollo:string))
    ;;
    ;; [INFO]
    (defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun PYTHIA|INFO_LinkDualApiKey:object{OuronetInfoV1.ClientInfo}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun PYTHIA|INFO_UnlinkDualApiKey:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            dual-link-key:string
        ))
    (defun PYTHIA|INFO_UpdateDualConsumerLane:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
)
(interface PythiaLedgerV2
    @doc "Pyth ledger V2 — batch flush entries (explicit day, iz-complete); order-independent txs."
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
    ;;
    (defun A_Flush:string (entries:[object{PYTHIA|S|PythFlushEntry}]))
    (defun UR_PythMaxFlushBatch:integer ())
    (defun UR_PythLedgerEpochStart:time ())
    (defun UR_PythCurrentDay:integer ())
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URD_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
)
;;
(module PYTHIA GOV
    @doc "Dual-Apollo Pythia registry + on-chain Pyth work ledger (daily flush / running total)."
    ;;
    (implements PythiaV4)
    (implements PythiaLedgerV2)
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
    ;;{2}
    (deftable PYTHIA|T|ApiKeys:{PYTHIA|S|ApiKey})                       ;;Key = <apollo-account>
    (deftable PYTHIA|T|DualLinks:{PYTHIA|S|DualLink})                   ;;Key = <dual-link-key>
    (deftable PYTHIA|T|Config:{PYTHIA|S|Config})                        ;;Key = PYTHIA|INFO
    (deftable PYTHIA|T|Revocation:{PYTHIA|S|Revocation})                ;;Key = PYTHIA|REVOCATION
    (deftable PYTHIA|T|PythDaily:{PythiaLedgerV2.PYTHIA|S|PythDaily})   ;;Key = <day ordinal string>
    (deftable PYTHIA|T|PythTotal:{PythiaLedgerV2.PYTHIA|S|PythTotal})   ;;Key = PYTHIA|STOACHAIN
    ;;{3}
    (defun CT_Bar ()                                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR:string                                (CT_Bar))
    (defconst PYTHIA|EPOCH:time                         (time "1970-01-01T00:00:00Z"))
    (defconst PYTHIA|LEDGER-EPOCH-START:time            (time "2026-08-01T00:00:00Z"))
    (defconst PYTHIA|SECONDS-PER-DAY:decimal            86400.0)
    (defconst PYTHIA|APOLLO-LEN:integer                 162)
    (defconst PYTHIA|DUAL-LINK-LEN:integer              325)
    (defconst PYTHIA|INFO:string                        "config")
    (defconst PYTHIA|REVOCATION:string                  "revocation")
    (defconst PYTHIA|STOACHAIN:string                   "stoachain")
    (defconst PYTHIA|DEFAULT-DEPLOY-PRICE:decimal       500.0)
    (defconst PYTHIA|DEFAULT-RENAME-PRICE:decimal       100.0)
    (defconst PYTHIA|REVOKE-IGNIS-FEE:decimal           1.0)
    (defconst PYTHIA|EPOCH-BLOCKS:integer               120)
    (defconst PYTHIA|APOLLO-STANDARD:string             "₱")
    (defconst PYTHIA|APOLLO-SMART:string                "Π")
    (defconst PYTHIA|MAX-DAILY-RANGE:integer            365)
    (defconst PYTHIA|MAX-FLUSH-BATCH:integer            1000)
    ;;#68L fix: removed PYTHIA|FLUSH-GAS-TARGET - dead constant, confirmed zero references
    ;;anywhere; likely a leftover from an earlier gas-based batching design later replaced by
    ;;the count-based PYTHIA|MAX-FLUSH-BATCH cap. No functional change.
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap PYTHIA|OWNER (owner-account:string)
        @doc "Caller controls the Ouronet (DALOS) account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
        )
    )
    ;;{C2}
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
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
        (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]
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
            \ (UC_RevokeIgnisFee), collected via IGNIS::C_Collect in TS01-C4. \
            \ Consumed by exec + INFO."
        (UC_RevokeIgnisFee)
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
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
            )
            (ref-U|DALOS::UDC_Makeid "PYTHIA")
        )
    )
    ;;
    ;;{F0b} [UCK]
    (defun UCK_PythDaily:string (day:integer)
        @doc "PYTHIA|T|PythDaily key = decimal string of day ordinal."
        (int-to-str 10 day)
    )
    (defun UC_PythDayOrdinal:integer (stamp:time)
        @doc "Calendar operating day: 1 = PYTHIA|LEDGER-EPOCH-START (UTC midnight boundary)."
        (+ 1 (floor (/ (diff-time stamp PYTHIA|LEDGER-EPOCH-START) PYTHIA|SECONDS-PER-DAY)))
    )
    (defun UC_AddPythMetrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
        (
            a:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
            b:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
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
    (defun UC_FlushAccFromTotal:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc}
        (tot:object{PythiaLedgerV2.PYTHIA|S|PythTotal})
        @doc "Seed batch fold from current PYTHIA|T|PythTotal row."
        { "total-metrics": (at "total-metrics" tot)
        , "last-day": (at "last-day" tot) }
    )
    (defun UC_FlushEntryMetrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
        (entry:object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry})
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
    ;;
    ;;{F1}  [UR]
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
        @doc "Full Config row (deploy-price + rename-price); defaults when unset."
        (with-default-read PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price" : PYTHIA|DEFAULT-DEPLOY-PRICE, "rename-price" : PYTHIA|DEFAULT-RENAME-PRICE}
            {"deploy-price" := d, "rename-price" := r}
            {"deploy-price" : d, "rename-price" : r}
        )
    )
    (defun UR_DeployPrice:decimal ()
        @doc "Governance-tunable deploy toll (default 500 STOA per Apollo half; collected in TS01-C4)."
        (at "deploy-price" (UR_Config))
    )
    (defun UR_RenamePrice:decimal ()
        @doc "Governance-tunable consumer-lane rename toll (default 100 STOA; collected in TS01-C4)."
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
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV2.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun UR_PythDay:object{PythiaLedgerV2.PYTHIA|S|PythDaily} (day:integer)
        @doc "Full Pyth daily delta row for day ordinal; zeroed row for un-flushed / gap \
            \ days (never aborts, so range reads survive holes in the ledger)."
        (with-default-read PYTHIA|T|PythDaily (UCK_PythDaily day)
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
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV2.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    (defun UR_PythTotal:object{PythiaLedgerV2.PYTHIA|S|PythTotal} ()
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
    (defun UR_PythTotal|TotalMetrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics} ()
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
        (with-default-read PYTHIA|T|PythDaily (UCK_PythDaily day)
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
    ;;
    ;;{F2}  [UDC]
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
    (defun UDC_PythMetrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV2.PYTHIA|S|PythMetrics}."
        { "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    (defun UDC_PythMetrics|Zero:object{PythiaLedgerV2.PYTHIA|S|PythMetrics} ()
        @doc "Zeroed six-metric blob."
        (UDC_PythMetrics 0 0.0 0 0 0 0)
    )
    (defun UDC_PythTotal:object{PythiaLedgerV2.PYTHIA|S|PythTotal}
        (
            total-metrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
            last-day:integer
        )
        @doc "Constructor for object{PythiaLedgerV2.PYTHIA|S|PythTotal}."
        { "total-metrics": total-metrics
        , "last-day": last-day
        }
    )
    (defun UDC_PythTotal|Zero:object{PythiaLedgerV2.PYTHIA|S|PythTotal} ()
        @doc "Zeroed Pyth running total (default before first flush)."
        (UDC_PythTotal (UDC_PythMetrics|Zero) 0)
    )
    (defun UDC_PythDaily:object{PythiaLedgerV2.PYTHIA|S|PythDaily}
        (
            day:integer
            flushed-at:time
            iz-sealed:bool
            metrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
        )
        @doc "Constructor for object{PythiaLedgerV2.PYTHIA|S|PythDaily}."
        { "day": day
        , "flushed-at": flushed-at
        , "iz-sealed": iz-sealed
        , "metrics": metrics
        }
    )
    (defun UDC_PythFlushEntry:object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}
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
        @doc "Constructor for object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}."
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
    ;;
    ;;{FW}  [W]
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
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV2.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun WI_PythDaily:string
        (
            day:integer
            row:object{PythiaLedgerV2.PYTHIA|S|PythDaily}
        )
        @doc "Insert PYTHIA|T|PythDaily full row (first flush of calendar day only)."
        (require-capability (SECURE))
        (insert PYTHIA|T|PythDaily (UCK_PythDaily day) row)
    )
    (defun WU_PythDaily|Metrics:string
        (
            day:integer
            metrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
        )
        @doc "Replace same-day metrics snapshot (open day re-flush)."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCK_PythDaily day) {"metrics": metrics})
    )
    (defun WU_PythDaily|FlushedAt:string (day:integer flushed-at:time)
        @doc "Stamp latest flush time on the open calendar day row."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCK_PythDaily day) {"flushed-at": flushed-at})
    )
    (defun WU_PythDaily|IzSealed:string (day:integer iz-sealed:bool)
        @doc "Seal a calendar day when advancing to the next day."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCK_PythDaily day) {"iz-sealed": iz-sealed})
    )
    ;; WU_PythDaily|Day — not mutable [.]
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV2.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    ;; WI_PythTotal — not used: first row touch is WW_PythTotal (upsert path).
    (defun WW_PythTotal:string (row:object{PythiaLedgerV2.PYTHIA|S|PythTotal})
        @doc "Upsert PYTHIA|T|PythTotal full row (A_Flush total-metrics + last-day)."
        (require-capability (SECURE))
        (write PYTHIA|T|PythTotal PYTHIA|STOACHAIN row)
    )
    ;; WU_PythTotal|TotalMetrics — not used: mutates via WW_PythTotal (full row).
    ;; WU_PythTotal|LastDay — not used: mutates via WW_PythTotal (full row).
    ;;
    ;;{F3}  [URD]
    (defun URD_ApiKeyCount:integer ()
        (length (keys PYTHIA|T|ApiKeys))
    )
    (defun URD_ApiKeyCountStr:string ()
        (format "Pythia Apollo halves registered: {}" [(URD_ApiKeyCount)])
    )
    (defun URD_DualLinkCount:integer ()
        (length (keys PYTHIA|T|DualLinks))
    )
    (defun URD_ListAllApiKeys:[object] ()
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "counterpart" "owner-account"
              "registered-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URD_ListAllDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URD_ListActiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= true))
        )
    )
    (defun URD_ListInactiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= false))
        )
    )
    (defun URD_ActiveDualLinkSet:[string] ()
        @doc "Active dual-link-key strings for Pythia cache mirror."
        (map
            (lambda (row:object) (at "dual-link-key" row))
            (select PYTHIA|T|DualLinks ["dual-link-key"] (where "iz-active" (= true)))
        )
    )
    (defun URD_ApiKeyByConsumer:object (smart-apollo:string)
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
    (defun URD_ListPythDaily:[object{PythiaLedgerV2.PYTHIA|S|PythDaily}] (from:integer to:integer)
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
    ;;{F4}  [UEV]
    (defun UEV_FlushEntries:bool (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
        @doc "Validate flush batch: fold over entries; pure bool (no enforce)."
        (fold
            (lambda (acc:bool entry:object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry})
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
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
            (enforce (= (UR_Counterpart smart-apollo) standard-apollo) "Smart half not linked to Standard")
            dlk
        )
    )
    ;;
    ;;{F5}  [A]
    (defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate (no fee): create active dual with auto PYTHIA-<hash12> lane, or flip inactive C_Link row to true."
        (UEV_IMC)
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
        (UEV_IMC)
        (with-capability (PYTHIA|A>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by Cronoton" [dual-link-key])
    )
    (defun A_UpdateDeployPrice:string (new-price:decimal)
        (UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config new-price (UR_RenamePrice))
            )
        )
        (format "Pythia deploy price set to {}" [new-price])
    )
    (defun A_UpdateRenamePrice:string (new-price:decimal)
        (UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config (UR_DeployPrice) new-price)
            )
        )
        (format "Pythia rename price set to {}" [new-price])
    )
    (defun A_Flush:string (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch flush: each entry is a drain DELTA — ADD onto day row + grand total; iz-complete seals only."
        (UEV_IMC)
        (with-capability (PYTHIA|A>FLUSH entries)
            (XI_FlushPythLedger entries)
        )
        (format "Pythia ledger flushed {} day entries" [(length entries)])
    )
    ;;
    ;;{F6}  [C]
    (defun C_DeployApolloPythiaApiKey:string
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Fee in TS01-C4."
        (UEV_IMC)
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
        (UEV_IMC)
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
        (UEV_IMC)
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
        (UEV_IMC)
        (with-capability (PYTHIA|C>UPDATE-DUAL-LANE dual-link-key new-name)
            (WU_DualLink|ConsumerLane dual-link-key new-name)
        )
        (format "Pythia dual link {} lane renamed to {}" [dual-link-key new-name])
    )
    ;;
    ;;{F7}  [INFO]
    (defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_DeployApiKey (500 STOA per half)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
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
    (defun PYTHIA|INFO_LinkDualApiKey:object{OuronetInfoV1.ClientInfo}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_Link (inactive dual row; no fee)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
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
    (defun PYTHIA|INFO_UnlinkDualApiKey:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            dual-link-key:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_RevokeLink / A_RevokeLink (1 IGNIS)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
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
    (defun PYTHIA|INFO_UpdateDualConsumerLane:object{OuronetInfoV1.ClientInfo}
        (
            patron:string
            dual-link-key:string
            new-name:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_UpdateDualConsumerLane."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
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
    ;;
    ;;{F8}  [XI]
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
    (defun XI_FlushPythLedger:string
        (entries:[object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}])
        @doc "Process batch entries; commit running total once (entries may land in any tx order)."
        ;; SECURE: granted by WW_PythTotal (underlying W_).
        (let
            (
                (now:time (at "block-time" (chain-data)))
                (tot:object{PythiaLedgerV2.PYTHIA|S|PythTotal} (UR_PythTotal))
                (init:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc} (UC_FlushAccFromTotal tot))
                (final:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc}
                    (fold
                        (lambda
                            (
                                acc:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc}
                                entry:object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}
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
    (defun XI_1|ApplyOneFlushEntry:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc}
        (
            acc:object{PythiaLedgerV2.PYTHIA|S|PythFlushAcc}
            entry:object{PythiaLedgerV2.PYTHIA|S|PythFlushEntry}
            now:time
        )
        @doc "Fold step: ADD entry metrics (gateway drain delta) onto day row + grand total; seal flag only."
        ;; SECURE: granted by WI_/WU_PythDaily (underlying W_).
        (let
            (
                (day:integer (at "day" entry))
                (iz-complete:bool (at "iz-complete" entry))
                (delta:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
                    (UC_FlushEntryMetrics entry)
                )
                (total-metrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
                    (at "total-metrics" acc)
                )
                (last-day:integer (at "last-day" acc))
                (next-last:integer (UC_MaxDay last-day day))
                (next-total:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
                    (UC_AddPythMetrics total-metrics delta)
                )
            )
            (if (UR_PythDailyExists day)
                (let
                    (
                        (old-row:object{PythiaLedgerV2.PYTHIA|S|PythDaily} (UR_PythDay day))
                        (day-metrics:object{PythiaLedgerV2.PYTHIA|S|PythMetrics}
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
    ;;
)

;; Module install — (create-table ...) runs in the same tx as (module PYTHIA …) on greenfield deploy.
(create-table P|T)                    ;; policy
(create-table P|MT)                   ;; policy meta
(create-table PYTHIA|T|ApiKeys)       ;; V1 name; V3 schema
(create-table PYTHIA|T|Config)        ;; carryover
(create-table PYTHIA|T|DualLinks)     ;; V3 NEW
(create-table PYTHIA|T|Revocation)    ;; V3 NEW
(create-table PYTHIA|T|PythDaily)     ;; Ledger NEW
(create-table PYTHIA|T|PythTotal)     ;; Ledger NEW