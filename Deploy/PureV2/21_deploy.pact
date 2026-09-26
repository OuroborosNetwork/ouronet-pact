;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 21
;; STOICPAY -- write the one row DEMIPAD-STOICPAY cannot write for itself
;; =========================================================================================
;; TWO LINES. Everything else the sale needs is already on chain; this closes the only gap.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IS ALREADY DONE -- measured on mainnet, not assumed:
;;
;;   (DPTF.UR_Supply "STOICPAY-64EvuR4kgZHd")            => 250000000
;;   (DEMIPAD.UR_CheckRegistration "STOICPAY-64Ev…")     => true
;;   (DEMIPAD.UR_OpenForBusiness  "STOICPAY-64Ev…")      => true
;;   (DEMIPAD.UR_Price            "STOICPAY-64Ev…")      => {"starting-time": 2025-11-01T00:00:00Z}
;;
;; The token exists, it is registered on the launchpad, it is open, and its price row carries
;; the `starting-time` that `UR_GetPeriod` and `UR_KpayPID` read. Nothing here needs issuing,
;; registering, pricing or toggling.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IS MISSING
;;
;; `DEMIPAD-STOICPAY` declares one table, `KPAY|T|Properties`, holding one row keyed
;; `"StoicPayV3"` whose only field is `asset-id`. `UR_KpayID` is nothing but a read of it:
;;
;;     (at "asset-id" (read KPAY|T|Properties KPAY|INFO ["asset-id"]))
;;
;; `create-table` ran at deploy. The row was never written, and NO FUNCTION IN THE MODULE CAN
;; write it -- the table appears in the whole tree exactly three times: `deftable`, that one
;; `read`, and `create-table`. No `insert`, no `write`, no initialiser.
;;
;; That is the same design as `DEMIPAD-SPARK`, whose table is equally unwritable from inside and
;; whose row exists anyway -- written by an admin transaction under `acquire-module-admin`. The
;; precedent is `0_Sample/CodeStoa.pact`, which does exactly the two lines below for Spark.
;;
;; So every read that needs the sale's own id fails today with
;;
;;     No value found in table ouronet-ns.DEMIPAD-STOICPAY_KPAY|T|Properties for key: StoicPayV3
;;
;; and that is seven readers deep: UR_KpayID -> UR_GetPeriod, UR_KpayLeft, UR_KpayPID,
;; URC_KpayAmountCosts, URC_Acquire, URC_GetMaxBuy, C_BuyStoicPay.
;;
;; ------------------------------------------------------------------------------------------
;; SIGNER.  `ouronet-ns.dh_master-keyset` -- what `DALOS::GOV|Demiurgoi` returns, and what
;; DEMIPAD-STOICPAY's `GOV|MD_KPAY` keyset-ref-guard resolves to. `acquire-module-admin` needs it.
;; =========================================================================================

(namespace "ouronet-ns")

(acquire-module-admin ouronet-ns.DEMIPAD-STOICPAY)

(insert ouronet-ns.DEMIPAD-STOICPAY.KPAY|T|Properties "StoicPayV3"
    {"asset-id" : "STOICPAY-64EvuR4kgZHd"}
)

;; =========================================================================================
;; VERIFY afterwards -- all free /local reads, no gas:
;;
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_KpayID)                  -> "STOICPAY-64EvuR4kgZHd"
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_GetPeriod)               -> 1..25
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_KpayLeft)                -> KPAY still buyable this period
;;   (ouronet-ns.DEMIPAD-STOICPAY.URC_KpayAmountCosts 1 0.0)  -> {"pid": …, "wstoa": …}
;;
;; WORTH ACTUALLY LOOKING AT THE PERIOD. `starting-time` is 2025-11-01 and UR_GetPeriod splits
;; three years from there into 25 periods of 3,784,320 seconds, so the sale does not open at
;; period 1 -- it opens wherever today falls in that schedule, and `URv_PeriodAllocation` grows
;; with the period number. None of that arithmetic has ever executed on mainnet, because the row
;; it depends on has never existed; these four reads are its first run.
;;
;; Two answers mean the sale is closed rather than broken, and both look like success from the
;; outside because every NAME resolves: period -1 (starting-time in the future) and period 0
;; (more than three years past) each make UR_KpayLeft 0.0.
;;
;; THEN: `python3 REPL/tools/_registrylive.py --record`, and `npm run check:chain` in OuronetUI
;; -- three of its accept-list entries exist only because this row was missing.
;; =========================================================================================
