;; ===========================================================================================
;; DASHBOARD DIAGNOSTIC -- dirty reads only. No gas, no signature, changes nothing.
;; ===========================================================================================
;; RUN EACH LAYER SEPARATELY, IN ORDER, AND STOP AT THE FIRST ONE THAT ERRORS.
;;
;; `URC_0001_HeaderV3` binds everything in one EAGER `let`, so a single failing dependency
;; aborts the whole object and the error names only the innermost form. That is why the layers
;; below exist: each one adds exactly one dependency to the previous, so the first failure tells
;; you which dependency -- not merely that something failed.
;;
;; L2 IS THE ONE TO WATCH, and the reason is that it is the only thing that CHANGED.
;;
;; L6 (the cross-module table scan) was the first suspect and has been ELIMINATED by evidence:
;; the PRE-SWEEP DPL-UR contained the identical `(length (keys DALOS.DALOS|AccountTable))` in
;; the same field, and the dashboard worked. So the live nodes do permit it in /local, and no
;; node flag needs changing. Kept below as a layer anyway -- an eliminated suspect that is cheap
;; to re-test is worth one line.
;;
;; What is left is the derivation that REPLACED the hardcoded pair ids. `UR_RewardToken` and
;; `UR_RewardBearingToken` read a REVERSE INDEX -- a table written when an ATS pair is created.
;; The mainnet pairs were created long ago. If that index was added later, or was never
;; backfilled for the primordial pairs, the reads return `[]`, `(at 0 [])` aborts, and HeaderV3
;; dies exactly where it used to succeed. The literals would have been working AROUND an empty
;; index rather than merely being lazy.
;;
;; WEAKENED, SAME DAY, BY EVIDENCE AGAINST IT -- recorded here rather than quietly dropped,
;; because an unmarked hypothesis is what a reader anchors on. Traced the writer: the reverse
;; index is populated by `DPTF::XE_UpdateRewardToken` / `XE_UpdateRewardBearingToken`, called
;; from `ATS::XI_FoldedIssue` -- the pair ISSUANCE path, not a later add-on -- and git says both
;; have existed since the initial import (2026-04-08), long before the mainnet pairs. So the
;; index is PROBABLY populated and L2 probably passes.
;;
;; Run it anyway. "Probably" is what the last three wrong diagnoses were made of, and L2 costs
;; one paste. But do not treat a passing L2 as the end -- go on through L3..L7, and if all of
;; them pass, the fault is in `URC_0002_Primordials` rather than the header. That path is NOT
;; layered here and is the obvious next thing to break down: it reaches `coin`, `ur-stoic`,
;; STOAICO and a hardcoded vault address, any of which could have moved.
;;
;; Whatever L2 says, the ids INTERFACE is still the right destination: it removes the dependency
;; on the reverse index entirely, which is a thing no read should need to care about.
;; ===========================================================================================


;; -------------------------------------------------------------------------------------------
;; L0 -- is the new module even there? Expect a list of 6 ids.
;;      If this errors, transaction 25 did not land.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.DPL-UR.URC_PrimordialIDs)


;; -------------------------------------------------------------------------------------------
;; L1 -- is this the V14 module or the old one? V14 has these; V7/V8 does not.
;;      `URC_StoaCollectionReceivers` was `URC_KadenaCollectionReceivers` before the sweep, so
;;      a "no such member" here means the OLD module is still live and tx25 did not take.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.DPL-UR.URC_StoaCollectionReceivers)


;; -------------------------------------------------------------------------------------------
;; L2 -- THE DERIVATION I INTRODUCED, and the only thing that changed. READ THE RESULT
;;      CAREFULLY -- the failure here is quiet, not loud.
;;
;;      EXPECTED : a one-element list holding a real pair id, e.g. ["Auryndex-O136CBn22ncY"].
;;
;;      ["|"]    : THE UNSET VALUE. DPTF's own code tests for exactly this
;;                 (05_DPTF.pact:1440 -- `(if (= (UR_RewardToken reward-token) [BAR]) ...)`),
;;                 so an unpopulated reverse index returns a BAR rather than an empty list.
;;                 That does NOT abort. `(at 0 ["|"])` cheerfully yields "|", which then flows
;;                 into `ATS::URC_Index "|"` and fails there -- several frames from the cause,
;;                 with a message that names the index lookup and not the empty index. This is
;;                 the single most likely reason the dashboard is still down.
;;
;;      an ERROR : the TOKEN ROW itself is missing. These readers use a bare `read` with no
;;                 default, so a non-existent id throws rather than returning BAR.
;;
;;      >1 elem  : a finding in its own right -- `at 0` is then picking arbitrarily, and the
;;                 RBT direction was chosen precisely because an RBT belongs to one pool.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_AurynID))        ;; -> Auryndex
(ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_EliteAurynID))   ;; -> EliteAuryndex
(ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_SilverStoaID))   ;; -> SilverStoaPillar
(ouronet-ns.DPTF.UR_RewardToken        (ouronet-ns.DALOS.UR_SilverStoaID))   ;; -> GoldenStoaPillar


