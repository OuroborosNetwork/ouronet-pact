;; Stage 01 Talos Interface Registry — HISTORICAL ClientFour versions only.
;; Latest Talos client interfaces live in each 3_Talos/*.pact file (deploy with module).
;; ClientFourV1–V5 + V6BlockTime historical below; ClientFourV6 shipped only in 06_TS01-C4
;; (not frozen here — A_Flush typed to module-owned PythiaLedgerV3). Latest: ClientFourV7 in 06_TS01-C4.
;; #39M/M14 fix: ClientThreeV2/ClientPactsV2 (frozen, pre-V3) live in 04_TS01-C3.pact /
;; 05_TS01-P.pact instead of here — same module-owned-type-dependency reason as ClientFourV6
;; above (V2's Smart Swap functions type against SwapperUsageV3.Slippage, not resolvable at
;; this registry's early Interfaces-load point). Latest: ClientThreeV3/ClientPactsV3, same files.
;;