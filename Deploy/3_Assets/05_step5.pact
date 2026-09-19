;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 5
;; AQP-BOOT.C_Step5_CreateSubsidiaryScores
;; ===========================================================================================
;; ESTIMATED GAS ~unmeasured
;;   as Step 4 -- five score issuances, likely 60-90k by comparison with Step 2
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues the FIVE subsidiary scores, completing the nine that transaction 7 wires to pools.
;;
;;     score                      kind           aqp-class   extra
;;     SubsidiaryCodingDivision   SemiFungible   6           true
;;     SubsidiaryWonderCoach      SemiFungible   6           false
;;     SubsidiaryBloodshed        NonFungible    6           -1
;;     SubsidiaryNosferatu        NonFungible    6           -1
;;     SubsidiaryBunnies          NonFungible    6           -1
;;
;;   The three NonFungible ones take `-1` where transaction 4's `Bloodshed` took `0`. That is the
;;   deb-boost setting, and the output confirms it as `deb-boost=enabled×5`.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- same two accounts as transaction 4: `patron` and `owner-konto`. Nothing is threaded in.
;;         Use the SAME `owner-konto` you used in transaction 4 unless you intend the subsidiary
;;         scores to be owned by a different account.
;;
;; OUT  -> ends with a quoted, pasteable list:
;;           PASTE INTO Step7 dh-score-ids slots [1,3,6,7,8] IN THIS ORDER: ["…" "…" "…" "…" "…"]
;;
;;      !! SAVE IT. These five ids carry THIS block's hash and cannot be recomputed after mining.
;;
;; -------------------------------------------------------------------------------------------
;; A BUG WAS FOUND AND FIXED IN THIS STEP'S OUTPUT -- 2026-09-18
;; -------------------------------------------------------------------------------------------
;;   The `NEXT=Step7:dh-score-ids[1,3,6,7,8]` list used to be emitted in CREATION order:
;;
;;     coding, wondercoach, bloodshed, nosferatu, bunnies
;;
;;   but slots [1,3,6,7,8] are, per transaction 7's own map:
;;
;;     1 SubsidiaryCodingDivision   3 SubsidiaryBloodshed   6 SubsidiaryWonderCoach
;;     7 SubsidiaryNosferatu        8 SubsidiaryBunnies
;;
;;   Positions 2 and 3 were TRANSPOSED against the slots the same string named. Pasting it would
;;   have put SubsidiaryWonderCoach in slot 3 and SubsidiaryBloodshed in slot 6 -- so the
;;   DHBloodshed pool would carry the WonderCoach subsidiary score and DHWonderCoach the Bloodshed
;;   one. PERMANENTLY, and WITHOUT ERRORING, because both are valid score ids.
;;
;;   It now emits in slot order, quoted and pasteable. This is the same defect class as
;;   transaction 2's boost-class ordering; both were found by checking each format string's output
;;   against the slot map it claims to fill, rather than by reading it.
;;
;; -------------------------------------------------------------------------------------------
;; ASSEMBLING TRANSACTION 7's NINE-ELEMENT LIST
;; -------------------------------------------------------------------------------------------
;;   index:  0        1        2        3        4        5        6       7       8
;;   from:   tx4      TX5      tx4      TX5      tx4      tx4      TX5     TX5     TX5
;;           coding   sub-cod  bloodsh  sub-blo  share    snakes   sub-wc  sub-nf  sub-bun
;;
;;   Transaction 4 gives you slots 0,2,4,5 in its own order; this one gives 1,3,6,7,8 in its
;;   order. Interleave them as above. Transaction 7's file will restate this map so you do not
;;   have to hold two outputs in your head.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   `TS02-C3` deployed with `P|A_Define` run. Transaction 4 is NOT a prerequisite -- these five
;;   are independent of the core four -- but run it first anyway so both outputs are in hand
;;   before transaction 7 needs them.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays five score issuances.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step5_CreateSubsidiaryScores
    PATRON_KONTO
    OWNER_KONTO                  ;; <- same owner as transaction 4, unless deliberately different.
)
