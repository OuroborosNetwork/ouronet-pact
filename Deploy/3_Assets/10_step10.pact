;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 10
;; AQP-BOOT.C_Step10_IssueMultipletFamily
;; ===========================================================================================
;; ESTIMATED GAS 11,237  (0.6% of a 2,000,000 block)
;;   measured, TX-BOOT-10 -- one issuance; the cheapest step after transaction 1
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues ONE chain-wide MultipletFamily (rank 3) describing the OURO -> Auryn -> Elite-Auryn
;;   Coil/Curl ladder, binding the three tokens to the two ATS pairs that move between them:
;;
;;     token-0  OURO         --\
;;                              >-- ats-0-1  (Auryndex)        token-0 RT on this pair
;;     token-1  Auryn        --/            token-1 is RBT here and RT on the next
;;                              >-- ats-1-2  (EliteAuryndex)
;;     token-2  Elite-Auryn  --/            token-2 RBT
;;
;; -------------------------------------------------------------------------------------------
;; ALL FIVE INPUTS ARE LIVE MAINNET IDS -- filled in below, 2026-09-19
;; -------------------------------------------------------------------------------------------
;;   Nothing here comes from an earlier transaction in this sequence. These are pre-existing
;;   chain assets, so this step could in principle run at any point -- it is placed at 10 because
;;   transaction 11 consumes its output.
;;
;;     ouro-id        OURO-8Nh-JO8JO4F5
;;     auryn-id       AURYN-8Nh-JO8JO4F5
;;     elite-auryn-id ELITEAURYN-8Nh-JO8JO4F5
;;     ats-0-1-id     Auryndex-O136CBn22ncY          (OURO -> Auryn)
;;     ats-1-2-id     EliteAuryndex-O136CBn22ncY     (Auryn -> Elite-Auryn)
;;
;;   `ouro-id` is THE SAME VALUE passed as `lp-denominator` to transactions 6 and 8, and as
;;   `ouro-id` to transaction 11. It is NOT the same as transaction 7's `ouro-lp-asset-id`, which
;;   is the LP token of the swap pair, not the OURO DPTF.
;;
;; -------------------------------------------------------------------------------------------
;; THE ONE ID IN THIS WHOLE TREE THAT IS GENUINELY DETERMINISTIC
;; -------------------------------------------------------------------------------------------
;;   family-id = (concat ["F" "|" ouro-id "|" auryn-id "|" elite-auryn-id])
;;
;;   It is a plain string concatenation -- NOT `UDC_Makeid` -- so it carries no block hash and
;;   can be computed before the transaction is ever sent. With the ids above it is exactly:
;;
;;     F|OURO-8Nh-JO8JO4F5|AURYN-8Nh-JO8JO4F5|ELITEAURYN-8Nh-JO8JO4F5
;;
;;   Transaction 11 takes this as `multiplet-family-id`. You can paste it from the output, or
;;   simply write it -- both give the same string, which is true of nothing else in this sequence.
;;   Transaction 11's `triplet-id` has the same property (`T|bronze|silver|golden`).
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING
;; -------------------------------------------------------------------------------------------
;; IN   <- nothing from this sequence. Five live chain ids, above.
;; OUT  -> "AQP-BOOT Step 10 done. multiplet-family-id={}. tokens=[ouro={} auryn={} elite={}]
;;          ats=[{} {}]. NEXT=Step11:C_IssueTriplet+AddScoreEntity."
;;         Consumed by transaction 11 only.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   The three DPTFs and both ATS pairs must be live (they are -- these are existing mainnet
;;   assets). `TS02-C3` deployed with `P|A_Define` run.
;;   Independent of transactions 1-9; only 11 depends on it.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays one MultipletFamily issuance.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step10_IssueMultipletFamily
    PATRON_KONTO
    "OURO-8Nh-JO8JO4F5"              ;; token-0  -- same DPTF as tx 6 / tx 8 lp-denominator
    "AURYN-8Nh-JO8JO4F5"             ;; token-1
    "ELITEAURYN-8Nh-JO8JO4F5"        ;; token-2
    "Auryndex-O136CBn22ncY"          ;; ats-0-1  OURO -> Auryn
    "EliteAuryndex-O136CBn22ncY"     ;; ats-1-2  Auryn -> Elite-Auryn
)
