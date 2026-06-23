(interface AcquisitionPoolsV1
    (defun GOV|Demiurgoi ())
    ;;
    ;;  [UC]
    (defun UC_DPTFTrackerKey:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UC_DPOFTrackerKey:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPSFTrackerKey:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPNFTrackerKey:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPSFScoreAttributionKey:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UC_DPNFScoreAttributionKey:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UC_BeneficiaryDptfTotalKey:string (beneficiary-id:string dptf-id:string))
    ;;
    ;;  [UR] AQP|Schema (AQP|T|Pool)
    (defun UR_AQP|AllPoolIds:[string] ())
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string))
    (defun UR_AQP|PoolAssetId:string (pool-id:string))
    (defun UR_AQP|PoolScorePrimary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSecondary:string (pool-id:string))
    (defun UR_AQP|PoolScoreTertiary:string (pool-id:string))
    (defun UR_AQP|PoolScoreQuaternary:string (pool-id:string))
    (defun UR_AQP|PoolScoreQuinary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSenary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSeptenary:string (pool-id:string))
    (defun UR_AQP|PoolAqpId:string (pool-id:string))
    ;;
    ;;  [UR] AQP|TrueFungibleTracker (AQP|T|DPTFTracker)
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    ;;
    ;;  [UR] AQP|BeneficiaryDptfTotal (AQP|T|BeneficiaryDptfTotal) — cross-pool ANK rollup
    (defun UR_AQP|BeneficiaryDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string))
    (defun UR_AQP|BeneficiaryDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string))
    (defun URC_BeneficiaryAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string))
    ;;
    ;;  [UR] AQP|OrtoFungibleTracker (AQP|T|DPOFTracker)
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|SemiFungibleTracker (AQP|T|DPSFTracker)
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|NonFungibleTracker (AQP|T|DPNFTracker)
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|DPSFScoreAttribution (AQP|T|DPSFScoreAttribution)
    (defun UR_AQP|DPSFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionPoolId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionDpsfId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionOwnerId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionBeneficiaryId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionScoreId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    ;;
    ;;  [UR] AQP|DPNFScoreAttribution (AQP|T|DPNFScoreAttribution)
    (defun UR_AQP|DPNFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionPoolId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionDpnfId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionOwnerId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionBeneficiaryId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionScoreId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    ;;
    ;;  [C]
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
    )
    (defun C_AddScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string score-id:string)
    )
    (defun C_RevokeScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string score-id:string)
    )
    ;;
    ;;=== PLANNED C_* (comment-only — not on interface; home module TBD at implementation) ===
    ;; TF stake/unstake recipe: FVT::C_TrueFungibleStakeFlow (Talos AQP-POOL|C_Stake/UnstakeTrueFungible).
    ;;
    ;; C_StakeOrtoFungible(patron pool-id owner-id beneficiary-id dpof-id nonces)
    ;;   Stake whole DPOF nonces into pool-id (AQP|T|DPOFTracker) via DPOF::C_Transfer only.
    ;;   Covers class-2 native DPOF, class-0 sleeping|Z| LP orto legs, class-1 sleeping/hib DPOF satellites.
    ;;
    ;; C_UnstakeOrtoFungible(patron pool-id owner-id dpof-id nonces)
    ;;   Unstake whole DPOF nonces; beneficiary read from tracker row per nonce at implementation time.
    ;;
    ;; C_StakeCollectable(patron pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts)
    ;;   Stake DPDC collectable nonces. son=true -> DPSF (class-3); son=false -> DPNF (class-4).
    ;;
    ;; C_UnstakeCollectable(patron pool-id owner-id collectable-id son nonces nonce-amounts)
    ;;   Unstake DPDC collectable nonces; beneficiary read from tracker row per nonce.
    ;;
    ;; C_SyncTrueFungibleAnchors(patron beneficiary-id dptf-id)
    ;;   Pool-agnostic ANK repair: same backward legs as FVT::XI_RefreshTrueFungibleStakeAnchors
    ;;   (read total, ANK::XE_UpdateTrueFungibleUserAnchorValues, AQP::XE_SetBeneficiaryDptfAnkSyncCount). Home module TBD.
    ;;
    ;; C_VacatePool(patron pool-id)
    ;;   Pool owner force-unwind all staked positions. Orchestration TBD (Talos loop vs sovereign recipe module).
    ;;
    ;;  [URC]  internal stake helpers (cross-module read from SCR XE_ApplyTrueFungibleStakeDelta; FVT recipe cap)
    (defun URC_DptfStakeIsNativeLeg:bool (dptf-id:string))
    (defun URC_OrtoUnstakeBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string nonce:integer))
    (defun URC_OrtoStakeWholeNonceAmounts:bool (dpof-id:string nonces:[integer] nonce-amounts:[decimal]))
    (defun URC_PoolActiveScoreIds:[string] (pool-id:string))
    (defun URC_PoolHasEmployedScores:bool (pool-id:string))
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeTrueFungibleDptfMatchesPool:bool (pool-id:string dptf-id:string))
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeOrtoFungibleDpofMatchesPool:bool (pool-id:string dpof-id:string))
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string nonces:[integer] nonce-amounts:[decimal])
    )
    ;;
    ;;  [XE]  cross-module forward (FVT::C_*StakeFlow · canonical phase 1 custody)
    (defun XE_Phase_1_1|TrueFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_Phase_1_2|TrueFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_Phase_1_3|TrueFungibleBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_Phase_1_1|OrtoFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_Phase_1_2|OrtoFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_TrueFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_OrtoFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_SetBeneficiaryDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
)
(module AQP-POOL GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionPoolsV1)
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP                    (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|AQP_ADMIN)))
    (defcap GOV|AQP_ADMIN ()                (enforce-guard GOV|MD_AQP))
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
    (defcap P|AQP|CALLER ()
        true
    )
    (defcap P|AQP|REMOTE-GOV ()
        @doc "Reserved — not wired in P|A_Define or C_RotateGovernor until a forward module needs a remote gov slot on AQP|SC_NAME."
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|AQP|CALLER))
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
        (with-capability (GOV|AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|AQP_ADMIN)
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
        @doc "Post-deploy IMC wiring (AQP-BOOT Step 0). TFT + DPOF vault transfer/receive on AQP|SC_NAME."
        (let
            (
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                ;;
                (mg:guard (create-capability-guard (P|AQP|CALLER)))
            )
            ;; AQP-POOL → TFT: XI_1|TransferDptfPoolCustody calls TFT::C_Transfer; TFT UEV_IMC requires this guard.
            (ref-P|TFT::P|A_AddIMP mg)
            ;; AQP-POOL → DPOF: XI_1|TransferDpofPoolCustody calls DPOF::C_Transfer (whole nonce only).
            (ref-P|DPOF::P|A_AddIMP mg)
            true
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
    (defschema AQP|Schema
        @doc "One aqp-class and one canonical asset-id per pool; employed \
            \ scores must match that class. Staking asset identity is \
            \ authoritative here (SCORE: Score -> aqpool-link -> this pool \
            \ -> asset-id). Class 0: asset-id is the primary LP key; stake \
            \ paths may accept additional linked LP token ids (native / \
            \ sleeping OF / frozen TF) when verified as the same LP family; \
            \ all credit the same pool score slots. Fix wrong pool economics \
            \ by issuing a new pool and new scores, not by mutating class or \
            \ primary asset-id after stake exists."
        ;;
        aqp-class:integer                                       ;;Defines the Pool Class, there are 5
        ;;                                                        Class 0 = LP family pool (issue native LP; stake native|F||Z| LP)
        ;;                                                        Class 1 = DPTF family pool (issue native DPTF; stake native|F| + linked sleep/hib DPOF)
        ;;                                                        Class 2 = standalone DPOF (issue one dpof; no sleep/hib satellites — use class 0/1)
        ;;                                                        Class 3 = DPSF collection pool
        ;;                                                        Class 4 = DPNF collection pool
        asset-id:string                                         ;;ID of the Asset that is allowed to be staked in the Pool.
        ;;                                                        This must be in accordance with the <aqp-class> and together with it
        ;;                                                        Defines which assets can be staked in the Pool
        ;;
        ;;Score - Links
        score-primary:string
        score-secondary:string
        score-tertiary:string
        score-quaternary:string
        score-quinary:string
        score-senary:string
        score-septenary:string
        ;;
        ;;Select Keys
        aqp-id:string
    )
    ;;Staking Trackers
    (defschema AQP|TrueFungibleTracker
        balance:decimal                                         ;;Store DPTF Balance Amount
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dptf-id:string                                          ;;DPTF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
    )
    (defschema AQP|OrtoFungibleTracker
        balance:decimal                                         ;;Staked DPOF amount for this nonce slot
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpof-id:string                                          ;;DPOF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|SemiFungibleTracker
        @doc "DPSF custody: staked balance per pool, collection, owner, \
            \ beneficiary, nonce. Per-score contribution and revision live in \
            \ AQP|T|DPSFScoreAttribution (one row per score-id that this stake \
            \ updates, up to 7 per pool)."
        balance:decimal                                         ;;Stores DPSF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpsf-id:string                                          ;;DPSF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|NonFungibleTracker
        @doc "DPNF custody: staked balance per pool, collection, owner, \
            \ beneficiary, nonce. Per-score contribution and revision live in \
            \ AQP|T|DPNFScoreAttribution (one row per score-id that this stake \
            \ updates, up to 7 per pool)."
        balance:decimal                                         ;;Stores DPNF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpnf-id:string                                          ;;DPNF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    ;;Per pool score-id: one stake may update several of score-primary…septenary;
    ;;each (pool, asset, position, score-id) gets its own cached contribution
    ;;and def-revision cursor (SCR|T|SF|DefRevision / SCR|T|NF|DefRevision).
    (defschema AQP|DPSFScoreAttribution
        @doc "Last committed base score from this DPSF position for one \
            \ pool score-id (same numeric sense as folded into \
            \ SCR|T|UserScore.base-score). Compare applied-def-revision-nonce \
            \ to SCR|T|SF|DefRevision at (score-id, dpsf-id). SFT: sft-equality \
            \ vs nonce table. On refresh/unstake, delta user aggregate using \
            \ cached-position-score vs recomputed value."
        cached-position-score:decimal                           ;;[M] Last applied base score for this score-id
        applied-def-revision-nonce:integer                      ;;Last applied SCR|T|SF|DefRevision revision
        ;;
        ;;Select Keys
        pool-id:string
        dpsf-id:string
        owner-id:string
        beneficiary-id:string
        nonce:integer
        score-id:string
    )
    (defschema AQP|DPNFScoreAttribution
        @doc "Last committed base score from this DPNF position for one \
            \ pool score-id. Compare applied-def-revision-nonce to \
            \ SCR|T|NF|DefRevision.global-revision-nonce at (score-id, dpnf-id). NFT model 1: \
            \ trait or class definition writes bump global (and their branch counter). Model 0 (native): compare \
            \ cached-position-score to live native read when revision unchanged."
        cached-position-score:decimal                           ;;[M] Last applied base score for this score-id
        applied-def-revision-nonce:integer                      ;;Last applied SCR|T|NF|DefRevision.global-revision-nonce
        ;;
        ;;Select Keys
        pool-id:string
        dpnf-id:string
        owner-id:string
        beneficiary-id:string
        nonce:integer
        score-id:string
    )
    ;;Beneficiary × asset rollups (pool-agnostic totals for ANK sync — see README_AQP.md § Anchor sync)
    (defschema AQP|BeneficiaryDptfTotal
        @doc "Cross-pool rollup: total DPTF staked by one beneficiary on one exact dptf-id leg \
            \ (native X and F|X are separate rows). Maintained on every TF stake/unstake POOL leg \
            \ (FVT::C_TrueFungibleStakeFlow → XE_TrueFungiblePoolCustody → XI bump). Input to \
            \ ANK::XE_UpdateTrueFungibleUserAnchorValues without scanning AQP|T|DPTFTracker keys. \
            \ last-ank-sync-count stores AQP-ANK::UR_AA|AnchorsActive(dptf-id) after the last successful \
            \ anchor refresh; URC_BeneficiaryAnchorsNeedSync compares it to the live count so the UI can \
            \ prompt C_SyncTrueFungibleAnchors when new anchors are issued after stake. Per-pool detail \
            \ remains in AQP|T|DPTFTracker; this row is the single O(1) read for anchor promile."
        total-balance:decimal                                           ;;[M] Sum of tracker balances for (beneficiary, dptf-id) across all pools
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last C_Sync* / stake ANK leg (0 = never synced)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dptf-id:string                                                  ;;[.] Exact DPTF id leg (native or F|); must match ANK ank-asset for sync call
    )
    ;;
    ;;{2}
    (deftable AQP|T|Pool:{AQP|Schema})                                  ;;Key = <Pool-ID>
    ;;Trackers (per-pool custody + score attribution keys)
    (deftable AQP|T|DPTFTracker:{AQP|TrueFungibleTracker})              ;;Key = <Pool-ID> | <DPTF-ID> | <Owner-ID> | <Beneficiary-ID>
    (deftable AQP|T|DPOFTracker:{AQP|OrtoFungibleTracker})              ;;Key = <Pool-ID> | <DPOF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPSFTracker:{AQP|SemiFungibleTracker})              ;;Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPNFTracker:{AQP|NonFungibleTracker})               ;;Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    ;;Score Attributions
    ;;
    (deftable AQP|T|DPSFScoreAttribution:{AQP|DPSFScoreAttribution})    ;;Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce> | <Score-ID>
    (deftable AQP|T|DPNFScoreAttribution:{AQP|DPNFScoreAttribution})    ;;Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce> | <Score-ID>
    ;;Beneficiary rollups (pool-agnostic; ANK sync — not a substitute for per-pool trackers)
    (deftable AQP|T|BeneficiaryDptfTotal:{AQP|BeneficiaryDptfTotal})    ;;Key = <Beneficiary-ID> | <DPTF-ID>
    ;;{3}
    (defun CT_Bar:string
        ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT))               (ref-U|CT::CT_BAR))
    )
    (defconst BAR                                                       (CT_Bar))
    (defconst GAS|ISSUE-POOL                                            1000.0)
    (defconst GAS|ADD-SCORE                                             500.0)
    (defconst GAS|REVOKE-SCORE                                          500.0)
    (defconst GAS|SYNC-TF-ANCHORS                                       500.0)
    (defconst GAS|STAKE-TRUE-FUNGIBLE                                   500.0)
    (defconst GAS|UNSTAKE-TRUE-FUNGIBLE                                 500.0)
    (defun CT_EmptyCumulator ()
        @doc "Empty IGNIS OutputCumulator for stub transfer legs."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2))
    )
    (defconst EOC                                                       (CT_EmptyCumulator))
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let ((ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)) (ref-ANK::GOV|AQP|SC_NAME))
    )
    (defconst AQP|SC_NAME                                               (CT_AqpScName))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    (defcap AQP|C>ISSUE-POOL
        (pool-name:string asset-id:string aqp-class:integer)
        @doc "Issue one acquisition pool (single @event). Validates pool-name, class, and asset-id; \
            \ enforces canonical asset ownership from aqp-class + asset-id; composes SECURE for XI_IssuePool."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
            )
            ;;1] pool-name is a valid autostake index (unique pool id stem)
            (ref-U|ATS::UEV_AutostakeIndex pool-name)
            ;;2] aqp-class in 0..4 and asset-id matches class rules (native id, not a special prefix)
            (UEV_IssuePoolClassAndAsset aqp-class asset-id)
            ;;3] tx sender must own the canonical asset behind this pool class + asset-id
            (CAP_AqpAssetOwner aqp-class asset-id)
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|C>ADD-SCORE
        (pool-id:string score-id:string slot-index:integer)
        @doc "Assign score-id to score slot slot-index (first free; computed once in C_AddScore). Validates \
            \ slot claim, pool/score pairing; CAP_PoolOwner. Score owner in SCR|XE>CREATE-AQPOOL-LINK on XE. \
            \ Composes SECURE for XI_AddScoreToPool."
        @event
        (UEV_AddScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>REVOKE-SCORE
        (pool-id:string score-id:string slot-index:integer)
        @doc "Revoke score-id from score slot slot-index (computed once in C_RevokeScore). Validates \
            \ slot claim, zero totals, fvt-link BAR, boost-link dependents; CAP_PoolOwner. Score owner in \
            \ SCR|XE>REVOKE-AQPOOL-LINK on XE. Composes SECURE for XI_RevokeScoreFromPool."
        @event
        (UEV_RevokeScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Forward-only (FVT::C_TrueFungibleStakeFlow phase 1]): validation for XE_TrueFungiblePoolCustody. \
            \ Pool/beneficiary/tracker/rollup rules here; dptf-id/amount/debit via TFT::C_Transfer. \
            \ CAP_StakeOwner (owner wallet); compose P|AQP|CALLER (TFT IMC); compose AQP-ANK.AQP|GOV (AQP|SC_NAME smart account — \
            \ send and receive both require governor proof). XI_* writers have no enforce. Not @event — UEV_IMC on XE entry."
        (let
            (
                (staked-bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (UR_AQP|BeneficiaryDptfTotalBalance beneficiary-id dptf-id))
                (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (dptf-ok:bool (URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (tracker-ok:bool (or direction (>= staked-bal amount)))
                (rollup-ok:bool (or direction (>= rollup-bal amount)))
            )
            (enforce
                (fold (and) true [class-ok scores-ok dptf-ok tracker-ok rollup-ok])
                "Invalid TF pool custody: pool class/scores/dptf-id or insufficient staked/rollup balance"
            )
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Forward-only (FVT::C_OrtoFungibleStakeFlow phase 1]): validation for XE_OrtoFungiblePoolCustody. \
            \ Whole-nonce DPOF::C_Transfer only. CAP_StakeOwner; compose P|AQP|CALLER + AQP-ANK.AQP|GOV for vault custody."
        (let
            (
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (class-ok:bool (URC_StakeOrtoFungiblePoolClassOk pool-id))
                (dpof-ok:bool (URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                (whole-nonce-ok:bool (URC_OrtoStakeWholeNonceAmounts dpof-id nonces nonce-amounts))
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_OrtoUnstakeNoncesSufficient pool-id dpof-id owner-id nonces nonce-amounts)
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) scores-ok class-ok dpof-ok whole-nonce-ok tracker-ok])
                "Invalid OF pool custody: pool class/dpof-id, whole nonces/amounts, or insufficient tracker balance"
            )
            (UEV_StakeOrtoFungibleDpofLeg dpof-id)
            (if direction
                (let
                    (
                        (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    )
                    (ref-DPOF::UEV_NoncesToAccount dpof-id owner-id nonces)
                    (ref-DPOF::UEV_NoncesCirculating dpof-id nonces)
                    (map
                        (lambda (idx:integer)
                            (ref-DPOF::UEV_Amount dpof-id (at idx nonce-amounts))
                        )
                        (enumerate 0 (- l-n 1))
                    )
                )
                true
            )
            (if direction
                (UEV_StakeBeneficiaryAccount beneficiary-id)
                true
            )
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC
        (beneficiary-id:string dptf-id:string)
        @doc "Backward-only (FVT::C_TrueFungibleStakeFlow phase 2.2]): stamp last-ank-sync-count on BeneficiaryDptfTotal. \
            \ beneficiary/dptf validation here; full stake rules in FVT|C>TRUE-FUNGIBLE-STAKE-FLOW. \
            \ Composes SECURE for XE write body. Not @event — UEV_IMC on XE entry."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    ;;{C3}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]
    (defun UC_DPTFTrackerKey:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|DPTFTracker: pool-id | dptf-id | owner-id | beneficiary-id."
        (concat [pool-id BAR dptf-id BAR owner-id BAR beneficiary-id])
    )
    (defun UC_DPOFTrackerKey:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPOFTracker: pool-id | dpof-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpof-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPSFTrackerKey:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPSFTracker: pool-id | dpsf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPNFTrackerKey:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPNFTracker: pool-id | dpnf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPSFScoreAttributionKey:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Composite key for AQP|T|DPSFScoreAttribution: pool | dpsf | owner | beneficiary | nonce | score-id."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce]) BAR score-id])
    )
    (defun UC_DPNFScoreAttributionKey:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Composite key for AQP|T|DPNFScoreAttribution: pool | dpnf | owner | beneficiary | nonce | score-id."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce]) BAR score-id])
    )
    (defun UC_BeneficiaryDptfTotalKey:string (beneficiary-id:string dptf-id:string)
        @doc "Composite key for AQP|T|BeneficiaryDptfTotal: beneficiary-id | dptf-id."
        (concat [beneficiary-id BAR dptf-id])
    )
    ;;
    ;;{F3}  [UDC]
    ;; Default tracker and attribution rows for UR with-default-read.
    (defun UDC_AQP|TrueFungibleTracker:object{AQP|TrueFungibleTracker}
        (bal:decimal pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Default DPTF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dptf-id"          : dptf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id}
    )
    (defun UDC_AQP|OrtoFungibleTracker:object{AQP|OrtoFungibleTracker}
        (bal:decimal pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPOF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpof-id"          : dpof-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|SemiFungibleTracker:object{AQP|SemiFungibleTracker}
        (bal:decimal pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPSF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpsf-id"          : dpsf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|NonFungibleTracker:object{AQP|NonFungibleTracker}
        (bal:decimal pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPNF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpnf-id"          : dpnf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|DPSFScoreAttribution:object{AQP|DPSFScoreAttribution}
        (cached:decimal rev:integer pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Default DPSF score attribution row."
        {"cached-position-score"        : cached
        ,"applied-def-revision-nonce"   : rev
        ,"pool-id"                      : pool-id
        ,"dpsf-id"                      : dpsf-id
        ,"owner-id"                     : owner-id
        ,"beneficiary-id"               : beneficiary-id
        ,"nonce"                        : nonce
        ,"score-id"                     : score-id}
    )
    (defun UDC_AQP|DPNFScoreAttribution:object{AQP|DPNFScoreAttribution}
        (cached:decimal rev:integer pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Default DPNF score attribution row."
        {"cached-position-score"        : cached
        ,"applied-def-revision-nonce"   : rev
        ,"pool-id"                      : pool-id
        ,"dpnf-id"                      : dpnf-id
        ,"owner-id"                     : owner-id
        ,"beneficiary-id"               : beneficiary-id
        ,"nonce"                        : nonce
        ,"score-id"                     : score-id}
    )
    (defun UDC_AQP|BeneficiaryDptfTotal:object{AQP|BeneficiaryDptfTotal}
        (total:decimal sync-count:integer beneficiary-id:string dptf-id:string)
        @doc "Default beneficiary DPTF rollup row (zero total, never synced)."
        {"total-balance"        : total
        ,"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_AQP|Schema:object{AQP|Schema}
        (aqp-class:integer asset-id:string aqp-id:string)
        @doc "Default new pool row: all seven score slots BAR; aqp-id equals pool-id (table key)."
        {"aqp-class"            : aqp-class
        ,"asset-id"             : asset-id
        ,"score-primary"        : BAR
        ,"score-secondary"      : BAR
        ,"score-tertiary"       : BAR
        ,"score-quaternary"     : BAR
        ,"score-quinary"        : BAR
        ,"score-senary"         : BAR
        ,"score-septenary"      : BAR
        ,"aqp-id"               : aqp-id}
    )
    (defun UDC_AQP|SchemaWithScoreSlots:object{AQP|Schema}
        (pool:object{AQP|Schema}
            score-primary:string
            score-secondary:string
            score-tertiary:string
            score-quaternary:string
            score-quinary:string
            score-senary:string
            score-septenary:string
        )
        @doc "Returns pool row with all seven score slots replaced (+ merge on existing row)."
        (+ pool
            {"score-primary"    : score-primary
            ,"score-secondary"  : score-secondary
            ,"score-tertiary"   : score-tertiary
            ,"score-quaternary" : score-quaternary
            ,"score-quinary"    : score-quinary
            ,"score-senary"     : score-senary
            ,"score-septenary"  : score-septenary}
        )
    )
    (defun UDC_AQP|SchemaWithScoreAtSlot:object{AQP|Schema}
        (pool:object{AQP|Schema} slot-index:integer score-id:string)
        @doc "Returns pool row with score-id written into slot-index (0=primary .. 6=septenary)."
        (UDC_AQP|SchemaWithScoreSlots pool
            (if (= slot-index 0) score-id (at "score-primary" pool))
            (if (= slot-index 1) score-id (at "score-secondary" pool))
            (if (= slot-index 2) score-id (at "score-tertiary" pool))
            (if (= slot-index 3) score-id (at "score-quaternary" pool))
            (if (= slot-index 4) score-id (at "score-quinary" pool))
            (if (= slot-index 5) score-id (at "score-senary" pool))
            (if (= slot-index 6) score-id (at "score-septenary" pool))
        )
    )
    (defun UC_PoolScoreSlotPatch:object
        (slot-index:integer score-id:string)
        @doc "Partial AQP|T|Pool update map for one score slot (0=primary .. 6=septenary)."
        (if (= slot-index 0)
            {"score-primary": score-id}
            (if (= slot-index 1)
                {"score-secondary": score-id}
                (if (= slot-index 2)
                    {"score-tertiary": score-id}
                    (if (= slot-index 3)
                        {"score-quaternary": score-id}
                        (if (= slot-index 4)
                            {"score-quinary": score-id}
                            (if (= slot-index 5)
                                {"score-senary": score-id}
                                {"score-septenary": score-id}
                            )
                        )
                    )
                )
            )
        )
    )
    ;;
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (2b) BeneficiaryDptfTotal \
    ;;     (3) OrtoFungibleTracker (4) SemiFungibleTracker (5) NonFungibleTracker \
    ;;     (6) DPSFScoreAttribution (7) DPNFScoreAttribution
    ;;
    ;; [1] AQP|T|Pool  (AQP|Schema)  Key = <Pool-ID>
    (defun UR_AQP|AllPoolIds:[string] ()
        @doc "Returns all row keys from AQP|T|Pool."
        (keys AQP|T|Pool)
    )
    (defun UR_AQP|Pool:object{AQP|Schema} (pool-id:string)
        @doc "Reads full pool definition row from AQP|T|Pool."
        (read AQP|T|Pool pool-id)
    )
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string)
        @doc "Reads aqp-class from pool row."
        (at "aqp-class" (read AQP|T|Pool pool-id ["aqp-class"]))
    )
    (defun UR_AQP|PoolAssetId:string (pool-id:string)
        @doc "Reads canonical asset-id from pool row."
        (at "asset-id" (read AQP|T|Pool pool-id ["asset-id"]))
    )
    (defun UR_AQP|PoolScorePrimary:string (pool-id:string)
        @doc "Reads score-primary slot from pool row."
        (at "score-primary" (read AQP|T|Pool pool-id ["score-primary"]))
    )
    (defun UR_AQP|PoolScoreSecondary:string (pool-id:string)
        @doc "Reads score-secondary slot from pool row."
        (at "score-secondary" (read AQP|T|Pool pool-id ["score-secondary"]))
    )
    (defun UR_AQP|PoolScoreTertiary:string (pool-id:string)
        @doc "Reads score-tertiary slot from pool row."
        (at "score-tertiary" (read AQP|T|Pool pool-id ["score-tertiary"]))
    )
    (defun UR_AQP|PoolScoreQuaternary:string (pool-id:string)
        @doc "Reads score-quaternary slot from pool row."
        (at "score-quaternary" (read AQP|T|Pool pool-id ["score-quaternary"]))
    )
    (defun UR_AQP|PoolScoreQuinary:string (pool-id:string)
        @doc "Reads score-quinary slot from pool row."
        (at "score-quinary" (read AQP|T|Pool pool-id ["score-quinary"]))
    )
    (defun UR_AQP|PoolScoreSenary:string (pool-id:string)
        @doc "Reads score-senary slot from pool row."
        (at "score-senary" (read AQP|T|Pool pool-id ["score-senary"]))
    )
    (defun UR_AQP|PoolScoreSeptenary:string (pool-id:string)
        @doc "Reads score-septenary slot from pool row."
        (at "score-septenary" (read AQP|T|Pool pool-id ["score-septenary"]))
    )
    (defun UR_AQP|PoolAqpId:string (pool-id:string)
        @doc "Reads aqp-id field from pool row."
        (at "aqp-id" (read AQP|T|Pool pool-id ["aqp-id"]))
    )
    ;;
    ;; [2] AQP|T|DPTFTracker  (AQP|TrueFungibleTracker)
    (defun UR_AQP|DPTFTracker:object{AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads DPTF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPTFTracker (UC_DPTFTrackerKey pool-id dptf-id owner-id beneficiary-id)
            (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dptf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid}
            (UDC_AQP|TrueFungibleTracker bal pid did oid bid)
        )
    )
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads staked DPTF balance from tracker row."
        (at "balance" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads pool-id from DPTF tracker row."
        (at "pool-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads dptf-id from DPTF tracker row."
        (at "dptf-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads owner-id from DPTF tracker row."
        (at "owner-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads beneficiary-id from DPTF tracker row."
        (at "beneficiary-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    ;;
    ;; [2b] AQP|T|BeneficiaryDptfTotal  (AQP|BeneficiaryDptfTotal)
    (defun UR_AQP|BeneficiaryDptfTotal:object{AQP|BeneficiaryDptfTotal}
        (beneficiary-id:string dptf-id:string)
        @doc "Reads cross-pool DPTF stake rollup for beneficiary × dptf-id; absent row reads as zero total."
        (with-default-read AQP|T|BeneficiaryDptfTotal (UC_BeneficiaryDptfTotalKey beneficiary-id dptf-id)
            (UDC_AQP|BeneficiaryDptfTotal 0.0 0 beneficiary-id dptf-id)
            {"total-balance"        := tb
            ,"last-ank-sync-count"  := sc
            ,"beneficiary-id"       := bid
            ,"dptf-id"              := did}
            (UDC_AQP|BeneficiaryDptfTotal tb sc bid did)
        )
    )
    (defun UR_AQP|BeneficiaryDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string)
        @doc "Total DPTF staked by beneficiary across all pools for this exact dptf-id leg."
        (at "total-balance" (UR_AQP|BeneficiaryDptfTotal beneficiary-id dptf-id))
    )
    (defun UR_AQP|BeneficiaryDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string)
        @doc "ANK anchors-active count recorded at last anchor sync for this beneficiary × dptf-id."
        (at "last-ank-sync-count" (UR_AQP|BeneficiaryDptfTotal beneficiary-id dptf-id))
    )
    (defun URC_BeneficiaryAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string)
        @doc "True when beneficiary has positive cross-pool stake on dptf-id and ANK has more live anchors \
            \ than were applied at last sync — UI signal for C_SyncTrueFungibleAnchors."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (total:decimal (UR_AQP|BeneficiaryDptfTotalBalance beneficiary-id dptf-id))
                (last-sync:integer (UR_AQP|BeneficiaryDptfLastAnkSyncCount beneficiary-id dptf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
            )
            (and (> total 0.0) (> live-count last-sync))
        )
    )
    ;;
    ;; [3] AQP|T|DPOFTracker  (AQP|OrtoFungibleTracker)
    (defun UR_AQP|DPOFTracker:object{AQP|OrtoFungibleTracker}
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPOF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPOFTracker (UC_DPOFTrackerKey pool-id dpof-id owner-id beneficiary-id nonce)
            (UDC_AQP|OrtoFungibleTracker 0.0 pool-id dpof-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpof-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|OrtoFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPOF balance from tracker row."
        (at "balance" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPOF tracker row."
        (at "pool-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpof-id from DPOF tracker row."
        (at "dpof-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPOF tracker row."
        (at "owner-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPOF tracker row."
        (at "beneficiary-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPOF tracker row."
        (at "nonce" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [4] AQP|T|DPSFTracker  (AQP|SemiFungibleTracker)
    (defun UR_AQP|DPSFTracker:object{AQP|SemiFungibleTracker}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPSF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPSFTracker (UC_DPSFTrackerKey pool-id dpsf-id owner-id beneficiary-id nonce)
            (UDC_AQP|SemiFungibleTracker 0.0 pool-id dpsf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpsf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|SemiFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPSF balance from tracker row."
        (at "balance" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPSF tracker row."
        (at "pool-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpsf-id from DPSF tracker row."
        (at "dpsf-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPSF tracker row."
        (at "owner-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPSF tracker row."
        (at "beneficiary-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPSF tracker row."
        (at "nonce" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [5] AQP|T|DPNFTracker  (AQP|NonFungibleTracker)
    (defun UR_AQP|DPNFTracker:object{AQP|NonFungibleTracker}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPNF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPNFTracker (UC_DPNFTrackerKey pool-id dpnf-id owner-id beneficiary-id nonce)
            (UDC_AQP|NonFungibleTracker 0.0 pool-id dpnf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpnf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|NonFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPNF balance from tracker row."
        (at "balance" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPNF tracker row."
        (at "pool-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpnf-id from DPNF tracker row."
        (at "dpnf-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPNF tracker row."
        (at "owner-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPNF tracker row."
        (at "beneficiary-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPNF tracker row."
        (at "nonce" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [6] AQP|T|DPSFScoreAttribution  (AQP|DPSFScoreAttribution)
    (defun UR_AQP|DPSFScoreAttribution:object{AQP|DPSFScoreAttribution}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads DPSF score attribution row; absent rows read as zero cache and revision 0."
        (with-default-read AQP|T|DPSFScoreAttribution
            (UC_DPSFScoreAttributionKey pool-id dpsf-id owner-id beneficiary-id nonce score-id)
            (UDC_AQP|DPSFScoreAttribution 0.0 0 pool-id dpsf-id owner-id beneficiary-id nonce score-id)
            {"cached-position-score"         := cps
            ,"applied-def-revision-nonce"   := arn
            ,"pool-id"                      := pid
            ,"dpsf-id"                      := did
            ,"owner-id"                     := oid
            ,"beneficiary-id"               := bid
            ,"nonce"                        := n
            ,"score-id"                     := sid}
            (UDC_AQP|DPSFScoreAttribution cps arn pid did oid bid n sid)
        )
    )
    (defun UR_AQP|DPSFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads cached-position-score from DPSF score attribution row."
        (at "cached-position-score" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads applied-def-revision-nonce from DPSF score attribution row."
        (at "applied-def-revision-nonce" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionPoolId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads pool-id from DPSF score attribution row."
        (at "pool-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionDpsfId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads dpsf-id from DPSF score attribution row."
        (at "dpsf-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionOwnerId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads owner-id from DPSF score attribution row."
        (at "owner-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionBeneficiaryId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads beneficiary-id from DPSF score attribution row."
        (at "beneficiary-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads nonce from DPSF score attribution row."
        (at "nonce" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionScoreId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads score-id from DPSF score attribution row."
        (at "score-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    ;;
    ;; [7] AQP|T|DPNFScoreAttribution  (AQP|DPNFScoreAttribution)
    (defun UR_AQP|DPNFScoreAttribution:object{AQP|DPNFScoreAttribution}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads DPNF score attribution row; absent rows read as zero cache and revision 0."
        (with-default-read AQP|T|DPNFScoreAttribution
            (UC_DPNFScoreAttributionKey pool-id dpnf-id owner-id beneficiary-id nonce score-id)
            (UDC_AQP|DPNFScoreAttribution 0.0 0 pool-id dpnf-id owner-id beneficiary-id nonce score-id)
            {"cached-position-score"         := cps
            ,"applied-def-revision-nonce"   := arn
            ,"pool-id"                      := pid
            ,"dpnf-id"                      := did
            ,"owner-id"                     := oid
            ,"beneficiary-id"               := bid
            ,"nonce"                        := n
            ,"score-id"                     := sid}
            (UDC_AQP|DPNFScoreAttribution cps arn pid did oid bid n sid)
        )
    )
    (defun UR_AQP|DPNFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads cached-position-score from DPNF score attribution row."
        (at "cached-position-score" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads applied-def-revision-nonce from DPNF score attribution row."
        (at "applied-def-revision-nonce" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionPoolId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads pool-id from DPNF score attribution row."
        (at "pool-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionDpnfId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads dpnf-id from DPNF score attribution row."
        (at "dpnf-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionOwnerId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads owner-id from DPNF score attribution row."
        (at "owner-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionBeneficiaryId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads beneficiary-id from DPNF score attribution row."
        (at "beneficiary-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads nonce from DPNF score attribution row."
        (at "nonce" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionScoreId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads score-id from DPNF score attribution row."
        (at "score-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    ;;
    ;;{F1}  [URC]
    (defun URC_AqpOwnerKontoFromClassAndAsset:string (aqp-class:integer asset-id:string)
        @doc "Resolve pool governor konto from aqp-class and canonical native asset-id (issue-time or pre-pool-row)."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (if (= aqp-class 0)
                (ref-SWP::UR_OwnerKonto (ref-SWP::UR_GetLpSwpair asset-id))
                (if (= aqp-class 1)
                    (ref-DPTF::UR_Konto asset-id)
                    (if (= aqp-class 2)
                        (ref-DPOF::UR_Konto asset-id)
                        (if (= aqp-class 3)
                            (ref-DPDC::UR_OwnerKonto asset-id true)
                            (ref-DPDC::UR_OwnerKonto asset-id false)
                        )
                    )
                )
            )
        )
    )
    (defun URC_AqpOwnerKonto:string (pool-id:string)
        @doc "Resolve pool governor konto from AQP|T|Pool via URC_AqpOwnerKontoFromClassAndAsset."
        (URC_AqpOwnerKontoFromClassAndAsset (UR_AQP|PoolAqpClass pool-id) (UR_AQP|PoolAssetId pool-id))
    )
    (defun URC_PoolActiveScoreIds:[string] (pool-id:string)
        @doc "Non-BAR score-id values currently assigned on pool-id (primary through septenary order)."
        (filter
            (lambda (sid:string) (!= sid BAR))
            [
                (UR_AQP|PoolScorePrimary pool-id)
                (UR_AQP|PoolScoreSecondary pool-id)
                (UR_AQP|PoolScoreTertiary pool-id)
                (UR_AQP|PoolScoreQuaternary pool-id)
                (UR_AQP|PoolScoreQuinary pool-id)
                (UR_AQP|PoolScoreSenary pool-id)
                (UR_AQP|PoolScoreSeptenary pool-id)
            ]
        )
    )
    (defun URC_StakeTrueFungibleDptfMatchesPool:bool (pool-id:string dptf-id:string)
        @doc "True when dptf-id (native or F| frozen leg) matches pool canonical asset-id for class 0/1 TF stake."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
                (core:string
                    (if (= (URC_DptfLegPrefix dptf-id) "F|")
                        (drop 2 dptf-id)
                        dptf-id
                    )
                )
            )
            (if (= c 1)
                (= core asset-id)
                (if (= c 0)
                    (and (URC_DptfIsLpNomenclature dptf-id) (= core asset-id))
                    false
                )
            )
        )
    )
    (defun URC_PoolScoreSlotValue:string (pool-id:string slot-index:integer)
        @doc "Score-id at pool score slot 0..6 (primary..septenary); read via UR_AQP|PoolScore* helpers."
        (if (= slot-index 0)
            (UR_AQP|PoolScorePrimary pool-id)
            (if (= slot-index 1)
                (UR_AQP|PoolScoreSecondary pool-id)
                (if (= slot-index 2)
                    (UR_AQP|PoolScoreTertiary pool-id)
                    (if (= slot-index 3)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (if (= slot-index 4)
                            (UR_AQP|PoolScoreQuinary pool-id)
                            (if (= slot-index 5)
                                (UR_AQP|PoolScoreSenary pool-id)
                                (UR_AQP|PoolScoreSeptenary pool-id)
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URC_PriorScoreSlotsOccupied:bool (pool-id:string slot-index:integer)
        @doc "Every slot index below slot-index is non-BAR; vacuously true when slot-index is 0."
        (if (= slot-index 0)
            true
            (fold (and) true
                (map
                    (lambda (i:integer) (!= (URC_PoolScoreSlotValue pool-id i) BAR))
                    (enumerate 0 (- slot-index 1))
                )
            )
        )
    )
    (defun URC_FirstFreeScoreSlotIndex:integer (pool-id:string)
        @doc "First empty score slot index 0..6 (primary..septenary), or -1 when all slots are taken."
        (if (= (UR_AQP|PoolScorePrimary pool-id) BAR)
            0
            (if (= (UR_AQP|PoolScoreSecondary pool-id) BAR)
                1
                (if (= (UR_AQP|PoolScoreTertiary pool-id) BAR)
                    2
                    (if (= (UR_AQP|PoolScoreQuaternary pool-id) BAR)
                        3
                        (if (= (UR_AQP|PoolScoreQuinary pool-id) BAR)
                            4
                            (if (= (UR_AQP|PoolScoreSenary pool-id) BAR)
                                5
                                (if (= (UR_AQP|PoolScoreSeptenary pool-id) BAR)
                                    6
                                    -1
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URC_ScoreSlotIndexForScore:integer (pool-id:string score-id:string)
        @doc "Slot index 0..6 where score-id is assigned on pool-id, or -1 when not employed."
        (let
            (
                (lst:[string]
                    [
                        (UR_AQP|PoolScorePrimary pool-id)
                        (UR_AQP|PoolScoreSecondary pool-id)
                        (UR_AQP|PoolScoreTertiary pool-id)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (UR_AQP|PoolScoreQuinary pool-id)
                        (UR_AQP|PoolScoreSenary pool-id)
                        (UR_AQP|PoolScoreSeptenary pool-id)
                    ]
                )
            )
            (cond
                ((= score-id (at 0 lst)) 0)
                ((= score-id (at 1 lst)) 1)
                ((= score-id (at 2 lst)) 2)
                ((= score-id (at 3 lst)) 3)
                ((= score-id (at 4 lst)) 4)
                ((= score-id (at 5 lst)) 5)
                ((= score-id (at 6 lst)) 6)
                -1
            )
        )
    )
    (defun URC_NoEmployedBoostLinkTarget:bool (pool-id:string score-id:string)
        @doc "True when no other employed pool score has boost-link pointing at score-id (triplet hub protection)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (active-ids:[string] (URC_PoolActiveScoreIds pool-id))
            )
            (fold (and) true
                (map
                    (lambda (peer-id:string)
                        (if (= peer-id score-id)
                            true
                            (!= (ref-SCR::UR_SCR|ScoreBoostLink peer-id) score-id)
                        )
                    )
                    active-ids
                )
            )
        )
    )
    (defun URC_DptfLegPrefix:string (dptf-id:string)
        @doc "First two characters of dptf-id (F|, R|, S|, W|, P|, or empty for short ids)."
        (take 2 dptf-id)
    )
    (defun URC_DptfStakeIsNativeLeg:bool (dptf-id:string)
        @doc "True when dptf-id is a native TF stake leg (not F| frozen prefix). Used for SCORE native-or-frozen internal flag."
        (!= (URC_DptfLegPrefix dptf-id) "F|")
    )
    (defun URC_DptfStakeIsReservedLeg:bool (dptf-id:string)
        @doc "True when dptf-id is R| reserved — stake paths reject this leg."
        (= (URC_DptfLegPrefix dptf-id) "R|")
    )
    (defun URC_DptfIsLpNomenclature:bool (dptf-id:string)
        @doc "True when dptf-id (after optional F| strip) uses LP token nomenclature S|, W|, or P|."
        (let
            (
                (p2:string (URC_DptfLegPrefix dptf-id))
                (core:string
                    (if (= p2 "F|")
                        (drop 2 dptf-id)
                        dptf-id
                    )
                )
            )
            (contains (take 2 core) ["S|" "W|" "P|"])
        )
    )
    (defun URC_PoolHasEmployedScores:bool (pool-id:string)
        @doc "True when pool-id has at least one non-BAR score slot (required before stake)."
        (> (length (URC_PoolActiveScoreIds pool-id)) 0)
    )
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP via TF) or 1 (non-LP DPTF)."
        (let ((c:integer (UR_AQP|PoolAqpClass pool-id)))
            (or (= c 0) (= c 1))
        )
    )
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP + Z| orto), 1 (DPTF + sleep/hib DPOF satellites), or 2 (native DPOF)."
        (let ((c:integer (UR_AQP|PoolAqpClass pool-id)))
            (or (= c 0) (or (= c 1) (= c 2)))
        )
    )
    (defun URC_DpofLegPrefix:string (dpof-id:string)
        @doc "First two characters of dpof-id (Z|, H|, or native collection prefix)."
        (take 2 dpof-id)
    )
    (defun URC_StakeOrtoFungibleDpofMatchesPool:bool (pool-id:string dpof-id:string)
        @doc "True when dpof-id is an allowed OF leg for pool aqp-class and canonical asset-id: \
            \ class 2 native circulating; class 1 Z|/H| satellite linked to pool DPTF; class 0 Z| orto LP linked to pool native LP."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (c:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
                (p2:string (URC_DpofLegPrefix dpof-id))
            )
            (if (= c 2)
                (and
                    (= dpof-id asset-id)
                    (not (contains p2 ["Z|" "H|"]))
                )
                (if (= c 1)
                    (or
                        (and (= p2 "Z|") (= (ref-DPOF::UR_Sleeping dpof-id) asset-id))
                        (and (= p2 "H|") (= (ref-DPOF::UR_Hibernation dpof-id) asset-id))
                    )
                    (if (= c 0)
                        (and
                            (= p2 "Z|")
                            (URC_DptfIsLpNomenclature asset-id)
                            (= (ref-DPOF::UR_Sleeping dpof-id) asset-id)
                        )
                        false
                    )
                )
            )
        )
    )
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount. v1 reads beneficiary from self-stake key (owner, owner)."
        (let
            (
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (q:decimal (at idx nonce-amounts))
                                (bid:string (UR_AQP|DPOFTrackerBeneficiaryId pool-id dpof-id owner-id owner-id n))
                                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id bid n))
                            )
                            (>= bal q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_OrtoUnstakeBeneficiaryId:string
        (pool-id:string dpof-id:string owner-id:string nonce:integer)
        @doc "Unstake: read beneficiary-id from DPOF tracker row. v1 uses self-stake key (beneficiary=owner); explicit beneficiary unstake TBD."
        (UR_AQP|DPOFTrackerBeneficiaryId pool-id dpof-id owner-id owner-id nonce)
    )
    (defun URC_OrtoStakeWholeNonceAmounts:bool
        (dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "True when each nonce-amount equals the full DPOF nonce supply (whole-nonce stake/unstake only)."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (l:integer (length nonces))
            )
            (enforce (= l (length nonce-amounts)) "whole-nonce check: nonces and amounts length mismatch")
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (q:decimal (at idx nonce-amounts))
                            )
                            (= q (ref-DPOF::UR_NonceSupply dpof-id n))
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    ;;
    ;;{F2}  [UEV]
    (defun UEV_IssuePoolClassAndAsset (aqp-class:integer asset-id:string)
        @doc "aqp-class 0..4 and asset-id existence / shape for that class (native id only at issue)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (p2:string (take 2 asset-id))
                (is-class-ok:bool (contains aqp-class (enumerate 0 4)))
                (is-native:bool
                    (not
                        (fold (or) false
                            [(= p2 "F|") (= p2 "Z|") (= p2 "H|") (= p2 "V|") (= p2 "R|")]
                        )
                    )
                )
            )
            (if (or (= aqp-class 0) (= aqp-class 1))
                (ref-DPTF::UEV_id asset-id)
                (if (= aqp-class 2)
                    (ref-DPOF::UEV_id asset-id)
                    (if (= aqp-class 3)
                        (ref-DPDC::UEV_id asset-id true)
                        (ref-DPDC::UEV_id asset-id false)
                    )
                )
            )
            (enforce
                (fold (and) true
                    [
                        is-class-ok
                        is-native
                        (if (<= aqp-class 2)
                            (enforce-one
                                "Invalid pool issue asset-id for aqp-class"
                                [
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 0)
                                                (contains p2 ["S|" "W|" "P|"])
                                                (= asset-id (ref-SWP::UR_TokenLP (ref-SWP::UR_GetLpSwpair asset-id)))
                                            ]
                                        )
                                        "class 0 asset-id must be native LP nomenclature matching its swap pair"
                                    )
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 1)
                                                (not (contains p2 ["S|" "W|" "P|"]))
                                            ]
                                        )
                                        "class 1 asset-id must be a non-LP DPTF"
                                    )
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 2)
                                                (not
                                                    (fold (or) false
                                                        [
                                                            (= (take 2 (ref-DPOF::UR_Ticker asset-id)) "Z|")
                                                            (= (take 2 (ref-DPOF::UR_Ticker asset-id)) "H|")
                                                        ]
                                                    )
                                                )
                                            ]
                                        )
                                        "class 2 asset-id must not be a sleeping or hibernating DPOF collection"
                                    )
                                ]
                            )
                            true
                        )
                    ]
                )
                "Invalid pool issue aqp-class or asset-id"
            )
        )
    )
    (defun UEV_AddScorePoolAndScore (pool-id:string score-id:string slot-index:integer)
        @doc "Validates slot-index is the first free slot (caller supplies index from one URC_FirstFreeScoreSlotIndex); \
            \ score exists with BAR aqpool-link; score-class matches pool; class-0 lp-denominator fits pool LP pair."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (aqp-class:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
            )
            (enforce
                (fold (and) true
                    [
                        (contains slot-index (enumerate 0 6))
                        (= (URC_PoolScoreSlotValue pool-id slot-index) BAR)
                        (URC_PriorScoreSlotsOccupied pool-id slot-index)
                    ]
                )
                "Invalid or unavailable score slot index for pool"
            )
            (enforce
                (fold (and) true
                    [
                        (= (ref-SCR::UR_SCR|ScoreScoreId score-id) score-id)
                        (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) BAR)
                        (= (ref-SCR::UR_SCR|ScoreClass score-id) aqp-class)
                        (not (contains score-id (URC_PoolActiveScoreIds pool-id)))
                    ]
                )
                "Invalid score-id for pool assignment (missing score, class mismatch, aqpool-link set, or duplicate slot)"
            )
            (enforce
                (if (= aqp-class 0)
                    (let
                        (
                            (lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator score-id))
                            (swpair:string (ref-SWP::UR_GetLpSwpair asset-id))
                            (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                        )
                        (contains lp-denom pool-tokens)
                    )
                    true
                )
                "Class 0 score lp-denominator must appear in the swap pair for the pool native LP asset-id"
            )
        )
    )
    (defun UEV_RevokeScorePoolAndScore (pool-id:string score-id:string slot-index:integer)
        @doc "Validates slot-index holds score-id with aqpool-link = pool-id, zero totals, fvt-link BAR, \
            \ and no employed peer has boost-link = score-id (revoke dependents before hub)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (enforce
                (fold (and) true
                    [
                        (contains slot-index (enumerate 0 6))
                        (= (URC_PoolScoreSlotValue pool-id slot-index) score-id)
                        (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (ref-SCR::UR_SCR|ScoreTotalBaseScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreTotalBoostedScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreTotalDebScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreNzsCount score-id) 0)
                        (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) BAR)
                        (URC_NoEmployedBoostLinkTarget pool-id score-id)
                    ]
                )
                "Invalid score revoke for pool (slot, aqpool-link, zero totals, fvt-link, or boost-link dependents)"
            )
        )
    )
    (defun UEV_StakeBeneficiaryAccount (beneficiary-id:string)
        @doc "Stake paths: beneficiary must exist and be an activated standard (non-principal) Ouronet account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists beneficiary-id)
            (ref-DALOS::UEV_EnforceAccountType beneficiary-id false)
        )
    )
    (defun UEV_StakeTrueFungibleDptfLeg (dptf-id:string)
        @doc "Reject R| reserved; validate DPTF id exists via DPTF::UEV_id."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (enforce (not (URC_DptfStakeIsReservedLeg dptf-id)) "Reserved DPTF (R|) cannot be staked")
            (ref-DPTF::UEV_id dptf-id)
        )
    )
    (defun UEV_StakeOrtoFungibleDpofLeg (dpof-id:string)
        @doc "Validate issued DPOF id via DPOF::UEV_id."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
            )
            (ref-DPOF::UEV_id dpof-id)
        )
    )
    ;;
    ;;{F4}  [CAP]
    (defun CAP_AqpAssetOwner (aqp-class:integer asset-id:string)
        @doc "Issue / pre-pool: tx sender must own the canonical asset for aqp-class and asset-id."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id))
        )
    )
    (defun CAP_PoolOwner (pool-id:string)
        @doc "Post-issue pool governance: tx sender must own the canonical asset behind pool-id (URC_AqpOwnerKonto)."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKonto pool-id))
        )
    )
    (defun CAP_StakeOwner (owner-id:string)
        @doc "Stake / unstake: tx sender must own owner-id (depositor of tokens)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-id)
        )
    )
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Lifecycle (AQP|T|Pool / AQP|Schema)
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Create a new pool (canonical native asset-id + aqp-class). Patron pays STOA smart + IGNIS; \
            \ returns pool-id in output list. Score slots start BAR."
        (UEV_IMC)
        (with-capability (AQP|C>ISSUE-POOL pool-name asset-id aqp-class)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_IssuePool pool-id aqp-class asset-id)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-POOL AQP|SC_NAME trigger [pool-id])
            )
        )
    )
    ;;Score slots (score-primary … score-septenary); score-class must match pool aqp-class.
    (defun C_AddScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string score-id:string)
        @doc "Assign score-id to the first free pool slot; SCR XE_CreateAqpoolLink then XI pool slot write. \
            \ URC_FirstFreeScoreSlotIndex runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|ADD-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (UEV_IMC)
        (let 
            (
                (slot-index:integer (URC_FirstFreeScoreSlotIndex pool-id))
            )
            (with-capability (AQP|C>ADD-SCORE pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_CreateAqpoolLink score-id pool-id)
                    (XI_AddScoreToPool pool-id score-id slot-index)
                    (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ADD-SCORE AQP|SC_NAME trigger [pool-id score-id])
                )
            )
        )
    )
    (defun C_RevokeScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string score-id:string)
        @doc "Clear score-id from its pool slot (compact higher slots); SCR XE_RevokeAqpoolLink then XI pool slot write. \
            \ URC_ScoreSlotIndexForScore runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|REVOKE-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (UEV_IMC)
        (let
            (
                (slot-index:integer (URC_ScoreSlotIndexForScore pool-id score-id))
            )
            (enforce (!= slot-index -1) "score-id is not assigned to pool")
            (with-capability (AQP|C>REVOKE-SCORE pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_RevokeAqpoolLink score-id pool-id)
                    (XI_RevokeScoreFromPool pool-id slot-index)
                    (ref-IGNIS::UDC_ConstructOutputCumulator GAS|REVOKE-SCORE AQP|SC_NAME trigger [pool-id score-id])
                )
            )
        )
    )
    ;;
    ;;=== PLANNED C_* (comment-only — not on interface; home module TBD at implementation) ===
    ;; TF stake/unstake recipe lives in FVT::C_TrueFungibleStakeFlow; POOL phase-1 is XE_TrueFungiblePoolCustody.
    ;;
    ;; C_StakeOrtoFungible(patron pool-id owner-id beneficiary-id dpof-id nonces)
    ;;   Stake whole DPOF nonces into pool-id (AQP|T|DPOFTracker) via DPOF::C_Transfer only.
    ;;   Covers class-2 native DPOF, class-0 sleeping|Z| LP orto legs, class-1 sleeping/hib DPOF satellites.
    ;;
    ;; C_UnstakeOrtoFungible(patron pool-id owner-id dpof-id nonces)
    ;;   Unstake DPOF nonces from pool-id; assets return to owner-id. beneficiary-id not on API — read from tracker row.
    ;;
    ;; C_StakeCollectable(patron pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts)
    ;;   Stake DPDC collectable nonces via DPDC-T transfer to AQP|SC_NAME. son=true -> DPSF; son=false -> DPNF.
    ;;
    ;; C_UnstakeCollectable(patron pool-id owner-id collectable-id son nonces nonce-amounts)
    ;;   Unstake DPDC collectable nonces; beneficiary read from tracker row per nonce.
    ;;
    ;; C_SyncTrueFungibleAnchors(patron beneficiary-id dptf-id)
    ;;   Pool-agnostic ANK repair: read AQP|T|BeneficiaryDptfTotal.total-balance (O(1)),
    ;;   ANK::XE_UpdateTrueFungibleUserAnchorValues, set last-ank-sync-count. Home module TBD.
    ;;
    ;; C_VacatePool(patron pool-id)
    ;;   Pool owner (CAP_PoolOwner): unwind every staked position on pool-id. Orchestration TBD.
    ;;
    ;;{F7}  [X]
    ;; Depth: C_* → XI_* (depth 0) ; XE_* / XB_* → XI_1|* (depth 1). Map order = entry first.
    ;;
    ;; --- Block A · C_* pool lifecycle ---
    ;;   C_Issue → XI_IssuePool
    ;;   C_AddScore → XI_AddScoreToPool
    ;;   C_RevokeScore → XI_RevokeScoreFromPool
    ;;
    (defun XI_IssuePool:string
        (pool-id:string aqp-class:integer asset-id:string)
        @doc "Insert AQP|T|Pool under SECURE (from AQP|C>ISSUE-POOL). Write only; C_Issue builds IGNIS."
        (require-capability (SECURE))
        (insert AQP|T|Pool pool-id (UDC_AQP|Schema aqp-class asset-id pool-id))
        pool-id
    )
    (defun XI_AddScoreToPool:string
        (pool-id:string score-id:string slot-index:integer)
        @doc "Write score-id into the first free slot (0=primary .. 6=septenary). Under SECURE from AQP|C>ADD-SCORE."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id (UC_PoolScoreSlotPatch slot-index score-id))
        (enforce
            (= (URC_PoolScoreSlotValue pool-id slot-index) score-id)
            "XI_AddScoreToPool: pool score slot write did not persist"
        )
        score-id
    )
    (defun XI_RevokeScoreFromPool:string
        (pool-id:string slot-index:integer)
        @doc "Remove score at slot-index and compact higher slots down (0=primary .. 6=septenary). Under SECURE from AQP|C>REVOKE-SCORE."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (lst:[string]
                    [
                        (UR_AQP|PoolScorePrimary pool-id)
                        (UR_AQP|PoolScoreSecondary pool-id)
                        (UR_AQP|PoolScoreTertiary pool-id)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (UR_AQP|PoolScoreQuinary pool-id)
                        (UR_AQP|PoolScoreSenary pool-id)
                        (UR_AQP|PoolScoreSeptenary pool-id)
                    ]
                )
                (lst-v1:[string] (ref-U|LST::UC_RemoveItemAt lst slot-index))
                (lst-v2:[string] (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (update AQP|T|Pool pool-id
                (UDC_AQP|SchemaWithScoreSlots (UR_AQP|Pool pool-id)
                    (at 0 lst-v2)
                    (at 1 lst-v2)
                    (at 2 lst-v2)
                    (at 3 lst-v2)
                    (at 4 lst-v2)
                    (at 5 lst-v2)
                    (at 6 lst-v2)
                )
            )
        )
    )
    ;;
    ;; --- Block B · Phase 1 custody (FVT::C_*StakeFlow) ---
    ;;   Phase 1 — move assets user↔vault and record pool-local + cross-pool custody.
    ;;   1.1 Transfer          UrStoa ≡ X_UR|Transfer
    ;;   1.2 Pool tracker      UrStoa ≡ (implicit in vault accounting)
    ;;   1.3 Beneficiary rollup UrStoa ≡ N/A (TF cross-pool O(1) for ANK)
    ;;
    (defun XE_Phase_1_1|TrueFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. TFT::C_Transfer owner↔AQP|SC_NAME. Composes custody cap (validation once per tx)."
        (UEV_IMC)
        (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dptf-id amount direction)
            (XI_1|TransferDptfPoolCustody owner-id dptf-id amount direction)
        )
    )
    (defun XE_Phase_1_2|TrueFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.2 — per-pool AQP|T|DPTFTracker row. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDptfTracker pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    (defun XE_Phase_1_3|TrueFungibleBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.3 — cross-pool AQP|T|BeneficiaryDptfTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBeneficiaryDptfTotal beneficiary-id dptf-id amount direction)
        )
    )
    (defun XE_TrueFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Legacy phase-1 concat (1.1 + 1.2 + 1.3). Prefer explicit XE_Phase_1_* in FVT recipe."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (XE_Phase_1_1|TrueFungibleTransfer pool-id owner-id beneficiary-id dptf-id amount direction)
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (XE_Phase_1_2|TrueFungiblePoolTracker pool-id owner-id beneficiary-id dptf-id amount direction)
                )
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (XE_Phase_1_3|TrueFungibleBeneficiaryRollup pool-id owner-id beneficiary-id dptf-id amount direction)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    (defun XE_Phase_1_1|OrtoFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPOF::C_Transfer whole nonces. Composes custody cap (validation once per tx)."
        (UEV_IMC)
        (with-capability (AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (XI_1|TransferDpofPoolCustody owner-id dpof-id nonces direction)
        )
    )
    (defun XE_Phase_1_2|OrtoFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Phase 1.2 — per-pool AQP|T|DPOFTracker rows. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDpofTracker pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
        )
    )
    (defun XE_OrtoFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Legacy phase-1 concat (1.1 + 1.2). Phase 1.3 N/A for OF. Prefer explicit XE_Phase_1_* in FVT recipe."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (XE_Phase_1_1|OrtoFungibleTransfer pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (XE_Phase_1_2|OrtoFungiblePoolTracker pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
        )
    )
    (defun XI_1|TransferDpofPoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (
            owner-id:string
            dpof-id:string
            nonces:[integer]
            direction:bool
        )
        @doc "DPOF::C_Transfer whole nonces: stake owner→AQP|SC_NAME; unstake vault→owner. \
            \ method=true (smart-account receive/send). Parent cap composes AQP-ANK.AQP|GOV for vault legs."
        (require-capability (SECURE))
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (vault:string AQP|SC_NAME)
                (sender:string (if direction owner-id vault))
                (receiver:string (if direction vault owner-id))
            )
            (ref-DPOF::C_Transfer dpof-id nonces sender receiver true)
        )
    )
    (defun XI_1|WriteDpofTracker:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Map XI_1|WriteDpofTrackerSlot — bump AQP|T|DPOFTracker ±nonce-amount per index."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (l:integer (length nonces))
                (slot-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (let
                                (
                                    (n:integer (at idx nonces))
                                    (bid:string
                                        (if direction
                                            beneficiary-id
                                            (URC_OrtoUnstakeBeneficiaryId pool-id dpof-id owner-id n)
                                        )
                                    )
                                )
                                (XI_1|WriteDpofTrackerSlot
                                    pool-id owner-id bid dpof-id n (at idx nonce-amounts) direction
                                )
                            )
                        )
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
        )
    )
    (defun XI_1|WriteDpofTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonce:integer
            amount:decimal
            direction:bool
        )
        @doc "One AQP|T|DPOFTracker row — read UR_AQP|DPOFTrackerBalance, write ±amount (cap validates unstake sufficiency)."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_DPOFTrackerKey pool-id dpof-id owner-id beneficiary-id nonce))
                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id nonce))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (write AQP|T|DPOFTracker key
                (UDC_AQP|OrtoFungibleTracker new-bal pool-id dpof-id owner-id beneficiary-id nonce)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|TransferDptfPoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (owner-id:string dptf-id:string amount:decimal direction:bool)
        @doc "TFT::C_Transfer dptf-id: stake (direction=true) owner→AQP|SC_NAME; unstake (false) AQP|SC_NAME→owner. \
            \ Returns TFT transfer OutputCumulator."
        (require-capability (SECURE))
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (vault:string AQP|SC_NAME)
            )
            (if direction
                (ref-TFT::C_Transfer dptf-id owner-id vault amount true)
                (ref-TFT::C_Transfer dptf-id vault owner-id amount true)
            )
        )
    )
    (defun XI_1|WriteDptfTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "AQP|T|DPTFTracker: bump balance ±amount for (pool, dptf-id, owner, beneficiary). \
            \ Read prior balance via UR_AQP|DPTFTrackerBalance; write only (no enforce — cap validates). \
            \ Returns ignis|medium via IGNIS::UDC_MediumCumulator."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_DPTFTrackerKey pool-id dptf-id owner-id beneficiary-id))
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (write AQP|T|DPTFTracker key
                (UDC_AQP|TrueFungibleTracker new-bal pool-id dptf-id owner-id beneficiary-id)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|BumpBeneficiaryDptfTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "AQP|T|BeneficiaryDptfTotal: bump total-balance ±amount for (beneficiary, dptf-id) across all pools. \
            \ Read via UR_AQP|BeneficiaryDptfTotal*; write only (no enforce — cap validates); preserves last-ank-sync-count. \
            \ Returns ignis|biggest via IGNIS::UDC_BiggestCumulator."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_BeneficiaryDptfTotalKey beneficiary-id dptf-id))
                (tb:decimal (UR_AQP|BeneficiaryDptfTotalBalance beneficiary-id dptf-id))
                (sc:integer (UR_AQP|BeneficiaryDptfLastAnkSyncCount beneficiary-id dptf-id))
                (delta:decimal (if direction amount (- amount)))
                (new-total:decimal (+ tb delta))
            )
            (write AQP|T|BeneficiaryDptfTotal key
                (UDC_AQP|BeneficiaryDptfTotal new-total sc beneficiary-id dptf-id)
            )
            (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
        )
    )
    ;;
    ;; --- Block C · TF stake phase 2.2 (FVT::XI_RefreshTrueFungibleStakeAnchors backward) ---
    ;;   XE_SetBeneficiaryDptfAnkSyncCount
    ;;
    (defun XE_SetBeneficiaryDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Backward (FVT::C_TrueFungibleStakeFlow phase 2.2]): set last-ank-sync-count on BeneficiaryDptfTotal \
            \ (:= AQP-ANK::UR_AA|AnchorsActive dptf-id); preserve total-balance. UEV_IMC + AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC. \
            \ Returns ignis|biggest via UDC_BiggestCumulator."
        (UEV_IMC)
        (with-capability (AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (key:string (UC_BeneficiaryDptfTotalKey beneficiary-id dptf-id))
                    (row:object{AQP|BeneficiaryDptfTotal} (UR_AQP|BeneficiaryDptfTotal beneficiary-id dptf-id))
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
                )
                (write AQP|T|BeneficiaryDptfTotal key
                    (+ row {"last-ank-sync-count": live-count})
                )
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table AQP|T|Pool)
(create-table AQP|T|DPTFTracker)
(create-table AQP|T|DPOFTracker)
(create-table AQP|T|DPSFTracker)
(create-table AQP|T|DPNFTracker)
(create-table AQP|T|DPSFScoreAttribution)
(create-table AQP|T|DPNFScoreAttribution)
(create-table AQP|T|BeneficiaryDptfTotal)
