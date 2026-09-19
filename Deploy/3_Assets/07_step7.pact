;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 7
;; AQP-BOOT.C_Step7_CreatePoolsAndScores
;; ===========================================================================================
;; ESTIMATED GAS ~267,000  (13% of a 2,000,000 block)
;;   Measured as 179,192 + 87,847 -- the boot suite performs this work as two hand-rolled
;;   transactions (TX-BOOT-07 / 07b); C_Step7 does all of it in one, so treat this as an upper
;;   bound with a little slack. It is the heaviest transaction in the asset tree.
;; ===========================================================================================
;;
;; WHAT THIS DOES -- THIS IS THE WIRING STEP, NOT AN ISSUANCE STEP
;;   Issues SEVEN pools and attaches TWELVE scores to them. Everything it attaches was created
;;   earlier; nothing here is new except the pools.
;;
;;     pool               aqp-class  asset passed in        scores attached
;;     DHCodingDivision   3 DPSF     DHCD-… dpsf-id         TheCodingDivision, SubsidiaryCodingDivision
;;     DHBloodshed        4 DPNF     DHB-…  dpnf-id         Bloodshed, SubsidiaryBloodshed
;;     DHCompany          3 DPSF     E|DH-… dpsf-id         DemiourgosShareholder, DemiourgosSnakes
;;     DHWonderCoach      3 DPSF     DHWC-… dpsf-id         SubsidiaryWonderCoach
;;     DHNosferatu        4 DPNF     DHN-…  dpnf-id         SubsidiaryNosferatu
;;     DHBunnies          4 DPNF     KBN-…  dpnf-id         SubsidiaryBunnies
;;     DHOuroLp           0 LP       native LP id           Silver, Bronze, Golden SnakePower
;;
;; -------------------------------------------------------------------------------------------
;; ITS TWO HALVES BEHAVE DIFFERENTLY ON MAINNET -- this is the crux of the whole sequence
;; -------------------------------------------------------------------------------------------
;;   POOL IDS -- NO LONGER PASSED IN AT ALL. Changed 2026-09-18, and this was the right question
;;   to ask: if this step mints the seven pools from name literals it already holds, in this
;;   transaction, then `UDC_Makeid` on those same literals returns exactly the ids it is about to
;;   create. A caller supplying them could only ever match or be wrong -- never more right. So
;;   `dh-pool-ids` and `ouro-lp-pool-id` were removed from the signature (7 arguments -> 5), one
;;   of the four length guards went with them, and an entire class of mainnet operator error
;;   disappeared. The function now asks only for what it cannot know.
;;
;;   SCORE IDS -- MUST be pasted from earlier outputs. The nine dh-scores were created in
;;   transactions 4 and 5; the three triplet scores in transaction 6. Different transactions,
;;   different blocks, different ids. Recomputing them here yields ids that do not exist.
;;   THE REPL CANNOT SHOW THIS -- one block hash for the whole suite means recomputed and real
;;   ids coincide there and never will on chain.
;;
;; -------------------------------------------------------------------------------------------
;; THE NINE-SLOT INTERLEAVE -- assembled from TWO outputs
;; -------------------------------------------------------------------------------------------
;;   index:  0        1        2        3        4        5        6       7       8
;;   from:   tx4      tx5      tx4      tx5      tx4      tx4      tx5     tx5     tx5
;;           coding   sub-cod  bloodsh  sub-blo  share    snakes   sub-wc  sub-nf  sub-bun
;;
;;   Transaction 4's output gives you slots 0,2,4,5 in its own order (coding, bloodshed, share,
;;   snakes). Transaction 5's gives 1,3,6,7,8 in ITS order -- and that order was WRONG until
;;   2026-09-18: it emitted wondercoach and bloodshed transposed against the slots it named, which
;;   would have put the WonderCoach subsidiary score on the DHBloodshed pool and vice versa,
;;   permanently and without erroring. If you captured a Step 5 output before that fix, DISCARD IT
;;   and re-read the order from the fixed string.
;;
;; -------------------------------------------------------------------------------------------
;; THE THREE TRIPLET SCORES -- not the boost classes of the same name
;; -------------------------------------------------------------------------------------------
;;   `ouro-triplet-score-ids` wants the LIQUIDITY SCORES from transaction 6, not the BOOST CLASSES
;;   from transaction 2. Both sets are named SilverSnakePower / BronzeSnakePower / GoldenSnakePower
;;   and in the REPL they are byte-identical. On mainnet they are not. Take the list from
;;   transaction 6's `PASTE INTO Step7 ouro-triplet-score-ids` line.
;;
;; -------------------------------------------------------------------------------------------
;; THE SIX COLLECTION ASSET IDS -- already on mainnet, you supply them
;; -------------------------------------------------------------------------------------------
;;   dh-asset-ids[0..5], in THIS order: coding, bloodshed, company, wondercoach, nosferatu, bunnies
;;   REPL shapes: "DHCD-…", "DHB-…", "E|DH-…", "DHWC-…", "DHN-…", "KBN-…"
;;   ouro-lp-asset-id -- the native LP id, REPL shape "W|SSTOA-OURO-WSTOA|LP-…"
;;
;;   The step enforces all four list LENGTHS before it derives anything, so a wrong-length list
;;   fails with a sentence naming which argument. A wrong-ORDER list does not.
;;
;; -------------------------------------------------------------------------------------------
;; !! DO NOT RUN THIS YET -- UNRESOLVED
;; -------------------------------------------------------------------------------------------
;;   Attaching `Bloodshed` to DHBloodshed makes it an EMPLOYED score. Transaction 9 links only the
;;   five subsidiaries plus coding, snakes and shares -- it gives `Bloodshed` no FVT link. Staking
;;   on that pool then aborts:
;;       Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink
;;       or reward DPTF                                     05_FVT.pact:1210
;;   Either the guard should tolerate an NFT-fed score with no FVT link, or transaction 9 needs a
;;   tenth score and a treasury. Owner ruling 2026-09-18 confirmed Bloodshed SHOULD carry both
;;   scores, so the wiring below is right and the gap is downstream.
;;
;;   ALSO: `C_Step7` has never been executed successfully anywhere in the suite -- its only six
;;   call sites are expect-failures probing its length guards. The WORK is covered (the hand-rolled
;;   TX-BOOT-07/07b do it), but this function's success path is unexecuted.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays 7 pool issuances + 12 score attachments.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step7_CreatePoolsAndScores
    PATRON_KONTO
    ;; dh-asset-ids -- six live collections: coding, bloodshed, company, wondercoach, nosferatu, bunnies
    ["DHCD_ASSET_ID" "DHB_ASSET_ID" "EDH_ASSET_ID" "DHWC_ASSET_ID" "DHN_ASSET_ID" "KBN_ASSET_ID"]
    "OURO_LP_ASSET_ID"   ;; NOT the OURO DPTF. This is the LP TOKEN of the OURO swap pair --
                         ;; REPL shape "W|SSTOA-OURO-WSTOA|LP-...". The OURO DPTF itself
                         ;; (OURO-8Nh-JO8JO4F5) is what tx 6, 8 and 11 take; this is not it.
    ;; NOTE: the seven POOL IDS are no longer arguments -- see the section above. This step mints
    ;; those pools from its own name literals and derives their ids itself.
    ;; dh-score-ids -- NINE, interleaved from tx4 (slots 0,2,4,5) and tx5 (slots 1,3,6,7,8)
    ["TX4_CODING"   "TX5_SUB_CODING"  "TX4_BLOODSHED" "TX5_SUB_BLOODSHED" "TX4_SHARE"
     "TX4_SNAKES"   "TX5_SUB_WONDERCOACH" "TX5_SUB_NOSFERATU" "TX5_SUB_BUNNIES"]
    ;; ouro-triplet-score-ids -- the SCORES from tx6, not tx2's boost classes
    ["TX6_SILVER_SCORE" "TX6_BRONZE_SCORE" "TX6_GOLDEN_SCORE"]
)
