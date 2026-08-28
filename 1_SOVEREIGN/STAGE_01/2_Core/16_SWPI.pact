;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapperIssueV3
    @doc "Exposes SWP Issuing Functions. \
        \ Also contains Swap Computation Functions, and the Hopper Function. \
        \ V3: UEV_Issue and C_Issue use SwapperV3.PoolTokens (bumped when Swapper row types moved to SwapperV3)."
    ;;
    ;;
    ;;  SCHEMAS
    ;;
    (defschema Hopper
        nodes:[string]
        edges:[string]
        output-values:[decimal]    
    )
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal]))
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal))
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal]))
    (defun UC_VirtualSwap:object{UtilitySwpV1.VirtualSwapEngine} 
        (vse:object{UtilitySwpV1.VirtualSwapEngine} dsid:object{UtilitySwpV1.DirectSwapInputData})
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV1.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV1.DirectSwapInputData} fees:object{UtilitySwpV1.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV1.InverseTaxedSwapOutput}
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV1.ReverseSwapInputData} fees:object{UtilitySwpV1.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
    )
    (defun UC_BareboneSwap:decimal (pool-type:string drsi:object{UtilitySwpV1.DirectRawSwapInput}))
    (defun UC_BareboneInverseSwap:decimal (pool-type:string irsi:object{UtilitySwpV1.InverseRawSwapInput}))
    (defun UC_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_EliteFeeReduction:object{UtilitySwpV1.SwapFeez} (account:string fees:object{UtilitySwpV1.SwapFeez}))
    (defun URC_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    (defun URC_DirectRawSwapInput:object{UtilitySwpV1.DirectRawSwapInput} (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}))
    (defun URC_InverseRawSwapInput:object{UtilitySwpV1.InverseRawSwapInput} (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData}))
        ;;
    (defun URC_Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} validation:bool))
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}))
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}))
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}))
        ;;
    (defun URC_InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData} validation:bool))
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData}))
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData}))
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData}))
        ;;
    (defun URC_Hopper:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActive:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActiveShortest:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    ;;#65bL Phase 4: URC_Hopper, sourcing its graph from an ALREADY-FETCHED <raw-graph>
    ;;(SWPT::URC_FetchRawGraph) instead of URCX_Hopper's own self-fetch — lets a caller
    ;;doing MULTIPLE unrelated Hopper queries in the same transaction (e.g. the
    ;;STOA-repricing loop, one query per distinct pool touched) fetch the whole
    ;;topology's raw graph exactly ONCE and reuse it across every query, instead of
    ;;each query independently re-reading and rebuilding it.
    (defun URC_HopperFromRaw:object{Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal raw-graph:[object{SwapTracerV2.RawGraphNode}])
    )
    ;;#65bL Phase 7: URC_HopperFromRaw again, but sourcing its graph from an
    ;;ALREADY-BUILT [GraphNode] (SWPT::UC_MakeGraphFromRaw) instead of rebuilding it
    ;;from <raw-graph> on every call — the STOA-repricing loop's own
    ;;URC_HopperFromRaw/URCX_HopperFromRaw calls independently rebuilt the identical
    ;;graph structure once per distinct pool touched; this lets that shared build
    ;;happen once and be reused, same shape of win one layer deeper than Phase 4's
    ;;raw-graph sharing.
    (defun URC_HopperFromGraph:object{Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV1.GraphNode}]
        )
    )
    ;;#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery. Mirrors
    ;;URCX_Hopper (the shared internal core URC_Hopper/URC_HopperActive both wrap) but
    ;;calls SWPT::URC_ComputeAllRoutes instead of the K=3-capped
    ;;URC_ComputeAlternateRoutes, and — unlike the hidden-universe URC_Hopper/
    ;;URC_HopperActive public wrappers — exposes <swpairs>/<max-attempts> directly, so
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
    ;;walking the EXACT supplied edges — unlike URCX_HopperForNodes (used by the
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
    (defun URC_TokenDollarPrice (id:string kda-pid:decimal))
    (defun URC_SingleWorthDWK (id:string))
    (defun URC_WorthDWK (id:string amount:decimal))
    (defun URC_PoolValue:[decimal] (swpair:string))
    ;;#65bL Phase 4: URC_WorthDWK/URC_PoolValue, sourcing any graph search they need
    ;;via an ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch per call — see
    ;;URC_HopperFromRaw's own doc for the full rationale (repricing-loop sharing).
    (defun URC_WorthDWKFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV2.RawGraphNode}]))
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV2.RawGraphNode}]))
    ;;#65bL Phase 7: URC_WorthDWK/URC_PoolValue again, sourcing any graph search via
    ;;an ALREADY-BUILT [GraphNode] instead of rebuilding it from <raw-graph> per
    ;;call — see URC_HopperFromGraph's own doc for the full rationale.
    (defun URC_WorthDWKFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV1.GraphNode}]))
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV1.GraphNode}]))
        ;;
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal]))
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal]))
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal]))
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_SwapData (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData}))
    (defun UEV_InverseSwapData (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData}))
        ;;
    (defun UEV_Issue (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV1.DirectRawSwapInput} 
        (dsid:object{UtilitySwpV1.DirectSwapInputData} A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal])
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV1.InverseRawSwapInput} 
        (rsid:object{UtilitySwpV1.ReverseSwapInputData} A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal])
    )
    (defun UDC_Hopper:object{Hopper} (a:[string] b:[string] c:[decimal]))
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;
    ;;
    ;;  [X] Functions
    ;;
    ;;#36M/M5 fix: forward-module entrypoint for the shared pool-issuance write
    ;;sequence — SWPI's own C_Issue and MTX-SWP::MTX|C_Issue's Step 3 both call this
    ;;instead of each independently reimplementing the same mint/transfer/tracker
    ;;writes. Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
    ;;— a wider list, not an IgnisCollectorV1.OutputCumulator (matches this codebase's
    ;;XE_* convention: the forward module's own C_ composes IGNIS, not this function) —
    ;;so C_Issue can still aggregate every sub-call's own cumulator into its single
    ;;billed response exactly as before, while MTX|C_Issue (which already bills
    ;;separately in its own Step 2) can just take swpair/token-lp and ignore the rest.
    (defun XE_IssueWrite:list (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
)
;;
(module SWPI GOV
    ;;
    (implements OuronetPolicyV1)
    (implements SwapperIssueV3)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_SWPI           (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|SWPI_ADMIN)))
    (defcap GOV|SWPI_ADMIN ()       (enforce-guard GOV|MD_SWPI))
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
        (with-capability (GOV|SWPI_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|SWPI_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV1} SWP)
                (ref-P|SWPT:module{OuronetPolicyV1} SWPT)
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
    (defconst EMPTY_HOPPER
        [
            {
                "nodes" : [],
                "edges" : [],
                "output-values" : []
            }
        ]
    )
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    ;;#36M/M5 fix: named, single source of truth for the genesis LP mint amount —
    ;;was a bare 10000000.0 literal duplicated independently in both C_Issue and
    ;;MTX|C_Issue's own write sequences; now lives once, inside the shared
    ;;XE_IssueWrite both call.
    (defconst GENESIS_LP_SUPPLY     10000000.0)
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
    (defcap SWPI|C>ISSUE (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        (UEV_Issue account pool-tokens fee-lp weights amp p)
        (compose-capability (P|DT))
        (if p
            (compose-capability (GOV|SWPI_ADMIN))
            true
        )
    )
    ;;#36M/M5 fix: local cap for XE_IssueWrite (forward-module entrypoint) — no
    ;;checks of its own beyond UEV_IMC in the defun itself. Real validation
    ;;(UEV_Issue) already ran in whichever caller's own defcap got here first
    ;;(SWPI|C>ISSUE for C_Issue, or MTX-SWP's own Step 1) — this function only
    ;;performs the already-validated writes, matching the XE_* contract of no
    ;;enforce/UEV_* beyond UEV_IMC.
    (defcap SWPI|XE>ISSUE-WRITE (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        true
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal])
        @doc "Maximum Pool Deviation is (n-1)/n, and max allowed deviation for asymmetric liq is 40% of this value"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (l1:integer (length pool-reserves))
                (l2:integer (length asymmetric-liq))
                (l3:integer (length w))
                (iz-asymmetric:bool (contains 0.0 asymmetric-liq))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce iz-asymmetric "Invalid Values to Compute Deviation In Value Shares")
            (let
                (
                    (ref-U|VST:module{UtilityVstV1} U|VST)
                    (sw:decimal (fold (+) 0.0 w))
                    (iz-weigthed:bool (if (= sw 1.0) true false))
                    ;;
                    (initial-shares:[decimal] (UC_PoolShares pool-reserves w))
                    (asymmetric-shares:[decimal] (zip (*) initial-shares asymmetric-liq))
                    (new-total-shares:decimal (+ 5040000.0 (fold (+) 0.0 asymmetric-shares)))
                    (new-supply:[decimal] (zip (+) pool-reserves asymmetric-liq))
                    ;;
                    (aw:[decimal] (if iz-weigthed w (ref-U|VST::UC_SplitBalanceForVesting 24 1.0 l1)))
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun UC_VirtualSwap:object{UtilitySwpV1.VirtualSwapEngine} 
        (vse:object{UtilitySwpV1.VirtualSwapEngine} dsid:object{UtilitySwpV1.DirectSwapInputData})
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
                (F:object{UtilitySwpV1.SwapFeez} (at "F" vse))
                (fuel:[decimal] (at "fuel" vse))
                (special:[decimal] (at "special" vse))
                (boost:[decimal] (at "boost" vse))
                (swaps:[object{UtilitySwpV1.DirectSwapInputData}] (at "swaps" vse))
                ;;
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (input-positions:[integer] (UC_PoolTokenPositions swpair input-ids))
                (output-position:integer (at 0 (UC_PoolTokenPositions swpair [output-id])))
                ;;
                (swap-result:object{UtilitySwpV1.DirectTaxedSwapOutput}
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
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV1.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV1.DirectSwapInputData} fees:object{UtilitySwpV1.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
        @doc "Performs a Direct Swap with Fees Computation, outputing results in an object{UtilitySwpV1.DirectTaxedSwapOutput} \
            \ Given proper inputs, can be used for an actual Swap Functions, to save redundant code."
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV1.SwapFeez} (URC_EliteFeeReduction account fees))
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
                (dsid-for-swap:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts-for-swap output-id)
                )
                (drsi:object{UtilitySwpV1.DirectRawSwapInput}
                    (UDC_DirectRawSwapInput dsid-for-swap A X input-positions output-position weights)
                )
                (input-amounts-for-lp:[decimal] (zip (-) input-amounts input-amounts-for-swap))
                (input-amounts-for-lp-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts-for-lp))
                ;;
                ;;Total-Swap-Output-Amount <tsoa> is computed without them, then splited into 3 parts: 
                ;;special, boost, remainder
                (tsoa:decimal (UC_BareboneSwap pool-type drsi))
                (special:decimal (floor (* (/ f2 fselp) tsoa) o-prec))
                (boost:decimal (floor (* (/ f3 fselp) tsoa) o-prec))
                (remainder:decimal (- tsoa (+ special boost)))
                (output:object{UtilitySwpV1.DirectTaxedSwapOutput}
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
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV1.InverseTaxedSwapOutput}
        
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV1.ReverseSwapInputData} fees:object{UtilitySwpV1.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
        @doc "Performs a Reverse Swap with Fees Computation, outputing results in an object{UtilitySwpV1.InverseTaxedSwapOutput} \
            \ Use Case is displaying Input Amounts for a Swap when the desired Output Amount of a Token is entered first. \
            \ However not only the input required can be displayed, but also the susequent fees that would be incurred"
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV1.SwapFeez} (URC_EliteFeeReduction account fees))
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
                (new-rsid:object{UtilitySwpV1.ReverseSwapInputData} 
                    (ref-U|SWP::UDC_ReverseSwapInputData output-id tsoa input-id)
                )
                (irsi:object{UtilitySwpV1.InverseRawSwapInput}
                    (UDC_InverseRawSwapInput new-rsid A X output-position input-position weights)
                )
                ;;Now Compute the Input Amount needed to get the <tsoa>, the Partial-Input-Amount <pia>
                ;;<pia> is part of the TotalInputAmount, that would be used for a direct swap, after LP fees have been retained
                (pia:decimal (UC_BareboneInverseSwap pool-type irsi))
                ;;Now Compute the Total-Input-Amouant <tia>
                (tia:decimal (floor (/ (* 1000.0 pia) (- 1000.0 f1)) i-prec))
                (output:object{UtilitySwpV1.InverseTaxedSwapOutput}
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
    (defun UC_BareboneSwap:decimal
        (pool-type:string drsi:object{UtilitySwpV1.DirectRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
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
        (pool-type:string irsi:object{UtilitySwpV1.InverseRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UC_ComputeInverseY irsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeInverseWP irsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeInverseEP irsi))
                -1.0
            )
        )
    )
    (defun UC_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        @doc "Same result as <URC_PoolTokenPositions> but being done without reading <swpair> data \
        \ Result is simply computed, through the <swpair> string"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::UC_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    (defun URC_EliteFeeReduction:object{UtilitySwpV1.SwapFeez} (account:string fees:object{UtilitySwpV1.SwapFeez})
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    (defun URC_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-SWP:module{SwapperV3} SWP)
                (pool-tokens (ref-SWP::UR_PoolTokens swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::UR_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    ;;
    (defun URC_DirectRawSwapInput:object{UtilitySwpV1.DirectRawSwapInput}
        (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                input-amounts 
                (URC_PoolTokenPositions swpair input-ids)
                (ref-SWP::UR_PoolTokenPosition swpair output-id)
                (ref-DPTF::UR_Decimals output-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    (defun URC_InverseRawSwapInput:object{UtilitySwpV1.InverseRawSwapInput}
        (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                output-amount
                (ref-SWP::UR_PoolTokenPosition swpair output-id)
                (ref-SWP::UR_PoolTokenPosition swpair input-id)
                (ref-DPTF::UR_Decimals input-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    ;;
    (defun URC_Swap:decimal 
        (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
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
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputeY
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Weigthed Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputeWP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputeEP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_InverseSwap:decimal
        (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
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
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseY
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputedInverseWP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseEP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    ;;
    (defun URCX_HopperForNodes:object{SwapperIssueV3.Hopper}
        (nodes:[string] hopper-input-amount:decimal swpairs:[string])
        @doc "Computes the Hopper object (best per-hop edge + accumulated output) for \
            \ an ALREADY-KNOWN <nodes> path. Split out of <URCX_Hopper> (#34M/M2 fix) \
            \ so the identical per-hop best-edge computation can be run once per \
            \ candidate route in <URCX_Hopper>'s best-of-K comparison, not just the \
            \ single first-found route. Computes: \
            \ 1] The hops along <nodes>, the <edges> as the highest-output edge from all available \
            \ #49L fix: was 'cheapest available edge' — backwards framing (C1/#6C's own fix made \
            \ this maximize output among parallel pools, not minimize cost) \
            \ 2] The best <output> values using said best <edges>, given the <hopper-input-amount>"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (if (!= nodes [BAR])
                (let
                    (
                        (fl:[object{SwapperIssueV3.Hopper}]
                            (fold
                                (lambda
                                    (acc:[object{SwapperIssueV3.Hopper}] idx:integer)
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
                                                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                                                    (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                )
                                                (output:decimal (URC_Swap best-edge dsid false))
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
    (defun URC_HopperForKnownRoute:object{SwapperIssueV3.Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
        @doc "#34 Phase 8: like URCX_HopperForNodes, computes the feeless per-hop output \
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                    (le:integer (length edges))
                )
                (if (= le 0)
                    (UDC_Hopper nodes [] [])
                    (let
                        (
                            (fl:[object{SwapperIssueV3.Hopper}]
                                (fold
                                    (lambda
                                        (acc:[object{SwapperIssueV3.Hopper}] idx:integer)
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
                                                    (dsid:object{UtilitySwpV1.DirectSwapInputData}
                                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                    )
                                                    (output:decimal (URC_Swap swpair dsid false))
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
    (defun UC_BestHopper:object{SwapperIssueV3.Hopper} (candidates:[object{SwapperIssueV3.Hopper}])
        @doc "Picks the candidate Hopper with the highest final output value. \
            \ <candidates> must be non-empty (caller's responsibility — <URCX_Hopper> \
            \ only calls this once it has confirmed at least one route was found)."
        (if (<= (length candidates) 1)
            (at 0 candidates)
            (fold
                (lambda
                    (best:object{SwapperIssueV3.Hopper} idx:integer)
                    (let
                        (
                            (candidate:object{SwapperIssueV3.Hopper} (at idx candidates))
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
    (defun URCX_Hopper:object{SwapperIssueV3.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string])
        @doc "Shared Hopper-computation core for <URC_Hopper>/<URC_HopperActive> — \
            \ identical in every respect except which <swpairs> universe routing \
            \ is allowed to consider. Internal only, not on <SwapperIssueV3>. \
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
            \ CAVEAT, worth stating plainly: URCX_HopperForNodes's own per-hop \
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
            \ URCX_HopperForNodes regardless of where the node-path came from — a \
            \ cache hit only changes WHICH nodes get tried, never how an edge gets \
            \ picked or validated. On a miss (or a stale entry, topology-version \
            \ behind current), falls through to the unchanged live search."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list at all — the Tracer's
                ;;storage is principal-agnostic (SwapTracerV2).
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (cached:object{SwapTracerV2.PathCacheRow}
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
                        (candidates:[object{SwapperIssueV3.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCX_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCX_HopperFromRaw:object{SwapperIssueV3.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] raw-graph:[object{SwapTracerV2.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URCX_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> (<SWPT::URC_FetchRawGraph>) instead of \
            \ letting <SWPT::URC_ComputeGraphPathFromRaw> fetch its own — for a caller \
            \ making MULTIPLE unrelated Hopper queries in one transaction (the \
            \ STOA-repricing loop: one query per distinct pool touched, each to a \
            \ different first-token but the SAME destination, DWK) who fetches the \
            \ whole topology's raw graph exactly ONCE and reuses it across every \
            \ query. Safe because <SWPT::UC_MakeGraphNodes> (the node-universe \
            \ derivation both the fetch and every query rely on) is <input>/<output>- \
            \ independent by construction — it derives every token appearing across \
            \ the full <swpairs> list, regardless of which specific pair is being \
            \ queried — so ONE raw-graph fetched against a given <swpairs> universe \
            \ is valid for EVERY query against that same universe, not just the one \
            \ it happened to be fetched for. Still checks SWPT|PathCache first, \
            \ identically to <URCX_Hopper> — a cache hit is even cheaper than a \
            \ shared-raw-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutesFromRaw> \
            \ — see <URCX_Hopper>'s own doc for the full measured rationale (identical \
            \ here, same shared decision)."
        (let
            (
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (cached:object{SwapTracerV2.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCX_Hopper's own comment
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
                        (candidates:[object{SwapperIssueV3.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCX_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCX_HopperFromGraph:object{SwapperIssueV3.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] graph:[object{BreadthFirstSearchV1.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URCX_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> (<SWPT::UC_MakeGraphFromRaw>) instead of \
            \ rebuilding it from <raw-graph> on every call — see \
            \ <URC_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing, one layer deeper than Phase 4's raw-graph \
            \ sharing). Still checks SWPT|PathCache first, identically to \
            \ <URCX_Hopper>/<URCX_HopperFromRaw> — a cache hit is even cheaper than \
            \ a shared-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too."
        (let
            (
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (cached:object{SwapTracerV2.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCX_Hopper's own comment
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
                        (candidates:[object{SwapperIssueV3.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCX_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_HopperExhaustive:object{SwapperIssueV3.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] max-attempts:integer
        )
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not URCX_Hopper's fixed best-of-3 approximation. Identical shape to \
            \ URCX_Hopper (route-then-price-then-pick-best) but sources candidate \
            \ node-paths from SWPT::URC_ComputeAllRoutes (a real parameterized search \
            \ up to <max-attempts>, P0.2's flat +1000 caller-side escalation pattern \
            \ and P0.2/P0.4's outer-hard-stop/depth-cap already enforced inside that \
            \ function) instead of the K=3-capped URC_ComputeAlternateRoutes. Reuses \
            \ URCX_HopperForNodes (per-candidate feeless value) and UC_BestHopper (pick \
            \ the genuinely highest-output candidate, P1.8's requirement — never by hop \
            \ count as a proxy for cost) completely unchanged; no new value-computation \
            \ logic needed, same division of labor URCX_Hopper already established. \
            \ Exposes <swpairs> directly (unlike the hidden-universe URC_Hopper/ \
            \ URC_HopperActive public wrappers) so a caller picks the routing universe \
            \ explicitly — active-only for real swap discovery, or any subset for \
            \ Phase 12's varying-scale measurement (P2.1). Off-chain dirty-read use \
            \ only — never call this from a paid transaction, that defeats the entire \
            \ point of the #34/#34M redesign."
        (let
            (
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (routes:[[string]]
                    (ref-SWPT::URC_ComputeAllRoutes hopper-input-id hopper-output-id swpairs max-attempts)
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV3.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCX_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_Hopper:object{SwapperIssueV3.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Creates a Hopper Object routed over the FULL swpair universe, \
            \ including <can-swap>=false pools. Used internally for issuance-time \
            \ pricing (<URC_WorthDWK>, <UEV_Issue>'s principal-anchoring check), \
            \ which must work even when neighboring pools aren't swap-enabled yet. \
            \ Live swap-execution/quote callers must use <URC_HopperActive> \
            \ instead (#19H) — routing a real user swap over disabled pools is \
            \ the exact bug that fix closes."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (URCX_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs))
        )
    )
    (defun URC_HopperFromRaw:object{SwapperIssueV3.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            raw-graph:[object{SwapTracerV2.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URC_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — see \
            \ <URCX_HopperFromRaw>'s own doc for the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (URCX_HopperFromRaw hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) raw-graph)
        )
    )
    (defun URC_HopperFromGraph:object{SwapperIssueV3.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV1.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URC_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> instead of rebuilding it from \
            \ <raw-graph> on every call — see <URCX_HopperFromGraph>'s own doc for \
            \ the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (URCX_HopperFromGraph hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) graph)
        )
    )
    (defun URC_HopperActive:object{SwapperIssueV3.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Live-swap-execution routing entrypoint — restricts BFS routing to \
            \ <can-swap>=true pools only, so a disabled pool can never be \
            \ BFS-selected and then rejected downstream with no fallback (#19H). \
            \ Used by SWPU's actual swap-execution and slippage-quote call sites."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (URCX_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_ActiveSwpairs))
        )
    )
    (defun URC_HopperActiveShortest:object{SwapperIssueV3.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Lightweight Hopper routing over <can-swap>=true pools only — a single \
            \ shortest BFS route (<SWPT::URC_ComputeGraphPath>), never the best-of-3 \
            \ alternate-route search <URC_HopperActive> runs (P0.6, SWP exhaustive- \
            \ path-search HANDOFF doc). Built for <SWPU::XI_RawLiquidPump>'s Liquid \
            \ Boost pump: that call only needs *a* valid route to DLK to price a \
            \ small residual fee slice for burning, not the *optimal* one — but it \
            \ fires once per SmartSwap hop, so routing it through the same up-to-3x \
            \ alternate-route search real swap execution uses multiplies cost by \
            \ hop-count x 3 for no pricing benefit worth the gas. Do not use this for \
            \ any live user-facing quote/execution path — those must keep using \
            \ <URC_HopperActive> so users still get the best available route."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPT:module{SwapTracerV2} SWPT)
                (swpairs:[string] (ref-SWP::URC_ActiveSwpairs))
                (nodes:[string]
                    (ref-SWPT::URC_ComputeGraphPath hopper-input-id hopper-output-id swpairs)
                )
            )
            (URCX_HopperForNodes nodes hopper-input-amount swpairs)
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
        (let ((ref-SWPT:module{SwapTracerV2} SWPT))
            (if (not (ref-SWPT::URC_ValidatePathStructure nodes edges))
                false
                (if (= (length edges) 0)
                    true
                    (let ((ref-SWP:module{SwapperV3} SWP))
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
    (defun URCX_BestEdgeOf:string (ia:decimal i:string o:string edges:[string])
        @doc "Shared best-edge-selection core for <URC_BestEdge>/<URC_BestEdgeFiltered> \
            \ — identical in every respect except which <edges> candidate list is \
            \ passed in. Internal only, not on the interface."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (svl:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (URC_Swap (at idx edges) (ref-U|SWP::UDC_DirectSwapInputData [i] [ia] o) false)
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
                (ref-SWPT:module{SwapTracerV2} SWPT)
            )
            (URCX_BestEdgeOf ia i o (ref-SWPT::URC_Edges i o))
        )
    )
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string])
        @doc "Best edge restricted to swpairs also present in <swpairs> — used by \
            \ <URCX_Hopper> so a disabled parallel pool between the same token \
            \ pair is never selected as the executed hop, even when an active \
            \ parallel pool exists between the same two tokens (#19H)."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV2} SWPT)
            )
            (URCX_BestEdgeOf ia i o (ref-SWPT::URC_EdgesActive i o swpairs))
        )
    )
    ;;Value Computations
    (defun URC_OuroPrimordialPrice:decimal ()
        (let
            (
                (ref-U|CT|DIA:module{DiaKdaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (primordial:string (ref-SWP::UR_PrimordialPool))
                (pts:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial))
                (kda-pid:decimal (ref-U|CT|DIA::UR|KDA-PID))
                ;;
                (lkda:string (ref-DALOS::UR_SilverStoaID))
                (lkda-supply:decimal (at 0 pts))
                (ouro-supply:decimal (at 1 pts))
                (wkda-supply:decimal (at 2 pts))
                ;;
                (lkda-prec:integer (ref-DPTF::UR_Decimals lkda))
                (lkda-in-wkda:decimal (URC_SingleWorthDWK lkda))
                (lkda-in-wkda-value (floor (* lkda-supply lkda-in-wkda) lkda-prec))
                (primordial-wkda-value:decimal (+ wkda-supply lkda-in-wkda-value))
                (primordial-wkda-value-in-dollarz:decimal (floor (* primordial-wkda-value kda-pid) 24))
            )
            (floor (/ primordial-wkda-value-in-dollarz ouro-supply) 24)
        )
    )
    (defun URC_TokenDollarPrice (id:string kda-pid:decimal)
        @doc "Retrieves Token Price in Dollars, via DIA Oracle that outputs KDA Price"
        ;;<kda-pid> or <kda-price-in-dollars> can be retrieved prior to the function call with:
        ;;(at "value" (n_bfb76eab37bf8c84359d6552a1d96a309e030b71.dia-oracle.get-value "KDA/USD"))
        ;;This function is structured like this, to allow price retrieval from any source.
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (id-in-kda:decimal (URC_SingleWorthDWK id))
                (id-precision:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* id-in-kda kda-pid) id-precision)
        )
    )
    (defun URC_SingleWorthDWK (id:string)
        (URC_WorthDWK id 1.0)
    )
    (defun URC_WorthDWK (id:string amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (dwk:string (ref-DALOS::UR_WrappedStoaID))
                (dlk:string (ref-DALOS::UR_SilverStoaID))
            )
            (if (= id dwk)
                amount
                (if (= id dlk)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                            (ref-ATS:module{AutostakeV2} ATS)
                            (ats-pairs-with-dlk-id:[string] (ref-DPTF::UR_RewardBearingToken dlk))
                            (kdaliquindex:string (at 0 ats-pairs-with-dlk-id))
                            (index-value:decimal (ref-ATS::URC_Index kdaliquindex))
                            (dlk-prec:integer (ref-DPTF::UR_Decimals dlk))
                        )
                        (floor (* amount index-value) dlk-prec)
                    )
                    (let
                        (
                            (h-obj:object{SwapperIssueV3.Hopper} (URC_Hopper id dwk amount))
                            (ovs:[decimal] (at "output-values" h-obj))
                        )
                        (if (= (length ovs) 0)
                            0.0
                            (at 0 (take -1 ovs))
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthDWKFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV2.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_WorthDWK>, sourcing any graph search it needs \
            \ via an ALREADY-FETCHED <raw-graph> (<URC_HopperFromRaw>) instead of a \
            \ fresh self-fetch — see <URCX_HopperFromRaw>'s own doc for the full \
            \ rationale (repricing-loop sharing). The DWK/DLK short-circuit branches \
            \ never needed a graph search to begin with and stay unchanged."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (dwk:string (ref-DALOS::UR_WrappedStoaID))
                (dlk:string (ref-DALOS::UR_SilverStoaID))
            )
            (if (= id dwk)
                amount
                (if (= id dlk)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                            (ref-ATS:module{AutostakeV2} ATS)
                            (ats-pairs-with-dlk-id:[string] (ref-DPTF::UR_RewardBearingToken dlk))
                            (kdaliquindex:string (at 0 ats-pairs-with-dlk-id))
                            (index-value:decimal (ref-ATS::URC_Index kdaliquindex))
                            (dlk-prec:integer (ref-DPTF::UR_Decimals dlk))
                        )
                        (floor (* amount index-value) dlk-prec)
                    )
                    (let
                        (
                            (h-obj:object{SwapperIssueV3.Hopper} (URC_HopperFromRaw id dwk amount raw-graph))
                            (ovs:[decimal] (at "output-values" h-obj))
                        )
                        (if (= (length ovs) 0)
                            0.0
                            (at 0 (take -1 ovs))
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthDWKFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV1.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_WorthDWK>, sourcing any graph search it needs \
            \ via an ALREADY-BUILT <graph> (<URC_HopperFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call — see \
            \ <URCX_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing). The DWK/DLK short-circuit branches never \
            \ needed a graph search to begin with and stay unchanged."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (dwk:string (ref-DALOS::UR_WrappedStoaID))
                (dlk:string (ref-DALOS::UR_SilverStoaID))
            )
            (if (= id dwk)
                amount
                (if (= id dlk)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                            (ref-ATS:module{AutostakeV2} ATS)
                            (ats-pairs-with-dlk-id:[string] (ref-DPTF::UR_RewardBearingToken dlk))
                            (kdaliquindex:string (at 0 ats-pairs-with-dlk-id))
                            (index-value:decimal (ref-ATS::URC_Index kdaliquindex))
                            (dlk-prec:integer (ref-DPTF::UR_Decimals dlk))
                        )
                        (floor (* amount index-value) dlk-prec)
                    )
                    (let
                        (
                            (h-obj:object{SwapperIssueV3.Hopper} (URC_HopperFromGraph id dwk amount graph))
                            (ovs:[decimal] (at "output-values" h-obj))
                        )
                        (if (= (length ovs) 0)
                            0.0
                            (at 0 (take -1 ovs))
                        )
                    )
                )
            )
        )
    )
    (defun URC_PoolValue:[decimal] (swpair:string)
        @doc "Outputs the Pool Value in DWK. \
            \ If the Pool is empty, even though its value is technically zero, \
            \ The Value of the Genesis Initiation is outputed \
            \ PoolValue includes two decimal values: \
            \ 1st Value: Total Value of the Pool in DWK \
            \ 2nd Value: Value of 1 LP Token in DWK"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
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
                (first-worth:decimal (URC_WorthDWK first-token first-token-supply))
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
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV2.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_PoolValue>, sourcing its <URC_WorthDWK> call via \
            \ an ALREADY-FETCHED <raw-graph> (<URC_WorthDWKFromRaw>) instead of a \
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
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
                (first-worth:decimal (URC_WorthDWKFromRaw first-token first-token-supply raw-graph))
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
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV1.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_PoolValue>, sourcing its <URC_WorthDWK> call via \
            \ an ALREADY-BUILT <graph> (<URC_WorthDWKFromGraph>) instead of \
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
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
                (first-worth:decimal (URC_WorthDWKFromGraph first-token first-token-supply graph))
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-SWP:module{SwapperV3} SWP)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-SWP:module{SwapperV3} SWP)
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
    ;;{F2}  [UEV]
    (defun UEV_SwapData 
        (swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (ref-SWP:module{SwapperV3} SWP)
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
        (swpair:string rsid:object{UtilitySwpV1.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (t1:bool (contains input-id pool-tokens))
                (t2:bool (contains output-id pool-tokens))
            )
            (enforce (and t1 t2) "Invalid Pool Tokens")
            (ref-DPTF::UEV_Amount output-id output-amount)
        )
    )
    (defun UEV_Issue
        (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
            ;;#34bM fix: was checking multi-hop BFS connectivity to DLK specifically
            ;;(SWPT::URC_Hopper, unbounded hop count, one hardcoded target token) —
            ;;owner's actual design: if a Stable Pool's first Token isn't itself a
            ;;Principal, it must be DIRECTLY pooled (one hop, an existing pool) with
            ;;ANY current Principal — not transitively connected through a chain of
            ;;non-Principal tokens, and not specifically DLK. Fixed to check the
            ;;first Token's direct neighbours (SWPT::URC_TokenNeighbours, one hop,
            ;;every existing pool regardless of type) against the full current
            ;;<principals> list.
            (if (and (> amp 0.0) (not contains-principals))
                (let
                    (
                        (ref-SWPT:module{SwapTracerV2} SWPT)
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
                        (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                        (pt-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                        (first-pool-token-amount:decimal (at 0 pt-amounts))
                        (prefix:string (ref-U|SWP::UC_Prefix weights amp))
                        (how-many:integer (length pool-tokens))
                        ;;
                        (first-worth:decimal (URC_WorthDWK first-pool-token first-pool-token-amount))
                        (pool-worth-with-input-tokens-in-dwk:decimal
                            (if (or (= prefix "S") (= prefix "P"))
                                (* (dec how-many) first-worth)
                                (/ first-worth (at 0 weights))
                            )
                        )
                        (spawn-limit:decimal (ref-SWP::UR_SpawnLimit))
                    )
                    (enforce (>= pool-worth-with-input-tokens-in-dwk spawn-limit) "More liquidity is needed to open a new pool!")
                )
                true
            )
            (format "Validation prior to pool creation executed succesfully {}" ["!"])
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV1.DirectRawSwapInput}
        (
            dsid:object{UtilitySwpV1.DirectSwapInputData}
            A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV1.InverseRawSwapInput}
        (
            rsid:object{UtilitySwpV1.ReverseSwapInputData}
            A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    (defun UDC_Hopper:object{SwapperIssueV3.Hopper} (a:[string] b:[string] c:[decimal])
        {"nodes"            : a
        ,"edges"            : b
        ,"output-values"    : c}
    )
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    (defun A_RebuildGraph ()
        @doc "One-time migration/backfill utility (#21H). Rebuilds SWPT's adjacency \
            \ graph (SwapTracerV2) from every currently-existing swpair \
            \ (SWP::URC_Swpairs()), by calling SWPT::XE_UpdateGraph exactly as normal \
            \ issuance already does — just once per EXISTING pool instead of once for \
            \ a newly-issued one. Lives here rather than in SWPT itself because SWPT \
            \ deploys before SWP in this codebase's deploy order and can't hold a \
            \ compile-time reference to SwapperV3; SWPI already deploys after both and \
            \ is already a legitimate XE_UpdateGraph caller (C_Issue uses the same \
            \ call). XE_UpdateGraph's own writes are idempotent (XI_UpdatePair only \
            \ appends a swpair if not already present), so this is safe to re-run — \
            \ pools issued after this upgrade (which already populate the graph \
            \ directly at issuance) are a no-op here. Intended to be run exactly once \
            \ by an admin immediately after deploying the #21H architecture change, to \
            \ backfill every pool that was issued under the old, now-removed \
            \ principal-keyed SWPT|Tracer storage."
        (with-capability (GOV|SWPI_ADMIN)
            ;;XE_UpdateGraph's own UEV_IMC checks that P|SWPI|CALLER (the guard SWPI
            ;;registers with SWPT via P|A_Define) is actively composed — true when
            ;;reached via C_Issue's cap chain (SWPI|C>ISSUE -> P|DT), not true by
            ;;default just because this code happens to live in SWPI's module.
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-SWP:module{SwapperV3} SWP)
                        (ref-SWPT:module{SwapTracerV2} SWPT)
                    )
                    (map (lambda (sp:string) (ref-SWPT::XE_UpdateGraph sp)) (ref-SWP::URC_Swpairs))
                )
            )
        )
    )
    ;;{F6}  [C]
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Issues a new SWPair (Liquidty Pool). \
            \ #36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in \
            \ the shared XE_IssueWrite — MTX-SWP::MTX|C_Issue's own Step 3 calls the same \
            \ function instead of independently reimplementing it. This function still \
            \ owns all of ITS OWN IGNIS billing/aggregation (MTX|C_Issue bills separately, \
            \ in its own Step 2, before Step 3 ever runs)."
        (UEV_IMC)
        (with-capability (SWPI|C>ISSUE account pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (kda-dptf-cost:decimal (ref-DALOS::UR_UsagePrice "dptf"))
                    (kda-swp-cost:decimal (ref-DALOS::UR_UsagePrice "swp"))
                    (kda-costs:decimal (+ kda-dptf-cost kda-swp-cost))
                    (gas-swp-cost:decimal (ref-DALOS::UR_UsagePrice "ignis|swp-issue"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (write-result:list (XE_IssueWrite account pool-tokens fee-lp weights amp p))
                    (swpair:string (at 0 write-result))
                    (token-lp:string (at 1 write-result))
                    (ico1:object{IgnisCollectorV1.OutputCumulator} (at 2 write-result))
                    (ico2:object{IgnisCollectorV1.OutputCumulator} (at 3 write-result))
                    (ico3:object{IgnisCollectorV1.OutputCumulator} (at 4 write-result))
                    (ico4:object{IgnisCollectorV1.OutputCumulator} (at 5 write-result))
                    (ico5:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator gas-swp-cost SWP|SC_NAME trigger [])
                    )
                )
                (ref-IGNIS::KDA|C_Collect patron kda-costs)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [swpair token-lp])
            )
        )
    )
    ;;{F7}  [X]
    (defun XE_IssueWrite:list
        (account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#36M/M5 fix: forward-module entrypoint holding the ONE shared pool-issuance \
            \ write sequence — mint the LP token, register the pool, transfer pool tokens \
            \ in, mint genesis LP supply, transfer LP out to the account, register the \
            \ swap-tracer graph edge. Both SWPI::C_Issue (this module) and \
            \ MTX-SWP::MTX|C_Issue's Step 3 (a different module, reached via a \
            \ module{SwapperIssueV3} ref) call this instead of each independently \
            \ reimplementing it. \
            \ Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out] — \
            \ a wider list, not an IgnisCollectorV1.OutputCumulator (this codebase's XE_* \
            \ convention: the forward module's own C_ composes IGNIS, not this function). \
            \ C_Issue aggregates all four sub-cumulators into its own single billed \
            \ response; MTX|C_Issue's Step 3 only needs swpair/token-lp (it already billed \
            \ separately, in its own Step 2, before Step 3 ever runs) and ignores the rest."
        (UEV_IMC)
        (with-capability (SWPI|XE>ISSUE-WRITE account pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-BRD:module{BrandingV1} BRD)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    ;;#21H: SWPT no longer needs a principal list.
                    (ref-SWPT:module{SwapTracerV2} SWPT)
                    (ref-SWP:module{SwapperV3} SWP)
                    (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                    (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                    (lp-name-ticker:[string] (ref-SWP::URC_LpComposer pool-tokens weights amp))
                    (ico-lp:object{IgnisCollectorV1.OutputCumulator}
                        (ref-DPTF::XE_IssueLP (at 0 lp-name-ticker) (at 1 lp-name-ticker))
                    )
                    (token-lp:string (at 0 (at "output" ico-lp)))
                    (swpair:string (ref-SWP::XE_Issue account pool-tokens token-lp fee-lp weights amp p))
                )
                (ref-BRD::XE_Issue swpair)
                (let
                    (
                        (ico-transfer-in:object{IgnisCollectorV1.OutputCumulator}
                            (ref-TFT::C_MultiTransfer pool-token-ids account SWP|SC_NAME pool-token-amounts true)
                        )
                        (ico-mint:object{IgnisCollectorV1.OutputCumulator}
                            (ref-DPTF::C_Mint token-lp SWP|SC_NAME GENESIS_LP_SUPPLY true)
                        )
                        (ico-transfer-out:object{IgnisCollectorV1.OutputCumulator}
                            (ref-TFT::C_Transfer token-lp SWP|SC_NAME account GENESIS_LP_SUPPLY true)
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
    ;;
)

(create-table P|T)
(create-table P|MT)