(interface AcquisitionFarmsVaultsTreasuriesV1
    (defun GOV|Demiurgoi ())
    ;;
    ;;  [UC]
    (defun UC_ScoreLinkKey:string (fvt-id:string score-id:string))
    (defun UC_RpsGlobalKey:string (fvt-id:string dptf-id:string))
    (defun UC_RpsMemberKey:string (fvt-id:string score-id:string dptf-id:string))
    (defun UC_RpsUserKey:string (user-id:string fvt-id:string score-id:string dptf-id:string))
    ;;
    ;;  [UR] FVT|Schema (FVT|T)  Key = <FVT-ID>
    (defun UR_FVT|FvtClass:integer (fvt-id:string))
    (defun UR_FVT|OwnerKonto:string (fvt-id:string))
    (defun UR_FVT|CanUpgrade:bool (fvt-id:string))
    (defun UR_FVT|CanChangeOwner:bool (fvt-id:string))
    (defun UR_FVT|CommonDenominator:string (fvt-id:string))
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string))
    (defun UR_FVT|TotalBaseScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalBoostedScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalNzsCount:integer (fvt-id:string))
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string))
    (defun UR_FVT|FvtId:string (fvt-id:string))
    ;;
    ;;  [UR] FVT|ScoreLink (FVT|T|ScoreLink)  Key = <FVT-ID> | <Score-ID>
    (defun UR_FVT-SL|Enabled:bool (fvt-id:string score-id:string))
    (defun UR_FVT-SL|Swpair:string (fvt-id:string score-id:string))
    (defun UR_FVT-SL|GhostTvlWeight:decimal (fvt-id:string score-id:string))
    (defun UR_FVT-SL|FvtId:string (fvt-id:string score-id:string))
    (defun UR_FVT-SL|ScoreId:string (fvt-id:string score-id:string))
    ;;
    ;;  [UR] FVT|RPS|Member (FVT|T|RPS|Member)  Key = <FVT-ID> | <Score-ID> | <DPTF-ID>
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RM|PendingMemberRewards:decimal (fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RM|FvtId:string (fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RM|ScoreId:string (fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RM|DptfId:string (fvt-id:string score-id:string dptf-id:string))
    ;;
    ;;  [UR] FVT|RPS|Global (FVT|T|RPS|Global)  Key = <FVT-ID> | <DPTF-ID>
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|Segmentation:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|FvtId:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|DptfId:string (fvt-id:string dptf-id:string))
    ;;
    ;;  [UR] FVT|RPS|User (FVT|T|RPS|User)  Key = <User-ID> | <FVT-ID> | <Score-ID> | <DPTF-ID>
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RU|UserId:string (user-id:string fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RU|FvtId:string (user-id:string fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RU|ScoreId:string (user-id:string fvt-id:string score-id:string dptf-id:string))
    (defun UR_FVT-RU|DptfId:string (user-id:string fvt-id:string score-id:string dptf-id:string))
    ;;
    (defun C_TrueFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun C_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
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
    (deftable P|T:{OuronetPolicyV1.P|S})                      ;; Key = <policy-name>
    ;;  PURPOSE: Named keyset guards for this module (OuronetPolicyV1). Used by GOV|FVT_ADMIN and IMP registration.
    (deftable P|MT:{OuronetPolicyV1.P|MS})                     ;; Key = P|I (module-identity constant)
    ;;  PURPOSE: Multi-policy metadata — IMP guard list for cross-module capability checks.
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
                    ;;
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
        @doc "Post-deploy hook (AQP-BOOT Step 0): register FVT SECURE on AQP-SCORE IMP for forward XE_* (e.g. XE_CreateFvtLink)."
        (let
            (
                (ref-P|SCR:module{OuronetPolicyV1} AQP-SCORE)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
            )
            (ref-P|SCR::P|A_AddIMP dg)
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
        @doc "Key = <FVT-ID>. One farm, vault, or treasury (FVT) entity: class, owner, enabled-reward-count, SCORE aggregate mirrors. \
            \ Farm (fvt-class 0): common-denominator + total-ghost-tvl-weight S is inject denominator. \
            \ Vault/Treasury: total-deb-score mirror for inject; common-denominator sentinel \"|\"; total-ghost-tvl-weight 0.0. \
            \ UrStoa analogue: vault header (urstoa-supply on SCORE side; S or total-deb here is FVT-side denominator). \
            \ Field tags: [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade."
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
        enabled-reward-count:integer                           ;;[M]   Count of FVT|T|RPS|Global rows with reward-enabled true; 0 at issue; maintained by C_AddRewardLink / C_ToggleRewardLink
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   FVT identity
    )
    (defschema FVT|ScoreLink
        @doc "Key = <FVT-ID> | <Score-ID>. Permanent membership — which scores belong to this FVT (C_AddScoreLink). \
            \ One row per member score, NOT per reward DPTF. \
            \ Farm: swpair + ghost-tvl-weight W_i (Tier-2 weight from SWP; same for every reward token on that score). Sync updates W_i here. \
            \ Vault/NFT: enabled + sentinels (swpair \"|\", W_i 0). Does not hold G, L_i, g_i, or user pending — those live on RPS|Member / RPS|User. \
            \ Tags: [.] fixed; [..] fixed after admission write; [M] mutable."
        ;;--- All classes ---
        enabled:bool                                            ;;[M]   Excludes member score from S and from user accrual when false
        ;;
        ;;--- Farm only (fvt-class 0 member); Vault/Treasury: sentinel / zero ---
        swpair:string                                           ;;[..]  Farm: SWP pair id from UR_GetLpSwpair at admission; else \"|\"
        ghost-tvl-weight:decimal                                ;;[M]   Farm: W_i from SWP ghost TVL; else 0.0
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   Parent FVT
        score-id:string                                         ;;[.]   Member score id
    )
    (defschema FVT|RPS|Global
        @doc "Key = <FVT-ID> | <DPTF-ID>. One registered reward DPTF on this FVT — farm-wide / vault-wide for that token. \
            \ current-rps G (Tier-2 index on farms), available-rewards, reward-enabled, unclaimed-count. \
            \ Inject writes ONE G per (fvt, dptf) shared by all member scores. reward-enabled gates C_Inject / C_Collect. \
            \ UrStoa analogue: vault RPS row. Vault/Treasury Tier-2 semantics TBD (single-tier placeholder)."
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
    (defschema FVT|RPS|Member
        @doc "Key = <FVT-ID> | <Score-ID> | <DPTF-ID>. Member-score reward line — this score's RPS slice for one reward DPTF \
            \ (LP farm score or NFT vault score; one or many DPTFs per FVT). \
            \ last-farm-rps-g g_i checkpoints vs RPS|Global.G; member-deb-rps L_i is Tier-1 index; pending-member-rewards when score has no deb stakers. \
            \ Separate from ScoreLink because W_i is per score (not per DPTF). Separate from Global because G is per FVT×DPTF (not per score). \
            \ Farm: earned Tier-2 = floor(W_i×(G−g_i), 48 dp). Vault/Treasury: floor(D_i×(G−g_i), 48 dp) using SCR total-deb as weight."
        last-farm-rps-g:decimal                                 ;;[M]   Tier-2 checkpoint g_i vs FVT|RPS|Global.current-rps (G)
        member-deb-rps:decimal                                 ;;[M]   Tier-1 L_i (reward per SCR deb unit for this member score)
        pending-member-rewards:decimal                         ;;[M]   Reward buffer when member score total-deb = 0
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]   Parent FVT
        score-id:string                                         ;;[.]   Member score id
        dptf-id:string                                          ;;[.]   Reward token id
    )
    (defschema FVT|RPS|User
        @doc "Key = <Ouronet-Account> | <FVT-ID> | <Score-ID> | <DPTF-ID>. Per-staker row on a member score × reward DPTF. \
            \ last-rps checkpoints vs RPS|Member L_i; pending-rewards accrued not yet collected. \
            \ Phase 2.1 banks pending at OLD deb; phase 2.4 advances last-rps after deb change. \
            \ UrStoa analogue: UrStoaVaultUser (extended with fvt + score keys for multi-score FVTs)."
        last-rps:decimal                                        ;;[M]   Last seen L_i (same precision as member-deb-rps)
        pending-rewards:decimal                                 ;;[M]   Accrued not yet collected
        ;;
        ;;Select Keys
        user-id:string                                          ;;[.]   Ouronet account
        fvt-id:string                                           ;;[.]   FVT id
        score-id:string                                         ;;[.]   Member score id
        dptf-id:string                                          ;;[.]   Reward token id
    )
    ;;Phase 2.1 settle — ephemeral rows (not deftable); built once per TF stake/unstake pass.
    (defschema FVT|SettleFvtRewards
        @doc "One distinct FVT row in URD_FVT|SettleFvtRewardBundle — enabled reward dptf-ids from one batched RPS|Global select."
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|SettleScorePlan
        @doc "One employed score row in URC_SettleScorePlanRows — score + fvt + reward list for phase 2.1 inner loop."
        score-id:string
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|ScorePreNzFlag
        @doc "Pre-SCORE snapshot for one employed score — was user triple non-zero before phase 2.3 (UrStoa user-score before UpdateUserScore)."
        score-id:string
        was-nz:bool
    )
    (defschema FVT|StakeSettleBundle
        @doc "Precomputed stake/unstake settle scope for phases 2.1, 2.35, and 2.4 — built once per C_*StakeFlow pass; \
            \ URD_FVT|SettleFvtRewardBundle runs at most once (not per XI phase). pre-nz-flags captured before SCORE mutation."
        settle-scores:[string]
        distinct-fvts:[string]
        settle-plans:[object{FVT|SettleScorePlan}]
        pre-nz-flags:[object{FVT|ScorePreNzFlag}]
    )
    ;;
    ;;{2}
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
    (deftable FVT|T|ScoreLink:{FVT|ScoreLink})                  ;; Key = <FVT-ID> | <Score-ID>
    (deftable FVT|T|RPS|Global:{FVT|RPS|Global})                ;; Key = <FVT-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|Member:{FVT|RPS|Member})                ;; Key = <FVT-ID> | <Score-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|User:{FVT|RPS|User})                    ;; Key = <Ouronet-Account> | <FVT-ID> | <Score-ID> | <DPTF-ID>
    ;;{3}
    (defconst CT_FVT_RPS_PREC 48)
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR))
    )
    (defconst BAR                                               (CT_Bar))
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let ((ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)) (ref-ANK::GOV|AQP|SC_NAME))
    )
    (defconst AQP|SC_NAME                                       (CT_AqpScName))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    (defcap FVT|C>TRUE-FUNGIBLE-STAKE-FLOW
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "TrueFungible stake/unstake recipe (direction=true stake, false unstake). \
            \ Composes SECURE for FVT XI_* phases. \
            \ Input validation: numbered matrix in cap body below. \
            \ Phase 1 transfer/custody/balance: AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (pool-class-ok:bool (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id))
                (scores-ok:bool (ref-AQP::URC_PoolHasEmployedScores pool-id))
                (dptf-pool-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (fvt-ready:bool (URC_PoolEmployedScoresFvtStakeReady pool-id))
            )
            ;;1] pool-id
            ;;1a] pool-id must refer to issued AQP|T|Pool row — implicit (AQP-POOL URC_* reads pool-id key)
            ;;1b] aqp-class must be TF-stakeable (0 = LP, 1 = DPTF) — HERE
            (enforce pool-class-ok "Invalid pool-id: TF stake requires aqp-class 0 or 1")
            ;;1c] pool must have ≥1 employed score — HERE
            (enforce scores-ok "Invalid pool-id: pool has no employed scores")
            ;;
            ;;2] owner-id
            ;;2a] owner-id must be an activated Ouronet account — HERE
            (UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;2b] tx sender must own owner-id — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;
            ;;3] beneficiary-id
            ;;3a] beneficiary must exist — HERE (DALOS::UEV_EnforceAccountExists)
            ;;3b] beneficiary must be activated standard (non-principal) account — HERE (DALOS::UEV_EnforceAccountType false)
            (UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;
            ;;4] dptf-id
            ;;4a] dptf-id must not be R| reserved leg — HERE
            (UEV_TrueFungibleStakeNotReserved dptf-id)
            ;;4b] dptf-id must be issued DPTF — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer → DPTF::UEV_id)
            ;;4c] dptf-id must match pool canonical asset (native or F| frozen) — HERE
            (enforce dptf-pool-ok "Invalid dptf-id: leg does not match pool canonical asset")
            ;;
            ;;5] amount
            ;;5a] amount must be > 0 — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer)
            ;;5b] amount must fit dptf-id decimal precision — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer → DPTF::UEV_Amount)
            ;;
            ;;6] direction
            ;;6a] bool — no id validation required
            ;;6b] unstake (direction=false): tracker + rollup balance sufficiency — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
            ;;
            ;;7] FVT reward pipeline (phase 2.1 / 2.4 — not a cap input, derived from pool-id)
            ;;7a] every employed score: fvt-link ≠ BAR, FVT issued, ScoreLink enabled, ≥1 enabled reward DPTF — HERE
            (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreLink or reward DPTF")
            ;;
            ;;8] transfer / custody (phase 1 — not re-validated here)
            ;;8a] owner signer proof — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;8b] TFT IMC + AQP|SC_NAME vault governor — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (P|AQP|CALLER, AQP-ANK.AQP|GOV)
            ;;
            ;;9] admission-time only (not re-checked at stake)
            ;;9a] score LP denominator vs pool pair — C_AddScore admission
            ;;9b] FVT common-denominator vs member scores — C_AddScoreLink admission
            ;;9c] aqpool-link slot assignment — C_AddScore / C_RevokeScore
            ;;
            ;;--- UrStoa canonical phases (see map above C_TrueFungibleStakeFlow) ---
            ;; PHASE 1   1.1–1.3 AQP-POOL custody
            ;; PHASE 2   FVT::XI_Phase_2|RpsPreScore
            ;; PHASE 3   3.1 TF anchors; 3.2/3.3 reserved
            ;; PHASE 4   SCR::XE_ApplyTrueFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>ORTO-FUNGIBLE-STAKE-FLOW
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "OrtoFungible stake/unstake recipe (direction=true stake, false unstake). \
            \ Whole-nonce DPOF::C_Transfer only — no Transmit / partial segmentation on stake. \
            \ Four phases — no ANK leg (anchors are TF/SF/NF only; DPOF stake does not move anchor balances). \
            \ Phase 1 custody: AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (scores-ok:bool (ref-AQP::URC_PoolHasEmployedScores pool-id))
                (fvt-ready:bool (URC_PoolEmployedScoresFvtStakeReady pool-id))
                (whole-nonce-ok:bool (ref-AQP::URC_OrtoStakeWholeNonceAmounts dpof-id nonces nonce-amounts))
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            ;;1] pool-id — issued pool + ≥1 employed score (implicit via URC_*)
            (enforce scores-ok "Invalid pool-id: pool has no employed scores")
            ;;2] owner-id — activated account; signer proof in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            (UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;3] beneficiary-id — stake only: exists + standard account; unstake: BAR (read per nonce in phase 1)
            (if direction
                (UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
                (enforce (= beneficiary-id BAR) "Unstake: beneficiary-id must be BAR; tracker row is authoritative")
            )
            ;;4] dpof-id — issued DPOF; pool leg match in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;5] nonces / nonce-amounts — equal positive length; each amount must equal full nonce supply
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) whole-nonce-ok])
                "Invalid nonces / nonce-amounts: equal positive length and whole-nonce supplies required"
            )
            ;;6] direction — stake/unstake; unstake sufficiency in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;7] FVT reward pipeline — same as TF when fvt-link set on employed scores
            (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreLink or reward DPTF")
            ;;--- UrStoa canonical phases (no 1.3 / 3.x on OF — reserved no-op) ---
            ;; PHASE 1   1.1–1.2 AQP-POOL; 1.3 no-op
            ;; PHASE 2   FVT::XI_Phase_2|RpsPreScore
            ;; PHASE 3   3.1–3.3 no-op
            ;; PHASE 4   SCR::XE_ApplyOrtoFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
    )
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC] + early [UDC]  (constructors before UR with-default-read defaults)
    (defun UC_ScoreLinkKey:string (fvt-id:string score-id:string)
        @doc "Composite key for FVT|T|ScoreLink: fvt-id | score-id."
        (concat [fvt-id BAR score-id])
    )
    (defun UC_RpsGlobalKey:string (fvt-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Global: fvt-id | dptf-id."
        (concat [fvt-id BAR dptf-id])
    )
    (defun UC_RpsMemberKey:string (fvt-id:string score-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Member: fvt-id | score-id | dptf-id."
        (concat [fvt-id BAR score-id BAR dptf-id])
    )
    (defun UC_RpsUserKey:string (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|User: user-id | fvt-id | score-id | dptf-id."
        (concat [user-id BAR fvt-id BAR score-id BAR dptf-id])
    )
    ;;
    ;; Early UDC: constructors required before UR_* with-default-read default objects.
    (defun UDC_FVT|Schema:object{FVT|Schema}
        (
            fvt-class:integer
            owner-konto:string
            can-upgrade:bool
            can-change-owner:bool
            common-denominator:string
            total-ghost-tvl-weight:decimal
            total-base-score:decimal
            total-boosted-score:decimal
            total-deb-score:decimal
            total-nzs-count:integer
            enabled-reward-count:integer
            fvt-id:string
        )
        @doc "Core constructor for object{FVT|Schema}."
        {"fvt-class"                : fvt-class
        ,"owner-konto"              : owner-konto
        ,"can-upgrade"              : can-upgrade
        ,"can-change-owner"         : can-change-owner
        ,"common-denominator"       : common-denominator
        ,"total-ghost-tvl-weight"   : total-ghost-tvl-weight
        ,"total-base-score"         : total-base-score
        ,"total-boosted-score"      : total-boosted-score
        ,"total-deb-score"          : total-deb-score
        ,"total-nzs-count"          : total-nzs-count
        ,"enabled-reward-count"     : enabled-reward-count
        ,"fvt-id"                   : fvt-id}
    )
    (defun UDC_FVT|ScoreLink:object{FVT|ScoreLink}
        (
            enabled:bool
            swpair:string
            ghost-tvl-weight:decimal
            fvt-id:string
            score-id:string
        )
        @doc "Core constructor for object{FVT|ScoreLink}."
        {"enabled"                  : enabled
        ,"swpair"                   : swpair
        ,"ghost-tvl-weight"         : ghost-tvl-weight
        ,"fvt-id"                   : fvt-id
        ,"score-id"                 : score-id}
    )
    (defun UDC_FVT|RPS|Global:object{FVT|RPS|Global}
        (
            reward-enabled:bool
            current-rps:decimal
            available-rewards:decimal
            unclaimed-count:integer
            segmentation:bool
            fvt-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|Global}."
        {"reward-enabled"       : reward-enabled
        ,"current-rps"          : current-rps
        ,"available-rewards"    : available-rewards
        ,"unclaimed-count"      : unclaimed-count
        ,"segmentation"         : segmentation
        ,"fvt-id"               : fvt-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_FVT|RPS|Member:object{FVT|RPS|Member}
        (
            last-farm-rps-g:decimal
            member-deb-rps:decimal
            pending-member-rewards:decimal
            fvt-id:string
            score-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|Member}."
        {"last-farm-rps-g"          : last-farm-rps-g
        ,"member-deb-rps"          : member-deb-rps
        ,"pending-member-rewards"  : pending-member-rewards
        ,"fvt-id"                   : fvt-id
        ,"score-id"                 : score-id
        ,"dptf-id"                  : dptf-id}
    )
    (defun UDC_FVT|RPS|User:object{FVT|RPS|User}
        (
            last-rps:decimal
            pending-rewards:decimal
            user-id:string
            fvt-id:string
            score-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|User}."
        {"last-rps"         : last-rps
        ,"pending-rewards"  : pending-rewards
        ,"user-id"          : user-id
        ,"fvt-id"           : fvt-id
        ,"score-id"         : score-id
        ,"dptf-id"          : dptf-id}
    )
    ;; --- Phase 2.1 settle · ephemeral (no deftable / no UR) ---
    (defun UDC_FVT|SettleFvtRewards:object{FVT|SettleFvtRewards}
        (fvt-id:string reward-dptf-ids:[string])
        @doc "Constructor for object{FVT|SettleFvtRewards} — one URD_FVT|SettleFvtRewardBundle entry."
        {"fvt-id"           : fvt-id
        ,"reward-dptf-ids"  : reward-dptf-ids}
    )
    (defun UDC_FVT|SettleScorePlan:object{FVT|SettleScorePlan}
        (score-id:string fvt-id:string reward-dptf-ids:[string])
        @doc "Constructor for object{FVT|SettleScorePlan} — one URC_SettleScorePlanRows entry."
        {"score-id"         : score-id
        ,"fvt-id"           : fvt-id
        ,"reward-dptf-ids"  : reward-dptf-ids}
    )
    (defun UDC_FVT|ScorePreNzFlag:object{FVT|ScorePreNzFlag}
        (score-id:string was-nz:bool)
        @doc "Constructor for object{FVT|ScorePreNzFlag} — pre-SCORE nz snapshot for one employed score."
        {"score-id" : score-id
        ,"was-nz"   : was-nz}
    )
    (defun UDC_FVT|StakeSettleBundle:object{FVT|StakeSettleBundle}
        (
            settle-scores:[string]
            distinct-fvts:[string]
            settle-plans:[object{FVT|SettleScorePlan}]
            pre-nz-flags:[object{FVT|ScorePreNzFlag}]
        )
        @doc "Constructor for object{FVT|StakeSettleBundle} — shared phase 2.1 / 2.35 / 2.4 settle scope."
        {"settle-scores"    : settle-scores
        ,"distinct-fvts"    : distinct-fvts
        ,"settle-plans"     : settle-plans
        ,"pre-nz-flags"     : pre-nz-flags}
    )
    ;;
    ;;{F1}  [UR]
    ;; Reads follow schema order: (1) FVT|Schema (2) FVT|ScoreLink (3) FVT|RPS|Global (4) FVT|RPS|Member (5) FVT|RPS|User
    ;; Ephemeral settle schemas (FVT|SettleFvtRewards, FVT|SettleScorePlan): UDC only — no UR rows.
    ;;
    ;; [1] FVT|T  (FVT|Schema)  Key = <FVT-ID>
    (defun UR_FVT|Fvt:object{FVT|Schema} (fvt-id:string)
        @doc "Reads full FVT definition row from FVT|T."
        (read FVT|T fvt-id)
    )
    (defun UR_FVT|FvtClass:integer (fvt-id:string)
        @doc "Reads fvt-class from FVT row."
        (at "fvt-class" (read FVT|T fvt-id ["fvt-class"]))
    )
    (defun UR_FVT|OwnerKonto:string (fvt-id:string)
        @doc "Reads owner-konto from FVT row."
        (at "owner-konto" (read FVT|T fvt-id ["owner-konto"]))
    )
    (defun UR_FVT|CanUpgrade:bool (fvt-id:string)
        @doc "Reads can-upgrade from FVT row."
        (at "can-upgrade" (read FVT|T fvt-id ["can-upgrade"]))
    )
    (defun UR_FVT|CanChangeOwner:bool (fvt-id:string)
        @doc "Reads can-change-owner from FVT row."
        (at "can-change-owner" (read FVT|T fvt-id ["can-change-owner"]))
    )
    (defun UR_FVT|CommonDenominator:string (fvt-id:string)
        @doc "Reads common-denominator from FVT row."
        (at "common-denominator" (read FVT|T fvt-id ["common-denominator"]))
    )
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string)
        @doc "Reads total-ghost-tvl-weight (Tier-2 sum S) from FVT row."
        (at "total-ghost-tvl-weight" (read FVT|T fvt-id ["total-ghost-tvl-weight"]))
    )
    (defun UR_FVT|TotalBaseScore:decimal (fvt-id:string)
        @doc "Reads total-base-score mirror from FVT row."
        (at "total-base-score" (read FVT|T fvt-id ["total-base-score"]))
    )
    (defun UR_FVT|TotalBoostedScore:decimal (fvt-id:string)
        @doc "Reads total-boosted-score mirror from FVT row."
        (at "total-boosted-score" (read FVT|T fvt-id ["total-boosted-score"]))
    )
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string)
        @doc "Reads total-deb-score mirror from FVT row."
        (at "total-deb-score" (read FVT|T fvt-id ["total-deb-score"]))
    )
    (defun UR_FVT|TotalNzsCount:integer (fvt-id:string)
        @doc "Reads total-nzs-count mirror from FVT row."
        (at "total-nzs-count" (read FVT|T fvt-id ["total-nzs-count"]))
    )
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string)
        @doc "Reads enabled-reward-count from FVT row — cheap cap path for ≥1 active reward DPTF."
        (at "enabled-reward-count" (read FVT|T fvt-id ["enabled-reward-count"]))
    )
    (defun UR_FVT|FvtId:string (fvt-id:string)
        @doc "Reads fvt-id field from FVT row (row key should match)."
        (at "fvt-id" (read FVT|T fvt-id ["fvt-id"]))
    )
    ;;
    ;; [2] FVT|T|ScoreLink  (FVT|ScoreLink)  Key = <FVT-ID> | <Score-ID>
    (defun UR_FVT-SL|ScoreLink:object{FVT|ScoreLink} (fvt-id:string score-id:string)
        @doc "Reads ScoreLink row; absent rows read as disabled with farm sentinels via default object."
        (with-default-read FVT|T|ScoreLink (UC_ScoreLinkKey fvt-id score-id)
            (UDC_FVT|ScoreLink false BAR 0.0 fvt-id score-id)
            {"enabled"                  := en
            ,"swpair"                   := sp
            ,"ghost-tvl-weight"         := w
            ,"fvt-id"                   := fid
            ,"score-id"                 := sid}
            (UDC_FVT|ScoreLink en sp w fid sid)
        )
    )
    (defun UR_FVT-SL|Enabled:bool (fvt-id:string score-id:string)
        @doc "Reads enabled from ScoreLink row."
        (at "enabled" (UR_FVT-SL|ScoreLink fvt-id score-id))
    )
    (defun UR_FVT-SL|Swpair:string (fvt-id:string score-id:string)
        @doc "Reads swpair from ScoreLink row."
        (at "swpair" (UR_FVT-SL|ScoreLink fvt-id score-id))
    )
    (defun UR_FVT-SL|GhostTvlWeight:decimal (fvt-id:string score-id:string)
        @doc "Reads ghost-tvl-weight (W_i) from ScoreLink row."
        (at "ghost-tvl-weight" (UR_FVT-SL|ScoreLink fvt-id score-id))
    )
    (defun UR_FVT-SL|FvtId:string (fvt-id:string score-id:string)
        @doc "Reads fvt-id from ScoreLink row."
        (at "fvt-id" (UR_FVT-SL|ScoreLink fvt-id score-id))
    )
    (defun UR_FVT-SL|ScoreId:string (fvt-id:string score-id:string)
        @doc "Reads score-id from ScoreLink row."
        (at "score-id" (UR_FVT-SL|ScoreLink fvt-id score-id))
    )
    ;;
    ;; [3] FVT|T|RPS|Global  (FVT|RPS|Global)  Key = <FVT-ID> | <DPTF-ID>
    (defun UR_FVT-RG|RpsGlobal:object{FVT|RPS|Global} (fvt-id:string dptf-id:string)
        @doc "Reads global RPS row for one reward token; absent rows read as disabled with zeroed rps fields."
        (with-default-read FVT|T|RPS|Global (UC_RpsGlobalKey fvt-id dptf-id)
            (UDC_FVT|RPS|Global false 0.0 0.0 0  false fvt-id dptf-id)
            {"reward-enabled"       := re
            ,"current-rps"          := cr
            ,"available-rewards"    := ar
            ,"unclaimed-count"      := uc
            ,"segmentation"         := seg
            ,"fvt-id"               := fid
            ,"dptf-id"              := did}
            (UDC_FVT|RPS|Global re cr ar uc seg fid did)
        )
    )
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string)
        @doc "Reads reward-enabled from global RPS row."
        (at "reward-enabled" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string)
        @doc "Reads current-rps (Tier-2 G) from global RPS row."
        (at "current-rps" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Reads available-rewards from global RPS row."
        (at "available-rewards" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string)
        @doc "Reads unclaimed-count from global RPS row."
        (at "unclaimed-count" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|Segmentation:bool (fvt-id:string dptf-id:string)
        @doc "Reads segmentation flag from global RPS row."
        (at "segmentation" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|FvtId:string (fvt-id:string dptf-id:string)
        @doc "Reads fvt-id from global RPS row."
        (at "fvt-id" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|DptfId:string (fvt-id:string dptf-id:string)
        @doc "Reads dptf-id from global RPS row."
        (at "dptf-id" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    ;;
    ;; [4] FVT|T|RPS|Member  (FVT|RPS|Member)  Key = <FVT-ID> | <Score-ID> | <DPTF-ID>
    (defun UR_FVT-RM|RpsMember:object{FVT|RPS|Member} (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads member-score RPS row; absent rows read as zero g_i / L_i / pending-member-rewards."
        (with-default-read FVT|T|RPS|Member (UC_RpsMemberKey fvt-id score-id dptf-id)
            (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-id dptf-id)
            {"last-farm-rps-g"          := g
            ,"member-deb-rps"          := l
            ,"pending-member-rewards"  := ptr
            ,"fvt-id"                   := fid
            ,"score-id"                 := sid
            ,"dptf-id"                  := did}
            (UDC_FVT|RPS|Member g l ptr fid sid did)
        )
    )
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads last-farm-rps-g (g_i) from member RPS row."
        (at "last-farm-rps-g" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads member-deb-rps (L_i) from member RPS row."
        (at "member-deb-rps" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RM|PendingMemberRewards:decimal (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads pending-member-rewards from member RPS row."
        (at "pending-member-rewards" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RM|FvtId:string (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads fvt-id from member RPS row."
        (at "fvt-id" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RM|ScoreId:string (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads score-id from member RPS row."
        (at "score-id" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RM|DptfId:string (fvt-id:string score-id:string dptf-id:string)
        @doc "Reads dptf-id from member RPS row."
        (at "dptf-id" (UR_FVT-RM|RpsMember fvt-id score-id dptf-id))
    )
    ;;
    ;; [5] FVT|T|RPS|User  (FVT|RPS|User)  Key = <User-ID> | <FVT-ID> | <Score-ID> | <DPTF-ID>
    (defun UR_FVT-RU|RpsUser:object{FVT|RPS|User}
        (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads user RPS row; absent rows read as zero pending and zero last-rps checkpoint."
        (with-default-read FVT|T|RPS|User (UC_RpsUserKey user-id fvt-id score-id dptf-id)
            (UDC_FVT|RPS|User 0.0 0.0 user-id fvt-id score-id dptf-id)
            {"last-rps"         := lr
            ,"pending-rewards"  := pr
            ,"user-id"          := uid
            ,"fvt-id"           := fid
            ,"score-id"         := sid
            ,"dptf-id"          := did}
            (UDC_FVT|RPS|User lr pr uid fid sid did)
        )
    )
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads last-rps (user checkpoint vs L_i) from user RPS row."
        (at "last-rps" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads pending-rewards from user RPS row."
        (at "pending-rewards" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RU|UserId:string (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads user-id from user RPS row."
        (at "user-id" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RU|FvtId:string (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads fvt-id from user RPS row."
        (at "fvt-id" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RU|ScoreId:string (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads score-id from user RPS row."
        (at "score-id" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    (defun UR_FVT-RU|DptfId:string (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Reads dptf-id from user RPS row."
        (at "dptf-id" (UR_FVT-RU|RpsUser user-id fvt-id score-id dptf-id))
    )
    ;;
    ;;{F2}  [URD]
    ;; --- FVT|T|RPS|Global selects (stake hot path: one batched select via URD_FVT|SettleFvtRewardBundle) ---
    (defun URD_FVT-RG|EnabledRewardRows:[string] (fvt-id:string)
        @doc "Expensive read: enabled reward dptf-ids for one fvt-id (FVT|T|RPS|Global.reward-enabled true). \
            \ Prefer URD_FVT|SettleFvtRewardBundle when resolving multiple distinct FVTs in one tx."
        (map
            (lambda (row:object)
                (at "dptf-id" row)
            )
            (select FVT|T|RPS|Global ["dptf-id"]
                (and?
                    (where "fvt-id" (= fvt-id))
                    (where "reward-enabled" (= true))
                )
            )
        )
    )
    (defun URD_FVT|SettleFvtRewardBundle:[object{FVT|SettleFvtRewards}] (distinct-fvts:[string])
        @doc "Expensive read: ONE select on FVT|T|RPS|Global for all distinct-fvts, then group to SettleFvtRewards rows. \
            \ Not N× URD_FVT-RG|EnabledRewardRows — single table pass per C_*StakeFlow."
        (let
            (
                (flat-rows:[object]
                    (if (= (length distinct-fvts) 0)
                        []
                        (select FVT|T|RPS|Global ["fvt-id" "dptf-id"]
                            (and?
                                (where "reward-enabled" (= true))
                                (where "fvt-id" (lambda (fid:string) (contains fid distinct-fvts)))
                            )
                        )
                    )
                )
            )
            ;; map: distinct FVT entities → object{FVT|SettleFvtRewards} (filter flat-rows; no second select)
            (map
                (lambda (fvt-id:string)
                    (UDC_FVT|SettleFvtRewards fvt-id
                        (map
                            (lambda (row:object)
                                (at "dptf-id" row)
                            )
                            (filter
                                (lambda (row:object)
                                    (= (at "fvt-id" row) fvt-id)
                                )
                                flat-rows
                            )
                        )
                    )
                )
                distinct-fvts
            )
        )
    )
    ;;
    ;;{F3}  [URC]
    ;; --- Cap / stake-flow validation (cheap bools; no keys/select) ---
    (defun URC_FvtResolveClass:integer (fvt-id:string)
        @doc "Probe FVT|T row: returns fvt-class, or -1 when the row is absent (read failure)."
        (try -1 (UR_FVT|FvtClass fvt-id))
    )
    (defun URC_FvtExists:bool (fvt-id:string)
        @doc "True when fvt-id is an issued FVT|T row (class resolves ≠ -1)."
        (!= (URC_FvtResolveClass fvt-id) -1)
    )
    (defun URC_FvtHasEnabledRewardToken:bool (fvt-id:string)
        @doc "True when FVT|T.enabled-reward-count > 0. Counter maintained by C_AddRewardLink (+1 on add) \
            \ and C_ToggleRewardLink (±1 on reward-enabled flip). Returns false when FVT row absent."
        (> (try 0 (UR_FVT|EnabledRewardCount fvt-id)) 0)
    )
    (defun URC_ScoreFvtStakeReady:bool (score-id:string)
        @doc "True when score-id has fvt-link≠BAR, issued FVT, enabled ScoreLink, and enabled-reward-count > 0."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (fvt-id:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
            )
            (fold (and) true
                [
                    (!= fvt-id BAR)
                    (URC_FvtExists fvt-id)
                    (UR_FVT-SL|Enabled fvt-id score-id)
                    (URC_FvtHasEnabledRewardToken fvt-id)
                ]
            )
        )
    )
    (defun URC_PoolEmployedScoresFvtStakeReady:bool (pool-id:string)
        @doc "True when pool has ≥1 employed score and every employed score passes URC_ScoreFvtStakeReady. \
            \ Used by FVT|C>TRUE-FUNGIBLE-STAKE-FLOW."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (employed-ids:[string] (ref-AQP::URC_PoolActiveScoreIds pool-id))
            )
            (if (= (length employed-ids) 0)
                false
                (fold (and) true
                    (map (lambda (score-id:string) (URC_ScoreFvtStakeReady score-id)) employed-ids)
                )
            )
        )
    )
    ;; --- Phase 2.1 settle · lists, plans, IGNIS ---
    (defun URC_SettleEligibleEmployedScores:[string] (employed-ids:[string])
        @doc "Internal: employed pool scores that run phase 2.1 settle — score-id≠BAR, SCR|ScoreFvtLink≠BAR, ScoreLink enabled."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (filter
                (lambda (score-id:string)
                    (let
                        (
                            (fvt-link:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                        )
                        (fold (and) true
                            [
                                (!= score-id BAR)
                                (!= fvt-link BAR)
                                (UR_FVT-SL|Enabled fvt-link score-id)
                            ]
                        )
                    )
                )
                employed-ids
            )
        )
    )
    (defun URC_SettleDistinctFvtLinks:[string] (settle-scores:[string])
        @doc "Internal: distinct SCR|ScoreFvtLink values for settle-scores — one FVT entity counted once for IGNIS and settle scope."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (distinct
                ;; map: settle-eligible scores → SCR fvt-link (dedupe for URD bundle scope)
                (map
                    (lambda (score-id:string)
                        (ref-SCR::UR_SCR|ScoreFvtLink score-id)
                    )
                    settle-scores
                )
            )
        )
    )
    (defun URC_FvtRewardDptfIdsFromBundle:[string]
        (fvt-id:string fvt-reward-bundle:[object{FVT|SettleFvtRewards}])
        @doc "Internal: cheap bundle lookup (filter ≤7 rows) on URD_FVT|SettleFvtRewardBundle — avoids repeat select when scores share FVT."
        (at "reward-dptf-ids"
            (at 0
                (filter
                    (lambda (row:object{FVT|SettleFvtRewards})
                        (= (at "fvt-id" row) fvt-id)
                    )
                    fvt-reward-bundle
                )
            )
        )
    )
    (defun URC_FvtRpsUserRowExists:bool
        (user-id:string fvt-id:string score-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|User row exists (UrStoa UR_URV|IzAccount try-read pattern)."
        (let
            (
                (trial (try false (read FVT|T|RPS|User (UC_RpsUserKey user-id fvt-id score-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtRpsMemberRowExists:bool
        (fvt-id:string score-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|Member row exists."
        (let
            (
                (trial (try false (read FVT|T|RPS|Member (UC_RpsMemberKey fvt-id score-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_UserTier1AvailableRewards:decimal
        (user-id:string fvt-id:string score-id:string dptf-id:string deb-user:decimal)
        @doc "Internal: UrStoa URC_AvailableRewards — pending + floor(deb×(L_i−last_rps), reward DPTF decimals). \
            \ deb-user is pre-2.3 OLD SCR deb-score (BankUserTier1Pending reads before SCORE delta)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (current-pending:decimal (UR_FVT-RU|PendingRewards user-id fvt-id score-id dptf-id))
                (last-rps:decimal (UR_FVT-RU|LastRps user-id fvt-id score-id dptf-id))
                (L-i:decimal (UR_FVT-RM|MemberDebRps fvt-id score-id dptf-id))
                (reward-prec:integer (ref-DPTF::UR_Decimals dptf-id))
                (diff-rps:decimal (- L-i last-rps))
                (gained:decimal (floor (* deb-user diff-rps) reward-prec))
            )
            (+ current-pending gained)
        )
    )
    (defun URC_SettleScorePlanRows:[object{FVT|SettleScorePlan}]
        (settle-scores:[string] fvt-reward-bundle:[object{FVT|SettleFvtRewards}])
        @doc "Internal: per settle-score object{FVT|SettleScorePlan} — reward list from URD bundle, not URD."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            ;; map: settle-eligible employed scores → object{FVT|SettleScorePlan}
            (map
                (lambda (score-id:string)
                    (let
                        (
                            (fvt-id:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                        )
                        (UDC_FVT|SettleScorePlan
                            score-id
                            fvt-id
                            (URC_FvtRewardDptfIdsFromBundle fvt-id fvt-reward-bundle)
                        )
                    )
                )
                settle-scores
            )
        )
    )
    (defun URC_UserScoreTripleIsNonZero:bool (beneficiary-id:string pool-id:string score-id:string)
        @doc "Internal: true when SCR|T|UserScore base, boosted, or deb is > 0 for (beneficiary, pool, score)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (fold (or) false
                [
                    (> (ref-SCR::UR_U-SCR|UserScoreBaseScore beneficiary-id pool-id score-id) 0.0)
                    (> (ref-SCR::UR_U-SCR|UserScoreBoostedScore beneficiary-id pool-id score-id) 0.0)
                    (> (ref-SCR::UR_U-SCR|UserScoreDebScore beneficiary-id pool-id score-id) 0.0)
                ]
            )
        )
    )
    (defun URC_PreScoreWasNonZeroForScore:bool
        (pre-nz-flags:[object{FVT|ScorePreNzFlag}] score-id:string)
        @doc "Internal: lookup was-nz from pre-SCORE snapshot for one score-id."
        (fold (or) false
            (map
                (lambda (flag:object{FVT|ScorePreNzFlag})
                    (if (= (at "score-id" flag) score-id)
                        (at "was-nz" flag)
                        false
                    )
                )
                pre-nz-flags
            )
        )
    )
    (defun URC_BuildPreScoreNzFlags:[object{FVT|ScorePreNzFlag}]
        (beneficiary-id:string pool-id:string settle-plans:[object{FVT|SettleScorePlan}])
        @doc "Internal: snapshot was-nz per employed score before phase 2.3 SCORE mutation."
        (map
            (lambda (plan:object{FVT|SettleScorePlan})
                (UDC_FVT|ScorePreNzFlag
                    (at "score-id" plan)
                    (URC_UserScoreTripleIsNonZero beneficiary-id pool-id (at "score-id" plan))
                )
            )
            settle-plans
        )
    )
    (defun URC_StakeAnyPendingOnFvtRewardLine:bool
        (
            beneficiary-id:string
            fvt-id:string
            reward-dptf-id:string
            plans:[object{FVT|SettleScorePlan}]
        )
        @doc "Internal: true when user has pending-rewards > 0 on any employed score for (fvt, reward-dptf)."
        (fold (or) false
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (> (UR_FVT-RU|PendingRewards beneficiary-id fvt-id (at "score-id" plan) reward-dptf-id) 0.0)
                )
                plans
            )
        )
    )
    (defun URC_BuildStakeSettleBundle:object{FVT|StakeSettleBundle}
        (pool-id:string beneficiary-id:string)
        @doc "Internal: one URD_FVT|SettleFvtRewardBundle per C_*StakeFlow pass — reuse in phases 2.1, 2.35, and 2.4. \
            \ pre-nz-flags snapshot beneficiary nz state before SCORE."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (employed-ids:[string] (ref-AQP::URC_PoolActiveScoreIds pool-id))
                (settle-scores:[string] (URC_SettleEligibleEmployedScores employed-ids))
                (distinct-fvts:[string] (URC_SettleDistinctFvtLinks settle-scores))
                (fvt-reward-bundle:[object{FVT|SettleFvtRewards}] (URD_FVT|SettleFvtRewardBundle distinct-fvts))
                (settle-plans:[object{FVT|SettleScorePlan}] (URC_SettleScorePlanRows settle-scores fvt-reward-bundle))
                (pre-nz-flags:[object{FVT|ScorePreNzFlag}]
                    (URC_BuildPreScoreNzFlags beneficiary-id pool-id settle-plans)
                )
            )
            (UDC_FVT|StakeSettleBundle settle-scores distinct-fvts settle-plans pre-nz-flags)
        )
    )
    (defun URC_SettleStakePendingIgnis:decimal (settle-scores:[string] distinct-fvts:[string])
        @doc "Internal: phase 2.1 settle IGNIS from precomputed lists (C_*StakeFlow / URC_BuildStakeSettleBundle). \
            \ ignis|biggest × |settle-scores| + ignis|medium × Σ enabled-reward-count over distinct-fvts."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (medium:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (reward-tokens:integer
                    (fold (+) 0
                        ;; map: distinct FVT entities (sum enabled-reward-count for IGNIS medium leg)
                        (map
                            (lambda (fvt-id:string)
                                (try 0 (UR_FVT|EnabledRewardCount fvt-id))
                            )
                            distinct-fvts
                        )
                    )
                )
            )
            (+
                (* (dec (length settle-scores)) biggest)
                (* medium (dec reward-tokens))
            )
        )
    )
    ;; --- Phase 2.35 unclaimed · IGNIS ---
    (defun URC_BookStakeUnclaimedIgnis:decimal (distinct-fvts:[string])
        @doc "Internal: IGNIS for XI_BookStakeUnclaimedCounts — ignis|medium × |distinct-fvts|."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (* (ref-DALOS::UR_UsagePrice "ignis|medium") (dec (length distinct-fvts)))
        )
    )
    ;; --- Phase 2.4 checkpoint · IGNIS ---
    (defun URC_CheckpointStakeRpsIgnis:decimal ()
        @doc "Internal: IGNIS for XI_CheckpointStakeRps — flat 2 × ignis|biggest."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (* 2.0 (ref-DALOS::UR_UsagePrice "ignis|biggest"))
        )
    )
    ;;{F4}  [UEV]  (UEV_IMC lives under POLICY)
    (defun UEV_TrueFungibleStakeOwnerAccount (owner-id:string)
        @doc "Recipe cap: owner-id must be an activated Ouronet account (signer proof in AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists owner-id)
        )
    )
    (defun UEV_TrueFungibleStakeBeneficiaryAccount (beneficiary-id:string)
        @doc "Recipe cap: beneficiary must exist and be an activated standard (non-principal) Ouronet account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists beneficiary-id)
            (ref-DALOS::UEV_EnforceAccountType beneficiary-id false)
        )
    )
    (defun UEV_TrueFungibleStakeNotReserved (dptf-id:string)
        @doc "Recipe cap §4a: reject R| reserved leg — not covered by TFT::C_Transfer in phase 1."
        (enforce (not (= (take 2 dptf-id) "R|")) "Reserved DPTF (R|) cannot be staked")
    )
    ;;{F5}  [CAP]  (capabilities above FUNCTIONS — {C1}–{C4})
    ;;{F6}  [A]
    ;;{F7}  [C]
    ;; --- Lifecycle (FVT|T) ---
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
        @doc "Register reward dptf-id: insert FVT|T|RPS|Global with reward-enabled true and zeroed rps fields; row key permanent. \
            \ XI: increment FVT|T.enabled-reward-count by 1."
        true
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Toggle FVT|T|RPS|Global.reward-enabled for (fvt-id, reward-dptf-id); off disables inject/collect for that token. \
            \ XI: increment enabled-reward-count when false→true, decrement when true→false."
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
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; UrStoa canonical stake/unstake — phased model (00_StoaSandbox/coin.pact)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; PHASE 1 — Custody (AQP-POOL): move assets + record trackers before RPS/SCORE.
    ;;   1.1 Transfer asset user↔vault           UrStoa ≡ X_UR|Transfer
    ;;   1.2 Per-pool tracker row                 UrStoa ≡ N/A (implicit single vault)
    ;;   1.3 Cross-pool beneficiary rollup        UrStoa ≡ N/A (TF / DPTF ANK only)
    ;;
    ;; PHASE 2 — FVT RPS prelude (at OLD deb/L_i, before SCORE mutation):
    ;;   2.1 Ghost TVL sync (farm Tier-2)         UrStoa ≡ N/A
    ;;   2.2 Ensure RPS Member + User rows        UrStoa ≡ insert UrStoaVaultUser if !IzAccount
    ;;   2.3 Bank pending at OLD deb × ΔL_i       UrStoa ≡ XI_URV|UpdatePendingRewards
    ;;
    ;; PHASE 3 — Anchors (AQP-ANK promile refresh after custody, before SCORE):
    ;;   3.1 DPTF anchor refresh                  UrStoa ≡ N/A (TF flow only)
    ;;   3.2 DPSF anchor refresh                  UrStoa ≡ N/A (DPDC son=true only)
    ;;   3.3 DPNF anchor refresh                  UrStoa ≡ N/A (DPDC son=false only)
    ;;
    ;; PHASE 4 — SCORE weight mutation:
    ;;   4.1 Vault aggregate totals               UrStoa ≡ XI_URV|UpdateVaultScore
    ;;   4.2 User base/boosted/deb triple         UrStoa ≡ XI_URV|UpdateUserScore
    ;;   4.3 NZS count delta                      UrStoa ≡ XI_URV|UpdateNZS
    ;;
    ;; PHASE 5 — FVT RPS post-SCORE (after nz state known):
    ;;   5.1 Global unclaimed-count               UrStoa ≡ XI_URV|UpdateUnclaimedCount
    ;;   5.2 Advance user last-rps to NEW L_i     UrStoa ≡ XI_URV|UpdateUserRPS
    ;;
    ;; Flow slots: TF=1.1–1.3,3.1 | OF=1.1–1.2 + 1.3/3.x no-op | DPDC=1.1–1.2 + 3.2 or 3.3
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; --- TF stake/unstake recipe (Talos client → C_TrueFungibleStakeFlow) ---
    (defun C_TrueFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Core TF stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above."
        (UEV_IMC)
        (with-capability (FVT|C>TRUE-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dptf-id amount direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URC_BuildStakeSettleBundle pool-id beneficiary-id)
                    )
                    ;; PHASE 1 — Custody
                    (step-1-1:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::XE_Phase_1_1|TrueFungibleTransfer pool-id owner-id beneficiary-id dptf-id amount direction)
                    )
                    (step-1-2:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::XE_Phase_1_2|TrueFungiblePoolTracker pool-id owner-id beneficiary-id dptf-id amount direction)
                    )
                    (step-1-3:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::XE_Phase_1_3|TrueFungibleBeneficiaryRollup pool-id owner-id beneficiary-id dptf-id amount direction)
                    )
                    ;; PHASE 2 — FVT RPS prelude (OLD deb)
                    (step-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_2|RpsPreScore beneficiary-id pool-id settle-bundle)
                    )
                    ;; PHASE 3 — Anchors (TF: 3.1 only; 3.2/3.3 reserved no-op)
                    (step-3-1:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_1|RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
                    )
                    (step-3-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_2|NoOpSemiFungibleAnchors)
                    )
                    (step-3-3:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_3|NoOpNonFungibleAnchors)
                    )
                    ;; PHASE 4 — SCORE
                    (step-4:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SCR::XE_ApplyTrueFungibleStakeDelta
                            pool-id beneficiary-id dptf-id amount direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                            (ref-AQP::URC_DptfStakeIsNativeLeg dptf-id)
                        )
                    )
                    ;; PHASE 5 — FVT RPS post-SCORE
                    (step-5-1:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_5_1|BookUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    )
                    (step-5-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_5_2|CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [step-1-1 step-1-2 step-1-3 step-2 step-3-1 step-3-2 step-3-3 step-4 step-5-1 step-5-2]
                    []
                )
            )
        )
    )
    ;;
    ;; --- OF stake/unstake recipe (Talos ×4 → C_OrtoFungibleStakeFlow) ---
    ;;   No phase 2.2 — ANK anchors are DPTF / DPSF / DPNF only; OF custody does not refresh promile.
    (defun C_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Core OrtoFungible stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ OF: phase 1.3 and 3.1–3.3 are reserved no-op slots."
        (UEV_IMC)
        (with-capability (FVT|C>ORTO-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    (settle-beneficiary:string
                        (if direction
                            beneficiary-id
                            (ref-AQP::URC_OrtoUnstakeBeneficiaryId pool-id dpof-id owner-id (at 0 nonces))
                        )
                    )
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URC_BuildStakeSettleBundle pool-id settle-beneficiary)
                    )
                    ;; PHASE 1 — Custody
                    (step-1-1:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::XE_Phase_1_1|OrtoFungibleTransfer
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                    )
                    (step-1-2:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::XE_Phase_1_2|OrtoFungiblePoolTracker
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                    )
                    (step-1-3:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_1_3|NoOpBeneficiaryRollup)
                    )
                    ;; PHASE 2 — FVT RPS prelude
                    (step-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_2|RpsPreScore settle-beneficiary pool-id settle-bundle)
                    )
                    ;; PHASE 3 — Anchors (all no-op for OF)
                    (step-3-1:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_1|NoOpTrueFungibleAnchors)
                    )
                    (step-3-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_2|NoOpSemiFungibleAnchors)
                    )
                    (step-3-3:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_3_3|NoOpNonFungibleAnchors)
                    )
                    ;; PHASE 4 — SCORE
                    (step-4:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SCR::XE_ApplyOrtoFungibleStakeDelta
                            pool-id settle-beneficiary dpof-id nonces nonce-amounts direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        )
                    )
                    ;; PHASE 5 — FVT RPS post-SCORE
                    (step-5-1:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_5_1|BookUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                    )
                    (step-5-2:object{IgnisCollectorV1.OutputCumulator}
                        (XI_Phase_5_2|CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [step-1-1 step-1-2 step-1-3 step-2 step-3-1 step-3-2 step-3-3 step-4 step-5-1 step-5-2]
                    []
                )
            )
        )
    )
    ;;
    ;;ACTIONS  (Farm class 0 — two-tier RPS; see README_FVT.md Ghost TVL + Execution order)
    ;;
    ;;1]INJECT Rewards (farm: require total-ghost-tvl-weight S > 0)
    ;;  1a] Tier-2: current-rps (G) += reward-amount / S
    ;;  1b] Update <available-rewards> = (+ <available-rewards> <reward-amount>)
    ;;  1c] Update <unclaimed-count> = <nzs-count> (aggregate across members; semantics TBD)
    ;;
    ;;2]STAKE / UNSTAKE (per beneficiary, per employed member score, per reward DPTF)
    ;;  UrStoa XI_URV|UpdatePendingRewards ≡ phase 2.1 only (bank pending at OLD indices).
    ;;  LP vs non-LP: phase 1 custody + phase 2.3 SCORE dispatch differ by score-class;
    ;;  phase 2.1 settle is the same Tier-1 deb×(L_i−last_rps) for every employed score with fvt-link≠BAR.
    ;;  Tier-2 (farm class-0 FVT only) splits injections across member scores by ghost TVL weight W_i.
    ;;  2.0] Ensure FVT|T|RPS|User row (UrStoa: insert user with last-rps=current index if absent)
    ;;  2a] Tier-2: farm class-0 earned = floor(W_i×(G−g_i), 48); vault/treasury earned = floor(D_i×(G−g_i), 48);
    ;;       if total-deb > 0: L_i += floor(earned/total-deb, 48); flush pending-member-rewards into L_i when deb appears;
    ;;       else pending-member-rewards += floor(earned, reward DPTF decimals); g_i := G
    ;;  2b] Tier-1: pending-rewards += deb_user×(L_i−last_rps_user) — read deb_user from SCORE (OLD, pre-2.3)
    ;;       do NOT advance last-rps here (UrStoa UpdateUserRPS ≡ phase 2.4 XI_CheckpointStakeRps)
    ;;  2c] SCORE stake path updates user deb / score totals — phase 2.3 XE_ApplyTrueFungibleStakeDelta
    ;;  2d] nz / unclaimed bookkeeping — phase 2.35 XI_BookStakeUnclaimedCounts (after SCORE; UrStoa UpdateNZS is in SCORE nzs-count)
    ;;  2e] last-rps_user := L_i — phase 2.4 only (after NEW deb is known if needed)
    ;;
    ;;3]UNSTAKE — same settle order as STAKE (2a then 2b before mutating deb)
    ;;
    ;;4]COLLECT
    ;;  4a] Repeat 2a (member Tier-2 settle) then 2b with current deb for reward line
    ;;  4b] Decrement available-rewards by payout
    ;;  4c] Dust / last-claimer rule on available-rewards vs pending
    ;;  4d-4f] pending and unclaimed-count updates; last-rps_user := L_i
    ;;
    ;;5]SWP / AQP — SWP|Pairs.stoa-value updated by TS01 swap/liquidity txs (no FVT call from SWP).
    ;;  FVT lazy-sync on reward entry (C_AddScoreLink, C_Inject, XI_SettleStakePendingRewards phase-2 entry, C_Collect):
    ;;  read SWP::UR_StoaValue via ScoreLink.swpair; if W_live ≠ W_cached settle Tier-2 at old W_i; write W_i; fix S.
    ;;
    ;;{F8}  [X]
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* (depth 1) → XI_2|* (depth 2) … Blocks: map first, functions in map order.
    ;;
    ;; --- Block A · Phase 2.1 settle (C_TrueFungibleStakeFlow) ---
    ;;   XI_SettleStakePendingRewards
    ;;     ├ XI_1|SyncFarmGhostTvlForEmployedScores
    ;;     │    └ (map) → XI_2|SettleMemberTier2
    ;;     └ XI_1|SettleOneEmployedScorePendingRewards
    ;;          └ (map) → XI_2|EnsureRpsMemberRow, XI_2|EnsureRpsUserRow,
    ;;                      XI_2|SettleMemberTier2, XI_2|BankUserTier1Pending
    ;;
    ;; --- Block C · Phase 2.4 checkpoint (C_TrueFungibleStakeFlow) ---
    ;;   XI_CheckpointStakeRps — nested map (score plan × reward line); no child XI_*.
    ;;
    ;; --- PHASE 2 · FVT RPS prelude (UrStoa 2.1 at OLD deb) ---
    ;;   XI_Phase_2|RpsPreScore — orchestrator: 2.1 → 2.2 → 2.3
    ;;
    (defun URC_StakeFlowPhaseNoOpIgnis:object{IgnisCollectorV1.OutputCumulator} (phase-tag:string)
        @doc "Internal: zero IGNIS for reserved phase slots (N/A on this flow)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 AQP|SC_NAME trigger [phase-tag])
        )
    )
    (defun XI_Phase_1_3|NoOpBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Phase 1.3 reserved — N/A for OF (no AQP|T|BeneficiaryDptfTotal on DPOF leg)."
        (require-capability (SECURE))
        (URC_StakeFlowPhaseNoOpIgnis "phase-1.3-na")
    )
    (defun XI_Phase_3_1|NoOpTrueFungibleAnchors:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Phase 3.1 reserved — N/A for OF (DPOF has no DPTF anchors)."
        (require-capability (SECURE))
        (URC_StakeFlowPhaseNoOpIgnis "phase-3.1-na")
    )
    (defun XI_Phase_3_2|NoOpSemiFungibleAnchors:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Phase 3.2 reserved — N/A for TF/OF; DPDC son=true will wire DPSF anchor refresh."
        (require-capability (SECURE))
        (URC_StakeFlowPhaseNoOpIgnis "phase-3.2-na")
    )
    (defun XI_Phase_3_3|NoOpNonFungibleAnchors:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Phase 3.3 reserved — N/A for TF/OF; DPDC son=false will wire DPNF anchor refresh."
        (require-capability (SECURE))
        (URC_StakeFlowPhaseNoOpIgnis "phase-3.3-na")
    )
    (defun XI_Phase_2|RpsPreScore:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "PHASE 2 orchestrator — FVT RPS at OLD score: 2.1 ghost TVL → 2.2 ensure rows → 2.3 bank pending."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (settle-scores:[string] (at "settle-scores" settle-bundle))
                (distinct-fvts:[string] (at "distinct-fvts" settle-bundle))
                (settle-plans:[object{FVT|SettleScorePlan}] (at "settle-plans" settle-bundle))
            )
            (XI_Phase_2_1|SyncFarmGhostTvl settle-plans)
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (XI_Phase_2_2|EnsureScoreRewardRows beneficiary-id plan)
                )
                settle-plans
            )
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (XI_Phase_2_3|BankScorePendingRewards beneficiary-id pool-id plan)
                )
                settle-plans
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_SettleStakePendingIgnis settle-scores distinct-fvts)
                AQP|SC_NAME
                trigger
                [pool-id "phase-2-rps-prelude"]
            )
        )
    )
    (defun XI_Phase_2_1|SyncFarmGhostTvl
        (score-plans:[object{FVT|SettleScorePlan}])
        @doc "Phase 2.1 — UrStoa ≡ N/A. Farm Tier-2 ghost-TVL reconcile before pending bank."
        (XI_1|SyncFarmGhostTvlForEmployedScores score-plans)
    )
    (defun XI_Phase_2_2|EnsureScoreRewardRows
        (beneficiary-id:string plan:object{FVT|SettleScorePlan})
        @doc "Phase 2.2 — UrStoa ≡ insert UrStoaVaultUser when account absent (IzAccount false)."
        (require-capability (SECURE))
        (let
            (
                (fvt-id:string (at "fvt-id" plan))
                (score-id:string (at "score-id" plan))
                (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
            )
            (map
                (lambda (reward-dptf-id:string)
                    (if (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id)
                        (do
                            (XI_2|EnsureRpsMemberRow fvt-id score-id reward-dptf-id)
                            (XI_2|EnsureRpsUserRow beneficiary-id fvt-id score-id reward-dptf-id)
                        )
                        true
                    )
                )
                reward-dptf-ids
            )
        )
    )
    (defun XI_Phase_2_3|BankScorePendingRewards
        (beneficiary-id:string pool-id:string plan:object{FVT|SettleScorePlan})
        @doc "Phase 2.3 — UrStoa ≡ XI_URV|UpdatePendingRewards (bank at OLD deb × ΔL_i)."
        (require-capability (SECURE))
        (let
            (
                (score-id:string (at "score-id" plan))
                (fvt-id:string (at "fvt-id" plan))
                (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
            )
            (map
                (lambda (reward-dptf-id:string)
                    (if (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id)
                        (do
                            (XI_2|SettleMemberTier2 fvt-id score-id reward-dptf-id)
                            (XI_2|BankUserTier1Pending beneficiary-id pool-id fvt-id score-id reward-dptf-id)
                        )
                        true
                    )
                )
                reward-dptf-ids
            )
        )
    )
    (defun XI_1|SyncFarmGhostTvlForEmployedScores
        (score-plans:[object{FVT|SettleScorePlan}])
        @doc "Internal (phase 2.1 · depth 1]): SWP→FVT ghost-tvl reconcile per object{FVT|SettleScorePlan} (≤7). \
            \ Caller builds plans once with reward-dptf-ids from a single URD_FVT|SettleFvtRewardBundle — no URD in child XI. \
            \ Per row: read SWP::UR_StoaValue via swpair; if W_live ≠ W_cached settle Tier-2 at old W_i, \
            \ write ghost-tvl-weight, adjust FVT|T.total-ghost-tvl-weight. \
            \ C_AddScoreLink / C_Inject / C_Collect: same pattern at call site."
        (require-capability (SECURE))
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            ;; map: employed score plans (farm ghost-TVL reconcile per score × FVT link)
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (let
                        (
                            (score-id:string (at "score-id" plan))
                            (fvt-id:string (at "fvt-id" plan))
                            (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
                        )
                        (if
                            (fold (and) true
                                [
                                    (!= score-id BAR)
                                    (!= fvt-id BAR)
                                    (= (UR_FVT|FvtClass fvt-id) 0)
                                    (UR_FVT-SL|Enabled fvt-id score-id)
                                ]
                            )
                            (let
                                (
                                    (swpair:string (UR_FVT-SL|Swpair fvt-id score-id))
                                    (W-live:decimal (ref-SWP::UR_StoaValue swpair))
                                    (W-cached:decimal (UR_FVT-SL|GhostTvlWeight fvt-id score-id))
                                )
                                (if (= W-live W-cached)
                                    true
                                    (let
                                        (
                                            (sl-key:string (UC_ScoreLinkKey fvt-id score-id))
                                            (delta-W:decimal (- W-live W-cached))
                                            (S:decimal (UR_FVT|TotalGhostTvlWeight fvt-id))
                                        )
                                        (map
                                            (lambda (reward-dptf-id:string)
                                                (XI_2|SettleMemberTier2 fvt-id score-id reward-dptf-id)
                                            )
                                            reward-dptf-ids
                                        )
                                        (update FVT|T|ScoreLink sl-key {"ghost-tvl-weight": W-live})
                                        (update FVT|T fvt-id {"total-ghost-tvl-weight": (+ S delta-W)})
                                        true
                                    )
                                )
                            )
                            true
                        )
                    )
                )
                score-plans
            )
            true
        )
    )
    (defun XI_1|SettleOneEmployedScorePendingRewards
        (beneficiary-id:string pool-id:string plan:object{FVT|SettleScorePlan})
        @doc "Legacy 2.x single-pass. Prefer XI_Phase_2|RpsPreScore."
        (require-capability (SECURE))
        (XI_Phase_2_2|EnsureScoreRewardRows beneficiary-id plan)
        (XI_Phase_2_3|BankScorePendingRewards beneficiary-id pool-id plan)
    )
    (defun XI_2|EnsureRpsMemberRow
        (fvt-id:string score-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2.0]): ensure FVT|T|RPS|Member row for (fvt, score, reward DPTF); insert when absent."
        (require-capability (SECURE))
        (if (not (URC_FvtRpsMemberRowExists fvt-id score-id reward-dptf-id))
            (insert FVT|T|RPS|Member (UC_RpsMemberKey fvt-id score-id reward-dptf-id)
                (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-id reward-dptf-id)
            )
            true
        )
    )
    (defun XI_2|EnsureRpsUserRow
        (beneficiary-id:string fvt-id:string score-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2.0]): ensure FVT|T|RPS|User row; insert with last-rps=L_i when absent (UrStoa IzAccount)."
        (require-capability (SECURE))
        (if (not (URC_FvtRpsUserRowExists beneficiary-id fvt-id score-id reward-dptf-id))
            (insert FVT|T|RPS|User (UC_RpsUserKey beneficiary-id fvt-id score-id reward-dptf-id)
                (UDC_FVT|RPS|User
                    (UR_FVT-RM|MemberDebRps fvt-id score-id reward-dptf-id)
                    0.0
                    beneficiary-id
                    fvt-id
                    score-id
                    reward-dptf-id
                )
            )
            true
        )
    )
    (defun XI_2|SettleMemberTier2
        (fvt-id:string score-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2a]): Tier-2 settle per reward DPTF on FVT|T|RPS|Member. \
            \ Farm: floor(W_i×(G−g_i), 48). Vault/Treasury: floor(D_i×(G−g_i), 48). Flush pending-member-rewards when deb > 0."
        (require-capability (SECURE))
        (XI_2|EnsureRpsMemberRow fvt-id score-id reward-dptf-id)
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (rm-key:string (UC_RpsMemberKey fvt-id score-id reward-dptf-id))
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                (G:decimal (UR_FVT-RG|CurrentRps fvt-id reward-dptf-id))
                (g-i:decimal (UR_FVT-RM|LastFarmRpsG fvt-id score-id reward-dptf-id))
                (total-deb:decimal (ref-SCR::UR_SCR|ScoreTotalDebScore score-id))
                (L-i:decimal (UR_FVT-RM|MemberDebRps fvt-id score-id reward-dptf-id))
                (ptr:decimal (UR_FVT-RM|PendingMemberRewards fvt-id score-id reward-dptf-id))
                (reward-prec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
                (L-i-work:decimal
                    (if (and (> total-deb 0.0) (> ptr 0.0))
                        (+ L-i (floor (/ ptr total-deb) CT_FVT_RPS_PREC))
                        L-i
                    )
                )
                (ptr-work:decimal
                    (if (and (> total-deb 0.0) (> ptr 0.0)) 0.0 ptr)
                )
                (rm:object{FVT|RPS|Member} (UR_FVT-RM|RpsMember fvt-id score-id reward-dptf-id))
            )
            (if (= G g-i)
                (if (and (> total-deb 0.0) (> ptr 0.0))
                    (update FVT|T|RPS|Member rm-key
                        (+ rm {"member-deb-rps": L-i-work, "pending-member-rewards": ptr-work})
                    )
                    true
                )
                (let
                    (
                        (weight:decimal
                            (if (= fvt-class 0)
                                (UR_FVT-SL|GhostTvlWeight fvt-id score-id)
                                total-deb
                            )
                        )
                        (earned:decimal (floor (* weight (- G g-i)) CT_FVT_RPS_PREC))
                    )
                    (if (> total-deb 0.0)
                        (update FVT|T|RPS|Member rm-key
                            (+ rm
                                {"member-deb-rps"         : (+ L-i-work (floor (/ earned total-deb) CT_FVT_RPS_PREC))
                                ,"last-farm-rps-g"        : G
                                ,"pending-member-rewards" : ptr-work}
                            )
                        )
                        (if (> earned 0.0)
                            (update FVT|T|RPS|Member rm-key
                                (+ rm
                                    {"pending-member-rewards" : (floor (+ ptr-work earned) reward-prec)
                                    ,"last-farm-rps-g"        : G}
                                )
                            )
                            (update FVT|T|RPS|Member rm-key
                                (+ rm {"last-farm-rps-g": G})
                            )
                        )
                    )
                )
            )
        )
    )
    (defun XI_2|BankUserTier1Pending
        (beneficiary-id:string pool-id:string fvt-id:string score-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2b]): bank user pending at OLD deb — UrStoa XI_URV|UpdatePendingRewards. \
            \ Does not advance last-rps (phase 2.4 XI_CheckpointStakeRps)."
        (require-capability (SECURE))
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (deb-old:decimal (ref-SCR::UR_U-SCR|UserScoreDebScore beneficiary-id pool-id score-id))
                (new-pending:decimal (URC_UserTier1AvailableRewards beneficiary-id fvt-id score-id reward-dptf-id deb-old))
                (ru:object{FVT|RPS|User} (UR_FVT-RU|RpsUser beneficiary-id fvt-id score-id reward-dptf-id))
            )
            (update FVT|T|RPS|User (UC_RpsUserKey beneficiary-id fvt-id score-id reward-dptf-id)
                (+ ru {"pending-rewards": new-pending})
            )
            true
        )
    )
    ;;
    ;; --- Block B · Phase 2.2 anchor refresh (C_TrueFungibleStakeFlow only) ---
    ;;   XI_RefreshTrueFungibleStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ AQP-POOL::XE_SetBeneficiaryDptfAnkSyncCount
    ;;
    ;; --- PHASE 3 · Anchors (AQP-ANK) ---
    (defun XI_Phase_3_1|RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Phase 3.1 — UrStoa ≡ N/A. TF: backward DPTF anchor promile refresh from rollup."
        (XI_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
    )
    (defun XI_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Internal (C_TrueFungibleStakeFlow phase 2.2 · depth 0]): read post-ico1 BeneficiaryDptfTotal balance, \
            \ call backward ANK promile refresh + AQP last-ank-sync-count bump; concat IGNIS OCs. \
            \ require-capability (SECURE) only — backward XE_* use UEV_IMC / domain caps."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (total-dptf-amount:decimal (ref-AQP::UR_AQP|BeneficiaryDptfTotalBalance beneficiary-id dptf-id))
                (ico-ank:object{IgnisCollectorV1.OutputCumulator}
                    (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues beneficiary-id dptf-id total-dptf-amount)
                )
                (ico-aqp:object{IgnisCollectorV1.OutputCumulator}
                    (ref-AQP::XE_SetBeneficiaryDptfAnkSyncCount beneficiary-id dptf-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-aqp] [])
        )
    )
    ;;
    ;; --- Block B · Phase 2.35 unclaimed (C_*StakeFlow) ---
    ;;   XI_BookStakeUnclaimedCounts — map distinct-fvts × reward lines; child XI_2|BumpRpsGlobalUnclaimed.
    ;;
    (defun XI_2|BumpRpsGlobalUnclaimed
        (fvt-id:string reward-dptf-id:string direction:bool)
        @doc "Internal (phase 2.35 · depth 2]): increment/decrement FVT|T|RPS|Global.unclaimed-count (UrStoa XI_URV|UpdateUnclaimedCount)."
        (let
            (
                (old-uc:integer (UR_FVT-RG|UnclaimedCount fvt-id reward-dptf-id))
                (new-uc:integer
                    (if direction
                        (+ old-uc 1)
                        (if (> old-uc 0) (- old-uc 1) 0)
                    )
                )
            )
            (update FVT|T|RPS|Global (UC_RpsGlobalKey fvt-id reward-dptf-id)
                {"unclaimed-count": new-uc}
            )
        )
    )
    (defun XI_1|BookUnclaimedForFvtRewardLine
        (
            beneficiary-id:string
            pool-id:string
            fvt-id:string
            reward-dptf-id:string
            plans:[object{FVT|SettleScorePlan}]
            pre-nz-flags:[object{FVT|ScorePreNzFlag}]
        )
        @doc "Internal (phase 2.35 · depth 1]): one (fvt, reward-dptf) unclaimed transition — OR was/is across pool employed scores on that fvt."
        (let
            (
                (was-claimant:bool
                    (fold (or) false
                        (map
                            (lambda (plan:object{FVT|SettleScorePlan})
                                (URC_PreScoreWasNonZeroForScore pre-nz-flags (at "score-id" plan))
                            )
                            plans
                        )
                    )
                )
                (is-claimant:bool
                    (fold (or) false
                        (map
                            (lambda (plan:object{FVT|SettleScorePlan})
                                (URC_UserScoreTripleIsNonZero beneficiary-id pool-id (at "score-id" plan))
                            )
                            plans
                        )
                    )
                )
                (any-pending:bool
                    (URC_StakeAnyPendingOnFvtRewardLine beneficiary-id fvt-id reward-dptf-id plans)
                )
            )
            (if (and (not was-claimant) is-claimant)
                (XI_2|BumpRpsGlobalUnclaimed fvt-id reward-dptf-id true)
                (if (and was-claimant (not is-claimant))
                    (if (not any-pending)
                        (XI_2|BumpRpsGlobalUnclaimed fvt-id reward-dptf-id false)
                        true
                    )
                    true
                )
            )
        )
    )
    ;; --- PHASE 5 · FVT RPS post-SCORE (UrStoa 2.3 unclaimed + 2.4 checkpoint) ---
    (defun XI_Phase_5_1|BookUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Phase 5.1 — UrStoa ≡ XI_URV|UpdateUnclaimedCount (after SCORE phase 4.3 NZS)."
        (XI_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
    )
    (defun XI_BookStakeUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Internal (C_*StakeFlow phase 2.35 · depth 0]): RPS|Global unclaimed-count after SCORE (UrStoa XI_URV|UpdateUnclaimedCount). \
            \ Once per (fvt-id, reward-dptf-id) per tx — OR was/is claimant across employed scores on that fvt in this pool. \
            \ Decrement only when user leaves claimant set and has no pending on that reward line. \
            \ IGNIS interactor = AQP|SC_NAME."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (distinct-fvts:[string] (at "distinct-fvts" settle-bundle))
                (settle-plans:[object{FVT|SettleScorePlan}] (at "settle-plans" settle-bundle))
                (pre-nz-flags:[object{FVT|ScorePreNzFlag}] (at "pre-nz-flags" settle-bundle))
            )
            ;; map: distinct FVT entities — one unclaimed pass per fvt × enabled reward lines
            (map
                (lambda (fvt-id:string)
                    (let
                        (
                            (plans:[object{FVT|SettleScorePlan}]
                                (filter
                                    (lambda (plan:object{FVT|SettleScorePlan})
                                        (= (at "fvt-id" plan) fvt-id)
                                    )
                                    settle-plans
                                )
                            )
                            (reward-dptf-ids:[string] (at "reward-dptf-ids" (at 0 plans)))
                        )
                        (map
                            (lambda (reward-dptf-id:string)
                                (XI_1|BookUnclaimedForFvtRewardLine
                                    beneficiary-id pool-id fvt-id reward-dptf-id plans pre-nz-flags
                                )
                            )
                            reward-dptf-ids
                        )
                    )
                )
                distinct-fvts
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_BookStakeUnclaimedIgnis distinct-fvts)
                AQP|SC_NAME
                trigger
                [pool-id beneficiary-id "book-unclaimed"]
            )
        )
    )
    ;;
    ;; --- Block C · Phase 2.4 checkpoint (C_TrueFungibleStakeFlow) ---
    ;;   XI_CheckpointStakeRps — nested map (score plan × reward line); no child XI_*.
    ;;
    (defun XI_Phase_5_2|CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Phase 5.2 — UrStoa ≡ XI_URV|UpdateUserRPS (advance last-rps to NEW L_i)."
        (XI_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
    )
    (defun XI_CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Internal (C_*StakeFlow phase 2.4 · depth 0]): advance last-rps to NEW L_i after SCORE deb mutation (UrStoa XI_URV|UpdateUserRPS). \
            \ settle-bundle from URC_BuildStakeSettleBundle (same scope as phase 2.1; no second URD). \
            \ Only existing FVT|T|RPS|User rows are updated. \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver). Returns checkpoint IGNIS OC."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (checkpoint-plans:[object{FVT|SettleScorePlan}] (at "settle-plans" settle-bundle))
            )
            ;; map: employed score plans (same scope as phase 2.1 settle)
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (let
                        (
                            (fvt-id:string (at "fvt-id" plan))
                            (score-id:string (at "score-id" plan))
                            (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
                        )
                        ;; map: reward DPTF lines — advance last-rps to NEW L_i on existing user rows only
                        (map
                            (lambda (reward-dptf-id:string)
                                (if (URC_FvtRpsUserRowExists beneficiary-id fvt-id score-id reward-dptf-id)
                                    (let
                                        (
                                            (ru:object{FVT|RPS|User}
                                                (UR_FVT-RU|RpsUser beneficiary-id fvt-id score-id reward-dptf-id)
                                            )
                                            (new-lr:decimal
                                                (UR_FVT-RM|MemberDebRps fvt-id score-id reward-dptf-id)
                                            )
                                        )
                                        (update FVT|T|RPS|User (UC_RpsUserKey beneficiary-id fvt-id score-id reward-dptf-id)
                                            (+ ru {"last-rps": new-lr})
                                        )
                                    )
                                    true
                                )
                            )
                            reward-dptf-ids
                        )
                    )
                )
                checkpoint-plans
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_CheckpointStakeRpsIgnis)
                AQP|SC_NAME
                trigger
                [pool-id beneficiary-id]
            )
        )
    )
    ;;
    ;; --- REPL dry-run (GOV|FVT_ADMIN; not on AcquisitionFarmsVaultsTreasuriesV1) ---
    ;; Until C_Issue / C_AddScoreLink / C_AddRewardLink are implemented.
    (defun REPL_BootstrapVault:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-1 vault + enabled ScoreLink + reward-enabled RPS|Global; SCR XE_CreateFvtLink."
        (with-capability (GOV|FVT_ADMIN)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (insert FVT|T fvt-id
                    (UDC_FVT|Schema 1 owner-konto true true "|" 0.0 0.0 0.0 0.0 0 1 fvt-id)
                )
                (insert FVT|T|ScoreLink (UC_ScoreLinkKey fvt-id score-id)
                    (UDC_FVT|ScoreLink true "|" 0.0 fvt-id score-id)
                )
                (insert FVT|T|RPS|Global (UC_RpsGlobalKey fvt-id reward-dptf-id)
                    (UDC_FVT|RPS|Global true 0.0 0.0 0 false fvt-id reward-dptf-id)
                )
                (with-capability (SECURE)
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                (enforce
                    (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapVault: SCR fvt-link not set after XE_CreateFvtLink"
                )
            )
        )
        fvt-id
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table FVT|T)                                            ;; Key = <FVT-ID>
(create-table FVT|T|ScoreLink)                                  ;; Key = <FVT-ID> | <Score-ID>
(create-table FVT|T|RPS|Global)                                ;; Key = <FVT-ID> | <DPTF-ID>
(create-table FVT|T|RPS|Member)                                ;; Key = <FVT-ID> | <Score-ID> | <DPTF-ID>
(create-table FVT|T|RPS|User)                                   ;; Key = <Ouronet-Account> | <FVT-ID> | <Score-ID> | <DPTF-ID>