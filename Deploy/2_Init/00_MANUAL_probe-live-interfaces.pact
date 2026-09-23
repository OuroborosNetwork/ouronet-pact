;; ---------------------------------------------------------------------------
;; OURONET — WHICH INTERFACES ARE ALREADY ON CHAIN?
;;
;; A DIRTY READ. Costs no gas, needs no signature, changes nothing. Paste into any
;; Pact tool pointed at StoaChain and keep the output.
;;
;; Each name is wrapped in `try`, so one that does NOT exist reports ABSENT instead
;; of aborting the read -- absence is the answer being sought.
;;
;; PRESENT  => the interface is deployed. If its content CHANGED it must be version
;;             bumped; if unchanged it must be SKIPPED from the deploy bundle.
;; ABSENT   => it deploys as-is, nothing to do.
;; ---------------------------------------------------------------------------
(namespace "ouronet-ns")
[
  ;; --- transaction 22 ---
  (try "ABSENT  SparksV2"                (let ((x (describe-module "ouronet-ns.SparksV2"))) "PRESENT SparksV2"))
  (try "ABSENT  SaleSnakesV2"            (let ((x (describe-module "ouronet-ns.SaleSnakesV2"))) "PRESENT SaleSnakesV2"))
  (try "ABSENT  SaleCustodiansV2"        (let ((x (describe-module "ouronet-ns.SaleCustodiansV2"))) "PRESENT SaleCustodiansV2"))
  (try "ABSENT  StoicPayV3"              (let ((x (describe-module "ouronet-ns.StoicPayV3"))) "PRESENT StoicPayV3"))
  (try "ABSENT  CitizenLaunchpadTalosV1" (let ((x (describe-module "ouronet-ns.CitizenLaunchpadTalosV1"))) "PRESENT CitizenLaunchpadTalosV1"))
  (try "ABSENT  InfoTwoV2"               (let ((x (describe-module "ouronet-ns.InfoTwoV2"))) "PRESENT InfoTwoV2"))
  ;; --- transaction 23 ---
  (try "ABSENT  AcquisitionPoolBootV1"   (let ((x (describe-module "ouronet-ns.AcquisitionPoolBootV1"))) "PRESENT AcquisitionPoolBootV1"))
  ;; --- transaction 24 (already bumped, expected ABSENT) ---
  (try "ABSENT  DispenserV2"             (let ((x (describe-module "ouronet-ns.DispenserV2"))) "PRESENT DispenserV2"))
]
