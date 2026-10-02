;; ===========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 24
;; AQP INTER-MODULE PERMISSIONS + the missing STOA oracle price.  *** RUN BEFORE ANY AQP STEP. ***
;; ===========================================================================================
;; NOT A MODULE DEPLOY. Four admin calls, no module body -- `REPL/tools/_purev2.py` lists it as
;; HANDWRITTEN for that reason.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT IS BROKEN
;; ------------------------------------------------------------------------------------------
;; Every Stage-2 AQP call fails with
;;
;;     "None of the guards passed"  @ ouronet-ns.U|G.UEV_Any
;;
;; which reads like a signature problem and is not one. `P|UEV_IMC` is `U|G::UEV_Any` over the
;; module's registered inter-module callers, and on mainnet:
;;
;;     (ouronet-ns.AQP-ANK.P|UR_IMP)  ->  [ouronet-ns.AQP-ANK.SECURE]
;;
;; one entry, its own seed. `TS02-C3.P|A_Define` -- which registers the Stage-2 Talos summoner
;; into the nine modules it drives -- was never executed. Measured across the family, with
;; TS02-C1 / TS02-C2 / TS02-DPAD shown for contrast because theirs DID run:
;;
;;     AQP-ANK    1 guard    TS02-C3: absent        DPDC-S   TS02-C1, TS02-C2: present
;;     AQP-SCORE  4 guards   TS02-C3: absent        DPDC     TS02-C1, TS02-C2: present
;;     AQP-POOL   4 guards   TS02-C3: absent        DEMIPAD  TS02-DPAD:        present
;;     AQP-FVT    2 guards   TS02-C3: absent
;;     AQP-VCT    1 guard    TS02-C3: absent
;;     MTX-AQP    1 guard    TS02-C3: absent
;;     AQP-DSA    1 guard    TS02-C3: absent
;;     ATSU       8 guards   TS02-C3: absent
;;     TS01-A     9 guards   TS02-C3: absent
;;
;; So the gap is exactly TS02-C3, and it closes the WHOLE AQP surface -- anchors, scores, pools,
;; FVT entities, delegation and the MTX defpacts. Not one step.
;;
;; THE SECOND GAP, found by running the first fix and watching what failed next:
;;
;;     "No value found in table ouronet-ns.DALOS_DALOS|PricesTable for key: stoa|price"
;;
;; `IGNIS::UC_StoaPrice` divides by that key, and a failed table read is NOT catchable -- it
;; takes the whole transaction, it does not degrade. The rest of the table is populated
;; (`dptf` 20, `dpnf` 50, `standard` 1, `smart` 2), so this one key was simply never written.
;;
;; ------------------------------------------------------------------------------------------
;; WHY ALL THREE P|A_Define CALLS AND NOT JUST C3
;; ------------------------------------------------------------------------------------------
;; `P|A_AddIMP` is IDEMPOTENT -- its @doc: "a guard already in the chain is left alone rather
;; than appended a second time". C1's and C2's registrations are already present, so those two
;; calls are no-ops that cost gas and nothing else. They are included because the measurement
;; above is a snapshot: if any target of C1 or C2 is ever missed the same way C3 was, this file
;; repairs it without needing to be rewritten, and re-running it is always safe.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT THE PRICE MEANS BEFORE YOU SIGN IT
;; ------------------------------------------------------------------------------------------
;; 0.1 is the hard peg the REPL seeds -- "STOA oracle price in USD. HARD-PEGGED at $0.10 until a
;; real price feed exists" ([4.0]_Sovereign-Executor). Every STOA charge derived through
;; `UC_StoaPrice` is a DOLLAR price divided by this, so the figure below sets real costs.
;; Measured against the live chain with the peg applied:
;;
;;     AQP-ANK.URCi_IssueAnchorStoa true   ->  100 STOA   (anchor + new boost class)
;;     AQP-ANK.URCi_IssueAnchorStoa false  ->   50 STOA   (anchor into an existing class)
;;     IGNIS.UC_StoaPrice "issue-nft"      ->  250 STOA
;;
;; So Step 2 alone (three anchors with acnoi=true, one with acnoi=false) costs 350 STOA = $35.
;; The pre-existing hand-set keys (dptf 20, dpnf 50, ...) are stored values read directly and
;; are NOT affected by this write.
;;
;; ------------------------------------------------------------------------------------------
;; SIGNING
;; ------------------------------------------------------------------------------------------
;;   `P|A_AddIMP` is gated on each target's `GOV|*_ADMIN`, and `DALOS|A_UpdateUsagePrice` on the
;;   DALOS admin -- all of which resolve to `ouronet-ns.dh_master-keyset`:
;;
;;       pred keys-any, keys
;;         10b998049806491ec3e26f7507020554441e6b9271cfee1779d85230139c92df
;;         1a4e15d3c51e0b73e92644600487ba8eaae312e1a178b91801d54e13c1b350a5
;;
;;   keys-any, so EITHER key alone satisfies every call here.
;;
;;   NOT GAS-STATION PAYABLE. `DALOS::GAS_PAYER` whitelists single-form coin.C_ /
;;   ouronet-ns.TS / DSP / STOAICO, two coin.C_ forms, or namespace+transmute+let. This file is
;;   `(namespace …)` plus four calls and matches none of them -- pay from a funded account.
;;
;; ------------------------------------------------------------------------------------------
;; VERIFICATION -- simulated against mainnet /local before being written
;; ------------------------------------------------------------------------------------------
;;   the three defines alone                 -> success, "Write succeeded"
;;   defines + price + AQP-BOOT Step 2       -> success,
;;     "AQP-BOOT Step 2 done. kbn-id=SBN-SUVEHxb9UQ6_. anchors issued=[OuroborosRain-…
;;      AurynRain-… EliteAurynRain-… LegendarySnakeTokenRain-…]"
;;   Step 2 WITHOUT this file                -> "None of the guards passed" @ U|G.UEV_Any
;;
;; AFTER RUNNING, confirm as a /local read (no signature):
;;   (ouronet-ns.AQP-ANK.P|UR_IMP)            must now contain TS02-C3.P|TALOS-SUMMONER
;;   (ouronet-ns.DALOS.UR_UsagePrice "stoa|price")   must return 0.1
;; ===========================================================================================

(namespace "ouronet-ns")

;; Registers each Talos summoner as a trusted inter-module caller of the modules it drives.
;; C1 and C2 are already registered and no-op; C3 is the one that is missing.
(TS02-C1.P|A_Define)
(TS02-C2.P|A_Define)
(TS02-C3.P|A_Define)

;; The STOA oracle price, in USD. Replace the account below with the signing Ouronet account.
(TS01-A.DALOS|A_UpdateUsagePrice
    "OURONET_ADMIN_ACCOUNT"
    "stoa|price"
    0.1
)
