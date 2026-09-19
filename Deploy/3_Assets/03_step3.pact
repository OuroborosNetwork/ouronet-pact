;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 3
;; AQP-BOOT.C_Step3_CreateBoosterAnchorClasses
;; ===========================================================================================
;; ESTIMATED GAS 166,832  (8.3% of a 2,000,000 block)
;;   measured, TX-BOOT-03 -- 11 anchors, the heaviest of the early steps
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Issues ELEVEN non-fungible anchors on the KBN collection, creating THREE booster classes.
;;   Same create-then-attach pattern as transaction 2: the FIRST anchor of each family passes a
;;   class NAME with flag `true` and creates the class; the rest pass that class's ID with flag
;;   `false` and attach to it.
;;
;;     family  anchor                    trait   value                    weight   flag
;;     Unity   Elk0nite                  Eyes    Elk0nite Unity Glasses    100.0   CREATES
;;             Osmiridium                Eyes    Osmiridium Unity Glasses  300.0   attach
;;             Titanium                  Eyes    Titaniumgold Unity Gl.    900.0   attach
;;             LegendaryUnityBooster     Rarity  Legendary                1000.0   attach
;;     Stoa    VegoldEyes                Eyes    vEGLD Focus              1000.0   CREATES
;;             LegendaryStoaBooster      Rarity  Legendary                3500.0   attach
;;     Vesta   RedEyes                   Eyes    Red                       250.0   CREATES
;;             GreenEyes                 Eyes    Green                     250.0   attach
;;             BlueEyes                  Eyes    Blue                      250.0   attach
;;             LegendaryVestaBooster     Rarity  Legendary                3500.0   attach
;;             RGBEyes                   --      (SET anchor)             1000.0   attach
;;
;;   THE LAST ONE USES A DIFFERENT FUNCTION. `RGBEyes` goes through
;;   `AQP-ANK|C_IssueNonFungibleSetAnchor`, not `...NonFungibleAnchor`, and carries a trailing
;;   `1` argument the others do not. It anchors against the Bunny SET DEFINITION created in
;;   transaction 1 rather than against a single trait value -- which is why transaction 1 has to
;;   have run, and why this anchor has no trait/value pair in the table above.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- `kbn-id`, THE SAME VALUE as transactions 1 and 2. Third and final use.
;;
;; OUT  -> "AQP-BOOT Step 3 done. kbn-id={}. anchor-ids=[11]. boost-class-ids=[unity stoa vesta].
;;          NEXT=none-for-Steps4-7."
;;
;;      NOTHING IN STEPS 4-7 CONSUMES THESE IDS. That is what `NEXT=none-for-Steps4-7` means, and
;;      it is why this output was not reshaped into a pasteable list the way transaction 2's was:
;;      there is no next argument to paste it into.
;;
;; -------------------------------------------------------------------------------------------
;; !! SAVE THIS OUTPUT ANYWAY -- IT IS THE ONLY RECORD OF FOURTEEN IDS
;; -------------------------------------------------------------------------------------------
;;   These fourteen ids (11 anchors + 3 boost classes) are what USERS boost against, and what the
;;   UI will need to display and reference. They are `UDC_Makeid` values, so they embed the
;;   `prev-block-hash` of the block THIS transaction lands in.
;;
;;   Once this transaction is mined you CANNOT recompute them. `UDC_Makeid "Elk0nite"` run later
;;   returns a different string, because it will be a different block. Your only recourse would be
;;   to query the chain for them.
;;
;;   So: capture the full return string and keep it with your deployment record. This is the one
;;   moment those ids are handed to you.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES
;; -------------------------------------------------------------------------------------------
;;   Transaction 1 (the Bunny set definition -- `RGBEyes` anchors against it).
;;   `TS02-C3` deployed with its `P|A_Define` run; all twelve calls route through it.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`, and the patron pays eleven anchor issuances -- the heaviest
;; of the early steps.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step3_CreateBoosterAnchorClasses
    PATRON_KONTO
    "KBN_COLLECTION_ID"          ;; <- same value as transactions 1 and 2. Last use.
)
