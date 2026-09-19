;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 9
;; AQP-BOOT.C_Step9_AddFvtScoreEntities
;; ===========================================================================================
;; ESTIMATED GAS 87,514  (4.4% of a 2,000,000 block)
;;   measured, TX-BOOT-09 -- eight C_AddScoreEntity calls
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Admits EIGHT score entities (type 1 = SCORE) onto the four treasury FVTs from transaction 8.
;;   No issuance; this is pure linking.
;;
;;     FVT entity          scores admitted
;;     SubsidiaryTreasury  all FIVE subsidiary scores (the list argument)
;;     CodingTreasury      TheCodingDivision
;;     SnakesTreasury      DemiourgosSnakes
;;     SharesTreasury      DemiourgosShareholder
;;
;;   Guard: `subsidiary-score-ids` must be exactly 5, enforced before anything is derived.
;;
;; -------------------------------------------------------------------------------------------
;; !! TWO UNRESOLVED ISSUES CONVERGE ON THIS TRANSACTION -- DO NOT RUN IT YET
;; -------------------------------------------------------------------------------------------
;;
;;   (1) THE `Bloodshed` SCORE GETS NO FVT LINK, AND THAT BREAKS STAKING.
;;       Look at the table above: the pure `Bloodshed` score from transaction 4 is NOT in it.
;;       Transaction 7 attaches `Bloodshed` to the DHBloodshed pool, making it an EMPLOYED score.
;;       This step then declines to give it a ScoreEntityLink. Staking a DHB nonce afterwards
;;       aborts:
;;
;;         Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink
;;         or reward DPTF                                        05_FVT.pact:1210
;;
;;       Verified by execution 2026-09-18: adding the `Bloodshed` attachment to the test fixture
;;       made `AQP-FULL` fail exactly there. Owner ruling the same day confirmed DHBloodshed
;;       SHOULD carry both the pure and the subsidiary score -- so transaction 7 is right and the
;;       gap is HERE.
;;
;;       Two ways out, and the choice is economic:
;;         a) The pure score is fed by the collection's internal NFT scores and never through FVT
;;            -> the pipeline guard at 05_FVT.pact:1210 is too strict and should tolerate an
;;               employed score with no FVT link.
;;         b) It should draw FVT rewards -> this step needs a NINTH admission and transaction 12
;;            needs a treasury to pay it.
;;
;;   (2) THE FVT CLASS OF THE FOUR TREASURIES IS ITSELF UNRESOLVED.
;;       Transaction 8 issues them at fvt-class 1 (Vault). This step links SF/NF scores to them,
;;       which passes only because `URC_ScoreClassMatchesFvtClass` admits score-class 3 and 4 at
;;       fvt-class 1. The sibling rule `URC_TripletCategoryMatchesFvtClass` says class 1 is
;;       TF-only and SF/NF belong at class 2 -- which is the owner's stated design.
;;       If that rule wins, transaction 8 must issue these at class 2 and this step's links
;;       change targets. See `Deploy/3_Assets/08_step8.pact`.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- eight values in, from two earlier transactions
;; -------------------------------------------------------------------------------------------
;; IN   <- FOUR TREASURY IDS from transaction 8's output (sub, coding, snakes, shares).
;;         Taken as four separate string arguments, not a list.
;;
;;      <- FIVE SUBSIDIARY SCORE IDS from transaction 5, as a list.
;;         ORDER IS NOT CONSTRAINED HERE -- this step maps all five onto the same FVT, so unlike
;;         transaction 7 a permutation is harmless. Only the COUNT is guarded.
;;
;;      <- THREE CORE SCORE IDS from transaction 4: coding, snakes, shares.
;;         These three ARE order-sensitive, because each goes to a different treasury. Transaction
;;         4's output labels them (`coding=`, `company-snakes=`, `company-share=`); match by
;;         label, not by position.
;;
;;         NOTE the fourth core score from transaction 4 -- `Bloodshed` -- has no slot here.
;;         That is issue (1) above, not an omission in this file.
;;
;; OUT  -> "AQP-BOOT Step 9 done. score-entities=[sub=5 coding=1 snakes=1 shares=1].
;;          fvt-ids=[…]. NEXT=Step10:C_IssueMultipletFamily."
;;         Echoes the four treasury ids back; creates no new id. Nothing downstream needs this
;;         output that transaction 8's did not already give you.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   Transactions 4, 5, 7 and 8 must have run. 7 in particular: the scores must be employed on
;;   pools before the reward pipeline means anything.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays eight score-entity admissions.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step9_AddFvtScoreEntities
    PATRON_KONTO
    "TX8_SUB_TREASURY_ID"        ;; <- the four treasury ids from transaction 8, by label
    "TX8_CODING_TREASURY_ID"
    "TX8_SNAKES_TREASURY_ID"
    "TX8_SHARES_TREASURY_ID"
    ;; five subsidiary scores from transaction 5 -- count guarded, order free
    ["TX5_SUB_CODING" "TX5_SUB_WONDERCOACH" "TX5_SUB_BLOODSHED" "TX5_SUB_NOSFERATU" "TX5_SUB_BUNNIES"]
    "TX4_CODING"                 ;; <- these three are order-SENSITIVE: different treasuries
    "TX4_SNAKES"
    "TX4_SHARE"
)
