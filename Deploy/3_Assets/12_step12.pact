;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 12  (FINAL)
;; AQP-BOOT.C_Step12_AddFvtRewardLinks
;; ===========================================================================================
;; ESTIMATED GAS 34,168  (1.7% of a 2,000,000 block)
;;   measured, TX-BOOT-12
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Registers ONE reward token on each of the four treasury FVTs, with `multiplet-family-id` set
;;   to BAR ("|") -- i.e. plain rewards, not laddered through a family the way the farm's OURO
;;   reward is in transaction 11.
;;
;;     treasury            reward token
;;     SubsidiaryTreasury  Auryn
;;     CodingTreasury      wSTOA
;;     SnakesTreasury      Auryn        <- same token as the subsidiary treasury, deliberately
;;     SharesTreasury      Ouroboros
;;
;;   Auryn appears TWICE and Elite-Auryn not at all. That is the shipped mapping, not a
;;   transcription error -- read it off the four C_AddRewardLink calls in the source if you want
;;   to confirm before sending.
;;
;; -------------------------------------------------------------------------------------------
;; !! ARGUMENT ORDER IS AURYN, OUROBOROS, wSTOA -- THE TABLE ABOVE IS IN A DIFFERENT ORDER
;; -------------------------------------------------------------------------------------------
;;   The three reward parameters are declared:
;;       reward-auryn-id, reward-ouroboros-id, reward-wstoa-id
;;   The links are made in the order: auryn, wstoa, auryn, ouroboros.
;;   Fill the arguments by NAME, not by matching the table's reading order.
;;
;; -------------------------------------------------------------------------------------------
;; A LABELLING BUG IN THIS STEP'S OUTPUT WAS FIXED 2026-09-18
;; -------------------------------------------------------------------------------------------
;;   It used to print `reward-links=[sub={} coding={} snakes={} shares={}]` fed with the REWARD
;;   TOKEN ids, so `sub=<auryn-id>` looked like it was naming the sub-treasury when it was naming
;;   what that treasury had been linked TO. The same three reward ids were then printed again
;;   under `rewards=`, and the four TREASURY ids -- what the links actually attach to -- did not
;;   appear anywhere. Arity was always correct; the labels were not.
;;   It now prints each link as the pair it is: `{treasury}<-auryn`.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- the last consumption of transaction 8's output
;; -------------------------------------------------------------------------------------------
;;   four treasury ids <- transaction 8 (third and final use; 9 and 11 took them before)
;;   reward-auryn-id   <- AURYN-8Nh-JO8JO4F5, live mainnet DPTF
;;   reward-ouroboros-id <- the live Ouroboros DPTF. NOT SUPPLIED YET.
;;   reward-wstoa-id     <- the live wSTOA DPTF.     NOT SUPPLIED YET.
;;
;;   OUT -> "…Bootstrap complete — ready for inject/stake/collect."
;;          That sentence is the end of the asset tree. Nothing consumes this output.
;;
;; -------------------------------------------------------------------------------------------
;; !! STILL BLOCKED BY THE SAME UNRESOLVED QUESTION AS TRANSACTIONS 8 AND 9
;; -------------------------------------------------------------------------------------------
;;   If the pure `Bloodshed` score is meant to draw FVT rewards, then transaction 9 needs a ninth
;;   admission AND this step needs a fifth reward link plus a treasury to pay it. As written,
;;   neither exists, and staking on DHBloodshed aborts at 05_FVT.pact:1210.
;;   If instead the score is fed by the collection's internal NFT scores and never through FVT,
;;   this step is complete as-is and the guard upstream is what needs relaxing.
;;   Do not send transactions 8-12 until that is settled -- 8 mints the entities the rest binds to.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays four reward-link registrations.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step12_AddFvtRewardLinks
    PATRON_KONTO
    "TX8_SUB_TREASURY_ID"            ;; <- the FIVE treasury ids from transaction 8, by label
    "TX8_CODING_TREASURY_ID"
    "TX8_SNAKES_TREASURY_ID"
    "TX8_SHARES_TREASURY_ID"
    "TX8_BLOODSHED_TREASURY_ID"      ;; <- ADDED 2026-09-19 with BloodshedTreasury
    "AURYN-8Nh-JO8JO4F5"             ;; <- reward-auryn-id (sub, snakes AND bloodshed treasuries)
    "OUROBOROS_DPTF_ID"              ;; <- reward-ouroboros-id -- live id needed
    "WSTOA-8Nh-JO8JO4F5"             ;; <- reward-wstoa-id (coding AND bloodshed treasuries)
)