;; -------------------------------------------------------------------------------------------
;; L3 -- the GoldenStoa chain, which is the longest derivation and the most likely to break.
;;      Expect: a pair id, then the GSTOA token id, then the hibernated GSTOA id.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.ATS.UR_ColdRewardBearingToken
    (at 0 (ouronet-ns.DPTF.UR_RewardToken (ouronet-ns.DALOS.UR_SilverStoaID))))

(ouronet-ns.DPTF.UR_Hibernation
    (ouronet-ns.ATS.UR_ColdRewardBearingToken
        (at 0 (ouronet-ns.DPTF.UR_RewardToken (ouronet-ns.DALOS.UR_SilverStoaID)))))

;; CROSS-CHECK against what DALOS itself thinks GSTOA is. These SHOULD agree. If DALOS returns
;; BAR ("|") the pool route is the only one that works -- which is exactly why HeaderV3 uses it.
(ouronet-ns.DALOS.UR_GoldenStoaID)


;; -------------------------------------------------------------------------------------------
;; L4 -- the index reads. Expect four decimals. -1.0 means an unfuelled pool, not an error.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.ATS.URC_Index (at 0 (ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_AurynID))))
(ouronet-ns.ATS.URC_Index (at 0 (ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_EliteAurynID))))
(ouronet-ns.ATS.URC_Index (at 0 (ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_SilverStoaID))))
(ouronet-ns.ATS.URC_Index (at 0 (ouronet-ns.DPTF.UR_RewardToken        (ouronet-ns.DALOS.UR_SilverStoaID))))


;; -------------------------------------------------------------------------------------------
;; L5 -- the price leg. Needs live SWP pools.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.SWPI.URC_OuroPrimordialPrice)
(ouronet-ns.U|CT.UR_STOA-PID|Price)


;; -------------------------------------------------------------------------------------------
;; L6 -- THE CROSS-MODULE TABLE SCAN, and the one failure here that is NOT a defect.
;;
;;      HeaderV3's `z3-v1` field is `(length (keys DALOS.DALOS|AccountTable))` -- a scan of
;;      ANOTHER module's table. Pact admin-gates that in TRANSACTIONAL mode. A chainweb node
;;      started WITH `--allowReadsInLocal` permits it in a `/local` query; a node started
;;      WITHOUT it does not.
;;
;;      So if every layer above passes and this one returns
;;          "Module admin necessary for operation but has not been acquired"
;;      then the contract is fine and the NODE is the problem: node2.stoachain.com is not
;;      running --allowReadsInLocal. That is a node-flag fix, not a Pact fix.
;;
;;      This has never been verified against the live nodes -- it was inferred from the flag's
;;      existence. Verify it here rather than assuming it, because the whole dashboard header
;;      depends on it and four other readers do too (URC_0016, URC_0018, URC_0021, URC_0035).
;; -------------------------------------------------------------------------------------------
(length (keys ouronet-ns.DALOS.DALOS|AccountTable))


;; -------------------------------------------------------------------------------------------
;; L7 -- the whole thing. Replace the account string with a real one.
;; -------------------------------------------------------------------------------------------
(ouronet-ns.DPL-UR.URC_0001_HeaderV3 "<<<FILL: any live Ѻ. account>>>")

;; And the dashboard's other call, which does NOT scan any table -- so if L7 fails on L6's
;; gate but this one works, the node flag is confirmed as the sole cause.
(ouronet-ns.DPL-UR.URC_0002_Primordials "<<<FILL: same account>>>" [])
