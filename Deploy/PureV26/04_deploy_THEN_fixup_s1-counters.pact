;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : backfill the four S1 counters onto every pre-existing AQP reward row
;;
;; RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 04_RPS.pact,
;; and BEFORE any inject or collect touches these aggregators.
;;
;; THAT IS BATCH 04 OF THE ROUND, NOT THE END OF IT. `UM_FVT|BackfillS1Counters`
;; and every function it calls -- the `WU_` writers, the `URH_` scans, the
;; `RPS|UM>BACKFILL-S1` capability -- all live in RPS, so this is runnable the
;; moment that batch lands. Waiting until batch 09 buys nothing and leaves five
;; more deploy transactions' worth of blocks in which a user collect could read
;; a not-yet-repaired counter. An earlier draft of this file said "AFTER files
;; 01-09"; that was wrong and this paragraph is the correction.
;;
;; THIS FILE IS NOT GENERATED. _deploybundle.py emits MODULE deploys; it has no
;; way to know that a schema gained a field and that live rows therefore need a
;; pass. It knows this file by name (KEEP) and will not report it as an orphan.
;;
;; ---------------------------------------------------------------------------
;; WHAT IT DOES
;;
;; The 2026-11-09 S1 round added four columns:
;;
;;     FVT|RewardAggregate.earning-leg-count      (per FVT)
;;     FVT|ScoreEntityLink.earning-user-count     (per member)
;;     FVT|RPS|Global.dormant-claim-count         (per lane)
;;     FVT|MemberVault.dormant-claim-count        (per member, per lane)
;;
;; They exist so `unclaimed-count` can be RESTORED at each accrual as
;; `earning + dormant` -- the count that arms both dust sweeps, which on every
;; live lane currently stands above the collectable legs so `= 1` is never
;; reached. A row written before this round carries none of them.
;;
;; MEASURED ON CHAIN 2026-11-09, and this is the state this transaction repairs:
;;
;;     FVT|T|RewardAggregate    9 rows   none carries earning-leg-count
;;     FVT|T|ScoreEntityLink   13 rows   none carries earning-user-count
;;     FVT|T|RPS|Global        11 rows   none carries dormant-claim-count
;;     FVT|T|MemberVault       19 rows   none carries dormant-claim-count
;;
;; All 52 rows were confirmed to carry every OTHER column of their schema, so
;; the readers may take the pre-existing fields bare and test `contains` only on
;; the new one.
;;
;; ---------------------------------------------------------------------------
;; THE DEFECT THIS FILE NO LONGER CARRIES -- read this before trusting it
;;
;; An earlier cut of `UM_FVT|BackfillS1Counters` SEEDED `dormant-claim-count`
;; from the pre-migration `unclaimed-count`, on the stated grounds that the
;; exact figure "needs each leg's claimable" and that the stored count was a
;; safe UPPER BOUND. It is not safe. It is self-defeating, and it would have
;; permanently disabled the sweep this entire round exists to enable.
;;
;; `unclaimed-count` ALREADY counts the earning legs, and the restore is
;; `unclaimed := earning + dormant`. Seeding dormant from it therefore counts
;; every earning leg TWICE. Computed against all eleven live lanes before
;; sending anything:
;;
;;   lane                       stored  seeded-restore  exact-restore  true owed
;;   CodingDivision/WSTOA           15              30             15          8
;;   OuroLpFarm/OURO                25              50             25          0
;;   Subsidiary/AURYN               69             128             61         27
;;   Subsidiary/WSTOA               29              88             61         27
;;
;; Every lane moved FURTHER from 1 than the value already stored. And the
;; over-count could never drain: T4 decrements `dormant` only when a DORMANT
;; leg collects, and on SEVEN of the eleven lanes the true dormant count is 0 --
;; there is no such leg, so `= 1` was unreachable by construction.
;;
;; IT WENT UNCAUGHT BY A GREEN GATE, and the reason is worth keeping. The
;; migration's own test (`REPL/modules/S1-UNCLAIMED.repl` <<TX-S1-02>>) ran
;; against a lane that the preceding transaction had already drained to zero, so
;; `unclaimed-count` was 0, the seed wrote 0, and the correct and incorrect
;; implementations were INDISTINGUISHABLE. The test now re-arms the lane with an
;; injection first and asserts the pre-migration count is non-zero before
;; claiming anything about dormant -- a vacuity guard, because a 0 expectation
;; against a 0 input proves nothing.
;;
;; ---------------------------------------------------------------------------
;; HOW THE FIGURES ARE DERIVED NOW
;;
;; EARNING IS COUNTED EXACTLY: one pass over each FVT's present users x its
;; enabled members, counting the (user, member) pairs that hold live weight,
;; which is the definition of the field. A TRIPLET member is resolved through
;; its SILVER leg, exactly as the collect path resolves it.
;;
;; DORMANT IS COUNTED EXACTLY TOO, and it is cheap for a reason that is not
;; obvious: a dormant leg is BY DEFINITION one with ZERO weight, and a zero
;; weight kills the projection term in `URC_LiveClaimable`
;; (`pending + floor(weight x (index - last-rps))`). So for exactly the legs
;; being classified, claimable IS the stored `pending` -- no projection, no
;; stream arithmetic, no estimate. Verified against the full
;; `URC_LiveClaimable` computation on all eleven lanes: IDENTICAL on every one,
;; at 1,066,656 gas instead of 2,514,666. OuroLpFarm's triplet lane alone fell
;; from 1,244,416 gas to 116,076.
;;
;; DIRECTION OF ERROR, STATED. `unclaimed` still slightly OVER-counts, because a
;; leg with live weight and nothing yet to claim is counted by `earning` -- the
;; approximation `XI_2|RestoreUnclaimedFromCounts` already documents.
;; Over-counting stalls the sweep and RETAINS dust; under-counting would let a
;; sweeper take another account's rewards. Only one is reversible.
;;
;; WHICH MEANS THE THREE DEAD LANES ARE NOT FIXED BY THIS, and that is not a
;; regression. Bloodshed/AURYN, Bloodshed/WSTOA and OuroLpFarm/OURO hold a
;; balance with ZERO collectable legs (true owed = 0) while carrying 9, 9 and 25
;; EARNING legs. `earning + dormant` is 9, 9 and 25 there, so `= 1` is still
;; unreachable and the sweep still cannot fire. Their residue is the
;; whole-aggregator EVICT path's job -- which this same round makes exact -- not
;; the last-claimant sweep's.
;;
;; IDEMPOTENT. Every value is RECOUNTED, never incremented, so a second run is
;; harmless. Pinned by REPL/modules/S1-UNCLAIMED.repl <<TX-S1-02>>.
;;
;; ---------------------------------------------------------------------------
;; PREDICTED RESULT, computed against the live chain under GLOBAL
;; ADMINISTRATIVE PAUSE (DALOS.UR_GAP = true, confirmed on chain 2026-11-09).
;; GAP is enforced in every Talos gas-station gate, so no stake, inject or
;; collect can move these inputs. These are the values this file WILL write:
;;
;;   FVT / lane                                earning  dormant  restored
;;   BloodshedTreasury/AURYN                          9        0         9
;;   BloodshedTreasury/WSTOA                          9        0         9
;;   CodingDivisionTreasury/WSTOA                    15        0        15
;;   CompanySharesTreasury/OURO                       7        2         9
;;   NosferatuTreasury/WSTOA                         13        0        13
;;   OuroLpFarm/OURO                                 25        0        25
;;   SnakesTreasury/AURYN                             7        2         9
;;   StoicismVault/WSTOA                              4        0         4
;;   SubsidiaryTreasury/AURYN                        59        2        61
;;   SubsidiaryTreasury/WSTOA                        59        2        61
;;   WonderCoachTreasury/WSTOA                       13        0        13
;;
;; Per FVT (what the `earning-leg-count` write lands on):
;;
;;   BloodshedTreasury-x_P-KU2bWWt9           users= 20  members=1  earning-legs=  9  lanes=2
;;   CodingDivisionTreasury-x_P-KU2bWWt9      users= 15  members=1  earning-legs= 15  lanes=1
;;   CompanySharesTreasury-x_P-KU2bWWt9       users= 10  members=1  earning-legs=  7  lanes=1
;;   NosferatuTreasury-VbI5pmK2CWEf           users= 13  members=1  earning-legs= 13  lanes=1
;;   OuroLpFarm-x_P-KU2bWWt9                  users= 25  members=1  earning-legs= 25  lanes=1
;;   SnakesTreasury-x_P-KU2bWWt9              users= 10  members=1  earning-legs=  7  lanes=1
;;   StoicismVault-VbI5pmK2CWEf               users=  4  members=1  earning-legs=  4  lanes=1
;;   SubsidiaryTreasury-x_P-KU2bWWt9          users= 26  members=5  earning-legs= 59  lanes=2
;;   WonderCoachTreasury-VbI5pmK2CWEf         users= 13  members=1  earning-legs= 13  lanes=1
;;
;; GAS, MEASURED AGAINST THE LIVE STATE in the shape this function actually runs
;; -- weights computed once per (user, member), earning and per-lane dormant
;; both derived from them:
;;
;;   BloodshedTreasury           127,478     SnakesTreasury         123,864
;;   CodingDivisionTreasury      124,697     StoicismVault          122,377
;;   CompanySharesTreasury       123,898     SubsidiaryTreasury     151,388
;;   NosferatuTreasury           124,248     WonderCoachTreasury    124,236
;;   OuroLpFarm                  150,517
;;   ------------------------------------------------------------------------
;;   all nine, READS only                  1,172,703   (58.6% of a 2.00M block)
;;
;; Measuring the combined pass MATTERED: the two scans measured separately came
;; to 856,250 + 1,066,656 = 1,922,906, because each one recomputed the weights.
;; Sharing them costs 1,172,703 -- so the naive sum would have over-stated this
;; transaction by 64% and argued for splitting it on a figure that was never
;; real.
;;
;; ON TOP OF THAT, 52 WRITES: 13 `earning-user-count` (one per member), 9
;; `earning-leg-count` (one per FVT) and 30 dormant writes (per lane, plus per
;; member-lane). A `/local` read cannot price a write, so the total is reads
;; plus an unmeasured term, and one transaction is EXPECTED to fit at roughly
;; 70-75% of a block.
;;
;; "EXPECTED TO FIT" IS NOT HOW THIS ROUND EARNS TRUST. Each call is independent
;; and idempotent, so if you would rather not rely on an unmeasured term, cut
;; the list at the marked line below and send two transactions. Both halves are
;; then under 35% of a block in reads. Sending all nine at once is fine; sending
;; them as two is free. There is no ordering constraint between the nine.
;;
;; Needs the RPS admin keyset (`GOV|MD_RPS`), which `RPS|UM>BACKFILL-S1`
;; composes before it grants SECURE.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(RPS.UM_FVT|BackfillS1Counters "BloodshedTreasury-x_P-KU2bWWt9")
(RPS.UM_FVT|BackfillS1Counters "CodingDivisionTreasury-x_P-KU2bWWt9")
(RPS.UM_FVT|BackfillS1Counters "CompanySharesTreasury-x_P-KU2bWWt9")
(RPS.UM_FVT|BackfillS1Counters "NosferatuTreasury-VbI5pmK2CWEf")
(RPS.UM_FVT|BackfillS1Counters "OuroLpFarm-x_P-KU2bWWt9")

