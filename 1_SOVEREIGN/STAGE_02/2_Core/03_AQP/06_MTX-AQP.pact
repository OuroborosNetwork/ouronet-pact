;; Deploy: load THIS file — interface + module ship together (model: 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact).
;; Holds ALL AQP multi-transaction (defpact) functions. M3 #12 (deb-staleness): the spike-fallback inject.
;;
(interface AqpMtxV1
    @doc "Exposes AQP MultiStep (defpact) client functions. Currently: the tiered enforced-fresh FVT inject \
        \ (MTX|n|C_Inject) — the spike fallback for CC_Inject when the stale set exceeds one transaction."
    ;;
    (defun C_2|Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal))
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
                (ref-P|ANK:module{OuronetPolicyV1} AQP-ANK)
                (ref-P|AQP:module{OuronetPolicyV1} AQP-POOL)
                (mg:guard (create-capability-guard (P|MTX-AQP|CALLER)))
            )
            ;; MTX-AQP calls the XE_ building blocks (UEV_IMC) of these modules — register as an allowed IMC caller.
            ;;   AQP-FVT: inject fix-chunk + the sweep recompute chunk.
            ;;   AQP-ANK: the re-score sweep's aggregate refold + swept anchor removal.
            ;;   AQP-POOL: the sweep freeze (XE_SetSweepInProgress).
            (ref-P|FVT::P|A_AddIMP mg)
            (ref-P|ANK::P|A_AddIMP mg)
            (ref-P|AQP::P|A_AddIMP mg)
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
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [C] client wrapper — acquires the flow cap, then runs the defpact
    (defun C_2|Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "2-step enforced-fresh inject (spike fallback for AQP-FVT::CC_Inject; handles up to 2×N_FIX stale \
            \ stakers). Acquires MTX-AQP|C>INJECT, then runs the MTX|2|C_Inject defpact. Advance with \
            \ (continue-pact 1). Vault/treasury only (the defpact's inject is class≠0)."
        (UEV_IMC)
        (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
            (MTX|2|C_Inject patron fvt-id reward-dptf-id amount)
        )
    )
    ;;{F6.P}  [MTX|C]
    (defpact MTX|2|C_Inject (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                    (stale:[string] (ref-FVT::URD_FvtStalePresentUsers fvt-id))
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
                                (stale:[string] (ref-FVT::URD_FvtStalePresentUsers fvt-id))
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
    ;;
)
(create-table P|T)
(create-table P|MT)
