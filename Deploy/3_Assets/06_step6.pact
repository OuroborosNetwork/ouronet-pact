;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 6
;; AQP-BOOT.C_Step6_CreateOuroLpTriplet
;; ===========================================================================================
;; ESTIMATED GAS 73,294  (3.7% of a 2,000,000 block)
;;   measured, TX-BOOT-06 -- 3 liquidity scores + 2 boost links
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues THREE class-0 LIQUIDITY SCORES -- Silver, Bronze, Golden SnakePower -- all sharing one
;;   `lp-denominator`, and links bronze and golden to silver as the base.
;;   It does NOT create a pool or any farm links. Those come later:
;;     the class-0 DHOuroLp pool + employing this triplet on it  -> transaction 7
;;     the triplet/farm wiring                                    -> transaction 11
;;
;; -------------------------------------------------------------------------------------------
;; !! THE NAME COLLISION -- read this before you paste anything
;; -------------------------------------------------------------------------------------------
;;   Transaction 2 created three BOOST CLASSES called SilverSnakePower, BronzeSnakePower and
;;   GoldenSnakePower. This transaction creates three LIQUIDITY SCORES with THE SAME THREE NAMES.
;;
;;   They are different entities. They have different ids -- because `UDC_Makeid` embeds the block
;;   hash and these are two different transactions.
;;
;;   IN THE REPL THEY ARE BYTE-IDENTICAL. The whole suite runs under one `prev-block-hash`, so
;;   `SilverSnakePower-98c486052a51` is BOTH the boost class and the score, and passing one where
;;   the other belongs works perfectly. On mainnet it will not, and no test in this repository can
;;   show you the difference.
;;
;;   Transaction 7 wants the SCORES from here, not the boost classes from transaction 2. Its
;;   argument is `ouro-triplet-score-ids`. Take the list after `PASTE INTO Step7` in THIS
;;   transaction's output -- not the one from transaction 2, which goes to a different argument
;;   (`boost-class-ids`) of a different step.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- FIRST STEP THAT CONSUMES A PASTED LIST.
;;         `boost-class-ids` -- the three from TRANSACTION 2's output, in the order that output
;;         gives them (silver, bronze, golden). The step enforces `length = 3` before anything
;;         else, so a wrong-length list fails loudly; a wrong-ORDER list does not.
;;
;;         `lp-denominator` -- the FULL NATIVE DPTF ID of the OURO pool leg, not the ticker.
;;         REPL shape: "OURO-98c486052a51". This is an existing on-chain asset; you supply it.
;;
;;         `patron`, `owner-konto` -- as in transactions 4 and 5.
;;
;; OUT  -> score-ids, the echoed boost-class-ids, the boost-links, and ending with:
;;           PASTE INTO Step7 ouro-triplet-score-ids
;;           (these are the SCORES made here, NOT the Step 2 boost classes of the same name):
;;           ["…" "…" "…"]
;;
;;      Reshaped 2026-09-18 to a quoted pasteable list, and labelled explicitly against the name
;;      collision above. The ordering was already correct -- verified silver, bronze, golden
;;      against transaction 7's expected `[silver bronze golden]`.
;;
;;      !! SAVE IT. Block-hash-bearing ids, unrecomputable after mining.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   Transaction 2 must have run -- its boost classes are this step's input.
;;   The OURO DPTF must exist on chain (it is the `lp-denominator`).
;;   `TS02-C3` deployed with `P|A_Define` run.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays three liquidity-score issuances plus two boost links.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step6_CreateOuroLpTriplet
    PATRON_KONTO
    OWNER_KONTO
    "OURO-8Nh-JO8JO4F5"          ;; <- the live OURO DPTF. Same value in tx 8 and tx 11.
    ["SILVER_BOOST_CLASS_ID"     ;; <- the three from TRANSACTION 2's output, in its order.
     "BRONZE_BOOST_CLASS_ID"
     "GOLDEN_BOOST_CLASS_ID"]
)
