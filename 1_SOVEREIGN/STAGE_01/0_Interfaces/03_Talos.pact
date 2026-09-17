;; Stage 01 Talos Interface Registry — EMPTY BY DESIGN. Nothing is declared in this file.
;;
;; Every Talos client interface is co-located with its module in 3_Talos/*.pact and deploys with
;; it. Live as of 2026-09-17: ClientOneV2 (02_TS01-C1), ClientTwoV2 (03_TS01-C2), ClientThreeV4
;; (04_TS01-C3), ClientPactsV4 (05_TS01-P), ClientFourV8 (06_TS01-C4), AdminV2 (01_TS01-A).
;;
;; THE FROZEN-PREDECESSOR CONVENTION IS RETIRED. This file used to hold historical ClientFour
;; V1–V5 + V6BlockTime, and audit fix #25 (SWP finding M14 / #39M) added frozen ClientThreeV2 /
;; ClientPactsV2 to the two module files. All of it was deleted by commit 6833a21 (2026-09-02)
;; under StoicSyntax-Prefixes.md §7.10 — "Retire the pool: delete the 0_Interfaces/ files; git
;; history preserves old versions." That is the current canon; the deletion was policy, not an
;; accident, and M14 is closed as SUPERSEDED rather than reopened. See DEFECT-LEDGER §8.6.
;;
;; Do not re-add frozen copies here. Under the cascade rule they cannot be both loadable and
;; historical: a verbatim V2 references interface versions that no longer exist and fails to load,
;; while rewriting its type refs to today's versions fabricates a "V2" that never existed. The
;; archive that lived here for ten days was silently rewritten by three canon sweeps and ended up
;; documenting a surface that never shipped. Git is the provenance store.
