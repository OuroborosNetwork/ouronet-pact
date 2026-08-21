;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapperUsageV2
    @doc "Exposes Adding|Removing Liquidty and Swapping Functions of the SWP Module \
    \    V2: Added the already existing <UDC_SpawnSlippageBounds> to the interface \
    \    V2: Smart Swap slippage quote using fee-less multi-hop path tracing via <UDC_SpawnSmartSwapSlippageBounds> \
    \    V2: Smart Swap Multi-hop swap across the entire pool base using BFS path tracing with per-hop liquid pump via <CC_SmartSwap> \
    \    (#34 Phase 8: renamed from <C_SmartSwap> — self-searching variant; <C_SmartSwap> is reserved for the bundle-based, dirty-read-injected path)"
    ;;
    ;;
    ;;  SCHEMAS
    ;;
    (defschema Slippage
        expected-output-amount:decimal
        output-precision:integer
        slippage-percent:decimal
    )
    ;;#34 Phase 6 — dirty-read path-injection bundle schemas. Not used by any function on
    ;;this interface yet (that's Phase 8) — declared now so Phase 7/8 build against a
    ;;settled shape instead of improvising one mid-implementation.
    (defschema SwapRoute
        @doc "The swap's own A->B route (nodes incl. both endpoints, edges one shorter). \
            \ Deliberately NOT the same shape as <CachedPathOrMiss> below — this is never \
            \ cached (P3.0: amount-sensitive, must be freshly discovered every time by \
            \ the exhaustive search, Phase 11), so there is no <is-new> concept for it. \
            \ Carries no value/output data either — the real transaction always computes \
            \ actual hop outputs fresh from live reserves, exactly as it does today; \
            \ off-chain-estimated outputs are only ever used to pick the best candidate \
            \ route before submission, never trusted for real execution numbers."
        nodes:[string]
        edges:[string]
    )
    (defschema CachedPathOrMiss
        @doc "An amount-agnostic X->target path (P3.0) — reused for two DIFFERENT cacheable \
            \ pricing targets, NOT the same token (caught 2026-08-21, before Phase 8 built \
            \ against this, while tracing URC_PoolValue's real implementation): \
            \ <boost-path> targets DLK (DALOS::UR_SilverStoaID — matches XI_RawLiquidPump's \
            \ existing URC_HopperActiveShortest id->lkda call); each <stoa-paths> entry \
            \ targets DWK (DALOS::UR_WrappedStoaID — matches URC_PoolValue's own \
            \ URC_WorthDWK first-token->dwk call, per its own \"Outputs the Pool Value in \
            \ DWK\" doc). Same schema shape, different destination token per field — callers \
            \ must supply/validate the correct one for each. <nodes>=[BAR] is the sentinel \
            \ for 'genuinely no path exists anywhere' (handled gracefully, not a crash — \
            \ this is also what finally closes the long-standing XI_RawLiquidPump crash \
            \ bug, Phase 8). <is-new>=true means this was freshly traced off-chain and \
            \ should be registered after use; false means it came from the shared cache \
            \ already. <is-new> is a hint only — the write path (Phase 7) must \
            \ independently verify before writing, never trust this flag as the write \
            \ authority (owner's final-check catch, 2026-08-21)."
        nodes:[string]
        edges:[string]
        is-new:bool
    )
    (defschema TokenPathPair
        @doc "One deduped entry in a bundle's <stoa-paths> list — one per DISTINCT first \
            \ token among all pools a swap actually touches, not one per pool (#34 Phase \
            \ 5 found today's per-pool loop redundantly re-traces identical paths when \
            \ pools share a first token). <path> targets DWK, matching URC_PoolValue's \
            \ own URC_WorthDWK target — NOT DLK (see CachedPathOrMiss's doc)."
        first-token:string
        path:object{CachedPathOrMiss}
    )
    (defschema SmartSwapPathBundle
        @doc "The full dirty-read-discovered input to the bundle-based SmartSwap entrypoint \
            \ (Phase 8, C_ prefix) — replaces all internal on-chain searching. Assembled \
            \ entirely client-side per P3.7's orchestration sequence. <boost-path> targets \
            \ DLK, <stoa-paths> entries target DWK — different destination tokens, see \
            \ CachedPathOrMiss's doc."
        swap-route:object{SwapRoute}
        boost-path:object{CachedPathOrMiss}
        stoa-paths:[object{TokenPathPair}]
    )
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC_SlippageMinMax:[decimal] (input:object{Slippage}))
    ;;#34 Phase 7: dedup + lookup helpers for the bundle's <stoa-paths>, built ahead of
    ;;Phase 8's actual wiring so that phase builds against a settled, tested shape.
    (defun URC_DedupFirstTokens:[string] (distinct-edges:[string]))
    (defun UC_FindStoaPath:object{CachedPathOrMiss} (stoa-paths:[object{TokenPathPair}] first-token:string))
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_SpawnSmartSwapSlippageBounds:object{Slippage} (input-id:string input-amount:decimal output-id:string slippage:decimal))
    (defun UDC_SpawnSlippageBounds:object{Slippage} (swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal))
    (defun UDC_Slippage:object{Slippage} (a:decimal b:integer c:decimal))
    (defun UDC_SlippageObject:object{Slippage} (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage-value:decimal))
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_ToggleSwapCapability:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool))
    (defun CC_SmartSwap:object{IgnisCollectorV1.OutputCumulator} (account:string input-id:string input-amount:decimal output-id:string slippage:decimal kda-pid:decimal slippage-bounds:object{Slippage}))
    ;;#34 Phase 8: the bundle-based, dirty-read-injected SmartSwap — performs zero
    ;;internal searching (route, boost-path and stoa-paths are all supplied by the
    ;;caller, per SmartSwapPathBundle), built alongside CC_SmartSwap for direct gas
    ;;comparison, not replacing it.
    (defun C_SmartSwap:list
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            kda-pid:decimal slippage-bounds:object{Slippage} bundle:object{SmartSwapPathBundle}
        )
    )
    (defun C_Swap:object{IgnisCollectorV1.OutputCumulator} (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal kda-pid:decimal slippage-bounds:object{Slippage}))
)
;;
(module SWPU GOV
    ;;
    (implements OuronetPolicyV1)
    (implements SwapperUsageV2)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_SWPU           (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|SWPU_ADMIN)))
    (defcap GOV|SWPU_ADMIN ()       (enforce-guard GOV|MD_SWPU))
    ;;
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV1.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P3}
    (defcap P|SWPU|CALLER ()
        true
    )
    (defcap P|SWPU|REMOTE-GOV ()
        true
    )
    (defcap P|DT ()
        (compose-capability (P|SWPU|REMOTE-GOV))
        (compose-capability (P|SWPU|CALLER))
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
        (with-capability (GOV|SWPU_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|SWPU_ADMIN)
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
                (ref-U|G:module{OuronetGuardsV1} U|G)
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|ATS:module{OuronetPolicyV1} ATS)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|ATSU:module{OuronetPolicyV1} ATSU)
                (ref-P|VST:module{OuronetPolicyV1} VST)
                (ref-P|LIQUID:module{OuronetPolicyV1} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV1} SWPT)
                (ref-P|SWP:module{OuronetPolicyV1} SWP)
                (mg:guard (create-capability-guard (P|SWPU|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "SWPU|RemoteDalosGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|VST::P|A_Add
                "SWPU|RemoteSwpGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "SWPU|RemoteSwpGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
                (mp:[guard] (P|UR_IMP))
                (g:guard (ref-U|G::UEV_GuardOfAny mp))
            )
            (enforce-guard g)
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    ;;#34 Phase 8: sentinel CachedPathOrMiss meaning "no bundle-supplied boost-path was
    ;;given, search for one internally" — passed by the self-searching CC_SmartSwap path
    ;;down through XI_SmartSwapCore/XI_LiquidIndexPump/XI_RawLiquidPump, which fall back
    ;;to their original SWPI::URC_HopperActiveShortest search whenever they see this
    ;;exact sentinel. Reuses the SAME [BAR] representation URC_ReadPathCache already uses
    ;;for "no cached path exists" — semantically the same case ("I have nothing for you,
    ;;compute it yourself"), not overloading the meaning.
    (defconst NO_PATH               {"nodes" : [BAR], "edges" : [], "is-new" : false})
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap SWPU|S>FEED-SPECIAL-TARGETS 
        (id:string total-amount:decimal targets:[string] target-proportions:[decimal] target-amounts:[decimal])
        @event
        (compose-capability (P|SWPU|REMOTE-GOV))
    )
    (defcap SWPU|S>LIQUID-BOOST (id:string total-amount:decimal idx-increment:decimal)
        @event
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap SPWU|C>TOGGLE-SWAP (swpair:string toggle:bool)
        (if toggle
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (pool-worth:decimal (at 0 (ref-SWPI::URC_PoolValue swpair)))
                    (inactive-limit:decimal (ref-SWP::UR_InactiveLimit))
                )
                (enforce
                    (> pool-worth inactive-limit)
                    (format "Pool {} cannot have its Swap Functionality turned on because its worth is {} DWK, and a {} DWK Value is required for swap" [swpair pool-worth inactive-limit])
                )
            )
            true
        )
        (compose-capability (P|SWPU|CALLER))
    )
    (defcap SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>SINGL-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>SINGL-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>MULTI-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>MULTI-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|X>SWAP (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (l1:integer (length input-ids))
                (l2:integer (length input-amounts))
                (can-swap:bool (ref-SWP::UR_CanSwap swpair))
                (izo:bool (ref-U|SWP::UC_IzOnPool output-id swpair))
            )
            (enforce izo (format "{} is not part of SwapPool {}" [output-id swpair]))
            (enforce can-swap (format "Pool {} swap functionality is inactive: cannot Swap Tokens" [swpair]))
            (enforce (= l1 l2) "Invalid input Values")
            (map
                (lambda
                    (idx:integer)
                    (let*
                        (
                            (id:string (at idx input-ids))
                            (amount:decimal (at idx input-amounts))
                            (iop:bool (ref-U|SWP::UC_IzOnPool id swpair))
                        )
                        (enforce iop (format "Input Token id {} is not part of Liquidity Pool {}" [id swpair]))
                        (ref-DPTF::UEV_Amount id amount)
                    )
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
    )
    (defcap SWPU|C>SMART-SWAP-WITH-SLIPPAGE
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @event
        (compose-capability (SWPU|X>SMART-SWAP account input-id input-amount output-id))
    )
    (defcap SWPU|C>SMART-SWAP-NO-SLIPPAGE
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal)
        @event
        (compose-capability (SWPU|X>SMART-SWAP account input-id input-amount output-id))
    )
    (defcap SWPU|X>SMART-SWAP (account:string input-id:string input-amount:decimal output-id:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (all-pool-tokens:[string] (ref-SWP::URC_AllPoolTokens))
                (h-obj:object{SwapperIssueV3.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
                (edges:[string] (at "edges" h-obj))
                (nodes:[string] (at "nodes" h-obj))
            )
            (enforce (!= input-id output-id) "Input and Output tokens must differ")
            (enforce (contains input-id all-pool-tokens) (format "Input token {} does not exist in any Swap Pool" [input-id]))
            (enforce (contains output-id all-pool-tokens) (format "Output token {} does not exist in any Swap Pool" [output-id]))
            (enforce (!= (length edges) 0) (format "No path found between {} and {}" [input-id output-id]))
            (ref-DPTF::UEV_Amount input-id input-amount)
            (map
                (lambda
                    (edge:string)
                    (let
                        (
                            (can-swap:bool (ref-SWP::UR_CanSwap edge))
                        )
                        (enforce can-swap (format "Pool {} along the Smart Swap path has swap functionality inactive" [edge]))
                    )
                )
                edges
            )
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
    )
    ;;#34 Phase 8: bundle-based SmartSwap caps — mirror SWPU|C>SMART-SWAP-WITH/NO-SLIPPAGE
    ;;+ SWPU|X>SMART-SWAP exactly, except validation runs against the bundle's own
    ;;swap-route instead of a fresh SWPI::URC_HopperActive search. This is the actual
    ;;gas win this whole redesign exists for: no full-graph BFS at the defcap layer.
    (defcap SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            slippage-bounds:object{SwapperUsageV2.Slippage} bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE account input-id input-amount output-id bundle))
    )
    (defcap SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE account input-id input-amount output-id bundle))
    )
    (defcap SWPU|X>SMART-SWAP-EXPLICIT-ROUTE
        (account:string input-id:string input-amount:decimal output-id:string bundle:object{SwapperUsageV2.SmartSwapPathBundle})
        @doc "All authorization/validation for the bundle-based path lives here, per this \
            \ codebase's client-defcap convention — XI_SmartSwapExplicitRoute below does \
            \ writes only, no enforce. Validates the SUPPLIED swap-route (structural \
            \ connectivity + active-required + depth-cap, all in ONE cheap \
            \ SWPI::URC_ValidatePathActive call — no full-graph search), and that it \
            \ actually starts/ends at <input-id>/<output-id> — a structurally-valid but \
            \ wrong-pair route must never be silently accepted."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (nodes:[string] (at "nodes" (at "swap-route" bundle)))
                (edges:[string] (at "edges" (at "swap-route" bundle)))
                (le:integer (length nodes))
            )
            (enforce (!= input-id output-id) "Input and Output tokens must differ")
            (enforce (!= le 0) (format "No path supplied between {} and {}" [input-id output-id]))
            (enforce (= (at 0 nodes) input-id) "swap-route in bundle does not start at input-id")
            (enforce (= (at (- le 1) nodes) output-id) "swap-route in bundle does not end at output-id")
            (enforce (ref-SWPI::URC_ValidatePathActive nodes edges) "swap-route in bundle is not a valid, fully active path")
            (ref-DPTF::UEV_Amount input-id input-amount)
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_SlippageMinMax:[decimal] (input:object{SwapperUsageV2.Slippage})
        (let
            (
                (expected:decimal (at "expected-output-amount" input))
                (o-prec:integer (at "output-precision" input))
                (sp:decimal (at "slippage-percent" input))
                (slippage:decimal (floor (/ sp 100.0) 4))
                (plus-minus-value:decimal (floor (* slippage expected) o-prec))
                (min:decimal (- expected plus-minus-value))
                (max:decimal (+ expected plus-minus-value))
            )
            [min max]
        )
    )
    (defun UC_FilterSelfFromTargets:list (account:string targets:[string] amounts:[decimal])
        @doc "If <account> is in <targets>, removes it and returns [filtered-targets filtered-amounts retained-amount]. \
            \ Otherwise returns [targets amounts 0.0]. Prevents duplicate receivers in bulk transfers."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (search:[integer] (ref-U|LST::UC_Search targets account))
            )
            (if (!= (length search) 0)
                (let
                    (
                        (pos:integer (at 0 search))
                        (retained:decimal (at pos amounts))
                    )
                    [
                        (ref-U|LST::UC_RemoveItemAt targets pos)
                        (ref-U|LST::UC_RemoveItemAt amounts pos)
                        retained
                    ]
                )
                [targets amounts 0.0]
            )
        )
    )
    (defun UC_FindStoaPath:object{CachedPathOrMiss} (stoa-paths:[object{TokenPathPair}] first-token:string)
        @doc "#34 Phase 7: linear search of a bundle's (already deduped, at most 6-7 \
            \ entries) <stoa-paths> for the entry matching <first-token>. Returns the \
            \ [BAR]-sentinel shape (is-new=false — nothing to register for a lookup \
            \ miss, that's a bundle-construction error, not a fresh discovery) if the \
            \ bundle didn't include an entry for this token at all — Phase 8's caller \
            \ must treat that the same as any other invalid/missing path, not silently \
            \ skip stoa-value pricing for that pool."
        (let*
            (
                (matches:[object{TokenPathPair}]
                    (filter (lambda (tp:object{TokenPathPair}) (= (at "first-token" tp) first-token)) stoa-paths)
                )
            )
            (if (= (length matches) 0)
                {"nodes": [BAR], "edges": [], "is-new": false}
                (at "path" (at 0 matches))
            )
        )
    )
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    (defun URC_DedupFirstTokens:[string] (distinct-edges:[string])
        @doc "#34 Phase 7 (validated with real evidence, P0.6/Phase 5): given the swap's \
            \ own <distinct-edges> (the pools actually traversed), returns the DEDUPED \
            \ list of their first tokens — one entry per distinct first token, not one \
            \ per pool. Two pools sharing a first token (confirmed real in the P2-scale \
            \ topology: two W-chain pools both first=W4, identical 673,080 gas each to \
            \ price independently) collapse to a single lookup here."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (distinct (map (lambda (sp:string) (at 0 (ref-SWP::UR_PoolTokens sp))) distinct-edges))
        )
    )
    (defun URC_PoolStoaValueFromPath:decimal (swpair:string stoa-paths:[object{TokenPathPair}])
        @doc "#34 Phase 8 — the 'dumb-writer' replacement for URC_PoolValue's own \
            \ URC_WorthDWK(first-token, first-token-supply) call. Reproduces \
            \ URC_PoolValue's EXACT pool-worth formula (same current-lp-supply/genesis \
            \ branch, same per-pool-type math), but sources <first-worth> from the \
            \ bundle's <stoa-paths> instead of a fresh first-token->DWK search — that \
            \ search is the actual redundant cost this whole helper exists to remove \
            \ (P0.6: 56.9% of the 102-pool worst-case total, more than 3x routing+boost \
            \ combined). Target is DWK (DALOS::UR_WrappedStoaID), matching \
            \ URC_PoolValue's own doc ('Outputs the Pool Value in DWK') — NOT DLK (see \
            \ CachedPathOrMiss's doc, caught 2026-08-21 before this was built). \
            \ Returns -1.0 (impossible pool-worth, easy sentinel) when the bundle didn't \
            \ supply a usable path for this pool's first token — same graceful-degrade \
            \ principle as the rest of Phase 8: a bad/missing entry just means this ONE \
            \ pool's stoa-value doesn't get refreshed this round, never a crash or an \
            \ aborted swap. Every path is re-validated here regardless of the bundle's \
            \ own <is-new> claim (P3.1: even a cache hit always re-validates) — \
            \ exists-only (SWPT::URC_ValidatePathStructure), matching URC_WorthDWK's own \
            \ URC_Hopper (unfiltered universe, not URC_HopperActive) — pricing paths were \
            \ never required to route over can-swap=true pools only."
        (let*
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (dwk:string (ref-DALOS::UR_WrappedStoaID))
                (dlk:string (ref-DALOS::UR_SilverStoaID))
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
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
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                ;;Same dwk/dlk short-circuits URC_WorthDWK already has — no path tracing
                ;;needed or possible for these two (dlk<->dwk is a fixed protocol-level
                ;;ATS liquid-index conversion, not a swap-pool route).
                (first-worth:decimal
                    (if (= first-token dwk)
                        first-token-supply
                        (if (= first-token dlk)
                            (let
                                (
                                    (ats-pairs-with-dlk-id:[string] (ref-DPTF::UR_RewardBearingToken dlk))
                                    (kdaliquindex:string (at 0 ats-pairs-with-dlk-id))
                                    (index-value:decimal (ref-ATS::URC_Index kdaliquindex))
                                    (dlk-prec:integer (ref-DPTF::UR_Decimals dlk))
                                )
                                (floor (* first-token-supply index-value) dlk-prec)
                            )
                            (let*
                                (
                                    (path:object{CachedPathOrMiss} (UC_FindStoaPath stoa-paths first-token))
                                    (nodes:[string] (at "nodes" path))
                                    (edges:[string] (at "edges" path))
                                    (le:integer (length nodes))
                                    (is-valid:bool
                                        (if (= nodes [BAR])
                                            false
                                            (and
                                                (ref-SWPT::URC_ValidatePathStructure nodes edges)
                                                (and
                                                    (= (at 0 nodes) first-token)
                                                    (= (at (- le 1) nodes) dwk)
                                                )
                                            )
                                        )
                                    )
                                )
                                (if (not is-valid)
                                    -1.0
                                    (let*
                                        (
                                            (h-obj:object{SwapperIssueV3.Hopper}
                                                (ref-SWPI::URC_HopperForKnownRoute nodes edges first-token-supply)
                                            )
                                            (ovs:[decimal] (at "output-values" h-obj))
                                        )
                                        (if (= (length ovs) 0)
                                            first-token-supply
                                            (at 0 (take -1 ovs))
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
            (if (= first-worth -1.0)
                -1.0
                (if (or (= pool-type "S") (= pool-type "P"))
                    (floor (* (dec how-many) first-worth) first-token-precision)
                    (floor (/ first-worth first-weigth) first-token-precision)
                )
            )
        )
    )
    (defun URC_ComputeStoaValueResults:list
        (distinct-edges:[string] stoa-paths:[object{TokenPathPair}])
        @doc "#34 Phase 8 (P3.3/P3.4) — emits [{pool, stoa-value}, ...] for every pool in \
            \ <distinct-edges> the bundle could actually price (skips any pool whose \
            \ first-token has no valid <stoa-paths> entry — URC_PoolStoaValueFromPath's \
            \ -1.0 sentinel — rather than fail the whole swap over one unpriceable pool). \
            \ Does NOT assume <distinct-edges> or <stoa-paths> were perfectly deduped by \
            \ the caller (P3.3: worst case, redundant but harmless per-pool lookups \
            \ against an already-supplied path — no correctness risk, only a missed \
            \ optimization if the caller's own dedup was sloppy)."
        (if (= (length distinct-edges) 0)
            []
            (let
                (
                    (results:[decimal] (map (lambda (sp:string) (URC_PoolStoaValueFromPath sp stoa-paths)) distinct-edges))
                )
                (fold
                    (lambda (acc:list idx:integer)
                        (if (= (at idx results) -1.0)
                            acc
                            (+ acc [{"pool" : (at idx distinct-edges), "stoa-value" : (at idx results)}])
                        )
                    )
                    []
                    ;;#20H-style guard: (enumerate 0 -1) is [0 -1], not empty, in Pact 5 —
                    ;;the outer 0-length branch above already keeps this fold from ever
                    ;;seeing that case, but guarding the enumerate bound directly too
                    ;;(matches this codebase's established convention) costs nothing.
                    (enumerate 0 (- (length distinct-edges) 1))
                )
            )
        )
    )
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    (defun UDC_SpawnSmartSwapSlippageBounds:object{SwapperUsageV2.Slippage}
        (
            input-id:string 
            input-amount:decimal 
            output-id:string 
            slippage:decimal
        )
        @doc "Creates a Slippage object for Smart Swap, using fee-less multi-hop output via URC_Hopper. \
            \ Called by the UI to generate the slippage-bounds object before submitting the Smart Swap transaction."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (h-obj:object{SwapperIssueV3.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
                (ovs:[decimal] (at "output-values" h-obj))
                (expected:decimal (at 0 (take -1 ovs)))
                (o-prec:integer (ref-DPTF::UR_Decimals output-id))
            )
            (enforce
                (= (floor slippage 2) slippage)
                (format "{} is not slippage conform decimal wise (max 2 decimals allowed)" [slippage])
            )
            (enforce
                (or
                    (= slippage -1.0)
                    (and
                        (> slippage 0.0)
                        (<= slippage 50.0)
                    )
                )
                "Slippage must be greater than 0.0 and maximum 50.0, or -1.0 for no slippage"
            )
            (UDC_Slippage expected o-prec slippage)
        )
    )
    (defun UDC_SpawnSlippageBounds:object{SwapperUsageV2.Slippage}
        (
            swpair:string 
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
            slippage:decimal
        )
        @doc "Creates the <slippage-bounds:object{SwapperUsageV2.Slippage}> \
            \ that needs to be passed to the Slippage Swap Functions,\
            \ using data from the UI"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
            )
            (UDC_SlippageObject swpair dsid slippage)
        )
    )
    (defun UDC_Slippage:object{SwapperUsageV2.Slippage}
        (a:decimal b:integer c:decimal)
        {"expected-output-amount"   : a
        ,"output-precision"         : b
        ,"slippage-percent"         : c}
    )
    (defun UDC_SlippageObject:object{SwapperUsageV2.Slippage}
        (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} slippage-value:decimal)
        @doc "Makes a Slippage Object from <input amounts>"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (o-prec:integer (ref-DPTF::UR_Decimals (at "output-id" dsid)))
                (expected:decimal (ref-SWPI::URC_Swap swpair dsid false))
            )
            (enforce
                (= (floor slippage-value 2) slippage-value)
                (format "{} is not slippage conform decimal wise (max 2 decimals allowed)" [slippage-value])
            )
            (enforce
                (or
                    (= slippage-value -1.0)
                    (and
                        (> slippage-value 0.0)
                        (<= slippage-value 50.0)
                    )
                )
                
                "Slippage must be greater than 0.0 and maximum 50.0, or -1.0 for no slippage"
            )
            (UDC_Slippage expected o-prec slippage-value)
        )
    )
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    (defun C_ToggleSwapCapability:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string toggle:bool)
        (UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (with-capability (SPWU|C>TOGGLE-SWAP swpair toggle)
                (ref-SWP::C_ToggleAddOrSwap swpair toggle false)
            )
        )
    )
    (defun CC_SmartSwap:object{IgnisCollectorV1.OutputCumulator}
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @doc "Executes a Smart Swap from <input-id> to <output-id> across multiple pools using BFS path tracing. \
            \ Each hop executes a full swap with fees (LP, special, boost via Option B). \
            \ When slippage != -1.0, slippage-bounds must be the pre-computed object from UDC_SpawnSmartSwapSlippageBounds. \
            \ When slippage == -1.0, pass a dummy object (e.g. UDC_Slippage 0.0 0 0.0). \
            \ #34 Phase 8: renamed from C_SmartSwap — this is the self-searching (BFS in-transaction) \
            \ variant, kept for comparison/fallback. The bundle-based, dirty-read-injected variant \
            \ takes the freed C_SmartSwap name."
        (UEV_IMC)
        (if (!= slippage -1.0)
            (with-capability (SWPU|C>SMART-SWAP-WITH-SLIPPAGE account input-id input-amount output-id slippage slippage-bounds)
                (XI_SmartSwapRouter account input-id input-amount output-id slippage kda-pid slippage-bounds)
            )
            (with-capability (SWPU|C>SMART-SWAP-NO-SLIPPAGE account input-id input-amount output-id slippage)
                (XI_SmartSwapRouter account input-id input-amount output-id slippage kda-pid slippage-bounds)
            )
        )
    )
    (defun C_SmartSwap:list
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage} bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8 — the bundle-based, dirty-read-injected SmartSwap: performs \
            \ ZERO internal searching. <bundle> (SmartSwapPathBundle) is assembled \
            \ entirely client-side per the exhaustive-path-search HANDOFF doc's P3.7 \
            \ orchestration sequence — swap-route (A->B), boost-path (B->DLK) and \
            \ stoa-paths (each distinct pool's first-token->DWK) are all dirty-read \
            \ off-chain before this transaction is ever submitted. Built ALONGSIDE, not \
            \ replacing, CC_SmartSwap (the original self-searching variant) for direct \
            \ A/B gas comparison (P3.5.2) — same slippage/no-slippage split, same \
            \ IGNIS-billing shape at the Talos layer. \
            \ Returns [ico stoa-results] — a WIDER container, not a schema change to the \
            \ shared IgnisCollectorV1.OutputCumulator (P3.10, settled 2026-08-21): <ico> \
            \ carries the same [final-netto hops pools distinct-edges] output shape \
            \ CC_SmartSwap already does (for like-for-like comparison), <stoa-results> is \
            \ the P3.4 dumb-writer's precomputed [{pool, stoa-value}, ...] list — Talos \
            \ maps it straight into XE_UpdateStoaValue with no URC_PoolValue re-derivation \
            \ at all, for every pool this call actually priced. \
            \ Cache self-warming: after a real execution, XI_RegisterBundlePaths \
            \ registers whichever of <boost-path>/<stoa-paths> are genuinely new, valid, \
            \ and actually used this round — via SWPT::XE_RegisterPath (the proper \
            \ forward-module writer), never a caller-side grant of SWPT's own SECURE \
            \ cap directly (see XE_RegisterPath's own doc for why that would be unsafe — \
            \ confirmed against this codebase's own ATS audit findings before landing). \
            \ Runs INSIDE the with-capability block below via XI_SmartSwapAndRegister — \
            \ a granted capability's scope is its own dynamic extent, not the rest of \
            \ the transaction (confirmed the hard way: 'require-capability: not granted' \
            \ when this was first tried as a separate call after the with-capability \
            \ block had already returned)."
        (UEV_IMC)
        (if (!= slippage -1.0)
            (with-capability
                (SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE account input-id input-amount output-id slippage slippage-bounds bundle)
                (XI_SmartSwapAndRegister account input-id input-amount output-id slippage kda-pid slippage-bounds bundle)
            )
            (with-capability
                (SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE account input-id input-amount output-id slippage bundle)
                (XI_SmartSwapAndRegister account input-id input-amount output-id slippage kda-pid slippage-bounds bundle)
            )
        )
    )
    (defun XI_SmartSwapAndRegister:list
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage} bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: C_SmartSwap's body, factored out so it runs entirely INSIDE \
            \ the caller's with-capability block (required for XI_RegisterBundlePaths' \
            \ own require-capability (SECURE) to see a granted capability — see \
            \ C_SmartSwap's doc for why this had to be restructured this way)."
        (require-capability (SECURE))
        (let*
            (
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (XI_SmartSwapExplicitRoute account input-id input-amount output-id slippage kda-pid slippage-bounds bundle)
                )
                (out:list (at "output" ico))
                ;;A slippage-exceeded soft-fail (matching CC_SmartSwap's own established
                ;;shape) returns a 1-element <output> ([exceed-message]) instead of the
                ;;successful [final-netto hops pools distinct-edges] 4-element shape — no
                ;;swap happened, so there's nothing to price or register, <stoa-results>
                ;;is [] and no registration call fires.
                (stoa-results:list
                    (if (= (length out) 4)
                        (URC_ComputeStoaValueResults (at 3 out) (at "stoa-paths" bundle))
                        []
                    )
                )
            )
            (if (= (length out) 4)
                (XI_RegisterBundlePaths output-id (at 3 out) bundle)
                "no registration — swap did not execute"
            )
            [ico stoa-results]
        )
    )
    (defun C_Swap:object{IgnisCollectorV1.OutputCumulator}
        (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @doc "Execute swap. When slippage != -1.0, slippage-bounds must be the pre-computed slippage object from quote time (e.g. UDC_SlippageObject); when slippage == -1.0, pass a dummy object (e.g. UDC_Slippage 0.0 0 0.0)."
        (UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
                (pp:string (ref-SWP::UR_PrimordialPool))
                (l:integer (length input-ids))
                (s-or-m:bool (if (= l 1) true false))
            )
            (if (= swpair pp)
                (if s-or-m
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE account swpair dsid slippage slippage-bounds)
                            (XI|KDA-PID_Swap account swpair dsid slippage kda-pid slippage-bounds)
                        )
                        (with-capability (SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE account swpair dsid slippage)
                            (XI|KDA-PID_Swap account swpair dsid slippage kda-pid slippage-bounds)
                        )
                    )
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE account swpair dsid slippage slippage-bounds)
                            (XI|KDA-PID_Swap account swpair dsid slippage kda-pid slippage-bounds)
                        )
                        (with-capability (SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE account swpair dsid slippage)
                            (XI|KDA-PID_Swap account swpair dsid slippage kda-pid slippage-bounds)
                        )
                    )
                )
                (if s-or-m
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|C>SINGL-SWAP-WITH-SLIPPAGE account swpair dsid slippage slippage-bounds)
                            (XI|KDA-PID_Swap account swpair dsid slippage -1.0 slippage-bounds)
                        )
                        (with-capability (SWPU|C>SINGL-SWAP-NO-SLIPPAGE account swpair dsid slippage)
                            (XI|KDA-PID_Swap account swpair dsid slippage -1.0 slippage-bounds)
                        )
                    )
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|C>MULTI-SWAP-WITH-SLIPPAGE account swpair dsid slippage slippage-bounds)
                            (XI|KDA-PID_Swap account swpair dsid slippage -1.0 slippage-bounds)
                        )
                        (with-capability (SWPU|C>MULTI-SWAP-NO-SLIPPAGE account swpair dsid slippage)
                            (XI|KDA-PID_Swap account swpair dsid slippage -1.0 slippage-bounds)
                        )
                    )
                )
            )
        )
    )
    ;;{F7}
    (defun XI_SmartSwapRouter:object{IgnisCollectorV1.OutputCumulator}
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage})
        @doc "Routes Smart Swap: performs slippage check using fee-less multi-hop output, then executes."
        (require-capability (SECURE))
        (let
            (
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (h-obj:object{SwapperIssueV3.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
                (nodes:[string] (at "nodes" h-obj))
                (edges:[string] (at "edges" h-obj))
                (ovs:[decimal] (at "output-values" h-obj))
                (feeless-final:decimal (at 0 (take -1 ovs)))
            )
            (if (!= slippage -1.0)
                (let
                    (
                        (min-max:[decimal] (UC_SlippageMinMax slippage-bounds))
                        (min:decimal (at 0 min-max))
                        (max:decimal (at 1 min-max))
                        (exceed-message:string
                            (format "Smart Swap Expected Output of {} out of Slippage bounds min of {} - max of {}" [feeless-final min max])
                        )
                    )
                    ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and` wrapper
                    ;;removed with it — Pact 5's `and` doesn't accept a single argument at
                    ;;runtime, confirmed the hard way via a real swap-execution test, not just
                    ;;load). Rejecting a swap for delivering MORE than quoted ("positive
                    ;;slippage") isn't how any major AMM works — checked Uniswap V2/V3, Curve,
                    ;;Balancer, SushiSwap, PancakeSwap: every one enforces a floor only on
                    ;;exact-input swaps, never a ceiling; several (CoW Protocol, UniswapX) are
                    ;;explicitly built to maximize/pass through favorable execution instead. To
                    ;;re-enable, restore `(and (>= feeless-final min) (<= feeless-final max))` —
                    ;;the `>= min` check below must never be touched, it's the real protection
                    ;;this whole check exists for.
                    (if
                        (>= feeless-final min)
                        ;;(<= feeless-final max)
                        (XI_SmartSwap account input-id input-amount output-id nodes edges kda-pid NO_PATH)
                        {"cumulator-chain"   :
                            [
                                {"ignis"        : 0.0
                                ,"interactor"   : BAR}
                            ]
                        ,"output"            : [exceed-message]}
                    )
                )
                (XI_SmartSwap account input-id input-amount output-id nodes edges kda-pid NO_PATH)
            )
        )
    )
    (defun XI_SmartSwapExplicitRoute:object{IgnisCollectorV1.OutputCumulator}
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage} bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8 — the bundle-based counterpart to XI_SmartSwapRouter: zero \
            \ internal searching. The route (structural connectivity, active-required, \
            \ depth-cap, correct endpoints) is already fully validated by the calling \
            \ defcap (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE) before this function ever runs — \
            \ matching this codebase's client-defcap-does-all-validation convention, this \
            \ XI_* does no enforce of its own. The feeless quote for the slippage floor \
            \ check is computed via URC_HopperForKnownRoute over the bundle's EXACT \
            \ edges (not a re-derived 'best' edge — see that function's own doc for why \
            \ this matters for keeping the quote and real execution consistent)."
        (require-capability (SECURE))
        (let
            (
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (nodes:[string] (at "nodes" (at "swap-route" bundle)))
                (edges:[string] (at "edges" (at "swap-route" bundle)))
                (h-obj:object{SwapperIssueV3.Hopper} (ref-SWPI::URC_HopperForKnownRoute nodes edges input-amount))
                (ovs:[decimal] (at "output-values" h-obj))
                (feeless-final:decimal (at 0 (take -1 ovs)))
            )
            (if (!= slippage -1.0)
                (let
                    (
                        (min-max:[decimal] (UC_SlippageMinMax slippage-bounds))
                        (min:decimal (at 0 min-max))
                        (max:decimal (at 1 min-max))
                        (exceed-message:string
                            (format "Smart Swap Expected Output of {} out of Slippage bounds min of {} - max of {}" [feeless-final min max])
                        )
                    )
                    ;;Same floor-only policy as XI_SmartSwapRouter (#26M/M9) — see that
                    ;;function's own comment for the full rationale, unchanged here.
                    (if
                        (>= feeless-final min)
                        (XI_SmartSwap account input-id input-amount output-id nodes edges kda-pid (at "boost-path" bundle))
                        {"cumulator-chain"   :
                            [
                                {"ignis"        : 0.0
                                ,"interactor"   : BAR}
                            ]
                        ,"output"            : [exceed-message]}
                    )
                )
                (XI_SmartSwap account input-id input-amount output-id nodes edges kda-pid (at "boost-path" bundle))
            )
        )
    )
    (defun XI_RegisterBundlePaths (output-id:string distinct-edges:[string] bundle:object{SwapperUsageV2.SmartSwapPathBundle})
        @doc "#34 Phase 8: cache self-warming — registers a bundle's <boost-path> and \
            \ each <stoa-paths> entry into SWPT|PathCache, ONLY when (a) the bundle \
            \ claims <is-new>=true AND (b) re-validated here from scratch (never trusting \
            \ the caller's claim — P3.1) AND (c), for stoa-paths, the first-token was \
            \ genuinely among THIS swap's own touched pools (URC_DedupFirstTokens of the \
            \ real <distinct-edges>, never blindly every entry a caller stuffed into the \
            \ bundle — matches P3.1's 'writes only as a side-effect of a real, validated, \
            \ USED path' rule, not just 'a real, validated path'). Registers via \
            \ SWPT::XE_RegisterPath (the forward-module writer, UEV_IMC + internal \
            \ SECURE composition) — never a caller-side grant of SWPT's own SECURE cap \
            \ directly (see XE_RegisterPath's own doc for why that would be unsafe). \
            \ XI_RegisterPath's own first-write-wins self-check makes every call here \
            \ safe to no-op on if another caller already won the race for the same pair."
        (require-capability (SECURE))
        (let*
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (lkda:string (ref-DALOS::UR_SilverStoaID))
                (dwk:string (ref-DALOS::UR_WrappedStoaID))
                (boost-path:object{CachedPathOrMiss} (at "boost-path" bundle))
                (boost-nodes:[string] (at "nodes" boost-path))
                (boost-edges:[string] (at "edges" boost-path))
                (boost-le:integer (length boost-nodes))
                (boost-eligible:bool
                    (if (or (not (at "is-new" boost-path)) (= boost-nodes [BAR]))
                        false
                        (fold (and) true
                            [
                                (ref-SWPI::URC_ValidatePathActive boost-nodes boost-edges)
                                (= (at 0 boost-nodes) output-id)
                                (= (at (- boost-le 1) boost-nodes) lkda)
                            ]
                        )
                    )
                )
            )
            (if boost-eligible
                (ref-SWPT::XE_RegisterPath output-id lkda boost-nodes boost-edges)
                "boost-path not registered (not new, invalid, or sentinel)"
            )
            (map
                (lambda (ft:string)
                    (let*
                        (
                            (path:object{CachedPathOrMiss} (UC_FindStoaPath (at "stoa-paths" bundle) ft))
                            (nodes:[string] (at "nodes" path))
                            (edges:[string] (at "edges" path))
                            (le:integer (length nodes))
                            (eligible:bool
                                (if (or (not (at "is-new" path)) (= nodes [BAR]))
                                    false
                                    (fold (and) true
                                        [
                                            (ref-SWPT::URC_ValidatePathStructure nodes edges)
                                            (= (at 0 nodes) ft)
                                            (= (at (- le 1) nodes) dwk)
                                        ]
                                    )
                                )
                            )
                        )
                        (if eligible
                            (ref-SWPT::XE_RegisterPath ft dwk nodes edges)
                            "stoa-path not registered (not new, invalid, or sentinel)"
                        )
                    )
                )
                (URC_DedupFirstTokens distinct-edges)
            )
        )
    )
    (defun XI_SmartSwap:object{IgnisCollectorV1.OutputCumulator}
        (
            account:string input-id:string input-amount:decimal output-id:string
            nodes:[string] edges:[string] kda-pid:decimal boost-path:object{SwapperUsageV2.CachedPathOrMiss}
        )
        @doc "Executes the multi-hop Smart Swap. Transfers input from user, delegates hop iteration \
            \ to XI_SmartSwapCore, handles kda-pid OURO price update, and returns final OutputCumulator. \
            \ #34 Phase 8: <boost-path> passthrough to XI_SmartSwapCore — NO_PATH sentinel from the \
            \ self-searching XI_SmartSwapRouter caller above, or a real bundle-supplied path from the \
            \ new dirty-read-injected XI_SmartSwapExplicitRoute caller. Shared unchanged by both — \
            \ nothing in this function searches for anything itself, so nothing here needed to change \
            \ beyond accepting and forwarding the one new parameter."
        (require-capability (SECURE))
        (let*
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                (pp:string (ref-SWP::UR_PrimordialPool))
                (ico-input:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::C_Transfer input-id account SWP|SC_NAME input-amount true)
                )
                (hop-result:list
                    (XI_SmartSwapCore account input-amount ico-input nodes edges boost-path)
                )
                (final-netto:decimal (at 0 hop-result))
                (all-icos:[object{IgnisCollectorV1.OutputCumulator}] (at 1 hop-result))
                (hops:integer (length edges))
                (distinct-edges:[string] (distinct edges))
                (pools:integer (length distinct-edges))
                (final-ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators all-icos [final-netto hops pools distinct-edges])
                )
            )
            (if (> kda-pid 0.0)
                (let
                    (
                        (iz-on-path:bool
                            (fold
                                (lambda (acc:bool edge:string) (or acc (= edge pp)))
                                false
                                edges
                            )
                        )
                    )
                    (if iz-on-path
                        (XI|KDA-PID_OPU pp kda-pid)
                        true
                    )
                )
                true
            )
            final-ico
        )
    )
    (defun XI_SmartSwapCore:list
        (
            account:string input-amount:decimal ico-input:object{IgnisCollectorV1.OutputCumulator}
            nodes:[string] edges:[string] boost-path:object{SwapperUsageV2.CachedPathOrMiss}
        )
        @doc "#34 Phase 8: <boost-path> — NO_PATH sentinel (self-searching caller, \
            \ XI_LiquidIndexPump searches internally as before) or a real bundle-supplied \
            \ id->DLK path (new dirty-read-injected caller) — passed through unchanged to \
            \ whichever XI_LiquidIndexPump call the last hop below fires (closure-captured \
            \ from this outer let, not threaded through the fold's own accumulator, since \
            \ it's a constant for the whole call, not something that varies per hop). \
            \ Iterates over all hops of a Smart Swap path. For each hop: computes fee-aware swap, fuels LP, \
            \ updates pool supplies, pays special targets, carries the Liquid Boost slice forward. \
            \ P0.6 direction 5 (SWP exhaustive-path-search HANDOFF doc): the Liquid Boost cut is no \
            \ longer priced-and-burned on every hop (6 independent full-graph searches on a 6-hop \
            \ route). Instead each hop converts the running carried amount into its own output token \
            \ via <SWPI::URC_Swap> over the SAME <swpair> edge the hop's real swap already used (raw, \
            \ fee-free curve math, no search), adds this hop's own boost cut, and passes the total \
            \ forward. Only the LAST hop actually prices-and-burns, via <XI_LiquidIndexPump>, against \
            \ the single accumulated total — one graph search per SmartSwap instead of one per hop. \
            \ This intentionally does NOT reproduce the old per-hop totals (it follows the swap's own \
            \ route instead of each hop's individually-best route to DLK) — acceptable since this is \
            \ internal index-pump accounting, not user-facing swap output. \
            \ Returns [final-netto all-icos-list ...] — callers (<XI_SmartSwap>) only read indices \
            \ 0/1; the fold's own accumulator carries further elements (running carried-boost, and \
            \ the batched special-fee-target lists below) that have already been fully consumed by \
            \ the last hop by the time the fold finishes. \
            \ Special-fee-target batching (owner's design, 2026-08-21, P0.6-adjacent — same \
            \ HANDOFF doc; rebuilt after the original worst-case test was found to never have \
            \ exercised this path at all, since <fee-special> defaulted to 0.0): every hop still \
            \ emits its own <SWPU|S>FEED-SPECIAL-TARGETS> event (the per-hop audit trail is \
            \ unchanged), but only the LAST hop pays it — every earlier hop's targets/amounts are \
            \ appended to a running list instead, and the whole batch is paid in ONE combined \
            \ multi-token <TFT::C_MultiBulkTransfer> fired on the last hop, alongside (not instead \
            \ of) that hop's own unchanged netto+targets payout."
        (require-capability (SECURE))
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                (le:integer (length edges))
            )
            (fold
                (lambda
                    (acc:list idx:integer)
                    (let*
                        (
                            (current-input:decimal (at 0 acc))
                            (acc-icos:[object{IgnisCollectorV1.OutputCumulator}] (at 1 acc))
                            (carried-boost-in:decimal (at 2 acc))
                            (sp-id-lst-in:[string] (at 3 acc))
                            (sp-receiver-arr-in:[[string]] (at 4 acc))
                            (sp-amount-arr-in:[[decimal]] (at 5 acc))
                            (i-id:string (at idx nodes))
                            (o-id:string (at (+ idx 1) nodes))
                            (swpair:string (at idx edges))
                            (iz-last:bool (= idx (- le 1)))
                            ;;
                            (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                            (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                            (A:decimal (ref-SWP::UR_Amplifier swpair))
                            (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                            (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                            (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair [i-id]))
                            (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair o-id))
                            (W:[decimal] (ref-SWP::UR_Weigths swpair))
                            (dsid:object{UtilitySwpV1.DirectSwapInputData}
                                (ref-U|SWP::UDC_DirectSwapInputData [i-id] [current-input] o-id)
                            )
                            (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                                (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                            )
                            (lp-fuel:[decimal] (at "lp-fuel" dtso))
                            (o-id-special:decimal (at "o-id-special" dtso))
                            (o-id-liquid:decimal (at "o-id-liquid" dtso))
                            (o-id-netto:decimal (at "o-id-netto" dtso))
                            ;;
                            (ico-fuel:object{IgnisCollectorV1.OutputCumulator}
                                (ref-SWPLC::C_Fuel account swpair lp-fuel false false)
                            )
                            (pt-amounts-after-fuel:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                            (dra:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [i-id] [current-input]))
                            (dra-o:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [o-id] [(fold (+) 0.0 [o-id-special o-id-liquid o-id-netto])]))
                            (remaining:[decimal] (zip (-) (zip (-) dra lp-fuel) dra-o))
                            (new-balances:[decimal] (zip (+) pt-amounts-after-fuel remaining))
                            ;;P0.6 direction 5: roll the running carried Liquid Boost amount
                            ;;(denominated in <i-id>, this hop's input token) forward into
                            ;;<o-id> terms over this SAME <swpair> edge, via raw fee-free
                            ;;curve math — no search, the edge is already known. Skipped when
                            ;;nothing has been carried yet (first hop, or Liquid Boost off).
                            (converted-carry:decimal
                                (if (= carried-boost-in 0.0)
                                    0.0
                                    (ref-SWPI::URC_Swap
                                        swpair
                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [carried-boost-in] o-id)
                                        false
                                    )
                                )
                            )
                            (carried-boost-out:decimal (+ converted-carry o-id-liquid))
                            ;;Special-fee-target batching: on every NON-last hop, still emit the
                            ;;SAME <SWPU|S>FEED-SPECIAL-TARGETS> event as before (unchanged
                            ;;per-hop audit trail) but don't pay yet — append <o-id>/its
                            ;;filtered targets+amounts to the running batch instead. [[] []]
                            ;;(no-op, nothing appended) whenever this hop has no special cut, or
                            ;;is the last hop (whose own targets stay handled by <ico-special>
                            ;;below, unchanged).
                            (sp-hop-targets:list
                                (if (and (!= o-id-special 0.0) (not iz-last))
                                    (let*
                                        (
                                            (o-prec:integer (at output-position X-prec))
                                            (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                            (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                            (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                            (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                            (f-targets:[string] (at 0 fsft))
                                            (f-amounts:[decimal] (at 1 fsft))
                                        )
                                        (with-capability (SWPU|S>FEED-SPECIAL-TARGETS o-id o-id-special f-targets target-proportions f-amounts)
                                            [f-targets f-amounts]
                                        )
                                    )
                                    [[] []]
                                )
                            )
                            (hop-f-targets:[string] (at 0 sp-hop-targets))
                            (hop-f-amounts:[decimal] (at 1 sp-hop-targets))
                            (sp-id-lst-out:[string]
                                (if (!= (length hop-f-targets) 0) (+ sp-id-lst-in [o-id]) sp-id-lst-in)
                            )
                            (sp-receiver-arr-out:[[string]]
                                (if (!= (length hop-f-targets) 0) (+ sp-receiver-arr-in [hop-f-targets]) sp-receiver-arr-in)
                            )
                            (sp-amount-arr-out:[[decimal]]
                                (if (!= (length hop-f-targets) 0) (+ sp-amount-arr-in [hop-f-amounts]) sp-amount-arr-in)
                            )
                            ;;Flush: fires ONLY on the last hop, ONE combined multi-token
                            ;;transfer covering every earlier hop's batched targets — the
                            ;;whole reason for the accumulator above. <sp-id-lst-in> (not
                            ;;-out) is correct here: this hop's own targets, if any, are
                            ;;handled separately by <ico-special> below, never appended.
                            (sp-flush:object{IgnisCollectorV1.OutputCumulator}
                                (if (and iz-last (!= (length sp-id-lst-in) 0))
                                    (ref-TFT::C_MultiBulkTransfer sp-id-lst-in SWP|SC_NAME sp-receiver-arr-in sp-amount-arr-in)
                                    EOC
                                )
                            )
                            ;;<ico-special> now only ever pays THIS hop's own targets+netto,
                            ;;and only on the last hop — unchanged from the pre-batching logic
                            ;;for that one case. Every non-last hop's targets are handled above
                            ;;instead (event now, payment deferred to <sp-flush>).
                            (ico-special:object{IgnisCollectorV1.OutputCumulator}
                                (if iz-last
                                    (if (!= o-id-special 0.0)
                                        (let*
                                            (
                                                (o-prec:integer (at output-position X-prec))
                                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                                (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                                (f-targets:[string] (at 0 fsft))
                                                (f-amounts:[decimal] (at 1 fsft))
                                                (retained:decimal (at 2 fsft))
                                                (adjusted-netto:decimal (+ o-id-netto retained))
                                            )
                                            (with-capability (SWPU|S>FEED-SPECIAL-TARGETS o-id o-id-special f-targets target-proportions f-amounts)
                                                (if (!= (length f-targets) 0)
                                                    (ref-TFT::C_MultiBulkTransfer
                                                        [o-id]
                                                        SWP|SC_NAME
                                                        [(+ [account] f-targets)]
                                                        [(+ [adjusted-netto] f-amounts)]
                                                    )
                                                    (ref-TFT::C_Transfer o-id SWP|SC_NAME account adjusted-netto true)
                                                )
                                            )
                                        )
                                        (ref-TFT::C_Transfer o-id SWP|SC_NAME account o-id-netto true)
                                    )
                                    EOC
                                )
                            )
                        )
                        (ref-SWP::XE_UpdateSupplies swpair new-balances)
                        [
                            o-id-netto
                            (+
                                acc-icos
                                [
                                    ico-fuel
                                    sp-flush
                                    ico-special
                                    ;;P0.6 direction 5: only the LAST hop actually prices-and-
                                    ;;burns, against the full accumulated <carried-boost-out> —
                                    ;;every earlier hop just carries it forward (above), no
                                    ;;search fired.
                                    (if (and iz-last (!= carried-boost-out 0.0))
                                        (XI_LiquidIndexPump o-id carried-boost-out boost-path)
                                        EOC
                                    )
                                ]
                            )
                            carried-boost-out
                            sp-id-lst-out
                            sp-receiver-arr-out
                            sp-amount-arr-out
                        ]
                    )
                )
                [input-amount [ico-input] 0.0 [] [] []]
                (enumerate 0 (- le 1))
            )
        )
    )
    (defun XI|KDA-PID_Swap:object{IgnisCollectorV1.OutputCumulator}
        (
            account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}
            slippage:decimal kda-pid:decimal slippage-bounds:object{SwapperUsageV2.Slippage}
        )
        @doc "Swap with optional slippage. When slippage != -1.0, min/max are taken from client-supplied slippage-bounds (computed off-chain at quote time), so the check reflects pool state at execution time."
        (let
            (
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (if (= slippage -1.0)
                        (XI_Swap account swpair dsid)
                        (let
                            (
                                (ref-SWPI:module{SwapperIssueV3} SWPI)
                                (max-toa:decimal 
                                    ;; Actual output at execution time (pool may have changed since quote)
                                    (ref-SWPI::URC_Swap swpair dsid true)
                                )
                                (min-max:[decimal] 
                                    ;; Bounds from client-supplied slippage object (quote time)
                                    (UC_SlippageMinMax slippage-bounds)
                                )
                                (min:decimal (at 0 min-max))
                                (max:decimal (at 1 min-max))
                                (exceed-message:string
                                    (format
                                        "Expected Output of {} out of Slippage bounds min of {} - max of {}"
                                        [max-toa min max]
                                    )
                                )
                            )
                            ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and`
                            ;;wrapper removed with it — Pact 5's `and` doesn't accept a single
                            ;;argument at runtime, confirmed the hard way via a real
                            ;;swap-execution test, not just load). Rejecting a swap for
                            ;;delivering MORE than quoted ("positive slippage") isn't how any
                            ;;major AMM works — checked Uniswap V2/V3, Curve, Balancer,
                            ;;SushiSwap, PancakeSwap: every one enforces a floor only on
                            ;;exact-input swaps, never a ceiling; several (CoW Protocol,
                            ;;UniswapX) are explicitly built to maximize/pass through favorable
                            ;;execution instead. To re-enable, restore
                            ;;`(and (>= max-toa min) (<= max-toa max))` — the `>= min` check
                            ;;below must never be touched, it's the real protection this whole
                            ;;check exists for.
                            ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and`
                            ;;wrapper removed with it — Pact 5's `and` doesn't accept a single
                            ;;argument at runtime, confirmed the hard way via a real
                            ;;swap-execution test, not just load). Rejecting a swap for
                            ;;delivering MORE than quoted ("positive slippage") isn't how any
                            ;;major AMM works — checked Uniswap V2/V3, Curve, Balancer,
                            ;;SushiSwap, PancakeSwap: every one enforces a floor only on
                            ;;exact-input swaps, never a ceiling; several (CoW Protocol,
                            ;;UniswapX) are explicitly built to maximize/pass through favorable
                            ;;execution instead. To re-enable, restore
                            ;;`(and (>= max-toa min) (<= max-toa max))` — the `>= min` check
                            ;;below must never be touched, it's the real protection this whole
                            ;;check exists for.
                            (if
                                (>= max-toa min)
                                ;;(<= max-toa max)
                                (XI_Swap account swpair dsid)
                                {"cumulator-chain"      :
                                    [
                                        {"ignis"        : 0.0
                                        ,"interactor"   : BAR}
                                    ]
                                ,"output"               : [exceed-message]}
                            )
                        )
                    )
                )
            )
            (if (> kda-pid 0.0)
                (XI|KDA-PID_OPU swpair kda-pid)
                true
            )
            ico
        )
    )
    (defun XI_Swap:object{IgnisCollectorV1.OutputCumulator}
        (account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (require-capability (SWPU|X>SWAP swpair dsid))
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                ;;
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                ;;Do Swap Computation and Unwrap Object Data
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                (o-id-special:decimal (at "o-id-special" dtso))
                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                (o-id-netto:decimal (at "o-id-netto" dtso))
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::C_MultiTransfer input-ids account SWP|SC_NAME input-amounts true)
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (ref-SWPLC::C_Fuel account swpair lp-fuel false false)
                )
                (pt-amounts-after-fuel-update:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (dra:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair input-ids input-amounts))
                (dra-o:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [output-id] [(fold (+) 0.0 [o-id-special o-id-liquid o-id-netto])]))
                (remaining-amounts-for-update:[decimal] (zip (-) (zip (-) dra lp-fuel) dra-o))
                (new-balances:[decimal] (zip (+) pt-amounts-after-fuel-update remaining-amounts-for-update))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (if (!= o-id-special 0.0)
                        (let*
                            (
                                (o-prec:integer (at output-position X-prec))
                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                (f-targets:[string] (at 0 fsft))
                                (f-amounts:[decimal] (at 1 fsft))
                                (retained:decimal (at 2 fsft))
                                (adjusted-netto:decimal (+ o-id-netto retained))
                            )
                            (with-capability (SWPU|S>FEED-SPECIAL-TARGETS output-id o-id-special f-targets target-proportions f-amounts)
                                (if (!= (length f-targets) 0)
                                    (ref-TFT::C_MultiBulkTransfer
                                        [output-id]
                                        SWP|SC_NAME
                                        [(+ [account] f-targets)]
                                        [(+ [adjusted-netto] f-amounts)]
                                    )
                                    (ref-TFT::C_Transfer output-id SWP|SC_NAME account adjusted-netto true)
                                )
                            )
                        )
                        (ref-TFT::C_Transfer output-id SWP|SC_NAME account o-id-netto true)
                    )
                )
            )
            ;;Execute Swap Exchange
            ;;1]Move all Input Tokens to SWP|SC_NAME via ico1
            ;;2]Fuel the <swpair> increasing LP Value, scaling with swpair <fee-lp> via ico2
            ;;3]Update <swpair> with the remaining Pool Token Amounts
            (ref-SWP::XE_UpdateSupplies swpair new-balances)
            ;;4]Handle Swap Client and Special Targets, if they exist, via ico3
            ;;5]Handle Liquid Boost via output-ico
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ico1 ico2 ico3
                    (if (!= o-id-liquid 0.0)
                        ;;#34 Phase 8: direct C_Swap has no bundle to source a boost-path
                        ;;from (that's a SmartSwap-only concept) — always the NO_PATH
                        ;;sentinel here, meaning "search internally", exactly matching
                        ;;this call's own pre-Phase-8 behavior unchanged.
                        (XI_LiquidIndexPump output-id o-id-liquid NO_PATH)
                        EOC
                    )
                ] 
                [o-id-netto]
            )
        )
    )
    (defun XI_LiquidIndexPump:object{IgnisCollectorV1.OutputCumulator}
        (id:string amount:decimal boost-path:object{SwapperUsageV2.CachedPathOrMiss})
        @doc "#34 Phase 8: <boost-path> passthrough — NO_PATH sentinel from the \
            \ self-searching caller, or a real bundle-supplied path from the new \
            \ dirty-read-injected caller. See XI_RawLiquidPump's doc for validation."
        (require-capability (SECURE))
        (let
            (
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (XI_RawLiquidPump id amount boost-path)
                )
                (raw-liquid-pump-data:list (at "output" ico))
            )
            ;;Bug fix, #34 (found while fixing XI_RawLiquidPump's own crash — that fix
            ;;makes it legitimately return EOC, whose "output" is [], when <id> has no
            ;;active route to DLK; this caller's own unguarded (at 0 ...) into that
            ;;empty list would then crash the same way, just one level up). Nothing to
            ;;pump/report when there's nothing there — skip the event+pumpdate, return
            ;;<ico> (EOC) as-is. XI_Pumpdate already tolerates non-5-length input safely
            ;;(its own length check), this guard just avoids indexing before reaching it.
            (if (= (length raw-liquid-pump-data) 0)
                ico
                (let
                    (
                        (increment:decimal (at 0 raw-liquid-pump-data))
                    )
                    (with-capability (SWPU|S>LIQUID-BOOST id amount increment)
                        (XI_Pumpdate raw-liquid-pump-data)
                    )
                    ico
                )
            )
        )
    )
    (defun XI_RawLiquidPump:object{IgnisCollectorV1.OutputCumulator}
        (id:string amount:decimal boost-path:object{SwapperUsageV2.CachedPathOrMiss})
        @doc "Operation that pumps LiquidIndex, returns the Pump Increment in the output object \
            \ Can be used for a Pool Token that already exists in the SWP|SC_NAME. \
            \ P0.6 fix (SWP exhaustive-path-search HANDOFF doc): routes via \
            \ <SWPI::URC_HopperActiveShortest> (single shortest BFS route), not \
            \ <URC_HopperActive> (best-of-3 alternate-route search) — this fires once \
            \ per SmartSwap hop, so the best-of-3 search's cost was being multiplied \
            \ by hop-count x 3 to price a residual fee slice that only needs *a* \
            \ valid route to DLK, not the optimal one. \
            \ #34 Phase 8: <boost-path> is NO_PATH (the [BAR]-nodes sentinel) for the \
            \ self-searching CC_SmartSwap caller (searches internally, as above) or a \
            \ real bundle-supplied id->DLK path for the new dirty-read-injected caller \
            \ (validated here — active-required, same standard <URC_HopperActiveShortest> \
            \ already enforced — before being trusted; an invalid or malformed supplied \
            \ path degrades to 'no boost pumped this time', same graceful EOC fallback \
            \ as a genuine no-route-found case, never a crash or an aborted swap)."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                ;;
                (lkda:string (ref-DALOS::UR_SilverStoaID))
                (liquidindex:string (at 0 (ref-DPTF::UR_RewardBearingToken lkda)))
                (lqi:decimal (ref-ATS::URC_Index liquidindex))
            )
            (if (= id lkda)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [(ref-DPTF::C_Burn lkda SWP|SC_NAME amount)]
                    [(- (ref-ATS::URC_Index liquidindex) lqi)]
                )
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV3} SWPI)
                        (is-sentinel:bool (= (at "nodes" boost-path) [BAR]))
                        ;;#34 Phase 8: a bundle-supplied path is never trusted blindly —
                        ;;re-validated active-required (structural connectivity + every
                        ;;edge can-swap=true) every single use, matching P3.1's "even a
                        ;;cache hit always re-validates" rule and this call's own
                        ;;pre-existing active-required standard. Also enforces the
                        ;;endpoints actually match this call's own <id>/<lkda> — a
                        ;;structurally-valid-but-wrong-pair path (e.g. leftover from a
                        ;;different hop) must never be silently accepted.
                        (is-valid-supplied:bool
                            (if is-sentinel
                                false
                                (and
                                    (ref-SWPI::URC_ValidatePathActive (at "nodes" boost-path) (at "edges" boost-path))
                                    (and
                                        (= (at 0 (at "nodes" boost-path)) id)
                                        (= (at (- (length (at "nodes" boost-path)) 1) (at "nodes" boost-path)) lkda)
                                    )
                                )
                            )
                        )
                        (h-obj:object{SwapperIssueV3.Hopper}
                            (if is-sentinel
                                (ref-SWPI::URC_HopperActiveShortest id lkda amount)
                                (if is-valid-supplied
                                    (ref-SWPI::URC_HopperForKnownRoute (at "nodes" boost-path) (at "edges" boost-path) amount)
                                    ;;Invalid/malformed supplied path — degrade to the
                                    ;;same empty-output-values shape a genuine
                                    ;;no-route-found search returns, so the existing
                                    ;;<(= (length ovs) 0)> EOC fallback below handles it
                                    ;;with zero new branching.
                                    {"nodes" : [], "edges" : [], "output-values" : []}
                                )
                            )
                        )
                        (path-to-lkda:[string] (at "nodes" h-obj))
                        (edges:[string] (at "edges" h-obj))
                        (ovs:[decimal] (at "output-values" h-obj))
                    )
                    ;;Bug fix, #34 (SWP exhaustive-path-search HANDOFF doc, flagged during
                    ;;P0.5, fixed now): <ovs> is legitimately empty whenever <id> has no
                    ;;*active* route to DLK at all (EMPTY_HOPPER's own output-values is
                    ;;[]) — the original `(at 0 (take -1 ovs))` crashed with an
                    ;;out-of-bounds error in that case instead of failing cleanly. A
                    ;;token with no route to DLK simply doesn't get its boost pumped this
                    ;;time (EOC, no burn) — not a corruption, not a lost swap, the rest of
                    ;;the transaction is unaffected. Adversarially proven (SWP|TX 032z5):
                    ;;reverted this fix, confirmed the exact "Array index out of bounds.
                    ;;Length (0), Index (0)" crash reproduces, restored. Phase 8: the same
                    ;;empty-<ovs> fallback now also covers an invalid bundle-supplied path
                    ;;(<is-valid-supplied>=false) — identical safe degrade, no new branch
                    ;;needed.
                    (if (= (length ovs) 0)
                        EOC
                        (let
                            (
                                (final-boost-output:decimal (at 0 (take -1 ovs)))
                                (ico:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-DPTF::C_Burn lkda SWP|SC_NAME final-boost-output)
                                )
                            )
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [ico]
                                [(- (ref-ATS::URC_Index liquidindex) lqi) path-to-lkda edges ovs amount]
                            )
                        )
                    )
                )
            )
        )
    )
    (defun XI_Pumpdate (raw-liquid-pump-data:list)
        (require-capability (SECURE))
        (if (= (length raw-liquid-pump-data) 5)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                    (path-to-dlk:[string] (at 1 raw-liquid-pump-data))
                    (edges:[string] (at 2 raw-liquid-pump-data))
                    (ovs:[decimal] (at 3 raw-liquid-pump-data))
                    (amount:decimal (at 4 raw-liquid-pump-data))
                    (le:integer (length edges))
                )
                (map
                    (lambda
                        (idx:integer)
                        (let
                            (
                                (first-id:string (at idx path-to-dlk))
                                (second-id:string (at (+ idx 1) path-to-dlk))
                                (hop:string (at idx edges))
                                (first-amount:decimal
                                    (if (= idx 0)
                                        amount
                                        (at (- idx 1) ovs)
                                    )
                                )
                                (second-amount:decimal (at idx ovs))
                                (f-id-hop-a:decimal (ref-SWP::UR_PoolTokenSupply hop first-id))
                                (s-id-hop-a:decimal (ref-SWP::UR_PoolTokenSupply hop second-id))
                            )
                            (ref-SWP::XE_UpdateSupply hop first-id (+ f-id-hop-a first-amount))
                            (ref-SWP::XE_UpdateSupply hop second-id (- s-id-hop-a second-amount))
                        )
                    )
                    (enumerate 0 (- le 1))
                )
            )
            true
        )
    )
    (defun XI|KDA-PID_OPU (swpair:string kda-pid:decimal)
        @doc "If <swpair> is primordial, <ouro-auto-price-via-swaps> is true, and \
            \ Ouro price moves more that 1 promile, update price"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (iz-auto:bool (ref-DALOS::UR_OuroAutoPriceUpdate))
            )
            (if iz-auto
                (let
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                        (ref-SWPI:module{SwapperIssueV3} SWPI)
                        (ouro-id:string (ref-DALOS::UR_OuroborosID))
                        (ouro-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                        (stored-ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                        (current-ouro-price:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                        (dev:decimal 0.001)
                        (min:decimal (floor (* stored-ouro-price (- 1.0 dev)) ouro-prec))
                        (max:decimal (floor (* stored-ouro-price (+ 1.0 dev)) ouro-prec))
                        (iz-update:bool
                            (if (or (< current-ouro-price min) (> current-ouro-price max))
                                true false
                            )
                        )
                    )
                    (if iz-update
                        (ref-DALOS::XB_UpdateOuroPrice current-ouro-price)
                        true
                    )
                )
                true
            )
        )
    )
)

(create-table P|T)
(create-table P|MT)