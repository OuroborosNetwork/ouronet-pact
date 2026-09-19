;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 2
;; AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses
;; ===========================================================================================
;; ESTIMATED GAS 61,609  (3.1% of a 2,000,000 block)
;;   measured, TX-BOOT-02 -- 4 anchor issuances
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues FOUR non-fungible anchors on the KBN collection, and in doing so creates THREE
;;   SnakePower boost classes:
;;
;;     anchor                     trait        value              boost class        weight
;;     OuroborosRain              Background   "Ouroboros Rain"   BronzeSnakePower    50.0
;;     AurynRain                  Background   "Auryn Rain"       SilverSnakePower   100.0
;;     EliteAurynRain             Background   "Elite-Auryn Rain" GoldenSnakePower   200.0
;;     LegendarySnakeTokenRain    Rarity       "Legendary"        (existing golden)  400.0
;;
;;   NOTE THE FOURTH IS DIFFERENT, and it is not a typo in the source. The first three pass a
;;   boost-class NAME with the flag `true`; the fourth passes the already-created GOLDEN CLASS ID
;;   with the flag `false`. So three anchors CREATE a class each, and the fourth ATTACHES to the
;;   golden class that `EliteAurynRain` just made. That is why four anchors yield three classes,
;;   and why `LegendarySnakeTokenRain` is a Rarity trait rather than a Background one.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- `kbn-id`, THE SAME VALUE YOU PASSED TO TRANSACTION 1. Step 1 echoes it for exactly
;;         this reason. Do not re-derive it; copy it.
;;
;; OUT  -> "AQP-BOOT Step 2 done. kbn-id={}. anchor-ids=[{} {} {} {}].
;;          boost-class-ids=[bronze={} silver={} golden={}].
;;          NEXT=Step6:boost-class-ids=[{} {} {}]."
;;
;;      !! CORRECTED 2026-09-18. An earlier draft of this file said these ids are deterministic
;;      and recomputable. THAT IS WRONG AND IT IS THE DANGEROUS DIRECTION TO BE WRONG IN.
;;
;;      `UDC_Makeid ticker` returns `<ticker>-<first 12 chars of prev-block-hash>`. The id depends
;;      on THE BLOCK THE TRANSACTION LANDS IN. Two calls with the same ticker in two different
;;      blocks return two different ids.
;;
;;      THE REPL CANNOT SHOW YOU THIS. The whole suite runs under a single `prev-block-hash`
;;      (`98c486052a51...`), so all 194 ids in the fixture share one suffix and re-deriving an id
;;      in a later transaction always matches. On mainnet it never will.
;;
;;      SO: the ids in this output MUST be carried forward from here. Do not recompute them in a
;;      later transaction -- that is a silent, unrecoverable mis-wiring, and the test suite is
;;      structurally incapable of catching it.
;;
;; -------------------------------------------------------------------------------------------
;; !! THE ORDERING TRAP -- read this before you get to transaction 6
;; -------------------------------------------------------------------------------------------
;;   The output prints the boost classes TWICE, in TWO DIFFERENT ORDERS:
;;
;;     boost-class-ids=[bronze silver golden]      <- creation order. NOT what Step 6 wants.
;;     NEXT=Step6:boost-class-ids=[silver bronze golden]   <- THIS is what Step 6 wants.
;;
;;   Step 6 expects [Silver Bronze Golden] -- indices [1 0 2] of the creation-order list. The
;;   function's own @doc says so. Take the THREE IDS AFTER `NEXT=Step6:` and use those verbatim;
;;   do not read the `boost-class-ids=` list and assume its order carries forward.
;;
;;   Getting this wrong would not error. It would silently wire the 50.0-weight class where the
;;   100.0 belongs, and the pools would pay the wrong boosts forever.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   Transaction 1 must have run (the Bunny set definition must exist on KBN).
;;   `TS02-C3` must be deployed AND have had its `P|A_Define` run -- every call below goes through
;;   `TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor`.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`, and the patron pays four anchor issuances.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses
    PATRON_KONTO
    "KBN_COLLECTION_ID"          ;; <- same value as transaction 1. Transaction 3 needs it too.
)
