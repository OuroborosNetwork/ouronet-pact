(interface BreadthFirstSearchV1
    @doc "Interface exposing a Breadth-First-Search Implementation on Pact \
    \ Used in the SWP Modules to compute Paths between SWPair Tokens."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

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
    ;;{3.2}  schemas
    ;;
    (defschema GraphNode
        node:string
        links:[string]
    )
    (defschema BFS
        visited:[string]
        que:[object{QE}]
        chains:[[string]]
    )
    (defschema QE
        node:string
        chain:[string]
    )
    ;;{3.3}  tables

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
    (defun UC_BFS:object{BFS} (graph:[object{GraphNode}] in:string))
    ;;#65hL: UC_BFS, with an early-exit once <target> has been reached — see the
    ;;defun's own doc for the full rationale. Additive, not a replacement.
    (defun UC_BFSTargeted:object{BFS} (graph:[object{GraphNode}] in:string target:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|BFS GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements BreadthFirstSearchV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                  (compose-capability (GOV|U|BFS_ADMIN)))
    (defcap GOV|U|BFS_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    (defconst BAR (CT_Bar))
    (defconst EQE
        [
            {
                "node":     BAR,
                "chain":    [BAR]
            }
        ]
    )
    (defconst EBFS
        {
            "visited":  [BAR],
            "que":      EQE,
            "chains":   [[BAR]]
        }
    )
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun UDCx_ExtendChain:object{BreadthFirstSearchV1.QE} (input:object{BreadthFirstSearchV1.QE} element:string)
        @doc "Extends a Que Element with a new element"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            {
                "node": element,
                "chain": (ref-U|LST::UC_AppL (at "chain" input) element)
            }
        )
    )
    (defun UDCx_AddVisited:object{BreadthFirstSearchV1.BFS} (input:object{BreadthFirstSearchV1.BFS} visited:[string])
        {
            "visited":  (UCx_ExStrLst (at "visited" input) visited),
            "que":      (at "que" input),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_AddToQue:object{BreadthFirstSearchV1.BFS} (input:object{BreadthFirstSearchV1.BFS} que:[object{BreadthFirstSearchV1.QE}])
        {
            "visited":  (at "visited" input),
            "que":      (UCx_ExQeLst (at "que" input) que),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_RmFromQue:object{BreadthFirstSearchV1.BFS} (input:object{BreadthFirstSearchV1.BFS})
        {
            "visited":  (at "visited" input),
            "que":      (UCx_RmFirstQeList (at "que" input)),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_AddChains:object{BreadthFirstSearchV1.BFS} (input:object{BreadthFirstSearchV1.BFS} chains-to-add:[[string]])
        {
            "visited":  (at "visited" input),
            "que":      (at "que" input),
            "chains":   (UCx_ExStrArrLst (at "chains" input) chains-to-add)
        }
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_BFS:object{BreadthFirstSearchV1.BFS} (graph:[object{BreadthFirstSearchV1.GraphNode}] in:string)
        @doc "Implementation of the Breadth First Search Method, outputing a BFS Object, \
        \ which ultimately contains all chains, starting from a specific <in> node"
        (fold
            (lambda
                (acc:object{BreadthFirstSearchV1.BFS} idx:integer)
                (if (= idx 0)
                    (let
                        (
                            (links:[string] (UCx_GraphNodeLinks graph in))
                        )
                        (if (!= links [BAR])
                            (let
                                (
                                    (primal-que:[object{BreadthFirstSearchV1.QE}] (UCx_PrimalQE links in))
                                    (chains-to-add:[[string]] (UCx_GetChains primal-que))
                                    (acc1-visited:object{BreadthFirstSearchV1.BFS} (UDCx_AddVisited acc (+ [in] links)))
                                    (acc2-que:object{BreadthFirstSearchV1.BFS} (UDCx_AddToQue acc1-visited primal-que))
                                    (acc3-chains:object{BreadthFirstSearchV1.BFS} (UDCx_AddChains acc2-que chains-to-add))
                                )
                                acc3-chains
                            )
                            EBFS
                        )
                    )
                    (if (!= acc EBFS)
                        (let
                            (
                                (first-qe:object{BreadthFirstSearchV1.QE} (at 0 (at "que" acc)))
                                (first-qe-node:string (at "node" first-qe))
                            )
                            (if (!= first-qe-node BAR)
                                (let
                                    (
                                        (ref-U|LST:module{StringProcessorV1} U|LST)
                                        (first-qe-node-links:[string] (UCx_GraphNodeLinks graph first-qe-node))
                                        (visited:[string] (at "visited" acc))
                                        (not-visited:[string] (UCx_FilterVisited visited first-qe-node-links))
                                        (lnv:integer (length not-visited))
                                        (acc0-rm:object{BreadthFirstSearchV1.BFS} (UDCx_RmFromQue acc))
                                        (new-que:[object{BreadthFirstSearchV1.QE}]
                                            (if (= lnv 0)
                                                EQE
                                                (fold
                                                    (lambda
                                                        (acc:[object{BreadthFirstSearchV1.QE}] idx2:integer)
                                                        (ref-U|LST::UC_AppL
                                                            acc
                                                            (UDCx_ExtendChain first-qe (at idx2 not-visited))
                                                        )
                                                    )
                                                    []
                                                    (enumerate 0 (- (length not-visited) 1))
                                                )
                                            )
                                        )
                                        (chains-to-add:[[string]] (UCx_GetChains new-que))
                                        (acc1-visited:object{BreadthFirstSearchV1.BFS} (UDCx_AddVisited acc0-rm not-visited))
                                        (acc2-que:object{BreadthFirstSearchV1.BFS}
                                            (if (!= chains-to-add [[BAR]])
                                                (UDCx_AddToQue acc1-visited new-que)
                                                acc1-visited
                                            )
                                        )
                                        (acc3-chains:object{BreadthFirstSearchV1.BFS}
                                            (if (!= chains-to-add [[BAR]])
                                                (UDCx_AddChains acc2-que chains-to-add)
                                                acc2-que
                                            )
                                        )
                                    )
                                    acc3-chains
                                )
                                acc
                            )
                        )
                        EBFS
                    )
                )
            )
            EBFS
            (enumerate 0 (- (length graph) 1))
        )
    )
    (defun UC_BFSTargeted:object{BreadthFirstSearchV1.BFS} (graph:[object{BreadthFirstSearchV1.GraphNode}] in:string target:string)
        @doc "#65hL: <UC_BFS>, with one addition — once <target> has been reached \
            \ (added to <visited>), every remaining fold iteration becomes a cheap \
            \ no-op instead of doing real BFS-expansion work, mirroring exactly how \
            \ this same fold ALREADY short-circuits once the queue naturally empties \
            \ (the <first-qe-node == BAR> branch below) — this just makes that same \
            \ short-circuit trigger EARLIER, the moment the caller's actual target is \
            \ found, instead of only once the full reachable set has been exhausted. \
            \ <UC_BFS> itself is unchanged — this is additive, for callers \
            \ (SWPT::URC_ComputeGraphPath and its FromRaw/FromGraph siblings) that \
            \ only ever want ONE specific target's shortest chain, not chains to \
            \ every reachable node — <UC_BFS>'s own callers (and any future one) keep \
            \ getting the full all-chains result, unaffected. \
            \ Correctness: BFS visits nodes in strictly non-decreasing distance order, \
            \ so a node's shortest chain is fixed the FIRST time it's visited — \
            \ skipping further work after <target> is already visited never changes \
            \ what its own chain entry says, only stops recording chains for nodes \
            \ that would have been discarded by the caller's own post-filter anyway. \
            \ Gas shape: the fold itself still always runs exactly <length graph> \
            \ times (Pact's fold has no native early-return) — the win is in how many \
            \ of those iterations do REAL (expensive, O(V) neighbor-lookup) work \
            \ before the cheap no-op path takes over, which is proportional to how \
            \ many BFS rounds it takes to reach <target> — the closer the target, \
            \ the fewer real iterations run, not a reduction in total iteration count."
        (fold
            (lambda
                (acc:object{BreadthFirstSearchV1.BFS} idx:integer)
                (if (= idx 0)
                    (let
                        (
                            (links:[string] (UCx_GraphNodeLinks graph in))
                        )
                        (if (!= links [BAR])
                            (let
                                (
                                    (primal-que:[object{BreadthFirstSearchV1.QE}] (UCx_PrimalQE links in))
                                    (chains-to-add:[[string]] (UCx_GetChains primal-que))
                                    (acc1-visited:object{BreadthFirstSearchV1.BFS} (UDCx_AddVisited acc (+ [in] links)))
                                    (acc2-que:object{BreadthFirstSearchV1.BFS} (UDCx_AddToQue acc1-visited primal-que))
                                    (acc3-chains:object{BreadthFirstSearchV1.BFS} (UDCx_AddChains acc2-que chains-to-add))
                                )
                                acc3-chains
                            )
                            EBFS
                        )
                    )
                    (if (contains target (at "visited" acc))
                        acc
                        (if (!= acc EBFS)
                            (let
                                (
                                    (first-qe:object{BreadthFirstSearchV1.QE} (at 0 (at "que" acc)))
                                    (first-qe-node:string (at "node" first-qe))
                                )
                                (if (!= first-qe-node BAR)
                                    (let
                                        (
                                            (ref-U|LST:module{StringProcessorV1} U|LST)
                                            (first-qe-node-links:[string] (UCx_GraphNodeLinks graph first-qe-node))
                                            (visited:[string] (at "visited" acc))
                                            (not-visited:[string] (UCx_FilterVisited visited first-qe-node-links))
                                            (lnv:integer (length not-visited))
                                            (acc0-rm:object{BreadthFirstSearchV1.BFS} (UDCx_RmFromQue acc))
                                            (new-que:[object{BreadthFirstSearchV1.QE}]
                                                (if (= lnv 0)
                                                    EQE
                                                    (fold
                                                        (lambda
                                                            (acc:[object{BreadthFirstSearchV1.QE}] idx2:integer)
                                                            (ref-U|LST::UC_AppL
                                                                acc
                                                                (UDCx_ExtendChain first-qe (at idx2 not-visited))
                                                            )
                                                        )
                                                        []
                                                        (enumerate 0 (- (length not-visited) 1))
                                                    )
                                                )
                                            )
                                            (chains-to-add:[[string]] (UCx_GetChains new-que))
                                            (acc1-visited:object{BreadthFirstSearchV1.BFS} (UDCx_AddVisited acc0-rm not-visited))
                                            (acc2-que:object{BreadthFirstSearchV1.BFS}
                                                (if (!= chains-to-add [[BAR]])
                                                    (UDCx_AddToQue acc1-visited new-que)
                                                    acc1-visited
                                                )
                                            )
                                            (acc3-chains:object{BreadthFirstSearchV1.BFS}
                                                (if (!= chains-to-add [[BAR]])
                                                    (UDCx_AddChains acc2-que chains-to-add)
                                                    acc2-que
                                                )
                                            )
                                        )
                                        acc3-chains
                                    )
                                    acc
                                )
                            )
                            EBFS
                        )
                    )
                )
            )
            EBFS
            (enumerate 0 (- (length graph) 1))
        )
    )
    (defun UCx_GraphNodeLinks:[string] (graph:[object{BreadthFirstSearchV1.GraphNode}] node:string)
        @doc "Scans a Graph for a Node, outputing its links. \
            \ #38M/M4 fix: single-pass <filter> directly over <graph>, matching by \
            \ the \"node\" field, replacing the old rebuild-the-whole-name-list \
            \ (UCx_GraphNodes) + linear search (UC_Search) + re-index-by-position \
            \ chain — that old path did two full O(V) passes plus a reindex per \
            \ call; this does one. Same O(V) cost per lookup either way (Pact has \
            \ no O(1) hash-index over a plain list argument, so a full BFS \
            \ traversal stays O(V^2) overall), but roughly halves the constant \
            \ factor, measured live (see ROUND-02-FIXES.md Fix #24). Tie-break \
            \ preserved exactly: first matching entry by original <graph> order, \
            \ same as the old UC_Search-based lookup. <filter> is empty-list-safe \
            \ by construction, so the #37M/M3-style length guard isn't needed \
            \ here. UCx_GraphNodes (its only caller) removed as dead code."
        (let
            (
                (matches:[object{BreadthFirstSearchV1.GraphNode}]
                    (filter
                        (lambda (gn:object{BreadthFirstSearchV1.GraphNode}) (= (at "node" gn) node))
                        graph
                    )
                )
            )
            (if (= 0 (length matches))
                [BAR]
                (at "links" (at 0 matches))
            )
        )
    )
    (defun UCx_PrimalQE:[object{BreadthFirstSearchV1.QE}] (links:[string] node:string)
        @doc "Computes the Primal Que Elements in a BFS Object, which is the first Que Element that is created"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[object{BreadthFirstSearchV1.QE}] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        {
                            "node":     (at idx links),
                            "chain":    [node, (at idx links)]
                        }
                    )
                )
                []
                (enumerate 0 (- (length links) 1))
            )
        )
    )
    (defun UCx_GetChains:[[string]] (input:[object{BreadthFirstSearchV1.QE}])
        @doc "Extracts a list of chains from a list of Que Objects"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[[string]] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (at "chain" (at idx input))
                    )
                )
                []
                (enumerate 0 (- (length input) 1))
            )
        )
    )
    (defun UCx_FilterVisited:[string] (visited:[string] new-nodes:[string])
        @doc "Filters a list of new-nodes by a list of visited nodes"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (let
                        (
                            (elem:string (at idx new-nodes))
                            (iz-visited:bool (contains elem visited))
                        )
                        (if iz-visited
                            (ref-U|LST::UC_RemoveItem acc elem)
                            acc
                        )
                    )
                )
                new-nodes
                (enumerate 0 (- (length new-nodes) 1))
            )
        )
    )
    (defun UCx_ExStrLst:[string] (to-extend:[string] elements:[string])
        (if (= [BAR] to-extend)
            elements
            (+ to-extend elements)
        )
    )
    (defun UCx_ExQeLst:[object{BreadthFirstSearchV1.QE}] (input:[object{BreadthFirstSearchV1.QE}] que-element:[object{BreadthFirstSearchV1.QE}])
        (if (and (= (at 0 EQE) (at 0 input)) (= (length input) 1))
            que-element
            (+ input que-element)
        )
    )
    (defun UCx_RmFirstQeList:[object{BreadthFirstSearchV1.QE}] (input:[object{BreadthFirstSearchV1.QE}])
        (if (> (length input) 1)
            (drop 1 input)
            EQE
        )
    )
    (defun UCx_ExStrArrLst:[[string]] (to-extend:[[string]] elements:[[string]])
        (if (= [[BAR]] to-extend)
            elements
            (+ to-extend elements)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)