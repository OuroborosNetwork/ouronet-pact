;; ---------------------------------------------------------------------------
;; PureV10 -- transaction 23 (MANUAL, not generated)
;; Label : STOAICO repair -- one-time admin migration
;;
;; RUN THIS AFTER transaction 21 (STOAICO's own redeploy). `A_MigrateGeneralFields`
;; does not exist on chain to call until tx21 has landed -- it is a NEW function
;; this round adds, not something already live.
;;
;; WHAT THIS FIXES. STOAICO's live `STOAICO|T|General` row predates the
;; `distribution-round` / `zombie-rewards` fields its own already-deployed code
;; has required since an earlier upgrade -- confirmed directly against the chain
;; (`describe-module` + a live `UR_Global0` read showing only the original 10
;; fields), not assumed. Every path that touches a distribution-round (A_Stake,
;; A_Unstake, A_Inject, collect, the dust-sweep) has been aborting with
;; "Key distribution-round not found in object" since that earlier upgrade
;; landed -- this is exactly what a real wallet simulation of this round hit on
;; 2026-10-12. Full diagnosis in Deploy/PureV10/README.md; the fix itself is
;; `A_MigrateGeneralFields` / `GOV|MIGRATE-GENERAL-FIELDS` in
;; `2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact`.
;;
;; GOVERNANCE: admin-gated (`GOV|STOAICO_ADMIN`, composed via `GOV|MIGRATE-
;; GENERAL-FIELDS`). Safe to re-send: the capability itself refuses a SECOND
;; call outright ("distribution-round already present -- migration already
;; applied, refusing a second run") rather than silently resetting real
;; escrowed state back to zero. Verified live, both directions, against the
;; real node before this file was written -- not merely asserted here.
;;
;; THIS FILE IS NOT GENERATED. `_purev10.py` extracts module/interface deploys
;; from the scoped planner; a bare admin function call has no module source to
;; extract, so it is hand-authored -- same reasoning as
;; `Deploy/2_Init/00_MANUAL_rotate-s2-governor.pact`. `_purev10.py` only manages
;; files matching `NN_deploy.pact`; this one does not match that pattern, so it
;; is invisible to its orphan/stale detection by construction, not by exception.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(ouronet-ns.STOAICO.A_MigrateGeneralFields)
