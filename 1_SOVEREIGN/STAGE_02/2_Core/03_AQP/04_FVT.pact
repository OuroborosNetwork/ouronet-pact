(interface AcquisitionFarmsVaultsTreasuriesV1
    (defun GOV|Demiurgoi ())
)
(module AQP-FVT GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionFarmsVaultsTreasuriesV1)
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_FVT                    (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|FVT_ADMIN)))
    (defcap GOV|FVT_ADMIN ()                (enforce-guard GOV|MD_FVT))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|FVT|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|FVT|CALLER))
        (compose-capability (SECURE))
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
        (with-capability (GOV|FVT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|FVT_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|FVT|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
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
    (defschema FVT|Schema
        @doc "FVT definition row. Field tags (same legend as SCR|Schema): \
            \ [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade. \
            \ \
            \ **Farm (fvt-class 0):** `common-denominator` + `total-ghost-tvl-weight` (Tier-2 sum S). \
            \ **Vault / Treasury:** `common-denominator` is sentinel \"|\"; `total-ghost-tvl-weight` stays 0.0 until a vault design uses it."
        ;;--- All classes ---
        fvt-class:integer                                       ;;[.]   0 = Farm, 1 = Vault, 2 = Treasury
        ;;
        ;;Management
        owner-konto:string                                      ;;[Mu]  FVT owner
        can-upgrade:bool                                        ;;[Mu]  Settings upgradeable when true
        can-change-owner:bool                                   ;;[Mu]  Owner rotation when true
        ;;
        ;;--- Farm-only (class 0): common LP leg + Tier-2 weight sum S (Vault/Treasury: sentinel + 0.0) ---
        common-denominator:string                               ;;[Mu]  Farm: DPTF id shared by member LP scores (e.g. OURO); unsafe to change after ScoreLinks; Vault/Treasury: \"|\"
        total-ghost-tvl-weight:decimal                          ;;[M]   Farm: S = sum of enabled ScoreLinks' ghost-tvl-weight; Vault/Treasury: 0.0
        ;;
        ;;--- Aggregated SCORE mirrors (all classes) ---
        total-base-score:decimal                                ;;[M]
        total-boosted-score:decimal                             ;;[M]
        total-deb-score:decimal                                 ;;[M]
        total-nzs-count:integer                                 ;;[M]
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   FVT identity
    )
    ;;FVT Memberships
    (defschema FVT|ScoreLink
        @doc "Member score row; key (fvt-id, score-id) permanent. Tags: [.] fixed; [..] fixed after admission write; [M] mutable. \
            \ \
            \ **All classes:** membership + SCORE aggregate participation. \
            \ **Farm (parent fvt-class 0) only:** `swpair` through `pending-tranche-rewards` implement Tier-2/Tier-1 RPS for that tranche. \
            \ **Vault / Treasury (parent class 1|2):** farm-only columns are unused for now — store `swpair` \"|\", numeric fields 0.0 until vault RPS is specified."
        ;;--- All classes ---
        enabled:bool                                            ;;[M]   Excludes tranche from S and from user accrual when false
        ;;
        ;;--- Farm only (fvt-class 0 member); Vault/Treasury: sentinel / zeros until defined ---
        swpair:string                                           ;;[..]  Farm: SWP pair id from UR_GetLpSwpair at admission; else \"|\"
        ghost-tvl-weight:decimal                                ;;[M]   Farm: W_i from SWP ghost TVL; else 0.0
        last-farm-rps-g:decimal                                 ;;[M]   Farm: checkpoint vs FVT|RPS|Global.current-rps (G); else 0.0
        tranche-deb-rps:decimal                                 ;;[M]   Farm: Tier-1 L_i (reward per SCR total-deb unit); else 0.0
        pending-tranche-rewards:decimal                         ;;[M]   Farm: buffer when tranche total-deb = 0; else 0.0
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   Parent FVT
        score-id:string                                         ;;[.]   Member score id
    )
    ;;RPS — one row per (fvt-id, dptf-id): replaces separate RewardLink; reward-enabled gates inject/collect.
    (defschema FVT|RPS|Global
        @doc "Global RPS per FVT per reward DPTF. Key = <FVT-ID> | <DPTF-ID>. Farm: current-rps is Tier-2 G; inject uses S on FVT|T. \
            \ Vault/Treasury: semantics TBD (single-tier placeholder)."
        reward-enabled:bool                                     ;;[M]   Gates C_Inject / C_Collect for this reward token (was FVT|RewardLink.enabled)
        current-rps:decimal                                     ;;[M]   Farm: Tier-2 G (48 dp). Else: legacy index
        available-rewards:decimal                               ;;[M]   24 dp vault for undistributed balance
        unclaimed-count:integer                                 ;;[M]   Claimants / dust policy
        segmentation:bool                                       ;;[.]   Reserved product flag at reward registration
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   Parent FVT
        dptf-id:string                                          ;;[.]   Reward token id
    )
    ;;User Tier-1 — per (user, fvt, score tranche, reward token)
    (defschema FVT|RPS|User
        @doc "User checkpoint against ScoreLink.tranche-deb-rps (L_i) for one reward token."
        last-rps:decimal                                        ;;[M]   Last seen L_i (same precision as tranche-deb-rps)
        pending-rewards:decimal                                 ;;[M]   Accrued not yet collected
        ;;
        ;;Select Keys
        user-id:string                                          ;;[.]   Ouronet account
        fvt-id:string                                           ;;[.]   FVT id
        score-id:string                                         ;;[.]   Member score tranche
        dptf-id:string                                          ;;[.]   Reward token id
    )
    ;;
    ;;{2}
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
    ;;
    (deftable FVT|T|ScoreLink:{FVT|ScoreLink})                  ;; Key = <FVT-ID> | <Score-ID>
    ;;
    (deftable FVT|T|RPS|Global:{FVT|RPS|Global})                ;; Key = <FVT-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|User:{FVT|RPS|User})                    ;; Key = <Ouronet-Account> | <FVT-ID> | <Score-ID> | <DPTF-ID>
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    (defcap FVT|XE>SYNC-SCORE-GHOST-TVL (fvt-id:string score-id:string)
        @doc "Forward (AQP-POOL after SWP ghost TVL refresh): settle Tier-2 for this tranche; update ghost-tvl-weight from SWP; adjust FVT|T.total-ghost-tvl-weight. \
            \ Not evented — composed under AQP client flows; SWP owns reserve math, FVT owns reward invariants."
        true
    )
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    (defun URC_StoaValue:decimal (swpair:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weight:decimal (at 0 w))
                (first-worth:decimal (ref-SWPI::URC_WorthDWK first-token first-token-supply))
            )
            (if (or (= pool-type "S") (= pool-type "P"))
                (floor (* (dec how-many) first-worth) first-token-precision)
                (floor (/ first-worth first-weight) first-token-precision)
            )
        )
    )
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Lifecycle
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Create a new FVT (Farm | Vault | Treasury) entity."
        true
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Transfer FVT owner-konto per governance rules."
        true
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Toggle can-upgrade and can-change-owner on the FVT entity."
        true
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set farm-only common DPTF id shared by linked LP scores; vault/treasury use sentinel."
        true
    )
    ;;Score membership (FVT|T|ScoreLink) — key is permanent; no delete. Add = enabled true; Toggle = on/off.
    (defun C_AddScoreLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Register a score-id on this FVT; ScoreLink.enabled is true. Row key cannot be removed."
        true
    )
    (defun C_ToggleScoreLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Turn ScoreLink.enabled on or off for (fvt-id, score-id); off \
            \ excludes score from FVT aggregates and RPS denominator."
        true
    )
    ;;Reward token registration — single row FVT|T|RPS|Global per (fvt-id, dptf-id); reward-enabled gates inject/collect
    (defun C_AddRewardLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Register reward dptf-id: insert FVT|T|RPS|Global with reward-enabled true and zeroed rps fields; row key permanent."
        true
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Toggle FVT|T|RPS|Global.reward-enabled for (fvt-id, reward-dptf-id); off disables inject/collect for that token."
        true
    )
    ;;RPS economics (FVT|T|RPS|Global / FVT|T|RPS|User)
    (defun C_Inject:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Inject reward amount for a reward dptf-id. Farm: G += R / total-ghost-tvl-weight when S>0; \
            \ Vault/Treasury: legacy path may use aggregated deb until split."
        true
    )
    (defun C_Collect:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Collect accrued rewards for caller into the chosen reward \
            \ dptf-id (pending + delta RPS, dust rule)."
        true
    )
    ;;
    ;;ACTIONS  (Farm class 0 — two-tier RPS; see README_FVT.md Ghost TVL + Execution order)
    ;;
    ;;1]INJECT Rewards (farm: require total-ghost-tvl-weight S > 0)
    ;;  1a] Tier-2: current-rps (G) += reward-amount / S
    ;;  1b] Update <available-rewards> = (+ <available-rewards> <reward-amount>)
    ;;  1c] Update <unclaimed-count> = <nzs-count> (aggregate across members; semantics TBD)
    ;;
    ;;2]STAKE (per user, per member score-id tranche)
    ;;  2a] settle_tranche_tier2: earned = ghost-tvl-weight * (G - last-farm-rps-g); last-farm-rps-g := G;
    ;;       if SCR total-deb-score for score-id > 0: tranche-deb-rps (L_i) += earned / total-deb else pending-tranche-rewards += earned
    ;;  2b] Tier-1: pending-rewards += deb_user * (L_i - last-rps_user); last-rps_user := L_i  (read deb from SCORE user row)
    ;;  2c] SCORE stake path updates user deb / score totals (AQP-SCORE)
    ;;  2d] nz / unclaimed bookkeeping
    ;;  2e] last-rps_user := L_i after score mutation if needed
    ;;
    ;;3]UNSTAKE — same settle order as STAKE (2a then 2b before mutating deb)
    ;;
    ;;4]COLLECT
    ;;  4a] Repeat 2a (tranche settle) then 2b with current deb for reward line
    ;;  4b] Decrement available-rewards by payout
    ;;  4c] Dust / last-claimer rule on available-rewards vs pending
    ;;  4d-4f] pending and unclaimed-count updates; last-rps_user := L_i
    ;;
    ;;5]SWP / AQP — after swap or add/remove liquidity on swpair P:
    ;;  5a] SWP::XE_RefreshGhostTvlForSwpair(P) — recompute and store ghost TVL for P (SWP module; STOA-equivalent policy)
    ;;  5b] AQP-POOL resolves affected (pool, score-id, fvt-id) rows and calls FVT::XE_SyncFarmScoreGhostTvlFromSwp for each linked farm member (bounded by scores per pool)
    ;;  5c] XE path: settle Tier-2 for that tranche at old W_i; set ghost-tvl-weight from SWP read; FVT|T.total-ghost-tvl-weight += (new_W - old_W)
    ;;
    ;;{F7}  [X]
    ;;
    (defun XE_SyncFarmScoreGhostTvlFromSwp:string (fvt-id:string score-id:string)
        @doc "Forward entry: AQP-POOL calls after SWP refreshed ghost TVL for the member score's swpair. \
            \ UEV_IMC; FVT|XE>SYNC-SCORE-GHOST-TVL; Tier-2 settle + W_i / S update (implementation pending). \
            \ Caller supplies IGNIS cumulator upstream."
        (UEV_IMC)
        (with-capability (FVT|XE>SYNC-SCORE-GHOST-TVL fvt-id score-id)
            fvt-id
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table FVT|T)
(create-table FVT|T|ScoreLink)
(create-table FVT|T|RPS|Global)
(create-table FVT|T|RPS|User)