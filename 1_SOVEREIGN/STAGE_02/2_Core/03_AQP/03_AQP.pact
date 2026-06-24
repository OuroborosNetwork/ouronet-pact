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
    (defun UC_BenDptfTotalKey:string (beneficiary-id:string dptf-id:string))
    (defun UC_BenDpsfNonceTotalKey:string (beneficiary-id:string dpsf-id:string nonce:integer))
    (defun UC_BenDpnfNonceTotalKey:string (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UC_BenDpsfAnkMetaKey:string (beneficiary-id:string dpsf-id:string))
    (defun UC_BenDpnfAnkMetaKey:string (beneficiary-id:string dpnf-id:string))
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
    ;;  [UR] AQP|BenDptfTotal (AQP|T|BenDptfTotal) — cross-pool ANK rollup
    (defun UR_AQP|BenDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string))
    (defun UR_AQP|BenDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string))
    (defun URC_BenDptfAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string))
    ;;
    ;;  [UR] AQP|BenDpsfNonceTotal + AQP|BenDpsfAnkMeta — cross-pool DPSF ANK rollup
    (defun UR_AQP|BenDpsfNonceAmount:integer (beneficiary-id:string dpsf-id:string nonce:integer))
    (defun UR_AQP|BenDpsfLastAnkSyncCount:integer (beneficiary-id:string dpsf-id:string))
    (defun URD_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfHasStake:bool (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfAnchorsNeedSync:bool (beneficiary-id:string dpsf-id:string))
    ;;
    ;;  [UR] AQP|BenDpnfNonceTotal + AQP|BenDpnfAnkMeta — cross-pool DPNF ANK rollup
    (defun UR_AQP|BenDpnfNonceAmount:integer (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string))
    (defun URD_AQP|BenDpnfActiveNonceSupplies:[object] (beneficiary-id:string dpnf-id:string))
    (defun URC_BenDpnfHasStake:bool (beneficiary-id:string dpnf-id:string))
    (defun URC_BenDpnfAnchorsNeedSync:bool (beneficiary-id:string dpnf-id:string))
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
    ;;  [C] — stake/unstake recipes live in FVT::C_*StakeFlow (Talos AQP-POOL|C_Stake* shells).
    (defun C_SyncTrueFungibleAnchors:object{IgnisCollectorV1.OutputCumulator}
        (patron:string beneficiary-id:string dptf-id:string)
    )
    (defun C_SyncCollectableAnchors:object{IgnisCollectorV1.OutputCumulator}
        (patron:string beneficiary-id:string collectable-id:string son:bool)
    )
    ;;  Remaining C_* here: C_VacatePool (see README_AQP.md).
    ;;
    ;;  [URC]  internal stake helpers (cross-module read from SCR XE_Apply*StakeDelta; FVT recipe cap)
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
    (defun URC_CollectableUnstakeBeneficiaryId:string
        (pool-id:string collectable-id:string son:bool owner-id:string nonce:integer)
    )
    (defun URC_StakeCollectablePoolClassOk:bool (pool-id:string son:bool))
    (defun URC_StakeCollectableMatchesPool:bool (pool-id:string collectable-id:string))
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun URC_VacateBatchLegParityOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
    )
    (defun URC_VacateBatchNonceTotalOk:bool (nonces-array:[[integer]]))
    (defun URC_VacateCollectableLegBeneficiaryOk:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer])
    )
    (defun URC_VacateCollectableNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun URC_VacateCollectableRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
    )
    ;;
    ;;  [XE]  cross-module forward (FVT::C_*StakeFlow · canonical phase 1 custody)
    (defun XE_TrueFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_OrtoFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_OrtoFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_CollectableTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
    )
    (defun XE_CollectablePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
    )
    (defun XE_CollectableBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
    )
    (defun XE_TrueFungibleVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
    )
    (defun XE_OrtoFungibleVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
        )
    )
    (defun XE_OrtoFungibleVacateBulkTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
    )
    (defun XE_CollectableVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    (defun XE_SetBenDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
    (defun XE_SetBenCollectableAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
    )
    (defun XE_TrueFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_OrtoFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
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
                (ref-P|DPDC-T:module{OuronetPolicyV1} DPDC-T)
                ;;
                (mg:guard (create-capability-guard (P|AQP|CALLER)))
            )
            ;; AQP-POOL → TFT: XI_1|TransferDptfPoolCustody calls TFT::C_Transfer; TFT UEV_IMC requires this guard.
            (ref-P|TFT::P|A_AddIMP mg)
            ;; AQP-POOL → DPOF: XI_1|TransferDpofPoolCustody calls DPOF::C_Transfer; vacate batch uses XI_1|BulkTransferDpofPoolCustody → DPOF::C_BulkTransfer.
            (ref-P|DPOF::P|A_AddIMP mg)
            ;; AQP-POOL → DPDC-T: XI_1|TransferCollectablePoolCustody calls DPDC-T::C_Transfer.
            (ref-P|DPDC-T::P|A_AddIMP mg)
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
    ;;Ben × asset rollups (pool-agnostic totals for ANK sync — see README_AQP.md § Anchor sync)
    (defschema AQP|BenDptfTotal
        @doc "Cross-pool rollup: total DPTF staked by one beneficiary on one exact dptf-id leg \
            \ (native X and F|X are separate rows). Maintained on every TF stake/unstake POOL leg \
            \ (FVT::C_TrueFungibleStakeFlow → XE_TrueFungiblePoolCustody → XI bump). Input to \
            \ ANK::XE_UpdateTrueFungibleUserAnchorValues without scanning AQP|T|DPTFTracker keys. \
            \ last-ank-sync-count stores AQP-ANK::UR_AA|AnchorsActive(dptf-id) after the last successful \
            \ anchor refresh; URC_BenDptfAnchorsNeedSync compares it to the live count so the UI can \
            \ prompt C_SyncTrueFungibleAnchors when new anchors are issued after stake. Per-pool detail \
            \ remains in AQP|T|DPTFTracker; this row is the single O(1) read for anchor promile."
        total-balance:decimal                                           ;;[M] Sum of tracker balances for (beneficiary, dptf-id) across all pools
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last C_Sync* / stake ANK leg (0 = never synced)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dptf-id:string                                                  ;;[.] Exact DPTF id leg (native or F|); must match ANK ank-asset for sync call
    )
    (defschema AQP|BenDpsfNonceTotal
        @doc "Cross-pool per-nonce DPSF rollup for one beneficiary. Separate table from DPNF so SELECT inventory \
            \ does not scan NFT rows. Maintained on DPSF stake/unstake POOL legs (phase 1.3, planned). amount is \
            \ integer supply staked on that nonce across all pools; 0 means fully unstaked (row may remain)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dpsf-id:string                                                  ;;[.] DPSF collection id (ANK ank-asset for SF sync)
        nonce:integer                                                   ;;[.] DPSF nonce
    )
    (defschema AQP|BenDpnfNonceTotal
        @doc "Cross-pool per-nonce DPNF rollup for one beneficiary. Separate table from DPSF — same id string may \
            \ exist on both collections when minted in one tx, but rows live in disjoint tables. Maintained on DPNF \
            \ stake/unstake POOL legs (phase 1.3, planned)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.] DPNF collection id
        nonce:integer                                                   ;;[.] DPNF nonce
    )
    (defschema AQP|BenDpsfAnkMeta
        @doc "Per (beneficiary, dpsf-id) ANK sync metadata. last-ank-sync-count is leg-wide, not per nonce — \
            \ mirrors AQP|BenDptfTotal for TF. Maintained on stake phase 2.2 / C_SyncDpsfAnchors (planned)."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpsf-id:string                                                  ;;[.]
    )
    (defschema AQP|BenDpnfAnkMeta
        @doc "Per (beneficiary, dpnf-id) ANK sync metadata — DPNF counterpart of AQP|BenDpsfAnkMeta."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.]
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
    ;;Ben rollups (pool-agnostic; ANK sync — not a substitute for per-pool trackers)
    (deftable AQP|T|BenDptfTotal:{AQP|BenDptfTotal})                    ;;Key = <Beneficiary-ID> | <DPTF-ID>
    (deftable AQP|T|BenDpsfNonceTotal:{AQP|BenDpsfNonceTotal})          ;;Key = <Beneficiary-ID> | <DPSF-ID> | <Nonce>
    (deftable AQP|T|BenDpnfNonceTotal:{AQP|BenDpnfNonceTotal})          ;;Key = <Beneficiary-ID> | <DPNF-ID> | <Nonce>
    (deftable AQP|T|BenDpsfAnkMeta:{AQP|BenDpsfAnkMeta})                ;;Key = <Beneficiary-ID> | <DPSF-ID>
    (deftable AQP|T|BenDpnfAnkMeta:{AQP|BenDpnfAnkMeta})                ;;Key = <Beneficiary-ID> | <DPNF-ID>
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
    (defconst GAS|SYNC-TF-ANCHORS                                       50.0)
    (defconst GAS|SYNC-COLLECTABLE-ANCHORS                              50.0)
    (defconst VACATE-MAX-LEGS                                           16)
    (defconst VACATE-MAX-NONCES                                         64)
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
                (rollup-bal:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
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
    (defcap AQP|XE>COLLECTABLE-POOL-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward-only (FVT::C_CollectableStakeFlow phase 1]): DPDC::C_Transfer + tracker validation. \
            \ son=true DPSF (class-3 pool); son=false DPNF (class-4 pool)."
        (let
            (
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (class-ok:bool (URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (URC_StakeCollectableMatchesPool pool-id collectable-id))
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeNoncesSufficient
                            pool-id collectable-id son owner-id nonces nonce-amounts
                        )
                    )
                )
                (rollup-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeRollupSufficient
                            pool-id collectable-id son owner-id nonces nonce-amounts
                        )
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) scores-ok class-ok collectable-ok tracker-ok rollup-ok])
                "Invalid collectable pool custody: pool class/collectable-id or insufficient tracker balance"
            )
            (UEV_StakeCollectableLeg collectable-id son)
            (if direction
                (let
                    (
                        (ref-DPDC:module{DpdcV1} DPDC)
                    )
                    (ref-DPDC::UEV_NonceQuantityInclusionMapper owner-id collectable-id son nonces nonce-amounts)
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
    (defcap AQP|XE>TRUE-FUNGIBLE-POOL-VACATE-CUSTODY
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Forward-only (FVT::C_VacateTrueFungible phase 1.1]): forced unstake — CAP_PoolOwner; \
            \ transfer vault→owner; beneficiary-id keys tracker/rollup row for SCORE/ANK unwind only."
        (let
            (
                (staked-bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (dptf-ok:bool (URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (tracker-ok:bool (>= staked-bal amount))
                (rollup-ok:bool (>= rollup-bal amount))
            )
            (enforce
                (fold (and) true [class-ok scores-ok dptf-ok tracker-ok rollup-ok (> amount 0.0)])
                "Invalid TF pool vacate: pool class/scores/dptf-id or insufficient staked/rollup balance"
            )
            (CAP_PoolOwner pool-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>ORTO-FUNGIBLE-POOL-VACATE-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
        )
        @doc "Forward-only (FVT::C_VacateOrtoFungibleBatch phase 1.1]): forced unstake — CAP_PoolOwner; \
            \ transfer vault→owner; beneficiary-id keys tracker row for SCORE unwind only."
        (let
            (
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (class-ok:bool (URC_StakeOrtoFungiblePoolClassOk pool-id))
                (dpof-ok:bool (URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                (whole-nonce-ok:bool (URC_OrtoStakeWholeNonceAmounts dpof-id nonces nonce-amounts))
                (beneficiary-ok:bool
                    (URC_VacateOrtoLegBeneficiaryOk pool-id dpof-id owner-id beneficiary-id nonces)
                )
                (tracker-ok:bool
                    (URC_VacateOrtoNoncesSufficient
                        pool-id dpof-id owner-id beneficiary-id nonces nonce-amounts
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) scores-ok class-ok dpof-ok whole-nonce-ok beneficiary-ok tracker-ok])
                "Invalid OF pool vacate: pool class/dpof-id, whole nonces/amounts, beneficiary mismatch, or insufficient tracker balance"
            )
            (UEV_StakeOrtoFungibleDpofLeg dpof-id)
            (CAP_PoolOwner pool-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>ORTO-FUNGIBLE-POOL-VACATE-BULK-CUSTODY
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Forward-only (FVT::C_VacateOrtoFungibleBatch phase 1.1]): one DPOF::C_BulkTransfer vault→owners; \
            \ CAP_PoolOwner; beneficiary-id per leg keys tracker/SCORE unwind only."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (vault:string AQP|SC_NAME)
                (l:integer (length owner-ids))
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (class-ok:bool (URC_StakeOrtoFungiblePoolClassOk pool-id))
                (dpof-ok:bool (URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                (all-nonces:[integer]
                    (fold
                        (lambda (acc:[integer] ns:[integer])
                            (+ acc ns)
                        )
                        []
                        nonces-array
                    )
                )
                (legs-ok:bool
                    (fold
                        (and)
                        true
                        (map
                            (lambda (idx:integer)
                                (let
                                    (
                                        (owner-id:string (at idx owner-ids))
                                        (beneficiary-id:string (at idx beneficiary-ids))
                                        (nonces:[integer] (at idx nonces-array))
                                        (nonce-amounts:[decimal] (at idx nonce-amounts-array))
                                        (l-n:integer (length nonces))
                                        (l-a:integer (length nonce-amounts))
                                        (whole-nonce-ok:bool
                                            (URC_OrtoStakeWholeNonceAmounts dpof-id nonces nonce-amounts)
                                        )
                                        (beneficiary-ok:bool
                                            (URC_VacateOrtoLegBeneficiaryOk
                                                pool-id dpof-id owner-id beneficiary-id nonces
                                            )
                                        )
                                        (tracker-ok:bool
                                            (URC_VacateOrtoNoncesSufficient
                                                pool-id dpof-id owner-id beneficiary-id nonces nonce-amounts
                                            )
                                        )
                                    )
                                    (fold (and) true
                                        [(> l-n 0) (= l-n l-a) whole-nonce-ok beneficiary-ok tracker-ok]
                                    )
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
            )
            (ref-U|LST::UC_IzUnique owner-ids)
            (enforce
                (fold (and) true
                    [
                        (> l 0)
                        scores-ok
                        class-ok
                        dpof-ok
                        legs-ok
                        (> (length all-nonces) 0)
                    ]
                )
                "Invalid OF pool vacate bulk custody: pool class/dpof-id, owner legs, or vault nonces"
            )
            (UEV_StakeOrtoFungibleDpofLeg dpof-id)
            (ref-DPOF::UEV_NoncesToAccount dpof-id vault all-nonces)
            (ref-DPOF::UEV_NoncesCirculating dpof-id all-nonces)
            (CAP_PoolOwner pool-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>COLLECTABLE-POOL-VACATE-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Forward-only (FVT::C_VacateCollectableBatch phase 1.1]): forced unstake — CAP_PoolOwner; \
            \ transfer vault→owner; beneficiary-id keys tracker/rollup rows for SCORE/ANK unwind only."
        (let
            (
                (scores-ok:bool (URC_PoolHasEmployedScores pool-id))
                (class-ok:bool (URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (URC_StakeCollectableMatchesPool pool-id collectable-id))
                (beneficiary-ok:bool
                    (URC_VacateCollectableLegBeneficiaryOk
                        pool-id collectable-id son owner-id beneficiary-id nonces
                    )
                )
                (tracker-ok:bool
                    (URC_VacateCollectableNoncesSufficient
                        pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                    )
                )
                (rollup-ok:bool
                    (URC_VacateCollectableRollupSufficient
                        pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true
                    [(> l-n 0) (= l-n l-a) scores-ok class-ok collectable-ok beneficiary-ok tracker-ok rollup-ok]
                )
                "Invalid collectable pool vacate: pool class/collectable-id, beneficiary mismatch, or insufficient balance"
            )
            (UEV_StakeCollectableLeg collectable-id son)
            (CAP_PoolOwner pool-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP-ANK.AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC
        (beneficiary-id:string dptf-id:string)
        @doc "Backward-only (FVT::C_TrueFungibleStakeFlow phase 2.2]): stamp last-ank-sync-count on BenDptfTotal. \
            \ beneficiary/dptf validation here; full stake rules in FVT|C>TRUE-FUNGIBLE-STAKE-FLOW. \
            \ Composes SECURE for XE write body. Not @event — UEV_IMC on XE entry."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Pool-agnostic ANK repair for one beneficiary × dptf-id leg. Patron pays IGNIS; composes SECURE."
        @event
        (enforce
            (> (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id) 0.0)
            "No cross-pool TF stake to sync"
        )
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>SYNC-COLLECTABLE-ANCHORS
        (patron:string beneficiary-id:string collectable-id:string son:bool)
        @doc "Pool-agnostic ANK repair for DPSF (son=true) or DPNF (son=false). Patron pays IGNIS; composes SECURE."
        @event
        (enforce
            (URC_BenCollectableHasStake beneficiary-id collectable-id son)
            "No cross-pool collectable stake to sync"
        )
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeCollectableLeg collectable-id son)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC
        (beneficiary-id:string collectable-id:string son:bool)
        @doc "Backward (FVT stake phase 3 / C_SyncCollectableAnchors): stamp BenDpsfAnkMeta or BenDpnfAnkMeta."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeCollectableLeg collectable-id son)
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
    (defun UC_BenDptfTotalKey:string (beneficiary-id:string dptf-id:string)
        @doc "Composite key for AQP|T|BenDptfTotal: beneficiary-id | dptf-id."
        (concat [beneficiary-id BAR dptf-id])
    )
    (defun UC_BenDpsfNonceTotalKey:string (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpsfNonceTotal: beneficiary-id | dpsf-id | nonce."
        (concat [beneficiary-id BAR dpsf-id BAR (format "{}" [nonce])])
    )
    (defun UC_BenDpnfNonceTotalKey:string (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpnfNonceTotal: beneficiary-id | dpnf-id | nonce."
        (concat [beneficiary-id BAR dpnf-id BAR (format "{}" [nonce])])
    )
    (defun UC_BenDpsfAnkMetaKey:string (beneficiary-id:string dpsf-id:string)
        @doc "Composite key for AQP|T|BenDpsfAnkMeta: beneficiary-id | dpsf-id."
        (concat [beneficiary-id BAR dpsf-id])
    )
    (defun UC_BenDpnfAnkMetaKey:string (beneficiary-id:string dpnf-id:string)
        @doc "Composite key for AQP|T|BenDpnfAnkMeta: beneficiary-id | dpnf-id."
        (concat [beneficiary-id BAR dpnf-id])
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
    (defun UDC_AQP|BenDptfTotal:object{AQP|BenDptfTotal}
        (total:decimal sync-count:integer beneficiary-id:string dptf-id:string)
        @doc "Default beneficiary DPTF rollup row (zero total, never synced)."
        {"total-balance"        : total
        ,"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_AQP|BenDpsfNonceTotal:object{AQP|BenDpsfNonceTotal}
        (amount:integer beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Default DPSF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpsf-id"          : dpsf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpnfNonceTotal:object{AQP|BenDpnfNonceTotal}
        (amount:integer beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Default DPNF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpnf-id"          : dpnf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpsfAnkMeta:object{AQP|BenDpsfAnkMeta}
        (sync-count:integer beneficiary-id:string dpsf-id:string)
        @doc "Default DPSF ANK meta row (never synced)."
        {"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpsf-id"              : dpsf-id}
    )
    (defun UDC_AQP|BenDpnfAnkMeta:object{AQP|BenDpnfAnkMeta}
        (sync-count:integer beneficiary-id:string dpnf-id:string)
        @doc "Default DPNF ANK meta row (never synced)."
        {"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpnf-id"              : dpnf-id}
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
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (2b) BenDptfTotal \
    ;;     (2c) BenDpsf* + BenDpnf* rollups \
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
    ;; [2b] AQP|T|BenDptfTotal  (AQP|BenDptfTotal)
    (defun UR_AQP|BenDptfTotal:object{AQP|BenDptfTotal}
        (beneficiary-id:string dptf-id:string)
        @doc "Reads cross-pool DPTF stake rollup for beneficiary × dptf-id; absent row reads as zero total."
        (with-default-read AQP|T|BenDptfTotal (UC_BenDptfTotalKey beneficiary-id dptf-id)
            (UDC_AQP|BenDptfTotal 0.0 0 beneficiary-id dptf-id)
            {"total-balance"        := tb
            ,"last-ank-sync-count"  := sc
            ,"beneficiary-id"       := bid
            ,"dptf-id"              := did}
            (UDC_AQP|BenDptfTotal tb sc bid did)
        )
    )
    (defun UR_AQP|BenDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string)
        @doc "Total DPTF staked by beneficiary across all pools for this exact dptf-id leg."
        (at "total-balance" (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
    )
    (defun UR_AQP|BenDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string)
        @doc "ANK anchors-active count recorded at last anchor sync for this beneficiary × dptf-id."
        (at "last-ank-sync-count" (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
    )
    (defun URC_BenDptfAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string)
        @doc "True when beneficiary has positive cross-pool stake on dptf-id and ANK has more live anchors \
            \ than were applied at last sync — UI signal for C_SyncTrueFungibleAnchors."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (total:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (last-sync:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
            )
            (and (> total 0.0) (> live-count last-sync))
        )
    )
    ;;
    ;; [2c] AQP|T|BenDpsfNonceTotal + AQP|T|BenDpsfAnkMeta
    (defun UR_AQP|BenDpsfNonceTotal:object{AQP|BenDpsfNonceTotal}
        (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPSF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpsfNonceTotal
            (UC_BenDpsfNonceTotalKey beneficiary-id dpsf-id nonce)
            (UDC_AQP|BenDpsfNonceTotal 0 beneficiary-id dpsf-id nonce)
            {"amount"           := amt
            ,"beneficiary-id"   := bid
            ,"dpsf-id"          := did
            ,"nonce"            := n}
            (UDC_AQP|BenDpsfNonceTotal amt bid did n)
        )
    )
    (defun UR_AQP|BenDpsfNonceAmount:integer (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Staked integer supply on one DPSF nonce across all pools for (beneficiary, dpsf-id)."
        (at "amount" (UR_AQP|BenDpsfNonceTotal beneficiary-id dpsf-id nonce))
    )
    (defun UR_AQP|BenDpsfAnkMeta:object{AQP|BenDpsfAnkMeta}
        (beneficiary-id:string dpsf-id:string)
        @doc "Reads ANK sync metadata for one DPSF leg; absent row reads as never synced."
        (with-default-read AQP|T|BenDpsfAnkMeta
            (UC_BenDpsfAnkMetaKey beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta 0 beneficiary-id dpsf-id)
            {"last-ank-sync-count"  := sc
            ,"beneficiary-id"       := bid
            ,"dpsf-id"              := did}
            (UDC_AQP|BenDpsfAnkMeta sc bid did)
        )
    )
    (defun UR_AQP|BenDpsfLastAnkSyncCount:integer (beneficiary-id:string dpsf-id:string)
        @doc "ANK anchors-active count recorded at last DPSF anchor sync for (beneficiary, dpsf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
    )
    (defun URD_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string)
        @doc "Nonce × amount objects for (beneficiary, dpsf-id) where rollup amount > 0 — DPSF resync inventory."
        (let
            (
                (results
                    (filter
                        (lambda (x) (> (at "amount" x) 0))
                        (select AQP|T|BenDpsfNonceTotal ["nonce" "amount"]
                            (and?
                                (where "beneficiary-id" (= beneficiary-id))
                                (where "dpsf-id" (= dpsf-id))
                            )
                        )
                    )
                )
            )
            (if (= (length results) 0) [] results)
        )
    )
    (defun URC_BenDpsfHasStake:bool (beneficiary-id:string dpsf-id:string)
        @doc "True when beneficiary has any positive DPSF per-nonce rollup under dpsf-id."
        (> (length (URD_AQP|BenDpsfActiveNonceSupplies beneficiary-id dpsf-id)) 0)
    )
    (defun URC_BenDpsfAnchorsNeedSync:bool (beneficiary-id:string dpsf-id:string)
        @doc "True when beneficiary has active DPSF stake and ANK has more live anchors on dpsf-id than at last sync."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (last-sync:integer (UR_AQP|BenDpsfLastAnkSyncCount beneficiary-id dpsf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dpsf-id))
            )
            (and (URC_BenDpsfHasStake beneficiary-id dpsf-id) (> live-count last-sync))
        )
    )
    ;;
    ;; [2d] AQP|T|BenDpnfNonceTotal + AQP|T|BenDpnfAnkMeta
    (defun UR_AQP|BenDpnfNonceTotal:object{AQP|BenDpnfNonceTotal}
        (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPNF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpnfNonceTotal
            (UC_BenDpnfNonceTotalKey beneficiary-id dpnf-id nonce)
            (UDC_AQP|BenDpnfNonceTotal 0 beneficiary-id dpnf-id nonce)
            {"amount"           := amt
            ,"beneficiary-id"   := bid
            ,"dpnf-id"          := nid
            ,"nonce"            := n}
            (UDC_AQP|BenDpnfNonceTotal amt bid nid n)
        )
    )
    (defun UR_AQP|BenDpnfNonceAmount:integer (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Staked integer supply on one DPNF nonce across all pools for (beneficiary, dpnf-id)."
        (at "amount" (UR_AQP|BenDpnfNonceTotal beneficiary-id dpnf-id nonce))
    )
    (defun UR_AQP|BenDpnfAnkMeta:object{AQP|BenDpnfAnkMeta}
        (beneficiary-id:string dpnf-id:string)
        @doc "Reads ANK sync metadata for one DPNF leg; absent row reads as never synced."
        (with-default-read AQP|T|BenDpnfAnkMeta
            (UC_BenDpnfAnkMetaKey beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta 0 beneficiary-id dpnf-id)
            {"last-ank-sync-count"  := sc
            ,"beneficiary-id"       := bid
            ,"dpnf-id"              := nid}
            (UDC_AQP|BenDpnfAnkMeta sc bid nid)
        )
    )
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string)
        @doc "ANK anchors-active count recorded at last DPNF anchor sync for (beneficiary, dpnf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
    )
    (defun URD_AQP|BenDpnfActiveNonceSupplies:[object] (beneficiary-id:string dpnf-id:string)
        @doc "Nonce × amount objects for (beneficiary, dpnf-id) where rollup amount > 0 — DPNF resync inventory."
        (let
            (
                (results
                    (filter
                        (lambda (x) (> (at "amount" x) 0))
                        (select AQP|T|BenDpnfNonceTotal ["nonce" "amount"]
                            (and?
                                (where "beneficiary-id" (= beneficiary-id))
                                (where "dpnf-id" (= dpnf-id))
                            )
                        )
                    )
                )
            )
            (if (= (length results) 0) [] results)
        )
    )
    (defun URC_BenDpnfHasStake:bool (beneficiary-id:string dpnf-id:string)
        @doc "True when beneficiary has any positive DPNF per-nonce rollup under dpnf-id."
        (> (length (URD_AQP|BenDpnfActiveNonceSupplies beneficiary-id dpnf-id)) 0)
    )
    (defun URC_BenDpnfAnchorsNeedSync:bool (beneficiary-id:string dpnf-id:string)
        @doc "True when beneficiary has active DPNF stake and ANK has more live anchors on dpnf-id than at last sync."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (last-sync:integer (UR_AQP|BenDpnfLastAnkSyncCount beneficiary-id dpnf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dpnf-id))
            )
            (and (URC_BenDpnfHasStake beneficiary-id dpnf-id) (> live-count last-sync))
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
    (defun URC_StakeCollectablePoolClassOk:bool (pool-id:string son:bool)
        @doc "True when pool aqp-class matches son: true→3 (DPSF), false→4 (DPNF)."
        (= (UR_AQP|PoolAqpClass pool-id) (if son 3 4))
    )
    (defun URC_StakeCollectableMatchesPool:bool (pool-id:string collectable-id:string)
        @doc "True when collectable-id equals pool canonical asset-id."
        (= collectable-id (UR_AQP|PoolAssetId pool-id))
    )
    (defun URC_CollectableUnstakeBeneficiaryId:string
        (pool-id:string collectable-id:string son:bool owner-id:string nonce:integer)
        @doc "Unstake: read beneficiary-id from DPSF/DPNF tracker row. v1 uses self-stake key (beneficiary=owner)."
        (if son
            (UR_AQP|DPSFTrackerBeneficiaryId pool-id collectable-id owner-id owner-id nonce)
            (UR_AQP|DPNFTrackerBeneficiaryId pool-id collectable-id owner-id owner-id nonce)
        )
    )
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount."
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
                                (q:integer (at idx nonce-amounts))
                                (bid:string (URC_CollectableUnstakeBeneficiaryId pool-id collectable-id son owner-id n))
                                (bal:decimal
                                    (if son
                                        (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id bid n)
                                        (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id bid n)
                                    )
                                )
                            )
                            (>= bal (dec q))
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_BenCollectableHasStake:bool (beneficiary-id:string collectable-id:string son:bool)
        @doc "True when beneficiary has active cross-pool collectable rollup (son dispatches DPSF vs DPNF table)."
        (if son
            (URC_BenDpsfHasStake beneficiary-id collectable-id)
            (URC_BenDpnfHasStake beneficiary-id collectable-id)
        )
    )
    (defun URC_CollectableUnstakeRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has cross-pool Ben* nonce rollup amount ≥ unstake amount."
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
                                (q:integer (at idx nonce-amounts))
                                (bid:string (URC_CollectableUnstakeBeneficiaryId pool-id collectable-id son owner-id n))
                                (rollup-amt:integer
                                    (if son
                                        (UR_AQP|BenDpsfNonceAmount bid collectable-id n)
                                        (UR_AQP|BenDpnfNonceAmount bid collectable-id n)
                                    )
                                )
                            )
                            (>= rollup-amt q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateOrtoLegBeneficiaryOk:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each DPOF nonce tracker row beneficiary-id must equal the supplied beneficiary-id."
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
                                (row-ben:string
                                    (UR_AQP|DPOFTrackerBeneficiaryId pool-id dpof-id owner-id beneficiary-id n)
                                )
                            )
                            (= row-ben beneficiary-id)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateOrtoNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "Vacate: each DPOF nonce has tracker balance ≥ vacate amount for explicit beneficiary."
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
                                (bal:decimal
                                    (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id n)
                                )
                            )
                            (>= bal q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateBatchLegParityOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Vacate batch: parallel arrays same positive length ≤ VACATE-MAX-LEGS."
        (let
            (
                (l:integer (length owner-ids))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (<= l VACATE-MAX-LEGS)
                    (= l (length beneficiary-ids))
                    (= l (length nonces-array))
                    (= l (length amounts-array))
                ]
            )
        )
    )
    (defun URC_VacateBatchNonceTotalOk:bool (nonces-array:[[integer]])
        @doc "Vacate batch: total nonce count across legs is positive and ≤ VACATE-MAX-NONCES."
        (let
            (
                (tot:integer
                    (fold
                        (+)
                        0
                        (map
                            (lambda (ns:[integer]) (length ns))
                            nonces-array
                        )
                    )
                )
            )
            (fold (and) true [(> tot 0) (<= tot VACATE-MAX-NONCES)])
        )
    )
    (defun URC_VacateCollectableLegBeneficiaryOk:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each nonce tracker row beneficiary-id must equal the supplied beneficiary-id."
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
                                (row-ben:string
                                    (if son
                                        (UR_AQP|DPSFTrackerBeneficiaryId pool-id collectable-id owner-id beneficiary-id n)
                                        (UR_AQP|DPNFTrackerBeneficiaryId pool-id collectable-id owner-id beneficiary-id n)
                                    )
                                )
                            )
                            (= row-ben beneficiary-id)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateCollectableNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Vacate: each nonce has tracker balance ≥ vacate amount for explicit beneficiary."
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
                                (q:integer (at idx nonce-amounts))
                                (bal:decimal
                                    (if son
                                        (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                        (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                    )
                                )
                            )
                            (>= bal (dec q))
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateCollectableRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Vacate: each nonce has cross-pool Ben* nonce rollup amount ≥ vacate amount."
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
                                (q:integer (at idx nonce-amounts))
                                (rollup-amt:integer
                                    (if son
                                        (UR_AQP|BenDpsfNonceAmount beneficiary-id collectable-id n)
                                        (UR_AQP|BenDpnfNonceAmount beneficiary-id collectable-id n)
                                    )
                                )
                            )
                            (>= rollup-amt q)
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
    (defun UEV_StakeCollectableLeg (collectable-id:string son:bool)
        @doc "Validate issued DPDC collectable id via DPDC::UEV_id."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-DPDC::UEV_id collectable-id son)
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
    (defun C_SyncTrueFungibleAnchors:object{IgnisCollectorV1.OutputCumulator}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Pool-agnostic ANK repair when new TF anchors issued after stake. Reads BenDptfTotal, \
            \ refreshes promile, stamps last-ank-sync-count. SCORE boosted unchanged (lazy on next stake)."
        (UEV_IMC)
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron beneficiary-id dptf-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (total:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-ank:object{IgnisCollectorV1.OutputCumulator}
                        (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues beneficiary-id dptf-id total)
                    )
                    (ico-meta:object{IgnisCollectorV1.OutputCumulator}
                        (XE_SetBenDptfAnkSyncCount beneficiary-id dptf-id)
                    )
                    (ico-gas:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            GAS|SYNC-TF-ANCHORS AQP|SC_NAME trigger [beneficiary-id dptf-id]
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
            )
        )
    )
    (defun C_SyncCollectableAnchors:object{IgnisCollectorV1.OutputCumulator}
        (patron:string beneficiary-id:string collectable-id:string son:bool)
        @doc "Pool-agnostic ANK repair for DPSF (son=true) or DPNF (son=false). Reads Ben* nonce rollup, \
            \ absolute resync via AQP-ANK::XE_Resync*, stamps Ben*AnkMeta. Talos splits SF/NF shells."
        (UEV_IMC)
        (with-capability (AQP|C>SYNC-COLLECTABLE-ANCHORS patron beneficiary-id collectable-id son)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (supplies:[object]
                        (if son
                            (URD_AQP|BenDpsfActiveNonceSupplies beneficiary-id collectable-id)
                            (URD_AQP|BenDpnfActiveNonceSupplies beneficiary-id collectable-id)
                        )
                    )
                    (nonces:[integer] (map (at "nonce") supplies))
                    (nonce-amounts:[integer] (map (at "amount") supplies))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-ank:object{IgnisCollectorV1.OutputCumulator}
                        (if son
                            (ref-ANK::XE_ResyncSemiFungibleUserAnchorValues
                                beneficiary-id collectable-id nonces nonce-amounts
                            )
                            (ref-ANK::XE_ResyncNonFungibleUserAnchorValues
                                beneficiary-id collectable-id nonces
                            )
                        )
                    )
                    (ico-meta:object{IgnisCollectorV1.OutputCumulator}
                        (XE_SetBenCollectableAnkSyncCount beneficiary-id collectable-id son)
                    )
                    (ico-gas:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            GAS|SYNC-COLLECTABLE-ANCHORS AQP|SC_NAME trigger
                            [beneficiary-id collectable-id]
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
            )
        )
    )
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
    (defun XE_TrueFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. TFT::C_Transfer owner↔AQP|SC_NAME. Composes custody cap (validation once per tx)."
        (UEV_IMC)
        (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dptf-id amount direction)
            (XI_1|TransferDptfPoolCustody owner-id dptf-id amount direction)
        )
    )
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.2 — per-pool AQP|T|DPTFTracker row. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDptfTracker pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.3 — cross-pool AQP|T|BenDptfTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBenDptfTotal beneficiary-id dptf-id amount direction)
        )
    )
    (defun XE_TrueFungiblePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Legacy phase-1 concat (1.1 + 1.2 + 1.3). Prefer explicit XE_TrueFungible* legs in FVT recipe."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (XE_TrueFungibleTransfer pool-id owner-id beneficiary-id dptf-id amount direction)
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (XE_TrueFungiblePoolTracker pool-id owner-id beneficiary-id dptf-id amount direction)
                )
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (XE_TrueFungibleBeneficiaryRollup pool-id owner-id beneficiary-id dptf-id amount direction)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    (defun XE_OrtoFungibleTransfer:object{IgnisCollectorV1.OutputCumulator}
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
    (defun XE_OrtoFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
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
        @doc "Legacy phase-1 concat (1.1 + 1.2). Phase 1.3 N/A for OF. Prefer explicit XE_OrtoFungible* legs in FVT recipe."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (XE_OrtoFungibleTransfer pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                )
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (XE_OrtoFungiblePoolTracker pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
        )
    )
    (defun XE_CollectableTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPDC-T::C_Transfer. Composes custody cap (validation once per tx)."
        (UEV_IMC)
        (with-capability
            (AQP|XE>COLLECTABLE-POOL-CUSTODY
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
            (XI_1|TransferCollectablePoolCustody owner-id collectable-id son nonces nonce-amounts direction)
        )
    )
    (defun XE_TrueFungibleVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Phase 1.1 vacate — TFT::C_Transfer vault→owner. CAP_PoolOwner via vacate custody cap."
        (UEV_IMC)
        (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-VACATE-CUSTODY pool-id owner-id beneficiary-id dptf-id amount)
            (XI_1|TransferDptfPoolCustody owner-id dptf-id amount false)
        )
    )
    (defun XE_OrtoFungibleVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
        )
        @doc "Phase 1.1 vacate — DPOF::C_Transfer vault→owner. CAP_PoolOwner via vacate custody cap."
        (UEV_IMC)
        (with-capability
            (AQP|XE>ORTO-FUNGIBLE-POOL-VACATE-CUSTODY
                pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts
            )
            (XI_1|TransferDpofPoolCustody owner-id dpof-id nonces false)
        )
    )
    (defun XE_OrtoFungibleVacateBulkTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Phase 1.1 vacate batch — DPOF::C_BulkTransfer vault→owner-ids. CAP_PoolOwner via vacate bulk custody cap."
        (UEV_IMC)
        (with-capability
            (AQP|XE>ORTO-FUNGIBLE-POOL-VACATE-BULK-CUSTODY
                pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array
            )
            (XI_1|BulkTransferDpofPoolCustody dpof-id nonces-array AQP|SC_NAME owner-ids true)
        )
    )
    (defun XE_CollectableVacateTransfer:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Phase 1.1 vacate — DPDC-T::C_Transfer vault→owner. CAP_PoolOwner via vacate custody cap."
        (UEV_IMC)
        (with-capability
            (AQP|XE>COLLECTABLE-POOL-VACATE-CUSTODY
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts
            )
            (XI_1|TransferCollectablePoolCustody owner-id collectable-id son nonces nonce-amounts false)
        )
    )
    (defun XE_CollectablePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.2 — per-pool DPSF/DPNF tracker rows. UrStoa: N/A. P|SECURE-CALLER."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteCollectableTracker
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
        )
    )
    (defun XE_CollectableBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.3 — cross-pool BenDpsfNonceTotal / BenDpnfNonceTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBenCollectableNonceTotals
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
        )
    )
    (defun XI_1|TransferCollectablePoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (
            owner-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "DPDC-T::C_Transfer: stake owner→AQP|SC_NAME; unstake vault→owner. method=true smart-account legs."
        (require-capability (SECURE))
        (let
            (
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                ;;
                (vault:string AQP|SC_NAME)
                (sender:string (if direction owner-id vault))
                (receiver:string (if direction vault owner-id))
            )
            (ref-DPDC-T::C_Transfer [collectable-id] [son] sender receiver [nonces] [nonce-amounts] true)
        )
    )
    (defun XI_1|WriteCollectableTracker:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Map XI_1|WriteCollectableTrackerSlot — bump DPSF/DPNF tracker ±amount per index."
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
                                            (URC_CollectableUnstakeBeneficiaryId
                                                pool-id collectable-id son owner-id n
                                            )
                                        )
                                    )
                                )
                                (XI_1|WriteCollectableTrackerSlot
                                    pool-id owner-id bid collectable-id son n (at idx nonce-amounts) direction
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
    (defun XI_1|WriteCollectableTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce:integer
            amount:integer
            direction:bool
        )
        @doc "One DPSF/DPNF tracker row — read balance, write ±amount (cap validates unstake sufficiency)."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (delta:decimal (if direction (dec amount) (- (dec amount))))
            )
            (if son
                (let
                    (
                        (key:string (UC_DPSFTrackerKey pool-id collectable-id owner-id beneficiary-id nonce))
                        (bal:decimal (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (write AQP|T|DPSFTracker key
                        (UDC_AQP|SemiFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                )
                (let
                    (
                        (key:string (UC_DPNFTrackerKey pool-id collectable-id owner-id beneficiary-id nonce))
                        (bal:decimal (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (write AQP|T|DPNFTracker key
                        (UDC_AQP|NonFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                )
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|BumpBenCollectableNonceTotals:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Map XI_2|BumpBenCollectableNonceTotalSlot — bump BenDpsf* / BenDpnf* rollup ±amount per index."
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
                                            (URC_CollectableUnstakeBeneficiaryId
                                                pool-id collectable-id son owner-id n
                                            )
                                        )
                                    )
                                )
                                (XI_2|BumpBenCollectableNonceTotalSlot
                                    bid collectable-id son n (at idx nonce-amounts) direction
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
    (defun XI_2|BumpBenCollectableNonceTotalSlot:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool nonce:integer amount:integer direction:bool)
        @doc "One BenDpsfNonceTotal or BenDpnfNonceTotal row — son dispatch to XI_3 leaf."
        (require-capability (SECURE))
        (if son
            (XI_3|BumpBenDpsfNonceTotal beneficiary-id collectable-id nonce amount direction)
            (XI_3|BumpBenDpnfNonceTotal beneficiary-id collectable-id nonce amount direction)
        )
    )
    (defun XI_3|BumpBenDpsfNonceTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dpsf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpsfNonceTotal: bump amount ±supply for (beneficiary, dpsf-id, nonce) across pools."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_BenDpsfNonceTotalKey beneficiary-id dpsf-id nonce))
                (amt:integer (UR_AQP|BenDpsfNonceAmount beneficiary-id dpsf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
            )
            (write AQP|T|BenDpsfNonceTotal key
                (UDC_AQP|BenDpsfNonceTotal new-amt beneficiary-id dpsf-id nonce)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_3|BumpBenDpnfNonceTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dpnf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpnfNonceTotal: bump amount ±supply for (beneficiary, dpnf-id, nonce) across pools."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_BenDpnfNonceTotalKey beneficiary-id dpnf-id nonce))
                (amt:integer (UR_AQP|BenDpnfNonceAmount beneficiary-id dpnf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
            )
            (write AQP|T|BenDpnfNonceTotal key
                (UDC_AQP|BenDpnfNonceTotal new-amt beneficiary-id dpnf-id nonce)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
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
    (defun XI_1|BulkTransferDpofPoolCustody:object{IgnisCollectorV1.OutputCumulator}
        (dpof-id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "DPOF::C_BulkTransfer whole nonces — same arg order as C_Transfer (nonces-array, sender, receiver-lst, method). \
            \ Parent cap composes AQP-ANK.AQP|GOV for vault legs."
        (require-capability (SECURE))
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::C_BulkTransfer dpof-id nonces-array sender receiver-lst method)
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
    (defun XI_1|BumpBenDptfTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "AQP|T|BenDptfTotal: bump total-balance ±amount for (beneficiary, dptf-id) across all pools. \
            \ Read via UR_AQP|BenDptfTotal*; write only (no enforce — cap validates); preserves last-ank-sync-count. \
            \ Returns ignis|biggest via IGNIS::UDC_BiggestCumulator."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (key:string (UC_BenDptfTotalKey beneficiary-id dptf-id))
                (tb:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (sc:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (delta:decimal (if direction amount (- amount)))
                (new-total:decimal (+ tb delta))
            )
            (write AQP|T|BenDptfTotal key
                (UDC_AQP|BenDptfTotal new-total sc beneficiary-id dptf-id)
            )
            (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
        )
    )
    ;;
    ;; --- Block C · TF stake phase 2.2 (FVT::XI_RefreshTrueFungibleStakeAnchors backward) ---
    ;;   XE_SetBenDptfAnkSyncCount
    ;;
    (defun XE_SetBenDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Backward (FVT::C_TrueFungibleStakeFlow phase 2.2]): set last-ank-sync-count on BenDptfTotal \
            \ (:= AQP-ANK::UR_AA|AnchorsActive dptf-id); preserve total-balance. UEV_IMC + AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC. \
            \ Returns ignis|biggest via UDC_BiggestCumulator."
        (UEV_IMC)
        (with-capability (AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (key:string (UC_BenDptfTotalKey beneficiary-id dptf-id))
                    (row:object{AQP|BenDptfTotal} (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
                )
                (write AQP|T|BenDptfTotal key
                    (+ row {"last-ank-sync-count": live-count})
                )
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    (defun XE_SetBenCollectableAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
        @doc "Backward (FVT collectable stake phase 3 / C_SyncCollectableAnchors): stamp last-ank-sync-count \
            \ on BenDpsfAnkMeta or BenDpnfAnkMeta. UEV_IMC + AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC."
        (UEV_IMC)
        (with-capability (AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC beneficiary-id collectable-id son)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive collectable-id))
                )
                (if son
                    (let
                        (
                            (key:string (UC_BenDpsfAnkMetaKey beneficiary-id collectable-id))
                            (row:object{AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id collectable-id))
                        )
                        (write AQP|T|BenDpsfAnkMeta key
                            (+ row {"last-ank-sync-count": live-count})
                        )
                    )
                    (let
                        (
                            (key:string (UC_BenDpnfAnkMetaKey beneficiary-id collectable-id))
                            (row:object{AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id collectable-id))
                        )
                        (write AQP|T|BenDpnfAnkMeta key
                            (+ row {"last-ank-sync-count": live-count})
                        )
                    )
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
(create-table AQP|T|BenDptfTotal)
(create-table AQP|T|BenDpsfNonceTotal)
(create-table AQP|T|BenDpnfNonceTotal)
(create-table AQP|T|BenDpsfAnkMeta)
(create-table AQP|T|BenDpnfAnkMeta)
