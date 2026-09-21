;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 7 of 24
;; This is STEP 7 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-6 must have run first, including the init steps between deploys.
;; 2 source file(s), 235,153 gas measured in the REPL gas model, 252,613 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact
;;
;; TOTAL: 2 interface(s), 2 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact
;;      interface  SwapperIssueV4
;;      module     SWPI
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact
;;      interface  SwapperLiquidityV2
;;      module     SWPL
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperIssueV4
    @doc "Exposes SWP Issuing Functions. \
        \ Also contains Swap Computation Functions, and the Hopper Function. \
        \ V3: UEV_Issue and C_Issue use SwapperV4.PoolTokens (bumped when Swapper row types moved to SwapperV4)."

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema Hopper
        nodes:[string]
        edges:[string]
        output-values:[decimal]    
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
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput} 
        (dsid:object{UtilitySwpV2.DirectSwapInputData} A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal])
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput} 
        (rsid:object{UtilitySwpV2.ReverseSwapInputData} A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal])
    )
    (defun UDC_Hopper:object{Hopper} (a:[string] b:[string] c:[decimal]))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UCv_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal]))
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal))
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal]))
    (defun UC_VirtualSwap:object{UtilitySwpV2.VirtualSwapEngine} 
        (vse:object{UtilitySwpV2.VirtualSwapEngine} dsid:object{UtilitySwpV2.DirectSwapInputData})
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV2.DirectSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV2.InverseTaxedSwapOutput}
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV2.ReverseSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
    )
    (defun UCv_BareboneSwap:decimal (pool-type:string drsi:object{UtilitySwpV2.DirectRawSwapInput}))
    (defun UC_BareboneInverseSwap:decimal (pool-type:string irsi:object{UtilitySwpV2.InverseRawSwapInput}))
    (defun UCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_EliteFeeReduction:object{UtilitySwpV2.SwapFeez} (account:string fees:object{UtilitySwpV2.SwapFeez}))
    (defun URCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    (defun URC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput} (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput} (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun URCv_Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} validation:bool))
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
        ;;
    (defun URC_InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData} validation:bool))
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun URC_Hopper:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActive:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActiveShortest:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    ;;#65bL Phase 4: URC_Hopper, sourcing its graph from an ALREADY-FETCHED <raw-graph>
    ;;(SWPT::URC_FetchRawGraph) instead of URCx_Hopper's own self-fetch — lets a caller
    ;;doing MULTIPLE unrelated Hopper queries in the same transaction (e.g. the
    ;;topology's raw graph exactly ONCE and reuse it across every query, instead of
    ;;each query independently re-reading and rebuilding it.
    (defun URC_HopperFromRaw:object{Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}])
    )
    ;;#65bL Phase 7: URC_HopperFromRaw again, but sourcing its graph from an
    ;;from <raw-graph> on every call — the STOA-repricing loop's own
    ;;graph structure once per distinct pool touched; this lets that shared build
    ;;happen once and be reused, same shape of win one layer deeper than Phase 4's
    ;;raw-graph sharing.
    (defun URC_HopperFromGraph:object{Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
    )
    ;;#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery. Mirrors
    ;;calls SWPT::URC_ComputeAllRoutes instead of the K=3-capped
    ;;an off-chain caller can choose the routing universe (active-only, full, or any
    ;;subset for Phase 12's varying-scale measurement) and search depth explicitly.
    ;;Meant for off-chain dirty-read use only (see the defun's own @doc).
    (defun URC_HopperExhaustive:object{Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string] max-attempts:integer)
    )
    ;;#34 Phase 7: active-required path validation — wraps SWPT's exists-only structural
    ;;check with an extra can-swap pass. Lives here, not in SWPT, because SWPT deploys
    ;;before SWP and can't reach SWP::UR_CanSwap directly (same reason URC_EdgesActive's
    ;;own whitelist check couldn't live there either).
    (defun URC_ValidatePathActive:bool (nodes:[string] edges:[string]))
    ;;#34 Phase 8: computes a Hopper (feeless output-values) for an ALREADY-CHOSEN
    ;;nodes+edges route (a dirty-read-injected bundle's swap-route or a pricing path),
    ;;walking the EXACT supplied edges — unlike URCx_HopperForNodes (used by the
    ;;self-searching URC_Hopper/URC_HopperActive), this never re-selects a "best" edge
    ;;per hop, since the real execution will use these exact edges regardless. Caller's
    ;;responsibility to validate nodes/edges first (URC_ValidatePathStructure/Active) —
    ;;this function only computes, it does not validate.
    (defun URC_HopperForKnownRoute:object{Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
    )
    (defun URC_BestEdge:string (ia:decimal i:string o:string))
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string]))
        ;;
    (defun URC_OuroPrimordialPrice:decimal ())
    ;;#73C fix: OURO's own worth in WSTOA, per unit — a real 1-unit weighted-pool swap
    ;;through the primordial pool (URC_W-Swap), not the old hand-rolled reserve ratio
    ;;(which silently ignored the pool's own weights). Still zero graph search — OURO
    ;;and WSTOA sit in the same primordial pool, one hop. <ouro>/<wstoa> are accepted
    ;;as params instead of self-fetched, so callers that already hold them (every real
    ;;caller does, via DALOS::UR_CanonicalStoaIds) don't pay for a redundant read — the
    ;;exact regression Phase 8b's own DALOS combined-reader fix was about avoiding.
    ;;Used by URC_WorthWSTOA's own id==OURO shortcut (see that function's own doc).
    (defun URC_SingleOuroWorthWSTOA:decimal (ouro:string wstoa:string))
    ;;#65fL Phase 8b: SSTOA's own worth in WSTOA, per unit, via the ATS autostake index
    ;;— extracted so URC_WorthWSTOA's own id==SSTOA branch and URCx_PrimordialValueAndOuroSupply
    ;;share it without a static recursive-cycle compile error (see the defun's own doc).
    (defun URC_SingleSSTOAWorthWSTOA:decimal ())
    (defun URC_TokenDollarPrice (id:string stoa-pid:decimal))
    (defun URC_SingleWorthWSTOA (id:string))
    (defun URC_WorthWSTOA (id:string amount:decimal))
    (defun URC_PoolValue:[decimal] (swpair:string))
    ;;#65bL Phase 4: URC_WorthWSTOA/URC_PoolValue, sourcing any graph search they need
    ;;via an ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch per call — see
    (defun URC_WorthWSTOAFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}]))
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV3.RawGraphNode}]))
    ;;#65bL Phase 7: URC_WorthWSTOA/URC_PoolValue again, sourcing any graph search via
    ;;an ALREADY-BUILT [GraphNode] instead of rebuilding it from <raw-graph> per
    ;;call — see URC_HopperFromGraph's own doc for the full rationale.
    (defun URC_WorthWSTOAFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV2.GraphNode}]))
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV2.GraphNode}]))
        ;;
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal]))
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal]))
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal]))
    (defun URC_IssuePoolIgnis:decimal ())
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (account:string pool-tokens:[object{SwapperV4.PoolTokens}]))
    (defun URCi_IssuePool:object{IgnisCollectorV3.OutputCumulator} (account:string pool-tokens:[object{SwapperV4.PoolTokens}]))
    (defun URCi_IssueStoa:decimal ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_SwapData (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun UEV_InverseSwapData (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun UEV_Issue (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;  [X] Functions
    ;;
    ;;#36M/M5 fix: forward-module entrypoint for the shared pool-issuance write
    ;;sequence — SWPI's own C_Issue and MTX-SWP::MTX|C_Issue's Step 3 both call this
    ;;instead of each independently reimplementing the same mint/transfer/tracker
    ;;writes. Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
    ;;— a wider list, not an IgnisCollectorV3.OutputCumulator (matches this codebase's
    ;;XE_* convention: the forward module's own C_ composes IGNIS, not this function) —
    ;;so C_Issue can still aggregate every sub-call's own cumulator into its single
    ;;billed response exactly as before, while MTX|C_Issue (which already bills
    ;;separately in its own Step 2) can just take swpair/token-lp and ignore the rest.
    (defun XE_IssueWrite:list (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))

)
;;
(module SWPI GOV
    @doc "SWPI (SwapperIssueV4) handles SWP pool issuance and the swap-math/pricing engine. \
        \ It computes direct and inverse swaps with fees across Stable/Weighted/standard \
        \ pool types, runs the Hopper multi-hop router (best-of-candidate selection), and \
        \ prices tokens/pools in WSTOA. C_Issue/XE_IssueWrite mint the LP token and register \
        \ the pool (folding in XE_AddLPTracker so every issuance path registers)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperIssueV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPI                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPI_ADMIN)))
    (defcap GOV|SWPI_ADMIN ()                           (enforce-guard GOV|MD_SWPI))
    ;;{G5}  functions
    ;;
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPI|CALLER ()
        true
    )
    (defcap P|SWPI|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPI|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|SWPI|REMOTE-GOV))
        (compose-capability (P|SWPI|CALLER))
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
        (with-capability (GOV|SWPI_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWPI|CALLER)))
            )
            (ref-P|SWP::P|A_Add
                "SWPI|RemoteSwpGov"
                (create-capability-guard (P|SWPI|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    ;;
    (defconst EMPTY_HOPPER
        [
            {
                "nodes" : [],
                "edges" : [],
                "output-values" : []
            }
        ]
    )
    (defconst BAR                                       (CT_Bar))
    ;;#36M/M5 fix: named, single source of truth for the genesis LP mint amount —
    ;;was a bare 10000000.0 literal duplicated independently in both C_Issue and
    ;;MTX|C_Issue's own write sequences; now lives once, inside the shared
    ;;XE_IssueWrite both call.
    (defconst GENESIS_LP_SUPPLY                         10000000.0)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;#36M/M5 fix: local cap for XE_IssueWrite (forward-module entrypoint) — no
    ;;checks of its own beyond P|UEV_IMC in the defun itself. Real validation
    ;;(UEV_Issue) already ran in whichever caller's own defcap got here first
    ;;(SWPI|C>ISSUE for C_Issue, or MTX-SWP's own Step 1) — this function only
    ;;performs the already-validated writes, matching the XE_* contract of no
    ;;enforce/UEV_* beyond P|UEV_IMC.
    (defcap SWPI|XE>ISSUE-WRITE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SWPI|C>ISSUE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        ;;CONDITIONAL authorisation, hoisted 2026-09-14: only a PRIMORDIAL issuance (p) needs the
        ;;admin key, so this cannot become an unconditional gate -- but when it does apply it must
        ;;apply BEFORE UEV_Issue, or a stranger's refusal comes from a shape rule and the admin
        ;;check is never the thing that stopped them. The branch is preserved exactly.
        (if p
            (compose-capability (GOV|SWPI_ADMIN))
            true
        )
        (UEV_Issue account pool-tokens fee-lp weights amp p)
        (compose-capability (P|DT))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (
            dsid:object{UtilitySwpV2.DirectSwapInputData}
            A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                A
                X
                input-amounts 
                input-positions
                output-position
                (ref-DPTF::UR_Decimals output-id)
                weights
            )
        )
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (
            rsid:object{UtilitySwpV2.ReverseSwapInputData}
            A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                A
                X
                output-amount
                output-position
                input-position
                (ref-DPTF::UR_Decimals input-id)
                weights
            )
        )
    )
    (defun UDC_Hopper:object{SwapperIssueV4.Hopper} (a:[string] b:[string] c:[decimal])
        {"nodes"            : a
        ,"edges"            : b
        ,"output-values"    : c}
    )
    ;;{5.2}  Compute [UC]
    (defun UCv_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal])
        @doc "Maximum Pool Deviation is (n-1)/n, and max allowed deviation for asymmetric liq is 40% of this value"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (l1:integer (length pool-reserves))
                (l2:integer (length asymmetric-liq))
                (l3:integer (length w))
                (iz-asymmetric:bool (contains 0.0 asymmetric-liq))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce iz-asymmetric "Invalid Values to Compute Deviation In Value Shares")
            (let
                (
                    (ref-U|VST:module{UtilityVstV2} U|VST)
                    (sw:decimal (fold (+) 0.0 w))
                    (iz-weigthed:bool (if (= sw 1.0) true false))
                    ;;
                    (initial-shares:[decimal] (UC_PoolShares pool-reserves w))
                    (asymmetric-shares:[decimal] (zip (*) initial-shares asymmetric-liq))
                    (new-total-shares:decimal (+ 5040000.0 (fold (+) 0.0 asymmetric-shares)))
                    (new-supply:[decimal] (zip (+) pool-reserves asymmetric-liq))
                    ;;
                    (aw:[decimal] (if iz-weigthed w (ref-U|VST::UCv_SplitBalanceForVesting 24 1.0 l1)))
                    (deviated-shares:[decimal] (UC_DeviatedShares new-supply initial-shares new-total-shares))
                    (diff-with-deviated-shares:[decimal] (zip (-) aw deviated-shares))
                    (abs-dwds:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] idx:integer)
                                (ref-U|LST::UC_AppL acc (abs (at idx diff-with-deviated-shares )))
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    ;;Total Deviation must be divided by 2, to account for gain and losses in share variation
                    (total-deviation:decimal (floor (/ (fold (+) 0.0 abs-dwds) 2.0) 24))
                )
                total-deviation
            )
        )
    )
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (floor (/ (* (at idx pool-reserves)(at idx pool-shares)) new-total-shares) 24)
                    )
                )
                []
                (enumerate 0 (- (length pool-reserves) 1))
            )
        )
    )
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (size:decimal (dec (length pool-reserves)))
                (sw:decimal (fold (+) 0.0 w))
                (iz-weigthed:bool (if (= sw 1.0) true false))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (amount:decimal (at idx pool-reserves))
                            (position-share:decimal
                                (if iz-weigthed
                                    (* 5040000.0 (at idx w))
                                    (/ 5040000.0 size)
                                )
                            )
                            (amount-share:decimal
                                (floor (/ position-share amount) 24)
                            )
                        )
                        (ref-U|LST::UC_AppL acc amount-share)
                    )
                )
                []
                (enumerate 0 (- (length w) 1))
            )
        )
    )
    (defun UC_VirtualSwap:object{UtilitySwpV2.VirtualSwapEngine} 
        (vse:object{UtilitySwpV2.VirtualSwapEngine} dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Executes a Virtual Swap, saving data in the Output Object"
        (let
            (
                ;;Unwrap Input Objects
                (v-tokens:[string] (at "v-tokens" vse))
                (v-prec:[integer] (at "v-prec" vse))
                (account:string (at "account" vse))
                (account-supply:[decimal] (at "account-supply" vse))
                (swpair:string (at "swpair" vse))
                (X:[decimal] (at "X" vse))
                (A:decimal (at "A" vse))
                (W:[decimal] (at "W" vse))
                (F:object{UtilitySwpV2.SwapFeez} (at "F" vse))
                (fuel:[decimal] (at "fuel" vse))
                (special:[decimal] (at "special" vse))
                (boost:[decimal] (at "boost" vse))
                (swaps:[object{UtilitySwpV2.DirectSwapInputData}] (at "swaps" vse))
                ;;
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (input-positions:[integer] (UCv_PoolTokenPositions swpair input-ids))
                (output-position:integer (at 0 (UCv_PoolTokenPositions swpair [output-id])))
                ;;
                (swap-result:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (UC_BareboneSwapWithFeez account pool-type dsid F A X v-prec input-positions output-position W)
                )
                (tsoa:decimal (fold (+) 0.0 [(at "o-id-special" swap-result) (at "o-id-liquid" swap-result) (at "o-id-netto" swap-result)]))
                (tsoa-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [tsoa]))
                (remainder-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [(at "o-id-netto" swap-result)]))
                (input-amounts-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts))
            )
            (ref-U|SWP::UDC_VirtualSwapEngine
                v-tokens v-prec account
                (zip (+) remainder-filled (zip (-) account-supply input-amounts-filled)) 
                swpair 
                (zip (-) (zip (+) X input-amounts-filled) remainder-filled)
                A W F
                (zip (+) fuel (at "lp-fuel" swap-result))
                (ref-U|LST::UC_ReplaceAt special output-position (+ (at output-position special) (at "o-id-special" swap-result)))
                (ref-U|LST::UC_ReplaceAt boost output-position (+ (at output-position boost) (at "o-id-liquid" swap-result)))
                (ref-U|LST::UC_AppL swaps dsid)
            )
        )
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV2.DirectSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
        @doc "Performs a Direct Swap with Fees Computation, outputing results in an object{UtilitySwpV2.DirectTaxedSwapOutput} \
            \ Given proper inputs, can be used for an actual Swap Functions, to save redundant code."
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                ;;
                ;;From the input amounts, compute FeeSharesExcludingLpFee <fselp>
                (fselp:decimal (- 1000.0 f1))
                (input-amounts-for-swap:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (floor
                                    (* (at idx input-amounts) (/ fselp 1000.0))
                                    (at (at idx input-positions) X-prec)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length input-amounts) 1))
                    )
                )
                (dsid-for-swap:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts-for-swap output-id)
                )
                (drsi:object{UtilitySwpV2.DirectRawSwapInput}
                    (UDC_DirectRawSwapInput dsid-for-swap A X input-positions output-position weights)
                )
                (input-amounts-for-lp:[decimal] (zip (-) input-amounts input-amounts-for-swap))
                (input-amounts-for-lp-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts-for-lp))
                ;;
                ;;Total-Swap-Output-Amount <tsoa> is computed without them, then splited into 3 parts: 
                ;;special, boost, remainder
                (tsoa:decimal (UCv_BareboneSwap pool-type drsi))
                (special:decimal (floor (* (/ f2 fselp) tsoa) o-prec))
                (boost:decimal (floor (* (/ f3 fselp) tsoa) o-prec))
                (remainder:decimal (- tsoa (+ special boost)))
                (output:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (ref-U|SWP::UDC_DirectTaxedSwapOutput
                        input-amounts-for-lp-filled
                        output-id
                        special
                        boost
                        remainder
                    )
                )
            )
            output
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV2.InverseTaxedSwapOutput}
        
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV2.ReverseSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
        @doc "Performs a Reverse Swap with Fees Computation, outputing results in an object{UtilitySwpV2.InverseTaxedSwapOutput} \
            \ Use Case is displaying Input Amounts for a Swap when the desired Output Amount of a Token is entered first. \
            \ However not only the input required can be displayed, but also the susequent fees that would be incurred"
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                (i-prec:integer (at input-position X-prec))
                ;;
                ;;Star by computing the Output fee shares <ofs>
                (ofs:decimal (- 1000.0 (fold (+) 0.0 [f1 f2 f3])))
                ;;Compute Output-Amount per fee Share <oapfs>
                (oapfs:decimal (floor (/ output-amount ofs) o-prec))
                (boost:decimal (floor (* f3 oapfs) o-prec))
                (special:decimal (floor (* f2 oapfs) o-prec))
                ;;Then Compute Total-Swap-Output-Amount <tsoa>
                (tsoa:decimal (fold (+) 0.0 [output-amount boost special]))
                ;:Remake a new rsid
                (new-rsid:object{UtilitySwpV2.ReverseSwapInputData} 
                    (ref-U|SWP::UDC_ReverseSwapInputData output-id tsoa input-id)
                )
                (irsi:object{UtilitySwpV2.InverseRawSwapInput}
                    (UDC_InverseRawSwapInput new-rsid A X output-position input-position weights)
                )
                ;;Now Compute the Input Amount needed to get the <tsoa>, the Partial-Input-Amount <pia>
                ;;<pia> is part of the TotalInputAmount, that would be used for a direct swap, after LP fees have been retained
                (pia:decimal (UC_BareboneInverseSwap pool-type irsi))
                ;;Now Compute the Total-Input-Amouant <tia>
                (tia:decimal (floor (/ (* 1000.0 pia) (- 1000.0 f1)) i-prec))
                (output:object{UtilitySwpV2.InverseTaxedSwapOutput}
                    (ref-U|SWP::UDC_InverseTaxedSwapOutput
                        boost
                        special
                        (URC_IndirectRefillAmounts X [input-position] [(- tia pia)])
                        input-id
                        tia
                    )
                )
            )
            output
        )
    )
    ;;
    (defun UCv_BareboneSwap:decimal
        (pool-type:string drsi:object{UtilitySwpV2.DirectRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (l1:integer (length (at "input-amounts" drsi)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UC_ComputeY drsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeWP drsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeEP drsi))
                -1.0
            )
        )
    )
    (defun UC_BareboneInverseSwap:decimal 
        (pool-type:string irsi:object{UtilitySwpV2.InverseRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UCv_ComputeInverseY irsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeInverseWP irsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeInverseEP irsi))
                -1.0
            )
        )
    )
    (defun UCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        @doc "Same result as <URCv_PoolTokenPositions> but being done without reading <swpair> data \
        \ Result is simply computed, through the <swpair> string"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::UCv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    (defun UC_BestHopper:object{SwapperIssueV4.Hopper} (candidates:[object{SwapperIssueV4.Hopper}])
        @doc "Picks the candidate Hopper with the highest final output value. \
            \ <candidates> must be non-empty (caller's responsibility — <URCx_Hopper> \
            \ only calls this once it has confirmed at least one route was found)."
        (if (<= (length candidates) 1)
            (at 0 candidates)
            (fold
                (lambda
                    (best:object{SwapperIssueV4.Hopper} idx:integer)
                    (let
                        (
                            (candidate:object{SwapperIssueV4.Hopper} (at idx candidates))
                            (best-final:decimal (at 0 (take -1 (at "output-values" best))))
                            (candidate-final:decimal (at 0 (take -1 (at "output-values" candidate))))
                        )
                        (if (> candidate-final best-final) candidate best)
                    )
                )
                (at 0 candidates)
                (enumerate 1 (- (length candidates) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCx_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string])
        @doc "Shared Hopper-computation core for <URC_Hopper>/<URC_HopperActive> — \
            \ identical in every respect except which <swpairs> universe routing \
            \ is allowed to consider. Internal only, not on <SwapperIssueV4>. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutes> \
            \ (#34M/M2's original fix). Measured directly against this codebase's \
            \ real, organically-grown ~102-pool topology (not a hand-engineered one) \
            \ across 7 representative pairs spanning 1-8 hops: best-of-3 found a \
            \ better route than the single first-found one in ZERO of them — 0.0% \
            \ difference every time. #34M/M2's own original proof that best-of-3 \
            \ matters used a deliberately hand-built diamond topology (issuance order \
            \ controlled specifically to make BFS's first-found route the weak one) \
            \ to demonstrate the FAILURE MODE is real — it never claimed the failure \
            \ mode manifests naturally at scale, and per this measurement, it \
            \ doesn't, here: with dozens of parallel pools and organic swap activity \
            \ pushing chronically-unbalanced pools back toward parity, first-found \
            \ and best-of-3 converge. Switched to a single <SWPT::URC_ComputeGraphPath> \
            \ call — the greedy, single-shot search <URC_HopperActiveShortest> \
            \ already uses elsewhere. <SWPT::URC_ComputeAlternateRoutes> itself is \
            \ NOT deleted (still correct, still tested, `SWP|TX 032c`-`032g`'s own \
            \ adversarial proof of the original failure mode stays as regression \
            \ coverage) — just no longer the default live-routing path. \
            \ CAVEAT, worth stating plainly: URCx_HopperForNodes's own per-hop \
            \ <URC_BestEdgeFiltered> selection is a GREEDY choice — picking the best \
            \ available edge at each individual hop does not mathematically guarantee \
            \ the overall path is the highest-value one achievable end to end (a \
            \ locally-optimal choice at every step is not the same as a globally- \
            \ optimal path). This was already true before this fix, at every K \
            \ (including best-of-3) — this fix does not introduce that limitation, it \
            \ was always structurally present; it only removes the (measured, at this \
            \ topology, not currently earning its cost) 2-candidate cross-route \
            \ comparison layered on top of it. \
            \ #65bL Phase 1 fix: checks SWPT|PathCache (via URC_ReadPathCacheFresh) \
            \ first — on a fresh hit, skips the live BFS search entirely and \
            \ uses the cached node-path as the sole candidate. Safe because the real \
            \ per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes regardless of where the node-path came from — a \
            \ cache hit only changes WHICH nodes get tried, never how an edge gets \
            \ picked or validated. On a miss (or a stale entry, topology-version \
            \ behind current), falls through to the unchanged live search."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list at all — the Tracer's
                ;;storage is principal-agnostic (SwapTracerV3).
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — a `let` binding here would
                ;;evaluate unconditionally even on a hit, silently paying for the live
                ;;search Phase 1's whole point is to skip. Nested inside the `if`
                ;;instead so a cache hit never touches SWPT::URC_ComputeGraphPathFromRaw.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        ;;#65bL Phase 5 fix: must go through the raw-graph-once path
                        ;;(URC_FetchRawGraph + URC_ComputeGraphPathFromRaw), NOT the
                        ;;plain self-fetching URC_ComputeGraphPath — that function was
                        ;;never touched by Phase 2's optimization (it only ever makes
                        ;;one call, so cross-attempt sharing never applied to it), so
                        ;;using it here would mean a SINGLE search that's still paying
                        ;;the pre-Phase-2 cost, while best-of-3's own first attempt
                        ;;(via URC_ComputeAlternateRoutes's own internal fetch) is
                        ;;already Phase-2-cheap. Measured directly: using the plain
                        ;;self-fetching path here was NET MORE EXPENSIVE than
                        ;;best-of-3, exactly backwards from the goal — caught before
                        ;;shipping, not after.
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw
                                        hopper-input-id hopper-output-id swpairs
                                        (ref-SWPT::URC_FetchRawGraph
                                            (ref-U|SWP::UC_MakeGraphNodes hopper-input-id hopper-output-id swpairs)
                                        )
                                    )
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URCx_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> (<SWPT::URC_FetchRawGraph>) instead of \
            \ letting <SWPT::URC_ComputeGraphPathFromRaw> fetch its own — for a caller \
            \ making MULTIPLE unrelated Hopper queries in one transaction (the \
            \ STOA-repricing loop: one query per distinct pool touched, each to a \
            \ different first-token but the SAME destination, WSTOA) who fetches the \
            \ whole topology's raw graph exactly ONCE and reuses it across every \
            \ query. Safe because <SWPT::UC_MakeGraphNodes> (the node-universe \
            \ derivation both the fetch and every query rely on) is <input>/<output>- \
            \ independent by construction — it derives every token appearing across \
            \ the full <swpairs> list, regardless of which specific pair is being \
            \ queried — so ONE raw-graph fetched against a given <swpairs> universe \
            \ is valid for EVERY query against that same universe, not just the one \
            \ it happened to be fetched for. Still checks SWPT|PathCache first, \
            \ identically to <URCx_Hopper> — a cache hit is even cheaper than a \
            \ shared-raw-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutesFromRaw> \
            \ — see <URCx_Hopper>'s own doc for the full measured rationale (identical \
            \ here, same shared decision)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw hopper-input-id hopper-output-id swpairs raw-graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URCx_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> (<SWPT::UC_MakeGraphFromRaw>) instead of \
            \ rebuilding it from <raw-graph> on every call — see \
            \ <URC_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing, one layer deeper than Phase 4's raw-graph \
            \ sharing). Still checks SWPT|PathCache first, identically to \
            \ <URCx_Hopper>/<URCx_HopperFromRaw> — a cache hit is even cheaper than \
            \ a shared-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromGraph hopper-input-id hopper-output-id graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_EliteFeeReduction:object{UtilitySwpV2.SwapFeez} (account:string fees:object{UtilitySwpV2.SwapFeez})
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
            )
            (ref-U|SWP::UDC_SwapFeez
                (ref-U|DALOS::UC_GasCost (at "lp" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "special" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "boost" fees) major minor false)
            )
        )
    )
    (defun URCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens (ref-SWP::UR_PoolTokens swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::URv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    ;;
    (defun URC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                input-amounts 
                (URCv_PoolTokenPositions swpair input-ids)
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-DPTF::UR_Decimals output-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    (defun URC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                output-amount
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-SWP::URv_PoolTokenPosition swpair input-id)
                (ref-DPTF::UR_Decimals input-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    ;;
    (defun URCv_Swap:decimal 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (l1:integer (length (at "input-amounts" dsid)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (if validation
                (UEV_SwapData swpair dsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-Swap swpair dsid))
                ((= pool-type "W") (URC_W-Swap swpair dsid))
                ((= pool-type "P") (URC_P-Swap swpair dsid))
                -1.0
            )
        )
    )
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = Position of the input token (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeY
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Weigthed Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeWP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeEP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_InverseSwap:decimal
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
            )
            (if validation
                (UEV_InverseSwapData swpair rsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-InverseSwap swpair rsid))
                ((= pool-type "W") (URC_W-InverseSwap swpair rsid))
                ((= pool-type "P") (URC_P-InverseSwap swpair rsid))
                -1.0
            )
        )
    )
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UCv_ComputeInverseY
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseWP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseEP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    ;;
    (defun URCx_HopperForNodes:object{SwapperIssueV4.Hopper}
        (nodes:[string] hopper-input-amount:decimal swpairs:[string])
        @doc "Computes the Hopper object (best per-hop edge + accumulated output) for \
            \ an ALREADY-KNOWN <nodes> path. Split out of <URCx_Hopper> (#34M/M2 fix) \
            \ so the identical per-hop best-edge computation can be run once per \
            \ candidate route in <URCx_Hopper>'s best-of-K comparison, not just the \
            \ single first-found route. Computes: \
            \ 1] The hops along <nodes>, the <edges> as the highest-output edge from all available \
            \ #49L fix: was 'cheapest available edge' — backwards framing (C1/#6C's own fix made \
            \ this maximize output among parallel pools, not minimize cost) \
            \ 2] The best <output> values using said best <edges>, given the <hopper-input-amount>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (if (!= nodes [BAR])
                (let
                    (
                        (fl:[object{SwapperIssueV4.Hopper}]
                            (fold
                                (lambda
                                    (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                    (ref-U|LST::UC_ReplaceAt
                                        acc
                                        0
                                        (let
                                            (
                                                (input:decimal
                                                    (if (= idx 0)
                                                        hopper-input-amount
                                                        (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                    )
                                                )
                                                (i-id:string (at idx nodes))
                                                (o-id:string (at (+ idx 1) nodes))
                                                ;;#19H fix: restrict edge candidates to this call's
                                                ;;<swpairs> universe (full for <URC_Hopper>, active-only
                                                ;;for <URC_HopperActive>) — a disabled parallel pool can
                                                ;;never be chosen over an active one, or at all when
                                                ;;routing active-only.
                                                (best-edge:string (URC_BestEdgeFiltered input i-id o-id swpairs))
                                                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                    (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                )
                                                (output:decimal (URCv_Swap best-edge dsid false))
                                            )
                                            (UDC_Hopper
                                                nodes
                                                (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) best-edge)
                                                (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                            )
                                        )
                                    )
                                )
                                EMPTY_HOPPER
                                (enumerate 0 (- (length nodes) 2))
                            )
                        )
                    )
                    (at 0 fl)
                )
                (at 0 EMPTY_HOPPER)
            )
        )
    )
    (defun URC_HopperForKnownRoute:object{SwapperIssueV4.Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
        @doc "#34 Phase 8: like URCx_HopperForNodes, computes the feeless per-hop output \
            \ chain for a KNOWN path — but walks the caller-supplied <edges> directly \
            \ instead of re-deriving a 'best' edge per hop via URC_BestEdgeFiltered. \
            \ This matters: a dirty-read-injected bundle's swap-route is what real \
            \ execution (XI_SmartSwapCore) will actually walk, hop for hop — the feeless \
            \ quote used for the slippage floor check must be computed against those SAME \
            \ edges, not a possibly-different 'best' edge a live re-derivation might pick \
            \ when parallel pools exist between the same two tokens (that mismatch could \
            \ silently let a worse real execution slip past a floor check computed on a \
            \ better hypothetical route). Also reused for pricing paths (boost-path, \
            \ stoa-paths) where the caller-chosen edges are likewise the ones that matter, \
            \ not a re-optimized alternative. Caller validates nodes/edges beforehand — \
            \ this function trusts its input and only computes."
        (if (!= nodes [BAR])
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (le:integer (length edges))
                )
                (if (= le 0)
                    (UDC_Hopper nodes [] [])
                    (let
                        (
                            (fl:[object{SwapperIssueV4.Hopper}]
                                (fold
                                    (lambda
                                        (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                        (ref-U|LST::UC_ReplaceAt
                                            acc
                                            0
                                            (let
                                                (
                                                    (input:decimal
                                                        (if (= idx 0)
                                                            hopper-input-amount
                                                            (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                        )
                                                    )
                                                    (i-id:string (at idx nodes))
                                                    (o-id:string (at (+ idx 1) nodes))
                                                    (swpair:string (at idx edges))
                                                    (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                    )
                                                    (output:decimal (URCv_Swap swpair dsid false))
                                                )
                                                (UDC_Hopper
                                                    nodes
                                                    (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) swpair)
                                                    (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                                )
                                            )
                                        )
                                    )
                                    [(UDC_Hopper nodes [] [])]
                                    (enumerate 0 (- le 1))
                                )
                            )
                        )
                        (at 0 fl)
                    )
                )
            )
            (at 0 EMPTY_HOPPER)
        )
    )
    (defun URC_HopperExhaustive:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] max-attempts:integer
        )
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not URCx_Hopper's fixed best-of-3 approximation. Identical shape to \
            \ URCx_Hopper (route-then-price-then-pick-best) but sources candidate \
            \ node-paths from SWPT::URC_ComputeAllRoutes (a real parameterized search \
            \ up to <max-attempts>, P0.2's flat +1000 caller-side escalation pattern \
            \ and P0.2/P0.4's outer-hard-stop/depth-cap already enforced inside that \
            \ function) instead of the K=3-capped URC_ComputeAlternateRoutes. Reuses \
            \ URCx_HopperForNodes (per-candidate feeless value) and UC_BestHopper (pick \
            \ the genuinely highest-output candidate, P1.8's requirement — never by hop \
            \ count as a proxy for cost) completely unchanged; no new value-computation \
            \ logic needed, same division of labor URCx_Hopper already established. \
            \ Exposes <swpairs> directly (unlike the hidden-universe URC_Hopper/ \
            \ URC_HopperActive public wrappers) so a caller picks the routing universe \
            \ explicitly — active-only for real swap discovery, or any subset for \
            \ Phase 12's varying-scale measurement (P2.1). Off-chain dirty-read use \
            \ only — never call this from a paid transaction, that defeats the entire \
            \ point of the #34/#34M redesign."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (routes:[[string]]
                    (ref-SWPT::URC_ComputeAllRoutes hopper-input-id hopper-output-id swpairs max-attempts)
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Creates a Hopper Object routed over the FULL swpair universe, \
            \ including <can-swap>=false pools. Used internally for issuance-time \
            \ pricing (<URC_WorthWSTOA>, <UEV_Issue>'s principal-anchoring check), \
            \ which must work even when neighboring pools aren't swap-enabled yet. \
            \ Live swap-execution/quote callers must use <URC_HopperActive> \
            \ instead (#19H) — routing a real user swap over disabled pools is \
            \ the exact bug that fix closes."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs))
        )
    )
    (defun URC_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URC_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — see \
            \ <URCx_HopperFromRaw>'s own doc for the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromRaw hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) raw-graph)
        )
    )
    (defun URC_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URC_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> instead of rebuilding it from \
            \ <raw-graph> on every call — see <URCx_HopperFromGraph>'s own doc for \
            \ the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromGraph hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) graph)
        )
    )
    (defun URC_HopperActive:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Live-swap-execution routing entrypoint — restricts BFS routing to \
            \ <can-swap>=true pools only, so a disabled pool can never be \
            \ BFS-selected and then rejected downstream with no fallback (#19H). \
            \ Used by SWPU's actual swap-execution and slippage-quote call sites."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_ActiveSwpairs))
        )
    )
    (defun URC_HopperActiveShortest:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Lightweight Hopper routing over <can-swap>=true pools only — a single \
            \ shortest BFS route (<SWPT::URC_ComputeGraphPath>), never the best-of-3 \
            \ alternate-route search <URC_HopperActive> runs (P0.6, SWP exhaustive- \
            \ path-search HANDOFF doc). Built for <SWPU::XI_RawLiquidPump>'s Liquid \
            \ Boost pump: that call only needs *a* valid route to SSTOA to price a \
            \ small residual fee slice for burning, not the *optimal* one — but it \
            \ fires once per SmartSwap hop, so routing it through the same up-to-3x \
            \ alternate-route search real swap execution uses multiplies cost by \
            \ hop-count x 3 for no pricing benefit worth the gas. Do not use this for \
            \ any live user-facing quote/execution path — those must keep using \
            \ <URC_HopperActive> so users still get the best available route. \
            \ #65fL Phase 8a fix: this was the one Hopper variant left completely \
            \ untouched by #65bL Phases 1-7 — no PathCache check, no shared \
            \ raw-graph. Now checks SWPT|PathCache first (URC_ReadPathCacheFresh), \
            \ identically to URCx_Hopper's own Phase 1 pattern — on a fresh hit, \
            \ skips the live BFS entirely and uses the cached node-path as the \
            \ sole candidate, safe for the same reason Phase 1 established (the \
            \ real per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes against the <swpairs> active-only universe, \
            \ regardless of where the node-path came from). Especially valuable \
            \ here since this targets exactly the pair a bundle-assisted swap's \
            \ own <boost-path> already warms in this same cache (#65bL Phase 6) — \
            \ a self-searching swap running after one for the same input token \
            \ gets this for free. On a miss, falls through to the unchanged live \
            \ search."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (swpairs:[string] (ref-SWP::URC_ActiveSwpairs))
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                (nodes:[string]
                    (if (!= cached-nodes [BAR])
                        cached-nodes
                        (ref-SWPT::URC_ComputeGraphPath hopper-input-id hopper-output-id swpairs)
                    )
                )
            )
            (URCx_HopperForNodes nodes hopper-input-amount swpairs)
        )
    )
    (defun URC_ValidatePathActive:bool (nodes:[string] edges:[string])
        @doc "#34 Phase 7: active-required validation for the A->B execution route — \
            \ SWPT's exists-only structural check (real edges, correctly connected, \
            \ within the depth cap) PLUS every edge must be <can-swap>=true, since this \
            \ route is actually walked with real user funds, unlike the boost/stoa-value \
            \ pricing paths (SWPT::URC_ValidatePathStructure alone, exists-only, is \
            \ sufficient for those — see the P3.0 split in the exhaustive-path-search \
            \ HANDOFF doc)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (if (not (ref-SWPT::URC_ValidatePathStructure nodes edges))
                false
                (if (= (length edges) 0)
                    true
                    (let
                        (
                            (ref-SWP:module{SwapperV4} SWP)
                        )
                        (fold
                            (lambda (acc:bool e:string) (and acc (ref-SWP::UR_CanSwap e)))
                            true
                            edges
                        )
                    )
                )
            )
        )
    )
    (defun URCx_BestEdgeOf:string (ia:decimal i:string o:string edges:[string])
        @doc "Shared best-edge-selection core for <URC_BestEdge>/<URC_BestEdgeFiltered> \
            \ — identical in every respect except which <edges> candidate list is \
            \ passed in. Internal only, not on the interface."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (svl:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (URCv_Swap (at idx edges) (ref-U|SWP::UDC_DirectSwapInputData [i] [ia] o) false)
                            )
                        )
                        []
                        (enumerate 0 (- (length edges) 1))
                    )
                )
                ;;C1 fix: keep the index with the LARGER output (argmax), not smaller (argmin) — "best"
                ;;edge for a fixed input means most output, matching URC_Hopper's own documented intent.
                (sp:integer
                    (fold
                        (lambda
                            (acc:integer idx:integer)
                            (if (= idx 0)
                                acc
                                (if (> (at idx svl) (at acc svl))
                                    idx
                                    acc
                                )
                            )
                        )
                        0
                        (enumerate 0 (- (length svl) 1))
                    )
                )
            )
            (at sp edges)
        )
    )
    (defun URC_BestEdge:string (ia:decimal i:string o:string)
        @doc "Best edge across ALL swpairs connecting <i>/<o>, including disabled \
            \ ones — matches <URC_Hopper>'s full-universe scope. Live \
            \ swap-execution callers should use <URC_BestEdgeFiltered> instead."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_Edges i o))
        )
    )
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string])
        @doc "Best edge restricted to swpairs also present in <swpairs> — used by \
            \ <URCx_Hopper> so a disabled parallel pool between the same token \
            \ pair is never selected as the executed hop, even when an active \
            \ parallel pool exists between the same two tokens (#19H)."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_EdgesActive i o swpairs))
        )
    )
    ;;Value Computations
    (defun URC_SingleSSTOAWorthWSTOA:decimal ()
        @doc "#65fL Phase 8b: SSTOA's own worth in WSTOA terms, per unit — the ATS \
            \ autostake index (the 'liquid staking conversion, backwards'), zero \
            \ graph search. Extracted as its own function, mirroring \
            \ <URC_SingleOuroWorthWSTOA>, so <URCx_PrimordialValueAndOuroSupply> can \
            \ call it directly instead of going through <URC_SingleWorthWSTOA>/ \
            \ <URC_WorthWSTOA> — routing through those would create a genuine STATIC \
            \ recursive cycle at compile time (URC_WorthWSTOA's own id==OURO branch \
            \ calls into URCx_PrimordialValueAndOuroSupply), caught by Pact 5's own \
            \ cycle detector when this was first wired that way — even though the \
            \ actual runtime call chain (always SSTOA's own id here, which never \
            \ re-enters the OURO branch) would never truly recurse. <URC_WorthWSTOA>'s \
            \ own id==SSTOA branch also uses this now, instead of its own inline copy \
            \ of the same lookup."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (ats-pairs-with-sstoa-id:[string] (ref-DPTF::UR_RewardBearingToken sstoa))
                (stoaliquindex:string (at 0 ats-pairs-with-sstoa-id))
            )
            (ref-ATS::URC_Index stoaliquindex)
        )
    )
    (defun URCx_PrimordialValueAndOuroSupply:[decimal] ()
        @doc "#65fL Phase 8b: shared core extracted from <URC_OuroPrimordialPrice> — \
            \ [<primordial-wstoa-value> <ouro-supply>], where <primordial-wstoa-value> \
            \ is the primordial pool's total value in WSTOA-equivalent terms (native \
            \ WSTOA reserve plus the SSTOA reserve converted via its own cheap \
            \ index-based shortcut, URC_SingleSSTOAWorthWSTOA — zero graph search either \
            \ way). \
            \ #73C fix, scope note: originally shared by BOTH <URC_OuroPrimordialPrice> \
            \ (dollar-denominated) and <URC_SingleOuroWorthWSTOA> (WSTOA-denominated) — \
            \ the WSTOA-denominated side moved to a real 1-unit weighted-pool swap \
            \ instead (see <URC_SingleOuroWorthWSTOA>'s own doc for why: this helper's \
            \ ratio ignores the primordial pool's own weights, undervaluing OURO). \
            \ <URC_OuroPrimordialPrice> is the only remaining caller. Flagged, not \
            \ fixed here (out of scope — the WSTOA-denominated case is what surfaced \
            \ this): <URC_OuroPrimordialPrice>'s own final division likely has the \
            \ identical weight-omission issue, unverified, left for a follow-up. \
            \ Internal only, not on the public interface."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (primordial:string (ref-SWP::UR_PrimordialPool))
                (pts:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial))
                ;;
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (sstoa-supply:decimal (at 0 pts))
                (ouro-supply:decimal (at 1 pts))
                (wstoa-supply:decimal (at 2 pts))
                ;;
                (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                (sstoa-in-wstoa:decimal (URC_SingleSSTOAWorthWSTOA))
                (sstoa-in-wstoa-value (floor (* sstoa-supply sstoa-in-wstoa) sstoa-prec))
                (primordial-wstoa-value:decimal (+ wstoa-supply sstoa-in-wstoa-value))
            )
            [primordial-wstoa-value ouro-supply]
        )
    )
    (defun URC_OuroPrimordialPrice:decimal ()
        @doc "OURO's price in dollars. \
            \ #73C-TWIN FIX (2026-09-17): this used to compute its own flat reserve ratio -- \
            \ (primordial-wstoa-value * stoa-pid) / ouro-supply -- which READ NO WEIGHT and so \
            \ silently assumed the primordial pool was equal-weighted. It cannot be: \
            \ SWP|C>DEFINE-PRIMORDIAL-POOL enforces a WEIGHTED pool of exactly three tokens, and \
            \ genesis ships [SSTOA 0.3, OURO 0.5, WSTOA 0.2]. Measured before the fix, with \
            \ reserves held constant and weights varied through the live C_ModifyWeights path, \
            \ the old output was BIT-IDENTICAL across [0.4 0.4 0.2], [0.2 0.6 0.2] and genesis \
            \ [0.3 0.5 0.2] -- it did not move one digit across three weightings of the pool it \
            \ prices. Error at genesis weights: -38.65%, reproducing #73C's independently \
            \ measured ~38% on the WSTOA twin, which is the same bug this is the twin of. \
            \ It reached the OURO oracle write, DEMIPAD launchpad payments and the Explorer. \
            \ The fix DELEGATES rather than re-deriving: URC_TokenDollarPrice -> \
            \ URC_SingleWorthWSTOA -> URC_WorthWSTOA's OURO short-circuit -> \
            \ URC_SingleOuroWorthWSTOA, a real 1-unit weighted swap through UC_ComputeWP -- the \
            \ only math in the family that consumes (at \"weights\" drsi). That path is #73C's \
            \ own repair, already live and already proven, so this carries no new arithmetic. \
            \ See DEFECT-LEDGER 8.1."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
            )
            (URC_TokenDollarPrice (at "gas-source-id" ids) stoa-pid)
        )
    )
    (defun URC_SingleOuroWorthWSTOA:decimal (ouro:string wstoa:string)
        @doc "#73C fix: OURO's own worth in WSTOA, per unit — a real 1-unit swap \
            \ through the primordial pool's own weighted-pool math (URC_W-Swap, the \
            \ exact same UC_ComputeWP invariant a live swap would use), instead of the \
            \ old hand-rolled <primordial-wstoa-value / ouro-supply> ratio. The old \
            \ formula was mathematically wrong for THIS pool, not just approximate: it \
            \ implicitly assumed every token in the primordial pool carries equal \
            \ weight, but the pool is genuinely weighted (SSTOA 0.3 / OURO 0.5 / WSTOA \
            \ 0.2 at issuance) — a weighted pool's real exchange rate depends on \
            \ reserve/weight ratios, not a flat sum-of-other-reserves-over-own-reserve \
            \ ratio. Confirmed live: the old formula returned 91.95 WSTOA for 100 OURO \
            \ against real reserves [sstoa=3200.0 ouro=10002.0 wstoa=5997.009] and \
            \ weights [0.3 0.5 0.2], while the weighted spot formula \
            \ ((wstoa/wstoa_w)/(ouro/ouro_w)) gives ~149.9, matching the pre-existing \
            \ graph-search fallback's 147.31 (the small remainder being real, correctly \
            \ modeled AMM slippage from an actual ~1%-of-reserves trade — see \
            \ URC_WorthWSTOA's own doc for why THAT part is now handled at the caller, \
            \ not here). Still zero graph search: OURO and WSTOA are direct pool \
            \ siblings in the SAME primordial pool, this is one single-hop direct-pool \
            \ swap computation, not a BFS route search. <ouro>/<wstoa> passed in by the \
            \ caller (not self-fetched) — every real caller already holds them via \
            \ DALOS::UR_CanonicalStoaIds, so this adds no new read."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (primordial:string (ref-SWP::UR_PrimordialPool))
            )
            (URC_W-Swap primordial (ref-U|SWP::UDC_DirectSwapInputData [ouro] [1.0] wstoa))
        )
    )
    (defun URC_TokenDollarPrice (id:string stoa-pid:decimal)
        @doc "Retrieves Token Price in Dollars, via DIA Oracle that outputs STOA Price"
        ;;<stoa-pid> or <stoa-price-in-dollars> can be retrieved prior to the function call with:
        ;;(at "value" (n_bfb76eab37bf8c84359d6552a1d96a309e030b71.dia-oracle.get-value "STOA/USD"))
        ;;This function is structured like this, to allow price retrieval from any source.
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (id-in-stoa:decimal (URC_SingleWorthWSTOA id))
                (id-precision:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* id-in-stoa stoa-pid) id-precision)
        )
    )
    (defun URC_SingleWorthWSTOA (id:string)
        (URC_WorthWSTOA id 1.0)
    )
    (defun URC_WorthWSTOA (id:string amount:decimal)
        @doc "#65fL Phase 8b fix: added an id==OURO short-circuit (URC_SingleOuroWorthWSTOA, \
            \ straight off the primordial pool's own reserves), zero graph search — same \
            \ shape as the pre-existing id==SSTOA short-circuit below. WSTOA/SSTOA/OURO are the \
            \ only tokens with a canonical zero-search pricing mechanism; every other id \
            \ still falls through to the graph-search branch. The OURO shortcut only fires \
            \ when a primordial pool has actually been defined (SWP::UR_PrimordialPool != \
            \ BAR, checked via a short-circuited `and` so this extra read only happens for \
            \ id==OURO, never for any other id) — SAFETY, not a guess: caught live, a real \
            \ pre-bootstrap crash reading an unset primordial pool during that very pool's \
            \ OWN issuance (UEV_Issue's spawn-limit check prices the first token before any \
            \ primordial pool could exist yet). Falls through to the exact original \
            \ graph-search behavior when unsafe — matches pre-Phase-8b behavior byte for \
            \ byte in that edge case, not a new approximation. Fetches WSTOA/SSTOA/OURO via \
            \ DALOS::UR_CanonicalStoaIds — ONE read for all 3, instead of 3 independent \
            \ reads of the same DALOS row — caught live: adding a naive 3rd standalone \
            \ UR_OuroborosID call regressed the P0.5/P2-scale worst-case checkpoints \
            \ (measured +928 gas) despite neither pool ever pricing OURO/SSTOA in that \
            \ scenario, isolated via git-stash bisection before this fix, not guessed. \
            \ #73C fix: the graph-search fallback below now prices ONE unit and scales \
            \ linearly, instead of simulating a swap of the full <amount> — see the \
            \ fallback branch's own comment for why (depth-skew: 'worth of N tokens' is \
            \ not N times 'worth of 1 token' once a simulated swap eats meaningfully into \
            \ pool depth, and URC_PoolValue's own caller passes an ENTIRE pool reserve as \
            \ <amount>, not a small swap-sized figure)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit via the real route (URC_Hopper amount=1.0,
                        ;;not <amount>), then scale linearly — never simulate a swap of the
                        ;;full requested <amount>, since a real swap of a large amount eats
                        ;;into pool depth (AMM slippage), so "worth of N" would come out
                        ;;systematically LESS than N times "worth of 1," most severely
                        ;;exactly where this function is actually called from
                        ;;(URC_PoolValue prices a pool's ENTIRE first-token reserve this
                        ;;way). "1 unit" is an accepted, unavoidable approximation of the
                        ;;true marginal/instantaneous spot price (an exact closed-form
                        ;;derivative isn't implemented anywhere in this codebase and isn't
                        ;;worth building for this) — computing at a smaller-than-1 amount
                        ;;isn't meaningful once atomic-unit precision is reached.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_Hopper id wstoa 1.0))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-FETCHED <raw-graph> (<URC_HopperFromRaw>) instead of a \
            \ fresh self-fetch — see <URCx_HopperFromRaw>'s own doc for the full \
            \ rationale (repricing-loop sharing). The WSTOA/SSTOA short-circuit branches \
            \ never needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromRaw id wstoa 1.0 raw-graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-BUILT <graph> (<URC_HopperFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call — see \
            \ <URCx_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing). The WSTOA/SSTOA short-circuit branches never \
            \ needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromGraph id wstoa 1.0 graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_PoolValue:[decimal] (swpair:string)
        @doc "Outputs the Pool Value in WSTOA. \
            \ If the Pool is empty, even though its value is technically zero, \
            \ The Value of the Genesis Initiation is outputed \
            \ PoolValue includes two decimal values: \
            \ 1st Value: Total Value of the Pool in WSTOA \
            \ 2nd Value: Value of 1 LP Token in WSTOA"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOA first-token first-token-supply))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-FETCHED <raw-graph> (<URC_WorthWSTOAFromRaw>) instead of a \
            \ fresh self-fetch. Built for the STOA-repricing loop \
            \ (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage, one URC_PoolValue call per \
            \ distinct pool a self-searching swap touched) — every call in that loop \
            \ now shares ONE raw-graph fetch instead of each one independently \
            \ re-reading and rebuilding the whole graph, same shape of win Phase 2 \
            \ already proved for a single Hopper call's own best-of-3 attempts, \
            \ extended here across the WHOLE loop's separate calls. Everything else \
            \ (genesis-vs-live supply/weight selection, pool-worth/lp-worth formulas) \
            \ is byte-for-byte identical to <URC_PoolValue> — only the one \
            \ <first-worth> line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromRaw first-token first-token-supply raw-graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-BUILT <graph> (<URC_WorthWSTOAFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call. Built for the STOA-repricing \
            \ loop (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage) — every call in that \
            \ loop already shared ONE raw-graph fetch (Phase 4); this shares the \
            \ downstream graph-BUILD too (SWPT::UC_MakeGraphFromRaw, a linear scan \
            \ per node in the whole topology, previously rebuilt identically on \
            \ every one of the loop's N distinct-first-token queries despite always \
            \ producing byte-identical output for the same <raw-graph>/<swpairs> \
            \ universe). Everything else (genesis-vs-live supply/weight selection, \
            \ pool-worth/lp-worth formulas) is byte-for-byte identical to \
            \ <URC_PoolValue>/<URC_PoolValueFromRaw> — only the one <first-worth> \
            \ line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromGraph first-token first-token-supply graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount list equal to the <swpair> token number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (pt:string (at idx pool-tokens))
                            (spt:[integer] (ref-U|LST::UC_Search ids pt))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length pool-tokens) 1))
            )
        )
    )
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount equal to the <X> positions number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (spt:[integer] (ref-U|LST::UC_Search positions idx))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal])
        @doc "From a complete list of input amounts, also containing zeroes, \
            \ creates a list of Pool Token IDs for the amounts greater than zero."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (zero-positions:[integer] (ref-U|LST::UC_Search input-amounts 0.0))
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (let
                        (
                            (iz-index-zero:bool (contains idx zero-positions))
                        )
                        (if (not iz-index-zero)
                            (ref-U|LST::UC_AppL
                                acc
                                (at idx pool-tokens)
                            )
                            acc
                        )
                    )
                )
                []
                (enumerate 0 (- (length input-amounts) 1))
            )
        )
    )
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA leg of a SINGLE-TX swap-pair issue. Read-only twin of the <stoa-costs> that \
            \ C_Issue hands to XE_CollectStoa, so the exec and its INFO_ previews are sourced from \
            \ one place and cannot drift. \
            \ NOTE this is deliberately NOT the same figure as the DEFPACT pool-issue path: \
            \ MTX-SWP charges (+ UsagePrice \"dptf\" \"swp\") while this charges \
            \ UC_StoaPrice \"issue-swp-pair\". The two paths really do cost different amounts, and \
            \ all six INFO_SWP|Issue* previews used to quote the MTX figure for both -- over-quoting \
            \ the single-tx path. Mirrors ATS::URCi_IssueStoa. \
            \ Pinned by `Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl <<SWP-ISSUE-INFO>>`."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UC_StoaPrice "issue-swp-pair")
        )
    )
    (defun URC_IssuePoolIgnis:decimal ()
        @doc "The ONE-leg IGNIS total the MULTI-STEP (defpact) pool issuance bills in \
            \ MTX-SWP::MTX|C_Issue step 2. Lives here, beside URCi_Issue, so the preview and the \
            \ exec read the SAME number from the SAME place: MTX-SWP deploys after SWPI, so the \
            \ exec can call down to this, and INFO_SWP|Issue*Pool previews through URCi_IssuePool. \
            \ ADDED 2026-09-14 with the GS-04 repair -- see URCi_IssuePool."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (fold (+) 0.0
                [
                    (ref-IGNIS::UC_IgnisDeter "issue-swp-pair")
                    (ref-IGNIS::UC_IgnisLeg "tier-token-issue")
                    (ref-IGNIS::UC_IgnisLeg "tier-biggest")
                    (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                ]
            )
        )
    )
    (defun URCi_IssuePool:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the MULTI-STEP pool issuance -- MTX-SWP::MTX|C_Issue -- as opposed \
            \ to URCi_Issue below, which previews the SINGLE-TX SWPI::C_Issue. TWO legs, matching \
            \ that step's concat exactly: the folded one-leg total (URC_IssuePoolIgnis) and the \
            \ account->SWP pool-token multi-transfer. \
            \ GS-04 (2026-09-14): the three INFO_SWP|Issue*Pool previews used to route through \
            \ URCi_Issue, which is tuned to the single-tx exec -- FOUR non-transfer legs totalling \
            \ 6158 against the defpact's ONE leg of 5506, an over-quote of 652. The leg COUNT \
            \ mattered independently: UDC_PrimeIgnisCumulator discounts and quarter-splits PER LEG, \
            \ so even equal totals could round apart. The tell was a dead `op-key` parameter, still \
            \ in URCi_Issue's signature and used nowhere in its body -- one reader serving two \
            \ executions that bill differently, the same shape as the red team's RT-A-001. \
            \ Measured, not reasoned about, at modules/DEFPACT-BILLING.repl <<DPB-02>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URC_IssuePoolIgnis) SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                    (ref-TFT::URCi_MultiTransferCumulator
                        pool-token-ids account SWP|SC_NAME pool-token-amounts
                    )
                ]
                []
            )
        )
    )
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the SINGLE-TX C_Issue's IGNIS cumulator (the STOA dptf+swp usage prices are \
            \ billed separately). Five legs, matching C_Issue's concat: \
            \ ico1 = LP-token issue gas (URCi_IssueGas 1 on SWP); \
            \ ico2 = the account->SWP pool-token multi-transfer (EXISTING tokens, real reader); \
            \ ico3 = the genesis LP mint (origin -> biggest on SWP); \
            \ ico4 = the SWP->account LP transfer-out (fresh LP is fee-toggle-off => class-1 \
            \        Simple => smallest); \
            \ ico5 = the flat swp-issue gas. \
            \ ico3/ico4 are reconstructed from XE_IssueLP's FIXED LP invariants (issued via \
            \ XB_IssueFree with fee-toggle off, so a fresh LP always transfers as class 1) rather \
            \ than calling URCi_Mint/URCi_Transfer, because the LP id is a block-hash write product \
            \ that does not exist at preview time. Every trigger reduces to the GLOBAL \
            \ URC_IsVirtualGasZero: URC_IsVirtualGasZeroAbsolutely on a non-gas id is global, \
            \ SWP is not in GAS_EXCEPTION, and <account> is a normal (non-exempt) account. \
            \ Output ([swpair token-lp]) is empty here (write products)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (swp-sc:string SWP|SC_NAME)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-DPTF::URCi_IssueGas 1) swp-sc trigger [])
                    (ref-TFT::URCi_MultiTransferCumulator pool-token-ids account swp-sc pool-token-amounts)
                    ;;ico3 — the genesis LP mint. The LP id is a block-hash write product that does
                    ;;not exist at preview time, so we cannot call URCi_Mint on it; we charge the
                    ;;SAME PRICE it would return. This MUST track DPTF|C_Mint: it was a hardcoded
                    ;;"tier-biggest" (5) and silently desynced when C_Mint was re-priced to its real
                    ;;computation (87), leaving the preview 82 BELOW what the exec charges.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "DPTF|C_Mint" "usage") swp-sc trigger [])
                    ;;ico4 — the SWP->account LP transfer-out. A fresh LP is fee-toggle-off, so it
                    ;;always transfers as class-1 Simple = smallest.
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisLeg "tier-smallest") swp-sc trigger [])
                    ;;ico5 — MUST equal what C_Issue bills, which is the DETERRENCE ALONE. Using
                    ;;UC_IgnisPrice here added the op's 35-point component cost to the preview only,
                    ;;overstating it by 35. A preview's job is to equal the exec, not to be the
                    ;;price we think the exec ought to charge.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisDeter "issue-swp-pair") swp-sc trigger [])
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_SwapData 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (l1:integer (length input-ids))
                (l2:integer (length input-amounts))
                (l3:integer (length pool-tokens))
                (lengths:[integer] [l1 l2])
                (iz-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
                (t1:bool (contains output-id input-ids))
                (t2:bool (contains output-id pool-tokens))
            )
            (ref-U|INT::UEV_UniformList lengths)
            (enforce iz-on-pool "Input Tokens are not part of the pool")
            (enforce (not t1) "Output-ID cannot be within the Input-IDs")
            (enforce t2 "OutputID is not part of Swpair Tokens")
            (enforce (and (>= l2 1) (< l2 l3)) "Incorrect amount of swap Tokens")
        )
    )
    (defun UEV_InverseSwapData 
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (t1:bool (contains input-id pool-tokens))
                (t2:bool (contains output-id pool-tokens))
            )
            (enforce (and t1 t2) "Invalid Pool Tokens")
            (ref-DPTF::UEV_Amount output-id output-amount)
        )
    )
    (defun UEV_Issue
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#74 note (2026-08-29): deliberately does NOT enforce that <pool-tokens>' \
            \ token IDs are distinct — that protection already exists, composed for \
            \ free, one layer down. Both real issuance paths (this function, via \
            \ XI_IssueWrite's SWPI|C>ISSUE, and MTX-SWP's defpact issuance) collect the \
            \ caller's genesis deposits through the SAME shared XE_IssueWrite chokepoint \
            \ (Fix #22/M5), which calls TFT::C_MultiTransfer — and C_MultiTransfer's own \
            \ U|LST::UC_IzUnique check already rejects a repeated token ID in the \
            \ transfer list ('Unique Items Required, duplicate item found: <id>'), for \
            \ its own unrelated reason (a batched multi-transfer can't sensibly resolve \
            \ two different amounts for the same ID). Confirmed live, not assumed: \
            \ issuing [OURO, OURO, W1] as a nominal 3-token pool reverts cleanly \
            \ (whole-tx atomicity, no partial/orphaned pool state) at \
            \ TFT|C>MULTI-TRANSFER, before this function's own writes ever run. \
            \ Duplicating that check HERE would be pure redundant gas cost for a \
            \ property a composed dependency already guarantees on every real call \
            \ path — the same 'no single non-tier choke point exists, OR one already \
            \ does and it's downstream' reasoning StoicSyntax's `v`-specialization rule \
            \ asks for before adding an intrinsic bounds guard (§6.1) applies in \
            \ reverse here: the choke point already exists, just not in this module."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
                (principals:[string] (ref-SWP::UR_Principals))
                (l1:integer (length pool-tokens))
                (l2:integer (length weights))
                (ws:decimal (fold (+) 0.0 weights))
                (pt-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (ptte:[string]
                    (if (= amp -1.0)
                        (drop 1 pt-ids)
                        pt-ids
                    )
                )
                (first-pool-token:string (at 0 pt-ids))
                (iz-principal:bool (contains first-pool-token principals))
                (contains-principals:bool
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (or
                                acc
                                (contains (at idx pt-ids) principals)
                            )
                        )
                        false
                        (enumerate 0 (- (length pt-ids) 1))
                    )
                )
            )
            ;;Functions
            (ref-SWP::UEV_PoolFee fee-lp)
            (ref-SWP::UEV_New pt-ids weights amp)
            ;;Mappings
            (map
                (lambda
                    (id:string)
                    (ref-DPTF::CAP_Owner id)
                )
                ptte
            )
            ;;#11C fix: real per-weight enforce — the original computed this exact precision check via
            ;;`=` and discarded the result (same dead-map pattern independently flagged as H5/#23H;
            ;;fixing this map in place closes both, since it's the one place the check lives). Combines
            ;;the precision check with a >=0.1 floor per weight — rules out the 0.0-weight div-by-zero
            ;;this finding is about, matching the floor already enforced for post-issuance reweights
            ;;(SWP|S>WEIGHTS, C7/#8C fix) so issuance and modification agree on the same bound.
            (map
                (lambda
                    (w:decimal)
                    (enforce
                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
                    )
                )
                weights
            )

            ;;Enforcements
            (enforce (!= principals [BAR]) "Principals must be defined before a Swap Pair can be issued")
            (enforce (or (= amp -1.0) (>= amp 1.0)) "Invalid amp value")
            (enforce (and (>= l1 2) (<= l1 7)) "2 - 7 Tokens can be used to create a Swap Pair")
            (enforce (= l1 l2) "Number of weigths does not concide with the pool-tokens Number")
            (enforce-one
                "Invalid Weight Values"
                [
                    (enforce (= ws 1.0) "Weights must add to exactly 1.0")
                    (enforce (= ws (dec l1)) "Weights must all be 1.0")
                ]
            )
            ;;Ifs
            ;;On a W or P pool, first Pool Token must be a Principal Token
            (if (= amp -1.0)
                (enforce iz-principal "1st Token is not a Principal")
                true
            )
            ;;#34bM fix: was checking multi-hop BFS connectivity to SSTOA specifically
            ;;(SWPT::URC_Hopper, unbounded hop count, one hardcoded target token) —
            ;;owner's actual design: if a Stable Pool's first Token isn't itself a
            ;;Principal, it must be DIRECTLY pooled (one hop, an existing pool) with
            ;;ANY current Principal — not transitively connected through a chain of
            ;;non-Principal tokens, and not specifically SSTOA. Fixed to check the
            ;;first Token's direct neighbours (SWPT::URC_TokenNeighbours, one hop,
            ;;every existing pool regardless of type) against the full current
            ;;<principals> list.
            (if (and (> amp 0.0) (not contains-principals))
                (let
                    (
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                        (neighbours:[string] (ref-SWPT::URC_TokenNeighbours first-pool-token))
                        (has-principal-neighbour:bool
                            (> (length (filter (lambda (n:string) (contains n principals)) neighbours)) 0)
                        )
                    )
                    (enforce
                        has-principal-neighbour
                        (format "{} is not directly pooled with any Principal token" [first-pool-token])
                    )
                )
                true
            )
            ;;If pool is not a principal pool, its initial liquidity must be worth at least <spawn-limit>
            (if (not p)
                (let
                    (
                        (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                        (pt-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                        (first-pool-token-amount:decimal (at 0 pt-amounts))
                        (prefix:string (ref-U|SWP::UC_Prefix weights amp))
                        (how-many:integer (length pool-tokens))
                        ;;
                        (first-worth:decimal (URC_WorthWSTOA first-pool-token first-pool-token-amount))
                        (pool-worth-with-input-tokens-in-wstoa:decimal
                            (if (or (= prefix "S") (= prefix "P"))
                                (* (dec how-many) first-worth)
                                (/ first-worth (at 0 weights))
                            )
                        )
                        (spawn-limit:decimal (ref-SWP::UR_SpawnLimit))
                    )
                    (enforce (>= pool-worth-with-input-tokens-in-wstoa spawn-limit) "More liquidity is needed to open a new pool!")
                )
                true
            )
            (format "Validation prior to pool creation executed succesfully {}" ["!"])
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWPI|XE>ISSUE-WRITE
    (defun XE_IssueWrite:list
        (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#36M/M5 fix: forward-module entrypoint holding the ONE shared pool-issuance \
            \ write sequence — mint the LP token, register the pool, transfer pool tokens \
            \ in, mint genesis LP supply, transfer LP out to the account, register the \
            \ swap-tracer graph edge. Both SWPI::C_Issue (this module) and \
            \ MTX-SWP::MTX|C_Issue's Step 3 (a different module, reached via a \
            \ module{SwapperIssueV4} ref) call this instead of each independently \
            \ reimplementing it. \
            \ Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out] — \
            \ a wider list, not an IgnisCollectorV3.OutputCumulator (this codebase's XE_* \
            \ convention: the forward module's own C_ composes IGNIS, not this function). \
            \ C_Issue aggregates all four sub-cumulators into its own single billed \
            \ response; MTX|C_Issue's Step 3 only needs swpair/token-lp (it already billed \
            \ separately, in its own Step 2, before Step 3 ever runs) and ignores the rest."
        (P|UEV_IMC)
        (with-capability (SWPI|XE>ISSUE-WRITE account pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;#21H: SWPT no longer needs a principal list.
                    (ref-SWPT:module{SwapTracerV3} SWPT)
                    (ref-SWP:module{SwapperV4} SWP)
                    (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                    (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                    (lp-name-ticker:[string] (ref-SWP::URC_LpComposer pool-tokens weights amp))
                    (ico-lp:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::XE_IssueLP (at 0 lp-name-ticker) (at 1 lp-name-ticker))
                    )
                    (token-lp:string (at 0 (at "output" ico-lp)))
                    (swpair:string (ref-SWP::XE_Issue account pool-tokens token-lp fee-lp weights amp p))
                )
                (ref-BRD::XE_Issue swpair)
                (let
                    (
                        (ico-transfer-in:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_MultiTransfer patron account SWP|SC_NAME pool-token-ids pool-token-amounts true)
                        )
                        (ico-mint:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Mint patron SWP|SC_NAME token-lp GENESIS_LP_SUPPLY true)
                        )
                        (ico-transfer-out:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron SWP|SC_NAME account token-lp GENESIS_LP_SUPPLY true)
                        )
                    )
                    ;;C9 fix (preserved): SWP|LP registration lives inside SWP::XE_Issue
                    ;;itself (called above via <swpair>'s own binding) — not a standalone
                    ;;call either caller needs to remember separately.
                    (ref-SWPT::XE_UpdateGraph swpair)
                    [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RebuildGraph ()
        @doc "One-time migration/backfill utility (#21H). Rebuilds SWPT's adjacency \
            \ graph (SwapTracerV3) from every currently-existing swpair \
            \ (SWP::URC_Swpairs()), by calling SWPT::XE_UpdateGraph exactly as normal \
            \ issuance already does — just once per EXISTING pool instead of once for \
            \ a newly-issued one. Lives here rather than in SWPT itself because SWPT \
            \ deploys before SWP in this codebase's deploy order and can't hold a \
            \ compile-time reference to SwapperV4; SWPI already deploys after both and \
            \ is already a legitimate XE_UpdateGraph caller (C_Issue uses the same \
            \ call). XE_UpdateGraph's own writes are idempotent (XI_UpdatePair only \
            \ appends a swpair if not already present), so this is safe to re-run — \
            \ pools issued after this upgrade (which already populate the graph \
            \ directly at issuance) are a no-op here. Intended to be run exactly once \
            \ by an admin immediately after deploying the #21H architecture change, to \
            \ backfill every pool that was issued under the old, now-removed \
            \ principal-keyed SWPT|Tracer storage."
        (with-capability (GOV|SWPI_ADMIN)
            ;;XE_UpdateGraph's own P|UEV_IMC checks that P|SWPI|CALLER (the guard SWPI
            ;;registers with SWPT via P|A_Define) is actively composed — true when
            ;;reached via C_Issue's cap chain (SWPI|C>ISSUE -> P|DT), not true by
            ;;default just because this code happens to live in SWPI's module.
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-SWP:module{SwapperV4} SWP)
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                    )
                    (map (lambda (sp:string) (ref-SWPT::XE_UpdateGraph sp)) (ref-SWP::URC_Swpairs))
                )
            )
        )
    )
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Issues a new SWPair (Liquidty Pool). \
            \ #36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in \
            \ the shared XE_IssueWrite — MTX-SWP::MTX|C_Issue's own Step 3 calls the same \
            \ function instead of independently reimplementing it. This function still \
            \ owns all of ITS OWN IGNIS billing/aggregation (MTX|C_Issue bills separately, \
            \ in its own Step 2, before Step 3 ever runs)."
        (P|UEV_IMC)
        (with-capability (SWPI|C>ISSUE executor pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;STOA leg of a swap-pair issue: the SAME DOLLAR VALUE as its IGNIS deter
                    ;;($50 => 500 STOA at the $0.10 peg), via UC_StoaPrice. Replaces the two
                    ;;legacy sub-cent UsagePrice legs ("dptf" + "swp").
                    (stoa-costs:decimal (ref-IGNIS::UC_StoaPrice "issue-swp-pair"))
                    (gas-swp-cost:decimal (ref-IGNIS::UC_IgnisDeter "issue-swp-pair"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (write-result:list (XE_IssueWrite patron executor pool-tokens fee-lp weights amp p))
                    (swpair:string (at 0 write-result))
                    (token-lp:string (at 1 write-result))
                    (ico1:object{IgnisCollectorV3.OutputCumulator} (at 2 write-result))
                    (ico2:object{IgnisCollectorV3.OutputCumulator} (at 3 write-result))
                    (ico3:object{IgnisCollectorV3.OutputCumulator} (at 4 write-result))
                    (ico4:object{IgnisCollectorV3.OutputCumulator} (at 5 write-result))
                    (ico5:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator gas-swp-cost SWP|SC_NAME trigger [])
                    )
                )
                (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [swpair token-lp])
            )
        )
    )

)

