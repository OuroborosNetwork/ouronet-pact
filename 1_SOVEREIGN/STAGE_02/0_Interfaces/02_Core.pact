;; Stage 02 Core Interface Registry — EMPTY BY DESIGN. Nothing is declared in this file.
;; The header used to say "SHARED schemas only" and to instruct that DpdcUdcV2 types be KEPT
;; here; it declares zero interfaces, and DpdcUdcV2 is co-located with its module. Corrected
;; 2026-09-17 — see DEFECT-LEDGER §8.6 for why a stale registry header is worse than an absent
;; one: it reads exactly like a correctly-populated registry, so nobody re-opens it.
;; Module-owned interfaces live in 2_Core/**/*.pact and deploy with their module (§7.10).
;;