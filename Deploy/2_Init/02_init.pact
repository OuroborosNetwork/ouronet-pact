;; ---------------------------------------------------------------------------
;; OURONET INIT -- file 2
;; IMC POLICY DELTA for this round.
;;
;; Each line adds ONE registration that the current sources expect and the live chain
;; does not have. Derived, not written: `python3 REPL/tools/_impdiff.py --live SNAP`
;; computes it from every module's `P|A_Define` minus a snapshot of what is on chain.
;;
;; REPLAY IS SAFE, and this header used to say the opposite. It warned that `P|A_AddIMP`
;; is a blind append with no dedupe, so a replayed `P|A_Define` block was a permanent gas
;; tax on every billed operation. That was TRUE until 2026-09-21, when commit b6e87ef6
;; (`Close the IMC guard chain`) made the add idempotent across 59 modules. Censused
;; 2026-09-24: all 58 `P|A_AddIMP` implementations in the tree now branch on
;; `(contains policy-guard mp)` and leave an existing guard alone. So re-running a define
;; block costs gas once and changes nothing.
;;
;; PREFER THE DELTA ANYWAY. It is the minimum change, it is derived rather than written,
;; and it does not re-acquire admin capabilities you would otherwise not need to sign.
;; But if you are unsure whether a registration landed, RE-RUN IT -- that is now the
;; cheap option, and the old warning made it look like the expensive one.
;;
;; SIGNERS: each call needs the TARGET module's admin key --
;;   `P|A_AddIMP` opens with `(with-capability (GOV|<TARGET>_ADMIN) ...)`.
;;
;; 4 registration(s).
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; MTX-AQP -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.MTX-AQP.P|MTX-AQP|CALLER)))
;; TS02-C2 -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C2.P|TALOS-SUMMONER)))
;; TS02-C3 -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-DPAD -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-DPAD.P|TALOS-SUMMONER)))
