;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 4 of 8
;; This is STEP 4 of 8 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-3 must have run first, including the init steps between deploys.
;; 2 source file(s), 130,214 gas measured in the REPL gas model, 77,183 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04b_RPSC.pact
;;
;; TOTAL: 1 interface(s), 2 module(s), 0 table(s)
;; What it DEPLOYS, in load order:
;;   -- 2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact
;;      module     O-UI-FOURTEEN
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04b_RPSC.pact
;;      interface  AcquisitionRewardCostsV1
;;      module     AQP-RPSC
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact ==
;; ===========================================================================================
;; O-UI-FOURTEEN -- the EarningPools page. SLICE 2: SCORE ENTITIES, client side.
;; ===========================================================================================
;; OuronetUI entity 14. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;; The anchors slice is 13_O-UI-THIRTEEN; this is deliberately a SEPARATE module rather than a
;; second slice of that one, because the two have no shared state and a read module owns no
;; tables -- so splitting costs nothing and lets either be redeployed without re-sending the
;; other. 13 has already been redeployed three times while its anchors surface settled.
;;
;; ------------------------------------------------------------------------------------------
;; NO CROSS-MODULE `keys`, for the same reason as 13
;; ------------------------------------------------------------------------------------------
;; Every scan below belongs to the module that owns the table: `URH_SCR|AllScoreIds` on
;; AQP-SCORE, and the four `URH_AQP|Dp*StakesByBeneficiary` on AQP-POOL. All are on their
;; interfaces and reached by `::`, so this module needs no `--allowReadsInLocal` and nothing
;; here has to be quarantined from `_conformance.py`.
;;
;; ------------------------------------------------------------------------------------------
;; HOW "MY SCORES" IS REACHED, AND WHY IT IS NOT A LOOKUP
;; ------------------------------------------------------------------------------------------
;; `SCR|T|UserScore` is keyed `<account> | <pool-id> | <score-id>` -- a TRIPLE. There is no
;; enumerator over it and there cannot be a cheap one, so the account's rows are reconstructed
;; from the other side:
;;
;;     account
;;       -> URH_AQP|Dp{tf,of,sf,nf}StakesByBeneficiary   rows carrying pool-id
;;       -> distinct pool-ids
;;       -> URC_PoolActiveScoreIds(pool)                 that pool's score slots
;;       -> UR_U-SCR|UserScore*(account, pool, score)    the numbers
;;
;; BENEFICIARY, NOT OWNER. The owner keeps custody; the BENEFICIARY earns the score. A page
;; built on `*StakesByOwner` would show a staker someone else's scores and hide their own.
;;
;; ------------------------------------------------------------------------------------------
;; TWO FACTS ABOUT THE NUMBERS THAT ARE EASY TO GET WRONG, AND BOTH WERE NEARLY GOT WRONG
;; ------------------------------------------------------------------------------------------
;; 1] `boosted-score` IS THE BOOST, NOT base+boost. `SCR|UserSchema` is explicit:
;;        base-deb-score    = base  x deb
;;        boosted-deb-score = boost x deb
;;        base-deb + boosted-deb = deb-score
;;    So the row's three figures are BASE, BOOST and the deb-multiplied TOTAL. Reading
;;    `boosted-score` as a running total would show the sum where the increment belongs, and it
;;    would look entirely plausible on screen.
;;
;; 2] A ROW CAN BE STALE AND MUST THEN READ AS ZERO. Vacate-v2 lazy invalidation: when a row's
;;    `stamped-generation` is behind the score's `vacate-generation` (a fast-vacate has nuked
;;    the score since the row was written), the VALUES are zero while the identity stands.
;;    `UR_U-SCR|UserScore` applies this, and the per-field readers delegate to it -- so the
;;    per-field readers used below are safe, and a direct table read would NOT have been.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT THIS MODULE DELIBERATELY DOES NOT ANSWER: reward ladders
;; ------------------------------------------------------------------------------------------
;; `FVT|T|MultipletFamily` (04_RPS) has NO enumerator, and neither does FVT itself -- AQP has
;; exactly four global enumerators: anchors, boost classes, scores, pools. A ladder id is only
;; reachable as `UR_FVT-RG|MultipletFamilyId(fvt-id, dptf-id)`, i.e. per aggregator reward lane,
;; so listing them needs an FVT enumerator that does not exist.
;;
;; That is a SOVEREIGN addition and is left out rather than faked. The third client view
;; (Reward Ladders) stays unwired until it lands; the two this module serves do not depend on it.
;; ===========================================================================================

(namespace "ouronet-ns")

;; OUiFourteenV1: already deployed and unchanged -- see LIVE_INTERFACES


