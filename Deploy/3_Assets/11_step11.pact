;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 11
;; AQP-BOOT.C_Step11_WireFarmTriplet
;; ===========================================================================================
;; ESTIMATED GAS 36,657  (1.8% of a 2,000,000 block)
;;   measured, TX-BOOT-11
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Three calls, all conditional on the farm existing:
;;     1. C_IssueTriplet  bronze, silver, golden          -- bundles the three LP scores
;;     2. C_AddScoreEntity  farm, type TRIPLET, triplet-id -- admits the bundle to OuroLpFarm
;;     3. C_AddRewardLink   farm, ouro-id, multiplet-family-id -- OURO as the farm's reward,
;;                                                              laddered through the family
;;
;; -------------------------------------------------------------------------------------------
;; !! ARGUMENT ORDER IS BRONZE, SILVER, GOLDEN -- NOT THE ORDER TRANSACTION 6 GIVES YOU
;; -------------------------------------------------------------------------------------------
;;   Transaction 6's pasteable list is ordered  SILVER, BRONZE, GOLDEN  -- because that is what
;;   transaction 7's `ouro-triplet-score-ids` wants.
;;
;;   This step's parameters are  BRONZE, SILVER, GOLDEN.
;;
;;   THEY ARE NOT THE SAME ORDER. Do not reuse transaction 6's bracket list here. Take the three
;;   ids from transaction 6's LABELLED section (`score-ids=[silver=… bronze=… golden=…]`) and
;;   place them by name.
;;
;;   Getting it wrong does not error. `triplet-id` is `T|bronze|silver|golden`, so a permuted
;;   input simply produces a DIFFERENT, VALID-LOOKING triplet id -- one that no triplet row
;;   exists under. The failure surfaces later, as a farm whose triplet cannot be found.
;;
;; -------------------------------------------------------------------------------------------
;; THE SKIP BRANCH
;; -------------------------------------------------------------------------------------------
;;   `wire-farm` is false when `farm-id` is empty or the literal "skipped". In that case this step
;;   does NOTHING and echoes `skipped` in all four output slots.
;;
;;   That is the correct behaviour if you passed "" as `lp-denominator` to transaction 8 -- there
;;   is no farm to wire. But it also means a WRONG farm-id does not fail loudly: paste the string
;;   "skipped" by accident and this transaction silently no-ops while reporting success.
;;   Check the output says a real farm id, not `skipped`, unless you meant it.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- four sources converge here
;; -------------------------------------------------------------------------------------------
;;   farm-id             <- transaction 8  (`fvt-ids=[farm=…]`)
;;   bronze/silver/golden<- transaction 6  (the LABELLED scores, by name -- see the order warning)
;;   ouro-id             <- the live OURO DPTF, same value as transactions 6, 8 and 10
;;   multiplet-family-id <- transaction 10. DETERMINISTIC: `F|ouro|auryn|elite`, verified against
;;                          `RPS::UCk_MultipletFamily` which builds the same concat with BAR="|".
;;                          With your ids: F|OURO-8Nh-JO8JO4F5|AURYN-8Nh-JO8JO4F5|ELITEAURYN-8Nh-JO8JO4F5
;;
;; OUT -> farm, triplet-id, multiplet-family-id, ouro-reward -- or four `skipped`s.
;;        `triplet-id` is also deterministic (`T|bronze|silver|golden`, verified against
;;        `SCORE::UC_ComputeTripletId`), so it too can be computed rather than captured.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   Transactions 6 (scores), 8 (farm) and 10 (family). Transaction 7 should have run so the
;;   class-0 DHOuroLp pool exists and the triplet has a pool to be meaningful on.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays one triplet issuance + two admissions.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step11_WireFarmTriplet
    PATRON_KONTO
    "TX8_FARM_ID"                    ;; <- from tx 8. Must NOT be "skipped" unless you mean it.
    "TX6_BRONZE_SCORE"               ;; <- BRONZE first here. Transaction 6 lists silver first.
    "TX6_SILVER_SCORE"
    "TX6_GOLDEN_SCORE"
    "OURO-8Nh-JO8JO4F5"              ;; <- same OURO DPTF as tx 6, 8, 10
    "F|OURO-8Nh-JO8JO4F5|AURYN-8Nh-JO8JO4F5|ELITEAURYN-8Nh-JO8JO4F5"   ;; <- tx 10, computable
)
