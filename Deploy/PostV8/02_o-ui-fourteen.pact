;; -------------------------------------------------------------------------
;; POST-V8 -- O-UI-FOURTEEN: the asset-id -> AQP pool-id reverse lookup the LP
;; console's stake flow was missing.
;;
;; `AQP|Schema` stores each pool's own asset-id (`UR_AQP|PoolAssetId`), keyed BY pool-id -- the
;; FORWARD direction only. Nothing in the tree answered the reverse question, "which pool wraps
;; THIS asset", and `RemoveLiquidityTab` (the shared LP console, reused on both the SWP-Pairs and
;; AQP-Pools screens) needed exactly that: its own `poolId` prop is a SWPAIR -- the id space every
;; other read inside it is keyed on (`getLPEntries`, `URCv_04|LpEntry`, `SWP.UR_TokenLP`) -- but
;; `CC_StakeTrueFungible` / `CC_StakeOrtoFungible` take a REAL AQP pool-id as their `pool-id`
;; argument.
;;
;; Without this reader the UI had no way to resolve one from the other, and the gap was papered
;; over by passing the swpair straight through. Reported live, 2026-10-11, against a 10,000-unit
;; frozen LP stake attempt:
;;
;;     No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: W|SSTOA-8N...
;;
;; -- the swpair string, handed to a table keyed on AQP pool-ids, which it never is.
;;
;; `URH_14|PoolForAsset` closes it: scans `URH_AQP|AllPoolIds` once, filters by
;; `UR_AQP|PoolAssetId == asset-id`, returns the matching pool-id or BAR when none wraps the
;; asset (a real answer -- most swpairs carry no AQP pool at all). Resolved from the NATIVE
;; asset-id works for a frozen leg too: `URC_StakeTrueFungibleDptfMatchesPool` strips a leading
;; `F|` before comparing against the pool's stored (always-unprefixed) asset-id, so native and
;; frozen legs of the same LP resolve to the same pool.
;;
;; SAFE AS A STANDALONE UPGRADE: O-UI-FOURTEEN owns no tables and has no dot-callers anywhere in
;; the tree (confirmed via grep for `O-UI-FOURTEEN::`), and the interface `OUiFourteenV1` is
;; UNCHANGED -- the new function is module-only, the same convention `URH_14|MyPoolIds`'s own
;; siblings follow, so this upgrade carries no interface and no `create-table` form.
;;
;; SIGNERS: the O-UI-FOURTEEN governance keyset (GOV|MD_O-UI-FOURTEEN -> GOV|Demiurgoi), the same
;; shape as PostV7/PostV8's O-UI-NINE hotfixes.
;; -------------------------------------------------------------------------

(namespace "ouronet-ns")

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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
        (let ((ref-SCR:module{AcquisitionScoresV2} AQP-SCORE))
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
        (let ((ref-SCR:module{AcquisitionScoresV2} AQP-SCORE))
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
