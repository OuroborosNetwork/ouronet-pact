;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 4
;; AQP-BOOT.C_Step4_CreateCoreScores
;; ===========================================================================================
;; ESTIMATED GAS ~unmeasured
;;   not exercised in the boot suite; it runs in [6.2.2]_AQP-SCORE and triplet-collect-golden. Four score issuances, so expect the order of Step 5
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues the FOUR core scores. Note they are not all the same kind:
;;
;;     score                   kind             aqp-class   extra
;;     TheCodingDivision       SemiFungible     3           false
;;     Bloodshed               NonFungible      6           0
;;     DemiourgosShareholder   SemiFungible     6           true
;;     DemiourgosSnakes        SemiFungible     6           false
;;
;;   `Bloodshed` is the PURE Bloodshed score -- the one earned from the collection's internal NFT
;;   scores, as distinct from `SubsidiaryBloodshed` which transaction 5 creates. It is the only
;;   NonFungible score of the four. See the WARNING at the bottom of this file.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- NOTHING FROM A PREVIOUS STEP. This is the first transaction since Step 0 that does not
;;         take `kbn-id`; transactions 1-3 are all KBN anchor work and this is unrelated to them.
;;         It takes two accounts:
;;           patron       -- the gas payer
;;           owner-konto  -- the SCORE OWNER. In the REPL both are `KST.ANHD`, which hides that
;;                           they are separate arguments. On mainnet decide deliberately who owns
;;                           these four scores; it is not necessarily the account paying gas.
;;
;; OUT  -> "AQP-BOOT Step 4 done. score-ids=[coding={} bloodshed={} company-share={}
;;          company-snakes={}]. NEXT=Step7:dh-score-ids[0,2,4,5]=[{} {} {} {}]."
;;
;;      !! SAVE THIS. These four ids are `UDC_Makeid` values carrying THIS block's hash, they are
;;      consumed by transaction 7, and they cannot be recomputed once this transaction is mined.
;;
;; -------------------------------------------------------------------------------------------
;; !! THE INDEX TRAP -- these four are NOT the first four of Step 7's list
;; -------------------------------------------------------------------------------------------
;;   Step 7 takes ONE `dh-score-ids` list of NINE. This step supplies four of them, at
;;   NON-CONTIGUOUS positions:
;;
;;     index:  0        1        2        3        4        5        6      7      8
;;     from:   STEP 4   step 5   STEP 4   step 5   STEP 4   STEP 4   step5  step5  step5
;;             coding   sub-cod  bloodsh  sub-blo  share    snakes   sub-wc sub-nf sub-bun
;;
;;   So the four ids below go to slots 0, 2, 4, 5 -- interleaved with transaction 5's five.
;;   Neither step can emit a pasteable nine-element list on its own, which is why this output
;;   names its slots instead. The assembly happens in transaction 7, and that file will show the
;;   interleave explicitly rather than leaving it to be reconstructed from two outputs.
;;
;;   Take the four ids after `NEXT=Step7:dh-score-ids[0,2,4,5]=`.
;;
;; -------------------------------------------------------------------------------------------
;; !! OPEN QUESTION THIS TRANSACTION CREATES -- unresolved as of 2026-09-18
;; -------------------------------------------------------------------------------------------
;;   `Bloodshed` (created here) is attached to the DHBloodshed pool by transaction 7, making it an
;;   EMPLOYED score. But transaction 9 (`C_Step9_AddFvtScoreEntities`) links only the five
;;   subsidiary scores plus coding, snakes and shares -- it does NOT give `Bloodshed` an FVT
;;   ScoreEntityLink. Staking on that pool then aborts:
;;
;;     Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink
;;     or reward DPTF                                        05_FVT.pact:1210
;;
;;   Either the pipeline guard should tolerate an NFT-fed score with no FVT link, or Step 9 needs
;;   a tenth score and a treasury to pay it. Running this transaction is safe -- the problem only
;;   materialises at 7/9 -- but it is created here, so it is recorded here.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   `TS02-C3` deployed with `P|A_Define` run. Transactions 1-3 are NOT prerequisites of this one.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays four score issuances.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step4_CreateCoreScores
    PATRON_KONTO
    OWNER_KONTO                  ;; <- the score owner. Distinct from patron; decide deliberately.
)
