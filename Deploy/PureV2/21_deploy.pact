;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 21
;; STOICPAY (KPAY) BRING-UP -- issue the token, register the asset, define the price,
;; and write the one row that DEMIPAD-STOICPAY cannot write for itself
;; =========================================================================================
;; NOT A MODULE UPGRADE. No source changes. This is a one-shot administrative transaction,
;; the same shape as the Spark bring-up recorded in `0_Sample/CodeStoa.pact`.
;;
;; ------------------------------------------------------------------------------------------
;; THE GAP, PRECISELY
;;
;; `DEMIPAD-STOICPAY` declares ONE table, `KPAY|T|Properties`, holding ONE row keyed
;; `"StoicPayV3"` whose only field is `asset-id`. `UR_KpayID` is nothing but
;;
;;     (at "asset-id" (read KPAY|T|Properties KPAY|INFO ["asset-id"]))
;;
;; `create-table` ran at deploy. **Nothing ever wrote the row, and no function in the module
;; can** -- grep the whole tree: the table appears in exactly three places, `deftable`,
;; that one `read`, and `create-table`. There is no `insert`, no `write`, no `A_Initialise`.
;;
;; That is not a defect in the module. It is the same design as `DEMIPAD-SPARK`, whose table is
;; equally unwritable from inside and whose row exists anyway -- written by an admin transaction
;; under `acquire-module-admin`. This file is that transaction for StoicPay.
;;
;; Every read that needs the sale's own asset id therefore fails today with
;;
;;     No value found in table ouronet-ns.DEMIPAD-STOICPAY_KPAY|T|Properties for key: StoicPayV3
;;
;; and that is FOUR readers deep, not one: `UR_KpayID` -> `UR_GetPeriod`, `UR_KpayLeft`,
;; `UR_KpayPID`, `URC_KpayAmountCosts`, `URC_Acquire`, `URC_GetMaxBuy`, `C_BuyStoicPay`.
;;
;; ------------------------------------------------------------------------------------------
;; WHY THE ONE-LINE INSERT ALONE WOULD BE WRONG
;;
;; The row's `asset-id` must name a REAL DPTF token. Measured on mainnet:
;;
;;     (filter (lambda (x) (contains "KPAY" x)) (DPTF.UR_KEYS))   =>   []
;;
;; There is no KPAY token. And `DEMIPAD.UR_CheckRegistration` is false for it, so the asset is
;; not registered on the launchpad either. Writing the row first would point the sale at a token
;; that does not exist -- and `UR_KpayID` would then succeed while everything downstream failed,
;; which is strictly worse than the honest failure it produces now.
;;
;; So the order below is the order the Spark bring-up used, and it is not rearrangeable.
;;
;; ------------------------------------------------------------------------------------------
;; THE PRICE OBJECT IS A DIFFERENT SHAPE FROM SPARK'S, and this is the easiest thing to get
;; wrong. `DEMIPAD::UR_Price` returns an UNTYPED `object`, so its keys are per-sale. Spark's is
;; `{id, boost, pid}` -- measured live. StoicPay reads `starting-time` off it, in
;; `UR_GetPeriod` and `UR_KpayPID`, and Spark's row does not have that key. A price object
;; copied from Spark would deploy cleanly and then fail inside the period calculation.
;;
;; StoicPay reads exactly two keys: `starting-time` (a `time`) and `pid` (a `decimal`).
;;
;; ------------------------------------------------------------------------------------------
;; THE PERIOD MACHINERY RUNS FOR THE FIRST TIME HERE
;;
;; `UR_GetPeriod` splits three years into 25 periods of 3,784,320 seconds from `starting-time`,
;; and `URv_PeriodAllocation` is `20,000,000 + 1,000,000 * Sk` over a decaying series. NONE of
;; that has ever executed on mainnet, because the row it depends on has never existed. Whatever
;; `starting-time` is set to below decides the period the sale opens in -- a time in the past
;; opens mid-schedule, and a time before `block-time` by more than three years returns period 0,
;; which makes `URv_PeriodAllocation` 0.0 and `UR_KpayLeft` 0.0. Set it deliberately.
;;
;; ------------------------------------------------------------------------------------------
;; SIGNERS.  `ouronet-ns.dh_master-keyset` -- that is what `DALOS::GOV|Demiurgoi` returns, and
;; DEMIPAD-STOICPAY's `GOV|MD_KPAY` is a `keyset-ref-guard` over it. `acquire-module-admin`
;; needs it for the insert; the Talos `A_*` calls need it for `P|TALOS-SUMMONER`.
;;
;; FILL IN before running: <PATRON>, <STARTING-TIME>, <PID>, and the issuance parameters.
;; =========================================================================================

