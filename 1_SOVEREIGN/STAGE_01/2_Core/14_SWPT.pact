;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapTracerV2
    @doc "Exposes Tracer Functions, needed to compute Paths between Tokens existing on \
        \ Liquidity Pools. \
        \ \
        \ #21H redesign (V1 -> V2): V1 stored adjacency keyed by PRINCIPAL identity — \
        \ every swpair got filed under one Edges entry per principal it touched, at \
        \ trace time. That broke the moment a principal was removed or replaced: every \
        \ entry filed under the retired principal became permanently unreachable to \
        \ every normal read path, silently, system-wide, for every token ever pooled \
        \ against it — with no resync mechanism anywhere. It also duplicated storage \
        \ (a swpair touching 2 principals got recorded twice) and grew read cost with \
        \ every read via repeated concatenate-then-dedup over all principal buckets. \
        \ \
        \ V2 stores plain token-to-token adjacency instead — principal identity plays \
        \ no role anywhere in this module's storage, keys, or reads. Principal changes \
        \ (SWP::A_UpdatePrincipal or its future replacement-only successor) never touch \
        \ this module at all; there is nothing here that could go stale."

    (defschema NeighbourEdge
        token:string
        swpairs:[string]
    )
    (defschema PathCacheRow
        @doc "#34 Phase 6/7: a cached route between two tokens, keyed by <token-a>|\
            \ <token-b> in whichever direction was first registered — no \
            \ canonicalization, readers check both directions and reverse on a miss in \
            \ one of them. Stores only the route STRUCTURE, never a computed value — \
            \ every real use re-derives the current value from live reserves, so a \
            \ stale-but-structurally-valid entry can only ever point at the wrong-but- \
            \ still-real edges, which per-edge validation on every read catches and \
            \ falls back from. Same <nodes>/<edges> shape as <URC_ComputeGraphPath>'s \
            \ own return (both endpoints included in <nodes>). Declared on this \
            \ interface, not the module, since interface function signatures below \
            \ reference it and interfaces load before module schemas exist. \
            \ #65bL Phase 1 fix: added <topology-version>, the global topology-version \
            \ counter's value at the moment this entry was written — WITHOUT it, \
            \ 'first-write-wins, never overwritten' meant a cached entry could never be \
            \ refreshed even after new pools made a better route possible; a reader \
            \ now compares this against the live counter (<UR_TopologyVersion>) to tell \
            \ a genuinely-current entry from a stale one, and a stale entry can be \
            \ overwritten instead of permanently blocking any future improvement."
        nodes:[string]
        edges:[string]
        topology-version:integer
    )
    (defschema TopologyVersionRow
        @doc "#65bL Phase 1: single counter, bumped once per genuinely new token-pair \
            \ connection or genuinely new parallel pool (see <XI_UpdatePair>'s own \
            \ <did-change> logic) — never bumped on an idempotent replay (e.g. \
            \ <A_RebuildGraph> re-running over already-registered pools). A coarse \
            \ generation number, not an exact change-count: a single multi-token pool \
            \ issuance bumps it once per ordered token-pair it introduces, not once per \
            \ pool. That's fine — its only job is 'has anything changed since a given \
            \ read', not precise counting."
        version:integer
    )
    (defschema RawGraphNode
        @doc "#65bL Phase 2: one token's raw, unfiltered neighbour data — exactly what \
            \ <UR_Graph> returns for it, paired with its own name. The point of this \
            \ shape is to let a caller read a whole node universe's raw rows ONCE \
            \ (<URC_FetchRawGraph>) and reuse them across multiple best-of-K attempts \
            \ via a purely in-memory filter (<UC_MakeGraphFromRaw>) instead of each \
            \ attempt independently re-reading and rebuilding the whole graph."
        node:string
        neighbours:[object{NeighbourEdge}]
    )

    (defun UR_Graph:[object{NeighbourEdge}] (token:string))
    (defun URC_TokenNeighbours:[string] (token:string))
    (defun URC_Edges:[string] (t1:string t2:string))
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string]))
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string]))
    ;;#45L fix: renamed from URC_AllGraphPaths — misleading, doesn't return all
    ;;paths (one shortest BFS chain per reached node, not every simple path).
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string]))
    (defun URC_MakeGraph:[object{BreadthFirstSearchV1.GraphNode}] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 2: raw-fetch/pure-filter split, used by URC_ComputeAlternateRoutes/
    ;;URC_ComputeAllRoutes to fetch each candidate node's SWPT|Graph row exactly ONCE
    ;;per transaction and reuse it across every best-of-K attempt, instead of each
    ;;attempt calling URC_MakeGraph (a fresh read per node, every time).
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string]))
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV1.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#65bL Phase 7: one layer deeper than Phase 2's raw-fetch/pure-filter split — a
    ;;caller making MULTIPLE Hopper queries against the SAME <swpairs> universe in one
    ;;transaction (the STOA-repricing loop: one query per distinct pool touched, each a
    ;;different source token but the same WSTOA destination) was still calling
    ;;UC_MakeGraphFromRaw (a linear-scan-per-node graph BUILD) fresh on every query,
    ;;even though that build's output is byte-identical every time for the same
    ;;<raw-graph>/<swpairs> universe (UC_MakeGraphFromRaw is input/output-independent,
    ;;same as UC_MakeGraphNodes underneath it — Phase 4's own finding). These let a
    ;;caller build the [GraphNode] graph ONCE (UC_MakeGraphFromRaw) and reuse it across
    ;;every query — only the BFS traversal itself (genuinely <input>-dependent) still
    ;;runs per query.
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV1.GraphNode}])
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV1.GraphNode}])
    )
    ;;#34M/M2 fix: additive — finds up to 3 edge-disjoint candidate routes instead
    ;;of just the single first-found one; see the defun's own @doc for the full
    ;;rationale.
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 4: URC_ComputeAlternateRoutes, sourcing its graph via an
    ;;ALREADY-FETCHED <raw-graph> instead of fetching its own — lets a caller doing
    ;;multiple unrelated best-of-K searches in one transaction (the STOA-repricing
    ;;loop, one search per distinct pool) share ONE raw-graph fetch across all of them.
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#34 Phase 11 (the original #34 ask): generalizes URC_ComputeAlternateRoutes' fixed
    ;;3-attempt cap into a real parameterized search — see the defun's own @doc for the
    ;;full mechanics (early-exit, depth-cap filter, outer hard stop).
    (defun URC_ComputeAllRoutes:[[string]] (input:string output:string swpairs:[string] max-attempts:integer))

    ;;#34 Phase 7: dirty-read path-cache core functions — exists-only (structural) side.
    ;;The active-required wrapper (adds SWP::UR_CanSwap per edge) lives in SWPI instead,
    ;;same reason URC_EdgesActive's own whitelist check couldn't live here either — SWPT
    ;;deploys before SWP, can't reach it.
    (defun URC_ReadPathCache:object{PathCacheRow} (token-a:string token-b:string))
    ;;#65bL Phase 1: current global topology-version counter — one point read.
    (defun UR_TopologyVersion:integer ())
    ;;#65bL Phase 1: URC_ReadPathCache, additionally collapsing a STALE entry (its
    ;;topology-version behind the current one) to the same [BAR] miss sentinel a
    ;;genuinely-absent entry already returns — callers never need to know the
    ;;difference between "never cached" and "cached but outdated."
    (defun URC_ReadPathCacheFresh:object{PathCacheRow} (token-a:string token-b:string))
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string))
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string]))
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))
    ;;#34 Phase 8: forward-module entrypoint for XI_RegisterPath — mirrors XE_UpdateGraph
    ;;exactly (UEV_IMC gate + internal SECURE composition). Cross-module callers (SWPU)
    ;;must go through this, never grant SWPT.SECURE directly themselves — SECURE's body
    ;;is unconditionally true, so a caller-side `(with-capability (SWPT.SECURE) ...)`
    ;;would grant it to literally anyone, not just legitimate Ouronet modules (confirmed
    ;;against this exact class of issue in this codebase's own ATS audit findings).
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))

    (defun XE_UpdateGraph (swpair:string))
)
;;
(module SWPT GOV
    ;;
    (implements OuronetPolicyV1)
    (implements SwapTracerV2)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_SWPT           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|SWPT_ADMIN)))
    (defcap GOV|SWPT_ADMIN ()       (enforce-guard GOV|MD_SWPT))
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
    (defcap P|SWPT|CALLER ()
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
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SWPT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|SWPT_ADMIN)
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
    (defun A_P|Define ()
        (let
            (
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
                (mg:guard (create-capability-guard (P|SWPT|CALLER)))
            )
            (ref-P|DALOS::A_P|AddIMP mg)
            (ref-P|BRD::A_P|AddIMP mg)
            (ref-P|DPTF::A_P|AddIMP mg)
            ;(ref-P|DPOF::A_P|AddIMP mg)
            (ref-P|ATS::A_P|AddIMP mg)
            (ref-P|TFT::A_P|AddIMP mg)
            (ref-P|ATSU::A_P|AddIMP mg)
            (ref-P|VST::A_P|AddIMP mg)
            (ref-P|LIQUID::A_P|AddIMP mg)
            (ref-P|ORBR::A_P|AddIMP mg)
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
    (defschema SWPT|GraphSchema
        neighbours:[object{SwapTracerV2.NeighbourEdge}]
    )
    ;;{2}
    (deftable SWPT|Graph:{SWPT|GraphSchema})                    ;;Key = <token>
    (deftable SWPT|PathCache:{SwapTracerV2.PathCacheRow})       ;;Key = <token-a>|<token-b> (insertion-order, reversed-lookup at read time)
    ;;#65bL Phase 1: own table per this codebase's storage-pattern rule (never
    ;;co-locate a row read for other reasons — segregated so only the path that
    ;;needs the counter pays to deserialize it).
    (deftable SWPT|TopologyVersion:{SwapTracerV2.TopologyVersionRow})  ;;Key = TOPOLOGY_VERSION_KEY (singleton)
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    ;;#65bL Phase 1: singleton key for SWPT|TopologyVersion — same pattern as this
    ;;codebase's other singleton-row tables (e.g. policy's P|I).
    (defconst TOPOLOGY_VERSION_KEY   "topology-version")
    ;;#34 Phase 11: P0.4's depth cap (7 tokens / 6 hops, "the sexy number 7") — same
    ;;value URC_ValidatePathStructure already enforces on submitted bundles, reused
    ;;here as a post-discovery filter in URC_ComputeAllRoutes (see that function's own
    ;;doc for why post-filter, not baked into U|BFS's traversal itself).
    (defconst MAX_ROUTE_NODES        7)
    ;;#34 Phase 11: P0.2's genuine outer hard stop on max-attempts, independent of
    ;;whatever a caller requests — placeholder value, not researched/considered,
    ;;owner may override. URC_ComputeAllRoutes clamps to this regardless of the
    ;;caller's own max-attempts argument.
    (defconst MAX_ATTEMPTS_HARD_CAP  50000)
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
    ;;{F1}  Construct [UDC]
    ;;{F2}  Compute [UC]
    (defun UC_FindNeighbourIndex:[integer] (neighbours:[object{SwapTracerV2.NeighbourEdge}] token:string)
        @doc "Returns [idx] of the entry in <neighbours> whose token field matches \
            \ <token>, or [] if no such entry exists yet."
        (let
            (
                (l:integer (length neighbours))
            )
            (if (= l 0)
                []
                (fold
                    (lambda
                        (acc:[integer] idx:integer)
                        (if (!= acc [])
                            acc
                            (if (= (at "token" (at idx neighbours)) token) [idx] [])
                        )
                    )
                    []
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun UC_ExcludeEdges:[string] (swpairs:[string] exclude:[string])
        @doc "Removes every entry of <exclude> from <swpairs> — pure list-difference. \
            \ Used to build a reduced routing universe for #34M/M2's best-of-K \
            \ alternate-route search: each retry excludes the edges of every route \
            \ already found, forcing a genuinely different one instead of \
            \ rediscovering the same route."
        (filter (lambda (s:string) (not (contains s exclude))) swpairs)
    )
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV1.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: pure (zero table reads) equivalent of <URC_MakeGraph> — \
            \ builds the identical active-filtered [GraphNode] shape, but derives \
            \ every node's links from an ALREADY-FETCHED <raw-graph> \
            \ (<URC_FetchRawGraph>) instead of re-reading SWPT|Graph per node, and \
            \ also skips the double-read <URC_MakeGraph> itself has (one read via \
            \ <URC_TokenNeighbours> to list neighbour tokens, another via \
            \ <URC_EdgesActive>/<URC_Edges> per neighbour to re-derive the exact \
            \ same swpairs already sitting in that first read's result) — the \
            \ per-neighbour <swpairs> field is already right there on each \
            \ <NeighbourEdge>, filtered directly, no re-read or re-derivation \
            \ needed either way. <raw-graph> must cover every node <swpairs> could \
            \ ever produce here — always true when it was fetched against a \
            \ swpairs universe that's a SUPERSET of this one (e.g. the original, \
            \ unshrunk universe a best-of-K search started from, reused unchanged \
            \ across every attempt's own shrinking exclusion universe)."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV1.GraphNode}] idx:integer)
                        (let*
                            (
                                (this-node:string (at idx nodes))
                                ;;#65bL Phase 3 investigated a binary-search replacement for
                                ;;this scan (see URC_FetchRawGraph's own doc) — measured as a
                                ;;real regression on the actual integrated call, not shipped.
                                ;;Linear filter stays, unchanged from Phase 2.
                                (raw-matches:[object{RawGraphNode}]
                                    (filter (lambda (rg:object{RawGraphNode}) (= (at "node" rg) this-node)) raw-graph)
                                )
                                (neighbours:[object{NeighbourEdge}]
                                    (if (= 0 (length raw-matches)) [] (at "neighbours" (at 0 raw-matches)))
                                )
                            )
                            (ref-U|LST::UC_AppL
                                acc
                                {
                                    "node": this-node,
                                    "links":
                                        (map (at "token")
                                            (filter
                                                (lambda (ne:object{NeighbourEdge})
                                                    (!=
                                                        (filter
                                                            (lambda (sp:string) (contains sp swpairs))
                                                            (at "swpairs" ne)
                                                        )
                                                        []
                                                    )
                                                )
                                                neighbours
                                            )
                                        )
                                }
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    ;;{F3}  Read [UR/URC/URH/URCi]
    (defun UR_Graph:[object{SwapTracerV2.NeighbourEdge}] (token:string)
        (with-default-read SWPT|Graph token
            {"neighbours" : []}
            {"neighbours" := n}
            n
        )
    )
    (defun UR_PathCacheRaw:object{SwapTracerV2.PathCacheRow} (key:string)
        @doc "#34 Phase 7: raw keyed read against SWPT|PathCache, [BAR]-sentinel default \
            \ for a missing row. Internal — callers go through <URC_ReadPathCache> for the \
            \ reversed-lookup logic, never this directly. \
            \ #65bL Phase 1: default <topology-version> is -1 — always older than any \
            \ real counter value (starts at 0, only ever increases), so a missing row \
            \ is automatically treated as stale by any freshness check, same as a \
            \ genuinely-absent entry always was structurally."
        (with-default-read SWPT|PathCache key
            {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
            {"nodes" := n, "edges" := e, "topology-version" := tv}
            {"nodes" : n, "edges" : e, "topology-version" : tv}
        )
    )
    (defun UR_TopologyVersion:integer ()
        @doc "#65bL Phase 1: current global topology-version counter — one point read, \
            \ default 0 for the pre-first-bump state."
        (with-default-read SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version" : 0}
            {"version" := v}
            v
        )
    )
    (defun URC_TokenNeighbours:[string] (token:string)
        (map (at "token") (UR_Graph token))
    )
    (defun URC_Edges:[string] (t1:string t2:string)
        @doc "All swpairs directly connecting <t1> and <t2> — regardless of can-swap \
            \ state. Direct keyed lookup against <t1>'s own row; O(deg(t1)), never a \
            \ table scan."
        (let*
            (
                (neighbours:[object{SwapTracerV2.NeighbourEdge}] (UR_Graph t1))
                (idx:[integer] (UC_FindNeighbourIndex neighbours t2))
            )
            (if (= (length idx) 0)
                []
                (at "swpairs" (at (at 0 idx) neighbours))
            )
        )
    )
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string])
        @doc "Same as <URC_Edges>, but the result is restricted to swpairs also \
            \ present in <whitelist> (e.g. <SWP::URC_ActiveSwpairs>) — so a disabled \
            \ parallel pool between the same token pair is never offered as an edge \
            \ candidate to <SWPI::URC_BestEdgeFiltered>. #19H fix, carried over \
            \ unchanged by the #21H storage redesign."
        (filter (lambda (swpair:string) (contains swpair whitelist)) (URC_Edges t1 t2))
    )
    (defun URCx_ShortestChainToTarget:[[string]] (input:string output:string swpairs:[string])
        @doc "#65hL: <URC_ShortestChainPerNode>, but stops doing real BFS-expansion \
            \ work once <output> is reached, via <U|BFS::UC_BFSTargeted> — see that \
            \ function's own doc for the full rationale and correctness argument \
            \ (a node's shortest chain is fixed the first time BFS visits it, so \
            \ stopping early never changes <output>'s own chain, only skips \
            \ recording chains for nodes the caller's post-filter would have \
            \ discarded anyway). Internal only, used exclusively by \
            \ <URC_ComputeGraphPath> — <URC_ShortestChainPerNode> itself is \
            \ unchanged, still available for any caller genuinely wanting chains to \
            \ every reachable node, not just one target."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (graph:[object{BreadthFirstSearchV1.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string])
        @doc "Computes the path between an <input> and <output> using BFS via \
        \ <URC_ShortestChainPerNode> from a passed down list of existing <swpairs>. \
        \ #20H fix: returns the clean [BAR] sentinel — never a bare out-of-bounds \
        \ <at> crash — whenever no chain reaches <output>, including the case of a \
        \ genuinely disconnected pair once <swpairs> has been narrowed upstream \
        \ (e.g. to active-only pools, #19H). \
        \ #65hL fix: sources its chains via <URCx_ShortestChainToTarget> instead of \
        \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic \
        \ below, unchanged, just fed from a BFS that stops once <output> is \
        \ actually found instead of exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (shortest-chains:[[string]] (URCx_ShortestChainToTarget input output swpairs))

            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    ;;#20H fix: guard against fp coming back empty (no chain
                    ;;reached output — e.g. a genuinely disconnected pair after
                    ;;active-only filtering) instead of a bare out-of-bounds `at`.
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string])
        @doc "#45L fix: renamed from URC_AllGraphPaths — the old name claimed 'all paths' \
            \ but this runs a single BFS traversal from <input> and keeps exactly one \
            \ shortest chain per node BFS reaches, not every simple path through the \
            \ graph (that's <URC_ComputeAllRoutes>, a different function entirely, added \
            \ in #34 Phase 11). <output> is accepted for signature symmetry with its only \
            \ caller (<URC_ComputeGraphPath>, which post-filters this result down to \
            \ chains actually ending at <output>) — it plays no role in the BFS itself, \
            \ which explores every reachable node from <input> regardless of <output>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (graph:[object{BreadthFirstSearchV1.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_RouteEdges:[string] (nodes:[string] swpairs:[string])
        @doc "For a <nodes> path (as returned by <URC_ComputeGraphPath>), returns the \
            \ union of every swpair actually usable to traverse it within <swpairs>'s \
            \ universe — one <URC_EdgesActive> lookup per hop. Used to build the \
            \ exclusion set for #34M/M2's best-of-K route comparison."
        (if (or (= nodes [BAR]) (< (length nodes) 2))
            []
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (+ acc (URC_EdgesActive (at idx nodes) (at (+ idx 1) nodes) swpairs))
                )
                []
                (enumerate 0 (- (length nodes) 2))
            )
        )
    )
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string])
        @doc "#34M/M2 fix: <URC_ComputeGraphPath> alone only ever returns the single \
            \ first-discovered route — BFS's global once-per-node visited marking \
            \ means an equally valid alternate route (e.g. a diamond A->{B,C}->D \
            \ graph) is silently lost, and nothing ever compared candidate routes by \
            \ value anyway. This finds up to 3 edge-disjoint candidate routes by \
            \ re-running <URC_ComputeGraphPath> with each previously-found route's \
            \ edges excluded from the universe, forcing genuinely different routes \
            \ rather than the same route with a different parallel pool (that choice \
            \ is already optimal per-hop via <URC_BestEdgeFiltered>/<URC_BestEdgeOf>'s \
            \ own argmax, so re-exploring it would be wasted work). \
            \ Fixed cap of 3 attempts — Pact has no dynamic-length/convergence loops, \
            \ so the count must be a number decided in advance, not a runtime \
            \ condition; measured sufficient against this codebase's actual pool \
            \ topology (see the SWP audit's adversarial REPL proof for #34M/M2). \
            \ Returns only the routes genuinely found (drops [BAR] no-route results), \
            \ so the result can have 0-3 entries; the caller picks the best by value. \
            \ #65bL Phase 4 fix: now a thin wrapper — fetches the raw graph for this \
            \ call's own node universe, then delegates to \
            \ <URC_ComputeAlternateRoutesFromRaw>. A caller who's already fetched a \
            \ raw graph covering this <swpairs> universe (e.g. the STOA-repricing \
            \ loop, sharing one fetch across many unrelated calls) should call that \
            \ function directly instead, to skip this self-fetch."
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (full-nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
                (raw-graph:[object{RawGraphNode}] (URC_FetchRawGraph full-nodes))
            )
            (URC_ComputeAlternateRoutesFromRaw input output swpairs raw-graph)
        )
    )
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2/4 fix: <URC_ComputeAlternateRoutes>'s real logic, \
            \ parameterized on an ALREADY-FETCHED <raw-graph> instead of fetching its \
            \ own — see <URC_ComputeAlternateRoutes>'s own doc for the full best-of-3 \
            \ rationale (unchanged here) and <URCx_HopperFromRaw>'s doc for why one \
            \ fetch can safely serve many different (input,output) queries against \
            \ the same <swpairs> universe (<UC_MakeGraphNodes> is input/output- \
            \ independent by construction). An exhausted-universe guard (empty \
            \ <swpairsN>) short-circuits to [BAR] instead of calling \
            \ <URC_ComputeGraphPathFromRaw> — that function's own downstream \
            \ graph-building (M3, a separate tracked finding) crashes rather than \
            \ cleanly returning no-route on an empty list, and this is the first \
            \ caller able to legitimately produce one (a fully-excluded, single-pool \
            \ universe after route1/route2 already claimed it)."
        (let*
            (
                (route1:[string]
                    (if (= swpairs []) [BAR] (URC_ComputeGraphPathFromRaw input output swpairs raw-graph))
                )
                (swpairs2:[string]
                    (if (= route1 [BAR])
                        swpairs
                        (UC_ExcludeEdges swpairs (URC_RouteEdges route1 swpairs))
                    )
                )
                (route2:[string]
                    (if (or (= route1 [BAR]) (= swpairs2 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs2 raw-graph)
                    )
                )
                (swpairs3:[string]
                    (if (= route2 [BAR])
                        swpairs2
                        (UC_ExcludeEdges swpairs2 (URC_RouteEdges route2 swpairs2))
                    )
                )
                (route3:[string]
                    (if (or (= route2 [BAR]) (= swpairs3 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs3 raw-graph)
                    )
                )
            )
            (filter (lambda (r:[string]) (!= r [BAR])) [route1 route2 route3])
        )
    )
    (defun URC_ComputeAllRoutes:[[string]]
        (input:string output:string swpairs:[string] max-attempts:integer)
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not the fixed best-of-3 approximation URC_ComputeAlternateRoutes settled \
            \ for. Generalizes that function's hardcoded 3-attempt let* chain into a \
            \ real fold over up to <max-attempts> attempts, same edge-exclusion-per-\
            \ found-route mechanism (URC_RouteEdges + UC_ExcludeEdges), same \
            \ early-exit-once-empty short-circuit already proven correct in that \
            \ function. Meant to be called via off-chain dirty read only (P3 — this is \
            \ what fills a SmartSwapPathBundle's swap-route component before \
            \ submission), never on the paid execution path; the whole point of the \
            \ #34/#34M redesign is to remove exactly this kind of search from paid \
            \ transactions. \
            \ P0.2's max-attempts escalation (try 1000, then 2000, then 3000... flat \
            \ +1000 steps, no doubling) is a CALLER-side retry pattern — this function \
            \ takes a fixed <max-attempts> and does exactly that many attempts (or \
            \ fewer, via early-exit), it does not escalate itself. A caller who gets \
            \ back exactly <max-attempts> routes with no natural exhaustion should \
            \ retry with a larger <max-attempts>; fewer than requested means the \
            \ search is genuinely exhausted (every route already found). \
            \ P0.2's outer hard stop (MAX_ATTEMPTS_HARD_CAP) is enforced here \
            \ regardless of what the caller requests — a caller cannot force an \
            \ unbounded search by passing an enormous <max-attempts>. \
            \ P0.4's depth cap (MAX_ROUTE_NODES, 7 tokens / 6 hops) is enforced as a \
            \ POST-DISCOVERY filter here, not baked into <U|BFS>'s own traversal — a \
            \ deliberate, documented deviation from P0.4's stated preference \
            \ ('ideally baked into the BFS/graph-walk itself... rather than only as a \
            \ post-discovery filter, wasteful'). Reasoning: baking a depth bound into \
            \ <U|BFS> would mean modifying a SHARED lower-layer utility module with \
            \ callers beyond this one feature, a broader and riskier change than this \
            \ phase's scope justifies; the 'wasteful — pay to explore and discard' \
            \ downside the preference is guarding against does not actually apply here, \
            \ since this function is dirty-read-only (free off-chain compute, never \
            \ paid gas) — the efficiency concern the baked-in preference exists for is \
            \ moot in this function's real deployment context. An over-cap route still \
            \ has its edges excluded from the remaining search universe before the next \
            \ attempt (without this, the deterministic BFS would just rediscover the \
            \ exact same over-cap route every remaining attempt, wasting the whole \
            \ budget making zero progress) — only whether it's ADDED to the returned \
            \ results is filtered. \
            \ Reuses the already-shipped URCx_HopperForNodes/UC_BestHopper unchanged \
            \ for picking the best candidate by actual computed output value (P1.8's \
            \ requirement) — that value-computation logic lives in SWPI (16_SWPI.pact), \
            \ not here; this function only discovers node-path candidates, same \
            \ division of labor URC_ComputeAlternateRoutes already established."
        (let
            (
                (capped-attempts:integer (if (> max-attempts MAX_ATTEMPTS_HARD_CAP) MAX_ATTEMPTS_HARD_CAP max-attempts))
            )
            (if (or (= swpairs []) (<= capped-attempts 0))
                []
                (at 0
                    (fold
                        (lambda
                            (acc:list idx:integer)
                            ;;acc = [routes-found:[[string]] remaining-universe:[string] stopped:bool]
                            (if (at 2 acc)
                                acc
                                (let*
                                    (
                                        (remaining:[string] (at 1 acc))
                                        (route:[string]
                                            (if (= remaining [])
                                                [BAR]
                                                (URC_ComputeGraphPath input output remaining)
                                            )
                                        )
                                    )
                                    (if (= route [BAR])
                                        ;;Genuinely exhausted — no route findable in the
                                        ;;remaining universe. Stop; every further attempt
                                        ;;would find the identical nothing.
                                        [(at 0 acc) remaining true]
                                        (let*
                                            (
                                                (route-edges:[string] (URC_RouteEdges route remaining))
                                                (new-remaining:[string] (UC_ExcludeEdges remaining route-edges))
                                                (within-depth-cap:bool (<= (length route) MAX_ROUTE_NODES))
                                                (new-routes:[[string]]
                                                    (if within-depth-cap
                                                        (+ (at 0 acc) [route])
                                                        (at 0 acc)
                                                    )
                                                )
                                            )
                                            [new-routes new-remaining false]
                                        )
                                    )
                                )
                            )
                        )
                        [[] swpairs false]
                        (enumerate 0 (- capped-attempts 1))
                    )
                )
            )
        )
    )
    (defun URC_MakeGraph:[object{BreadthFirstSearchV1.GraphNode}] (input:string output:string swpairs:[string])
        @doc "#13C fix + #19H fix, carried over unchanged by the #21H storage redesign: \
            \ a node's links must be genuine active edges (<URC_EdgesActive> non-empty), \
            \ not just 'is this token a valid node somewhere' — a neighbor token can be \
            \ a perfectly valid node overall while the ONLY swpair directly connecting \
            \ it to THIS node is outside <swpairs> (e.g. disabled). Requiring a real \
            \ <URC_EdgesActive> match subsumes plain node-membership (a real active edge \
            \ implies both endpoints are already valid nodes) and closes both problems \
            \ with one condition. \
            \ #37M/M3 fix: <nodes> can genuinely be [] (e.g. <swpairs> is [] \
            \ before the first pool is ever issued) — previously unguarded here, \
            \ a case not named by the original finding but sharing its exact \
            \ <enumerate 0 -1> / <at 0 []> root cause, directly downstream of \
            \ <UC_MakeGraphNodes>. Short-circuits to [] instead of crashing."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV1.GraphNode}] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            {
                                "node": (at idx nodes),
                                "links":
                                    (filter
                                        (lambda (n:string) (!= (URC_EdgesActive (at idx nodes) n swpairs) []))
                                        (URC_TokenNeighbours (at idx nodes))
                                    )
                            }
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string])
        @doc "#65bL Phase 2: reads each of <nodes>'s SWPT|Graph row exactly once — \
            \ the read-fetch half of the raw-fetch/pure-filter split. A caller doing \
            \ multiple best-of-K attempts over the SAME node universe calls this \
            \ ONCE, then reuses the result via <UC_MakeGraphFromRaw> for every \
            \ attempt instead of each attempt independently re-reading and \
            \ rebuilding the whole graph the way <URC_MakeGraph> does. \
            \ #65bL Phase 3 investigated: a sorted-list + binary-search lookup was \
            \ built and measured against the linear scan <UC_MakeGraphFromRaw> uses \
            \ — an isolated synthetic benchmark showed binary search winning at \
            \ 100-300 elements, but the REAL integrated measurement (this exact \
            \ function, the real P2-scale 143-node universe) showed it as a net \
            \ REGRESSION (+27,527 gas on the SWP|TX 032z2 checkpoint), isolated and \
            \ confirmed by reverting only the lookup call. Trusted the real \
            \ measurement over the synthetic one and dropped it — recorded in \
            \ ROUND-01-OWNER-FEEDBACK.md as a real, deliberately-not-shipped result, \
            \ not silently discarded."
        (map
            (lambda (n:string) {"node": n, "neighbours": (UR_Graph n)})
            nodes
        )
    )
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ShortestChainPerNode>, sourcing its graph via \
            \ <UC_MakeGraphFromRaw> (an already-fetched <raw-graph>) instead of \
            \ <URC_MakeGraph> (a fresh read per node, every call)."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (graph:[object{BreadthFirstSearchV1.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTarget>, sourcing its graph via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — same \
            \ early-exit-on-<output> shape as <UC_BFSTargeted>, mirroring \
            \ <URC_ShortestChainPerNodeFromRaw>'s own raw-graph sourcing. Internal \
            \ only, used exclusively by <URC_ComputeGraphPathFromRaw>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (graph:[object{BreadthFirstSearchV1.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ComputeGraphPath>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromRaw> instead of \
            \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic, \
            \ unchanged, just fed from an already-fetched raw graph. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromRaw> instead — same raw-graph sourcing, \
            \ but stops once <output> is actually found instead of exploring the \
            \ whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromRaw input output swpairs raw-graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV1.GraphNode}])
        @doc "#65bL Phase 7: <URC_ShortestChainPerNodeFromRaw>, sourcing an \
            \ ALREADY-BUILT <graph> (<UC_MakeGraphFromRaw>) instead of building it \
            \ fresh from <raw-graph>/<swpairs> on every call — for a caller making \
            \ MULTIPLE Hopper queries against the SAME <swpairs> universe in one \
            \ transaction (the STOA-repricing loop), who builds the graph ONCE and \
            \ reuses it across every query. Safe per the same input/output- \
            \ independence <UC_MakeGraphFromRaw>'s own doc records — one graph \
            \ built against a given <swpairs> universe is valid for EVERY query \
            \ against that same universe, not just the one it happened to be built \
            \ for. Only the BFS traversal itself (genuinely <input>-dependent) \
            \ still runs per query."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromGraph:[[string]]
        (input:string output:string graph:[object{BreadthFirstSearchV1.GraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTargetFromRaw>, sourcing an ALREADY-BUILT \
            \ <graph> instead of rebuilding it from <raw-graph>/<swpairs> — same \
            \ early-exit-on-<output> shape, mirroring \
            \ <URC_ShortestChainPerNodeFromGraph>'s own already-built-graph sourcing. \
            \ Internal only, used exclusively by <URC_ComputeGraphPathFromGraph>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV1.GraphNode}])
        @doc "#65bL Phase 7: <URC_ComputeGraphPathFromRaw>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromGraph> (an already-built <graph>) \
            \ instead of rebuilding it from <raw-graph>/<swpairs> on every call — \
            \ same post-filter-down-to-<output> logic, unchanged. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromGraph> instead — same already-built- \
            \ graph sourcing, but stops once <output> is actually found instead of \
            \ exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromGraph input output graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    ;;#34 Phase 7: dirty-read path-cache core functions.
    (defun URC_ReadPathCache:object{SwapTracerV2.PathCacheRow} (token-a:string token-b:string)
        @doc "Reversed-lookup read: checks <token-a>|<token-b> first, then \
            \ <token-b>|<token-a> reversed (the graph is confirmed bidirectional — \
            \ XI_UpdateGraphForSwpair's symmetric i×j registration), before concluding \
            \ no cached path exists. Returns {nodes:[BAR], edges:[], topology-version:-1} \
            \ on a genuine miss in both directions — never a crash, always a clean \
            \ sentinel. No trust implied: every caller still runs \
            \ <URC_ValidatePathStructure> (or SWPI's active-required wrapper) on \
            \ whatever this returns before using it — a hit here is not itself proof of \
            \ current validity, only of prior registration. Raw registration status \
            \ only — callers wanting freshness too go through \
            \ <URC_ReadPathCacheFresh> instead (#65bL Phase 1)."
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (row-fwd:object{SwapTracerV2.PathCacheRow} (UR_PathCacheRaw key-fwd))
            )
            (if (!= (at "nodes" row-fwd) [BAR])
                row-fwd
                (let*
                    (
                        (key-rev:string (+ (+ token-b "|") token-a))
                        (row-rev:object{SwapTracerV2.PathCacheRow} (UR_PathCacheRaw key-rev))
                    )
                    (if (!= (at "nodes" row-rev) [BAR])
                        {
                            "nodes" : (reverse (at "nodes" row-rev)),
                            "edges" : (reverse (at "edges" row-rev)),
                            "topology-version" : (at "topology-version" row-rev)
                        }
                        {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                    )
                )
            )
        )
    )
    (defun URC_ReadPathCacheFresh:object{SwapTracerV2.PathCacheRow} (token-a:string token-b:string)
        @doc "#65bL Phase 1: <URC_ReadPathCache>, additionally collapsing a STALE entry \
            \ (its <topology-version> behind the live counter) to the same [BAR] miss \
            \ sentinel a genuinely-absent entry already returns. Callers never need to \
            \ distinguish 'never cached' from 'cached but topology has moved on since' — \
            \ both mean 'don't trust this, go search live instead'."
        (let*
            (
                (row:object{SwapTracerV2.PathCacheRow} (URC_ReadPathCache token-a token-b))
                (current-version:integer (UR_TopologyVersion))
            )
            (if (< (at "topology-version" row) current-version)
                {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                row
            )
        )
    )
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string)
        @doc "Structural legitimacy check for ONE claimed hop: is <swpair> a real, \
            \ registered edge that actually connects <i-id> to <o-id> — not just some \
            \ active pool that happens to exist somewhere. Prevents a submitted bundle \
            \ from containing genuinely-real-but-unrelated edges that don't actually \
            \ form a connected path."
        (contains swpair (URC_Edges i-id o-id))
    )
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string])
        @doc "Exists-only structural validation (P3.1): every claimed hop genuinely \
            \ connects its claimed node pair, and the whole path respects the P0.4 depth \
            \ cap (7 tokens / 6 hops) — checked here directly rather than assumed of the \
            \ off-chain search that produced it, since a malformed or adversarial bundle \
            \ could otherwise submit a structurally-valid-per-hop but far-too-long route. \
            \ [BAR] (the 'no path found' sentinel) is explicitly rejected, not treated as \
            \ a trivial 1-node path. Does NOT check can-swap — SWPI wraps this with that \
            \ additional check for the active-required (real execution) case; this \
            \ module can't reach SWP to check it directly (deploy order)."
        (if (= nodes [BAR])
            false
            (if
                ;;Pact 5's <or> is strictly binary, not variadic — 3+ conditions need
                ;;fold, per this codebase's own documented convention (same class of
                ;;gotcha as the #26M/M9 single-arg <and> bug found earlier this session).
                (fold (or) false
                    [
                        (> (length nodes) 7)
                        (> (length edges) 6)
                        (!= (length edges) (- (length nodes) 1))
                    ]
                )
                false
                ;;#20H-style guard: (enumerate 0 -1) is [0 -1], NOT empty, in Pact 5 — a
                ;;0-hop path (single-node, edges=[]) would otherwise crash on an
                ;;out-of-bounds <at>. Explicit empty-edges short-circuit avoids it.
                (if (= (length edges) 0)
                    true
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (and acc (URC_EdgeConnects (at idx nodes) (at (+ idx 1) nodes) (at idx edges)))
                        )
                        true
                        (enumerate 0 (- (length edges) 1))
                    )
                )
            )
        )
    )
    ;;{F4}  Validate [UEV/CAP]
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    (defun XE_UpdateGraph (swpair:string)
        @doc "Records <swpair> in the adjacency graph: every token in <swpair> gets \
            \ every OTHER token in <swpair> appended to its neighbour list (idempotent \
            \ — safe to call more than once for the same swpair). Called once at \
            \ issuance from both SWPI::C_Issue and the MTX-SWP defpact path."
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateGraphForSwpair swpair)
        )
    )
    (defun XI_UpdateGraphForSwpair (swpair:string)
        (require-capability (SECURE))
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (n:integer (length tokens))
            )
            (map
                (lambda (i:integer)
                    (map
                        (lambda (j:integer)
                            (if (= i j)
                                BAR
                                (XI_UpdatePair (at i tokens) (at j tokens) swpair)
                            )
                        )
                        (enumerate 0 (- n 1))
                    )
                )
                (enumerate 0 (- n 1))
            )
        )
    )
    (defun XI_UpdatePair (from:string to:string swpair:string)
        @doc "Adds <to> as a neighbour of <from> via <swpair>, creating the neighbour \
            \ entry if this is the first connection between them, or appending \
            \ <swpair> to the existing entry's swpairs list if not already present. \
            \ #65bL Phase 1 fix: also bumps the global topology-version counter, but \
            \ ONLY when this call genuinely changes something — a new token-pair \
            \ connection, or a new parallel pool on an already-connected pair — never \
            \ on an idempotent replay of an already-registered pair+swpair (e.g. \
            \ A_RebuildGraph re-running over every existing pool). <did-change> below \
            \ is exactly the same condition the pre-existing branching already computed \
            \ implicitly; this just names it so it can also gate the version bump."
        (require-capability (SECURE))
        (let*
            (
                (existing:[object{SwapTracerV2.NeighbourEdge}] (UR_Graph from))
                (idx:[integer] (UC_FindNeighbourIndex existing to))
                (is-new-pair:bool (= (length idx) 0))
                (old-swpairs:[string]
                    (if is-new-pair
                        []
                        (at "swpairs" (at (at 0 idx) existing))
                    )
                )
                (is-new-swpair:bool (not (contains swpair old-swpairs)))
                (did-change:bool (or is-new-pair is-new-swpair))
                (new-neighbours:[object{SwapTracerV2.NeighbourEdge}]
                    (if is-new-pair
                        (+ existing [{"token": to, "swpairs": [swpair]}])
                        (let*
                            (
                                (i:integer (at 0 idx))
                                (new-swpairs:[string]
                                    (if is-new-swpair
                                        (+ old-swpairs [swpair])
                                        old-swpairs
                                    )
                                )
                            )
                            (+ (+ (take i existing) [{"token": to, "swpairs": new-swpairs}]) (drop (+ i 1) existing))
                        )
                    )
                )
            )
            (write SWPT|Graph from {"neighbours": new-neighbours})
            (if did-change (XI_BumpTopologyVersion) "no-op")
        )
    )
    (defun XI_BumpTopologyVersion ()
        @doc "#65bL Phase 1: increments the global topology-version counter by 1. \
            \ Called only from <XI_UpdatePair> when it detects a genuine change — \
            \ never unconditionally."
        (require-capability (SECURE))
        (write SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version": (+ (UR_TopologyVersion) 1)}
        )
    )
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 7: registration into SWPT|PathCache. Self-verifying (owner's \
            \ final-check catch, 2026-08-21) — checks whether a row already exists in \
            \ EITHER direction before writing, rather than trusting a caller's is-new \
            \ claim as the write authority. Structural validation is the CALLER's \
            \ responsibility (URC_ValidatePathStructure/SWPI's active-required wrapper) \
            \ — this function only handles the write-safety half, matching this \
            \ codebase's XI_* convention of writes-only, no enforce/validation here. \
            \ #65bL Phase 1 fix: was strictly first-write-wins/insert-only, meaning a \
            \ cached entry could never be refreshed even after new topology made a \
            \ better route possible — permanent staleness by construction. Now \
            \ version-checked: a genuinely absent entry still inserts; an existing \
            \ entry only gets overwritten if its own <topology-version> is behind the \
            \ current counter (topology has moved on since it was cached), otherwise \
            \ still a no-op — never a redundant write for an already-current entry."
        (require-capability (SECURE))
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (key-rev:string (+ (+ token-b "|") token-a))
                (row-fwd:object{SwapTracerV2.PathCacheRow} (UR_PathCacheRaw key-fwd))
                (row-rev:object{SwapTracerV2.PathCacheRow} (UR_PathCacheRaw key-rev))
                (already-fwd:bool (!= (at "nodes" row-fwd) [BAR]))
                (already-rev:bool (!= (at "nodes" row-rev) [BAR]))
                (current-version:integer (UR_TopologyVersion))
                (new-row:object{SwapTracerV2.PathCacheRow}
                    {"nodes": nodes, "edges": edges, "topology-version": current-version}
                )
            )
            (if (and (not already-fwd) (not already-rev))
                (insert SWPT|PathCache key-fwd new-row)
                (if already-fwd
                    (if (< (at "topology-version" row-fwd) current-version)
                        (write SWPT|PathCache key-fwd new-row)
                        "already fresh, no-op"
                    )
                    (if (< (at "topology-version" row-rev) current-version)
                        (write SWPT|PathCache key-rev new-row)
                        "already fresh, no-op"
                    )
                )
            )
        )
    )
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 8: forward-module entrypoint for XI_RegisterPath, mirroring \
            \ XE_UpdateGraph exactly — UEV_IMC gate, then internal SECURE composition. \
            \ Cross-module callers (SWPU::C_SmartSwap, once wired) go through THIS, never \
            \ a caller-side (with-capability (SWPT.SECURE) ...) directly — SECURE's own \
            \ body is unconditionally true, so a direct outside grant would hand it to \
            \ any caller at all, not just legitimate Ouronet modules (this exact class of \
            \ issue is already documented, empirically, in this codebase's own ATS audit \
            \ findings)."
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_RegisterPath token-a token-b nodes edges)
        )
    )
    ;;{F7}  User [A]
    ;;{F8}  User [C]
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table SWPT|Graph)
(create-table SWPT|PathCache)
(create-table SWPT|TopologyVersion)