(module O-UI-FOURTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiFourteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-FOURTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_FOURTEEN_ADMIN)))
    (defcap GOV|O_UI_FOURTEEN_ADMIN ()      (enforce-guard GOV|MD_O-UI-FOURTEEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV3} DALOS)) (ref-DALOS::GOV|Demiurgoi))
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
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                (ref-RPS:module{AcquisitionRewardPerShareV5} RPS)
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
                ;;THE FOREIGN BOOST LINK -- the score whose BASE this score's boost is computed
                ;;from, or BAR when it is its own primary. This is NOT the boost-class link above:
                ;;that names a group of boosters, this names another SCORE.
                ;;
                ;;IT IS THE ONLY RELATIONSHIP THREE SIBLING SCORES HAVE BEFORE A TRIPLET EXISTS.
                ;;`AQP-BOOT` Step 6 issues Bronze/Silver/Golden as three class-0 scores pointing
                ;;their boost-links at Silver; `C_IssueTriplet` is Step 11, so between the two the
                ;;chain holds a boost CHAIN and no triplet row at all -- measured on mainnet
                ;;2026-10-05: `SCR|T|Triplet` has zero keys while the three links are live. A
                ;;client with only `triplet-id` to go on can show those three only as unrelated
                ;;singles, which is exactly what they are not.
                ,"boost-link"      : (ref-SCR::UR_SCR|ScoreBoostLink score-id)
                ;;The LP leg these class-0 scores are denominated in. BAR for classes 1-4 by
                ;;construction (`UEV` on issuance enforces it), so it doubles as the second half
                ;;of a chain's identity: siblings share a denominator.
                ,"lp-denominator"  : (ref-SCR::UR_SCR|ScoreLpDenominator score-id)
                ,"deb-boost"       : (ref-SCR::UR_SCR|ScoreDebBoost score-id)
                ,"in-triplet"      : (ref-SCR::UR_SCR|ScoreTriplet score-id)
                ,"triplet-id"      : triplet-id
                ;;A DIRECT READER, NOT A DERIVATION. A TRUE triplet is one whose rungs form a
                ;;closed boost ring: ONE HUB carrying the staked base and two ADDITIVE SATELLITES
                ;;whose base is 0 and which earn only what their own boosters make against the
                ;;hub's base. That is what a client needs it for -- a zero on a satellite is
                ;;EXPECTED, not a missing position.
                ;;CORRECTED 2026-10-09. This said a true triplet's weight "comes from maintained
                ;;LANE WEIGHTS rather than a deb product, so it is deb-independent, cannot go
                ;;stale, and `CC_UnstaleMyScores` no-ops on it". All three clauses are now false:
                ;;`URC_ComputeTripletLanes` reads the legs' deb-scores, `URC_ScoreEntityUserWeight`
                ;;reads that sum LIVE, and the true-triplet short-circuit was removed from
                ;;`URC_FvtMemberDebNeedsFix` -- so a true triplet CAN go stale and IS repaired.
                ;;The first draft of this field inferred the property from the three rungs'
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
        (let ((ref-SCR:module{AcquisitionScoresV5} AQP-SCORE))
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
        (let ((ref-SCR:module{AcquisitionScoresV5} AQP-SCORE))
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
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
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
            \ - `my-stamped-generation`. `AcquisitionScoresV2` declares \
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
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (+ (URC_14|MyScoreInPool account pool-id score-id)
               {;;THE [Mu] MANAGEMENT FLAGS. `can-upgrade` false means the score's settings are
                ;;frozen for good -- a manager pressing an edit button would be refused by the
                ;;chain, so the client disables it instead of charging for the refusal.
                "can-upgrade"       : (ref-SCR::UR_SCR|ScoreCanUpgrade score-id)
               ,"can-change-owner"  : (ref-SCR::UR_SCR|ScoreCanChangeOwner score-id)
               ,"i-am-owner"        : (= account (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                ;;A FOREIGN BOOST-LINK CHANGES WHAT EVERY NUMBER MEANS. When non-BAR this score
                ;;is an ADDITIVE SATELLITE: its own base is stored as 0 and the promille applies
                ;;to the HUB's user base, so the row holds boost ONLY. A client showing
                ;;base+boost without saying so is showing a figure that does not mean what the
                ;;label claims -- and specifically must not imply a staked unit is worth anything
                ;;here, because without a booster in this score's own class it is worth zero.
                ;;BAR = own base, the normal case, and never this score itself
                ;;(`SCR|C>CREATE-BOOST-LINK-SCORE` forbids it).
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

    (defun URH_14|PoolForAsset:string (asset-id:string)
        @doc "Which AQP pool, if any, carries <asset-id> as its canonical asset -- the REVERSE \
            \ of `UR_AQP|PoolAssetId`, which AQP-POOL has no index for: a pool row stores its \
            \ own asset-id keyed BY pool-id, so there is no table that goes the other way. \
            \ \
            \ Added 2026-10-11 for the LP console (`RemoveLiquidityTab`), which already resolves \
            \ the SWPAIR behind an LP token (`SWP::UR_GetLpSwpair`) and needs this to resolve the \
            \ AQP pool-id too, for `CC_StakeTrueFungible`/`CC_StakeOrtoFungible`'s own `pool-id` \
            \ parameter. Passing a swpair there instead -- the bug this closes -- aborts with \
            \ \"No value found in table ... AQP|T|Pool for key: W|...\", because that table is \
            \ keyed on the AQP pool-id and a swpair string is never one. \
            \ \
            \ BAR means no AQP pool wraps this asset -- a real answer, not a missing one: most \
            \ swapped assets have no AQP pool at all. Scans every pool once; there is no cheaper \
            \ answer without an index this module does not own."
        (let*
            (
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (hit:[string]
                    (filter (lambda (p:string) (= (ref-AQP::UR_AQP|PoolAssetId p) asset-id))
                            (ref-AQP::URH_AQP|AllPoolIds)))
            )
            (if (= (length hit) 0) (ref-U|CT::CT_BAR) (at 0 hit))
        )
    )

    (defun URH_14|MyPoolIds:[string] (account:string)
        @doc "Every pool this account is a BENEFICIARY in, across all four asset kinds, deduped. \
            \ Four scans, one per tracker table -- there is no single staking table and a pool \
            \ can hold legs of more than one kind, so a stake in any of them puts the account in \
            \ that pool exactly once."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04b_RPSC.pact ============
;; net: v1   ·   dev: v1   ;; NEW MODULE 2026-10-29. Never deployed, so its interface stays V1.
;; Deploy: load THIS file — interface + module ship together.
;; ==============================================================================
;; AQP-RPSC — the RPS COST & CLIENT surface, split out of 04_RPS.pact.
;;
;; WHY IT EXISTS, and the number that forced it. 04_RPS.pact reached 336,132 bytes
;; and its emitted deploy transaction reached 318,758 of _deploybundle.py's 320,000
;; cap — 1,242 bytes of headroom. Making the triplet reward ladder coil as
;; AQP|SC_NAME (so reward EVICTION can drive it without the beneficiary's
;; signature) needs more room than that: the homogeneous branch alone put the
;; transaction at 321,744, and the heterogeneous branch, two cost mirrors and the
;; ladder preview were still to come.
;;
;; The cap is not arbitrary and could not simply be raised: the size charge grows
;; as the SEVENTH power of transaction bytes, so RPS already spends 37% of a
;; 2,000,000-gas block on size alone. A module cannot be split across two
;; transactions either. So the module had to lose mass.
;;
;; WHAT MOVED, and how the seam was chosen. Not by taste — by fixpoint. Starting
;; from every URCi_*, every URC_*Ignis/*Preview and every client entrypoint, the
;; set was shrunk until no function LEFT BEHIND in RPS calls anything that moved,
;; because AQP-RPSC deploys AFTER RPS and a backward call is unbuildable. 25 members
;; survived that, 38,310 bytes.
;;
;; FOUR WERE PULLED BACK and stay in RPS, each named by the stayer that calls it:
;;   URC_SettleStakePendingIgnis    <- XI_RpsPreScore
;;   URCi_Inject                    <- XI_FvtInjectCore, XIv_FvtAddStream
;;   URC_BookStakeUnclaimedIgnis    <- XI_BookStakeUnclaimedCounts
;;   URC_CheckpointStakeRpsIgnis    <- XI_CheckpointStakeRps
;; A useful consequence: the last two are exactly what AQP-VCT calls, so VCT's 12
;; call sites needed no change. AA_MigrateMinInject also stays — it is the only
;; candidate doing DIRECT table access, and the tables belong to RPS.
;;
;; NO POLICY SURFACE, DELIBERATELY. Every member here is a READER: there is no
;; write, no capability, no table, so there is nothing for P|UEV_IMC to gate and
;; no OuronetPolicyV2 to implement. 09_AQP-INFO.pact is the precedent — a leaf
;; preview module with no policy boilerplate at all. Unlike AQP-INFO this one IS
;; called by others (AQP-FVT, AQP-INFO, AQP-DSA), so it carries an interface and
;; is reached by modref rather than by dot call.
;; ==============================================================================

(interface AcquisitionRewardCostsV1
    @doc "The cost-preview and client surface for the AQP reward engine: every URCi_* IGNIS \
        \ reader, the collect ladder's cost mirrors and amount preview, and the stake-flow cost \
        \ readers. Split out of AcquisitionRewardPerShareV4 on 2026-10-29 for deploy-size \
        \ reasons recorded in the file header; the members are unchanged."

    ;;{1}  CAP
    ;;{2}  FUN
    ;;{5.1}  Compute [UC/UCv]
    ;;{5.2}  Read [UR]
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun UDC_LadderPreview:object ( mode:string payout:decimal token-0-id:string token-0-amount:decimal token-1-id:string token-1-amount:decimal token-2-id:string token-2-amount:decimal ))
    (defun URCi_RotateOwnership:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string))
    (defun URCi_Control:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetMosaic:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetSplitMode:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_AddRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_InjectFull:decimal (op-key:string patron:string fvt-id:string reward-dptf-id:string amount:decimal))
    (defun URCi_Collect:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string))
    (defun URC_CollectXferIgnis:decimal (id:string collector:string amount:decimal))
    (defun URC_HeterogeneousLaneRouteIgnis:decimal (collector:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer))
    (defun URC_CollectLadderPreview:object (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URC_CollectTransferLegIgnis:decimal (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URC_CollectForcedFixIgnis:decimal (patron:string collector:string fvt-id:string reward-dptf-id:string))
    (defun URCi_CollectFull:decimal (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URCi_TrueFungibleStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool))
    (defun URCi_OrtoFungibleStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool))
    (defun URCi_CollectableStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
)

(module AQP-RPSC GOV
    @doc "AQP reward-engine COST and CLIENT surface. Reads RPS's state through its interface and \
        \ derives every IGNIS figure the Talos layer and AQP-INFO quote; writes nothing, owns no \
        \ table, holds no capability. See the file header for why it is a separate module."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements AcquisitionRewardCostsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_RPSC (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G4}  capabilities
    (defcap GOV () (compose-capability (GOV|RPSC_ADMIN)))
    (defcap GOV|RPSC_ADMIN () (enforce-guard GOV|MD_RPSC))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    ;;RESOLVED, NOT COPIED. These two are read from their owning modules by the same
    ;;accessor pattern 04_RPS.pact uses, so there is one source of truth for each.
    (defconst BAR                                       (CT_Bar))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    ;;
    ;;COPIED LITERALS, AND THE DUPLICATION IS PRE-EXISTING RATHER THAN INTRODUCED HERE:
    ;;04_RPS.pact and 05_FVT.pact ALREADY carry their own copies of all four (see
    ;;05_FVT.pact's {3.1} block). A third copy follows that practice, so it is pinned
    ;;instead of trusted -- the REPL suite asserts RPS, FVT and AQP-RPSC agree on every
    ;;one. A constant duplicated three ways and checked nowhere is how a reward kind
    ;;silently stops matching.
    (defconst CT_FORCED_FIX_RATE:decimal                10.0)
    (defconst CT_SCORE_ENTITY_TRIPLET                   3)
    (defconst CT_REWARD_KIND_MULTIPLET_BASE             "MULTIPLET_BASE")
    (defconst CT_REWARD_MODE_HETEROGENEOUS              "HETEROGENEOUS")
    ;;{3.2}  functions
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun UDC_LadderPreview:object
        (
            mode:string
            payout:decimal
            token-0-id:string token-0-amount:decimal
            token-1-id:string token-1-amount:decimal
            token-2-id:string token-2-amount:decimal
        )
        @doc "Constructor for URC_CollectLadderPreview's answer: the per-token amounts a collect \
            \ actually pays out, plus the `mode` that decided the routing and the `payout` basis \
            \ they sum to. BARE object by design -- it describes no table row, and a schema would \
            \ have to live in AcquisitionSchemasV3 and bump it for a read-only client preview. \
            \ `mode` is BAR for a non-ladder lane, where the whole payout lands on token-0."
        {"mode"             : mode
        ,"payout"           : payout
        ,"token-0-id"       : token-0-id
        ,"token-0-amount"   : token-0-amount
        ,"token-1-id"       : token-1-id
        ,"token-1-amount"   : token-1-amount
        ,"token-2-id"       : token-2-id
        ,"token-2-amount"   : token-2-amount}
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership on the (pre-rotate) FVT owner \
            \ — deter(auth) + components, like every other module's RotateOwnership."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_RotateOwnership" "auth")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_Control:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string)
        @doc "Cost preview for AQP-FVT|C_Control on the FVT owner — deter(setup) + components, \
            \ like every other module's Control."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_Control" "setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetCommonDenominator" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetMosaic:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetMosaic" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetSplitMode:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetSplitMode" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_AddScoreEntity" "add-score-entity")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_ToggleScoreEntityLink" "fvt-link-toggle")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_AddRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_AddRewardLink" "add-reward-link")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_ToggleRewardLink" "fvt-link-toggle")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetQualitySplit" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_InjectFull:decimal
        (op-key:string patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FULL ignis-for-price of the inject family: the custody-transfer leg PLUS the gas leg. \
            \ <URCi_Inject> alone is only the gas leg, but XI_FvtInjectCore concatenates a \
            \ <TFT::C_Transfer> of the reward principal ahead of it, and that transfer carries its \
            \ own cumulator -- so a preview quoting <URCi_Inject> on its own is short by exactly the \
            \ transfer leg. The other two phases XI_FvtInjectCore concatenates (XI_ReleaseStream, \
            \ XI_DistributeInjectAmount) build no cumulator and cost nothing. Same shape as \
            \ <URCi_CollectFull> and <URCi_TrueFungibleStakeFlow> leg 1.1, both of which already \
            \ count their transfer legs this way; the inject family was the only one that did not. \
            \ Module-only, like <URCi_Inject> itself -- the INFO module reaches it dotted."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (xfer-type:integer
                    (at "type" (TFT.URC_TransferClasses reward-dptf-id patron AQP|SC_NAME amount)))
            )
            (+  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (TFT.URCi_TransferCumulator xfer-type reward-dptf-id patron AQP|SC_NAME))
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (RPS.URCi_Inject op-key fvt-id []))
            )
        )
    )
    (defun URCi_Collect:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        @doc "GAS|COLLECT gas leg (konto = FVT owner); exec concats it with the forced-fix penalty leg and (triplet) the ATS ladder legs."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|CC_Collect" "aqp-collect")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string)
        @doc "Read-only IGNIS ifp of the custody move in XE_WithdrawRoyalty: IGNIS-normalize leg (compress the \
            \ IGNIS royalty to OURO when reward-dptf is IGNIS, else none) + a TFT transfer of the normalized live \
            \ royalty balance from AQP|SC_NAME to <destination>."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                ;;
                (royalty:decimal   (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool     (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string      (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal    (if is-ignis (at 0 (ref-ORBR::URCv_Compress royalty)) royalty))
                (xfer-type:integer (at "type" (ref-TFT::URC_TransferClasses token AQP|SC_NAME destination amount)))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_TransferCumulator xfer-type token AQP|SC_NAME destination)))
        ))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string)
        @doc "Read-only IGNIS ifp of the custody burn in XE_BurnRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + a DPTF burn of the normalized live royalty balance from AQP|SC_NAME."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                ;;
                (royalty:decimal (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Burn token AQP|SC_NAME)))
        ))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Read-only IGNIS ifp of the custody fuel in XE_FuelRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + an SWPLC fuel of the normalized live royalty balance from AQP|SC_NAME \
            \ into <swpair> (amount in the normalized token's slot, 0 elsewhere; direct)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                (ref-SWP:module{SwapperV5} SWP)
                (ref-SWPLC:module{SwapperLiquidityClientV3} SWPLC)
                ;;
                (royalty:decimal (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal  (if is-ignis (at 0 (ref-ORBR::URCv_Compress royalty)) royalty))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (input-amounts:[decimal] (map (lambda (t:string) (if (= t token) amount 0.0)) pool-tokens))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_Fuel AQP|SC_NAME swpair input-amounts true)))
        ))
    (defun URC_CollectXferIgnis:decimal (id:string collector:string amount:decimal)
        @doc "IGNIS ifp of one reward custody transfer AQP|SC_NAME -> collector of <amount> <id> (0 when amount<=0); \
            \ mirrors (if (> amt 0.0) (C_Transfer id AQP|SC_NAME collector amt true) (UC_EmptyOc))."
        (if (<= amount 0.0)
            0.0
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                )
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_TransferCumulator
                        (at "type" (ref-TFT::URC_TransferClasses id AQP|SC_NAME collector amount))
                        id AQP|SC_NAME collector))
            )))
    (defun URC_HeterogeneousLaneRouteIgnis:decimal
        (collector:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer)
        @doc "IGNIS ifp mirror of XI_1|HeterogeneousLaneRoute: ONE token-0 pre-fund of the whole payout + \
            \ Coil(total-t1+total-t2) on ats-01 + Coil(remainder) on ats-12. Mirrors the exec leg for leg; \
            \ the leg list here and the leg list there are the same three branches."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-ATS:module{AutostakeV4} ATS)
                (bs:[integer] (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id))
                (ss:[integer] (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id))
                (gs:[integer] (RPS.UR_FVT-QS|GoldSplit fvt-id reward-dptf-id))
                (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                (b0:decimal (floor (/ (* amt-b (dec (at 0 bs))) 1000.0) prec))
                (b1:decimal (floor (/ (* amt-b (dec (at 1 bs))) 1000.0) prec))
                (s0:decimal (floor (/ (* amt-s (dec (at 0 ss))) 1000.0) prec))
                (s1:decimal (floor (/ (* amt-s (dec (at 1 ss))) 1000.0) prec))
                (g0:decimal (floor (/ (* amt-g (dec (at 0 gs))) 1000.0) prec))
                (g1:decimal (floor (/ (* amt-g (dec (at 1 gs))) 1000.0) prec))
                (total-t0:decimal (+ b0 (+ s0 g0)))
                (total-t1:decimal (+ b1 (+ s1 g1)))
                (total-t2:decimal (- (+ amt-b (+ amt-s amt-g)) (+ total-t0 total-t1)))
                (fund-12:decimal (+ total-t1 total-t2))
                (payout-all:decimal (+ total-t0 fund-12))
            )
            (if (<= fund-12 0.0)
                (URC_CollectXferIgnis token-0 collector payout-all)
                (let
                    (
                        (h-all:object{AutostakeV4.CoilData}
                            (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund-12))
                        (rbt1-keep:decimal
                            (if (> total-t1 0.0)
                                (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t1))
                                0.0))
                    )
                    (let
                        (
                            (rbt1-id:string (at "rbt-id" h-all))
                            (rbt1-ladder:decimal (- (at "rbt-amount" h-all) rbt1-keep))
                            ;;MIRRORS THE AQP|SC_NAME LADDER, leg for leg, and the leg list here and
                            ;;the one in RPS::XI_1|HeterogeneousLaneRoute are the same four branches.
                            ;;<URCi_CoilTo>, not <URCi_Coil>: a transfer's IGNIS class is chosen by
                            ;;URC_TransferClasses -> URC_IzSimpleTransfer -> UR_AccountRoleFeeExemption
                            ;;on the RECEIVER, so a coil funded by AQP|SC_NAME and credited to a
                            ;;beneficiary must price BOTH endpoints. Naming one account twice is the
                            ;;five-site defect this family already paid for on 2026-10-29.
                            (hop1:bool (> (at "rbt-amount" h-all) 0.0))
                            (hop2:bool
                                (and (> rbt1-ladder 0.0)
                                     (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder)) 0.0)))
                        )
                        (fold (+) 0.0
                            [ (URC_CollectXferIgnis token-0 collector (if hop1 total-t0 payout-all))
                              (if hop1
                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME AQP|SC_NAME ats-01 token-0 fund-12))
                                  0.0)
                              (if hop1
                                  (URC_CollectXferIgnis rbt1-id collector (if hop2 rbt1-keep (at "rbt-amount" h-all)))
                                  0.0)
                              (if hop2
                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME collector ats-12 rbt1-id rbt1-ladder))
                                  0.0)
                            ])
                    )
                )
            )
        ))
    (defun URC_CollectLadderPreview:object
        (collector:string pool-id:string fvt-id:string score-entity-type:integer
         score-entity-id:string reward-dptf-id:string)
        @doc "AMOUNT preview for a collect: what the collector actually RECEIVES, per token. \
            \ A MULTIPLET_BASE triplet lane pays in up to THREE tokens, so a client showing one \
            \ figure in one ticker names a denomination the collector will not receive. Returns \
            \ {mode, payout, token-N-id, token-N-amount} for N in 0..2; a non-ladder lane answers \
            \ the whole payout on token-0 with BAR/0.0 above it. \
            \ Mirrors XI_TransferRewardDptfFromVault leg for leg, INCLUDING both precision skips: \
            \ when hop 1 rounds to zero the collector keeps the whole payout as token-0, and when \
            \ hop 2 rounds to zero they keep ALL of token-1 rather than the token-1 keep-share. \
            \ Returns a BARE object, so by the interface object-return rule it is module-only -- \
            \ a client reaches it as `ouronet-ns.RPS.URC_CollectLadderPreview`, the same way it \
            \ must already reach URC_ComputeTripletLanes. Pinned against real balance deltas by \
            \ REPL/Stage_02/[6.4]_AQP-LADDER-PREVIEW.repl -- a preview nothing compares to \
            \ execution is a fourth copy of the ladder waiting to drift."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (reward-kind:string (RPS.UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (RPS.URC_CollectClaimableRewards collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            ;;BRANCH ON KIND BEFORE AMOUNT, deliberately. Short-circuiting on `payout <= 0`
            ;;first was the obvious shape and it was wrong for the common case: EVERY lane the
            ;;user is not currently owed anything on has payout 0, and answering those with BAR
            ;;token ids leaves a client unable to tell a drained LADDER lane from a plain one --
            ;;so it renders one unknown ticker instead of three tokens at zero.
            (if (not (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE)
                          (= score-entity-type CT_SCORE_ENTITY_TRIPLET)))
                ;;plain lane: one token, the whole payout, nothing above it.
                (UDC_LadderPreview BAR payout reward-dptf-id payout BAR 0.0 BAR 0.0)
                (if (<= payout 0.0)
                    ;;drained LADDER lane: the identities and the mode are still the truth about
                    ;;this lane, and they cost three row reads -- no lane scan, no ATS derivation.
                    (let
                        (
                            (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        )
                        (UDC_LadderPreview (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id) 0.0
                            (RPS.UR_FVT-MF|Token0Id mf-id) 0.0
                            (RPS.UR_FVT-MF|Token1Id mf-id) 0.0
                            (RPS.UR_FVT-MF|Token2Id mf-id) 0.0)
                    )
                (let*
                    (
                        (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        (lanes:object (RPS.URC_ComputeTripletLanes collector pool-id score-entity-id))
                        (w-total:decimal (at "w-user" lanes))
                        (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                        (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                        (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                        (prec:integer (ref-DPTF::UR_Decimals token-0))
                        (mode:string (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id))
                        (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ (at "lane-b" lanes) w-total)) prec) 0.0))
                        (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ (at "lane-s" lanes) w-total)) prec) 0.0))
                        (amt-g:decimal (- payout (+ amt-b amt-s)))
                        ;;HOMOGENEOUS routes lane->one token; HETEROGENEOUS splits EACH lane across
                        ;;all three per the per-mille matrix. Either way the route reduces to the
                        ;;same three figures: raw token-0, the amount coiled once, the remainder.
                        (raw:decimal
                            (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                                (+ (floor (/ (* amt-b (dec (at 0 (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                   (+ (floor (/ (* amt-s (dec (at 0 (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                      (floor (/ (* amt-g (dec (at 0 (RPS.UR_FVT-QS|GoldSplit   fvt-id reward-dptf-id)))) 1000.0) prec)))
                                amt-b))
                        (once:decimal
                            (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                                (+ (floor (/ (* amt-b (dec (at 1 (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                   (+ (floor (/ (* amt-s (dec (at 1 (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                      (floor (/ (* amt-g (dec (at 1 (RPS.UR_FVT-QS|GoldSplit   fvt-id reward-dptf-id)))) 1000.0) prec)))
                                amt-s))
                    )
                    (let*
                        (
                            (fund:decimal (- payout raw))
                            (token-1:string (RPS.UR_FVT-MF|Token1Id mf-id))
                            (token-2:string (RPS.UR_FVT-MF|Token2Id mf-id))
                            ;;hop 1 on the WHOLE laddering amount, exactly as the route coils it
                            (h-all:object{AutostakeV4.CoilData}
                                (if (> fund 0.0)
                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund)
                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 0.0)))
                            (rbt1-total:decimal (at "rbt-amount" h-all))
                            (rbt1-id:string (at "rbt-id" h-all))
                            (rbt1-keep:decimal
                                (if (> once 0.0)
                                    (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 once))
                                    0.0))
                            (rbt1-ladder:decimal (- rbt1-total rbt1-keep))
                            (rbt2:decimal
                                (if (> rbt1-ladder 0.0)
                                    (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder))
                                    0.0))
                        )
                        (if (<= rbt1-total 0.0)
                            ;;hop 1 rounds away: nothing is coiled, the single pre-fund already
                            ;;handed the collector the entire payout as token-0.
                            (UDC_LadderPreview mode payout token-0 payout token-1 0.0 token-2 0.0)
                            (if (> rbt2 0.0)
                                (UDC_LadderPreview mode payout token-0 raw token-1 rbt1-keep token-2 rbt2)
                                ;;hop 2 rounds away: the collector keeps ALL of token-1, not the keep-share.
                                (UDC_LadderPreview mode payout token-0 raw token-1 rbt1-total token-2 0.0)))
                    )
                ))
            )
        )
    )
    (defun URC_CollectTransferLegIgnis:decimal
        (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of XI_TransferRewardDptfFromVault (PHASE 1.1 collect payout leg)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (reward-kind:string (RPS.UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (RPS.URC_CollectClaimableRewards collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            (if (<= payout 0.0)
                0.0
                (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                    (let*
                        (
                            (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (lanes:object (RPS.URC_ComputeTripletLanes collector pool-id score-entity-id))
                            (lane-b:decimal (at "lane-b" lanes))
                            (lane-s:decimal (at "lane-s" lanes))
                            (lane-g:decimal (at "lane-g" lanes))
                            (w-total:decimal (at "w-user" lanes))
                            (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                            (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                            (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                            (prec:integer (ref-DPTF::UR_Decimals token-0))
                            (mode:string (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id))
                            (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ lane-b w-total)) prec) 0.0))
                            (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ lane-s w-total)) prec) 0.0))
                            (amt-g:decimal (- payout (+ amt-b amt-s)))
                            (fund-sg:decimal (+ amt-s amt-g))
                        )
                        (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                            (URC_HeterogeneousLaneRouteIgnis collector fvt-id reward-dptf-id mf-id amt-b amt-s amt-g prec)
                            (if (<= fund-sg 0.0)
                                (URC_CollectXferIgnis token-0 collector payout)
                                (let*
                                    (
                                        (h-all:object{AutostakeV4.CoilData}
                                            (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund-sg))
                                        (rbt1-keep:decimal
                                            (if (> amt-s 0.0)
                                                (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-s))
                                                0.0))
                                        (rbt1-id:string (at "rbt-id" h-all))
                                        (rbt1-ladder:decimal (- (at "rbt-amount" h-all) rbt1-keep))
                                    )
                                    ;;SAME FOUR LEGS as RPS's homogeneous branch -- see the note in the
                                    ;;heterogeneous mirror above for why this takes URCi_CoilTo.
                                    (let
                                        (
                                            (hop1:bool (> (at "rbt-amount" h-all) 0.0))
                                            (hop2:bool
                                                (and (> rbt1-ladder 0.0)
                                                     (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder)) 0.0)))
                                        )
                                        (fold (+) 0.0
                                            [ (URC_CollectXferIgnis token-0 collector (if hop1 amt-b payout))
                                              (if hop1
                                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME AQP|SC_NAME ats-01 token-0 fund-sg))
                                                  0.0)
                                              (if hop1
                                                  (URC_CollectXferIgnis rbt1-id collector (if hop2 rbt1-keep (at "rbt-amount" h-all)))
                                                  0.0)
                                              (if hop2
                                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME collector ats-12 rbt1-id rbt1-ladder))
                                                  0.0)
                                            ]))
                                )))
                    )
                    (URC_CollectXferIgnis reward-dptf-id collector payout)))
        ))
    (defun URC_CollectForcedFixIgnis:decimal
        (patron:string collector:string fvt-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of CC_Collect PHASE 7 forced-fix penalty: (ffc x CT_FORCED_FIX_RATE / patron-discount) \
            \ gated by the virtual-gas toggle; 0 when ffc<=0. \
            \ TOOK A SECOND PARAMETER rather than a rename: the COUNT is the collector's (the exec reads \
            \ it for <executor>) while the DISCOUNT dividing it is the patron's, who actually pays."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ffc:integer (RPS.UR_FVT-FFC|Count fvt-id reward-dptf-id collector))
            )
            (if (<= ffc 0)
                0.0
                (RPS.UC_GasPrice (/ (* (dec ffc) CT_FORCED_FIX_RATE) (ref-DALOS::URC_IgnisGasDiscount patron))
                             (ref-IGNIS::URC_IsVirtualGasZero)))
        ))
    (defun URCi_CollectFull:decimal
        (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of CC_Collect = reward-payout leg (URC_CollectTransferLegIgnis) + Phase-7 \
            \ forced-fix penalty (URC_CollectForcedFixIgnis) + the URCi_Collect leg. Residual: the payout is read pre-drip, so \
            \ a lane carrying a LIVE stream (whose exec drip vests extra reward before payout) can shift the transfer \
            \ tier — exact only for un-streamed / already-settled lanes."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                ;;
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            ;;THE CONFLATION IS GONE, 2026-10-29. This read <patron> for BOTH roles, because
            ;;adding a parameter meant bumping a LIVE interface. AQP-FVT's interface had to bump
            ;;to V5 anyway -- for the XE_EvictDrip/XE_EvictPay eviction surface -- so the fix rode
            ;;that bump at near-zero marginal cost, which is why it waited rather than shipping as
            ;;its own cascade round.
            ;;
            ;;<collector> is the REWARD SUBJECT: its claimable is computed, its triplet lane split
            ;;is read from ITS deb scores, the transfer class depends on IT as receiver, and the
            ;;forced-fix count is ITS count. <patron> only supplies the IGNIS discount. A sponsored
            ;;collect now quotes the right account; before, it quoted the sponsor's figures.
            (fold (+) 0.0
                [ (URC_CollectTransferLegIgnis collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                  (URC_CollectForcedFixIgnis patron collector fvt-id reward-dptf-id)
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id]))
                ])
        ))
    (defun URCi_TrueFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Toggled total IGNIS IFP of CC_TrueFungibleStakeFlow. Legs: transfer + tracker + rollup \
            \ + RPS-settle + anchor-refresh(ANK per-unit + XB flat) + score-delta + book + checkpoint. \
            \ direction=true stake (owner→vault), false unstake (vault→owner)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (xfer-type:integer (at "type" (TFT.URC_TransferClasses dptf-id sender receiver amount)))
                (n-live:integer   (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 custody transfer
                      (TFT.URCi_TransferCumulator xfer-type dptf-id sender receiver)))
                  (RPS.URC_TierMedium)                                                                 ;; 1.2 pool tracker (medium ×1)
                  (RPS.URC_TierBiggest)                                                                ;; 1.3 ben rollup   (biggest ×1)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierFixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live))         ;; 3.1a ANK anchor refresh
                  (RPS.URC_TierBiggest)                                                                ;; 3.1b XB sync-count (biggest ×1)
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSum pool-id))                                 ;; 4   score delta
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_OrtoFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_OrtoFungibleStakeFlow. Legs: transfer(DPOF, direction- \
            \ INDEPENDENT) + tracker(medium × |nonces|) + RPS-settle + score-delta(class ∈ {0,2}) + \
            \ book + checkpoint. NO 1.3 rollup, NO anchor leg."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (nn:decimal       (dec (length nonces)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-indep)
                      (DPOF.URCi_MoveCumulator dpof-id nonces false)))
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSumForClasses pool-id [0 2]))                 ;; 4   score delta (class ∈ {0,2})
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_CollectableStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_CollectableStakeFlow (SF son=true class-3 / NF son=false \
            \ class-4). Legs: transfer(DPDC-T, direction-dependent) + tracker(medium × |nonces|) + \
            \ rollup(medium × |nonces|) + RPS-settle + anchor(FLAT medium + biggest) + score-delta \
            \ (class == son?3:4) + book + checkpoint. nonce-amounts is caller-supplied."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (nn:decimal       (dec (length nonces)))
                (tgt-class:integer (if son 3 4))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-dep)
                      (DPDC-T.URCi_MultiTransferCumulator [collectable-id] [son] sender receiver [nonces] [nonce-amounts])))
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.3 rollup  (medium × |nonces|)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierMedium)                                                                 ;; 3 anchor flat medium
                  (RPS.URC_TierBiggest)                                                                ;; 3 anchor flat biggest
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSumForClasses pool-id [tgt-class]))           ;; 4 score delta (class == son?3:4)
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
)

