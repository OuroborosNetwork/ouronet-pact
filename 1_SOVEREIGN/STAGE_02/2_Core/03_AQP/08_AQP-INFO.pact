;; ================================================================================
;; AQP-INFO — pre-execution COST PREVIEW surface for the AQP modules.
;;
;; Each AQP-<MOD>|INFO_<Fn> is the read-only counterpart of a TS02-C3 execution
;; wrapper. It returns object{OuronetInfoV1.ClientInfo} describing what the op does,
;; which execution function runs it, and the EXACT IGNIS + STOA price for a given
;; account (mirroring the execution's own cost logic byte-for-byte — same GAS| const,
;; same UsagePrice tier, same multipliers/branches, same zero-gas toggle gate).
;;
;; Procedure: OuronetInformational/skills/aqp-info-module-procedure.md
;; Surface  : OuronetInformational/skills/aqp-entrypoint-surface.md
;; Deploys AFTER 01_ANK..07_DSA + TS02-C3 (reads their state + GAS| constants; never writes).
;; No interface: this is a leaf read-only preview module — nothing references it via module{}.
;; ================================================================================
(module AQP-INFO GOV
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO|AQP       (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|INFO|AQP_ADMIN)))
    (defcap GOV|INFO|AQP_ADMIN ()   (enforce-guard GOV|MD_INFO|AQP))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    ;;{P3}
    ;;{P4}
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]  — gas-price gate (mirrors INFO-ONE UC|GasPrice: zero when the toggle is off)
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool)
        @doc "Full price when live billing is on (trigger=false); 0.0 when the gas toggle zeroes it."
        (if trigger 0.0 full-price)
    )
    ;;{F1}  [SIP|URC]  — Simple Ignis Price: one named UsagePrice tier behind the virtual-gas gate
    (defun SIP|URC_Small:decimal ()
        @doc "IGNIS tier 'ignis|small' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|small") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Medium:decimal ()
        @doc "IGNIS tier 'ignis|medium' behind the virtual-gas toggle (score/FVT rotate & control, enable-deb-boost)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|medium") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Big:decimal ()
        @doc "IGNIS tier 'ignis|big' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|big") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Biggest:decimal ()
        @doc "IGNIS tier 'ignis|biggest' behind the virtual-gas toggle (anchor/boost-class revokes, score boost-links)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|biggest") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Fixed:decimal (gas-cost:decimal)
        @doc "A FIXED GAS| constant (read cross-module from the executing core) behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS))
            (UC|GasPrice gas-cost (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    ;;{F2}  [SKP|URC]  — Simple Stoa Price: a native UsagePrice charge behind the native-gas gate
    (defun SKP|URC_Standard:decimal (multiplier:decimal)
        @doc "Native STOA 'standard' × multiplier behind the native-gas toggle (anchor issue: mult 2 when acnoi)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (* (ref-DALOS::UR_UsagePrice "standard") multiplier) (ref-IGNIS::URC_IsNativeGasZero)))
    )
    (defun SKP|URC_Smart:decimal ()
        @doc "Native STOA 'smart' behind the native-gas toggle (score/pool/FVT issue)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "smart") (ref-IGNIS::URC_IsNativeGasZero)))
    )
    ;;{F2.5} [URC]  — multi-leg stake/unstake flow IFP reconstructors (mirror CC_*StakeFlow byte-for-byte).
    ;;              Each leg is summed already gated by the virtual-gas toggle (SIP|URC_*), so the sum is
    ;;              the toggled total (toggle-on → every leg 0 → 0). Leg map: memories/2026-08-27-aqp-info-final17-costmap.md
    (defun URC_StakeScoreDeltaSum:decimal (pool-id:string)
        @doc "Phase-4 leg: Σ SCORE.URC_StakeScoreDeltaIgnisUnit over POOL.URC_PoolActiveScoreIds (raw, ungated)."
        (fold (+) 0.0
            (map (lambda (sid:string) (AQP-SCORE.URC_StakeScoreDeltaIgnisUnit sid))
                 (AQP-POOL.URC_PoolActiveScoreIds pool-id)))
    )
    (defun URC_TrueFungibleStakeFlowIfp:decimal
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Toggled total IGNIS IFP of CC_TrueFungibleStakeFlow (04_FVT.pact:6412). Legs: transfer + tracker \
            \ + rollup + RPS-settle + anchor-refresh(ANK per-unit + XB flat) + score-delta + book + checkpoint. \
            \ direction=true stake (owner→vault), false unstake (vault→owner)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (AQP-FVT.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (xfer-type:integer (at "type" (TFT.URC_TransferClasses dptf-id sender receiver amount)))
                (n-live:integer   (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 custody transfer
                      (TFT.URCi_TransferCumulator xfer-type dptf-id sender receiver)))
                  (SIP|URC_Medium)                                                                 ;; 1.2 pool tracker (medium ×1)
                  (SIP|URC_Biggest)                                                                ;; 1.3 ben rollup   (biggest ×1)
                  (SIP|URC_Fixed (AQP-FVT.URC_SettleStakePendingIgnis settle-scores distinct-fvts));; 2   RPS settle
                  (SIP|URC_Fixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live))         ;; 3.1a ANK anchor refresh
                  (SIP|URC_Biggest)                                                                ;; 3.1b XB sync-count (biggest ×1)
                  (SIP|URC_Fixed (URC_StakeScoreDeltaSum pool-id))                                 ;; 4   score delta
                  (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis distinct-fvts))              ;; 5.1 book unclaimed
                  (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))                            ;; 5.2 checkpoint
                ])
        )
    )
    (defun URC_StakeScoreDeltaSumForClasses:decimal (pool-id:string classes:[integer])
        @doc "Class-matched phase-4 leg (OF/SF/NF): Σ SCORE.URC_StakeScoreDeltaIgnisUnit over the pool's \
            \ employed scores whose SCORE.UR_SCR|ScoreClass ∈ classes — mirrors XE_Apply{OrtoFungible, \
            \ Collectable}StakeDelta, which emit 0.0 for non-matching classes (OF: {0,2}; SF: {3}; NF: {4})."
        (fold (+) 0.0
            (map (lambda (sid:string) (AQP-SCORE.URC_StakeScoreDeltaIgnisUnit sid))
                 (filter (lambda (sid:string) (contains (AQP-SCORE.UR_SCR|ScoreClass sid) classes))
                         (AQP-POOL.URC_PoolActiveScoreIds pool-id))))
    )
    (defun URC_OrtoFungibleStakeFlowIfp:decimal
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_OrtoFungibleStakeFlow (04_FVT.pact:6478). Legs: transfer(DPOF, \
            \ direction-INDEPENDENT) + tracker(medium × |nonces|) + RPS-settle + score-delta(class ∈ {0,2}) + \
            \ book + checkpoint. NO 1.3 rollup, NO anchor leg."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (AQP-FVT.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (nn:decimal       (dec (length nonces)))
            )
            (fold (+) 0.0
                [ (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-indep)
                      (DPOF.UC_MoveCumulator dpof-id nonces false)))
                  (* (SIP|URC_Medium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (SIP|URC_Fixed (AQP-FVT.URC_SettleStakePendingIgnis settle-scores distinct-fvts));; 2   RPS settle
                  (SIP|URC_Fixed (URC_StakeScoreDeltaSumForClasses pool-id [0 2]))                 ;; 4   score delta (class ∈ {0,2})
                  (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis distinct-fvts))              ;; 5.1 book unclaimed
                  (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))                            ;; 5.2 checkpoint
                ])
        )
    )
    (defun URC_CollectableStakeFlowIfp:decimal
        (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_CollectableStakeFlow (04_FVT.pact:6544; SF son=true class-3 / NF \
            \ son=false class-4). Legs: transfer(DPDC-T, direction-dependent) + tracker(medium × |nonces|) + \
            \ rollup(medium × |nonces|) + RPS-settle + anchor(FLAT medium + biggest) + score-delta(class == son?3:4) \
            \ + book + checkpoint. nonce-amounts is caller-supplied: stake derives it from owner supply (owner \
            \ holds the nonces pre-stake), unstake gets it from the caller (the vault holds them mid-stake)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (AQP-FVT.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (nn:decimal       (dec (length nonces)))
                (tgt-class:integer (if son 3 4))
            )
            (fold (+) 0.0
                [ (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-dep)
                      (DPDC-T.URCi_MultiTransferCumulator [collectable-id] [son] sender receiver [nonces] [nonce-amounts])))
                  (* (SIP|URC_Medium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (* (SIP|URC_Medium) nn)                                                          ;; 1.3 rollup  (medium × |nonces|)
                  (SIP|URC_Fixed (AQP-FVT.URC_SettleStakePendingIgnis settle-scores distinct-fvts));; 2   RPS settle
                  (SIP|URC_Medium)                                                                 ;; 3 anchor flat medium
                  (SIP|URC_Biggest)                                                                ;; 3 anchor flat biggest
                  (SIP|URC_Fixed (URC_StakeScoreDeltaSumForClasses pool-id [tgt-class]))           ;; 4 score delta (class == son?3:4)
                  (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis distinct-fvts))              ;; 5.1 book unclaimed
                  (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))                            ;; 5.2 checkpoint
                ])
        )
    )
    ;;{F3}  [INFO]  — one per AQP user/admin entrypoint, grouped by source module
    ;;
    ;;<====================>
    ;;[AQP-ANK] Anchors
    ;;<====================>
    (defun AQP-ANK|INFO_IssueTrueFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for AQP-ANK|C_IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a True-Fungible (DPTF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueTrueFungibleAnchor."]
                [(format "Anchor '{}' issued on DPTF {}." [anchor-name dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueSemiFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for AQP-ANK|C_IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Semi-Fungible (DPSF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueSemiFungibleAnchor."]
                [(format "Anchor '{}' issued on DPSF {} nonce {}." [anchor-name dpsf-id dpsf-nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueNonFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) trait-anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleAnchor."]
                [(format "Anchor '{}' issued on DPNF {} trait {}={}." [anchor-name dpnf-id dpnf-trait-key dpnf-trait-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueNonFungibleSetAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) set-anchor (by nonce-class) for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleSetAnchor."]
                [(format "Anchor '{}' issued on DPNF {} nonce-class {}." [anchor-name dpnf-id dpnf-nonce-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_RevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an anchor and update its BoostClass bookkeeping."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeAnchor."]
                [(format "Anchor {} revoked." [anchor-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun AQP-ANK|INFO_RevokeBoostClass:object{OuronetInfoV1.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an empty BoostClass."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeBoostClass."]
                [(format "BoostClass {} revoked." [boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;<====================>
    ;;[AQP-SCR] Scores
    ;;<====================>
    (defun AQP-SCR|INFO_IssueLiquidityScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.AQP-SCR|C_IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueTrueFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueOrtoFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.AQP-SCR|C_IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueSemiFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_RotateScoreOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-SCR|C_RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.AQP-SCR|C_RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_ControlScore:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-SCR|C_ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-SCR|C_ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CreateScoreBoostClassLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CreateScoreBoostLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_EnableDebBoost:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.AQP-SCR|C_EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueTriplet:object{OuronetInfoV1.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for AQP-SCR|C_IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.AQP-SCR|C_IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-TRIPLET))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueSingleScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.AQP-SCR|C_IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CombineTripletScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for AQP-SCR|C_CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.AQP-SCR|C_CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueScoreFromModel:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for AQP-SCR|C_IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.AQP-SCR|C_IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueSemiFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;; mirror C_IssueSemiFungibleScoreDefinition: (* (dec (length nonces)) (UsagePrice "ignis|big"))
                (ifp:decimal (UC|GasPrice (* (dec (length nonces)) (ref-DALOS::UR_UsagePrice "ignis|big")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ifp:decimal (UC|GasPrice (* (dec (length trait-keys)) (ref-DALOS::UR_UsagePrice "ignis|biggest")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleSetScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ifp:decimal (UC|GasPrice (* (dec (length dpnf-nonce-classes)) (ref-DALOS::UR_UsagePrice "ignis|biggest")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible SET score definition rows (one per nonce-class)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleSetScoreDefinition."]
                [(format "Wrote {} NF set score-definition rows on score {}." [(length dpnf-nonce-classes) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;<====================>
    ;;[AQP-POOL] Pools (config)
    ;;<====================>
    (defun AQP-POOL|INFO_Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for AQP-POOL|C_Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.AQP-POOL|C_Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|ISSUE-POOL))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-POOL|INFO_AddScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.AQP-POOL|C_AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|ADD-SCORE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_RevokeScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.AQP-POOL|C_RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|REVOKE-SCORE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_EnablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SET-POOL-STAKE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_DisablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SET-POOL-STAKE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncTrueFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncTrueFungibleAnchors. IGNIS GAS|SYNC-TF-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [beneficiary-id dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-TF-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncSemiFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncSemiFungibleAnchors. IGNIS GAS|SYNC-COLLECTABLE-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [beneficiary-id dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-COLLECTABLE-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncNonFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncNonFungibleAnchors. IGNIS GAS|SYNC-COLLECTABLE-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [beneficiary-id dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-COLLECTABLE-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;<---- stake / unstake (multi-leg reconstructed cost) ---->
    (defun AQP-POOL|INFO_StakeTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_StakeTrueFungible. Full multi-leg IGNIS (transfer + tracker + rollup \
            \ + RPS + anchor + score-delta + book + checkpoint); no STOA. Cost reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake a True-Fungible amount into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeTrueFungible."]
                [(format "Staked {} of {} into pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_TrueFungibleStakeFlowIfp pool-id owner-id beneficiary-id dptf-id amount true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-POOL|INFO_UnstakeTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_UnstakeTrueFungible. Same legs as stake with the custody transfer \
            \ reversed (vault→owner); no STOA. Cost reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake a True-Fungible amount from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeTrueFungible."]
                [(format "Unstaked {} of {} from pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_TrueFungibleStakeFlowIfp pool-id owner-id beneficiary-id dptf-id amount false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-POOL|INFO_StakeOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeOrtoFungible. Multi-leg IGNIS (transfer + tracker×|nonces| + RPS \
            \ + class-matched score-delta + book + checkpoint); no STOA. Reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake whole Orto-Fungible nonces into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeOrtoFungible."]
                [(format "Staked {} nonces of {} into pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_OrtoFungibleStakeFlowIfp pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun AQP-POOL|INFO_UnstakeOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeOrtoFungible. Same legs as OF stake; no STOA. Reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake whole Orto-Fungible nonces from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeOrtoFungible."]
                [(format "Unstaked {} nonces of {} from pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_OrtoFungibleStakeFlowIfp pool-id owner-id beneficiary-id dpof-id nonces false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun AQP-POOL|INFO_StakeSemiFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeSemiFungibleCollectable (DPSF, son=true / class-3). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-3 score-delta + book + checkpoint); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Semi-Fungible collectable nonces (DPSF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeSemiFungibleCollectable."]
                [(format "Staked {} DPSF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_CollectableStakeFlowIfp pool-id owner-id beneficiary-id collectable-id true nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id true nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun AQP-POOL|INFO_UnstakeSemiFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeSemiFungibleCollectable (DPSF, son=true / class-3). Same legs as SF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Semi-Fungible collectable nonces (DPSF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeSemiFungibleCollectable."]
                [(format "Unstaked {} DPSF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_CollectableStakeFlowIfp pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun AQP-POOL|INFO_StakeNonFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeNonFungibleCollectable (DPNF, son=false / class-4). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-4 score-delta + book + checkpoint); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Non-Fungible collectable nonces (DPNF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeNonFungibleCollectable."]
                [(format "Staked {} DPNF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_CollectableStakeFlowIfp pool-id owner-id beneficiary-id collectable-id false nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id false nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun AQP-POOL|INFO_UnstakeNonFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeNonFungibleCollectable (DPNF, son=false / class-4). Same legs as NF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Non-Fungible collectable nonces (DPNF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeNonFungibleCollectable."]
                [(format "Unstaked {} DPNF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_CollectableStakeFlowIfp pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    ;;<---- vacate lifecycle (fixed-cost endpoints) ---->
    (defun URC_VacateTfBatchCostIfp:decimal
        (pool-id:string dptf-id:string legs:[object{AcquisitionVacateV1.VCT|VacateTfLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateTrueFungible, fed the SAME \
            \ dirty-read <legs> the exec receives (owner's exact-preview / dirty-read-fed rule). \
            \ Mirrors XI_VacateTrueFungibleFromLegs byte-for-byte: per-leg tracker-zero (medium) \
            \ + per-unique-beneficiary unwind (rollup biggest + free RPS-prezero + anchor-refresh \
            \ [ANK per-live + XB biggest] + score-delta + book(that benef's distinct-fvts) + \
            \ checkpoint) + the one bulk DPTF multi-transfer. Reuses the identical phase readers \
            \ the stake INFO is ground-truth-proven against."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (unique-benefs:[string] (AQP-VCT.UC_VacateUniqueBeneficiariesFromLegs legs))
                (n-live:integer (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
                (bulk-arr:object (AQP-VCT.UC_VacateTfLegsToTftBulkArrays legs))
                (score-delta:decimal (URC_StakeScoreDeltaSum pool-id))
            )
            (fold (+) 0.0
                [ (* (SIP|URC_Medium) (dec (length legs)))                                         ;; per-leg tracker-zero
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (SIP|URC_Biggest)                                              ;; rollup
                                    (SIP|URC_Fixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live)) ;; anchor refresh
                                    (SIP|URC_Biggest)                                              ;; XB sync-count flat
                                    (SIP|URC_Fixed score-delta)                                    ;; apply stake delta
                                    (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (AQP-FVT.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))          ;; checkpoint
                                  ]))
                          unique-benefs))
                  (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                       ;; bulk DPTF multi-transfer
                      (TFT.URCi_MultiBulkTransferCumulator [dptf-id] AQP-POOL.AQP|SC_NAME
                          (at "receiver-array" bulk-arr) (at "transfer-amount-array" bulk-arr))))
                ])
        )
    )
    (defun AQP-POOL|INFO_BatchVacateTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionVacateV1.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateTrueFungible. Multi-leg IGNIS (per-leg \
            \ tracker-zero + per-beneficiary unwind + one bulk transfer); no STOA. Fed the same \
            \ dirty-read <legs> slice the exec is fed."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPTF asset's owner-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateTrueFungible."]
                [(format "Batch-vacated {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_VacateTfBatchCostIfp pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun URC_VacateOfBatchCostIfp:decimal
        (pool-id:string dpof-id:string legs:[object{AcquisitionVacateV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateOrtoFungible, fed the same \
            \ dirty-read nonce <legs> the exec receives. Mirrors XI_VacateOrtoFungibleBatch: the \
            \ one bulk DPOF whole-nonce transfer (URCi_MoveCumulator over all nonces) + per-owner- \
            \ row tracker (medium × total-nonce-count) + per-unique-beneficiary score unwind = \
            \ free RPS-prezero + ApplyOFDelta (class-matched {0,2}) + book + checkpoint. NO rollup, \
            \ NO anchor (OF phase-3 N/A)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (nonces-array:[[integer]] (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                (unique-benefs:[string]
                    (AQP-VCT.UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (all-nonces:[integer] (fold (+) [] nonces-array))
                (score-delta:decimal (URC_StakeScoreDeltaSumForClasses pool-id [0 2]))
            )
            (fold (+) 0.0
                [ (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                       ;; bulk DPOF transfer
                      (DPOF.URCi_MoveCumulator dpof-id all-nonces false)))
                  (* (SIP|URC_Medium) (dec (length all-nonces)))                                    ;; per-row tracker (medium × Σ|nonces|)
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (SIP|URC_Fixed score-delta)                                     ;; apply OF stake delta {0,2}
                                    (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (AQP-FVT.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))           ;; checkpoint
                                  ]))
                          unique-benefs))
                ])
        )
    )
    (defun AQP-POOL|INFO_BatchVacateOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionVacateV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateOrtoFungible. Multi-leg IGNIS (bulk DPOF \
            \ transfer + per-nonce tracker + per-beneficiary score unwind); no STOA. Fed the same \
            \ dirty-read nonce <legs> slice the exec is fed."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPOF asset's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateOrtoFungible."]
                [(format "Batch-vacated {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_VacateOfBatchCostIfp pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun URC_VacateCollBatchCostIfp:decimal
        (pool-id:string collectable-id:string son:bool legs:[object{AcquisitionVacateV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateCollectables (son=DPSF/DPNF), \
            \ fed the same dirty-read nonce <legs> the exec receives. Mirrors XI_VacateCollectable \
            \ Batch: the one bulk DPDC-T transfer + per-owner-row (tracker medium×|nonces| + rollup \
            \ medium×|nonces|) + per-unique-beneficiary score unwind = free RPS-prezero + FLAT anchor \
            \ refresh (medium+biggest) + ApplyCollectableDelta (class-matched: SF [3] / NF [4]) + \
            \ book + checkpoint. Collectable units are whole (amounts floored, matching exec)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (nonces-array:[[integer]] (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                (amounts-array:[[integer]]
                    (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg})
                            (map (lambda (q:decimal) (floor q)) (at "amounts" l))) legs))
                (unique-benefs:[string]
                    (AQP-VCT.UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (score-delta:decimal (URC_StakeScoreDeltaSumForClasses pool-id (if son [3] [4])))
                (anchor-flat:decimal (+ (SIP|URC_Medium) (SIP|URC_Biggest)))
            )
            (fold (+) 0.0
                [ (SIP|URC_Fixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                       ;; bulk DPDC-T transfer
                      (DPDC-T.URCi_BulkTransferCumulator collectable-id son AQP-POOL.AQP|SC_NAME
                          (map (lambda (l:object{AcquisitionVacateV1.VCT|VacateNonceLeg}) (at "owner-id" l)) legs)
                          nonces-array amounts-array)))
                  (* (* 2.0 (SIP|URC_Medium)) (dec (length (fold (+) [] nonces-array))))            ;; per-row tracker + rollup (each medium×|nonces|)
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (SIP|URC_Fixed anchor-flat)                                     ;; flat anchor refresh
                                    (SIP|URC_Fixed score-delta)                                     ;; apply collectable delta [son?3:4]
                                    (SIP|URC_Fixed (AQP-FVT.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (AQP-FVT.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (SIP|URC_Fixed (AQP-FVT.URC_CheckpointStakeRpsIgnis))           ;; checkpoint
                                  ]))
                          unique-benefs))
                ])
        )
    )
    (defun AQP-POOL|INFO_BatchVacateCollectables:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionVacateV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateCollectables (son=DPSF true / DPNF false). \
            \ Multi-leg IGNIS (bulk transfer + per-nonce tracker + rollup + flat anchor + per- \
            \ beneficiary class-matched score unwind); no STOA. Fed the dirty-read nonce <legs>."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one collectable collection's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateCollectables."]
                [(format "Batch-vacated {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (URC_VacateCollBatchCostIfp pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_FinalizeVacate:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_FinalizeVacate. IGNIS one flat 'ignis|medium' tier (05_VCT:3016); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a vacate — nuke employed scores, unfreeze FVTs, re-enable stake."
                 "Executes via TS02-C3.AQP-POOL|C_FinalizeVacate."]
                [(format "Finalized vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-POOL|INFO_AbortVacate:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_AbortVacate. Empty cumulator (05_VCT:2989) — costs you nothing."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Abort an in-progress vacate (clear the in-progress flag; stake stays disabled)."
                 "Costs you nothing."
                 "Executes via TS02-C3.AQP-POOL|C_AbortVacate."]
                [(format "Aborted vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;<====================>
    ;;[AQP-FVT] Farms / Vaults / Treasuries (config + rewards)
    ;;<====================>
    (defun AQP-FVT|INFO_Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_Issue. IGNIS GAS|ISSUE-FVT + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a Farm / Vault / Treasury." "Executes via TS02-C3.AQP-FVT|C_Issue."]
                [(format "FVT '{}' created (class {}) for {}." [fvt-name fvt-class owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|ISSUE-FVT))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-FVT|INFO_RotateOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership. IGNIS 'ignis|medium'; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer an FVT's owner-konto." "Executes via TS02-C3.AQP-FVT|C_RotateOwnership."]
                [(format "FVT {} ownership moved to {}." [fvt-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_Control:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-FVT|C_Control. IGNIS 'ignis|medium'; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set an FVT's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-FVT|C_Control."]
                [(format "FVT {} control flags updated." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_SetCommonDenominator:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_SetCommonDenominator. IGNIS GAS|SET-COMMON-DENOMINATOR; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's common-denominator (before any links)." "Executes via TS02-C3.AQP-FVT|C_SetCommonDenominator."]
                [(format "FVT {} common-denominator set to {}." [fvt-id common-denominator])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|SET-COMMON-DENOMINATOR))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_SetMosaic:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Cost preview for AQP-FVT|C_SetMosaic. IGNIS GAS|SET-MOSAIC; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a farm's mosaic membership policy." "Executes via TS02-C3.AQP-FVT|C_SetMosaic."]
                [(format "FVT {} mosaic set to {}." [fvt-id mosaic])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|SET-MOSAIC))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_SetSplitMode:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string split-mode:string)
        @doc "Cost preview for AQP-FVT|C_SetSplitMode. IGNIS GAS|SET-SPLIT-MODE; no STOA. Reports the farm's current \
            \ reward-split mode alongside the requested one."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size)." "Executes via TS02-C3.AQP-FVT|C_SetSplitMode."]
                [(format "Farm {} reward-split mode: {} -> {}." [fvt-id (AQP-FVT.UR_FVT|SplitMode fvt-id) split-mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|SET-SPLIT-MODE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_AddScoreEntity:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Cost preview for AQP-FVT|C_AddScoreEntity. IGNIS GAS|ADD-SCORE-ENTITY; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a score (type 1) or triplet (type 3) on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddScoreEntity."]
                [(format "Score-entity {} (type {}) registered on FVT {}." [score-entity-id score-entity-type fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|ADD-SCORE-ENTITY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_ToggleScoreEntityLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleScoreEntityLink. IGNIS GAS|TOGGLE-SCORE-ENTITY-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable/disable a ScoreEntityLink on an FVT." "Executes via TS02-C3.AQP-FVT|C_ToggleScoreEntityLink."]
                [(format "FVT {} score-entity {} enabled={}." [fvt-id score-entity-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|TOGGLE-SCORE-ENTITY-LINK))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_IssueMultipletFamily:object{OuronetInfoV1.ClientInfo}
        (patron:string token-0-id:string token-1-id:string token-2-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueMultipletFamily. IGNIS GAS|ISSUE-MULTIPLET-FAMILY; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a chain-wide MultipletFamily reward ladder." "Executes via TS02-C3.AQP-FVT|C_IssueMultipletFamily."]
                [(format "MultipletFamily issued: {} -> {} -> {}." [token-0-id token-1-id token-2-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|ISSUE-MULTIPLET-FAMILY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_AddRewardLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Cost preview for AQP-FVT|C_AddRewardLink. IGNIS GAS|ADD-REWARD-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a reward DPTF on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddRewardLink."]
                [(format "Reward {} linked on FVT {} (family {})." [reward-dptf-id fvt-id multiplet-family-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|ADD-REWARD-LINK))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_ToggleRewardLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleRewardLink. IGNIS GAS|TOGGLE-REWARD-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a reward link's enabled flag." "Executes via TS02-C3.AQP-FVT|C_ToggleRewardLink."]
                [(format "FVT {} reward {} enabled={}." [fvt-id reward-dptf-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|TOGGLE-REWARD-LINK))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_SetQualitySplit:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Cost preview for AQP-FVT|C_SetQualitySplit. IGNIS GAS|SET-QUALITY-SPLIT; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a MULTIPLET_BASE reward's quality-split mode + matrix." "Executes via TS02-C3.AQP-FVT|C_SetQualitySplit."]
                [(format "FVT {} reward {} quality-split mode={}." [fvt-id reward-dptf-id mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|SET-QUALITY-SPLIT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_InjectStream:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Cost preview for AQP-FVT|CC_InjectStream. IGNIS GAS|INJECT; STOA none (custody transfer)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Inject reward tokens as a linear time-stream over the given duration."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectStream."]
                [(format "Streaming {} of {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|INJECT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-FVT|INFO_CC_Inject:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_Inject (enforced-fresh single-tx inject). IGNIS GAS|INJECT; STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enforced-fresh single-tx inject (fixes all stale members first)."
                 "Executes via TS02-C3.AQP-FVT|CC_Inject."]
                [(format "Fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|INJECT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-FVT|INFO_CC_InjectFinalize:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_InjectFinalize. IGNIS GAS|INJECT; STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a paginated fresh inject (zero-stale gate, then inject)."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectFinalize."]
                [(format "Finalized fresh inject of {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|INJECT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-FVT|INFO_CCp_InjectFixChunk:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_InjectFixChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page the enforced-fresh FIX phase (up to `chunk` stale members)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_InjectFixChunk."]
                [(format "Fixed up to {} stale members on FVT {} reward {}." [chunk fvt-id reward-dptf-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_CCp_UnstaleAll:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_UnstaleAll. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Owner mass deb-unstale (make injection-ready; no inject)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_UnstaleAll."]
                [(format "Unstaled up to {} members on FVT {}." [chunk fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_UnstaleMyScores:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-ids:[string])
        @doc "Cost preview for AQP-FVT|CC_UnstaleMyScores. IGNIS GAS|UNSTALE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Self-service deb-unstale of your own scores across FVTs." "Executes via TS02-C3.AQP-FVT|CC_UnstaleMyScores."]
                [(format "Unstaled your scores across {} FVTs." [(length fvt-ids)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|UNSTALE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_Collect:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|CC_Collect. IGNIS GAS|COLLECT base; STOA none. For a MULTIPLET_BASE triplet \
            \ reward the payout also fires ATS Coil/Curl ladder legs (added at execution)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Collect your claimable reward from this FVT membership."
                 "Base IGNIS shown; a triplet MULTIPLET reward adds ladder (Coil/Curl) legs at execution."
                 "Executes via TS02-C3.AQP-FVT|CC_Collect."]
                [(format "Collected reward token {} from score-entity {}." [reward-dptf-id score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|COLLECT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_CC_SweepRevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Single-tx re-score sweep retiring an employed anchor."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepRevokeAnchor."]
                [(format "Swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_CC_SweepBegin:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepBegin. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a paginated re-score sweep (freeze + swept-revoke + cursor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepBegin."]
                [(format "Opened sweep on anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-FVT|INFO_CCp_SweepRecomputeChunk:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_SweepRecomputeChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page a re-score sweep (recompute the next `chunk` holders; final page unfreezes)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_SweepRecomputeChunk."]
                [(format "Recomputed up to {} holders on anchor {}'s sweep." [chunk anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;<====================>
    ;;[AQP-DSA] Delegated Staking Agencies
    ;;<====================>
    (defun AQP-DSA|INFO_DefineDelegationVault:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Cost preview for AQP-DSA|A_DefineDelegationVault. IGNIS GAS|DEFINE-VAULT; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bind a class-0 FVT as a DSA delegation vault." "Executes via TS02-C3.AQP-DSA|A_DefineDelegationVault."]
                [(format "FVT {} bound as delegation vault (model {})." [fvt-id model-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|DEFINE-VAULT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_OpenAgency:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer collectable-id:string stake-nonces:[integer])
        @doc "Cost preview for AQP-DSA|C_OpenAgency. IGNIS GAS|OPEN-AGENCY base; the atomic open also stakes the \
            \ operator's collateral (staking legs added at execution). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a delegation agency (admit + operator-stake + terminal gate)."
                 "Base IGNIS shown; the operator collateral stake adds its legs at execution."
                 "Executes via TS02-C3.AQP-DSA|C_OpenAgency."]
                [(format "Agency {} opened on vault {} (fee {} per-mille)." [score-entity-id fvt-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|OPEN-AGENCY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_RecomputeCapture:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Cost preview for AQP-DSA|C_RecomputeCapture. IGNIS GAS|RECOMPUTE-CAPTURE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Recompute an agency's capture (permissionless; preserves oracle-ts)." "Executes via TS02-C3.AQP-DSA|C_RecomputeCapture."]
                [(format "Agency {} capture recomputed on vault {}." [score-entity-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|RECOMPUTE-CAPTURE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_SetOracleAuth:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Cost preview for AQP-DSA|A_SetOracleAuth. IGNIS GAS|SET-ORACLE-AUTH; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Authorize the delegated oracle key + arm the capture expiry." "Executes via TS02-C3.AQP-DSA|A_SetOracleAuth."]
                [(format "Oracle authority set on vault {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|SET-ORACLE-AUTH))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_OracleWrite:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Cost preview for AQP-DSA|A_OracleWrite. IGNIS GAS|ORACLE-WRITE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Oracle writes an agency's daily {nodes, uptime} + recomputes its capture." "Executes via TS02-C3.AQP-DSA|A_OracleWrite."]
                [(format "Oracle wrote nodes {} / uptime {} for agency {}." [nodes uptime score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|ORACLE-WRITE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_ToggleExternalOracle:object{OuronetInfoV1.ClientInfo}
        (patron:string on:bool)
        @doc "Cost preview for AQP-DSA|A_ToggleExternalOracle. Chain-wide GOV switch — no IGNIS/STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Flip the SINGULAR GLOBAL external-oracle switch for ALL agencies (governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_ToggleExternalOracle."]
                [(format "Global external-oracle switch set to {}." [on])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_SetOracleValidity:object{OuronetInfoV1.ClientInfo}
        (patron:string seconds:integer)
        @doc "Cost preview for AQP-DSA|A_SetOracleValidity. Chain-wide GOV switch — no IGNIS/STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set the GLOBAL oracle-validity window (freshness horizon; governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_SetOracleValidity."]
                [(format "Global oracle-validity window set to {} seconds." [seconds])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_WithdrawRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|A_WithdrawRoyalty. IGNIS GAS|WITHDRAW-ROYALTY; STOA none (custody move)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Withdraw the whole royalty pool to the FVT owner." "Executes via TS02-C3.AQP-DSA|A_WithdrawRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} withdrawn to owner." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|WITHDRAW-ROYALTY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_BurnRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|A_BurnRoyalty. IGNIS GAS|BURN-ROYALTY; STOA none (custody burn)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Burn the whole royalty pool." "Executes via TS02-C3.AQP-DSA|A_BurnRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} burned." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|BURN-ROYALTY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_FuelRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Cost preview for AQP-DSA|A_FuelRoyalty. IGNIS GAS|FUEL-ROYALTY; STOA none (custody move)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fuel a swap pair with the whole royalty pool (no LP mint)." "Executes via TS02-C3.AQP-DSA|A_FuelRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} fueled into {}." [reward-dptf-id fvt-id swpair])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|FUEL-ROYALTY))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun AQP-DSA|INFO_SetAgencyFee:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Cost preview for AQP-DSA|A_SetAgencyFee. IGNIS GAS|SET-AGENCY-FEE; no STOA. O(1) reprice."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Change a delegation agency's operator fee (reprices only future injects)." "Executes via TS02-C3.AQP-DSA|A_SetAgencyFee."]
                [(format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-DSA.GAS|SET-AGENCY-FEE))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;<====================>
    ;;[AQP-MTX] Matrix drivers (spike-fallback defpacts)
    ;;<====================>
    (defun AQP-MTX|INFO_2Inject:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for MTX-AQP|C_2|Inject (2-step enforced-fresh inject). IGNIS GAS|INJECT (inner XB_FvtInject); STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step enforced-fresh inject (spike fallback for CC_Inject on vault/treasury)."
                 "Executes via TS02-C3.MTX-AQP|C_2|Inject."]
                [(format "2-step fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-FVT.GAS|INJECT))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun AQP-MTX|INFO_2SweepRevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for MTX-AQP|C_2|SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step paginated sweep retiring an employed anchor (spike fallback for CC_SweepRevokeAnchor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.MTX-AQP|C_2|SweepRevokeAnchor."]
                [(format "2-step swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;{F4}  [CAP]
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
)
