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
;; 35 registration(s).
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; TS02-C3 -> AQP-ANK
(ouronet-ns.AQP-ANK.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-C3 -> AQP-DSA
(ouronet-ns.AQP-DSA.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; AQP-DSA -> AQP-FVT
(ouronet-ns.AQP-FVT.P|A_AddIMP (create-capability-guard (ouronet-ns.AQP-DSA.P|DSA|CALLER)))
;; MTX-AQP -> AQP-FVT
(ouronet-ns.AQP-FVT.P|A_AddIMP (create-capability-guard (ouronet-ns.MTX-AQP.P|MTX-AQP|CALLER)))
;; TS02-C3 -> AQP-FVT
(ouronet-ns.AQP-FVT.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-C3 -> AQP-POOL
(ouronet-ns.AQP-POOL.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-C3 -> AQP-SCORE
(ouronet-ns.AQP-SCORE.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-C3 -> AQP-VCT
(ouronet-ns.AQP-VCT.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS01-A -> ATS
(ouronet-ns.ATS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS01-A.P|TS)))
;; TS01-A -> ATSU
(ouronet-ns.ATSU.P|A_AddIMP (create-capability-guard (ouronet-ns.TS01-A.P|TS)))
;; TS02-C3 -> ATSU
(ouronet-ns.ATSU.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-CPAD -> DEMIPAD-CUSTODIANS
(ouronet-ns.DEMIPAD-CUSTODIANS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
;; TS02-CPAD -> DEMIPAD-SNAKES
(ouronet-ns.DEMIPAD-SNAKES.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
;; TS02-CPAD -> DEMIPAD-SPARK
(ouronet-ns.DEMIPAD-SPARK.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
;; TS02-CPAD -> DEMIPAD-STOICPAY
(ouronet-ns.DEMIPAD-STOICPAY.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
;; TS02-DPAD -> DPDC
(ouronet-ns.DPDC.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-DPAD.P|TALOS-SUMMONER)))
;; ATS -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.ATS.P|ATS|CALLER)))
;; DPDC -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.DPDC.P|DPDC|CALLER)))
;; DPDC-I -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.DPDC-I.P|DPDC-I|CALLER)))
;; DPOF -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.DPOF.P|DPOF|CALLER)))
;; DPTF -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.DPTF.P|DPTF|CALLER)))
;; LIQUID -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.LIQUID.P|LQD|CALLER)))
;; MTX-SWP -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.MTX-SWP.P|MTX-SWP|CALLER)))
;; SWP -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.SWP.P|SWP|CALLER)))
;; SWPI -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.SWPI.P|SWPI|CALLER)))
;; SWPLC -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.SWPLC.P|SWPLC|CALLER)))
;; TS02-C1 -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C1.P|TALOS-SUMMONER)))
;; VST -> IGNIS
(ouronet-ns.IGNIS.P|A_AddIMP (create-capability-guard (ouronet-ns.VST.P|VST|CALLER)))
;; TS02-C3 -> MTX-AQP
(ouronet-ns.MTX-AQP.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; AQP-DSA -> RPS
(ouronet-ns.RPS.P|A_AddIMP (create-capability-guard (ouronet-ns.AQP-DSA.P|DSA|CALLER)))
;; MTX-AQP -> RPS
(ouronet-ns.RPS.P|A_AddIMP (create-capability-guard (ouronet-ns.MTX-AQP.P|MTX-AQP|CALLER)))
;; TS02-CPAD -> STOAICO
(ouronet-ns.STOAICO.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
;; MTX-SWP -> SWPI
(ouronet-ns.SWPI.P|A_AddIMP (create-capability-guard (ouronet-ns.MTX-SWP.P|MTX-SWP|CALLER)))
;; TS02-C3 -> TS01-A
(ouronet-ns.TS01-A.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
;; TS02-CPAD -> TS01-A
(ouronet-ns.TS01-A.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-CPAD.P|TALOS-SUMMONER)))
