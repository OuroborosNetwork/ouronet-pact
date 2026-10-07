;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 32
;; O-UI-FOURTEEN (FIRST DEPLOY) -- the EarningPools reads, slice 2: scores
;; =========================================================================================
;; A NEW MODULE, so this ships the INTERFACE AND THE MODULE. `OUiFourteenV1` has never been
;; deployed, and a module cannot implement an interface that does not exist on chain -- which
;; is why this file does not take the module-only shape that 26/29/31 did for slice 1.
;;
;; NO TABLES. Every function here is a read over tables the AQP modules already own, so there
;; is no `create-table` to send and nothing to repair if this is re-sent.
;;
;; -----------------------------------------------------------------------------------------
;; WHY A READER MODULE AT ALL
;; -----------------------------------------------------------------------------------------
;; The score data a client needs is spread over four AQP modules and five score classes, and
;; assembling one row of it costs several reads whose SHAPE the client would otherwise have to
;; know. Slice 1 (`O-UI-THIRTEEN`) settled that pattern for anchors; this is the same bargain
;; for scores -- the chain answers in one call what the UI would otherwise stitch together,
;; and the stitching rules live in Pact where a REPL assertion can reach them.
;;
;; -----------------------------------------------------------------------------------------
;; THE SURFACE -- 9 FUNCTIONS, ALL NINE DECLARED
;; -----------------------------------------------------------------------------------------
;; EVERY FUNCTION IS ON THE INTERFACE, and this is the only moment that choice is available.
;; A deployed interface cannot be changed. `OUiThirteenV1` shipped with four of its module's
;; functions undeclared and `URC_13|AnchorFull` is now permanently module-only -- adding it
;; would force a V2 bump for a function only the UI calls, by name, at /local.
;;
;; An earlier draft of this header claimed the four object-returning functions HAD to stay
;; module-only under "the interface object-return rule". That was wrong: the rule bites on
;; `object{Schema}` for a schema defined in the module, and this module defines no schemas --
;; every return is a bare `object`, which 13 itself declares twice. The functions were
;; undeclared by omission, not by rule, and they are declared now.
;;
;;   URC_14|ScoreKind       (score-class)                 -> "lp"|"dptf"|"dpof"|"dpsf"|"dpnf"|"unknown"
;;   URC_14|PoolLabel       (pool-id)                     -> the id's stem; the chain stores no name
;;   URC_14|ScoreDefinition (score-id)                    -> what a score IS, account-independent
;;   URC_14|TripletRungs    (triplet-id)                  -> three ids, or [] for a non-triplet
;;   URH_14|AllScoreEntities ()                           -> the catalogue, one row per score
;;   URC_14|MyScoreInPool   (account pool-id score-id)    -> one position
;;   URC_14|ScoreEntityFull (account pool-id score-id)    -> the detail screen
;;   URH_14|MyPoolIds       (account)                     -> 4 beneficiary scans, deduped
;;   URH_14|MyScoreEntities (account)                     -> one row per (pool, score), zeros dropped
;;
;; -----------------------------------------------------------------------------------------
;; THE TWO-HOP ASSET RESOLUTION, which is the part most likely to be reimplemented wrongly
;; -----------------------------------------------------------------------------------------
;; A SCORE CARRIES NO ASSET. `SCR|Schema` says so in as many words:
;;
;;     "No separate scr-asset on the score. Staking asset is defined on the AQP pool.
;;      Resolve Score -> aqpool-link -> Pool -> asset-id."
;;
;; So `asset-id` is derived, not read, and it is derived HERE so that four clients cannot each
;; get it wrong. A score employed by no pool answers BAR rather than aborting -- that is a real
;; and showable state, and a reader that died on it would take the whole catalogue down.
;;
;; THE AGGREGATOR'S CLASS comes from RPS (`UR_FVT|FvtClass`) and answers -1 for a score admitted
;; nowhere. -1 is a SENTINEL, not a class: a client reading it as 0 would render a FARM for a
;; score that earns nothing.
;;
;; THERE IS NO FVT NAME ON CHAIN -- no field, no reader, anywhere in the tree. The client
;; derives a label from the id's stem, exactly as it does for pools and scores.
;;
;; -----------------------------------------------------------------------------------------
;; TWO BEHAVIOURS WORTH KNOWING BEFORE READING THE OUTPUT
;; -----------------------------------------------------------------------------------------
;; AN OUT-OF-RANGE SCORE CLASS ANSWERS "unknown" RATHER THAN ABORTING. This is a display
;; label, and a reader that kills a whole page over one odd row is worse than one that says
;; so. `URC_14|ScoreKind` is the only function here that swallows anything.
;;
;; ZERO HOLDINGS ARE DROPPED, not returned as zeros. `URH_14|MyScoreEntities` scans every pool
;; the account stakes in against every score defined, which is a cross product most of whose
;; cells are empty. The filter is what makes the result a list of what you HAVE.
;;
;; VACATE-v2 LAZY INVALIDATION IS NOT HANDLED HERE AND DOES NOT NEED TO BE. When a pool's
;; `stamped-generation < vacate-generation` the user-score values read as ZERO, and that is
;; decided inside `AQP-SCORE`'s own `UR_U-SCR|UserScore` -- this module reads through it, so a
;; vacated holding arrives as zero and is then dropped by the filter above.
;;
;; -----------------------------------------------------------------------------------------
;; A DELIBERATE GAP
;; -----------------------------------------------------------------------------------------
;; THE REWARD LADDERS VIEW IS NOT SERVED BY THIS MODULE, and cannot be yet: there is no
;; sovereign enumerator for FVTs or MultipletFamilies, so nothing can list the ladders to read
;; them. It needs `URH_FVT|AllFvtIds` in `05_FVT` or a family enumerator in `04_RPS`, neither
;; of which exists. The two views this module serves do not depend on it.
;;
;; AQP HAS EXACTLY FOUR GLOBAL ENUMERATORS -- anchors, boost classes, scores, pools -- and
;; every catalogue here is built from those four. That is the boundary, not an oversight in
;; this file.
;;
;; -----------------------------------------------------------------------------------------
;; PROVEN BEFORE SENDING
;; -----------------------------------------------------------------------------------------
;; 14 assertions under `AQP-FULL.repl`, 0 failures. The pair that matters:
;;
;;   <<OUI14-S3>>  EMMA, who stakes nothing, is in no pool and holds no score entity
;;   <<OUI14-S4>>  ANHD, who stakes, IS in a pool, holds >=1 entity, every row names its
;;                 pool and score, no row is a zero holding, and every final is >= 0
;;
;; S4 exists BECAUSE S3 alone would pass for a reader that always returns nothing. An
;; emptiness assertion cannot distinguish a correct filter from a broken scan.
;;
;; -----------------------------------------------------------------------------------------
;; SIGNING / VERIFY
;; -----------------------------------------------------------------------------------------
;; `GOV|O_UI_FOURTEEN_ADMIN` (the Demiurgoi keyset, same as every AppReads module). The
;; interface needs no signature beyond namespace write. Afterwards, as /local reads:
;;
;;   (ouronet-ns.O-UI-FOURTEEN.URC_14|ScoreKind 0)   -> "lp"
;;   (ouronet-ns.O-UI-FOURTEEN.URC_14|ScoreKind 4)   -> "dpnf"
;;   (ouronet-ns.O-UI-FOURTEEN.URC_14|ScoreKind 99)  -> "unknown"
;;   (length (ouronet-ns.O-UI-FOURTEEN.URH_14|AllScoreEntities))
;;     -> must equal EXACTLY (length (ouronet-ns.AQP-SCORE.URH_SCR|AllScoreIds)). The
;;        catalogue is a straight `map` over that enumerator -- one row per score, no more and
;;        no fewer. A triplet does NOT add rows; it adds a `rungs` field to the rows it owns.
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact
(interface OUiFourteenV1
    @doc "Read surface for the EarningPools SCORE views, client side."

    ;;THE WHOLE SURFACE IS DECLARED HERE, DELIBERATELY, AND THIS IS THE ONE CHANCE TO DO IT.
    ;;
    ;;A deployed interface cannot be changed. `OUiThirteenV1` shipped with four of its module's
    ;;functions undeclared, and `URC_13|AnchorFull` is now permanently module-only -- adding it
    ;;would force a V2 bump for a function only the UI calls, by name, at /local. Its own
    ;;source carries the note.
    ;;
    ;;`OUiFourteenV1` has NOT been deployed, so every function the client actually calls is
    ;;declared now while that is still possible. A bare `object` return is fine in an interface
    ;;(13 declares two); the rule that keeps a function module-only is `object{Schema}` for a
    ;;schema defined in the MODULE, and this module defines no schemas at all.
    (defun URC_14|ScoreKind:string (score-class:integer))
    (defun URC_14|PoolLabel:string (pool-id:string))
    (defun URC_14|ScoreDefinition:object (score-id:string))
    (defun URC_14|TripletRungs:[string] (triplet-id:string))
    (defun URH_14|AllScoreEntities:[object] ())
    (defun URC_14|MyScoreInPool:object (account:string pool-id:string score-id:string))
    (defun URC_14|ScoreEntityFull:object (account:string pool-id:string score-id:string))
    (defun URH_14|MyPoolIds:[string] (account:string))
    (defun URH_14|MyScoreEntities:[object] (account:string))
)