;; ----------------------------- OPTIONAL CUT -------------------------------
;; Everything above: 650,838 gas of reads (32.5% of a block). Below: 521,865
;; (26.1%). Split here if you want two transactions instead of one; the nine
;; calls are independent, unordered and individually idempotent.
;; --------------------------------------------------------------------------

(RPS.UM_FVT|BackfillS1Counters "SnakesTreasury-x_P-KU2bWWt9")
(RPS.UM_FVT|BackfillS1Counters "StoicismVault-VbI5pmK2CWEf")
(RPS.UM_FVT|BackfillS1Counters "SubsidiaryTreasury-x_P-KU2bWWt9")
(RPS.UM_FVT|BackfillS1Counters "WonderCoachTreasury-VbI5pmK2CWEf")

;; ---------------------------------------------------------------------------
;; VERIFY AFTERWARDS (read-only, /local, no signature). Compare against the
;; PREDICTED RESULT table above -- not merely "did it not error".
;;
;;   (map (lambda (k:string)
;;          [k (ouronet-ns.RPS.UR_FVT|EarningLegCount k)])
;;        (keys ouronet-ns.RPS.FVT|T|RewardAggregate))
;;
;;   (map (lambda (k:string)
;;          [k (at "dormant-claim-count" (read ouronet-ns.RPS.FVT|T|RPS|Global k))])
;;        (keys ouronet-ns.RPS.FVT|T|RPS|Global))
;;
;; Both must answer with integers rather than a "no such field" error, for all
;; 9 and all 11 rows respectively, and the integers must match the table.
;; ---------------------------------------------------------------------------