;; --- tables for 16_SWPI.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SwapperLiquidityV2
    @doc "Exposes Liquidity Functions;"

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema OutputLP
        primary:decimal
        secondary:decimal
    )
    (defschema LiquiditySplit
        balanced:[decimal]
        asymmetric:[decimal]
    )
    (defschema LiquiditySplitType
        iz-balanced:bool
        iz-asymmetric:bool
    )
    (defschema LiquidityData
        sorted-lq:object{LiquiditySplit}
        sorted-lq-type:object{LiquiditySplitType}
        balanced:decimal
        asymmetric:decimal
        asymmetric-fee:decimal
    )
    (defschema LiquidityComputationData
        li:integer
        pool-type:string
        lp-prec:integer
        current-lp-supply:decimal
        lp-supply:decimal
        pool-token-supplies:[decimal]
    )
    (defschema AsymmetricTax
        tad:decimal                     ;;The value of Token A Deficit
        tad-diff:decimal                ;;Difference between <tad> and Fee Shares
        fuel:decimal                    ;;Token A amount as Fuel
        special:decimal                 ;;Token A amount for Special Targets
        boost:decimal                   ;;Token A amount for Boost
        fuel-to-lp:decimal              ;;Token A amount for Fuel converted to LP amounts
    )
    (defschema CompleteLiquidityAdditionData
        total-input-liquidity:[decimal]
        balanced-liquidity:[decimal]
        asymmetric-liquidity:[decimal]
        asymmetric-deviation:[decimal]
        ;;
        primary-lp:decimal
        secondary-lp:decimal
        ;;
        total-ignis-tax-needed:decimal
        ;;
        gaseous-ignis-fee:decimal
        deficit-ignis-tax:decimal
        special-ignis-tax:decimal
        lqboost-ignis-tax:decimal
        relinquish-lp:decimal
        ;;
        gaseous-text:string
        deficit-text:string
        special-text:string
        lqboost-text:string
        fueling-text:string
        ;;
        clad-op:object{CladOperation}
    )
    (defschema CladOperation
        perfect-ignis-fee:object{IgnisCollectorV3.OutputCumulator}   
                                    ;;Ignis Cumulator for the Operation
                                    ;;Can be used to Collect Fees in Advance
        mt-ids:[string]             ;;IDs the User Moves to swp-sc
        mt-amt:[decimal]            ;;Their Amounts
        lp-mint:bool                ;;True Mints only Primary, false mints both
        bk-ids:[string]             ;;IDs of the special Targets, in case none then BAR
        bk-amt:[decimal]            ;;Amounts for the BulkT, in case none, then 0.0
        ;;
        ppb:[decimal]               ;;Pool Amounts plus balanced-liq
        ppa:[decimal]               ;;Pool Amounts plus all input-lq

    )
    (defschema PoolState
        A:decimal
        F:object{UtilitySwpV2.SwapFeez}
        X:[decimal]
        W:[decimal]
        ;;
        LP:decimal
        FT:[string]
        FTP:[decimal]
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
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_VirtualSwapEngineSwpair:object{UtilitySwpV2.VirtualSwapEngine} (account:string account-liq:[decimal] swpair:string pool-liq:[decimal]))
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV2.VirtualSwapEngine}
        (
            account:string account-liq:[decimal] swpair:string starting-liq:[decimal]
            A:decimal W:[decimal] F:object{UtilitySwpV2.SwapFeez}
        )
    )
    (defun UDC_PoolFees:object{UtilitySwpV2.SwapFeez} (swpair:string))
        ;;
    (defun UDC_OutputLP:object{OutputLP} (a:decimal b:decimal))
    (defun UDC_LiquiditySplit:object{LiquiditySplit} (a:[decimal] b:[decimal]))
    (defun UDC_LiquiditySplitType:object{LiquiditySplitType} (a:bool b:bool))
    (defun UDC_LiquidityData:object{LiquidityData} (a:object{LiquiditySplit} b:object{LiquiditySplitType} c:decimal d:decimal e:decimal))
    (defun UDC_LiquidityComputationData:object{LiquidityComputationData} (a:integer b:string c:integer d:decimal e:decimal f:[decimal]))
    (defun UDC_AsymmetricTax:object{AsymmetricTax} (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal))
    (defun UDC_CompleteLiquidityAdditionData:object{CompleteLiquidityAdditionData}
        (
            a:[decimal] b:[decimal] c:[decimal] d:[decimal]
            e:decimal f:decimal
            g:decimal
            h:decimal i:decimal j:decimal k:decimal l:decimal
            m:string n:string o:string p:string q:string
            r:object{CladOperation}
        )
    )
    (defun UDC_CladOperation:object{CladOperation} (a:object{IgnisCollectorV3.OutputCumulator} b:[string] c:[decimal] d:bool e:[string] f:[decimal] g:[decimal] h:[decimal]))
    (defun UDC_PoolState:object{PoolState} (a:decimal b:object{UtilitySwpV2.SwapFeez} c:[decimal] d:[decimal] e:decimal f:[string] g:[decimal]))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC_DetermineLiquidity:object{LiquiditySplitType} (input-lqs:object{LiquiditySplit}))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_STOA-PID|LpToIgnis:decimal (swpair:string amount:decimal stoa-pid:decimal))
    (defun URC_STOA-PID|TokenToIgnis (id:string amount:decimal stoa-pid:decimal))
    (defun URC_STOA-PID|CLAD:object{CompleteLiquidityAdditionData}
        (
            account:string swpair:string ld:object{LiquidityData} 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
    )
    (defun URC_TokenPrecision (id:string))
    (defun URC_IgnisPrecision ())
        ;;
    (defun URC_LD:object{LiquidityData} (swpair:string input-amounts:[decimal]))
    (defun URC_AsymmetricTax:object{AsymmetricTax} (account:string swpair:string ld:object{LiquidityData}))
    (defun URC_SortLiquidity:object{LiquiditySplit} (swpair:string input-amounts:[decimal]))
        ;;
    ;;#56L fix: renamed to URCv_AreAmountsBalanced (StoicSyntax v1.11.0 'validating'
    ;;specialization) — see the defun's own @doc for the full rationale.
    (defun URCv_AreAmountsBalanced:bool (swpair:string input-amounts:[decimal]))
    (defun URC_BalancedLiquidity:[decimal] (swpair:string input-id:string input-amount:decimal with-validation:bool))
    (defun URC_LpBreakAmounts:[decimal] (swpair:string input-lp-amount:decimal))
    (defun URCv_CustomLpBreakAmounts:[decimal] (swpair:string swpair-pool-token-supplies:[decimal] swpair-lp-supply:decimal input-lp-amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_Liquidity:[decimal] (swpair:string ld:object{LiquidityData}))
    (defun UEV_BalancedLiquidity (swpair:string input-id:string input-amount:decimal))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XE_STOA-PID|AddLiquidity (patron:string account:string swpair:string asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal ld:object{LiquidityData} clad:object{CompleteLiquidityAdditionData}))
    (defun XE_AutonomousSwapManagement (swpair:string))
    ;;{5.7}  User [A/C]

)
;;
(module SWPL GOV
    @doc "Exposes Liquidity Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperLiquidityV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPL                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPL_ADMIN)))
    (defcap GOV|SWPL_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_SWPL)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "SWPL Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G5}  functions
    ;;
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPL|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPL|CALLER))
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
        (with-capability (GOV|SWPL_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPL_ADMIN)
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
        (with-capability (GOV|SWPL_ADMIN)
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
        (with-capability (GOV|SWPL_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|SWPL|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
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
    (defcap SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX (text:string)
        @doc "ASYMMETRIC-LQ-GASEOUS-TAX \
            \   PURPOSE     Compensates for the LP token deficit arising from asymmetric liquidity additions, \
            \               as determined by the Curve liquidity formula, which calculates excess LP tokens \
            \               compared to a balanced addition. Unlike the Curve approach, which restricts LP minting, \
            \               this tax permits minting but imposes a gas fee in Ignis to offset the deficit. \
            \   CALCULATION The tax is the Ignis equivalent of the LP token deficit (e.g., X LP units), \
            \               computed using the Curve formula based on V-POOL reserves. \
            \               where the V-Pool reserves are: [Pool-Reserves + Balanced Liq Part] from Input Liquidty) \
            \               The LP value is converted to Ignis \
            \   APPLICATION Collected as gas during the liquidity addition transaction, \
            \               subject to Elite Account Gas Discounts (e.g., reduced by Z%). \
            \               This tax maintains pool balance by charging users for excess LP tokens minted"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX (text:string)
        @doc "ASYMMETRIC-LQ-DEFICIT-TAX \
        \   PURPOSE     The Asymmetric Liquidity Deficit Tax mitigates pool imbalance and LP token dilution \
        \               from asymmetric liquidity additions. It targets the difference between \
        \               the deficit (Token A cost to achieve the Asymmetric Break Amounts, ABA) \
        \               and fees (Boost, Fuel, Special), which are computed via virtual swaps. \
        \ \
        \   DEFICIT and ABA Derivationa \
        \               The deficit is the Token A cost to balance an asymmetric input \
        \               (e.g., [0 A, X B, Y C, Z D]) using the Virtual Swap Engine (VSE) \
        \               on the Virtual Pool (V-POOL) (original reserves + balanced liquidity). \
        \               The ABA ([A_aba, B_aba, C_aba, D_aba]) is obtained by calculating \
        \               full LP tokens for the asymmetric addition on V-POOL and removing them, preserving pool ratios. \
        \       VIRTUAL SWAPS \
        \           DIRECT SWAPS \
        \               Convert non-A tokens (e.g., X B → W A) to Token A, with fees (save Fee Values) \
        \              (which are subject to Elite Account Discoutn). No swap if only A is input \
        \           REVERSE|FORWARD SWAPS (For (n-1) non-A ABA tokens (n = pool tokens)) \
        \               Compute A needed for B_aba via reverse swap with fees \
        \               Perform forward swap (Computed A → B_aba, save Fee Values) \
        \               Repeat for C, D, etc \
        \           DEFICIT \
        \               The absolute value of the negative A amount accrued in the virtual swap account \
        \               after all the Forward Virtual Swaps is the TOTAL Deficit \
        \               This value incorporates all the Fees generated by the forward virtual swaps. \
        \               Difference Deficit = Total Deficit minus value of Fees. \
        \       REASONING \
        \               Virtual swaps measure the cost of achieving ABA, using V-POOL for stable ratios \
        \               and incorporating fees to assess damage. \
        \   TAX CALCULATION \
        \       FIXED       50% of the Difference Deficit, flat fee \
        \       VARIABLE    Imbalance cause by asymmetric liquidity (share deviation e.g., W%) \
        \                   capped at 40% Maximum Pool Deviation (which is (n-1)/n given n number of Pool Tokens) \
        \       TOTAL       FIXED + VARIABLE \
        \ \
        \   APPLICATION Collectes as IGNIS to the SWP|SC_NAME Smart Ouronet Account \
        \   SUMMARY     The Deficit Tax, based on Virtual Swaps Computation on V-POOL Data, \
        \               addresses residual damage. ABA is derived by removing LP tokens, \
        \               with deficit accrued from the forward swaps. \
        \               The tax (50% flat + deviation, capped at 40%) ensures fairness and scalability"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-FUELING-TAX (text:string)
        @doc "ASYMMETRIC-LQ-FUELING-TAX \
        \   PURPOSE     Enhances LP token value during asymmetric liquidity additions \
        \               by reducing the number of LP tokens minted, counteracting dilution. \
        \               It is based on the Fuel fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Fuel fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value, then to an LP Token Value. \
        \       REASONING \
        \               The Fuel fee, derived from virtual swaps, represents the cost of processing asymmetric inputs. \
        \               Reducing LP minting by this amount preserves LP value, mimicking traditional fueling mechanisms. \
        \ \
        \   APPLICATION Applied by reducing the amount of LP Tokens minted by the calculated amount \
        \   SUMMARY     The Fueling Tax, based on the Fuel fee from VSE swaps on the V-POOL, \
        \               mitigates LP dilution by reducing minted LP tokens (e.g., V LP). \
        \               It leverages the swap process outlined in the Deficit Tax documentation, \
        \               ensuring efficiency and fairness in asymmetric liquidity additions."
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX (text:string)
        @doc "ASYMMETRIC-LQ-SPECIAL-TAX \
        \   PURPOSE     Allocates funds to ecosystem targets \
        \               (e.g., governance, incentives) during asymmetric liquidity additions, \
        \               using the Special fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Special fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value \
        \       REASONING \
        \               The Special fee reflects swap processing costs, redirected to support ecosystem functions. \
        \ \
        \   APPLICATION Collected in Ignis and transferred to designated targets via BulkTransfer \
        \   SUMMARY     The Special Tax, based on the Special fee from VSE swaps on the V-POOL, \
        \               supports ecosystem targets (e.g., V Ignis). \
        \               It leverages the Deficit Tax’s swap process, promoting fairness in asymmetric liquidity additions"
        @event
        true
    )
    (defcap SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX (text:string)
        @doc "ASYMMETRIC-LQ-LQBOOST-TAX \
        \   PURPOSE     Enhances the LiquidIndex of the SSTOA Token, during asymmetric liqudity Additions \
        \               using the Boost fee computed via virtual swaps, \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   DERIVATION  Corresponds to the Boost fee portion from the Virtual Swap Engine (VSE) swaps \
        \               performed on the Virtual Pool (V-POOL) (original reserves + balanced liquidity) \
        \               to achieve the Asymmetric Break Amounts (ABA), \
        \               as detailed in the Asymmetric Liquidity Deficit Tax documentation \
        \   TAC CALCULATION \
        \               The Fee Value computed in pool Tokens, is converted to Token A equivalents using the Pool ratio \
        \               which are then converted to an IGNIS amount value. \
        \       REASONING \
        \               The Boost fee reflects swap processing costs, redirected to increase the value of SSTOA \
        \   APPLICATION Resulted IGNIS is compressed to OURO, \
        \               which is then further used to fuel the SSTOA-OURO-WSTOA Primal Ouronet Pool, \
        \               while burning an equivalent amount of SSTOA, thus increasing the LiquidIndex \
        \               which further increases SSTOA value in WSTOA \
        \   SUMMARY     The Boost Tax, based on the Boost fee from the VSE Swaps on the V-POOL \
        \               supports the Ouronet Ecosystem by increasing the value of SSTOA in WSTOA \
        \               It leverages the Deficit Tax’s swap process, promoting fairness in asymmetric liquidity additions"
        @event
        true
    )
    (defcap SWPL|S>ADD_ASYMMETRIC-LQ (account:string swpair:string input-amounts:[decimal])
        @doc "Exposes <input-amounts> when they have an asymetric part \
            \ when Liquidity is added from <account> on <swpair>"
        @event
        true
    )
    (defcap SWPL|S>ADD_BALANCED-LQ (account:string swpair:string input-amounts:[decimal])
        @doc "Exposes <input-amounts> when they have a balanced part \
            \ when Liquidity is added from <account> on <swpair>"
        @event
        true
    )
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    (defun UDC_VirtualSwapEngineSwpair:object{UtilitySwpV2.VirtualSwapEngine}
        (account:string account-liq:[decimal] swpair:string pool-liq:[decimal])
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
            )
            (UDC_VirtualSwapEngine
                account account-liq swpair pool-liq
                A W (UDC_PoolFees swpair)
            )
        )
    )
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV2.VirtualSwapEngine}
        (
            account:string account-liq:[decimal] swpair:string starting-liq:[decimal]
            A:decimal W:[decimal] F:object{UtilitySwpV2.SwapFeez}
        )
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (zero-lst:[decimal] (make-list (length pool-tokens) 0.0))
            )
            (ref-U|SWP::UDC_VirtualSwapEngine
                pool-tokens
                (ref-SWP::UC_PoolTokenPrecisions swpair)
                account account-liq swpair starting-liq
                A W F
                zero-lst zero-lst zero-lst []
            )
        )
    )
    (defun UDC_PoolFees:object{UtilitySwpV2.SwapFeez} (swpair:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (lb:bool (ref-SWP::UR_LiquidBoost))
                (lp-fee:decimal (ref-SWP::UR_FeeLP swpair))
                (special-fee:decimal (ref-SWP::UR_FeeSP swpair))
                (boost-fee:decimal (if lb lp-fee 0.0))
            )
            (ref-U|SWP::UDC_SwapFeez lp-fee special-fee boost-fee)
        )
    )
    (defun UDC_OutputLP:object{SwapperLiquidityV2.OutputLP} (a:decimal b:decimal)
        {"primary"                  : a
        ,"secondary"                : b}
    )
    (defun UDC_LiquiditySplit:object{SwapperLiquidityV2.LiquiditySplit} (a:[decimal] b:[decimal])
        {"balanced"                 : a
        ,"asymmetric"               : b}
    )
    (defun UDC_LiquiditySplitType:object{SwapperLiquidityV2.LiquiditySplitType} (a:bool b:bool)
        {"iz-balanced"              : a
        ,"iz-asymmetric"            : b}
    )
    (defun UDC_LiquidityData:object{SwapperLiquidityV2.LiquidityData}
        (a:object{SwapperLiquidityV2.LiquiditySplit} b:object{SwapperLiquidityV2.LiquiditySplitType} c:decimal d:decimal e:decimal)
        {"sorted-lq"                : a
        ,"sorted-lq-type"           : b
        ,"balanced"                 : c
        ,"asymmetric"               : d
        ,"asymmetric-fee"           : e}
    )
    (defun UDC_LiquidityComputationData:object{SwapperLiquidityV2.LiquidityComputationData}
        (a:integer b:string c:integer d:decimal e:decimal f:[decimal])
        {"li"                       : a
        ,"pool-type"                : b
        ,"lp-prec"                  : c
        ,"current-lp-supply"        : d
        ,"lp-supply"                : e
        ,"pool-token-supplies"      : f}
    )
    (defun UDC_AsymmetricTax:object{SwapperLiquidityV2.AsymmetricTax}
        (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal)
        {"tad"                      : a
        ,"tad-diff"                 : b
        ,"fuel"                     : c
        ,"special"                  : d
        ,"boost"                    : e
        ,"fuel-to-lp"               : f}
    )
    (defun UDC_CompleteLiquidityAdditionData:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (
            a:[decimal] b:[decimal] c:[decimal] d:[decimal]
            e:decimal f:decimal
            g:decimal
            h:decimal i:decimal j:decimal k:decimal l:decimal
            m:string n:string o:string p:string q:string
            r:object{SwapperLiquidityV2.CladOperation}
        )
        {"total-input-liquidity"    : a
        ,"balanced-liquidity"       : b
        ,"asymmetric-liquidity"     : c
        ,"asymmetric-deviation"     : d
        ;;
        ,"primary-lp"               : e
        ,"secondary-lp"             : f
        ;;
        ,"total-ignis-tax-needed"   : g
        ;;
        ,"gaseous-ignis-fee"        : h
        ,"deficit-ignis-tax"        : i
        ,"special-ignis-tax"        : j
        ,"lqboost-ignis-tax"        : k
        ,"relinquish-lp"            : l
        ;;
        ,"gaseous-text"             : m
        ,"deficit-text"             : n
        ,"special-text"             : o
        ,"lqboost-text"             : p
        ,"fueling-text"             : q
        ;;
        ,"clad-op"                  : r}
    )
    (defun UDC_CladOperation:object{SwapperLiquidityV2.CladOperation}
        (a:object{IgnisCollectorV3.OutputCumulator} b:[string] c:[decimal] d:bool e:[string] f:[decimal] g:[decimal] h:[decimal])
        {"perfect-ignis-fee"        : a
        ;;
        ,"mt-ids"                   : b
        ,"mt-amt"                   : c
        ,"lp-mint"                  : d
        ,"bk-ids"                   : e
        ,"bk-amt"                   : f
        ;;
        ,"ppb"                      : g
        ,"ppa"                      : h}
    )
    (defun UDC_PoolState:object{SwapperLiquidityV2.PoolState}
        (a:decimal b:object{UtilitySwpV2.SwapFeez} c:[decimal] d:[decimal] e:decimal f:[string] g:[decimal])
        {"A"    : a
        ,"F"    : b
        ,"X"    : c
        ,"W"    : d
        ;;
        ,"LP"   : e
        ,"FT"   : f
        ,"FTP"  : g}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_DetermineLiquidity:object{SwapperLiquidityV2.LiquiditySplitType}
        (input-lqs:object{SwapperLiquidityV2.LiquiditySplit})
        (UDC_LiquiditySplitType
            (!= (at "balanced" input-lqs) (make-list (length (at "balanced" input-lqs)) 0.0))
            (!= (at "asymmetric" input-lqs) (make-list (length (at "asymmetric" input-lqs)) 0.0))
        )
    )
    (defun UCx_Step2AsymmetricTaxVirtualSwapper:object{UtilitySwpV2.VirtualSwapEngine}
        (vse:object{UtilitySwpV2.VirtualSwapEngine} first-token-id:string liq-ids:[string] liq-amounts:[decimal])
        (let
            (
                (l1:integer (length liq-ids))
                (l2:integer (length liq-amounts))
            )
            (if (and (= l1 l2) (= l1 0))
                vse
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        ;;
                        ;;Unwrap VSE Object Data for fixed Variables
                        (account:string (at "account" vse))
                        (pool-type:string (ref-U|SWP::UC_PoolType (at "swpair" vse)))
                        (fees:object{UtilitySwpV2.SwapFeez} (at "F" vse))
                        (A:decimal (at "A" vse))
                        (X-prec:[integer] (at "v-prec" vse))
                        (v-tokens:[string] (at "v-tokens" vse))
                        (W:[decimal] (at "W" vse))
                        ;;
                        (vse-single-chain:[object{UtilitySwpV2.VirtualSwapEngine}]
                            (fold
                                (lambda
                                    (acc:[object{UtilitySwpV2.VirtualSwapEngine}] idx:integer)
                                    (let
                                        (
                                            (prev-vse:object{UtilitySwpV2.VirtualSwapEngine} (at 0 acc))
                                            (id:string (at idx liq-ids))
                                            (amount:decimal (at idx liq-amounts))
                                            ;;
                                            ;;Unwrap VSE Object Data for mutable Variables
                                            (X:[decimal] (at "X" prev-vse))
                                            (output-position:integer (at 0 (ref-U|LST::UC_Search v-tokens id)))
                                            ;;
                                            (rsid:object{UtilitySwpV2.ReverseSwapInputData}
                                                (ref-U|SWP::UDC_ReverseSwapInputData
                                                    id amount first-token-id
                                                )
                                            )
                                            (itso:object{UtilitySwpV2.InverseTaxedSwapOutput}
                                                (ref-SWPI::UC_InverseBareboneSwapWithFeez
                                                    account pool-type rsid fees A X X-prec output-position 0 W
                                                )
                                            )
                                            (input-amount:decimal (at "i-id-brutto" itso))
                                            ;;
                                            (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                (ref-U|SWP::UDC_DirectSwapInputData
                                                    [first-token-id]
                                                    [input-amount]
                                                    id
                                                )
                                            )
                                            (new-vse:object{UtilitySwpV2.VirtualSwapEngine}
                                                (ref-SWPI::UC_VirtualSwap prev-vse dsid)
                                            )
                                        )
                                        (ref-U|LST::UC_ReplaceAt acc 0 new-vse)
                                    )
                                )
                                [vse]
                                (enumerate 0 (- l1 1))
                            )
                        )
                    )
                    (at 0 vse-single-chain)
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_STOA-PID|LpToIgnis:decimal (swpair:string amount:decimal stoa-pid:decimal)
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (ignis-prec:integer (URC_IgnisPrecision))
                (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                (lp-value-in-dwk:decimal (at 1 pool-value))
            )
            (floor (fold (*) 100.0 [amount lp-value-in-dwk stoa-pid]) 2)
        )
    )
    (defun URC_STOA-PID|TokenToIgnis (id:string amount:decimal stoa-pid:decimal)
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (ignis-prec:integer (URC_IgnisPrecision))
                (a-price:decimal (ref-SWPI::URC_TokenDollarPrice id stoa-pid))
            )
            (floor (fold (*) 1.0 [100.0 a-price amount]) ignis-prec)
        )
    )
    (defun URC_STOA-PID|CLAD:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (
            account:string swpair:string ld:object{SwapperLiquidityV2.LiquidityData} 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (total-input-liquidity:[decimal] (zip (+) balanced-liquidity asymmetric-liquidity))
                ;;
                (balanced-lp-amount:decimal (at "balanced" ld))
                ;;
                ;;Create <ico-flat>
                (flat-ignis-lq-fee:decimal 1000.0)
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico-flat:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-fee SWP|SC_NAME trigger [])
                )
                ;;Initial Transfer IDs and Amounts
                (input-ids-for-transfer:[string]
                    (if (and (not iz-balanced) iz-asymmetric)
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair total-input-liquidity)
                        (ref-SWP::UR_PoolTokens swpair)
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if (and (not iz-balanced) iz-asymmetric)
                        (ref-U|LST::UC_RemoveItem total-input-liquidity 0.0)
                        total-input-liquidity
                    )
                )
                ;;General Variables
                (pt-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (pt-amounts-with-balanced:[decimal] 
                    (zip (+) pt-current-amounts balanced-liquidity)
                )
                (pt-amounts-with-asymmetric:[decimal] 
                    (zip (+) pt-amounts-with-balanced asymmetric-liquidity)
                )
            )
            (if iz-asymmetric
                (let
                    (
                        (asymmetric-lp-amount:decimal (at "asymmetric" ld))
                        (asymmetric-lp-fee-amount:decimal (at "asymmetric-fee" ld))
                        (full-asymmetric-deviation:[decimal] (UEV_Liquidity swpair ld))
                        (asymmetric-deviation:decimal (at 0 full-asymmetric-deviation))
                        (computed-gaseous-fee:decimal (URC_STOA-PID|LpToIgnis swpair asymmetric-lp-fee-amount stoa-pid))
                        (raw-gaseous-fee:decimal
                            (if (< computed-gaseous-fee 50.0)
                                50.0
                                (dec (ceiling computed-gaseous-fee))
                            )
                        )
                        (gaseous-ignis-fee:decimal
                            (if gaseous-collection
                                raw-gaseous-fee
                                0.0
                            )
                        )
                        (ico-gaseous:object{IgnisCollectorV3.OutputCumulator}
                            (if gaseous-collection
                                (ref-IGNIS::UDC_ConstructOutputCumulator gaseous-ignis-fee SWP|SC_NAME trigger [])
                                EOC
                            )
                        )
                        (gaseous-text:string
                            (format "~{} LP out of a total ~{} Asym-LP, covered by {} IGNIS (discounted as GAS), as Asym-Liq.-FEE"
                                [(floor asymmetric-lp-fee-amount 4) (floor asymmetric-lp-amount 4) gaseous-ignis-fee]
                            )
                        )
                    )
                    (if asymmetric-collection
                        ;;Asymmetric Liquidity With Asymetric TAX Collection
                        (let
                            (
                                (ref-U|LST:module{StringProcessorV2} U|LST)
                                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                (ignis-prec:integer (ref-DPTF::UR_Decimals ignis-id))
                                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                                ;;Compute Asymetric Tax
                                (asymmetric-tax:object{SwapperLiquidityV2.AsymmetricTax} (URC_AsymmetricTax account swpair ld))
                                ;;
                                (a-id:string (at 0 pt-ids))
                                (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                                
                                ;;
                                ;;<ASYMMETRIC-LQ-DEFICIT-TAX>
                                (tad-diff-fillup:decimal (+ asymmetric-deviation 0.5))
                                (tad-diff:decimal (at "tad-diff" asymmetric-tax))
                                (tad-diff-fillup-as-a:decimal (floor (* tad-diff tad-diff-fillup) a-prec))
                                (raw-deficit-ignis-tax:decimal (URC_STOA-PID|TokenToIgnis a-id tad-diff-fillup-as-a stoa-pid))
                                (deficit-ignis-tax:decimal
                                    (if (< raw-deficit-ignis-tax 50.0)
                                        50.0 (ceiling raw-deficit-ignis-tax 2)
                                    )
                                )
                                ;;
                                ;;ASYMMETRIC-LQ-FUELING-TAX
                                (relinquish-lp:decimal (at "fuel-to-lp" asymmetric-tax))
                                ;;
                                ;;ASYMMETRIC-LQ-SPECIAL-TAX
                                (special-as-a:decimal (at "special" asymmetric-tax))
                                (raw-special-ignis-tax:decimal (URC_STOA-PID|TokenToIgnis a-id special-as-a stoa-pid))
                                (special-ignis-tax:decimal
                                    (if (and (> raw-special-ignis-tax 0.0) (< raw-special-ignis-tax 50.0))
                                        50.0 (ceiling raw-special-ignis-tax 2)
                                    )
                                )
                                ;;
                                ;;ASYMMETRIC-LQ-LQBOOST-TAX
                                (boost-as-a:decimal (at "boost" asymmetric-tax))
                                (raw-lqboost-ignis-tax:decimal 
                                    (if (= boost-as-a 0.0)
                                        0.0
                                        (URC_STOA-PID|TokenToIgnis a-id boost-as-a stoa-pid)
                                    )
                                )
                                (lqboost-ignis-tax:decimal
                                    (if (and (> raw-lqboost-ignis-tax 0.0) (< raw-lqboost-ignis-tax 100.0))
                                        100.0 (dec (ceiling raw-lqboost-ignis-tax))
                                    )
                                )
                                ;;Construc ICOz
                                (ignis-swp:decimal (fold (+) 0.0 [deficit-ignis-tax special-ignis-tax lqboost-ignis-tax]))
                                ;;DUPLICATE READ REMOVED 2026-09-13: <ignis-id> is already bound at
                                ;;the top of this same let group, from the identical
                                ;;(ref-DALOS::UR_IgnisID) call, and is consumed there by <ignis-prec>.
                                ;;Rebinding it here shadowed that one for the rest of the group with
                                ;;the same value, at the cost of a second table read on every
                                ;;asymmetric-collection swap -- a transactional path, so real user gas.
                                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                                (secondary-ids-for-transfer:[string] (ref-U|LST::UC_InsertFirst input-ids-for-transfer ignis-id))
                                (secondary-amounts-for-transfer:[decimal] (ref-U|LST::UC_InsertFirst input-amounts-for-transfer ignis-swp))
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    ;;For initial Transfer towards the SWP|SC_NAME of input tokens and ignis (removed Ignis additions as is always zero)
                                    (ref-TFT::URCi_MultiTransferCumulator input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    ;;For LP Minting (2)
                                    (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                                )
                                ;;
                                (read-bk-ids:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (bk-ids:[string] (if (= read-bk-ids [BAR]) [BAR] read-bk-ids))
                                (bk-amt:[decimal]
                                    (if (= read-bk-ids [BAR])
                                        [0.0]
                                        (ref-U|SWP::UC_SpecialFeeOutputs
                                            (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
                                            special-ignis-tax
                                            ignis-prec
                                        )
                                    )
                                )
                                ;;Cumulator needed if Liquid Boost is enabled and executed
                                (ico5:object{IgnisCollectorV3.OutputCumulator}
                                    ;;ico3 for IGNIS to special Targets is always zero: removed
                                    ;;Ico4 for IGNIS burn is always zero;removed
                                    ;;Used for the OURO Mint (2)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator 
                                        (ref-IGNIS::UC_IgnisLeg "tier-small") 
                                        SWP|SC_NAME 
                                        (ref-IGNIS::URC_ZeroGAS ouro-id account) []
                                    )
                                )
                                (ico6:object{IgnisCollectorV3.OutputCumulator}
                                    ;;Used for SSTOA Burn (2)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator 
                                        (ref-IGNIS::UC_IgnisLeg "tier-small") 
                                        SWP|SC_NAME 
                                        (ref-IGNIS::URC_ZeroGAS sstoa-id account) []
                                    )
                                )
                                (ico56:object{IgnisCollectorV3.OutputCumulator}
                                    (if (= lqboost-ignis-tax 0.0)
                                        EOC
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                            [ico5 ico6] 
                                            []
                                        )
                                    )
                                )
                                (s-ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [ico-flat ico-gaseous ico1 ico2 ico56] 
                                        []
                                    )
                                )
                            )
                            (UDC_CompleteLiquidityAdditionData
                                total-input-liquidity
                                balanced-liquidity
                                asymmetric-liquidity
                                full-asymmetric-deviation
                                ;;
                                (- (+ balanced-lp-amount asymmetric-lp-amount) relinquish-lp)
                                0.0
                                ;;
                                (fold (+) 0.0 [deficit-ignis-tax special-ignis-tax lqboost-ignis-tax])
                                ;;
                                gaseous-ignis-fee
                                deficit-ignis-tax
                                special-ignis-tax
                                lqboost-ignis-tax
                                relinquish-lp
                                ;;
                                gaseous-text
                                (format "{} IGNIS costs for a Deviation of ~{}%, as Asym-Liq.-Deficit-TAX"
                                    [deficit-ignis-tax (floor (* 100.0 asymmetric-deviation) 4)]
                                )
                                (if (= special-ignis-tax 0.0)
                                    "Without Asym-Liq.-Special-Tax, as Pool isn't setup up with a special fee"
                                    (format "{} IGNIS credited to Special Targets, as Asym-Liq.-Special-TAX"
                                        [special-ignis-tax]
                                    )
                                )
                                (if (= lqboost-ignis-tax 0.0)
                                    "Without Asym-Liq.LqBoost-TAX, as Global Liquid Boost is disabled"
                                    (format "{} IGNIS fueling SSTOA LiquidIndex, as Asym-Liq.LqBoost-TAX"
                                        [lqboost-ignis-tax]
                                    )
                                )
                                (format "Relinquish ~{} LP increasing LP Value, as Asym-Liq.-Fueling-TAX"
                                    [(floor relinquish-lp 4)]
                                )
                                (UDC_CladOperation
                                    s-ico1
                                    ;;
                                    secondary-ids-for-transfer
                                    secondary-amounts-for-transfer
                                    true
                                    bk-ids
                                    bk-amt
                                    ;;
                                    pt-amounts-with-balanced
                                    pt-amounts-with-asymmetric
                                )
                            )
                        )
                        ;;Asymmetric Liquidity Without Asymetric TAX Collection
                        (UDC_CompleteLiquidityAdditionData
                            total-input-liquidity
                            balanced-liquidity
                            asymmetric-liquidity
                            full-asymmetric-deviation
                            ;;
                            (if gaseous-collection
                                (+ balanced-lp-amount asymmetric-lp-fee-amount)
                                balanced-lp-amount
                            )
                            (if gaseous-collection
                                (- asymmetric-lp-amount asymmetric-lp-fee-amount)
                                asymmetric-lp-amount
                            )
                            ;;
                            0.0
                            ;;
                            gaseous-ignis-fee
                            0.0
                            0.0
                            0.0
                            0.0
                            ;;
                            (if gaseous-collection
                                gaseous-text
                                (format "Credited ~{} LP out of a total ~{} Asym-LP, with no IGNIS Asym-Liq.-Fee"
                                    [(floor asymmetric-lp-fee-amount 4) (floor asymmetric-lp-amount 4)]
                                )
                            )
                            (format "Asymmetric Deviation ~{}%: no Asym-Liq.-Deficit-Tax"
                                [(floor (* 100.0 asymmetric-deviation) 4)]
                            )
                            "Without Asym-Liq.-Special-Tax"
                            "Without Asym-Liq.-LqBoost-Tax"
                            "Without Asym-Liq.-Fueling-Tax"
                            (UDC_CladOperation
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [
                                        ico-flat ico-gaseous 
                                        (ref-TFT::URCi_MultiTransferCumulator 
                                            input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer
                                        )
                                        (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                                    ] 
                                    []
                                )
                                ;;
                                input-ids-for-transfer
                                input-amounts-for-transfer
                                false
                                [BAR]
                                [0.0]
                                ;;
                                pt-amounts-with-balanced
                                pt-amounts-with-asymmetric
                            )
                        )
                    )
                )
                (UDC_CompleteLiquidityAdditionData
                    total-input-liquidity
                    balanced-liquidity
                    asymmetric-liquidity
                    [0.0 0.0]
                    ;;
                    balanced-lp-amount
                    0.0
                    ;;
                    0.0
                    ;;
                    0.0
                    0.0
                    0.0
                    0.0
                    0.0
                    ;;
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Fee)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Deficit-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-Special-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} IGNIS as Asym-Liq.-LqBoost-Tax)" [0.0])
                    (format "Balanced-Liquidity, ({} LP relinquished as Asym-Liq.-Fueling-Tax)" [0.0])
                    (UDC_CladOperation
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [
                                ico-flat 
                                (ref-TFT::URCi_MultiTransferCumulator 
                                    input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer
                                )
                                (ref-IGNIS::UDC_LegCumulator "lp-mint" SWP|SC_NAME)
                            ] 
                            []
                        )
                        ;;
                        input-ids-for-transfer
                        input-amounts-for-transfer
                        true
                        [BAR]
                        [0.0]
                        ;;
                        pt-amounts-with-balanced
                        pt-amounts-with-asymmetric
                    )
                )
            )
        )
    )
    (defun URC_TokenPrecision (id:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Decimals id)
        )
    )
    (defun URC_IgnisPrecision ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (URC_TokenPrecision (ref-DALOS::UR_IgnisID))
        )
    )
    ;;
    (defun URC_LD:object{SwapperLiquidityV2.LiquidityData} (swpair:string input-amounts:[decimal])
        @doc "Computes the LP amounts, valid for all 3 pool types, outputing a TripleLP object containing: \
        \ 1st Value: A Liquidity Split Object, containing the Liquidity Split \
        \ 2nd Value: The Type of Liquidity existing in the input \
        \ 3rd Value: LP for the Balanced Part \
        \ 4th Value: Full LP for the asymmetric Part \
        \ 5th Value: LP Amount as Liquidity Fee for the asymmetric Part"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (sorted-lq:object{SwapperLiquidityV2.LiquiditySplit} (URC_SortLiquidity swpair input-amounts))
                (sorted-lq-type:object{SwapperLiquidityV2.LiquiditySplitType} (UC_DetermineLiquidity sorted-lq))
                (balanced-lq:[decimal] (at "balanced" sorted-lq))
                (asymmetric-lq:[decimal] (at "asymmetric" sorted-lq))
                (iz-balanced:bool (at "iz-balanced" sorted-lq-type))
                (iz-asymmetric:bool (at "iz-asymmetric" sorted-lq-type))
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (lcd:object{SwapperLiquidityV2.LiquidityComputationData}
                    (UDC_LiquidityComputationData
                        (length input-amounts)
                        (ref-U|SWP::UC_PoolType swpair)
                        (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair))
                        current-lp-supply
                        lp-supply
                        pool-token-supplies
                    )
                )
                ;;Balanced Liq Computation
                (x:decimal 
                    (if iz-balanced
                        (URCx_BalancedLP lcd balanced-lq)
                        0.0
                    )
                )
                ;;asymmetric Liq Computation
                (y-with-z:[decimal]
                    (if iz-asymmetric
                        (let
                            (
                                (asymmetric-lp:[decimal] (URCx_AsymmetricLP swpair asymmetric-lq lcd))
                                (full-lp:decimal (at 0 asymmetric-lp))
                                (taxd-lp:decimal (at 1 asymmetric-lp))
                            )
                            [full-lp (- full-lp taxd-lp)]
                        )
                        [0.0 0.0]
                    )
                )
            )
            (UDC_LiquidityData
                sorted-lq
                sorted-lq-type
                x
                (at 0 y-with-z)
                (at 1 y-with-z)
            )
        )
    )
    (defun URCx_BalancedLP:decimal (lcd:object{SwapperLiquidityV2.LiquidityComputationData} balanced-lq:[decimal])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_LP 
                balanced-lq 
                (at "pool-token-supplies" lcd)
                (at "lp-supply" lcd)
                (at "lp-prec" lcd)
            )
        )
    )
    (defun URCx_AsymmetricLP:[decimal] (swpair:string asymmetric-lq:[decimal] lcd:object{SwapperLiquidityV2.LiquidityComputationData})
        @doc "Computes the Full LP (at 0) and Reduced LP (at 1) from Liquidity Fee for asymmetric-liquidity"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (li:integer (at "li" lcd))
                (pool-type:string (at "pool-type" lcd))
                (lp-prec:integer (at "lp-prec" lcd))
                (current-lp-supply:decimal (at "current-lp-supply" lcd))
                (lp-supply:decimal (at "lp-supply" lcd))
                (pool-token-supplies:[decimal] (at "pool-token-supplies" lcd))
                ;;
                ;;Compute Full LP for asymmetric Liq
                (percent-lst:[decimal]
                    (if (= pool-type "W")
                        (if (= current-lp-supply 0.0)
                            (ref-SWP::UR_GenesisWeigths swpair)
                            (ref-SWP::UR_Weigths swpair)
                        )
                        (ref-U|VST::UCv_SplitBalanceForVesting 24 1.0 li)
                    )
                )
                (lp-amounts:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL 
                                acc 
                                (floor 
                                    (fold (*) 1.0 [(/ (at idx asymmetric-lq) (at idx pool-token-supplies)) (at idx percent-lst) lp-supply]) 
                                    lp-prec
                                )
                            )
                        )
                        []
                        (enumerate 0 (- li 1))
                    )
                )
                (full-asymmetric-lp:decimal (fold (+) 0.0 lp-amounts))
                ;;Compute Taxed LP for asymmetric Liq
                (liquidity-fee:decimal (/ (ref-SWP::URC_LiquidityFee swpair) 1000.0))
                (amp:decimal (ref-SWP::UR_Amplifier swpair))
                (new-balances:[decimal] (zip (+) pool-token-supplies asymmetric-lq))
                (d0:decimal
                    (if (= pool-type "S")
                        (ref-U|SWP::UC_ComputeD amp pool-token-supplies)
                        5040000.0
                    )
                )
                (d1:decimal
                    (if (= pool-type "S")
                        (ref-U|SWP::UC_ComputeD amp new-balances)
                        (+ 5040000.0 (URC_D1forWP swpair pool-token-supplies asymmetric-lq))
                    )
                )
                (dr:decimal (floor (/ d0 d1) 24))
                (Xp:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (adjusted-balances:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (- 
                                    (at idx new-balances) 
                                    (floor 
                                        (* 
                                            (abs 
                                                (- 
                                                    (at idx new-balances) 
                                                    (floor 
                                                        (* 
                                                            (at idx pool-token-supplies)
                                                            dr
                                                        ) 
                                                        (at idx Xp)
                                                    )
                                                )
                                            )
                                            liquidity-fee
                                        )
                                        (at idx Xp)
                                    )
                                )
                            )
                        )
                        []
                        (enumerate 0 (- li 1))
                    )
                )
                (taxed-asymmetric-lp:decimal
                    (floor 
                        (/ 
                            (* 
                                (-
                                    (if (= pool-type "S")
                                        (ref-U|SWP::UC_ComputeD amp adjusted-balances) 
                                        (URC_D1forWP swpair pool-token-supplies adjusted-balances)
                                    )
                                    d0
                                ) 
                                lp-supply
                            ) 
                            d0
                        ) 
                        lp-prec
                    )
                )
            )
            [full-asymmetric-lp taxed-asymmetric-lp]
        )
    )
    (defun URC_D1forWP:decimal (swpair:string current:[decimal] input:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (how-many:decimal (dec (length current)))
                (weigths:[decimal] (ref-SWP::UR_Weigths swpair))
                (vpt:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL 
                                acc 
                                (floor 
                                    (/ 
                                        (if (= pool-type "P")
                                            (/ 5040000.0 how-many)
                                            (* 5040000.0 (at idx weigths))
                                        )
                                        (at idx current)
                                    ) 
                                    24
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length current) 1))
                    )
                )
                (input-values:[decimal] (zip (lambda (x:decimal y:decimal) (* x y)) input vpt))
            )
            (fold (+) 0.0 input-values)
        )
    )
    (defun URC_AsymmetricTax:object{SwapperLiquidityV2.AsymmetricTax}
        (account:string swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                ;;Unwrap Object Data
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
            )
            (if (and iz-balanced (not iz-asymmetric))
                (UDC_AsymmetricTax 0.0 0.0 0.0 0.0 0.0 0.0)
                (let
                    (
                        (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                        (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                        (total-input-liqudity:[decimal] 
                            (zip (+) balanced-liquidity asymmetric-liquidity)
                        )
                        (balanced-lp-amount:decimal (at "balanced" ld))
                        (asymmetric-lp-amount:decimal (at "asymmetric" ld))
                        (asymmetric-lp-fee-amount:decimal (at "asymmetric-fee" ld))
                        (lp-amount:decimal (+ balanced-lp-amount asymmetric-lp-amount))
                        ;;
                        ;;
                        ;;Get Data to Construct the Virtual Swapper and the Values to compute ABA
                        (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                        (first-pt:string (at 0 pool-tokens))
                        (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                        (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                        ;;
                        (w:[decimal] (ref-SWP::UR_Weigths swpair))
                        (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                        ;;
                        ;;The Asymetric Break Amounts <aba>
                        ;;<aba> is the Output Liquidity one would get by removing LP made with asymmetric Liquidity
                        ;;These are hypothetical values one would get, if all input Liqudity were to be added into the Pool
                        ;;While minting all the LP generated by it via raw mathematical computation.
                        ;;Against these hypothetical Values the Token A Deficit is calculated, which is the base for the Asymetric Taxes.
                        (pool-token-supplies-for-aba:[decimal]
                            ;; on Pool that has a liqudity equal to <pool-liq> + <input-balanced-lq> + <input-asymmetric-lq>
                            (zip (+) pool-token-supplies total-input-liqudity)
                        )
                        (lp-supply-for-aba:decimal
                            ;; and an LP amount equal to <lp-supply> + <balanced-lp-amount> + <asymmetric-lp-amount>
                            (+ lp-supply lp-amount)
                            ;;<aba> is the base for computing the AsymmetricTax
                        )
                        (aba:[decimal]
                            (URCv_CustomLpBreakAmounts swpair pool-token-supplies-for-aba lp-supply-for-aba asymmetric-lp-amount)
                        )
                        ;;
                        ;;
                        ;;Constructing the Pool Supplies of the Virtual Swapper, and the Virtual Account Starting Liquidity
                        (virtual-pool-token-supplies:[decimal] 
                            ;;<virtual-pool-token-supplies> = <pool-token-supplies> + <balanced-liquidity> when it exists
                            (if iz-balanced
                                (zip (+) pool-token-supplies balanced-liquidity)
                                pool-token-supplies
                            )
                        )
                        (virtual-lp-supply:decimal
                            ;; Used to compute Fuel Shares as LP
                            (if iz-balanced
                                (+ lp-supply balanced-lp-amount)
                                lp-supply
                            )
                        )
                        (first-bonus-amount:decimal (at 0 aba))
                        (fba-filled:[decimal] (ref-SWPI::URC_IndirectRefillAmounts pool-token-supplies [0] [first-bonus-amount]))
                        (account-starting-liq:[decimal]
                            ;;The Liquidity the Virtual Account starts with on the Virtual Swap Engine
                            ;;Equal to the Asymetric Liqudity minus the A amount from ABA
                            (zip (-) asymmetric-liquidity fba-filled)
                        )
                        (vse:object{UtilitySwpV2.VirtualSwapEngine}
                            (UDC_VirtualSwapEngineSwpair 
                                account account-starting-liq
                                swpair virtual-pool-token-supplies
                            )
                        )
                        (a-prec:integer 
                            (at 0 (at "v-prec" vse))
                            ;;Preparing Step 1 of the Virtual Swaps
                            ;;STEP 1.
                            ;;All no-A Tokens on the Virtual Account are swapped in the Virtual Pool to Token A.
                            ;;      This consumes all non token-A in the Virtual Account of the Swap Engine
                            ;;STEP 2.
                            ;;For each non-A Token the Value of Token A is computed with Reverse Swap (with fees) Math,
                            ;;      that would results in its coresponding value in <aba>
                            ;;      the computed A Amount is then forward swapped in the Virtual Swap Engine
                            ;;      this is done sequentially for each positive value of non-A Tokens present in <aba>
                            ;;After the Virtual Swaps are done, 
                            ;;  1)A deficit of Token A would result.
                            ;;      This deficit represents how much more Token A you would have needed to get the <aba> values of non-A Tokens,
                            ;;          if you were to execute natural Swaps in the pool using Token A as input for these Swaps.
                            ;;      Naturally, the amount of Token A present in the <asymmetric-liquidity> counts against the deficit (since you already have it)
                            ;;      And the amount of Token A in the <aba> counts towards the deficit (since you would have gotten it by breaking the <asymmetric-lp-amount>)
                            ;;          Which is why the Token A in the <aba> needs to be subtracted from the Starting Asymmetric Liquidity 
                            ;;          the Virtual Account starts with in the Virtual Swap Engine
                            ;;  2)Various Fees saved by the VSE (Virtual Swap Engine) related to existing POOL Fees
                            ;;      These are the basis for the computed Taxes.
                        )
                        (df-pool-tokens:[string] (drop 1 pool-tokens))
                        (df-asymmetric-liquidity:[decimal] (drop 1 asymmetric-liquidity))
                        (df-asymmetric-liquidity-no-zeroes:[decimal] (ref-U|LST::UC_RemoveItem df-asymmetric-liquidity 0.0))
                        (df-pool-tokens-no-zeroes:[string]
                            (fold
                                (lambda
                                    (acc:[string] idx:integer)
                                    (if (!= (at idx df-asymmetric-liquidity) 0.0)
                                        (ref-U|LST::UC_AppL
                                            acc
                                            (at idx df-pool-tokens)
                                        )
                                        acc
                                    )
                                )
                                []
                                (enumerate 0 (- (length df-pool-tokens) 1))
                            )
                        )
                        (l1:integer (length df-asymmetric-liquidity-no-zeroes))
                        (swap-no1-data:object{UtilitySwpV2.DirectSwapInputData}
                            (ref-U|SWP::UDC_DirectSwapInputData
                                df-pool-tokens-no-zeroes
                                df-asymmetric-liquidity-no-zeroes
                                (at 0 pool-tokens)
                            )
                        )
                        ;;
                        ;;First Virtual Swap
                        (vse1:object{UtilitySwpV2.VirtualSwapEngine}
                            (if (!= l1 0)
                                (ref-SWPI::UC_VirtualSwap vse swap-no1-data)
                                vse
                            )
                        )
                        (vse2:object{UtilitySwpV2.VirtualSwapEngine}
                            (UCx_Step2AsymmetricTaxVirtualSwapper 
                                vse1 first-pt df-pool-tokens (drop 1 aba)
                            )
                        )
                        ;;Get Needed Virtual Swap Values
                        (token-a-deficit:decimal (abs (at 0 (at "account-supply" vse2))))
                        
                        (fuel:[decimal] (at "fuel" vse2))
                        (special:[decimal] (at "special" vse2))
                        (boost:[decimal] (at "boost" vse2))
                        ;;
                        ;;Get Share Values on <virtual-pool-token-supplies>
                        (shares:[decimal] (ref-SWPI::UC_PoolShares virtual-pool-token-supplies w))
                        (a-share:decimal (at 0 shares))
                        (tad-shares:decimal (floor (* token-a-deficit a-share) 24))

                        (fuel-shares:decimal (floor (fold (+) 0.0 (zip (*) fuel shares)) 24))
                        (special-shares:decimal (floor (fold (+) 0.0 (zip (*) special shares)) 24))
                        (boost-shares:decimal (floor (fold (+) 0.0 (zip (*) boost shares)) 24))
                        (fee-shares:decimal (fold (+) 0.0 [fuel-shares special-shares boost-shares]))
                        (diff-shares:decimal (- tad-shares fee-shares))
                        ;;
                        (fuel-as-a:decimal (floor (/ fuel-shares a-share) a-prec))
                        (special-as-a:decimal (floor (/ special-shares a-share) a-prec))
                        (boost-as-a:decimal (floor (/ boost-shares a-share) a-prec))
                        (tad-diff:decimal (- token-a-deficit (fold (+) 0.0 [fuel-as-a special-as-a boost-as-a])))
                        ;;
                        ;;Get Fuel Shares as LP
                        (fuel-to-lp:decimal (floor (/ (* virtual-lp-supply fuel-shares) 5040000.0) lp-prec))
                    )
                    (UDC_AsymmetricTax
                        token-a-deficit
                        tad-diff
                        fuel-as-a
                        special-as-a
                        boost-as-a
                        fuel-to-lp
                    )
                )
            )
        )
    )
    (defun URC_SortLiquidity:object{SwapperLiquidityV2.LiquiditySplit} (swpair:string input-amounts:[decimal])
        @doc "Sorts Liquidity into a balanced part and an asymmetric part"
        (let
            (
                (iz-balanced:bool (URCv_AreAmountsBalanced swpair input-amounts))
            )
            (if iz-balanced
                (UDC_LiquiditySplit
                    input-amounts
                    (make-list (length input-amounts) 0.0)
                )
                (let
                    (
                        (has-zeroes:bool (contains 0.0 input-amounts))
                    )
                    (if has-zeroes
                        (UDC_LiquiditySplit
                            (make-list (length input-amounts) 0.0)
                            input-amounts
                        )
                        (let
                            (
                                (ref-SWP:module{SwapperV4} SWP)
                                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                                (balanced-chain:[decimal]
                                    (fold
                                        (lambda
                                            (acc:[decimal] idx:integer)
                                            (let
                                                (
        
                                                    (input-id:string (at idx pool-tokens))
                                                    (input-amount:decimal (at idx input-amounts))
                                                    (balanced-lq:[decimal] (URC_BalancedLiquidity swpair input-id input-amount false))
                                                    (iz-it-fitting:bool
                                                        (fold
                                                            (lambda
                                                                (acc:bool idxx:integer)
                                                                (let
                                                                    (
                                                                        (element:decimal (at idxx balanced-lq))
                                                                        (iz-smaller:bool (<= element (at idxx input-amounts)))
                                                                    )
                                                                    (and acc iz-smaller)
                                                                )
                                                            )
                                                            true
                                                            (enumerate 0 (- (length balanced-lq) 1))
                                                        )
                                                    )
                                                )
                                                (if iz-it-fitting
                                                    balanced-lq
                                                    acc
                                                )
                                            )
                                        )
                                        []
                                        (enumerate 0 (- (length input-amounts) 1))
                                    )
                                )
                            )
                            (UDC_LiquiditySplit
                                balanced-chain
                                (zip (-) input-amounts balanced-chain)
                            )
                        )
                    )
                )
            )
        )
    )
    ;;
    (defun URCv_AreAmountsBalanced:bool (swpair:string input-amounts:[decimal])
        @doc "Determines if <input-amounts> are balanced according to <swpair>. \
            \ #56L fix: renamed URC_ -> URCv_ (new StoicSyntax v1.11.0 'validating' \
            \ specialization) — both enforces below are intrinsic shape guards on this \
            \ computation itself, not business validation. Traced all 11 real callers \
            \ (SWPL/SWPLC/MTX-SWP/INFO-ONE+) before keeping them here: 8 of 11 pass raw, \
            \ caller-controlled amounts with zero upstream validation, so both checks are \
            \ genuinely reachable, not tautological; and no single non-URC_* choke point \
            \ exists upstream shared by all of them (3 separate modules call in \
            \ directly), so relocating to a UEV_* would mean duplicating the identical \
            \ checks 8 times instead of once, here. Added the missing per-element \
            \ non-negative check — the old sum-only check let a mixed-sign list like \
            \ [-5.0, 10.0] pass clean (sum=5.0>0) despite containing a negative amount; \
            \ matches the equivalent check already correct in UEV_InputsForLP (used by \
            \ the one path -- C_Fuel -- that already validates this properly)."
        (let
            (
                (sum:decimal (fold (+) 0.0 input-amounts))
                (l1:integer (length input-amounts))
            )
            (enforce (> sum 0.0) "At least a single input value must be greater than zero!")
            (map
                (lambda
                    (idx:integer)
                    (enforce (>= (at idx input-amounts) 0.0) "No input amount may be negative")
                )
                (enumerate 0 (- l1 1))
            )
            (let
                (
                    (has-zeroes:bool (contains 0.0 input-amounts))
                )
                (if has-zeroes
                    false
                    (let
                        (
                            (ref-U|LST:module{StringProcessorV2} U|LST)
                            (ref-SWPI:module{SwapperIssueV4} SWPI)
                            (positive-amounts:[decimal] (ref-U|LST::UC_RemoveItem input-amounts 0.0))
                            (positive-ids:[string] (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts))
                        )
                        (fold
                            (lambda
                                (acc:bool idx:integer)
                                (let
                                    (
                                        (amount:decimal (at idx positive-amounts))
                                        (id:string (at idx positive-ids))
                                        (computed-balance:[decimal] (URC_BalancedLiquidity swpair id amount false))
                                        (checks:bool (= input-amounts computed-balance))
                                    )
                                    (or acc checks)
                                )
                            )
                            false
                            (enumerate 0 (- (length positive-amounts) 1))

                        )
                    )
                )
            )
        )
    )
    (defun URC_BalancedLiquidity:[decimal] (swpair:string input-id:string input-amount:decimal with-validation:bool)
        @doc "Computes the amounts of Balanced Liquidity from one <input-id> with an <input-amount> on a given <swpair> \
        \ <with-validation> specifies if additional validation should also be executed to validate the inputs."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (input-position:integer (ref-SWP::URv_PoolTokenPosition swpair input-id))
                (input-precision:integer (ref-DPTF::UR_Decimals input-id))
                (X:[decimal]
                    (if (= (ref-SWP::URC_LpCapacity swpair) 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (Xp:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
            )
            (if with-validation
                (UEV_BalancedLiquidity swpair input-id input-amount)
                true
            )
            (ref-U|SWP::UC_BalancedLiquidity input-amount input-position input-precision X Xp)
        )
    )
    (defun URC_LpBreakAmounts:[decimal] (swpair:string input-lp-amount:decimal)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
            )
            (URCv_CustomLpBreakAmounts swpair pool-token-supplies lp-supply input-lp-amount)
        )
    )
    (defun URCv_CustomLpBreakAmounts:[decimal]
        (swpair:string swpair-pool-token-supplies:[decimal] swpair-lp-supply:decimal input-lp-amount:decimal)
        @doc "Computes the Pool Token Amounts that result from removing <input-lp-amount> of LP Token \
        \ Using Custom values for PoolTokenSupplies and PoolLPSupply"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (ratio:decimal (floor (/ input-lp-amount swpair-lp-supply) 24))
                (pool-token-precisions:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (l1:integer (length swpair-pool-token-supplies))
                (l2:integer (length pool-token-precisions))
            )
            ;;Validation of inputs
            (enforce 
                (and
                    (<= input-lp-amount swpair-lp-supply)
                    (= l1 l2)
                )
                "Invalid Input Data for Break LP Computation"
            )
            (if (= input-lp-amount swpair-lp-supply)
                swpair-pool-token-supplies
                (fold
                    (lambda
                        (acc:[decimal] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (floor (* ratio (at idx swpair-pool-token-supplies)) (at idx pool-token-precisions))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpair-pool-token-supplies) 1))
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Liquidity:[decimal]
        (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
            @doc "Validates the asymmetric Liquidity amount, if it exists within the LD Object. \
            \ Validation means that it doesent produce a Share Deviation \
            \ greater than 40% of the Maximum Pool Deviation \
            \ Maximum Pool Deviation is given by its token Size \
            \ and is given by the formula (n-1)/n \
            \ The Deviation is computed on existing <swpair> liquidity, plus \
            \ any balanced-liq, should it exist within the <ld> \
            \ Outputs the Share deviation <ld> would produce on the <swpair> \
            \ If no asymmetric liq exists within the LD, then outputs zero, as no Deviation would occur"
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                ;;Unwrap Object Data
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                ;;
                ;;Get Data to Construct the Virtual Swapper
                (pool-token-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (virtual-pool-token-supplies:[decimal] 
                    (if iz-balanced
                        (zip (+) pool-token-supplies balanced-liquidity)
                        pool-token-supplies
                    )
                )
            )
            (if (not iz-asymmetric)
                [0.0 0.0]
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        ;;
                        (w:[decimal] (ref-SWP::UR_Weigths swpair))
                        (n:decimal (dec (length w)))
                        (max-dev:decimal (floor (* 0.4 (/ (- n 1.0) n)) 24))
                        (dev:decimal (ref-SWPI::UCv_DeviationInValueShares virtual-pool-token-supplies asymmetric-liquidity w))
                    )
                    (enforce (<= dev max-dev) (format "asymmetric Liqudity incurrs {} deviation, which is greater than the maximum allowed deviation of {}" [dev max-dev]))
                    [dev max-dev]
                )
            )
        )
    )
    (defun UEV_BalancedLiquidity (swpair:string input-id:string input-amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-on-pool:bool (contains input-id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of SWPair {}" [input-id swpair]))
            (ref-DPTF::UEV_Amount input-id input-amount)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_STOA-PID|AddLiquidity
        (patron:string 
            account:string swpair:string asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
            ld:object{SwapperLiquidityV2.LiquidityData} clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        )
        @doc "#59L note: every branch below calls XE_UpdateSupplies (reserve bump) BEFORE \
            \ XI_AddLiqSendAndMint (the actual token transfer-in + LP mint). That ordering \
            \ is only safe because this whole function always executes as one atomic \
            \ unit — never split across a transaction/step boundary. Confirmed for both \
            \ real call shapes: the single-tx SWPLC client paths call this directly \
            \ inside one transaction; MTX-SWP::MTX|C_AddLiquidity's defpact calls it \
            \ entirely within Step 1's own step-with-rollback block (never spanning \
            \ Step 1 and a later step) — a defpact step is itself a single atomic \
            \ transaction, so the same guarantee holds there too. If a future caller \
            \ ever needs to split this function's bump and transfer across two separate \
            \ steps, this ordering would need re-deriving from scratch, not assumed safe."
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (balanced-liquidity:[decimal] (at "balanced" (at "sorted-lq" ld)))
                (asymmetric-liquidity:[decimal] (at "asymmetric" (at "sorted-lq" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (pt-amounts-with-asymmetric:[decimal] (at "ppa" (at "clad-op" clad)))
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (gw:[decimal] (ref-SWP::UR_GenesisWeigths swpair))
                (read-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (primary-lp-amount:decimal (at "primary-lp" clad))
                (secondary-lp-amount:decimal (at "secondary-lp" clad))
                (lp-mint:bool (at "lp-mint" (at "clad-op" clad)))
                (lp-to-mint:decimal (if lp-mint primary-lp-amount (+ primary-lp-amount secondary-lp-amount)))
            )
            (if iz-asymmetric
                (do
                    (if iz-balanced
                        (with-capability (SWPL|S>ADD_BALANCED-LQ account swpair balanced-liquidity)
                            (with-capability (SWPL|S>ADD_ASYMMETRIC-LQ account swpair asymmetric-liquidity)
                                (ref-SWP::XE_UpdateSupplies swpair pt-amounts-with-asymmetric)
                                (if (= read-lp-supply 0.0)
                                    (ref-SWP::XB_ModifyWeights swpair gw)
                                    true
                                )
                            )
                        )
                        (with-capability (SWPL|S>ADD_ASYMMETRIC-LQ account swpair asymmetric-liquidity)
                            (ref-SWP::XE_UpdateSupplies swpair pt-amounts-with-asymmetric)
                        )
                    )
                    (with-capability (SWPL|S>ASYMMETRIC-LQ-GASEOUS-TAX (at "gaseous-text" clad)) true)
                    (if asymmetric-collection
                        (let
                            (
                                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-ORBR:module{OuroborosV2} OUROBOROS)
                                (ref-SWPI:module{SwapperIssueV4} SWPI)
                                ;;
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                                (primordial-swpair:string (ref-SWP::UR_PrimordialPool))
                                (lqboost-ignis-tax:decimal (at "lqboost-ignis-tax" clad))
                                (primordial-supplies:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial-swpair))
                                ;;
                                ;;Computing the LQ Boost Tax
                                ;;
                                (ouro-mint-amount:decimal 
                                    (if (= lqboost-ignis-tax 0.0)
                                        0.0
                                        (at 0 (ref-ORBR::URCv_Compress lqboost-ignis-tax))
                                    )
                                )    
                                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                    (ref-U|SWP::UDC_DirectSwapInputData
                                        [ouro-id]
                                        [ouro-mint-amount]
                                        sstoa-id
                                    )
                                )
                                (sstoa-burn-amount:decimal 
                                    (if (= lqboost-ignis-tax 0.0)
                                        0.0
                                        (ref-SWPI::URCv_Swap primordial-swpair dsid false)
                                    )
                                )
                                (bk-ids:[string] (at "bk-ids" (at "clad-op" clad)))
                                (bk-amt:[decimal] (at "bk-amt" (at "clad-op" clad)))
                            )
                            (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                            ;;Handle Special Targets
                            (if (!= bk-ids [BAR])
                                (ref-TFT::C_MultiBulkTransfer
                                    patron
                                    SWP|SC_NAME
                                    [bk-ids]
                                    [ignis-id]
                                    [bk-amt]
                                )
                                true
                            )
                            ;;Handle Liquid Boost
                            (if (!= lqboost-ignis-tax 0.0)
                                (do
                                    (ref-DPTF::C_Burn patron SWP|SC_NAME ignis-id lqboost-ignis-tax)
                                    (ref-DPTF::C_Mint patron SWP|SC_NAME ouro-id ouro-mint-amount false)
                                    (ref-DPTF::C_Burn patron SWP|SC_NAME sstoa-id sstoa-burn-amount)
                                    (ref-SWP::XE_UpdateSupplies 
                                        primordial-swpair 
                                        (zip (+) primordial-supplies [(- 0.0 sstoa-burn-amount) ouro-mint-amount 0.0])
                                    )
                                )
                                true
                            )
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-DEFICIT-TAX (at "deficit-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-FUELING-TAX (at "fueling-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-SPECIAL-TAX (at "special-text" clad)) true)
                            (with-capability (SWPL|S>ASYMMETRIC-LQ-LQBOOST-TAX (at "lqboost-text" clad)) true)
                        )
                        (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                    )
                )
                (with-capability (SWPL|S>ADD_BALANCED-LQ account swpair balanced-liquidity)
                    (if (= read-lp-supply 0.0)
                        (ref-SWP::XB_ModifyWeights swpair gw)
                        true
                    )
                    (ref-SWP::XE_UpdateSupplies swpair (at "ppb" (at "clad-op" clad)))
                    (with-capability (SECURE) (XI_AddLiqSendAndMint patron account lp-id lp-to-mint clad))
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_AddLiqSendAndMint 
        (patron:string 
            account:string lp-id:string lp-amount:decimal 
            clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        )
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (ref-TFT::C_MultiTransfer
                patron
                account
                SWP|SC_NAME
                (at "mt-ids" (at "clad-op" clad))
                (at "mt-amt" (at "clad-op" clad))
                true
            )
            (ref-DPTF::C_Mint patron SWP|SC_NAME lp-id lp-amount false)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_AutonomousSwapManagement (swpair:string)
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (pool-worth:decimal (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (inactive-limit:decimal (ref-SWP::UR_InactiveLimit))
            )
            (with-capability (P|SWPL|CALLER)
                (if (< pool-worth inactive-limit)
                    (ref-SWP::XE_CanAddOrSwapToggle swpair false false)
                    (ref-SWP::XE_CanAddOrSwapToggle swpair true false)
                )
            )
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 17_SWPL.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

