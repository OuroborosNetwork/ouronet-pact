(interface AcquisitionPoolsV1
    (defun GOV|Demiurgoi ())
    ;;
    ;;  [UCK]
    (defun UCK_DPTFTracker:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UCK_DPOFTracker:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCK_DPSFTracker:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCK_DPNFTracker:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCK_BenDptfTotal:string (beneficiary-id:string dptf-id:string))
    (defun UCK_BenDpsfNonceTotal:string (beneficiary-id:string dpsf-id:string nonce:integer))
    (defun UCK_BenDpnfNonceTotal:string (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UCK_BenDpsfAnkMeta:string (beneficiary-id:string dpsf-id:string))
    (defun UCK_BenDpnfAnkMeta:string (beneficiary-id:string dpnf-id:string))
    ;;
    ;;  [UR] AQP|Schema (AQP|T|Pool)
    (defun URD_AQP|AllPoolIds:[string] ())
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
    (defun UR_AQP|PoolStakeEnabled:bool (pool-id:string))
    (defun UR_AQP|PoolSweepInProgress:bool (pool-id:string))
    (defun UR_AQP|PoolVacateSession:object (pool-id:string))
    (defun URD_AQP|ActiveDptfTrackerRows:[object] (pool-id:string dptf-id:string))
    (defun URD_AQP|ActiveDpofTrackerRows:[object] (pool-id:string dpof-id:string))
    (defun URD_AQP|ActivePoolDpofIds:[string] (pool-id:string))
    (defun URD_AQP|ActiveDpsfTrackerRows:[object] (pool-id:string dpsf-id:string))
    (defun URD_AQP|ActiveDpnfTrackerRows:[object] (pool-id:string dpnf-id:string))
    ;; M5 (#14) UI observability — cross-pool per-user stake legs (owner-side + beneficiary-side).
    (defun URD_AQP|DptfStakesByOwner:[object] (owner-id:string))
    (defun URD_AQP|DptfStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URD_AQP|DpofStakesByOwner:[object] (owner-id:string))
    (defun URD_AQP|DpofStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URD_AQP|DpsfStakesByOwner:[object] (owner-id:string))
    (defun URD_AQP|DpsfStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URD_AQP|DpnfStakesByOwner:[object] (owner-id:string))
    (defun URD_AQP|DpnfStakesByBeneficiary:[object] (beneficiary-id:string))
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
    (defun UR_AQP|BenDpsfActiveNonceCount:integer (beneficiary-id:string dpsf-id:string))
    (defun URD_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfHasStake:bool (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfAnchorsNeedSync:bool (beneficiary-id:string dpsf-id:string))
    ;;
    ;;  [UR] AQP|BenDpnfNonceTotal + AQP|BenDpnfAnkMeta — cross-pool DPNF ANK rollup
    (defun UR_AQP|BenDpnfNonceAmount:integer (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string))
    (defun UR_AQP|BenDpnfActiveNonceCount:integer (beneficiary-id:string dpnf-id:string))
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
    (defun C_DisablePoolStake:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string)
    )
    (defun C_EnablePoolStake:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string)
    )
    (defun XB_SetPoolStakeEnabled:string (pool-id:string enabled:bool))
    (defun XB_SetBenDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
    (defun XB_SetBenCollectableAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
    )
    ;;
    ;;  [XE]  cross-module forward (FVT::C_*StakeFlow · canonical phase 1 custody)
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
    (defun URC_PoolActiveScoreIds:[string] (pool-id:string))
    (defun URC_PoolHasEmployedScores:bool (pool-id:string))
    (defun URC_PoolStakeAdmissionOk:bool (pool-id:string))
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeTrueFungibleDptfMatchesPool:bool (pool-id:string dptf-id:string))
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeOrtoFungibleDpofMatchesPool:bool (pool-id:string dpof-id:string))
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
    )
    (defun URC_StakeCollectablePoolClassOk:bool (pool-id:string son:bool))
    (defun URC_StakeCollectableMatchesPool:bool (pool-id:string collectable-id:string))
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
    )
    ;;
    ;;  [XE]  cross-module forward (FVT::C_*StakeFlow · canonical phase 1 custody; AQP-VCT vacate session)
    (defun XE_ZeroDptfTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
    )
    (defun XE_SetVacateJobState:string
        (pool-id:string vacate-in-progress:bool initial-hash:string phase-hash:string last-hash:string)
    )
    (defun XE_SetSweepInProgress:string
        (pool-id:string flag:bool)
    )
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
    (defcap AQP|GOV ()
        @doc "Governor capability for the AQP|SC_NAME smart DALOS account (TFT/DPOF/DPDC vault send and receive). \
            \ Composed only from this module — never compose AQP-ANK.AQP|GOV cross-module."
        true
    )
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
        @doc "Reserved local remote-gov slot — forward modules register P|*|REMOTE-GOV on P|T (FVT|RemoteAqpGov, VCT|RemoteAqpGov)."
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
            ;; AQP-POOL → TFT: XE_TrueFungibleTransfer calls TFT::C_Transfer; TFT UEV_IMC requires this guard.
            (ref-P|TFT::P|A_AddIMP mg)
            ;; AQP-POOL → DPOF: XE_OrtoFungibleTransfer calls DPOF::C_Transfer; vacate batch is AQP-VCT → DPOF::C_BulkTransfer.
            (ref-P|DPOF::P|A_AddIMP mg)
            ;; AQP-POOL → DPDC-T: XE_CollectableTransfer calls DPDC-T::C_Transfer; vacate batch is AQP-VCT → DPDC-T::C_BulkTransfer.
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
    ;; [1] AQP|T|Pool
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
        stake-enabled:bool                                      ;;[M]   Gates new stakes when false; default true at issue. Unstake/vacate ignore.
        vacate-in-progress:bool                                 ;;[M]   True while AQP-VCT session active on this pool.
        sweep-in-progress:bool                                  ;;[M]   True while a re-score sweep (anchor retire/re-price) runs; blocks stake + collect (D3).
        initial-vacate-hash:string                              ;;[M]   Legacy vacate manifest hash ("" under Legs; unused).
        phase-vacate-hash:string                                ;;[M]   Current phase manifest hash after reslice ("" when idle).
        last-vacate-hash:string                                 ;;[M]   Last committed slice hash ("" when idle).
        ;;
        ;;Select Keys
        aqp-id:string
    )
    ;;
    ;; [2] AQP|T|DPTFTracker
    (defschema AQP|TrueFungibleTracker
        balance:decimal                                         ;;Store DPTF Balance Amount
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dptf-id:string                                          ;;DPTF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
    )
    ;;
    ;; [3] AQP|T|DPOFTracker
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
    ;;
    ;; [4] AQP|T|DPSFTracker
    (defschema AQP|SemiFungibleTracker
        @doc "DPSF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPSF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpsf-id:string                                          ;;DPSF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    ;;
    ;; [5] AQP|T|DPNFTracker
    (defschema AQP|NonFungibleTracker
        @doc "DPNF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPNF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpnf-id:string                                          ;;DPNF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    ;;
    ;; [8] AQP|T|BenDptfTotal
    ;;Ben × asset rollups (pool-agnostic totals for ANK sync — see README_AQP.md § Anchor sync)
    (defschema AQP|BenDptfTotal
        @doc "Cross-pool rollup: total DPTF staked by one beneficiary on one exact dptf-id leg \
            \ (native X and F|X are separate rows). Maintained on every TF stake/unstake POOL leg \
            \ (FVT::C_TrueFungibleStakeFlow → XE_TrueFungible* legs → XI bump). Input to \
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
    ;;
    ;; [9] AQP|T|BenDpsfNonceTotal
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
    ;;
    ;; [10] AQP|T|BenDpnfNonceTotal
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
    ;;
    ;; [11] AQP|T|BenDpsfAnkMeta
    (defschema AQP|BenDpsfAnkMeta
        @doc "Per (beneficiary, dpsf-id) ANK sync metadata. last-ank-sync-count is leg-wide, not per nonce — \
            \ mirrors AQP|BenDptfTotal for TF. active-nonce-count is O(1) has-stake for defcaps (no select). \
            \ Bumped when BenDpsfNonceTotal crosses 0↔positive; preserved on sync stamp."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpsfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpsf-id:string                                                  ;;[.]
    )
    ;;
    ;; [12] AQP|T|BenDpnfAnkMeta
    (defschema AQP|BenDpnfAnkMeta
        @doc "Per (beneficiary, dpnf-id) ANK sync metadata — DPNF counterpart of AQP|BenDpsfAnkMeta."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpnfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.]
    )
    ;;
    ;;{2}
    (deftable AQP|T|Pool:{AQP|Schema})                                  ;;1] Key = <Pool-ID>
    (deftable AQP|T|DPTFTracker:{AQP|TrueFungibleTracker})              ;;2] Key = <Pool-ID> | <DPTF-ID> | <Owner-ID> | <Beneficiary-ID>
    (deftable AQP|T|DPOFTracker:{AQP|OrtoFungibleTracker})              ;;3] Key = <Pool-ID> | <DPOF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPSFTracker:{AQP|SemiFungibleTracker})              ;;4] Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPNFTracker:{AQP|NonFungibleTracker})               ;;5] Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|BenDptfTotal:{AQP|BenDptfTotal})                    ;;8] Key = <Beneficiary-ID> | <DPTF-ID>
    (deftable AQP|T|BenDpsfNonceTotal:{AQP|BenDpsfNonceTotal})          ;;9] Key = <Beneficiary-ID> | <DPSF-ID> | <Nonce>
    (deftable AQP|T|BenDpnfNonceTotal:{AQP|BenDpnfNonceTotal})          ;;10] Key = <Beneficiary-ID> | <DPNF-ID> | <Nonce>
    (deftable AQP|T|BenDpsfAnkMeta:{AQP|BenDpsfAnkMeta})                ;;11] Key = <Beneficiary-ID> | <DPSF-ID>
    (deftable AQP|T|BenDpnfAnkMeta:{AQP|BenDpnfAnkMeta})                ;;12] Key = <Beneficiary-ID> | <DPNF-ID>
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
    (defconst GAS|SET-POOL-STAKE                                        500.0)
    (defconst GAS|SYNC-TF-ANCHORS                                       50.0)
    (defconst GAS|SYNC-COLLECTABLE-ANCHORS                              50.0)
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
    (defcap AQP|C>DISABLE-POOL-STAKE
        (pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). Idempotent when already false. \
            \ Unstake and vacate are unaffected."
        @event
        (CAP_PoolOwner pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>ENABLE-POOL-STAKE
        (pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). BLOCKED while a vacate session is in \
            \ progress — the owner must finish the vacate or C_AbortVacate first (audit H2 / fix #5). \
            \ Idempotent when already true; admission still requires ≥1 employed score and FVT pipeline ready."
        @event
        (enforce
            (not (UR_AQP|PoolVacateInProgress pool-id))
            "Cannot enable pool stake while a vacate is in progress; finish or abort the vacate first"
        )
        (CAP_PoolOwner pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Forward-only (FVT::C_TrueFungibleStakeFlow phase 1]): validation for XE_TrueFungibleTransfer. \
            \ Pool/beneficiary/tracker/rollup rules here; dptf-id/amount/debit via TFT::C_Transfer. \
            \ CAP_StakeOwner (owner wallet); compose P|AQP|CALLER (TFT IMC); compose AQP|GOV (AQP|SC_NAME smart account — \
            \ send and receive both require governor proof). XI_* writers have no enforce. Not @event — UEV_IMC on XE entry."
        (let
            (
                (staked-bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) true))
                (dptf-ok:bool (URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (tracker-ok:bool (or direction (>= staked-bal amount)))
                (rollup-ok:bool (or direction (>= rollup-bal amount)))
            )
            (enforce
                (fold (and) true [class-ok stake-admission-ok dptf-ok tracker-ok rollup-ok])
                "Invalid TF pool custody: pool class/stake admission/dptf-id or insufficient staked/rollup balance"
            )
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
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
        @doc "Forward-only (FVT::C_OrtoFungibleStakeFlow phase 1]): validation for XE_OrtoFungibleTransfer. \
            \ Whole-nonce DPOF::C_Transfer only. CAP_StakeOwner; compose P|AQP|CALLER + AQP|GOV for vault custody."
        (let
            (
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) true))
                (class-ok:bool (URC_StakeOrtoFungiblePoolClassOk pool-id))
                (dpof-ok:bool (URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                ;; L1 #16: no whole-nonce-amount check — DPOF::C_Transfer moves WHOLE nonces (ignores amounts),
                ;; and every caller sources nonce-amounts from UR_NoncesSupplies, so "amount == nonce supply" was a
                ;; tautology. Whole-nonce is a structural invariant of the token transfer, not a cap-level check.
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_OrtoUnstakeNoncesSufficient pool-id dpof-id owner-id beneficiary-id nonces nonce-amounts)
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) stake-admission-ok class-ok dpof-ok tracker-ok])
                "Invalid OF pool custody: pool class/dpof-id, equal nonce/amount length, stake admission, or insufficient tracker balance"
            )
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
            (UEV_StakeOrtoFungibleDpofLeg dpof-id)
            ;; M5: beneficiary account must exist BOTH directions (owner may stake for self OR a foreign beneficiary;
            ;; unstake removes that exact (owner, beneficiary) row). Mirror TF custody cap.
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
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
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) true))
                (class-ok:bool (URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (URC_StakeCollectableMatchesPool pool-id collectable-id))
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeNoncesSufficient
                            pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                        )
                    )
                )
                (rollup-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeRollupSufficient
                            pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                        )
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) stake-admission-ok class-ok collectable-ok tracker-ok rollup-ok])
                "Invalid collectable pool custody: pool class/collectable-id, stake admission, or insufficient tracker balance"
            )
            (if direction
                (let
                    (
                        (ref-DPDC:module{DpdcV1} DPDC)
                    )
                    (ref-DPDC::UEV_NonceQuantityInclusionMapper owner-id collectable-id son nonces nonce-amounts)
                )
                true
            )
            (UEV_StakeCollectableLeg collectable-id son)
            ;; M5: beneficiary account must exist BOTH directions (self OR foreign beneficiary). Mirror TF custody cap.
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
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
    ;;  [UCK]
    (defun UCK_DPTFTracker:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|DPTFTracker: pool-id | dptf-id | owner-id | beneficiary-id."
        (concat [pool-id BAR dptf-id BAR owner-id BAR beneficiary-id])
    )
    (defun UCK_DPOFTracker:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPOFTracker: pool-id | dpof-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpof-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCK_DPSFTracker:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPSFTracker: pool-id | dpsf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCK_DPNFTracker:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPNFTracker: pool-id | dpnf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCK_BenDptfTotal:string (beneficiary-id:string dptf-id:string)
        @doc "Composite key for AQP|T|BenDptfTotal: beneficiary-id | dptf-id."
        (concat [beneficiary-id BAR dptf-id])
    )
    (defun UCK_BenDpsfNonceTotal:string (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpsfNonceTotal: beneficiary-id | dpsf-id | nonce."
        (concat [beneficiary-id BAR dpsf-id BAR (format "{}" [nonce])])
    )
    (defun UCK_BenDpnfNonceTotal:string (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpnfNonceTotal: beneficiary-id | dpnf-id | nonce."
        (concat [beneficiary-id BAR dpnf-id BAR (format "{}" [nonce])])
    )
    (defun UCK_BenDpsfAnkMeta:string (beneficiary-id:string dpsf-id:string)
        @doc "Composite key for AQP|T|BenDpsfAnkMeta: beneficiary-id | dpsf-id."
        (concat [beneficiary-id BAR dpsf-id])
    )
    (defun UCK_BenDpnfAnkMeta:string (beneficiary-id:string dpnf-id:string)
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
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpsf-id:string)
        @doc "Default DPSF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpsf-id"              : dpsf-id}
    )
    (defun UDC_AQP|BenDpnfAnkMeta:object{AQP|BenDpnfAnkMeta}
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpnf-id:string)
        @doc "Default DPNF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
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
        ,"stake-enabled"        : true
        ,"vacate-in-progress"   : false
        ,"sweep-in-progress"    : false
        ,"initial-vacate-hash"  : ""
        ,"phase-vacate-hash"    : ""
        ,"last-vacate-hash"     : ""
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
    ;;{FW}  [W]
    ;; Twelve blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    ;; [1] AQP|T|Pool  (AQP|Schema)  Key = <Pool-ID>
    (defun WI_Pool:string
        (pool-id:string row:object{AQP|Schema})
        @doc "Insert AQP|T|Pool full row (issue only)."
        (require-capability (SECURE))
        (insert AQP|T|Pool pool-id row)
    )
    ;; WW_Pool — not used: issue path is WI_Pool; other paths use WU_*.
    (defun WU_Pool|StakeEnabled:string
        (pool-id:string enabled:bool)
        @doc "Update stake-enabled on AQP|T|Pool."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id {"stake-enabled": enabled})
    )
    (defun WU_Pool|SweepInProgress:string
        (pool-id:string flag:bool)
        @doc "Update sweep-in-progress on AQP|T|Pool (the re-score sweep freeze)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id {"sweep-in-progress": flag})
    )
    (defun WU_Pool|ScoreSlot:string
        (pool-id:string slot-index:integer score-id:string)
        @doc "Write score-id into one pool score slot (0=primary .. 6=septenary)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id (UC_PoolScoreSlotPatch slot-index score-id))
    )
    (defun WU4_Pool|VacateJobState:string
        (pool-id:string vacate-in-progress:bool initial-hash:string phase-hash:string last-hash:string)
        @doc "Update vacate session fields on AQP|T|Pool."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id
            {"vacate-in-progress"   : vacate-in-progress
            ,"initial-vacate-hash"  : initial-hash
            ,"phase-vacate-hash"    : phase-hash
            ,"last-vacate-hash"     : last-hash}
        )
    )
    (defun WU7_Pool|ScoreSlots:string
        (pool-id:string
            score-primary:string
            score-secondary:string
            score-tertiary:string
            score-quaternary:string
            score-quinary:string
            score-senary:string
            score-septenary:string
        )
        @doc "Replace all seven score slots on AQP|T|Pool (revoke compact path)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id
            {"score-primary"    : score-primary
            ,"score-secondary"  : score-secondary
            ,"score-tertiary"   : score-tertiary
            ,"score-quaternary" : score-quaternary
            ,"score-quinary"    : score-quinary
            ,"score-senary"     : score-senary
            ,"score-septenary"  : score-septenary}
        )
    )
    ;; WU_Pool|AqpClass — not mutable [.]
    ;; WU_Pool|AssetId — not mutable [.]
    ;; WU_Pool|ScorePrimary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSecondary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreTertiary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreQuaternary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreQuinary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSenary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSeptenary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|VacateInProgress — not used: mutates via WU4_Pool|VacateJobState.
    ;; WU_Pool|InitialVacateHash — not used: mutates via WU4_Pool|VacateJobState.
    ;; WU_Pool|PhaseVacateHash — not used: mutates via WU4_Pool|VacateJobState.
    ;; WU_Pool|LastVacateHash — not used: mutates via WU4_Pool|VacateJobState.
    ;; WU_Pool|AqpId — select key; WU not needed.
    ;;
    ;; [2] AQP|T|DPTFTracker  (AQP|TrueFungibleTracker)
    ;; WI_DPTFTracker — not used: first row touch is WW_DPTFTracker (upsert path).
    (defun WW_DPTFTracker:string
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string row:object{AQP|TrueFungibleTracker})
        @doc "Upsert full AQP|T|DPTFTracker row for (pool, dptf, owner, beneficiary)."
        (require-capability (SECURE))
        (write AQP|T|DPTFTracker (UCK_DPTFTracker pool-id dptf-id owner-id beneficiary-id) row)
    )
    ;; WU_DPTFTracker|Balance — not used: mutates via WW_DPTFTracker (full row).
    ;; WU_DPTFTracker|PoolId — select key; WU not needed.
    ;; WU_DPTFTracker|DptfId — select key; WU not needed.
    ;; WU_DPTFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPTFTracker|BeneficiaryId — select key; WU not needed.
    ;;
    ;; [3] AQP|T|DPOFTracker  (AQP|OrtoFungibleTracker)
    ;; WI_DPOFTracker — not used: first row touch is WW_DPOFTracker (upsert path).
    (defun WW_DPOFTracker:string
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AQP|OrtoFungibleTracker})
        @doc "Upsert full AQP|T|DPOFTracker row for (pool, dpof, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPOFTracker (UCK_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPOFTracker|Balance — not used: mutates via WW_DPOFTracker (full row).
    ;; WU_DPOFTracker|PoolId — select key; WU not needed.
    ;; WU_DPOFTracker|DpofId — select key; WU not needed.
    ;; WU_DPOFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPOFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPOFTracker|Nonce — select key; WU not needed.
    ;;
    ;; [4] AQP|T|DPSFTracker  (AQP|SemiFungibleTracker)
    ;; WI_DPSFTracker — not used: first row touch is WW_DPSFTracker (upsert path).
    (defun WW_DPSFTracker:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AQP|SemiFungibleTracker})
        @doc "Upsert full AQP|T|DPSFTracker row for (pool, dpsf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPSFTracker (UCK_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPSFTracker|Balance — not used: mutates via WW_DPSFTracker (full row).
    ;; WU_DPSFTracker|PoolId — select key; WU not needed.
    ;; WU_DPSFTracker|DpsfId — select key; WU not needed.
    ;; WU_DPSFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPSFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPSFTracker|Nonce — select key; WU not needed.
    ;;
    ;; [5] AQP|T|DPNFTracker  (AQP|NonFungibleTracker)
    ;; WI_DPNFTracker — not used: first row touch is WW_DPNFTracker (upsert path).
    (defun WW_DPNFTracker:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AQP|NonFungibleTracker})
        @doc "Upsert full AQP|T|DPNFTracker row for (pool, dpnf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPNFTracker (UCK_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPNFTracker|Balance — not used: mutates via WW_DPNFTracker (full row).
    ;; WU_DPNFTracker|PoolId — select key; WU not needed.
    ;; WU_DPNFTracker|DpnfId — select key; WU not needed.
    ;; WU_DPNFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPNFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPNFTracker|Nonce — select key; WU not needed.
    ;;
    ;; [8] AQP|T|BenDptfTotal  (AQP|BenDptfTotal)
    ;; WI_BenDptfTotal — not used: first row touch is WW_BenDptfTotal (upsert path).
    (defun WW_BenDptfTotal:string
        (beneficiary-id:string dptf-id:string row:object{AQP|BenDptfTotal})
        @doc "Upsert full AQP|T|BenDptfTotal row for (beneficiary, dptf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDptfTotal (UCK_BenDptfTotal beneficiary-id dptf-id) row)
    )
    (defun WU_BenDptfTotal|LastAnkSyncCount:string
        (beneficiary-id:string dptf-id:string row:object{AQP|BenDptfTotal} sync-count:integer)
        @doc "Update last-ank-sync-count on AQP|T|BenDptfTotal; preserve other fields. \
            \ <row> kept for call-site symmetry with collectable meta WU_*; write uses update (not object-+ merge)."
        (require-capability (SECURE))
        (update AQP|T|BenDptfTotal (UCK_BenDptfTotal beneficiary-id dptf-id)
            {"last-ank-sync-count": sync-count}
        )
    )
    ;; WU_BenDptfTotal|TotalBalance — not used: mutates via WW_BenDptfTotal (full row).
    ;; WU_BenDptfTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDptfTotal|DptfId — select key; WU not needed.
    ;;
    ;; [9] AQP|T|BenDpsfNonceTotal  (AQP|BenDpsfNonceTotal)
    ;; WI_BenDpsfNonceTotal — not used: first row touch is WW_BenDpsfNonceTotal (upsert path).
    (defun WW_BenDpsfNonceTotal:string
        (beneficiary-id:string dpsf-id:string nonce:integer row:object{AQP|BenDpsfNonceTotal})
        @doc "Upsert full AQP|T|BenDpsfNonceTotal row for (beneficiary, dpsf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfNonceTotal (UCK_BenDpsfNonceTotal beneficiary-id dpsf-id nonce) row)
    )
    ;; WU_BenDpsfNonceTotal|Amount — not used: mutates via WW_BenDpsfNonceTotal (full row).
    ;; WU_BenDpsfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|DpsfId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; [10] AQP|T|BenDpnfNonceTotal  (AQP|BenDpnfNonceTotal)
    ;; WI_BenDpnfNonceTotal — not used: first row touch is WW_BenDpnfNonceTotal (upsert path).
    (defun WW_BenDpnfNonceTotal:string
        (beneficiary-id:string dpnf-id:string nonce:integer row:object{AQP|BenDpnfNonceTotal})
        @doc "Upsert full AQP|T|BenDpnfNonceTotal row for (beneficiary, dpnf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfNonceTotal (UCK_BenDpnfNonceTotal beneficiary-id dpnf-id nonce) row)
    )
    ;; WU_BenDpnfNonceTotal|Amount — not used: mutates via WW_BenDpnfNonceTotal (full row).
    ;; WU_BenDpnfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|DpnfId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; [11] AQP|T|BenDpsfAnkMeta  (AQP|BenDpsfAnkMeta)
    ;; WI_BenDpsfAnkMeta — not used: first row touch is WW_BenDpsfAnkMeta (upsert path).
    (defun WW_BenDpsfAnkMeta:string
        (beneficiary-id:string dpsf-id:string row:object{AQP|BenDpsfAnkMeta})
        @doc "Upsert full AQP|T|BenDpsfAnkMeta row for (beneficiary, dpsf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCK_BenDpsfAnkMeta beneficiary-id dpsf-id) row)
    )
    (defun WU_BenDpsfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpsf-id:string row:object{AQP|BenDpsfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCK_BenDpsfAnkMeta beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpsf-id)
        )
    )
    ;; WU_BenDpsfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfAnkMeta|DpsfId — select key; WU not needed.
    ;;
    ;; [12] AQP|T|BenDpnfAnkMeta  (AQP|BenDpnfAnkMeta)
    ;; WI_BenDpnfAnkMeta — not used: first row touch is WW_BenDpnfAnkMeta (upsert path).
    (defun WW_BenDpnfAnkMeta:string
        (beneficiary-id:string dpnf-id:string row:object{AQP|BenDpnfAnkMeta})
        @doc "Upsert full AQP|T|BenDpnfAnkMeta row for (beneficiary, dpnf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCK_BenDpnfAnkMeta beneficiary-id dpnf-id) row)
    )
    (defun WU_BenDpnfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpnf-id:string row:object{AQP|BenDpnfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCK_BenDpnfAnkMeta beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpnf-id)
        )
    )
    ;; WU_BenDpnfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfAnkMeta|DpnfId — select key; WU not needed.
    ;;
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (2b) BenDptfTotal \
    ;;     (2c) BenDpsf* + BenDpnf* rollups \
    ;;     (3) OrtoFungibleTracker (4) SemiFungibleTracker (5) NonFungibleTracker
    ;;
    ;; [1] AQP|T|Pool  (AQP|Schema)  Key = <Pool-ID>
    (defun URD_AQP|AllPoolIds:[string] ()
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
    (defun UR_AQP|PoolStakeEnabled:bool (pool-id:string)
        @doc "Reads stake-enabled from pool row (true at issue; owner may disable to pause new stakes)."
        (at "stake-enabled" (read AQP|T|Pool pool-id ["stake-enabled"]))
    )
    (defun UR_AQP|PoolVacateInProgress:bool (pool-id:string)
        @doc "Point read: true while an AQP-VCT vacate session is active on this pool (audit H2 / fix #5)."
        (at "vacate-in-progress" (read AQP|T|Pool pool-id ["vacate-in-progress"]))
    )
    (defun UR_AQP|PoolSweepInProgress:bool (pool-id:string)
        @doc "Point read: true while a re-score sweep (anchor retire/re-price) is active on this pool — blocks new \
            \ stakes AND collect until the sweep completes (the aggregate-promile is in flux; sweep D3)."
        (at "sweep-in-progress" (read AQP|T|Pool pool-id ["sweep-in-progress"]))
    )
    ;;
    ;; [2] AQP|T|DPTFTracker  (AQP|TrueFungibleTracker)
    (defun UR_AQP|DPTFTracker:object{AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads DPTF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPTFTracker (UCK_DPTFTracker pool-id dptf-id owner-id beneficiary-id)
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
        (with-default-read AQP|T|BenDptfTotal (UCK_BenDptfTotal beneficiary-id dptf-id)
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
            (UCK_BenDpsfNonceTotal beneficiary-id dpsf-id nonce)
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
        @doc "Reads ANK sync metadata for one DPSF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpsfAnkMeta
            (UCK_BenDpsfAnkMeta beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta 0 0 beneficiary-id dpsf-id)
            {"last-ank-sync-count"  := sc
            ,"active-nonce-count"   := anc
            ,"beneficiary-id"       := bid
            ,"dpsf-id"              := did}
            (UDC_AQP|BenDpsfAnkMeta sc anc bid did)
        )
    )
    (defun UR_AQP|BenDpsfLastAnkSyncCount:integer (beneficiary-id:string dpsf-id:string)
        @doc "ANK anchors-active count recorded at last DPSF anchor sync for (beneficiary, dpsf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
    )
    (defun UR_AQP|BenDpsfActiveNonceCount:integer (beneficiary-id:string dpsf-id:string)
        @doc "O(1) count of positive BenDpsfNonceTotal rows — defcap-safe has-stake signal."
        (at "active-nonce-count" (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
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
        @doc "True when beneficiary has any positive DPSF per-nonce rollup under dpsf-id (O(1) meta counter)."
        (> (UR_AQP|BenDpsfActiveNonceCount beneficiary-id dpsf-id) 0)
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
            (UCK_BenDpnfNonceTotal beneficiary-id dpnf-id nonce)
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
        @doc "Reads ANK sync metadata for one DPNF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpnfAnkMeta
            (UCK_BenDpnfAnkMeta beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta 0 0 beneficiary-id dpnf-id)
            {"last-ank-sync-count"  := sc
            ,"active-nonce-count"   := anc
            ,"beneficiary-id"       := bid
            ,"dpnf-id"              := nid}
            (UDC_AQP|BenDpnfAnkMeta sc anc bid nid)
        )
    )
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string)
        @doc "ANK anchors-active count recorded at last DPNF anchor sync for (beneficiary, dpnf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
    )
    (defun UR_AQP|BenDpnfActiveNonceCount:integer (beneficiary-id:string dpnf-id:string)
        @doc "O(1) count of positive BenDpnfNonceTotal rows — defcap-safe has-stake signal."
        (at "active-nonce-count" (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
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
        @doc "True when beneficiary has any positive DPNF per-nonce rollup under dpnf-id (O(1) meta counter)."
        (> (UR_AQP|BenDpnfActiveNonceCount beneficiary-id dpnf-id) 0)
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
        (with-default-read AQP|T|DPOFTracker (UCK_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce)
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
        (with-default-read AQP|T|DPSFTracker (UCK_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce)
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
        (with-default-read AQP|T|DPNFTracker (UCK_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce)
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
    (defun URC_PoolStakeAdmissionOk:bool (pool-id:string)
        @doc "True when stake-enabled, pool has ≥1 employed score, AND no vacate session NOR re-score sweep is in \
            \ progress (stake direction only). The vacate guard blocks new stakes mid-vacate (audit H2 / fix #5); \
            \ the sweep guard blocks new stakes mid-sweep so the recompute set stays bounded (sweep D3)."
        (fold (and) true
            [
                (UR_AQP|PoolStakeEnabled pool-id)
                (URC_PoolHasEmployedScores pool-id)
                (not (UR_AQP|PoolVacateInProgress pool-id))
                (not (UR_AQP|PoolSweepInProgress pool-id))
            ]
        )
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
                            (and
                                (URC_DptfIsLpNomenclature asset-id)
                                (= (ref-DPOF::UR_Sleeping dpof-id) asset-id)
                            )
                        )
                        false
                    )
                )
            )
        )
    )
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount at the exact (owner, beneficiary) row. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
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
                                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id n))
                            )
                            (>= bal q)
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
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount at the exact (owner, beneficiary) row. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
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
    (defun URC_BenCollectableHasStake:bool (beneficiary-id:string collectable-id:string son:bool)
        @doc "True when beneficiary has active cross-pool collectable rollup (son dispatches DPSF vs DPNF table)."
        (if son
            (URC_BenDpsfHasStake beneficiary-id collectable-id)
            (URC_BenDpnfHasStake beneficiary-id collectable-id)
        )
    )
    (defun URC_CollectableUnstakeRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has cross-pool Ben* nonce rollup amount ≥ unstake amount for the beneficiary. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
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
    (defun UR_AQP|PoolVacateSession:object
        (pool-id:string)
        @doc "Pool-row vacate session observability (AQP|T|Pool fields)."
        (read AQP|T|Pool pool-id
            ["vacate-in-progress" "initial-vacate-hash" "phase-vacate-hash" "last-vacate-hash"])
    )
    (defun URD_AQP|ActiveDptfTrackerRows:[object] (pool-id:string dptf-id:string)
        @doc "Core pool read: active DPTF tracker rows (balance>0) for pool×asset."
        (filter
            (lambda (row:object) (> (at "balance" row) 0.0))
            (select AQP|T|DPTFTracker ["owner-id" "beneficiary-id" "balance"]
                (and?
                    (where "pool-id" (= pool-id))
                    (where "dptf-id" (= dptf-id))
                )
            )
        )
    )
    (defun URD_AQP|ActiveDpofTrackerRows:[object] (pool-id:string dpof-id:string)
        @doc "Core pool read: active DPOF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpof-id" (= dpof-id))
                    )
                )
            )
        )
    )
    (defun URD_AQP|ActivePoolDpofIds:[string] (pool-id:string)
        @doc "HEAVY: distinct DPOF asset-ids that hold live (balance>0) stake in a pool — on-chain satellite \
            \ enumeration for class-1 (DPTF-family) full vacate. Selects the pool's DPOF tracker rows across all \
            \ assets and returns the unique dpof-ids (native TF is vacated separately, so callers vacate each of \
            \ these as an OF leg). Table scan → use only from HEAVY (CC_/AA_) recipes."
        (distinct
            (map
                (lambda (row:object) (at "dpof-id" row))
                (filter
                    (lambda (row:object) (> (at "balance" row) 0.0))
                    (select AQP|T|DPOFTracker ["dpof-id" "balance"]
                        (where "pool-id" (= pool-id))
                    )
                )
            )
        )
    )
    (defun URD_AQP|ActiveDpsfTrackerRows:[object] (pool-id:string dpsf-id:string)
        @doc "Core pool read: active DPSF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpsf-id" (= dpsf-id))
                    )
                )
            )
        )
    )
    (defun URD_AQP|ActiveDpnfTrackerRows:[object] (pool-id:string dpnf-id:string)
        @doc "Core pool read: active DPNF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpnf-id" (= dpnf-id))
                    )
                )
            )
        )
    )
    ;;
    ;; ── M5 (#14) UI OBSERVABILITY ──────────────────────────────────────────────
    ;; Cross-pool, dirty-read `select` helpers over the trackers (no maintained tables). For a user U:
    ;;   ByOwner(U)       → every leg U staked (as owner). Split: self = rows where beneficiary-id = U;
    ;;                       staked-for-others = rows where beneficiary-id != U.  (answers query A + B)
    ;;   ByBeneficiary(U) → every leg staked FOR U (as beneficiary). gifted-by-others = rows where owner-id != U.
    ;;                       (answers query C; owner-id = U rows are U's own self-stakes)
    ;; TF is amount-based (no nonce); OF/SF/NF carry nonce + amount. Rows include pool-id + asset-id + the
    ;; counterparty so the UI can display everything and has all inputs for any unstake.
    (defun URD_AQP|DptfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all TF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dptf-id, beneficiary-id, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dptf-id": (at "dptf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPTFTracker ["pool-id" "dptf-id" "beneficiary-id" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URD_AQP|DptfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all TF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dptf-id, owner-id, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dptf-id": (at "dptf-id" row),
                 "owner-id": (at "owner-id" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPTFTracker ["pool-id" "dptf-id" "owner-id" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URD_AQP|DpofStakesByOwner:[object] (owner-id:string)
        @doc "UI: all OF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpof-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpof-id": (at "dpof-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["pool-id" "dpof-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URD_AQP|DpofStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all OF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpof-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpof-id": (at "dpof-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["pool-id" "dpof-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URD_AQP|DpsfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all SF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpsf-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpsf-id": (at "dpsf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["pool-id" "dpsf-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URD_AQP|DpsfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all SF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpsf-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpsf-id": (at "dpsf-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["pool-id" "dpsf-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URD_AQP|DpnfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all NF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpnf-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpnf-id": (at "dpnf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["pool-id" "dpnf-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URD_AQP|DpnfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all NF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpnf-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpnf-id": (at "dpnf-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["pool-id" "dpnf-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
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
            (enforce (!= slot-index -1) "score-id is not assigned to pool")
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
    (defun C_DisablePoolStake:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (UEV_IMC)
        (with-capability (AQP|C>DISABLE-POOL-STAKE pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id false)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|SET-POOL-STAKE AQP|SC_NAME trigger [pool-id])
            )
        )
    )
    (defun C_EnablePoolStake:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (UEV_IMC)
        (with-capability (AQP|C>ENABLE-POOL-STAKE pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id true)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|SET-POOL-STAKE AQP|SC_NAME trigger [pool-id])
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
                        (XB_SetBenDptfAnkSyncCount beneficiary-id dptf-id)
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
            \ absolute resync via AQP-ANK::XE_Resync*, stamps Ben*AnkMeta. Talos splits SF/NF shells. \
            \ URD inventory is read before with-capability (select illegal in defcap)."
        (UEV_IMC)
        (let
            (
                (supplies:[object]
                    (if son
                        (URD_AQP|BenDpsfActiveNonceSupplies beneficiary-id collectable-id)
                        (URD_AQP|BenDpnfActiveNonceSupplies beneficiary-id collectable-id)
                    )
                )
            )
            (with-capability (AQP|C>SYNC-COLLECTABLE-ANCHORS patron beneficiary-id collectable-id son)
                (let
                    (
                        (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        ;;
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
                            (XB_SetBenCollectableAnkSyncCount beneficiary-id collectable-id son)
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
    )
    ;;
    ;;{F7}  [X]
    ;; Depth: C_* → XI_* (depth 0) ; XE_* / XB_* → XI_1|* (depth 1). Map order = entry first.
    ;;
    ;; --- Block A · C_* pool lifecycle ---
    ;;   C_Issue → XI_IssuePool
    ;;   C_AddScore → XI_AddScoreToPool
    ;;   C_RevokeScore → XI_RevokeScoreFromPool
    ;;   C_DisablePoolStake / C_EnablePoolStake → XB_SetPoolStakeEnabled (also AQP-VCT vacate via IMC)
    ;;
    (defun XB_SetPoolStakeEnabled:string
        (pool-id:string enabled:bool)
        @doc "Write stake-enabled on AQP|T|Pool. UEV_IMC gates cross-module callers (e.g. AQP-VCT vacate). \
            \ Same-module C_Disable/C_Enable compose owner caps then call here."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|StakeEnabled (underlying W_).
            (WU_Pool|StakeEnabled pool-id enabled)
        )
        pool-id
    )
    (defun XE_SetVacateJobState:string
        (pool-id:string vacate-in-progress:bool initial-hash:string phase-hash:string last-hash:string)
        @doc "Write vacate session fields on AQP|T|Pool. UEV_IMC gates AQP-VCT caller."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU4_Pool|VacateJobState (underlying W_).
            (WU4_Pool|VacateJobState pool-id vacate-in-progress initial-hash phase-hash last-hash)
        )
        pool-id
    )
    (defun XE_SetSweepInProgress:string
        (pool-id:string flag:bool)
        @doc "Forward (re-score sweep · MTX-AQP): freeze/unfreeze a pool for a sweep — blocks new stakes AND collect \
            \ while true (D3). UEV_IMC gates the caller; P|SECURE-CALLER composes SECURE."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|SweepInProgress (underlying W_).
            (WU_Pool|SweepInProgress pool-id flag)
        )
        pool-id
    )
    (defun XI_IssuePool:string
        (pool-id:string aqp-class:integer asset-id:string)
        @doc "Insert AQP|T|Pool under SECURE (from AQP|C>ISSUE-POOL). Write only; C_Issue builds IGNIS."
        ;; SECURE: granted by WI_Pool (underlying W_).
        (WI_Pool pool-id (UDC_AQP|Schema aqp-class asset-id pool-id))
        pool-id
    )
    (defun XI_AddScoreToPool:string
        (pool-id:string score-id:string slot-index:integer)
        @doc "Write score-id into the first free slot (0=primary .. 6=septenary). Under SECURE from AQP|C>ADD-SCORE."
        ;; SECURE: granted by WU_Pool|ScoreSlot (underlying W_).
        (WU_Pool|ScoreSlot pool-id slot-index score-id)
        score-id
    )
    (defun XI_RevokeScoreFromPool:string
        (pool-id:string slot-index:integer)
        @doc "Remove score at slot-index and compact higher slots down (0=primary .. 6=septenary). Under SECURE from AQP|C>REVOKE-SCORE."
        ;; SECURE: granted by WU7_Pool|ScoreSlots (underlying W_).
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
            (WU7_Pool|ScoreSlots pool-id
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
    )
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.2 — per-pool AQP|T|DPTFTracker row. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    (defun XE_ZeroDptfTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "IMC: zero one AQP|T|DPTFTracker row (write-only). Called from AQP-VCT vacate."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|ZeroDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id)
        )
    )
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.3 — cross-pool AQP|T|BenDptfTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBenDptfTotalSlot pool-id owner-id beneficiary-id dptf-id amount direction)
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
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: write/remove the exact (owner, beneficiary) tracker row BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|WriteDpofTrackerSlot
                                    pool-id owner-id beneficiary-id dpof-id (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
            )
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
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: write/remove the exact (owner, beneficiary) tracker row BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|WriteCollectableTrackerSlot
                                    pool-id owner-id beneficiary-id collectable-id son (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
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
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: bump/unbump the exact beneficiary rollup slot BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|BumpBenCollectableNonceTotalSlot
                                    beneficiary-id collectable-id son (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
            )
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
        ;; SECURE: granted by WW_DPSFTracker / WW_DPNFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (delta:decimal (if direction (dec amount) (- (dec amount))))
            )
            (if son
                (let
                    (
                        (bal:decimal (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (WW_DPSFTracker pool-id collectable-id owner-id beneficiary-id nonce
                        (UDC_AQP|SemiFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                )
                (let
                    (
                        (bal:decimal (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (WW_DPNFTracker pool-id collectable-id owner-id beneficiary-id nonce
                        (UDC_AQP|NonFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                )
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|BumpBenCollectableNonceTotalSlot:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool nonce:integer amount:integer direction:bool)
        @doc "One BenDpsfNonceTotal or BenDpnfNonceTotal row — son dispatch to XI_2 leaf."
        ;; SECURE: granted by XI_2|BumpBenDpsfNonceTotal / XI_2|BumpBenDpnfNonceTotal (underlying W_).
        (if son
            (XI_2|BumpBenDpsfNonceTotal beneficiary-id collectable-id nonce amount direction)
            (XI_2|BumpBenDpnfNonceTotal beneficiary-id collectable-id nonce amount direction)
        )
    )
    (defun XI_2|BumpBenDpsfNonceTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dpsf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpsfNonceTotal: bump amount ±supply for (beneficiary, dpsf-id, nonce) across pools. \
            \ Also bumps BenDpsfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpsfNonceTotal / WW_BenDpsfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpsfNonceAmount beneficiary-id dpsf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
                (sc:integer (at "last-ank-sync-count" meta))
                (anc:integer (at "active-nonce-count" meta))
                (new-anc:integer
                    (if (and (= amt 0) (> new-amt 0))
                        (+ anc 1)
                        (if (and (> amt 0) (= new-amt 0))
                            (- anc 1)
                            anc
                        )
                    )
                )
            )
            (WW_BenDpsfNonceTotal beneficiary-id dpsf-id nonce
                (UDC_AQP|BenDpsfNonceTotal new-amt beneficiary-id dpsf-id nonce)
            )
            (if (!= new-anc anc)
                (WW_BenDpsfAnkMeta beneficiary-id dpsf-id
                    (UDC_AQP|BenDpsfAnkMeta sc new-anc beneficiary-id dpsf-id)
                )
                true
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_2|BumpBenDpnfNonceTotal:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dpnf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpnfNonceTotal: bump amount ±supply for (beneficiary, dpnf-id, nonce) across pools. \
            \ Also bumps BenDpnfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpnfNonceTotal / WW_BenDpnfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpnfNonceAmount beneficiary-id dpnf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
                (sc:integer (at "last-ank-sync-count" meta))
                (anc:integer (at "active-nonce-count" meta))
                (new-anc:integer
                    (if (and (= amt 0) (> new-amt 0))
                        (+ anc 1)
                        (if (and (> amt 0) (= new-amt 0))
                            (- anc 1)
                            anc
                        )
                    )
                )
            )
            (WW_BenDpnfNonceTotal beneficiary-id dpnf-id nonce
                (UDC_AQP|BenDpnfNonceTotal new-amt beneficiary-id dpnf-id nonce)
            )
            (if (!= new-anc anc)
                (WW_BenDpnfAnkMeta beneficiary-id dpnf-id
                    (UDC_AQP|BenDpnfAnkMeta sc new-anc beneficiary-id dpnf-id)
                )
                true
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|WriteDptfTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|DPTFTracker row — read balance, write ±amount (cap validates unstake sufficiency)."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker new-bal pool-id dptf-id owner-id beneficiary-id)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|ZeroDptfTrackerSlot:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "Vacate V3: write AQP|T|DPTFTracker balance=0 without balance read."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    (defun XI_1|BumpBenDptfTotalSlot:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|BenDptfTotal row — bump total-balance ±amount; preserve last-ank-sync-count."
        ;; SECURE: granted by WW_BenDptfTotal (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (tb:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (sc:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (delta:decimal (if direction amount (- amount)))
                (new-total:decimal (+ tb delta))
            )
            (WW_BenDptfTotal beneficiary-id dptf-id
                (UDC_AQP|BenDptfTotal new-total sc beneficiary-id dptf-id)
            )
            (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
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
        ;; SECURE: granted by WW_DPOFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id nonce))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce
                (UDC_AQP|OrtoFungibleTracker new-bal pool-id dpof-id owner-id beneficiary-id nonce)
            )
            (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
        )
    )
    ;;
    ;; --- Block C · TF stake phase 2.2 (FVT::XI_RefreshTrueFungibleStakeAnchors backward) ---
    ;;   XB_SetBenDptfAnkSyncCount
    ;;
    (defun XB_SetBenDptfAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Backward (FVT::C_TrueFungibleStakeFlow phase 2.2]): set last-ank-sync-count on BenDptfTotal \
            \ (:= AQP-ANK::UR_AA|AnchorsActive dptf-id); preserve total-balance. UEV_IMC + AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC. \
            \ Same-module C_SyncTrueFungibleAnchors and cross-module FVT::XI_RefreshTrueFungibleStakeAnchors call here."
        (UEV_IMC)
        (with-capability (AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (row:object{AQP|BenDptfTotal} (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
                )
                ;; SECURE: granted by WU_BenDptfTotal|LastAnkSyncCount (underlying W_).
                (WU_BenDptfTotal|LastAnkSyncCount beneficiary-id dptf-id row live-count)
                (ref-IGNIS::UDC_BiggestCumulator AQP|SC_NAME)
            )
        )
    )
    (defun XB_SetBenCollectableAnkSyncCount:object{IgnisCollectorV1.OutputCumulator}
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
                            (row:object{AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpsfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpsfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
                    )
                    (let
                        (
                            (row:object{AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpnfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpnfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
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
(create-table AQP|T|BenDptfTotal)
(create-table AQP|T|BenDpsfNonceTotal)
(create-table AQP|T|BenDpnfNonceTotal)
(create-table AQP|T|BenDpsfAnkMeta)
(create-table AQP|T|BenDpnfAnkMeta)