;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 8
;; AQP-BOOT.C_Step8_IssueFvtEntities
;; ===========================================================================================
;; ESTIMATED GAS 56,925  (2.8% of a 2,000,000 block)
;;   measured, TX-BOOT-08 -- five FVT issuances
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues FIVE FVT entities. Issuance only -- no links, no scores, no rewards. Those are
;;   transactions 9, 11 and 12.
;;
;;     entity                  class   denominator
;;     OuroLpFarm              0       the OURO DPTF id you pass as `lp-denominator`
;;     SubsidiaryTreasury      1       BOOT|TREASURY_COMMON
;;     CodingTreasury          1       BOOT|TREASURY_COMMON
;;     SnakesTreasury          1       BOOT|TREASURY_COMMON
;;     SharesTreasury          1       BOOT|TREASURY_COMMON
;;
;;   !! WHAT "class 1" MEANS IS UNRESOLVED -- TWO SOVEREIGN RULES DISAGREE.
;;
;;   Score classes are 0=LP, 1=DPTF, 2=DPOF, 3=DPSF, 4=DPNF. FVT classes are 0=Farm, 1=Vault,
;;   2=Treasury (05_FVT.pact:580). But the two admission functions do not agree:
;;
;;     URC_ScoreClassMatchesFvtClass   (05_FVT.pact)    vault(1) <- 1,3,4 = TF,SF,NF
;;                                                      treasury(2) <- 2 = OF
;;     URC_TripletCategoryMatchesFvtClass (02_SCORE)     VAULT_TF <-> 1
;;                                                      TREASURY_SF_NF <-> 2
;;
;;   Owner intent (2026-09-19): vaults take TF and OF; treasuries take SF and NF. The TRIPLET
;;   rule matches that. The SCORE rule does not -- it admits SF/NF into the vault and puts OF in
;;   the treasury, i.e. the two roles are effectively swapped relative to the design.
;;
;;   CONSEQUENCE HERE: this step issues four entities NAMED *Treasury at fvt-class 1, and
;;   transaction 9 links the SF/NF subsidiary scores to them. That succeeds only because the
;;   score rule permits classes 3 and 4 at fvt-class 1. If the triplet rule is the correct one,
;;   these four should be class 2 and this transaction is issuing them wrong.
;;
;;   DO NOT RUN THIS UNTIL RULED ON. Changing the class after issuance is not a re-run; these are
;;   minted entities with ids baked into every later step.
;;
;; -------------------------------------------------------------------------------------------
;;
;;   Like transaction 7 after today's change, this step derives all five ids itself via
;;   `UDC_Makeid` on its own name constants. They are minted in this transaction, so that is
;;   correct on mainnet. Nothing here needs an id from you.
;;
;; -------------------------------------------------------------------------------------------
;; THE `lp-denominator` SWITCH -- a real branch, not a formality
;; -------------------------------------------------------------------------------------------
;;   Pass the full OURO DPTF id  -> OuroLpFarm is issued as a class-0 farm.
;;   Pass the empty string ""    -> the farm is SKIPPED entirely and the output echoes
;;                                  `farm=skipped`. You get four treasuries and no farm.
;;
;;   Use the SAME value you gave transaction 6. If they disagree, the farm and the LP triplet are
;;   denominated differently and transaction 11 wires a farm the triplet does not belong to.
;;
;;   Skipping is a deliberate vault-only bootstrap path. If you skip it here, transaction 11 has
;;   no farm to wire and must also be skipped -- do not run 11 against `farm=skipped`.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- `patron`, `owner-konto` (the FVT owner), and `lp-denominator` (same as transaction 6).
;;         Nothing threaded from a previous step's output.
;;
;; OUT  -> "AQP-BOOT Step 8 done. fvt-ids=[farm={} sub-treasury={} coding-treasury={}
;;          snakes-treasury={} shares-treasury={}]. NEXT=Step9:C_AddScoreEntity."
;;
;;      THESE FIVE IDS ARE CONSUMED THREE TIMES OVER. This is the most reused output in the tree:
;;
;;        transaction 9  <- sub, coding, snakes, shares treasuries (4 of the 5)
;;        transaction 11 <- farm-id
;;        transaction 12 <- sub, coding, snakes, shares treasuries again
;;
;;      They are taken as FOUR SEPARATE STRING ARGUMENTS by 9 and 12, not as a list, so there is
;;      no pasteable bracket form to give you here -- the labelled output is the usable shape.
;;
;;      !! SAVE IT. Block-hash-bearing, unrecomputable after mining, and needed by three later
;;      transactions rather than one. Losing this output costs more than losing any other.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   `TS02-C3` deployed with `P|A_Define` run. The OURO DPTF must exist if you are passing it.
;;   Transaction 6 is not a hard prerequisite, but use its `lp-denominator` for consistency.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays five FVT issuances (four if the farm is skipped).
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step8_IssueFvtEntities
    PATRON_KONTO
    OWNER_KONTO                  ;; <- the FVT owner
    "OURO-8Nh-JO8JO4F5"          ;; <- same as tx 6. "" here would skip the farm entirely.
)
