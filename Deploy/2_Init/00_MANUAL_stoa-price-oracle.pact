;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL
;; The STOA oracle price. *** RUN BEFORE ANY STOA-CHARGING OPERATION. ***
;; ---------------------------------------------------------------------------
;; NOT GENERATED, and named MANUAL so it cannot be mistaken for generated output. The VALUE
;; below is an owner decision -- a price peg -- which no generator can derive from the tree.
;;
;; WHAT IS BROKEN
;;   (ouronet-ns.DALOS.UR_UsagePrice "stoa|price")
;;     -> No value found in table ouronet-ns.DALOS_DALOS|PricesTable for key: stoa|price
;;
;; `IGNIS::UC_StoaPrice` divides by this key, and a failed table read is NOT catchable -- `try`
;; does not stop it. So every STOA-charging operation aborts outright rather than degrading.
;; Hit immediately after the IMC delta in 02_init.pact unblocked AQP-BOOT Step 2.
;;
;; The rest of the table IS populated -- `dptf` 20, `dpnf` 50, `standard` 1, `smart` 2, measured
;; on mainnet 2026-10-02 -- so this one key was simply never written. Those four are stored
;; values read directly and are NOT affected by this write.
;;
;; WHAT THE NUMBER MEANS, BEFORE YOU SIGN IT
;;   0.1 is the hard peg the REPL seeds, from [4.0]_Sovereign-Executor: "STOA oracle price in
;;   USD. HARD-PEGGED at $0.10 until a real price feed exists. UC_StoaPrice divides by this, so
;;   ISSUE functions charge a constant DOLLAR value: when this moves, the STOA amount moves but
;;   the value the user pays does not."
;;
;;   Measured against mainnet with the peg applied, so the cost is known rather than assumed:
;;     AQP-ANK.URCi_IssueAnchorStoa true   ->  100 STOA   (anchor + new boost class)
;;     AQP-ANK.URCi_IssueAnchorStoa false  ->   50 STOA   (anchor into an existing class)
;;     IGNIS.UC_StoaPrice "issue-nft"      ->  250 STOA
;;   AQP-BOOT Step 2 issues three anchors with acnoi=true and one with false: 350 STOA = $35.
;;
;; SIGNING
;;   `DALOS|A_UpdateUsagePrice` is admin-gated and resolves to `ouronet-ns.dh_master-keyset`
;;   (pred keys-any), so EITHER of its two keys alone satisfies it.
;;
;;   NOT GAS-STATION PAYABLE. `DALOS::GAS_PAYER` whitelists single-form coin.C_ / ouronet-ns.TS /
;;   DSP / STOAICO, two coin.C_ forms, or namespace+transmute+let. This is `(namespace …)` plus
;;   one call and matches none -- pay from a funded account.
;;
;; AFTER RUNNING, confirm as a /local read (no signature):
;;   (ouronet-ns.DALOS.UR_UsagePrice "stoa|price")   -> 0.1
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; Replace with the signing Ouronet account.
(TS01-A.DALOS|A_UpdateUsagePrice
    "OURONET_ADMIN_ACCOUNT"
    "stoa|price"
    0.1
)
