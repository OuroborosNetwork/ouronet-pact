;; ---------------------------------------------------------------------------
;; OURONET INIT -- file 2
;; IMC POLICY DELTA for this round.
;;
;; Each line adds ONE registration that the current sources expect and the live chain
;; does not have. Derived, not written: `python3 REPL/tools/_impdiff.py --live SNAP`
;; computes it from every module's `P|A_Define` minus a snapshot of what is on chain.
;;
;; DO NOT substitute `P|A_Define` calls for this file. `P|A_AddIMP` is a blind append
;; with no dedupe, and `P|UEV_IMC` scans the whole list on every IMC-gated call -- so a
;; replayed define block is a permanent gas tax on every billed operation, invisible
;; afterwards. Add the delta; never replay the definition.
;;
;; SIGNERS: each call needs the TARGET module's admin key --
;;   `P|A_AddIMP` opens with `(with-capability (GOV|<TARGET>_ADMIN) ...)`.
;;
;; 4 registration(s).
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; MTX-AQP -> IGNIS
(IGNIS.P|A_AddIMP (create-capability-guard (MTX-AQP.P|MTX-AQP|CALLER)))
;; TS02-C2 -> IGNIS
(IGNIS.P|A_AddIMP (create-capability-guard (TS02-C2.P|TALOS-SUMMONER)))
;; TS02-C3 -> IGNIS
(IGNIS.P|A_AddIMP (create-capability-guard (TS02-C3.P|TALOS-SUMMONER)))
;; TS02-DPAD -> IGNIS
(IGNIS.P|A_AddIMP (create-capability-guard (TS02-DPAD.P|TALOS-SUMMONER)))