(module O-UI-FOURTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiFourteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-FOURTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_FOURTEEN_ADMIN)))
    (defcap GOV|O_UI_FOURTEEN_ADMIN ()      (enforce-guard GOV|MD_O-UI-FOURTEEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{2}  CONSTANTS
    ;;The five score classes, in the order `C_Issue*Score` assigns them. Named here because the
    ;;chain stores an integer and a client showing "class 3" tells a user nothing.
    (defconst CT_14_SCORE_KINDS:[string] ["lp" "dptf" "dpof" "dpsf" "dpnf"])

    ;;{5.3}  Read

    (defun URC_14|ScoreKind:string (score-class:integer)
        @doc "The score's asset kind, named. 0 LP, 1 DPTF, 2 DPOF, 3 DPSF, 4 DPNF -- the order \
            \ `C_IssueLpScore` .. `C_IssueNonFungibleScore` assign. An out-of-range class answers \
            \ \"unknown\" rather than aborting: this is a display label, and a reader that kills \
            \ the whole page over one odd row is worse than one that says so."
        (if (and (>= score-class 0) (< score-class (length CT_14_SCORE_KINDS)))
            (at score-class CT_14_SCORE_KINDS)
            "unknown")
    )

    (defun URC_14|PoolLabel:string (pool-id:string)
        @doc "A pool's human label. THE CHAIN STORES NONE -- `AQP|Schema` has no name field, and \
            \ the id's stem is what the operator typed at issuance, so it is the only human \
            \ string there is. Same rule the anchors slice uses for an anchor's label."
        (let ((ref-U|LST:module{StringProcessorV2} U|LST))
            ;;`UC_SplitString` takes the SPLITTER first and the subject second -- the opposite
            ;;order to the obvious guess, and an argument order a type checker cannot catch
            ;;because both are strings.
            (at 0 (ref-U|LST::UC_SplitString "-" pool-id))
        )
    )

    (defun URC_14|ScoreDefinition:object (score-id:string)
        @doc "A score's DEFINITION -- what it is, independent of any account. Shared by the \
            \ catalogue and by every per-user row, so the two can never disagree about what a \
            \ score is while disagreeing only about whose numbers are shown."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (let
                (
                    (triplet-id:string (ref-SCR::UR_SCR|ScoreTripletId score-id))
                    (aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
                )
                {"score-id"        : score-id
                ;;The id IS the name. `SCR|Schema` has no name field and the issuing entrypoints
                ;;take a human string as the id's stem.
                ,"label"           : (URC_14|PoolLabel score-id)
                ,"owner"           : (ref-SCR::UR_SCR|ScoreOwnerKonto score-id)
                ,"score-class"     : (ref-SCR::UR_SCR|ScoreClass score-id)
                ,"kind"            : (URC_14|ScoreKind (ref-SCR::UR_SCR|ScoreClass score-id))
                ,"precision"       : (ref-SCR::UR_SCR|ScorePrecision score-id)
                ;;SINGULAR AND PERMANENT. A BAR fvt-link means this score is admitted NOWHERE and
                ;;therefore earns nobody anything -- a state the catalogue must be able to show,
                ;;because a perfectly well-defined score can be economically inert.
                ,"fvt-link"        : (ref-SCR::UR_SCR|ScoreFvtLink score-id)
                ,"boost-class-link": (ref-SCR::UR_SCR|ScoreBoostClassLink score-id)
                ,"deb-boost"       : (ref-SCR::UR_SCR|ScoreDebBoost score-id)
                ,"in-triplet"      : (ref-SCR::UR_SCR|ScoreTriplet score-id)
                ,"triplet-id"      : triplet-id
                ;;A DIRECT READER, NOT A DERIVATION. A TRUE triplet is one whose rungs form a
                ;;closed boost ring, and it matters to a client for one reason: its weight comes
                ;;from maintained LANE WEIGHTS rather than a deb product, so it is
                ;;deb-independent, cannot go stale, and `CC_UnstaleMyScores` no-ops on it. The
                ;;first draft of this field inferred the property from the three rungs'
                ;;boost-links; `UR_SCR|TripletTrueTriplet` answers it outright.
                ,"true-triplet"    : (if (ref-SCR::URC_TripletExists triplet-id)
                                         (ref-SCR::UR_SCR|TripletTrueTriplet triplet-id)
                                         false)
                ;;THE STAKING ASSET IS NOT ON THE SCORE. `SCR|Schema` says so in as many words:
                ;;"No separate scr-asset on the score. Staking asset is defined on the AQP pool.
                ;;Resolve Score -> aqpool-link -> Pool -> asset-id." So this is a two-hop
                ;;resolution, and it is done HERE so that four clients cannot each get it wrong.
                ;;
                ;;A BAR aqpool-link means the score is employed by no pool, which is a real and
                ;;showable state -- not an error -- so the asset answers BAR rather than aborting.
                ,"aqpool-link"     : aqpool
                ,"asset-id"        : (if (= aqpool (ref-U|CT::CT_BAR))
                                         (ref-U|CT::CT_BAR)
                                         (ref-AQP::UR_AQP|PoolAssetId aqpool))
                ;;THE AGGREGATOR'S CLASS -- farm(0) / vault(1) / treasury(2). Read from RPS,
                ;;which owns the FVT row. Guarded on the link for the same reason as the asset:
                ;;a score admitted nowhere has no aggregator to have a class.
                ;;
                ;;THERE IS NO FVT NAME ON CHAIN, anywhere -- no field and no reader. The client
                ;;derives a label from the id's stem, exactly as it does for pools and scores.
                ,"fvt-class"       : (if (= (ref-SCR::UR_SCR|ScoreFvtLink score-id)
                                            (ref-U|CT::CT_BAR))
                                         -1
                                         (ref-RPS::UR_FVT|FvtClass
                                             (ref-SCR::UR_SCR|ScoreFvtLink score-id)))
                ;;TOTALS ACROSS EVERYBODY, not this account's. Shown so a holder can see what
                ;;share of a score they hold, which a bare personal figure cannot convey.
                ,"total-base"      : (ref-SCR::UR_SCR|ScoreTotalBaseScore score-id)
                ,"total-deb"       : (ref-SCR::UR_SCR|ScoreTotalDebScore score-id)
                ,"holders"         : (ref-SCR::UR_SCR|ScoreNzsCount score-id)}
            )
        )
    )

    (defun URC_14|TripletRungs:[string] (triplet-id:string)
        @doc "A triplet's three score ids in SLOT order. The slots are ids only, NOT boost roles \
            \ -- the schema says so in as many words -- so bronze/silver/golden here name \
            \ positions and imply no ranking. Answers an empty list for a non-triplet rather \
            \ than aborting, so a caller can ask unconditionally."
        (let ((ref-SCR:module{AcquisitionScoresV1} AQP-SCORE))
            (if (ref-SCR::URC_TripletExists triplet-id)
                [(ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id)
                 (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id)
                 (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id)]
                [])
        )
    )

    (defun URH_14|AllScoreEntities:[object] ()
        @doc "B view -- every score entity on chain, with its definition and its triplet \
            \ membership. \
            \ \
            \ TRIPLETS ARE DERIVED, NOT ENUMERATED. `SCR|T|Triplet` has no enumerator, but every \
            \ score carries `triplet-id`, so walking the scores finds every triplet that has a \
            \ member -- which is every triplet that can matter to anyone. A triplet with no \
            \ member scores would be invisible here and is also inert."
        (let ((ref-SCR:module{AcquisitionScoresV1} AQP-SCORE))
            (map (lambda (s:string)
                     (let ((def:object (URC_14|ScoreDefinition s)))
                         (+ def {"rungs": (URC_14|TripletRungs (at "triplet-id" def))})))
                 (ref-SCR::URH_SCR|AllScoreIds))
        )
    )

    (defun URC_14|MyScoreInPool:object (account:string pool-id:string score-id:string)
        @doc "One account's standing in ONE score of ONE pool, with the definition alongside. \
            \ \
            \ The three figures are BASE, BOOST and the deb-multiplied TOTAL -- see the module \
            \ header: `boosted-score` is the BOOST, not a running total. `deb-multiplier` is \
            \ derived rather than read because the chain stores no such field; it is what the \
            \ tier did to (base + boost), and 1.0 when there is nothing to divide."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (let
                (
                    (base:decimal (ref-SCR::UR_U-SCR|UserScoreBaseScore account pool-id score-id))
                    (boost:decimal (ref-SCR::UR_U-SCR|UserScoreBoostedScore account pool-id score-id))
                    (deb:decimal (ref-SCR::UR_U-SCR|UserScoreDebScore account pool-id score-id))
                )
                (+ (URC_14|ScoreDefinition score-id)
                   {"pool-id"        : pool-id
                   ,"pool-label"     : (URC_14|PoolLabel pool-id)
                   ,"base"           : base
                   ,"boost"          : boost
                   ,"final"          : deb
                   ,"deb-multiplier" : (if (> (+ base boost) 0.0)
                                           (/ deb (+ base boost))
                                           1.0)
                   ;;THE RUNGS, so a per-user row is as identifiable as a catalogue row. The
                   ;;slots are IDS ONLY and imply no ranking -- the schema is explicit that
                   ;;bronze/silver/golden are positions, not boost roles. Empty for a single
                   ;;score, which is what `URC_14|TripletRungs` answers for a BAR triplet-id.
                   ,"rungs"          : (URC_14|TripletRungs
                                           (ref-SCR::UR_SCR|ScoreTripletId score-id))
                   ;;THE REPAIR FLAG, read rather than inferred. A client that guessed staleness
                   ;;from the numbers would be wrong both ways: a legitimately zero score looks
                   ;;stale, and a stale one that happens to match looks fresh.
                   ,"needs-sync"     : (ref-SCR::URC_U-SCR|UserScoreDebStale account pool-id score-id)})
            )
        )
    )

    (defun URC_14|ScoreEntityFull:object (account:string pool-id:string score-id:string)
        @doc "ONE score entity, in full -- the screen behind a row click. \
            \ \
            \ It is `URC_14|MyScoreInPool` plus the fields that only a detail view needs, and \
            \ it is a SEPARATE function for a cost reason rather than a tidiness one: these \
            \ extra reads are per-entity, and folding them into the shared definition would \
            \ multiply them across every row of the catalogue and of the A view. \
            \ \
            \ WHAT IT CANNOT ANSWER, and the client must not pretend otherwise: \
            \ \
            \ - `my-stamped-generation`. `AcquisitionScoresV1` declares \
            \   `UR_SCR|ScoreVacateGeneration` for the SCORE but no stamped-generation reader \
            \   for the USER row, so the pair cannot be shown side by side. This is not a loss: \
            \   `URC_U-SCR|UserScoreDebStale` already answers the only decidable question -- is \
            \   my row invalidated -- and the raw counters were informational either way. \
            \ \
            \ - the BOOST SOURCES and the account's aggregate promille. Those live in AQP-ANK \
            \   and are the anchors slice's subject; `O-UI-THIRTEEN` answers them. A client \
            \   wanting both asks for both in ONE request, which costs one round trip, rather \
            \   than this module reaching across a boundary it has no reason to own."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (+ (URC_14|MyScoreInPool account pool-id score-id)
               {;;THE [Mu] MANAGEMENT FLAGS. `can-upgrade` false means the score's settings are
                ;;frozen for good -- a manager pressing an edit button would be refused by the
                ;;chain, so the client disables it instead of charging for the refusal.
                "can-upgrade"       : (ref-SCR::UR_SCR|ScoreCanUpgrade score-id)
               ,"can-change-owner"  : (ref-SCR::UR_SCR|ScoreCanChangeOwner score-id)
               ,"i-am-owner"        : (= account (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                ;;A FOREIGN BOOST-LINK CHANGES WHAT EVERY NUMBER MEANS. When non-BAR, the
                ;;promille is applied to ANOTHER score's user base and this row holds only the
                ;;surplus -- so a client showing base+boost without saying so is showing a
                ;;figure that does not mean what the label claims. BAR = own base, the normal
                ;;case, and never this score itself (`SCR|C>CREATE-BOOST-LINK-SCORE` forbids it).
               ,"boost-link"        : (ref-SCR::UR_SCR|ScoreBoostLink score-id)
                ;;THE THIRD TOTAL. The definition carries total-base and total-deb; the boosted
                ;;total completes the decomposition the module header spells out:
                ;;   base-deb + boosted-deb = deb-score.
               ,"total-boosted"     : (ref-SCR::UR_SCR|ScoreTotalBoostedScore score-id)
                ;;VACATE-v2, SHOWN BECAUSE A USER WHOSE WEIGHT VANISHED HAS NO OTHER EXPLANATION.
                ;;A fast-vacate bumps this counter and every user row stamped below it reads as
                ;;zero until re-staked. Without the counter on screen the page just shows zero.
               ,"vacate-generation" : (ref-SCR::UR_SCR|ScoreVacateGeneration score-id)
                ;;MY SHARE OF THE WHOLE SCORE, in promille, derived here so four clients cannot
                ;;each divide differently. -1.0 when the score's total is zero: there is no
                ;;share of nothing, and 0.0 would read as "you hold none of a populated score".
               ,"my-share-promille" : (let
                                          (
                                              (mine:decimal (ref-SCR::UR_U-SCR|UserScoreDebScore
                                                                account pool-id score-id))
                                              (whole:decimal (ref-SCR::UR_SCR|ScoreTotalDebScore
                                                                score-id))
                                          )
                                          (if (> whole 0.0)
                                              (* 1000.0 (/ mine whole))
                                              -1.0))
                ;;ECHOED so a detail response is self-describing: a client that cached it knows
                ;;which account it belongs to without keeping the request alongside.
               ,"account"           : account
               ,"bar"               : (ref-U|CT::CT_BAR)}
            )
        )
    )

    (defun URH_14|MyPoolIds:[string] (account:string)
        @doc "Every pool this account is a BENEFICIARY in, across all four asset kinds, deduped. \
            \ Four scans, one per tracker table -- there is no single staking table and a pool \
            \ can hold legs of more than one kind, so a stake in any of them puts the account in \
            \ that pool exactly once."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (distinct
                (map (lambda (r:object) (at "pool-id" r))
                     (+ (+ (ref-AQP::URH_AQP|DptfStakesByBeneficiary account)
                           (ref-AQP::URH_AQP|DpofStakesByBeneficiary account))
                        (+ (ref-AQP::URH_AQP|DpsfStakesByBeneficiary account)
                           (ref-AQP::URH_AQP|DpnfStakesByBeneficiary account)))))
        )
    )

    (defun URH_14|MyScoreEntities:[object] (account:string)
        @doc "A view -- every score this account holds a position in, one row per \
            \ (pool, score) pair. \
            \ \
            \ ONE ROW PER PAIR, NOT PER SCORE, because the chain keys the standing that way: the \
            \ same score in two pools is two independent positions with two independent numbers, \
            \ and summing them here would hide which pool to act on. \
            \ \
            \ VERY HEAVY -- four cross-pool scans, then a point read per (pool x score slot). \
            \ `/local` only, and it needs a generous gas limit; the anchors slice's \
            \ `URH_13|MyAnchorableAssets` measured above 150,000 and this reaches further."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            ;;ZERO ROWS ARE DROPPED. An account that has unstaked keeps a row at 0 until it is
            ;;swept, and a list of scores you do not hold is noise on the one screen whose whole
            ;;job is "what am I earning".
            (filter (lambda (r:object) (> (at "final" r) 0.0))
                (fold (+) []
                    (map (lambda (p:string)
                             (map (lambda (s:string) (URC_14|MyScoreInPool account p s))
                                  (ref-AQP::URC_PoolActiveScoreIds p)))
                         (URH_14|MyPoolIds account))))
        )
    )
)