(namespace "ouronet-ns")

(let
    (
        (patron:string          "<PATRON>")             ;; a Demiurgoi-owned Ouronet account
        (lpad-sc:string         (ouronet-ns.DEMIPAD.UR_PAD_LEDGER_ACCOUNT))
        (starting-time:time     (time "<STARTING-TIME>"))   ;; e.g. "2026-10-01T00:00:00Z"
        (pid:decimal            <PID>)                  ;; dollar price per KPAY at period 1
    )
    [
    ;;[0]  ISSUE THE TOKEN. Mirrors the Spark issuance: a true fungible, then the frozen link,
    ;;     then mint + the launchpad's mint/burn roles. `C_Issue` returns the id list; the token
    ;;     id is element 0 and is what every step below refers to.
    ;;     KEPT SEPARATE from the rest on purpose -- if issuance is already done, skip to [1]
    ;;     and substitute the existing id.
      "STEP 0 -- issue the KPAY true fungible; see 0_Sample/CodeStoa.pact for the Spark call"

    ;;[1]  REGISTER THE ASSET ON THE LAUNCHPAD, and set its price. Both are DEMIPAD Talos
    ;;     admin ops. `[true true]` is the fungibility pair Spark used.
      "STEP 1 -- (ouronet-ns.TS02-DPAD.A_RegisterAssetToLaunchpad patron <KPAY-ID> [true true])"
      "STEP 1 -- (ouronet-ns.TS02-DPAD.A_DefinePrice patron <KPAY-ID>
                    {\"pid\" : pid, \"starting-time\" : starting-time, \"id\" : <KPAY-ID>})"

    ;;[2]  THE ROW. Two lines, and the reason this file exists. `KPAY|INFO` is the constant
    ;;     "StoicPayV3" -- the key `UR_KpayID` reads. Nothing inside the module can do this.
      "STEP 2 -- (acquire-module-admin ouronet-ns.DEMIPAD-STOICPAY)"
      "STEP 2 -- (insert ouronet-ns.DEMIPAD-STOICPAY.KPAY|T|Properties \"StoicPayV3\"
                    {\"asset-id\" : <KPAY-ID>})"

    ;;[3]  OPEN FOR BUSINESS -- LAST, and only after [2] verifies. Spark's bring-up left this
    ;;     line commented (";;kept off") so the asset could be inspected before anyone could buy.
    ;;     Do the same: run [0]-[2], confirm `UR_KpayID` returns the id and `UR_KpayLeft` returns
    ;;     a positive number, and only then toggle.
      "STEP 3 -- (ouronet-ns.TS02-DPAD.A_ToggleRetrieval <KPAY-ID> true)"
      "STEP 3 -- (ouronet-ns.TS02-DPAD.A_ToggleOpenForBusiness <KPAY-ID> true)   ;; keep off until verified"
    ]
)

;; =========================================================================================
;; VERIFY, after [2] and before [3]. All four are free /local reads.
;;
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_KpayID)                    -> the KPAY id, not an error
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_GetPeriod)                 -> 1..25, NOT -1 and NOT 0
;;   (ouronet-ns.DEMIPAD-STOICPAY.UR_KpayLeft)                  -> > 0.0
;;   (ouronet-ns.DEMIPAD-STOICPAY.URC_KpayAmountCosts 1 0.0)     -> {"pid": ..., "wstoa": ...}
;;
;; `UR_GetPeriod` returning -1 means `starting-time` is in the future; 0 means it is more than
;; three years past. Either makes `UR_KpayLeft` 0.0 and the sale unbuyable while every name
;; resolves -- which is the failure mode worth checking for explicitly rather than assuming.
;;
;; THEN, in this order: `python3 REPL/tools/_registrylive.py --record` (a new module hash means
;; the registry snapshot is stale), and re-run `npm run check:chain` in OuronetUI -- three of its
;; accept-list entries exist only because this sale has no row.
;; =========================================================================================
