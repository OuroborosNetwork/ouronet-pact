;; Deploy: load THIS file — interface + module ship together (model: 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact).
;; Holds ALL AQP multi-transaction (defpact) functions. M3 #12 (deb-staleness): the spike-fallback inject.
;;
(interface AqpMtxV1
    @doc "Exposes AQP MultiStep (defpact) client functions. Currently: the tiered enforced-fresh FVT inject \
        \ (MTX|n|C_Inject) — the spike fallback for CC_Inject when the stale set exceeds one transaction."
    ;;
    (defun C_2|Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal))
    (defun C_2|SweepRevokeAnchor (patron:string anchor-id:string))
    ;;
)
;;
(module MTX-AQP GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AqpMtxV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_MTX-AQP        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|MTX-AQP_ADMIN)))
    (defcap GOV|MTX-AQP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_MTX-AQP)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "MTX-AQP Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|MTX-AQP|CALLER ()
        true
    )
    (defcap P|MTX-AQP|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|MTX-AQP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|MTX-AQP|REMOTE-GOV))
        (compose-capability (P|MTX-AQP|CALLER))
    )
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|MTX-AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|MTX-AQP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV1} AQP-FVT)
                (mg:guard (create-capability-guard (P|MTX-AQP|CALLER)))
            )
            ;; MTX-AQP calls AQP-FVT's XE_ building blocks (UEV_IMC) — register as an allowed IMC caller.
            ;; (The re-score sweep's ANK/POOL calls live in AQP-FVT::CC_SweepRevokeAnchor, which is already in
            ;;  ANK's + POOL's IMP — so MTX-AQP itself does not call ANK/POOL directly.)
            (ref-P|FVT::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    ;; Per-step fix capacity (deb-staleness sweep). CALIBRATION-GATED: size N against the measured gas of one
    ;; (settle+refresh+mirror-resync) fix + the O(present-users) scan that shares the step, staying under ~2M.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration). Start conservative.
    (defconst N_FIX:integer 400)
    ;; Per-step recompute capacity (re-score SWEEP). CALIBRATION-GATED — size N_SWEEP against the measured gas of one
    ;; holder recompute (settle → aggregate/lane refold → deb + mirror) plus the O(present) window scan it shares,
    ;; staying under ~2M. The sweep unit is HEAVIER than the inject fix (deeper refold), so N_SWEEP < N_FIX.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration).
    (defconst N_SWEEP:integer 300)
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    (defcap MTX-AQP|C>INJECT (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Protects the MTX|n|C_Inject multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is ACTIVE \
            \ while the steps call AQP-FVT's XE_ building blocks (FVT's UEV_IMC checks MTX-AQP's registered caller \
            \ guard — see P|A_Define). Acquired fresh per step (steps are separate txs; the pact-id gates continuation)."
        @event
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap MTX-AQP|C>SWEEP-REVOKE (patron:string anchor-id:string)
        @doc "Protects the MTX|n|C_SweepRevokeAnchor multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is \
            \ ACTIVE while the steps call AQP-FVT's XE_ bracket (freeze/revoke/unfreeze) + recompute-chunk building \
            \ blocks (FVT's UEV_IMC checks MTX-AQP's registered caller guard — see P|A_Define). Acquired fresh per \
            \ step (steps are separate txs; the pact-id gates continuation). The anchor owner (= anchored-asset \
            \ owner) is enforced downstream inside ANK|XE>SWEEP-REVOKE."
        @event
        (compose-capability (P|SECURE-CALLER))
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [URC] sweep recompute-set sizing (read-only; the freeze keeps it fixed across steps)
    (defun URC_SweepTotalPresent:integer (score-ids:[string])
        @doc "Total present holders across every FVT member employing the swept boost-class — the paginated \
            \ recompute-set size. Read-only; sweep-in-progress keeps it fixed across defpact steps."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
            )
            (fold (+) 0
                (map
                    (lambda (sid:string) (length (ref-FVT::URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids))
        )
    )
    ;;{F1}  [X] paginated window recompute — advances by GLOBAL offset over the fixed flattened present set
    (defun XI_SweepRecomputeWindow:integer
        (score-ids:[string] boost-class-id:string win-lo:integer win-hi:integer)
        @doc "Recompute holders whose GLOBAL flattened index — present users concatenated across score-ids in order \
            \ — falls in [win-lo, win-hi). Per score, slice its present users to the window overlap and forward one \
            \ AQP-FVT::XE_FvtSweepRecomputeChunk. The sweep freeze makes URH_FvtPresentUsers order deterministic \
            \ across steps, so (drop offset) advances the window without re-processing (contrast the inject's \
            \ shrinking (take N) set). Returns the number of holders recomputed. Runs under MTX-AQP|C>SWEEP-REVOKE."
        (at "processed"
            (fold
                (lambda (acc:object sid:string)
                    (let
                        (
                            (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                            (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                            (seen-before:integer (at "seen" acc))
                            (fvt:string (ref-SCR::UR_SCR|ScoreFvtLink sid))
                            (member:string
                                (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid))
                        )
                        (let
                            (
                                (users:[string] (ref-FVT::URH_FvtPresentUsers fvt))
                            )
                            (let
                                (
                                    (seen-after:integer (+ seen-before (length users)))
                                    (lo:integer (if (> win-lo seen-before) win-lo seen-before))
                                )
                                (let
                                    (
                                        (hi:integer (if (< win-hi seen-after) win-hi seen-after))
                                    )
                                    (if (> hi lo)
                                        (let
                                            (
                                                (slice:[string] (take (- hi lo) (drop (- lo seen-before) users)))
                                            )
                                            (ref-FVT::XE_FvtSweepRecomputeChunk fvt member boost-class-id slice)
                                            {"seen": seen-after, "processed": (+ (at "processed" acc) (length slice))})
                                        {"seen": seen-after, "processed": (at "processed" acc)}))))))
                {"seen": 0, "processed": 0}
                score-ids))
    )
    ;;{F2}  [C] client wrappers — acquire the flow cap, then run the defpact
    (defun C_2|Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "2-step enforced-fresh inject (spike fallback for AQP-FVT::CC_Inject; handles up to 2×N_FIX stale \
            \ stakers). Acquires MTX-AQP|C>INJECT, then runs the MTX|2|C_Inject defpact. Advance with \
            \ (continue-pact 1). Vault/treasury only (the defpact's inject is class≠0)."
        (UEV_IMC)
        (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
            (MTX|2|C_Inject patron fvt-id reward-dptf-id amount)
        )
    )
    (defun C_2|SweepRevokeAnchor (patron:string anchor-id:string)
        @doc "2-step paginated re-score SWEEP that retires an employed anchor (Phase 3 closeout; spike fallback for \
            \ AQP-FVT::CC_SweepRevokeAnchor when the recompute set exceeds one tx). Acquires MTX-AQP|C>SWEEP-REVOKE, \
            \ then runs the MTX|2|C_SweepRevokeAnchor defpact. Step 0 brackets (freeze + swept-revoke) + recomputes \
            \ the first window; advance with (continue-pact 1). Owner enforced downstream in ANK|XE>SWEEP-REVOKE."
        (UEV_IMC)
        (with-capability (MTX-AQP|C>SWEEP-REVOKE patron anchor-id)
            (MTX|2|C_SweepRevokeAnchor patron anchor-id)
        )
    )
    ;;{F3}  [MTX|C] client defpacts
    (defpact MTX|2|C_Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Enforced-fresh vault/treasury inject as a 2-step defpact: each step's opening stale scan IS the \
            \ pre-inject freshness proof — atomically fixing a whole scanned set of size <= N_FIX leaves zero \
            \ stale, so no re-scan is needed. Step 0 injects terminally when the stale set fits, else fixes \
            \ N_FIX and continues to step 1. Handles up to 2xN_FIX stale stakers; larger spikes need a higher-n variant."
        ;; Enforced-fresh vault/treasury inject over 2 steps (owner design §2.8). Each step's opening scan IS the
        ;; pre-inject freshness proof: fixing an entire scanned set of size ≤ N_FIX atomically leaves ZERO stale, so
        ;; no separate re-scan is needed. Handles up to 2×N_FIX; larger spikes → a higher-n variant (add when needed).
        ;;
        ;;Step 0 — scan; if the whole stale set fits (≤ N_FIX) fix it all + inject (terminal), else fix N_FIX + continue.
        (step
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (require-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount))
              (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (stale:[string] (ref-FVT::URH_FvtStalePresentUsers fvt-id))
                )
                (if (<= (length stale) N_FIX)
                    (let ((n:integer (length stale)))
                        (ref-FVT::XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                        (ref-IGNIS::C_Collect patron (ref-FVT::XB_FvtInject patron fvt-id reward-dptf-id amount))
                        (yield {"injected" : true})
                        (format "MTX Inject 1|2: fixed {} stale staker(s) and INJECTED {} {} (terminal)." [n amount reward-dptf-id])
                    )
                    (let ((remaining:integer (- (length stale) N_FIX)))
                        (ref-FVT::XE_FvtFixUserChunk fvt-id reward-dptf-id (take N_FIX stale))
                        (yield {"injected" : false})
                        (format "MTX Inject 1|2: fixed {} of {} stale — {} remain, continue to step 2." [N_FIX (length stale) remaining])
                    )
                )
              )
            )
        )
        ;;Step 1 — if step 0 already injected, no-op; else fix the (now ≤ N_FIX) remainder and inject.
        (step
            (resume
                {"injected" := injected}
                (if injected
                    "MTX Inject 2|2: already injected in step 1 — no-op."
                    (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
                        (let
                            (
                                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                                (stale:[string] (ref-FVT::URH_FvtStalePresentUsers fvt-id))
                            )
                            (ref-FVT::XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                            (ref-IGNIS::C_Collect patron (ref-FVT::XB_FvtInject patron fvt-id reward-dptf-id amount))
                            (format "MTX Inject 2|2: fixed {} remaining stale staker(s) and INJECTED {} {}." [(length stale) amount reward-dptf-id])
                        )
                    )
                )
            )
        )
    )
    (defpact MTX|2|C_SweepRevokeAnchor (patron:string anchor-id:string)
        @doc "Paginated re-score sweep + anchor revoke as a 2-step defpact (Phase 3 closeout): step 0 brackets \
            \ the sweep (freezes every affected pool + swept-revokes the anchor) then recomputes the first window \
            \ of present holders; sweep-in-progress holds across steps (separate txs) so the flattened holder \
            \ window pages deterministically. Terminal in step 0 when the whole holder set fits (<= N_SWEEP); \
            \ handles up to 2xN_SWEEP holders, larger spikes need a higher-n variant."
        ;; Paginated re-score SWEEP over 2 steps (Phase 3 closeout). Step 0 brackets the sweep (freeze every affected
        ;; pool + swept-revoke the anchor) then recomputes the first window of present holders; if the whole set fits
        ;; (≤ N_SWEEP) it unfreezes + terminates, else it yields the cursor. sweep-in-progress holds ACROSS steps
        ;; (separate txs), keeping the recompute set FIXED (stake + collect blocked) so the flattened [offset, …)
        ;; window pages deterministically. Handles up to 2×N_SWEEP holders; larger spikes → a higher-n variant.
        ;;
        ;;Step 0 — bracket (freeze + swept-revoke) + recompute window [0, N_SWEEP); terminal if the whole set fits.
        (step
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (require-capability (MTX-AQP|C>SWEEP-REVOKE patron anchor-id))
                (let
                    (
                        (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                    )
                    (let
                        (
                            (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                        )
                        (ref-FVT::XE_SweepBegin anchor-id)
                        (let
                            (
                                (total:integer (URC_SweepTotalPresent score-ids))
                            )
                            (if (<= total N_SWEEP)
                                (let
                                    (
                                        (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id 0 total))
                                    )
                                    (ref-FVT::XE_SweepEnd anchor-id)
                                    (yield {"done": true, "boost-class-id": boost-class-id, "score-ids": score-ids, "offset": 0})
                                    (format "MTX Sweep 1|2: swept-revoked anchor {} and recomputed {} holder(s) across {} score(s) (terminal)." [anchor-id n (length score-ids)]))
                                (let
                                    (
                                        (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id 0 N_SWEEP))
                                    )
                                    (yield {"done": false, "boost-class-id": boost-class-id, "score-ids": score-ids, "offset": N_SWEEP})
                                    (format "MTX Sweep 1|2: swept-revoked anchor {}; recomputed {} of {} holder(s) — {} remain, continue to step 2." [anchor-id n total (- total N_SWEEP)]))))))
            )
        )
        ;;Step 1 — if step 0 already finished, no-op; else recompute the remainder [offset, total) then unfreeze.
        (step
            (resume
                {"done" := done, "boost-class-id" := boost-class-id, "score-ids" := score-ids, "offset" := offset}
                (if done
                    "MTX Sweep 2|2: already completed in step 1 — no-op."
                    (with-capability (MTX-AQP|C>SWEEP-REVOKE patron anchor-id)
                        (let
                            (
                                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                                (total:integer (URC_SweepTotalPresent score-ids))
                            )
                            (let
                                (
                                    (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id offset total))
                                )
                                (ref-FVT::XE_SweepEnd anchor-id)
                                (format "MTX Sweep 2|2: recomputed {} remaining holder(s) — anchor {} retired." [n anchor-id])))))))
    )
    ;;
)
(create-table P|T)
(create-table P|MT)
