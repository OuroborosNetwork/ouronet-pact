;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapTracerV1
    @doc "Exposes Tracer Functions, needed to compute Paths between Tokens existing on Liquidity Pools"
    ;;
    (defschema Edges
        principal:string
        swpairs:[string]
    )
    ;;
    (defun UC_PSwpairsFTO:[string] (traces:[object{Edges}] id:string principal:string principals-lst:[string]))
    (defun UC_PrincipalsFromTraces:[string] (traces:[object{Edges}]))
    ;;
    (defun UR_PathTrace:[object{Edges}] (id:string))
    ;;
    (defun URC_PathTracer:[object{Edges}] (old-path-tracer:[object{Edges}] id:string swpair:string principals-lst:[string]))
    (defun URC_ContainsPrincipals:bool (swpair:string principals-lst:[string]))
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string] principal-lst:[string]))
    (defun URC_AllGraphPaths:[[string]] (input:string output:string swpairs:[string] principal-lst:[string]))
    (defun URC_MakeGraph:[object{BreadthFirstSearchV1.GraphNode}] (input:string output:string swpairs:[string] principal-lst:[string]))
    (defun URC_TokenNeighbours:[string] (token-id:string principal-lst:[string]))
    (defun URC_TokenSwpairs:[string] (token-id:string principal-lst:[string]))
    (defun URC_PrincipalSwpairs:[string] (id:string principal:string principal-lst:[string]))
    (defun URC_Edges:[string] (t1:string t2:string principal-lst:[string])) ;;1
    (defun URC_EdgesActive:[string] (t1:string t2:string principal-lst:[string] whitelist:[string]))
    ;;
    (defun UEV_IdAsPrincipal (id:string for-trace:bool principals-lst:[string]))
    ;;
    (defun XE_MultiPathTracer (swpair:string principals-lst:[string]))
)
;;
(module SWPT GOV
    ;;
    (implements OuronetPolicyV1)
    (implements SwapTracerV1)
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
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
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
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SWPT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
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
    (defun P|A_Define ()
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
    (defschema SWPT|TracerSchema
        links:[object{SwapTracerV1.Edges}]
    )
    ;;{2}
    (deftable SWPT|Tracer:{SWPT|TracerSchema})
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    (defconst NLE [NLEO])
    (defconst NLEO
        { "principal" : BAR
        , "swpairs"   : [BAR]}
    )
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
    (defun UC_PSwpairsFTO:[string] (traces:[object{SwapTracerV1.Edges}] id:string principal:string principals-lst:[string])
        @doc "Principal Swpairs From Trace Object: given a trace object, id and principal, output the stored swpairs\
        \ UTILS.BAR can be used as principal, returning swpairs that contain no principals. \
        \ Swpairs that contain no principals, can only be stable swap pairs."
        (UEV_IdAsPrincipal principal true principals-lst)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (principals-from-traces:[string] (UC_PrincipalsFromTraces traces))
                (search:[integer] (ref-U|LST::UC_Search principals-from-traces principal))
            )
            (if (!= (length search) 0)
                (at "swpairs" (at (at 0 search) traces))
                [BAR]
            )
        )
    )
    (defun UC_PrincipalsFromTraces:[string] (traces:[object{SwapTracerV1.Edges}])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (at "principal" (at idx traces))
                    )
                )
                []
                (enumerate 0 (- (length traces) 1))
            )
        )
    )
    ;;{F0}  [UR]
    (defun UR_PathTrace:[object{SwapTracerV1.Edges}] (id:string)
        (at "links" (read SWPT|Tracer id ["links"]))
    )
    ;;{F1}  [URC]
    (defun URC_PathTracer:[object{SwapTracerV1.Edges}] (old-path-tracer:[object{SwapTracerV1.Edges}] id:string swpair:string principals-lst:[string])
        "Computes a new Path-tracer object list, given <old-path-tracer> object, token-id <id> and Swap-Pair <swpair>"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (swpair-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (has-principals:bool (URC_ContainsPrincipals swpair principals-lst))
                (current-element-zero-swpairs:[string] (UC_PSwpairsFTO old-path-tracer id BAR principals-lst))
                (new-element-zero-swpairs:[string]
                    (if (= current-element-zero-swpairs [BAR])
                        (if has-principals
                            [BAR]
                            [swpair]
                        )
                        (if has-principals
                            current-element-zero-swpairs
                            (ref-U|LST::UC_AppL current-element-zero-swpairs swpair)
                        )
                    )
                )
                (element-zero:object{SwapTracerV1.Edges}
                    { "principal" : BAR , "swpairs" : new-element-zero-swpairs}
                )
            )
            (fold
                (lambda
                    (acc:[object{SwapTracerV1.Edges}] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (let
                            (
                                (current-element-swpairs:[string] (UC_PSwpairsFTO old-path-tracer id (at idx principals-lst) principals-lst))
                                (lopt:integer (length old-path-tracer))
                                (iz-principal-on-swpair:bool (contains (at idx principals-lst) swpair-tokens))
                                (check:bool iz-principal-on-swpair)
                                (swpairs-to-add:[string]
                                    (if (= lopt 1)
                                        (if check
                                            [swpair]
                                            [BAR]
                                        )
                                        (if check
                                            (ref-U|LST::UC_AppL current-element-swpairs swpair)
                                            current-element-swpairs
                                        )
                                    )
                                )
                                (filtered-swpairs-to-add:[string]
                                    (if (= swpairs-to-add [BAR])
                                        swpairs-to-add
                                        (if (= (at 0 swpairs-to-add) BAR)
                                            (drop 1 swpairs-to-add)
                                            swpairs-to-add
                                        )
                                    )
                                )
                            )
                            {
                                "principal" : (at idx principals-lst),
                                "swpairs"   : filtered-swpairs-to-add
                            }
                        )
                    )
                )
                [element-zero]
                (enumerate 0 (- (length principals-lst) 1))
            )
        )
    )
    (defun URC_ContainsPrincipals:bool (swpair:string principals-lst:[string])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (swpair-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
            )
            (fold
                (lambda
                    (acc:bool idx:integer)
                    (or
                        acc
                        (contains (at idx swpair-tokens) principals-lst)
                    )
                )
                false
                (enumerate 0 (- (length swpair-tokens) 1))
            )
        )
    )
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string] principal-lst:[string])
        @doc "Computes the path between an <input> and <output> using BFS via <URC_AllGraphPaths> \
        \ from a passed down list of existing <swpairs>. \
        \ #20H fix: returns the clean [BAR] sentinel — never a bare out-of-bounds \
        \ <at> crash — whenever no chain reaches <output>, including the case of a \
        \ genuinely disconnected pair once <swpairs> has been narrowed upstream \
        \ (e.g. to active-only pools, #19H)."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (all-paths:[[string]] (URC_AllGraphPaths input output swpairs principal-lst))

            )
            (if (!= all-paths [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx all-paths))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                all-paths
                                (enumerate 0 (- (length all-paths) 1))
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
    (defun URC_AllGraphPaths:[[string]] (input:string output:string swpairs:[string] principal-lst:[string])
        @doc "Computes all paths that exist in a Graph defined from <input> ids, <output> ids \
        \ over a specific passed-down list of existing <swpairs>"
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV1} U|BFS)
                (graph:[object{BreadthFirstSearchV1.GraphNode}] (URC_MakeGraph input output swpairs principal-lst))
                (bfs-obj:object{BreadthFirstSearchV1.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_MakeGraph:[object{BreadthFirstSearchV1.GraphNode}] (input:string output:string swpairs:[string] principal-lst:[string])
        @doc "#13C fix (2nd layer) + #19H fix (2nd layer): <URC_TokenNeighbours> \
            \ reads the FULL, live <SWPT|Tracer> table directly — it has no \
            \ notion of the caller's <swpairs> universe at all. Two problems \
            \ follow, both closed here: \
            \ 1] (#13C) A neighbor reachable only through a swpair OUTSIDE \
            \    <swpairs> would otherwise be returned as a link with no \
            \    matching <GraphNode> entry in <nodes> at all. \
            \ 2] (#19H) A neighbor token can be a perfectly valid node overall \
            \    (has SOME active pool elsewhere) while the ONLY swpair directly \
            \    connecting it to THIS node is outside <swpairs> (e.g. disabled) \
            \    — merely checking 'is this token a valid node' (#1's fix) does \
            \    NOT catch this, since the neighbor token legitimately belongs \
            \    to <nodes> via its other pools. BFS would still treat the two \
            \    as directly linked, discover a 'path' through a non-existent \
            \    active edge, and crash downstream in <SWPI::URC_BestEdgeFiltered> \
            \    when no active edge is actually found. \
            \ Requiring a genuine <URC_EdgesActive> match (not just <nodes> \
            \ membership) between each node and its candidate neighbor closes \
            \ both — and subsumes the plain membership check, since any real \
            \ active edge implies both endpoints are already valid nodes."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (fold
                (lambda
                    (acc:[object{BreadthFirstSearchV1.GraphNode}] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        {
                            "node": (at idx nodes),
                            "links":
                                (filter
                                    (lambda (n:string) (!= (URC_EdgesActive (at idx nodes) n principal-lst swpairs) []))
                                    (URC_TokenNeighbours (at idx nodes) principal-lst)
                                )
                        }
                    )
                )
                []
                (enumerate 0 (- (length nodes) 1))
            )
        )
    )
    (defun URC_TokenNeighbours:[string] (token-id:string principal-lst:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (token-swpairs:[string] (URC_TokenSwpairs token-id principal-lst))
                (unique-tokens:[string] (ref-U|SWP::UC_UniqueTokens token-swpairs))
            )
            (ref-U|LST::UC_RemoveItem unique-tokens token-id)
        )
    )
    (defun URC_TokenSwpairs:[string] (token-id:string principal-lst:[string])
        @doc "Reads all swpairs attached to the <token-id> and outputs them into a string list \
        \ Requires a list of principals through <principal-lst>"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (cp:[string] (ref-U|LST::UC_InsertFirst principal-lst BAR))
                (swpairs-array:[[string]]
                    (fold
                        (lambda
                            (acc:[[string]] idx:integer)
                            (let
                                (
                                    (swpairs:[string] (URC_PrincipalSwpairs token-id (at idx cp) principal-lst))
                                    (u2:[string] [BAR])
                                )
                                (if (!= swpairs u2)
                                    (ref-U|LST::UC_AppL
                                        acc
                                        swpairs
                                    )
                                    acc
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length cp) 1))
                    )
                )
            )
            (fold (+) [] swpairs-array)
        )
    )
    (defun URC_PrincipalSwpairs:[string] (id:string principal:string principal-lst:[string])
        (UC_PSwpairsFTO (UR_PathTrace id) id principal principal-lst)
    )
    (defun URC_Edges:[string] (t1:string t2:string principal-lst:[string])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (swp1:[string] (URC_TokenSwpairs t1 principal-lst))
                (swp2:[string] (URC_TokenSwpairs t2 principal-lst))
                (swps:[string] (+ swp1 swp2))
                (d:[string] (distinct swps))
            )
            (ref-U|SWP::UC_FilterTwo d t1 t2)
        )
    )
    (defun URC_EdgesActive:[string] (t1:string t2:string principal-lst:[string] whitelist:[string])
        @doc "Same as <URC_Edges>, but the result is restricted to swpairs also \
            \ present in <whitelist> (e.g. <SWP::URC_ActiveSwpairs>) — so a \
            \ disabled parallel pool between the same token pair is never offered \
            \ as an edge candidate to <SWPI::URC_BestEdgeFiltered>. #19H fix."
        (filter (lambda (swpair:string) (contains swpair whitelist)) (URC_Edges t1 t2 principal-lst))
    )
    ;;{F2}  [UEV]
    (defun UEV_IdAsPrincipal (id:string for-trace:bool principals-lst:[string])
        (let
            (
                (iz-principal:bool (contains id principals-lst))
            )
            (if for-trace
                (enforce (or iz-principal (= id BAR)) (format "ID {} is not a valid principal for trace operations" [id]))
                (enforce iz-principal (format "ID {} is not a principal" [id]))
            )
        )
    )
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    (defun XE_MultiPathTracer (swpair:string principals-lst:[string])
        (UEV_IMC)
        (with-capability (SECURE)
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                )
                (map
                    (lambda
                        (token:string)
                        (XI_SinglePathTracer token swpair principals-lst)
                    )
                    (ref-U|SWP::UC_TokensFromSwpairString swpair)
                )
            )
        )
    )
    (defun XI_SinglePathTracer (id:string swpair:string principals-lst:[string])
        (require-capability (SECURE))
        (with-default-read SWPT|Tracer id
            { "links" : NLE }
            { "links" := lks }
            (write SWPT|Tracer id
                { "links" : (URC_PathTracer lks id swpair principals-lst)}
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table SWPT|Tracer)