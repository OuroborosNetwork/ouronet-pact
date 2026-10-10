;; -------------------------------------------------------------------------
;; TX 04/09 -- MTX-AQP, AQP-DSA
;;
;; DOT-PIN CASCADE ONLY -- both dot-call RPS.
;;
;; SEND IN ORDER. This round is SEQUENTIAL: every module here either changed or dot-calls one
;; that did, and a dot-caller compiled against a superseded table-owning callee aborts on its
;; next table access rather than failing at deploy. Parallel submission orders nothing.
;;
;; SIGNERS: this module's governance keyset.
;; -------------------------------------------------------------------------

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev7.py

(namespace "ouronet-ns")

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact (module only -- its interface is already live)
(module MTX-AQP GOV
    @doc "Holds all AQP multi-transaction (defpact) flows. Provides C_2|Inject — a 2-step \
        \ enforced-fresh vault/treasury reward inject that is the spike fallback for \
        \ AQP-FVT::CC_Inject when the deb-stale staker set exceeds one tx — and \
        \ C_2|SweepRevokeAnchor — a 2-step paginated re-score sweep that retires an employed \
        \ anchor. Each step atomically fixes/recomputes a bounded window of holders via \
        \ AQP-FVT XE_ building blocks under its own policy caller guard."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AqpMtxV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_MTX-AQP                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|MTX-AQP_ADMIN)))
    (defcap GOV|MTX-AQP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
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
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|MTX-AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|MTX-AQP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|MTX-AQP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|MTX-AQP_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|MTX-AQP|CALLER)))
            )
            ;; MTX-AQP calls AQP-FVT's XE_ building blocks (P|UEV_IMC) — register as an allowed IMC caller.
            ;; (The re-score sweep's ANK/POOL calls live in AQP-FVT::CC_SweepRevokeAnchor, which is already in
            ;;  ANK's + POOL's IMP — so MTX-AQP itself does not call ANK/POOL directly.)
            (ref-P|FVT::P|A_AddIMP mg)
            ;; #75 B': the deb-fix + re-score defpacts now drive RPS::XE_FvtFixUserChunk /
            ;; XE_FvtSweepRecomputeChunk (moved to the RPS reward engine) — register on RPS IMP too.
            (ref-P|RPS::P|A_AddIMP mg)
            ;;IGNIS RESTRUCTURE 2026-09-20: the collectors became protected X_ functions
            ;;behind `P|UEV_IMC`, so every module that bills must be a registered IMP peer
            ;;of IGNIS or the fee call dies with "None of the guards passed".
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;; Per-step fix capacity (deb-staleness sweep). CALIBRATION-GATED: size N against the measured gas of one
    ;; (settle+refresh+mirror-resync) fix + the O(present-users) scan that shares the step, staying under ~2M.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration). Start conservative.
    (defconst N_FIX:integer 400)
    ;; Per-step recompute capacity (re-score SWEEP). CALIBRATION-GATED — size N_SWEEP against the measured gas of one
    ;; holder recompute (settle → aggregate/lane refold → deb + mirror) plus the O(present) window scan it shares,
    ;; staying under ~2M. The sweep unit is HEAVIER than the inject fix (deeper refold), so N_SWEEP < N_FIX.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration).
    (defconst N_SWEEP:integer 300)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap MTX-AQP|C>INJECT (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Protects the MTX|n|C_Inject multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is ACTIVE \
            \ while the steps call AQP-FVT's XE_ building blocks (FVT's P|UEV_IMC checks MTX-AQP's registered caller \
            \ guard — see P|A_Define). Acquired fresh per step (steps are separate txs; the pact-id gates continuation)."
        @event
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap MTX-AQP|C>SWEEP-REVOKE (patron:string executor:string anchor-id:string)
        @doc "Protects the MTX|n|C_SweepRevokeAnchor multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is \
            \ ACTIVE while the steps call AQP-FVT's XE_ bracket (freeze/revoke/unfreeze) + recompute-chunk building \
            \ blocks (FVT's P|UEV_IMC checks MTX-AQP's registered caller guard — see P|A_Define). Acquired fresh per \
            \ step (steps are separate txs; the pact-id gates continuation). The anchor owner (= anchored-asset \
            \ owner) is enforced downstream inside ANK|XE>SWEEP-REVOKE; the EXECUTOR is pinned to that same \
            \ authority here, via ANK's shared disjunction helper rather than a second copy of the rule."
        @event
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::UEV_ExecutorIzAnchorAuthority executor anchor-id)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_SweepTotalPresent:integer (score-ids:[string])
        @doc "Total present holders across every FVT member employing the swept boost-class — the paginated \
            \ recompute-set size. Read-only; sweep-in-progress keeps it fixed across defpact steps."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (fold (+) 0
                (map
                    (lambda (sid:string) (length (RPS.URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 1 — Innate protection offered by XE_FvtSweepRecomputeChunk
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
                            (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                            (seen-before:integer (at "seen" acc))
                            (fvt:string (ref-SCR::UR_SCR|ScoreFvtLink sid))
                            (member:string
                                (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid))
                        )
                        (let
                            (
                                (users:[string] (RPS.URH_FvtPresentUsers fvt))
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
                                            (RPS.XE_FvtSweepRecomputeChunk fvt member boost-class-id slice)
                                            {
                                            "seen"
                                            :
                                            seen-after,
                                            "processed"
                                            :
                                            (+ (at "processed" acc) (length slice))
                                            }
                                        )
                                        {"seen": seen-after, "processed": (at "processed" acc)})
                                )
                            )
                        )
                    ))
                {"seen": 0, "processed": 0}
                score-ids))
    )
    ;;{5.7}  User [A/C]
    (defun C_2|Inject (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "2-step enforced-fresh inject (spike fallback for AQP-FVT::CC_Inject; handles up to 2×N_FIX stale \
            \ stakers). Acquires MTX-AQP|C>INJECT, then runs the MTX|2|C_Inject defpact. Advance with \
            \ (continue-pact 1). Vault/treasury only (the defpact's inject is class≠0). \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. MTX-AQP|C>INJECT validates the CONTEXT and \
            \ proves no account. The executor's tokens are debited inside the defpact's step 0, \
            \ which calls AQP-FVT::XB_FvtInject and bottoms out in \
            \ (TFT::C_Transfer patron executor AQP|SC_NAME reward-dptf-id amount). FORWARDED \
            \ cannot see it: the hop is a DEFPACT STEP, and the tool matches direct modref \
            \ calls in the entrypoint's own body. Renamed from <injector>, which was already the \
            \ right account under a local word -- the same rename 05_FVT's three injects took. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
            (MTX|2|C_Inject patron executor fvt-id reward-dptf-id amount)
        )
    )
    (defun C_2|SweepRevokeAnchor (patron:string executor:string anchor-id:string)
        @doc "2-step paginated re-score SWEEP that retires an employed anchor (Phase 3 closeout; spike fallback for \
            \ AQP-FVT::CC_SweepRevokeAnchor when the recompute set exceeds one tx). Acquires MTX-AQP|C>SWEEP-REVOKE, \
            \ then runs the MTX|2|C_SweepRevokeAnchor defpact. Step 0 brackets (freeze + swept-revoke) + recomputes \
            \ the first window; advance with (continue-pact 1). Owner enforced downstream in ANK|XE>SWEEP-REVOKE."
        (P|UEV_IMC)
        (with-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id)
            (MTX|2|C_SweepRevokeAnchor patron executor anchor-id)
        )
    )
    (defpact MTX|2|C_Inject (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (stale:[string] (RPS.URH_FvtStalePresentUsers fvt-id))
                )
                (if (<= (length stale) N_FIX)
                    (let
                        (
                            (n:integer (length stale))
                        )
                        (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                        (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron executor fvt-id reward-dptf-id amount))
                        (yield {"injected" : true})
                        (format "MTX Inject 1|2: fixed {} stale staker(s) and INJECTED {} {} (terminal)." [n amount reward-dptf-id])
                    )
                    (let
                        (
                            (remaining:integer (- (length stale) N_FIX))
                        )
                        (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id (take N_FIX stale))
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
                                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                                (stale:[string] (RPS.URH_FvtStalePresentUsers fvt-id))
                            )
                            (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                            (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron executor fvt-id reward-dptf-id amount))
                            (format "MTX Inject 2|2: fixed {} remaining stale staker(s) and INJECTED {} {}." [(length stale) amount reward-dptf-id])
                        )
                    )
                )
            )
        )
    )
    (defpact MTX|2|C_SweepRevokeAnchor (patron:string executor:string anchor-id:string)
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
                (require-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id))
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
                                    (format "MTX Sweep 1|2: swept-revoked anchor {} and recomputed {} holder(s) across {} score(s) (terminal)." [anchor-id n (length score-ids)])
                                )
                                (let
                                    (
                                        (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id 0 N_SWEEP))
                                    )
                                    (yield {"done": false, "boost-class-id": boost-class-id, "score-ids": score-ids, "offset": N_SWEEP})
                                    (format "MTX Sweep 1|2: swept-revoked anchor {}; recomputed {} of {} holder(s) — {} remain, continue to step 2." [anchor-id n total (- total N_SWEEP)])
                                ))
                        )
                    )
                )
            )
        )
        ;;Step 1 — if step 0 already finished, no-op; else recompute the remainder [offset, total) then unfreeze.
        (step
            (resume
                {"done" := done, "boost-class-id" := boost-class-id, "score-ids" := score-ids, "offset" := offset}
                (if done
                    "MTX Sweep 2|2: already completed in step 1 — no-op."
                    (with-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id)
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
                                (format "MTX Sweep 2|2: recomputed {} remaining holder(s) — anchor {} retired." [n anchor-id])
                            )
                        )))))
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact (module only -- its interface is already live)
(module AQP-DSA GOV
    @doc "Delegated Staking Agencies — a delegation layer over AQP-FVT's two-tier farm \
        \ settle. An agency is one FVT member (a triplet for Custodians): delegators stake \
        \ into it, an operator runs nodes to capture reward units and takes a per-mille fee. \
        \ Provides C_DefineDelegationVault, C_AdmitAgency, C_RecomputeCapture, oracle \
        \ auth/write, and royalty withdraw/burn/fuel/fee ops; it writes the member's \
        \ delegation/capture fields through FVT XE_ and reads them at inject. First client: \
        \ Custodians."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DsaV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DSA                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DSA_ADMIN)))
    (defcap GOV|DSA_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_DSA)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "DSA Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DSA|CALLER ()
        true
    )
    (defcap P|DSA|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DSA|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|DSA|REMOTE-GOV))
        (compose-capability (P|DSA|CALLER))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DSA_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (mg:guard (create-capability-guard (P|DSA|CALLER)))
            )
            ;; DSA calls AQP-FVT's XE_ building blocks (SetMemberCapture / SetMemberDelegation / SetFvtOracleOn,
            ;; all P|UEV_IMC-gated) — register DSA as an allowed IMC caller of AQP-FVT. (SCORE/POOL calls for
            ;; agency-open are added here when that path is built.)
            (ref-P|FVT::P|A_AddIMP mg)
            ;; #75 B': DSA's capture/oracle/royalty XE_ building blocks moved to the RPS reward engine — register on RPS IMP.
            (ref-P|RPS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;; Operator fee bounds (flat, per-mille): 1%..50%.
    (defconst DSA_FEE_MIN:integer 10)
    (defconst DSA_FEE_MAX:integer 500)
    ;; Full-uptime promile (the oracle scale; capture-weight = capture-units × uptime / DSA_UPTIME_FULL).
    (defconst DSA_UPTIME_FULL:integer 1000)
    (defconst GAS|DEFINE-VAULT:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-dsa-vault")))
    (defconst GAS|OPEN-AGENCY:decimal                       (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-dsa-agency")))
    (defconst GAS|RECOMPUTE-CAPTURE:decimal                 (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "recompute-capture")))
    (defconst GAS|SET-ORACLE-AUTH:decimal                   (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "set-oracle-auth")))
    (defconst GAS|ORACLE-WRITE:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "oracle-write")))
    (defconst GAS|WITHDRAW-ROYALTY:decimal                  (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-dispose")))
    (defconst GAS|BURN-ROYALTY:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-dispose")))
    (defconst GAS|FUEL-ROYALTY:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-fuel")))
    (defconst GAS|SET-AGENCY-FEE:decimal                    (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "set-agency-fee")))
    (defconst DSA_UPTIME_MIN:integer 0)
    ;;{3.2}  schemas
    ;;
    ;;{3.3}  tables
    (deftable DSA|T|Template:{AcquisitionSchemasV1.DSA|Template})                    ;; Key = <FVT-ID>
    (deftable DSA|T|Agency:{AcquisitionSchemasV1.DSA|Agency})                        ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable DSA|T|OracleAuth:{AcquisitionSchemasV1.DSA|OracleAuth})                ;; Key = <FVT-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DSA|C>DEFINE-VAULT (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault. Enforces: the FVT exists + is class-0, patron IS the \
            \ FVT owner (+ signs), unit-score positive, no template yet. Composes SECURE for the template write. \
            \ (The model-id's validity is enforced when CC_OpenAgency calls the SCORE factory.)"
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
            (enforce (= executor fvt-owner) "Only the FVT owner may define the delegation vault")
            (enforce (> unit-score 0) "unit-score must be positive")
            (enforce (not (URC_DsaTemplateExists fvt-id)) "This FVT is already a DSA vault")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (SECURE))
    )
    (defcap DSA|C>OPEN-AGENCY (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Authorize opening a delegation agency on an active DSA vault. Enforces the vault template exists + \
            \ active and the fee is in [DSA_FEE_MIN, DSA_FEE_MAX]. Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard + SECURE are active for the FVT admit/delegation/stake calls + the DSA|Agency write. The \
            \ one-time quintessence ≥ unit-score/2 OPEN GATE is NOT here — it is a TERMINAL enforce at the END of \
            \ CC_OpenAgency's body, AFTER the operator's initial stake (the cap runs before the body, when Q is still \
            \ 0; a score can only be staked once admission has linked it, so the stake must live inside open). \
            \ Operator account-ownership is enforced downstream in FVT|XE>ADMIT-DELEGATION."
        @event
        (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
        (enforce (and (>= fee-per-mille DSA_FEE_MIN) (<= fee-per-mille DSA_FEE_MAX)) "Operator fee out of range (1%..50%)")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>RECOMPUTE-CAPTURE (patron:string fvt-id:string score-entity-id:string)
        @doc "Recompute an agency's capture from its CURRENT quintessence / nodes / uptime (permissionless — any \
            \ patron may keep an agency's capture fresh after a delegator stake/unstake changed Q). Enforces the \
            \ FVT is a DSA vault + the score entity is a delegation member. Composes P|SECURE-CALLER for the FVT \
            \ XE_SetMemberCapture write."
        @event
        (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
        (enforce (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-ORACLE-AUTH (patron:string executor:string fvt-id:string)
        @doc "Authorize the delegated oracle key for a DSA vault + arm the FVT oracle-on expiry. Owner-gated \
            \ (patron IS the FVT owner + signs). Composes P|SECURE-CALLER for the FVT XE_SetFvtOracleOn write."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may set the oracle authority")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>WITHDRAW-ROYALTY (patron:string executor:string fvt-id:string)
        @doc "Owner-only: withdraw the whole royalty pool of a DSA vault to the FVT owner. Enforces the vault is a \
            \ live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard is active for the FVT XE_WithdrawRoyalty custody call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may withdraw royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>BURN-ROYALTY (patron:string executor:string fvt-id:string)
        @doc "Owner-only: BURN the whole royalty pool of a DSA vault. Enforces the vault is a live DSA vault + \
            \ patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC guard is active \
            \ for the FVT XE_BurnRoyalty custody-burn call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may burn royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>FUEL-ROYALTY (patron:string executor:string fvt-id:string swpair:string)
        @doc "Owner-only: FUEL a swpair with the whole royalty pool of a DSA vault (add liquidity, no LP mint). \
            \ Enforces the vault is a live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER \
            \ so DSA's registered IMC guard is active for the FVT XE_FuelRoyalty custody-fuel call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may fuel with royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-AGENCY-FEE (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee. Enforces the vault is live, patron IS the FVT \
            \ owner (+ signs), fee in [DSA_FEE_MIN, DSA_FEE_MAX]. A fee change is O(1) — it reprices only FUTURE \
            \ injects (the fee is never baked into a stored weight). Composes P|SECURE-CALLER for the FVT mirror."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may change the agency fee")
            (enforce (and (>= fee-per-mille DSA_FEE_MIN) (<= fee-per-mille DSA_FEE_MAX)) "Operator fee out of range (1%..50%)")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|A>ORACLE-WRITE (fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "The delegated oracle writes an agency's daily {nodes, uptime}. Enforces the registered oracle guard \
            \ (DSA|OracleAuth), the score entity is a delegation member, nodes non-negative, uptime in \
            \ [DSA_UPTIME_MIN, DSA_UPTIME_FULL]. Composes P|SECURE-CALLER for the recompute + FVT capture write."
        @event
        (enforce-guard (UR_DSA-ORA|Guard fvt-id))
        (enforce (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
        (enforce (fold (and) true
            [ (>= nodes 0)
              (>= uptime DSA_UPTIME_MIN)
              (<= uptime DSA_UPTIME_FULL) ]) "Oracle values out of range (nodes >= 0, uptime 0..1000)")
        (compose-capability (P|SECURE-CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_DSA|Template:object{AcquisitionSchemasV1.DSA|Template}
        (model-id:string unit-score:integer active:bool fvt-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|Template}."
        {"model-id"            : model-id
        ,"unit-score"          : unit-score
        ,"active"              : active
        ,"fvt-id"              : fvt-id}
    )
    (defun UDC_DSA|Agency:object{AcquisitionSchemasV1.DSA|Agency}
        (operator-konto:string fee-per-mille:integer nodes:integer uptime:integer fvt-id:string score-entity-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|Agency}."
        {"operator-konto" : operator-konto
        ,"fee-per-mille"  : fee-per-mille
        ,"nodes"          : nodes
        ,"uptime"         : uptime
        ,"fvt-id"         : fvt-id
        ,"score-entity-id": score-entity-id}
    )
    (defun UDC_DSA|OracleAuth:object{AcquisitionSchemasV1.DSA|OracleAuth}
        (oracle-guard:guard fvt-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|OracleAuth}."
        {"oracle-guard" : oracle-guard
        ,"fvt-id"       : fvt-id}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_Agency:string (fvt-id:string score-entity-id:string)
        @doc "Composite key for DSA|T|Agency: fvt-id | score-entity-id."
        (concat [fvt-id BAR score-entity-id])
    )
    (defun UC_CaptureWeight:decimal (capture-units:decimal uptime:integer)
        @doc "The capture-weight (inject numerator) = capture-units × uptime / DSA_UPTIME_FULL. Uptime is a \
            \ per-mille [0..1000]; /1000 is exact in decimal, so no rounding is needed."
        (* capture-units (/ (dec uptime) (dec DSA_UPTIME_FULL)))
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    (defun UR_DSA-TMP|Template:object{AcquisitionSchemasV1.DSA|Template} (fvt-id:string)
        @doc "Reads the full DSA template row for a vault."
        (read DSA|T|Template fvt-id)
    )
    (defun UR_DSA-TMP|ModelId:string (fvt-id:string)
        @doc "Reads the score-entity model-id bound to a DSA vault."
        (at "model-id" (read DSA|T|Template fvt-id ["model-id"]))
    )
    (defun UR_DSA-TMP|UnitScore:integer (fvt-id:string)
        @doc "Reads the unit-score (quintessence per capture unit; open gate = unit-score/2) for a DSA vault."
        (at "unit-score" (read DSA|T|Template fvt-id ["unit-score"]))
    )
    (defun UR_DSA-TMP|Active:bool (fvt-id:string)
        @doc "Reads whether a DSA vault template is active."
        (at "active" (read DSA|T|Template fvt-id ["active"]))
    )
    (defun UR_DSA-AGN|Agency:object{AcquisitionSchemasV1.DSA|Agency} (fvt-id:string score-entity-id:string)
        @doc "Reads the full agency row (absent ⇒ defaults: no operator, min fee, no nodes, full uptime)."
        (with-default-read DSA|T|Agency (UCk_Agency fvt-id score-entity-id)
            {"operator-konto": "", "fee-per-mille": DSA_FEE_MIN, "nodes": 0, "uptime": DSA_UPTIME_FULL
            ,"fvt-id": fvt-id, "score-entity-id": score-entity-id}
            {"operator-konto":= op, "fee-per-mille":= fee, "nodes":= n, "uptime":= u, "fvt-id":= fid, "score-entity-id":= seid}
            (UDC_DSA|Agency op fee n u fid seid)
        )
    )
    (defun UR_DSA-AGN|Operator:string (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's operator konto."
        (at "operator-konto" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|FeePerMille:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's flat operator fee (per-mille, on delegators only)."
        (at "fee-per-mille" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|Nodes:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's oracle node count (the capture-unit cap)."
        (at "nodes" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|Uptime:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's oracle uptime promile (1..1000)."
        (at "uptime" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-ORA|Guard:guard (fvt-id:string)
        @doc "Reads the delegated oracle-write guard for a DSA vault."
        (at "oracle-guard" (read DSA|T|OracleAuth fvt-id ["oracle-guard"]))
    )
    (defun URC_DsaTemplateExists:bool (fvt-id:string)
        @doc "True when a DSA vault template exists for this FVT."
        (with-default-read DSA|T|Template fvt-id {"fvt-id" : BAR} {"fvt-id" := f} (!= f BAR))
    )
    (defun URC_DsaTemplateActive:bool (fvt-id:string)
        @doc "True when a DSA vault template exists AND is active."
        (with-default-read DSA|T|Template fvt-id {"fvt-id" : BAR, "active" : false} {"fvt-id" := f, "active" := a} (and (!= f BAR) a))
    )
    (defun URC_AgencyQuintessence:decimal (score-entity-id:string)
        @doc "An agency's total quintessence = Σ the triplet's three scores' total-base-score (staked collectable × \
            \ the model's nonce values). The open gate + the capture divisor read this."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (+ (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
               (+ (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                  (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))))
        )
    )
    (defun URC_CaptureUnits:decimal (fvt-id:string score-entity-id:string)
        @doc "How many whole capture units this agency currently commands = min(⌊Q / unit-score⌋, nodes): the \
            \ stake supports ⌊Q/unit-score⌋ units, capped by the oracle-reported node count."
        (let
            (
                (raw:integer (floor (/ (URC_AgencyQuintessence score-entity-id) (dec (UR_DSA-TMP|UnitScore fvt-id)))))
                (nodes:integer (UR_DSA-AGN|Nodes fvt-id score-entity-id))
            )
            (dec (if (< raw nodes) raw nodes))
        )
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    ;;   (flat GAS legs; the 3 royalty readers return the GAS leg the exec concats with the custody-move XE_)
    (defun URCi_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_DefineDelegationVault" "issue-dsa-vault")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OpenAgency:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg for the core admit (C_AdmitAgency); the Talos open flow additionally stakes operator collateral."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|CC_OpenAgency" "issue-dsa-agency")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_RecomputeCapture" "recompute-capture")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_SetOracleAuth" "set-oracle-auth")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OracleWrite:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_OracleWrite" "oracle-write")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the custody-move IGNIS (FVT::XE_WithdrawRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_WithdrawRoyalty" "royalty-dispose")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the burn's IGNIS (FVT::XE_BurnRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_BurnRoyalty" "royalty-dispose")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the fuel's IGNIS (FVT::XE_FuelRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_FuelRoyalty" "royalty-fuel")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_WithdrawRoyalty: GAS|WITHDRAW-ROYALTY gas leg + the FVT custody-move \
            \ leg (FVT::URCi_WithdrawRoyaltyCustody mirroring XE_WithdrawRoyalty to the FVT owner). Read-only mirror \
            \ of the exec's UDC_ConcatenateOutputCumulators [gas custody]."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_WithdrawRoyalty patron [fvt-id]))
               (RPS.URCi_WithdrawRoyaltyCustody fvt-id reward-dptf-id (RPS.UR_FVT|OwnerKonto fvt-id)))
        ))
    (defun URCi_BurnRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_BurnRoyalty: GAS|BURN-ROYALTY gas leg + the FVT custody-burn leg \
            \ (FVT::URCi_BurnRoyaltyCustody mirroring XE_BurnRoyalty). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_BurnRoyalty patron [fvt-id]))
               (RPS.URCi_BurnRoyaltyCustody fvt-id reward-dptf-id))
        ))
    (defun URCi_FuelRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "FULL reconstructed IGNIS ifp of C_FuelRoyalty: GAS|FUEL-ROYALTY gas leg + the FVT custody-fuel leg \
            \ (FVT::URCi_FuelRoyaltyCustody mirroring XE_FuelRoyalty into <swpair>). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_FuelRoyalty patron [fvt-id]))
               (RPS.URCi_FuelRoyaltyCustody fvt-id reward-dptf-id swpair))
        ))
    (defun URCi_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_SetAgencyFee" "set-agency-fee")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_OpenGate:bool (fvt-id:string score-entity-id:string)
        @doc "Terminal open gate — after the operator's initial stake, the agency quintessence must clear \
            \ unit-score/2. The Talos AQP-DSA|CC_OpenAgency flow calls this at the END of the atomic open (admit → \
            \ stake → THIS); a short operator stake fails here and rolls the whole open back. Unprotected read+enforce. \
            \ \
            \ THE HALF IS FIXED BY DESIGN — owner ruling 2026-09-19, recorded because it LOOKS like a \
            \ missing knob. Opening an agency costs exactly half of one earning unit; the module implies \
            \ that ratio everywhere and it is deliberately not configurable. A second DSA|Template field \
            \ was considered and REJECTED: flexibility is not wanted at this variable, and a settable gate \
            \ could be raised above unit-score, which would make agencies unopenable while looking valid. \
            \ So `unit-score 20000` publishes BOTH thresholds — 20000 per earning unit, 10000 to open."
        (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec (UR_DSA-TMP|UnitScore fvt-id)) 2.0))
            "Open gate: operator must stake quintessence >= unit-score/2 to open")
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    (defun WI_Template:string (fvt-id:string row:object{AcquisitionSchemasV1.DSA|Template})
        @doc "Insert a DSA vault template row. require SECURE."
        (require-capability (SECURE))
        (insert DSA|T|Template fvt-id row)
    )
    (defun WI_Agency:string (fvt-id:string score-entity-id:string row:object{AcquisitionSchemasV1.DSA|Agency})
        @doc "Insert a DSA agency row. require SECURE."
        (require-capability (SECURE))
        (insert DSA|T|Agency (UCk_Agency fvt-id score-entity-id) row)
    )
    (defun WU_Agency-Oracle:string (fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Update an agency's oracle inputs {nodes, uptime}. require SECURE."
        (require-capability (SECURE))
        (update DSA|T|Agency (UCk_Agency fvt-id score-entity-id) {"nodes" : nodes, "uptime" : uptime})
    )
    (defun WU_Agency-Fee:string (fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Update an agency's operator fee-per-mille. require SECURE."
        (require-capability (SECURE))
        (update DSA|T|Agency (UCk_Agency fvt-id score-entity-id) {"fee-per-mille" : fee-per-mille})
    )
    (defun WI_OracleAuth:string (fvt-id:string row:object{AcquisitionSchemasV1.DSA|OracleAuth})
        @doc "Write (set / rotate) a DSA vault's oracle authority row. require SECURE."
        (require-capability (SECURE))
        (write DSA|T|OracleAuth fvt-id row)
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;Protection: Class 2 — SECURE
    (defun XI_ApplyCapture:string (fvt-id:string score-entity-id:string oracle-ts:time)
        @doc "Recompute an agency's capture from CURRENT Q / nodes / uptime and write it onto the FVT member \
            \ (XE_SetMemberCapture), stamping the given oracle-ts. Callers hold P|SECURE-CALLER (⇒ SECURE + the \
            \ DSA IMC guard the FVT XE_ requires); a stake recompute passes the PRESERVED oracle-ts, an oracle \
            \ write passes NOW."
        (require-capability (SECURE))
        (let
            (
                (units:decimal (URC_CaptureUnits fvt-id score-entity-id))
            )
            (RPS.XE_SetMemberCapture fvt-id score-entity-id
                units (UC_CaptureWeight units (UR_DSA-AGN|Uptime fvt-id score-entity-id)) oracle-ts)
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [A]   admin
    (defun C_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault: record the score-entity model + unit-score (active). \
            \ Only the FVT owner may define it. P|UEV_IMC + DSA|C>DEFINE-VAULT. Bills GAS|DEFINE-VAULT. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>DEFINE-VAULT resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>DEFINE-VAULT patron executor fvt-id model-id unit-score)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_Template fvt-id (UDC_DSA|Template model-id unit-score true fvt-id))
                (URCi_DefineDelegationVault patron [fvt-id])
            )
        )
    )
    (defun C_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string oracle-guard:guard)
        @doc "Owner-only: authorize the delegated oracle key for this DSA vault (DSA|OracleAuth) and ARM the FVT \
            \ oracle-on expiry, so stale oracle data (>25h) captures nothing. P|UEV_IMC + DSA|C>SET-ORACLE-AUTH. \
            \ Bills GAS|SET-ORACLE-AUTH. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>SET-ORACLE-AUTH resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-ORACLE-AUTH patron executor fvt-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_OracleAuth fvt-id (UDC_DSA|OracleAuth oracle-guard fvt-id))
                (ref-FVT::XE_SetFvtOracleOn fvt-id true)
                (URCi_SetOracleAuth patron [fvt-id])
            )
        )
    )
    (defun C_OracleWrite:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Delegated-oracle-only: write an agency's daily {nodes, uptime}, then recompute its capture stamped \
            \ \
            \ EXECUTORLESS BY DESIGN (canon 2.2, 2026-09-22). The authority here is \
            \ (enforce-guard (UR_DSA-ORA|Guard fvt-id)) -- a GUARD, not an account. There is no \
            \ Ouronet account to bind an executor to, and inventing one would be a name nothing \
            \ checks, which 4f rates worse than none. \
            \ \
            \ The attribution exists ONE LEVEL UP and is recorded there: C_SetOracleAuth is what \
            \ registers this guard, and it takes an <executor> proven against the vault owner. \
            \ So the ledger can answer WHO AUTHORISED this oracle, which is the question that \
            \ has an account-shaped answer. \
            \ with NOW (fresh oracle-ts resets the 25h expiry). Authorized by the registered oracle guard. \
            \ P|UEV_IMC + DSA|A>ORACLE-WRITE. Bills GAS|ORACLE-WRITE."
        (P|UEV_IMC)
        (with-capability (DSA|A>ORACLE-WRITE fvt-id score-entity-id nodes uptime)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Oracle fvt-id score-entity-id nodes uptime)
                (XI_ApplyCapture fvt-id score-entity-id (at "block-time" (chain-data)))
                (URCi_OracleWrite patron [score-entity-id])
            )
        )
    )
    (defun A_ToggleExternalOracle:string (patron:string executor:string on:bool)
        @doc "DSA MODULE ADMIN (GOV): flip the SINGULAR GLOBAL external-oracle switch for ALL operators at once. \
            \ OFF ⇒ external oracling is bypassed protocol-wide — every agency captures its STORED weight (oracle \
            \ entries, fresh or stale, are ignored); ON ⇒ the oracle-validity freshness gate applies (an operator \
            \ with no/stale entry captures 0). Composes P|SECURE-CALLER for the FVT global-config write. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: GOV|DSA_ADMIN decides whether the call proceeds. The EXECUTOR is the ACTOR \
            \ among the keyholders, proven by CAP_EnforceAccountOwnership -- authority and \
            \ attribution are orthogonal and neither substitutes for the other. This switch is \
            \ SINGULAR AND GLOBAL, so the audit trail for WHICH keyholder flipped it matters \
            \ more here than for a per-entity admin op, not less. Same treatment as DEMIPAD's \
            \ four admin ops and LIQUID::A_MigrateLiquidFunds."
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (RPS.XE_SetExternalOracle on)
            )
        )
    )
    (defun A_SetOracleValidity:string (patron:string executor:string seconds:integer)
        @doc "DSA MODULE ADMIN (GOV): set the GLOBAL oracle-validity window (seconds; the freshness horizon an \
            \ oracle write is honored for while external-oracle is ON). Must be positive. Composes P|SECURE-CALLER \
            \ for the FVT global-config write. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: GOV|DSA_ADMIN decides whether the call proceeds. The EXECUTOR is the ACTOR \
            \ among the keyholders, proven by CAP_EnforceAccountOwnership -- authority and \
            \ attribution are orthogonal and neither substitutes for the other. This switch is \
            \ SINGULAR AND GLOBAL, so the audit trail for WHICH keyholder flipped it matters \
            \ more here than for a per-entity admin op, not less. Same treatment as DEMIPAD's \
            \ four admin ops and LIQUID::A_MigrateLiquidFunds."
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (enforce (> seconds 0) "oracle-validity must be positive")
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (RPS.XE_SetOracleValidity seconds)
            )
        )
    )
    (defun C_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool (uptime-shortfall custody) of <reward-dptf-id> on a DSA \
            \ vault by WITHDRAWING it to the FVT owner (delegates the AQP-custody move + zero to the FVT primitive \
            \ FVT::XE_WithdrawRoyalty, which holds the custody-governor authority). P|UEV_IMC + DSA|C>WITHDRAW-ROYALTY. \
            \ Bills GAS|WITHDRAW-ROYALTY merged with the custody transfer's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>WITHDRAW-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>WITHDRAW-ROYALTY patron executor fvt-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_WithdrawRoyalty patron [fvt-id])
                      (RPS.XE_WithdrawRoyalty patron fvt-id reward-dptf-id (RPS.UR_FVT|OwnerKonto fvt-id)) ]
                    [fvt-id])
            )
        )
    )
    (defun C_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by BURNING it (delegates \
            \ the AQP-custody burn + zero to FVT::XE_BurnRoyalty; AQP|SC_NAME holds the autonomic burn role). \
            \ P|UEV_IMC + DSA|C>BURN-ROYALTY. Bills GAS|BURN-ROYALTY merged with the burn's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>BURN-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>BURN-ROYALTY patron executor fvt-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_BurnRoyalty patron [fvt-id])
                      (RPS.XE_BurnRoyalty patron fvt-id reward-dptf-id) ]
                    [fvt-id])
            )
        )
    )
    (defun C_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by FUELING <swpair> \
            \ (add liquidity WITHOUT minting LP — delegates to FVT::XE_FuelRoyalty; the reward-dptf must be a token \
            \ of the swpair). P|UEV_IMC + DSA|C>FUEL-ROYALTY. Bills GAS|FUEL-ROYALTY merged with the fuel's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>FUEL-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>FUEL-ROYALTY patron executor fvt-id swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_FuelRoyalty patron [fvt-id])
                      (RPS.XE_FuelRoyalty patron fvt-id reward-dptf-id swpair) ]
                    [fvt-id])
            )
        )
    )
    (defun C_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee-per-mille. Updates DSA|Agency + mirrors it onto \
            \ the FVT member (FVT::XE_SetAgencyFee) so the next inject uses the new split. Safe + O(1) — the fee is \
            \ never in a stored weight, so this reprices only FUTURE injects, no per-delegator recompute. P|UEV_IMC + \
            \ DSA|C>SET-AGENCY-FEE. Bills GAS|SET-AGENCY-FEE. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>SET-AGENCY-FEE resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-AGENCY-FEE patron executor fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Fee fvt-id score-entity-id fee-per-mille)
                (RPS.XE_SetAgencyFee fvt-id score-entity-id (UR_DSA-AGN|Operator fvt-id score-entity-id) fee-per-mille)
                (URCi_SetAgencyFee patron [score-entity-id])
            )
        )
    )
    ;; [C]   client
    (defun C_AdmitAgency:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Core admit of the ATOMIC open (the Talos AQP-DSA|CC_OpenAgency flow drives the full sequence): admit \
            \ the operator's BLANK triplet as a delegation member of the class-0 vault FVT (XE_AdmitDelegationMember \
            \ — requires the sub-scores' fvt-links BAR, i.e. unstaked) + flip delegation on + record DSA|Agency. \
            \ Does NOT stake or gate: the deep DPDC custody transfer of the operator's stake needs the caller's \
            \ guard registered in DPDC-T's IMP, which is P|TS (Talos) — so the Talos flow performs the stake under \
            \ P|TS after this admit, then calls UEV_OpenGate as the terminal atomic check (a short stake reverts the \
            \ whole open). P|UEV_IMC + DSA|C>OPEN-AGENCY. Bills GAS|OPEN-AGENCY. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. DSA|C>OPEN-AGENCY validates the vault \
            \ template and the fee range; the OPERATOR's account ownership is enforced \
            \ downstream in FVT|XE>ADMIT-DELEGATION, which its own @doc already said. Stated \
            \ here too, because the canon requires the route to be written in the FUNCTION. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>OPEN-AGENCY patron executor fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (RPS.XE_AdmitDelegationMember fvt-id score-entity-id executor)
                (RPS.XE_SetMemberDelegation fvt-id score-entity-id true)
                (WI_Agency fvt-id score-entity-id (UDC_DSA|Agency executor fee-per-mille 0 DSA_UPTIME_FULL fvt-id score-entity-id))
                ;; mirror the operator + fee onto the FVT member so the inject settle can apply the fee split locally
                (RPS.XE_SetAgencyFee fvt-id score-entity-id executor fee-per-mille)
                (URCi_OpenAgency patron [score-entity-id])
            )
        )
    )
    (defun C_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "EXECUTORLESS BY DESIGN (canon 2.2, 2026-09-22): DSA|C>RECOMPUTE-CAPTURE validates \
            \ that the template is active and the score entity is a delegation member, and \
            \ proves NO account. It recomputes a DERIVED aggregate from stored weight and the \
            \ oracle entry -- idempotent truth-restoration, paid for by the patron -- so it is \
            \ deliberately permissionless, the same disposition 03_AQP's anchor syncs and \
            \ DALOS|C_UpdateEliteAccount carry. Neither parameter is an account: <fvt-id> and \
            \ <score-entity-id> are entities, so there is no executee either. \
            \ \
            \ Permissionless: recompute an agency's capture from its CURRENT quintessence (after a delegator \
            \ stake/unstake changed Q), PRESERVING the stored oracle-ts (a stake must not refresh oracle freshness). \
            \ P|UEV_IMC + DSA|C>RECOMPUTE-CAPTURE. Bills GAS|RECOMPUTE-CAPTURE."
        (P|UEV_IMC)
        (with-capability (DSA|C>RECOMPUTE-CAPTURE patron fvt-id score-entity-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XI_ApplyCapture fvt-id score-entity-id (RPS.UR_FVT-SEL|OracleTs fvt-id score-entity-id))
                (URCi_RecomputeCapture patron [score-entity-id])
            )
        )
    )

)

